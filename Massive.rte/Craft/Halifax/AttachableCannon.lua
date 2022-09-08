function halifaxClamp(value, min, max)

	if value < min then return min
	elseif value > max then return max
	else return value
	end
	
end

function Create(self)

	self.debugChargeSound = CreateSoundContainer("cannondebug Halifax Massive", "Massive.rte");
	self.debugFireSound = CreateSoundContainer("Boom Homage", "Massive.rte");

	self.rattleEndSound = CreateSoundContainer("Turret Rattle End Halifax Massive", "Massive.rte");

	self.turnSpeed = 0.015;	--Speed of the turret turning, in rad per frame
	self.searchRange = 500;	--Detection area diameter or max ray distance to search enemies from, in px
	--Toggle visibility of the aim area / trace to see how the detection works
	self.showAim = false;
	--Angle alteration variables (do not touch)
	self.rotation = 0;	--Left / Right movement affecting turret angle
	self.verticalFactor = 0;	--How Up / Down movement affects turret angle
	
	self.aiFireDelayTimer = Timer();
	self.aiFireDelay = 1000;
	
	self.delayedFire = false
	self.delayedFireTimer = Timer();
	
	self.coolDownTimer = Timer();
	
	self.reloadTimer = Timer();
	
	
	self.Mouse = Vector(self.Pos.X, self.Pos.Y)
	
	
