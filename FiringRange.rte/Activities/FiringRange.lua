package.loaded.Constants = nil; require("Constants");

----------------------
--- Start Activity ---
----------------------

function FiringRangeMission:StartActivity()
	--print("START! -- FiringRangeMission:StartActivity()!");
	PresetMan:ReloadAllScripts();	-- reload .lua files
	if not FiringRangeIntroMessage then
		ConsoleMan:PrintString("     ");
		ConsoleMan:PrintString("     WELCOME TO 4ZK'S FIRING RANGE, ORIGINALLY MADE BY LURINGEN");
	--[[
	ConsoleMan:PrintString("     all .lua files are reloaded on reset");
	ConsoleMan:PrintString("     ")
	ConsoleMan:PrintString("     PageUp: increase TimeScale");
	ConsoleMan:PrintString("     PageDown: decrease TimeScale");
	ConsoleMan:PrintString("     cleanup = true: enable cleanup");
	ConsoleMan:PrintString("     antiair = true: spawn an enemy dropship")
	]]--
		ConsoleMan:PrintString("     ");
		self:GetBanner(GUIBanner.YELLOW, 0):ShowText("WELCOME TO", GUIBanner.FLYBYLEFTWARD, 1000, Vector(FrameMan.PlayerScreenWidth, FrameMan.PlayerScreenHeight), 0.4, 2000, 0);
		self:GetBanner(GUIBanner.RED, 0):ShowText("FIRING RANGE", GUIBanner.FLYBYRIGHTWARD, 1000, Vector(FrameMan.PlayerScreenWidth, FrameMan.PlayerScreenHeight), 0.6, 2000, 0);
		FiringRangeIntroMessage = true;
	else
		self:GetBanner(GUIBanner.YELLOW, 0):ShowText("RESET", GUIBanner.FLYBYLEFTWARD, 500, Vector(FrameMan.PlayerScreenWidth, FrameMan.PlayerScreenHeight), 0.5, 2000, 0);
	end
	AudioMan:ClearMusicQueue();
	AudioMan:PlayMusic("Base.rte/Music/Watts/Last Man.ogg", 2, -1.0);

	autoclear = true;

	self.weaponList = {};
	self.weaponCount = 0;
	FiringRangeActorList = {};

	local module = PresetMan:GetModuleID(self:GetTeamTech(0));
	
	for module in PresetMan.Modules do
		if module.Author then
			print(module.Author);
		end
		for entity in module.Presets do
			if (entity.ClassName == "HDFirearm" or entity.ClassName == "TDExplosive")
			and ToMOSRotating(entity).IsBuyable then
				table.insert(self.weaponList, entity);
				self.weaponCount = self.weaponCount + 1;
				--print(entity.PresetName);
			elseif (entity.ClassName == "AHuman" or entity.ClassName == "ACrab")
			and ToMOSRotating(entity).IsBuyable then
				table.insert(FiringRangeActorList, entity);
				if not ActorToSpawn and entity.PresetName == "Soldier Light" then
					ActorToSpawn = #FiringRangeActorList;
				end
			end
		end
	end
	ActorToSpawn = ActorToSpawn and ActorToSpawn or 5;
	self.playerWeaponID = 1;

	self.playerActor = "Brain Robot";	-- starting actor

	self.playerTech = PresetMan:GetModuleID(self:GetTeamTech(Activity.TEAM_1));
	self.CPUTech = PresetMan:GetModuleID(self:GetTeamTech(Activity.TEAM_2));

	self.menuV = 0;
	self.keyHeld = false;

	self.rangeGun = nil;
	self.gunTimer = Timer();

	cleanup = false;	--
	antiair = false;	--
	
	--Remove buy menu restrictions
	self.DeliveryDelay = 1;
	self:GetBuyGUI(0).EnforceMaxPassengersConstraint = false;
	self:GetBuyGUI(0).EnforceMaxMassConstraint = false;

	self.braindead = {};
	self.AssignedBrains = {};
	self.MOIDLimit = rte.MOIDCountMax;
	self.RespawnTimer = Timer();
	self.PlayerGold = 1000000;	-- one million dollars
   	self.CPUTeam = Activity.TEAM_2;
	self.PlayerTeam = Activity.TEAM_1;
	self.Disabled = 1
	self.Patrol = true;
	self.SpawnInterval = 5.0
	self.InOutSpawn1 = 0
	self.InOutSpawn2 = 0
	self.InOutSpawn3 = 0
	self.gunnerPos = Vector(3400, 810);

	for player = 0, self.PlayerCount - 1 do
        if not self:GetPlayerBrain(player) then
			self.braindead[player] = false;
			--local brain = RandomAHuman("Brains" , self.playerTech);
			local brain = CreateAHuman(self.playerActor);
			brain.Pos = Vector(3200, 520);
			brain.Team = self.PlayerTeam;
			brain:AddInventoryItem(CreateHDFirearm("Assault Rifle"));
			
			brain.AIMode = Actor.AIMODE_SENTRY;
			self.AssignedBrains[player] = brain;
			
            MovableMan:AddActor(brain);
            self:SetPlayerBrain(brain, player);
            SceneMan:SetScroll(self:GetPlayerBrain(player).Pos, player);
            self:SetObservationTarget(self:GetPlayerBrain(player).Pos, player);
			self:SwitchToActor(brain, player, self.PlayerTeam);
        end
    end
	--self:SetLZArea(Activity.TEAM_1, SceneMan.Scene:GetArea("LZ Team 1"));
	local guard = CreateAHuman("Soldier Light");
	--guard.PresetName = "Ronin Infantry Engineer";
	guard.Team = self.PlayerTeam;
	guard.Health = 100;
