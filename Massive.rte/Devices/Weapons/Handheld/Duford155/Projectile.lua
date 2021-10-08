
function Create(self)
	
	self.hitMOTable = {}
	
	self.soundFlyLoop = CreateSoundContainer("Shell Flying Duford155", "Massive.rte");
	self.soundFlyLoop:Play(self.Pos);
	
	self.explodeCoreSound = CreateSoundContainer("Explode Core Duford155", "Massive.rte");
	self.explodeFlavorSound = CreateSoundContainer("Explode Flavor Duford155", "Massive.rte");
	self.explodeReflectionOutdoorsSound = CreateSoundContainer("Explode Reflection Outdoors Duford155", "Massive.rte");
	self.explodeReflectionIndoorsSound = CreateSoundContainer("Explode Reflection Indoors Duford155", "Massive.rte");

end

function Update(self)
	self.soundFlyLoop.Pos = self.Pos;
	
	if self.Vel.Magnitude > 40 then -- Raycast, stick to things
		local rayOrigin = self.Pos
		local rayVec = Vector(self.Vel.X,self.Vel.Y):SetMagnitude(self.Vel.Magnitude * rte.PxTravelledPerFrame + self.IndividualRadius);
		local moCheck = SceneMan:CastMORay(rayOrigin, rayVec, self.ID, self.Team, 0, false, 2); -- Raycast
		if moCheck ~= rte.NoMOID then	
			local rayHitPos = SceneMan:GetLastRayHitPos()
			local MO = MovableMan:GetMOFromID(moCheck)
			if IsMOSRotating(MO) then
				local hitAllowed = true;
				if self.hitMOTable then -- this shouldn't be needed but it is
					for index, root in pairs(self.hitMOTable) do
						if root == MO:GetRootParent().UniqueID or index == MO.UniqueID then
							hitAllowed = false;
						end
					end
				end
				if hitAllowed == true then
					MO = ToMOSRotating(MO);
					self.hitMOTable[MO.UniqueID] = MO:GetRootParent().UniqueID;
					
					local addWounds = true
					
					-- if we can gib just gib and move on with our 155mm lives, but if not...
					local lessVel = Vector(self.Vel.X, self.Vel.Y):SetMagnitude(self.Vel.Magnitude/5);
					if MO.WoundCount + 30 >= MO.GibWoundLimit then
						MO:GibThis();
						addWounds = false;
						rootMO.Vel = rootMO.Vel + lessVel
					else
						self.soundFlyLoop:Stop(-1);
						self:GibThis();
					end
					
					if addWounds == true then
						-- Damage, create a pixel that makes a hole
						for i = 0, 30 do
							local pixel = CreateMOPixel("Duford155 Damage Particle", "Massive.rte");
							pixel.Vel = self.Vel;
							pixel.Pos = self.Pos - Vector(self.Vel.X,self.Vel.Y):SetMagnitude(self.IndividualRadius * 0.9);
							pixel.Team = self.Team;
							pixel.IgnoresTeamHits = true;
							MovableMan:AddParticle(pixel);
						end
					end

				end
			end	
		end
	end
end
	
function OnCollideWithTerrain(self, terrainID)
	self:GibThis();
end

function OnCollideWithMO(self, MO, rootMO)

	if IsMOSRotating(MO) then
		local hitAllowed = true;
		if self.hitMOTable then -- this shouldn't be needed but it is
			for index, root in pairs(self.hitMOTable) do
				if root == MO:GetRootParent().UniqueID or index == MO.UniqueID then
					hitAllowed = false;
				end
			end
		end
		if hitAllowed == true then
			MO = ToMOSRotating(MO);
			self.hitMOTable[MO.UniqueID] = MO:GetRootParent().UniqueID;
			
			local addWounds = true
			
			local actorHit = rootMO
			if (actorHit and IsActor(actorHit)) then
		
				if IsAttachable(MO) and ToAttachable(MO):IsAttached() and (IsArm(MO) or IsLeg(MO) or (IsAHuman(actorHit) and ToAHuman(actorHit).Head and MO.UniqueID == ToAHuman(actorHit).Head.UniqueID)) then
					-- if we can gib just gib and move on with our 155mm lives, but if not...
					local lessVel = Vector(self.Vel.X, self.Vel.Y):SetMagnitude(self.Vel.Magnitude/5);
					if MO.WoundCount + 30 >= MO.GibWoundLimit then
						MO:GibThis();
						addWounds = false;
						rootMO.Vel = rootMO.Vel + lessVel
					else
						self.soundFlyLoop:Stop(-1);
						self:GibThis();
					end
				end
				
			end
			
			if addWounds == true then
				-- Damage, create a pixel that makes a hole
				for i = 0, 30 do
					local pixel = CreateMOPixel("Duford155 Damage Particle", "Massive.rte");
					pixel.Vel = self.Vel;
					pixel.Pos = self.Pos - Vector(self.Vel.X,self.Vel.Y):SetMagnitude(self.IndividualRadius * 0.9);
					pixel.Team = self.Team;
					pixel.IgnoresTeamHits = true;
					MovableMan:AddParticle(pixel);
				end
			end

		end
	end

end

function Destroy(self)
	self.soundFlyLoop:Stop(-1);
	
	local smokeAmount = 50
	local particleSpread = 25
	
	local smokeLingering = 10
	local smokeVelocity = (1 + math.sqrt(smokeAmount / 8) ) * 0.5
	
	local shakenessParticle = CreateMOPixel("Shakeness Particle Mhati999", "Massive.rte");
	shakenessParticle.Pos = self.Pos;
	shakenessParticle.Mass = 45;
	shakenessParticle.Lifetime = 750;
	MovableMan:AddParticle(shakenessParticle);
	
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
	
	for i = 1, 15 do
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
		--

	if not self.ToSettle then

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
		
		self.explodeCoreSound:Play(self.Pos);
		
		if outdoorRays >= self.rayThreshold then
			self.explodeReflectionOutdoorsSound:Play(self.Pos);
			self.explodeFlavorSound:Play(self.Pos);
		else
			self.explodeReflectionIndoorsSound:Play(self.Pos);
		end
		
	end	
	
end