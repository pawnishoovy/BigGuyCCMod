function Create(self)
	
	self.stickMO = nil;
	self.stickVecX = 0;
	self.stickVecY = 0;
	self.stickRot = 0;
	self.stickDeepness = RangeRand(0.1, 1);

	self.stuck = false;
	
	self.phase = 0;
	
	self:DisableScript("Massive.rte/Devices/Weapons/Melee/JetAxe/TwirlPierceThrow.lua");
	
end
function Update(self)
	if self.wasThrown == true then
	
		if self.throwSoundPlayed == false then
			self.AngularVel = self.AngularVel - self.Vel.Magnitude * self.FlipFactor * 0.6
			self.throwSoundPlayed = true;
			self.throwSound.Pitch = self.throwPitch;
			self.throwSound:Play(self.Pos);
		end
	
		if self.phase == 0 and self.Vel.Magnitude > 13 then -- Raycast, stick to things
		
			if math.abs(self.AngularVel) > 6 and math.abs(self.Vel.Magnitude) > 6 and self.spinTimer:IsPastSimMS(self.spinDelay) then
				self.spinTimer:Reset();
				self.spinDelay = 145 * (math.abs(self.AngularVel)/10);
				
				self.spinSound.Volume = math.max(0.3, math.min(math.abs(self.AngularVel/20), 1))
				self.spinSound.Pitch = self.throwPitch * 1.5;
				self.spinSound:Play(self.Pos);
				
			end
			
			local particle = CreateMOSParticle("Flame Smoke 2");
			particle.Lifetime = math.random(250, 600);
			particle.Vel = self.Vel + Vector(-4*self.FlipFactor, 0):RadRotate(self.RotAngle);
			particle.Pos = self.Pos + Vector(-6*self.FlipFactor, -15):RadRotate(self.RotAngle);
			MovableMan:AddParticle(particle);			
		
			local rayOrigin = self.Pos
			local rayVec = Vector(self.Vel.X,self.Vel.Y):SetMagnitude(self.Vel.Magnitude * rte.PxTravelledPerFrame + self.IndividualRadius);
			local moCheck = SceneMan:CastMORay(rayOrigin, rayVec, self.ID, self.thrownTeam, 0, false, 2); -- Raycast
			if moCheck ~= rte.NoMOID then
				local rayHitPos = SceneMan:GetLastRayHitPos()
				local MO = MovableMan:GetMOFromID(moCheck)
				if IsMOSRotating(MO) then
					self.stickMO = ToMOSRotating(MO);
					local stickVec = SceneMan:ShortestDistance(self.stickMO.Pos,rayHitPos,SceneMan.SceneWrapsX):RadRotate(-self.stickMO.RotAngle);
					self.stickVecX = stickVec.X;
					self.stickVecY = stickVec.Y;
					self.stickRot = self.RotAngle - self.stickMO.RotAngle;
					
					local addWounds = true;
					
					-- Get the material and set damage multiplier
					local material = self.stickMO.Material.PresetName;
					
					-- get wounds to check for dent metal
					local woundName = self.stickMO:GetEntryWoundPresetName()
					local woundNameExit = self.stickMO:GetExitWoundPresetName()
					local woundOffset = (rayHitPos - self.stickMO.Pos):RadRotate(self.stickMO.RotAngle * -1.0)
					
					
					-- Add extra effects based on the material
					if string.find(material,"Flesh") then
						local blood = CreateMOSParticle("Blood Spray Particle");
						blood.Pos = rayHitPos - Vector(self.Vel.X,self.Vel.Y) * rte.PxTravelledPerFrame * 0.1;
						blood.Vel = Vector(self.Vel.X,self.Vel.Y):RadRotate(math.pi * RangeRand(-0.1, 0.1)) * RangeRand(0.05, 0.1) * -1.0;
						MovableMan:AddParticle(blood);
						self.soundHitFlesh:Play(self.Pos);
					else
						for i = 1, 3 do
							local bloofm = CreateMOSParticle("Tiny Smoke Trail 1");
							bloofm.Pos = rayHitPos - Vector(self.Vel.X,self.Vel.Y) * rte.PxTravelledPerFrame * 0.1;
							bloofm.Vel = Vector(self.Vel.X,self.Vel.Y):RadRotate(math.pi * RangeRand(-0.2, 0.2)) * RangeRand(0.1, 0.4) * -1.0;
							MovableMan:AddParticle(bloofm);
						end
						if string.find(material,"Metal") or string.find(woundName,"Dent") or string.find(woundNameExit,"Dent") then
							self.soundHitMetal:Play(self.Pos);
						end
					end
					
					local effect = CreateMOSRotating("Melee Terrain Hard Effect Massive", "Massive.rte");
					if effect then
						effect.Pos = rayHitPos
						MovableMan:AddParticle(effect);
						effect:GibThis();
					end
					
					local actorHit = MovableMan:GetMOFromID(self.stickMO.RootID)
					if (actorHit and IsActor(actorHit)) then
				
						if IsAHuman(actorHit) then
							local actorHuman = ToAHuman(actorHit)
							if actorHuman.Head and self.stickMO.ID == actorHuman.Head.ID or actorHuman.FGArm and self.stickMO.ID == actorHuman.FGArm.ID or actorHuman.BGArm and self.stickMO.ID == actorHuman.BGArm.ID or actorHuman.FGLeg and self.stickMO.ID == actorHuman.FGLeg.ID or actorHuman.BGLeg and self.stickMO.ID == actorHuman.BGLeg.ID then
								-- two different ways to dismember: 1. if wounds would gib the limb hit, dismember it instead 2. low hp
								local halfVel = Vector(self.Vel.X, self.Vel.Y):SetMagnitude(self.Vel.Magnitude/2);
								if self.stickMO.WoundCount + 7 > self.stickMO.GibWoundLimit then
									ToMOSRotating(actorHuman):RemoveAttachable(ToAttachable(self.stickMO), true, true);
									addWounds = false;
									self.stickMO.Vel = self.stickMO.Vel + halfVel
								elseif actorHuman.Health < 10 and math.random(0, 100) < 50 then
									ToMOSRotating(actorHuman):RemoveAttachable(ToAttachable(self.stickMO), true, true);
									addWounds = false;
									self.stickMO.Vel = self.stickMO.Vel + halfVel
								end
							end
						end
					end
					
					if addWounds == true then
						-- weird lopsidedness can easily make pixels miss, so we just add wounds raw
						for i = 1, self.throwWounds do
							self.stickMO:AddWound(CreateAEmitter(woundName), woundOffset, true)
						end
					end
						
					self.spinSound:Stop(-1);
					
					if not (MO:IsInGroup("Weapons - Mordhau Melee") or ToMOSRotating(MO):NumberValueExists("Weapons - Mordhau Melee")) then -- deflect coolly off of weapons! 
						self.PinStrength = 1000;
						self.Vel = Vector()
						self.AngularVel = 0;
						
						self.stuck = true
						self.phase = 1
					else
						self.phase = 3
						self.AngularVel = math.random(-15, 15);
						self.Vel = Vector(self.Vel.X, self.Vel.Y - 6):SetMagnitude(self.Vel.Magnitude * 0.5);
					end
					
					self.HitsMOs = false;
				end
				
			else
				local terrCheck = SceneMan:CastStrengthSumRay(rayOrigin, rayOrigin + rayVec, 2, 0); -- Raycast
				if terrCheck > 5 then
					local rayHitPos = SceneMan:GetLastRayHitPos()
					self.Pos = rayHitPos - Vector(self.IndividualRadius * self.stickDeepness, 0):RadRotate(self.RotAngle);
					
					local terrPixel = SceneMan:GetTerrMatter(rayHitPos.X, rayHitPos.Y)
			
					if terrPixel ~= 0 then -- 0 = air
						if self.terrainSounds.Impact[terrPixel] ~= nil then
							self.terrainSounds.Impact[terrPixel]:Play(self.Pos);
						else -- default to concrete
							self.terrainSounds.Impact[177]:Play(self.Pos);
						end
					end
					
					self.PinStrength = 1000;
					self.Vel = Vector()
					self.AngularVel = 0;
					
					self.HitsMOs = false;
			
					local effect = CreateMOSRotating("Melee Terrain Hard Effect Massive", "Massive.rte");
					if effect then
						effect.Pos = self.Pos + SceneMan:ShortestDistance(self.Pos,rayHitPos,SceneMan.SceneWrapsX) * 0.5
						MovableMan:AddParticle(effect);
						effect:GibThis();
					end
					
					self.spinSound:Stop(-1);
					
					self.stuck = true
					self.phase = 2


				end
			end
			
			--PrimitiveMan:DrawLinePrimitive(rayOrigin, rayOrigin + rayVec, 5);
			
		elseif self.phase == 1 then -- Stuck into MO
			
			if self.stickMO.ID ~= rte.NoMOID and self.PinStrength > 10 then
				--self.Pos = self.stickMO.Pos + Vector(self.stickVec.X, self.stickVec.Y):RadRotate(self.stickMO.RotAngle)
				self.RotAngle = self.stickMO.RotAngle + self.stickRot * 0.1
				self.Pos = self.stickMO.Pos + Vector(self.stickVecX, self.stickVecY):RadRotate(self.stickMO.RotAngle) - Vector(self.IndividualRadius * self.stickDeepness, 0):RadRotate(self.RotAngle);
				self.PinStrength = 1000;
				self.AngularVel = 0;
				
			else
				
				self.PinStrength = 0;
				
				self.stickMO = nil;
				self.stuck = false
				self.phase = 3
			end
			
		elseif self.phase == 2 then -- Stuck into terrain
		
			self.HUDVisible = true;
			
			self.wasThrown = false;
			self:DisableScript("Massive.rte/Devices/Weapons/Melee/JetAxe/TwirlPierceThrow.lua");
		
			self.PinStrength = 0;
			self.AngularVel = 0;

		elseif self.phase == 3 then -- Fell from MO
		
			self.HUDVisible = true;
		
			self.wasThrown = false;
			self:DisableScript("Massive.rte/Devices/Weapons/Melee/JetAxe/TwirlPierceThrow.lua");
		
			self.PinStrength = 0;
			
		end
	end
end

function OnCollideWithTerrain(self)

	self.HUDVisible = true;
	
	if self.phase ~= 2 then
		if self.bounceSound then
			self.bounceSound:Play(self.Pos);
		end
	end
	
	self.wasThrown = false;
	self:DisableScript("Massive.rte/Devices/Weapons/Melee/JetAxe/TwirlPierceThrow.lua");
	
	self.PinStrength = 0;
	
end