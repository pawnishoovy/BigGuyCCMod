function Create(self)

	self.activateSound = CreateSoundContainer("Activate PISD", "Massive.rte");
	self.throwSound = CreateSoundContainer("Throw PISD", "Massive.rte");
	
	self.flyLoop = CreateSoundContainer("Fly Loop PISD", "Massive.rte");
	
	self.activated = false;
	
end

function Update(self)

	self.flyLoop.Pos = self.Pos;
	
	self.flyLoop.Volume = math.min(self.Vel.Magnitude / 25, 0.95) + 0.05;
	self.flyLoop.Pitch = (self.Vel.Magnitude / 25) + 0.5;

	if self:IsActivated() and self.activated == false then
		self.activateSound:Play(self.Pos);
		self.activated = true;
		
		self.flyLoop:Play(self.Pos);
		
		self.GibImpulseLimit = 1
		
	end
	
end

function OnDetach(self)

	if self.activated then
		self.throwSound:Play(self.Pos);
	end
end

function Destroy(self)

	self.flyLoop:Stop(-1);

end