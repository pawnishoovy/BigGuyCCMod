function OnAttach(self)

	self:EnableScript("Massive.rte/Devices/Weapons/Handheld/Brutum/Brutum.lua");
	
	if self:GetRootParent().PresetName == "Massive" or self:GetRootParent().PresetName == "Zedmassive" then
		self.equippedByMassive = true;
	else
		self.equippedByMassive = false;
	end
	
end