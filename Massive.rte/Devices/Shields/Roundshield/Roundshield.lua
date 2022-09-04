function Create(self)

	self.expandSound = CreateSoundContainer("Expand Roundshield Massive", "Massive.rte");
	self.retractSound = CreateSoundContainer("Retract Roundshield Massive", "Massive.rte");
	
	self.preSound = CreateSoundContainer("Retract Roundshield Massive", "Massive.rte");

	self.satisfyingAddSound = CreateSoundContainer("SatisfyingAdd Roundshield Massive", "Massive.rte");
	self.satisfyingAddIndoorsSound = CreateSoundContainer("SatisfyingAddIndoors Roundshield Massive", "Massive.rte");
	
	self.coreBassSound = CreateSoundContainer("CoreBass Roundshield Massive", "Massive.rte");
	
	self.debrisIndoorsSound = CreateSoundContainer("Debris Indoors DualSniper", "Massive.rte");

	self.veryWeakHitSound = CreateSoundContainer("Impact Metal Small Massive", "Massive.rte");
	self.weakHitSound = CreateSoundContainer("Impact Metal Tight Massive", "Massive.rte");
	self.moderateHitSound = CreateSoundContainer("Impact Metal Solid Massive", "Massive.rte");
	self.moderatelyStrongHitSound = CreateSoundContainer("Impact Metal Basic Massive", "Massive.rte");
	self.strongHitSound = CreateSoundContainer("Impact Metal Clang Massive", "Massive.rte");
	self.veryStrongHitSound = CreateSoundContainer("Impact Metal Rip Massive", "Massive.rte");
	
	self.actualGibWoundLimit = self.GibWoundLimit;
	self.GibWoundLimit = 200;
	
	self.oldWoundCount = 0;
	
	self.animTimer = Timer();
	
	self.chargeTimer = Timer();
	self.charging = false;
	
	self.coolDownTimer = Timer();
	self.coolDown = false;
	
	self.delayedFire = false
	self.delayedFireTimer = Timer();
	self.delayedFireTimeMS = 50
	self.delayedAnimTimeMS = 0
	self.delayedFireEnabled = true
	
	self.lastAge = self.Age + 0
	
	self.shotsTaken = 0
	
