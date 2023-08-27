function Create(self)

	if self:GetRootParent() and self:GetRootParent().PresetName == "Massive" or self:GetRootParent().PresetName == "Zedmassive" then
		self.equippedByMassive = true;
	else
		self.equippedByMassive = false;
	end

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
	
	self.BaseReloadTime = 9900;
	
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
	
	self.originalJointOffset = Vector(self.JointOffset.X, self.JointOffset.Y)
	self.originalStanceOffset = Vector(math.abs(self.StanceOffset.X), self.StanceOffset.Y)
	self.originalSharpStanceOffset = Vector(self.SharpStanceOffset.X, self.SharpStanceOffset.Y)
	
	self.FireTimer = Timer();
	self.powNum = 0.1;
	
	self.delayedFire = false
	self.delayedFireTimer = Timer();
	self.delayedFireTimeMS = 150
	self.delayedFireEnabled = true
	
	self.lastAge = self.Age + 0
	
	self.fireDelayTimer = Timer()
	
	self.activated = false
	
	self.frameNum = 0
	self.frameChangeFactor = 0
	
	self.shoveTimer = Timer();
	self.shoveCooldown = 1100;

end

function Update(self)

	if UInputMan:KeyPressed(9) then
		self:GibThis();
	end

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
    self.angVel = (result / TimerMan.DeltaTimeSecs * 1.0) * self.FlipFactor
    
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
				
					self:SetNumberValue("MagRemoved", 1);
				
					local fake
					fake = CreateMOSRotating("Fake Magazine MOSRotating HYPBORMinigun", "Massive.rte");
					fake.Pos = self.Pos + Vector(-9 * self.FlipFactor, 1):RadRotate(self.RotAngle);
					fake.Vel = self.Vel + Vector(-0.5 * self.FlipFactor, 1):RadRotate(self.RotAngle);
					fake.RotAngle = self.RotAngle;
					fake.AngularVel = self.AngularVel + (-0.5*self.FlipFactor);
					fake.HFlipped = self.HFlipped;
					MovableMan:AddParticle(fake);
					
					self.magRemoved = true;
					self.verticalAnim = 1;
					
				elseif self.reloadPhase == 3 then
					
					self:RemoveNumberValue("MagRemoved");
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
					self.BaseReloadTime = 0;
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
		self.BaseReloadTime = 9900;
	end
	
	self.frameNum = self.frameNum + (TimerMan.DeltaTimeSecs * self.frameChangeFactor)
	self.Frame = math.floor(self.frameNum) % 6;
	
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
		
		if not self.Firing and self.frameChangeFactor > 0 then
			self.frameChangeFactor = self.frameChangeFactor - 2;
		end
		
		--if self.parent:GetController():IsState(Controller.WEAPON_FIRE) and not self:IsReloading() then
		if fire and not self:IsReloading() then
			if not self.Magazine or self.Magazine.RoundCount < 1 then
				--self:Reload()
				self:Activate()
			elseif not self.activated and not self.delayedFire and self.fireDelayTimer:IsPastSimMS(1 / (self.RateOfFire / 60) * 1000) then
				self.activated = true
				
				self.frameChangeFactor = 60;
				
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
		
		self.powNum = self.powNum + TimerMan.DeltaTimeSecs * 0.05;
	end
	
	self.SharpLength = self.originalSharpLength * math.sin((1 + math.pow(math.min(self.FireTimer.ElapsedSimTimeMS / (16000), 1), self.powNum) * 0.5) * math.pi) * -1
	
	local recoilFactor = math.pow(math.min(self.FireTimer.ElapsedSimTimeMS / (200 * 4), 1), 1)
	self.rotationTarget = self.rotationTarget + math.sin(recoilFactor * math.pi) * (20 * self.powNum)
	
	if self.FiredFrame then -- lag code, can't enjoy the game too much now can we
	
		self.heatNum = self.heatNum + 2;
	
		if self.RoundInMagCount == 0 then
			self.beltRemoved = true;
		end
		
		self.FireTimer:Reset();
		
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
		
		local smokeAmount = math.floor((math.max(3, math.floor(20*self.ambientIntenseLoopSound.Volume))) * MassiveSettings.GunshotSmokeMultiplier);
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
		self.frameChangeFactor = 120;
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
	
		if self.shoveStart then
			self.horizontalAnim = 8;
			self.rotationTarget = self.rotationTarget - 10;
			if self.shoveTimer:IsPastSimMS(self.shoveCooldown / 2) then
				self.shoveStart = false;
				self.parent:SetNumberValue("Gun Shove Massive", 1);
			end
		elseif self.shoving then
			self.horizontalAnim = -8;
			self.rotationTarget = self.rotationTarget + self.shoveRot;
			if self.shoveTimer:IsPastSimMS(self.shoveCooldown / 1.3) then
				self.shoving = false;
			end
			
			local rayVec = Vector(self.MuzzleOffset.X * self.FlipFactor + 8 * self.FlipFactor, 0):RadRotate(self.RotAngle);
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
			self.shoveRot = 15 * (math.random(80, 120) / 100);
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
		
		local jointOffset = Vector(self.JointOffset.X * self.FlipFactor, self.JointOffset.Y):RadRotate(self.RotAngle);
		local offsetTotal = Vector(jointOffset.X, jointOffset.Y):RadRotate(-total) - jointOffset
		self.Pos = self.Pos + offsetTotal;
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
				
		end
		
		self.GFXTimer:Reset()
		self.GFXDelay = math.max(50, math.random(self.GFXDelayMin, self.GFXDelayMax) - self.heatNum) 
	end

end

function OnDetach(self)

	self.heatNum = 0;

	self.shoveStart = false;
	self.shoving = false;

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