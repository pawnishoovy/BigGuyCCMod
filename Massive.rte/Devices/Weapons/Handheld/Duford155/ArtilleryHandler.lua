function Create(self)

	print("creat")

	self.groundPos = SceneMan:MovePointToGround(self.Pos, 50, 50);

	self.angleDeviation = 0;
	
	if self.Mass > 90 then -- leftwards
		self.angleDeviation = (self.Mass - 90) * -1;
	elseif self.Mass < 90 then
		self.angleDeviation = 90 - self.Mass;
	end
	
	print(self.angleDeviation)
	
	local upNum = self.Pos.Y - self.groundPos.Y;
	local upVector = Vector(0, upNum)
	local angledVector = upVector:DegRotate(self.angleDeviation);
	-- this rotated vector is now definitely below where we actually want it. hopefully. definitely hopefully.
	angledVector = Vector(angledVector.X * 4, angledVector.Y) -- it seems to undercorrect and i suck at angle math so have this bodge
	angledVector = angledVector:SetMagnitude(angledVector.Magnitude * (self.Pos.Y / angledVector.Y))
	self.finalShotVector = Vector(self.Pos.X + angledVector.X, self.Pos.Y);
	print(self.finalShotVector)
	if SceneMan.SceneWrapsX == true then
		self.finalShotVector = Vector(self.finalShotVector.X % SceneMan.SceneWidth, self.finalShotVector.Y);
	end
	
	self.extraIncomingDelay = 700 * (math.abs(self.angleDeviation) / 90)

	self.Timer = Timer();
	
	self.shellIncomingSound = CreateSoundContainer("Shell Incoming Duford155", "Massive.rte");

end

function Update(self)

	if self.Timer:IsPastSimMS(5000) and self.shot ~= true then
		
		self.shot = true;
		local shot = CreateMOSRotating("Duford155 Shot", "Massive.rte");
		
		shot.Pos = self.finalShotVector
		shot.Sharpness = 0;
		shot.Vel = Vector(0, 150):DegRotate(self.angleDeviation);

		MovableMan:AddParticle(shot);
		
		self.ToDelete = true;
		self.LifeTime = 1;
		
	elseif self.Timer:IsPastSimMS(3200 + self.extraIncomingDelay) and self.soundPlayed ~= true then
	
		self.soundPlayed = true;
		self.shellIncomingSound:Play(self.groundPos);
		
	end

end

function Destroy(self)

	print(self.WentToOrbit)
	
end