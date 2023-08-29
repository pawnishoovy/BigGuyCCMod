function Create(self)

	self.targetLockSound = CreateSoundContainer("CIWS Target Lock Halifax Massive", "Massive.rte");

	self.turnSpeed = 0.015;	--Speed of the turret turning, in rad per frame
	self.searchRange = self:NumberValueExists("TurretSearchRange") and self:GetNumberValue("TurretSearchRange") or 250;	--Detection area diameter or max ray distance to search enemies from, in px
	--Whether turret searches for enemies in a larger area. Default mode is a narrower ray detection
	self.areaMode = true;
	--Toggle visibility of the aim area / trace to see how the detection works
	self.showAim = false;
	--Angle alteration variables (do not touch)
	self.rotation = 0;	--Left / Right movement affecting turret angle
	self.verticalFactor = 0;	--How Up / Down movement affects turret angle
	
	self.fireTimer = Timer();
	self.fireTimer:SetSimTimeLimitMS(200);
	
	self.parent = ToACDropShip(self:GetRootParent());
	
end
function Update(self)
	
	if IsACDropShip(self.parent) then
		--Aim directly away from self.parent
		local posTrace = SceneMan:ShortestDistance(self.parent.Pos, self.Pos, SceneMan.SceneWrapsX):SetMagnitude(self.searchRange * 0.5);
		self.RotAngle = (math.pi * 0.5 * self.verticalFactor + posTrace.AbsRadAngle + (self.parent.HFlipped and math.pi or 0))/(1 + self.verticalFactor) - self.rotation;
		if IsActor(self.parent) then
			self.parent = ToActor(self.parent);
			if self.parent.Status ~= Actor.STABLE then
				return;
			end
			local controller = self.parent:GetController();
				
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
		if self.target and MovableMan:ValidMO(self.target) then
			local dist = SceneMan:ShortestDistance(self.Pos , self.target.Pos,true).Magnitude;
			if dist < 1000 then
				local angle = SceneMan:ShortestDistance(self.Pos,self.target.Pos, true).AbsRadAngle;

				
				local framestotarget = math.floor(SceneMan:ShortestDistance(self.Pos,self.target.Pos, true).Magnitude / 180);
				local adjustedfireposition = self.target.Pos + (self.target.Vel * framestotarget);
				
				local firevector = SceneMan:ShortestDistance(self.Pos,adjustedfireposition, true);					
				
				local terrCheck = SceneMan:CastStrengthRay(self.Pos, firevector, 30, Vector(), 5, 0, SceneMan.SceneWrapsX);
				
				if terrCheck == false then
					
					self.RotAngle = firevector.AbsRadAngle;

					self:EnableEmission(true);		
				else
					self.target = nil;
					self:EnableEmission(false);	
				end
			else
				self.target = nil;
				self:EnableEmission(false);	
			end
		else
			self.target = nil;
			self:EnableEmission(false);	
			for p in MovableMan:GetMOsInRadius(self.Pos, 1000, self.Team, true) do
				if p.ClassName == "MOSRotating" or p.ClassName == "AEmitter" then

					if (p.HitsMOs) and p.Team ~= self.Team and p.Team ~= -1 and p.Vel.Magnitude > 10 then
					
						local angle = SceneMan:ShortestDistance(self.Pos,p.Pos, true).AbsRadAngle;

						
						local framestotarget = math.floor(SceneMan:ShortestDistance(self.Pos,p.Pos, true).Magnitude / 180);
						local adjustedfireposition = p.Pos + (p.Vel * framestotarget);
						
						local firevector = SceneMan:ShortestDistance(self.Pos,adjustedfireposition, true);					
						
						local terrCheck = SceneMan:CastStrengthRay(self.Pos, firevector, 30, Vector(), 5, 0, SceneMan.SceneWrapsX);
						
						if terrCheck == false then
							
							self.targetLockSound:Play(self.Pos);
							self.target = p;
							self.RotAngle = firevector.AbsRadAngle;
	
							self.fireTimer:Reset();
							self:EnableEmission(true);		
							self:TriggerBurst();
						end
					end
				end
			end
		end
	else
		self:GibThis();
	end
	if self.fireTimer:IsPastSimTimeLimit() then
		self:EnableEmission(false);
	end
end
