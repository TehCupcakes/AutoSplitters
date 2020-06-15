// Latest version should always be at top of file so it is default!
state("Ato", "1.0.3.0")
{
	int room : 0x006C2DB8;
	double gameTimer : 0x004B2780, 0x2C, 0x10, 0x120, 0x50;
	double phase : 0x004B2780, 0x2C, 0x10, 0x120, 0x30;
	double orb1 : 0x004B2780, 0x2C, 0x10, 0x120, 0x00, 0x44, 0x04, 0x00;
	double orb2 : 0x004B2780, 0x2C, 0x10, 0x120, 0x00, 0x44, 0x04, 0x10;
	double orb3 : 0x004B2780, 0x2C, 0x10, 0x120, 0x00, 0x44, 0x04, 0x20;
	double win : 0x004B2780, 0x2C, 0x10, 0xE04, 0x00, 0x04, 0x04, 0x200;
}
state("Ato", "1.0.2.0")
{
	int room : 0x006C2DB8;
	double gameTimer : 0x004A1164, 0x00, 0x2C, 0x10, 0x120, 0x80;
	double phase : 0x004A1164, 0x00, 0x2C, 0x10, 0x120, 0x60;
	double orb1 : 0x004B2780, 0x2C, 0x10, 0x888, 0x10, 0x44, 0x04, 0x00;
	double orb2 : 0x004B2780, 0x2C, 0x10, 0x888, 0x10, 0x44, 0x04, 0x10;
	double orb3 : 0x004B2780, 0x2C, 0x10, 0x888, 0x10, 0x44, 0x04, 0x20;
	double win : 0x004B2780, 0x2C, 0x10, 0x120, 0x00, 0x04, 0x04, 0x200;
}
state("Ato", "1.0.1.0")
{
	int room : 0x006C2DB8;
	double gameTimer : 0x004A1164, 0x00, 0x2C, 0x10, 0x120, 0x80;
	double phase : 0x004A1164, 0x00, 0x2C, 0x10, 0x120, 0x60;
	double orb1 : 0x004B2780, 0x2C, 0x10, 0x888, 0x10, 0x44, 0x04, 0x00;
	double orb2 : 0x004B2780, 0x2C, 0x10, 0x888, 0x10, 0x44, 0x04, 0x10;
	double orb3 : 0x004B2780, 0x2C, 0x10, 0x888, 0x10, 0x44, 0x04, 0x20;
	double win : 0x004B2780, 0x2C, 0x10, 0x120, 0x00, 0x04, 0x04, 0x200;
}

