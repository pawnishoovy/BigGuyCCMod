function Create(self)

	self.Timer = Timer();
	
	self.terrainImpactSound = CreateSoundContainer("CompartmentTerrainImpact Halifax Massive", "Massive.rte");
	
end

function Update(self)

	if self.Timer:IsPastSimMS(1000) then
		self.GetsHitByMOs = true;
	end
	
end

function OnCollideWithTerrain(self)

	if self.terrainImpactPlayed ~= true then
		self.terrainImpactPlayed = true;
		self.terrainImpactSound:Play(self.Pos);
	end
end