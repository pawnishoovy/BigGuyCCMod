function Create(self)

	if self:GetRootParent() and self:GetRootParent().PresetName == "Massive" or self:GetRootParent().PresetName == "Zedmassive" then
		self.equippedByMassive = true;
	else
		self.equippedByMassive = false;
	end

	self.preSound = CreateSoundContainer("Pre Maxav", "Massive.rte");
	
	self.satisfyingAddSound = CreateSoundContainer("Satisfying Add Maxav", "Massive.rte");
	self.satisfyingReflectionSound = CreateSoundContainer("Satisfying Reflection Maxav", "Massive.rte");
	
	self.mechFinalSound = CreateSoundContainer("Mech Final Maxav", "Massive.rte");
	
	self.noiseOutdoorsSound = CreateSoundContainer("Noise Outdoors Maxav", "Massive.rte");
	self.noiseIndoorsSound = CreateSoundContainer("Noise Indoors Maxav", "Massive.rte");
	
	self.oldNoise = self.noiseOutdoorsSound;
	
	self.reloadPrepareSounds = {}
	self.reloadPrepareSounds.Raise = CreateSoundContainer("Raise Prepare Maxav", "Massive.rte");
	self.reloadPrepareSounds.coverOpen = CreateSoundContainer("Cover Open Prepare Maxav", "Massive.rte");
	self.reloadPrepareSounds.drumOut = CreateSoundContainer("Drum Out Prepare Maxav", "Massive.rte");
	self.reloadPrepareSounds.drumIn = CreateSoundContainer("Drum In Prepare Maxav", "Massive.rte");
	self.reloadPrepareSounds.beltIn = CreateSoundContainer("Belt In Prepare Maxav", "Massive.rte");
	self.reloadPrepareSounds.coverClose = CreateSoundContainer("Cover Close Prepare Maxav", "Massive.rte");
	self.reloadPrepareSounds.Lower = CreateSoundContainer("Lower Prepare Maxav", "Massive.rte");
	
	self.reloadPrepareLengths = {}
	self.reloadPrepareLengths.Raise = 580
	self.reloadPrepareLengths.coverOpen = 600
	self.reloadPrepareLengths.drumOut = 480
	self.reloadPrepareLengths.drumIn = 1700
	self.reloadPrepareLengths.beltIn = 760
	self.reloadPrepareLengths.coverClose = 720
	self.reloadPrepareLengths.Lower = 715
	
	self.reloadPrepareDelay = {}
	self.reloadPrepareDelay.Raise = 845
	self.reloadPrepareDelay.coverOpen = 500
	self.reloadPrepareDelay.drumOut = 520
	self.reloadPrepareDelay.drumIn = 1700
	self.reloadPrepareDelay.beltIn = 760
	self.reloadPrepareDelay.coverClose = 720
	self.reloadPrepareDelay.Lower = 970
	
	self.reloadAfterSounds = {}
	self.reloadAfterSounds.Raise = CreateSoundContainer("Raise Maxav", "Massive.rte");
	self.reloadAfterSounds.coverOpen = CreateSoundContainer("Cover Open Maxav", "Massive.rte");
	self.reloadAfterSounds.drumOut = CreateSoundContainer("Drum Out Maxav", "Massive.rte");
	self.reloadAfterSounds.drumIn = CreateSoundContainer("Drum In Maxav", "Massive.rte");
	self.reloadAfterSounds.beltIn = CreateSoundContainer("Belt In Maxav", "Massive.rte");
	self.reloadAfterSounds.coverClose = CreateSoundContainer("Cover Close Maxav", "Massive.rte");
	self.reloadAfterSounds.Lower = CreateSoundContainer("Lower Maxav", "Massive.rte");
	
	self.reloadAfterDelay = {}
	self.reloadAfterDelay.Raise = 100
	self.reloadAfterDelay.coverOpen = 300
	self.reloadAfterDelay.drumOut = 450
	self.reloadAfterDelay.drumIn = 1000
	self.reloadAfterDelay.beltIn = 1000
	self.reloadAfterDelay.coverClose = 400
	self.reloadAfterDelay.Lower = 300
	
	self.reloadTimer = Timer();
	
	self.reloadPhase = 0;
	
	self.ReloadTime = 12000;

	self.parentSet = false;
	
	self.rotation = 0
	self.rotationTarget = 0
	self.rotationSpeed = 9
	
	self.horizontalAnim = 0
	self.verticalAnim = 0
	
	self.angVel = 0
	self.lastRotAngle = (self.RotAngle + self.InheritedRotAngleOffset)
	
	self.originalSharpLength = self.SharpLength
	
	self.originalStanceOffset = Vector(math.abs(self.StanceOffset.X), self.StanceOffset.Y)
	self.originalSharpStanceOffset = Vector(self.SharpStanceOffset.X, self.SharpStanceOffset.Y)
	
	self.FireTimer = Timer();
	self.powNum = 0.1;
	
	self.delayedFire = false
	self.delayedFireTimer = Timer();
	self.delayedFireTimeMS = 50
	self.delayedFireEnabled = true
	
	self.lastAge = self.Age + 0
	
	self.fireDelayTimer = Timer()
	
	self.activated = false
	
	self.shoveTimer = Timer();
	self.shoveCooldown = 1100;

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
    self.angVel = (result / TimerMan.DeltaTimeSecs * 0.8) * self.FlipFactor
    
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
			self.reloadDelay = self.reloadPrepareDelay.Raise;
			self.afterDelay = self.reloadAfterDelay.Raise;		
			
			self.prepareSound = self.reloadPrepareSounds.Raise;
			self.prepareSoundLength = self.reloadPrepareLengths.Raise;
			self.afterSound = self.reloadAfterSounds.Raise;
			
			self.rotationTarget = 50 * (self.reloadTimer.ElapsedSimTimeMS/self.reloadDelay);
			
		elseif self.reloadPhase == 1 then
			self.reloadDelay = self.reloadPrepareDelay.coverOpen;
			self.afterDelay = self.reloadAfterDelay.coverOpen;		
			
			self.prepareSound = self.reloadPrepareSounds.coverOpen;
			self.prepareSoundLength = self.reloadPrepareLengths.coverOpen;
			self.afterSound = self.reloadAfterSounds.coverOpen;
			
			self.rotationTarget = 45;
			
		elseif self.reloadPhase == 2 then
			self.reloadDelay = self.reloadPrepareDelay.drumOut;
			self.afterDelay = self.reloadAfterDelay.drumOut;		
			
			self.prepareSound = self.reloadPrepareSounds.drumOut;
			self.prepareSoundLength = self.reloadPrepareLengths.drumOut;
			self.afterSound = self.reloadAfterSounds.drumOut;
			
			self.rotationTarget = 45;
			
		elseif self.reloadPhase == 3 then
			self.reloadDelay = self.reloadPrepareDelay.drumIn;
			self.afterDelay = self.reloadAfterDelay.drumIn;		
			
			self.prepareSound = self.reloadPrepareSounds.drumIn;
			self.prepareSoundLength = self.reloadPrepareLengths.drumIn;
			self.afterSound = self.reloadAfterSounds.drumIn;
			
			self.rotationTarget = 30;
			
		elseif self.reloadPhase == 4 then
			self.reloadDelay = self.reloadPrepareDelay.beltIn;
			self.afterDelay = self.reloadAfterDelay.beltIn;		
			
			self.prepareSound = self.reloadPrepareSounds.beltIn;
			self.prepareSoundLength = self.reloadPrepareLengths.beltIn;
			self.afterSound = self.reloadAfterSounds.beltIn;
			
			self.rotationTarget = 25;
			
		elseif self.reloadPhase == 5 then
			self.reloadDelay = self.reloadPrepareDelay.coverClose;
			self.afterDelay = self.reloadAfterDelay.coverClose;		
			
			self.prepareSound = self.reloadPrepareSounds.coverClose;
			self.prepareSoundLength = self.reloadPrepareLengths.coverClose;
			self.afterSound = self.reloadAfterSounds.coverClose;
			
			self.rotationTarget = 25;
			
		elseif self.reloadPhase == 6 then
			self.reloadDelay = self.reloadPrepareDelay.Lower;
			self.afterDelay = self.reloadAfterDelay.Lower;		
			
			self.prepareSound = self.reloadPrepareSounds.Lower;
			self.prepareSoundLength = self.reloadPrepareLengths.Lower;
			self.afterSound = self.reloadAfterSounds.Lower;

			self.rotationTarget = 20;
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
		
			self.phasePrepareFinished = true;
			
			if self.reloadPhase == 0 then
			
				self.rotationTarget = 45;

			elseif self.reloadPhase == 1 then
			
				if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*4)) then
					self.Frame = 4;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*3)) then
					self.Frame = 3;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2)) then
					self.Frame = 2;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1)) then
					self.Frame = 1;
				end

			elseif self.reloadPhase == 2 then
			
				self.Frame = 5;

			elseif self.reloadPhase == 3 then
			
				self.Frame = 4;
			
			elseif self.reloadPhase == 4 then
			
			elseif self.reloadPhase == 5 then
			
				if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*4)) then
					self.Frame = 0;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*3)) then
					self.Frame = 1;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2)) then
					self.Frame = 2;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1)) then
					self.Frame = 3;
				end
			
			elseif self.reloadPhase == 6 then
				
			
				self.rotationTarget = 5;

			end
			
			if self.afterSoundPlayed ~= true then
			
				if self.reloadPhase == 0 then
				
					self.verticalAnim = 2;
			
				elseif self.reloadPhase == 1 then
				
					self.coverOpened = true;
					
				elseif self.reloadPhase == 2 then
					
					if self.drumRemoved ~= true then
						local fake
						fake = CreateMOSRotating("Fake Magazine MOSRotating Maxav", "Massive.rte");
						fake.Pos = self.Pos + Vector(-6 * self.FlipFactor, 1):RadRotate(self.RotAngle);
						fake.Vel = self.Vel + Vector(2 * self.FlipFactor, 1):RadRotate(self.RotAngle);
						fake.RotAngle = self.RotAngle;
						fake.AngularVel = self.AngularVel + (-1*self.FlipFactor);
						fake.HFlipped = self.HFlipped;
						MovableMan:AddParticle(fake);
						self.drumRemoved = true;
					end
					self.verticalAnim = 1;
					
				elseif self.reloadPhase == 3 then
					
					self.drumInserted = true;
					self.verticalAnim = 1;
					
				elseif self.reloadPhase == 4 then
				
					self.beltInserted = true;
		
				elseif self.reloadPhase == 5 then
				
					self.coverClosed = true;
					
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
				if self.reloadPhase == 0 then
					if self.coverClosed then
						self.reloadPhase = 6;
					elseif self.beltInserted then
						self.reloadPhase = 5;					
					elseif self.drumInserted then
						self.reloadPhase = 4;
					elseif self.drumRemoved then
						self.reloadPhase = 3;
					elseif self.coverOpened then
						self.reloadPhase = 2;
					else
						self.reloadPhase = 1;
					end
				elseif self.reloadPhase == 6 then
					self.coverOpened = false;
					self.drumRemoved = false;
					self.drumInserted = false;
					self.beltInserted = false;
					self.coverClosed = false;
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
		
		self.reloadPhase = 0;
		
		self.Frame = self.coverClosed and 0 or self.drumInserted and 4 or self.drumRemoved and 5 or self.coverOpened and 4 or 0
		
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
				
				self.satisfyingVolume = 0;
				
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
	
	self.SharpLength = self.originalSharpLength * math.sin((1 + math.pow(math.min(self.FireTimer.ElapsedSimTimeMS / 900, 1), self.powNum) * 0.5) * math.pi) * -1
	
	local recoilFactor = math.pow(math.min(self.FireTimer.ElapsedSimTimeMS / (300 * 4), 1), 2.0)
	self.rotationTarget = self.rotationTarget + math.sin(recoilFactor * math.pi) * 1.7
	
	if self.FiredFrame then
	
		self.satisfyingVolume = self.satisfyingVolume + 0.082;
		
		self.satisfyingAddSound.Volume = self.satisfyingVolume;
		self.satisfyingAddSound:Play(self.Pos);
	
		if self.RoundInMagCount == 0 then
			self.mechFinalSound:Play(self.Pos);
		end
		
		self.FireTimer:Reset();
		self.powNum = 0.1 + (0.1 * self.satisfyingVolume)
		
		-- Ground Smoke
		local maxi = 7 + (math.floor(4 * self.satisfyingVolume))
		for i = 1, maxi do
			
			local effect = CreateMOSRotating("Ground Smoke Particle Large Massive", "Massive.rte")
			effect.Pos = self.MuzzlePos + Vector(RangeRand(-1,1), RangeRand(-1,1)) * 3
			effect.Vel = self.Vel + Vector(math.random(90,150),0):RadRotate(math.pi * 2 / maxi * i + RangeRand(-2,2) / maxi)
			effect.Lifetime = effect.Lifetime * RangeRand(0.5,2.0)
			effect.AirResistance = effect.AirResistance * RangeRand(0.5,0.8)
			MovableMan:AddParticle(effect)
		end
		
		local xSpread = 0
		
		local smokeAmount = 20 + (math.floor(10 * self.satisfyingVolume))
		local particleSpread = 10 + (math.floor(7 * self.satisfyingVolume))
		
		local smokeLingering = math.sqrt(smokeAmount / 8) * (1 + self.satisfyingVolume * 2)
		local smokeVelocity = (1 + math.sqrt(smokeAmount / 8) ) * 0.5
		
		-- Muzzle main smoke
		for i = 1, math.ceil(smokeAmount / (math.random(2,4))) do
			local spread = math.pi * RangeRand(-1, 1) * 0.05
			local velocity = 110 * RangeRand(0.1, 0.9) * 0.4;
			
			local particle = CreateMOSParticle((math.random() * particleSpread) < 6.5 and "Tiny Smoke Ball 1" or "Small Smoke Ball 1");
			particle.Pos = self.MuzzlePos
			particle.Vel = self.Vel + Vector(velocity * self.FlipFactor,0):RadRotate(self.RotAngle + spread) * smokeVelocity
			particle.Lifetime = particle.Lifetime * RangeRand(0.9, 1.6) * 0.3 * smokeLingering
			particle.AirThreshold = particle.AirThreshold * 0.5
			particle.GlobalAccScalar = 0
			MovableMan:AddParticle(particle);
		end
		
		-- Muzzle lingering smoke
		for i = 1, math.ceil(smokeAmount / (math.random(2,4))) do
			local spread = math.pi * RangeRand(-1, 1) * 0.05
			local velocity = 110 * RangeRand(0.1, 0.9) * 0.4;
			
			local particle = CreateMOSParticle((math.random() * particleSpread) < 10 and "Tiny Smoke Ball 1" or "Small Smoke Ball 1");
			particle.Pos = self.MuzzlePos
			particle.Vel = self.Vel + Vector(velocity * self.FlipFactor,0):RadRotate(self.RotAngle + spread) * smokeVelocity
			particle.Lifetime = particle.Lifetime * RangeRand(0.9, 1.6) * 0.3 * smokeLingering * 3
			particle.AirThreshold = particle.AirThreshold * 0.5
			particle.GlobalAccScalar = 0.01
			MovableMan:AddParticle(particle);
		end
		
		-- Muzzle side smoke
		for i = 1, math.ceil(smokeAmount / (math.random(4,6))) do
			local vel = Vector(110 * self.FlipFactor,0):RadRotate(self.RotAngle)
			
			local xSpreadVec = Vector(xSpread * self.FlipFactor * math.random() * -1, 0):RadRotate(self.RotAngle)
			
			local particle = CreateMOSParticle("Tiny Smoke Ball 1");
			particle.Pos = self.MuzzlePos + xSpreadVec
			-- oh LORD
			particle.Vel = self.Vel + ((Vector(vel.X, vel.Y):RadRotate(math.pi * (math.random(0,1) * 2.0 - 1.0) * 0.5 + math.pi * RangeRand(-1, 1) * 0.15) * RangeRand(0.1, 0.9) * 0.3 + Vector(vel.X, vel.Y):RadRotate(math.pi * RangeRand(-1, 1) * 0.15) * RangeRand(0.1, 0.9) * 0.2) * 0.5) * smokeVelocity;
			-- have mercy
			particle.Lifetime = particle.Lifetime * RangeRand(0.9, 1.6) * 0.3 * smokeLingering
			particle.AirThreshold = particle.AirThreshold * 0.5
			particle.GlobalAccScalar = 0
			MovableMan:AddParticle(particle);
		end
		
		-- Muzzle scary smoke
		for i = 1, math.ceil(smokeAmount / (math.random(8,12))) do
			local spread = math.pi * RangeRand(-1, 1) * 0.05
			local velocity = 110 * RangeRand(0.1, 0.9) * 0.4;
			
			local particle = CreateMOSParticle("Side Thruster Blast Ball 1", "Base.rte");
			particle.Pos = self.MuzzlePos
			particle.Vel = self.Vel + Vector(velocity * self.FlipFactor,0):RadRotate(self.RotAngle + spread) * smokeVelocity
			particle.Lifetime = particle.Lifetime * RangeRand(0.9, 1.6) * 0.3 * smokeLingering
			particle.AirThreshold = particle.AirThreshold * 0.5
			particle.GlobalAccScalar = 0
			MovableMan:AddParticle(particle);
		end
		
		-- Muzzle flash-smoke
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
			MovableMan:AddParticle(particle);
		end
		--
		
		local shakenessParticle = CreateMOPixel("Shakeness Particle Glow Massive", "Massive.rte");
		shakenessParticle.Pos = self.MuzzlePos;
		shakenessParticle.Mass = 25 + (25 * self.satisfyingVolume);
		shakenessParticle.Lifetime = 500;
		MovableMan:AddParticle(shakenessParticle);
		
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
			self.oldNoise:FadeOut(150);
			local sound = self.noiseOutdoorsSound;
			sound.Volume = 1 - self.satisfyingVolume / 3;
			sound:Play(self.Pos);
			self.oldNoise = sound;
			
			self.satisfyingReflectionSound.Volume = self.satisfyingVolume;
			self.satisfyingReflectionSound:Play(self.Pos);
		else
			self.oldNoise:FadeOut(150);
			local sound = self.noiseIndoorsSound;
			sound:Play(self.Pos);
			self.oldNoise = sound;
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
			self.horizontalAnim = -5;
			self.rotationTarget = self.rotationTarget + 10;
			if self.shoveTimer:IsPastSimMS(self.shoveCooldown / 1.3) then
				self.shoving = false;
			end
			
			local rayVec = Vector(8 * self.FlipFactor, 0):RadRotate(self.RotAngle);
			local rayOrigin = self.MuzzlePos + Vector(0, 0);
			
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
	
		if self.shoveTimer:IsPastSimMS(self.shoveCooldown) and self.parent:IsPlayerControlled() and UInputMan:KeyPressed(22) then
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
		
		-- local jointOffset = Vector(self.JointOffset.X * self.FlipFactor, self.JointOffset.Y):RadRotate(self.RotAngle);
		-- local offsetTotal = Vector(jointOffset.X, jointOffset.Y):RadRotate(-total) - jointOffset
		-- self.Pos = self.Pos + offsetTotal;
		-- self:SetNumberValue("MagOffsetX", offsetTotal.X);
		-- self:SetNumberValue("MagOffsetY", offsetTotal.Y);
		
		if self.reloadingVector then
			self.StanceOffset = self.reloadingVector + stance
			self.SharpStanceOffset = self.reloadingVector + stance
		else
			self.StanceOffset = Vector(self.originalStanceOffset.X, self.originalStanceOffset.Y) + stance
			self.SharpStanceOffset = Vector(self.originalSharpStanceOffset.X, self.originalSharpStanceOffset.Y) + stance
		end
		
	end

end

function OnDetach(self)

	self.shoveStart = false;
	self.shoving = false;

	self.Frame = self.coverClosed and 0 or self.drumInserted and 4 or self.drumRemoved and 5 or self.coverOpened and 4 or 0

	self.delayedFirstShot = true;
	self:DisableScript("Massive.rte/Devices/Weapons/Handheld/Maxav/Maxav.lua");

end