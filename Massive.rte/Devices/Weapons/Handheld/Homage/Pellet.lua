function Create(self)
	self.Vel = Vector(self.Vel.X, self.Vel.Y) * RangeRand(0.85, 1.15)
	
	self.murder = 2
	
	self.spewBlood = true
	
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
		if terrPixel ~= 0 and math.random(0, 100) < 20 then -- 0 = air
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
	
	local timeFactor = (1 + math.pow(self.Age * 0.07, 2))
	
	-- The murder:
	if (self.murder > 0 and self.Age < 200) or math.random() < 1 / timeFactor then
		self.murder = self.murder - 1
		self.ToDelete = false
	end
	
	if self.spewBlood then
		self.spewBlood = false
		local material = MO.Material.PresetName;
		
		-- Add extra effects based on the material
		if (not IsActor(rootMO) or ToActor(rootMO).Health < 101) and math.random() < 0.1 and string.find(material,"Flesh") then
			local fuck = CreatePEmitter("Fucking Blood Spray Massive", "Massive.rte");
			fuck.Pos = self.Pos;
			fuck.Vel = (self.Vel.Normalized + Vector(RangeRand(-0.3, 0.3), -1) * RangeRand(0.2, 1)) * 0.1 * self.Vel.Magnitude;
			fuck.Lifetime = fuck.Lifetime * RangeRand(0.2, 1.2) * 3;
			MovableMan:AddParticle(fuck);
		end
	end
	
	--if math.random() < 1 / timeFactor then
		MO.Vel = rootMO.Vel
		local timeFactor2 = math.sqrt(1 + self.Age * 0.07)
		if IsAHuman(rootMO) then
			ToAHuman(rootMO).Status = 1;
			rootMO.Vel = (rootMO.Vel / 2) + (self.Vel / rootMO.Mass / timeFactor2 * 10);
		else
			rootMO.Vel = (rootMO.Vel / 2) + (self.Vel / rootMO.Mass / timeFactor2 * 10);
		end
	--end
	
end