startup
{
	Action<string> DebugOutput = (text) => {
		print("[Autosplitter] "+text);
	};
	vars.DebugOutput = DebugOutput;

	// ARRAY/LIST POINTERS
	// We'd have to put each individual value in state to set these up. To allow us to increment
	// the offset and add all the ones we need programatically, we set these in startup instead.
	int[] abilityOffsets;
	int[] achievementOffsets;
	int[] runeOffsets;
	switch(version)
	{
		case "1.0.1.0":
			abilityOffsets = new int[] {0x004B38B4, 0x24, 0x08, 0x50, 0x14, 0x30, 0xA98, 0x00, 0x04, 0x04};
			achievementOffsets = new int[] {0x004B2780, 0x2C, 0x10, 0x120, 0x00, 0x04, 0x04};
			runeOffsets = new int[] {0x004B2780, 0x2C, 0x10, 0x120, 0x00, 0x04, 0x0C};
			break;
		case "1.0.2.0":
			abilityOffsets = new int[] {0x0048BBF4, 0x24, 0x2C, 0x270, 0x20, 0x14};
			achievementOffsets = new int[] {0x004B2780, 0x2C, 0x10, 0x120, 0x00, 0x04, 0x04};
			runeOffsets = new int[] {0x004B2780, 0x2C, 0x10, 0xC3C, 0x00, 0x04, 0x04};
		case "1.0.3.0":
		default:
			abilityOffsets = new int[] {0x0048BBF4, 0x24, 0x2C, 0x270, 0x20, 0x14};
			achievementOffsets = new int[] {0x004B2780, 0x2C, 0x10, 0xE04, 0x00, 0x04, 0x04};
			runeOffsets = new int[] {0x004B2780, 0x2C, 0x10, 0x69C, 0x50, 0x04, 0x04};
			break;
	}

	// SETTINGS
	settings.Add("autostart", true, "Auto-start when starting a new file.");
	
	settings.Add("progression_splits", true, "Progression Splits");
	settings.Add("boss_splits", false, "Boss Splits (Excluding final boss)");
	settings.Add("scroll_splits", false, "Scroll Splits");
	// settings.Add("misc_splits", false, "Misc. Splits");

	settings.CurrentDefaultParent = "progression_splits";
	settings.Add("split_phase", true, "Split after destruction cutscene.");
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
	
	settings.CurrentDefaultParent = "scroll_splits";
	settings.Add("dash_count", true, "Dash (+2 Upgrades)");
	settings.Add("double_jump", true, "Double Jump");
	settings.Add("speed_charge", true, "Speed Charge");
	settings.Add("dodge", true, "Dodge (+Upgrade)");
	settings.Add("vision", true, "Vision");
	settings.Add("ewls", true, "Electric Wind Lethal Strike");
	settings.Add("crystal", true, "Crystal Break");
	settings.Add("spell_spin", true, "Spin Spell (+Upgrade)");
	settings.Add("spell_throw", true, "Throw Spell (+Upgrade)");
	settings.Add("spell_down", true, "Down Spell (+Upgrade)");
	settings.Add("fatal_draw", true, "Fatal Draw (+Upgrade)");
	settings.Add("triple_slash", true, "Triple Slash");
	settings.Add("meditate", true, "Meditate");
	settings.Add("parry", true, "Parry/Counter");
	
	/* TODO: Implement these
	settings.CurrentDefaultParent = "misc_splits";
	settings.Add("split_talisman", true, "Talismans");
	settings.Add("split_coin", true, "Coins");
	settings.Add("split_rune", true, "Runes");
	settings.Add("split_magic", true, "Magic Bars");
	*/
	
	// POINTER WATCHERS
	// Set up memory watchers for boss splits. Since they're sequential, it's easier to do in a loop than one by one.
	vars.GetDemonbladeWatcher = (Func<MemoryWatcher>)(() => {
		var baseOffset = abilityOffsets[0];
		int[] demonbladeOffsets = new int[abilityOffsets.Length];
		Array.Copy(abilityOffsets, 1, demonbladeOffsets, 0, abilityOffsets.Length - 1);
		demonbladeOffsets[demonbladeOffsets.Length - 1] = 0x1E0;
		return new MemoryWatcher<double>(new DeepPointer(baseOffset, demonbladeOffsets));
	});
	vars.GetBossWatchers = (Func<Dictionary<string, MemoryWatcher>>)(() => {
		var dict = new Dictionary<string, MemoryWatcher>();
		var baseOffset = achievementOffsets[0];
		for (int i = 0; i <= 31; i++)
		{
			// Copy the offsets minus the first one and append the offset for the individual ability
			int[] currentOffsets = new int[achievementOffsets.Length];
			Array.Copy(achievementOffsets, 1, currentOffsets, 0, achievementOffsets.Length - 1);
			currentOffsets[currentOffsets.Length - 1] = 0x10 * i;
			
			var watcher = new MemoryWatcher<double>(new DeepPointer(baseOffset, currentOffsets));
			dict.Add("boss_" + i.ToString(), watcher);
		}
		int[] owlOffsets = new int[achievementOffsets.Length];
		Array.Copy(achievementOffsets, 1, owlOffsets, 0, achievementOffsets.Length - 1);
		owlOffsets[owlOffsets.Length - 1] = 0x570;
		dict.Add("boss_owl", new MemoryWatcher<double>(new DeepPointer(baseOffset, owlOffsets)));
		return dict;
	});
	vars.GetScrollWatchers = (Func<Dictionary<string, MemoryWatcher>>)(() => {
		var dict = new Dictionary<string, MemoryWatcher>();
		var scrollOffsets = new Dictionary<string, int>()
		{
			{ "dash_count", 0x10 },
			{ "double_jump", 0x20 },
			{ "speed_charge", 0x40 },
			{ "dodge", 0x70 },
			{ "vision", 0x90 },
			{ "ewls", 0xA0 },
			{ "crystal", 0xB0 },
			{ "spell_spin", 0x100 },
			{ "spell_throw", 0x110 },
			{ "spell_down", 0x120 },
			{ "fatal_draw", 0x130 },
			{ "triple_slash", 0x150 },
			{ "meditate", 0x160 },
			{ "parry", 0x170 }
		};
		var baseOffset = abilityOffsets[0];
		foreach (KeyValuePair<string, int> kvp in scrollOffsets)
		{
			// Copy the offsets minus the first one and append the offset for the individual ability
			int[] currentOffsets = new int[abilityOffsets.Length];
			Array.Copy(abilityOffsets, 1, currentOffsets, 0, abilityOffsets.Length - 1);
			currentOffsets[currentOffsets.Length - 1] = kvp.Value;
			
			// vars.DebugOutput("All offsets: " + string.Join(", ", Array.ConvertAll(currentOffsets, off => off.ToString())));
			var watcher = new MemoryWatcher<double>(new DeepPointer(baseOffset, currentOffsets));
			dict.Add(kvp.Key, watcher);
		}
		return dict;
	});
	
	// Keep track of total run based on game time. (Stored in milliseconds)
	vars.savedTime = 0;
	
	// Important room numbers for splitting
	vars.menuRoom = 5;
	vars.introRoom = 6;
}

