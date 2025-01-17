function Create(self)

	self.terrainSounds = {
	Impact = {[12] = CreateSoundContainer("Shotgun Bullet Impact Concrete Massive", "Massive.rte"),
			[164] = CreateSoundContainer("Shotgun Bullet Impact Concrete Massive", "Massive.rte"),
			[177] = CreateSoundContainer("Shotgun Bullet Impact Concrete Massive", "Massive.rte"),
			[9] = CreateSoundContainer("Shotgun Bullet Impact Dirt Massive", "Massive.rte"),
			[10] = CreateSoundContainer("Shotgun Bullet Impact Dirt Massive", "Massive.rte"),
			[11] = CreateSoundContainer("Shotgun Bullet Impact Dirt Massive", "Massive.rte"),
			[128] = CreateSoundContainer("Shotgun Bullet Impact Dirt Massive", "Massive.rte"),
			[6] = CreateSoundContainer("Shotgun Bullet Impact Sand Massive", "Massive.rte"),
			[8] = CreateSoundContainer("Shotgun Bullet Impact Sand Massive", "Massive.rte"),
			[178] = CreateSoundContainer("Shotgun Bullet Impact SolidMetal Massive", "Massive.rte"),
			[179] = CreateSoundContainer("Shotgun Bullet Impact SolidMetal Massive", "Massive.rte"),
			[180] = CreateSoundContainer("Shotgun Bullet Impact SolidMetal Massive", "Massive.rte"),
			[181] = CreateSoundContainer("Shotgun Bullet Impact SolidMetal Massive", "Massive.rte"),
			[182] = CreateSoundContainer("Shotgun Bullet Impact SolidMetal Massive", "Massive.rte")}}
			
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

function OnCollideWithMO(self, MO, rootMO)

	if self.Age <= TimerMan.DeltaTimeSecs * 1000 then
		MO.Vel = rootMO.Vel
		if IsAHuman(rootMO) then
			ToAHuman(rootMO).Status = 1;
			rootMO.Vel = (rootMO.Vel/2) + (self.Vel/20);
		else
			rootMO.Vel = (rootMO.Vel/2) + (self.Vel/35);
		end
	end
	
end