end
function Update(self)

	self.expandSound.Pos = self.Pos;
	self.retractSound.Pos = self.Pos;
	self.successSound = self.Pos;
	self.preSound.Pos = self.Pos;

	local parent = self:GetRootParent()
	if IsAHuman(parent) then
		self.parent = ToAHuman(parent)
	end
	
	-- Check if switched weapons/hide in the inventory, etc.
	if self.Age > (self.lastAge + TimerMan.DeltaTimeSecs * 2000) then
		if self.delayedFire then
			self.delayedFire = false
		end
	end
	self.lastAge = self.Age + 0	
	
	self.newWoundsThisFrame = 0;

	if self.WoundCount > self.oldWoundCount then
		local strengthCheck = self.WoundCount - self.oldWoundCount;
		self.newWoundsThisFrame = strengthCheck
		self.shotsTaken = self.shotsTaken + self.newWoundsThisFrame
		if strengthCheck < 2 then
			self.veryWeakHitSound:Play(self.Pos);
			if math.random(0, 100) < 70 then
				self:RemoveWounds(1);
				self.newWoundsThisFrame = 0
			end
		elseif strengthCheck < 3 then
			self.weakHitSound:Play(self.Pos);
		elseif strengthCheck < 4 then
			self.moderateHitSound:Play(self.Pos);
		elseif strengthCheck < 5 then
			self.moderatelyStrongHitSound:Play(self.Pos);
		elseif strengthCheck < 6 then
			self.strongHitSound:Play(self.Pos);
		else
			self.veryStrongHitSound:Play(self.Pos);
		end
		if strengthCheck > 10 then
			self:RemoveWounds((self.WoundCount - self.oldWoundCount) / 2)
			self.newWoundsThisFrame = math.floor(math.max(0, (self.WoundCount - self.oldWoundCount) / 2))
		end
		if strengthCheck > 1 and self.WoundCount > self.actualGibWoundLimit then
			self:GibThis();
		end
	end
	
	self.oldWoundCount = self.WoundCount;
	
	if self.coolDown ~= true and self:IsActivated() then	
		if self.charging == false then		
			self.charging = true;
			self.chargeTimer:Reset();		
			self.toRetract = false;
			self.shotsTaken = 0;		

			self.expandSound:Play(self.Pos);
			
		else
		
			self.shotsTaken = self.shotsTaken + self.newWoundsThisFrame;
			self:RemoveWounds(self.newWoundsThisFrame);
		
			if self.Frame < 8 and self.animTimer:IsPastSimMS(15) then
				self.Frame = self.Frame + 1
				self.animTimer:Reset();
			end
		
			if self.chargeTimer:IsPastSimMS(2000) then
				self.charging = false;
				self.coolDownTimer:Reset();
				self.coolDown = true;
				
				if self.shotsTaken > 2 then
				
					self.toFire = true;	
					
					if self.shotsTaken > 20 then
					
						self.delayedFireTimeMS = 650
						self.delayedAnimTimeMS = 490;
						
						self.preSound = CreateSoundContainer("SuccessPre Roundshield Massive", "Massive.rte");
						
					else
					
						self.delayedFireTimeMS = 200
						self.delayedAnimTimeMS = 0;
						
						self.preSound = self.retractSound
						
					end
					
				else
					self.toRetract = true;
					self.retractSound:Play(self.Pos);
				end
			end		
		end	
	else
	
		if self.charging then
			self.charging = false;
			self.coolDownTimer:Reset();
			self.coolDown = true;
			
			if self.shotsTaken > 2 then
			
				self.toFire = true;	
				
				if self.shotsTaken > 20 then
				
					self.delayedFireTimeMS = 650
					self.delayedAnimTimeMS = 400;
					
					self.preSound = CreateSoundContainer("SuccessPre Roundshield Massive", "Massive.rte");
					
				else
				
					self.delayedFireTimeMS = 200
					self.delayedAnimTimeMS = 0;
					
					self.preSound = self.retractSound
					
				end
				
			else
				self.toRetract = true;
				self.retractSound:Play(self.Pos);
			end
		end		
	end
	
	if self.toRetract and not self.charging then
		if self.Frame > 0 and self.animTimer:IsPastSimMS(10) then
			self.Frame = self.Frame - 1
			self.animTimer:Reset();
		end
	end
	
	if self.coolDown and self.coolDownTimer:IsPastSimMS(700) then
		self.coolDown = false;
	end

		
	if self.toFire then
		if not self.activated and not self.delayedFire then
		
			self.activated = true	
			
			self.preSound:Play(self.Pos);
			self.delayedFire = true
			self.delayedFireTimer:Reset()
		end
	else
		if self.activated then
			self.activated = false
		end
	end
	
	if self.delayedFire then
		if self.delayedFireTimer:IsPastSimMS(self.delayedFireTimeMS) then
			self.delayedFire = false
			self.toFire = false;

			-- fire!
			
			
			local shot = CreateMOPixel("Maxav Particle Scripted", "Massive.rte");
			shot.Pos = self.Pos;
			shot.Vel = self.Vel + Vector((math.min(160, 85 + 10*self.shotsTaken)) * self.FlipFactor, 0):RadRotate(self.RotAngle);
			shot.Team = self.Team;
			shot.IgnoresTeamHits = true;
			MovableMan:AddParticle(shot);	
			for i = 1, math.min(35, self.shotsTaken) do
				local shot = CreateMOPixel("Maxav Particle", "Massive.rte");
				shot.Pos = self.Pos;
				shot.Vel = self.Vel + Vector((math.min(160, 85 + 10*self.shotsTaken)) * self.FlipFactor, 0):RadRotate(self.RotAngle);
				shot.Team = self.Team;
				shot.IgnoresTeamHits = true;
				MovableMan:AddParticle(shot);
			end	
			
			local shakenessParticle = CreateMOPixel("Shakeness Particle Glow Massive", "Massive.rte");
			shakenessParticle.Pos = self.Pos;
			shakenessParticle.Mass = 60
			shakenessParticle.Lifetime = math.min(600, 200 + 75*self.shotsTaken);
			MovableMan:AddParticle(shakenessParticle);		
			
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
			
			local smokeAmount = math.floor(6 + 2 * self.shotsTaken) * MassiveSettings.GunshotSmokeMultiplier;
			local particleSpread = 2
			
			local smokeLingering = math.sqrt(smokeAmount / 8)
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
			
			self.coreBassSound:Play(self.Pos);
			
			if outdoorRays >= self.rayThreshold then
				if self.shotsTaken > 20 then
					self.satisfyingAddSound:Play(self.Pos);
				end
			else	
				if self.shotsTaken > 20 then
					self.debrisIndoorsSound:Play(self.Pos);
					self.satisfyingAddIndoorsSound:Play(self.Pos);
				end
			end		
			
			self.satisfyingAddSound:Play(self.Pos);
		
		elseif self.delayedFireTimer:IsPastSimMS(self.delayedAnimTimeMS) and not self.toRetract then
		
			self.toRetract = true;
			
		end
	end
	
end

function OnDetach(self)
	self.parent = nil;
end