--[[
	--local testGun = CreateHDFirearm("Mauler SG-23");
	if not testGun.FullAuto then
		testGun.RateOfFire = 1000;
		testGun.ReloadTime = 0;
	end
	guard:AddInventoryItem(testGun);
--]]
	--guard:AddInventoryItem(CreateHDFirearm("Holy Revolver"));
	guard:AddInventoryItem(CreateHDFirearm("Assault Rifle"));
	guard.Pos = Vector(300, 500);
	guard.Pos = Vector(2800, 500);
	MovableMan:AddActor(guard);

	self.OutSpawn1 = SceneMan.Scene:GetArea("OutSpawn1");
	self.OutSpawn2 = SceneMan.Scene:GetArea("OutSpawn2");
	self.OutSpawn3 = SceneMan.Scene:GetArea("OutSpawn3");
	self.Range = SceneMan.Scene:GetArea("Range");
    self:SetTeamFunds(self.PlayerGold , self.PlayerTeam);
	
	self.tap = {counter = 0, limit = 3, timer = Timer(), time = 125};
	
	Button4Text = "Starting Spawner..."

	self.Respawn(0, 2028, 480, 0);

	self.Respawn(0, 2220, 480, 0);

	self.Respawn(0, 2412, 480, 0);
	
	self.actorList = {};
	for a in MovableMan.AddedActors do
		if a.PresetName == "Firing Range Door" then
			self.rangeDoor = ToADoor(a);
			break;
		end
	end
	--[[
	local player = Activity.PLAYER_2;
	self:ClearOverridePurchase(player)
	self:SetLandingZone(Vector(2900, 0), player)
	self:SetOverridePurchaseList("Default", player)
	self:CreateDelivery(player)
	]]--
end
--[[
function FiringRangeMission:OnPieMenu(pieActor)
	if self.pieAI then
		self:RemovePieMenuSlice("Form Squad", "");
		self:RemovePieMenuSlice("Brain Hunt AI Mode", "");
		self:RemovePieMenuSlice("Patrol AI Mode", "");
		self:RemovePieMenuSlice("Gold Dig AI Mode", "");
		self:RemovePieMenuSlice("Go-To AI Mode", "");
		self:RemovePieMenuSlice("Sentry AI Mode", "");
		
		self.pieAI = nil;
	else
		self.pieAI = true;
		self:RemovePieMenuSlice("Reload", "");
		self:RemovePieMenuSlice("Next Item", "");
		self:RemovePieMenuSlice("Prev Item", "");
		if IsAHuman(pieActor) then
			self:RemovePieMenuSlice(ToAHuman(pieActor).EquippedItem and "Drop ".. ToAHuman(pieActor).EquippedItem.PresetName or "Not holding anything!", "");
		end
		self:RemovePieMenuSlice("Buy Menu", "");
		self:RemovePieMenuSlice("Sentry AI Mode", "");
		--self:AddPieMenuSlice("Name", "Preset", Slice.UP, true);
	end
end
]]--
function FiringRangeMission:PauseActivity(pause)
end

function FiringRangeMission:EndActivity()
end