init
{
	int moduleSize = modules.First().ModuleMemorySize;
	vars.DebugOutput("Size: " + moduleSize);
	// So far Ato's module size is the same regardless of version
	if (moduleSize == 7593984)
	{
		// looks like "1.0.2.0"
		version = modules.First().FileVersionInfo.ProductVersion;
	}
	else
	{
		return;
	}
	vars.DebugOutput("INITIALIZED with version: " + version);
	
	vars.bossWatchers = vars.GetBossWatchers();
	vars.DebugOutput("Boss watcher count: " + vars.bossWatchers.Count.ToString());
	vars.scrollWatchers = vars.GetScrollWatchers();
	vars.DebugOutput("Scroll watcher count: " + vars.scrollWatchers.Count.ToString());
	vars.demonbladeWatcher = vars.GetDemonbladeWatcher();
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
	
	vars.demonbladeWatcher.Update(game);
	foreach (var currentWatcher in vars.bossWatchers)
	{
		currentWatcher.Value.Update(game);
	}
	foreach (var currentWatcher in vars.scrollWatchers)
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
	
	// Split on orb collection if relevant setting is on.
	if ((settings["split_orb1"] && current.orb1 == 1 && old.orb1 == 0) ||
		(settings["split_orb2"] && current.orb2 == 1 && old.orb2 == 0) ||
		(settings["split_orb3"] && current.orb3 == 1 && old.orb3 == 0))
	{
		vars.DebugOutput("Orb collected split.");
		return true;
	}
	
	// Split on demonblade collection if relevant setting is on.
	if (settings["split_demonblade"] && vars.demonbladeWatcher.Current == 1 && vars.demonbladeWatcher.Old == 0)
	{
		vars.DebugOutput("Demonblade collected split.");
		return true;
	}

	// Split on game finish. Only works if this is the first time the game has been won with the current save file.
	if (settings["split_rebirth"] && current.win == 1 && old.win == 0)
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
	
	// Split on each scroll obtained if the appropriate setting is activated
	foreach (KeyValuePair<string, MemoryWatcher> kvp in vars.scrollWatchers)
	{
		double oldVal = kvp.Value.Old == null ? 0d : (double)kvp.Value.Old;
		double currentVal = kvp.Value.Current == null ? 0d : (double)kvp.Value.Current;
		if (settings[kvp.Key] && currentVal > oldVal)
		{
			vars.DebugOutput("Obtained scroll " + kvp.Key + " split.");
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