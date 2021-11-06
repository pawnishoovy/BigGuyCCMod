function OnAttach(self)

	self.TheViolence = CreateSoundContainer("Brewing Homage", "Massive.rte");
	self.TheViolence.Volume = 0;
	self.IsEscalating = CreateSoundContainer("Storm Homage", "Massive.rte");
	self.IsEscalating.Immobile = true;
	self:EnableScript("Massive.rte/Devices/Weapons/Handheld/Homage/Homage.lua");
	
	if self:GetRootParent().PresetName == "Massive" or self:GetRootParent().PresetName == "Zedmassive" then
		self.equippedByMassive = true;
	else
		self.equippedByMassive = false;
	end
	
end

function Destroy()

	self.TheViolence:Stop(-1);
	self.IsEscalating:Stop(-1);
	
end