function Create(self)

	if string.find(self.PresetName, "Left") then
		self.leftFactor = -1;
	else
		self.leftFactor = 1;
	end

	self.detachSound = CreateSoundContainer("ArmorPlateDetach Halifax Massive", "Massive.rte");
	self.flySound = CreateSoundContainer("ArmorPlateFly Halifax Massive", "Massive.rte");
	self.terrainImpactSound = CreateSoundContainer("ArmorPlateTerrainImpact Halifax Massive", "Massive.rte");
	
	self.realWoundLimit = self.GibWoundLimit;
	

end
function Update(self)

	self.flySound.Pos = self.Pos;

	if self.WoundCount > self.realWoundLimit / 2 and self:IsAttached() then
		self:RemoveFromParent(true, true);
		self.flySound:Play(self.Pos);
		self.detachSound:Play(self.Pos);
		self.Vel = self.Vel + Vector(10 * self.leftFactor, 0);
		self.AngularVel = 12 * self.leftFactor
	end
	

end

function OnDetach(self)

	self.flySound:Play(self.Pos);
	self.detachSound:Play(self.Pos);
	self.terrainImpactToPlay = true;
	
end

function OnCollideWithTerrain(self)

	if self.terrainImpactToPlay == true then
		self.terrainImpactToPlay = false;
		self.terrainImpactSound:Play(self.Pos);
		self.flySound:FadeOut(100);
	end
end

function Destroy(self)

	self.flySound:Stop(-1);
	
end