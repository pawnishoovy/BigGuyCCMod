function OnDetach(self)

	self.jetFactor = 0;

	self:RemoveNumberValue("AI Parry")
	self:RemoveNumberValue("AI Parry Eligible")

	if self.wasThrown == true then
	
		self.throwWounds = 20;
		self.throwPitch = 0.7;
	
		self.HUDVisible = false;
		
		self:EnableScript("Massive.rte/Devices/Weapons/Melee/JetAxe/TwirlPierceThrow.lua");
		self.thrownTeam = self.Team;
		
		self.stickMO = nil;
		self.stickVecX = 0;
		self.stickVecY = 0;
		self.stickRot = 0;
		self.stickDeepness = RangeRand(0.1, 1);

		self.stuck = false;
		
		self.phase = 0;
	end

	self:DisableScript("Massive.rte/Devices/Weapons/Melee/JetAxe/JetAxe.lua");
	
	self:RemoveStringValue("Parrying Type");
	self.Parrying = false;
	
	self.Blocking = false;
	self:RemoveNumberValue("Blocking");
	
	self.currentAttackAnimation = 0;
	self.currentAttackSequence = 0;
	self.currentAttackStart = false
	self.attackAnimationIsPlaying = false
	
	self.rotationInterpolationSpeed = 25;
	
	self.Frame = 0;
	
	self.canBlock = false;
	
end

function OnAttach(self)

	self.HUDVisible = true;

	self:DisableScript("Massive.rte/Devices/Weapons/Melee/JetAxe/TwirlPierceThrow.lua");
	self.PinStrength = 0;

	self:EnableScript("Massive.rte/Devices/Weapons/Melee/JetAxe/JetAxe.lua");
	
	if self.RootID == 255 then --equipped from inv
	
		self.equipAnim = true;
		
		-- local rotationTarget = 170 / 180 * math.pi
		-- local stanceTarget = Vector(-15, -25);
	
		-- self.stance = self.stance + stanceTarget
		
		-- rotationTarget = rotationTarget * self.FlipFactor
		-- self.rotation = self.rotation + rotationTarget
		
		-- self.StanceOffset = self.originalStanceOffset + self.stance
		-- self.RotAngle = self.RotAngle + self.rotation
		
	end
	
	self.canBlock = true;
	
end

function Update(self)

	if self.activeSound then
		self.activeSound.Pos = self.Pos;
	end
	
	if self.canBlock == false then
		if self.WoundCount > self.woundCounter then
			self.woundCounter = self.WoundCount;
			-- self.breakSound:Play(self.Pos);
		end
	end
	
end