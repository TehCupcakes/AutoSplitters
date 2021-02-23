// Latest version should always be at top of file so it is default!
state("Frog Hop", "2.0.0.0")
{
	int room : 0x006EFE10;
	double gameTimer : 0x004CE070, 0x00, 0x2C, 0x10, 0xC24, 0x00;
	double isPaused : 0x004E0AB0, 0x3F0, 0x50, 0x2C, 0x10, 0x00, 0x0450;
	double levelComplete : 0x004E0AB0, 0x504, 0x30, 0x2C, 0x10, 0x00, 0x370;
	double gemCount : 0x004E0AB0, 0x504, 0x30, 0x2C, 0x10, 0x00, 0x430;
	double gem1 : 0x006FCAF8, 0x828, 0x6C, 0x00;
	double gem2 : 0x006FCAF8, 0x828, 0x6C, 0x10;
	double gem3 : 0x006FCAF8, 0x828, 0x6C, 0x20;
	double gem4 : 0x006FCAF8, 0x828, 0x6C, 0x30;
	double gem5 : 0x006FCAF8, 0x828, 0x6C, 0x40;
}

state("Frog Hop", "v1.03")
{
	int room : 0x00617EA0;
	double gameTimer : 0x0040794C, 0x44, 0x10, 0xA00, 0x00;
	double isPaused : 0x003F8F44, 0x00, 0x44, 0x10, 0x28, 0x00;
	double levelComplete : 0x003F8F44, 0x00, 0x44, 0x10, 0x3C4, 0x00;
	double gemCount : 0x003F8F44, 0x00, 0x44, 0x10, 0xA30, 0x00;
	double gem1 : 0x003F8F44, 0x00, 0x44, 0x10, 0xA54, 0x00, 0x04, 0x04, 0x00;
	double gem2 : 0x003F8F44, 0x00, 0x44, 0x10, 0xA54, 0x00, 0x04, 0x04, 0x10;
	double gem3 : 0x003F8F44, 0x00, 0x44, 0x10, 0xA54, 0x00, 0x04, 0x04, 0x20;
	double gem4 : 0x003F8F44, 0x00, 0x44, 0x10, 0xA54, 0x00, 0x04, 0x04, 0x30;
	double gem5 : 0x003F8F44, 0x00, 0x44, 0x10, 0xA54, 0x00, 0x04, 0x04, 0x40;
}

startup
{
	settings.Add("autostart", true, "Auto-start at World Map");
	settings.SetToolTip("autostart", "By default will only start on a new file.");
	settings.Add("notnew", false, "Even if not a new file", "autostart");
	
	settings.Add("100percent", false, "100%");
	settings.SetToolTip("100percent", "Will only split after you complete a level with all gems.");

	settings.Add("world_1", true, "World 1");
	settings.Add("world_2", true, "World 2");
	settings.Add("world_3", true, "World 3");
	settings.Add("world_4", true, "World 4");
	settings.Add("world_5", true, "World 5");

	settings.CurrentDefaultParent = "world_1";
	settings.Add("level_15", true, "World 1-1");
	settings.Add("level_22", true, "World 1-2");
	settings.Add("level_26", true, "World 1-3 (Bottom)");
	settings.SetToolTip("level_26", "NOTE: Having multiple branches checked does not required you to complete them. It simply will cause a split at the end of the level if it is checked. You don't have to disable anything for Any% runs.");
	settings.Add("level_32", true, "World 1-3 (Top)");
	settings.SetToolTip("level_32", "NOTE: Having multiple branches checked does not required you to complete them. It simply will cause a split at the end of the level if it is checked. You don't have to disable anything for Any% runs.");
	settings.Add("level_36", true, "World 1-4");

	settings.CurrentDefaultParent = "world_2";
	settings.Add("level_42", true, "World 2-1");
	settings.Add("level_47", true, "World 2-2");
	settings.Add("level_52", true, "World 2-3 (Top)");
	settings.Add("level_56", true, "World 2-3 (Bottom)");
	settings.Add("level_60", true, "World 2-4");
	settings.Add("level_63", true, "World 2-5");

	settings.CurrentDefaultParent = "world_3";
	settings.Add("level_67", true, "World 3-1");
	settings.Add("level_70", true, "World 3-2 (Left)");
	settings.Add("level_74", true, "World 3-2 (Right)");
	settings.Add("level_77", true, "World 3-3");
	settings.Add("level_82", true, "World 3-4");
	settings.Add("level_87", true, "World 3-5");
	
	settings.CurrentDefaultParent = "world_4";
	settings.Add("level_90", true, "World 4-1");
	settings.Add("level_96", true, "World 4-2 (Left)");
	settings.Add("level_102", true, "World 4-2 (Middle)");
	settings.Add("level_107", true, "World 4-2 (Right)");
	settings.Add("level_111", true, "World 4-3");
	settings.Add("level_118", true, "World 4-4");
	
	settings.CurrentDefaultParent = "world_5";
	settings.Add("level_119", true, "World 5-1");
	settings.Add("level_126", true, "World 5-2 (Left)");
	settings.Add("level_132", true, "World 5-2 (Right)");
	settings.Add("level_139", true, "World 5-3");
	settings.Add("level_145", true, "World 5-4");
	settings.Add("level_160", true, "World 5-5");
	
	settings.CurrentDefaultParent = null;
	settings.Add("outro", true, "Meet Jumpy");
	settings.SetToolTip("outro", "After the final boss and before the credits. This is the scene where Hoppy meets up with Jumpy.");

	Action<string> DebugOutput = (text) => {
		print("[Autosplitter] "+text);
	};
	vars.DebugOutput = DebugOutput;
	
	// Frog Hop doesn't really track levels; it just has room IDs which are kind of weird...
	// We'll track the level when it starts so we don't have to check multiple room IDs in split.
	vars.level = 0;
	
	// This is a constant. World map is special because we use it to detect several things.
	vars.worldMapId = 6; // Might be different in different version?
	
	// Keep track of total run based on game time. (Stored in milliseconds)
	vars.savedTime = 0;
}

