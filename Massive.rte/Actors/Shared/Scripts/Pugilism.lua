
function Create(self)
	--self.pugilism = {}
	self.pugilismArmFG = {
		targetOffset = Vector(0, 0),
		position = Vector(self.Pos.X ,self.Pos.Y),
		strengths = {0.5, 2.0, 5.0, 2.5},
		strengthBase = 70.0,
		velocity = Vector(0, 0),
		originalParentOffset = Vector(self.FGArm.ParentOffset.X, self.FGArm.ParentOffset.Y),
		originalFlailScalar = self.FGArmFlailScalar,
		originalMoveSpeed = self.FGArm.MoveSpeed
	}
	self.pugilismArmBG = {
		targetOffset = Vector(0, 0),
		position = Vector(self.Pos.X ,self.Pos.Y),
		strengths = {0.5, 2.0, 5.0, 2.5},
		strengthBase = 70.0,
		velocity = Vector(0, 0),
		originalParentOffset = Vector(self.BGArm.ParentOffset.X, self.BGArm.ParentOffset.Y),
		originalFlailScalar = self.BGArmFlailScalar,
		originalMoveSpeed = self.BGArm.MoveSpeed
	}
	
	self.pugilismArms = {self.pugilismArmFG, self.pugilismArmBG}
	self.pugilismArmActivePrevious = self.pugilismArmBG
	self.pugilismArmActive = self.pugilismArmFG
	self.pugilismArmIndex = 1
	self.pugilismStates = {Idle = 1, Blocking = 2, Punch = 3, Showe = 4}
	self.pugilismState = self.pugilismStates.Idle
	
	self.pugilismAttackDuration = 100
	self.pugilismAttackTimer = Timer()
	self.pugilismAttackCooldown = 20
	self.pugilismAttackCooldownTimer = Timer()
	self.pugilismAttackGrunt = true
	self.pugilismAttackDamage = true
	
	self.originalArmSwing = self.ArmSwingRate
	
end

