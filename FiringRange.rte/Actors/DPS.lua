
function Create(self)
	self.hits = 0;	-- track hits of damage to determine reloading gap
	
	if self:StringValueExists("rangeGun PresetName") then	-- Firing Range sets PresetName as weapon name and module
		self.quickmode = true;				-- allows instant print mode for weapons
	--[[
		rof = a
		rtm = b 
		hits = c
		
		60000/a+b/c	= avg. time between hits
		
		real RoF from time between hits:
		
		60000/(60000/a+b/c)
		=(60000*a*c)/(a*b+60000*c)
	]]--
		self.gunSpeed = self:GetNumberValue("rangeGun RateOfFire");
		self.gunWeight = "Cost: "..self:GetNumberValue("rangeGun GoldValue").."  Weight: ".. math.floor(self:GetNumberValue("rangeGun Mass") * 10) * 0.1 .."+".. math.floor(self:GetNumberValue("rangeGun MagazineMass") * 10) * 0.1;
		self.gunAccuracy = "Accuracy: ".. math.floor(self:GetNumberValue("rangeGun ShakeRange") * 10) * 0.1 .."/".. math.floor(self:GetNumberValue("rangeGun SharpShakeRange") * 10) * 0.1 .."  Aim distance: "..self:GetNumberValue("rangeGun SharpLength");
	end	
	--self.resetTimer = Timer();
	self.resetDelay = 15000;		-- maximum delay after reset
	DPSprintCount = DPSprintCount and DPSprintCount or 0;

	self.damage = 0;
	self.wounds = 0;
	self.impulse = 0;
	
	self.lastPos = Vector(self.Pos.X, self.Pos.Y);

	self.HUDVisible = false;
end

