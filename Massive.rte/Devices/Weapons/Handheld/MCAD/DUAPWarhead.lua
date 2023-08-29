function Create(self)

	self.shakeTable = {}
	for actor in MovableMan.Actors do
		actor = ToActor(actor)
		table.insert(self.shakeTable, actor);
	end
	
	self.shake = 130
	
	self.hitMOTable = {}
	
	self.width = math.floor(ToMOSprite(self):GetSpriteWidth() * 0.5 + 0.5);
	
	self.soundFlyLoop = CreateSoundContainer("Shell Flying Duford155", "Massive.rte");
	self.soundFlyLoop.Volume = 0.5;
	self.soundFlyLoop:Play(self.Pos);
	
	self.soundFlyBy = CreateSoundContainer("Shell FlyBy Duford155", "Massive.rte");
	self.soundFlyBy.AttenuationStartDistance = 30
	
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
			
	self.lastVel = Vector(self.Vel.X, self.Vel.Y)
	self.impulse = Vector()
	self.impactSoundTimer = Timer()		
	
	self.flyby = true
	self.flybyTimer = Timer()

	self.boosterTimer = Timer()
	self.booster = false
	
	self.igniteIndoorsSound = CreateSoundContainer("Rocket Ignite Indoors Massive MCAD", "Massive.rte");
	self.igniteOutdoorsSound = CreateSoundContainer("Rocket Ignite Outdoors Massive MCAD", "Massive.rte");
	
	for i = 1, math.random(2,6) do
		local poof = CreateMOSParticle(math.random(1,2) < 2 and "Tiny Smoke Ball 1" or "Small Smoke Ball 1");
		poof.Pos = self.Pos
		poof.Vel = Vector(self.Vel.X, self.Vel.Y):RadRotate(math.pi * RangeRand(-1, 1) * 0.05) * RangeRand(0.1, 0.9) * 0.6;
		poof.Lifetime = poof.Lifetime * RangeRand(0.9, 1.6) * 0.6
		MovableMan:AddParticle(poof);
	end
	for i = 1, math.random(2,4) do
		local poof = CreateMOSParticle("Small Smoke Ball 1");
		poof.Pos = self.Pos
		poof.Vel = (Vector(self.Vel.X, self.Vel.Y):RadRotate(math.pi * (math.random(0,1) * 2.0 - 1.0) * 2.5 + math.pi * RangeRand(-1, 1) * 0.15) * RangeRand(0.1, 0.9) * 0.6 + Vector(self.Vel.X, self.Vel.Y):RadRotate(math.pi * RangeRand(-1, 1) * 0.15) * RangeRand(0.1, 0.9) * 0.2) * 0.5;
		poof.Lifetime = poof.Lifetime * RangeRand(0.9, 1.6) * 0.6
		MovableMan:AddParticle(poof);
	end
	for i = 1, 3 do
		local poof = CreateMOSParticle("Explosion Smoke 2");
		poof.Pos = self.Pos
		poof.Vel = Vector(self.Vel.X, self.Vel.Y):RadRotate(RangeRand(-1, 1) * 0.15) * RangeRand(0.9, 1.6) * 0.66 * i;
		poof.Lifetime = poof.Lifetime * RangeRand(0.8, 1.6) * 0.1 * i
		MovableMan:AddParticle(poof);
	end
