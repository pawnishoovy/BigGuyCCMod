function Create(self)

	if self:GetRootParent() and self:GetRootParent().PresetName == "Massive" or self:GetRootParent().PresetName == "Zedmassive" then
		self.equippedByMassive = true;
	else
		self.equippedByMassive = false;
	end
	
	self.preSound = CreateSoundContainer("Pre Flamethrower Massive", "Massive.rte");
	self.pilotSound = CreateSoundContainer("Pilot Flamethrower Massive", "Massive.rte");
	
	self.burstOutdoorsSound = CreateSoundContainer("Burst Outdoors Flamethrower Massive", "Massive.rte");
	self.burstIndoorsSound = CreateSoundContainer("Burst Indoors Flamethrower Massive", "Massive.rte");
	
	self.flowLoopSound = CreateSoundContainer("Flow Loop Flamethrower Massive", "Massive.rte");
	self.flowEndSound = CreateSoundContainer("Flow End Flamethrower Massive", "Massive.rte");
	self.flowLoopSound.Volume = 0.6; -- turn that down a tad will you
	self.flowEndSound.Volume = 0.6;
	
	self.plumeLoopSound = CreateSoundContainer("Plume Loop Flamethrower Massive", "Massive.rte");
	self.plumeEndSound = CreateSoundContainer("Plume End Flamethrower Massive", "Massive.rte");
	
	self.nozzleLoopSound = CreateSoundContainer("Nozzle Loop Flamethrower Massive", "Massive.rte");
	self.nozzleEndSound = CreateSoundContainer("Nozzle End Flamethrower Massive", "Massive.rte");
	
	self.nozzleIndoorsLoopSound = CreateSoundContainer("Nozzle Indoors Loop Flamethrower Massive", "Massive.rte");
	self.nozzleIndoorsEndSound = CreateSoundContainer("Nozzle Indoors End Flamethrower Massive", "Massive.rte");
	
	self.nozzleLoopIntenseSound = CreateSoundContainer("Nozzle Loop Intense Flamethrower Massive", "Massive.rte");
	self.nozzleEndIntenseSound = CreateSoundContainer("Nozzle End Intense Flamethrower Massive", "Massive.rte");
	
	self.tailSound = CreateSoundContainer("Tail Flamethrower Massive", "Massive.rte");
	self.overheatSound = CreateSoundContainer("Overheat Flamethrower Massive", "Massive.rte");
	
	self.reloadPrepareSounds = {}
	self.reloadPrepareSounds.canisterIn = CreateSoundContainer("Canister In Prepare Flamethrower Massive", "Massive.rte");
	self.reloadPrepareSounds.chamberClose = CreateSoundContainer("Chamber Close Prepare Flamethrower Massive", "Massive.rte");
	
	self.reloadPrepareLengths = {}
	self.reloadPrepareLengths.canisterIn = 1925
	self.reloadPrepareLengths.chamberClose = 870
	
	self.reloadPrepareDelay = {}
	self.reloadPrepareDelay.chamberOpen = 100
	self.reloadPrepareDelay.canisterOut = 450
	self.reloadPrepareDelay.canisterIn = 1925
	self.reloadPrepareDelay.chamberClose = 950
	
	self.reloadAfterSounds = {}
	self.reloadAfterSounds.chamberOpen = CreateSoundContainer("Chamber Open Flamethrower Massive", "Massive.rte");
	self.reloadAfterSounds.canisterOut = CreateSoundContainer("Canister Out Flamethrower Massive", "Massive.rte");
	self.reloadAfterSounds.canisterIn = CreateSoundContainer("Canister In Flamethrower Massive", "Massive.rte");
	self.reloadAfterSounds.chamberClose = CreateSoundContainer("Chamber Close Flamethrower Massive", "Massive.rte");
	
	self.reloadAfterDelay = {}
	self.reloadAfterDelay.chamberOpen = 500
	self.reloadAfterDelay.canisterOut = 350
	self.reloadAfterDelay.canisterIn = 750
	self.reloadAfterDelay.chamberClose = 500
	
	self.reloadTimer = Timer();
	
	self.reloadPhase = 0;
	
	self.ReloadTime = 8000;

	self.parentSet = false;
	
	self.environmentCheckTimer = Timer();
	self.environmentCheckDelay = 350;
	
	self.rotation = 0
	self.rotationTarget = 0
	self.rotationSpeed = 9
	
	self.horizontalAnim = 0
	self.verticalAnim = 0
	
	self.angVel = 0
	self.lastRotAngle = (self.RotAngle + self.InheritedRotAngleOffset)
	
	self.originalSharpLength = self.SharpLength
	
	self.originalJointOffset = Vector(self.JointOffset.X, self.JointOffset.Y)
	self.originalStanceOffset = Vector(math.abs(self.StanceOffset.X), self.StanceOffset.Y)
	self.originalSharpStanceOffset = Vector(self.SharpStanceOffset.X, self.SharpStanceOffset.Y)
	
	self.fireDuration = 60000/self.RateOfFire
	self.FireTimer = Timer();
	self.powNum = 0.1;
	
	self.lastAge = self.Age + 0
	
	self.fireDelayTimer = Timer()
	
	self.activated = false
	
	self.shoveTimer = Timer();
	self.shoveCooldown = 800;
	
	self.satisfyingVolume = 0;
	self.delayedFire = false
	self.delayedFireTimer = Timer();
	self.delayedFireTimeMS = 400
	self.delayedFireEnabled = true	
	
	self.GFXTimer = Timer();
	self.GFXDelay = 50;
	self.GFXDelayMin = 50;
	self.GFXDelayMax = 150;
	self.heatNum = 0;

