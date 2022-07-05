function Create(self)

	self.RotAngle = 0;
	self.RotAngleVel = 0;
	
	self.parent = nil;
end

function Update(self)
	
	
	if self.parent == nil then
		mo = self:GetParent()
		if mo and IsHeldDevice(mo) then
			self.parent = ToHeldDevice(mo);
		end

	elseif IsHeldDevice(self.parent) then
		local rotationFactor = self.parent:NumberValueExists("BarrelRotation") and self.parent:GetNumberValue("BarrelRotation") or 0
		
		local targetAngle = self.parent.RotAngle - math.rad(70) * rotationFactor * self.FlipFactor
		
		local min_value = -math.pi
		local max_value = math.pi
		local value = targetAngle - self.RotAngle
		local result
		
		local range = max_value - min_value
		local ret = (value - min_value) % range
		if ret < 0 then ret = ret + range end
		result = ret + min_value
		
		
		local a = 48
		local b = 80
		
		self.RotAngleVel = (self.RotAngleVel + result * TimerMan.DeltaTimeSecs * a) / (1 + TimerMan.DeltaTimeSecs * a)
		--self.RotAngle = self.RotAngle + self.RotAngleVel * TimerMan.DeltaTimeSecs * b -- Interpolate 
		
		-- self.JointOffset.X = -8 + 5 * (rotationFactor)
		
		self.InheritedRotAngleOffset = self.InheritedRotAngleOffset + self.RotAngleVel * TimerMan.DeltaTimeSecs * b * self.FlipFactor
	end
end