
function Create(self)

	self.smokeTrailLifeTime = self:NumberValueExists("SmokeTrailLifeTime") and self:GetNumberValue("SmokeTrailLifeTime") or 2500;
	self.smokeTrailSize = self:NumberValueExists("SmokeTrailSize") and self:GetNumberValue("SmokeTrailSize") or 13;
	self.smokeTrailRadius = self:NumberValueExists("SmokeTrailRadius") and self:GetNumberValue("SmokeTrailRadius") or 4;
	self.smokeTrailTwirl = self:NumberValueExists("SmokeTrailTwirl") and self:GetNumberValue("SmokeTrailTwirl") or 1;
	
	self.smokeAirThreshold = 5/(1 + self.smokeTrailLifeTime * 0.01);
	self.smokeTwirlCounter = math.random() < 0.5 and math.pi or 0;

	self.scaryDistantLoopSound = CreateSoundContainer("Scary Loop Distant Quicket", "Massive.rte");
	self.scaryDistantLoopSound.Volume = 0;
	self.scaryDistantLoopSound:Play(self.Pos);
	
	self.scaryCloseLoopSound = CreateSoundContainer("Scary Loop Close Quicket", "Massive.rte");
	self.scaryCloseLoopSound.Volume = 0;
	self.scaryCloseLoopSound:Play(self.Pos);
	self.rocketBlastLoopSound = CreateSoundContainer("Rocket Blast Loop Quicket", "Massive.rte");
	self.rocketBlastLoopSound.Volume = 0;
	self.rocketBlastLoopSound:Play(self.Pos);
	self.windLoopSound = CreateSoundContainer("Wind Loop Quicket", "Massive.rte");
	self.windLoopSound.Volume = 0;
	self.windLoopSound:Play(self.Pos);
	
	self.abortFlyBySound = CreateSoundContainer("Abort FlyBy Quicket", "Massive.rte");

	self.originPos = Vector(self.Pos.X, self.Pos.Y);

	self.targetID = self:GetNumberValue("Parent Grenade ID");
	self.target = MovableMan:FindObjectByUniqueID(self.targetID);
	self.targetPos = self.target.Pos
	
	self.phase = 0;
	
	self.Timer = Timer();
	self.arrivalDelay = 6000;
	self.leaveDelay = 2500;
	
	-- phase 0 inbound
	-- phase 1 inbound close
	-- phase 2 inbound actual (death time)
	-- phase 3 abort start


end

