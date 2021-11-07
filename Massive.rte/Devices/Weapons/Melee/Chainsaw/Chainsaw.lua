function OnAttach(self)

	if self:GetRootParent() and self:GetRootParent().PresetName == "Massive" or self:GetRootParent().PresetName == "Zedmassive" then
		self.equippedByMassive = true;
	else
		self.equippedByMassive = false;
	end
	
end

function Create(self)

	if self:GetRootParent() and self:GetRootParent().PresetName == "Massive" or self:GetRootParent().PresetName == "Zedmassive" then
		self.equippedByMassive = true;
	else
		self.equippedByMassive = false;
	end

	self.Frame = 1;

	self.rotFactor = 0;
	self.lastAngle = 0;
	self.origFireRate = self.RateOfFire;
	self.origParticleSpread = self.ParticleSpreadRange;

	self.fired = false;

	self.activated = false;
	
	self.dismemberStrength = 500;
	self.length = ToMOSprite(self):GetSpriteWidth();
	
	self.brutalDieSound = CreateSoundContainer("Brutal Die Massive Chainsaw", "Massive.rte");
	self.brutalFirstRevSound = CreateSoundContainer("Brutal First Rev Massive Chainsaw", "Massive.rte");
	--self.brutalHighLoopSound = CreateSoundContainer("Brutal High Loop Massive Chainsaw", "Massive.rte");
	--self.brutalHighLoopVolumeTarget = 0;
	--self.brutalHighLoopSound.Volume = 0;
	--self.brutalHighLoopSound:Play(self.Pos);
	self.brutalIdleSound = CreateSoundContainer("Brutal Idle Massive Chainsaw", "Massive.rte");
	self.brutalIdleVolumeTarget = 0;
	self.brutalIdleSound.Volume = 0;
	self.brutalIdleSound:Play(self.Pos);
	self.brutalRevDownSound = CreateSoundContainer("Brutal Rev Down Massive Chainsaw", "Massive.rte");
	self.brutalRevUpSound = CreateSoundContainer("Brutal Rev Up Massive Chainsaw", "Massive.rte");
	self.brutalStartOneSound = CreateSoundContainer("Brutal Start One Massive Chainsaw", "Massive.rte");
	self.revUpOneShotSound = CreateSoundContainer("Brutal Rev Up One Shot Massive Chainsaw", "Massive.rte");
	self.startTwoSound = CreateSoundContainer("Brutal Start Two Massive Chainsaw", "Massive.rte");
	
	self.rotation = 0
	self.rotationTarget = 0
	self.rotationSpeed = 9

	self.angVel = 0
	
	self.antiOPTimer = Timer();
	
	self.turnOnTimer = Timer();
	
	self.startTimer = Timer();
	self.Starts = 0;
	self.startsRequired = math.random(1, 4);

