
function Create(self)

	-- Ground Smoke
	local maxi = 60
	for i = 1, maxi do
		
		local effect = CreateMOSRotating("Ground Smoke Particle HYPBORMinigun", "Massive.rte")
		effect.Pos = self.Pos
		effect.Vel = self.Vel + Vector(math.random(90,150),0):RadRotate(math.pi * 2 / maxi * i + RangeRand(-2,2) / maxi)
		effect.Lifetime = effect.Lifetime * 8
		effect.AirResistance = effect.AirResistance * RangeRand(0.5,0.8)
		MovableMan:AddParticle(effect)
	end
	
	self.ToDelete = true;
	
end