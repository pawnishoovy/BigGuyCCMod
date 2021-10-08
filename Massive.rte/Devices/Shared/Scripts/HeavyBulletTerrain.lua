function Create(self)

	self.terrainSounds = {
	Impact = {[12] = CreateSoundContainer("Heavy Bullet Impact Concrete Massive", "Massive.rte"),
			[164] = CreateSoundContainer("Heavy Bullet Impact Concrete Massive", "Massive.rte"),
			[177] = CreateSoundContainer("Heavy Bullet Impact Concrete Massive", "Massive.rte"),
			[9] = CreateSoundContainer("Heavy Bullet Impact Dirt Massive", "Massive.rte"),
			[10] = CreateSoundContainer("Heavy Bullet Impact Dirt Massive", "Massive.rte"),
			[11] = CreateSoundContainer("Heavy Bullet Impact Dirt Massive", "Massive.rte"),
			[128] = CreateSoundContainer("Heavy Bullet Impact Dirt Massive", "Massive.rte"),
			[6] = CreateSoundContainer("Heavy Bullet Impact Sand Massive", "Massive.rte"),
			[8] = CreateSoundContainer("Heavy Bullet Impact Sand Massive", "Massive.rte"),
			[178] = CreateSoundContainer("Heavy Bullet Impact SolidMetal Massive", "Massive.rte"),
			[179] = CreateSoundContainer("Heavy Bullet Impact SolidMetal Massive", "Massive.rte"),
			[180] = CreateSoundContainer("Heavy Bullet Impact SolidMetal Massive", "Massive.rte"),
			[181] = CreateSoundContainer("Heavy Bullet Impact SolidMetal Massive", "Massive.rte"),
			[182] = CreateSoundContainer("Heavy Bullet Impact SolidMetal Massive", "Massive.rte")}}
			
	self.terrainGFX = {
	Impact = {[12] = CreateMOSRotating("GFX Heavy Bullet Impact Concrete Massive", "Massive.rte"),
			[164] = CreateMOSRotating("GFX Heavy Bullet Impact Concrete Massive", "Massive.rte"),
			[177] = CreateMOSRotating("GFX Heavy Bullet Impact Concrete Massive", "Massive.rte"),
			[9] = CreateMOSRotating("GFX Heavy Bullet Impact Dirt Massive", "Massive.rte"),
			[10] = CreateMOSRotating("GFX Heavy Bullet Impact Dirt Massive", "Massive.rte"),
			[11] = CreateMOSRotating("GFX Heavy Bullet Impact Dirt Massive", "Massive.rte"),
			[128] = CreateMOSRotating("GFX Heavy Bullet Impact Dirt Massive", "Massive.rte"),
			[6] = CreateMOSRotating("GFX Heavy Bullet Impact Sand Massive", "Massive.rte"),
			[8] = CreateMOSRotating("GFX Heavy Bullet Impact Sand Massive", "Massive.rte"),
			[178] = CreateMOSRotating("GFX Heavy Bullet Impact SolidMetal Massive", "Massive.rte"),
			[179] = CreateMOSRotating("GFX Heavy Bullet Impact SolidMetal Massive", "Massive.rte"),
			[180] = CreateMOSRotating("GFX Heavy Bullet Impact SolidMetal Massive", "Massive.rte"),
			[181] = CreateMOSRotating("GFX Heavy Bullet Impact SolidMetal Massive", "Massive.rte"),
			[182] = CreateMOSRotating("GFX Heavy Bullet Impact SolidMetal Massive", "Massive.rte")}}
			
	self.terrainExtraGFX = {
	Impact = {[12] = CreateMOSRotating("GFX Heavy Bullet Impact Concrete Extra Massive", "Massive.rte"),
			[164] = CreateMOSRotating("GFX Heavy Bullet Impact Concrete Extra Massive", "Massive.rte"),
			[177] = CreateMOSRotating("GFX Heavy Bullet Impact Concrete Extra Massive", "Massive.rte"),
			[9] = CreateMOSRotating("GFX Heavy Bullet Impact Dirt Extra Massive", "Massive.rte"),
			[10] = CreateMOSRotating("GFX Heavy Bullet Impact Dirt Extra Massive", "Massive.rte"),
			[11] = CreateMOSRotating("GFX Heavy Bullet Impact Dirt Extra Massive", "Massive.rte"),
			[128] = CreateMOSRotating("GFX Heavy Bullet Impact Dirt Extra Massive", "Massive.rte"),
			[6] = CreateMOSRotating("GFX Heavy Bullet Impact Sand Extra Massive", "Massive.rte"),
			[8] = CreateMOSRotating("GFX Heavy Bullet Impact Sand Extra Massive", "Massive.rte"),
			[178] = CreateMOSRotating("GFX Heavy Bullet Impact SolidMetal Extra Massive", "Massive.rte"),
			[179] = CreateMOSRotating("GFX Heavy Bullet Impact SolidMetal Extra Massive", "Massive.rte"),
			[180] = CreateMOSRotating("GFX Heavy Bullet Impact SolidMetal Extra Massive", "Massive.rte"),
			[181] = CreateMOSRotating("GFX Heavy Bullet Impact SolidMetal Extra Massive", "Massive.rte"),
			[182] = CreateMOSRotating("GFX Heavy Bullet Impact SolidMetal Extra Massive", "Massive.rte")}}
	
end

function OnCollideWithTerrain(self, terrPixel)

	if self.impactDone ~= true then
	
		self.impactDone = true;
		if terrPixel ~= 0 then -- 0 = air
			if self.terrainSounds.Impact[terrPixel] ~= nil then
				self.terrainSounds.Impact[terrPixel]:Play(self.Pos);
			end
			if self.terrainGFX.Impact[terrPixel] ~= nil then
				local GFX = self.terrainGFX.Impact[terrPixel]:Clone()
				GFX.Pos = self.Pos
				GFX.Vel = Vector(self.Vel.X, self.Vel.Y):DegRotate(math.random(-10, 10));
				MovableMan:AddParticle(GFX)
				if math.random(0, 100) < 20 then
					local extraGFX = self.terrainExtraGFX.Impact[terrPixel]:Clone()
					extraGFX.Pos = self.Pos
					extraGFX.Vel = Vector(self.Vel.X, self.Vel.Y):DegRotate(math.random(-10, 10));
					MovableMan:AddParticle(extraGFX)
				end
			else
				local GFX = self.terrainGFX.Impact[177]:Clone()
				GFX.Pos = self.Pos
				GFX.Vel = self.Vel
				MovableMan:AddParticle(GFX)
			end				
		end
		
	end

end