end
function Update(self)

	self.impulse = (self.Vel - self.lastVel) / TimerMan.DeltaTimeSecs * self.Vel.Magnitude * 0.1
	self.lastVel = Vector(self.Vel.X, self.Vel.Y)

	self.soundFlyLoop.Pos = self.Pos;

	--Flyby sound (epic haxx)
	if self.flyby and self.flybyTimer:IsPastSimMS(80) then
		--local cameraPos = Vector(SceneMan:GetScrollTarget(0).X, SceneMan:GetScrollTarget(0).Y)
		
		local controlledActor = ActivityMan:GetActivity():GetControlledActor(0);
		
		if controlledActor then
		
			local distA = SceneMan:ShortestDistance(self.Pos,controlledActor.Pos,SceneMan.SceneWrapsX).Magnitude
			local vectorA = SceneMan:ShortestDistance(self.Pos,controlledActor.Pos,SceneMan.SceneWrapsX)
			local distAMin = math.random(100,200)		
			
			if distA < distAMin and SceneMan:CastObstacleRay(self.Pos, vectorA, Vector(0, 0), Vector(0, 0), controlledActor.ID, -1, 128, 8) < 0 then
				self.flyby = false
				
				self.soundFlyBy:Play(controlledActor.Pos);
			else
				local offset = Vector(self.Vel.X, self.Vel.Y) * RangeRand(0.2,1.0)
				local distB = SceneMan:ShortestDistance(self.Pos + offset,controlledActor.Pos,SceneMan.SceneWrapsX).Magnitude
				local distBMin = math.random(80,160)
				if distB < distBMin and SceneMan:CastObstacleRay(self.Pos, vectorA, Vector(0, 0), Vector(0, 0), controlledActor.ID, -1, 128, 8) < 0 then
					self.flyby = false
					
					self.soundFlyBy:Play(controlledActor.Pos);
					
				end
			end
		end
		
		local s = self.UniqueID % 7 + 1
		--PrimitiveMan:DrawCirclePrimitive(cameraPos, s, 5)
	end
	
	if self.HitsMOs == false then
	
		local offset = self.Vel * rte.PxTravelledPerFrame
		
		local rayOrigin = self.Pos - offset
		local rayVec = Vector(self.Vel.X,self.Vel.Y):SetMagnitude(self.Vel.Magnitude * rte.PxTravelledPerFrame + self.IndividualRadius);
		local moCheck = SceneMan:CastMORay(rayOrigin, rayVec, self.ID, self.Team, 0, false, 2); -- Raycast
		if moCheck ~= rte.NoMOID then	
			local rayHitPos = SceneMan:GetLastRayHitPos()
			local mo = MovableMan:GetMOFromID(moCheck)
			if IsMOSRotating(mo) then
				local hitAllowed = true;
				if self.hitMOTable then -- this shouldn't be needed but it is
					for index, root in pairs(self.hitMOTable) do
						if root == mo:GetRootParent().UniqueID or index == mo.UniqueID then
							hitAllowed = false;
						end
					end
				end
				if hitAllowed == true then
					mo = ToMOSRotating(mo);
					self.hitMOTable[mo.UniqueID] = mo:GetRootParent().UniqueID;
					local hitPos = self.Pos;
					
					self.soundFlyLoop:Stop(-1);
					local penetration = (self.Mass * self.PrevVel.Magnitude * self.Sharpness)/math.max(mo.Material.StructuralIntegrity, 1);
					local concussiveForce = (self.Mass * self.PrevVel.Magnitude)/mo.Mass;
					if penetration > 1 then
						local dist = SceneMan:ShortestDistance(mo.Pos, hitPos, SceneMan.SceneWrapsX);
						local stickOffset = Vector(dist.X * mo.FlipFactor, dist.Y):RadRotate(-mo.RotAngle * mo.FlipFactor);
						
						local setAngle = stickOffset.AbsRadAngle - (mo.HFlipped and math.pi or 0);
						local setOffset = Vector(stickOffset.X, stickOffset.Y):SetMagnitude(stickOffset.Magnitude - self.width);
						
						local woundName = mo:GetEntryWoundPresetName();
						local woundNameExit = mo:GetExitWoundPresetName();
						local multiplier = math.min(math.sqrt(penetration), self.WoundDamageMultiplier);
						local mildMultiplier = math.sqrt(multiplier);
						local milderMultiplier = math.sqrt(mildMultiplier);
						if woundName ~= "" then
							local wound = CreateAEmitter(woundName);
							wound.DamageMultiplier = multiplier;
							wound.EmitCountLimit = math.ceil(wound.EmitCountLimit * mildMultiplier);
							wound.Scale = wound.Scale * milderMultiplier;
							if wound.BurstSound then
								wound.BurstSound.Pitch = wound.BurstSound.Pitch/milderMultiplier;
								wound.BurstSound.Volume = wound.BurstSound.Volume * milderMultiplier;
							end
							for em in wound.Emissions do
								em.ParticlesPerMinute = em.ParticlesPerMinute * multiplier;
								em.MaxVelocity = em.MaxVelocity * mildMultiplier;
								em.MinVelocity = em.MinVelocity * mildMultiplier;
							end
							wound.InheritedRotAngleOffset = setAngle;
							wound.DrawAfterParent = true;
							mo:AddWound(wound, setOffset, true);
						end
						
						if string.find(mo.Material.PresetName,"Metal") or string.find(woundName,"Metal") or string.find(woundNameExit,"Metal")
						or string.find(mo.Material.PresetName,"Stuff") or string.find(woundName,"Dent") or string.find(woundNameExit,"Dent") then
							self.terrainSounds.Impact[178]:Play(self.Pos); -- extra juice for hitting metal
						end
						
						if penetration > 2 then
							if penetration > 35 then
								local rootMO = mo:GetRootParent();
								local woundName = ToMOSRotating(rootMO):GetEntryWoundPresetName();
								local damage = 3;
								if woundName ~= "" then
									local damage = CreateAEmitter(woundName).BurstDamage;
								end
								if IsActor(rootMO) and IsArm(mo) or IsLeg(mo) or (IsAHuman(rootMO) and ToAHuman(rootMO).Head and ToAHuman(rootMO).Head.UniqueID == mo.UniqueID) then
									ToActor(rootMO).Health = ToActor(rootMO).Health - (damage * 15);
								end
								if concussiveForce > 60 then
									mo:GibThis();
								end
							else
								self.HitsMOs = true;
								self.Vel = Vector(self.Vel.X, self.Vel.Y):SetMagnitude(self.Vel.Magnitude^0.9);
								self:GibThis();
							end
							if mo.Radius > 70 then
								self:GibThis();
							end
							if penetration < 40 then
								self.disabled = true;
							end
							if woundNameExit ~= "" then
								local wound = CreateAEmitter(woundNameExit);
								wound.DamageMultiplier = multiplier;
								wound.EmitCountLimit = math.ceil(wound.EmitCountLimit * mildMultiplier);
								wound.Scale = wound.Scale * milderMultiplier;
								if wound.BurstSound then
									wound.BurstSound.Pitch = wound.BurstSound.Pitch/milderMultiplier;
									wound.BurstSound.Volume = wound.BurstSound.Volume * milderMultiplier;
								end
								for em in wound.Emissions do
									em.ParticlesPerMinute = em.ParticlesPerMinute * multiplier;
									em.MaxVelocity = em.MaxVelocity * mildMultiplier;
									em.MinVelocity = em.MinVelocity * mildMultiplier;
								end
								wound.InheritedRotAngleOffset = setAngle;
								wound.DrawAfterParent = true;
								mo:AddWound(wound, setOffset, true);
							end
						end
					end
				end
			end
		end
	end

	local factor = 1
	
	-- Shake
	if self.shakeTable and not self.disabled then
		for i = 1, #self.shakeTable do
			local actor = self.shakeTable[i];
			if actor and IsActor(actor) then
				actor = ToActor(actor)
				local dist = SceneMan:ShortestDistance(self.Pos, actor.Pos, SceneMan.SceneWrapsX).Magnitude
				local distFactor = math.sqrt(dist * 0.03)
				
				actor.ViewPoint = actor.ViewPoint + Vector(self.shake * RangeRand(-1, 1), self.shake * RangeRand(-1, 1)) * factor / distFactor;
			end
		end
	end

	if self.boosterTimer:IsPastSimMS(0) and not self.disabled then
		self:EnableEmission(true)
		if not self.booster then
			for i = 1, 6 do
				local poof = CreateMOSParticle("Explosion Smoke Small");
				poof.Pos = self.Pos + Vector(0, 3)-- * self.FlipFactor):RadRotate(self.RotAngle)
				poof.Vel = Vector(self.Vel.X, self.Vel.Y):RadRotate(RangeRand(-1, 1) * 0.03) * RangeRand(0.9, 1.6) * 0.99 * (i-3);
				poof.Lifetime = poof.Lifetime * RangeRand(0.8, 1.6) * 0.1 * i
				poof.GlobalAccScalar = 0
				poof.AirResistance = poof.AirResistance * 1
				MovableMan:AddParticle(poof);
			end
			self.booster = true
			
			local outdoorRays = 0;

			self.rayThreshold = 2; -- this is the first ray check to decide whether we play outdoors
			local Vector2 = Vector(0,-700); -- straight up
			local Vector2Left = Vector(0,-700):RadRotate(45*(math.pi/180));
			local Vector2Right = Vector(0,-700):RadRotate(-45*(math.pi/180));			
			local Vector2SlightLeft = Vector(0,-700):RadRotate(22.5*(math.pi/180));
			local Vector2SlightRight = Vector(0,-700):RadRotate(-22.5*(math.pi/180));		
			local Vector3 = Vector(0,0); -- dont need this but is needed as an arg
			local Vector4 = Vector(0,0); -- dont need this but is needed as an arg

			self.ray = SceneMan:CastObstacleRay(self.Pos, Vector2, Vector3, Vector4, self.RootID, self.Team, 128, 7);
			self.rayRight = SceneMan:CastObstacleRay(self.Pos, Vector2Right, Vector3, Vector4, self.RootID, self.Team, 128, 7);
			self.rayLeft = SceneMan:CastObstacleRay(self.Pos, Vector2Left, Vector3, Vector4, self.RootID, self.Team, 128, 7);			
			self.raySlightRight = SceneMan:CastObstacleRay(self.Pos, Vector2SlightRight, Vector3, Vector4, self.RootID, self.Team, 128, 7);
			self.raySlightLeft = SceneMan:CastObstacleRay(self.Pos, Vector2SlightLeft, Vector3, Vector4, self.RootID, self.Team, 128, 7);
			
			self.rayTable = {self.ray, self.rayRight, self.rayLeft, self.raySlightRight, self.raySlightLeft};
			
			for _, rayLength in ipairs(self.rayTable) do
				if rayLength < 0 then
					outdoorRays = outdoorRays + 1;
				end
			end
			
			if outdoorRays >= self.rayThreshold then
				self.igniteOutdoorsSound:Play(self.Pos);
			else
				self.igniteIndoorsSound:Play(self.Pos);
			end			
			
		end
	else
		self:EnableEmission(false)
	end
