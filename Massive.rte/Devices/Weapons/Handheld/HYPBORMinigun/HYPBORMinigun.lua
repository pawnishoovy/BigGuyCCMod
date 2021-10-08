function Create(self)

	self.spinUpSound = CreateSoundContainer("Spin Up HYPBORMinigun", "Massive.rte");
	self.spinLoopSound = CreateSoundContainer("Spin Loop HYPBORMinigun", "Massive.rte");
	self.spinDownSound = CreateSoundContainer("Spin Down HYPBORMinigun", "Massive.rte");
	
	self.ambientLoopSound = CreateSoundContainer("Ambient Loop HYPBORMinigun", "Massive.rte");
	self.ambientIntenseLoopSound = CreateSoundContainer("Ambient Intense Loop HYPBORMinigun", "Massive.rte");
	
	self.fireLoopFarSound = CreateSoundContainer("Fire Loop Far HYPBORMinigun", "Massive.rte");
	self.fireLoopIndoorsSound = CreateSoundContainer("Fire Loop Indoors HYPBORMinigun", "Massive.rte");
	self.fireOneSound = CreateSoundContainer("Fire One HYPBORMinigun", "Massive.rte");
	
	self.reflectionCloseSound = CreateSoundContainer("Reflection Close HYPBORMinigun", "Massive.rte");
	self.reflectionCloseIndoorsSound = CreateSoundContainer("Reflection Close Indoors HYPBORMinigun", "Massive.rte");
	self.reflectionFarSound = CreateSoundContainer("Reflection Far HYPBORMinigun", "Massive.rte");
	self.reflectionIntenseSound = CreateSoundContainer("Reflection Intense HYPBORMinigun", "Massive.rte");
	self.reflectionIntenseIndoorsSound = CreateSoundContainer("Reflection Intense Indoors HYPBORMinigun", "Massive.rte");
	self.reflectionSatisfyingSound = CreateSoundContainer("Reflection Satisfying HYPBORMinigun", "Massive.rte");
	
	self.reloadPrepareSounds = {}
	self.reloadPrepareSounds.Raise = CreateSoundContainer("Raise Prepare HYPBORMinigun", "Massive.rte");
	self.reloadPrepareSounds.beltOut = CreateSoundContainer("Belt Out Prepare HYPBORMinigun", "Massive.rte");
	self.reloadPrepareSounds.magOut = CreateSoundContainer("Mag Out Prepare HYPBORMinigun", "Massive.rte");
	self.reloadPrepareSounds.magIn = CreateSoundContainer("Mag In Prepare HYPBORMinigun", "Massive.rte");
	self.reloadPrepareSounds.beltIn = CreateSoundContainer("Belt In Prepare HYPBORMinigun", "Massive.rte");
	self.reloadPrepareSounds.Shoulder = CreateSoundContainer("Shoulder Prepare HYPBORMinigun", "Massive.rte");
	
	self.reloadPrepareLengths = {}
	self.reloadPrepareLengths.Raise = 550
	self.reloadPrepareLengths.beltOut = 430
	self.reloadPrepareLengths.magOut = 465
	self.reloadPrepareLengths.magIn = 900
	self.reloadPrepareLengths.beltIn = 710
	self.reloadPrepareLengths.Shoulder = 845
	
	self.reloadPrepareDelay = {}
	self.reloadPrepareDelay.Raise = 900
	self.reloadPrepareDelay.beltOut = 500
	self.reloadPrepareDelay.magOut = 800
	self.reloadPrepareDelay.magIn = 1400
	self.reloadPrepareDelay.beltIn = 800
	self.reloadPrepareDelay.Shoulder = 1000
	
	self.reloadAfterSounds = {}
	self.reloadAfterSounds.Raise = CreateSoundContainer("Raise HYPBORMinigun", "Massive.rte");
	self.reloadAfterSounds.beltOut = CreateSoundContainer("Belt Out HYPBORMinigun", "Massive.rte");
	self.reloadAfterSounds.magOut = CreateSoundContainer("Mag Out HYPBORMinigun", "Massive.rte");
	self.reloadAfterSounds.magIn = CreateSoundContainer("Mag In HYPBORMinigun", "Massive.rte");
	self.reloadAfterSounds.beltIn = CreateSoundContainer("Belt In HYPBORMinigun", "Massive.rte");
	self.reloadAfterSounds.Shoulder = CreateSoundContainer("Shoulder HYPBORMinigun", "Massive.rte");
	
	self.reloadAfterDelay = {}
	self.reloadAfterDelay.Raise = 600
	self.reloadAfterDelay.beltOut = 750
	self.reloadAfterDelay.magOut = 1500
	self.reloadAfterDelay.magIn = 600
	self.reloadAfterDelay.beltIn = 600
	self.reloadAfterDelay.Shoulder = 300
	
	self.reloadTimer = Timer();
	
	self.reloadPhase = 0;
	
	self.ReloadTime = 9900;
	
	self.environmentCheckTimer = Timer();
	self.environmentCheckDelay = 350;

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
	
	self.delayedFire = false
	self.delayedFireTimer = Timer();
	self.delayedFireTimeMS = 150
	self.delayedFireEnabled = true
	
	self.lastAge = self.Age + 0
	
	self.fireDelayTimer = Timer()
	
	self.activated = false

