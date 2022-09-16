function Create(self)
	self.deviation = 50
	
	self.deviationTimer = Timer()
	self.deviationDelayMin = 13
	self.deviationDelayMax = 200
	self.deviationDelay = RangeRand(self.deviationDelayMin, self.deviationDelayMax)
	
	self.smokeTrailLifeTime = 5000;
	self.smokeTrailTwirl = 0.0;
	
	self.smokeTwirlCounter = math.random() < 0.5 and math.pi or 0;
	
	self.trailAcc = 0
end

function Update(self)
	if self.deviationTimer:IsPastSimMS(self.deviationDelay) then
		self.deviationTimer:Reset()
		self.deviationDelay = RangeRand(self.deviationDelayMin, self.deviationDelayMax)
		self.Vel = Vector(self.Vel.X, self.Vel.Y):DegRotate(self.deviation * RangeRand(-0.5, 0.5))
	end
	
	local offset = self.Vel * GetPPM() * TimerMan.DeltaTimeSecs;	--The effect will be created the next frame so move it one frame backwards towards the barrel
	
	local length = offset.Magnitude
	if math.abs(self.Vel.X) > self.AirThreshold * 2 or math.abs(self.Vel.Y) > self.AirThreshold * 2 then
		
		self.trailAcc = self.trailAcc + length * 0.5
		local trailLength = math.floor(self.trailAcc);
		self.trailAcc = self.trailAcc - trailLength
		
		for i = 1, trailLength do
			local effect = CreateMOSParticle("Flame Smoke 1 Micro", "Base.rte");
			effect.Pos = self.Pos - (offset * i/trailLength);
			effect.Vel = self.Vel * RangeRand(0.0, 0.1);
			effect.Lifetime = math.max(self.smokeTrailLifeTime * RangeRand(0.5, 1) * ((self.Age / self.Lifetime)), 1)-- * (self.Lifetime > 1 and 1 - self.Age/self.Lifetime or 1);
			effect.AirResistance = self.AirResistance;
			effect.AirThreshold = self.AirThreshold;
		
			if self.smokeTrailTwirl > 0 then
				effect.GlobalAccScalar = effect.GlobalAccScalar * math.random();

				effect.Pos = self.Pos - offset + (offset * i/trailLength);
				effect.Vel = self.Vel + Vector(0, math.sin(self.smokeTwirlCounter) * self.smokeTrailTwirl + RangeRand(-0.1, 0.1)):RadRotate(self.Vel.AbsRadAngle);
				
				self.smokeTwirlCounter = self.smokeTwirlCounter + RangeRand(-0.2, 0.4);
			end
			MovableMan:AddParticle(effect);
		end
	end
end