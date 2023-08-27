function Create(self)

	self.parentSet = false;
	
	if self:GetRootParent() and self:GetRootParent().PresetName == "Massive" or self:GetRootParent().PresetName == "Zedmassive" then
		self.equippedByMassive = true;
	else
		self.equippedByMassive = false;
	end
	
	-- Sounds --
	
	self.preSound = CreateSoundContainer("Pre Brutum", "Massive.rte");
	self.satisfyingAddSound = CreateSoundContainer("SatisfyingAdd Brutum", "Massive.rte");
	self.mechSound = CreateSoundContainer("Mech Brutum", "Massive.rte");
	
	self.debrisIndoorsSound = CreateSoundContainer("Debris Indoors DualSniper", "Massive.rte");
	
	self.reflectionOutdoorsSound = CreateSoundContainer("ReflectionOutdoors Brutum", "Massive.rte");
	self.satisfyingReflectionOutdoorsSound = CreateSoundContainer("SatisfyingReflectionOutdoors Brutum", "Massive.rte");
	-- bit ridiculous at this point isnt it
	self.ExtraSatisfyingReflectionOutdoorsSound = CreateSoundContainer("ExtraSatisfyingReflectionOutdoors Brutum", "Massive.rte");
	self.satisfyingVolume = 0;
	
	self.meleeSound = CreateSoundContainer("Melee Brutum", "Massive.rte");
	
	self.extraLoadCloseAddSound = CreateSoundContainer("ExtraLoadCloseAdd Brutum", "Massive.rte");
	self.extraLoadCloseAddFinalSound = CreateSoundContainer("ExtraLoadCloseAddFinal Brutum", "Massive.rte");
	
	self.reflectionIndoorsSound = CreateSoundContainer("ReflectionIndoors Brutum", "Massive.rte");
	
	self.reloadPrepareSounds = {}
	self.reloadPrepareSounds.Raise = nil;
	self.reloadPrepareSounds.Open = CreateSoundContainer("OpenPrepare Brutum", "Massive.rte");
	self.reloadPrepareSounds.FirstShellIn = CreateSoundContainer("ShellInPrepare Brutum", "Massive.rte");
	self.reloadPrepareSounds.FirstShellInClose = nil;
	self.reloadPrepareSounds.ShellIn = CreateSoundContainer("ShellInPrepare Brutum", "Massive.rte");
	self.reloadPrepareSounds.Close = nil;
	
	self.reloadPrepareLengths = {}
	self.reloadPrepareLengths.Raise = 0
	self.reloadPrepareLengths.Open = 100
	self.reloadPrepareLengths.FirstShellIn = 280
	self.reloadPrepareLengths.FirstShellInClose = 0
	self.reloadPrepareLengths.ShellIn = 250
	self.reloadPrepareLengths.Close = 0
	
	self.reloadPrepareDelay = {}
	self.reloadPrepareDelay.Raise = 50
	self.reloadPrepareDelay.Open = 400
	self.reloadPrepareDelay.FirstShellIn = 600
	self.reloadPrepareDelay.FirstShellInClose = 300
	self.reloadPrepareDelay.ShellIn = 450
	self.reloadPrepareDelay.Close = 300
	
	self.reloadAfterSounds = {}
	self.reloadAfterSounds.Raise = CreateSoundContainer("Raise Brutum", "Massive.rte");
	self.reloadAfterSounds.Open = CreateSoundContainer("Open Brutum", "Massive.rte");
	self.reloadAfterSounds.FirstShellIn = CreateSoundContainer("FirstShellIn Brutum", "Massive.rte");
	self.reloadAfterSounds.FirstShellInClose = CreateSoundContainer("Close Brutum", "Massive.rte");
	self.reloadAfterSounds.ShellIn = CreateSoundContainer("ShellIn Brutum", "Massive.rte");
	self.reloadAfterSounds.Close = CreateSoundContainer("Close Brutum", "Massive.rte");
	
	self.reloadAfterDelay = {}
	self.reloadAfterDelay.Raise = 450
	self.reloadAfterDelay.Open = 200
	self.reloadAfterDelay.FirstShellIn = 300
	self.reloadAfterDelay.FirstShellInClose = 400
	self.reloadAfterDelay.ShellIn = 380
	self.reloadAfterDelay.Close = 750
	
	self.reloadTimer = Timer();
	
	self.reloadPhase = 0;
	
	self.BaseReloadTime = 12000;

	self.parentSet = false;
	
	self.rotation = 0
	self.rotationTarget = 0
	self.rotationSpeed = 6
	
	self.horizontalAnim = 0
	self.verticalAnim = 0
	
	self.angVel = 0
	self.lastRotAngle = (self.RotAngle + self.InheritedRotAngleOffset)
	
	self.originalSharpLength = self.SharpLength
	
	self.originalStanceOffset = Vector(math.abs(self.StanceOffset.X), self.StanceOffset.Y)
	self.originalSharpStanceOffset = Vector(self.SharpStanceOffset.X, self.SharpStanceOffset.Y)
	
	self.originalJointOffset = Vector(self.JointOffset.X, self.JointOffset.Y)
	self.originalSupportOffset = Vector(math.abs(self.SupportOffset.X), self.SupportOffset.Y)
	
	self.FireTimer = Timer();
	self.powNum = 0.1;
	
	self.GFXTimer = Timer();
	self.GFXDelay = 50;
	
	self.heatNum = 0;
	
	self.delayedFire = false
	self.delayedFireTimer = Timer();
	self.delayedFireTimeMS = 50
	self.delayedFireEnabled = true
	
	self.lastAge = self.Age + 0
	
	self.fireDelayTimer = Timer()
	
	self.activated = false
	
	self.ammoCount = 6
	
	self.shoveTimer = Timer();
	self.shoveCooldown = 700;
	
	self.extraRounds = 0;
	
