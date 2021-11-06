function OnAttach(self)

	self:EnableScript("Massive.rte/Devices/Weapons/Handheld/Hardwall/Hardwall.lua");
	
	if self.Magazine and self.Magazine.RoundCount % 2 ~= 0 then
		self.Magazine.RoundCount = self.Magazine.RoundCount - 1;
	end
	
	if self:GetRootParent().PresetName == "Massive" or self:GetRootParent().PresetName == "Zedmassive" then
		self.equippedByMassive = true;
	else
		self.equippedByMassive = false;
	end
	
end