function Update(self)

	local offset = self.Vel * rte.PxTravelledPerFrame;	--The effect will be created the next frame so move it one frame backwards towards the barrel
	
	local trailLength = math.floor(offset.Magnitude/self.smokeTrailSize - self.smokeTrailSize);
	local setVel = Vector(self.Vel.X, self.Vel.Y):SetMagnitude(math.sqrt(self.Vel.Magnitude));
	for i = 1, trailLength do
		local effect = self.smokeTrailSize < 2 and CreateMOPixel("Micro Smoke Trail " .. math.random(3), "Base.rte") or CreateMOSParticle((self.smokeTrailSize < 3 and "Tiny" or "Small") .. " Smoke Trail " .. math.random(3), "Base.rte");
		effect.Pos = self.Pos - (offset * i/trailLength) + Vector(RangeRand(-1, 1), RangeRand(-1, 1)) * self.smokeTrailRadius;
		effect.Vel = setVel * RangeRand(0.6, 1);
		effect.Lifetime = self.smokeTrailLifeTime * RangeRand(0.4, 1) * (self.Lifetime > 1 and 1 - self.Age/self.Lifetime or 1);
		effect.AirResistance = effect.AirResistance * RangeRand(0.8, 1);
		effect.AirThreshold = self.smokeAirThreshold;
	
		if self.smokeTrailTwirl > 0 then
			effect.GlobalAccScalar = effect.GlobalAccScalar * math.random();

			effect.Pos = self.Pos - offset + (offset * i/trailLength);
			effect.Vel = setVel + Vector(0, math.sin(self.smokeTwirlCounter) * self.smokeTrailTwirl + RangeRand(-0.1, 0.1)):RadRotate(self.Vel.AbsRadAngle);
			
			self.smokeTwirlCounter = self.smokeTwirlCounter + RangeRand(-0.2, 0.4);
		end
		MovableMan:AddParticle(effect);
	end

	self.scaryDistantLoopSound.Pos = self.Pos;
	self.scaryCloseLoopSound.Pos = self.Pos;
	self.rocketBlastLoopSound.Pos = self.Pos;
	self.windLoopSound.Pos = self.Pos;

	if self.phase == 0 then
	
		self.PinStrength = 10000;
		self.originPos = self.Pos; -- pin in place, we should be outside the map
		
		if self.scaryDistantLoopSound.Volume < 0.5 then
			self.scaryDistantLoopSound.Volume = self.scaryDistantLoopSound.Volume + 0.009 * TimerMan.DeltaTimeSecs;
		end
	
		if self:NumberValueExists("Abort") then
			self.phase = 3;
			self.abortFlyBySound:Play(self.Pos);
			self.Timer:Reset();
		elseif self:NumberValueExists("Tracked") then
			self:EnableEmission(true);
			self.phase = 1;
			self.Timer:Reset();
		end
		
		-- explosive end towards enemy
		
		local dif = SceneMan:ShortestDistance(self.Pos,self.targetPos,SceneMan.SceneWrapsX);
		
		local angToTarget = dif.AbsRadAngle
		
		local velCurrent = self.Vel-- + SceneMan.GlobalAcc
		local velTarget = Vector(100, 0):RadRotate(angToTarget)
		local velDif = velTarget - velCurrent
		
		local min_value = -math.pi;
		local max_value = math.pi;
		local value = velDif.AbsRadAngle - self.RotAngle
		local result;
		
		local range = max_value - min_value;
		if range <= 0 then
			result = min_value;
		else
			local ret = (value - min_value) % range;
			if ret < 0 then ret = ret + range end
			result = ret + min_value;
		end
		
		self.RotAngle = self.RotAngle + result * TimerMan.DeltaTimeSecs * 25
		
	elseif self.phase == 1 then
	
		self.PinStrength = 10000;
		self.originPos = self.Pos; -- pin in place, we should be outside the map
		
		if self.scaryDistantLoopSound.Volume > 0 then
			self.scaryDistantLoopSound.Volume = self.scaryDistantLoopSound.Volume - 0.1 * TimerMan.DeltaTimeSecs;
			if self.scaryDistantLoopSound.Volume < 0 then
				self.scaryDistantLoopSound.Volume = 0;
			end
		end
		
		if self.scaryCloseLoopSound.Volume < 1 then
			self.scaryCloseLoopSound.Volume = self.scaryCloseLoopSound.Volume + 0.1 * TimerMan.DeltaTimeSecs;
		end
		
		if self.rocketBlastLoopSound.Volume < 1 then
			self.rocketBlastLoopSound.Volume = self.rocketBlastLoopSound.Volume + 0.1 * TimerMan.DeltaTimeSecs;
		end
		
		if self.windLoopSound.Volume < 0.8 then
			self.windLoopSound.Volume = self.windLoopSound.Volume + 0.1 * TimerMan.DeltaTimeSecs;
		end
		
		-- explosive end towards enemy
		
		local dif = SceneMan:ShortestDistance(self.Pos,self.targetPos,SceneMan.SceneWrapsX);
		
		local angToTarget = dif.AbsRadAngle
		
		local velCurrent = self.Vel-- + SceneMan.GlobalAcc
		local velTarget = Vector(100, 0):RadRotate(angToTarget)
		local velDif = velTarget - velCurrent
		
		local min_value = -math.pi;
		local max_value = math.pi;
		local value = velDif.AbsRadAngle - self.RotAngle
		local result;
		
		local range = max_value - min_value;
		if range <= 0 then
			result = min_value;
		else
			local ret = (value - min_value) % range;
			if ret < 0 then ret = ret + range end
			result = ret + min_value;
		end
		
		self.RotAngle = self.RotAngle + result * TimerMan.DeltaTimeSecs * 25
		
		if self:NumberValueExists("Abort") then
			self.phase = 3;
			self.abortFlyBySound:Play(self.Pos);
			self.Timer:Reset();
		elseif self.Timer:IsPastSimMS(self.arrivalDelay) then
			self.phase = 2;
			self.Vel = Vector(130, 0):RadRotate(angToTarget)
		end
		

	elseif self.phase == 2 then
	
		self.PinStrength = 0;
	
		if self.scaryCloseLoopSound.Volume < 1 then
			self.scaryCloseLoopSound.Volume = self.scaryCloseLoopSound.Volume + 5 * TimerMan.DeltaTimeSecs;
		end
		
		if self.rocketBlastLoopSound.Volume < 1 then
			self.rocketBlastLoopSound.Volume = self.rocketBlastLoopSound.Volume + 5 * TimerMan.DeltaTimeSecs;
		end
		
		if self.windLoopSound.Volume < 1 then
			self.windLoopSound.Volume = self.windLoopSound.Volume + 5 * TimerMan.DeltaTimeSecs;
		end
	
		local dif = SceneMan:ShortestDistance(self.Pos,self.targetPos,SceneMan.SceneWrapsX);
		
		local angToTarget = dif.AbsRadAngle
		
		local velCurrent = self.Vel-- + SceneMan.GlobalAcc
		local velTarget = Vector(130, 0):RadRotate(angToTarget)
		local velDif = velTarget - velCurrent
		
		
		-- Frotate self.hoverDirection
		local min_value = -math.pi;
		local max_value = math.pi;
		local value = velDif.AbsRadAngle - self.RotAngle
		local result;
		
		local range = max_value - min_value;
		if range <= 0 then
			result = min_value;
		else
			local ret = (value - min_value) % range;
			if ret < 0 then ret = ret + range end
			result = ret + min_value;
		end
		
		self.RotAngle = self.RotAngle + result * TimerMan.DeltaTimeSecs * 1
		
		-- acceleration
		self.Vel = self.Vel + Vector(math.pow(math.min(velDif.Magnitude, 25), 1.5), 0):RadRotate(self.RotAngle) * TimerMan.DeltaTimeSecs

	
	elseif self.phase == 3 then

		if self.scaryDistantLoopSound.Volume < 0.5 then
			self.scaryDistantLoopSound.Volume = self.scaryDistantLoopSound.Volume + 0.045 * TimerMan.DeltaTimeSecs;
		end
		
		if self.scaryCloseLoopSound.Volume > 0 then
			self.scaryCloseLoopSound.Volume = self.scaryCloseLoopSound.Volume - 0.045 * TimerMan.DeltaTimeSecs;
			if self.scaryCloseLoopSound.Volume < 0 then
				self.scaryCloseLoopSound.Volume = 0;
			end
		end
		
		if self.rocketBlastLoopSound.Volume > 0 then
			self.rocketBlastLoopSound.Volume = self.rocketBlastLoopSound.Volume - 0.045 * TimerMan.DeltaTimeSecs;
			if self.rocketBlastLoopSound.Volume < 0 then
				self.rocketBlastLoopSound.Volume = 0;
			end
		end
		
		if self.windLoopSound.Volume > 0 then
			self.windLoopSound.Volume = self.windLoopSound.Volume - 0.060 * TimerMan.DeltaTimeSecs;
			if self.windLoopSound.Volume < 0 then
				self.windLoopSound.Volume = 0;
			end
		end
		
		if self.Timer:IsPastSimMS(self.leaveDelay) then
			self.Aborted = true;
			self.scaryCloseLoopSound:Stop(-1);
			self.rocketBlastLoopSound:Stop(-1);
			self.windLoopSound:Stop(-1);
			self.scaryDistantLoopSound:FadeOut(6000);
			
			self.ToDelete = true;
		end
	end
	
	if MovableMan:ValidMO(self.target) then
		self.targetPos = self.target.Pos;
	end
	
end
	
function OnCollideWithTerrain(self, terrPixel)

	
end

function Destroy(self)

	if not self.Aborted then
		self.scaryDistantLoopSound:Stop(-1);
	end
	
	self.scaryCloseLoopSound:Stop(-1);
	self.rocketBlastLoopSound:Stop(-1);
	self.windLoopSound:Stop(-1);

	
end