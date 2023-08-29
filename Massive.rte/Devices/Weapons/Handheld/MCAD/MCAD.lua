function OnReload(self)

	if self.spentRound then
		-- Switched magically turns itself back on for some reason so tell it here to disable itself before it acts
		
		-- new info: it magically turns itself back on because the Reload function in the pie menu is actually before the
		-- value setting... i could remove this and fix it, but time is precious and life is short so i wrote this instead
		
		self.weirdoFixer = true;
		self.spentRound = false;
	end
	
end

function Create(self)

	if self:GetRootParent() and self:GetRootParent().PresetName == "Massive" or self:GetRootParent().PresetName == "Zedmassive" then
		self.equippedByMassive = true;
	else
		self.equippedByMassive = false;
	end
	
	self.Frame = 0;
	self.roundLocked = true;
	self.leverCocked = true;

	self.rocketRemoveSound = CreateSoundContainer("Rocket Remove Massive MCAD", "Massive.rte");

	self.preSound = CreateSoundContainer("Pre Massive MCAD", "Massive.rte");
	self.fireOutdoorsSound = CreateSoundContainer("Fire Outdoors Massive MCAD", "Massive.rte");
	self.fireIndoorsSound = CreateSoundContainer("Fire Indoors Massive MCAD", "Massive.rte");
	
	self.reloadPrepareSounds = {}
	self.reloadPrepareSounds.Raise = nil
	self.reloadPrepareSounds.RocketIn = CreateSoundContainer("Rocket In Prepare Massive MCAD", "Massive.rte");
	self.reloadPrepareSounds.RocketLock = nil
	self.reloadPrepareSounds.Cock = nil
	self.reloadPrepareSounds.Lower = CreateSoundContainer("Lower Prepare Massive MCAD", "Massive.rte");
	
	self.reloadPrepareLengths = {}
	self.reloadPrepareLengths.Raise = 0
	self.reloadPrepareLengths.RocketIn = 565
	self.reloadPrepareLengths.RocketLock = 0
	self.reloadPrepareLengths.Cock = 0
	self.reloadPrepareLengths.Lower = 620
	
	self.reloadPrepareDelay = {}
	self.reloadPrepareDelay.Raise = 345
	self.reloadPrepareDelay.RocketIn = 700
	self.reloadPrepareDelay.RocketLock = 230
	self.reloadPrepareDelay.Cock = 800
	self.reloadPrepareDelay.Lower = 1000
	
	self.reloadAfterSounds = {}
	self.reloadAfterSounds.Raise = CreateSoundContainer("Raise Massive MCAD", "Massive.rte");
	self.reloadAfterSounds.RocketIn = CreateSoundContainer("Rocket In Massive MCAD", "Massive.rte");
	self.reloadAfterSounds.RocketLock = CreateSoundContainer("Rocket Lock Massive MCAD", "Massive.rte");
	self.reloadAfterSounds.Cock = CreateSoundContainer("Cock Massive MCAD", "Massive.rte");
	self.reloadAfterSounds.Lower = CreateSoundContainer("Lower Massive MCAD", "Massive.rte");
	
	self.reloadAfterDelay = {}
	self.reloadAfterDelay.Raise = 1000
	self.reloadAfterDelay.RocketIn = 600
	self.reloadAfterDelay.RocketLock = 450
	self.reloadAfterDelay.Cock = 450
	self.reloadAfterDelay.Lower = 700
	
	self.reloadTimer = Timer();
	
	self.reloadPhase = 0;
	
	self.BaseReloadTime = 12000;

	self.parentSet = false;
	
	self.rotation = 0
	self.rotationTarget = 0
	self.rotationSpeed = 3
	
	self.horizontalAnim = 0
	self.verticalAnim = 0
	
	self.angVel = 0
	self.lastRotAngle = (self.RotAngle + self.InheritedRotAngleOffset)
	
	self.originalSharpLength = self.SharpLength
	
	self.originalJointOffset = Vector(self.JointOffset.X, self.JointOffset.Y)
	self.originalStanceOffset = Vector(math.abs(self.StanceOffset.X), self.StanceOffset.Y)
	self.originalSharpStanceOffset = Vector(self.SharpStanceOffset.X, self.SharpStanceOffset.Y)
	
	self.delayedFire = false
	self.delayedFireTimer = Timer();
	self.delayedFireTimeMS = 70;
	self.delayedFireEnabled = true
	
	self.searchRange = 650 + FrameMan.PlayerScreenWidth * 0.3;
	
	self.lastAge = self.Age + 0
	
	self.FireTimer = Timer();
	self.fireDelayTimer = Timer()
	
	self.activated = false
	
	self.shoveTimer = Timer();
	self.shoveCooldown = 1300;
	
	self.extraFrameNum = 4
	
	self.Reloadable = false;
	
