function Create(self)
	self.parentSet = false;
	self.parentHuman = false
	
	self.Heat = 0
	self.HeatMax = 100
	self.HeatLast = 0
	
	self.HeatOverheatThreshold = self.HeatMax * 0.9
	self.HeatDamageAccumulated = 0
	self.HeatDamageAccumulatedMax = 15
	self.HeatDamage = 2
	
	self.HeatBurning = false
	
	self.GFXDelayMin = 100
	self.GFXDelayMax = 300
	
	self.GFXTimer = Timer()
	self.GFXDelay = math.random(self.GFXDelayMin, self.GFXDelayMax)
	
	self.HeatDissipateTimer = Timer()
end
function Update(self)
	--PrimitiveMan:DrawCirclePrimitive(self.Pos, 13, 162)
	
	if not self:IsAttached() then
		self.parent = nil;
		self.parentSet = false;
	elseif self.parentSet == false then
		local actor = self:GetParent()
		if actor then
			if IsAHuman(actor) then
				self.parent = ToAHuman(actor);
				self.parentSet = true;
				self.parentHuman = true;
			elseif IsACrab(actor) then
				self.parent = ToACrab(actor);
				self.parentSet = true;
			end
		end
	end
	
	if self.parent then
		self.Heat = self.parent:GetNumberValue("ActorHeat")
		
		self.Heat = math.min(self.Heat, self.HeatMax)
		--PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(-20, 20), "HEAT = ".. math.floor(self.Heat), true, 0)
		
		if self.Heat > self.HeatLast then
			self.HeatDamageAccumulated = self.HeatDamageAccumulated + math.abs(self.Heat - self.HeatLast)
			
			self.HeatLast = self.Heat
			
			self.HeatDissipateTimer:Reset()
		elseif self.Heat < self.HeatLast then
			self.HeatLast = self.Heat
		end
		self.HeatDamageAccumulated = self.HeatDamageAccumulated + self.Heat * TimerMan.DeltaTimeSecs
		
		if self.parent.Status ~= Actor.DEAD and self.parent.Status ~= Actor.DYING then
			--HeatIncrease
			if self.HeatBurning then
				self.parent.Health = self.parent.Health - 30.0 * TimerMan.DeltaTimeSecs
				if self.parentHuman then
					if self.parent.FGArm then
						ToArm(self.parent.FGArm).IdleOffset = Vector(30 * RangeRand(0.5, 1), 0):RadRotate(RangeRand(-1, 1) * math.pi * 0.4)
					end
					if self.parent.BGArm then
						ToArm(self.parent.BGArm).IdleOffset = Vector(30 * RangeRand(0.5, 1), 0):RadRotate(RangeRand(-1, 1) * math.pi * 0.4)
					end
					self.parent.AngularVel = self.parent.AngularVel + RangeRand(-1, 1) * 90 * TimerMan.DeltaTimeSecs
				end
			elseif self.Heat > self.HeatOverheatThreshold then -- Overheat instakill
				self.parent:SetNumberValue("Death By Fire", self.Heat)
				self.HeatBurning = true
			elseif self.HeatDamageAccumulated > self.HeatDamageAccumulatedMax then
				self.parent.Health = self.parent.Health - (self.HeatDamageAccumulated / self.HeatDamageAccumulatedMax) * self.HeatDamage
				self.HeatDamageAccumulated = 0
				
				if self.parent.Health < 1 or self.parent.Status == Actor.DEAD or self.parent.Status == Actor.DYING then
					self.parent:SetNumberValue("Death By Fire", self.Heat)
				end
				
				self.parent:SetNumberValue("Burn Pain", self.Heat)
				self.parent:FlashWhite(30)
			end
		end
		
		if self.GFXTimer:IsPastSimMS(self.GFXDelay) then
			if self.Heat > 5 and IsAHuman(self.parent) then
				local MOs
				local particles = {"Flame Smoke 2"}
				
				if self.parentHuman then
					MOs = {self.parent.FGFoot, self.parent.BGFoot}
				else
					MOs = {self.parent}
				end
				
				if self.parentHuman and self.Heat > 25 then
					table.insert(MOs, self.parent.FGLeg)
					table.insert(MOs, self.parent.BGLeg)
				end
				if self.Heat > 60 then
					if self.parentHuman then
						table.insert(MOs, self.parent)
					end
					
					table.insert(particles, "Explosion Smoke 1")
				end
				if self.Heat > 75 then
					if self.parentHuman then
						table.insert(MOs, self.parent.FGArm)
						table.insert(MOs, self.parent.BGArm)
					end
					
					table.insert(particles, "Explosion Smoke 1")
					table.insert(particles, "Flame Smoke 2 Glow B")
				end
				
				if self.Heat > 90 then
					if self.parentHuman then
						table.insert(MOs, self.parent.Head)
					end
					table.insert(particles, "Explosion Smoke 1")
				end
				
				for i, MO in ipairs(MOs) do
					if MO then
						for i = 1, math.random(1,3) do
							local particle = CreateMOSParticle(particles[math.random(1,#particles)]);
							particle.Lifetime = math.random(250, 600);
							particle.Vel = MO.Vel + Vector(0, -1);
							particle.Vel = particle.Vel + Vector(math.random() * self.Heat * 0.03, 0):RadRotate(math.random() * 6.28);
							particle.Pos = Vector(MO.Pos.X + math.random(-2, 2), MO.Pos.Y - math.random(0, 4));
							MovableMan:AddParticle(particle);
						end
						MO.Pos = MO.Pos + Vector(RangeRand(-1, 1), RangeRand(-1, 1)) * 1
						if self.Heat > 80 and math.random(0,2) < 1 then
							local particle = CreatePEmitter("Flame Hurt Short Float");
							particle.Lifetime = math.random(100, 1000);
							particle.Vel = MO.Vel + Vector(0, -1);
							particle.Vel = particle.Vel + Vector(math.random() * 4, 0):RadRotate(math.random() * 6.28);
							particle.Pos = Vector(MO.Pos.X + math.random(-2, 2), MO.Pos.Y - math.random(0, 4));
							MovableMan:AddParticle(particle);
						end
					end
					
				end
			end
			
			self.GFXTimer:Reset()
			self.GFXDelay = math.random(self.GFXDelayMin, self.GFXDelayMax)
		end
		
		if self.HeatDissipateTimer:IsPastSimMS(300) and not (self.HeatBurning and self.parent.Health > 0) then
			self.Heat = self.Heat / (1 + TimerMan.DeltaTimeSecs * 1.3) -- Slowly Reduce Heat
			
			if self.Heat < 1 then
				self.parent:RemoveNumberValue("ActorHeat")
				self.ToDelete = true
			end
		end
		
		if not self.ToDelete then
			self.parent:SetNumberValue("ActorHeat", self.Heat)
		end
	else
		self.ToDelete = true
	end
end