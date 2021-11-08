function Create(self)

	self.heatNum = 0;
	
	self.heatCoolRate = 10; -- per second
	self.heatLimit = 200;
	
	self.GFXDelayMin = 300
	self.GFXDelayMax = 600
	
	self.GFXTimer = Timer()
	self.GFXDelay = math.max(50, math.random(self.GFXDelayMin, self.GFXDelayMax) - self.heatNum) 
	
end

function Update(self)
	
	-- rot angle woes forced me to put this in each gun .lua below the animation section
	
	-- if self.GFXTimer:IsPastSimMS(self.GFXDelay) then
		-- if self.heatNum > 2 then
			-- local particles = {"Tiny Smoke Ball 1"}
			
			-- if self.heatNum > 100 then
				-- table.insert(particles, "Small Smoke Ball 1")
			-- end
			
			-- for i = 1, math.random(1,3) do
				-- local particle = CreateMOSParticle(particles[math.random(1,#particles)]);
				-- particle.Lifetime = math.random(250, 600);
				-- particle.Vel = self.Vel + Vector(0, -0.1);
				-- particle.Pos = self.MuzzlePos;
				-- MovableMan:AddParticle(particle);
			-- end
				
		-- end
		
		-- self.GFXTimer:Reset()
		-- self.GFXDelay = math.max(50, math.random(self.GFXDelayMin, self.GFXDelayMax) - self.heatNum) 
	-- end
	
	if self.heatNum > self.heatLimit then
		self.heatNum = self.heatLimit;
	end
	
	local value = (1 * TimerMan.DeltaTimeSecs * self.heatCoolRate);
	self.heatNum = self.heatNum - value
	if self.heatNum < 0 then
		self.heatNum = 0;
	end
	
end