end

function Update(self)

	self.rotationTarget = 0 -- ZERO IT FIRST AAAA!!!!!

	if self:GetRootParent().UniqueID == self.UniqueID then
		self.parent = nil;
		self.parentSet = false;
	elseif self.parentSet == false then
		self.parent = ToActor(self:GetRootParent());
		self.parentSet = true;
	end
	
    -- Smoothing
    local min_value = -math.pi;
    local max_value = math.pi;
    local value = (self.RotAngle) - self.lastRotAngle
    local result;
    local ret = 0
    
    local range = max_value - min_value;
    if range <= 0 then
        result = min_value;
    else
        ret = (value - min_value) % range;
        if ret < 0 then ret = ret + range end
        result = ret + min_value;
    end
    
    self.lastRotAngle = (self.RotAngle)
    self.angVel = (result / TimerMan.DeltaTimeSecs * 1.4) * self.FlipFactor
    
    if self.lastHFlipped ~= nil then
        if self.lastHFlipped ~= self.HFlipped then
            self.lastHFlipped = self.HFlipped
            self.angVel = 0
        end
    else
        self.lastHFlipped = self.HFlipped
    end

	-- Check if switched weapons/hide in the inventory, etc.
	if self.Age > (self.lastAge + TimerMan.DeltaTimeSecs * 2000) then
		if self.delayedFire then
			self.delayedFire = false
		end
		self.fireDelayTimer:Reset()
	end
	self.lastAge = self.Age + 0
	
	if self:IsReloading() then
		if self.parent and self.reloadPhase > 1 and self.reloadPhase < 4 then
			self.parent:GetController():SetState(Controller.AIM_SHARP,false);
		end
		
		if self.weirdoFixer == true then
			self.weirdoFixer = false;
			if self:NumberValueExists("Switched") then
				if self:NumberValueExists("DUAP Round") then
					self.extraFrameNum = 0
				else
					self.extraFrameNum = 4
				end
				self:RemoveNumberValue("Switched")
			end
		end		
		
		if self.roundLocked then
			if self:NumberValueExists("Switched") then
				self.Frame = 3 + self.extraFrameNum;
				self.rocketRemoveSound:Play(self.Pos);
				if self.reloadPhase ~= 0 then
					self.reloadPhase = 1
					self.reloadTimer:Reset();
					self.afterSoundPlayed = false;
					self.prepareSoundPlayed = false;
				end
				if self:NumberValueExists("DUAP Round") then
					local shell = CreateMOSRotating("Massive MCAD Inert HE");
					shell.Pos = self.Pos + Vector(16*self.FlipFactor, -1):RadRotate(self.RotAngle);
					shell.Vel = Vector(2*self.FlipFactor, 0):RadRotate(self.RotAngle);
					shell.HFlipped = self.HFlipped;
					MovableMan:AddParticle(shell);
					self.extraFrameNum = 0
				else
					local shell = CreateMOSRotating("Massive MCAD Inert DUAP");
					shell.Pos = self.Pos + Vector(16*self.FlipFactor, -1):RadRotate(self.RotAngle);
					shell.Vel = Vector(2*self.FlipFactor, 0):RadRotate(self.RotAngle);
					shell.HFlipped = self.HFlipped;
					MovableMan:AddParticle(shell);		
					self.extraFrameNum = 4		
				end
				
				self:RemoveNumberValue("Switched")
				self.roundLocked = false;
				
			end
		end
				
		
		-- if not self:NumberValueExists("MagRemoved") and self.parent:IsPlayerControlled() then
			-- local color = (self.reloadPhase < 2 and 105 or 120)
			-- local position = self.parent.AboveHUDPos + Vector(0, 36)
			-- PrimitiveMan:DrawCirclePrimitive(position + Vector(0,-3), 2, color);
			-- PrimitiveMan:DrawLinePrimitive(position + Vector(2,-2), position + Vector(2,4), color);
			-- PrimitiveMan:DrawLinePrimitive(position + Vector(-2,-2), position + Vector(-2,4), color);
			-- PrimitiveMan:DrawLinePrimitive(position + Vector(2,4), position + Vector(-2,4), color);
		-- end

		if self.reloadPhase == 0 then
			self.reloadDelay = self.reloadPrepareDelay.Raise;
			self.afterDelay = self.reloadAfterDelay.Raise;		
			
			self.prepareSound = self.reloadPrepareSounds.Raise;
			self.prepareSoundLength = self.reloadPrepareLengths.Raise;
			self.afterSound = self.reloadAfterSounds.Raise;
			
		elseif self.reloadPhase == 1 then
			self.reloadDelay = self.reloadPrepareDelay.RocketIn;
			self.afterDelay = self.reloadAfterDelay.RocketIn;		
			
			self.prepareSound = self.reloadPrepareSounds.RocketIn;
			self.prepareSoundLength = self.reloadPrepareLengths.RocketIn;
			self.afterSound = self.reloadAfterSounds.RocketIn;
			
			self.rotationTarget = 45;
			
		elseif self.reloadPhase == 2 then
			self.reloadDelay = self.reloadPrepareDelay.RocketLock;
			self.afterDelay = self.reloadAfterDelay.RocketLock;		
			
			self.prepareSound = self.reloadPrepareSounds.RocketLock;
			self.prepareSoundLength = self.reloadPrepareLengths.RocketLock;
			self.afterSound = self.reloadAfterSounds.RocketLock;
			
			self.rotationTarget = 45;
			
		elseif self.reloadPhase == 3 then
			self.reloadDelay = self.reloadPrepareDelay.Cock;
			self.afterDelay = self.reloadAfterDelay.Cock;		
			
			self.prepareSound = self.reloadPrepareSounds.Cock;
			self.prepareSoundLength = self.reloadPrepareLengths.Cock;
			self.afterSound = self.reloadAfterSounds.Cock;
			
			self.rotationTarget = 40;
			
		elseif self.reloadPhase == 4 then
			self.reloadDelay = self.reloadPrepareDelay.Lower;
			self.afterDelay = self.reloadAfterDelay.Lower;		
			
			self.prepareSound = self.reloadPrepareSounds.Lower;
			self.prepareSoundLength = self.reloadPrepareLengths.Lower;
			self.afterSound = self.reloadAfterSounds.Lower;

			self.rotationTarget = 25;
		end
		
		if self.prepareSoundPlayed ~= true
		and self.reloadTimer:IsPastSimMS(self.reloadDelay - self.prepareSoundLength) then
			self.prepareSoundPlayed = true;
			if self.prepareSound then
				self.prepareSound:Play(self.Pos);
			end
		end
		
		if self.prepareSound then self.prepareSound.Pos = self.Pos; end
		self.afterSound.Pos = self.Pos;
	
		if self.reloadTimer:IsPastSimMS(self.reloadDelay) then
			
			if self.reloadPhase == 0 then
			
				if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*4.5)) then
					self.reloadingVector = Vector(4, 7);
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*3.5)) then
					self.reloadingVector = Vector(2, 3);
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1)) then
					self.reloadingVector = Vector(0, 0);
				end
			
				self.rotationTarget = 45;

			elseif self.reloadPhase == 1 then
			
				if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2)) then
					self.Frame = 0 + self.extraFrameNum;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.5)) then
					self.Frame = 1 + self.extraFrameNum;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1)) then
					self.Frame = 2 + self.extraFrameNum;
				end

			elseif self.reloadPhase == 2 then
			
				self.roundLocked = true;
				self.reloadingVector = Vector(5, 7);

			elseif self.reloadPhase == 3 then
			
				self.leverCocked = true;
			
			elseif self.reloadPhase == 4 then
			
				if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*4.5)) then
					self.reloadingVector = Vector(3, -1);
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*4)) then
					self.reloadingVector = Vector(3, 0);
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*3)) then
					self.reloadingVector = Vector(3, 2);
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2)) then
					self.reloadingVector = Vector(3, 4);
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1)) then
					self.reloadingVector = Vector(5, 7);
				end			
			
				self.rotationTarget = -5;

			end
			
			if self.afterSoundPlayed ~= true then
			
				self.afterSoundPlayed = true;
				if self.afterSound then
					self.afterSound:Play(self.Pos);
				end
			end
			
			if self.reloadTimer:IsPastSimMS(self.reloadDelay + self.afterDelay) then
				self.reloadTimer:Reset();
				self.prepareSoundPlayed = false;
				self.afterSoundPlayed = false;
				if self.reloadPhase == 0 then
					if self.leverCocked and self.roundLocked then
						self.reloadPhase = 4;
					elseif self.roundLocked then
						self.reloadPhase = 3;
					else
						self.reloadPhase = 1;
					end
				elseif self.reloadPhase == 2 then
					if self.leverCocked then
						self.reloadPhase = 4;
					else
						self.reloadPhase = 3;
					end
				elseif self.reloadPhase == 4 then
					self.BaseReloadTime = 0;
					self.reloadPhase = 0;
					self.reloadingVector = nil;
					self.spentRound = false;
					self.Reloadable = false;
				else
					self.reloadPhase = self.reloadPhase + 1;
				end
			end
		end
	else
		self.reloadingVector = nil;
		self.rotationTarget = 0
		
		self.reloadTimer:Reset();
		self.prepareSoundPlayed = false;
		self.afterSoundPlayed = false;
		self.reloadPhase = 0;
		if self.roundLocked then
			self.Frame = 0 + self.extraFrameNum;
		else
			self.Frame = 3 + self.extraFrameNum;
		end
		self.BaseReloadTime = 9999;
	end
	
	local fire = self.shoveTimer:IsPastSimMS(self.shoveCooldown) and self:IsActivated() and self.RoundInMagCount > 0;

	if self.parent and self.delayedFirstShot == true then
		if self.RoundInMagCount > 0 then
			self:Deactivate()
		end
		
		if fire and not self:IsReloading() then
			if not self.Magazine or self.Magazine.RoundCount < 1 then
				--self:Reload()
				self:Activate()
			elseif not self.activated and not self.delayedFire and self.fireDelayTimer:IsPastSimMS(1 / (self.RateOfFire / 60) * 1000) then
				self.activated = true
				
				self.preSound:Play(self.Pos);
				
				self.fireDelayTimer:Reset()
				
				self.delayedFire = true
				self.delayedFireTimer:Reset()
			end
		else
			if self.activated then
				self.activated = false
			end
		end
	elseif fire == false then
		self.delayedFirstShot = true;
	end
	self.SharpLength = (self.originalSharpLength*0.5) + ((self.originalSharpLength*0.5) * math.sin((1 + math.pow(math.min(self.FireTimer.ElapsedSimTimeMS / 1500, 1), 2.0) * 0.5) * math.pi) * -1)
	
	local recoilFactor = math.pow(math.min(self.FireTimer.ElapsedSimTimeMS / (300 * 4), 1), 2.0)
	self.rotationTarget = self.rotationTarget + math.sin(recoilFactor * math.pi) * 13
	
	if self.RoundInMagCount == 0 and self.FireTimer:IsPastSimMS(500) then
		if self.Reloadable == false then
			self.Reloadable = true;
		end
	end
	
	
	if self.FiredFrame then	
	
		self.Reloadable = false;
		self.FireTimer:Reset();
	
		self:RemoveNumberValue("Switched")

		local searchPos = self.Pos + Vector(self.searchRange * 0.75 * self.FlipFactor, 0):RadRotate(self.RotAngle);
		local targets = {};
		local targetMax = math.random(1, 2);
		for actor in MovableMan.Actors do
			if #targets < targetMax and actor.Team ~= self.Team then

				if (SceneMan:ShortestDistance(searchPos, actor.Pos, SceneMan.SceneWrapsX).Magnitude - actor.Radius) < self.searchRange
				and SceneMan:CastObstacleRay(self.MuzzlePos, SceneMan:ShortestDistance(self.MuzzlePos, actor.Pos, SceneMan.SceneWrapsX), Vector(), Vector(), actor.ID, actor.Team, rte.airID, 10) < 0 then
				
					table.insert(targets, actor);
					actor:SetNumberValue("Spotted Rocket", 1);
				end
			end
		end
	
		self.canSmoke = true
		
		self.horizontalAnim = self.horizontalAnim + 0.2
		self.angVel = self.angVel - RangeRand(0,1) * 6
		
		self.Frame = 3 + self.extraFrameNum;
		self.spentRound = true;
		self.roundLocked = false;
		self.leverCocked = false;
		
		local shakenessParticle = CreateMOPixel("Shakeness Particle Glow Massive", "Massive.rte");
		shakenessParticle.Pos = self.MuzzlePos;
		shakenessParticle.Mass = 60;
		shakenessParticle.Lifetime = 1000;
		MovableMan:AddParticle(shakenessParticle);
		
		-- Back Blast
		local effectNames = {"Small Smoke Ball 1", "Tiny Smoke Ball 1", "Blast Ball Small 1", "Tracer Smoke Ball 1"}
		for i = 1, 23 do
		
			local effect = CreateMOSParticle(effectNames[math.random(1, #effectNames)])
			effect.Pos = self.Pos + Vector(-13 * self.FlipFactor, -1):RadRotate(self.RotAngle) + Vector(RangeRand(-1,1), RangeRand(-1,1));
			effect.Vel = self.Vel + Vector(-30 * self.FlipFactor,0):RadRotate(self.RotAngle + RangeRand(-1,1) * 0.15 * math.random(1,3)) * RangeRand(0.1,1.5) * math.random(1,3)
			effect.Lifetime = effect.Lifetime * RangeRand(1.0,3.0)
			effect.AirResistance = effect.AirResistance * RangeRand(0.5,0.8)
			MovableMan:AddParticle(effect)
		end
		
		-- Ground Smoke
		local maxi = 70
		for i = 1, maxi do
			
			local effect = CreateMOSRotating("Ground Smoke Particle Small Massive", "Massive.rte")
			effect.Pos = self.Pos + Vector(RangeRand(-1,1), RangeRand(-1,1)) * 3
			effect.Vel = self.Vel + Vector(math.random(90,150),0):RadRotate(math.pi * 2 / maxi * i + RangeRand(-2,2) / maxi)
			effect.Lifetime = effect.Lifetime * RangeRand(0.5,2.0)
			effect.AirResistance = effect.AirResistance * RangeRand(0.5,0.8)
			MovableMan:AddParticle(effect)
		end

		local outdoorRays = 0;
		
		local indoorRays = 0;
		
		local bigIndoorRays = 0;

		if self.parent:IsPlayerControlled() then
			self.rayThreshold = 2; -- this is the first ray check to decide whether we play outdoors
			local Vector2 = Vector(0,-700); -- straight up
			local Vector2Left = Vector(0,-700):RadRotate(45*(math.pi/180));
			local Vector2Right = Vector(0,-700):RadRotate(-45*(math.pi/180));			
			local Vector2SlightLeft = Vector(0,-700):RadRotate(22.5*(math.pi/180));
			local Vector2SlightRight = Vector(0,-700):RadRotate(-22.5*(math.pi/180));		
			local Vector3 = Vector(0,0); -- dont need this but is needed as an arg
			local Vector4 = Vector(0,0); -- dont need this but is needed as an arg

			self.ray = SceneMan:CastObstacleRay(self.Pos, Vector2, Vector3, Vector4, self.RootID, self.Team, 128, 7);
			self.rayRight = SceneMan:CastObstacleRay(self.Pos, Vector2Right, Vector3, Vector4, self.RootID, self.Team, 128, 7);
			self.rayLeft = SceneMan:CastObstacleRay(self.Pos, Vector2Left, Vector3, Vector4, self.RootID, self.Team, 128, 7);			
			self.raySlightRight = SceneMan:CastObstacleRay(self.Pos, Vector2SlightRight, Vector3, Vector4, self.RootID, self.Team, 128, 7);
			self.raySlightLeft = SceneMan:CastObstacleRay(self.Pos, Vector2SlightLeft, Vector3, Vector4, self.RootID, self.Team, 128, 7);
			
			self.rayTable = {self.ray, self.rayRight, self.rayLeft, self.raySlightRight, self.raySlightLeft};
		else
			self.rayThreshold = 1; -- has to be different for AI
			local Vector2 = Vector(0,-700); -- straight up
			local Vector3 = Vector(0,0); -- dont need this but is needed as an arg
			local Vector4 = Vector(0,0); -- dont need this but is needed as an arg		
			self.ray = SceneMan:CastObstacleRay(self.Pos, Vector2, Vector3, Vector4, self.RootID, self.Team, 128, 7);
			
			self.rayTable = {self.ray};
		end
		
		for _, rayLength in ipairs(self.rayTable) do
			if rayLength < 0 then
				outdoorRays = outdoorRays + 1;
			elseif rayLength > 170 then
				bigIndoorRays = bigIndoorRays + 1;
			else
				indoorRays = indoorRays + 1;
			end
		end
		
		if outdoorRays >= self.rayThreshold then
			self.fireOutdoorsSound:Play(self.Pos);
		else -- bigIndoor
			self.fireIndoorsSound:Play(self.Pos);
		end

	end
	
	if self.delayedFire and self.delayedFireTimer:IsPastSimMS(self.delayedFireTimeMS) then
		self:Activate()	
		self.delayedFire = false
		self.delayedFirstShot = false;
	end

	-- Animation
	if self.parent then
	
		if self.shoveStart then
			self.horizontalAnim = 4;
			self.rotationTarget = self.rotationTarget - 10;
			if self.shoveTimer:IsPastSimMS(self.shoveCooldown / 2) then
				self.shoveStart = false;
				self.parent:SetNumberValue("Gun Shove Massive", 1);
			end
		elseif self.shoving then
			self.horizontalAnim = -15;
			self.rotationTarget = self.rotationTarget + self.shoveRot;
			if self.shoveTimer:IsPastSimMS(self.shoveCooldown / 1.3) then
				self.shoving = false;
			end
			
			local rayVec = Vector(self.MuzzleOffset.X * self.FlipFactor + 12 * self.FlipFactor, 0):RadRotate(self.RotAngle);
			local rayOrigin = self.Pos + Vector(0, 0);
			
			--PrimitiveMan:DrawLinePrimitive(rayOrigin, rayOrigin + rayVec,  5);
			--PrimitiveMan:DrawCirclePrimitive(self.Pos, 3, 5);
			
			local moCheck = SceneMan:CastMORay(rayOrigin, rayVec, self.IDToIgnore or self.ID, self.Team, 0, false, 2); -- Raycast		
			
			if moCheck and moCheck ~= rte.NoMOID then
				local rayHitPos = SceneMan:GetLastRayHitPos()
				local rayHitPos = Vector(rayHitPos.X, rayHitPos.Y);
				local MO = MovableMan:GetMOFromID(moCheck)
				
				local dist = SceneMan:ShortestDistance(self.Pos, rayHitPos, SceneMan.SceneWrapsX)
							
				if IsMOSRotating(MO) then
					--print("HIT BEGIN")
					if self.shoveDamage == true then
						self.shoveDamage = false;
						MO = ToMOSRotating(MO)
						--print("HIT THE FOLLOWING")
						--print(MO)
						--print(MO.UniqueID)
						--print(MO:GetRootParent())
						--print(MO:GetRootParent().UniqueID)
						--print("TABLE NOW CONTAINS")
						local woundName = MO:GetEntryWoundPresetName()
						local woundNameExit = MO:GetExitWoundPresetName()
						local woundOffset = (rayHitPos - MO.Pos):RadRotate(MO.RotAngle * -1.0)
						
						local material = MO.Material.PresetName
						--if crit then
						--	woundName = woundNameExit
						--end
						
						if self.equippedByMassive then
							if IsAttachable(MO) and ToAttachable(MO):IsAttached() then
								if MO:IsDevice() and math.random(0, 100) >= 90 then
									ToAttachable(MO):RemoveFromParent(true, true);
								end
								
								if MO:IsInGroup("Shields") and math.random(0, 100) >= 95 then
									ToAttachable(MO):RemoveFromParent(true, true);
								end
							end
						end
						
						local damage = self.equippedByMassive and 2 or 1;
						
						local addWounds = true;
						
						local woundsToAdd = damage;
						
						-- Hurt the actor, add extra damage
						local actorHit = MovableMan:GetMOFromID(MO.RootID)
						if (actorHit and IsActor(actorHit)) then-- and (MO.RootID == moCheck or (not IsAttachable(MO) or string.find(MO.PresetName,"Arm") or string.find(MO,"Leg") or string.find(MO,"Head"))) then -- Apply addational damage			
						
							actorHit = ToActor(actorHit)
							
							if actorHit.BodyHitSound then
								actorHit.BodyHitSound:Play(actorHit.Pos)
							end
							
							if self.equippedByMassive then
								if math.random(0, 100) >= 75 then
									actorHit.Status = 1;
								end
								actorHit.Vel = actorHit.Vel + Vector(5, 0):RadRotate(self.RotAngle);
							end
							
							if (actorHit.Health - (damage * 10)) < 0 then -- bad estimation, but...
								if math.random(0, 100) < 15 then
									self.parent:SetNumberValue("Attack Killed", 1); -- celebration!!
								end
							elseif math.random(0, 100) < 30 then
								self.parent:SetNumberValue("Attack Success", 1); -- celebration!!
							end
							
							if IsActor(MO) then -- if we hit torso
								if MO.WoundCount + woundsToAdd >= MO.GibWoundLimit and math.random(0, 100) < 95 then
									addWounds = false;
									addSingleWound = true;
									ToActor(MO).Health = 0;
								end
							end
							
							if addWounds == true and woundName and woundName ~= "" then
								for i = 1, woundsToAdd do
									MO:AddWound(CreateAEmitter(woundName), woundOffset, true)
								end
							elseif addSingleWound == true and woundName and woundName ~= "" then
								MO:AddWound(CreateAEmitter(woundName), woundOffset, true)
							end

						elseif woundName and woundName ~= "" then -- generic wound adding for non-actors
							for i = 1, woundsToAdd do
								MO:AddWound(CreateAEmitter(woundName), woundOffset, true)
							end
						end
					end
				end	
			end
			
		end
	
		if not self:IsReloading() and self.shoveTimer:IsPastSimMS(self.shoveCooldown) and self.parent:IsPlayerControlled() and UInputMan:KeyPressed(MassiveSettings.GunShoveHotkey) then
			self.shoveRot = 10 * (math.random(80, 120) / 100);
			self.shoveTimer:Reset();
			self.parent:SetNumberValue("Gun Shove Start Massive", 1);
			self.shoving = true;
			self.shoveStart = true;
			self.shoveDamage = true;
		end
	
		self.horizontalAnim = math.floor(self.horizontalAnim / (1 + TimerMan.DeltaTimeSecs * 24.0) * 1000) / 1000
		self.verticalAnim = math.floor(self.verticalAnim / (1 + TimerMan.DeltaTimeSecs * 15.0) * 1000) / 1000
		
		local stance = Vector()
		stance = stance + Vector(-1,0) * self.horizontalAnim -- Horizontal animation
		stance = stance + Vector(0,5) * self.verticalAnim -- Vertical animation
		
		self.rotationTarget = self.rotationTarget - (self.angVel * 9)
		
		self.rotation = (self.rotation + self.rotationTarget * TimerMan.DeltaTimeSecs * self.rotationSpeed) / (1 + TimerMan.DeltaTimeSecs * self.rotationSpeed)
		local total = math.rad(self.rotation) * self.FlipFactor
		
		self.RotAngle = self.RotAngle + total;
		-- self.RotAngle = self.RotAngle + total;
		-- self:SetNumberValue("MagRotation", total);
		
		local jointOffset = Vector(self.JointOffset.X * self.FlipFactor, self.JointOffset.Y):RadRotate(self.RotAngle);
		local offsetTotal = Vector(jointOffset.X, jointOffset.Y):RadRotate(-total) - jointOffset
		self.Pos = self.Pos + offsetTotal;
		-- self:SetNumberValue("MagOffsetX", offsetTotal.X);
		-- self:SetNumberValue("MagOffsetY", offsetTotal.Y);
		
		if self.reloadingVector then
			self.StanceOffset = Vector(self.originalStanceOffset.X, self.originalStanceOffset.Y) + self.reloadingVector + stance
			self.SharpStanceOffset = Vector(self.originalSharpStanceOffset.X, self.originalSharpStanceOffset.Y) + self.reloadingVector + stance
		else
			self.StanceOffset = Vector(self.originalStanceOffset.X, self.originalStanceOffset.Y) + stance
			self.SharpStanceOffset = Vector(self.originalSharpStanceOffset.X, self.originalSharpStanceOffset.Y) + stance
		end
		
	end

end

function OnDetach(self)

	self.delayedFirstShot = true;
	self:DisableScript("Massive.rte/Devices/Weapons/Handheld/MCAD/MCAD.lua");

end

function OnPieMenu(item)
	if item and IsHDFirearm(item) and item.PresetName == "MCAD" then
		item = ToHDFirearm(item);
		if item.Magazine then
			--Remove corresponding pie slices if mode is already active
			if item.Magazine.PresetName == "Magazine DUAP Massive MCAD" then
				ToGameActivity(ActivityMan:GetActivity()):RemovePieMenuSlice("DU-AP-HEAT Warhead", "MCADDUAP");
			elseif item.Magazine.PresetName == "Magazine HE Massive MCAD" then
				ToGameActivity(ActivityMan:GetActivity()):RemovePieMenuSlice("High-Explosive Warhead", "MCADHE")
			end
		end
	end
end