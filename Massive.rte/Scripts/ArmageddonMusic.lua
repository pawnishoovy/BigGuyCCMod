ArmageddonMusicFunctions = {};

function ArmageddonMusicFunctions.checkForPreferencePossibility(self, prefersTable, possibilityTable)

	local resultsTable = {};
	local foundAny = false;
	-- possibly inefficient?
	for k, v in pairs(possibilityTable) do
		for pKey, pValue in pairs(prefersTable) do
			if v == pValue then
				foundAny = true;
				table.insert(resultsTable, v);
			end
		end
	end
	if foundAny then
		print("foundpreferredtoo")
		return resultsTable;
	else
		return false;
	end
	
end

function ArmageddonMusicFunctions.selectPossibleLoops(self, loopTable)

	-- basically just avoids repeats and any loops the currentloop says to Never play

	local resultIndex
	local loopSelectedTable = {};
	for k, v in pairs(loopTable) do
		local valid = true;
		if v ~= self.currentIndex then
			if self.currentTune.Components[self.currentIndex].Never then
				for k, neverV in pairs(self.currentTune.Components[self.currentIndex].Never) do
					if v == neverV then
						valid = false;
						break;
					end
				end
			end
			if valid == true then
				table.insert(loopSelectedTable, v);
			end
		end
	end
	resultIndex = loopSelectedTable[math.random(1, #loopSelectedTable)];
	
	-- if there's any compatibility between our final curated selection and loop preferences,
	-- 80% chance to pick one (not always so things are at least a little random)
	
	if math.random(0, 100) < 80 and self.currentTune.Components[self.currentIndex].Prefers ~= nil then
		local prefersTable = self.currentTune.Components[self.currentIndex].Prefers
		local resultsTable = ArmageddonMusicFunctions.checkForPreferencePossibility(self, prefersTable, loopSelectedTable)
		if resultsTable then
			resultIndex = prefersTable[math.random(1, #prefersTable)];
		end
	end
	
	return resultIndex

end

function ArmageddonMusicScript:StartScript()
	self.activity = ActivityMan:GetActivity();
	
	AudioMan:ClearMusicQueue();
	AudioMan:StopMusic();
	
	self.actorTable = {};
	
	for actor in MovableMan.AddedActors do
		table.insert(self.actorTable, actor);
	end
	
	-- our dynamic music is just normal sound, so get the current ratio between sound and music volume
	-- to set the container volumes
	
	self.dynamicVolume = (AudioMan.MusicVolume / AudioMan.SoundsVolume);
	
	self.MUSIC_STATE = "Main";
	
	self.componentTimer = Timer();
	self.restTimer = Timer();
	
	self.loopNumber = 0;
	self.totalLoopNumber = 0;
	self.tuneMaxLoops = 48;
	
	-- unfortunately the real intensities we have to set are as follows
	-- 1: ambient
	-- 3: light
	-- 6: heavy
	-- 8: extreme
	-- this is due to ease of selecting transitions and comedowns later in code
	-- i should probably change these to an enum of some sort, but i dont know how
	self.desiredIntensity = 1;
	self.Intensity = 1;
	
	-- checks amount of ACTION going on to decide appropriate intensity
	self.intensityUpdateTimer = Timer();
	self.intensityUpdateDelay = 3000;
	self.lastIntensityIncreaseFactor = 0;
	
	self.timesNothingHasHappened = 0;
	

	self.Tunes = {};
	
	-- self.victoryPath = "Massive.rte/Music/Victory.ogg";
	-- self.defeatPath = "Massive.rte/Music/Defeat.ogg";
	
	-- self.happyAmbients = {"Massive.rte/Music/Ambient1.ogg", "Massive.rte/Music/Ambient2.ogg",
	-- "Massive.rte/Music/Ambient3.ogg", "Massive.rte/Music/Ambient4.ogg", "Massive.rte/Music/Ambient5.ogg"
	-- , "Massive.rte/Music/Ambient6.ogg", "Massive.rte/Music/Ambient7.ogg"};
	
	-- self.evilAmbients = {"Massive.rte/Music/EvilAmbient1.ogg", "Massive.rte/Music/EvilAmbient2.ogg",
	-- "Massive.rte/Music/EvilAmbient3.ogg"};
	
	
	-- note that ambients can really be upgraded at any time not just according to totalPost
	
	self.Tunes.samuelsBase = {};
	-- read: not recommended, enforced, tune will always change after this amount
	self.Tunes.samuelsBase.recommendedLoops = 40;	
	-- some pieces thrive at different intensity level, so bias them one way or another
	-- by making it more or less difficult to climb in intensity
	self.Tunes.samuelsBase.lightIntoHeavyDifficulty = 3.5;
	-- note that lightintoextreme is 2x lightintoheavy
	self.Tunes.samuelsBase.heavyIntoExtremeDifficulty = 3.5;
	
	
	self.Tunes.samuelsBase.Components = {};
	self.Tunes.samuelsBase.Components[1] = {};
	self.Tunes.samuelsBase.Components[1].Container = CreateSoundContainer("SamuelsBase Ambient 1", "Massive.rte");
	self.Tunes.samuelsBase.Components[1].preLength = 4035;
	self.Tunes.samuelsBase.Components[1].totalPost = 44952;
	self.Tunes.samuelsBase.Components[1].Type = "Ambient";
	
	self.Tunes.samuelsBase.Components[2] = {};
	self.Tunes.samuelsBase.Components[2].Container = CreateSoundContainer("SamuelsBase Ambient 2", "Massive.rte");
	self.Tunes.samuelsBase.Components[2].preLength = 0;
	self.Tunes.samuelsBase.Components[2].totalPost = 74570;
	self.Tunes.samuelsBase.Components[2].Type = "Ambient";
	
	self.Tunes.samuelsBase.Components[3] = {};
	self.Tunes.samuelsBase.Components[3].Container = CreateSoundContainer("SamuelsBase Ambient 3", "Massive.rte");
	self.Tunes.samuelsBase.Components[3].preLength = 2000;
	self.Tunes.samuelsBase.Components[3].totalPost = 77569;
	self.Tunes.samuelsBase.Components[3].Type = "Ambient";
	
	self.Tunes.samuelsBase.Components[4] = {};
	self.Tunes.samuelsBase.Components[4].Container = CreateSoundContainer("SamuelsBase Ambient 4", "Massive.rte");
	self.Tunes.samuelsBase.Components[4].preLength = 2915;
	self.Tunes.samuelsBase.Components[4].totalPost = 58934;
	self.Tunes.samuelsBase.Components[4].Type = "Ambient";
	
	self.Tunes.samuelsBase.Components[5] = {};
	self.Tunes.samuelsBase.Components[5].Container = CreateSoundContainer("SamuelsBase Ambient 5", "Massive.rte");
	self.Tunes.samuelsBase.Components[5].preLength = 3164;
	self.Tunes.samuelsBase.Components[5].totalPost = 60656;
	self.Tunes.samuelsBase.Components[5].Type = "Ambient";
	
	self.Tunes.samuelsBase.Components[6] = {};
	self.Tunes.samuelsBase.Components[6].Container = CreateSoundContainer("SamuelsBase Light Transition 1", "Massive.rte");
	self.Tunes.samuelsBase.Components[6].preLength = 947;
	self.Tunes.samuelsBase.Components[6].totalPost = 4290;
	self.Tunes.samuelsBase.Components[6].Type = "Light Transition";
	
	self.Tunes.samuelsBase.Components[7] = {};
	self.Tunes.samuelsBase.Components[7].Container = CreateSoundContainer("SamuelsBase Light Transition 2", "Massive.rte");
	self.Tunes.samuelsBase.Components[7].preLength = 471;
	self.Tunes.samuelsBase.Components[7].totalPost = 7052;
	self.Tunes.samuelsBase.Components[7].Type = "Light Transition";
	
	self.Tunes.samuelsBase.Components[8] = {};
	self.Tunes.samuelsBase.Components[8].Container = CreateSoundContainer("SamuelsBase Light Main 1", "Massive.rte");
	self.Tunes.samuelsBase.Components[8].preLength = 3278;
	self.Tunes.samuelsBase.Components[8].totalPost = 9927;
	self.Tunes.samuelsBase.Components[8].Type = "Light Main";
	
	self.Tunes.samuelsBase.Components[9] = {};
	self.Tunes.samuelsBase.Components[9].Container = CreateSoundContainer("SamuelsBase Light Main 2", "Massive.rte");
	self.Tunes.samuelsBase.Components[9].preLength = 3287;
	self.Tunes.samuelsBase.Components[9].totalPost = 16490;
	self.Tunes.samuelsBase.Components[9].Type = "Light Main";
	
	self.Tunes.samuelsBase.Components[10] = {};
	self.Tunes.samuelsBase.Components[10].Container = CreateSoundContainer("SamuelsBase Light Main 3", "Massive.rte");
	self.Tunes.samuelsBase.Components[10].preLength = 1402;
	self.Tunes.samuelsBase.Components[10].totalPost = 16425;
	self.Tunes.samuelsBase.Components[10].Type = "Light Main";
	
	self.Tunes.samuelsBase.Components[11] = {};
	self.Tunes.samuelsBase.Components[11].Container = CreateSoundContainer("SamuelsBase Light Main 4", "Massive.rte");
	self.Tunes.samuelsBase.Components[11].preLength = 1401;
	self.Tunes.samuelsBase.Components[11].totalPost = 8000;
	self.Tunes.samuelsBase.Components[11].Type = "Light Main";
	
	self.Tunes.samuelsBase.Components[12] = {};
	self.Tunes.samuelsBase.Components[12].Container = CreateSoundContainer("SamuelsBase Light Main 5", "Massive.rte");
	self.Tunes.samuelsBase.Components[12].preLength = 3284;
	self.Tunes.samuelsBase.Components[12].totalPost = 29551;
	self.Tunes.samuelsBase.Components[12].Type = "Light Main";
	
	self.Tunes.samuelsBase.Components[13] = {};
	self.Tunes.samuelsBase.Components[13].Container = CreateSoundContainer("SamuelsBase Light Main 6", "Massive.rte");
	self.Tunes.samuelsBase.Components[13].preLength = 941;
	self.Tunes.samuelsBase.Components[13].totalPost = 10822;
	self.Tunes.samuelsBase.Components[13].Type = "Light Main";
	
	self.Tunes.samuelsBase.Components[14] = {};
	self.Tunes.samuelsBase.Components[14].Container = CreateSoundContainer("SamuelsBase Light Main 7", "Massive.rte");
	self.Tunes.samuelsBase.Components[14].preLength = 3281;
	self.Tunes.samuelsBase.Components[14].totalPost = 32868;
	self.Tunes.samuelsBase.Components[14].Type = "Light Main";

	self.Tunes.samuelsBase.Components[15] = {};
	self.Tunes.samuelsBase.Components[15].Container = CreateSoundContainer("SamuelsBase Light Main 8", "Massive.rte");
	self.Tunes.samuelsBase.Components[15].preLength = 3288;
	self.Tunes.samuelsBase.Components[15].totalPost = 9863;
	self.Tunes.samuelsBase.Components[15].Type = "Light Main";
	
	self.Tunes.samuelsBase.Components[16] = {};
	self.Tunes.samuelsBase.Components[16].Container = CreateSoundContainer("SamuelsBase Light Main 9", "Massive.rte");
	self.Tunes.samuelsBase.Components[16].preLength = 3280;
	self.Tunes.samuelsBase.Components[16].totalPost = 30274;
	self.Tunes.samuelsBase.Components[16].Type = "Light Main";
	
	self.Tunes.samuelsBase.Components[17] = {};
	self.Tunes.samuelsBase.Components[17].Container = CreateSoundContainer("SamuelsBase Light Main 10", "Massive.rte");
	self.Tunes.samuelsBase.Components[17].preLength = 3290;
	self.Tunes.samuelsBase.Components[17].totalPost = 16495;
	self.Tunes.samuelsBase.Components[17].Type = "Light Main";
	
	self.Tunes.samuelsBase.Components[18] = {};
	self.Tunes.samuelsBase.Components[18].Container = CreateSoundContainer("SamuelsBase Light Comedown 1", "Massive.rte");
	self.Tunes.samuelsBase.Components[18].preLength = 3286;
	self.Tunes.samuelsBase.Components[18].midChance = 9843;
	self.Tunes.samuelsBase.Components[18].totalPost = 16507;
	self.Tunes.samuelsBase.Components[18].Type = "Light Comedown";

	self.Tunes.samuelsBase.Components[19] = {};
	self.Tunes.samuelsBase.Components[19].Container = CreateSoundContainer("SamuelsBase Light Comedown 2", "Massive.rte");
	self.Tunes.samuelsBase.Components[19].preLength = 3286;
	self.Tunes.samuelsBase.Components[19].midChance = 16540;
	self.Tunes.samuelsBase.Components[19].totalPost = 33330;
	self.Tunes.samuelsBase.Components[19].Type = "Light Comedown";
	
	self.Tunes.samuelsBase.Components[20] = {};
	self.Tunes.samuelsBase.Components[20].Container = CreateSoundContainer("SamuelsBase Heavy Main 1", "Massive.rte");
	self.Tunes.samuelsBase.Components[20].preLength = 584;
	self.Tunes.samuelsBase.Components[20].totalPost = 37865;
	self.Tunes.samuelsBase.Components[20].Type = "Heavy Main";
	
	self.Tunes.samuelsBase.Components[21] = {};
	self.Tunes.samuelsBase.Components[21].Container = CreateSoundContainer("SamuelsBase Heavy Main 2", "Massive.rte");
	self.Tunes.samuelsBase.Components[21].preLength = 444;
	self.Tunes.samuelsBase.Components[21].totalPost = 37865;
	self.Tunes.samuelsBase.Components[21].Type = "Heavy Main";
	
	self.Tunes.samuelsBase.Components[22] = {};
	self.Tunes.samuelsBase.Components[22].Container = CreateSoundContainer("SamuelsBase Heavy Main 3", "Massive.rte");
	self.Tunes.samuelsBase.Components[22].preLength = 444;
	self.Tunes.samuelsBase.Components[22].totalPost = 56574;
	self.Tunes.samuelsBase.Components[22].Type = "Heavy Main";
	
	self.Tunes.samuelsBase.Components[23] = {};
	self.Tunes.samuelsBase.Components[23].Container = CreateSoundContainer("SamuelsBase Heavy Main 4", "Massive.rte");
	self.Tunes.samuelsBase.Components[23].preLength = 588;
	self.Tunes.samuelsBase.Components[23].totalPost = 19248;
	self.Tunes.samuelsBase.Components[23].Type = "Heavy Main";
	self.Tunes.samuelsBase.Components[23].Prefers = {30};
	
	self.Tunes.samuelsBase.Components[24] = {};
	self.Tunes.samuelsBase.Components[24].Container = CreateSoundContainer("SamuelsBase Heavy Main 5", "Massive.rte");
	self.Tunes.samuelsBase.Components[24].preLength = 592;
	self.Tunes.samuelsBase.Components[24].totalPost = 37886;
	self.Tunes.samuelsBase.Components[24].Type = "Heavy Main";
	self.Tunes.samuelsBase.Components[24].Prefers = {33};
	
	self.Tunes.samuelsBase.Components[25] = {};
	self.Tunes.samuelsBase.Components[25].Container = CreateSoundContainer("SamuelsBase Heavy Main 6", "Massive.rte");
	self.Tunes.samuelsBase.Components[25].preLength = 291;
	self.Tunes.samuelsBase.Components[25].totalPost = 18954;
	self.Tunes.samuelsBase.Components[25].Type = "Heavy Main";
	
	self.Tunes.samuelsBase.Components[26] = {};
	self.Tunes.samuelsBase.Components[26].Container = CreateSoundContainer("SamuelsBase Heavy Comedown 1", "Massive.rte");
	self.Tunes.samuelsBase.Components[26].preLength = 585;
	self.Tunes.samuelsBase.Components[26].midChance = 19226;
	self.Tunes.samuelsBase.Components[26].totalPost = 42058;
	self.Tunes.samuelsBase.Components[26].Type = "Heavy Comedown";

	self.Tunes.samuelsBase.Components[27] = {};
	self.Tunes.samuelsBase.Components[27].Container = CreateSoundContainer("SamuelsBase Heavy Comedown 2", "Massive.rte");
	self.Tunes.samuelsBase.Components[27].preLength = 585;
	self.Tunes.samuelsBase.Components[27].midChance = 19226;
	self.Tunes.samuelsBase.Components[27].totalPost = 42058;
	self.Tunes.samuelsBase.Components[27].Type = "Heavy Comedown";

	self.Tunes.samuelsBase.Components[28] = {};
	self.Tunes.samuelsBase.Components[28].Container = CreateSoundContainer("SamuelsBase Heavy Comedown 3", "Massive.rte");
	self.Tunes.samuelsBase.Components[28].preLength = 585;
	self.Tunes.samuelsBase.Components[28].midChance = 19226;
	self.Tunes.samuelsBase.Components[28].totalPost = 42058;
	self.Tunes.samuelsBase.Components[28].Type = "Heavy Comedown";
	
	self.Tunes.samuelsBase.Components[29] = {};
	self.Tunes.samuelsBase.Components[29].Container = CreateSoundContainer("SamuelsBase Extreme 1", "Massive.rte");
	self.Tunes.samuelsBase.Components[29].preLength = 296;
	self.Tunes.samuelsBase.Components[29].totalPost = 37617;
	self.Tunes.samuelsBase.Components[29].Type = "Extreme";
	self.Tunes.samuelsBase.Components[29].Prefers = {30};
	self.Tunes.samuelsBase.Components[29].returnToHeavy = false;
	
	self.Tunes.samuelsBase.Components[30] = {};
	self.Tunes.samuelsBase.Components[30].Container = CreateSoundContainer("SamuelsBase Extreme 2", "Massive.rte");
	self.Tunes.samuelsBase.Components[30].preLength = 290;
	self.Tunes.samuelsBase.Components[30].totalPost = 18982;
	self.Tunes.samuelsBase.Components[30].Type = "Extreme";
	self.Tunes.samuelsBase.Components[30].Prefers = {31};
	
	self.Tunes.samuelsBase.Components[31] = {};
	self.Tunes.samuelsBase.Components[31].Container = CreateSoundContainer("SamuelsBase Extreme 3", "Massive.rte");
	self.Tunes.samuelsBase.Components[31].preLength = 290;
	self.Tunes.samuelsBase.Components[31].totalPost = 18982;
	self.Tunes.samuelsBase.Components[31].Type = "Extreme";
	self.Tunes.samuelsBase.Components[31].Prefers = {33};
	
	self.Tunes.samuelsBase.Components[32] = {};
	self.Tunes.samuelsBase.Components[32].Container = CreateSoundContainer("SamuelsBase Extreme 4", "Massive.rte");
	self.Tunes.samuelsBase.Components[32].preLength = 290;
	self.Tunes.samuelsBase.Components[32].totalPost = 18982;
	self.Tunes.samuelsBase.Components[32].Type = "Extreme";
	self.Tunes.samuelsBase.Components[32].returnToHeavy = true;
	
	self.Tunes.samuelsBase.Components[33] = {};
	self.Tunes.samuelsBase.Components[33].Container = CreateSoundContainer("SamuelsBase Extreme 5", "Massive.rte");
	self.Tunes.samuelsBase.Components[33].preLength = 544;
	self.Tunes.samuelsBase.Components[33].totalPost = 19258;
	self.Tunes.samuelsBase.Components[33].Type = "Extreme";
	self.Tunes.samuelsBase.Components[33].Prefers = {32};
	
	self.Tunes.samuelsBase.Components[34] = {}; -- I KNOW I KNOW but im NOT shifting all the other ones down!!
	self.Tunes.samuelsBase.Components[34].Container = CreateSoundContainer("SamuelsBase Heavy Main 7", "Massive.rte");
	self.Tunes.samuelsBase.Components[34].preLength = 2299;
	self.Tunes.samuelsBase.Components[34].totalPost = 20960;
	self.Tunes.samuelsBase.Components[34].Type = "Heavy Main";	
	self.Tunes.samuelsBase.Components[34].Prefers = {29};
	
	-- ambient: 1
	-- light transition: 2
	-- light main: 3
	-- light comedown: 4
	-- heavy transition: 5
	-- heavy main: 6
	-- heavy comedown: 7
	-- extreme: 8
	
	self.Tunes.samuelsBase.typeTables = {};
	self.Tunes.samuelsBase.typeTables[1] = {};
	self.Tunes.samuelsBase.typeTables[1].Loops = {1, 2, 3, 4, 5};
	
	self.Tunes.samuelsBase.typeTables[2] = {};
	self.Tunes.samuelsBase.typeTables[2].Loops = {6, 7};
	
	self.Tunes.samuelsBase.typeTables[3] = {};
	self.Tunes.samuelsBase.typeTables[3].Loops = {8, 9, 10, 11, 12, 13, 14, 15, 16, 17};
	
	self.Tunes.samuelsBase.typeTables[4] = {};
	self.Tunes.samuelsBase.typeTables[4].Loops = {18, 19};
	
	self.Tunes.samuelsBase.typeTables[5] = {};
	self.Tunes.samuelsBase.typeTables[5].Loops = {};
	
	self.Tunes.samuelsBase.typeTables[6] = {};
	self.Tunes.samuelsBase.typeTables[6].Loops = {20, 21, 22, 23, 24, 25, 34};
	
	self.Tunes.samuelsBase.typeTables[7] = {};
	self.Tunes.samuelsBase.typeTables[7].Loops = {26, 27, 28};
	
	self.Tunes.samuelsBase.typeTables[8] = {};
	self.Tunes.samuelsBase.typeTables[8].Loops = {29, 30, 31, 32, 33};
	
	
	self.Tunes.combatHell02 = {};
	self.Tunes.combatHell02.recommendedLoops = 75;	

	self.Tunes.combatHell02.lightIntoHeavyDifficulty = 4.0;
	self.Tunes.combatHell02.heavyIntoExtremeDifficulty = 0.5; -- look, it's rip and tear. cmon.
	
	
	self.Tunes.combatHell02.Components = {};
	self.Tunes.combatHell02.Components[1] = {};
	self.Tunes.combatHell02.Components[1].Container = CreateSoundContainer("CombatHell02 Ambient 1", "Massive.rte");
	self.Tunes.combatHell02.Components[1].preLength = 0;
	self.Tunes.combatHell02.Components[1].totalPost = 52470;
	self.Tunes.combatHell02.Components[1].Type = "Ambient";
	
	self.Tunes.combatHell02.Components[2] = {};
	self.Tunes.combatHell02.Components[2].Container = CreateSoundContainer("CombatHell02 Ambient 2", "Massive.rte");
	self.Tunes.combatHell02.Components[2].preLength = 0;
	self.Tunes.combatHell02.Components[2].totalPost = 80615;
	self.Tunes.combatHell02.Components[2].Type = "Ambient";
	
	self.Tunes.combatHell02.Components[3] = {};
	self.Tunes.combatHell02.Components[3].Container = CreateSoundContainer("CombatHell02 Ambient 3", "Massive.rte");
	self.Tunes.combatHell02.Components[3].preLength = 0;
	self.Tunes.combatHell02.Components[3].totalPost = 98875;
	self.Tunes.combatHell02.Components[3].Type = "Ambient";
	
	self.Tunes.combatHell02.Components[4] = {};
	self.Tunes.combatHell02.Components[4].Container = CreateSoundContainer("CombatHell02 Ambient 4", "Massive.rte");
	self.Tunes.combatHell02.Components[4].preLength = 0;
	self.Tunes.combatHell02.Components[4].totalPost = 139356;
	self.Tunes.combatHell02.Components[4].Type = "Ambient";
	
	self.Tunes.combatHell02.Components[5] = {};
	self.Tunes.combatHell02.Components[5].Container = CreateSoundContainer("CombatHell02 Ambient 5", "Massive.rte");
	self.Tunes.combatHell02.Components[5].preLength = 3164;
	self.Tunes.combatHell02.Components[5].totalPost = 85593;
	self.Tunes.combatHell02.Components[5].Type = "Ambient";
	
	self.Tunes.combatHell02.Components[6] = {};
	self.Tunes.combatHell02.Components[6].Container = CreateSoundContainer("CombatHell02 Light Main 1", "Massive.rte");
	self.Tunes.combatHell02.Components[6].preLength = 538;
	self.Tunes.combatHell02.Components[6].totalPost = 53816;
	self.Tunes.combatHell02.Components[6].Type = "Light Main";
	
	self.Tunes.combatHell02.Components[7] = {};
	self.Tunes.combatHell02.Components[7].Container = CreateSoundContainer("CombatHell02 Light Main 2", "Massive.rte");
	self.Tunes.combatHell02.Components[7].preLength = 560;
	self.Tunes.combatHell02.Components[7].totalPost = 60546;
	self.Tunes.combatHell02.Components[7].Type = "Light Main";
	
	self.Tunes.combatHell02.Components[8] = {};
	self.Tunes.combatHell02.Components[8].Container = CreateSoundContainer("CombatHell02 Light Main 3", "Massive.rte");
	self.Tunes.combatHell02.Components[8].preLength = 1120;
	self.Tunes.combatHell02.Components[8].totalPost = 61102;
	self.Tunes.combatHell02.Components[8].Type = "Light Main";
	
	self.Tunes.combatHell02.Components[9] = {};
	self.Tunes.combatHell02.Components[9].Container = CreateSoundContainer("CombatHell02 Light Main 4", "Massive.rte");
	self.Tunes.combatHell02.Components[9].preLength = 552;
	self.Tunes.combatHell02.Components[9].totalPost = 58343;
	self.Tunes.combatHell02.Components[9].Type = "Light Main";
	
	self.Tunes.combatHell02.Components[10] = {};
	self.Tunes.combatHell02.Components[10].Container = CreateSoundContainer("CombatHell02 Heavy Transition 1", "Massive.rte");
	self.Tunes.combatHell02.Components[10].preLength = 292;
	self.Tunes.combatHell02.Components[10].totalPost = 4731;
	self.Tunes.combatHell02.Components[10].Type = "Heavy Transition";
	
	self.Tunes.combatHell02.Components[11] = {};
	self.Tunes.combatHell02.Components[11].Container = CreateSoundContainer("CombatHell02 Heavy Transition 2", "Massive.rte");
	self.Tunes.combatHell02.Components[11].preLength = 568;
	self.Tunes.combatHell02.Components[11].totalPost = 5004;
	self.Tunes.combatHell02.Components[11].Type = "Heavy Transition";
	
	self.Tunes.combatHell02.Components[12] = {};
	self.Tunes.combatHell02.Components[12].Container = CreateSoundContainer("CombatHell02 Heavy Transition 3", "Massive.rte");
	self.Tunes.combatHell02.Components[12].preLength = 568;
	self.Tunes.combatHell02.Components[12].totalPost = 1654;
	self.Tunes.combatHell02.Components[12].Type = "Heavy Transition";
	
	self.Tunes.combatHell02.Components[13] = {};
	self.Tunes.combatHell02.Components[13].Container = CreateSoundContainer("CombatHell02 Heavy Transition 4", "Massive.rte");
	self.Tunes.combatHell02.Components[13].preLength = 568;
	self.Tunes.combatHell02.Components[13].totalPost = 1768;
	self.Tunes.combatHell02.Components[13].Type = "Heavy Transition";
	
	self.Tunes.combatHell02.Components[14] = {};
	self.Tunes.combatHell02.Components[14].Container = CreateSoundContainer("CombatHell02 Heavy Transition 5", "Massive.rte");
	self.Tunes.combatHell02.Components[14].preLength = 568;
	self.Tunes.combatHell02.Components[14].totalPost = 1768;
	self.Tunes.combatHell02.Components[14].Type = "Heavy Transition";

	self.Tunes.combatHell02.Components[15] = {};
	self.Tunes.combatHell02.Components[15].Container = CreateSoundContainer("CombatHell02 Heavy Transition 6", "Massive.rte");
	self.Tunes.combatHell02.Components[15].preLength = 282;
	self.Tunes.combatHell02.Components[15].totalPost = 4729;
	self.Tunes.combatHell02.Components[15].Type = "Heavy Transition";
	
	self.Tunes.combatHell02.Components[16] = {};
	self.Tunes.combatHell02.Components[16].Container = CreateSoundContainer("CombatHell02 Heavy Transition 7", "Massive.rte");
	self.Tunes.combatHell02.Components[16].preLength = 550;
	self.Tunes.combatHell02.Components[16].totalPost = 5046;
	self.Tunes.combatHell02.Components[16].Type = "Heavy Transition";
	
	self.Tunes.combatHell02.Components[17] = {};
	self.Tunes.combatHell02.Components[17].Container = CreateSoundContainer("CombatHell02 Heavy Transition 8", "Massive.rte");
	self.Tunes.combatHell02.Components[17].preLength = 282;
	self.Tunes.combatHell02.Components[17].totalPost = 4727;
	self.Tunes.combatHell02.Components[17].Type = "Heavy Transition";
	
	self.Tunes.combatHell02.Components[18] = {};
	self.Tunes.combatHell02.Components[18].Container = CreateSoundContainer("CombatHell02 Heavy Transition 9", "Massive.rte");
	self.Tunes.combatHell02.Components[18].preLength = 282;
	self.Tunes.combatHell02.Components[18].totalPost = 4727;
	self.Tunes.combatHell02.Components[18].Type = "Heavy Transition";

	self.Tunes.combatHell02.Components[19] = {};
	self.Tunes.combatHell02.Components[19].Container = CreateSoundContainer("CombatHell02 Heavy Transition 10", "Massive.rte");
	self.Tunes.combatHell02.Components[19].preLength = 282;
	self.Tunes.combatHell02.Components[19].totalPost = 6949;
	self.Tunes.combatHell02.Components[19].Type = "Heavy Transition";
	
	self.Tunes.combatHell02.Components[20] = {};
	self.Tunes.combatHell02.Components[20].Container = CreateSoundContainer("CombatHell02 Heavy Transition 11", "Massive.rte");
	self.Tunes.combatHell02.Components[20].preLength = 554;
	self.Tunes.combatHell02.Components[20].totalPost = 2780;
	self.Tunes.combatHell02.Components[20].Type = "Heavy Transition";
	
	self.Tunes.combatHell02.Components[21] = {};
	self.Tunes.combatHell02.Components[21].Container = CreateSoundContainer("CombatHell02 Heavy Transition 12", "Massive.rte");
	self.Tunes.combatHell02.Components[21].preLength = 562;
	self.Tunes.combatHell02.Components[21].totalPost = 2780;
	self.Tunes.combatHell02.Components[21].Type = "Heavy Transition";
	
	self.Tunes.combatHell02.Components[22] = {};
	self.Tunes.combatHell02.Components[22].Container = CreateSoundContainer("CombatHell02 Heavy Transition 13", "Massive.rte");
	self.Tunes.combatHell02.Components[22].preLength = 703;
	self.Tunes.combatHell02.Components[22].totalPost = 5293;
	self.Tunes.combatHell02.Components[22].Type = "Heavy Transition";
	
	self.Tunes.combatHell02.Components[23] = {};
	self.Tunes.combatHell02.Components[23].Container = CreateSoundContainer("CombatHell02 Heavy Main 1", "Massive.rte");
	self.Tunes.combatHell02.Components[23].preLength = 562;
	self.Tunes.combatHell02.Components[23].totalPost = 2819;
	self.Tunes.combatHell02.Components[23].Type = "Heavy Main";
	
	self.Tunes.combatHell02.Components[24] = {};
	self.Tunes.combatHell02.Components[24].Container = CreateSoundContainer("CombatHell02 Heavy Main 2", "Massive.rte");
	self.Tunes.combatHell02.Components[24].preLength = 280;
	self.Tunes.combatHell02.Components[24].totalPost = 6416;
	self.Tunes.combatHell02.Components[24].Type = "Heavy Main";
	
	self.Tunes.combatHell02.Components[25] = {};
	self.Tunes.combatHell02.Components[25].Container = CreateSoundContainer("CombatHell02 Heavy Main 3", "Massive.rte");
	self.Tunes.combatHell02.Components[25].preLength = 262;
	self.Tunes.combatHell02.Components[25].totalPost = 3628;
	self.Tunes.combatHell02.Components[25].Type = "Heavy Main";
	
	self.Tunes.combatHell02.Components[26] = {};
	self.Tunes.combatHell02.Components[26].Container = CreateSoundContainer("CombatHell02 Heavy Main 4", "Massive.rte");
	self.Tunes.combatHell02.Components[26].preLength = 562;
	self.Tunes.combatHell02.Components[26].totalPost = 3904;
	self.Tunes.combatHell02.Components[26].Type = "Heavy Main";

	self.Tunes.combatHell02.Components[27] = {};
	self.Tunes.combatHell02.Components[27].Container = CreateSoundContainer("CombatHell02 Heavy Main 5", "Massive.rte");
	self.Tunes.combatHell02.Components[27].preLength = 280;
	self.Tunes.combatHell02.Components[27].totalPost = 3619;
	self.Tunes.combatHell02.Components[27].Type = "Heavy Main";

	self.Tunes.combatHell02.Components[28] = {};
	self.Tunes.combatHell02.Components[28].Container = CreateSoundContainer("CombatHell02 Heavy Main 6", "Massive.rte");
	self.Tunes.combatHell02.Components[28].preLength = 282;
	self.Tunes.combatHell02.Components[28].totalPost = 2515;
	self.Tunes.combatHell02.Components[28].Type = "Heavy Main";
	
	self.Tunes.combatHell02.Components[29] = {};
	self.Tunes.combatHell02.Components[29].Container = CreateSoundContainer("CombatHell02 Heavy Main 7", "Massive.rte");
	self.Tunes.combatHell02.Components[29].preLength = 282;
	self.Tunes.combatHell02.Components[29].totalPost = 3634;
	self.Tunes.combatHell02.Components[29].Type = "Heavy Main";
	
	self.Tunes.combatHell02.Components[30] = {};
	self.Tunes.combatHell02.Components[30].Container = CreateSoundContainer("CombatHell02 Heavy Main 8", "Massive.rte");
	self.Tunes.combatHell02.Components[30].preLength = 280;
	self.Tunes.combatHell02.Components[30].totalPost = 2507;
	self.Tunes.combatHell02.Components[30].Type = "Heavy Main";
	
	self.Tunes.combatHell02.Components[31] = {};
	self.Tunes.combatHell02.Components[31].Container = CreateSoundContainer("CombatHell02 Heavy Comedown 1", "Massive.rte");
	self.Tunes.combatHell02.Components[31].preLength = 259;
	self.Tunes.combatHell02.Components[31].totalPost = 3885;
	self.Tunes.combatHell02.Components[31].Type = "Heavy Comedown";
	
	self.Tunes.combatHell02.Components[32] = {};
	self.Tunes.combatHell02.Components[32].Container = CreateSoundContainer("CombatHell02 Heavy Comedown 2", "Massive.rte");
	self.Tunes.combatHell02.Components[32].preLength = 280;
	self.Tunes.combatHell02.Components[32].totalPost = 3628;
	self.Tunes.combatHell02.Components[32].Type = "Heavy Comedown";
	
	self.Tunes.combatHell02.Components[33] = {};
	self.Tunes.combatHell02.Components[33].Container = CreateSoundContainer("CombatHell02 Heavy Comedown 3", "Massive.rte");
	self.Tunes.combatHell02.Components[33].preLength = 562;
	self.Tunes.combatHell02.Components[33].totalPost = 2785;
	self.Tunes.combatHell02.Components[33].Type = "Heavy Comedown";
	
	self.Tunes.combatHell02.Components[34] = {};
	self.Tunes.combatHell02.Components[34].Container = CreateSoundContainer("CombatHell02 Heavy Comedown 4", "Massive.rte");
	self.Tunes.combatHell02.Components[34].preLength = 560;
	self.Tunes.combatHell02.Components[34].totalPost = 3890;
	self.Tunes.combatHell02.Components[34].Type = "Heavy Comedown";
	
	self.Tunes.combatHell02.Components[35] = {};
	self.Tunes.combatHell02.Components[35].Container = CreateSoundContainer("CombatHell02 Heavy Comedown 5", "Massive.rte");
	self.Tunes.combatHell02.Components[35].preLength = 290;
	self.Tunes.combatHell02.Components[35].totalPost = 3637;
	self.Tunes.combatHell02.Components[35].Type = "Heavy Comedown";
	
	-- okay, i'm kinda pissed. mid rapid-firing index numbers with some weirdo twisted claw grip on my keyboard,
	-- moping about wishing i could automate this, i realize: i can. here's what it takes:
	
	local indexAutomator = 35;
	indexAutomator = indexAutomator + 1;
	
	local soundContainerNumberAutomator = 0;
	soundContainerNumberAutomator = soundContainerNumberAutomator + 1;
	
	self.Tunes.combatHell02.Components[indexAutomator] = {};
	self.Tunes.combatHell02.Components[indexAutomator].Container = CreateSoundContainer("CombatHell02 Extreme " .. soundContainerNumberAutomator, "Massive.rte");
	self.Tunes.combatHell02.Components[indexAutomator].preLength = 555;
	self.Tunes.combatHell02.Components[indexAutomator].totalPost = 10606;
	self.Tunes.combatHell02.Components[indexAutomator].Type = "Extreme";
	
	-- ffs man...	
	
	indexAutomator = indexAutomator + 1;
	soundContainerNumberAutomator = soundContainerNumberAutomator + 1;
	
	self.Tunes.combatHell02.Components[indexAutomator] = {};
	self.Tunes.combatHell02.Components[indexAutomator].Container = CreateSoundContainer("CombatHell02 Extreme " .. soundContainerNumberAutomator, "Massive.rte");
	self.Tunes.combatHell02.Components[indexAutomator].preLength = 424;
	self.Tunes.combatHell02.Components[indexAutomator].totalPost = 11731;
	self.Tunes.combatHell02.Components[indexAutomator].Type = "Extreme";
	
	indexAutomator = indexAutomator + 1;
	soundContainerNumberAutomator = soundContainerNumberAutomator + 1;
	
	self.Tunes.combatHell02.Components[indexAutomator] = {};
	self.Tunes.combatHell02.Components[indexAutomator].Container = CreateSoundContainer("CombatHell02 Extreme " .. soundContainerNumberAutomator, "Massive.rte");
	self.Tunes.combatHell02.Components[indexAutomator].preLength = 424;
	self.Tunes.combatHell02.Components[indexAutomator].totalPost = 4111;
	self.Tunes.combatHell02.Components[indexAutomator].Type = "Extreme";
	
	indexAutomator = indexAutomator + 1;
	soundContainerNumberAutomator = soundContainerNumberAutomator + 1;
	
	self.Tunes.combatHell02.Components[indexAutomator] = {};
	self.Tunes.combatHell02.Components[indexAutomator].Container = CreateSoundContainer("CombatHell02 Extreme " .. soundContainerNumberAutomator, "Massive.rte");
	self.Tunes.combatHell02.Components[indexAutomator].preLength = 543;
	self.Tunes.combatHell02.Components[indexAutomator].totalPost = 5005;
	self.Tunes.combatHell02.Components[indexAutomator].Type = "Extreme";
	
	indexAutomator = indexAutomator + 1;
	soundContainerNumberAutomator = soundContainerNumberAutomator + 1;
	
	self.Tunes.combatHell02.Components[indexAutomator] = {};
	self.Tunes.combatHell02.Components[indexAutomator].Container = CreateSoundContainer("CombatHell02 Extreme " .. soundContainerNumberAutomator, "Massive.rte");
	self.Tunes.combatHell02.Components[indexAutomator].preLength = 565;
	self.Tunes.combatHell02.Components[indexAutomator].totalPost = 10619;
	self.Tunes.combatHell02.Components[indexAutomator].Type = "Extreme";
	
	indexAutomator = indexAutomator + 1;
	soundContainerNumberAutomator = soundContainerNumberAutomator + 1;
	
	self.Tunes.combatHell02.Components[indexAutomator] = {};
	self.Tunes.combatHell02.Components[indexAutomator].Container = CreateSoundContainer("CombatHell02 Extreme " .. soundContainerNumberAutomator, "Massive.rte");
	self.Tunes.combatHell02.Components[indexAutomator].preLength = 282;
	self.Tunes.combatHell02.Components[indexAutomator].totalPost = 4769;
	self.Tunes.combatHell02.Components[indexAutomator].Type = "Extreme";
	
	indexAutomator = indexAutomator + 1;
	soundContainerNumberAutomator = soundContainerNumberAutomator + 1;
	
	self.Tunes.combatHell02.Components[indexAutomator] = {};
	self.Tunes.combatHell02.Components[indexAutomator].Container = CreateSoundContainer("CombatHell02 Extreme " .. soundContainerNumberAutomator, "Massive.rte");
	self.Tunes.combatHell02.Components[indexAutomator].preLength = 562;
	self.Tunes.combatHell02.Components[indexAutomator].totalPost = 9475;
	self.Tunes.combatHell02.Components[indexAutomator].Type = "Extreme";
	
	indexAutomator = indexAutomator + 1;
	soundContainerNumberAutomator = soundContainerNumberAutomator + 1;
	
	self.Tunes.combatHell02.Components[indexAutomator] = {};
	self.Tunes.combatHell02.Components[indexAutomator].Container = CreateSoundContainer("CombatHell02 Extreme " .. soundContainerNumberAutomator, "Massive.rte");
	self.Tunes.combatHell02.Components[indexAutomator].preLength = 562;
	self.Tunes.combatHell02.Components[indexAutomator].totalPost = 5050;
	self.Tunes.combatHell02.Components[indexAutomator].Type = "Extreme";
	
	indexAutomator = indexAutomator + 1;
	soundContainerNumberAutomator = soundContainerNumberAutomator + 1;
	
	self.Tunes.combatHell02.Components[indexAutomator] = {};
	self.Tunes.combatHell02.Components[indexAutomator].Container = CreateSoundContainer("CombatHell02 Extreme " .. soundContainerNumberAutomator, "Massive.rte");
	self.Tunes.combatHell02.Components[indexAutomator].preLength = 562;
	self.Tunes.combatHell02.Components[indexAutomator].totalPost = 11711;
	self.Tunes.combatHell02.Components[indexAutomator].Type = "Extreme";
	
	indexAutomator = indexAutomator + 1;
	soundContainerNumberAutomator = soundContainerNumberAutomator + 1;
	
	self.Tunes.combatHell02.Components[indexAutomator] = {};
	self.Tunes.combatHell02.Components[indexAutomator].Container = CreateSoundContainer("CombatHell02 Extreme " .. soundContainerNumberAutomator, "Massive.rte");
	self.Tunes.combatHell02.Components[indexAutomator].preLength = 290;
	self.Tunes.combatHell02.Components[indexAutomator].totalPost = 6986;
	self.Tunes.combatHell02.Components[indexAutomator].Type = "Extreme";
	
	indexAutomator = indexAutomator + 1;
	soundContainerNumberAutomator = soundContainerNumberAutomator + 1;
	
	self.Tunes.combatHell02.Components[indexAutomator] = {};
	self.Tunes.combatHell02.Components[indexAutomator].Container = CreateSoundContainer("CombatHell02 Extreme " .. soundContainerNumberAutomator, "Massive.rte");
	self.Tunes.combatHell02.Components[indexAutomator].preLength = 564;
	self.Tunes.combatHell02.Components[indexAutomator].totalPost = 12840;
	self.Tunes.combatHell02.Components[indexAutomator].Type = "Extreme";
	
	indexAutomator = indexAutomator + 1;
	soundContainerNumberAutomator = soundContainerNumberAutomator + 1;
	
	self.Tunes.combatHell02.Components[indexAutomator] = {};
	self.Tunes.combatHell02.Components[indexAutomator].Container = CreateSoundContainer("CombatHell02 Extreme " .. soundContainerNumberAutomator, "Massive.rte");
	self.Tunes.combatHell02.Components[indexAutomator].preLength = 562;
	self.Tunes.combatHell02.Components[indexAutomator].totalPost = 5050;
	self.Tunes.combatHell02.Components[indexAutomator].Type = "Extreme";
	
	indexAutomator = indexAutomator + 1;
	soundContainerNumberAutomator = soundContainerNumberAutomator + 1;
	
	self.Tunes.combatHell02.Components[indexAutomator] = {};
	self.Tunes.combatHell02.Components[indexAutomator].Container = CreateSoundContainer("CombatHell02 Extreme " .. soundContainerNumberAutomator, "Massive.rte");
	self.Tunes.combatHell02.Components[indexAutomator].preLength = 562;
	self.Tunes.combatHell02.Components[indexAutomator].totalPost = 5074;
	self.Tunes.combatHell02.Components[indexAutomator].Type = "Extreme";
	
	indexAutomator = indexAutomator + 1;
	soundContainerNumberAutomator = soundContainerNumberAutomator + 1;
	
	self.Tunes.combatHell02.Components[indexAutomator] = {};
	self.Tunes.combatHell02.Components[indexAutomator].Container = CreateSoundContainer("CombatHell02 Extreme " .. soundContainerNumberAutomator, "Massive.rte");
	self.Tunes.combatHell02.Components[indexAutomator].preLength = 556;
	self.Tunes.combatHell02.Components[indexAutomator].totalPost = 9448;
	self.Tunes.combatHell02.Components[indexAutomator].Type = "Extreme";
	
	indexAutomator = indexAutomator + 1;
	soundContainerNumberAutomator = soundContainerNumberAutomator + 1;
	
	self.Tunes.combatHell02.Components[indexAutomator] = {};
	self.Tunes.combatHell02.Components[indexAutomator].Container = CreateSoundContainer("CombatHell02 Extreme " .. soundContainerNumberAutomator, "Massive.rte");
	self.Tunes.combatHell02.Components[indexAutomator].preLength = 565;
	self.Tunes.combatHell02.Components[indexAutomator].totalPost = 7191;
	self.Tunes.combatHell02.Components[indexAutomator].Type = "Extreme";
	
	indexAutomator = indexAutomator + 1;
	soundContainerNumberAutomator = soundContainerNumberAutomator + 1;
	
	self.Tunes.combatHell02.Components[indexAutomator] = {};
	self.Tunes.combatHell02.Components[indexAutomator].Container = CreateSoundContainer("CombatHell02 Extreme " .. soundContainerNumberAutomator, "Massive.rte");
	self.Tunes.combatHell02.Components[indexAutomator].preLength = 559;
	self.Tunes.combatHell02.Components[indexAutomator].totalPost = 11702;
	self.Tunes.combatHell02.Components[indexAutomator].Type = "Extreme";
	
	indexAutomator = indexAutomator + 1;
	soundContainerNumberAutomator = soundContainerNumberAutomator + 1;
	
	self.Tunes.combatHell02.Components[indexAutomator] = {};
	self.Tunes.combatHell02.Components[indexAutomator].Container = CreateSoundContainer("CombatHell02 Extreme " .. soundContainerNumberAutomator, "Massive.rte");
	self.Tunes.combatHell02.Components[indexAutomator].preLength = 562;
	self.Tunes.combatHell02.Components[indexAutomator].totalPost = 21174;
	self.Tunes.combatHell02.Components[indexAutomator].Type = "Extreme";
	
	indexAutomator = indexAutomator + 1;
	soundContainerNumberAutomator = soundContainerNumberAutomator + 1;
	
	self.Tunes.combatHell02.Components[indexAutomator] = {};
	self.Tunes.combatHell02.Components[indexAutomator].Container = CreateSoundContainer("CombatHell02 Extreme " .. soundContainerNumberAutomator, "Massive.rte");
	self.Tunes.combatHell02.Components[indexAutomator].preLength = 562;
	self.Tunes.combatHell02.Components[indexAutomator].totalPost = 9478;
	self.Tunes.combatHell02.Components[indexAutomator].Type = "Extreme";
	
	indexAutomator = indexAutomator + 1;
	soundContainerNumberAutomator = soundContainerNumberAutomator + 1;
	
	self.Tunes.combatHell02.Components[indexAutomator] = {};
	self.Tunes.combatHell02.Components[indexAutomator].Container = CreateSoundContainer("CombatHell02 Extreme " .. soundContainerNumberAutomator, "Massive.rte");
	self.Tunes.combatHell02.Components[indexAutomator].preLength = 421;
	self.Tunes.combatHell02.Components[indexAutomator].totalPost = 10559;
	self.Tunes.combatHell02.Components[indexAutomator].Type = "Extreme";
	
	indexAutomator = indexAutomator + 1;
	soundContainerNumberAutomator = soundContainerNumberAutomator + 1;
	
	self.Tunes.combatHell02.Components[indexAutomator] = {};
	self.Tunes.combatHell02.Components[indexAutomator].Container = CreateSoundContainer("CombatHell02 Extreme " .. soundContainerNumberAutomator, "Massive.rte");
	self.Tunes.combatHell02.Components[indexAutomator].preLength = 570;
	self.Tunes.combatHell02.Components[indexAutomator].totalPost = 5030;
	self.Tunes.combatHell02.Components[indexAutomator].Type = "Extreme";
	
	indexAutomator = indexAutomator + 1;
	soundContainerNumberAutomator = soundContainerNumberAutomator + 1;
	
	self.Tunes.combatHell02.Components[indexAutomator] = {};
	self.Tunes.combatHell02.Components[indexAutomator].Container = CreateSoundContainer("CombatHell02 Extreme " .. soundContainerNumberAutomator, "Massive.rte");
	self.Tunes.combatHell02.Components[indexAutomator].preLength = 423;
	self.Tunes.combatHell02.Components[indexAutomator].totalPost = 12692;
	self.Tunes.combatHell02.Components[indexAutomator].Type = "Extreme";
	
	indexAutomator = indexAutomator + 1;
	soundContainerNumberAutomator = soundContainerNumberAutomator + 1;
	
	self.Tunes.combatHell02.Components[indexAutomator] = {};
	self.Tunes.combatHell02.Components[indexAutomator].Container = CreateSoundContainer("CombatHell02 Extreme " .. soundContainerNumberAutomator, "Massive.rte");
	self.Tunes.combatHell02.Components[indexAutomator].preLength = 571;
	self.Tunes.combatHell02.Components[indexAutomator].totalPost = 10593;
	self.Tunes.combatHell02.Components[indexAutomator].Type = "Extreme";
	
	indexAutomator = indexAutomator + 1;
	soundContainerNumberAutomator = soundContainerNumberAutomator + 1;
	
	self.Tunes.combatHell02.Components[indexAutomator] = {};
	self.Tunes.combatHell02.Components[indexAutomator].Container = CreateSoundContainer("CombatHell02 Extreme " .. soundContainerNumberAutomator, "Massive.rte");
	self.Tunes.combatHell02.Components[indexAutomator].preLength = 700;
	self.Tunes.combatHell02.Components[indexAutomator].totalPost = 5175;
	self.Tunes.combatHell02.Components[indexAutomator].Type = "Extreme";
	
	indexAutomator = indexAutomator + 1;
	soundContainerNumberAutomator = soundContainerNumberAutomator + 1;
	
	self.Tunes.combatHell02.Components[indexAutomator] = {};
	self.Tunes.combatHell02.Components[indexAutomator].Container = CreateSoundContainer("CombatHell02 Extreme " .. soundContainerNumberAutomator, "Massive.rte");
	self.Tunes.combatHell02.Components[indexAutomator].preLength = 562;
	self.Tunes.combatHell02.Components[indexAutomator].totalPost = 6141;
	self.Tunes.combatHell02.Components[indexAutomator].Type = "Extreme";
	
	indexAutomator = indexAutomator + 1;
	soundContainerNumberAutomator = soundContainerNumberAutomator + 1;
	
	self.Tunes.combatHell02.Components[indexAutomator] = {};
	self.Tunes.combatHell02.Components[indexAutomator].Container = CreateSoundContainer("CombatHell02 Extreme " .. soundContainerNumberAutomator, "Massive.rte");
	self.Tunes.combatHell02.Components[indexAutomator].preLength = 565;
	self.Tunes.combatHell02.Components[indexAutomator].totalPost = 20867;
	self.Tunes.combatHell02.Components[indexAutomator].Type = "Extreme";
	
	indexAutomator = indexAutomator + 1;
	soundContainerNumberAutomator = soundContainerNumberAutomator + 1;
	
	self.Tunes.combatHell02.Components[indexAutomator] = {};
	self.Tunes.combatHell02.Components[indexAutomator].Container = CreateSoundContainer("CombatHell02 Extreme " .. soundContainerNumberAutomator, "Massive.rte");
	self.Tunes.combatHell02.Components[indexAutomator].preLength = 562;
	self.Tunes.combatHell02.Components[indexAutomator].totalPost = 7181;
	self.Tunes.combatHell02.Components[indexAutomator].Type = "Extreme";
	
	indexAutomator = indexAutomator + 1;
	soundContainerNumberAutomator = soundContainerNumberAutomator + 1;
	
	self.Tunes.combatHell02.Components[indexAutomator] = {};
	self.Tunes.combatHell02.Components[indexAutomator].Container = CreateSoundContainer("CombatHell02 Extreme " .. soundContainerNumberAutomator, "Massive.rte");
	self.Tunes.combatHell02.Components[indexAutomator].preLength = 562;
	self.Tunes.combatHell02.Components[indexAutomator].totalPost = 5043;
	self.Tunes.combatHell02.Components[indexAutomator].Type = "Extreme";
	
	indexAutomator = indexAutomator + 1;
	soundContainerNumberAutomator = soundContainerNumberAutomator + 1;
	
	self.Tunes.combatHell02.Components[indexAutomator] = {};
	self.Tunes.combatHell02.Components[indexAutomator].Container = CreateSoundContainer("CombatHell02 Extreme " .. soundContainerNumberAutomator, "Massive.rte");
	self.Tunes.combatHell02.Components[indexAutomator].preLength = 562;
	self.Tunes.combatHell02.Components[indexAutomator].totalPost = 10613;
	self.Tunes.combatHell02.Components[indexAutomator].Type = "Extreme";
	
	indexAutomator = indexAutomator + 1;
	soundContainerNumberAutomator = soundContainerNumberAutomator + 1;
	
	self.Tunes.combatHell02.Components[indexAutomator] = {};
	self.Tunes.combatHell02.Components[indexAutomator].Container = CreateSoundContainer("CombatHell02 Extreme " .. soundContainerNumberAutomator, "Massive.rte");
	self.Tunes.combatHell02.Components[indexAutomator].preLength = 562;
	self.Tunes.combatHell02.Components[indexAutomator].totalPost = 6147;
	self.Tunes.combatHell02.Components[indexAutomator].Type = "Extreme";
	
	print("indexautomator")
	print(indexAutomator)
	
	-- though, to be fair, much less readable.
	
	-- ambient: 1
	-- light transition: 2
	-- light main: 3
	-- light comedown: 4
	-- heavy transition: 5
	-- heavy main: 6
	-- heavy comedown: 7
	-- extreme: 8
	
	self.Tunes.combatHell02.typeTables = {};
	self.Tunes.combatHell02.typeTables[1] = {};
	self.Tunes.combatHell02.typeTables[1].Loops = {1, 2, 3, 4, 5};
	
	self.Tunes.combatHell02.typeTables[2] = {};
	self.Tunes.combatHell02.typeTables[2].Loops = {};
	
	self.Tunes.combatHell02.typeTables[3] = {};
	self.Tunes.combatHell02.typeTables[3].Loops = {6, 7, 8, 9};
	
	self.Tunes.combatHell02.typeTables[4] = {};
	self.Tunes.combatHell02.typeTables[4].Loops = {};
	
	self.Tunes.combatHell02.typeTables[5] = {};
	self.Tunes.combatHell02.typeTables[5].Loops = {10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22};
	
	self.Tunes.combatHell02.typeTables[6] = {};
	self.Tunes.combatHell02.typeTables[6].Loops = {23, 24, 25, 26, 27, 28, 29, 30};
	
	self.Tunes.combatHell02.typeTables[7] = {};
	self.Tunes.combatHell02.typeTables[7].Loops = {31, 32, 33, 34, 35};
	
	self.Tunes.combatHell02.typeTables[8] = {};
	self.Tunes.combatHell02.typeTables[8].Loops = {36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65};

	if self.activity.ActivityState == Activity.EDITING then
	
		-- self.editingMusic = true;
	
		-- AudioMan:ClearMusicQueue();
		-- AudioMan:StopMusic();
		-- local ambientTable = {};
		-- for k, v in pairs(self.happyAmbients) do
			-- table.insert(ambientTable, v);
		-- end
		-- for i = 1, #ambientTable do
			-- local randomizedIndex = math.random(1, #ambientTable);
			-- local randomizedAmbient = ambientTable[randomizedIndex];
			-- AudioMan:QueueMusicStream(randomizedAmbient);
			-- AudioMan:QueueSilence(10);
			-- table.remove(ambientTable, randomizedIndex);
		-- end
		
	else
	
		self.currentIndex = 1;
		local tuneTable = {};
		for k, v in pairs(self.Tunes) do
			table.insert(tuneTable, v);
		end
		self.currentTuneIndex = math.random(1, #tuneTable);
		self.currentTune = tuneTable[self.currentTuneIndex];
		if self.currentTune.Components then
			self.dynamicMusic = true;
			self.currentIndex = math.random(1, #self.currentTune.typeTables[1].Loops)
			self.currentTune.Components[self.currentIndex].Container.Volume = self.dynamicVolume;
			self.currentTune.Components[self.currentIndex].Container:Play();
			print(self.currentTune.Components[self.currentIndex].Container)
		end
		
	end
	
end

function ArmageddonMusicScript:UpdateScript()

	-- DEBUG
	if UInputMan:KeyPressed(39) then
		-- numpad 2 and up
		self.desiredIntensity = 1;
	elseif UInputMan:KeyPressed(40) then
		self.desiredIntensity = 3;
	elseif UInputMan:KeyPressed(41) then
		self.desiredIntensity = 6;
	elseif UInputMan:KeyPressed(42) then
		self.desiredIntensity = 8;
	elseif UInputMan:KeyPressed(43) then
		ArmageddonEngageExtreme = true;
	elseif UInputMan:KeyPressed(44) then
		-- debug start new song
		self.totalLoopNumber = 1000;
	elseif UInputMan:KeyPressed(45) then
		for actor in MovableMan.Actors do 
			if not string.find(actor.PresetName, "Brain") and not actor:IsPlayerControlled() then
				actor.Team = 3;
			end
		end
	
	end
	
	
	if self.dynamicMusic == true then
		
		AudioMan:ClearMusicQueue();
		AudioMan:StopMusic();		
	
		if (self.Intensity == 1 and self.desiredIntensity ~= 1)
		or (self.MUSIC_STATE == "Comedown" and self.desiredIntensity > self.Intensity)
		or (self.Intensity ~= 8 and ArmageddonEngageExtreme == true) then
		
			if ArmageddonEngageExtreme == true then
				ArmageddonEngageExtreme = false;
				self.desiredIntensity = 8;
			end
		
			-- if we're in ambience or comedown and anything, at all, is going on, immediately upgrade
			-- OR, also, if we've just had an extreme trigger
			
			self.Intensity = self.desiredIntensity;
			
			local loopTable
			local index
			
			if self.Intensity == 8 then
				-- use heavy transition
				loopTable = self.currentTune.typeTables[5].Loops;
			elseif self.Intensity > 1 then
				-- minus one: transition
				loopTable = self.currentTune.typeTables[self.Intensity - 1].Loops;
			end
			
			if #loopTable ~= 0 then
				index = ArmageddonMusicFunctions.selectPossibleLoops(self, loopTable);
				self.MUSIC_STATE = "Transition";
			else
				-- if we lack a transition go right into the Main instead
				self.MUSIC_STATE = "Main";
				loopTable = self.currentTune.typeTables[self.Intensity].Loops;
				index = ArmageddonMusicFunctions.selectPossibleLoops(self, loopTable);
			end
									
			
			self.nextDecided = false;
		
			self.loopNumber = self.loopNumber + 1;
			
			self.totalLoopNumber = self.totalLoopNumber + 1;
			
			self.intensityLowerPreLength = nil;
			
			local oldIndex = self.currentIndex + 0;
			self.instantUpgradeOldContainer = self.currentTune.Components[oldIndex].Container
			
			self.currentIndex = index
			
			-- -- fade the ambience/comedown out by the prelength of what we're about to play
			-- -- maybe a bit messy? just stop it when the new thing plays proper?
			-- note: it was a bit messy and i just did the second thing
			-- self.currentTune.Components[oldIndex].Container:FadeOut(self.currentTune.Components[self.currentIndex].preLength);
			
			self.dynamicVolume = (AudioMan.MusicVolume / AudioMan.SoundsVolume);
			
			self.currentTune.Components[self.currentIndex].Container.Volume = self.dynamicVolume;
			self.currentTune.Components[self.currentIndex].Container:Play();
			
			print(self.currentTune.Components[self.currentIndex].Container)
			
			self.componentTimer:Reset();
			
		else
	
			if self.componentTimer:IsPastRealMS(self.currentTune.Components[self.currentIndex].totalPost/3) then
				-- a third thru current loop, decide what to play next
				if self.nextDecided ~= true then
					self.nextDecided = true;	
					
					print("decidingintensity:")
					print(self.Intensity)
					print("desired:")
					print(self.desiredIntensity)
					
					if self.totalLoopNumber > self.currentTune.recommendedLoops then
						self.desiredIntensity = 1; -- will cause a comedown or an(other) ambient loop
						self.endTune = true;
						
						if self.MUSIC_STATE == "Transition" then
							-- count transition as main for ease of codeage, will cause comedown in most cases
							-- (or another ambient loop)
							self.MUSIC_STATE = "Main";
						end
						
					end
					
					local index
					local loopTable
					
					if self.MUSIC_STATE == "Transition" then

						loopTable = self.currentTune.typeTables[self.Intensity].Loops;
						index = ArmageddonMusicFunctions.selectPossibleLoops(self, loopTable);
						
						self.MUSIC_STATE = "Main";
					
					elseif self.MUSIC_STATE == "Comedown" then
					
						self.Intensity = self.desiredIntensity;
							
						if self.Intensity == 8 then
							-- use heavy transition (should never happen, code above auto-plays extreme again)
							loopTable = self.currentTune.typeTables[5].Loops;
						elseif self.Intensity > 1 then -- ambient has no transition so prevent trying that
							-- minus one: transition
							loopTable = self.currentTune.typeTables[self.Intensity - 1].Loops;
						end
						
						if loopTable and #loopTable ~= 0 then
							index = ArmageddonMusicFunctions.selectPossibleLoops(self, loopTable);
							self.MUSIC_STATE = "Transition";
						else
							-- if we lack a transition go right into the Main instead
							self.MUSIC_STATE = "Main";
							loopTable = self.currentTune.typeTables[self.Intensity].Loops;
							index = ArmageddonMusicFunctions.selectPossibleLoops(self, loopTable);
						end
						
					else
						
						loopTable = self.currentTune.typeTables[self.Intensity].Loops;
						
						index = ArmageddonMusicFunctions.selectPossibleLoops(self, loopTable);
					
						if (self.desiredIntensity ~= self.Intensity and self.loopNumber > 2) or (self.totalLoopNumber >= self.tuneMaxLoops) then					
							
							if self.Intensity > self.desiredIntensity then
							
								-- if we're going lower, do a comedown in this intensity first
								
								if self.Intensity == 8 then
									-- use heavy comedown
									loopTable = self.currentTune.typeTables[7].Loops;
								else
									-- plus one: comedown
									loopTable = self.currentTune.typeTables[self.Intensity + 1].Loops;
								end
								
								if #loopTable ~= 0 then
									index = ArmageddonMusicFunctions.selectPossibleLoops(self, loopTable);
									self.MUSIC_STATE = "Comedown";
								else
									-- if we lack a comedown go right into the Main instead (should never happen?) (note: happens for rip and tear)
									self.MUSIC_STATE = "Main";
									loopTable = self.currentTune.typeTables[self.Intensity].Loops;
									index = ArmageddonMusicFunctions.selectPossibleLoops(self, loopTable);
								end			
								
							else
							
								-- set intensity early here, we wanna use transitions of the resulting higher intensity
								self.Intensity = self.desiredIntensity
							
								if self.Intensity == 8 then
									-- use heavy transition
									loopTable = self.currentTune.typeTables[5].Loops;

								elseif self.Intensity > 1 then
									-- minus one: transition
									loopTable = self.currentTune.typeTables[self.Intensity - 1].Loops;
								end
								
								if #loopTable ~= 0 then
									index = ArmageddonMusicFunctions.selectPossibleLoops(self, loopTable);
									self.MUSIC_STATE = "Transition";
								else
									-- if we lack a transition go right into the Main instead
									self.MUSIC_STATE = "Main";
									loopTable = self.currentTune.typeTables[self.Intensity].Loops;
									index = ArmageddonMusicFunctions.selectPossibleLoops(self, loopTable);
								end
								
							end
							
							-- finally set our real intensity for real
							
							self.Intensity = self.desiredIntensity

						end			

					end
					
					-- however, if our current loop tells us to returnToHeavy, disregard everything and do exactly that
					if self.currentTune.Components[self.currentIndex].returnToHeavy == true then
							
							self.Intensity = 6;
						
							-- randomly either transition into heavy or just straight to main
							if math.random(0, 100) < 50 then
								loopTable = self.currentTune.typeTables[5].Loops;
								if loopTable and #loopTable ~= 0 then
									index = ArmageddonMusicFunctions.selectPossibleLoops(self, loopTable);
									self.MUSIC_STATE = "Transition";
								else
									-- if we lack a transition go right into the Main instead
									self.MUSIC_STATE = "Main";
									loopTable = self.currentTune.typeTables[self.Intensity].Loops;
									index = ArmageddonMusicFunctions.selectPossibleLoops(self, loopTable);
								end

							else

								self.MUSIC_STATE = "Main";
								loopTable = self.currentTune.typeTables[self.Intensity].Loops;
								index = ArmageddonMusicFunctions.selectPossibleLoops(self, loopTable);
							end			

							self.Intensity = 8; -- 1. go back to extreme unless we really stop doing much of anything
												-- 2. make sure another ArmageddonEngageExtreme doesn't interrupt our government-mandated
												-- break from mick gordon
						
					end
						
					
					self.indexToPlay = index;
					
				end
						
				local actingPreLength = self.currentTune.Components[self.indexToPlay].preLength
			
				if self.componentTimer:IsPastRealMS(self.currentTune.Components[self.currentIndex].totalPost - actingPreLength) then
				
					self.nextDecided = false;
				
					self.loopNumber = self.loopNumber + 1;
					
					self.totalLoopNumber = self.totalLoopNumber + 1;
					
					self.intensityLowerPreLength = nil;
					
					self.currentIndex = self.indexToPlay;
					
					self.dynamicVolume = (AudioMan.MusicVolume / AudioMan.SoundsVolume);
					
					if self.endTune == true then
						-- no rest for the wicked, straight into next song!
						self.endTune = false;
						
						self.MUSIC_STATE = "Main";
						self.desiredIntensity = 1;
						self.Intensity = 1;
						self.totalLoopNumber = 0;
						self.loopNumber = 0;
						
						self.currentIndex = 1;
						local tuneTable = {};
						for k, v in pairs(self.Tunes) do
							if v ~= self.currentTune then
								table.insert(tuneTable, v);
							end
						end
						self.currentTuneIndex = math.random(1, #tuneTable);
						self.currentTune = tuneTable[self.currentTuneIndex];
						if self.currentTune.Components then
							self.dynamicMusic = true;
							self.currentIndex = math.random(1, #self.currentTune.typeTables[1].Loops)
						end			
					
					end
					
					self.currentTune.Components[self.currentIndex].Container.Volume = self.dynamicVolume;
					self.currentTune.Components[self.currentIndex].Container:Play();
					
					print(self.currentTune.Components[self.currentIndex].Container)
					
					self.componentTimer:Reset();
					
				end					

			elseif self.componentTimer:IsPastRealMS(self.currentTune.Components[self.currentIndex].preLength) then
				if self.instantUpgradeOldContainer then
					self.instantUpgradeOldContainer:FadeOut(50); -- better fading it out on true newcontainer begin rather
																 -- than back at selection
					self.instantUpgradeOldContainer = nil;
				end
			end
			
		end
		
	end
	
	for actor in MovableMan.AddedActors do
		if IsAHuman(actor) or IsACrab(actor) then
			self.actorTable[actor.UniqueID] = actor.Team;
		end
	end
	
	ArmageddonEngageExtreme = false; -- you only got one chance to Engage The Extreme
									 -- if you miss it, that's it!
	
	if self.intensityUpdateTimer:IsPastSimMS(self.intensityUpdateDelay) then

		if self.firstUpdate ~= false then
			self.actorTable = {};
			-- game sometimes wigs out and reports a bunch of addedactors that don't exist and then
			-- causes us to have too many dead
			-- i'm looking at you dummyassault
			for actor in MovableMan.Actors do
				if IsAHuman(actor) or IsACrab(actor) then
					self.actorTable[actor.UniqueID] = actor.Team;
				end
			end
		end		
		
		self.firstUpdate = false;	
	
		self.intensityUpdateTimer:Reset();
		
		local eventlessUpdate = true;
		local intensityIncreaseFactor = 0;
		intensityIncreaseFactor = self.lastIntensityIncreaseFactor / 2;
		
		for uniqueID, team in pairs(self.actorTable) do
			local actor = MovableMan:FindObjectByUniqueID(uniqueID);
			local playerTeamDead = false;
			
			if not actor or ToActor(actor):IsDead() then
				for i = -1, 4 do
					if self.activity:TeamActive(i) and self.activity:IsHumanTeam(i) then
						if team == i then
							eventlessUpdate = false;
							intensityIncreaseFactor = intensityIncreaseFactor + 1.5;
							playerTeamDead = true;
							break;
						end
					end
				end
				if playerTeamDead == false then
					eventlessUpdate = false;
					intensityIncreaseFactor = intensityIncreaseFactor + 1.0;
				end
				self.actorTable[uniqueID] = nil;
			end
		end
		
		-- delicious pasta
		
		if eventlessUpdate == true then
			self.timesNothingHasHappened = self.timesNothingHasHappened + 1;
			if self.Intensity == 8 and self.timesNothingHasHappened > 3 then
				self.desiredIntensity = 6;
			elseif self.Intensity == 6 and self.timesNothingHasHappened > 8 then
				self.desiredIntensity = 3;
			elseif self.Intensity == 3 and self.timesNothingHasHappened > 15 then
				self.desiredIntensity = 1; -- peace? on the battlefield?
			end
		else
			if intensityIncreaseFactor > 8 then
				ArmageddonEngageExtreme = true; -- DEATH AND DESTRUCTION!!
			end
			self.desiredIntensity = self.Intensity;
			if self.Intensity == 1 then
				if intensityIncreaseFactor > 5 then
					self.desiredIntensity = 6;
				elseif intensityIncreaseFactor > 1 then
					self.desiredIntensity = 3;
				end
			elseif self.Intensity == 3 then
				if intensityIncreaseFactor > (self.currentTune.lightIntoHeavyDifficulty * 2) then
					self.desiredIntensity = 8;
				elseif intensityIncreaseFactor > self.currentTune.lightIntoHeavyDifficulty then
					self.desiredIntensity = 6;
				end
			elseif self.Intensity == 6 then
				if intensityIncreaseFactor > self.currentTune.heavyIntoExtremeDifficulty then
					self.desiredIntensity = 8;
				end
			end
			self.timesNothingHasHappened = 0;
		end
		
		self.lastIntensityIncreaseFactor = intensityIncreaseFactor;
		if self.lastIntensityIncreaseFactor < 1 then
			self.lastIntensityIncreaseFactor = 0;
		end
		print(intensityIncreaseFactor)
		
	end
	
	--for actor in MovableMan.Actors do actor.HUDVisible = false end

end

function ArmageddonMusicScript:EndScript()

	self.gameActivity = ToGameActivity(ActivityMan:GetActivity())

	AudioMan:StopMusic();
	AudioMan:ClearMusicQueue();
	-- if self.activityOverPlayed ~= true then
		-- if self.currentTune.Components and self.currentTune.Components[self.currentIndex].Container:IsBeingPlayed() then
			-- self.currentTune.Components[self.currentIndex].Container:Stop(-1);
		-- end
		-- self.activityOverPlayed = true;
		-- if self.activity:HumanBrainCount() == 0 then
			-- AudioMan:PlayMusic(self.defeatPath, 0, -1);
			-- for actor in MovableMan.Actors do
				-- if IsAHuman(actor) and not self.gameActivity.WinnerTeam == actor.Team then
					-- ToAHuman(actor):SetNumberValue("Warcry Together", 1);
					-- ToAHuman(actor):SetNumberValue("Ye Olde Defeat", 1); -- hmmmmm...
				-- end
			-- end
			-- for i = 1, #self.evilAmbients do
				-- AudioMan:QueueSilence(10);
				-- local randomizedIndex = math.random(1, #self.evilAmbients);
				-- local randomizedAmbient = self.evilAmbients[randomizedIndex];
				-- AudioMan:QueueMusicStream(randomizedAmbient);
				-- table.remove(self.evilAmbients, randomizedIndex);
			-- end

		-- else
			-- --But if humans are left, play happy music!
			-- AudioMan:ClearMusicQueue();
			-- AudioMan:PlayMusic(self.victoryPath, 0, -1);
			-- for actor in MovableMan.Actors do
				-- if IsAHuman(actor) and self.gameActivity.WinnerTeam == actor.Team then
					-- ToAHuman(actor):SetNumberValue("Warcry Together", 1);
					-- ToAHuman(actor):SetNumberValue("Ye Olde Victory", 1); -- hmmmmm...
				-- end
			-- end
			-- for i = 1, #self.happyAmbients do
				-- AudioMan:QueueSilence(10);
				-- local randomizedIndex = math.random(1, #self.happyAmbients);
				-- local randomizedAmbient = self.happyAmbients[randomizedIndex];
				-- AudioMan:QueueMusicStream(randomizedAmbient);
				-- table.remove(self.happyAmbients, randomizedIndex);
			-- end
		-- end
	-- end
end

function ArmageddonMusicScript:PauseScript()
end

function ArmageddonMusicScript:CraftEnteredOrbit()
end
