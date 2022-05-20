------ Thanks to Zeta for that amazing hovercraft Bike. thanks to Just Alex for the modified former  -------
------ Modified script of the turret --------

function Create(self)
	
	if IsACrab(self:GetRootParent()) then
		self.parent = ToACrab(self:GetRootParent());
		self.IsPlayer = ActivityMan:GetActivity():IsHumanTeam(self.parent.Team)
	else
		self.parent = nil
	end
	
	if IsAttachable(self:GetParent()) then
		self.motorParent = ToAttachable(self:GetParent())
	else
		self.motorParent = nil
	end
	
	self.crewSize = 1	--How many people can operate this gun.
	
	self.gunner = nil;
	self.originalPerceptiveness = self.Perceptiveness
	self.perceptivenessValue = 0.95 --Value in which the gunners/reloaders/whateva percetivness is multiplied before aplying it in total to the turret

	self.optimizationTimer = Timer();
	self.optimizationDelay = 10
	
	self.delayedFire = false
	self.delayedFireTimer = Timer();
	self.delayedFireTimeMS = 50
	self.delayedFireEnabled = true
	
	self.fireDelayTimer = Timer()
	
	self.activated = false
	
	-- Sounds --
	
	self.afterSound = CreateSoundContainer("Pre Arbalest", "Massive.rte");
	-- meaningless! just here to save an if check
	
	self.preSound = CreateSoundContainer("Pre Weltzerstorer", "Massive.rte");	
	self.pullBackSound = CreateSoundContainer("PullBack Weltzerstorer", "Massive.rte");	
	self.lockPrepareSound = CreateSoundContainer("LockPrepare Weltzerstorer", "Massive.rte");	
	self.lockSound = CreateSoundContainer("Lock Weltzerstorer", "Massive.rte");
	self.dropInPrepareSound = CreateSoundContainer("DropInPrepare Weltzerstorer", "Massive.rte");	
	self.dropInSound = CreateSoundContainer("DropIn Weltzerstorer", "Massive.rte");
	
	self.delayedFireTimeMS = 440;
	
	self.reloadTimer = Timer();

	self.pullBackPrepareDelay = 1000;
	self.pullBackAfterDelay = 5360;
	self.lockPrepareDelay = 315;
	self.lockAfterDelay = 1350;
	self.dropInPrepareDelay = 240;
	self.dropInAfterDelay = 500;
	
	-- phases:
	-- 0 attach
	-- 1 pullBack
	-- 2 Lock
	-- 3 detach
	-- 4 boltLoad
	
	self.reloadPhase = 0;
	
	self.Frame = 0;
	self.Locked = true;
	self.Loaded = true;
	
	self.ReloadTime = 15000;

end

