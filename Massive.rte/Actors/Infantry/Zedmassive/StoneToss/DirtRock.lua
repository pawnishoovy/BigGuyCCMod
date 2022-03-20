
-- uses heavily pared down melee system
-- i mean, if it's also a full-fledged animating and cqc damage system... why not?

-- virtually identical to rock, just less damage

function playAttackAnimation(self, animation)
	self.attackAnimationIsPlaying = true
	self.currentAttackStart = false;
	self.currentAttackSequence = 1
	self.currentAttackAnimation = animation
	self.attackAnimationTimer:Reset()
	
	return
end

function Explode(self)
	if not self.explode then return end
	self.explode = false
	
	local shakenessParticle = CreateMOPixel("Shakeness Particle Massive", "Massive.rte");
	shakenessParticle.Pos = self.Pos;
	shakenessParticle.Mass = 35;
	shakenessParticle.Lifetime = 1000;
	MovableMan:AddParticle(shakenessParticle);
	
	self:GibThis();
	
	local smokeAmount = 20
	local smokeLingering = 5
	
	if self.Vel.Magnitude > 13 or self.enoughForce then
		smokeAmount = 40;
		smokeLingering = 30
		self.explodeSound:Play(self.Pos);
		local airBlast = CreateMOPixel("Air Blast Scripted Rock StoneToss", "Massive.rte");
		airBlast.Pos = self.Pos;
		airBlast.Mass = math.min(self.Vel.Magnitude * 150, 200);
		MovableMan:AddParticle(airBlast);
	end

	local particleSpread = 25

	local smokeVelocity = (1 + math.sqrt(smokeAmount / 8) ) * 0.5
	
	for i = 1, math.ceil(smokeAmount / (math.random(4,6))) do
		local spread = (math.pi * 2) * RangeRand(-1, 1) * 0.05
		local velocity = 110 * RangeRand(0.1, 0.9) * 0.4;
		
		local particle = CreateMOSParticle((math.random() * particleSpread) < 6.5 and "Tiny Smoke Ball 1" or "Small Smoke Ball 1");
		particle.Pos = self.Pos
		particle.Vel = self.Vel + Vector(velocity * self.FlipFactor,0):RadRotate(self.RotAngle + spread) * smokeVelocity
		particle.Lifetime = particle.Lifetime * RangeRand(0.9, 1.6) * 0.3 * smokeLingering
		particle.AirThreshold = particle.AirThreshold * 0.5
		particle.GlobalAccScalar = 0
		MovableMan:AddParticle(particle);
	end
	
	for i = 1, 50 do
		local spread = (math.pi * 2) * RangeRand(-1, 1)
		local velocity = 30 * RangeRand(0.1, 0.9) * 0.4;
		
		local particle = CreateMOSParticle("Tiny Smoke Ball 1");
		particle.Pos = self.Pos
		particle.Vel = self.Vel + Vector(velocity * self.FlipFactor,0):RadRotate(spread) * (50 * 0.2)
		particle.Lifetime = particle.Lifetime * RangeRand(0.9, 1.6) * 0.9 * 25
		particle.AirThreshold = particle.AirThreshold * 0.5
		particle.GlobalAccScalar = -0.0001
		MovableMan:AddParticle(particle);
	end	
	
	for i = 1, math.ceil(smokeAmount / (math.random(4,6))) do
		local vel = Vector(110 ,0):RadRotate(self.RotAngle)
		
		local particle = CreateMOSParticle("Tiny Smoke Ball 1");
		particle.Pos = self.Pos
		-- oh LORD
		particle.Vel = self.Vel + ((Vector(vel.X, vel.Y):RadRotate((math.pi * 2) * (math.random(0,1) * 2.0 - 1.0) * 0.5 + (math.pi * 2) * RangeRand(-1, 1) * 0.15) * RangeRand(0.1, 0.9) * 0.3 + Vector(vel.X, vel.Y):RadRotate((math.pi * 2) * RangeRand(-1, 1) * 0.15) * RangeRand(0.1, 0.9) * 0.2) * 0.5) * smokeVelocity;
		-- have mercy
		particle.Lifetime = particle.Lifetime * RangeRand(0.9, 1.6) * 0.3 * smokeLingering
		particle.AirThreshold = particle.AirThreshold * 0.5
		particle.GlobalAccScalar = 0
		MovableMan:AddParticle(particle);
	end
	
	for i = 1, math.ceil(smokeAmount / (math.random(5,10) * 0.5)) do
		local spread = (math.pi * 2) * RangeRand(-1, 1)
		local velocity = 110 * 0.6 * RangeRand(0.9,1.1)
		
		local particle = CreateMOSParticle("Flame Smoke 1 Micro")
		particle.Pos = self.Pos
		particle.Vel = self.Vel + Vector(velocity ,0):RadRotate(self.RotAngle + spread) * smokeVelocity
		particle.Team = self.Team
		particle.Lifetime = particle.Lifetime * RangeRand(0.9,1.2) * 0.75 * smokeLingering
		particle.AirResistance = particle.AirResistance * 2.5 * RangeRand(0.9,1.1)
		particle.IgnoresTeamHits = true
		particle.AirThreshold = particle.AirThreshold * 0.5
		particle.GlobalAccScalar = 0
		MovableMan:AddParticle(particle);
	end	

