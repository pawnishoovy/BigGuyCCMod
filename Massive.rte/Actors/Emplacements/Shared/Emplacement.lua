------ Thanks to Zeta for that amazing hovercraft Bike. 
------ and thanks to you alex for turning it into an anti tank gun i could steal, turn into a Weltzerstorer, then back into an anti tank gun

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

	if self.Magazine then
		self.Magazine.RoundCount = self:NumberValueExists("Ammo Count") and self:GetNumberValue("Ammo Count") or 1	--This is really only useful when gun has more than 1 bullet
	end
	
	self.setAmmo = true

	self.crewSize = 3	--How many people can operate this gun.
	
	self.gunner = nil;
	self.originalPerceptiveness = self.Perceptiveness
	self.perceptivenessValue = 0.95 --Value in which the gunners/reloaders/whateva percetivness is multiplied before aplying it in total to the turret
	
	self.reloader = nil;
	self.originalReloadTime = self.ReloadTime
	self.reloadTimeReducer = 1.5
	
	self.spotter = nil
	self.originalSharpLength = self.SharpLength
	self.sharpLengthIncreaser = 2

	self.optimizationTimer = Timer();
	self.optimizationDelay = 10

end

function Update(self)

	if self:IsAttached() == true then
		if self.motorParent and self.motorParent:IsAttached() == true then

			if self:IsReloading() then
				self.setAmmo = false
			elseif self.Magazine then
				if self.setAmmo == false then
					self.Magazine.RoundCount = self:NumberValueExists("Ammo Count") and self:GetNumberValue("Ammo Count") or 1
					self.setAmmo = true
				end
			end

			if math.abs(self.parent.RotAngle) > 0.8 and math.abs(self.parent.AngularVel) > 0 and math.abs(self.parent.AngularVel) < 7 then
				if self.parent.RotAngle < -0.6 then
					self.parent.AngularVel = self.parent.AngularVel + 1;
				elseif self.parent.RotAngle > 0.6 then
					self.parent.AngularVel = self.parent.AngularVel - 1;
				end
			end

			------------------------------- Gunner Man ------------------------------------
		
			if (self.gunner == nil or not MovableMan:IsActor(self.gunner)) then		--Get first guy: Gunner
			
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
				
				if self.reloader then
					self.gunner = ToAHuman(self.reloader);
					self.reloader = nil
					self.gunner:AddInventoryItem(CreateHDFirearm("Gunner Holder","UnitedMilitia.rte"));
					self.gunner:EquipNamedDevice("Gunner Holder", true)
					self.gunner:RemoveInventoryItem("Reloader Holder")
				
				elseif self.spotter then
					self.gunner = ToAHuman(self.spotter);
					self.spotter = nil
					self.gunner:AddInventoryItem(CreateHDFirearm("Gunner Holder","UnitedMilitia.rte"));
					self.gunner:EquipNamedDevice("Gunner Holder", true)
					self.gunner:RemoveInventoryItem("Spotter Holder")

				elseif self.optimizationTimer:IsPastSimMS(self.optimizationDelay) then
					self.optimizationTimer:Reset();
					if not (math.abs(self.parent.AngularVel) > 7 or math.abs(self.parent.RotAngle) > 0.8 or not MovableMan:IsActor(self.parent) or self.parent.Health <= 0) then
						for actor in MovableMan.Actors do 
							if actor.Team == self.Team and SceneMan:ShortestDistance(actor.Pos, self.Pos, SceneMan.SceneWrapsX).Magnitude < 45 and actor.Vel.Magnitude < 10 and actor.Status == 0 then
								if IsAHuman(actor) then
									if (actor:IsPlayerControlled() and UInputMan:KeyPressed(6)) or (not actor:IsPlayerControlled() and actor.AIMode == Actor.AIMODE_SENTRY) then	--F to mount
										self.gunner = ToAHuman(actor);		
										if self.gunner.FGArm and (not self.gunner.EquippedItem  or (self.gunner.EquippedItem and self.gunner.EquippedItem.PresetName ~= "Gunner Holder")) then
											self.gunner:AddInventoryItem(CreateHDFirearm("Gunner Holder","UnitedMilitia.rte"));
											self.gunner:EquipNamedDevice("Gunner Holder", true)
											self.gunner.AIMode = Actor.AIMODE_NONE
											self.gunner.HUDVisible = false
											self.parent.AIMode = 1
											self.ReloadTime = self.originalReloadTime	
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
				self.gunner.Pos = self.Pos + Vector((-31*self.FlipFactor)+(math.abs(self.RotAngle))*self.FlipFactor,10):RadRotate(self.RotAngle/1.75)					
				self.gunner.HFlipped = self.HFlipped;					
				self.gunner:SetAimAngle(self.parent:GetAimAngle(false))

				if self.gunner.Status ~= 0 then						
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

					self.gunner = nil
				end	

				------------------------- Reloader Man -----------------------------------

				if self.crewSize > 1 then
					if (self.reloader == nil or not MovableMan:IsActor(self.reloader)) then		--Get second guy: Reloader
					
						self.ReloadTime = self.originalReloadTime

						if self.spotter then
							self.reloader = ToAHuman(self.spotter);
							self.spotter = nil
							self.reloader:AddInventoryItem(CreateHDFirearm("Reloader Holder","UnitedMilitia.rte"));
							self.reloader:EquipNamedDevice("Reloader Holder", true)
							self.reloader:RemoveInventoryItem("Spotter Holder")

						elseif self.optimizationTimer:IsPastSimMS(self.optimizationDelay) then
							self.optimizationTimer:Reset();
							if not (math.abs(self.parent.AngularVel) > 7 or math.abs(self.parent.RotAngle) > 0.8 or not MovableMan:IsActor(self.parent) or self.parent.Health <= 0) then
								for actor in MovableMan.Actors do 
									if actor.Team == self.Team and SceneMan:ShortestDistance(actor.Pos, self.Pos, SceneMan.SceneWrapsX).Magnitude < 30 and actor.Vel.Magnitude < 10 and actor.Status == 0 then
										if IsAHuman(actor) then
											if (actor:IsPlayerControlled() and UInputMan:KeyPressed(6)) or (not actor:IsPlayerControlled() and actor.AIMode == Actor.AIMODE_SENTRY) then	--F to mount
												self.reloader = ToAHuman(actor);
												if self.reloader.FGArm and (not self.reloader.EquippedItem  or (self.reloader.EquippedItem and self.reloader.EquippedItem.PresetName ~= "Gunner Holder")) then
													self.reloader:AddInventoryItem(CreateHDFirearm("Reloader Holder","UnitedMilitia.rte"));
													self.reloader:EquipNamedDevice("Reloader Holder", true)
													self.reloader.AIMode = Actor.AIMODE_NONE
													self.reloader.HUDVisible = false
												else
													self.reloader = nil							
												end
											end
										end
									end
								end
							end
						end
					elseif self.reloader then

						if self.reloader.EquippedItem then
							self.reloader.EquippedItem.Sharpness = 2
						end

						if self.IsPlayer and self.reloader:IsPlayerControlled() then
							local switcher = ActivityMan:GetActivity()
							switcher:SwitchToActor(self.parent, self.reloader:GetController().Player, self.Team)
						end

						if self.reloader:GetController().InputMode ~= Controller.CIM_DISABLED then
							self.reloader:SetControllerMode(Controller.CIM_DISABLED , self.reloader:GetController().Player);
							self.reloader.AIMode = Actor.AIMODE_NONE;
						end

						self.ReloadTime = self.originalReloadTime/self.reloadTimeReducer
						
						--Set reloader pos and vel so it moves with the turret
						
						self.reloader.Vel = self.motorParent.Vel/1.5;
						self.reloader.Pos = self.parent.Pos + Vector(-18*self.FlipFactor,2):RadRotate(self.parent.RotAngle/1.5)								
						self.reloader.HFlipped = self.HFlipped;						
						self.reloader:SetAimAngle(self.parent.RotAngle)

						if self.reloader.Status ~= 0 then						
							self.reloader = nil;
						end	
						
						-- Remove reloader if turret moves a lot or is very rotated
						
						if self.reloader and (math.abs(self.parent.AngularVel) > 7 or math.abs(self.parent.RotAngle) > 0.8 or not MovableMan:IsActor(self.parent) or self.parent.Health <= 0 
						or (self.parent:IsPlayerControlled() and UInputMan:KeyPressed(8)) or  self.reloader.FGArm == nil) then
							
							if self.reloader.EquippedItem then							
								self.reloader.EquippedItem.ToDelete = true
							end
							self.reloader.AIMode = 1
							self.reloader:SetControllerMode(2 , self.reloader:GetController().Player)	
							self.reloader.HUDVisible = true

							if self.IsPlayer and self.parent:IsPlayerControlled() then
								local switcher = ActivityMan:GetActivity()
								switcher:SwitchToActor(self.reloader, self.parent:GetController().Player, self.Team)
							end

							self.reloader = nil
						end

						if self.crewSize > 2 then
							if (self.spotter == nil or not MovableMan:IsActor(self.spotter)) then		--Get third guy: Spotter
							
								self.SharpLength = self.originalSharpLength

								if self.optimizationTimer:IsPastSimMS(self.optimizationDelay) then
									self.optimizationTimer:Reset();
									if not (math.abs(self.parent.AngularVel) > 7 or math.abs(self.parent.RotAngle) > 0.8 or not MovableMan:IsActor(self.parent) or self.parent.Health <= 0) then
										for actor in MovableMan.Actors do 
											if actor.Team == self.Team and SceneMan:ShortestDistance(actor.Pos, self.Pos, SceneMan.SceneWrapsX).Magnitude < 30 and actor.Vel.Magnitude < 10 and actor.Status == 0 then
												if IsAHuman(actor) then
													if (actor:IsPlayerControlled() and UInputMan:KeyPressed(6)) or (not actor:IsPlayerControlled() and actor.AIMode == Actor.AIMODE_SENTRY) then	--F to mount
														self.spotter = ToAHuman(actor);	
														if self.spotter.FGArm and (not self.spotter.EquippedItem  or (self.spotter.EquippedItem and self.spotter.EquippedItem.PresetName ~= "Gunner Holder")) then
															self.spotter:AddInventoryItem(CreateHDFirearm("Spotter Holder","UnitedMilitia.rte"));
															self.spotter:EquipNamedDevice("Spotter Holder", true)
															self.spotter.AIMode = Actor.AIMODE_NONE
															self.spotter.HUDVisible = false	
														else
															self.spotter = nil
														end
													end
												end
											end
										end
									end
								end
							elseif self.spotter then

								if self.spotter.EquippedItem then
									self.spotter.EquippedItem.Sharpness = 2
								end

								if self.IsPlayer and self.spotter:IsPlayerControlled() then
									local switcher = ActivityMan:GetActivity()
									switcher:SwitchToActor(self.parent, self.spotter:GetController().Player, self.Team)
								end

								if self.spotter:GetController().InputMode ~= Controller.CIM_DISABLED then
									self.spotter:SetControllerMode(Controller.CIM_DISABLED , self.spotter:GetController().Player);
									self.spotter.AIMode = Actor.AIMODE_NONE;
								end

								self.SharpLength = self.originalSharpLength*self.sharpLengthIncreaser
								
								--Set spotter pos and vel so it moves with the turret
								
								self.spotter.Vel = self.motorParent.Vel/1.5;
								self.spotter.Pos = self.parent.Pos + Vector(12*self.FlipFactor,-12):RadRotate(self.parent.RotAngle/1.5)									
								self.spotter.HFlipped = self.HFlipped;									
								self.spotter:SetAimAngle(self.parent:GetAimAngle(false))

								if self.spotter.Status ~= 0 then						
									self.spotter = nil;
								end	
								
								-- Remove spotter if turret moves a lot or is very rotated
								
								if self.spotter and (math.abs(self.parent.AngularVel) > 7 or math.abs(self.parent.RotAngle) > 0.8 or not MovableMan:IsActor(self.parent) or self.parent.Health <= 0 
								or (self.parent:IsPlayerControlled() and UInputMan:KeyPressed(10)) or self.spotter.FGArm == nil) then
									
									if self.spotter.EquippedItem then									
										self.spotter.EquippedItem.ToDelete = true
									end
									self.spotter.AIMode = 1
									self.spotter:SetControllerMode(2 , self.spotter:GetController().Player)	
									self.spotter.HUDVisible = true

									if self.IsPlayer and self.parent:IsPlayerControlled() then
										local switcher = ActivityMan:GetActivity()
										switcher:SwitchToActor(self.spotter, self.parent:GetController().Player, self.Team)
									end

									self.spotter = nil
								end
							end
						end
					end
				end
			end				

			--------------- HUD Part, should make this more user friednly in create but oh well --------------------------

			local ctrl = self.parent:GetController();
			local screen = ActivityMan:GetActivity():ScreenOfPlayer(ctrl.Player);	
			
			local gunnerFrame = (math.abs(self.parent.AngularVel) > 7 or math.abs(self.parent.RotAngle) > 0.8) and 5 or self.gunner and (self.parent.Team + 1) or 0
			local gunnerIcon = CreateMOSRotating("Gunner HUD Icon", "UnitedMilitia.rte");
			local gunnerIconPos = self.crewSize > 2 and self.parent.Pos + Vector(-12, -38) or self.crewSize > 1 and self.parent.Pos + Vector(-6, -38) or self.parent.Pos + Vector(0, -38)
				
			PrimitiveMan:DrawBitmapPrimitive(screen, gunnerIconPos, gunnerIcon, 3.14, gunnerFrame, true, true);
			
			if self.crewSize > 1 then
				local reloaderFrame = (math.abs(self.parent.AngularVel) > 7 or math.abs(self.parent.RotAngle) > 0.8) and 5 or self.reloader and (self.parent.Team + 1) or 0
				local reloaderIcon = CreateMOSRotating("Reloader HUD Icon", "UnitedMilitia.rte");
				local reloaderIconPos = self.crewSize > 2 and self.parent.Pos + Vector(0, -38) or self.parent.Pos + Vector(6, -38)
				
				PrimitiveMan:DrawBitmapPrimitive(screen, reloaderIconPos, reloaderIcon, 3.14, reloaderFrame, true, true);
			end

			if self.crewSize > 2 then
				local spotterFrame = (math.abs(self.parent.AngularVel) > 7 or math.abs(self.parent.RotAngle) > 0.8) and 5 or self.spotter and (self.parent.Team + 1) or 0
				local spotterIcon = CreateMOSRotating("Spotter HUD Icon", "UnitedMilitia.rte");
				local spotterIconPos = self.parent.Pos + Vector(12, -38)
				
				PrimitiveMan:DrawBitmapPrimitive(screen, spotterIconPos, spotterIcon, 3.14, spotterFrame, true, true);
			end

		else
			self.motorParent = nil
			if self.gunner then
				if self.gunner.Status ~= 0 then						
					self.gunner = nil;	
				else					
					self.gunner.AIMode = 1
					self.gunner:SetControllerMode(2 , self.gunner:GetController().Player)	
					self.gunner.HUDVisible = true
					
					if self.IsPlayer and self.parent and self.parent:IsPlayerControlled() then
						local switcher = ActivityMan:GetActivity()
						switcher:SwitchToActor(self.gunner, self.parent:GetController().Player, self.Team)
					end
					
					self.gunner = nil;
				end	
			end
			
			if self.reloader then
				if self.reloader.Status ~= 0 then						
					self.reloader = nil;	
				else					
					self.reloader.AIMode = 1
					self.reloader:SetControllerMode(2 , self.reloader:GetController().Player)	
					self.reloader.HUDVisible = true
					
					self.reloader = nil;
				end	
			end	
			
			if self.spotter then
				if self.spotter.Status ~= 0 then						
					self.spotter = nil;	
				else					
					self.spotter.AIMode = 1
					self.spotter:SetControllerMode(2 , self.spotter:GetController().Player)	
					self.spotter.HUDVisible = true
					
					self.spotter = nil;
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
			self.gunner = nil;
		end

		if self.reloader then
			if self.reloader.Status ~= 0 then						
				self.reloader.AIMode = 1
				self.reloader:SetControllerMode(2 , self.reloader:GetController().Player)	
				self.reloader.HUDVisible = true
			end					
			self.reloader = nil;
		end

		if self.spotter then
			if self.spotter.Status ~= 0 then						
				self.spotter.AIMode = 1
				self.spotter:SetControllerMode(2 , self.spotter:GetController().Player)	
				self.spotter.HUDVisible = true
			end					
			self.spotter = nil;
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
		
		self.gunner = nil
	end
	
	if self.reloader then
		self.reloader.AIMode = 1
		self.reloader:SetControllerMode(2 , self.reloader:GetController().Player)
		self.reloader.HUDVisible = true		
		self.reloader = nil
	end
	
	if self.spotter then
		self.spotter.AIMode = 1
		self.spotter:SetControllerMode(2 , self.spotter:GetController().Player)
		self.spotter.HUDVisible = true		
		self.spotter = nil
	end
end