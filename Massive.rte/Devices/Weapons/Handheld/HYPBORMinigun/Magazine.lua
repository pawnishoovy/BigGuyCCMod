function Create(self)	
	
	self.magDropSound = CreateSoundContainer("Mag Drop HYPBORMinigun", "Massive.rte");
	

end

function OnCollideWithTerrain(self, terrainID)
	
	if self.soundPlayed ~= true then
	
		self.soundPlayed = true;
	
		self.magDropSound:Play(self.Pos);

	end

end