end

function Update(self)

	self.rotationTarget = 0 -- ZERO IT FIRST AAAA!!!!!
	
	self.preSound.Pos = self.Pos;
	self.pilotSound.Pos = self.Pos;
	self.burstOutdoorsSound.Pos = self.Pos;
	self.burstIndoorsSound.Pos = self.Pos;
	self.flowLoopSound.Pos = self.Pos;
	self.flowEndSound.Pos = self.Pos;
	self.plumeLoopSound.Pos = self.Pos;
	self.plumeEndSound.Pos = self.Pos;
	self.nozzleLoopSound.Pos = self.Pos;
	self.nozzleEndSound.Pos = self.Pos;
	self.nozzleLoopIntenseSound.Pos = self.Pos;
	self.nozzleEndIntenseSound.Pos = self.Pos;
	self.nozzleIndoorsLoopSound.Pos = self.Pos;
	self.nozzleIndoorsEndSound.Pos = self.Pos;
	self.overheatSound.Pos = self.Pos;

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
    self.angVel = (result / TimerMan.DeltaTimeSecs * 0.6) * self.FlipFactor
    
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
		if self.parent and self.reloadPhase > 0 then
			self.parent:GetController():SetState(Controller.AIM_SHARP,false);
		end

		if self.reloadPhase == 0 then
			self.reloadDelay = self.reloadPrepareDelay.chamberOpen;
			self.afterDelay = self.reloadAfterDelay.chamberOpen;		
			
			self.prepareSound = nil
			self.prepareSoundLength = nil
			self.afterSound = self.reloadAfterSounds.chamberOpen;
			
			self.rotationTarget = 30
		elseif self.reloadPhase == 1 then
			self.reloadDelay = self.reloadPrepareDelay.canisterOut;
			self.afterDelay = self.reloadAfterDelay.canisterOut;		
			
			self.prepareSound = nil
			self.prepareSoundLength = nil
			self.afterSound = self.reloadAfterSounds.canisterOut;
			
			self.rotationTarget = 50;
			
		elseif self.reloadPhase == 2 then
			self.reloadDelay = self.reloadPrepareDelay.canisterIn;
			self.afterDelay = self.reloadAfterDelay.canisterIn;		
			
			self.prepareSound = self.reloadPrepareSounds.canisterIn;
			self.prepareSoundLength = self.reloadPrepareLengths.canisterIn;
			self.afterSound = self.reloadAfterSounds.canisterIn;
			
			self.rotationTarget = 30;
			
		elseif self.reloadPhase == 3 then
			self.reloadDelay = self.reloadPrepareDelay.chamberClose;
			self.afterDelay = self.reloadAfterDelay.chamberClose;		
			
			self.prepareSound = self.reloadPrepareSounds.chamberClose;
			self.prepareSoundLength = self.reloadPrepareLengths.chamberClose;
			self.afterSound = self.reloadAfterSounds.chamberClose;
			
			self.rotationTarget = 10;
			
		end
		
		if self.prepareSound and self.prepareSoundPlayed ~= true
		and self.reloadTimer:IsPastSimMS(self.reloadDelay - self.prepareSoundLength) then
			self.prepareSoundPlayed = true;
			self.prepareSound:Play(self.Pos);
		end
		
		if self.prepareSound then self.prepareSound.Pos = self.Pos; end
		self.afterSound.Pos = self.Pos;
	
		if self.reloadTimer:IsPastSimMS(self.reloadDelay) then
		
			self.phasePrepareFinished = true;
			
			if self.reloadPhase == 0 then

			elseif self.reloadPhase == 1 then

			elseif self.reloadPhase == 2 then

			elseif self.reloadPhase == 3 then

			end
			
			if self.afterSoundPlayed ~= true then
			
				if self.reloadPhase == 0 then
				
					self.phaseOnStop = 1;
			
				elseif self.reloadPhase == 1 then
				
					self.phaseOnStop = 2;
				
					self:SetNumberValue("MagRemoved", 1);
					
					local fake
					fake = CreateMOSRotating("Fake Magazine MOSRotating Mhati999", "Massive.rte");
					fake.Pos = self.Pos + Vector(-1 * self.FlipFactor, -6):RadRotate(self.RotAngle);
					fake.Vel = self.Vel + Vector(-7 * self.FlipFactor, -10):RadRotate(self.RotAngle);
					fake.RotAngle = self.RotAngle;
					fake.AngularVel = self.AngularVel + (-1*self.FlipFactor);
					fake.HFlipped = self.HFlipped;
					MovableMan:AddParticle(fake);
					
				elseif self.reloadPhase == 2 then
				
					self.verticalAnim = 1;
				
					self:RemoveNumberValue("MagRemoved");
					self.phaseOnStop = 3;
					
				elseif self.reloadPhase == 3 then
				
					self.phaseOnStop = 3;
					
				end
			
				self.afterSoundPlayed = true;
				if self.afterSound then
					self.afterSound:Play(self.Pos);
				end
			end
			if self.reloadTimer:IsPastSimMS(self.reloadDelay + self.afterDelay) then
				self.reloadTimer:Reset();
				self.prepareSoundPlayed = false;
				self.afterSoundPlayed = false;

				if self.reloadPhase == 3 then
					self.phaseOnStop = nil;
					self.ReloadTime = 0;
					self.reloadPhase = 0;
					self.reloadingVector = nil;
				else
					self.reloadPhase = self.reloadPhase + 1;
				end
			end
		else
			self.phasePrepareFinished = false;
		end
	else
		self.reloadingVector = nil;
		self.rotationTarget = 0
		
		if self.phaseOnStop then
			self.reloadPhase = self.phaseOnStop
			self.phaseOnStop = nil;
		end
		
		self.Frame = 0;
		
		self.reloadTimer:Reset();
		self.prepareSoundPlayed = false;
		self.afterSoundPlayed = false;
		self.ReloadTime = 12000;
	end
	
	if self:DoneReloading() or self:IsReloading() then
		self.fireDelayTimer:Reset()
		self.activated = false;
		self.delayedFire = false;
	end
		
	local fire = self.shoveTimer:IsPastSimMS(self.shoveCooldown) and self:IsActivated() and self.RoundInMagCount > 0;

	if self.parent and self.delayedFirstShot == true then
	
		if self.powNum > 0.1 then
			self.powNum = self.powNum - 0.2 * TimerMan.DeltaTimeSecs;
			if self.powNum < 0.1 then
				self.powNum = 0.1;
			end
		end	
	
		if self.RoundInMagCount > 0 then
			self:Deactivate()
		end
		
		--if self.parent:GetController():IsState(Controller.WEAPON_FIRE) and not self:IsReloading() then
		if fire and not self:IsReloading() then
			if not self.Magazine or self.Magazine.RoundCount < 1 then
				--self:Reload()
				self:Activate()
			elseif not self.activated and not self.delayedFire and self.fireDelayTimer:IsPastSimMS(1 / (self.RateOfFire / 60) * 1000) then
				self.activated = true
				
				if self.preSound then
					self.preSound:Play(self.Pos);
				end
				
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
		if self.shakenessParticle then
			self.shakenessParticle.ToDelete = true;
			self.shakenessParticle.Lifetime = 10;
			self.shakenessParticle = nil;
		end
		self.delayedFirstShot = true;
		if self.Firing == true then
			self.Firing = false;
			self.nozzleLoopSound:FadeOut(30);
			self.nozzleIndoorsLoopSound:FadeOut(30);
			self.nozzleLoopIntenseSound:FadeOut(30);
			self.flowLoopSound:FadeOut(30)
			self.plumeLoopSound:FadeOut(30);
			
			self.flowEndSound.Volume = self.flowLoopSound.Volume;
			self.flowEndSound:Play(self.Pos);
			
			self.plumeEndSound:Play(self.Pos);
			
			self.nozzleEndIntenseSound.Volume = self.satisfyingVolume;
			self.nozzleEndIntenseSound:Play(self.Pos);
			
			self.tailSound.Volume = math.min(1.0, self.satisfyingVolume);
			self.tailSound.Pitch = 1.0 - (0.1*(self.satisfyingVolume));
			self.tailSound:Play(self.Pos);
			
			local outdoorRays = 0;

			if self.parent and self.parent:IsPlayerControlled() then
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
				end
			end
			
			if outdoorRays >= self.rayThreshold then
				self.nozzleEndSound:Play(self.Pos);
			else
				self.nozzleIndoorsEndSound:Play(self.Pos);
			end
			if self.satisfyingVolume == 1 then
				self.overheatSound:Play(self.Pos);
			end
			
			self.satisfyingVolume = 0;
		end
	elseif fire == true then
	
		self.shakenessParticle.Pos = self.MuzzlePos;
		
		if self.satisfyingVolume < 1 then
			self.satisfyingVolume = self.satisfyingVolume + 0.125 * TimerMan.DeltaTimeSecs;
			self.nozzleLoopIntenseSound.Volume = self.satisfyingVolume;
			self.flowLoopSound.Volume = math.max(0, 0.6 *  (1 - self.satisfyingVolume));
			if self.satisfyingVolume > 1 then
				self.satisfyingVolume = 1;
				self.nozzleLoopIntenseSound.Volume = 1;
				self.flowLoopSound.Volume = 0;
			end
		end		
		
		if self.Environment == 0 and self.nozzleIndoorsLoopSound.Volume > 0 then
			self.nozzleIndoorsLoopSound.Volume = self.nozzleIndoorsLoopSound.Volume - 0.2 * TimerMan.DeltaTimeSecs;
			if self.nozzleIndoorsLoopSound.Volume < 0 then
				self.nozzleIndoorsLoopSound.Volume = 0;
			end
		elseif self.Environment == 1 and self.nozzleIndoorsLoopSound.Volume < 1 then
			self.nozzleIndoorsLoopSound.Volume = self.nozzleIndoorsLoopSound.Volume + 0.2 * TimerMan.DeltaTimeSecs;
			if self.nozzleIndoorsLoopSound.Volume > 1 then
				self.nozzleIndoorsLoopSound.Volume = 1;
			end
		end
		if self.environmentCheckTimer:IsPastSimMS(self.environmentCheckDelay) then
			self.environmentCheckTimer:Reset();
			local outdoorRays = 0;

			if self.parent and self.parent:IsPlayerControlled() then
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
				end
			end
			
			if outdoorRays >= self.rayThreshold then
				self.Environment = 0;
			else
				self.Environment = 1;
			end
		end
		self.firedOnce = true;
		
		self.powNum = self.powNum + TimerMan.DeltaTimeSecs * 0.05;
	end
	
	self.SharpLength = self.originalSharpLength * math.sin((1 + math.pow(math.min(self.FireTimer.ElapsedSimTimeMS / (16000), 1), self.powNum) * 0.5) * math.pi) * -1
	
	local recoilFactor = math.pow(math.min(self.FireTimer.ElapsedSimTimeMS / (200 * 4), 1), 1)
	self.rotationTarget = self.rotationTarget + math.sin(recoilFactor * math.pi) * (20 * self.powNum)
	
	if self.FiredFrame then
	
		self.heatNum = math.min(self.heatNum + 1, 200);
		self.GFXTimer:Reset()
		self.FireTimer:Reset();
		
		-- -- Ground Smoke
		-- local maxi = 0 + (math.floor(1 * self.satisfyingVolume))
		-- for i = 1, maxi do
			
			-- local effect = CreateMOSRotating("Ground Smoke Particle Small Massive", "Massive.rte")
			-- effect.Pos = self.MuzzlePos + Vector(RangeRand(-1,1), RangeRand(-1,1)) * 3
			-- effect.Vel = self.Vel + Vector(math.random(90,150),0):RadRotate(math.pi * 2 / maxi * i + RangeRand(-2,2) / maxi)
			-- effect.Lifetime = effect.Lifetime * RangeRand(0.5,2.0)
			-- effect.AirResistance = effect.AirResistance * RangeRand(0.5,0.8)
			-- MovableMan:AddParticle(effect)
		-- end
		
		local xSpread = 0
		
		local smokeAmount = math.floor((1 + (math.floor(5 * self.satisfyingVolume))) * MassiveSettings.GunshotSmokeMultiplier);
		local particleSpread = 10 + (math.floor(7 * self.satisfyingVolume))
		
		local smokeLingering = math.sqrt(smokeAmount / 8) * (1 + self.satisfyingVolume * 2) * 3
		local smokeVelocity = (1 + math.sqrt(smokeAmount / 8) )
		
		-- Muzzle main smoke
		if math.random(0,3) < 1 then
			for i = 1, math.ceil(smokeAmount / (math.random(2,4))) do
				local spread = math.pi * RangeRand(-1, 1) * 0.05
				local velocity = 110 * RangeRand(0.1, 0.9) * 0.4;
				
				local particle = CreateMOSParticle((math.random() * particleSpread) < 6.5 and "Flame Smoke 2" or "Smoke Ball 1");
				particle.Pos = self.MuzzlePos
				particle.Vel = self.Vel + Vector(velocity * self.FlipFactor,0):RadRotate(self.RotAngle + spread) * smokeVelocity
				particle.Lifetime = particle.Lifetime * RangeRand(0.9, 1.6) * 0.3 * smokeLingering
				particle.AirThreshold = particle.AirThreshold * 0.5
				particle.GlobalAccScalar = 0
				MovableMan:AddParticle(particle);
			end
		end
		
		-- Muzzle lingering smoke
		if math.random(0,3) < 1 then
			for i = 1, math.ceil(smokeAmount / (math.random(2,4))) do
				local spread = math.pi * RangeRand(-1, 1) * 0.05
				local velocity = 110 * RangeRand(0.1, 0.9) * 0.4;
				
				local particle = CreateMOSParticle((math.random() * particleSpread) < 10 and "Flame Smoke 2" or "Smoke Ball 1");
				particle.Pos = self.MuzzlePos
				particle.Vel = self.Vel + Vector(velocity * self.FlipFactor,0):RadRotate(self.RotAngle + spread) * smokeVelocity
				particle.Lifetime = particle.Lifetime * RangeRand(0.9, 1.6) * 0.3 * smokeLingering
				particle.AirThreshold = particle.AirThreshold * 0.5
				particle.GlobalAccScalar = 0.01
				MovableMan:AddParticle(particle);
			end
		end
		
		-- Muzzle side smoke
		if math.random(0,3) < 1 then
			for i = 1, math.ceil(smokeAmount / (math.random(4,6))) do
				local vel = Vector(110 * self.FlipFactor,0):RadRotate(self.RotAngle)
				
				local xSpreadVec = Vector(xSpread * self.FlipFactor * math.random() * -1, 0):RadRotate(self.RotAngle)
				
				local particle = CreateMOSParticle("Flame Smoke 2");
				particle.Pos = self.MuzzlePos + xSpreadVec
				-- oh LORD
				particle.Vel = self.Vel + ((Vector(vel.X, vel.Y):RadRotate(math.pi * (math.random(0,1) * 2.0 - 1.0) * 0.5 + math.pi * RangeRand(-1, 1) * 0.15) * RangeRand(0.1, 0.9) * 0.3 + Vector(vel.X, vel.Y):RadRotate(math.pi * RangeRand(-1, 1) * 0.15) * RangeRand(0.1, 0.9) * 0.2) * 0.5) * smokeVelocity;
				-- have mercy
				particle.Lifetime = particle.Lifetime * RangeRand(0.9, 1.6) * 0.3 * smokeLingering
				particle.AirThreshold = particle.AirThreshold * 0.5
				particle.GlobalAccScalar = 0
				MovableMan:AddParticle(particle);
			end
		end
		
		-- Muzzle scary smoke
		if math.random(0,3) < 1 then
			for i = 1, math.ceil(smokeAmount / (math.random(8,12))) do
				local spread = math.pi * RangeRand(-1, 1) * 0.05
				local velocity = 110 * RangeRand(0.1, 0.9) * 0.4;
				
				local particle = CreateMOSParticle("Flame Smoke 2", "Base.rte");
				particle.Pos = self.MuzzlePos
				particle.Vel = self.Vel + Vector(velocity * self.FlipFactor,0):RadRotate(self.RotAngle + spread) * smokeVelocity
				particle.Lifetime = particle.Lifetime * RangeRand(0.9, 1.6) * 0.3 * smokeLingering
				particle.AirThreshold = particle.AirThreshold * 0.5
				particle.GlobalAccScalar = 0
				particle.AirResistance = particle.AirResistance * 3.0
				MovableMan:AddParticle(particle);
			end
		end
		
		-- Muzzle flash-smoke
		if math.random(0,3) < 1 then
			for i = 1, math.ceil(smokeAmount / (math.random(5,10) * 0.5)) do
				local spread = RangeRand(-math.rad(particleSpread), math.rad(particleSpread)) * (1 + math.random(0,3) * 0.3)
				local velocity = 110 * 0.6 * RangeRand(0.9,1.1)
				
				local xSpreadVec = Vector(xSpread * self.FlipFactor * math.random() * -1, 0):RadRotate(self.RotAngle)
				
				local particle = CreateMOSParticle("Flame Smoke 1 Micro")
				particle.Pos = self.MuzzlePos + xSpreadVec
				particle.Vel = self.Vel + Vector(velocity * self.FlipFactor,0):RadRotate(self.RotAngle + spread) * smokeVelocity
				particle.Team = self.Team
				particle.Lifetime = particle.Lifetime * RangeRand(0.9,1.2) * 0.75 * smokeLingering
				particle.AirResistance = particle.AirResistance * 2.5 * RangeRand(0.9,1.1)
				particle.IgnoresTeamHits = true
				particle.AirThreshold = particle.AirThreshold * 0.5
				particle.AirResistance = particle.AirResistance * 3.0
				MovableMan:AddParticle(particle);
			end
		end
		--
		
		-- local outdoorRays = 0;

		-- if self.parent and self.parent:IsPlayerControlled() then
			-- self.rayThreshold = 2; -- this is the first ray check to decide whether we play outdoors
			-- local Vector2 = Vector(0,-700); -- straight up
			-- local Vector2Left = Vector(0,-700):RadRotate(45*(math.pi/180));
			-- local Vector2Right = Vector(0,-700):RadRotate(-45*(math.pi/180));			
			-- local Vector2SlightLeft = Vector(0,-700):RadRotate(22.5*(math.pi/180));
			-- local Vector2SlightRight = Vector(0,-700):RadRotate(-22.5*(math.pi/180));		
			-- local Vector3 = Vector(0,0); -- dont need this but is needed as an arg
			-- local Vector4 = Vector(0,0); -- dont need this but is needed as an arg

			-- self.ray = SceneMan:CastObstacleRay(self.Pos, Vector2, Vector3, Vector4, self.RootID, self.Team, 128, 7);
			-- self.rayRight = SceneMan:CastObstacleRay(self.Pos, Vector2Right, Vector3, Vector4, self.RootID, self.Team, 128, 7);
			-- self.rayLeft = SceneMan:CastObstacleRay(self.Pos, Vector2Left, Vector3, Vector4, self.RootID, self.Team, 128, 7);			
			-- self.raySlightRight = SceneMan:CastObstacleRay(self.Pos, Vector2SlightRight, Vector3, Vector4, self.RootID, self.Team, 128, 7);
			-- self.raySlightLeft = SceneMan:CastObstacleRay(self.Pos, Vector2SlightLeft, Vector3, Vector4, self.RootID, self.Team, 128, 7);
			
			-- self.rayTable = {self.ray, self.rayRight, self.rayLeft, self.raySlightRight, self.raySlightLeft};
		-- else
			-- self.rayThreshold = 1; -- has to be different for AI
			-- local Vector2 = Vector(0,-700); -- straight up
			-- local Vector3 = Vector(0,0); -- dont need this but is needed as an arg
			-- local Vector4 = Vector(0,0); -- dont need this but is needed as an arg		
			-- self.ray = SceneMan:CastObstacleRay(self.Pos, Vector2, Vector3, Vector4, self.RootID, self.Team, 128, 7);
			
			-- self.rayTable = {self.ray};
		-- end
		
		-- for _, rayLength in ipairs(self.rayTable) do
			-- if rayLength < 0 then
				-- outdoorRays = outdoorRays + 1;
			-- end
		-- end
		
		-- if outdoorRays >= self.rayThreshold then
			-- -- local sound = self.noiseOutdoorsSound;
			-- -- sound:Play(self.Pos);
			-- -- self.oldNoise = sound;
			
			-- -- self.satisfyingReflectionOutdoorsSound.Volume = self.satisfyingVolume;
			-- -- self.satisfyingReflectionOutdoorsSound:Play(self.Pos);
		-- else
			-- -- local sound = self.noiseIndoorsSound;
			-- -- sound:Play(self.Pos);
			-- -- self.oldNoise = sound;
			
			-- -- self.reflectionIndoorsSound:Play(self.Pos);
		-- end	

	end
	
	if self.delayedFire and self.delayedFireTimer:IsPastSimMS(self.delayedFireTimeMS) then
		self:Activate()
		self.Firing = true;
		self.firedOnce = false;
		
		self.pilotSound:Play(self.Pos);
			
		self.flowLoopSound.Volume = 0.6;
		self.flowLoopSound:Play(self.Pos);
		self.plumeLoopSound.Volume = 1;
		self.plumeLoopSound:Play(self.Pos);
		
		self.nozzleLoopIntenseSound:Play(self.Pos);
		
		local outdoorRays = 0;

		if self.parent and self.parent:IsPlayerControlled() then
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
			end
		end
		
		if outdoorRays >= self.rayThreshold then
			self.Environment = 0;
			self.nozzleLoopSound.Volume = 1;
			self.nozzleIndoorsLoopSound.Volume = 0;
			self.burstOutdoorsSound:Play(self.Pos);
		else
			self.Environment = 1;
			self.nozzleLoopSound.Volume = 0;
			self.nozzleIndoorsLoopSound.Volume = 1;
			self.burstIndoorsSound:Play(self.Pos);
		end
		
		self.nozzleLoopSound:Play(self.Pos);
		self.nozzleIndoorsLoopSound:Play(self.Pos);
		
		local shakenessParticle = CreateMOPixel("Shakeness Particle Flamethrower Massive", "Massive.rte");
		shakenessParticle.Pos = self.MuzzlePos;
		self.shakenessParticle = shakenessParticle;
		MovableMan:AddParticle(shakenessParticle);
		
		self.delayedFire = false
		self.delayedFirstShot = false;
	end

	-- Animation
	if self.parent then
	
		if self.shoveStart then
			self.horizontalAnim = 3;
			self.rotationTarget = self.rotationTarget + 65;
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
			
			local rayVec = Vector(15 * self.FlipFactor, 0):RadRotate(self.RotAngle);
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
	
		if self.shoveTimer:IsPastSimMS(self.shoveCooldown) and self.parent:IsPlayerControlled() and UInputMan:KeyPressed(MassiveSettings.GunShoveHotkey) then
			self.shoveRot = 80 * (math.random(90, 110) / 100);
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
		local total = math.rad(self.rotation)
		
		self.InheritedRotAngleOffset = total;
		-- self.RotAngle = self.RotAngle + total;
		self:SetNumberValue("MagRotation", total);
		
		-- local jointOffset = Vector(self.JointOffset.X * self.FlipFactor, self.JointOffset.Y):RadRotate(self.RotAngle);
		-- local offsetTotal = Vector(jointOffset.X, jointOffset.Y):RadRotate(-total) - jointOffset
		-- self.Pos = self.Pos + offsetTotal;
		if self.fakeMag and not self:NumberValueExists("LostFakeMag") then
			self.fakeMag.RotAngle = self.RotAngle;
			self.fakeMag.Pos = self.fakeMag.Pos + offsetTotal;
		end
		
		if self.reloadingVector then
			self.StanceOffset = self.reloadingVector + stance
			self.SharpStanceOffset = self.reloadingVector + stance
		else
			self.StanceOffset = Vector(self.originalStanceOffset.X, self.originalStanceOffset.Y) + stance
			self.SharpStanceOffset = Vector(self.originalSharpStanceOffset.X, self.originalSharpStanceOffset.Y) + stance
		end
		
	end
	
	if self.GFXTimer:IsPastSimMS(self.GFXDelay) then
		if self.heatNum > 2 then
			local particles = {"Tiny Smoke Ball 1"}
			
			if self.heatNum > 100 then
				table.insert(particles, "Small Smoke Ball 1")
			end
			
			for i = 1, math.random(1,3) do
				local particle = CreateMOSParticle(particles[math.random(1,#particles)]);
				particle.Lifetime = math.random(250, 600);
				particle.Vel = self.Vel + Vector(0, -0.1);
				particle.Pos = self.MuzzlePos;
				MovableMan:AddParticle(particle);
			end
			
			self.heatNum = math.max(self.heatNum - 2, 0)
		end
		
		self.GFXTimer:Reset()
		self.GFXDelay = math.max(50, math.random(self.GFXDelayMin, self.GFXDelayMax) - self.heatNum) 
	end
	
	self.Frame = math.floor(7 * math.pow(math.min(self.heatNum / 100, 1), 2) + 0.5) 
end

function OnDetach(self)

	if self.shakenessParticle then
		self.shakenessParticle.ToDelete = true;
		self.shakenessParticle.Lifetime = 10;
		self.shakenessParticle = nil;
	end
	self.delayedFirstShot = true;
	if self.Firing == true then
		self.Firing = false;
		self.nozzleLoopSound:FadeOut(30);
		self.nozzleIndoorsLoopSound:FadeOut(30);
		self.nozzleLoopIntenseSound:FadeOut(30);
		self.flowLoopSound:FadeOut(30)
		self.plumeLoopSound:FadeOut(30);
		
		self.flowEndSound.Volume = self.flowLoopSound.Volume;
		self.flowEndSound:Play(self.Pos);
		
		self.plumeEndSound:Play(self.Pos);
		
		self.nozzleEndIntenseSound.Volume = self.satisfyingVolume;
		self.nozzleEndIntenseSound:Play(self.Pos);
		
		self.tailSound.Volume = math.min(1.0, self.satisfyingVolume);
		self.tailSound.Pitch = 1.0 - (0.1*(self.satisfyingVolume));
		self.tailSound:Play(self.Pos);
		
		local outdoorRays = 0;

		if self.parent and self.parent:IsPlayerControlled() then
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
			end
		end
		
		if outdoorRays >= self.rayThreshold then
			self.nozzleEndSound:Play(self.Pos);
		else
			self.nozzleIndoorsEndSound:Play(self.Pos);
		end
		if self.satisfyingVolume == 1 then
			self.overheatSound:Play(self.Pos);
		end
		
		self.satisfyingVolume = 0;
	end

	self.heatNum = 0;

	self.shoveStart = false;
	self.shoving = false;

	self.delayedFirstShot = true;
	self:DisableScript("Massive.rte/Devices/Weapons/Handheld/Flamethrower/Flamethrower.lua");

end

function OnDestroy(self)

	if ValidMO(self.shakenessParticle) then
		self.shakenessParticle.ToDelete = true;
		self.shakenessParticle.Lifetime = 10;
		self.shakenessParticle = nil;
	end
	self.delayedFirstShot = true;
	if self.Firing == true then
		self.Firing = false;
		self.nozzleLoopSound:FadeOut(30);
		self.nozzleIndoorsLoopSound:FadeOut(30);
		self.nozzleLoopIntenseSound:FadeOut(30);
		self.flowLoopSound:FadeOut(30)
		self.plumeLoopSound:FadeOut(30);
		
		self.flowEndSound.Volume = self.flowLoopSound.Volume;
		self.flowEndSound:Play(self.Pos);
		
		self.plumeEndSound:Play(self.Pos);
		
		self.nozzleEndIntenseSound.Volume = self.satisfyingVolume;
		self.nozzleEndIntenseSound:Play(self.Pos);
		
		self.tailSound.Volume = math.min(1.0, self.satisfyingVolume);
		self.tailSound.Pitch = 1.0 - (0.1*(self.satisfyingVolume));
		self.tailSound:Play(self.Pos);
		
		local outdoorRays = 0;

		if self.parent and self.parent:IsPlayerControlled() then
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
			end
		end
		
		if outdoorRays >= self.rayThreshold then
			self.nozzleEndSound:Play(self.Pos);
		else
			self.nozzleIndoorsEndSound:Play(self.Pos);
		end
		if self.satisfyingVolume == 1 then
			self.overheatSound:Play(self.Pos);
		end
		
		self.satisfyingVolume = 0;
	end
		
		
end