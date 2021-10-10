function Create(self)	
	
	self.clipDropSound = CreateSoundContainer("Clip Drop Hardwall", "Massive.rte");
	

end

function OnCollideWithTerrain(self, terrainID)
	
	if self.soundPlayed ~= true then
	
		self.soundPlayed = true;
	
		self.clipDropSound:Play(self.Pos);

	end

end