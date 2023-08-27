function Create(self)

	if self:GetRootParent() and self:GetRootParent().PresetName == "Massive" or self:GetRootParent().PresetName == "Zedmassive" then
		self.equippedByMassive = true;
	else
		self.equippedByMassive = false;
	end

	self.preSound = CreateSoundContainer("Pre Hardwall", "Massive.rte");
	
	self.mechFinalSound = CreateSoundContainer("Mech Final Hardwall", "Massive.rte");
	self.satisfyingMechFinalSound = CreateSoundContainer("Satisfying Mech Final Hardwall", "Massive.rte");
	
	self.satisfyingRifleBassSound = CreateSoundContainer("Satisfying Rifle Bass Hardwall", "Massive.rte");
	self.satisfyingRifleReflectionSound = CreateSoundContainer("Satisfying Rifle Reflection Hardwall", "Massive.rte");
	
	self.rifleNoiseOutdoorsSound = CreateSoundContainer("Rifle Noise Outdoors Hardwall", "Massive.rte");
	self.rifleNoiseIndoorsSound = CreateSoundContainer("Rifle Noise Indoors Hardwall", "Massive.rte");
	
	self.rifleReflectionSound = CreateSoundContainer("Rifle Reflection Hardwall", "Massive.rte");
	
	self.shotgunBassSound = CreateSoundContainer("Shotgun Bass Hardwall", "Massive.rte");
	self.shotgunAddSound = CreateSoundContainer("Shotgun Add Hardwall", "Massive.rte");
	
	self.shotgunNoiseOutdoorsSound = CreateSoundContainer("Shotgun Noise Outdoors Hardwall", "Massive.rte");
	self.shotgunNoiseIndoorsSound = CreateSoundContainer("Shotgun Noise Indoors Hardwall", "Massive.rte");
	
	self.shotgunReflectionSound = CreateSoundContainer("Shotgun Reflection Hardwall", "Massive.rte");
	
	self.reloadPrepareSounds = {}
	self.reloadPrepareSounds.boltBack = CreateSoundContainer("Bolt Back Prepare Hardwall", "Massive.rte");
	self.reloadPrepareSounds.clipIn = CreateSoundContainer("Clip In Prepare Hardwall", "Massive.rte");
	self.reloadPrepareSounds.boltForward = CreateSoundContainer("Bolt Forward Prepare Hardwall", "Massive.rte");
	
	self.reloadPrepareLengths = {}
	self.reloadPrepareLengths.boltBack = 830
	self.reloadPrepareLengths.clipIn = 1520
	self.reloadPrepareLengths.boltForward = 315
	
	self.reloadPrepareDelay = {}
	self.reloadPrepareDelay.boltBack = 830
	self.reloadPrepareDelay.clipIn = 1520
	self.reloadPrepareDelay.boltForward = 320
	
	self.reloadAfterSounds = {}
	self.reloadAfterSounds.boltBack = CreateSoundContainer("Bolt Back Hardwall", "Massive.rte");
	self.reloadAfterSounds.clipIn = CreateSoundContainer("Clip In Hardwall", "Massive.rte");
	self.reloadAfterSounds.boltForward = CreateSoundContainer("Bolt Forward Hardwall", "Massive.rte");
	
	self.reloadAfterDelay = {}
	self.reloadAfterDelay.boltBack = 350
	self.reloadAfterDelay.clipIn = 260
	self.reloadAfterDelay.boltForward = 600
	
	self.reloadTimer = Timer();
	
	self.reloadPhase = 0;
	
	self.BaseReloadTime = 5000;

	self.parentSet = false;
	
	self.rotation = 0
	self.rotationTarget = 0
	self.rotationSpeed = 4
	
	self.horizontalAnim = 0
	self.verticalAnim = 0
	
	self.angVel = 0
	self.lastRotAngle = (self.RotAngle + self.InheritedRotAngleOffset)
	
	self.originalSharpLength = self.SharpLength
	
	self.originalJointOffset = Vector(self.JointOffset.X, self.JointOffset.Y)
	self.originalStanceOffset = Vector(math.abs(self.StanceOffset.X), self.StanceOffset.Y)
	self.originalSharpStanceOffset = Vector(self.SharpStanceOffset.X, self.SharpStanceOffset.Y)
	
	self.sharpLengthRegainTime = 500;
	self.powNum = 1;
	self.FireTimer = Timer();
	
	self.delayedFire = false
	self.delayedFireTimer = Timer();
	self.delayedFireTimeMS = 50
	self.delayedFireEnabled = true
	
	self.lastAge = self.Age + 0
	
	self.fireDelayTimer = Timer()
	
	self.activated = false
	
	self.satisfyingFactor = 0;
	
	self.shoveTimer = Timer();
	self.shoveCooldown = 800;

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
	
		self.toFireShotgun = false;
	
		self.fireDelayTimer:Reset()
		self.activated = false;
		self.delayedFire = false;	
	
		if self.parent and self.reloadPhase > 0 then
			self.parent:GetController():SetState(Controller.AIM_SHARP,false);
		end

			
		if self.reloadPhase == 0 then
			self.Frame = 0;
			
			self.reloadDelay = self.reloadPrepareDelay.boltBack;
			self.afterDelay = self.reloadAfterDelay.boltBack;		
			
			self.prepareSound = self.reloadPrepareSounds.boltBack;
			self.prepareSoundLength = self.reloadPrepareLengths.boltBack;
			self.afterSound = self.reloadAfterSounds.boltBack;
			
			self.rotationTarget = 10;
			
		elseif self.reloadPhase == 1 then
			self.reloadDelay = self.reloadPrepareDelay.clipIn;
			self.afterDelay = self.reloadAfterDelay.clipIn;		
			
			self.prepareSound = self.reloadPrepareSounds.clipIn;
			self.prepareSoundLength = self.reloadPrepareLengths.clipIn;
			self.afterSound = self.reloadAfterSounds.clipIn;
			
			self.rotationTarget = 5;
			
		elseif self.reloadPhase == 2 then
			self.reloadDelay = self.reloadPrepareDelay.boltForward;
			self.afterDelay = self.reloadAfterDelay.boltForward;		
			
			self.prepareSound = self.reloadPrepareSounds.boltForward;
			self.prepareSoundLength = self.reloadPrepareLengths.boltForward;
			self.afterSound = self.reloadAfterSounds.boltForward;
			
			self.rotationTarget = 2;
			
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
			
				if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*4.5)) then
					self.Frame = 5;
					if not self.fakeSpawned then
						self.fakeSpawned = true;
						local fake
						fake = CreateAEmitter("Fake Magazine AEmitter Hardwall");
						fake.Pos = self.Pos + Vector(1 * self.FlipFactor, -1):RadRotate(self.RotAngle);
						fake.Vel = self.Vel + Vector(-1*self.FlipFactor, -3):RadRotate(self.RotAngle);
						fake.RotAngle = self.RotAngle;
						fake.AngularVel = self.AngularVel + (-1*self.FlipFactor);
						fake.HFlipped = self.HFlipped;
						MovableMan:AddParticle(fake);
					end
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*3.5)) then
					self.Frame = 4;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2.5)) then
					self.Frame = 3;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.5)) then
					self.Frame = 2;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*0.5)) then
					self.Frame = 1;
				end
			
			elseif self.reloadPhase == 1 then
				
			elseif self.reloadPhase == 2 then
			
				if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2.8)) then
					self.Frame = 0;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2.3)) then
					self.Frame = 1;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.7)) then
					self.Frame = 2;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1)) then
					self.Frame = 3;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1)) then
					self.Frame = 4;
				end

			end
			
			if self.afterSoundPlayed ~= true then
			
				if self.reloadPhase == 0 then
				
					self.boltOpen = true;
					self.phaseOnStop = 1;
					self.horizontalAnim = -1;
			
				elseif self.reloadPhase == 1 then
				
					self.clipInserted = true;
					self.phaseOnStop = 2;
					self.verticalAnim = 1;
					self.Frame = 6;
					
				elseif self.reloadPhase == 2 then
				
					self.horizontalAnim = 3;

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
				if self.reloadPhase == 2 then
					self.BaseReloadTime = 0;
					self.reloadPhase = 0;
					self.phaseOnStop = 0;
					self.satisfyingFactor = math.max(0, self.satisfyingFactor - 0.4);
					self.Frame = 0;
					self.clipInserted = false;
					self.boltOpen = false;
					self.fakeSpawned = false;
				else
					self.reloadPhase = self.reloadPhase + 1;
				end
			end
		else
			self.phasePrepareFinished = false;
		end
	else
		self.reloadingVector = nil;
		
		self.Frame = self.clipInserted and 6 or self.boltOpen and 5 or 0;
		
		if self.phaseOnStop then
			self.reloadPhase = self.phaseOnStop;
			self.phaseOnStop = nil;
		end
		
		self.reloadTimer:Reset();
		self.prepareSoundPlayed = false;
		self.afterSoundPlayed = false;
		self.BaseReloadTime = 5000;
	end
	
	if self:DoneReloading() then
		self.fireDelayTimer:Reset()
		self.activated = false;
		self.delayedFire = false;
	end
	
	local fire = self.shoveTimer:IsPastSimMS(self.shoveCooldown) and self:IsActivated() and self.RoundInMagCount > 0;

	if self.toFireShotgun == false and self.parent and self.delayedFirstShot == true then
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
	elseif self.toFireShotgun == true and self.FireTimer:IsPastSimMS(400) then
	
		self.heatNum = self.heatNum + 50;
		
		self:AddImpulseForce(Vector(-240 * self.FlipFactor, 0):RadRotate(self.RotAngle), Vector());
	
		self.sharpLengthRegainTime = 1000;
		self.powNum = 0.7;
	
		self.Magazine.RoundCount = self.Magazine.RoundCount - 1;
	
		if self.RoundInMagCount == 0 then
		
			self.mechFinalSound:Play(self.Pos);
			
			if self.satisfyingFactor > 0.8 then
				self.satisfyingMechFinalSound:Play(self.Pos);
			end
			
			self.Frame = 5;
			self.boltOpen = true;
			
			local fake
			fake = CreateAEmitter("Fake Magazine AEmitter Hardwall");
			fake.Pos = self.Pos + Vector(1 * self.FlipFactor, -1):RadRotate(self.RotAngle);
			fake.Vel = self.Vel + Vector(-4*self.FlipFactor, -8):RadRotate(self.RotAngle);
			fake.RotAngle = self.RotAngle;
			fake.AngularVel = self.AngularVel + (24*self.FlipFactor);
			fake.HFlipped = self.HFlipped;
			fake:EnableEmission(true)
			MovableMan:AddParticle(fake);
			
			self.reloadPhase = 1;
		end
	
		self.toFireShotgun = false;
		
		self.shotgunAddSound:Play(self.Pos);
		self.shotgunBassSound:Play(self.Pos);
		
		self.angVel = self.angVel + RangeRand(0.7,1.1) * -25
		
		for i = 1, 15 do
			local spread = RangeRand(-math.rad(2), math.rad(2))
			local shot = CreateMOPixel("Pellet Hardwall", "Massive.rte");
			shot.Pos = self.MuzzlePos + Vector(0.1*i*self.FlipFactor, 0):RadRotate(self.RotAngle);
			shot.Vel = self.Vel + Vector(130 * self.FlipFactor, 0):RadRotate(self.RotAngle + spread);
			shot.Lifetime = shot.Lifetime * math.random(0.8, 1.2);
			shot.Team = self.Team;
			shot.IgnoresTeamHits = true;
			shot:SetWhichMOToNotHit(ToMovableObject(self), 150);
			MovableMan:AddParticle(shot);
		end
	
		local shot = CreateMOPixel("Pellet Hardwall Scripted", "Massive.rte");
		shot.Pos = self.MuzzlePos;
		shot.Vel = self.Vel + Vector(130 * self.FlipFactor, 0):RadRotate(self.RotAngle);
		shot.Lifetime = shot.Lifetime * math.random(0.8, 1.2);
		shot.Team = self.Team;
		shot.IgnoresTeamHits = true;
		shot:SetWhichMOToNotHit(ToMovableObject(self), 150);
		MovableMan:AddParticle(shot);	
		
		
		local shakenessParticle = CreateMOPixel("Shakeness Particle Glow Massive", "Massive.rte");
		shakenessParticle.Pos = self.MuzzlePos;
		shakenessParticle.Mass = 15 + (15 * self.satisfyingFactor);
		shakenessParticle.Lifetime = 250;
		MovableMan:AddParticle(shakenessParticle);
		
		local flashParticle = CreateAttachable("Muzzle Flash Custom Hardwall", "Massive.rte");
		flashParticle.Frame = math.random(0, 2);
		flashParticle.HFlipped = self.HFlipped;
		self:AddAttachable(flashParticle);	

		self.FireTimer:Reset();
		
		-- Ground Smoke
		local maxi = 7
		for i = 1, maxi do
			
			local effect = CreateMOSRotating("Ground Smoke Particle Small Massive", "Massive.rte")
			effect.Pos = self.MuzzlePos + Vector(RangeRand(-1,1), RangeRand(-1,1)) * 3
			effect.Vel = self.Vel + Vector(math.random(90,150) * self.FlipFactor,0):RadRotate(math.pi * -0.3 + (0.6 * (i/maxi)))
			effect.Lifetime = effect.Lifetime * RangeRand(0.5,2.0)
			effect.AirResistance = effect.AirResistance * RangeRand(0.5,0.8)
			MovableMan:AddParticle(effect)
		end
		
		local xSpread = 0
		
		local smokeAmount = math.floor((30) * MassiveSettings.GunshotSmokeMultiplier);
		local particleSpread = 21
		
		local smokeLingering = math.sqrt(smokeAmount / 8) * 4
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
		--
		
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
			self.shotgunNoiseOutdoorsSound:Play(self.Pos);
			self.shotgunReflectionSound:Play(self.Pos);
		else
			self.shotgunNoiseIndoorsSound:Play(self.Pos);
		end
		
		if not self:IsAttached() then
			self.delayedFirstShot = true;
			self:DisableScript("Massive.rte/Devices/Weapons/Handheld/Hardwall/Hardwall.lua");
		end
		
	elseif self.toFireShotgun ~= true and fire == false then
		self.delayedFirstShot = true;
	end
	
	self.SharpLength = self.originalSharpLength * math.sin((1 + math.pow(math.min(self.FireTimer.ElapsedSimTimeMS / self.sharpLengthRegainTime, 1), self.powNum) * 0.5) * math.pi) * -1
	
	local recoilFactor = math.pow(math.min(self.FireTimer.ElapsedSimTimeMS / (self.sharpLengthRegainTime / 3), 1), 2.0)
	self.rotationTarget = math.sin(recoilFactor * math.pi) * 3
	
	if self.FiredFrame then
	
		self.heatNum = self.heatNum + 10;
	
		self.sharpLengthRegainTime = 500;
		self.powNum = 0.3;
	
		self.Frame = 7
	
		for i = 1, 7 do
			local shot = CreateMOPixel("Bullet Hardwall", "Massive.rte");
			shot.Pos = self.MuzzlePos + Vector(0.1*i*self.FlipFactor, 0):RadRotate(self.RotAngle);
			shot.Vel = self.Vel + Vector(170 * self.FlipFactor, 0):RadRotate(self.RotAngle);
			shot.Lifetime = shot.Lifetime * math.random(0.8, 1.2);
			shot.Team = self.Team;
			shot.IgnoresTeamHits = true;
			MovableMan:AddParticle(shot);
		end
	
		local shot = CreateMOPixel("Bullet Hardwall Scripted", "Massive.rte");
		shot.Pos = self.MuzzlePos;
		shot.Vel = self.Vel + Vector(170 * self.FlipFactor, 0):RadRotate(self.RotAngle);
		shot.Lifetime = shot.Lifetime * math.random(0.8, 1.2);
		shot.Team = self.Team;
		shot.IgnoresTeamHits = true;
		MovableMan:AddParticle(shot);	
	
		self.FireTimer:Reset();
		
		if self.RoundInMagCount > 0 then
		
			self.toFireShotgun = true;
			
		end
		
		self.angVel = self.angVel + RangeRand(0.7,1.1) * 15
		
		local shakenessParticle = CreateMOPixel("Shakeness Particle Massive", "Massive.rte");
		shakenessParticle.Pos = self.MuzzlePos;
		shakenessParticle.Mass = 0 + (15 * self.satisfyingFactor);
		shakenessParticle.Lifetime = 250;
		MovableMan:AddParticle(shakenessParticle);
		
		local glowParticle = CreateMOPixel("Vent Glow Hardwall", "Massive.rte");
		glowParticle.Pos = self.Pos + Vector(9 * self.FlipFactor, -5):RadRotate(self.RotAngle);
		glowParticle.EffectRotAngle = self.RotAngle;
		MovableMan:AddParticle(glowParticle);
		
		-- venting smoke
		-- if i ever spot anyone making a sus joke, i will find you
		
		for i = 1, 4 do
			local ventParticle = CreateMOSParticle(math.random(0, 100) < 70 and "Tiny Smoke Ball 1" or "Small Smoke Ball 1");
			ventParticle.Vel = self.Vel + Vector(0, math.random(-4, -1)):RadRotate(self.RotAngle)
			ventParticle.Lifetime = ventParticle.Lifetime * RangeRand(0.9, 1.6) * 0.3
			ventParticle.AirThreshold = ventParticle.AirThreshold * 0.5
			ventParticle.GlobalAccScalar = 0
			ventParticle.Pos = self.Pos + Vector(3 * self.FlipFactor * i, -3):RadRotate(self.RotAngle)
			MovableMan:AddParticle(ventParticle);
		end
		
		self.satisfyingRifleBassSound.Volume = self.satisfyingFactor;
		self.satisfyingRifleBassSound:Play(self.Pos);
		
		self.satisfyingRifleReflectionSound.Volume = self.satisfyingFactor;

		self.satisfyingFactor = math.min(1, self.satisfyingFactor + 0.3);
		
		local xSpread = 0
		
		local smokeAmount = math.floor((10 + (math.floor(5 * self.satisfyingFactor))) * MassiveSettings.GunshotSmokeMultiplier);
		local particleSpread = 5 + (math.floor(3 * self.satisfyingFactor))
		
		local smokeLingering = math.sqrt(smokeAmount / 8) * (1 + self.satisfyingFactor * 2)
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
			self.rifleNoiseOutdoorsSound:Play(self.Pos);
			self.rifleReflectionSound:Play(self.Pos);
			self.satisfyingRifleReflectionSound:Play(self.Pos);
		else
			self.rifleNoiseIndoorsSound:Play(self.Pos);
		end		

	end
	
	if self.satisfyingFactor > 0 then
		self.satisfyingFactor = self.satisfyingFactor - 0.1 * TimerMan.DeltaTimeSecs;
		if self.satisfyingFactor < 0 then
			self.satisfyingFactor = 0;
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
			self.horizontalAnim = 3;
			self.rotationTarget = self.rotationTarget + 45;
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
			self.shoveRot = 100 * (math.random(80, 120) / 100);
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
				
		end
		
		self.GFXTimer:Reset()
		self.GFXDelay = math.max(50, math.random(self.GFXDelayMin, self.GFXDelayMax) - self.heatNum) 
	end

end

function OnDetach(self)

	self.heatNum = 0;
	
	self.shoveStart = false;
	self.shoving = false;	
	
	if not self.toFireShotgun then
		self.delayedFirstShot = true;
		self:DisableScript("Massive.rte/Devices/Weapons/Handheld/Hardwall/Hardwall.lua");
	end

end