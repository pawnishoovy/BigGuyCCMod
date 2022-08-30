function Create(self)

	self.shakeTable = {}
	for actor in MovableMan.Actors do
		actor = ToActor(actor)
		table.insert(self.shakeTable, actor);
	end
	
	self.shake = 160
	
	self.soundFlyLoop = CreateSoundContainer("Shell Flying Duford155", "Massive.rte");
	self.soundFlyLoop.Volume = 0.5;
	self.soundFlyLoop:Play(self.Pos);
	
	self.soundFlyBy = CreateSoundContainer("Shell FlyBy Duford155", "Massive.rte");
	self.soundFlyBy.AttenuationStartDistance = 30
	
	self.flyby = true
	self.flybyTimer = Timer()

	self.boosterTimer = Timer()
	self.booster = false
	
	self.igniteIndoorsSound = CreateSoundContainer("Rocket Ignite Indoors Massive MCAD", "Massive.rte");
	self.igniteOutdoorsSound = CreateSoundContainer("Rocket Ignite Outdoors Massive MCAD", "Massive.rte");
	
	for i = 1, math.random(2,6) do
		local poof = CreateMOSParticle(math.random(1,2) < 2 and "Tiny Smoke Ball 1" or "Small Smoke Ball 1");
		poof.Pos = self.Pos
		poof.Vel = Vector(self.Vel.X, self.Vel.Y):RadRotate(math.pi * RangeRand(-1, 1) * 0.05) * RangeRand(0.1, 0.9) * 0.6;
		poof.Lifetime = poof.Lifetime * RangeRand(0.9, 1.6) * 0.6
		MovableMan:AddParticle(poof);
	end
	for i = 1, math.random(2,4) do
		local poof = CreateMOSParticle("Small Smoke Ball 1");
		poof.Pos = self.Pos
		poof.Vel = (Vector(self.Vel.X, self.Vel.Y):RadRotate(math.pi * (math.random(0,1) * 2.0 - 1.0) * 2.5 + math.pi * RangeRand(-1, 1) * 0.15) * RangeRand(0.1, 0.9) * 0.6 + Vector(self.Vel.X, self.Vel.Y):RadRotate(math.pi * RangeRand(-1, 1) * 0.15) * RangeRand(0.1, 0.9) * 0.2) * 0.5;
		poof.Lifetime = poof.Lifetime * RangeRand(0.9, 1.6) * 0.6
		MovableMan:AddParticle(poof);
	end
	for i = 1, 3 do
		local poof = CreateMOSParticle("Explosion Smoke 2");
		poof.Pos = self.Pos
		poof.Vel = Vector(self.Vel.X, self.Vel.Y):RadRotate(RangeRand(-1, 1) * 0.15) * RangeRand(0.9, 1.6) * 0.66 * i;
		poof.Lifetime = poof.Lifetime * RangeRand(0.8, 1.6) * 0.1 * i
		MovableMan:AddParticle(poof);
	end
end
function Update(self)

	self.soundFlyLoop.Pos = self.Pos;

	--Flyby sound (epic haxx)
	if self.flyby and self.flybyTimer:IsPastSimMS(80) then
		--local cameraPos = Vector(SceneMan:GetScrollTarget(0).X, SceneMan:GetScrollTarget(0).Y)
		
		local controlledActor = ActivityMan:GetActivity():GetControlledActor(0);
		
		if controlledActor then
		
			local distA = SceneMan:ShortestDistance(self.Pos,controlledActor.Pos,SceneMan.SceneWrapsX).Magnitude
			local vectorA = SceneMan:ShortestDistance(self.Pos,controlledActor.Pos,SceneMan.SceneWrapsX)
			local distAMin = math.random(100,200)		
			
			if distA < distAMin and SceneMan:CastObstacleRay(self.Pos, vectorA, Vector(0, 0), Vector(0, 0), controlledActor.ID, -1, 128, 8) < 0 then
				self.flyby = false
				
				self.soundFlyBy:Play(controlledActor.Pos);
			else
				local offset = Vector(self.Vel.X, self.Vel.Y) * RangeRand(0.2,1.0)
				local distB = SceneMan:ShortestDistance(self.Pos + offset,controlledActor.Pos,SceneMan.SceneWrapsX).Magnitude
				local distBMin = math.random(80,160)
				if distB < distBMin and SceneMan:CastObstacleRay(self.Pos, vectorA, Vector(0, 0), Vector(0, 0), controlledActor.ID, -1, 128, 8) < 0 then
					self.flyby = false
					
					self.soundFlyBy:Play(controlledActor.Pos);
					
				end
			end
		end
		
		local s = self.UniqueID % 7 + 1
		--PrimitiveMan:DrawCirclePrimitive(cameraPos, s, 5)
	end		

	local factor = 1
	
	-- Shake
	if self.shakeTable then
		for i = 1, #self.shakeTable do
			local actor = self.shakeTable[i];
			if actor and IsActor(actor) then
				actor = ToActor(actor)
				local dist = SceneMan:ShortestDistance(self.Pos, actor.Pos, SceneMan.SceneWrapsX).Magnitude
				local distFactor = math.sqrt(dist * 0.03)
				
				actor.ViewPoint = actor.ViewPoint + Vector(self.shake * RangeRand(-1, 1), self.shake * RangeRand(-1, 1)) * factor / distFactor;
			end
		end
	end

	if self.boosterTimer:IsPastSimMS(0) then
		self:EnableEmission(true)
		if not self.booster then
			for i = 1, 6 do
				local poof = CreateMOSParticle("Explosion Smoke Small");
				poof.Pos = self.Pos + Vector(0, 3)-- * self.FlipFactor):RadRotate(self.RotAngle)
				poof.Vel = Vector(self.Vel.X, self.Vel.Y):RadRotate(RangeRand(-1, 1) * 0.03) * RangeRand(0.9, 1.6) * 0.99 * (i-3);
				poof.Lifetime = poof.Lifetime * RangeRand(0.8, 1.6) * 0.1 * i
				poof.GlobalAccScalar = 0
				poof.AirResistance = poof.AirResistance * 1
				MovableMan:AddParticle(poof);
			end
			self.booster = true
			
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
				self.igniteOutdoorsSound:Play(self.Pos);
			else
				self.igniteIndoorsSound:Play(self.Pos);
			end			
			
		end
	else
		self:EnableEmission(false)
	end
end

function Destroy(self)

	self.soundFlyLoop:Stop(-1);
	
end