end

function Create(self)
	self.explode = true
	self.soundFlyLoop = CreateSoundContainer("FlightLoop Rock StoneToss", "Massive.rte");
	--self.originalPitch = math.random(8, 12) / 100;
	--self.soundFlyLoop:Play(self.Pos);
	
	self.HitsMOs = false; -- avoid hitting ourselves
	--self.hitTimer = Timer();
	
	self.lastPos = Vector(self.Pos.X, self.Pos.Y)
	self.launchVector = Vector()

	self.explodeSound = CreateSoundContainer("Dirt Impact Rock StoneToss", "Massive.rte");
	
	self.flying = false
	
	
	self.originalStanceOffset = Vector(self.StanceOffset.X * self.FlipFactor, self.StanceOffset.Y)
	
	self.attackAnimations = {}
	self.attackAnimationCanHit = false
	self.attackAnimationTimer = Timer();
	
	self.currentAttackAnimation = 0;
	self.currentAttackSequence = 0;
	self.currentAttackStart = false
	self.attackAnimationIsPlaying = false
	
	local attackPhase
	local regularAttackSounds = {}
	local i
	
	-- Throw
	throwPhase = {}
	
	-- Windup
	i = 1
	throwPhase[i] = {}
	throwPhase[i].durationMS = 1200
	throwPhase[i].angleStart = 0
	throwPhase[i].angleEnd = 120
	throwPhase[i].offsetStart = Vector(0, 0)
	throwPhase[i].offsetEnd = Vector(-15, -15)

	
	-- Pause
	i = 2
	throwPhase[i] = {}
	throwPhase[i].lastPrepare = true;
	throwPhase[i].durationMS = 400
	throwPhase[i].angleStart = 120
	throwPhase[i].angleEnd = 120
	throwPhase[i].offsetStart = Vector(-15, -15)
	throwPhase[i].offsetEnd = Vector(-15, -15)
	throwPhase[i].soundStart = CreateSoundContainer("Throw Rock StoneToss", "Massive.rte");
	throwPhase[i].soundStartVariations = 0
	
	
	-- Throw
	i = 3
	throwPhase[i] = {}
	throwPhase[i].durationMS = 230
	throwPhase[i].angleStart = 120
	throwPhase[i].angleEnd = -90
	throwPhase[i].offsetStart = Vector(-15, -15)
	throwPhase[i].offsetEnd = Vector(15, -8)
	
	-- Add the animation to the animation table
	self.attackAnimations[1] = throwPhase
	
	-- smash
	smashPhase = {}
	
	-- Windup
	i = 1
	smashPhase[i] = {}
	smashPhase[i].durationMS = 1200
	smashPhase[i].angleStart = 0
	smashPhase[i].angleEnd = 120
	smashPhase[i].offsetStart = Vector(0, 0)
	smashPhase[i].offsetEnd = Vector(-15, -15)

	
	-- Pause
	i = 2
	smashPhase[i] = {}
	smashPhase[i].durationMS = 400
	smashPhase[i].angleStart = 120
	smashPhase[i].angleEnd = 120
	smashPhase[i].offsetStart = Vector(-15, -15)
	smashPhase[i].offsetEnd = Vector(-15, -15)
	
	
	-- smash
	i = 3
	smashPhase[i] = {}
	smashPhase[i].attackPhase = true
	smashPhase[i].durationMS = 250
	smashPhase[i].angleStart = 120
	smashPhase[i].angleEnd = -90
	smashPhase[i].offsetStart = Vector(-10, -15)
	smashPhase[i].offsetEnd = Vector(15, 25)

	
	self.attackAnimations[2] = smashPhase
	
	-- Equip anim
	equipPhase = {}
	
	-- Out
	i = 1
	equipPhase[i] = {}
	equipPhase[i].durationMS = 500
	equipPhase[i].angleStart = 0
	equipPhase[i].angleEnd = 0
	equipPhase[i].offsetStart = Vector(15, 0)
	equipPhase[i].offsetEnd = Vector(0, -15)
	
	-- Upright
	i = 2
	equipPhase[i] = {}
	equipPhase[i].durationMS = 450
	equipPhase[i].angleStart = 0
	equipPhase[i].angleEnd = 15
	equipPhase[i].offsetStart = Vector(0, -15)
	equipPhase[i].offsetEnd = Vector(-2, -17)
	
	-- Stance
	i = 3
	equipPhase[i] = {}
	equipPhase[i].durationMS = 600
	equipPhase[i].angleStart = 15
	equipPhase[i].angleEnd = 0
	equipPhase[i].offsetStart = Vector(-2, -17)
	equipPhase[i].offsetEnd = Vector(8, 6)
	
	-- Add the animation to the animation table
	self.attackAnimations[3] = equipPhase

	self.rotation = 0
	self.rotationInterpolation = 1 -- 0 instant, 1 smooth, 2 wiggly smooth
	self.rotationInterpolationSpeed = 25
	
	self.stance = Vector(0, 0)
	self.stanceInterpolation = 0 -- 0 instant, 1 smooth
	self.stanceInterpolationSpeed = 25	
	
	playAttackAnimation(self, 3)
	
