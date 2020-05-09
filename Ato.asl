state("Ato", "v1.0")
{
	int room : 0x006C2DB8;
	double gameTimer : 0x004A1164, 0x00, 0x2C, 0x10, 0x120, 0x80;
	double phase : 0x004A1164, 0x00, 0x2C, 0x10, 0x120, 0x60;
	double orb1 : 0x004B2780, 0x2C, 0x10, 0x888, 0x10, 0x44, 0x04, 0x00;
	double orb2 : 0x004B2780, 0x2C, 0x10, 0x888, 0x10, 0x44, 0x04, 0x10;
	double orb3 : 0x004B2780, 0x2C, 0x10, 0x888, 0x10, 0x44, 0x04, 0x20;
	double demonblade : 0x004B38B4, 0x24, 0x08, 0x50, 0x14, 0x30, 0xA98, 0x00, 0x04, 0x04, 0x1E0;
	double win : 0x004B2780, 0x2C, 0x10, 0x120, 0x00, 0x04, 0x04, 0x200;
	double introCutscene : 0x004A1164, 0x00, 0x2C, 0x10, 0x120, 0x00, 0x44, 0x04, 0x00;
}

startup
{
	settings.Add("autostart", true, "Auto-start when starting a new file.");
	settings.Add("split_phase", true, "Split after destruction cutscene.");
	settings.Add("split_orb1", true, "Split on collecting blue orb.");
	settings.Add("split_orb2", true, "Split on collecting pink orb.");
	settings.Add("split_orb3", true, "Split on collecting yellow orb.");
	settings.Add("split_demonblade", true, "Split on collecting demon blade.");

	Action<string> DebugOutput = (text) => {
		print("[Autosplitter] "+text);
	};
	vars.DebugOutput = DebugOutput;
	
	// Keep track of total run based on game time. (Stored in milliseconds)
	vars.savedTime = 0;
	
	// Important room numbers for splitting
	vars.menuRoom = 5;
	vars.introRoom = 6;
	vars.finalBossRoom = 263;
}

init
{
	int moduleSize = modules.First().ModuleMemorySize;
	vars.DebugOutput("Size: " + moduleSize);
	if (moduleSize == 7593984)
	{
		version = "v1.0";
	}
	vars.DebugOutput("INITIALIZED with version: " + version);
}

exit
{
	timer.IsGameTimePaused = true;
}

update
{
	// Disable if version not detected
	if (version == "")
		return false;
	
	// This can happen if the run is reset
	if (timer.CurrentPhase == TimerPhase.NotRunning && vars.savedTime > 0)
	{
		vars.savedTime = 0;
	}
}

start
{
	if (settings["autostart"] && current.room == vars.introRoom && old.room == vars.menuRoom && current.introCutscene == 0)
	{
		vars.DebugOutput("Timer started");
		return true;
	}
}

split
{
	// Don't split on main menu.
	if (current.room == vars.menuRoom)
	{
		return false;
	}

	// This should happen at room 11 just after the main boss defeats you and takes your child
	if (settings["split_phase"] && current.phase == 1 && old.phase == 0)
	{
		vars.DebugOutput("Phase change split.");
		return true;
	}
	
	// Split on orb collection if relevant setting is on.
	if ((settings["split_orb1"] && current.orb1 == 1 && old.orb1 == 0) ||
		(settings["split_orb2"] && current.orb2 == 1 && old.orb2 == 0) ||
		(settings["split_orb3"] && current.orb3 == 1 && old.orb3 == 0))
	{
		vars.DebugOutput("Orb collected split.");
		return true;
	}
	
	// Split on demonblade collection if relevant setting is on.
	if (settings["split_demonblade"] && current.demonblade == 1 && old.demonblade == 0)
	{
		vars.DebugOutput("Demonblade collected split.");
		return true;
	}

	// Split on game finish. Only works if this is the first time the game has been won with the current save file.
	if (current.room == vars.finalBossRoom && current.win == 1 && old.win == 0)
	{
		vars.DebugOutput("Game finish split.");
		return true;
	}
}

isLoading
{
    return current.room <= vars.introRoom;
}

gameTime
{
	// Pause game time while on main menu. This is to prevent timer jumps when loading save file.
	if (current.room <= vars.menuRoom)
	{
		timer.SetGameTime(new TimeSpan(0));
		return TimeSpan.FromMilliseconds(vars.savedTime);
	}

	// gameTime is frames rendered. Game runs at 60 fps
	double ms = current.gameTimer * (1000d / 60d);
	double oldMs = old.gameTimer * (1000d / 60d);
	vars.DebugOutput("Ms: " + ms.ToString());
	vars.DebugOutput((ms - oldMs).ToString());
	if (ms > oldMs)
	{
		vars.savedTime += ms - oldMs;
	}

	// Game display rounds up to the nearest hundredth, although a frame is much longer
	// so such precision doesn't really matter. But it looks more consistent.
	return TimeSpan.FromMilliseconds(Math.Round(vars.savedTime / 10d) * 10d);
}