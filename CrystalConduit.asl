state("Crystal Conduit", "v1.0")
{
	int room : 0x006A7F98;
	double fadeIn : 0x00488F5C, 0x04, 0x58, 0x10, 0x10, 0x00;
}

startup
{
	settings.Add("autoStart", true, "Auto-start");
	settings.Add("autoReset", true, "Auto-reset");
	settings.SetToolTip("autoReset", "Will reset run if dying or restarting on first level, or returning to menu.");
	
	/* Couldn't get this working. Had trouble finding pointer for fade out.
	settings.Add("pauseBetween", false, "Pause between levels");
	settings.SetToolTip("pauseBetween", "Pauses timer while level is fading out/in.");
	*/
	
	vars.menu = 0;
	vars.firstLevel = 2;
	vars.gameWonRoom = 12;
}

init
{
	int moduleSize = modules.First().ModuleMemorySize;
	if (moduleSize == 7905280)
	{
		version = "v1.0";
	}
}

reset
{
	return settings["autoReset"] == true && (
		(current.room == vars.menu && old.room != vars.menu && old.room < vars.gameWonRoom)
		|| (current.room == vars.firstLevel && current.fadeIn > 0 && old.fadeIn <= 0)
	);
}

start
{
	return settings["autoStart"] == true && current.room == vars.firstLevel;
}

split
{
	return current.room > old.room && old.room >= vars.firstLevel && current.room <= vars.gameWonRoom;
}

isLoading
{
    return current.room < vars.firstLevel;
		// || (settings["pauseBetween"] == true && current.fadeIn > 0);
}
