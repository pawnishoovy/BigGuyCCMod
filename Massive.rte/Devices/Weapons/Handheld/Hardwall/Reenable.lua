function OnAttach(self)

	self:EnableScript("Massive.rte/Devices/Weapons/Handheld/Hardwall/Hardwall.lua");
	
	if self.Magazine and self.Magazine.RoundCount % 2 ~= 0 then
		self.Magazine.RoundCount = self.Magazine.RoundCount - 1;
	end
	
end