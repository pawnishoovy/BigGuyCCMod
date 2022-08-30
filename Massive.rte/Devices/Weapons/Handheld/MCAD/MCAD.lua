function Create(self)

	self.parentSet = false;

	-- Sounds --
	
	self.preSound = CreateSoundContainer("Pre RPG", "SandstormInsurgency.rte");
	
	self.addSounds = {["Start"] = nil, ["Loop"] = nil};
	self.addSounds.Loop = CreateSoundContainer("Add RPG", "SandstormInsurgency.rte");
	
	self.bassSounds = {["Start"] = nil, ["Loop"] = nil};
	self.bassSounds.Loop = CreateSoundContainer("Bass RPG", "SandstormInsurgency.rte");
	
	self.noiseSounds = {["Outdoors"] = {["Loop"] = nil, ["End"] = nil},
	["Indoors"] = {["Loop"] = nil, ["End"] = nil},
	["bigIndoors"] = {["Loop"] = nil, ["End"] = nil}};
	self.noiseSounds.Outdoors.End = CreateSoundContainer("NoiseOutdoorsEnd RPG", "SandstormInsurgency.rte");
	self.noiseSounds.Outdoors.End.Pitch = 1.0;
	self.noiseSounds.Indoors.End = CreateSoundContainer("NoiseIndoorsEnd RPG", "SandstormInsurgency.rte");
	self.noiseSounds.Indoors.End.Pitch = 1.0;
	self.noiseSounds.bigIndoors.End = CreateSoundContainer("NoiseBigIndoorsEnd RPG", "SandstormInsurgency.rte");
	self.noiseSounds.bigIndoors.End.Pitch = 1.0;
	
	self.reflectionSounds = {["Outdoors"] = nil};
	self.reflectionSounds.Outdoors = CreateSoundContainer("Noise ReflectionOutdoors", "Sandstorm.rte");
	self.reflectionSounds.Outdoors.Pitch = 0.6;
	self.reflectionSounds.Outdoors.Volume = 1.1;
	
	self.reloadPrepareSounds = {}
	self.reloadPrepareSounds.Raise = CreateSoundContainer("RaisePrepare RPG", "SandstormInsurgency.rte");
	self.reloadPrepareSounds.Shoulder = CreateSoundContainer("ShoulderPrepare RPG", "SandstormInsurgency.rte");
	
	self.reloadPrepareLengths = {}
	self.reloadPrepareLengths.Raise = 750;
	self.reloadPrepareLengths.Shoulder = 900;
	
	self.reloadAfterSounds = {}
	self.reloadAfterSounds.Raise = CreateSoundContainer("Raise RPG", "SandstormInsurgency.rte");
	self.reloadAfterSounds.InsertRound = CreateSoundContainer("InsertRound RPG", "SandstormInsurgency.rte");
	self.reloadAfterSounds.LockRound = CreateSoundContainer("LockRound RPG", "SandstormInsurgency.rte");
	self.reloadAfterSounds.CockLever = CreateSoundContainer("CockLever RPG", "SandstormInsurgency.rte");
	self.reloadAfterSounds.Shoulder = CreateSoundContainer("Shoulder RPG", "SandstormInsurgency.rte");
	
	self:SetNumberValue("DelayedFireTimeMS", 35);
	
	self.FireTimer = Timer();
	
	self.originalStanceOffset = Vector(math.abs(self.StanceOffset.X), self.StanceOffset.Y)
	self.originalSharpStanceOffset = Vector(math.abs(self.SharpStanceOffset.X), self.SharpStanceOffset.Y)
	
	self.rotation = 0
	self.rotationTarget = 0
	self.rotationSpeed = 5
	
	self.horizontalAnim = 0
	self.verticalAnim = 0
	
	self.angVel = 0
	self.lastRotAngle = self.RotAngle
	
	self.smokeTimer = Timer();
	self.smokeDelayTimer = Timer();
	self.canSmoke = false
	
	self.searchRange = 650 + FrameMan.PlayerScreenWidth * 0.3;
	
	self.reloadTimer = Timer();
	
	self.roundLocked = true;
	self.leverCocked = true;
	
	self.raisePrepareDelay = 750;
	self.raiseAfterDelay = 800;
	self.insertRoundPrepareDelay = 1050;
	self.insertRoundAfterDelay = 250;
	self.lockRoundPrepareDelay = 600;
	self.lockRoundAfterDelay = 730;
	self.cockLeverPrepareDelay = 1000;
	self.cockLeverAfterDelay = 700;
	self.shoulderPrepareDelay = 900;
	self.shoulderAfterDelay = 400;
	
	-- phases:
	-- 0 raise
	-- 1 insertround
	-- 2 lockround
	-- 3 cocklever
	-- 4 shoulder
	
	self.reloadPhase = 0;
	
	self.ReloadTime = 19999;

	local actor = MovableMan:GetMOFromID(self.RootID);
	if actor and IsAHuman(actor) then
		self.parent = ToAHuman(actor);
	end
	
