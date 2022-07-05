function Create(self)

	self.RotAngle = 0;
	self.RotAngleVel = 0;
	
	self.parent = nil;
	
	self.jiggle = 0
end

function Update(self)
	
	
	if self.parent == nil then
		mo = self:GetRootParent()
		if mo and IsActor(mo) then
			self.parent = ToActor(mo);
		end

	elseif IsActor(self.parent) then
		local targetAngle = self.parent.RotAngle
		
		self.jiggle = self.jiggle + TimerMan.DeltaTimeSecs * math.abs(self.parent.Vel.Y)
		
		targetAngle = targetAngle + math.rad(10) * math.sin(self.jiggle) + math.rad(5) * math.cos(self.jiggle * 3 + 2) + math.rad(5) * math.sin(self.jiggle * 0.3 + 0.2) - math.rad(10) * math.sin(-self.jiggle * 0.1 - 5.2)
		
		--if not self.parent:GetController():IsState(Controller.MOVE_LEFT) and not self.parent:GetController():IsState(Controller.MOVE_RIGHT) then
		--	targetAngle = targetAngle + math.rad(10) * self.parent.Vel.X
		--end
		
		local min_value = -math.pi
		local max_value = math.pi
		local value = targetAngle - self.RotAngle
		local result
		
		local range = max_value - min_value
		local ret = (value - min_value) % range
		if ret < 0 then ret = ret + range end
		result = ret + min_value
		
		
		local a = 24
		local b = 30
		
		self.RotAngleVel = (self.RotAngleVel + result * TimerMan.DeltaTimeSecs * a) / (1 + TimerMan.DeltaTimeSecs * a)
		self.InheritedRotAngleOffset = self.InheritedRotAngleOffset + self.RotAngleVel * TimerMan.DeltaTimeSecs * b * self.FlipFactor
	end
end