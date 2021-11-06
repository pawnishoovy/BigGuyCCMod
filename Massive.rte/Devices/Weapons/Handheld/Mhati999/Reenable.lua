function OnAttach(self)

	self:EnableScript("Massive.rte/Devices/Weapons/Handheld/Mhati999/Mhati999.lua");
	
	if self:GetRootParent().PresetName == "Massive" or self:GetRootParent().PresetName == "Zedmassive" then
		self.equippedByMassive = true;
	else
		self.equippedByMassive = false;
	end
	
end