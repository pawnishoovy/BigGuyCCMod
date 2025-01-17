function Create(self)

	-- detect indoors/outdoors, weaken range if outdoors

	local outdoorRays = 0;	
	local indoorRays = 0;

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
		else
			indoorRays = indoorRays + 1;
		end
	end
	
	if outdoorRays > indoorRays then
		self.range = 2.5 * self.Vel.Magnitude;
		self.Outdoors = true;
	else
		self.range = 5 * self.Vel.Magnitude;
	end

	self.strength = self.Mass * self.Vel.Magnitude;
	
	local maxi = 1	
	
	maxi = 240
	for i = 1, maxi do
		local effect = CreateMOPixel("Shockwave Blast PISD", "Massive.rte")
		effect.Pos = self.Pos + Vector(RangeRand(-1,1), RangeRand(-1,1)) * 3
		effect.Vel = Vector(self.Vel.Magnitude * RangeRand(0.95,1.05) * 2,0):RadRotate(math.pi * 2 / maxi * i + RangeRand(-1,1) / maxi)
		effect.Lifetime = effect.Lifetime * math.random(1,4) * 0.5
		MovableMan:AddParticle(effect)
	end
	
	self.flash = true
end
function Update(self)
	--PrimitiveMan:DrawCirclePrimitive(self.Pos, self.range, 5)
	
	-- Run the effect on Update() to give other particles a chance to reach the target
	if self.flash then
		for mo in MovableMan:GetMOsInRadius(self.Pos, self.range, self.Team, true) do
			if IsActor(mo) then
				local actor = ToActor(mo)
				local dist = nil
				if actor.Head then
					dist = SceneMan:ShortestDistance(self.Pos, actor.Head.Pos, SceneMan.SceneWrapsX);
				else
					dist = SceneMan:ShortestDistance(self.Pos, actor.Pos, SceneMan.SceneWrapsX);
				end
				local canFlash = false
				if SceneMan:CastStrengthSumRay(self.Pos, self.Pos + dist, 3, 0) < self.strength then
					canFlash = true
				end
				
				if canFlash and actor.ClassName ~= "ADoor" and actor.ClassName ~= "ACraft" then
					if not self.flashedActors then
						self.flashedActors = {}
					end
					if actor.Status == 0 and IsAHuman(actor) then
						actor.Status = 1
					end
					if not self.Outdoors then -- only drop gun if we are indoors
						if math.random(1,3) < 2 and actor:GetController() then
							actor:GetController():SetState(Controller.WEAPON_DROP,true)
						end
					end
					actor:SetNumberValue("Flashed", 1)
					
					table.insert(self.flashedActors, actor.UniqueID)
				end
			end
		end
		
		self.flash = false
	end
	if self.flashedActors then
		for i, ID in ipairs(self.flashedActors) do
			local actor = MovableMan:FindObjectByUniqueID(ID)
			if actor then
				actor = ToActor(actor)
				if actor.Status == 0 and IsAHuman(actor) then
					actor.Status = 1
				end
				local ctrl = actor:GetController()
				if ctrl then
					ctrl:SetState(Controller.WEAPON_FIRE,false)
					ctrl:SetState(Controller.AIM_SHARP,false)
					ctrl:SetState(Controller.MOVE_LEFT,false);
					ctrl:SetState(Controller.MOVE_RIGHT,false);
				end
			end
		end
	end
	--self.ToDelete = true;
end