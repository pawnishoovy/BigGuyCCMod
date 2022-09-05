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

	self.chargingHitSound = CreateSoundContainer("ChargingHit Roundshield Massive", "Massive.rte");

	self.expandSound = CreateSoundContainer("Expand Roundshield Massive", "Massive.rte");
	self.retractSound = CreateSoundContainer("Retract Roundshield Massive", "Massive.rte");
	
	self.preSound = CreateSoundContainer("Retract Roundshield Massive", "Massive.rte");

	self.satisfyingAddSound = CreateSoundContainer("SatisfyingAdd Roundshield Massive", "Massive.rte");
	self.satisfyingAddIndoorsSound = CreateSoundContainer("SatisfyingAddIndoors Roundshield Massive", "Massive.rte");
	
	self.shotgunBoomSound = CreateSoundContainer("Boom Homage", "Massive.rte");
	
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
	
	self.shoveTimer = Timer();
	self.shoveCooldown = 750;
	
end
function Update(self)

	self.rotationTarget = 0;

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
		if self.charging and self.newWoundsThisFrame > 0 then
			self.chargingHitSound:Play(self.Pos);
			self.chargeTimer:Reset();
		end
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
	
	if self.coolDown ~= true and self.parent and self:IsActivated() then	
		if self.charging == false then		
			self.charging = true;
			self.chargeTimer:Reset();		
			self.shotgunMode = false;
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
			
			if self.shoveStart then
			
				-- shotgun bash mode
			
				self.charging = false;
				self.coolDownTimer:Reset();
				self.coolDown = true;	

				self.toFire = true;	
				
				self.shotgunMode = true;
			
				self.delayedFireTimeMS = 525
				self.delayedAnimTimeMS = 400;
				
				self.preSound = CreateSoundContainer("SuccessPre Roundshield Massive", "Massive.rte");
				
			end

			if self.chargeTimer:IsPastSimMS(2000) then
				self.charging = false;
				self.coolDownTimer:Reset();
				self.coolDown = true;
				
				if self.shotsTaken > -1 then
				
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
			
			if self.shotsTaken > -1 then
			
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
	
	if self.coolDown and self.coolDownTimer:IsPastSimMS(800) then
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
			
			self.coolDownTimer:Reset();
			
			if self.shotgunMode then
			
				-- see above
				
				self.shotgunBoomSound:Play(self.Pos);
				
				local shot = CreateMOPixel("Pellet Homage Extra", "Massive.rte");
				shot.Pos = self.MuzzlePos;
				shot.Vel = self.Vel + Vector(160 * self.FlipFactor, 0):RadRotate(self.RotAngle);
				shot.Lifetime = shot.Lifetime * math.random(0.4, 0.8);
				shot.Team = self.Team;
				shot.IgnoresTeamHits = true;
				MovableMan:AddParticle(shot);	
				
				for i = 1, math.min(35, self.shotsTaken) do
					local shot = CreateMOPixel("Pellet Homage", "Massive.rte");
					shot.Pos = self.Pos;
					shot.Vel = self.Vel + (Vector(160*self.FlipFactor,0) + Vector(RangeRand(-1,1), RangeRand(-6,6))):RadRotate(self.RotAngle)
					shot.Lifetime = shot.Lifetime * math.random(0.4, 0.8);
					shot.Team = self.Team;
					shot.IgnoresTeamHits = true;
					MovableMan:AddParticle(shot);
				end	
				
				local shakenessParticle = CreateMOPixel("Shakeness Particle Glow Massive", "Massive.rte");
				shakenessParticle.Pos = self.Pos;
				shakenessParticle.Mass = 60
				shakenessParticle.Lifetime = math.min(600, 200 + 75*self.shotsTaken);
				MovableMan:AddParticle(shakenessParticle);		
			
			elseif self.shotsTaken > 0 then
			
				-- normal mode
			
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
				
			else
			
				-- weak, no shots taken mode
			
				local shot = CreateMOPixel("Bullet UltraMag Scripted", "Massive.rte");
				shot.Pos = self.Pos;
				shot.Vel = self.Vel + Vector(90 * self.FlipFactor, 0):RadRotate(self.RotAngle);
				shot.Team = self.Team;
				shot.IgnoresTeamHits = true;
				MovableMan:AddParticle(shot);	

			end
			
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
		
		elseif self.delayedFireTimer:IsPastSimMS(self.delayedAnimTimeMS) and not self.toRetract then
		
			self.toRetract = true;
			
		end
	end
	
	-- animation and shoving
	
	if self.parent then
	
		if self.shoveStart then
			self.horizontalAnim = 11;
			self.rotationTarget = 0;
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
			self.shoveRot = 0
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
		
		self.StanceOffset = Vector(self.originalStanceOffset.X, self.originalStanceOffset.Y) + stance
		self.SharpStanceOffset = Vector(self.originalSharpStanceOffset.X, self.originalSharpStanceOffset.Y) + stance
		
	end
	
end

function OnDetach(self)
	self.parent = nil;
	
	self.shoveStart = false;
	self.shoving = false;	
	
end