function Update(self)

	if UInputMan:KeyPressed(38) then
		self:ReloadScripts();
	end

	if self:IsAttached() == true then
		if self.motorParent and self.motorParent:IsAttached() == true then

			if math.abs(self.parent.RotAngle) > 0.8 and math.abs(self.parent.AngularVel) > 0 and math.abs(self.parent.AngularVel) < 7 then
				if self.parent.RotAngle < -0.6 then
					self.parent.AngularVel = self.parent.AngularVel + 1;
				elseif self.parent.RotAngle > 0.6 then
					self.parent.AngularVel = self.parent.AngularVel - 1;
				end
			end

			------------------------------- Gunner Man ------------------------------------
		
			if (self.gunner == nil or not MovableMan:IsActor(self.gunner)) then		--Get first guy: Gunner
				
				self.reloadTimer:Reset();
				self.afterSoundPlayed = false;
				self.prepareSoundPlayed = false;
				
				if self.Loaded == true then
					--self.Frame = 4;
				elseif self.Locked == true then
					--self.Frame = 3;
				else
					--self.Frame = 0;
					self.afterSound:Stop(-1) -- seconds long sound... oughta stop it lol
				end
				
				if self.phaseOnStop then
					self.reloadPhase = self.phaseOnStop;
					self.phaseOnStop = nil;
				end
				
				self.ReloadTime = 15000;
			
				self:Deactivate();										--Deactivate a bunch of stuff
				self.parent:SetAimAngle((-0.3 + self.parent.RotAngle))
				self.Perceptiveness = self.originalPerceptiveness
				self.ReloadTime = 999999
				
				if self.parent:GetController().InputMode ~= Controller.CIM_DISABLED then
					self.parent:SetControllerMode(Controller.CIM_DISABLED , self.parent:GetController().Player);
					self.parent.AIMode = Actor.AIMODE_NONE;
				end

				if self.parent:IsPlayerControlled() then
					local ctrl = self.parent:GetController();
					local screen = ActivityMan:GetActivity():ScreenOfPlayer(ctrl.Player);	
					
					PrimitiveMan:DrawTextPrimitive(screen, self.parent.AboveHUDPos + Vector(-14, -25), "UNMANNED", true, 0);
					PrimitiveMan:DrawTextPrimitive(screen, self.parent.AboveHUDPos + Vector(-25, -15), "REQUIRES: GUNNER", true, 0);	
				end

				if self.optimizationTimer:IsPastSimMS(self.optimizationDelay) then
					self.optimizationTimer:Reset();
					for actor in MovableMan.Actors do 
						if actor.Team == self.Team and SceneMan:ShortestDistance(actor.Pos, self.Pos, SceneMan.SceneWrapsX).Magnitude < 30 and actor.Vel.Magnitude < 10 and actor.Status == 0 then
							if IsAHuman(actor) then
								if not (math.abs(self.parent.AngularVel) > 7 or math.abs(self.parent.RotAngle) > 0.8 or not MovableMan:IsActor(self.parent) or self.parent.Health <= 0) then
									if (actor:IsPlayerControlled() and UInputMan:KeyPressed(6)) or (not actor:IsPlayerControlled() and actor.AIMode == Actor.AIMODE_SENTRY) then	--F to mount
										self.gunner = ToAHuman(actor);		
										if self.gunner.FGArm and (not self.gunner.EquippedItem  or (self.gunner.EquippedItem and self.gunner.EquippedItem.PresetName ~= "Gunner Holder")) then
											self.gunner:AddInventoryItem(CreateHDFirearm("Gunner Holder","Massive.rte"));
											self.gunner:EquipNamedDevice("Gunner Holder", true)
											self.gunner.AIMode = Actor.AIMODE_NONE
											self.gunner.HUDVisible = false
											self.gunner:SetNumberValue("Massive Disable Movement", 1);
											self.parent.AIMode = 1				
											self.parent:SetControllerMode(2 , self.parent:GetController().Player)
										else
											self.gunner = nil
										end
									end
								end
							end
						end
					end
				end
			elseif self.gunner then			--We have gunner
			
				-- PAWNIS RELOAD ANIMATION HERE
				if self:IsReloading() then

					if self.reloadPhase == 0 then
						self.reloadDelay = self.pullBackPrepareDelay;
						self.afterDelay = self.pullBackAfterDelay;			
						self.prepareSound = nil;
						self.afterSound = self.pullBackSound;
						
					elseif self.reloadPhase == 1 then
					
						self.reloadDelay = self.lockPrepareDelay;
						self.afterDelay = self.lockAfterDelay;			
						self.prepareSound = self.lockPrepareSound;
						self.afterSound = self.lockSound;
						
					elseif self.reloadPhase == 2 then
					
						self.reloadDelay = self.dropInPrepareDelay;
						self.afterDelay = self.dropInAfterDelay;			
						self.prepareSound = self.dropInPrepareSound;
						self.afterSound = self.dropInSound;
						
					end
					
					self.afterSound.Pos = self.Pos;
					
					if self.prepareSoundPlayed ~= true then
						self.prepareSoundPlayed = true;
						if self.prepareSound then
							self.prepareSound:Play(self.Pos);
						end
					end
				
					if self.reloadTimer:IsPastSimMS(self.reloadDelay) then
					
						-- if self.reloadPhase == 0 then
							-- local minTime = self.reloadDelay
							-- local maxTime = self.reloadDelay + ((self.afterDelay/5)*4.7)
							
							-- local factor = math.pow(math.min(math.max(self.reloadTimer.ElapsedSimTimeMS - minTime, 0) / (maxTime - minTime), 1), 2)
							
							-- self.Frame = math.floor(factor * (3) + 0.5)
						-- end
						
						if self.reloadPhase == 0 then
							

						end
						
						if self.afterSoundPlayed ~= true then
						
							if self.reloadPhase == 0 then
								self.phaseOnStop = 0;
	
								
							elseif self.reloadPhase == 1 then
								self.phaseOnStop = 1;
								self.Locked = true;
								
							elseif self.reloadPhase == 2 then
								self.phaseOnStop = 2;								
								self.Loaded = true;
							
							else
								self.phaseOnStop = nil;
							end
						
							self.afterSoundPlayed = true;
							if self.afterSound then
								self.afterSound:Play(self.Pos);
							end
						end
						if self.reloadTimer:IsPastSimMS(self.reloadDelay + self.afterDelay) then
							self.reloadTimer:Reset();
							self.afterSoundPlayed = false;
							self.prepareSoundPlayed = false;
							
							if self.reloadPhase == 2 then
								self.ReloadTime = 0;
								self.reloadPhase = 0;
								self.phaseOnStop = nil;
								
							else
								self.reloadPhase = self.reloadPhase + 1;
							end
						end
					end		
				else
					
					self.reloadTimer:Reset();
					self.afterSoundPlayed = false;
					self.prepareSoundPlayed = false;
					
					if self.Loaded == true then
						--self.Frame = 4;
					elseif self.Locked == true then
						--self.Frame = 3;
					else
						--self.Frame = 0;
						self.afterSound:Stop(-1) -- seconds long sound... oughta stop it lol
					end
					
					if self.phaseOnStop then
						self.reloadPhase = self.phaseOnStop;
						self.phaseOnStop = nil;
					end
					
					self.ReloadTime = 15000;
					
				end
				
				if self.delayedFire == true then
					self.Locked = false;
					self.Loaded = false;
					-- local minTime = 0
					-- local maxTime = 200
					
					-- local factor = math.pow(math.min(math.max(self.delayedFireTimer.ElapsedSimTimeMS - minTime, 0) / (maxTime - minTime), 1), 2)
					
					-- self.Frame = math.floor((1 - factor) * (4) + 0.5)
				end
				
				if self.FiredFrame then
					self.Frame = 0;
				end
					
				if self:DoneReloading() or self:IsReloading() then
					self.fireDelayTimer:Reset()
				end

				local fire = self:IsActivated()
				self:Deactivate()
				
				--if self.parent:GetController():IsState(Controller.WEAPON_FIRE) and not self:IsReloading() then
				if fire and not self:IsReloading() then
					if not self.Magazine or self.Magazine.RoundCount < 1 then
						--self:Reload()
						self:Activate()
					elseif not self.activated and not self.delayedFire then
						self.activated = true
						
						if self.preSound then
							self.preSound:Play(self.Pos);
						end
						
						self.fireDelayTimer:Reset()
						
						self.delayedFire = true
						self.delayedFireTimer:Reset()
					end
				else
					if self.activated then
						self.activated = false
					end
				end
				
				if self.delayedFire and self.delayedFireTimer:IsPastSimMS(self.delayedFireTimeMS) then
					self:Activate()
					self.delayedFire = false
				end

				if self.gunner.EquippedItem then
					self.gunner.EquippedItem.Sharpness = 2
				end

				if self.IsPlayer and self.gunner:IsPlayerControlled() then
					local switcher = ActivityMan:GetActivity()
					switcher:SwitchToActor(self.parent, self.gunner:GetController().Player, self.Team)
				end		

				if self.gunner:GetController().InputMode ~= Controller.CIM_DISABLED then
					self.gunner:SetControllerMode(Controller.CIM_DISABLED , self.gunner:GetController().Player);
					self.gunner.AIMode = Actor.AIMODE_NONE;
				end
		
				self.Perceptiveness = self.gunner.Perceptiveness*self.perceptivenessValue
				
				--Set gunner pos and vel so it moves with the turret
				
				self.gunner.Vel = self.motorParent.Vel/1.5;
				self.gunner.Pos = self.Pos + Vector(-21*self.FlipFactor,8):RadRotate(self.RotAngle/1.5)					
				self.gunner.HFlipped = self.HFlipped;				
				self.gunner:SetAimAngle(self.parent:GetAimAngle(false))

				if self.gunner.Status ~= 0 then	
					self.gunner:RemoveNumberValue("Massive Disable Movement");
					self.gunner = nil;
				end	
				
				-- Remove gunner if turret moves a lot or is very rotated
				
				if self.gunner and (math.abs(self.parent.AngularVel) > 7 or math.abs(self.parent.RotAngle) > 0.8 or not MovableMan:IsActor(self.parent) or self.parent.Health <= 0 
				or (self.parent:IsPlayerControlled() and UInputMan:KeyPressed(7)) or self.gunner.FGArm == nil) then
					
					if self.gunner.EquippedItem then					
						self.gunner.EquippedItem.ToDelete = true
					end
					self.gunner.AIMode = 1
					self.gunner:SetControllerMode(2 , self.gunner:GetController().Player)	
					self.gunner.HUDVisible = true

					if self.IsPlayer and self.parent:IsPlayerControlled() then
						local switcher = ActivityMan:GetActivity()
						switcher:SwitchToActor(self.gunner, self.parent:GetController().Player, self.Team)
					end

					self.gunner:RemoveNumberValue("Massive Disable Movement");
					self.gunner = nil
				end	
			
			end				

			--------------- HUD Part, should make this more user friednly in create but oh well --------------------------

			local ctrl = self.parent:GetController();
			local screen = ActivityMan:GetActivity():ScreenOfPlayer(ctrl.Player);	
			
			local gunnerFrame = (math.abs(self.parent.AngularVel) > 7 or math.abs(self.parent.RotAngle) > 0.8) and 5 or self.gunner and (self.parent.Team + 1) or 0
			local gunnerIcon = CreateMOSRotating("Gunner HUD Icon", "Massive.rte");
			local gunnerIconPos = self.crewSize > 1 and self.parent.Pos + Vector(-6, -32) or self.parent.Pos + Vector(0, -32)
				
			PrimitiveMan:DrawBitmapPrimitive(screen, gunnerIconPos, gunnerIcon, 3.14, gunnerFrame, true, true);

		else
			self.motorParent = nil
			if self.gunner then
				if self.gunner.Status ~= 0 then				
					self.gunner:RemoveNumberValue("Massive Disable Movement");
					self.gunner = nil;	
				else					
					self.gunner.AIMode = 1
					self.gunner:SetControllerMode(2 , self.gunner:GetController().Player)	
					self.gunner.HUDVisible = true
					
					if self.IsPlayer and self.parent and self.parent:IsPlayerControlled() then
						local switcher = ActivityMan:GetActivity()
						switcher:SwitchToActor(self.gunner, self.parent:GetController().Player, self.Team)
					end
					
					self.gunner:RemoveNumberValue("Massive Disable Movement");
					self.gunner = nil;
				end	
			end	
			
			self.parent = nil
		end
	else
		self.parent = nil
		if self.gunner then
			if self.gunner.Status ~= 0 then						
				self.gunner.AIMode = 1
				self.gunner:SetControllerMode(2 , self.gunner:GetController().Player)
				self.gunner.HUDVisible = true
			end				

			self.gunner:RemoveNumberValue("Massive Disable Movement");
			self.gunner = nil;
		end
	end
end

function Destroy(self)

	if self.gunner then
		self.gunner.AIMode = 1
		self.gunner:SetControllerMode(2 , self.gunner:GetController().Player)
		self.gunner.HUDVisible = true
	
		if self.IsPlayer and self.parent and self.parent:IsPlayerControlled() then
			local switcher = ActivityMan:GetActivity()
			switcher:SwitchToActor(self.gunner, self.parent:GetController().Player, self.Team)
		end
		
		self.gunner:RemoveNumberValue("Massive Disable Movement");
		self.gunner = nil
	end
end