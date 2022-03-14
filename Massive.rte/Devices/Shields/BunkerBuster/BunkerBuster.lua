function Create(self)

	self.veryWeakHitSound = CreateSoundContainer("Impact Metal Small Massive", "Massive.rte");
	self.weakHitSound = CreateSoundContainer("Impact Metal Tight Massive", "Massive.rte");
	self.moderateHitSound = CreateSoundContainer("Impact Metal Solid Massive", "Massive.rte");
	self.moderatelyStrongHitSound = CreateSoundContainer("Impact Metal Basic Massive", "Massive.rte");
	self.strongHitSound = CreateSoundContainer("Impact Metal Clang Massive", "Massive.rte");
	self.veryStrongHitSound = CreateSoundContainer("Impact Metal Rip Massive", "Massive.rte");
	
	self.deploySound = CreateSoundContainer("Deploy BunkerBuster Massive", "Massive.rte");
	self.warningBeepSound = CreateSoundContainer("Warning Beep BunkerBuster Massive", "Massive.rte");
	
	self.neutralExplodeSound = CreateSoundContainer("Explode Neutral BunkerBuster Massive", "Massive.rte");
	self.concreteExplodeSound = CreateSoundContainer("Explode Concrete BunkerBuster Massive", "Massive.rte");
	self.dirtExplodeSound = CreateSoundContainer("Explode Dirt BunkerBuster Massive", "Massive.rte");
	self.sandExplodeSound = CreateSoundContainer("Explode Sand BunkerBuster Massive", "Massive.rte");
	self.solidMetalExplodeSound = CreateSoundContainer("Explode SolidMetal BunkerBuster Massive", "Massive.rte");
	
	self.explodeReflectionIndoorsSound = CreateSoundContainer("Explode Reflection Indoors BunkerBuster Massive", "Massive.rte");
	self.explodeReflectionOutdoorsSound = CreateSoundContainer("Explode Reflection Outdoors BunkerBuster Massive", "Massive.rte");
	
	self.terrainSounds = {
	Impact = {[12] = CreateSoundContainer("Plant Concrete BunkerBuster Massive", "Massive.rte"),
			[164] = CreateSoundContainer("Plant Concrete BunkerBuster Massive", "Massive.rte"),
			[177] = CreateSoundContainer("Plant Concrete BunkerBuster Massive", "Massive.rte"),
			[9] = CreateSoundContainer("Plant Dirt BunkerBuster Massive", "Massive.rte"),
			[10] = CreateSoundContainer("Plant Dirt BunkerBuster Massive", "Massive.rte"),
			[11] = CreateSoundContainer("Plant Dirt BunkerBuster Massive", "Massive.rte"),
			[128] = CreateSoundContainer("Plant Dirt BunkerBuster Massive", "Massive.rte"),
			[6] = CreateSoundContainer("Plant Sand BunkerBuster Massive", "Massive.rte"),
			[8] = CreateSoundContainer("Plant Sand BunkerBuster Massive", "Massive.rte"),
			[178] = CreateSoundContainer("Plant SolidMetal BunkerBuster Massive", "Massive.rte"),
			[179] = CreateSoundContainer("Plant SolidMetal BunkerBuster Massive", "Massive.rte"),
			[180] = CreateSoundContainer("Plant SolidMetal BunkerBuster Massive", "Massive.rte"),
			[181] = CreateSoundContainer("Plant SolidMetal BunkerBuster Massive", "Massive.rte"),
			[182] = CreateSoundContainer("Plant SolidMetal BunkerBuster Massive", "Massive.rte")}}
			
	self.checkTimer = Timer();
	self.checkDelay = 1000;
	self.checkI = 0
	
	self.actualGibWoundLimit = self.GibWoundLimit;
	self.GibWoundLimit = 200;
	
	self.oldWoundCount = 0;
	