function FiringRangeMission:DoBrainSelection()
	if not (self.ActivityState == Activity.OVER) then
		for player = 0, self.PlayerCount - 1 do
			local team = self:GetTeamOfPlayer(player);

			local brain = self:GetPlayerBrain(player);
			if MovableMan:IsActor(brain) then
			elseif not brain or not MovableMan:IsActor(brain) or not brain:HasObjectInGroup("Brains") then

				self:SetPlayerBrain(nil, player);
				local newBrain = MovableMan:GetUnassignedBrain(team);
				if newBrain and self.braindead[player] == false then
					self:SetPlayerBrain(newBrain, player);
					self:SwitchToActor(newBrain, player, team);
				else							-- if brain dies, just spawn a new one
					self.braindead[player] = false;
					local brain = CreateAHuman("Base.rte/Brain Robot");
					brain.Pos = Vector(3200, 480);
					brain:AddInventoryItem(RandomHDFirearm("Light Weapons", self.playerTech));
					brain:AddInventoryItem(RandomHDFirearm("Secondary Weapons", self.playerTech));
					brain:AddInventoryItem(RandomTDExplosive("Grenades", self.playerTech));
					brain.AIMode = Actor.AIMODE_SENTRY;
					self.AssignedBrains[player] = brain;

       					MovableMan:AddActor(brain);
          				self:SetPlayerBrain(brain, player);
					SceneMan:SetScroll(self:GetPlayerBrain(player).Pos, player);
					self:SetObservationTarget(self:GetPlayerBrain(player).Pos, player);
					self:SwitchToActor(brain, player, self.PlayerTeam);
				end
			end
		end
	end
end

function FiringRangeMission:UpdateActivity()

	-- Different actions with global values
	if T then	-- quick timescale alteration
		TimerMan.TimeScale = T;
		ConsoleMan:PrintString("    TimeScale set to ".. T);
		T = nil;
	end
	if rof then
		for a in MovableMan.Actors do
			if IsAHuman(a) and ToAHuman(a).EquippedItem and IsHDFirearm(ToAHuman(a).EquippedItem) then
				ToHDFirearm(ToAHuman(a).EquippedItem).RateOfFire = rof;
			end
		end
		ConsoleMan:PrintString("    Rate of Fire set to ".. rof);
		rof = nil;
	end
	if rt then
		for a in MovableMan.Actors do
			if IsAHuman(a) and ToAHuman(a).EquippedItem and IsHDFirearm(ToAHuman(a).EquippedItem) then
				ToHDFirearm(ToAHuman(a).EquippedItem).ReloadTime = rt;
			end
		end
		ConsoleMan:PrintString("    Reload Time set to ".. rt);
		rt = nil;
	end
	if unseen then
		if unseen == true then
			ConsoleMan:PrintString("    Fog enabled");
			SceneMan:MakeAllUnseen(Vector(25, 25), self.PlayerTeam);
		end
		unseen = nil;
	elseif unseen == false then
		ConsoleMan:PrintString("    Fog disabled");
		SceneMan:RevealUnseenBox(0, 0, SceneMan.SceneWidth, SceneMan.SceneHeight, self.PlayerTeam);
		unseen = nil;
	end
	if cleararea then
		-- above ground area
		for i = 0, 6 do
			local clear = CreateTerrainObject("FiringRange.rte/Clear 4X4"); 
			clear.Pos = Vector(1884 + (i * 96), 420);
			SceneMan:AddTerrainObject(clear);
		end
		-- under ground area
		for i = 0, 5 do
			local clear = CreateTerrainObject("FiringRange.rte/Clear 4X4"); 
			clear.Pos = Vector(3468 + (i * 96), 732);
			SceneMan:AddTerrainObject(clear);
		end
		for i = 0, 6 do
			local clear = CreateTerrainObject("FiringRange.rte/Clear 4X4"); 
			clear.Pos = Vector(3468 + (i * 96), 636);
			SceneMan:AddTerrainObject(clear);
		end
		local clear = CreateTerrainObject("FiringRange.rte/Clear 4X4"); 
		clear.Pos = Vector(12, 696);
		SceneMan:AddTerrainObject(clear);
		if not autoclear then
			ConsoleMan:PrintString("    Spawn areas cleared");
		end
		cleararea = false;
	end
	if antiair then
		local ship = CreateACDropShip("Dropship MK1");
		ship.Pos = Vector(300, -ship.Radius);

		ship.Status = Actor.STABLE;
		ship.AIMode = Actor.AIMODE_STAY;
		ship.Team = self.CPUTeam;
		MovableMan:AddActor(ship);

		ConsoleMan:PrintString("    Dropship spawned");
		antiair = false;
	end
	self:CheckActors();

	if self.RespawnTimer:IsPastSimMS(1000 * self.SpawnInterval) and MovableMan:GetMOIDCount() <= self.MOIDLimit then
		self:CheckRespawn();
		self.RespawnTimer:Reset();
	end
	self:DoBrainSelection();