end

function Update(self)

	if UInputMan:KeyPressed(15) then
	  PresetMan:ReloadAllScripts();
	  self:ReloadScripts();
	end

	self.rotationTarget = 0 -- ZERO IT FIRST AAAA!!!!!

	if self.ID == self.RootID then
		self.parent = nil;
		self.parentSet = false;
	elseif self.parentSet == false then
		local actor = MovableMan:GetMOFromID(self.RootID);
		if actor and IsAHuman(actor) then
			self.parent = ToAHuman(actor);
			self.parentSet = true;
		end
	end
	
    -- Smoothing
    local min_value = -math.pi;
    local max_value = math.pi;
    local value = self.RotAngle - self.lastRotAngle
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
    
    self.lastRotAngle = self.RotAngle
    self.angVel = (result / TimerMan.DeltaTimeSecs) * self.FlipFactor
    
    if self.lastHFlipped ~= nil then
        if self.lastHFlipped ~= self.HFlipped then
            self.lastHFlipped = self.HFlipped
            self.angVel = 0
        end
    else
        self.lastHFlipped = self.HFlipped
    end
	--PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(-20, 20), "Angular Velocity = "..self.angVel, true, 0);
	--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + Vector(15 * self.FlipFactor,0):RadRotate(self.RotAngle),  13);
	--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + Vector(15 * self.FlipFactor,0):RadRotate(self.RotAngle + (self.angVel * 0.05)),  5);
	
	if self:IsReloading() then
		if self.parent and self.reloadPhase > 0 and  self.reloadPhase < 4 then
			self.parent:GetController():SetState(Controller.AIM_SHARP,false);
		end
		
		if not self:NumberValueExists("MagRemoved") and self.parent:IsPlayerControlled() then
			local color = (self.reloadPhase < 2 and 105 or 120)
			local position = self.parent.AboveHUDPos + Vector(0, 36)
			PrimitiveMan:DrawCirclePrimitive(position + Vector(0,-3), 2, color);
			PrimitiveMan:DrawLinePrimitive(position + Vector(2,-2), position + Vector(2,4), color);
			PrimitiveMan:DrawLinePrimitive(position + Vector(-2,-2), position + Vector(-2,4), color);
			PrimitiveMan:DrawLinePrimitive(position + Vector(2,4), position + Vector(-2,4), color);
		end

		if self.reloadPhase == 0 then
			self.reloadDelay = self.raisePrepareDelay;
			self.afterDelay = self.raiseAfterDelay;			

			self.prepareSound = self.reloadPrepareSounds.Raise;
			self.prepareSoundLength = self.reloadPrepareLengths.Raise;
			self.afterSound = self.reloadAfterSounds.Raise;
			
		elseif self.reloadPhase == 1 then
			self.reloadDelay = self.insertRoundPrepareDelay;
			self.afterDelay = self.insertRoundAfterDelay;

			self.prepareSound = nil
			self.prepareSoundLength = 0
			self.afterSound = self.reloadAfterSounds.InsertRound;
			
			self.rotationTarget = 45;
			
		elseif self.reloadPhase == 2 then
			self.reloadDelay = self.lockRoundPrepareDelay;
			self.afterDelay = self.lockRoundAfterDelay;

			self.prepareSound = nil
			self.prepareSoundLength = 0
			self.afterSound = self.reloadAfterSounds.LockRound;
			
			self.rotationTarget = 45;
			
		elseif self.reloadPhase == 3 then
			self.reloadDelay = self.cockLeverPrepareDelay;
			self.afterDelay = self.cockLeverAfterDelay;

			self.prepareSound = nil
			self.prepareSoundLength = 0
			self.afterSound = self.reloadAfterSounds.CockLever;
			
			self.rotationTarget = 25;
			
		elseif self.reloadPhase == 4 then
			self.reloadDelay = self.shoulderPrepareDelay;
			self.afterDelay = self.shoulderAfterDelay;

			self.prepareSound = self.reloadPrepareSounds.Shoulder;
			self.prepareSoundLength = self.reloadPrepareLengths.Shoulder;
			self.afterSound = self.reloadAfterSounds.Shoulder;

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
			
				if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2)) then
					self.reloadingVector = Vector(4, 7);
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.5)) then
					self.reloadingVector = Vector(2, 3);
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1)) then
					self.reloadingVector = Vector(0, 0);
				end
			
				self.rotationTarget = 45;

			elseif self.reloadPhase == 1 then
			
				if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2)) then
					self.Frame = 0;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.5)) then
					self.Frame = 1;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1)) then
					self.Frame = 2;
				end

			elseif self.reloadPhase == 2 then
			
				self.roundLocked = true;
				self.reloadingVector = Vector(5, 7);

			elseif self.reloadPhase == 3 then
			
				self.leverCocked = true;
			
			elseif self.reloadPhase == 4 then
			
				if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*3)) then
					self.reloadingVector = Vector(3, -1);
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2.5)) then
					self.reloadingVector = Vector(3, 0);
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2)) then
					self.reloadingVector = Vector(3, 2);
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.5)) then
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
					if self.leverCocked then
						self.reloadPhase = 4;
					elseif self.roundLocked then
						self.reloadPhase = 3;
					else
						self.reloadPhase = 1;
					end
				elseif self.reloadPhase == 4 then
					self.ReloadTime = 0;
					self.reloadPhase = 0;
					self.reloadingVector = nil;
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
			self.Frame = 0;
		else
			self.Frame = 3;
		end
		self.ReloadTime = 9999;
	end
	
	if self.FiredFrame then	

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
		self.smokeTimer:Reset()
		
		self.horizontalAnim = self.horizontalAnim + 0.2
		self.angVel = self.angVel - RangeRand(0,1) * 6
		
		self.Frame = 3;
		self.roundLocked = false;
		self.leverCocked = false;
		
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
			
			local effect = CreateMOSRotating("Ground Smoke Particle 1", "Sandstorm.rte")
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
		
		self.bassSounds.Loop:Play(self.Pos);
		
		if outdoorRays >= self.rayThreshold then
			self.noiseSounds.Outdoors.End:Play(self.Pos);
			self.reflectionSounds.Outdoors:Play(self.Pos);
		elseif math.max(outdoorRays, bigIndoorRays, indoorRays) == indoorRays then
			self.noiseSounds.Indoors.End:Play(self.Pos);
		else -- bigIndoor
			self.noiseSounds.bigIndoors.End:Play(self.Pos);
		end
		
		self.addSounds.Loop:Play(self.Pos);

	end
	
	if not self:IsActivated() then
		self.firstShot = true;
	end	
	
	-- Animation
	if self.parent then
		self.horizontalAnim = math.floor(self.horizontalAnim / (1 + TimerMan.DeltaTimeSecs * 12.0) * 1000) / 1000
		self.verticalAnim = math.floor(self.verticalAnim / (1 + TimerMan.DeltaTimeSecs * 8.0) * 1000) / 1000
		
		local stance = Vector()
		stance = stance + Vector(-5,0) * self.horizontalAnim -- Horizontal animation
		stance = stance + Vector(0,6) * self.verticalAnim -- Vertical animation
		
		self.rotationTarget = self.rotationTarget - (self.angVel * 4)
		self.rotation = (self.rotation + self.rotationTarget * TimerMan.DeltaTimeSecs * self.rotationSpeed) / (1 + TimerMan.DeltaTimeSecs * self.rotationSpeed)
		local total = math.rad(self.rotation) * self.FlipFactor
		
		self.RotAngle = self.RotAngle + total;
		self:SetNumberValue("MagRotation", total);
		
		local jointOffset = Vector(self.JointOffset.X * self.FlipFactor, self.JointOffset.Y):RadRotate(self.RotAngle);
		local offsetTotal = Vector(jointOffset.X, jointOffset.Y):RadRotate(-total) - jointOffset
		self.Pos = self.Pos + offsetTotal;
		self:SetNumberValue("MagOffsetX", offsetTotal.X);
		self:SetNumberValue("MagOffsetY", offsetTotal.Y);
		
		if self.reloadingVector then
			self.StanceOffset = self.reloadingVector + stance
			self.SharpStanceOffset = self.reloadingVector + stance
		else
			self.StanceOffset = Vector(self.originalStanceOffset.X, self.originalStanceOffset.Y) + stance
			self.SharpStanceOffset = Vector(self.originalSharpStanceOffset.X, self.originalSharpStanceOffset.Y) + stance
		end
	end
	
	if self.canSmoke and not self.smokeTimer:IsPastSimMS(3000) then
		--[[
		local poof = CreateMOPixel("Real Bullet Micro Smoke Ball "..math.random(1,4), "Sandstorm.rte");
		poof.Pos = self.Pos + Vector(self.MuzzleOffset.X * self.FlipFactor, self.MuzzleOffset.Y):RadRotate(self.RotAngle) + Vector(RangeRand(-1,1), RangeRand(-1,1));
		poof.Lifetime = poof.Lifetime * RangeRand(0.2, 1.3) * 0.9;
		poof.Vel = self.Vel * 0.1
		poof.GlobalAccScalar = RangeRand(0.9, 1.0) * -0.4; -- Go up and down
		MovableMan:AddParticle(poof);
		]]
		if self.smokeDelayTimer:IsPastSimMS(80) then
			
			local poof = math.random(1,2) < 2 and CreateMOSParticle("Tiny Smoke Ball 1") or CreateMOPixel("Real Bullet Micro Smoke Ball "..math.random(1,4), "Sandstorm.rte");
			poof.Pos = self.Pos + Vector(self.MuzzleOffset.X * self.FlipFactor, self.MuzzleOffset.Y):RadRotate(self.RotAngle);
			poof.Lifetime = poof.Lifetime * RangeRand(0.3, 1.3) * 0.9;
			poof.Vel = self.Vel * 0.1
			poof.GlobalAccScalar = RangeRand(0.9, 1.0) * -0.4; -- Go up and down
			MovableMan:AddParticle(poof);
			self.smokeDelayTimer:Reset()
			
			--[[
			for i = 0, 2 do
				local poof = i == 0 and CreateMOSParticle("Tiny Smoke Ball 1") or CreateMOPixel("Real Bullet Micro Smoke Ball "..math.random(1,4), "Sandstorm.rte");
				poof.Pos = self.Pos + Vector(self.MuzzleOffset.X * self.FlipFactor, self.MuzzleOffset.Y):RadRotate(self.RotAngle) + Vector(RangeRand(-1,1), RangeRand(-1,1));
				poof.Lifetime = poof.Lifetime * RangeRand(0.7, 1.7) * 0.9;
				--poof.Vel = Vector(RangeRand(-1,1), RangeRand(-1,1)) * 0.5
				poof.GlobalAccScalar = RangeRand(0.9, 1.0) * -0.4; -- Go up and down
				MovableMan:AddParticle(poof);
				self.smokeDelayTimer:Reset()
			end]]
		end
	end
end