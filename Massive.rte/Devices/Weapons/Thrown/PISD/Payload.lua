function Create(self)

	local payload = CreateMOSRotating("EMP Payload PISD", "Massive.rte");
	if payload then
		payload.Pos = self.Pos;
		MovableMan:AddParticle(payload);
		payload:GibThis();
	end

	self.strength = self.Mass * 160;
	self.range = self.Lifetime * 160;
	
	self.shakenessParticle = CreateMOPixel("Shakeness Particle Massive", "Massive.rte");
	self.extraSmokeParticle = CreateMOPixel("Indoor Payload PISD", "Massive.rte");

	self.explodeOutdoorsSound = CreateSoundContainer("Explode Outdoors PISD", "Massive.rte");
	self.explodeIndoorsSound = CreateSoundContainer("Explode Indoors PISD", "Massive.rte");
	
	self.indoorDebrisSound = CreateSoundContainer("Projectile Indoor Debris Duford155", "Massive.rte");
	
	self.shakenessParticle.Pos = self.Pos;
	self.shakenessParticle.Mass = 45;
	self.shakenessParticle.Lifetime = 450;
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
		self.explodeOutdoorsSound:Play(self.Pos);
	else
		self.indoorDebrisSound:Play(self.Pos);
		self.extraSmokeParticle.Pos = self.Pos;
		MovableMan:AddParticle(self.extraSmokeParticle);
		self.explodeIndoorsSound:Play(self.Pos);
	end
	
end
function Update(self)
	-- Run the effect on Update() to give other particles a chance to reach the target
	for i = 1 , MovableMan:GetMOIDCount() - 1 do
		local mo = MovableMan:GetMOFromID(i);
		if mo and mo.PinStrength == 0 then
			local dist = SceneMan:ShortestDistance(self.Pos, mo.Pos, SceneMan.SceneWrapsX);
			if dist.Magnitude < self.range then
				local strSumCheck = SceneMan:CastStrengthSumRay(self.Pos, self.Pos + dist, 3, rte.airID);
				if strSumCheck < self.strength then
					local massFactor = math.sqrt(1 + math.abs(mo.Mass));
					local distFactor = 1 + dist.Magnitude * 0.1;
					local forceVector =	dist:SetMagnitude((self.strength*2 - strSumCheck)/distFactor);
					mo.Vel = mo.Vel + ((forceVector/massFactor) / 2);
					mo.AngularVel = mo.AngularVel - forceVector.X/(massFactor + math.abs(mo.AngularVel));
					mo:AddForce(forceVector * massFactor, Vector());
					-- Add some additional points damage to actors
					if IsActor(mo) then
						local actor = ToActor(mo);
						local impulse = (forceVector.Magnitude * self.strength/massFactor) - actor.ImpulseDamageThreshold;
						local damage = impulse/(actor.GibImpulseLimit * 0.1 + actor.Material.StructuralIntegrity * 10);
						actor.Health = damage > 0 and actor.Health - damage or actor.Health;
						actor.Status = (actor.Status == Actor.STABLE and damage > (actor.Health * 0.7)) and Actor.UNSTABLE or actor.Status;
						if actor.Health < 5 then
							for attachable in actor.Attachables do
								local part = ToAttachable(attachable)
								if math.random(0, 100) < 30 then
									ToMOSRotating(actor):RemoveAttachable(part, true, true)
								elseif math.random(0, 100) < 60 then
									part:GibThis();
								end
							end
						end
					end
				end
			end
		end	
	end
	self.ToDelete = true;
end