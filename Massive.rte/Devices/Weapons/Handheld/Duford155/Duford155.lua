function Create(self)

	if self:GetRootParent() and self:GetRootParent().PresetName == "Massive" or self:GetRootParent().PresetName == "Zedmassive" then
		self.equippedByMassive = true;
	else
		self.equippedByMassive = false;
	end

	self.preSound = CreateSoundContainer("Pre Duford155", "Massive.rte");
	self.bassPreSound = CreateSoundContainer("Bass Pre Duford155", "Massive.rte");
	
	
	self.bassOutdoorsSound = CreateSoundContainer("Bass Outdoors Duford155", "Massive.rte");
	self.bassIndoorsSound = CreateSoundContainer("Bass Indoors Duford155", "Massive.rte");
	
	self.boomOutdoorsSound = CreateSoundContainer("Boom Outdoors Duford155", "Massive.rte");
	self.boomIndoorsSound = CreateSoundContainer("Boom Indoors Duford155", "Massive.rte");

	self.boomOutdoorsDistantSound = CreateSoundContainer("Boom Outdoors Distant Duford155", "Massive.rte");
	
	self.boomOutdoorsFarSound = CreateSoundContainer("Boom Outdoors Far Duford155", "Massive.rte");
	
	self.reflectionIndoorsSound = CreateSoundContainer("Reflection Indoors Duford155", "Massive.rte");
	
	self.artilleryConfirmSound = CreateSoundContainer("Artillery Confirm Duford155", "Massive.rte");
	
	self.reloadPrepareSounds = {}
	self.reloadPrepareSounds.Raise = CreateSoundContainer("Raise Prepare Duford155", "Massive.rte");
	self.reloadPrepareSounds.Open = CreateSoundContainer("Open Prepare Duford155", "Massive.rte");
	self.reloadPrepareSounds.Load = CreateSoundContainer("Load Prepare Duford155", "Massive.rte");
	self.reloadPrepareSounds.Close = CreateSoundContainer("Close Prepare Duford155", "Massive.rte");
	
	self.reloadPrepareLengths = {}
	self.reloadPrepareLengths.Raise = 510
	self.reloadPrepareLengths.Open = 660
	self.reloadPrepareLengths.Load = 1920
	self.reloadPrepareLengths.Close = 700
	
	self.reloadPrepareDelay = {}
	self.reloadPrepareDelay.Raise = 510
	self.reloadPrepareDelay.Open = 660
	self.reloadPrepareDelay.Load = 2400
	self.reloadPrepareDelay.Close = 700
	
	self.reloadAfterSounds = {}
	self.reloadAfterSounds.Raise = CreateSoundContainer("Raise Duford155", "Massive.rte");
	self.reloadAfterSounds.Open = CreateSoundContainer("Open Duford155", "Massive.rte");
	self.reloadAfterSounds.Load = CreateSoundContainer("Load Duford155", "Massive.rte");
	self.reloadAfterSounds.Close = CreateSoundContainer("Close Duford155", "Massive.rte");
	
	self.reloadAfterDelay = {}
	self.reloadAfterDelay.Raise = 100
	self.reloadAfterDelay.Open = 600
	self.reloadAfterDelay.Load = 1000
	self.reloadAfterDelay.Close = 2000
	
	self.reloadTimer = Timer();
	
	self.reloadPhase = 0;
	
	self.ReloadTime = 12000;

	self.parentSet = false;
	
	self.rotation = 0
	self.rotationTarget = 0
	self.rotationSpeed = 4
	
	self.horizontalAnim = 0
	self.verticalAnim = 0
	
	self.angVel = 0
	self.lastRotAngle = (self.RotAngle + self.InheritedRotAngleOffset)
	
	self.originalSharpLength = self.SharpLength
	
	self.originalStanceOffset = Vector(math.abs(self.StanceOffset.X), self.StanceOffset.Y)
	self.originalSharpStanceOffset = Vector(self.SharpStanceOffset.X, self.SharpStanceOffset.Y)
	
	self.delayedFire = false
	self.delayedFireTimer = Timer();
	self.delayedFireTimeMS = 150;
	self.delayedFireEnabled = true
	
	self.lastAge = self.Age + 0
	
	self.FireTimer = Timer();
	self.fireDelayTimer = Timer()
	
	self.activated = false
	
	-- honestly quite incredible
	
	self.artilleryModeEnabled = false;
	
	self.textTimer = Timer();
	self.textDelay = 0;
	
	self.shoveTimer = Timer();
	self.shoveCooldown = 1300;

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
		if self.parent and self.reloadPhase > 0 then
			self.parent:GetController():SetState(Controller.AIM_SHARP,false);
		end

		if self.reloadPhase == 0 then
			self.reloadDelay = self.reloadPrepareDelay.Raise;
			self.afterDelay = self.reloadAfterDelay.Raise;		
			
			self.prepareSound = self.reloadPrepareSounds.Raise;
			self.prepareSoundLength = self.reloadPrepareLengths.Raise;
			self.afterSound = self.reloadAfterSounds.Raise;
			
			self.rotationTarget = 8 * (self.reloadTimer.ElapsedSimTimeMS/self.reloadDelay);
			
		elseif self.reloadPhase == 1 then
			self.reloadDelay = self.reloadPrepareDelay.Open;
			self.afterDelay = self.reloadAfterDelay.Open;		
			
			self.prepareSound = self.reloadPrepareSounds.Open;
			self.prepareSoundLength = self.reloadPrepareLengths.Open;
			self.afterSound = self.reloadAfterSounds.Open;
			
			self.rotationTarget = 2;
			
		elseif self.reloadPhase == 2 then
			self.reloadDelay = self.reloadPrepareDelay.Load;
			self.afterDelay = self.reloadAfterDelay.Load;		
			
			self.prepareSound = self.reloadPrepareSounds.Load;
			self.prepareSoundLength = self.reloadPrepareLengths.Load;
			self.afterSound = self.reloadAfterSounds.Load;
			
			self.rotationTarget = -6;
			
		elseif self.reloadPhase == 3 then
		
			self.reloadDelay = self.reloadPrepareDelay.Close;
			self.afterDelay = self.reloadAfterDelay.Close;		
			
			self.prepareSound = self.reloadPrepareSounds.Close;
			self.prepareSoundLength = self.reloadPrepareLengths.Close;
			self.afterSound = self.reloadAfterSounds.Close;
			
			self.rotationTarget = -3;
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
			
			if self.reloadPhase == 1 then
			
				local minTime = self.reloadDelay
				local maxTime = self.reloadDelay + ((self.afterDelay/5)*5)
				
				local factor = math.pow(math.min(math.max(self.reloadTimer.ElapsedSimTimeMS - minTime, 0) / (maxTime - minTime), 1), 2)
				factor = factor^2

				self.Frame = math.floor(factor * (11) + 0.5)
				
				if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*3)) then
					self.reloadingVector = Vector(4, -2);
					if self.Opened ~= true then
						local fake
						fake = CreateMOSRotating("Shell Duford155", "Massive.rte");
						fake.Pos = self.Pos + Vector(-22 * self.FlipFactor, 0):RadRotate(self.RotAngle);
						fake.Vel = self.Vel + Vector(-1 * self.FlipFactor, 1):RadRotate(self.RotAngle);
						fake.RotAngle = self.RotAngle;
						fake.AngularVel = self.AngularVel + (-0.3*self.FlipFactor);
						fake.HFlipped = self.HFlipped;
						MovableMan:AddParticle(fake);
					
						self.Opened = true;
					end
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2)) then
					self.reloadingVector = Vector(4, -1);
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1)) then
					self.reloadingVector = Vector(4, 0);
				end

			elseif self.reloadPhase == 2 then
			
				local minTime = self.reloadDelay
				local maxTime = self.reloadDelay + ((self.afterDelay/5)*3)
				
				local factor = math.pow(math.min(math.max(self.reloadTimer.ElapsedSimTimeMS - minTime, 0) / (maxTime - minTime), 1), 2)
				factor = factor^2

				self.Frame = 11 + math.floor(factor * (8) + 0.5)

			elseif self.reloadPhase == 3 then
			
				local minTime = self.reloadDelay
				local maxTime = self.reloadDelay + ((self.afterDelay/5)*2)
				
				local factor = math.pow(math.min(math.max(self.reloadTimer.ElapsedSimTimeMS - minTime, 0) / (maxTime - minTime), 1), 2)
				factor = factor^3

				self.frameNum = 19 + math.floor(factor * (11) + 0.5)
				
				if self.frameNum  == 30 then
					self.Frame = 0;
				elseif self.frameNum  == 29 then
					self.Frame = 1;
				elseif self.frameNum == 28 then
					self.Frame = 2;
				else
					self.Frame = self.frameNum;
				end
				
				if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*5)) then
					self.reloadingVector = Vector(4, 0);
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*4)) then
					self.reloadingVector = Vector(4, -1);
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2)) then
					self.reloadingVector = Vector(4, -2);
				end

			end
			
			if self.afterSoundPlayed ~= true then
			
				if self.reloadPhase == 0 then
				
					self.verticalAnim = 2;
			
				elseif self.reloadPhase == 1 then
					
				elseif self.reloadPhase == 2 then
					
					self.Loaded = true;
					self.verticalAnim = 1;
					
				elseif self.reloadPhase == 3 then
					self.horizontalAnim = 1;
					
					self.rotationTarget = 5;
					
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
				
					if self.Loaded then
						self.reloadPhase = 3;
					elseif self.Opened then
						self.reloadPhase = 2;
					else
						self.reloadPhase = 1;
					end
				elseif self.reloadPhase == 3 then
					self.Opened = false;
					self.Loaded = false;
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
		
		self.Frame = self.Loaded and 19 or self.Opened and 11 or 0
		
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
	
	if self:NumberValueExists("Enter Artillery Mode") then
		self:RemoveNumberValue("Enter Artillery Mode");
		if self.artilleryModeEnabled ~= true then
		
			if self.RoundInMagCount == 1 then
		
				self.antiFireHold = true;
			
				self.artilleryPos = nil;
				self.artilleryOriginPos = Vector(self.Pos.X, self.Pos.Y);
			
				self.artilleryModeEnabled = true;
				-- this is MEGA ANNOYING
				-- guns are in the wrong update order to affect the viewpoint of actors
				-- we need to spawn a viewpoint handler particle instead, which is in the right update order
				local viewpointHandler = CreateMOPixel("Viewpoint Handler Duford155", "Massive.rte");
				viewpointHandler.Pos = self.Pos;
				viewpointHandler.Mass = self.parent.UniqueID;
				viewpointHandler.Sharpness = self.UniqueID;
				self.viewpointHandlerParticle = viewpointHandler;
				MovableMan:AddParticle(viewpointHandler);
			else
				self.textTimer:Reset();
				self.textDelay = 3000;
				self.textToDisplay = "RELOAD FIRST";
			end
		end
	end
	
	if self.artilleryModeEnabled == true then
		self.artilleryConfirmSound.Pos = self.Pos;
		local originDeviation = SceneMan:ShortestDistance(self.artilleryOriginPos, self.Pos, SceneMan.SceneWrapsX);
		if UInputMan:KeyPressed(8) or originDeviation.Magnitude > 35 or not self.parent:IsPlayerControlled() then
			self.artilleryModeEnabled = false;
			self.artilleryPos = nil;

			if MovableMan:ValidMO(self.viewpointHandlerParticle) then
				self.viewpointHandlerParticle.ToDelete = true;
			end
			
			self.textTimer:Reset();
			self.textDelay = 3000;
			if not self.parent:IsPlayerControlled() or UInputMan:KeyPressed(8) then
				self.textToDisplay = "ARTILLERY CANCELLED";
			else
				self.textToDisplay = "MOVED TOO FAR!";
			end
			
			self.viewpointHandlerParticle = nil;
		elseif not self.artilleryPos then
			if self:IsActivated() then
				self.artilleryConfirmSound:Play(self.Pos);
				self.textTimer:Reset();
				self.textDelay = 10000;
				self.textToDisplay = "FIRE!";
				self.antiFireHold = true;
				self.artilleryPos = self.parent.ViewPoint.X;
				if MovableMan:ValidMO(self.viewpointHandlerParticle) then
					self.viewpointHandlerParticle.ToDelete = true;
					self.viewpointHandlerParticle = nil;
				end
			end
		end
	end
	
	if self.shotExists then
		if self:NumberValueExists("Shot Exited Map") then
			self.shotExists = false;
			if self.artilleryEndText then
				self.artilleryEndText = false;
				self.textTimer:Reset();
				self.textDelay = 5000;
				self.textToDisplay = "STAND BY FOR IMPACT";
				self.artilleryPos = nil;
			end
		elseif self:NumberValueExists("Shot Expired") then
			self.shotExists = false;
			if self.artilleryEndText then
				self.artilleryEndText = false;
				self.textTimer:Reset();
				self.textDelay = 5000;
				self.textToDisplay = "ARTILLERY TENDS TO BE FIRED INTO THE SKY";
				self.artilleryPos = nil;
			end
		end
	end
	
	self:RemoveNumberValue("Shot Expired");
	self:RemoveNumberValue("Shot Exited Map");
	
	if not self.textTimer:IsPastSimMS(self.textDelay) and self.textToDisplay then
		local ctrl = self.parent:GetController();
		local screen = ActivityMan:GetActivity():ScreenOfPlayer(ctrl.Player);
		local pos = self.parent.AboveHUDPos + Vector(0, 35)
		PrimitiveMan:DrawTextPrimitive(screen, pos, self.textToDisplay, true, 1)
	elseif self.artilleryPos then
		self.artilleryPos = nil;
		self.artilleryModeEnabled = false;
		self.textTimer:Reset();
		self.textDelay = 3000;
		self.textToDisplay = "CALCULATION EXPIRED...";
	end
	
	local fire = self.shoveTimer:IsPastSimMS(self.shoveCooldown) and self:IsActivated() and self.RoundInMagCount > 0;

	if self.parent and self.delayedFirstShot == true then
		if self.RoundInMagCount > 0 then
			self:Deactivate()
		end
		
		if fire and self.antiFireHold then
			fire = false;
		elseif self.artilleryPos or self.artilleryModeEnabled ~= true then
			self.antiFireHold = false;
		end
		
		if fire and not self:IsReloading() then
			if not self.Magazine or self.Magazine.RoundCount < 1 then
				--self:Reload()
				self:Activate()
			elseif not self.activated and not self.delayedFire and self.fireDelayTimer:IsPastSimMS(1 / (self.RateOfFire / 60) * 1000) then
				self.activated = true
				
				self.bassPreSound:Play(self.Pos);
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
	
	self.SharpLength = self.originalSharpLength * math.sin((1 + math.pow(math.min(self.FireTimer.ElapsedSimTimeMS / 1500, 1), 2.0) * 0.5) * math.pi) * -1
	
	local recoilFactor = math.pow(math.min(self.FireTimer.ElapsedSimTimeMS / (300 * 4), 1), 2.0)
	self.rotationTarget = math.sin(recoilFactor * math.pi) * 13
	
	if self.FiredFrame then
	
		self.heatNum = self.heatNum + 200;
	
		self.FireTimer:Reset();
	
		local shot = CreateMOSRotating("Duford155 Shot", "Massive.rte");
		shot.Pos = self.MuzzlePos;
		shot.Vel = self.Vel + Vector(200 * self.FlipFactor,0):RadRotate(self.RotAngle);
		shot.Team = self.Team;
		shot.IgnoresTeamHits = true;
		shot.Sharpness = self.UniqueID;
		self.shotExists = true;
		if self.artilleryPos then
			self.textTimer:Reset();
			self.textDelay = 12000;
			self.textToDisplay = "...";
			ToMOSRotating(shot):SetNumberValue("PosX", self.artilleryPos);
			self.artilleryPos = nil;
			self.artilleryModeEnabled = false;
			self.artilleryEndText = true;
		end
		MovableMan:AddParticle(shot);
		
		-- Ground Smoke
		local maxi = 15
		for i = 1, maxi do
			
			local effect = CreateMOSRotating("Ground Smoke Particle Large Massive", "Massive.rte")
			effect.Pos = self.MuzzlePos + Vector(RangeRand(-1,1), RangeRand(-1,1)) * 3
			effect.Vel = self.Vel + Vector(math.random(90,150),0):RadRotate(math.pi * 2 / maxi * i + RangeRand(-2,2) / maxi)
			effect.Lifetime = effect.Lifetime * RangeRand(0.5,2.0)
			effect.AirResistance = effect.AirResistance * RangeRand(0.5,0.8)
			MovableMan:AddParticle(effect)
		end

		local xSpread = 0
		
		local smokeAmount = 45
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
		shakenessParticle.Mass = 60;
		shakenessParticle.Lifetime = 1000;
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
			self.bassOutdoorsSound:Play(self.Pos);
			self.boomOutdoorsSound:Play(self.Pos);
			self.boomOutdoorsDistantSound:Play(self.Pos);
			self.boomOutdoorsFarSound:Play(self.Pos);
		else
			self.bassIndoorsSound:Play(self.Pos);
			self.boomIndoorsSound:Play(self.Pos);
			self.reflectionIndoorsSound:Play(self.Pos);
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
	
		if not self:IsReloading() and self.shoveTimer:IsPastSimMS(self.shoveCooldown) and self.parent:IsPlayerControlled() and UInputMan:KeyPressed(22) then
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
		
		-- local jointOffset = Vector(self.JointOffset.X * self.FlipFactor, self.JointOffset.Y):RadRotate(self.RotAngle);
		-- local offsetTotal = Vector(jointOffset.X, jointOffset.Y):RadRotate(-total) - jointOffset
		-- self.Pos = self.Pos + offsetTotal;
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

	self.Frame = self.Loaded and 19 or self.Opened and 11 or 0

	self.artilleryModeEnabled = false;
	self.artilleryPos = nil;

	if MovableMan:ValidMO(self.viewpointHandlerParticle) then
		self.viewpointHandlerParticle.ToDelete = true;
	end
	
	self.viewpointHandlerParticle = nil;

	self.delayedFirstShot = true;
	self:DisableScript("Massive.rte/Devices/Weapons/Handheld/Duford155/Duford155.lua");

end

function OnDestroy(self)

	self.shoveStart = false;
	self.shoving = false;

	self.artilleryModeEnabled = false;
	self.artilleryPos = nil;

	if MovablerMan:ValidMO(self.viewpointHandlerParticle) then
		self.viewpointHandlerParticle.ToDelete = true;
	end
	
end