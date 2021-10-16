function Create(self)

	self.failedSound = CreateSoundContainer("EngineFailure Halifax Massive", "Massive.rte");

	self.failedBurnLoopSound = CreateSoundContainer("EngineFailedBurnRightLoop Halifax Massive", "Massive.rte");
	self.engineFailed = false;
	
	self.height = ToMOSprite(self):GetSpriteHeight();
	self.width = ToMOSprite(self):GetSpriteWidth();
	
	self.realWoundLimit = self.GibWoundLimit;
	
	self.terrainImpactSlowSound = CreateSoundContainer("TerrainImpactSlow Halifax Massive", "Massive.rte");
	self.terrainImpactFastSound = CreateSoundContainer("TerrainImpactFast Halifax Massive", "Massive.rte");	
	
	self.terrainImpactSoundTimer = Timer()
end
function Update(self)

	if not self:IsAttached() and self.TravelImpulse.Magnitude > 1000 and self.terrainImpactSoundTimer:IsPastSimMS(300) then

		if self.TravelImpulse.Magnitude > 2500 then -- Hit
			self.terrainImpactFastSound:Play(self.Pos);
			self.terrainImpactSoundTimer:Reset()
		else
			self.terrainImpactSlowSound:Play(self.Pos);
			self.terrainImpactSoundTimer:Reset()
		end
	end

	self.failedSound.Pos = self.Pos;

	if self.WoundCount > self.realWoundLimit / 2 and self.engineFailed == false then
		self.failedSound:Play(self.Pos);
		self.engineFailed = true;
		self.EmissionSound:Stop(-1);
		self.EmissionSound = self.failedBurnLoopSound;
		self.EmissionSound:Play(self.Pos);
		
		if self:GetParent() then
			self:GetParent():SetNumberValue("Engine Right Failed", 1);
		end				
		
		local explosion = CreateAEmitter("Halifax Engine Fail Explosion");
		explosion.Pos = self.Pos + Vector(self.width * 0.5 * RangeRand(-0.9, 0.9), self.height * 0.5 * RangeRand(-0.9, 0.9)):RadRotate(self.RotAngle);
		explosion.Vel = self.Vel;
		MovableMan:AddParticle(explosion);
	end
	
	
	if self.engineFailed == true then
		self.Throttle = math.min(0.4, math.max(-1, self.Throttle - 0.285));
	end

end