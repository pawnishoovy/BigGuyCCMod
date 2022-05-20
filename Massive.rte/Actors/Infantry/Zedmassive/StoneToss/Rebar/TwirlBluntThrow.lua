function Create(self)

	self:DisableScript("Massive.rte/Actors/Infantry/Zedmassive/StoneToss/Rebar/TwirlBluntThrow.lua");
	
end
function Update(self)

	if self.wasThrown == true then
	
		if self.throwSoundPlayed == false then
			self.AngularVel = self.AngularVel - self.Vel.Magnitude * self.FlipFactor * 0.6
			self.throwSoundPlayed = true;
			self.throwSound.Pitch = self.throwPitch;
			--self.throwSound:Play(self.Pos);
		end
		
		if self.Vel.Magnitude > 13 then -- Raycast
		
			if math.abs(self.AngularVel) > 6 and math.abs(self.Vel.Magnitude) > 6 and self.spinTimer:IsPastSimMS(self.spinDelay) then
				self.spinTimer:Reset();
				self.spinDelay = 170 * (math.abs(self.AngularVel)/10);
				
				self.spinSound.Volume = math.max(0.3, math.min(math.abs(self.AngularVel/20), 1))
				self.spinSound.Pitch = self.throwPitch * 1.5;
				self.spinSound:Play(self.Pos);
			end
		
			local rayOrigin = self.Pos
			local rayVec = Vector(self.Vel.X,self.Vel.Y):SetMagnitude(self.Vel.Magnitude * rte.PxTravelledPerFrame + self.IndividualRadius);
			local moCheck = SceneMan:CastMORay(rayOrigin, rayVec, self.ID, self.thrownTeam, 0, false, 2); -- Raycast
			if moCheck ~= rte.NoMOID then
				local rayHitPos = SceneMan:GetLastRayHitPos()
				local MO = MovableMan:GetMOFromID(moCheck)
				if IsMOSRotating(MO) then
					self.hitMO = ToMOSRotating(MO);
					
					local vel = Vector(self.Vel.X, self.Vel.Y):SetMagnitude(self.Vel.Magnitude * 0.3);
					self.Vel = vel;
					self.AngularVel = self.AngularVel * 0.5;
					
					local addWounds = true;
					
					-- Get the material and set damage multiplier
					local material = self.hitMO.Material.PresetName;
					
					-- get wounds to check for dent metal
					local woundName = self.hitMO:GetEntryWoundPresetName()
					local woundNameExit = self.hitMO:GetExitWoundPresetName()
					local woundOffset = (rayHitPos - self.hitMO.Pos):RadRotate(self.hitMO.RotAngle * -1.0)
					
					
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
					
					local actorHit = MovableMan:GetMOFromID(self.hitMO.RootID)
					
					if addWounds == true then
						-- weird lopsidedness can easily make pixels miss, so we just add wounds raw
						for i = 1, 7 do
							self.hitMO:AddWound(CreateAEmitter(woundName), woundOffset, true)
						end
					end
						
					self.spinSound:Stop(-1);
					
					self.HUDVisible = true;
			
					self.wasThrown = false;
					self:DisableScript("Massive.rte/Actors/Infantry/Zedmassive/StoneToss/Rebar/TwirlBluntThrow.lua");

				end
				
			else
				local terrCheck = SceneMan:CastStrengthSumRay(rayOrigin, rayOrigin + rayVec, 2, 0); -- Raycast
				if terrCheck > 5 then
					local rayHitPos = SceneMan:GetLastRayHitPos()
					
					local terrPixel = SceneMan:GetTerrMatter(rayHitPos.X, rayHitPos.Y)
			
					if terrPixel ~= 0 then -- 0 = air
						if self.terrainSounds.Impact[terrPixel] ~= nil then
							self.terrainSounds.Impact[terrPixel]:Play(self.Pos);
						else -- default to concrete
							self.terrainSounds.Impact[177]:Play(self.Pos);
						end
					end
					
					self.spinSound:Stop(-1);
					
					self.HUDVisible = true;
			
					self.wasThrown = false;
					self:DisableScript("Massive.rte/Actors/Infantry/Zedmassive/StoneToss/Rebar/TwirlBluntThrow.lua");

				end
			end		
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
	self:DisableScript("Massive.rte/Actors/Infantry/Zedmassive/StoneToss/Rebar/TwirlBluntThrow.lua");
	
end