function Update(self)
	local handsEmpty = not self.EquippedItem and not self.EquippedBGItem
	
	if handsEmpty then
		self.ArmSwingRate = 0;
		self.FGArmFlailScalar = 0;
		self.BGArmFlailScalar = 0;
		self:SetNumberValue("Pugilism", 1)
		
		local armFG = self.FGArm
		local armBG = self.BGArm
		local arms = {armFG, armBG}
		
		local doSway = false;
		local armPairs = {{self.FGArm, self.FGLeg, self.BGLeg}, {self.BGArm, self.BGLeg, self.FGLeg}};
		
		local ctrl = (self.controller and self.controller or self:GetController())
		
		local blocking = (self:IsPlayerControlled() and UInputMan:KeyHeld(MassiveSettings.MeleeBlockHotkey)) or self:NumberValueExists("AI Block")
		local attacking = (ctrl and ctrl:IsState(Controller.WEAPON_FIRE) or false)
		
		self:RemoveNumberValue("AI Block");
		
		if self.pugilismState == self.pugilismStates.Idle then
			local idleAnimFG = Vector(-1 + -math.sin(((self.Age % 3000) / 500))*math.pi/7, math.sin(((self.Age % 3000) / 500))*math.pi/3)
			local idleAnimBG = Vector(5, -1 + -math.sin(((self.Age % 3000) / 500))*math.pi/5)
			
			self:RemoveNumberValue("Pugilism Blocking")
			self:RemoveNumberValue("Pugilism Attacking")
			
			if attacking and self.kicking ~= true  then
				if self.pugilismAttackCooldownTimer:IsPastSimMS(self.pugilismAttackCooldown) then
					self.pugilismState = self.pugilismStates.Punch
					self.pugilismAttackTimer:Reset()
					self.pugilismSwingSound:Play(self.Pos);
					
					local new = self.pugilismArmActivePrevious
					self.pugilismArmActivePrevious = self.pugilismArmActive
					self.pugilismArmActive = new
					self.pugilismArmIndex = (self.pugilismArmIndex) % 2 + 1
					
					self.Vel = self.Vel + Vector(-3 * self.FlipFactor, -1) * 0.3
					
					self.pugilismAttackGrunt = true
					self.pugilismAttackDamage = true
				end
			end
			
			self.pugilismArmFG.targetOffset = Vector(7, -4) + Vector(idleAnimFG.X, idleAnimFG.Y * 1.0)
			self.pugilismArmBG.targetOffset = Vector(7, -4) + Vector(idleAnimBG.X, idleAnimBG.Y * 1.0)
			
			if armFG then
				armFG.ParentOffset = armFG.ParentOffset + ((self.pugilismArmFG.originalParentOffset) - armFG.ParentOffset) * TimerMan.DeltaTimeSecs * 8
			end
			if armBG then
				armBG.ParentOffset = armBG.ParentOffset + ((self.pugilismArmBG.originalParentOffset) - armBG.ParentOffset) * TimerMan.DeltaTimeSecs * 8
			end
			
			if blocking then
				self.pugilismState = self.pugilismStates.Blocking
				self:SetNumberValue("Pugilism Blocking", 1)
			end
		elseif self.pugilismState == self.pugilismStates.Blocking then
			local blockAnim = Vector(10, -10)--:RadRotate(self:GetAimAngle(false))
			self.pugilismArmFG.targetOffset = blockAnim
			self.pugilismArmBG.targetOffset = blockAnim
			
			self:SetNumberValue("Pugilism Blocking", 1)
			self:RemoveNumberValue("Pugilism Attacking")
			
			if armFG then
				armFG.ParentOffset = armFG.ParentOffset + ((self.pugilismArmFG.originalParentOffset + Vector(0, 1)) - armFG.ParentOffset) * TimerMan.DeltaTimeSecs * 5.5
			end
			if armBG then
				armBG.ParentOffset = armBG.ParentOffset + ((self.pugilismArmBG.originalParentOffset + Vector(0, 1)) - armBG.ParentOffset) * TimerMan.DeltaTimeSecs * 5.5
			end
			
			if not blocking then
				self.pugilismState = self.pugilismStates.Idle
			end
		elseif self.pugilismState == self.pugilismStates.Punch then
			local factor = self.pugilismAttackTimer.ElapsedSimTimeMS / self.pugilismAttackDuration
			factor = math.max(math.min(factor, 1), 0.01)
			factor = math.pow(factor, 4)
			
			self:RemoveNumberValue("Pugilism Blocking")
			self:SetNumberValue("Pugilism Attacking", 1)
			
			local arm = arms[self.pugilismArmIndex]
			if arm then
				if self.pugilismAttackGrunt and factor > 0.2 then
					self.pugilismAttackCooldown = 400;
					self:SetNumberValue("Pugilism Attack", 1)
					self.pugilismAttackGrunt = false
					
					self.Vel = self.Vel + Vector(2/(1 + self.Vel.Magnitude), 0):RadRotate(self:GetAimAngle(true)) * math.abs(math.cos(self:GetAimAngle(true)));
				end
				
				local attackAnim = Vector(45, 0):RadRotate(self:GetAimAngle(false)) * factor + (Vector(-10, 0) * factor*2);
				self.pugilismArmActive.targetOffset = Vector(0, -0) + attackAnim
				arm.ParentOffset = arm.ParentOffset + ((self.pugilismArmActive.originalParentOffset + Vector(8 * math.sin((1 - factor) * math.pi), 1)) - arm.ParentOffset) * TimerMan.DeltaTimeSecs * 14.0
				
				if self.pugilismAttackDamage and (factor < 0.7 or (self.pugilismArmActive.velocity).Magnitude > 3) then
					local handPos = arm.HandPos + Vector(4, 0):RadRotate(self:GetAimAngle(true)) * factor
					local rayOrigin = arm.HandPos
					local rayVec = Vector(self.pugilismArmActive == self.pugilismArmFG and 20 or 15, 0):RadRotate(self:GetAimAngle(true)) * math.max(0.5, factor);
					local moCheck = SceneMan:CastMORay(rayOrigin, rayVec, self.ID, self.Team, 0, false, 2); -- Raycast
					local hitPos = SceneMan:GetLastRayHitPos();
					
					--PrimitiveMan:DrawLinePrimitive(rayOrigin, rayOrigin + rayVec, 5);
					
					if moCheck and moCheck ~= rte.NoMOID and MovableMan:GetMOFromID(moCheck).Team ~= self.Team then
						local mo = ToMOSRotating(MovableMan:GetMOFromID(moCheck))
						if mo then
							if IsArm(mo) and ToAHuman(mo:GetRootParent()):NumberValueExists("Pugilism Blocking") then
								self.pugilismAttackDamage = false
								self.tackleImpactGenericSound:Play(handPos);
							else
								self.pugilismAttackDamage = false
								
								local woundName = mo:GetEntryWoundPresetName()
								local woundNameExit = mo:GetExitWoundPresetName()
								local woundOffset = SceneMan:ShortestDistance(mo.Pos, hitPos, SceneMan.SceneWrapsX)
								
								local material = mo.Material.PresetName
								
								local damage = 3
								
								local addWounds = true;
								
								local woundsToAdd;
								local speedMult = math.max(1, self.Vel.Magnitude / 18);
								
								woundsToAdd = math.floor((damage*speedMult))
								
								if not IsHeldDevice(mo) then
									local parent = mo:GetRootParent()
									if parent and IsActor(parent) then
					
										--self.kickImpactSound:Play(self.Pos);
										
										--print(self.Mass/parent.Mass)
										
										local shakenessParticle = CreateMOPixel("Shakeness Particle Massive", "Massive.rte");
										shakenessParticle.Pos = self.Pos;
										shakenessParticle.Mass = 10;
										shakenessParticle.Lifetime = 100;
										MovableMan:AddParticle(shakenessParticle);
										
										local velToSet = parent.Vel + (self.Vel/10)
										+ SceneMan:ShortestDistance(self.Pos, parent.Pos, SceneMan.SceneWrapsX):RadRotate(self:GetAimAngle(true)/2):SetMagnitude(math.max(0, 3*((self.Mass/2)/parent.Mass)))
										
										velToSet.Y = 0;
										
										parent.Vel = velToSet;
										
										--print((self.Vel/10)
										--+ SceneMan:ShortestDistance(self.Pos, parent.Pos, SceneMan.SceneWrapsX):RadRotate(self:GetAimAngle(true)/2):SetMagnitude(math.max(0, 4*((self.Mass)/parent.Mass))))
									
										parent = ToActor(parent)
										
										if IsAHuman(parent) then
											if ToAHuman(parent).Head and mo.UniqueID == ToAHuman(parent).Head.UniqueID then
												parent.Status = 1;
												parent.AngularVel = parent.AngularVel + (self.HFlipped and 5 or -5);
											end
										end
										
										if self.Mass/parent.Mass > 1.2 and math.random(0, 100) > 70 then
											parent.Status = 1;
											parent.Vel = parent.Vel + (self.Vel/10)
										+ SceneMan:ShortestDistance(self.Pos, parent.Pos, SceneMan.SceneWrapsX):SetMagnitude(math.max(0, 1*((self.Mass/2)/parent.Mass))) + Vector(0, -1);
										end
										
										if parent.BodyHitSound then
											parent.BodyHitSound:Play(parent.Pos)
										end

										--parent.Vel = parent.Vel + Vector(1.5, 0):RadRotate(self:GetAimAngle(true))
										
										mo:SetNumberValue("Mordhau Flinched", 1);
										--local flincher = CreateAttachable("Mordhau Flincher", "Massive.rte")
										--mo:AddAttachable(flincher)
									end
								elseif mo:IsInGroup("Weapons - Mordhau Melee") then
									self.pugilismAttackCooldown = 200;
									mo:SetStringValue("Blocked Type", "Slash");
									addWounds = false;
								end
								
								if addWounds == true and woundName ~= "" and woundName ~= nil then -- generic wound adding for non-actors
									for i = 1, woundsToAdd do
										mo:AddWound(CreateAEmitter(woundName), woundOffset, true)
									end
								end
								
								if string.find(material,"Metal") or string.find(woundName,"Metal") or string.find(woundNameExit,"Metal") or string.find(material,"Stuff") or string.find(woundName,"Dent") or string.find(woundNameExit,"Dent") then
									-- if self.attackAnimationsGFX[self.currentAttackAnimation].hitMetalGFX then
										-- local effect = CreateMOSRotating(self.attackAnimationsGFX[self.currentAttackAnimation].hitMetalGFX);
										-- if effect then
											-- effect.Pos = rayHitPos - rayVec:SetMagnitude(3)
											-- MovableMan:AddParticle(effect);
											-- effect:GibThis();
										-- end
									-- end
									self.pugilismHitMetalSound:Play(handPos);
								else
									self.pugilismHitFleshSound:Play(handPos);
								end
								
							end
						end
						
						
					end
					
					if checkPixTerrain and checkPixTerrain ~= 0 then
						
						self.pugilismAttackDamage = false
					end
				end
				
			end
			
			if self.pugilismAttackTimer:IsPastSimMS(self.pugilismAttackDuration) then
				self.pugilismState = self.pugilismStates.Idle
				self.pugilismAttackCooldownTimer:Reset()
			end
			
		elseif self.pugilismState == self.pugilismStates.Showe then
			self:RemoveNumberValue("Pugilism Blocking")
			self:SetNumberValue("Pugilism Attacking", 1)
		end
		
		for i, arm in ipairs(arms) do
			if arm then
			
				arm.MoveSpeed = 0.7;
				
				local data = self.pugilismArms[i]
				
				local pos = Vector(data.position.X, data.position.Y)
				local vel = Vector(data.velocity.X, data.velocity.Y)
				
				local posTarget = self.Pos + Vector(data.targetOffset.X * self.FlipFactor, data.targetOffset.Y):RadRotate(self.RotAngle)
				local dif = SceneMan:ShortestDistance(pos, posTarget, SceneMan.SceneWrapsX)
				
				
				
				vel = vel + Vector(dif.X, dif.Y).Normalized * math.min(math.max((dif.Magnitude * 0.15), 0), 4) * TimerMan.DeltaTimeSecs
				* data.strengthBase * (data.strengths[self.pugilismState] * math.max(1, self.Vel.Magnitude / 10))
				
				vel = vel + self.Vel * TimerMan.DeltaTimeSecs * 2
				vel = vel + Vector(-self.AngularVel, 0):RadRotate(self.RotAngle) * TimerMan.DeltaTimeSecs * 3
				
				local friction = (3 - math.min(math.max((dif.Magnitude), 1), 2)) * 7.0
				vel = Vector(vel.X , vel.Y) / (1 + TimerMan.DeltaTimeSecs * friction)
			
				
				pos = pos + vel * rte.PxTravelledPerFrame
				pos = pos + SceneMan:ShortestDistance(pos, posTarget, SceneMan.SceneWrapsX) * TimerMan.DeltaTimeSecs * 0.3
				
				data.position = Vector(pos.X, pos.Y)
				data.velocity = Vector(vel.X, vel.Y)
				
				--PrimitiveMan:DrawCirclePrimitive(data.position, 1, 5);
				--PrimitiveMan:DrawLinePrimitive(data.position, posTarget, 5);
				local offset = SceneMan:ShortestDistance(self.Pos + Vector(arm.ParentOffset.X * self.FlipFactor, arm.ParentOffset.Y):RadRotate(self.RotAngle), pos + vel * rte.PxTravelledPerFrame * 0.25, SceneMan.SceneWrapsX):RadRotate(-self.RotAngle)
			
				arm.HandIdleOffset = Vector(offset.X * self.FlipFactor, offset.Y)
			end
		end
		
		
	else
		self:RemoveNumberValue("Pugilism")
		
		self.ArmSwingRate = self.originalArmSwingRate
		
		if self.BGArm then self.BGArm.MoveSpeed = self.pugilismArmBG.originalMoveSpeed
						   self.BGArmFlailScalar = self.pugilismArmBG.originalFlailScalar
						   end
		if self.FGArm then self.FGArm.MoveSpeed = self.pugilismArmFG.originalMoveSpeed
						   self.FGArmFlailScalar = self.pugilismArmFG.originalFlailScalar
						   end
		
	end
end