end

function Update(self)
	self.rotationTarget = 0 -- ZERO IT FIRST AAAA!!!!!
	
	if self.ID == self.RootID then
		self.parent = nil;
		self.parentSet = false;
	elseif self.parentSet == false then
		local actor = MovableMan:GetMOFromID(self.RootID);
		if actor and IsAHuman(actor) then
			self.parent = ToAHuman(actor);
			self.parentSet = true;
		end
	end
	
    -- Smoothing
    local min_value = -math.pi;
    local max_value = math.pi;
    local value = self.RotAngle - self.lastRotAngle
    local result;
    local ret = 0
    
    local range = max_value - min_value;
    if range <= 0 then
        result = min_value;
    else
        ret = (value - min_value) % range;
        if ret < 0 then ret = ret + range end
        result = ret + min_value;
    end
    
    self.lastRotAngle = self.RotAngle
    self.angVel = (result / TimerMan.DeltaTimeSecs) * self.FlipFactor
    
    if self.lastHFlipped ~= nil then
        if self.lastHFlipped ~= self.HFlipped then
            self.lastHFlipped = self.HFlipped
            self.angVel = 0
        end
    else
        self.lastHFlipped = self.HFlipped
    end
	

	if self.reChamber then
		if self:IsReloading() then
			self.Reloading = true;
			self.reloadCycle = true;
			if self.ammoCount == 0 then
				self.reloadPhase = 0;
			else
				self.reloadPhase = 0;
			end
		end
		self.reChamber = false;
		self.Chamber = true;
	end
	
	if self:IsReloading() and (not self.Chamber) then -- if we start reloading from "scratch"
		self.Chamber = true;
		self.BaseReloadTime = 19999;
		self.Reloading = true;
		self.reloadCycle = true;
		self.reloadPhase = 0;
	end
	
	if self.parent then
	
		local ctrl = self.parent:GetController();
		local screen = ActivityMan:GetActivity():ScreenOfPlayer(ctrl.Player);
		
		if self.resumeReload then
			self:Reload();
			self.resumeReload = false;
			if self.reloadPhase == 4 and self.ammoCount == 6 then
				self.reloadPhase = 5;
			end
		end
		if self.Chamber then
			self:Deactivate();
			if self:IsReloading() then
				
				-- Fancy Reload Progress GUI
				if not (not self.reloadCycle and self.parent:GetController():IsState(Controller.WEAPON_FIRE)) and self.parent:IsPlayerControlled() then
					for i = 1, self.ammoCount do
						local color = 120
						local spacing = 4
						local offset = Vector(0 - spacing * 0.5 + spacing * (i) - spacing * self.ammoCount / 2, (self.ammoCountRaised and i == self.ammoCount) and 35 or 36)
						local position = self.parent.AboveHUDPos + offset
						PrimitiveMan:DrawCirclePrimitive(position + Vector(0,-2), 1, color);
						PrimitiveMan:DrawLinePrimitive(position + Vector(1,-3), position + Vector(1,3), color);
						PrimitiveMan:DrawLinePrimitive(position + Vector(-1,-3), position + Vector(-1,3), color);
						PrimitiveMan:DrawLinePrimitive(position + Vector(1,3), position + Vector(-1,3), color);
					end
				end
				
				if self.Reloading == false then
					self.reloadCycle = true;
					self.BaseReloadTime = 19999;
					self.Reloading = true;
					-- self.reloadTimer:Reset();
					-- self.prepareSoundPlayed = false;
					-- self.afterSoundPlayed = false;
				end
				
			else
				self.Reloading = false;
			end
			
			
			if self.reloadPhase == 0 then
			
				self.reloadDelay = self.reloadPrepareDelay.Raise;
				self.afterDelay = self.reloadAfterDelay.Raise;		
				
				self.prepareSound = nil;
				self.prepareSoundLength = nil;
				self.afterSound = self.reloadAfterSounds.Raise;
				
				self.rotationTarget = 30;
			
			elseif self.reloadPhase == 1 then
			
				self.reloadDelay = self.fasterPump and self.reloadPrepareDelay.Open / 2 or self.reloadPrepareDelay.Open;
				self.afterDelay = self.reloadAfterDelay.Open;		
				
				self.prepareSound = self.reloadPrepareSounds.Open;
				self.prepareSoundLength = self.reloadPrepareLengths.Open;
				self.afterSound = self.reloadAfterSounds.Open;
				
				if self:IsReloading() then
					self.rotationTarget = (30 * self.reloadTimer.ElapsedSimTimeMS / (self.reloadDelay + self.afterDelay))
				else
					self.rotationTarget = (20 * self.reloadTimer.ElapsedSimTimeMS / (self.reloadDelay + self.afterDelay))
				end
				
			elseif self.reloadPhase == 2 then

				self.reloadDelay = self.reloadPrepareDelay.FirstShellIn;
				self.afterDelay = self.reloadAfterDelay.FirstShellIn;		
				
				self.prepareSound = self.reloadPrepareSounds.FirstShellIn;
				self.prepareSoundLength = self.reloadPrepareLengths.FirstShellIn;
				self.afterSound = self.reloadAfterSounds.FirstShellIn;
				
				self.rotationTarget = 27
				
			elseif self.reloadPhase == 3 then
			
				self.reloadDelay = self.reloadPrepareDelay.FirstShellInClose;
				self.afterDelay = self.reloadAfterDelay.FirstShellInClose;		
				
				self.prepareSound = nil;
				self.prepareSoundLength = nil;
				self.afterSound = self.reloadAfterSounds.FirstShellInClose;
				
				self.rotationTarget = 32
				
			elseif self.reloadPhase == 4 then
			
				self.reloadDelay = self.reloadPrepareDelay.ShellIn;
				self.afterDelay = self.reloadAfterDelay.ShellIn;		
				
				self.prepareSound = self.reloadPrepareSounds.ShellIn;
				self.prepareSoundLength = self.reloadPrepareLengths.ShellIn;
				self.afterSound = self.reloadAfterSounds.ShellIn;
				
				self.rotationTarget = 15 + (5 * self.reloadTimer.ElapsedSimTimeMS / (self.reloadDelay + self.afterDelay))
				
			elseif self.reloadPhase == 5 then

				self.reloadDelay = self.fasterPump and self.reloadPrepareDelay.Close / 2 or self.reloadPrepareDelay.Close;
				self.afterDelay = self.fasterPump and self.reloadAfterDelay.Close / 2 or self.reloadAfterDelay.Close;	
				
				self.prepareSound = nil;
				self.prepareSoundLength = nil;
				self.afterSound = self.reloadAfterSounds.Close;
				
				self.rotationTarget = -5
				
			end
			
			if self.prepareSoundPlayed ~= true then
				self.prepareSoundPlayed = true;
				if self.prepareSound then
					self.prepareSound:Play(self.Pos);
				end
			end
			
			if self.reloadTimer:IsPastSimMS(self.reloadDelay) then
				--[[
				if self.reloadPhase == 0 and self.Casing then
					local shell
					shell = CreateMOSParticle("Shell Shotgun");
					shell.Pos = self.Pos+Vector(0,-3):RadRotate(self.RotAngle);
					shell.Vel = self.Vel+Vector(-math.random(2,4)*self.FlipFactor,-math.random(3,4)):RadRotate(self.RotAngle);
					MovableMan:AddParticle(shell);
					
					self.Casing = false
				end]]
				-- if self.reloadPhase == 0 then
					-- self.horizontalAnim = self.horizontalAnim + TimerMan.DeltaTimeSecs * self.afterDelay
				-- end
			
				self.phasePrepareFinished = true;
			
				if self.afterSoundPlayed ~= true then
					if self.reloadPhase == 2 or self.reloadPhase == 4 then
						self.horizontalAnim = self.horizontalAnim + 1
						self.verticalAnim = self.verticalAnim - 1
					end
				
					self.afterSoundPlayed = true;
					if self.afterSound then
						self.afterSound:Play(self.Pos);
						if self.reloadPhase == 5 and self.extraRounds > 0 then
							self.extraLoadCloseAddSound:Play(self.Pos);
							if self.extraRounds == 5 then
								self.extraLoadCloseAddFinalSound:Play(self.Pos);
							end
						end
					end
				end
			
				if self.reloadPhase == 1 then
				
					self.Opened = true;
					
					if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2)) then
						self.Frame = 4;
					elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.5)) then
						self.Frame = 3;
					elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1)) then
						self.Frame = 2;
					elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*0.5)) then
						self.Frame = 1;
					end
					
				elseif self.reloadPhase == 2 then
				
					if self.parent:GetController():IsState(Controller.WEAPON_FIRE) then
						self.reloadCycle = false;
						PrimitiveMan:DrawTextPrimitive(screen, self.parent.AboveHUDPos + Vector(0, 30), "Interrupting...", true, 1);
					end
					
					self.Frame = 5;
				
					if self.ammoCountRaised ~= true then
						self.ammoCountRaised = true;
						if self.ammoCount < 6 then
							self.ammoCount = self.ammoCount + 1;
							if self.ammoCount == 6 then
								self.reloadCycle = false;
							end
						else
							self.reloadCycle = false;
						end
					end
					
					self.phaseOnStop = 2;
					
				elseif self.reloadPhase == 3 then
				
					self.Opened = false;
					
					if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2.0)) then
						self.Frame = 0;
					elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.5)) then
						self.Frame = 9;
					elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.0)) then
						self.Frame = 8;
					elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*0.5)) then
						self.Frame = 7;
					else
						self.Frame = 6;
					end
					
				elseif self.reloadPhase == 4 then
					
					self.phaseOnStop = 3;
				
					if self.parent:GetController():IsState(Controller.WEAPON_FIRE) then
						self.reloadCycle = false;
						PrimitiveMan:DrawTextPrimitive(screen, self.parent.AboveHUDPos + Vector(0, 30), "Interrupting...", true, 1);
					end

					if self.ammoCountRaised ~= true then
						self.ammoCountRaised = true;
						if self.ammoCount < 6 then
							self.ammoCount = self.ammoCount + 1;
							if self.ammoCount == 6 then
								self.reloadCycle = false;
							end
						else
							self.reloadCycle = false;
						end
					end

				elseif self.reloadPhase == 5 then
				
					self.Opened = false;
					
					if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*2)) then
						self.Frame = 0;
					elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1.5)) then
						self.Frame = 1;
					elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*1)) then
						self.Frame = 2;
					elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay/5)*0.5)) then
						self.Frame = 3;
					end

				end
				
				if self.reloadTimer:IsPastSimMS(self.reloadDelay + self.afterDelay) then
					self.reloadTimer:Reset();
					self.prepareSoundPlayed = false;
					self.afterSoundPlayed = false;
					
					
					if self.reloadPhase == 0 then
					
						if self.Opened then
							if self.breechShellReload then
								self.reloadPhase = 2
							else
								self.reloadPhase = 5;
							end
						elseif self.breechShellReload == false and self.ammoCount < 6 then
							self.reloadPhase = 4;
						else
							self.reloadPhase = self.reloadPhase + 1;
						end
						
					elseif self.reloadPhase == 1 then

						if not self:IsReloading() then
							self.reloadPhase = 5;
						elseif self.breechShellReload == true then
							self.reloadPhase = self.reloadPhase + 1;
						else
							self.reloadPhase = 5;
						end
						if self.Casing then
							local shell
							shell = CreateAEmitter("Shell Brutum", "Massive.rte");
							shell.Pos = self.Pos+Vector(1 * self.FlipFactor,-1):RadRotate(self.RotAngle);
							shell.Vel = self.Vel+Vector(-math.random(2,4)*self.FlipFactor,-math.random(3,4)):RadRotate(self.RotAngle);
							shell.RotAngle = self.RotAngle
							shell.HFlipped = self.HFlipped
							MovableMan:AddParticle(shell);
							
							self.Casing = false
						end
					
					elseif self.reloadPhase == 2 then
					
						self.ammoCountRaised = false;
					
						self.reloadPhase = self.reloadPhase + 1;
						
					elseif self.reloadPhase == 3 then
					
						if self.reloadCycle then
							self.reloadPhase = 4; -- same phase baby the ride never ends (except at 4 rounds)
						else
							self.BaseReloadTime = 0;
							self.reloadPhase = 0;
							self.Chamber = false;
							self.Reloading = false;
							self.phaseOnStop = nil;
						end
						
					elseif self.reloadPhase == 4 then
					
						self.ammoCountRaised = false;
					
						if self.reloadCycle then
							self.reloadPhase = 4; -- same phase baby the ride never ends (except at 4 rounds)
						else
							self.BaseReloadTime = 0;
							self.reloadPhase = 0;
							self.Chamber = false;
							self.Reloading = false;
							self.phaseOnStop = nil;
						end
					
					elseif self.reloadPhase == 5 then
					
						self.fasterPump = false;
					
						if self:IsReloading() then
							if self.ammoCount < 6 then
								self.reloadPhase = 4;
							else
								self.BaseReloadTime = 0;
								self.reloadPhase = 0;
								self.Chamber = false;
								self.Reloading = false;
								self.phaseOnStop = nil;
							end
						else
							self.BaseReloadTime = 0;
							self.reloadPhase = 0;
							self.Chamber = false;
							self.Reloading = false;
							self.phaseOnStop = nil;
						end
						
					else
						self.reloadPhase = self.reloadPhase + 1;
					end
				end				
			else
				self.phasePrepareFinished = false;
			end
			
		else
		
			local f = math.max(1 - math.min((self.FireTimer.ElapsedSimTimeMS - 25) / 200, 1), 0)
			self.JointOffset = self.originalJointOffset + Vector(1, 0) * f
			
			self.reloadTimer:Reset();
			self.prepareSoundPlayed = false;
			self.afterSoundPlayed = false;
			self.BaseReloadTime = 19999;
		end
		
		-- Fancy Extra Round Progress GUI
		if self.RoundInMagCount > 0 then
			for i = 1, 1 + self.extraRounds do
				local color = 26
				local spacing = 4
				local offset = Vector(0 - spacing * 0.5 + spacing * (i) - spacing * self.ammoCount / 2, (self.ammoCountRaised and i == self.ammoCount) and 35 or 36)
				local position = self.parent.AboveHUDPos + offset
				PrimitiveMan:DrawCirclePrimitive(position + Vector(0,-2), 1, color);
				PrimitiveMan:DrawLinePrimitive(position + Vector(1,-3), position + Vector(1,3), color);
				PrimitiveMan:DrawLinePrimitive(position + Vector(-1,-3), position + Vector(-1,3), color);
				PrimitiveMan:DrawLinePrimitive(position + Vector(1,3), position + Vector(-1,3), color);
			end
		end				
	
	else
		self.reloadTimer:Reset();
	end
	
	if self:DoneReloading() then
		self.breechShellReload = false;
		self.Magazine.RoundCount = self.ammoCount;
		self.fireDelayTimer:Reset()
		self.activated = false;
		self.delayedFire = false;
	end	
	
	local fire = self.shoveTimer:IsPastSimMS(self.shoveCooldown) and self:IsActivated() and self.RoundInMagCount > 0;

	if self.parent and self.delayedFirstShot == true then
		if self.RoundInMagCount > 0 then
			self:Deactivate()
		end
		
		--if self.parent:GetController():IsState(Controller.WEAPON_FIRE) and not self:IsReloading() then
		if fire and not self:IsReloading() then
			if not self.Magazine or self.Magazine.RoundCount < 1 then
				--self:Reload()
				self:Activate()
			elseif not self.activated and not self.delayedFire and self.fireDelayTimer:IsPastSimMS(1 / (self.RateOfFire / 60) * 1000) then
				self.activated = true
				
				self.preSound:Play(self.Pos);
				self.preSound = CreateSoundContainer("Pre Brutum", "Massive.rte");
				self.mechSound:Play(self.Pos);
				
				self.fireDelayTimer:Reset()
				
				self.delayedFire = true
				self.delayedFireTimer:Reset()
			end
		else
			if self.activated then
				self.activated = false
			end
		end
	elseif fire == false then
		self.delayedFirstShot = true;
	end
	
	self.SharpLength = self.originalSharpLength * math.sin((1 + math.pow(math.min(self.FireTimer.ElapsedSimTimeMS / 1500, 1), self.powNum) * 0.5) * math.pi) * -1
	
	local recoilFactor = math.pow(math.min(self.FireTimer.ElapsedSimTimeMS / (300 * 4), 1), 2.0)
	self.rotationTarget = self.rotationTarget + math.max(0, math.sin(recoilFactor * math.pi) * 13)
	
	if self.FiredFrame then
	
		self.horizontalAnim = self.horizontalAnim + 2
		
		self.angVel = self.angVel + RangeRand(0.7,1.1) * -10
	
		self.satisfyingVolume = math.min(1, self.satisfyingVolume + 0.33);
		
		self.GFXTimer:Reset();
		
		self.heatNum = self.heatNum + 20 * (self.extraRounds + 1);
		
		self.reloadTimer:Reset();
		self.reChamber = true;
		self.Casing = true;
		self.reloadPhase = 1;
		
		self.FireTimer:Reset();
		self.powNum = 0.6 + (0.3 * self.satisfyingVolume)
		
		if self.Magazine then
			self.ammoCount = 0 + self.Magazine.RoundCount; -- +0 to avoid reference bullshit and save it as a number properly
			if self.ammoCount == 0 then
				self.breechShellReload = true;
				self:Reload();
			end
		else
			self.ammoCount = 0;
			self.breechShellReload = true;
			self:Reload();
		end
		
		local shot = CreateMOPixel("Pellet Brutum Extra", "Massive.rte");
		shot.Pos = self.MuzzlePos;
		shot.Vel = self.Vel + Vector(150 * self.FlipFactor, 0):RadRotate(self.RotAngle);
		shot.Lifetime = shot.Lifetime * math.random(0.8, 1.2);
		shot.Team = self.Team;
		shot.IgnoresTeamHits = true;
		MovableMan:AddParticle(shot);
		
		for i = 1, self.extraRounds do
		
			-- Lasting tiny flames
			for i = 1, math.ceil(RangeRand(1, 2)) do
				local spreadFactor = RangeRand(-1, 1)
				local spread = math.rad(spreadFactor * 5)
				local velocity = 25 * 0.6 * RangeRand(0.2,1.1) * (2 - math.abs(spreadFactor))
				
				local positionOffset = Vector(math.random() * self.FlipFactor, RangeRand(-2, 2)) * 2
				
				local particle = CreateMOSParticle("Muzzle Twirl Smoke Massive", "Massive.rte")
				particle.Pos = self.MuzzlePos + positionOffset
				particle.Vel = self.Vel + Vector(velocity * self.FlipFactor,0):RadRotate(self.RotAngle + spread)
				particle.Team = self.Team
				particle.Lifetime = particle.Lifetime * RangeRand(0.5,3.2)
				particle.AirResistance = particle.AirResistance * 1 * RangeRand(0.9,1.1)
				particle.IgnoresTeamHits = true
				particle.AirThreshold = particle.AirThreshold * 0.5
				MovableMan:AddParticle(particle);
			end
			
			self.powNum = self.powNum + 0.3
			self.satisfyingVolume = 1;
			self.Magazine.RoundCount = self.Magazine.RoundCount - 1
			for i = 1, 12 do			
				local shot = CreateMOPixel("Pellet Brutum", "Massive.rte");
				shot.Pos = self.MuzzlePos;
				shot.Vel = self.Vel + Vector(150 * self.FlipFactor, 0):RadRotate(self.RotAngle);
				shot.Lifetime = shot.Lifetime * math.random(0.8, 1.2);
				shot.Team = self.Team;
				shot.IgnoresTeamHits = true;
				MovableMan:AddParticle(shot);			
			end			
		end
		
		if self.Magazine then
			self.ammoCount = 0 + self.Magazine.RoundCount; -- +0 to avoid reference bullshit and save it as a number properly
			if self.ammoCount == 0 then
				self.breechShellReload = true;
				self:Reload();
			end
		else
			self.ammoCount = 0;
			self.breechShellReload = true;
			self:Reload();
		end	
		
		-- Ground Smoke
		local maxi = 7 + (math.floor(4 * self.satisfyingVolume))
		for i = 1, maxi do
			
			local effect = CreateMOSRotating("Ground Smoke Particle Small Massive", "Massive.rte")
			effect.Pos = self.MuzzlePos + Vector(RangeRand(-1,1), RangeRand(-1,1)) * 3
			effect.Vel = self.Vel + Vector(math.random(90,150),0):RadRotate(math.pi * 2 / maxi * i + RangeRand(-2,2) / maxi)
			effect.Lifetime = effect.Lifetime * RangeRand(0.5,2.0)
			effect.AirResistance = effect.AirResistance * RangeRand(0.5,0.8)
			MovableMan:AddParticle(effect)
		end
		
		local xSpread = 0
		
		local smokeAmount = math.floor((20 + (math.floor(10 * self.satisfyingVolume))) * MassiveSettings.GunshotSmokeMultiplier);
		local particleSpread = 10 + (math.floor(7 * self.satisfyingVolume))
		
		local smokeLingering = math.sqrt(smokeAmount / 8) * (1 + self.satisfyingVolume * 2)
		local smokeVelocity = (1 + math.sqrt(smokeAmount / 8) ) * 0.5
		
		-- Muzzle main smoke
		for i = 1, math.ceil(smokeAmount / (math.random(2,4))) do
			local spread = math.pi * RangeRand(-1, 1) * 0.05
			local velocity = 110 * RangeRand(0.1, 0.9) * 0.4;
			
			local particle = CreateMOSParticle((math.random() * particleSpread) < 6.5 and "Tiny Smoke Ball 1" or "Small Smoke Ball 1");
			particle.Pos = self.MuzzlePos
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
			particle.Pos = self.MuzzlePos
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
			particle.Pos = self.MuzzlePos + xSpreadVec
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
			particle.Pos = self.MuzzlePos
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
			particle.Pos = self.MuzzlePos + xSpreadVec
			particle.Vel = self.Vel + Vector(velocity * self.FlipFactor,0):RadRotate(self.RotAngle + spread) * smokeVelocity
			particle.Team = self.Team
			particle.Lifetime = particle.Lifetime * RangeRand(0.9,1.2) * 0.75 * smokeLingering
			particle.AirResistance = particle.AirResistance * 2.5 * RangeRand(0.9,1.1)
			particle.IgnoresTeamHits = true
			particle.AirThreshold = particle.AirThreshold * 0.5
			MovableMan:AddParticle(particle);
		end
		--
		
		local shakenessParticle = CreateMOPixel("Shakeness Particle Glow Massive", "Massive.rte");
		shakenessParticle.Pos = self.MuzzlePos;
		shakenessParticle.Mass = 35 + (25 * self.satisfyingVolume);
		shakenessParticle.Lifetime = 500;
		MovableMan:AddParticle(shakenessParticle);

		local outdoorRays = 0;
		
		local indoorRays = 0;
		
		local bigIndoorRays = 0;

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
			elseif rayLength > 170 then
				bigIndoorRays = bigIndoorRays + 1;
			else
				indoorRays = indoorRays + 1;
			end
		end
		
		if outdoorRays >= self.rayThreshold then
			self.satisfyingReflectionOutdoorsSound.Volume = self.satisfyingVolume;
			self.satisfyingReflectionOutdoorsSound:Play(self.Pos);
			self.ExtraSatisfyingReflectionOutdoorsSound.Volume = math.min(1, self.extraRounds * 0.2)
			self.ExtraSatisfyingReflectionOutdoorsSound:Play(self.Pos);
			self.reflectionOutdoorsSound:Play(self.Pos);
		else
			self.debrisIndoorsSound.Volume = self.satisfyingVolume;
			self.debrisIndoorsSound:Play(self.Pos);
			self.reflectionIndoorsSound:Play(self.Pos);
		end
		
				
		if self.extraRounds > 0 then	
			self.satisfyingAddSound.Volume = math.min(1, self.extraRounds * 0.2)
			self.satisfyingAddSound:Play(self.Pos);
			self.extraRounds = 0;	
		end

	end
	
	if self.delayedFire then 
		if self.delayedFireTimer:IsPastSimMS(self.delayedFireTimeMS) then
			self:Activate()	
			self.delayedFire = false
			self.delayedFirstShot = false;
			self.delayedFireTimeMS = 50;
		elseif self.extraRounds > 0 then
			local particles = {"Tiny Smoke Ball 1"}
			
			if self.heatNum > 100 then
				table.insert(particles, "Small Smoke Ball 1")
			end
			for i = 1, math.random(1,3) do
				local particle = CreateMOSParticle(particles[math.random(1,#particles)]);
				particle.Lifetime = math.random(250, 600);
				particle.Vel = self.Vel + Vector(0, -0.1);
				particle.Pos = self.MuzzlePos;
				MovableMan:AddParticle(particle);
			end
			for i = 1, math.random(1,3) do
				local particle = CreateMOSParticle(particles[math.random(1,#particles)]);
				particle.Lifetime = math.random(250, 600);
				particle.Vel = self.Vel + Vector(0, -0.1);
				particle.Pos = self.Pos + Vector(2*self.FlipFactor, -1):RadRotate(self.RotAngle);
				MovableMan:AddParticle(particle);
			end
		end
	end
	
	if self.satisfyingVolume > 0 then
		self.satisfyingVolume = self.satisfyingVolume - 0.006 * TimerMan.DeltaTimeSecs;
		if self.satisfyingVolume < 0 then
			self.satisfyingVolume = 0;
		end
	end
	
	-- Animation
	if self.parent then
	
		if self.shoveStart then
			self.horizontalAnim = 8;
			self.rotationTarget = self.rotationTarget - 35;
			self.rotationSpeed = 9
			if self.shoveTimer:IsPastSimMS(self.shoveCooldown / 3) then
				self.shoveStart = false;
				self.parent:SetNumberValue("Gun Shove Massive", 1);
			end
		elseif self.shoving then
			self.horizontalAnim = -8;
			self.rotationTarget = self.rotationTarget + self.shoveRot;
			if self.shoveTimer:IsPastSimMS(self.shoveCooldown / 1.3) then
				self.shoving = false;
				self.rotationSpeed = 6
			end
			
			local rayVec = Vector(self.MuzzleOffset.X * self.FlipFactor + 10 * self.FlipFactor, 0):RadRotate(self.RotAngle);
			local rayOrigin = self.Pos + Vector(0, 0);
			
			--PrimitiveMan:DrawLinePrimitive(rayOrigin, rayOrigin + rayVec,  5);
			--PrimitiveMan:DrawCirclePrimitive(self.Pos, 3, 5);
			
			local moCheck = SceneMan:CastMORay(rayOrigin, rayVec, self.IDToIgnore or self.ID, self.Team, 0, false, 2); -- Raycast		
			
			if moCheck and moCheck ~= rte.NoMOID then
				local rayHitPos = SceneMan:GetLastRayHitPos()
				local rayHitPos = Vector(rayHitPos.X, rayHitPos.Y);
				local MO = MovableMan:GetMOFromID(moCheck)
				
				local dist = SceneMan:ShortestDistance(self.Pos, rayHitPos, SceneMan.SceneWrapsX)
							
				if IsMOSRotating(MO) then
					--print("HIT BEGIN")
					if self.shoveDamage == true then
						self.shoveDamage = false;
						MO = ToMOSRotating(MO)
						--print("HIT THE FOLLOWING")
						--print(MO)
						--print(MO.UniqueID)
						--print(MO:GetRootParent())
						--print(MO:GetRootParent().UniqueID)
						--print("TABLE NOW CONTAINS")
						local woundName = MO:GetEntryWoundPresetName()
						local woundNameExit = MO:GetExitWoundPresetName()
						local woundOffset = (rayHitPos - MO.Pos):RadRotate(MO.RotAngle * -1.0)
						
						local material = MO.Material.PresetName
						--if crit then
						--	woundName = woundNameExit
						--end
						
						if self.equippedByMassive then
							if IsAttachable(MO) and ToAttachable(MO):IsAttached() then
								if MO:IsDevice() and math.random(0, 100) >= 90 then
									ToAttachable(MO):RemoveFromParent(true, true);
								end
								
								if MO:IsInGroup("Shields") and math.random(0, 100) >= 95 then
									ToAttachable(MO):RemoveFromParent(true, true);
								end
							end
						end
						
						local damage = self.equippedByMassive and 2 or 1;
						
						local addWounds = true;
						
						local woundsToAdd = damage;
						
						-- Hurt the actor, add extra damage
						local actorHit = MovableMan:GetMOFromID(MO.RootID)
						if (actorHit and IsActor(actorHit)) then-- and (MO.RootID == moCheck or (not IsAttachable(MO) or string.find(MO.PresetName,"Arm") or string.find(MO,"Leg") or string.find(MO,"Head"))) then -- Apply addational damage			
						
							actorHit = ToActor(actorHit)
							
							if actorHit.BodyHitSound then
								actorHit.BodyHitSound:Play(actorHit.Pos)
							end
							
							if self.equippedByMassive then
								if math.random(0, 100) >= 75 then
									actorHit.Status = 1;
								end
								actorHit.Vel = actorHit.Vel + Vector(5, 0):RadRotate(self.RotAngle);
							end
							
							if (actorHit.Health - (damage * 10)) < 0 then -- bad estimation, but...
								if math.random(0, 100) < 15 then
									self.parent:SetNumberValue("Attack Killed", 1); -- celebration!!
								end
							elseif math.random(0, 100) < 30 then
								self.parent:SetNumberValue("Attack Success", 1); -- celebration!!
							end
							
							if IsActor(MO) then -- if we hit torso
								if MO.WoundCount + woundsToAdd >= MO.GibWoundLimit and math.random(0, 100) < 95 then
									addWounds = false;
									addSingleWound = true;
									ToActor(MO).Health = 0;
								end
							end
							
							if addWounds == true and woundName and woundName ~= "" then
								for i = 1, woundsToAdd do
									MO:AddWound(CreateAEmitter(woundName), woundOffset, true)
								end
							elseif addSingleWound == true and woundName and woundName ~= "" then
								MO:AddWound(CreateAEmitter(woundName), woundOffset, true)
							end

						elseif woundName and woundName ~= "" then -- generic wound adding for non-actors
							for i = 1, woundsToAdd do
								MO:AddWound(CreateAEmitter(woundName), woundOffset, true)
							end
						end
					end
				end	
			end
			
		end
	
		if not self:IsReloading() and self.shoveTimer:IsPastSimMS(self.shoveCooldown) and self.parent:IsPlayerControlled() and UInputMan:KeyPressed(MassiveSettings.GunShoveHotkey) then
			self.shoveRot = 50 * (math.random(80, 120) / 100);
			self.shoveTimer:Reset();
			self.parent:SetNumberValue("Gun Shove Start Massive", 1);
			self.shoving = true;
			self.shoveStart = true;
			self.shoveDamage = true;
			self.meleeSound:Play(self.Pos);		
		end
		
		if self.extraRounds + 1 < self.RoundInMagCount and
		not self:IsReloading() and not self.Chamber
		and self.shoveTimer:IsPastSimMS(self.shoveCooldown)
		and self.parent:IsPlayerControlled() and UInputMan:KeyPressed(MassiveSettings.WeaponAbilitySecondary) then
			self.reloadPhase = 1;
			self.reChamber = true;
			self.extraRounds = self.extraRounds + 1;
			self.fasterPump = true;
			
			self.extraLoadCloseAddSound.Pitch = 1.0 + ((self.extraRounds - 1) * 0.1)
			
			self.preSound = CreateSoundContainer("SatisfyingPre Brutum", "Massive.rte");
			self.delayedFireTimeMS = 50 + (50 * self.extraRounds);
			
		end
	
		self.horizontalAnim = math.floor(self.horizontalAnim / (1 + TimerMan.DeltaTimeSecs * 24.0) * 1000) / 1000
		self.verticalAnim = math.floor(self.verticalAnim / (1 + TimerMan.DeltaTimeSecs * 15.0) * 1000) / 1000
		
		local stance = Vector()
		stance = stance + Vector(-1,0) * self.horizontalAnim -- Horizontal animation
		stance = stance + Vector(0,5) * self.verticalAnim -- Vertical animation
		
		self.rotationTarget = self.rotationTarget - (self.angVel * 9)
		
		self.rotation = (self.rotation + self.rotationTarget * TimerMan.DeltaTimeSecs * self.rotationSpeed) / (1 + TimerMan.DeltaTimeSecs * self.rotationSpeed)
		local total = math.rad(self.rotation) * self.FlipFactor
		
		local supportOffset = Vector(0,0)
		if self.Frame == 1 or self.Frame == 9 then
			supportOffset = Vector(-1,0)
		elseif self.Frame == 2 or self.Frame == 8 then
			supportOffset = Vector(-2,0)
		elseif self.Frame == 3 or self.Frame == 7 then
			supportOffset = Vector(-3,0)
		elseif self.Frame == 4 or self.Frame == 6 then
			supportOffset = Vector(-4,0)
		end
		if self.parent:GetController():IsState(Controller.AIM_SHARP) == true and self.parent:GetController():IsState(Controller.MOVE_LEFT) == false and self.parent:GetController():IsState(Controller.MOVE_RIGHT) == false then
			supportOffset = supportOffset + Vector(-1,0)
		end
		
		self.SupportOffset = self.originalSupportOffset + supportOffset
		
		self.RotAngle = self.RotAngle + total;
		-- self.RotAngle = self.RotAngle + total;
		-- self:SetNumberValue("MagRotation", total);
		
		local jointOffset = Vector(self.JointOffset.X * self.FlipFactor, self.JointOffset.Y):RadRotate(self.RotAngle);
		local offsetTotal = Vector(jointOffset.X, jointOffset.Y):RadRotate(-total) - jointOffset
		self.Pos = self.Pos + offsetTotal;
		-- self:SetNumberValue("MagOffsetX", offsetTotal.X);
		-- self:SetNumberValue("MagOffsetY", offsetTotal.Y);
		
		if self.reloadingVector then
			self.StanceOffset = self.reloadingVector + stance
			self.SharpStanceOffset = self.reloadingVector + stance
		else
			self.StanceOffset = Vector(self.originalStanceOffset.X, self.originalStanceOffset.Y) + stance
			self.SharpStanceOffset = Vector(self.originalSharpStanceOffset.X, self.originalSharpStanceOffset.Y) + stance
		end
		
	end
	
	if self.GFXTimer:IsPastSimMS(self.GFXDelay) then
		if self.heatNum > 2 then
			local particles = {"Tiny Smoke Ball 1"}
			
			if self.heatNum > 100 then
				table.insert(particles, "Small Smoke Ball 1")
			end
			
			for i = 1, math.random(1,3) do
				local particle = CreateMOSParticle(particles[math.random(1,#particles)]);
				particle.Lifetime = math.random(250, 600);
				particle.Vel = self.Vel + Vector(0, -0.1);
				particle.Pos = self.MuzzlePos;
				MovableMan:AddParticle(particle);
			end
				
		end
		
		self.GFXTimer:Reset()
		self.GFXDelay = math.max(50, math.random(35, 100) - self.heatNum) 
	end
	
	self.heatNum = math.max(self.heatNum - 0.05, 0)
	
end

function OnDetach(self)

	self.heatNum = 0;

	self.shoveStart = false;
	self.shoving = false;
	
	self.rotationSpeed = 6

	self.delayedFirstShot = true;
	self:DisableScript("Massive.rte/Devices/Weapons/Handheld/Brutum/Brutum.lua");

end