end
function Update(self)

	self.rotationTarget = 0;
	self.angVel = 0;

	self.brutalDieSound.Pos = self.Pos;
	self.brutalFirstRevSound.Pos = self.Pos;
	--self.brutalHighLoopSound.Pos = self.Pos;
	--if not self.brutalHighLoopSound:IsBeingPlayed() then
	--	self.brutalHighLoopSound:Play(self.Pos);
	--end
	self.brutalIdleSound.Pos = self.Pos;
	if not self.brutalIdleSound:IsBeingPlayed() then
		self.brutalIdleSound:Play(self.Pos);
	end
	self.brutalRevDownSound.Pos = self.Pos;
	self.brutalRevUpSound.Pos = self.Pos;
	self.brutalStartOneSound.Pos = self.Pos;
	self.revUpOneShotSound.Pos = self.Pos;
	self.startTwoSound.Pos = self.Pos;
	
	local turn = math.abs(self.AngularVel);

	if self.turnedOn == true and self.turnOnTimer:IsPastSimMS(500) then
	
		self:SetNumberValue("Turned On", 1);
	
		self.angVel = math.random(-1, 1);
	
		local smokeAmount = 2
		local particleSpread = 1
		
		local smokeLingering = math.sqrt(smokeAmount / 8) * 1
		
		-- Muzzle main smoke
		for i = 1, math.ceil(smokeAmount / (math.random(2,4))) do
			local spread = math.pi * RangeRand(-1, 1) * 0.05
			local velocity = 60 * RangeRand(0.1, 0.9) * 0.4;
			
			local particle = CreateMOSParticle((math.random() * particleSpread) < 6.5 and "Tiny Smoke Ball 1" or "Small Smoke Ball 1");
			particle.Pos = self.Pos
			particle.Vel = self.Vel + Vector(0, velocity):RadRotate(self.RotAngle + spread)
			particle.Lifetime = particle.Lifetime * RangeRand(0.9, 1.6) * 0.3 * smokeLingering
			particle.AirThreshold = particle.AirThreshold * 0.5
			particle.GlobalAccScalar = 0
			MovableMan:AddParticle(particle);
		end	
	
		if self.turnOnTimer:IsPastSimMS(self.turnOnTime) then
		
			self.stickMO = nil;
		
			if self.shakenessParticle then
				self.shakenessParticle.ToDelete = true;
				self.shakenessParticle.Lifetime = 10;
				self.shakenessParticle = nil;
			end
			
			local shakenessParticle = CreateMOPixel("Shakeness Particle Massive", "Massive.rte");
			shakenessParticle.Pos = self.MuzzlePos;
			shakenessParticle.Mass = 40;
			shakenessParticle.Lifetime = 500;
			MovableMan:AddParticle(shakenessParticle);
		
			self.Scale = 1;
			
			self.startActivated = true;
		
			self.Starts = 0;
			self.startsRequired = math.random(1, 4);
		
			self.turnedOn = false;
			self.activated = false;
		
			self.brutalIdleVolumeTarget = 0;
			--self.brutalHighLoopVolumeTarget = 0;
			self.brutalIdleSound.Volume = 0;
			--self.brutalHighLoopSound.Volume = 0;
			self.brutalDieSound:Play(self.Pos);
			
			if self.fired == true then
				self.brutalRevUpSound:Stop(-1);
			end
		
			local smokeAmount = 20
			local particleSpread = 1
			
			local smokeLingering = math.sqrt(smokeAmount / 8) * 1
			
			-- Muzzle main smoke
			for i = 1, math.ceil(smokeAmount / (math.random(2,4))) do
				local spread = math.pi * RangeRand(-1, 1) * 0.05
				local velocity = 60 * RangeRand(0.1, 0.9) * 0.4;
				
				local particle = CreateMOSParticle((math.random() * particleSpread) < 6.5 and "Tiny Smoke Ball 1" or "Small Smoke Ball 1");
				particle.Pos = self.Pos
				particle.Vel = self.Vel + Vector(0, velocity):RadRotate(self.RotAngle + spread)
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
				particle.Vel = self.Vel + Vector(0, velocity):RadRotate(self.RotAngle + spread)
				particle.Lifetime = particle.Lifetime * RangeRand(0.9, 1.6) * 0.3 * smokeLingering
				particle.AirThreshold = particle.AirThreshold * 0.5
				particle.GlobalAccScalar = 0
				MovableMan:AddParticle(particle);
			end			
			
			
		end
				
		if self.Magazine then
			if self.activated == true then
				self.RateOfFire = self.origFireRate + 9 * (math.sqrt(turn * 100) + math.sqrt(self.Vel.Largest * 100));
				self.ParticleSpreadRange = self.origParticleSpread + 3 * (math.sqrt(turn * 100) + math.sqrt(self.Vel.Largest));
			end
			if self:IsActivated() and self.Magazine.RoundCount ~= 0 then
				self.Scale = 0;
				if self.fired ~= true then
					self.fired = true;
					self.brutalFirstRevSound:Stop(-1);
					self.brutalIdleVolumeTarget = 0;
					self.brutalRevDownSound:Stop(-1);
					self.revUpOneShotSound:Play(self.Pos);
					self.brutalRevUpSound:Play(self.Pos);
					self.antiOPTimer:Reset();
					
					local shakenessParticle = CreateMOPixel("Shakeness Particle Massive Chainsaw", "Massive.rte");
					shakenessParticle.Pos = self.Pos
					self.shakenessParticle = shakenessParticle;
					MovableMan:AddParticle(shakenessParticle);					
					
					local shakenessParticle = CreateMOPixel("Shakeness Particle Massive", "Massive.rte");
					shakenessParticle.Pos = self.MuzzlePos;
					shakenessParticle.Mass = 20;
					shakenessParticle.Lifetime = 500;
					MovableMan:AddParticle(shakenessParticle);
					
				end
				--Dismemberment: detach limbs via MO detection among other things done
				local moCheck = SceneMan:CastMORay(self.Pos, Vector(self.length * 0.5 * self.FlipFactor, 0):RadRotate(self.RotAngle), self.ID, self.Team, rte.airID, true, 2);
				--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + Vector(self.length * 0.5 * self.FlipFactor, 0):RadRotate(self.RotAngle),  5);
				if moCheck ~= rte.NoMOID then
					local mo = MovableMan:GetMOFromID(moCheck);
					if mo and IsAttachable(mo) and ToAttachable(mo):IsAttached() and not (IsHeldDevice(mo) or IsThrownDevice(mo)) then
						mo = ToAttachable(mo);
						local jointPos = mo.Pos + Vector(mo.JointOffset.X * mo.FlipFactor, mo.JointOffset.Y):RadRotate(mo.RotAngle);
						if SceneMan:ShortestDistance(self.Pos, jointPos, SceneMan.SceneWrapsX).Magnitude < 3 and math.random(self.dismemberStrength) > mo.JointStrength then
							ToMOSRotating(mo:GetParent()):RemoveAttachable(mo.UniqueID, true, true);
						end
					elseif IsAHuman(mo) and self.stickMO == nil and self.equippedByMassive == true then
						self.stickMO = mo;
						self.stickMOAngle = mo.RotAngle - self.RotAngle
					end
						
				end
				
				local stickObstructionCheckRay = SceneMan:CastStrengthSumRay(self.Pos, self.Pos + Vector(self.length * 1.0 * self.FlipFactor, 0):RadRotate(self.RotAngle), 4, 0);
				if stickObstructionCheckRay > 100 then
					self.stickMO = nil;
				end
				
				if self.stickMO and MovableMan:ValidMO(self.stickMO) then				
					self.stickMO.Vel = self.Vel;
					self.stickMO.Pos = Vector(self.Pos.X, self.Pos.Y) + Vector(20 * self.FlipFactor, 0):RadRotate(self.RotAngle)
					self.stickMO.RotAngle = self.RotAngle + self.stickMOAngle;					
				else
					self.stickMO = nil;
				end
				
				if self.shakenessParticle then
					self.shakenessParticle.Pos = self.Pos;
				end
				
				if not self.brutalRevUpSound:IsBeingPlayed() and self.turnedOn then
					self.brutalRevUpSound:Play(self.Pos);
				end
				
				if self.antiOPTimer:IsPastSimMS(10000) then
					self.turnOnTime = 0;
					--self.brutalHighLoopSound.Volume = 1;
					--self.brutalHighLoopVolumeTarget = 1;
				end
				
			elseif self.fired == true then
				self.stickMO = nil;
				if self.shakenessParticle then
					self.shakenessParticle.ToDelete = true;
					self.shakenessParticle.Lifetime = 10;
					self.shakenessParticle = nil;
				end
				self.Scale = 1;
				self.fired = false;
				--self.brutalHighLoopVolumeTarget = 0;
				self.brutalIdleVolumeTarget = 0.5;
				
				self.brutalRevUpSound:Stop(-1);
				self.brutalRevDownSound:Play(self.Pos);

				if self.Magazine.RoundCount == 0 then
					self:Reload();
				end
			end
		else
			self.activated = false;
		end
		
		-- if self.brutalHighLoopSound.Volume < self.brutalHighLoopVolumeTarget then
			-- self.brutalHighLoopSound.Volume = self.brutalHighLoopSound.Volume + 3 * TimerMan.DeltaTimeSecs;
			-- if self.brutalHighLoopSound.Volume > self.brutalHighLoopVolumeTarget then
				-- self.brutalHighLoopSound.Volume = self.brutalHighLoopVolumeTarget;
			-- end
		-- elseif self.brutalHighLoopSound.Volume > self.brutalHighLoopVolumeTarget then
			-- self.brutalHighLoopSound.Volume = self.brutalHighLoopSound.Volume - 3 * TimerMan.DeltaTimeSecs;
			-- if self.brutalHighLoopSound.Volume < self.brutalHighLoopVolumeTarget then
				-- self.brutalHighLoopSound.Volume = self.brutalHighLoopVolumeTarget;
			-- end
		-- end
		
		if self.brutalIdleSound.Volume < self.brutalIdleVolumeTarget then
			self.brutalIdleSound.Volume = self.brutalIdleSound.Volume + 3 * TimerMan.DeltaTimeSecs;
			if self.brutalIdleSound.Volume > self.brutalIdleVolumeTarget then
				self.brutalIdleSound.Volume = self.brutalIdleVolumeTarget;
			end
		elseif self.brutalIdleSound.Volume > self.brutalIdleVolumeTarget then
			self.brutalIdleSound.Volume = self.brutalIdleSound.Volume - 3 * TimerMan.DeltaTimeSecs;
			if self.brutalIdleSound.Volume < self.brutalIdleVolumeTarget then
				self.brutalIdleSound.Volume = self.brutalIdleVolumeTarget;
			end
		end
	else
		
		self:RemoveNumberValue("Turned On");
	
		self.fired = false;
	
		self.brutalIdleSound.Volume = 0;
		--self.brutalHighLoopSound.Volume = 0;
		
		if self.startActivated ~= true then
			if self:IsActivated() then
				self.startTimer:Reset();
				self.angVel = -10
				self.startActivated = true;
				if self.Starts < self.startsRequired then
					local shakenessParticle = CreateMOPixel("Shakeness Particle Massive", "Massive.rte");
					shakenessParticle.Pos = self.MuzzlePos;
					shakenessParticle.Mass = 20;
					shakenessParticle.Lifetime = 500;
					MovableMan:AddParticle(shakenessParticle);
					local smokeAmount = 20
					local particleSpread = 1
					
					local smokeLingering = math.sqrt(smokeAmount / 8) * 1
					
					-- Muzzle main smoke
					for i = 1, math.ceil(smokeAmount / (math.random(2,4))) do
						local spread = math.pi * RangeRand(-1, 1) * 0.05
						local velocity = 60 * RangeRand(0.1, 0.9) * 0.4;
						
						local particle = CreateMOSParticle((math.random() * particleSpread) < 6.5 and "Tiny Smoke Ball 1" or "Small Smoke Ball 1");
						particle.Pos = self.Pos
						particle.Vel = self.Vel + Vector(0, velocity):RadRotate(self.RotAngle + spread)
						particle.Lifetime = particle.Lifetime * RangeRand(0.9, 1.6) * 0.3 * smokeLingering
						particle.AirThreshold = particle.AirThreshold * 0.5
						particle.GlobalAccScalar = 0
						MovableMan:AddParticle(particle);
					end
					self.brutalDieSound:Stop(-1);
					self.Starts = self.Starts + 1;
					self.brutalStartOneSound:Play(self.Pos);
				else
					local shakenessParticle = CreateMOPixel("Shakeness Particle Massive", "Massive.rte");
					shakenessParticle.Pos = self.MuzzlePos;
					shakenessParticle.Mass = 40;
					shakenessParticle.Lifetime = 500;
					MovableMan:AddParticle(shakenessParticle);
					local smokeAmount = 20
					local particleSpread = 1
					
					local smokeLingering = math.sqrt(smokeAmount / 8) * 1
					
					-- Muzzle main smoke
					for i = 1, math.ceil(smokeAmount / (math.random(2,4))) do
						local spread = math.pi * RangeRand(-1, 1) * 0.05
						local velocity = 60 * RangeRand(0.1, 0.9) * 0.4;
						
						local particle = CreateMOSParticle((math.random() * particleSpread) < 6.5 and "Tiny Smoke Ball 1" or "Small Smoke Ball 1");
						particle.Pos = self.Pos
						particle.Vel = self.Vel + Vector(0, velocity):RadRotate(self.RotAngle + spread)
						particle.Lifetime = particle.Lifetime * RangeRand(0.9, 1.6) * 0.3 * smokeLingering
						particle.AirThreshold = particle.AirThreshold * 0.5
						particle.GlobalAccScalar = 0
						MovableMan:AddParticle(particle);
					end				
					self.turnOnTime = math.random(25000, 40000);
					self.brutalFirstRevSound:Play(self.Pos);
					self.startTwoSound:Play(self.Pos);
					self.turnedOn = true;
					self.turnOnTimer:Reset();
					self.brutalIdleVolumeTarget = 0.5;
				end
			end
		else
			if not self:IsActivated() and self.startTimer:IsPastSimMS(500) then
				self.startActivated = false;
			end
		end
		
		self:Deactivate();
		
	end
	
	if self.FiredFrame then -- lag code, can't enjoy the game too much now can we
	
		self.angVel = math.random(-2, 2);
		
		local smokeAmount = 2
		local particleSpread = 1
		
		local smokeLingering = math.sqrt(smokeAmount / 8) * 1
		
		-- Muzzle main smoke
		for i = 1, math.ceil(smokeAmount / (math.random(2,4))) do
			local spread = math.pi * RangeRand(-1, 1) * 0.05
			local velocity = 60 * RangeRand(0.1, 0.9) * 0.4;
			
			local particle = CreateMOSParticle((math.random() * particleSpread) < 6.5 and "Tiny Smoke Ball 1" or "Small Smoke Ball 1");
			particle.Pos = self.Pos
			particle.Vel = self.Vel + Vector(0, velocity):RadRotate(self.RotAngle + spread)
			particle.Lifetime = particle.Lifetime * RangeRand(0.9, 1.6) * 0.3 * smokeLingering
			particle.AirThreshold = particle.AirThreshold * 0.5
			particle.GlobalAccScalar = 0
			MovableMan:AddParticle(particle);
		end
	end
	

	local actor = MovableMan:GetMOFromID(self.RootID);
	if actor and IsAHuman(actor) then

		local parent = ToAHuman(actor);
		if self.turnedOn ~= true and not parent:IsPlayerControlled() and self.startTimer:IsPastSimMS(500) then
			self:Deactivate();
			self.startActivated = false;
		end
		parent:GetController():SetState(Controller.AIM_SHARP, false);
		turn = math.abs(self.lastAngle - parent:GetAimAngle(false));

		self.InheritedRotAngleOffset = -(-0.8 + math.sin(self.rotFactor) * 0.4);
		
		self.Scale = 1;
		if self.Magazine then
			if self:IsActivated() then
				self.Scale = 0;
				self.activated = true;
			end
			if self.fired then

				if self.rotFactor < 1 then
					self.rotFactor = self.rotFactor + 0.1;
				elseif self.rotFactor > 1 then
					self.rotFactor = 1;
				end
			else
				self.Scale = 1;

				if self.rotFactor > 0 then
					self.rotFactor = self.rotFactor - 0.1;
				elseif self.rotFactor < 0 then
					self.rotFactor = 0;
				end

				if self.Magazine.RoundCount < self.Magazine.Capacity then
					self.Magazine.RoundCount = self.Magazine.RoundCount + 1;
				end
			end
		end

		self.StanceOffset = Vector(10 + self.rotFactor * 3, 5):RadRotate(math.sin(self.rotFactor * 0.3) - 0.3);

		self.lastAngle = parent:GetAimAngle(true);
		
		self.rotationTarget = self.rotationTarget - (self.angVel * 9 * self.FlipFactor)
		
		self.rotation = (self.rotation + self.rotationTarget * TimerMan.DeltaTimeSecs * self.rotationSpeed) / (1 + TimerMan.DeltaTimeSecs * self.rotationSpeed)
		local total = math.rad(self.rotation) * self.FlipFactor
		
		self.InheritedRotAngleOffset = total -(-0.8 + math.sin(self.rotFactor) * 0.4);
		-- self.RotAngle = self.RotAngle + total;
		--self:SetNumberValue("MagRotation", total);
		
		-- local jointOffset = Vector(self.JointOffset.X * self.FlipFactor, self.JointOffset.Y):RadRotate(self.RotAngle);
		-- local offsetTotal = Vector(jointOffset.X, jointOffset.Y):RadRotate(-total) - jointOffset
		-- self.Pos = self.Pos + offsetTotal;
		--self:SetNumberValue("MagOffsetX", offsetTotal.X);
		--self:SetNumberValue("MagOffsetY", offsetTotal.Y);
		
		
	else
		self.Scale = 1;
		self.lastAngle = self.RotAngle;
	end	
	
	
end

function Destroy(self)

	self.stickMO = nil;

	if ValidMO(self.shakenessParticle) then
		self.shakenessParticle.ToDelete = true;
		self.shakenessParticle.Lifetime = 10;
		self.shakenessParticle = nil;
	end

	self.brutalDieSound:Stop(-1);
	self.brutalFirstRevSound:Stop(-1);
	--self.brutalHighLoopSound:Stop(-1);
	self.brutalIdleSound:Stop(-1);
	self.brutalRevDownSound:Stop(-1);
	self.brutalRevUpSound:Stop(-1);
	self.brutalStartOneSound:Stop(-1);
	self.revUpOneShotSound:Stop(-1);
	self.startTwoSound:Stop(-1);
	
end

function OnDetach(self)

	self.stickMO = nil;

	self:RemoveNumberValue("Turned On");
	if self.shakenessParticle then
		self.shakenessParticle.ToDelete = true;
		self.shakenessParticle.Lifetime = 10;
		self.shakenessParticle = nil;
	end

	self.turnOnTime = 0;
	
end