end

function Update(self)

	self.rotationTarget = 0 -- ZERO IT FIRST AAAA!!!!!

	self.spinUpSound.Pos = self.Pos;
	self.spinLoopSound.Pos = self.Pos;
	self.spinDownSound.Pos = self.Pos;
	self.ambientLoopSound.Pos = self.Pos;
	self.fireLoopFarSound.Pos = self.Pos;
	self.fireLoopIndoorsSound.Pos = self.Pos;

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
    self.angVel = (result / TimerMan.DeltaTimeSecs) * self.FlipFactor
    
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
			self.reloadDelay = self.reloadPrepareDelay.beltOut;
			self.afterDelay = self.reloadAfterDelay.beltOut;		
			
			self.prepareSound = self.reloadPrepareSounds.beltOut;
			self.prepareSoundLength = self.reloadPrepareLengths.beltOut;
			self.afterSound = self.reloadAfterSounds.beltOut;
			
			self.rotationTarget = 45;
			
		elseif self.reloadPhase == 2 then
			self.reloadDelay = self.reloadPrepareDelay.magOut;
			self.afterDelay = self.reloadAfterDelay.magOut;		
			
			self.prepareSound = self.reloadPrepareSounds.magOut;
			self.prepareSoundLength = self.reloadPrepareLengths.magOut;
			self.afterSound = self.reloadAfterSounds.magOut;
			
			self.rotationTarget = 45;
			
		elseif self.reloadPhase == 3 then
			self.reloadDelay = self.reloadPrepareDelay.magIn;
			self.afterDelay = self.reloadAfterDelay.magIn;		
			
			self.prepareSound = self.reloadPrepareSounds.magIn;
			self.prepareSoundLength = self.reloadPrepareLengths.magIn;
			self.afterSound = self.reloadAfterSounds.magIn;
			
			self.rotationTarget = 30;
			
		elseif self.reloadPhase == 4 then
			self.reloadDelay = self.reloadPrepareDelay.beltIn;
			self.afterDelay = self.reloadAfterDelay.beltIn;		
			
			self.prepareSound = self.reloadPrepareSounds.beltIn;
			self.prepareSoundLength = self.reloadPrepareLengths.beltIn;
			self.afterSound = self.reloadAfterSounds.beltIn;
			
			self.rotationTarget = 40;
			
		elseif self.reloadPhase == 5 then
			self.reloadDelay = self.reloadPrepareDelay.Shoulder;
			self.afterDelay = self.reloadAfterDelay.Shoulder;		
			
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
		
			self.phasePrepareFinished = true;
			
			if self.reloadPhase == 0 then
			
				self.rotationTarget = 45;

			elseif self.reloadPhase == 1 then

			elseif self.reloadPhase == 2 then

			elseif self.reloadPhase == 3 then
			
			elseif self.reloadPhase == 4 then
			
			elseif self.reloadPhase == 5 then
				
			
				self.rotationTarget = 5;

			end
			
			if self.afterSoundPlayed ~= true then
			
				if self.reloadPhase == 0 then
				
					self.verticalAnim = 2;
			
				elseif self.reloadPhase == 1 then
				
					self.beltRemoved = true;
					
				elseif self.reloadPhase == 2 then
					
					self.magRemoved = true;
					self.verticalAnim = 1;
					
				elseif self.reloadPhase == 3 then
					
					self.magInserted = true;
					
				elseif self.reloadPhase == 4 then
				
					self.beltInserted = true;
					
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
					if self.beltInserted then
						self.reloadPhase = 5;
					elseif self.magInserted then
						self.reloadPhase = 4;
					elseif self.magRemoved then
						self.reloadPhase = 3;
					elseif self.beltRemoved then
						self.reloadPhase = 2;
					else
						self.reloadPhase = 1;
					end
				elseif self.reloadPhase == 5 then
					self.beltRemoved = false;
					self.magRemoved = false;
					self.magInserted = false;
					self.beltInserted = false;
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
		
		self.reloadTimer:Reset();
		self.prepareSoundPlayed = false;
		self.afterSoundPlayed = false;
		self.ReloadTime = 9900;
	end
	
	if self:DoneReloading() or self:IsReloading() then
		self.fireDelayTimer:Reset()
		self.activated = false;
		self.delayedFire = false;
	end
	
	local fire = self:IsActivated() and self.RoundInMagCount > 0;

	if self.parent and self.delayedFirstShot == true then
		self:Deactivate()
		
		--if self.parent:GetController():IsState(Controller.WEAPON_FIRE) and not self:IsReloading() then
		if fire and not self:IsReloading() then
			if not self.Magazine or self.Magazine.RoundCount < 1 then
				--self:Reload()
				self:Activate()
			elseif not self.activated and not self.delayedFire and self.fireDelayTimer:IsPastSimMS(1 / (self.RateOfFire / 60) * 1000) then
				self.activated = true
				
				if self.spinUpSound then
					self.spinUpSound:Play(self.Pos);
				end
				
				if self.spinDownSound:IsBeingPlayed() then
					self.spinDownSound:FadeOut(100);
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
			self.spinLoopSound:FadeOut(30);
			self.ambientLoopSound:FadeOut(150);
			self.ambientIntenseLoopSound:FadeOut(30)
			self.fireLoopFarSound:FadeOut(30);
			self.fireLoopIndoorsSound:FadeOut(30);
			self.spinDownSound:Play(self.Pos);
			self.reflectionIntenseSound.Volume = self.ambientIntenseLoopSound.Volume;
			self.reflectionIntenseIndoorsSound.Volume = self.ambientIntenseLoopSound.Volume;
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
			
			self.reflectionSatisfyingSound.Volume = math.max(0.8, self.ambientIntenseLoopSound.Volume);
			self.reflectionSatisfyingSound.Pitch = 1.0 - (0.1*(self.ambientIntenseLoopSound.Volume));
			
			if outdoorRays >= self.rayThreshold then
				self.reflectionIntenseSound:Play(self.Pos);
				self.reflectionCloseSound:Play(self.Pos);
				self.reflectionFarSound:Play(self.Pos);
				self.reflectionSatisfyingSound:Play(self.Pos);
			else
				self.reflectionIntenseIndoorsSound:Play(self.Pos);
				self.reflectionCloseIndoorsSound:Play(self.Pos);
			end
		end
	elseif fire == true then
	
		self.shakenessParticle.Pos = self.MuzzlePos;
	
		if self.ambientIntenseLoopSound.Volume < 1 then
			self.ambientIntenseLoopSound.Volume = self.ambientIntenseLoopSound.Volume + 0.2 * TimerMan.DeltaTimeSecs;
			self.ambientLoopSound.Volume = self.ambientLoopSound.Volume - 0.2 * TimerMan.DeltaTimeSecs;
			self.spinLoopSound.Volume = self.spinLoopSound.Volume - 0.005 * TimerMan.DeltaTimeSecs;
			if self.ambientIntenseLoopSound.Volume > 1 then
				self.ambientIntenseLoopSound.Volume = 1;
				self.ambientLoopSound.Volume = 0;
			end
		end
		if self.Environment == 1 and self.fireLoopFarSound.Volume > 0 then
			self.fireLoopFarSound.Volume = self.fireLoopFarSound.Volume - 0.2 * TimerMan.DeltaTimeSecs;
			if self.fireLoopFarSound.Volume < 0 then
				self.fireLoopFarSound.Volume = 0;
			end
		elseif self.Environment == 0 and self.fireLoopFarSound.Volume < 1 then
			self.fireLoopFarSound.Volume = self.fireLoopFarSound.Volume + 0.2 * TimerMan.DeltaTimeSecs;
			if self.fireLoopFarSound.Volume > 1 then
				self.fireLoopFarSound.Volume = 1;
			end
		end
		
		if self.Environment == 0 and self.fireLoopIndoorsSound.Volume > 0 then
			self.fireLoopIndoorsSound.Volume = self.fireLoopIndoorsSound.Volume - 0.2 * TimerMan.DeltaTimeSecs;
			if self.fireLoopIndoorsSound.Volume < 0 then
				self.fireLoopIndoorsSound.Volume = 0;
			end
		elseif self.Environment == 1 and self.fireLoopIndoorsSound.Volume < 1 then
			self.fireLoopIndoorsSound.Volume = self.fireLoopIndoorsSound.Volume + 0.2 * TimerMan.DeltaTimeSecs;
			if self.fireLoopIndoorsSound.Volume > 1 then
				self.fireLoopIndoorsSound.Volume = 1;
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
	end
	
	if self.FiredFrame then -- lag code, can't enjoy the game too much now can we
	
		if self.RoundInMagCount == 0 then
			self.beltRemoved = true;
		end
		
		-- Ground Smoke
		local maxi = 7
		local changed = math.max(math.floor(maxi*self.ambientIntenseLoopSound.Volume), 2)
		for i = 1, changed do
			
			local effect = CreateMOSRotating("Ground Smoke Particle Small Massive", "Massive.rte")
			effect.Pos = self.MuzzlePos + Vector(RangeRand(-1,1), RangeRand(-1,1)) * 3
			effect.Vel = self.Vel + Vector(math.random(90,150),0):RadRotate(math.pi * 2 / changed * i + RangeRand(-2,2) / changed)
			effect.Lifetime = effect.Lifetime * RangeRand(0.5,2.0)
			effect.AirResistance = effect.AirResistance * RangeRand(0.5,0.8)
			MovableMan:AddParticle(effect)
		end
		
		local xSpread = 0
		
		local smokeAmount = math.max(3, math.floor(20*self.ambientIntenseLoopSound.Volume))
		local particleSpread = math.max(5, math.floor(15*self.ambientIntenseLoopSound.Volume))
		
		local smokeLingering = math.sqrt(smokeAmount / 8) * 1
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
		for i = 1, math.ceil(smokeAmount / (math.random(4,6))) do
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
	end
	
	if self.delayedFire and self.delayedFireTimer:IsPastSimMS(self.delayedFireTimeMS) then
		self:Activate()
		self.Firing = true;
		self.firedOnce = false;
		self.fireOneSound:Play(self.Pos);
		self.spinLoopSound.Volume = 1;
		self.spinLoopSound:Play(self.Pos);
		self.ambientLoopSound:Stop(-1);
		self.ambientLoopSound.Volume = 1;
		self.ambientLoopSound:Play(self.Pos);
		self.ambientIntenseLoopSound.Volume = 0;
		self.ambientIntenseLoopSound:Play(self.Pos);
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
			self.fireLoopFarSound.Volume = 1;
			self.fireLoopIndoorsSound.Volume = 0;
		else
			self.Environment = 1;
			self.fireLoopFarSound.Volume = 0;
			self.fireLoopIndoorsSound.Volume = 1;
		end
		self.fireLoopFarSound:Play(self.Pos);
		self.fireLoopIndoorsSound:Play(self.Pos);
		
		local shakenessParticle = CreateMOPixel("Shakeness Particle HYPBORMinigun", "Massive.rte");
		shakenessParticle.Pos = self.MuzzlePos;
		self.shakenessParticle = shakenessParticle;
		MovableMan:AddParticle(shakenessParticle);
		
		self.delayedFire = false
		self.delayedFirstShot = false;
	end

	-- Animation
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

	if self.shakenessParticle then
		self.shakenessParticle.ToDelete = true;
		self.shakenessParticle.Lifetime = 10;
		self.shakenessParticle = nil;
	end
	self.delayedFirstShot = true;
	if self.Firing == true then
		self.Firing = false;
		self.spinLoopSound:FadeOut(30);
		self.ambientLoopSound:FadeOut(150);
		self.ambientIntenseLoopSound:FadeOut(30)
		self.fireLoopFarSound:FadeOut(30);
		self.fireLoopIndoorsSound:FadeOut(30);
		self.spinDownSound:Play(self.Pos);
		self.reflectionIntenseSound.Volume = self.ambientIntenseLoopSound.Volume;
		self.reflectionIntenseIndoorsSound.Volume = self.ambientIntenseLoopSound.Volume;
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
		
		self.reflectionSatisfyingSound.Volume = math.max(0.8, self.ambientIntenseLoopSound.Volume);
		self.reflectionSatisfyingSound.Pitch = 1.0 - (0.1*(self.ambientIntenseLoopSound.Volume));
		
		if outdoorRays >= self.rayThreshold then
			self.reflectionIntenseSound:Play(self.Pos);
			self.reflectionCloseSound:Play(self.Pos);
			self.reflectionFarSound:Play(self.Pos);
			self.reflectionSatisfyingSound:Play(self.Pos);
		else
			self.reflectionIntenseIndoorsSound:Play(self.Pos);
			self.reflectionCloseIndoorsSound:Play(self.Pos);
		end
	end

	self:DisableScript("Massive.rte/Devices/Weapons/Handheld/HYPBORMinigun/HYPBORMinigun.lua");

