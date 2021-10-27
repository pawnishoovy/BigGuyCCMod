function Create(self)

	self.rattleLoopSound = CreateSoundContainer("Turret Rattle Loop Halifax Massive", "Massive.rte");
	self.rattleLoopSound.Volume = 0;
	self.rattleLoopSound:Play(self.Pos);
	self.rattleEndSound = CreateSoundContainer("Turret Rattle End Halifax Massive", "Massive.rte");

	self.turnSpeed = 0.015;	--Speed of the turret turning, in rad per frame
	self.searchRange = 500;	--Detection area diameter or max ray distance to search enemies from, in px
	--Whether turret searches for enemies in a larger area. Default mode is a narrower ray detection
	self.areaMode = true;
	--Toggle visibility of the aim area / trace to see how the detection works
	self.showAim = false;
	--Angle alteration variables (do not touch)
	self.rotation = 0;	--Left / Right movement affecting turret angle
	self.verticalFactor = 0;	--How Up / Down movement affects turret angle
	
	self.fireTimer = Timer();
	self.fireTimer:SetSimTimeLimitMS(500);
	
	self.cooldownTimer = Timer();
	self.cooldownDelay = math.random(300, 900);
	
end
function Update(self)

	self.rattleLoopSound.Pos = self.Pos;
	self.rattleEndSound.Pos = self.Pos;
	
	local parent = self:GetRootParent();
	if parent then
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
		if self.areaMode then	--Area Mode
			local aimPos = self.Pos + Vector((self.searchRange * 0.5), 0):RadRotate(self.RotAngle);
			--Debug: visualize aim area
			if self.showAim then
				PrimitiveMan:DrawCirclePrimitive(self.Team, aimPos, (self.searchRange * 0.5), 13);
			end
			local aimTarget = MovableMan:GetClosestEnemyActor(self.Team, aimPos, (self.searchRange * 0.5), Vector());
			if aimTarget and aimTarget.Status < Actor.INACTIVE then
				--Debug: visualize search trace
				if self.showAim then
					PrimitiveMan:DrawLinePrimitive(self.Team, aimPos, aimTarget.Pos, 13);
				end
				--Check that the target isn't obscured by terrain
				local aimTrace = SceneMan:ShortestDistance(self.Pos, aimTarget.Pos, SceneMan.SceneWrapsX);
				local terrCheck = SceneMan:CastStrengthRay(self.Pos, aimTrace, 30, Vector(), 5, 0, SceneMan.SceneWrapsX);
				if terrCheck == false and self.cooldownTimer:IsPastSimMS(self.cooldownDelay) then
					self.RotAngle = aimTrace.AbsRadAngle;
					--Debug: visualize aim trace
					if self.showAim then
						PrimitiveMan:DrawLinePrimitive(self.Team, self.Pos, aimTarget.Pos, 254);
					end
					self.rattleLoopSound.Volume = 1;
					if not self:IsEmitting() then
						self.fireTimer:SetSimTimeLimitMS(math.random(400, 1400));
						self.fireTimer:Reset();
					end
					self:EnableEmission(true);
					self:TriggerBurst();
				end
			end
		end
	end
	if self:IsEmitting() and self.fireTimer:IsPastSimTimeLimit() then
		self.rattleLoopSound.Volume = 0;
		self.rattleEndSound:Play(self.Pos);
		self.cooldownDelay = math.random(300, 900);
		self.cooldownTimer:Reset();
		self:EnableEmission(false);
	end
end

function Destroy(self)

	self.rattleLoopSound:Stop(-1);
	self.rattleEndSound:Stop(-1);
	
end