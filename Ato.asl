state("Ato", "v1.0")
{
	int room : 0x006C2DB8;
	double gameTimer : 0x004A1164, 0x00, 0x2C, 0x10, 0x120, 0x80;
	double phase : 0x004A1164, 0x00, 0x2C, 0x10, 0x120, 0x60;
	double crystalBreak : 0x004B2780, 0x2C, 0x10, 0x120, 0x00, 0x04, 0x04, 0x430;
	double orb1 : 0x004B2780, 0x2C, 0x10, 0x888, 0x10, 0x44, 0x04, 0x00;
	double orb2 : 0x004B2780, 0x2C, 0x10, 0x888, 0x10, 0x44, 0x04, 0x10;
	double orb3 : 0x004B2780, 0x2C, 0x10, 0x888, 0x10, 0x44, 0x04, 0x20;
	double demonblade : 0x004B38B4, 0x24, 0x08, 0x50, 0x14, 0x30, 0xA98, 0x00, 0x04, 0x04, 0x1E0;
	double win : 0x004B2780, 0x2C, 0x10, 0x120, 0x00, 0x04, 0x04, 0x200;
}

startup
{
	settings.Add("autostart", true, "Auto-start when starting a new file.");
	
	settings.Add("progression_splits", true, "Progression Splits");
	settings.Add("boss_splits", false, "Boss Splits");
	// settings.Add("misc_splits", false, "Misc. Splits");

	settings.CurrentDefaultParent = "progression_splits";
	settings.Add("split_phase", true, "Split after destruction cutscene.");
	settings.Add("split_crystal", true, "Split after destroying first crystal block.");
	settings.Add("split_orb1", true, "Split on collecting blue orb.");
	settings.Add("split_orb2", true, "Split on collecting pink orb.");
	settings.Add("split_orb3", true, "Split on collecting yellow orb.");
	settings.Add("split_demonblade", true, "Split on collecting demon blade.");
	settings.Add("split_rebirth", true, "Split on defeating final boss (Rebirth.)");
	
	settings.CurrentDefaultParent = "boss_splits";
	settings.Add("boss_0", true, "Rogue");
	settings.Add("boss_1", true, "Jin");
	settings.Add("boss_2", true, "Guardian");
	settings.Add("boss_3", true, "Ninja");
	settings.Add("boss_4", true, "Acolyte");
	settings.Add("boss_5", true, "Bandit");
	settings.Add("boss_6", true, "Geisha");
	settings.Add("boss_7", true, "Berserker");
	settings.Add("boss_8", true, "Sentinel");
	settings.Add("boss_9", true, "Samurai");
	settings.Add("boss_10", true, "Warden");
	settings.Add("boss_11", true, "Twins");
	settings.Add("boss_12", true, "Shadow Jin");
	settings.Add("boss_13", true, "Phantom Shin");
	settings.Add("boss_14", true, "Vagrant");
	settings.Add("boss_15", true, "Mother");
	settings.Add("boss_16", true, "Father");
	settings.Add("boss_17", true, "Child");
	settings.Add("boss_18", true, "Ancient Warrior");
	settings.Add("boss_19", true, "Yari");
	settings.Add("boss_20", true, "Deceiver");
	settings.Add("boss_21", true, "Blameless");
	settings.Add("boss_22", true, "Cross Blade");
	settings.Add("boss_23", true, "Dagger Man");
	settings.Add("boss_24", true, "Turtle");
	settings.Add("boss_25", true, "Champ");
	settings.Add("boss_26", true, "Tiny Warrior");
	settings.Add("boss_27", true, "Archer");
	settings.Add("boss_28", true, "Tempest");
	settings.Add("boss_29", true, "Monk");
	settings.Add("boss_30", true, "Leader");
	settings.Add("boss_31", true, "Demon");
	settings.Add("boss_owl", true, "Owl");
	
	/* TODO: Implement these
	settings.CurrentDefaultParent = "misc_splits";
	settings.Add("split_scroll", true, "Ability Scroll");
	settings.Add("split_talisman", true, "Talismans");
	settings.Add("split_coin", true, "Coins");
	settings.Add("split_rune", true, "Runes");
	settings.Add("split_magic", true, "Magic Bar");
	*/

	Action<string> DebugOutput = (text) => {
		print("[Autosplitter] "+text);
	};
	vars.DebugOutput = DebugOutput;
	
	// Set up memory watchers for boss splits. Since they're sequential, it's easier to do in a loop than one by one.
	vars.GetWatchers = (Func<Dictionary<string, MemoryWatcher>>)(() => {
		var dict = new Dictionary<string, MemoryWatcher>();
		for (int i = 0; i <= 31; i++)
		{
			var watcher = new MemoryWatcher<double>(new DeepPointer(0x004B2780, 0x2C, 0x10, 0x120, 0x00, 0x04, 0x04, (0x10 * i)));
			dict.Add("boss_" + i.ToString(), watcher);
		}
		dict.Add("boss_owl", new MemoryWatcher<double>(new DeepPointer(0x004B2780, 0x2C, 0x10, 0x120, 0x00, 0x04, 0x04, 0x570)));
		return dict;
	});
	
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
		// Note: Subsequent patches may be the same size, so assume this is v1.0+ until module size changes
		version = "v1.0";
	}
	else
	{
		return;
	}
	vars.DebugOutput("INITIALIZED with version: " + version);
	
	vars.bossWatchers = vars.GetWatchers();
	vars.DebugOutput("Boss watcher count: " + vars.bossWatchers.Count.ToString());
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
	
	foreach (var currentWatcher in vars.bossWatchers)
	{
		currentWatcher.Value.Update(game);
	}
}

start
{
	if (settings["autostart"] && current.room >= vars.introRoom && old.room == vars.menuRoom && current.gameTimer == 0)
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
	
	if (settings["split_crystal"] && current.crystalBreak == 1 && old.crystalBreak == 0)
	{
		vars.DebugOutput("Crystal break split.");
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
	if (settings["split_rebirth"] && current.room == vars.finalBossRoom && current.win == 1 && old.win == 0)
	{
		vars.DebugOutput("Game finish split.");
		return true;
	}
	
	// Split on each boss if the appropriate setting is activated
	foreach (KeyValuePair<string, MemoryWatcher> kvp in vars.bossWatchers)
	{
		double oldVal = kvp.Value.Old == null ? 0d : (double)kvp.Value.Old;
		double currentVal = kvp.Value.Current == null ? 0d : (double)kvp.Value.Current;
		if (settings[kvp.Key] && oldVal == 0 && currentVal > 0)
		{
			vars.DebugOutput("Boss kill " + kvp.Key + " split.");
			return true;
		}
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
	if (ms > oldMs)
	{
		vars.savedTime += ms - oldMs;
	}

	// Game display rounds up to the nearest hundredth, although a frame is much longer
	// so such precision doesn't really matter. But it looks more consistent.
	return TimeSpan.FromMilliseconds(Math.Round(vars.savedTime / 10d) * 10d);
}