end
function Update(self)

	local parent = ToActor(self:GetRootParent());
	if parent then
		if parent:IsPlayerControlled() then
			-- manual mode
			
			self.Mouse = Vector(self.Mouse.X + UInputMan:GetMouseMovement(self.Team).X, self.Mouse.Y + UInputMan:GetMouseMovement(self.Team).Y)
			self.Mouse.X = halifaxClamp(self.Mouse.X, -250, 250);
			self.Mouse.Y = halifaxClamp(self.Mouse.Y, -250, 250);
			
			self.finalPos = self.Pos + self.Mouse
			parent.ViewPoint = self.finalPos
			PrimitiveMan:DrawCirclePrimitive(self.finalPos, 3, 5)
			
			if UInputMan:KeyPressed(MassiveSettings.GunShoveHotkey) then
				self.toFire = true;
			end
			
			local aimTrace = SceneMan:ShortestDistance(self.Pos, self.finalPos, SceneMan.SceneWrapsX);		
			self.RotAngle = aimTrace.AbsRadAngle;
			
		else
		
			-- AI mode	
				
			--Aim vertically away from parent
			local posTrace = SceneMan:ShortestDistance(parent.Pos, self.Pos, SceneMan.SceneWrapsX):SetMagnitude(self.searchRange * 0.5);
			self.RotAngle = (math.pi * 0.5 * self.verticalFactor + Vector(0, posTrace.Y).AbsRadAngle + (parent.HFlipped and math.pi or 0))/(1 + self.verticalFactor) - self.rotation;
			if IsActor(parent) then
				parent = ToActor(parent);
				if parent.Status ~= Actor.STABLE then
					return;
				end
				local controller = parent:GetController();
					
				if controller:IsState(Controller.MOVE_RIGHT) then
					self.rotation = self.rotation + self.turnSpeed;
				end
				if controller:IsState(Controller.MOVE_LEFT) then
					self.rotation = self.rotation - self.turnSpeed;
				end
				--Spread / tighten aim when moving up / down
				if controller:IsState(Controller.MOVE_DOWN) then
					self.verticalFactor = self.verticalFactor - self.turnSpeed;
				end
			end
			if math.abs(self.rotation) > 0.001 then
				self.rotation = self.rotation/(1 + self.turnSpeed * 2);
			else
				self.rotation = 0;
			end
			if math.abs(self.verticalFactor) > 0.001 then
				self.verticalFactor = self.verticalFactor/(1 + self.turnSpeed * 4);
			else
				self.verticalFactor = 0;
			end
			
			local aimPos = self.Pos + Vector((self.searchRange * 0.5), 0):RadRotate(self.RotAngle);
			--Debug: visualize aim area
			if self.showAim then
				PrimitiveMan:DrawCirclePrimitive(self.Team, aimPos, (self.searchRange * 0.5), 13);
			end
			
			local aimTarget = MovableMan:GetClosestEnemyActor(self.Team, aimPos, (self.searchRange * 0.5), Vector());
			if aimTarget and aimTarget.Status < Actor.INACTIVE then
			
				if self.aiToFire and self.aiFireDelayTimer:IsPastSimMS(self.aiFireDelay) then
					self.toFire = true;
					self.aiToFire = false;
				end		
				
				--Debug: visualize search trace
				if self.showAim then
					PrimitiveMan:DrawLinePrimitive(self.Team, aimPos, aimTarget.Pos, 13);
				end
				--Check that the target isn't obscured by terrain
				local aimTrace = SceneMan:ShortestDistance(self.Pos, aimTarget.Pos, SceneMan.SceneWrapsX);
				local terrCheck = SceneMan:CastStrengthRay(self.Pos, aimTrace, 30, Vector(), 5, 0, SceneMan.SceneWrapsX);
				if terrCheck == false then
					self.RotAngle = aimTrace.AbsRadAngle;
					--Debug: visualize aim trace
					if self.showAim then
						PrimitiveMan:DrawLinePrimitive(self.Team, self.Pos, aimTarget.Pos, 254);
					end

					if not self.aiToFire then
						self.aiFireDelayTimer:Reset();
						self.aiToFire = true;
					end

				end
				
			end
			
		end
	end
	
	if self.toFire and self.coolDownTimer:IsPastSimMS(2500) then
		if not self.activated and not self.delayedFire then
		
			self.activated = true	
			
			self.debugChargeSound:Play(self.Pos);
			
			self.delayedFire = true
			self.delayedFireTimer:Reset()
		end
	else
		if self.activated then
			self.activated = false
		end
	end
	
	if self.delayedFire then
		if self.delayedFireTimer:IsPastSimMS(1500) or not self.toFire then
			self.delayedFire = false
			self.toFire = false;
			self.aiToFire = false;

			-- fire!
			
			self.coolDownTimer:Reset();
			
			local shot = CreateMOPixel("Maxav Particle Scripted", "Massive.rte");
			shot.Pos = self.Pos + Vector(15 * self.FlipFactor, 0):RadRotate(self.RotAngle);
			shot.Vel = self.Vel + Vector(153 + math.random(0, 7) * self.FlipFactor, 0):RadRotate(self.RotAngle);
			shot.Team = self.Team;
			shot.IgnoresTeamHits = true;
			MovableMan:AddParticle(shot);	
			for i = 1, 45 do
				local shot = CreateMOPixel("Maxav Particle", "Massive.rte");
				shot.Pos = self.Pos + Vector(15 * self.FlipFactor, 0):RadRotate(self.RotAngle);
				shot.Vel = self.Vel + Vector(153 + math.random(0, 7) * self.FlipFactor, 0):RadRotate(self.RotAngle);
				shot.Team = self.Team;
				shot.IgnoresTeamHits = true;
				MovableMan:AddParticle(shot);
			end	
			
			local shakenessParticle = CreateMOPixel("Shakeness Particle Glow Massive", "Massive.rte");
			shakenessParticle.Pos = self.Pos;
			shakenessParticle.Mass = 60
			shakenessParticle.Lifetime = 1000
			MovableMan:AddParticle(shakenessParticle);		

			
			-- Ground Smoke
			local maxi = 6
			for i = 1, maxi do
				
				local effect = CreateMOSRotating("Ground Smoke Particle Small Massive", "Massive.rte")
				effect.Pos = self.Pos + Vector(RangeRand(-1,1), RangeRand(-1,1)) * 3
				effect.Vel = self.Vel + Vector(math.random(90,150),0):RadRotate(math.pi * 2 / maxi * i + RangeRand(-2,2) / maxi)
				effect.Lifetime = effect.Lifetime * RangeRand(0.5,2.0)
				effect.AirResistance = effect.AirResistance * RangeRand(0.5,0.8)
				MovableMan:AddParticle(effect)
			end
			
			local xSpread = 0
			
			local smokeSatisfyingFactor = 1
			
			local smokeAmount = 40 * MassiveSettings.GunshotSmokeMultiplier;
			local particleSpread = 2
			
			local smokeLingering = math.sqrt(smokeAmount / 8)
			local smokeVelocity = (1 + math.sqrt(smokeAmount / 8) ) * 0.5
			
			-- Muzzle main smoke
			for i = 1, math.ceil(smokeAmount / (math.random(2,4))) do
				local spread = math.pi * RangeRand(-1, 1) * 0.05
				local velocity = 110 * RangeRand(0.1, 0.9) * 0.4;
				
				local particle = CreateMOSParticle((math.random() * particleSpread) < 6.5 and "Tiny Smoke Ball 1" or "Small Smoke Ball 1");
				particle.Pos = self.Pos
				particle.Vel = self.Vel + Vector(velocity * self.FlipFactor,0):RadRotate(self.RotAngle + spread) * smokeVelocity
				particle.Lifetime = particle.Lifetime * RangeRand(0.9, 1.6) * 0.3 * smokeLingering
				particle.AirThreshold = particle.AirThreshold * 0.5
				particle.GlobalAccScalar = 0
				MovableMan:AddParticle(particle);
			end
			
			-- Muzzle lingering smoke
			for i = 1, math.ceil(smokeAmount / (math.random(2,4))) do
				local spread = math.pi * RangeRand(-1, 1) * 0.05
				local velocity = 110 * RangeRand(0.1, 0.9) * 0.4;
				
				local particle = CreateMOSParticle((math.random() * particleSpread) < 10 and "Tiny Smoke Ball 1" or "Small Smoke Ball 1");
				particle.Pos = self.Pos
				particle.Vel = self.Vel + Vector(velocity * self.FlipFactor,0):RadRotate(self.RotAngle + spread) * smokeVelocity
				particle.Lifetime = particle.Lifetime * RangeRand(0.9, 1.6) * 0.3 * smokeLingering * 3
				particle.AirThreshold = particle.AirThreshold * 0.5
				particle.GlobalAccScalar = 0.01
				MovableMan:AddParticle(particle);
			end
			
			-- Muzzle side smoke
			for i = 1, math.ceil(smokeAmount / (math.random(4,6))) do
				local vel = Vector(110 * self.FlipFactor,0):RadRotate(self.RotAngle)
				
				local xSpreadVec = Vector(xSpread * self.FlipFactor * math.random() * -1, 0):RadRotate(self.RotAngle)
				
				local particle = CreateMOSParticle("Tiny Smoke Ball 1");
				particle.Pos = self.Pos + xSpreadVec
				-- oh LORD
				particle.Vel = self.Vel + ((Vector(vel.X, vel.Y):RadRotate(math.pi * (math.random(0,1) * 2.0 - 1.0) * 0.5 + math.pi * RangeRand(-1, 1) * 0.15) * RangeRand(0.1, 0.9) * 0.3 + Vector(vel.X, vel.Y):RadRotate(math.pi * RangeRand(-1, 1) * 0.15) * RangeRand(0.1, 0.9) * 0.2) * 0.5) * smokeVelocity;
				-- have mercy
				particle.Lifetime = particle.Lifetime * RangeRand(0.9, 1.6) * 0.3 * smokeLingering
				particle.AirThreshold = particle.AirThreshold * 0.5
				particle.GlobalAccScalar = 0
				MovableMan:AddParticle(particle);
			end
			
			-- Muzzle scary smoke
			for i = 1, math.ceil(smokeAmount / (math.random(8,12))) do
				local spread = math.pi * RangeRand(-1, 1) * 0.05
				local velocity = 110 * RangeRand(0.1, 0.9) * 0.4;
				
				local particle = CreateMOSParticle("Side Thruster Blast Ball 1", "Base.rte");
				particle.Pos = self.Pos
				particle.Vel = self.Vel + Vector(velocity * self.FlipFactor,0):RadRotate(self.RotAngle + spread) * smokeVelocity
				particle.Lifetime = particle.Lifetime * RangeRand(0.9, 1.6) * 0.3 * smokeLingering
				particle.AirThreshold = particle.AirThreshold * 0.5
				particle.GlobalAccScalar = 0
				MovableMan:AddParticle(particle);
			end
			
			-- Muzzle flash-smoke
			for i = 1, math.ceil(smokeAmount / (math.random(5,10) * 0.5)) do
				local spread = RangeRand(-math.rad(particleSpread), math.rad(particleSpread)) * (1 + math.random(0,3) * 0.3)
				local velocity = 110 * 0.6 * RangeRand(0.9,1.1)
				
				local xSpreadVec = Vector(xSpread * self.FlipFactor * math.random() * -1, 0):RadRotate(self.RotAngle)
				
				local particle = CreateMOSParticle("Flame Smoke 1 Micro")
				particle.Pos = self.Pos + xSpreadVec
				particle.Vel = self.Vel + Vector(velocity * self.FlipFactor,0):RadRotate(self.RotAngle + spread) * smokeVelocity
				particle.Team = self.Team
				particle.Lifetime = particle.Lifetime * RangeRand(0.9,1.2) * 0.75 * smokeLingering
				particle.AirResistance = particle.AirResistance * 2.5 * RangeRand(0.9,1.1)
				particle.IgnoresTeamHits = true
				particle.AirThreshold = particle.AirThreshold * 0.5
				MovableMan:AddParticle(particle);
			end
			--
			
			local outdoorRays = 0;

			if self.parent and self.parent:IsPlayerControlled() then
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
			else
				self.rayThreshold = 1; -- has to be different for AI
				local Vector2 = Vector(0,-700); -- straight up
				local Vector3 = Vector(0,0); -- dont need this but is needed as an arg
				local Vector4 = Vector(0,0); -- dont need this but is needed as an arg		
				self.ray = SceneMan:CastObstacleRay(self.Pos, Vector2, Vector3, Vector4, self.RootID, self.Team, 128, 7);
				
				self.rayTable = {self.ray};
			end
			
			for _, rayLength in ipairs(self.rayTable) do
				if rayLength < 0 then
					outdoorRays = outdoorRays + 1;
				end
			end
			
			self.debugFireSound:Play(self.Pos);
			
			if outdoorRays >= self.rayThreshold then

			else	

			end		
			
		end
	end	
	
end

function Destroy(self)
	
end