end

function Destroy(self)

	self.soundFlyLoop:Stop(-1);
	
end

function OnCollideWithTerrain(self, terrPixel)

	if self.firstImpact ~= true or self.impactSoundTimer:IsPastSimMS(200) then

		self.firstImpact = true;
		self.impactSoundTimer:Reset();

		self.soundFlyLoop:Stop(-1);
		
		if self.impulse.Magnitude > 45 then -- Hit
		
			if self.impulse.Magnitude > 140 then
				self:GibThis();
			end
		
			local shakenessParticle = CreateMOPixel("Shakeness Particle Massive", "Massive.rte");
			shakenessParticle.Pos = self.Pos;
			shakenessParticle.Mass = 45;
			shakenessParticle.Lifetime = 250;
			MovableMan:AddParticle(shakenessParticle);
		
			self.disabled = true;
		
			if terrPixel ~= 0 then -- 0 = air
				if self.terrainSounds.Impact[terrPixel] ~= nil then
					self.terrainSounds.Impact[terrPixel]:Play(self.Pos);
				end
			end
		end
		
	end
	
end

function OnCollideWithMO(self, mo, rootMO)
	-- local hitPos = Vector(self.PrevPos.X, self.PrevPos.Y);
	-- if SceneMan:CastFindMORay(self.PrevPos, self.PrevVel * rte.PxTravelledPerFrame, mo.ID, hitPos, rte.airID, true, 1) then
		-- self.hit = true;
		-- local penetration = (self.Mass * self.PrevVel.Magnitude * self.Sharpness)/math.max(mo.Material.StructuralIntegrity, 1);
		-- if penetration > 1 then
			-- local dist = SceneMan:ShortestDistance(mo.Pos, hitPos, SceneMan.SceneWrapsX);
			-- local stickOffset = Vector(dist.X * mo.FlipFactor, dist.Y):RadRotate(-mo.RotAngle * mo.FlipFactor);
			
			-- local setAngle = stickOffset.AbsRadAngle - (mo.HFlipped and math.pi or 0);
			-- local setOffset = Vector(stickOffset.X, stickOffset.Y):SetMagnitude(stickOffset.Magnitude - self.width);
			
			-- local woundName = mo:GetEntryWoundPresetName();
			-- local multiplier = math.min(math.sqrt(penetration), self.WoundDamageMultiplier);
			-- local mildMultiplier = math.sqrt(multiplier);
			-- local milderMultiplier = math.sqrt(mildMultiplier);
			-- if woundName ~= "" then
				-- local wound = CreateAEmitter(woundName);
				-- wound.DamageMultiplier = multiplier;
				-- wound.EmitCountLimit = math.ceil(wound.EmitCountLimit * mildMultiplier);
				-- wound.Scale = wound.Scale * milderMultiplier;
				-- if wound.BurstSound then
					-- wound.BurstSound.Pitch = wound.BurstSound.Pitch/milderMultiplier;
					-- wound.BurstSound.Volume = wound.BurstSound.Volume * milderMultiplier;
				-- end
				-- for em in wound.Emissions do
					-- em.ParticlesPerMinute = em.ParticlesPerMinute * multiplier;
					-- em.MaxVelocity = em.MaxVelocity * mildMultiplier;
					-- em.MinVelocity = em.MinVelocity * mildMultiplier;
				-- end
				-- wound.InheritedRotAngleOffset = setAngle;
				-- wound.DrawAfterParent = true;
				-- mo:AddWound(wound, setOffset, true);
			-- end
			
			-- if penetration > 2 then
				-- if penetration > 35 then
					-- mo:GibThis();
				-- end
				-- self.disabled = true;
				-- woundName = mo:GetExitWoundPresetName();
				-- if woundName ~= "" then
					-- local wound = CreateAEmitter(woundName);
					-- wound.DamageMultiplier = multiplier;
					-- wound.EmitCountLimit = math.ceil(wound.EmitCountLimit * mildMultiplier);
					-- wound.Scale = wound.Scale * milderMultiplier;
					-- if wound.BurstSound then
						-- wound.BurstSound.Pitch = wound.BurstSound.Pitch/milderMultiplier;
						-- wound.BurstSound.Volume = wound.BurstSound.Volume * milderMultiplier;
					-- end
					-- for em in wound.Emissions do
						-- em.ParticlesPerMinute = em.ParticlesPerMinute * multiplier;
						-- em.MaxVelocity = em.MaxVelocity * mildMultiplier;
						-- em.MinVelocity = em.MinVelocity * mildMultiplier;
					-- end
					-- wound.InheritedRotAngleOffset = setAngle;
					-- wound.DrawAfterParent = true;
					-- mo:AddWound(wound, setOffset, true);
				-- end
			-- end
		-- end
		-- self.Vel = Vector(self.Vel.X, self.Vel.Y):SetMagnitude(self.Vel.Magnitude^0.9);
	-- end
	-- self:GibThis();
	
end

function Destroy(self)

	self.soundFlyLoop:Stop(-1);
end