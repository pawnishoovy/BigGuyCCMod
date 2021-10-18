function Create(self)

	local Sound = CreateSoundContainer("Turret Fire Halifax Massive", "Massive.rte");
	Sound:Play(self.Pos);
	
	local particle = CreateMOPixel("Bullet Halifax Massive", "Massive.rte");
	particle.Vel = self.Vel;
	particle.Pos = self.Pos;
	particle.Team = self.Team;
	MovableMan:AddParticle(particle)
	
end