function Update(self)

	local impPlus = " ";	--
	local impExcl = " ";	-- impulse damage indicators
	
	local damage = 0;	-- 1 wound = 3 Health

	if self.Health < self.MaxHealth then
		damage = damage + (self.MaxHealth - self.Health);
		self.Health = self.MaxHealth;

		self:FlashWhite(10);
	end

	if self.WoundCount > 0 then

		self.wounds = self.wounds + self.WoundCount;
		self:RemoveAnyRandomWounds(self.wounds);

		self:FlashWhite(10);
	end
	local impulses = self:GetImpulsesCount() + math.ceil(math.sqrt(self.Vel.Magnitude));
	if impulses > 10 then	-- don't add tiny nudges
		self.impulse = self.impulse + impulses;--math.ceil(self.Vel.Magnitude*10)*0.1;

		if impulses > 25 then
			damage = damage + math.floor(impulses);

			impPlus = " +impulse";
			impExcl = " !";
			self:FlashWhite(10);
		end
	end
	
	if damage > 0 then
		self.hits = self.hits + 1;
		if self.resetTimer then
			self.hitGap = (self.hitGap + self.resetTimer.ElapsedSimTimeMS) * 0.5;
			self.resetTimer:Reset();
		else
			self.hitGap = 0;
			self.resetTimer = Timer();
		end
		self.damage = self.damage + damage;
	end
	
	if self.damage > 0
	or self.wounds > 0
	or self.impulse > 0 then
	
		if not self.dpsTimer then
			self.dpsTimer = Timer();
		end

		self.dps = math.ceil(self.damage/(self.dpsTimer.ElapsedSimTimeMS * 0.001 + 1) * 10) * 0.1;

		PrimitiveMan:DrawTextPrimitive(self.AboveHUDPos + Vector(-10, -20), "damage: " .. self.damage .. impPlus, true, 0);
		PrimitiveMan:DrawTextPrimitive(self.AboveHUDPos + Vector(-10, -10), "wounds: " .. self.wounds , true, 0);
		PrimitiveMan:DrawTextPrimitive(self.AboveHUDPos + Vector(-10, -0), "impulse: " .. self.impulse .. impExcl, true, 0);

		PrimitiveMan:DrawTextPrimitive(self.AboveHUDPos + Vector(-10, 15), "DPS: " .. math.ceil(self.dps * 10) * 0.1 , true, 0);
		
		if self.quickmode then
			if self:NumberValueExists("rangeGun MaxThrowVel") then
				if self.hits > 0 and self.resetTimer:IsPastSimMS(3000) then
				
					self.gunWeight = "Cost: "..self:GetNumberValue("rangeGun GoldValue").."  Weight: ".. math.floor(self:GetNumberValue("rangeGun Mass") * 10) * 0.1;
					
					DPSprintCount = DPSprintCount + 1;
				ConsoleMan:PrintString("PRINT " .. DPSprintCount .. ": " .. self:GetStringValue("rangeGun PresetName"));
				ConsoleMan:PrintString("Damage: "..self.damage.."  Wounds: "..self.wounds.."  Impulse: "..self.impulse);
				ConsoleMan:PrintString("Throw Distance: " ..self:GetNumberValue("rangeGun MinThrowVel") .."-".. self:GetNumberValue("rangeGun MaxThrowVel"));
				ConsoleMan:PrintString(self.gunWeight);
				
					self.quickmode = false;	-- end sequence
				end
					
			elseif self.hits > 3 then
						
				if self.resetTimer:IsPastSimMS(self.hitGap * 3) or self.dpsTimer:IsPastSimMS(self.resetDelay) then
					DPSprintCount = DPSprintCount + 1;
				-- calculate true RoF from total
					local hitsvar = self.hits;	-- take roundcount to account if able?
					if self:GetNumberValue("rangeGun Ammo") > 0 and self:GetNumberValue("rangeGun Ammo") <= self. hits then
						hitsvar = self:GetNumberValue("rangeGun Ammo");
					end
					self.gunSpeed = math.floor((60000*self:GetNumberValue("rangeGun RateOfFire") * hitsvar)/(self:GetNumberValue("rangeGun RateOfFire")*self:GetNumberValue("rangeGun ReloadTime") + 60000 * hitsvar));
				
				ConsoleMan:PrintString("PRINT " .. DPSprintCount .. ": " .. self:GetStringValue("rangeGun PresetName"));
				--ConsoleMan:PrintString("damage: "..self.damage.."  wounds: "..self.wounds.."  impulse: "..self.impulse);
				ConsoleMan:PrintString("DPS: " .. self.dps .. "  damage per wound: " ..math.ceil(self.damage/3/self.wounds * 10) * 0.1);
				ConsoleMan:PrintString(self.gunWeight);
				ConsoleMan:PrintString("True RoF: "..self.gunSpeed);
				ConsoleMan:PrintString(self.gunAccuracy);
				local score = self.dps
							-- different aspects have different weight on the score, represented by the multipliers at the end
							/ (1 + math.abs(self:GetNumberValue("rangeGun Mass") + self:GetNumberValue("rangeGun MagazineMass")) * 0.1)
							/ (1 + math.abs(self:GetNumberValue("rangeGun ShakeRange")) * 0.05)
							/ (1 + math.abs(self:GetNumberValue("rangeGun SharpShakeRange")) * 0.05)
							/ (1 + math.abs(self:GetNumberValue("rangeGun GoldValue")) * 0.005)
							* (1 + self.gunSpeed * 0.0025)
							* (1 + math.abs(self:GetNumberValue("rangeGun SharpLength")) * 0.005)	-- can vaguely correlate to actual lethal range
							* (1 + math.abs(self:GetNumberValue("rangeGun FullAuto")) * 0.1)	-- 0 or 1
							* (1 + math.abs(self:GetNumberValue("rangeGun OneHanded/DualWieldable")) * 0.05)	-- OneHanded = 1, DualWieldable = 2
							;
				--ConsoleMan:PrintString("SCORE: "..math.floor(score*10)/10);	-- not reliable yet
				ConsoleMan:PrintString("----------------");
					self.quickmode = false;	-- end sequence
				end
			end
		end
	end
	if self.resetTimer and self.resetTimer:IsPastSimMS(self.resetDelay) then
		self.damage = 0;
		self.wounds = 0;
		self.impulse = 0;
		self.dps = 0;
		self.hits = 0;
		self.hitGap = nil;
		self.PinStrength = 1;

		self.dpsTimer = nil;
		self.resetTimer = nil;
	end

	if self:GetController():IsState(Controller.BODY_JUMP) then
		self.lastPos = self.lastPos + Vector(0, -1);
	end
	if self:GetController():IsState(Controller.BODY_CROUCH) then
		self.lastPos = self.lastPos + Vector(0, 1);
	end
	if self:GetController():IsState(Controller.MOVE_LEFT) then
		self.lastPos = self.lastPos + Vector(-1, 0);
		self.HFlipped = true;
	end
	if self:GetController():IsState(Controller.MOVE_RIGHT) then
		self.lastPos = self.lastPos + Vector(1, 0);
		self.HFlipped = false;
	end

	self.Pos = Vector(self.lastPos.X, self.lastPos.Y);
	self.lastPos = Vector(self.Pos.X, self.Pos.Y);
	self.Vel = Vector();
	self.AngularVel = 0;
	self.RotAngle = 0;
end