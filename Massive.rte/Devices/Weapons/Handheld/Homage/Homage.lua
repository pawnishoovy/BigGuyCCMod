function Create(self)

	self.TheViolence = CreateSoundContainer("Brewing Homage", "Massive.rte");
	self.TheViolence.Volume = 0;
	self.IsEscalating = CreateSoundContainer("Storm Homage", "Massive.rte");
	self.IsEscalating.Immobile = true;
	
	self.noiseOutdoorsSound = CreateSoundContainer("Noise Outdoors Homage", "Massive.rte");
	self.noiseIndoorsSound = CreateSoundContainer("Noise Indoors Homage", "Massive.rte");
	
	self.reloadPrepareSounds = {}
	self.reloadPrepareSounds.Open = CreateSoundContainer("OpenPrepare Homage", "Massive.rte");
	self.reloadPrepareSounds.Close = CreateSoundContainer("ClosePrepare Homage", "Massive.rte");
	
	self.reloadPrepareLengths = {}
	self.reloadPrepareLengths.Open = 135
	self.reloadPrepareLengths.ShellsIn = 0
	self.reloadPrepareLengths.Close = 145
	
	self.reloadPrepareDelay = {}
	self.reloadPrepareDelay.Open = 480
	self.reloadPrepareDelay.ShellsIn = 200
	self.reloadPrepareDelay.Close = 270
	
	self.reloadAfterSounds = {}
	self.reloadAfterSounds.Open = CreateSoundContainer("Open Homage", "Massive.rte");
	self.reloadAfterSounds.ShellsIn = CreateSoundContainer("ShellsIn Homage", "Massive.rte");
	self.reloadAfterSounds.Close = CreateSoundContainer("Close Homage", "Massive.rte");
	
	self.reloadAfterDelay = {}
	self.reloadAfterDelay.Open = 150
	self.reloadAfterDelay.ShellsIn = 200
	self.reloadAfterDelay.Close = 300
	
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
	
	self.satisfyingVolume = -0.5;

end

function Update(self)

	self.TheViolence.Pos = self.Pos;
	self.TheViolence.Volume = math.max(0, self.satisfyingVolume);
	self.IsEscalating.Volume = math.max(0, self.satisfyingVolume);

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
	
	if self:IsReloading() then
	
		if self.parent and self.reloadPhase > 0 then
			self.parent:GetController():SetState(Controller.AIM_SHARP,false);
		end

			
		if self.reloadPhase == 0 then
			self.reloadDelay = self.reloadPrepareDelay.Open;
			self.afterDelay = self.reloadAfterDelay.Open;		
			
			self.prepareSound = self.reloadPrepareSounds.Open;
			self.prepareSoundLength = self.reloadPrepareLengths.Open;
			self.afterSound = self.reloadAfterSounds.Open;
			
			self.rotationTarget = -5;
			
		elseif self.reloadPhase == 1 then
			self.reloadDelay = self.reloadPrepareDelay.ShellsIn;
			self.afterDelay = self.reloadAfterDelay.ShellsIn;		
			
			self.prepareSound = nil;
			self.prepareSoundLength = self.reloadPrepareLengths.ShellsIn;
			self.afterSound = self.reloadAfterSounds.ShellsIn;
			
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
			
				if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.3)) then
					self.Frame = 3;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.1)) then
					self.Frame = 2;
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*0.8)) then
					self.Frame = 1;	
				end
			
			elseif self.reloadPhase == 1 then
			
				
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
				
					 for i = 1, 2 do
						 local fake
						 shell = CreateAEmitter("Shell Homage", "Massive.rte");
						 shell.Pos = self.Pos + Vector(-2 * self.FlipFactor, 0):RadRotate(self.RotAngle);
						 shell.Vel = self.Vel + Vector(-1.5*self.FlipFactor, -6):RadRotate(self.RotAngle + math.rad(5) * RangeRand(-1, 1)) * RangeRand(0.8,1.2);
						 shell.RotAngle = self.RotAngle;
						 shell.AngularVel = self.AngularVel + (-1*self.FlipFactor);
						 shell.HFlipped = self.HFlipped;
						 MovableMan:AddParticle(shell);
					 end
					 
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
				if self.reloadPhase == 2 then
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
		
		if self.phaseOnStop then
			self.reloadPhase = self.phaseOnStop;
			self.phaseOnStop = nil;
		end
		
		self.reloadTimer:Reset();
		self.prepareSoundPlayed = false;
		self.afterSoundPlayed = false;
		self.ReloadTime = 5000;
	end
	
	self.SharpLength = self.originalSharpLength * (0.9 + math.pow(math.min(self.FireTimer.ElapsedSimTimeMS / 500, 1), 2.0) * 0.5)
	
	if self.FiredFrame then
	
		if self.Magazine then self.Magazine.RoundCount = 0 end
	
		local shot = CreateMOPixel("Pellet Homage Scripted", "Massive.rte");
		shot.Pos = self.MuzzlePos;
		shot.Vel = self.Vel + Vector(160 * self.FlipFactor, 0):RadRotate(self.RotAngle);
		shot.Lifetime = shot.Lifetime * math.random(0.8, 1.2);
		shot.Team = self.Team;
		shot.IgnoresTeamHits = true;
		MovableMan:AddParticle(shot);	
	
		self.FireTimer:Reset();
		
		self.angVel = self.angVel + RangeRand(0.7,1.1) * -15
		
		local shakenessParticle = CreateMOPixel("Shakeness Particle Glow Massive", "Massive.rte");
		shakenessParticle.Pos = self.MuzzlePos;
		shakenessParticle.Mass = 20 + (20 * self.satisfyingVolume);
		shakenessParticle.Lifetime = 500;
		MovableMan:AddParticle(shakenessParticle);
		
		if AudioMan.MusicVolume == 0 then
			self.satisfyingVolume = math.min(1, self.satisfyingVolume + 0.055);
		end
		
		if self.satisfyingVolume > 0 and self.itHasEscalated ~= true then
			self.itHasEscalated = true;
			self.TheViolence:Play(self.Pos);
		elseif self.satisfyingVolume < 0 then
			self.itHasEscalated = false;
			self.itHasBloomed = false;
			self.TheViolence:Stop(-1);
			self.IsEscalating:Stop(-1);
		end
		
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
	
	if self.satisfyingVolume > -0.5 then
		self.satisfyingVolume = self.satisfyingVolume - (self.itHasBloomed and 0.006 or 0.01) * TimerMan.DeltaTimeSecs;
		if self.satisfyingVolume < -0.5 then
			self.satisfyingVolume = -0.5;
		end
	end

	if self.parent then
	
		if self.parent:NumberValueExists("Warcried") and self.satisfyingVolume > 0.95 and self.itHasBloomed ~= true then
			self.itHasBloomed = true;
			self.TheViolence:FadeOut(100);
			self.IsEscalating:Play(self.Pos);
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
		
		if not self.parent:IsPlayerControlled() then
			self.itHasBloomed = false;
			self.itHasEscalated = false;
			self.TheViolence:Stop(-1);
			self.IsEscalating:Stop(-1);
			self.satisfyingVolume = math.min(self.satisfyingVolume, 0);
		end
	end


end

function OnDetach(self)

	self.itHasEscalated = false;
	self.itHasBloomed = false;
	self.TheViolence.Volume = 0;
	self.IsEscalating.Volume = 0;
	self.TheViolence:Stop(-1);
	self.IsEscalating:Stop(-1);
	self:DisableScript("Massive.rte/Devices/Weapons/Handheld/Homage/Homage.lua");

end