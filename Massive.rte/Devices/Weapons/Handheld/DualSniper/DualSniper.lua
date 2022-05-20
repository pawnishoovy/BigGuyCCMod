function Create(self)

	if self:GetRootParent() and self:GetRootParent().PresetName == "Massive" or self:GetRootParent().PresetName == "Zedmassive" then
		self.equippedByMassive = true;
	else
		self.equippedByMassive = false;
	end
	
	
	self.chargeSound = CreateSoundContainer("Charge DualSniper", "Massive.rte");
	self.chargedReflectionOutdoorsSound = CreateSoundContainer("Charged Reflection Outdoors DualSniper", "Massive.rte");
	self.chargedBassPreSound = CreateSoundContainer("Charged BassPre DualSniper", "Massive.rte");
	self.chargedAddSound = CreateSoundContainer("Charged Add DualSniper", "Massive.rte");
	
	self.laserOnSound = CreateSoundContainer("Laser On DualSniper", "Massive.rte");
	self.laserOffSound = CreateSoundContainer("Laser Off DualSniper", "Massive.rte");
	
	self.reflectionOutdoorsSound = CreateSoundContainer("Reflection Outdoors DualSniper", "Massive.rte");
	self.satisfyingReflectionOutdoorsSound = CreateSoundContainer("Satisfying Reflection Outdoors DualSniper", "Massive.rte");
	
	self.noiseIndoorsSound = CreateSoundContainer("Noise Indoors DualSniper", "Massive.rte");
	self.debrisIndoorsSound = CreateSoundContainer("Debris Indoors DualSniper", "Massive.rte");
	
	self.casingEjectSound = CreateSoundContainer("Casing Eject DualSniper", "Massive.rte");
	
	self.preSound = CreateSoundContainer("Pre DualSniper", "Massive.rte");
	self.bassPreSound = CreateSoundContainer("BassPre DualSniper", "Massive.rte");
	
	self.reloadPrepareSounds = {}
	self.reloadPrepareSounds.Open = CreateSoundContainer("OpenPrepare DualSniper", "Massive.rte");
	self.reloadPrepareSounds.RoundIn = CreateSoundContainer("RoundInPrepare DualSniper", "Massive.rte");
	self.reloadPrepareSounds.Close = CreateSoundContainer("ClosePrepare DualSniper", "Massive.rte");
	
	self.reloadPrepareLengths = {}
	self.reloadPrepareLengths.Open = 850
	self.reloadPrepareLengths.RoundIn = 0
	self.reloadPrepareLengths.Close = 260
	
	self.reloadPrepareDelay = {}
	self.reloadPrepareDelay.Open = 950
	self.reloadPrepareDelay.RoundIn = 30
	self.reloadPrepareDelay.Close = 300
	
	self.reloadAfterSounds = {}
	self.reloadAfterSounds.Open = CreateSoundContainer("Open DualSniper", "Massive.rte");
	self.reloadAfterSounds.RoundIn = CreateSoundContainer("RoundIn DualSniper", "Massive.rte");
	self.reloadAfterSounds.Close = CreateSoundContainer("Close DualSniper", "Massive.rte");
	
	self.reloadAfterDelay = {}
	self.reloadAfterDelay.Open = 540
	self.reloadAfterDelay.RoundIn = 600
	self.reloadAfterDelay.Close = 300
	
	self.reloadTimer = Timer();
	
	self.reloadPhase = 0;
	
	self.ReloadTime = 5000;
	
	self.ammoCount = 3;
	self.shellCount = 3;

	self.parentSet = false;
	
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
	
	self.delayedFire = false
	self.delayedFireTimer = Timer();
	self.delayedFireTimeMS = 150;
	self.delayedFireEnabled = true
	
	self.chargeHoldTime = 200;
	self.chargeTimer = Timer();
	
	self.lastAge = self.Age + 0
	
	self.fireDelayTimer = Timer()
	
	self.activated = false
	
	self.sharpLengthRegainTime = 500;
	self.powNum = 1;
	self.FireTimer = Timer();
	
	self.shoveTimer = Timer();
	self.shoveCooldown = 750;
	
	self.targetingLaser = true
	self.targetingLaserTimer = Timer();
	self.targetingLaserDelay = 70;
	self.targetingPos = Vector(self.Pos.X, self.Pos.Y)
	self.targetingMOUniqueID = -1	