end


function FiringRangeMission:CheckActors()

	if UInputMan:AnyPress() and UInputMan:KeyPressed(67) then
		print("enter");
	end
	self.Disabled = 1;
	self.InOutSpawn1 = 0;
	self.InOutSpawn2 = 0;
	self.InOutSpawn3 = 0;
	for act in MovableMan.Actors do

		if self.rangeTarget and act.Team == self.CPUTeam then
			act.ToDelete = true;
		end

		if self.OutSpawn1:IsInside(act.Pos) then
			self.InOutSpawn1 = 1
		end
		
		if self.OutSpawn2:IsInside(act.Pos) then
			self.InOutSpawn2 = 1
		end
		
		if self.OutSpawn3:IsInside(act.Pos) then
			self.InOutSpawn3 = 1
		end

		local cont = act:GetController();
		if act:IsPlayerControlled() then
		
				A = nil;
				A = act;
		
				if kill then
					act.Health = 0;
					kill = nil;
				end

				--[[ get two vectors for the effective radius of an mo from the AI's angle/position

				local lowVector = Vector();
				local highVector = Vector();

				lowVector = Vector(act.Pos.X,act.Pos.Y) + Vector(0,act.Radius);
				highVector = Vector(act.Pos.X,act.Pos.Y) + Vector(0,-act.Radius);

				local lowRange = act.Radius;
				local highRange = act.Radius;

				for mo in ToActor(act).Attachables do
					local partDist = SceneMan:ShortestDistance(act.Pos, mo.Pos, SceneMan.SceneWrapsX);
					-- rotate the vector as if the AI->target vector was perfectly horizontal
					if partDist.Y + mo.Radius > highRange then
						highRange = partDist.Y + mo.Radius;
					end
					if partDist.Y - mo.Radius < lowRange then
						lowRange = partDist.Y - mo.Radius;
					end
				end
				lowVector = Vector(act.Pos.X,act.Pos.Y) + Vector(0,lowRange);
				highVector = Vector(act.Pos.X,act.Pos.Y) + Vector(0,highRange);

				PrimitiveMan:DrawLinePrimitive(lowVector, highVector, 13);
				]]--
			if C then
				C = nil;
				if Clone then
					print(Clone);
					Clone.Pos = act.Pos;
					MovableMan:AddActor(Clone);
					Clone = nil;
				else
					Clone = act:Clone();
				end
			end

	local A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z;
	local n0, n1, n2, n3, n4, n5, n6, n7, n8, n9;
	local np0, np1, np2, np3, np4, np5, np6, np7, np8, np9;
	local spacebar, insert, delete, pageup, pagedown;

		A = 1;	N = 14;	n0 = 27;	np0 = 37;	-- wiki: keylist
		B = 2;	O = 15;	n1 = 28;	np1 = 38;
		C = 3;	P = 16;	n2 = 29;	np2 = 39;
		D = 4;	Q = 17;	n3 = 30;	np3 = 40;
		E = 5;	R = 18;	n4 = 31;	np4 = 41;
		F = 6;	S = 19;	n5 = 32;	np5 = 42;
		G = 7;	T = 20;	n6 = 33;	np6 = 43;
		H = 8;	U = 21;	n7 = 34;	np7 = 44;
		I = 9;	V = 22;	n8 = 35;	np8 = 45;
		J = 10;	W = 23;	n9 = 36;	np9 = 46;
		K = 11;	X = 24;
		L = 12;	Y = 25;
		M = 13;	Z = 26;

	spacebar = 75;
	insert = 76;
	delete = 77;
	pageup = 80;
	pagedown = 81;

			if UInputMan:KeyPressed(insert) and self.keyHeld == false then	-- generate an automatic gun for testing (WIP)
				self.keyHeld = true;

				if IsAHuman(act) then
					act = ToAHuman(act);
					
					local attackDistance = 100;
					
					if self.rangeGuy then
						self.rangeGuy.ToDelete = true;
						self.rangeGuy = nil;
					end
					if self.rangeTarget then
						self.rangeTarget.ToDelete = true;
					end
					if self.rangeDoor then
						self.rangeDoor:OpenDoor();
						self.rangeDoor:SetClosedByDefault(false);
					end

					if act.EquippedItem and IsHDFirearm(act.EquippedItem) then
						local gun = ToHDFirearm(act.EquippedItem);
						attackDistance = math.min(math.min(gun:GetAIFireVel() * gun:GetAIBulletLifeTime()/TimerMan.DeltaTimeMS * rte.PxTravelledPerFrame, gun.SharpLength), 500);

						self.rangeGuy = CreateAHuman("FiringRange.rte/Test Dummy");
						self.rangeGuy.Pos = self.gunnerPos;
						self.rangeGuy.PinStrength = 1000;
						self.rangeGuy.Team = self.PlayerTeam;
						self.rangeGun = gun:Clone();
						self.rangeGun.JointStrength = 10000;
						self.rangeGun.GibWoundLimit = 1000;
						self.rangeGuy:AddInventoryItem(self.rangeGun);
						MovableMan:AddActor(self.rangeGuy);

						self.rangeTarget = CreateAHuman("FiringRange.rte/Test Dummy");
						self.rangeTarget.PinStrength = 1000;
						self.rangeTarget:SetStringValue("rangeGun PresetName", self.rangeGun:GetModuleAndPresetName());
						MovableMan:AddActor(self.rangeTarget);
						self.rangeTarget:SetNumberValue("rangeGun GoldValue", self.rangeGun:GetGoldValue(0, 1, 1));
						self.rangeTarget:SetNumberValue("rangeGun MagazineMass", self.rangeGun.Magazine.Mass);				--
						self.rangeTarget:SetNumberValue("rangeGun Mass", self.rangeGun.Mass - self.rangeGun.Magazine.Mass);	-- display separately
						self.rangeTarget:SetNumberValue("rangeGun SharpLength", self.rangeGun.SharpLength);
						self.rangeTarget:SetNumberValue("rangeGun ShakeRange", self.rangeGun.ShakeRange);
						self.rangeTarget:SetNumberValue("rangeGun SharpShakeRange", self.rangeGun.SharpShakeRange);
						self.rangeTarget:SetNumberValue("rangeGun RateOfFire", self.rangeGun.RateOfFire);
						self.rangeTarget:SetNumberValue("rangeGun ReloadTime", self.rangeGun.ReloadTime);
						self.rangeTarget:SetNumberValue("rangeGun Ammo", self.rangeGun.Magazine.RoundCount);
						self.rangeTarget:SetNumberValue("rangeGun FullAuto", 0);
						if self.rangeGun.FullAuto then
							self.rangeTarget:SetNumberValue("rangeGun FullAuto", 1);
						end
						self.rangeTarget:SetNumberValue("rangeGun OneHanded/DualWieldable", 0);
						if self.rangeGun:IsOneHanded() then
							self.rangeTarget:SetNumberValue("rangeGun OneHanded/DualWieldable", 1);
							if self.rangeGun:IsDualWieldable() then
								self.rangeTarget:SetNumberValue("rangeGun OneHanded/DualWieldable", 2);
							end
						end
					elseif act.EquippedItem and IsTDExplosive(act.EquippedItem) then

						self.rangeNade = CreateTDExplosive(act.EquippedItem:GetModuleAndPresetName());
						
						attackDistance = self.rangeNade.MaxThrowVel * self.rangeNade.Mass < self.rangeNade.GibImpulseLimit and 100 or 200;
						MovableMan:AddParticle(self.rangeNade);

						self.rangeTarget = CreateActor("DPS meter");
						self.rangeTarget:SetStringValue("rangeGun PresetName", self.rangeNade:GetModuleAndPresetName());
						MovableMan:AddActor(self.rangeTarget);
						self.rangeTarget:SetNumberValue("rangeGun GoldValue", self.rangeNade:GetGoldValue(0,1,1));--
						self.rangeTarget:SetNumberValue("rangeGun Mass", self.rangeNade.Mass);
						self.rangeTarget:SetNumberValue("rangeGun MinThrowVel", self.rangeNade.MinThrowVel);
						self.rangeTarget:SetNumberValue("rangeGun MaxThrowVel", self.rangeNade.MaxThrowVel);	-- also counts as throwable check
					end
					self.rangeTarget.Pos = self.gunnerPos + Vector(25 + attackDistance, 0);
					self.rangeTarget.HFlipped = true;
				end
			else
				self.keyHeld = false;
			end

			if UInputMan:KeyPressed(delete) and self.keyHeld == false then	-- delete rangeGun
				self.keyHeld = true;

				if self.rangeGuy then
					self.rangeGuy.ToDelete = true;
					self.rangeGuy = nil;
				end
			else
				self.keyHeld = false;
			end

			if UInputMan:KeyPressed(pageup) and self.keyHeld == false then
				self.keyHeld = true;

				--FrameMan:SetScreenText("TimeScale = " .. TimerMan.TimeScale, act.Team, 0, 1000, false);

				if TimerMan.TimeScale < 2 then
					TimerMan.TimeScale = TimerMan.TimeScale + 0.1;
				--else
				--	TimerMan.TimeScale = 2;
				end
			else
				self.keyHeld = false;
			end

			if UInputMan:KeyPressed(pagedown) and self.keyHeld == false then
				self.keyHeld = true;

				--FrameMan:SetScreenText("TimeScale = " .. TimerMan.TimeScale, act.Team, 0, 1000, false);

				if TimerMan.TimeScale > 0.1 then
					TimerMan.TimeScale = TimerMan.TimeScale - 0.1;
				--else
				--	TimerMan.TimeScale = 0.1;
				end
			else
				self.keyHeld = false;
			end

			--FrameMan:SetScreenText("TimeScale = " .. math.floor(TimerMan.TimeScale * 10 + 0.01) / 10, act.Team, 0, 1000, false);

			if UInputMan:KeyHeld(spacebar) then
			
				-- Offset the lua menu if using spacebar
				local menuOffset = 60;
				if cont:IsState(Controller.PIE_MENU_ACTIVE) then
					menuOffset = 0;
				end

				cont:SetState(Controller.MOVE_LEFT, false);
				cont:SetState(Controller.MOVE_RIGHT, false);
				cont:SetState(Controller.AIM_UP, false);
				cont:SetState(Controller.AIM_DOWN, false);
				
				if UInputMan:KeyPressed(W)
				and self.keyHeld == false then
					self.keyHeld = true;

					if self.menuV > 0 then
						self.menuV = self.menuV - 1;
					else
						self.menuV = 2;
					end
				else
					self.keyHeld = false;
				end
				--if cont:IsState(Controller.BODY_CROUCH) then	--down
				if UInputMan:KeyPressed(S)
				and self.keyHeld == false then
					self.keyHeld = true;

					if self.menuV < 2 then
						self.menuV = self.menuV + 1;
					else
						self.menuV = 0;
					end
				else
					self.keyHeld = false;
				end
				--if cont:IsState(Controller.MOVE_LEFT) then
				if UInputMan:KeyPressed(A)
				and self.keyHeld == false then
					self.keyHeld = true;

					if self.menuV == 0 then		-- ActorToSpawn 
						if ActorToSpawn == 1 then
							ActorToSpawn = #FiringRangeActorList;
						else
							ActorToSpawn = ActorToSpawn - 1;
						end

					elseif self.menuV == 1 then	-- self.Patrol
						if self.Patrol == false then
							self.Patrol = true;
						else
							self.Patrol = false;
						end

					elseif self.menuV == 2 then	-- SpawnInterval

						if self.SpawnInterval > 1.0 then
				
							self.SpawnInterval = self.SpawnInterval - 0.5;	-- seconds
						else
							self.SpawnInterval = 30.0;
						end
					end
				else
					self.keyHeld = false;
				end
				--if cont:IsState(Controller.MOVE_RIGHT) then
				if UInputMan:KeyPressed(D) and self.keyHeld == false then
					self.keyHeld = true;

					if self.menuV == 0 then		-- ActorToSpawn 
						if ActorToSpawn == #FiringRangeActorList then
							ActorToSpawn = 1;
						else
							ActorToSpawn = ActorToSpawn + 1;
						end

					elseif self.menuV == 1 then	-- Patrol
						if self.Patrol == false then
							self.Patrol = true;
						else
							self.Patrol = false;
						end

					elseif self.menuV == 2 then	-- SpawnInterval

						if self.SpawnInterval < 30 then
				
							self.SpawnInterval = self.SpawnInterval + 0.5;	-- seconds
						else
							self.SpawnInterval = 1;		-- 30 seconds max, return to 1
						end
					end
				else
					self.keyHeld = false;
				end

				local patroltext = self.Patrol == true and "Walk into pit" or "Stand still";
				
				if IsAHuman(act) then
					act = ToAHuman(act);
					local changed = false;
					
					if not self.tap.timer:IsPastSimMS(self.tap.time) then
						if math.abs(self.tap.counter) >= self.tap.limit then
							changed = true;
							if self.tap.counter > 0 then
								self.playerWeaponID = self.playerWeaponID >= self.weaponCount and 1 or self.playerWeaponID + 1;
							else
								self.playerWeaponID = self.playerWeaponID <= 1 and self.weaponCount or self.playerWeaponID - 1;
							end
						end
					else
						self.tap.counter = 0;
					end
					if cont:IsState(Controller.WEAPON_CHANGE_PREV) then
						cont:SetState(Controller.WEAPON_CHANGE_PREV, false);
						
						self.tap.counter = self.tap.counter - 1;
						self.tap.timer:Reset();
						changed = true;
	
						self.playerWeaponID = self.playerWeaponID <= 1 and self.weaponCount or self.playerWeaponID - 1;
					end
					if cont:IsState(Controller.WEAPON_CHANGE_NEXT) then
						cont:SetState(Controller.WEAPON_CHANGE_NEXT, false);
						
						self.tap.counter = self.tap.counter + 1;
						self.tap.timer:Reset();
						changed = true;
		
						self.playerWeaponID = self.playerWeaponID >= self.weaponCount and 1 or self.playerWeaponID + 1;
					end
					
					local tempWeapon = self.weaponList[self.playerWeaponID];
					
					if changed then
						local classCheck = {};
						classCheck[#classCheck + 1] = {class = "HDFirearm", create = CreateHDFirearm};
						classCheck[#classCheck + 1] = {class = "HeldDevice", create = CreateHeldDevice};
						classCheck[#classCheck + 1] = {class = "TDExplosive", create = CreateTDExplosive};
						classCheck[#classCheck + 1] = {class = "ThrownDevice", create = CreateThrownDevice};
						for _, check in pairs(classCheck) do
							if tempWeapon.ClassName == check.class then
								local inventory = act:Inventory();
								if inventory then
									act:RemoveInventoryItem(inventory.PresetName);
								end
								act:AddInventoryItem(check.create(tempWeapon:GetModuleAndPresetName()));
							end
						end
					end
					PrimitiveMan:DrawTextPrimitive(act.AboveHUDPos+Vector(-34,menuOffset-104), tempWeapon.PresetName, true, 0);
				end
				
				PrimitiveMan:DrawTextPrimitive(act.AboveHUDPos+Vector(-38,menuOffset-86+self.menuV*8), ">" , true, 0);
				PrimitiveMan:DrawTextPrimitive(act.AboveHUDPos+Vector(-34,menuOffset-86), "Actor to spawn: " .. Button4Text, true, 0);
				PrimitiveMan:DrawTextPrimitive(act.AboveHUDPos+Vector(-34,menuOffset-78), "Movement: " .. patroltext, true, 0);
				PrimitiveMan:DrawTextPrimitive(act.AboveHUDPos+Vector(-34,menuOffset-70), "Spawn interval: " .. self.SpawnInterval .. " s", true, 0);
			end

			if self.Range:IsInside(act.Pos) then
				self.Disabled = 0
			end
		end

		if act.Team == self.CPUTeam and act.ClassName ~= "ACDropShip" then
			for i = 0, 40 do	-- Go through and disable all 40 + 1 controller states
				cont:SetState(i, false);
			end
			if act.AIMode == Actor.AIMODE_GOTO then
				cont:SetState(Controller.MOVE_LEFT, true);
			end
		end
	end
	Button4Text = FiringRangeActorList[ActorToSpawn].PresetName;

	if self.rangeGuy then
		if self.rangeDoor then
			self.rangeDoor:OpenDoor();
		end
		if self.rangeGuy.EquippedItem and IsHDFirearm(self.rangeGuy.EquippedItem) then
			local gun = ToHDFirearm(self.rangeGuy.EquippedItem);
			local controller = self.rangeGuy:GetController();	
			controller:SetState(Controller.AIM_SHARP, true);
			if self.rangeGuy.FirearmNeedsReload then
				controller:SetState(Controller.WEAPON_RELOAD, true);
			elseif self.rangeGuy.FirearmIsReady then
				controller:SetState(Controller.WEAPON_FIRE, gun.FullAuto or math.random() < 0.5);
			end
		end
		self.rangeGuy.PinStrength = 1000;
		self.rangeGuy.HFlipped = false;
		self.rangeGuy:SetAimAngle(0);
	end
--[[
	if self.rangeGun then	---- DESTROYING THE RANGEGUN CRASHES GAME, JUST DON'T DO IT OKAY THX ----

		self.rangeGun:RemoveWounds(99);

		if self.rangeGun.Magazine then

			local FireVel = 100;
			local GlobalAcc = 1;
			if self.rangeGun.Magazine.NextRound then
				FireVel = self.rangeGun.Magazine.NextRound.FireVel;
				GlobalAcc = self.rangeGun.Magazine.NextRound.NextParticle.GlobalAccScalar;
			end
		
			self.rangeGun.RotAngle = (SceneMan.GlobalAcc.Y * GlobalAcc)/((math.abs(FireVel * 0.3) + 1) ^ 2);	-- "professional trajectory guide"
		end

		self.rangeGun.Pos = Vector(3500, 802);
		self.rangeGun.Vel = Vector();
		self.rangeGun.AngularVel = 0;

		if self.rangeGun.Magazine then
			if self.rangeGun.FullAuto == false and self.rangeGun.RateOfFire > 0 then

				if self.rangeGun.FiredFrame then
					self.gunTimer:Reset();
					self.rangeGun:Deactivate();
				end

				-- time in between shots = 60000 / ROF

				if self.gunTimer:IsPastSimMS(60000/self.rangeGun.RateOfFire) then
					self.rangeGun:Activate();
				end
			else
				self.rangeGun:Activate();
			end
			if self.rangeGun.Magazine.RoundCount == 0 then
				self.rangeGun:Reload();
			end
		else
			self.gunTimer:Reset();
			self.rangeGun:Reload();
			self.rangeGun:Deactivate();
		end
	else
		self.gunTimer:Reset();
	end]]--
end

function FiringRangeMission:CheckRespawn()

	if autoclear then
		cleararea = true;
	end
	if not self.rangeTarget then	-- don't spam enemies when auto-testing
		if self.Disabled == 0 then
			if self.Patrol == false then
				self.Respawn(0, 84, 744, 0);
			else
				self.Respawn(0, 84, 744, 1);
			end
		end
	end
		
	if self.InOutSpawn1 == 0 then
		self.Respawn(0, 2028, 480, 0);
	end
		
	if self.InOutSpawn2 == 0 then
		self.Respawn(0, 2220, 480, 0);
	end
	
	if self.InOutSpawn3 == 0 then
		self.Respawn(0, 2412, 480, 0);
	end
end 

function FiringRangeMission:Respawn(x, y, patrol)
	local actor;
	local entity = FiringRangeActorList[ActorToSpawn];
	if entity then
		if entity.ClassName == "AHuman" then
			actor = CreateAHuman(entity:GetModuleAndPresetName());
			--actor:AddInventoryItem(CreateHDFirearm("Assault Rifle"));
		elseif entity.ClassName == "ACrab" then
			actor = CreateACrab(entity:GetModuleAndPresetName());
		end
	end
	if actor then
		if patrol == 1 then
			actor.AIMode = Actor.AIMODE_GOTO;
			actor:ClearAIWaypoints();
			actor:AddAISceneWaypoint(Vector(3516, 816));
		else
			actor.AIMode = Actor.AIMODE_SENTRY;
		end
		actor.Pos = Vector(x, y);
		actor.Team = FiringRangeMission.CPUTeam;
		--actor.Health = actor.MaxHealth * 10;
		MovableMan:AddActor(actor);
	end
end

function FiringRangeMission:UpdateMarkers()
	self:ClearObjectivePoints();
end

function FiringRangeMission:GetModule(preset, friendlyName)
	local module = string.gsub(preset:GetModuleAndPresetName(), "/".. preset.PresetName, "");
	if friendlyName == true then
		module = PresetMan:GetModuleID(module);
	end
	return module;
end