init
{
	int moduleSize = modules.First().ModuleMemorySize;
	if (moduleSize == 6631424)
	{
		version = "v1.03";
	}
	else if (moduleSize == 7446528)
	{
		// looks like "2.0.0.0"
		version = modules.First().FileVersionInfo.ProductVersion;
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
	
	// Look for level start.
	if (vars.level == 0 && settings["level_" + current.room] == true)
	{
		// We could map level to our own ID, but there's no reason to really
		vars.level = current.room;
	}
	else if (current.room == vars.worldMapId)
	{
		// Reset whenever we return to the world map so we can find the next level start.
		vars.level = 0;
	}
}

start
{
	if (current.room == vars.worldMapId && settings["autostart"]
	&& (old.room == 177 || settings["notnew"]))
	{
		vars.DebugOutput("Timer started");
		return true;
	}
}

split
{
	if (current.room <= vars.worldMapId) {
		return false;
	}

	// Only trigger once, right when the level is marked complete
	if (current.levelComplete == 1 && old.levelComplete == 0 && vars.level > 0)
	{
		if (settings["level_" + vars.level])
		{
			if (settings["100percent"])
			{
				var allGems = new double[] { current.gem1, current.gem2, current.gem3, current.gem4, current.gem5 };
				if (allGems.Sum(x => x > 0 ? 1 : 0) < current.gemCount)
					return false;
			}
			
			vars.DebugOutput("Split level " + vars.level + " completed.");
			return true;
		}
	}
	// RoomID 7 = final room player has control; 164 = Stay; 171 = Leave;
	else if (
			settings["outro"] && (
				(old.room == 7 && (current.room == 164 || current.room == 171)) || // Normal finish
				current.room == 170 // Rocket finish
			)
		)
	{
		return true;
	}
}

isLoading {
    return current.room <= vars.worldMapId || current.room >= 164 || current.isPaused == 1 || current.levelComplete == 1;
}

gameTime
{
	if (current.room <= vars.worldMapId)
	{
		timer.SetGameTime(new TimeSpan(0));
		return TimeSpan.FromMilliseconds(vars.savedTime);
	}

	// gameTime is frames rendered. Game runs at 60 fps
	double ms = current.gameTimer * (1000d / 60d);
	double oldMs = old.gameTimer * (1000d / 60d);
	if (ms > oldMs)
	{
		vars.savedTime += ms - oldMs;
	}

	// Game display rounds up to the nearest hundredth, although a frame is much longer
	// so such precision doesn't really matter. But it looks more consistent.
	return TimeSpan.FromMilliseconds(Math.Round(vars.savedTime / 10d) * 10d);
}