end

function OnDetach(self)
	if not self.Throwing == true then return end
	self.flying = true
	
	self.AngularVel = RangeRand(-1, 1)
	
	self.originalPitch = math.random(8, 12) / 100;
	self.soundFlyLoop:Play(self.Pos);
	
	--self.HitsMOs = false; -- avoid hitting ourselves
	--self.hitTimer = Timer();
	
	self.HitsMOs = true
end

function Update(self)

	local act = self:GetRootParent();
	local actor = IsAHuman(act) and ToAHuman(act) or nil;
	local player = false
	local controller = nil
	if actor then
		--ToActor(actor):GetController():SetState(Controller.WEAPON_RELOAD,false);
		controller = actor:GetController();
		controller:SetState(Controller.AIM_SHARP,false);
		self.parent = actor;
		if actor:IsPlayerControlled() then
			player = true
		end
	end
	
	if controller then

		local attacked = false
		
		-- if player then -- PLAYER INPUT
			-- charge = (self:IsActivated() and not self.isCharged) or (self.isCharging and not self.isCharged)
		-- else -- AI
		local activated = self:IsActivated();
		attacked = activated and not self.attackAnimationIsPlaying
		if attacked then
		
			self.chargeDecided = false;
			playAttackAnimation(self, 1)
		end
		
		-- ANIMATION PLAYER
		local stanceTarget = Vector(0, 0)
		local rotationTarget = 0

		if self.attackAnimationIsPlaying and currentAttackAnimation ~= 0 then -- play the animation
		
			self.rotationInterpolationSpeed = 25;
		
			local animation = self.currentAttackAnimation
			local attackPhases = self.attackAnimations[animation]
			local currentPhase = attackPhases[self.currentAttackSequence]
			
			if self.equipFinished and self.currentAttackSequence == 3 and self.currentAttackAnimation == 1 then self.Throwing = true end

			local nextPhase = attackPhases[self.currentAttackSequence + 1]
			
			if self.equipFinished and self.chargeDecided == false and nextPhase and currentPhase.lastPrepare == true then
				self.chargeDecided = true;
				if activated then
					self.parent:SetNumberValue("Massive MASSIVE Stone Throw", 1);
					
					-- local shakenessParticle = CreateMOPixel("Shakeness Particle Massive", "Massive.rte");
					-- shakenessParticle.Pos = self.Pos;
					-- shakenessParticle.Mass = 4;
					-- shakenessParticle.Lifetime = 500;
					-- MovableMan:AddParticle(shakenessParticle);							
					
					self.wasCharged = true;
					self.currentAttackAnimation = 2; -- ought to seamlessly transfer to smashing it
				else	
					self.parent:SetNumberValue("Massive Stone Throw", 1);
				end
				
			end
				
			local factor = self.attackAnimationTimer.ElapsedSimTimeMS / currentPhase.durationMS
			if factor > 1 then
				factor = 1;
			end
			
			if currentPhase.attackPhase == true then
				self.attackAnimationCanHit = true;
			end
			
			rotationTarget = rotationTarget + (currentPhase.angleStart * (1 - factor) + currentPhase.angleEnd * factor) / 180 * math.pi -- interpolate rotation
			stanceTarget = stanceTarget + (currentPhase.offsetStart * (1 - factor) + currentPhase.offsetEnd * factor) -- interpolate stance offset
			
			if not self.currentAttackStart then -- Start of the sequence
				if currentPhase.soundStart then
					self.currentAttackStart = true
					currentPhase.soundStart:Play(self.Pos);
				end
			end
			
			local workingDuration = currentPhase.durationMS
			
			if self.attackAnimationTimer:IsPastSimMS(workingDuration) then
				if (self.currentAttackSequence+1) <= #attackPhases then
					self.currentAttackSequence = self.currentAttackSequence + 1
				else
					self.currentAttackAnimation = 0
					self.currentAttackSequence = 0
					self.attackAnimationIsPlaying = false
					if self.equipFinished then
						
						if self.wasCharged == true then
							self:GetParent():RemoveAttachable(self, true, false);
							-- being thrown downwards (uh oh)
							self.Vel = self.parent.Vel + Vector((10)*self.FlipFactor, 10):RadRotate(self.RotAngle);
							
						else
							self:GetParent():RemoveAttachable(self, true, false);
							self.Vel = self.parent.Vel + Vector((25)*self.FlipFactor, 0):RadRotate(self.RotAngle);
						end
					end
					self.equipFinished = true;
				end
				self.attackAnimationTimer:Reset();
			end
		end
	
		if self.stanceInterpolation == 0 then
			self.stance = stanceTarget
		elseif self.stanceInterpolation == 1 then
			self.stance = (self.stance + stanceTarget * TimerMan.DeltaTimeSecs * self.stanceInterpolationSpeed) / (1 + TimerMan.DeltaTimeSecs * self.stanceInterpolationSpeed);
		end
		
		rotationTarget = rotationTarget * self.FlipFactor
		if self.rotationInterpolation == 0 then
			self.rotation = rotationTarget
		elseif self.rotationInterpolation == 1 then
			self.rotation = (self.rotation + rotationTarget * TimerMan.DeltaTimeSecs * self.rotationInterpolationSpeed) / (1 + TimerMan.DeltaTimeSecs * self.rotationInterpolationSpeed);
		end
		local pushVector = Vector(10 * self.FlipFactor, 0):RadRotate(self.RotAngle)
		
		self.StanceOffset = self.originalStanceOffset + self.stance
		--self.InheritedRotAngleOffset = self.rotation
		self.RotAngle = self.RotAngle + self.rotation
		
		local jointOffset = Vector(self.JointOffset.X * self.FlipFactor, self.JointOffset.Y):RadRotate(self.RotAngle);
		self.Pos = self.Pos - jointOffset + Vector(jointOffset.X, jointOffset.Y):RadRotate(-self.rotation);
		
		-- COLLISION DETECTION
		
		--self.attackAnimationsSounds[1]
		if self.attackAnimationCanHit then -- Detect collision
			--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + attackOffset,  13);
			local hit = false
			local team = 0
			if actor then team = actor.Team end
			local rayVec = Vector(16 * self.FlipFactor, 0):RadRotate(self.RotAngle):DegRotate(-45*self.FlipFactor)--damageVector:RadRotate(self.RotAngle) * Vector(self.FlipFactor, 1)
			local rayOrigin = Vector(self.Pos.X, self.Pos.Y) + Vector(0 * self.FlipFactor, 0):RadRotate(self.RotAngle)
			
			--PrimitiveMan:DrawLinePrimitive(rayOrigin, rayOrigin + rayVec,  5);
			--PrimitiveMan:DrawCirclePrimitive(self.Pos, 3, 5);
			
			local moCheck = SceneMan:CastMORay(rayOrigin, rayVec, self.IDToIgnore or self.ID, self.Team, 0, false, 2); -- Raycast
			if not (moCheck and moCheck ~= rte.NoMOID) then
				-- Dual Ray Technology or something
				rayVec = Vector(16 * self.FlipFactor, 0):RadRotate(self.RotAngle):DegRotate(25*self.FlipFactor)--damageVector:RadRotate(self.RotAngle) * Vector(self.FlipFactor, 1)
				rayOrigin = Vector(self.Pos.X, self.Pos.Y) + Vector(0 * self.FlipFactor, 0):RadRotate(self.RotAngle)
				moCheck = SceneMan:CastMORay(rayOrigin, rayVec, self.IDToIgnore or self.ID, self.Team, 0, false, 2); -- Raycast
				--PrimitiveMan:DrawLinePrimitive(rayOrigin, rayOrigin + rayVec,  5);
			end
			if moCheck and moCheck ~= rte.NoMOID then
				local rayHitPos = SceneMan:GetLastRayHitPos()
				local MO = MovableMan:GetMOFromID(moCheck)
				if IsMOSRotating(MO) then
					MO = ToMOSRotating(MO)
					hit = true
					local woundName = MO:GetEntryWoundPresetName()
					local woundNameExit = MO:GetExitWoundPresetName()
					local woundOffset = (rayHitPos - MO.Pos):RadRotate(MO.RotAngle * -1.0)
					local gibbed = false;
					if MO.Mass < 100 then
						MO:GibThis();
						gibbed = true
					end
					if gibbed == false and woundName ~= nil and woundName ~= "" then -- generic wound adding
						for i = 1, 25 do
							MO:AddWound(CreateAEmitter(woundName), woundOffset, true)
						end
					end
				end
			else
				local terrCheck = SceneMan:CastMaxStrengthRay(rayOrigin, rayOrigin + rayVec, 2); -- Raycast
				if terrCheck > 5 then									
					hit = true
				end
			end
			
			if hit then
				self.explodeSound:Play(self.Pos);
				self:GibThis();
				-- self.explode = true;
				-- self.enoughForce = true;
				-- Explode(self);
			end
		end
	end
	
	if not self.flying then return end
	
	self.ToSettle = false
	
	self.soundFlyLoop.Pos = self.Pos
	
	self.soundFlyLoop.Volume = math.min(self.Vel.Magnitude / 2, 50) + 0.10;
	self.soundFlyLoop.Pitch = (self.Vel.Magnitude / 35) + self.originalPitch;
	
	-- if self.hitTimer:IsPastSimMS(50) then
		-- self.HitsMOs = true;
	-- end
	
end

function OnCollideWithTerrain(self, terrainID)
	if self.Throwing == true and self.Vel.Magnitude > 13 then
		Explode(self)
		self.enoughForce = true;
	end
end

function OnCollideWithMO(self, MO, rootMO)
	if not self:GetRootParent() == self then return end
	if MO.Team == self.Team then
		self:GibThis();
		return
	end
	if MO and MO.Mass < 60 then
		MO:GibThis();
	end
	if self.Vel.Magnitude > 13 then
		Explode(self)
		if rootMO and rootMO.UniqueID ~= MO.UniqueID then
			rootMO:GibThis();
		end
		self.enoughForce = true;
	end
end

function Destroy(self)
	self.soundFlyLoop:Stop(-1);
end