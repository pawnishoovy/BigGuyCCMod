function Create(self)

	self.preSound = CreateSoundContainer("Pre UltraMag", "Massive.rte");
	
	self.satisfyingAddSound = CreateSoundContainer("Satisfying Add UltraMag", "Massive.rte");
	
	self.noiseOutdoorsSound = CreateSoundContainer("Noise Outdoors UltraMag", "Massive.rte");
	self.noiseIndoorsSound = CreateSoundContainer("Noise Indoors UltraMag", "Massive.rte");
	
	self.reloadPrepareSounds = {}
	self.reloadPrepareSounds.magOut = CreateSoundContainer("Mag Out Prepare UltraMag", "Massive.rte");
	self.reloadPrepareSounds.magIn = CreateSoundContainer("Mag In Prepare UltraMag", "Massive.rte");
	
	self.reloadPrepareLengths = {}
	self.reloadPrepareLengths.magOut = 370
	self.reloadPrepareLengths.magIn = 220
	
	self.reloadPrepareDelay = {}
	self.reloadPrepareDelay.magOut = 370
	self.reloadPrepareDelay.magIn = 730
	
	self.reloadAfterSounds = {}
	self.reloadAfterSounds.magOut = CreateSoundContainer("Mag Out UltraMag", "Massive.rte");
	self.reloadAfterSounds.magIn = CreateSoundContainer("Mag In UltraMag", "Massive.rte");
	self.reloadAfterSounds.magInFull = CreateSoundContainer("Mag In Full UltraMag", "Massive.rte");
	
	self.reloadAfterDelay = {}
	self.reloadAfterDelay.magOut = 330
	self.reloadAfterDelay.magIn = 700
	self.reloadAfterDelay.magInFull = 300
	
	self.reloadTimer = Timer();
	
	self.reloadPhase = 0;
	
	self.ReloadTime = 5000;

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
	
	self.delayedFire = false
	self.delayedFireTimer = Timer();
	self.delayedFireTimeMS = 50
	self.delayedFireEnabled = true
	
	self.lastAge = self.Age + 0
	
	self.fireDelayTimer = Timer()
	
	self.activated = false
	
	self.satisfyingVolume = 0;
	
	self.offHand = -1;

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
    local value = (self.RotAngle + self.InheritedRotAngleOffset) - self.lastRotAngle
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
    
    self.lastRotAngle = (self.RotAngle + self.InheritedRotAngleOffset)
    self.angVel = (result / (TimerMan.DeltaTimeSecs)) * self.FlipFactor
    
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
		self.offHand = -1
		if self.delayedFire then
			self.delayedFire = false
		end
		self.fireDelayTimer:Reset()
	end
	self.lastAge = self.Age + 0
	
	if self:IsReloading() then
	
		self.fireDelayTimer:Reset()
		self.activated = false;
		self.delayedFire = false;	
	
		if self.parent and self.reloadPhase > 0 then
			self.parent:GetController():SetState(Controller.AIM_SHARP,false);
		end

			
		if self.reloadPhase == 0 then
			self.reloadDelay = self.reloadPrepareDelay.magOut;
			self.afterDelay = self.reloadAfterDelay.magOut;		
			
			self.prepareSound = self.reloadPrepareSounds.magOut;
			self.prepareSoundLength = self.reloadPrepareLengths.magOut;
			self.afterSound = self.reloadAfterSounds.magOut;
			
			self.rotationTarget = 50;
			
		elseif self.reloadPhase == 1 then
			self.reloadDelay = self.reloadPrepareDelay.magIn;
			self.afterDelay = self.reloadAfterDelay.magInFull;		
			
			self.prepareSound = self.reloadPrepareSounds.magIn;
			self.prepareSoundLength = self.reloadPrepareLengths.magIn;
			self.afterSound = self.reloadAfterSounds.magInFull;
			
			self.rotationTarget = 60;
			
		elseif self.reloadPhase == 2 then
			self.reloadDelay = self.reloadPrepareDelay.magIn;
			self.afterDelay = self.reloadAfterDelay.magIn;		
			
			self.prepareSound = self.reloadPrepareSounds.magIn;
			self.prepareSoundLength = self.reloadPrepareLengths.magIn;
			self.afterSound = self.reloadAfterSounds.magIn;
			
			self.rotationTarget = 55;
			
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
			
				if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2)) then
					self.reloadingVector = Vector(9, 7);
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.5)) then
					self.reloadingVector = Vector(6, 3);
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1)) then
					self.reloadingVector = Vector(0, 0);
				end
			
			elseif self.reloadPhase == 1 then
			
				if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*4.5)) then
					self.reloadingVector = Vector(0, 0);
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*4)) then
					self.reloadingVector = Vector(6, 3);
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*3.5)) then
					self.reloadingVector = Vector(9, 7);
				end
				
			elseif self.reloadPhase == 2 then
			
				if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*4.5)) then
					self.reloadingVector = Vector(0, 0);
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2.5)) then
					self.reloadingVector = Vector(9, 3);
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2.0)) then
					self.reloadingVector = Vector(9, 7);
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.3)) then
					self.Frame = 0;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.1)) then
					self.Frame = 1;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*0.8)) then
					self.Frame = 2;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*0.5)) then
					self.Frame = 3;
				end

			end
			
			if self.afterSoundPlayed ~= true then
			
				if self.reloadPhase == 0 then
				
					self:SetNumberValue("MagRemoved", 1);
				
					local fake
					fake = CreateMOSRotating("Fake Magazine MOSRotating UltraMag", "Massive.rte");
					fake.Pos = self.Pos + Vector(-3 * self.FlipFactor, 2):RadRotate(self.RotAngle);
					fake.Vel = self.Vel + Vector(1 * self.FlipFactor, 3):RadRotate(self.RotAngle);
					fake.RotAngle = self.RotAngle;
					fake.AngularVel = self.AngularVel + (-1*self.FlipFactor);
					fake.HFlipped = self.HFlipped;
					MovableMan:AddParticle(fake);
				
					if self.chamberOnReload then
						self.phaseOnStop = 2;
					else
						self.phaseOnStop = 1;
					end
					self.verticalAnim = 1;
			
				elseif self.reloadPhase == 1 then
				
					self:RemoveNumberValue("MagRemoved");
				
					self.verticalAnim = -1;
					
				elseif self.reloadPhase == 2 then
				
					self:RemoveNumberValue("MagRemoved");
				
					self.verticalAnim = -1;
					self.angVel = 1

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
					if self.chamberOnReload then
						self.reloadPhase = 2;
					else
						self.reloadPhase = 1;
					end
				elseif self.reloadPhase == 1 or self.reloadPhase == 2 then
					self.ReloadTime = 0;
					self.reloadPhase = 0;
					self.phaseOnStop = 0;
					self.reloadingVector = nil;
					self.chamberOnReload = false;
					self.offHand = -1;
				else
					self.reloadPhase = self.reloadPhase + 1;
				end
			end
		else
			self.phasePrepareFinished = false;
		end
	else
		self.reloadingVector = nil;
		
		if self.phaseOnStop then
			self.reloadPhase = self.phaseOnStop;
			self.phaseOnStop = nil;
		end
		
		self.reloadTimer:Reset();
		self.prepareSoundPlayed = false;
		self.afterSoundPlayed = false;
		self.ReloadTime = 5000;
		-- SLIDE animation when firing
		-- don't ask, math magic
		if self.Magazine and self.Magazine.RoundCount < 1 or not self.Magazine then
			self.chamberOnReload = true;
			self.Frame = 4;
		else
			local f = math.max(1 - math.min((self.FireTimer.ElapsedSimTimeMS) / 200, 1), 0)
			self.Frame = math.floor(f * 5 + 0.55);
		end
	end
	
	if self:DoneReloading() then
		self.fireDelayTimer:Reset()
		self.activated = false;
		self.delayedFire = false;
		if self.chamberOnReload then
			self.Magazine.RoundCount = 12;
		else
			self.Magazine.RoundCount = 12 + 1;
		end
	end
	
	local fire = self:IsActivated() and self.RoundInMagCount > 0;
	
	self:Deactivate()

	if self.parent and self.delayedFirstShot == true then
		local isOffhand = ToAHuman(self.parent).BGArm and self:GetParent().UniqueID == ToAHuman(self.parent).BGArm.UniqueID
	
		-- what a mess
		
		if self.offHand == -1 then
			self.offHand = (isOffhand and 1 or 0)
		elseif fire then
			local oppositeHand;
			if isOffhand then
				oppositeHand = ToAHuman(self.parent).EquippedItem;
			else
				oppositeHand = ToAHuman(self.parent).EquippedBGItem;
			end
			if oppositeHand then
				if (not IsHDFirearm(oppositeHand))
				or (ToHDFirearm(oppositeHand).RoundInMagCount == 0) then
					oppositeHand = nil;
					self.lone = true;
				elseif self.offHand == 1 and isOffhand then
					self.lone = false;
				elseif self.lone == true and self.offHand == 1 and not isOffhand then
					self.offHand = 0;
					self.lone = false;
				end
			else
				self.lone = true;
			end
			if self.offHand == 0 or not oppositeHand then
				if oppositeHand and self.lone then
					self.lone = false;
					if isOffhand then -- main hand will be expecting us not to fire if it just got here
						self.offHand = (self.offHand + 1) % 2
						fire = false;
					end
				end
				self.delayedFirstShot = false;
			else
				if not self.lone then
					fire = false;
				end
				self.delayedFirstShot = false;
			end
			self.offHand = (self.offHand + 1) % 2
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
	elseif fire == false then
		self.delayedFirstShot = true;
	end
	
	self.SharpLength = self.originalSharpLength * (0.9 + math.pow(math.min(self.FireTimer.ElapsedSimTimeMS / 500, 1), 2.0) * 0.5)
	
	if self.FiredFrame then
	
		for i = 1, 5 do
			local shot = CreateMOPixel("Bullet UltraMag", "Massive.rte");
			shot.Pos = self.MuzzlePos + Vector(0.1*i*self.FlipFactor, 0):RadRotate(self.RotAngle);
			shot.Vel = self.Vel + Vector(140 * self.FlipFactor, 0):RadRotate(self.RotAngle);
			shot.Lifetime = shot.Lifetime * math.random(0.8, 1.2);
			shot.Team = self.Team;
			shot.IgnoresTeamHits = true;
			MovableMan:AddParticle(shot);
		end
	
		local shot = CreateMOPixel("Bullet UltraMag Scripted", "Massive.rte");
		shot.Pos = self.MuzzlePos;
		shot.Vel = self.Vel + Vector(140 * self.FlipFactor, 0):RadRotate(self.RotAngle);
		shot.Lifetime = shot.Lifetime * math.random(0.8, 1.2);
		shot.Team = self.Team;
		shot.IgnoresTeamHits = true;
		MovableMan:AddParticle(shot);	
	
		self.FireTimer:Reset();
		
		self.angVel = self.angVel + RangeRand(0.7,1.1) * -15
		
		self.satisfyingAddSound.Volume = self.satisfyingVolume;
		self.satisfyingAddSound:Play(self.Pos);
		
		local shakenessParticle = CreateMOPixel("Shakeness Particle Glow Massive", "Massive.rte");
		shakenessParticle.Pos = self.MuzzlePos;
		shakenessParticle.Mass = 0 + (5 * self.satisfyingVolume);
		shakenessParticle.Lifetime = 500;
		MovableMan:AddParticle(shakenessParticle);
		
		self.satisfyingVolume = math.min(1, self.satisfyingVolume + 0.082);
		
		-- Ground Smoke
		local maxi = 3 + (math.floor(2 * self.satisfyingVolume))
		for i = 1, maxi do
			
			local effect = CreateMOSRotating("Ground Smoke Particle Small Massive", "Massive.rte")
			effect.Pos = self.MuzzlePos + Vector(RangeRand(-1,1), RangeRand(-1,1)) * 3
			effect.Vel = self.Vel + Vector(math.random(90,150),0):RadRotate(math.pi * 2 / maxi * i + RangeRand(-2,2) / maxi)
			effect.Lifetime = effect.Lifetime * RangeRand(0.5,2.0)
			effect.AirResistance = effect.AirResistance * RangeRand(0.5,0.8)
			MovableMan:AddParticle(effect)
		end
		
		local xSpread = 0
		
		local smokeAmount = 10 + (math.floor(5 * self.satisfyingVolume))
		local particleSpread = 5 + (math.floor(3 * self.satisfyingVolume))
		
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
			self.noiseOutdoorsSound:Play(self.Pos);
		else
			self.noiseIndoorsSound:Play(self.Pos);
		end		

	end
	
	if self.satisfyingVolume > 0 then
		self.satisfyingVolume = self.satisfyingVolume - 0.1 * TimerMan.DeltaTimeSecs;
		if self.satisfyingVolume < 0 then
			self.satisfyingVolume = 0;
		end
	end
	
	if self.delayedFire and self.delayedFireTimer:IsPastSimMS(self.delayedFireTimeMS) then
		self:Activate()	
		self.delayedFire = false
		self.delayedFirstShot = false;
	end


	if self.parent then
	
		self.horizontalAnim = math.floor(self.horizontalAnim / (1 + TimerMan.DeltaTimeSecs * 24.0) * 1000) / 1000
		self.verticalAnim = math.floor(self.verticalAnim / (1 + TimerMan.DeltaTimeSecs * 15.0) * 1000) / 1000
		
		local stance = Vector()
		stance = stance + Vector(-1,0) * self.horizontalAnim -- Horizontal animation
		stance = stance + Vector(0,5) * self.verticalAnim -- Vertical animation
		
		self.rotationTarget = self.rotationTarget - (self.angVel * 9)
		
		self.rotation = (self.rotation + self.rotationTarget * TimerMan.DeltaTimeSecs * self.rotationSpeed) / (1 + TimerMan.DeltaTimeSecs * self.rotationSpeed)
		local total = math.rad(self.rotation)
		
		self.InheritedRotAngleOffset = total
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

	self.offHand = -1;

	self.delayedFirstShot = true;
	self:DisableScript("Massive.rte/Devices/Weapons/Handheld/UltraMag/UltraMag.lua");

end