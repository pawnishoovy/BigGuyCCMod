
function Create(self)

	self.shakenessParticle = CreateMOPixel("Shakeness Particle Massive", "Massive.rte");
	self.smokeParticle = CreateMOPixel("Smoke Payload Duford155", "Massive.rte");
	self.extraSmokeParticle = CreateMOPixel("Extra Smoke Payload Duford155", "Massive.rte");

	self.artilleryHandler = CreateMOPixel("Artillery Handler Duford155", "Massive.rte");

	if self:NumberValueExists("PosX") then
		self.artilleryPos = self:GetNumberValue("PosX");
	end
	
	if self.Sharpness > 0.5 then -- floating point makes it something stupid like 0.10000000040 in reality so we just check like this
		self.gunParent = ToMOSRotating(MovableMan:FindObjectByUniqueID(self.Sharpness));
		self.Sharpness = 0.1;
	end
	
	self.hitMOTable = {}
	
	self.soundFlyLoop = CreateSoundContainer("Shell Flying Duford155", "Massive.rte");
	self.soundFlyLoop:Play(self.Pos);
	
	self.soundOutOfMap = CreateSoundContainer("Shell Out Of Map Flying Duford155", "Massive.rte");
	self.soundLeaveMap = CreateSoundContainer("Shell Leave Map Duford155", "Massive.rte");
	
	self.terrainSounds = {
	Impact = {[12] = CreateSoundContainer("Duford155 Projectile Hit Concrete", "Massive.rte"),
			[164] = CreateSoundContainer("Duford155 Projectile Hit Concrete", "Massive.rte"),
			[177] = CreateSoundContainer("Duford155 Projectile Hit Concrete", "Massive.rte"),
			[9] = CreateSoundContainer("Duford155 Projectile Hit Dirt", "Massive.rte"),
			[10] = CreateSoundContainer("Duford155 Projectile Hit Dirt", "Massive.rte"),
			[11] = CreateSoundContainer("Duford155 Projectile Hit Dirt", "Massive.rte"),
			[128] = CreateSoundContainer("Duford155 Projectile Hit Dirt", "Massive.rte"),
			[6] = CreateSoundContainer("Duford155 Projectile Hit Sand", "Massive.rte"),
			[8] = CreateSoundContainer("Duford155 Projectile Hit Sand", "Massive.rte"),
			[178] = CreateSoundContainer("Duford155 Projectile Hit SolidMetal", "Massive.rte"),
			[179] = CreateSoundContainer("Duford155 Projectile Hit SolidMetal", "Massive.rte"),
			[180] = CreateSoundContainer("Duford155 Projectile Hit SolidMetal", "Massive.rte"),
			[181] = CreateSoundContainer("Duford155 Projectile Hit SolidMetal", "Massive.rte"),
			[182] = CreateSoundContainer("Duford155 Projectile Hit SolidMetal", "Massive.rte")}}
			
	-- this thing goes QUICK, better check on create too
	
	local offset = self.Vel * rte.PxTravelledPerFrame
	
	local rayOrigin = self.Pos - offset
	local rayVec = Vector(self.Vel.X,self.Vel.Y):SetMagnitude(self.Vel.Magnitude * rte.PxTravelledPerFrame + self.IndividualRadius);
	local moCheck = SceneMan:CastMORay(rayOrigin, rayVec, self.ID, self.Team, 0, false, 2); -- Raycast
	if moCheck ~= rte.NoMOID then	
		local rayHitPos = SceneMan:GetLastRayHitPos()
		local MO = MovableMan:GetMOFromID(moCheck)
		if IsMOSRotating(MO) then
			local hitAllowed = true;
			if self.hitMOTable then -- this shouldn't be needed but it is
				for index, root in pairs(self.hitMOTable) do
					if root == MO:GetRootParent().UniqueID or index == MO.UniqueID then
						hitAllowed = false;
					end
				end
			end
			if hitAllowed == true then
				MO = ToMOSRotating(MO);
				self.hitMOTable[MO.UniqueID] = MO:GetRootParent().UniqueID;
				
				local addWounds = true
				
				-- if we can gib just gib and move on with our 155mm lives, but if not...
				local lessVel = Vector(self.Vel.X, self.Vel.Y):SetMagnitude(self.Vel.Magnitude/2);
				if MO.WoundCount + 30 >= MO.GibWoundLimit then
					MO:GibThis();
					addWounds = false;
					if IsAttachable(MO) and ToAttachable(MO):IsAttached() and MO:GetRootParent() and IsActor(MO:GetRootParent()) then
						MO:GetRootParent().Vel = MO:GetRootParent().Vel + lessVel
					end
				else
					self.soundFlyLoop:Stop(-1);
					self:GibThis();
				end
				
				if addWounds == true then
					-- Damage, create a pixel that makes a hole
					for i = 0, 30 do
						local pixel = CreateMOPixel("Duford155 Damage Particle", "Massive.rte");
						pixel.Vel = self.Vel;
						pixel.Pos = self.Pos - Vector(self.Vel.X,self.Vel.Y):SetMagnitude(self.IndividualRadius * 0.9);
						pixel.Team = self.Team;
						pixel.IgnoresTeamHits = true;
						MovableMan:AddParticle(pixel);
					end
				end

			end
		end	
	end