end

function Update(self)

	if not self.shoveTimer:IsPastSimMS(self.shoveCooldown) then
		self:Deactivate();
	end

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
    self.angVel = (result / TimerMan.DeltaTimeSecs * 0.2) * self.FlipFactor
    
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
		
		local ctrl
		local screen
		
		if self.parent then
			ctrl = self.parent:GetController();
			screen = ActivityMan:GetActivity():ScreenOfPlayer(ctrl.Player);
			if self.reloadPhase > 0 then
				self.parent:GetController():SetState(Controller.AIM_SHARP,false);
			end
		end

			
		if self.reloadPhase == 0 then
			self.reloadDelay = self.reloadPrepareDelay.Open;
			self.afterDelay = self.reloadAfterDelay.Open;		
			
			self.prepareSound = self.reloadPrepareSounds.Open;
			self.prepareSoundLength = self.reloadPrepareLengths.Open;
			self.afterSound = self.reloadAfterSounds.Open;
			
			self.rotationTarget = -5;
			
		elseif self.reloadPhase == 1 then
			self.reloadDelay = self.reloadPrepareDelay.RoundIn;
			self.afterDelay = self.reloadAfterDelay.RoundIn;		
			
			self.prepareSound = nil;
			self.prepareSoundLength = self.reloadPrepareLengths.RoundIn;
			self.afterSound = self.reloadAfterSounds.RoundIn;
			
			self.rotationTarget = -5;
			
		elseif self.reloadPhase == 2 then
			self.reloadDelay = self.reloadPrepareDelay.Close;
			self.afterDelay = self.reloadAfterDelay.Close;		
			
			self.prepareSound = self.reloadPrepareSounds.Close;
			self.prepareSoundLength = self.reloadPrepareLengths.Close;
			self.afterSound = self.reloadAfterSounds.Close;
			
			self.rotationTarget = -5;
			
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
			
				self.phaseOnStop = 0;
			
				if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.3)) then
					self.Frame = 3;
					self.phaseOnStop = 1;
					if not self.shellsSpawned then
						self.shellsSpawned = true;
						
						for i = 1, self.shellCount - self.ammoCount do
							self.shellCount = self.shellCount -1;
							self.casingEjectSound:Play(self.Pos); -- supposedly it auto prevents repeats... here's hoping?
							local shell
							shell = CreateAEmitter("Shell DualSniper", "Massive.rte");
							shell.Pos = self.Pos + Vector(-2 * self.FlipFactor, 0):RadRotate(self.RotAngle);
							shell.Vel = self.Vel + Vector(-1.5*self.FlipFactor, -6):RadRotate(self.RotAngle + math.rad(5) * RangeRand(-1, 1)) * RangeRand(0.8,1.2);
							shell.RotAngle = self.RotAngle;
							shell.AngularVel = self.AngularVel + (-1*self.FlipFactor);
							shell.HFlipped = self.HFlipped;
							MovableMan:AddParticle(shell);
						end
					end
					
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.1)) then
					self.Frame = 2;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*0.8)) then
					self.Frame = 1;	
				end
			
			elseif self.reloadPhase == 1 then
			
				if self.parent and self.parent:GetController():IsState(Controller.WEAPON_FIRE) then
					self.reloadCycle = false;
					PrimitiveMan:DrawTextPrimitive(screen, self.parent.AboveHUDPos + Vector(0, 30), "Interrupting...", true, 1);
				end
				
				if self.ammoCountRaised ~= true then
					self.ammoCountRaised = true;
					if self.ammoCount < 3 then
						self.ammoCount = self.ammoCount + 1;
						self.shellCount = self.shellCount + 1;
						if self.ammoCount == 3 then
							self.phaseOnStop = 2;
							self.reloadCycle = false;
						end
					else
						self.phaseOnStop = 2;
						self.reloadCycle = false;
					end
				end
				
			elseif self.reloadPhase == 2 then
			
				if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.3)) then
					self.Frame = 0;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.1)) then
					self.Frame = 1;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*0.8)) then
					self.Frame = 2;	
				end

			end
			
			if self.afterSoundPlayed ~= true then
			
				if self.reloadPhase == 0 then
					 
					self.verticalAnim = 1;
			
				elseif self.reloadPhase == 1 then
				
					self.verticalAnim = 1;
					
				elseif self.reloadPhase == 2 then
								
					self.verticalAnim = -1;
					self.angVel = -1

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
				if self.reloadPhase == 1 and self.reloadCycle == true then
					self.ammoCountRaised = false;
					self.reloadPhase = 1; -- same phase baby the ride never ends (except at 2 rounds)
				elseif self.reloadPhase == 2 then
					self.shellsSpawned = false;
					self.ReloadTime = 0;
					self.reloadPhase = 0;
					self.phaseOnStop = 0;
				else
					self.reloadPhase = self.reloadPhase + 1;
				end
			end
		end
	else
		self.reloadingVector = nil;
		self.reloadCycle = true;
		self.ammoCountRaised = false;
		
		if self.phaseOnStop then
			self.reloadPhase = self.phaseOnStop;
			self.phaseOnStop = nil;
		end
		
		self.reloadTimer:Reset();
		self.prepareSoundPlayed = false;
		self.afterSoundPlayed = false;
		self.ReloadTime = 5000;
	end
	
	if self:DoneReloading() or self:IsReloading() then
		self.fireDelayTimer:Reset()
		self.activated = false;
		self.delayedFire = false;
	end
	
	if self:DoneReloading() and self.Magazine then
		self.Magazine.RoundCount = self.ammoCount;
	end
	
	self.SharpLength = self.originalSharpLength * math.sin((1 + math.pow(math.min(self.FireTimer.ElapsedSimTimeMS / self.sharpLengthRegainTime, 1), self.powNum) * 0.5) * math.pi) * -1
	
	local recoilFactor = math.pow(math.min(self.FireTimer.ElapsedSimTimeMS / (self.sharpLengthRegainTime / 3), 1), 2.0)
	self.rotationTarget = math.sin(recoilFactor * math.pi) * 8
	
	if self.FireTimer:IsPastSimMS(250) then
		if self.Reloadable == false then
			self.Reloadable = true;
		end
	end
	
	local fire = self.shoveTimer:IsPastSimMS(self.shoveCooldown) and self:IsActivated() and self.RoundInMagCount > 0;

	if self.parent and self.delayedFirstShot == true then
		if self.RoundInMagCount > 0 then
			self:Deactivate()
		end
		
		if not self.activated then
			if fire and not self.Charged then
				if self.Magazine and self.Magazine.RoundCount > 1 then
					fire = false;
					if not self.preActivated then
						if not self.chargeSound:IsBeingPlayed() then
							self.chargeSound:Play(self.Pos);
						end
						self.chargeTimer:Reset();
						self.preActivated = true;
						fire = false;
					elseif self.chargeTimer:IsPastSimMS(self.chargeHoldTime) then
						self.preActivated = false;
						self.Charged = true;
						fire = true;
					end
				end
			elseif self.preActivated then
				self.chargeSound:Stop();
				self.Charged = false;
				fire = true;
				self.preActivated = false;
			end
		end
		
		if fire and not self:IsReloading() then
			if not self.Magazine or self.Magazine.RoundCount < 1 then
				--self:Reload()
				self:Activate()
			elseif not self.activated and not self.delayedFire and self.fireDelayTimer:IsPastSimMS(1 / (self.RateOfFire / 60) * 1000) then
				self.activated = true
				
				self.bassPreSound:Play(self.Pos);
				self.preSound:Play(self.Pos);
				
				if self.Charged == true then
					self.chargedBassPreSound:Play(self.Pos);
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
		self.delayedFirstShot = true;
	end
	
	if self.FiredFrame then
	
		self.heatNum = self.heatNum + 50;
		
		self:AddImpulseForce(Vector(-240 * self.FlipFactor, 0):RadRotate(self.RotAngle), Vector());
	
		self.sharpLengthRegainTime = 1000;
		self.powNum = 0.7;
	
		self.Reloadable = false;
		
		self.ammoCount = self.ammoCount - 1;
		
		local smokeNum = 40;
		if self.Charged then
			if self.Magazine then
				self.Magazine.RoundCount = 0;
			end
			smokeNum = 70;
			self.powNum = 1.2
			self.sharpLengthRegainTime = 2000;
			self.chargedAddSound:Play(self.Pos);			
			local shakenessParticle = CreateMOPixel("Shakeness Particle Glow Massive", "Massive.rte");
			shakenessParticle.Pos = self.MuzzlePos;
			shakenessParticle.Mass = 60
			shakenessParticle.Lifetime = 600;
			MovableMan:AddParticle(shakenessParticle);		

			self.angVel = self.angVel + RangeRand(0.7,1.1) * -10
			
			for i = 1, self.ammoCount - 1 do
				local shot = CreateMOPixel("Pellet DualSniper Scripted", "Massive.rte");
				shot.Pos = self.MuzzlePos;
				shot.Vel = self.Vel + Vector(160 * self.FlipFactor, 0):RadRotate(self.RotAngle);
				shot.Lifetime = shot.Lifetime * math.random(0.8, 1.2);
				shot.Team = self.Team;
				shot.IgnoresTeamHits = true;
				MovableMan:AddParticle(shot);	
				for i = 1, 36 do
					local shot = CreateMOPixel("Pellet DualSniper", "Massive.rte");
					shot.Pos = self.MuzzlePos;
					shot.Vel = self.Vel + (Vector(160*self.FlipFactor,0) + Vector(RangeRand(-1,1), RangeRand(-2,2))):RadRotate(self.RotAngle)
					shot.Lifetime = shot.Lifetime * math.random(0.8, 1.2);
					shot.Team = self.Team;
					shot.IgnoresTeamHits = true;
					MovableMan:AddParticle(shot);
				end
			end
			self.ammoCount = 0;
		else
	
			local shakenessParticle = CreateMOPixel("Shakeness Particle Glow Massive", "Massive.rte");
			shakenessParticle.Pos = self.MuzzlePos;
			shakenessParticle.Mass = 60
			shakenessParticle.Lifetime = 60;
			MovableMan:AddParticle(shakenessParticle);
			
			self.angVel = self.angVel + RangeRand(0.7,1.1) * -5
		end
		
		local shot = CreateMOPixel("Pellet DualSniper Scripted", "Massive.rte");
		shot.Pos = self.MuzzlePos;
		shot.Vel = self.Vel + Vector(160 * self.FlipFactor, 0):RadRotate(self.RotAngle);
		shot.Lifetime = shot.Lifetime * math.random(0.8, 1.2);
		shot.Team = self.Team;
		shot.IgnoresTeamHits = true;
		MovableMan:AddParticle(shot);	
	
		self.FireTimer:Reset();
		
		-- Ground Smoke
		local maxi = 6
		for i = 1, maxi do
			
			local effect = CreateMOSRotating("Ground Smoke Particle Small Massive", "Massive.rte")
			effect.Pos = self.MuzzlePos + Vector(RangeRand(-1,1), RangeRand(-1,1)) * 3
			effect.Vel = self.Vel + Vector(math.random(90,150),0):RadRotate(math.pi * 2 / maxi * i + RangeRand(-2,2) / maxi)
			effect.Lifetime = effect.Lifetime * RangeRand(0.5,2.0)
			effect.AirResistance = effect.AirResistance * RangeRand(0.5,0.8)
			MovableMan:AddParticle(effect)
		end
		
		local xSpread = 0
		
		local smokeSatisfyingFactor = 1
		
		local smokeAmount = math.floor((smokeNum + (math.floor(5 * smokeSatisfyingFactor))) * MassiveSettings.GunshotSmokeMultiplier);
		local particleSpread = 5 + (math.floor(3 * smokeSatisfyingFactor))
		
		local smokeLingering = math.sqrt(smokeAmount / 8) * (1 + smokeSatisfyingFactor * 2)
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
			self.reflectionOutdoorsSound:Play(self.Pos);
			self.satisfyingReflectionOutdoorsSound:Play(self.Pos);
			if self.Charged then
				self.chargedReflectionOutdoorsSound:Play(self.Pos);
			end
		else
			self.debrisIndoorsSound:Play(self.Pos);
			self.noiseIndoorsSound:Play(self.Pos);
		end		
		
		self.Charged = false;

	end

	if self.delayedFire and self.delayedFireTimer:IsPastSimMS(self.delayedFireTimeMS) then
		self:Activate()	
		self.delayedFire = false
		self.delayedFirstShot = false;
	end

	if self.parent then
	
		if self.parent:IsPlayerControlled() then
			if UInputMan:KeyPressed(MassiveSettings.WeaponAbilitySecondary) then
				if self.laserOn == true then
					self.laserOn = false;
					self.laserOffSound:Play(self.Pos);
				else
					self.laserOn = true;
					self.laserOnSound:Play(self.Pos);
				end												
			end
		end
	
		if self.shoveStart then
			self.horizontalAnim = 11;
			self.rotationTarget = self.rotationTarget + 45;
			if self.shoveTimer:IsPastSimMS(self.shoveCooldown / 2) then
				self.shoveStart = false;
				self.parent:SetNumberValue("Gun Shove Massive", 1);
			end
		elseif self.shoving then
			self.horizontalAnim = -7;
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
			self.shoveRot = 55 * (math.random(80, 120) / 100);
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
		self:SetNumberValue("MagOffsetX", offsetTotal.X);
		self:SetNumberValue("MagOffsetY", offsetTotal.Y);
		
		if self.reloadingVector then
			self.StanceOffset = self.reloadingVector + stance
			self.SharpStanceOffset = self.reloadingVector + stance
		else
			self.StanceOffset = Vector(self.originalStanceOffset.X, self.originalStanceOffset.Y) + stance
			self.SharpStanceOffset = Vector(self.originalSharpStanceOffset.X, self.originalSharpStanceOffset.Y) + stance
		end
		
		-- Laser
		-- Tactical Laser!!
		if self.laserOn == true then
			local offset = Vector(-4 * self.FlipFactor, 0):RadRotate(self.RotAngle)
			local point = self.Pos + offset
			
			--PrimitiveMan:DrawCirclePrimitive(point, 1, 13);
			--PrimitiveMan:DrawLinePrimitive(point, point, 13);
			
			if self.targetingLaserTimer:IsPastSimMS(self.targetingLaserDelay) then
				local glow = CreateMOPixel("Mine Laser Particle");
				glow.Pos = point;
				MovableMan:AddParticle(glow);
				
				local rayVec = Vector(700 * self.FlipFactor, 0):RadRotate(self.RotAngle)
				
				local endPos = point + rayVec; -- This value is going to be overriden by function below, this is the end of the ray
				self.ray = SceneMan:CastObstacleRay(point, rayVec, Vector(0, 0), endPos, self.parent.ID, self.Team, 0, 2) -- Do the hitscan stuff, raycast
				local vec = SceneMan:ShortestDistance(point,endPos,SceneMan.SceneWrapsX);
				
				--PrimitiveMan:DrawLinePrimitive(point, point + vec, 13);
				if self.parent:IsPlayerControlled() then
					if self.ray > 0 then
						local glow = CreateMOPixel("Mine Laser Particle");
						glow.Pos = endPos;
						MovableMan:AddParticle(glow);
						
						glow = CreateMOPixel("Mine Laser Particle");
						glow.Pos = endPos;
						MovableMan:AddParticle(glow);
						PrimitiveMan:DrawLinePrimitive(endPos, endPos, 13);
					end
					
					local maxi = vec.Magnitude / GetPPM() * 1.5
					for i = 1, maxi do
						if math.random(1,3) >= 2 then
							local glow = CreateMOPixel("Mine Laser Beam "..math.random(1,3));
							glow.Pos = point + vec * math.max(math.min((1 / maxi * i) + RangeRand(-1.0,1.0) * 0.03, 1), 0);
							glow.EffectRotAngle = self.RotAngle;
							MovableMan:AddParticle(glow);
						end
					end
				end
				
				self.targetingLaserTimer:Reset()
			end
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
				particle.Pos = self.Frame ~= 0 and self.MuzzlePos + Vector(0.6 * self.Frame * self.FlipFactor, 3 * self.Frame):RadRotate(self.RotAngle) or self.MuzzlePos;
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

	self:DisableScript("Massive.rte/Devices/Weapons/Handheld/DualSniper/DualSniper.lua");

end