end

function OnDestroy(self)

	if ValidMO(self.shakenessParticle) then
		self.shakenessParticle.ToDelete = true;
		self.shakenessParticle.Lifetime = 10;
		self.shakenessParticle = nil;
	end
	if self.Firing == true then
		self.Firing = false;
		self.spinLoopSound:FadeOut(30);
		self.ambientLoopSound:FadeOut(150);
		self.ambientIntenseLoopSound:FadeOut(30)
		self.fireLoopFarSound:FadeOut(30);
		self.fireLoopIndoorsSound:FadeOut(30);
		self.spinDownSound:Play(self.Pos);
		self.reflectionIntenseSound.Volume = self.ambientIntenseLoopSound.Volume;
		self.reflectionIntenseIndoorsSound.Volume = self.ambientIntenseLoopSound.Volume;
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
		
		self.reflectionSatisfyingSound.Volume = math.max(0.8, self.ambientIntenseLoopSound.Volume);
		self.reflectionSatisfyingSound.Pitch = 1.0 - (0.1*(self.ambientIntenseLoopSound.Volume));
		
		if outdoorRays >= self.rayThreshold then
			self.reflectionIntenseSound:Play(self.Pos);
			self.reflectionCloseSound:Play(self.Pos);
			self.reflectionFarSound:Play(self.Pos);
			self.reflectionSatisfyingSound:Play(self.Pos);
		else
			self.reflectionIntenseIndoorsSound:Play(self.Pos);
			self.reflectionCloseIndoorsSound:Play(self.Pos);
		end
	end

end