end
function Update(self)

	local parent = self:GetRootParent()
	if IsAHuman(parent) then
		self.parent = ToAHuman(parent)
		if self.Planted then
			self:RemoveFromParent(true, false);
		end
	end

	if self.WoundCount > self.oldWoundCount then
		local strengthCheck = self.WoundCount - self.oldWoundCount;
		if strengthCheck < 2 then
			self.veryWeakHitSound:Play(self.Pos);
			if math.random(0, 100) < 70 then
				self:RemoveWounds(1);
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
		end
		if strengthCheck > 1 and self.WoundCount > self.actualGibWoundLimit then
			self:GibThis();
		end
	end
	
	self.oldWoundCount = self.WoundCount;
	
	if self.parent and self:NumberValueExists("Enter Planting Mode") and not self.Planted then
	
		if not self.Planting == true then
			self.Planting = true;
			self:SetOneHanded(false);
			self.deploySound:Play(self.Pos);
			self.Frame = 1;
		end
	
		local hitLocation = Vector()
		--local checkOrigin = self.parent.FGArm.Pos + Vector(self.StanceOffset.X, self.StanceOffset.Y - 2):RadRotate(self.RotAngle)
		local checkOrigin = self.parent.FGArm.Pos + Vector(7 * self.FlipFactor, 2):RadRotate(self.RotAngle)
		local checkVec = Vector(24 * self.FlipFactor, 0):RadRotate(self.RotAngle)
		--local terrCheck = SceneMan:CastStrengthSumRay(checkOrigin, checkOrigin + checkVec, 2, 0);
		local terrCheck = SceneMan:CastStrengthRay(checkOrigin, checkVec, 30, hitLocation, 2, 0, SceneMan.SceneWrapsX)
		
		local direction = self.RotAngle
		
		local rayEndPos = checkOrigin + checkVec
		
		if terrCheck then 
			local rayHitPos = SceneMan:GetLastRayHitPos()
			rayEndPos = Vector(rayHitPos.X, rayHitPos.Y)
			
			local normal = Vector()
			local maxi = 25
			for i = 1, maxi do
				local vec = Vector(3,0):RadRotate(math.pi * 2 * (i / maxi))
				PrimitiveMan:DrawLinePrimitive(vec, vec, 5)
				local checkPos = rayEndPos + vec
				local checkPix = SceneMan:GetTerrMatter(checkPos.X, checkPos.Y)
				if checkPix == 0 then
					normal = normal + vec
				end
			end
			direction = normal.AbsRadAngle
			
			-- cool VISUALIZATIONZZZZ
			local color = 120
			local position = rayEndPos + Vector(2,0):RadRotate(direction)
			local width = 27 * 0.5
			local height = 4 * 0.5
			
			PrimitiveMan:DrawLinePrimitive(position + Vector(width, height):RadRotate(direction + math.pi/2), position + Vector(-width, height):RadRotate(direction + math.pi/2), color)
			
			PrimitiveMan:DrawLinePrimitive(position + Vector(-width, height):RadRotate(direction + math.pi/2), position + Vector(-width, -height):RadRotate(direction + math.pi/2), color)
			PrimitiveMan:DrawLinePrimitive(position + Vector(width, -height):RadRotate(direction + math.pi/2), position + Vector(width, height):RadRotate(direction + math.pi/2), color)
			
			PrimitiveMan:DrawLinePrimitive(position + Vector(width, -height):RadRotate(direction + math.pi/2), position + Vector(-width, -height):RadRotate(direction + math.pi/2), color)
			
			if self:IsActivated() then
				-- Stick
				self.Planted = true;

				local terrainID = SceneMan:GetTerrMatter(hitLocation.X, hitLocation.Y);
				if self.terrainSounds.Impact[terrainID] ~= nil then
					self.terrainSounds.Impact[terrainID]:Play(self.Pos);
				else -- default to concrete
					self.terrainSounds.Impact[177]:Play(self.Pos);
				end
				
				self:RemoveFromParent(true, false)
				self.Pos = rayEndPos + Vector(2,0):RadRotate(direction);
				self.pinPosition = Vector(self.Pos.X, self.Pos.Y);
				self.RotAngle = direction + math.pi
				self.pinRotAngle = self.RotAngle + 0;
				self.Team = -1;
				ToHeldDevice(self).Unpickupable = true; -- doesn't work gg
				self.HitsMOs = true;
				self.Vel = Vector(0, 0);
				self.checkTimer:Reset();
				
			end

		else
		
			local color = 120
			
			local maxi = 3
			for i = 1, maxi do
				PrimitiveMan:DrawLinePrimitive(checkOrigin + checkVec * i / maxi * 0.8, checkOrigin + checkVec * i / maxi, color)
			end
			PrimitiveMan:DrawLinePrimitive(checkOrigin + checkVec, checkOrigin + checkVec + Vector(-5 * self.FlipFactor, 4):RadRotate(self.RotAngle), color)
			PrimitiveMan:DrawLinePrimitive(checkOrigin + checkVec, checkOrigin + checkVec + Vector(-5 * self.FlipFactor, -4):RadRotate(self.RotAngle), color)
			
		end
		
	elseif self.Planted then
	
		if not self.warningBeepSound:IsBeingPlayed() then
			self.warningBeepSound:Play(self.Pos);
		end
	
		self.Pos = self.pinPosition;
		self.RotAngle = self.pinRotAngle;
		self.Vel = Vector(0, 0);
		
		-- for some reason MOSRotating collisions just don't register as they should, so we have to custom-detect this stuff.
		

		for i = 1, 14 do	
			self.checkI = self.checkI % 13 + 1
			
			local checkOrigin = Vector(self.Pos.X, self.Pos.Y) + Vector(-9, -10 + (self.checkI - 1) * 3):RadRotate(self.RotAngle)
			local checkPix = SceneMan:GetMOIDPixel(checkOrigin.X, checkOrigin.Y)
			--PrimitiveMan:DrawLinePrimitive(checkOrigin, checkOrigin, 5)
			
			local stepper = nil
			if checkPix ~= 255 and checkPix ~= self.ID then
				stepper = MovableMan:GetMOFromID(checkPix);
			end
			
			if stepper then
				local stepperParent = stepper:GetRootParent();
				if (stepperParent and stepperParent.Mass > 10) or stepper.Mass > 10 then
					local dist = SceneMan:ShortestDistance(stepperParent.Pos, self.Pos, SceneMan.SceneWrapsX);
					local stepperVel = stepperParent.Vel;
					if stepperVel.AbsRadAngle > (dist.AbsRadAngle - 1.5) and stepperVel.AbsRadAngle < (dist.AbsRadAngle + 1.5) then
						-- well, they're going the right way, one hopes, now check they're chunky enough or fast enough
						if stepperVel.Magnitude > 6 or stepperVel.Y > 5 then -- base speed check
							if stepperVel.Magnitude + stepperParent.Mass > 300 then
								self.Obliterate = true;
							end
						end
					end
				end
			end
		end
	end
	
	if self.Obliterate then -- Obliterate.
	
		self:EraseFromTerrain();
	
		local concPixels = 0;
		local dirtPixels = 0;
		local sandPixels = 0;
		local solidMetalPixels = 0;
	
		for i = 1, 14 do	
			-- count how many of each material we find to decide what debris-y sound to play
			self.checkI = self.checkI % 13 + 1
			
			local checkOrigin = Vector(self.Pos.X, self.Pos.Y) + Vector(9, -10 + (self.checkI - 1) * 3):RadRotate(self.RotAngle)
			local checkPix = SceneMan:GetTerrMatter(checkOrigin.X, checkOrigin.Y)
			
			if checkPix == 12 or checkPix == 164 or checkPix == 177 then
				concPixels = concPixels + 1;
			elseif checkPix == 9 or checkPix == 10 or checkPix == 11 or checkPix == 128 then
				dirtPixels = dirtPixels + 1;
			elseif checkPix == 6 or checkPix == 8 then
				sandPixels = sandPixels + 1;
			elseif checkPix == 178 or checkPix == 179 or checkPix == 180 or checkPix == 181 or checkPix == 182 then
				solidMetalPixels = solidMetalPixels + 1;
			end
			
			-- and while we're at it... Obliterate.
			
			for i = 1, 50 do
				local particle = CreateMOPixel("Particle BunkerBuster Massive", "Massive.rte");
				particle.Pos = Vector(self.Pos.X, self.Pos.Y) + Vector(2, -10 + (self.checkI - 1) * 3):RadRotate(self.RotAngle)
				particle.Vel = Vector(80, math.random(-25, 25)):RadRotate(self.RotAngle);
				particle.Team = self.Team -- the Obliterate. unfortunately.. has to discriminate.
				particle.IgnoresTeamHits = true;
				MovableMan:AddParticle(particle);
			end
			
		end
		
		if concPixels > 7 then
			self.concreteExplodeSound:Play(self.Pos);
			print("conc")
		elseif dirtPixels > 7 then
			self.dirtExplodeSound:Play(self.Pos);
			print("dirt")
		elseif sandPixels > 7 then
			self.sandExplodeSound:Play(self.Pos);
			print("sand")
		elseif solidMetalPixels > 7 then
			self.solidMetalExplodeSound:Play(self.Pos);
			print("metal")
		else
			self.neutralExplodeSound:Play(self.Pos);
		end
		
		self.shakenessParticle = CreateMOPixel("Shakeness Particle Massive", "Massive.rte");
		self.shakenessParticle.Pos = self.Pos;
		self.shakenessParticle.Mass = 80;
		self.shakenessParticle.Lifetime = 750;
		MovableMan:AddParticle(self.shakenessParticle);
		
		-- Ground Smoke
		local maxi = 25
		for i = 1, maxi do
			
			local effect = CreateMOSRotating("Ground Smoke Particle Small Massive", "Massive.rte")
			effect.Pos = self.Pos
			effect.Vel = self.Vel + Vector(math.random(90,150),0):RadRotate(math.pi * 2 / maxi * i + RangeRand(-2,2) / maxi)
			effect.Lifetime = effect.Lifetime * RangeRand(0.5,2.0)
			effect.AirResistance = effect.AirResistance * RangeRand(0.5,0.8)
			MovableMan:AddParticle(effect)
		end

		local smokeAmount = 50
		local particleSpread = 360
		
		local smokeLingering = 10
		local smokeVelocity = (1 + math.sqrt(smokeAmount / 8) ) * 0.5
		
		for i = 1, math.ceil(smokeAmount / (math.random(4,6))) do
			local spread = (math.pi * 2) * RangeRand(-1, 1) * 0.05
			local velocity = 110 * RangeRand(0.1, 0.9) * 0.4;
			
			local particle = CreateMOSParticle((math.random() * particleSpread) < 6.5 and "Tiny Smoke Ball 1" or "Small Smoke Ball 1");
			particle.Pos = self.Pos
			particle.Vel = self.Vel + Vector(velocity,0):RadRotate(self.RotAngle + spread) * smokeVelocity
			particle.Lifetime = particle.Lifetime * RangeRand(0.9, 1.6) * 0.3 * smokeLingering
			particle.AirThreshold = particle.AirThreshold * 0.5
			particle.GlobalAccScalar = 0
			MovableMan:AddParticle(particle);
		end
		
		for i = 1, 15 do
			local spread = (math.pi * 2) * RangeRand(-1, 1)
			local velocity = 30 * RangeRand(0.1, 0.9) * 0.4;
			
			local particle = CreateMOSParticle("Tiny Smoke Ball 1");
			particle.Pos = self.Pos
			particle.Vel = self.Vel + Vector(velocity,0):RadRotate(spread) * (50 * 0.2)
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

		local outdoorRays = 0;

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
		
		for _, rayLength in ipairs(self.rayTable) do
			if rayLength < 0 then
				outdoorRays = outdoorRays + 1;
			end
		end
		
		if outdoorRays >= self.rayThreshold then
			self.explodeReflectionOutdoorsSound:Play(self.Pos);
		else
			self.explodeReflectionIndoorsSound:Play(self.Pos);
		end
		
		self:GibThis();
		
	end
	
end

function OnDetach(self)
	self.parent = nil;
	self:SetOneHanded(true);
	self:RemoveNumberValue("Enter Planting Mode");
end