end

function Update(self)

	self.lastRotAngle = self.RotAngle;

	self.soundFlyLoop.Pos = self.Pos;
	
	if self.Vel.Magnitude > 40 then -- Raycast
		local rayOrigin = self.Pos
		local rayVec = Vector(self.Vel.X,self.Vel.Y):SetMagnitude(self.Vel.Magnitude * rte.PxTravelledPerFrame + self.IndividualRadius);
		local moCheck = SceneMan:CastMORay(rayOrigin, rayVec, self.ID, self.Team, 0, false, 2); -- Raycast
		if moCheck ~= rte.NoMOID then	
			local rayHitPos = SceneMan:GetLastRayHitPos()
			local MO = MovableMan:GetMOFromID(moCheck)
			if IsMOSRotating(MO) then
				local hitAllowed = true;
				if self.hitMOTable then -- this shouldn't be needed but it is
					for index, root in pairs(self.hitMOTable) do
						if root == MO:GetRootParent().UniqueID or index == MO.UniqueID then
							hitAllowed = false;
						end
					end
				end
				if hitAllowed == true then
					MO = ToMOSRotating(MO);
					self.hitMOTable[MO.UniqueID] = MO:GetRootParent().UniqueID;
					
					local addWounds = true
					
					-- if we can gib just gib and move on with our 155mm lives, but if not...
					local lessVel = Vector(self.Vel.X, self.Vel.Y):SetMagnitude(self.Vel.Magnitude/2);
					if MO.WoundCount + 30 >= MO.GibWoundLimit then
						MO:GibThis();
						addWounds = false;
						if IsAttachable(MO) and ToAttachable(MO):IsAttached() and MO:GetRootParent() and IsActor(MO:GetRootParent()) then
							MO:GetRootParent().Vel = MO:GetRootParent().Vel + lessVel
						end
					else
						self.soundFlyLoop:Stop(-1);
						self:GibThis();
					end
					
					if addWounds == true then
						-- Damage, create a pixel that makes a hole
						for i = 0, 30 do
							local pixel = CreateMOPixel("Duford155 Damage Particle", "Massive.rte");
							pixel.Vel = self.Vel;
							pixel.Pos = self.Pos - Vector(self.Vel.X,self.Vel.Y):SetMagnitude(self.IndividualRadius * 0.9);
							pixel.Team = self.Team;
							pixel.IgnoresTeamHits = true;
							MovableMan:AddParticle(pixel);
						end
					end

				end
			end	
		end
	end
	
	if self.ToDelete then
		if self.Age < self.Lifetime then
			if self.Pos.Y + self.Vel.Y < (150 + SceneMan.SceneHeight * -1) then --check pos and scene height with a 150 pixel grace distance... VERY IMPERFECT
				-- this is the equivalent of a hail mary to get around buggy Destroy spawning
				self.soundFlyLoop:FadeOut(500);
				self.soundLeaveMap:Play(self.Pos);
				self.soundOutOfMap:Play(self.Pos);
				if self.gunParent then
					self.gunParent:SetNumberValue("Shot Exited Map", 1);
				end
				
				self.artilleryHandler = CreateMOPixel("Artillery Handler Duford155", "Massive.rte");
				if not self.artilleryPos then
					self.artilleryPos = math.random(0, SceneMan.SceneWidth);
				end
				self.artilleryHandler.Pos = Vector(self.artilleryPos, (SceneMan.SceneHeight*-1) + 200);
				self.artilleryHandler.Mass = math.deg(self.lastRotAngle)
				MovableMan:AddParticle(self.artilleryHandler);		
			else
				if self.gunParent then
					self.gunParent:SetNumberValue("Shot Expired", 1);
				end

				self.soundFlyLoop:Stop(-1);
			end
		else
			if self.gunParent then
				self.gunParent:SetNumberValue("Shot Expired", 1);
			end

			self.soundFlyLoop:Stop(-1);
		end
	end	
	
end
	
function OnCollideWithTerrain(self, terrPixel)


	if self.gunParent then
		self.gunParent:SetNumberValue("Shot Expired", 1);
	end

	self.soundFlyLoop:Stop(-1);

	self:GibThis();
	
	if self.terrainSoundPlayed ~= true then
		self.terrainSoundPlayed = true;
		if terrPixel ~= 0 then -- 0 = air
			if self.terrainSounds.Impact[terrPixel] ~= nil then
				self.terrainSounds.Impact[terrPixel]:Play(self.Pos);
			end
		end	
	end
	
end

function Destroy(self)

	self.soundFlyLoop:Stop(-1);
	if self.gunParent then
		self.gunParent:SetNumberValue("Shot Expired", 1);
	end
	
end