ZedmassiveAIBehaviours = {};

-- function ZedmassiveAIBehaviours.createSoundEffect(self, effectName, variations)
	-- if effectName ~= nil then
		-- self.soundEffect = AudioMan:PlaySound(effectName .. math.random(1, variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 400, false);	
	-- end
-- end

-- no longer needed as of pre3!

function ZedmassiveAIBehaviours.createEmotion(self, emotion, priority, duration, canOverridePriority)
	if canOverridePriority == nil then
		canOverridePriority = false;
	end
	local usingPriority
	if canOverridePriority == false then
		usingPriority = priority - 1;
	else
		usingPriority = priority;
	end
	if emotion then
		
		self.emotionApplied = false; -- applied later in handleheadframes
		self.Emotion = emotion;
		if duration then
			self.emotionTimer:Reset();
			self.emotionDuration = duration;
		else
			self.emotionDuration = 0; -- will follow voiceSound length
		end
		self.lastEmotionPriority = priority;
	end
end

function ZedmassiveAIBehaviours.createVoiceSoundEffect(self, soundContainer, priority, emotion, canOverridePriority)
	if canOverridePriority == nil then
		canOverridePriority = false;
	end
	local usingPriority
	if canOverridePriority == false then
		usingPriority = priority - 1;
	else
		usingPriority = priority;
	end
	if self.Head and soundContainer ~= nil then
		if self.voiceSound then
			if self.voiceSound:IsBeingPlayed() then
				if self.lastPriority <= usingPriority then
					if emotion then
						ZedmassiveAIBehaviours.createEmotion(self, emotion, priority, 0, canOverridePriority);
					end
					self.voiceSound:Stop();
					self.voiceSound = soundContainer;
					soundContainer:Play(self.Pos)
					self.lastPriority = priority;
					return true;
				end
			else
				if emotion then
					ZedmassiveAIBehaviours.createEmotion(self, emotion, priority, 0, canOverridePriority);
				end
				self.voiceSound = soundContainer;
				soundContainer:Play(self.Pos)
				self.lastPriority = priority;
				return true;
			end
		else
			if emotion then
				ZedmassiveAIBehaviours.createEmotion(self, emotion, priority, 0, canOverridePriority);
			end
			self.voiceSound = soundContainer;
			soundContainer:Play(self.Pos)
			self.lastPriority = priority;
			return true;
		end
	end
end

function ZedmassiveAIBehaviours.handleMovement(self)

	if self.EquippedItem and IsHDFirearm(self.EquippedItem) and self.EquippedItem.Mass < 35 then
		local gun = ToHDFirearm(self.EquippedItem)
		if not gun:NumberValueExists("MassiveOneHand") then
			local attachment = CreateAttachable("One Hand Attachment Massive", "Massive.rte");
			gun:AddAttachable(attachment);
			gun:SetNumberValue("MassiveOneHand", 1);
		end
	end

	if self:NumberValueExists("Mordhau Disable Movement") then
		return;
	end
	
	local crouching = self.controller:IsState(Controller.BODY_CROUCH)
	local moving = self.controller:IsState(Controller.MOVE_LEFT) or self.controller:IsState(Controller.MOVE_RIGHT);
	
	-- Leg Collision Detection system
    --local i = 0
	if self:IsPlayerControlled() then -- AI doesn't update its own foot checking when playercontrolled so we have to do it
		if self.Vel.Y > 10 then
			self.wasInAir = true;
		else
			self.wasInAir = false;
		end
		for i = 1, 2 do
			--local foot = self.feet[i]
			local foot = nil
			--local leg = self.legs[i]
			if i == 1 then
				foot = self.FGFoot 
			else
				foot = self.BGFoot 
			end

			--if foot ~= nil and leg ~= nil and leg.ID ~= rte.NoMOID then
			if foot ~= nil then
				local footPos = foot.Pos				
				local mat = nil
				local pixelPos = footPos + Vector(0, 4)
				self.footPixel = SceneMan:GetTerrMatter(pixelPos.X, pixelPos.Y)
				--PrimitiveMan:DrawLinePrimitive(pixelPos, pixelPos, 13)
				if self.footPixel ~= 0 then
					mat = SceneMan:GetMaterialFromID(self.footPixel)
				--	PrimitiveMan:DrawLinePrimitive(pixelPos, pixelPos, 162);
				--else
				--	PrimitiveMan:DrawLinePrimitive(pixelPos, pixelPos, 13);
				end
				
				local movement = (self.controller:IsState(Controller.MOVE_LEFT) == true or self.controller:IsState(Controller.MOVE_RIGHT) == true or self.Vel.Magnitude > 3)
				if mat ~= nil then
					--PrimitiveMan:DrawTextPrimitive(footPos, mat.PresetName, true, 0);
					if self.feetContact[i] == false then
						self.feetContact[i] = true
						if self.feetTimers[i]:IsPastSimMS(self.footstepTime) and movement then																	
							self.feetTimers[i]:Reset()
						end
					end
				else
					if self.feetContact[i] == true then
						self.feetContact[i] = false
						if self.feetTimers[i]:IsPastSimMS(self.footstepTime) and movement then
							self.feetTimers[i]:Reset()
						end
					end
				end
			end
		end
	else
		if self.AI.flying == true and self.wasInAir == false then
			self.wasInAir = true;
		elseif self.AI.flying == false and self.wasInAir == true then
			self.wasInAir = false;
			self.isJumping = false
			if self.moveSoundTimer:IsPastSimMS(500) then
			
				self.movementSounds.Land:Play(self.Pos);
				self.movementSounds.BassLayer:Play(self.Pos);
				
				-- Ground Smoke
				local maxi = 7
				for i = 1, maxi do	
					local effect = CreateMOSRotating("Ground Smoke Particle Small Massive", "Massive.rte")
					effect.Pos = self.Pos;
					effect.Vel = self.Vel + Vector(math.random(-50, 50),math.random(90,150))
					effect.Lifetime = effect.Lifetime * RangeRand(0.5,2.0)
					effect.AirResistance = effect.AirResistance * RangeRand(0.5,0.8)
					MovableMan:AddParticle(effect)
				end
				
				local shakenessParticle = CreateMOPixel("Shakeness Particle Massive", "Massive.rte");
				shakenessParticle.Pos = self.Pos;
				shakenessParticle.Mass = 25;
				shakenessParticle.Lifetime = 500;
				MovableMan:AddParticle(shakenessParticle);
				
				self.moveSoundTimer:Reset();
				
			end
		end
	end
	
	
	
	-- Custom Jump
	if self.controller:IsState(Controller.BODY_JUMPSTART) == true and self.controller:IsState(Controller.BODY_CROUCH) == false and self.jumpTimer:IsPastSimMS(self.jumpDelay) and not self.isJumping then
		if (self:IsPlayerControlled() and self.feetContact[1] == true or self.feetContact[2] == true) or self.wasInAir == false then
			local jumpVec = Vector(0, self.noSprint and self.jumpStrength * 0.01 or self.jumpStrength)
			local jumpWalkX = 3
			if moving then
				if self.controller:IsState(Controller.MOVE_LEFT) == true then
					jumpVec.X = -jumpWalkX
				elseif self.controller:IsState(Controller.MOVE_RIGHT) == true then
					jumpVec.X = jumpWalkX
				end
			end
			if self.controller:IsState(Controller.WEAPON_FIRE) then
				ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Grunt, 4, 5);
				jumpVec = Vector(0, self.noSprint and self.jumpStrength * 0.01 or self.jumpStrength * 1.3)
				if self.isSprinting then
					-- dive lmao
					self.AngularVel = self.AngularVel + (-1 * self.FlipFactor)
					self.Status = 1;
					jumpVec = Vector(0, self.noSprint and self.jumpStrength * 0.01 or self.jumpStrength * 2)
					jumpVec.X = 10 * self.FlipFactor
				end
			end
			self.movementSounds.Jump:Play(self.Pos);
			self.movementSounds.FoleySprint:Play(self.Pos);
			self.movementSounds.SprintStepLeft:Play(self.Pos);
			self.jumpBoostTimer:Reset();

			local pos = Vector(0, 0);
			SceneMan:CastObstacleRay(self.Pos, Vector(0, 45), pos, Vector(0, 0), self.ID, self.Team, 0, 10);				
			local terrPixel = SceneMan:GetTerrMatter(pos.X, pos.Y)
			
			if math.abs(self.Vel.X) > jumpWalkX * 2.0 then
				self.Vel = Vector(self.Vel.X, self.Vel.Y + jumpVec.Y)
			else
				self.Vel = Vector(self.Vel.X + jumpVec.X, self.Vel.Y + jumpVec.Y)
			end
			self.isJumping = true
			self.jumpTimer:Reset()
			self.jumpStop:Reset()
		end
	elseif self.isJumping or self.wasInAir then
		if self.isJumping and self.Status < 1 then
			if self.controller:IsState(Controller.BODY_JUMP) == true and not self.jumpBoostTimer:IsPastSimMS(200) then
				self.Vel = self.Vel - SceneMan.GlobalAcc * TimerMan.DeltaTimeSecs * 2.8 -- Stop the gravity
			end
			if self.controller:IsState(Controller.MOVE_LEFT) == true and not self.jumpBoostTimer:IsPastSimMS(1000) and self.Vel.X > -5 then
				self.Vel = self.Vel + Vector(-8, 0) * TimerMan.DeltaTimeSecs * 1.0
			elseif self.controller:IsState(Controller.MOVE_RIGHT) == true and not self.jumpBoostTimer:IsPastSimMS(1000) and self.Vel.X < 5 then
				self.Vel = self.Vel + Vector(8, 0) * TimerMan.DeltaTimeSecs * 1.0
			end
		end
		if (self:IsPlayerControlled() and self.feetContact[1] == true or self.feetContact[2] == true) and self.jumpStop:IsPastSimMS(100) then
			self.isJumping = false
			self.wasInAir = false;
			if self.Vel.Y > 0 and self.moveSoundTimer:IsPastSimMS(500) then
				self.movementSounds.Land:Play(self.Pos);
				
				-- Ground Smoke
				local maxi = 7
				for i = 1, maxi do	
					local effect = CreateMOSRotating("Ground Smoke Particle Small Massive", "Massive.rte")
					effect.Pos = self.Pos;
					effect.Vel = self.Vel + Vector(math.random(-50, 50),math.random(90,150))
					effect.Lifetime = effect.Lifetime * RangeRand(0.5,2.0)
					effect.AirResistance = effect.AirResistance * RangeRand(0.5,0.8)
					MovableMan:AddParticle(effect)
				end
				
				local shakenessParticle = CreateMOPixel("Shakeness Particle Massive", "Massive.rte");
				shakenessParticle.Pos = self.Pos;
				shakenessParticle.Mass = 25;
				shakenessParticle.Lifetime = 500;
				MovableMan:AddParticle(shakenessParticle);
				
				self.movementSounds.BassLayer:Play(self.Pos);
				self.moveSoundTimer:Reset();
				
				local pos = Vector(0, 0);
				SceneMan:CastObstacleRay(self.Pos, Vector(0, 45), pos, Vector(0, 0), self.ID, self.Team, 0, 10);				
				local terrPixel = SceneMan:GetTerrMatter(pos.X, pos.Y)					
				
			end
		end
	end
	
	-- Sprint
	local input = not self.isJumping
	and not crouching
	and ((self.controller:IsState(Controller.MOVE_LEFT) == true or self.controller:IsState(Controller.MOVE_RIGHT) == true)
	and not (self.controller:IsState(Controller.MOVE_LEFT) == true and self.controller:IsState(Controller.MOVE_RIGHT) == true))
	and not (self.controller:IsState(Controller.MOVE_LEFT) == true and self.HFlipped == false or self.controller:IsState(Controller.MOVE_RIGHT) == true and self.HFlipped == true)
	and not self.Dying
	
	if input then
		
		if self.moveMultiplier < self.sprintMultiplier then
			self.moveMultiplier = self.moveMultiplier + TimerMan.DeltaTimeSecs * self.accelerationFactor;
			if self.moveMultiplier > self.sprintMultiplier then
				self.isSprinting = true;
				self.moveMultiplier = self.sprintMultiplier;
			end
		end
		
		if self.isSprinting then
			ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Breathing, 1);
		end
		
		self:SetLimbPathSpeed(0, self.limbPathDefaultSpeed0 * self.moveMultiplier);
		self:SetLimbPathSpeed(1, self.limbPathDefaultSpeed1 * self.moveMultiplier);
		self:SetLimbPathSpeed(2, self.limbPathDefaultSpeed2 * self.moveMultiplier);
		self.LimbPathPushForce = self.limbPathDefaultPushForce * self.sprintPushForceDenominator
	elseif self.Dying ~= true then
		self.isSprinting = false;
		self.moveMultiplier = self.walkMultiplier;
		self:SetLimbPathSpeed(0, self.limbPathDefaultSpeed0 * self.moveMultiplier);
		self:SetLimbPathSpeed(1, self.limbPathDefaultSpeed1 * self.moveMultiplier);
		self:SetLimbPathSpeed(2, self.limbPathDefaultSpeed2 * self.moveMultiplier);
		self.LimbPathPushForce = self.limbPathDefaultPushForce * self.moveMultiplier
	end

	if (crouching) then
		if (not self.wasCrouching and self.moveSoundTimer:IsPastSimMS(600)) then
			if (moving) then
				if self.isSprinting then
					self.movementSounds.SprintProne:Play(self.Pos);
				else
					self.movementSounds.Prone:Play(self.Pos);
				end

			else
				self.movementSounds.Crouch:Play(self.Pos);
			end
		end
		if (moving) then
			if self.terrainCollided == true and self.proneTerrainSoundPlayed ~= true then
				self.proneTerrainSoundPlayed = true;
				
				self.movementSounds.BassLayer:Play(self.Pos);
				
			end
				
			if (self.moveSoundWalkTimer:IsPastSimMS(400)) then
				self.oldStepFoley:FadeOut(50);
				local sound = self.movementSounds.FoleyWalk;
				sound:Play(self.Pos);
				self.oldStepFoley = sound;
				self.moveSoundWalkTimer:Reset();
				
				local pos = Vector(0, 0);
				SceneMan:CastObstacleRay(self.Pos, Vector(0, 20), pos, Vector(0, 0), self.ID, self.Team, 0, 5);				
				local terrPixel = SceneMan:GetTerrMatter(pos.X, pos.Y)
				
			end
		end
	else
		if (self.wasCrouching and self.moveSoundTimer:IsPastSimMS(600)) then
			self.movementSounds.Stand:Play(self.Pos);
			self.moveSoundTimer:Reset();
		end
		self.proneTerrainSoundPlayed = false;
	end
	
	if not (moving) then
		self.foot = 0
	end

	self.wasCrouching = crouching;
	self.wasMoving = moving;
end

function ZedmassiveAIBehaviours.handleHealth(self)
	if UInputMan:KeyPressed(26) then
		self.Health = -1;
	end

	local healthTimerReady = self.healthUpdateTimer:IsPastSimMS(750);
	local wasLightlyInjured = self.Health < (self.oldHealth - 5);
	local wasInjured = self.Health < (self.oldHealth - 25);
	local wasHeavilyInjured = self.Health < (self.oldHealth - 50);

	if self.Health < (self.oldHealth - 75) then -- reduce extreme damage
		self.Health = self.Health + ((self.oldHealth - self.Health) / 2);
	end

	if (healthTimerReady or wasLightlyInjured or wasInjured or wasHeavilyInjured) then
	
		if self:NumberValueExists("Death By Fire") then
			self:RemoveNumberValue("Death By Fire");
			ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Pain, 9, 5);
		end
	
		self.oldHealth = self.Health;
		self.healthUpdateTimer:Reset();
		
		if not (self.FGArm) and (self.FGArmLost ~= true) then
			self.Suppression = self.Suppression + 100;
			self.FGArmLost = true;
			if self.Health < 50 then
				ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Pain, 5, 5);
			else
				ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.LashOut, 4, 5);
			end
		end
		if not (self.BGArm) and (self.BGArmLost ~= true) then
			self.Suppression = self.Suppression + 100;
			self.BGArmLost = true;
			if self.Health < 50 then
				ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Pain, 5, 5);
			else
				ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.LashOut, 4, 5);
			end
		end
		if not (self.FGLeg) and (self.FGLegLost ~= true) then
			self.Suppression = self.Suppression + 100;
			self.FGLegLost = true;
			if self.Health < 50 then
				ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Pain, 5, 5);
			else
				ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.LashOut, 4, 5);
			end
		end
		if not (self.BGLeg) and (self.BGLegLost ~= true) then
			self.Suppression = self.Suppression + 100;
			self.BGLegLost = true;
			if self.Health < 50 then
				ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Pain, 5, 5);
			else
				ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.LashOut, 4, 5);
			end
		end	
		
		if wasHeavilyInjured then
			if math.random(0, 100) < 50 then -- just don't be in pain sometimes
				if self.Health < 200 then
					ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Pain, 5, 2)
				elseif self.inCombat == true then
					ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.LashOut, 4, 2)
				end
			end
			self.Suppression = self.Suppression + 100;
		elseif wasInjured then
			if math.random(0, 100) < 50 then -- just don't be in pain sometimes
				if self.Health < 100 then
					ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Pain, 5, 2)
				elseif self.inCombat == true then
					ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.LashOut, 4, 2)
				end
			end
			self.Suppression = self.Suppression + 50;
		elseif wasLightlyInjured then
			if math.random(0, 100) < 80 then -- just don't be in pain sometimes
				if self.inCombat == true then
					if math.random(0, 100) < 50 then
						ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.LashOut, 4, 2)
					else
						ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Vocalize, 4, 2)
					end
				end
			end
			ZedmassiveAIBehaviours.createEmotion(self, 2, 1, 500);
			self.Suppression = self.Suppression + math.random(15,25);
		end
	end
	
	if (self.allowedToDie == false and self.Health <= 0) and self.Dying ~= true then
		self.Health = 1;
		self.Dying = true;
		
		self.deathCount = self.deathCount + 1;
		self.Vel = self.Vel + Vector(RangeRand(-2, 2), RangeRand(-2.0, 0.5))
		self.AngularVel = self.AngularVel + RangeRand(2,6) * (math.random(0,1) * 2.0 - 1.0)
		
		if not self.voiceSound:IsBeingPlayed() then
			self.fakeDeathPlayed = true;
			ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.FakeDeath, 10, 2)
		else
			self.fakeDeathPlayed = false;
		end
		
		if math.random(1,2) < 2 then
			self.controller:SetState(Controller.WEAPON_DROP,true);
		end
	end	
	
end

function ZedmassiveAIBehaviours.handleSuppression(self)

	-- local blinkTimerReady = self.blinkTimer:IsPastSimMS(self.blinkDelay);
	local suppressionTimerReady = self.suppressionUpdateTimer:IsPastSimMS(1500);
	
	-- if (blinkTimerReady) and (not self.Suppressed) and self.Head then
		-- if self.Head.Frame == self.baseHeadFrame then
			-- ZedmassiveAIBehaviours.createEmotion(self, 1, 0, 100);
			-- self.blinkTimer:Reset();
			-- self.blinkDelay = math.random(5000, 11000);
		-- end
	-- end	
	
	if (suppressionTimerReady) then
		if self.inCombat == true then
			if self.Suppression < 35 then
				self.Suppression = self.Suppression + math.random(self.passiveSuppressionAmountLower, self.passiveSuppressionAmountUpper);
			end
		end
		if self.Suppression > 25 then

			if self.inCombat == true then
				if self.suppressedVoicelineTimer:IsPastSimMS(self.suppressedVoicelineDelay) and (not self.voiceSound:IsBeingPlayed()) then
					local chance = math.random(0, 100);
					if self.Suppression > 99 then
						-- keep playing voicelines if we keep being suppressed
							ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.BattleScream, 6, 4);
						self.suppressedVoicelineTimer:Reset();
						self.suppressionUpdates = 0;
					elseif self.Suppression > 55 then
						if self.Health < 100 and math.random(0, 100) < 20 then
							ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.BattleScream, 5, 4);
						elseif chance < 50 then
							ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Vocalize, 4, 4);
						elseif chance < 75 then
							ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.LashOut, 4, 4);
						else
							ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Breathing, 1, 4);
						end
						self.suppressedVoicelineTimer:Reset();
						self.suppressionUpdates = 0;
					end
					if self.Suppressed == false then -- initial voiceline
						if self.Suppression > 55 then
							if chance < 25 then
								ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.BattleScream, 5, 4);
							elseif chance < 50 then
								ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Vocalize, 4, 4);
							elseif chance < 75 then
								ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.LashOut, 4, 4);
							else
								ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Breathing, 1, 4);
							end
						else
							ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.LashOut, 4, 4);
						end
						self.suppressedVoicelineTimer:Reset();
					end
				end
			end
			self.Suppressed = true;
		else
			self.Suppressed = false;
		end
		self.Suppression = math.min(self.Suppression, 100)
		if self.Suppression > 0 then
			self.Suppression = self.Suppression - 2.5;
		end
		self.Suppression = math.max(self.Suppression, 0);
		self.suppressionUpdateTimer:Reset();
	end
end

function ZedmassiveAIBehaviours.handleAITargetLogic(self)
	-- SPOT ENEMY REACTION
	-- works off of the native AI's target
	
	if not self.LastTargetID then
		self.LastTargetID = -1
	end
	
	--spotEnemy
	--spotEnemyFar
	--spotEnemyClose
	
	if (not self:IsPlayerControlled()) and self.AI.Target and IsAHuman(self.AI.Target) then
	
		self.inCombat = true;
		self:SetNumberValue("InCombat", 1)
		self.combatExitTimer:Reset();
	
		self.spotVoiceLineTimer:Reset();
		
		local posDifference = SceneMan:ShortestDistance(self.Pos,self.AI.Target.Pos,SceneMan.SceneWrapsX)
		local distance = posDifference.Magnitude
		
		local isClose = distance < self.spotDistanceClose
		local isMid = distance < self.spotDistanceMid 
		local isFar = distance > self.spotDistanceMid 
		
		-- DEBUG spot distance
		--[[
		local maxi = math.floor(distance / 10)
		for i = 1, maxi do
			local vec = posDifference * i / maxi
			local pos = self.Pos + vec
			local color = 162
			if vec.Magnitude < self.spotDistanceClose then
				color = 13
			elseif vec.Magnitude < self.spotDistanceMid then
				color = 122
			end
			PrimitiveMan:DrawLinePrimitive(pos, pos, color);
		end]]
		
		if self.spotAllowed ~= false then
			
			if self.LastTargetID == -1 then
				self.LastTargetID = self.AI.Target.UniqueID
				-- Target spotted
				--local posDifference = SceneMan:ShortestDistance(self.Pos,self.AI.Target.Pos,SceneMan.SceneWrapsX)
				
				if not self.AI.Target:NumberValueExists("Massive Enemy Spotted Age") or -- If no timer exists
				self.AI.Target:GetNumberValue("Massive Enemy Spotted Age") < (self.AI.Target.Age - self.AI.Target:GetNumberValue("Massive Enemy Spotted Delay")) or -- If the timer runs out of time limit
				math.random(0, 100) < self.spotIgnoreDelayChance -- Small chance to ignore timers, to spice things up
				then
					-- Setup the delay timer
					self.AI.Target:SetNumberValue("Massive Enemy Spotted Age", self.AI.Target.Age)
					self.AI.Target:SetNumberValue("Massive Enemy Spotted Delay", math.random(self.spotDelayMin, self.spotDelayMax))
					
					self.spotAllowed = false;
				
					if isClose then
						ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.BattleScream, 5, 4);
					elseif math.random(0, 100) < 20 then
						ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Vocalize, 4, 4);
					end
					
				end
			else
				-- Refresh the delay timer
				if self.AI.Target:NumberValueExists("Massive Enemy Spotted Age") then
					self.AI.Target:SetNumberValue("Massive Enemy Spotted Age", self.AI.Target.Age)
				end
			end
		end
	else
		if self.spotVoiceLineTimer:IsPastSimMS(self.spotVoiceLineDelay) then
			self.spotAllowed = true;
		end
		if self.combatExitTimer:IsPastSimMS(self.combatExitDelay) and self.inCombat == true then
			self.inCombat = false;
			self:RemoveNumberValue("InCombat")
			if self.Health < 35 then
				ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Breathing, 2, 0);
			end
		end
		if self.LastTargetID ~= -1 then
			self.LastTargetID = -1
			-- Target lost
			--print("TARGET LOST!")
		end
	end
end

function ZedmassiveAIBehaviours.handleVoicelines(self)

	if self:NumberValueExists("Death By Fire") then
		self:RemoveNumberValue("Death By Fire");
		ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Pain, 9, 5);
	end
	
	if self:NumberValueExists("Massive Stone Throw") then
		self:RemoveNumberValue("Massive Stone Throw");
		ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.LashOut, 4, 4);
	end	
	
	if self:NumberValueExists("Massive MASSIVE Stone Throw") then
		self:RemoveNumberValue("Massive MASSIVE Stone Throw");
		ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.BattleScream, 5, 4);
	end	
	
	if self:NumberValueExists("Catapulted") then
		self:RemoveNumberValue("Catapulted");
		local chance = math.random(0, 100);
		if chance < 25 then
			ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.BattleScream, 5, 4);
		elseif chance < 50 then
			ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Vocalize, 4, 4);
		elseif chance < 75 then
			ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.LashOut, 4, 4);
		end
	end	
	
	self:RemoveNumberValue("Warcried");
	
	if (self:IsPlayerControlled() and UInputMan:KeyPressed(24)) and self.warCryTimer:IsPastSimMS(self.warCryDelay) and self.warCrySetOff ~= true then
		self.warCryTimer:Reset();
		self.warCrySetOff = true;
		
		ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.BattleScreamReverbPre, 9, 4);
		
	elseif self.warCrySetOff == true and self.warCryTimer:IsPastSimMS(350) then
	
		self.warCrySetOff = false;
		self:SetNumberValue("Warcried", 1);
	
		ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.BattleScreamReverb, 10, 4);
		self.battleScreamImpact:Play(self.Pos);
		self.warCryTimer:Reset();
		-- Ground Smoke
		local maxi = 25
		for i = 1, maxi do
			
			local effect = CreateMOSRotating("Ground Smoke Particle Small Massive", "Massive.rte")
			effect.Pos = self.Pos + Vector(RangeRand(-1,1), RangeRand(-1,1)) * 3
			effect.Vel = self.Vel + Vector(math.random(90,150),0):RadRotate(math.pi * 2 / maxi * i + RangeRand(-2,2) / maxi)
			effect.Lifetime = effect.Lifetime * RangeRand(0.5,2.0)
			effect.AirResistance = effect.AirResistance * RangeRand(0.5,0.8)
			MovableMan:AddParticle(effect)
		end
		
		for i = 1 , MovableMan:GetMOIDCount() - 1 do
			local mo = MovableMan:GetMOFromID(i);
			if mo and mo.PinStrength == 0 and mo.Team ~= self.Team then
				local dist = SceneMan:ShortestDistance(self.Pos, mo.Pos, SceneMan.SceneWrapsX);
				if dist.Magnitude < 700 then
					local strSumCheck = SceneMan:CastStrengthSumRay(self.Pos, self.Pos + dist, 3, rte.airID);
					if strSumCheck < 700 then
						local massFactor = math.sqrt(1 + math.abs(mo.Mass));
						local distFactor = 1 + dist.Magnitude * 0.1;
						local forceVector =	dist:SetMagnitude((700 - strSumCheck)/distFactor);
						mo.Vel = mo.Vel + ((forceVector/massFactor) / 2);
						mo.AngularVel = mo.AngularVel - forceVector.X/(massFactor + math.abs(mo.AngularVel));
						mo:AddForce(forceVector * massFactor, Vector());
					end
				end
			end	
		end
		
		local shakenessParticle = CreateMOPixel("Shakeness Particle Massive", "Massive.rte");
		shakenessParticle.Pos = self.Pos;
		shakenessParticle.Mass = 80;
		shakenessParticle.Lifetime = 2000;
		MovableMan:AddParticle(shakenessParticle);
		
	elseif not self.warCryTimer:IsPastSimMS(7000) then
		self.accelerationFactor = 0.5;
		if self.Health < self.warCryOldHealth then
			self.Health = self.Health + ((self.warCryOldHealth - self.Health) / 2);
			self.warCryOldHealth = self.Health;
		end
	else
		self.accelerationFactor = 0.1;
	end
	
	if self:NumberValueExists("Mordhau Arrow Suppression") then
		self:RemoveNumberValue("Mordhau Arrow Suppression");
		self.Suppression = self.Suppression + 3;
		ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.LashOut, 3, 0);
	end

	-- DEVICE RELATED VOICELINES
	
	if (self.attackSuccess == true) and (not self.voiceSound:IsBeingPlayed() or self.attackSuccessTimer:IsPastSimMS(self.attackSuccessTime)) then
		self.attackSuccess = false;
		ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.LashOut, 4, 3);
	end
	
	if (self.attackKilled == true) and (not self.voiceSound:IsBeingPlayed() or self.attackKilledTimer:IsPastSimMS(self.attackKilledTime)) then
		self.attackKilled = false;
		ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.BattleScream, 5, 4);
	end
	
	if self.EquippedItem then	
		-- SUPPRESSING
		if (IsHDFirearm(self.EquippedItem)) then
			local gun = ToHDFirearm(self.EquippedItem);
			local gunMag = gun.Magazine
			local reloading = gun:IsReloading();
			
			if self.EquippedItem:IsInGroup("Weapons - Primary") and not ToMOSRotating(self.EquippedItem):NumberValueExists("Weapons - Mordhau Melee") then
				
				if gun.FullAuto == true and gunMag and gunMag.Capacity > 40  and gun:IsActivated() then
					if gun.FiredFrame then
						self.gunShotCounter = self.gunShotCounter + 1;
					end
					if self.gunShotCounter > (gunMag.Capacity*0.7) and self.suppressingVoicelineTimer:IsPastSimMS(self.suppressingVoicelineDelay) then
						ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.BattleScream, 3, 3);
						self.suppressingVoicelineTimer:Reset();
					end
				else
					self.gunShotCounter = 0;
				end			
				
			elseif (self.EquippedItem:IsInGroup("Weapons - Mordhau Melee") or ToMOSRotating(self.EquippedItem):NumberValueExists("Weapons - Mordhau Melee")) then
				if self:NumberValueExists("Block Foley") then
					self:RemoveNumberValue("Block Foley");
					self.movementSounds.AttackLight:Play(self.Pos);
				elseif self:NumberValueExists("Light Attack") then
					self:RemoveNumberValue("Light Attack");
					ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Grunt, 3, 3);
					self.movementSounds.AttackLight:Play(self.Pos);
				elseif self:NumberValueExists("Medium Attack") then
					self:RemoveNumberValue("Medium Attack");
					ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Grunt, 3, 3);
					self.movementSounds.AttackMedium:Play(self.Pos);
				elseif self:NumberValueExists("Large Attack") then
					self:RemoveNumberValue("Large Attack");
					ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.LashOut, 3, 3);
					self.movementSounds.AttackLarge:Play(self.Pos);
				elseif self:NumberValueExists("Extreme Attack") then
					self:RemoveNumberValue("Extreme Attack");
					ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.LashOut, 3, 3);
					self.movementSounds.AttackExtreme:Play(self.Pos);
					
				elseif self:NumberValueExists("Attack Success") then
					self.attackSuccess = true;
					self:RemoveNumberValue("Attack Success");
					self.attackSuccessTimer:Reset();
					
				elseif self:NumberValueExists("Attack Killed") then
					self.attackKilled = true;
					self:RemoveNumberValue("Attack Killed");
					self.attackKilledTimer:Reset();
				end
			end
			
			
			if (reloading) then
				if (self.reloadVoicelinePlayed ~= true) then
					self.reloadVoicelinePlayed = true;
				end
			else
				self.reloadVoicelinePlayed = false;
			end
		end
		
		-- THROWING GRENADES
	
		if IsThrownDevice(self.EquippedItem) then
			local activated = self.controller:IsState(Controller.WEAPON_FIRE)
			if (activated) then

				if self.activatedExplosive ~= true then
					self.activatedExplosive = true;
					self.movementSounds.FoleyGenericLight:Play(self.Pos);
				end

				-- if (self.throwGrenadeVoicelinePlayed ~= true) then
					-- --ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.throwGrenade, 3, 4);
					-- self.throwGrenadeVoicelinePlayed = true;
				-- end
			else
				-- self.throwGrenadeVoicelinePlayed = false;
				if self.activatedExplosive then
					self.activatedExplosive = false;
					self.movementSounds.FoleyGenericHeavy:Play(self.Pos);
					ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Vocalize, 3, 3);

				end
			end
		end
	end

	-- DEATH REACTIONS
	-- the dying actor actually lets us know whether to play a voiceline through 1-time detection and value-setting.
	-- 0 = male, 1 = female
	
	-- if self:NumberValueExists("Massive Friendly Down") then
		-- self.Suppression = self.Suppression + 25;
		-- if self.friendlyDownTimer:IsPastSimMS(self.friendlyDownDelay) then
			-- local Sounds = self:GetNumberValue("Massive Friendly Down") == 0 and self.voiceSounds.maleDown or self.voiceSounds.femaleDown;
			
			-- ZedmassiveAIBehaviours.createVoiceSoundEffect(self, Sounds, 4, 4, true);		
			-- self.friendlyDownTimer:Reset();
		-- end
		-- self:RemoveNumberValue("Massive Friendly Down")
	-- end	
end

function ZedmassiveAIBehaviours.handleDying(self)

	self.HUDVisible = false
	
	if self.allowedToDie == false then
		self.Health = 1;
		self.Status = 0;
		if self.deathCount > self.deathsMax and self.Reviving ~= true then
			self.controller:SetState(Controller.BODY_JUMPSTART, false);
			self.controller:SetState(Controller.BODY_JUMP, false);
			self.controller:SetState(Controller.BODY_CROUCH, false);
			if self.deathFirstPlayed ~= true then
				self.deathFirstPlayed = true;
				ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.DeathFirst, 16, 5);
				self.deathTimer = Timer();
			elseif not self.voiceSound:IsBeingPlayed() then
				self.deathFinal = true;
				ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.DeathFinal, 15, 5);
				self.allowedToDie = true;
				print("allow")
				self.Status = 3;
				self.Vel = self.Vel + Vector(RangeRand(1, 2), -1) * self.FlipFactor
				self.AngularVel = self.AngularVel + RangeRand(5,10) * self.FlipFactor * -1
			end
			if self.deathFirstPlayed then
				if self.moveMultiplier > 0 then
					self.moveMultiplier = self.moveMultiplier - TimerMan.DeltaTimeSecs * 0.4;
					self:SetLimbPathSpeed(0, self.limbPathDefaultSpeed0 * self.moveMultiplier);
					self:SetLimbPathSpeed(1, self.limbPathDefaultSpeed1 * self.moveMultiplier);
					self:SetLimbPathSpeed(2, self.limbPathDefaultSpeed2 * self.moveMultiplier);
					self.LimbPathPushForce = self.limbPathDefaultPushForce * self.sprintPushForceDenominator * self.moveMultiplier;
				end
				if self.deathTimer:IsPastSimMS(1700) then
					self.controller:SetState(Controller.BODY_CROUCH, true);
					self.controller:SetState(Controller.MOVE_RIGHT, false);
					self.controller:SetState(Controller.MOVE_LEFT, false);
				end
			end
		else		
			self.Status = 3;
		end
	else
		self.controller.Disabled = true;
		self.Health = -1;
		self.Status = 4;
	end
	
	if self.terrainCollided and self.deathCount <= self.deathsMax and self.deathTerrainSoundPlayed ~= true then
		self.deathTerrainSoundPlayed = true;
		self.movementSounds.BassLayer:Play(self.Pos);
		self.movementSounds.FallDamage:Play(self.Pos);
		self.movementSounds.FoleyTerrainImpact:Play(self.Pos);
		local shakenessParticle = CreateMOPixel("Shakeness Particle Massive", "Massive.rte");
		shakenessParticle.Pos = self.Pos;
		shakenessParticle.Mass = 35;
		shakenessParticle.Lifetime = 1000;
		MovableMan:AddParticle(shakenessParticle);
	end

	if self.Head then
			
		if self.deathCount <= self.deathsMax then
			self.controller.Disabled = true;
			if not self.fakeDeathPlayed then
				ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.FakeDeath, 12, 5);
				self.fakeDeathPlayed = true;
			elseif not self.Reviving and not self.voiceSound:IsBeingPlayed() then
				self.Reviving = true;
				ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Reviving, 15, 5);
			elseif not self.voiceSound:IsBeingPlayed() then
				ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Revived, 15, 5);
				self.warCryTimer:Reset();
				self.Health = 150;
				self.HUDVisible = true;
				self.controller.Disabled = false;
				self.Reviving = false;
				self.Dying = false;
				self.Status = 1;
			end
			if self.Reviving then
				self.AngularVel = self.AngularVel + RangeRand(1,2) * (math.random(0,1) * 2.0 - 1.0)
			end
		end
	else
		self.allowedToDie = true;
	end
end

function ZedmassiveAIBehaviours.handleRagdoll(self)
	
	local mat = self.HitWhatTerrMaterial
	--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + self.TravelImpulse * 0.1, 5);
	--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + self.Vel, 13);
	--self.TravelImpulse.Magnitude
	if mat ~= 0 then
		if self.ragdollTerrainImpactTimer:IsPastSimMS(self.ragdollTerrainImpactDelay) then
			self.ragdollTerrainImpactDelay = math.random(200, 500)
			self.ragdollTerrainImpactTimer:Reset()
			if self.TravelImpulse.Magnitude > self.ImpulseDamageThreshold then
				self.movementSounds.BassLayer:Play(self.Pos);
				self.movementSounds.FallDamage:Play(self.Pos);
				self.movementSounds.FoleyTerrainImpact:Play(self.Pos);
				local shakenessParticle = CreateMOPixel("Shakeness Particle Massive", "Massive.rte");
				shakenessParticle.Pos = self.Pos;
				shakenessParticle.Mass = 80;
				shakenessParticle.Lifetime = 1000;
				MovableMan:AddParticle(shakenessParticle);
			elseif self.TravelImpulse.Magnitude > self.ImpulseDamageThreshold/2 then
				self.movementSounds.BassLayer:Play(self.Pos);
				self.movementSounds.FoleyTerrainImpact:Play(self.Pos);
				local shakenessParticle = CreateMOPixel("Shakeness Particle Massive", "Massive.rte");
				shakenessParticle.Pos = self.Pos;
				shakenessParticle.Mass = 35;
				shakenessParticle.Lifetime = 700;
				MovableMan:AddParticle(shakenessParticle);
			end
		end
	end
end

function ZedmassiveAIBehaviours.handleHeadFrames(self)
	if not self.Head then return end
	if self.Emotion and self.emotionApplied ~= true and self.Head then
		self.Head.Frame = self.baseHeadFrame + self.Emotion;
		self.emotionApplied = true;
	end
		
		
	if self.emotionDuration > 0 and self.emotionTimer:IsPastSimMS(self.emotionDuration) then
		if (self.Suppressed or self.Suppressing) and (self.inCombat == true) then
			self.Head.Frame = self.baseHeadFrame + 2;
		else
			self.Head.Frame = self.baseHeadFrame;
		end
	elseif (self.emotionDuration == 0) and ((not self.voiceSound or not self.voiceSound:IsBeingPlayed())) then
		-- if suppressed OR suppressing when in combat base emotion is angry
		if (self.Suppressed or self.Suppressing) and (self.inCombat == true) then
			self.Head.Frame = self.baseHeadFrame + 2;
		else
			self.Head.Frame = self.baseHeadFrame;
		end
	end

end

function ZedmassiveAIBehaviours.DoArmSway(self, pushStrength)
	local aimAngle = self:GetAimAngle(false);
	local flippedAimAngle = self:GetAimAngle(true);
	if self.Status == Actor.STABLE and self.lastHandPos then
		--Flail around if aiming around too fast
		local angleMovement = self.lastAngle - aimAngle;
		self.AngularVel = self.AngularVel - (2 * angleMovement * self.FlipFactor)/(math.abs(self.AngularVel) * 0.1 + 1);
		--Shove when unarmed
		if self.controller:IsState(Controller.WEAPON_FIRE) and (self.FGArm or self.BGArm) and not (self.EquippedItem or self.EquippedBGItem) and self.shoveCooldownTimer:IsPastSimMS(self.shoveCooldownTime) then
			self.AngularVel = self.AngularVel/(self.shoved and 2.4 or 3) + (aimAngle - self.RotAngle * self.FlipFactor - 1.57) * (self.shoved and 0.1 or 3) * self.FlipFactor/(1 + math.abs(self.RotAngle));
			if not self.shoved then
				ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Grunt, 4, 5);
				self.Vel = self.Vel + Vector(2/(1 + self.Vel.Magnitude), 0):RadRotate(self:GetAimAngle(true)) * math.abs(math.cos(self:GetAimAngle(true)));
				self.shoved = true;
			end
		else
			if self.shoved == true then
				self.shoveCooldownTimer:Reset();
			end
			self.shoved = false;
		end
		local shove = {};
		local armPairs = {{self.FGArm, self.FGLeg, self.BGLeg}, {self.BGArm, self.BGLeg, self.FGLeg}};
		for i = 1, #armPairs do
			local arm = armPairs[i][1];
			if arm then
				arm = ToArm(arm);
				
				local armLength = arm.MaxLength;
				local rotAng = self.RotAngle - (1.57 * self.FlipFactor);
				local legMain = armPairs[i][2];
				local legAlt = armPairs[i][3];
				
				if self.controller:IsState(Controller.MOVE_LEFT) or self.controller:IsState(Controller.MOVE_RIGHT) then
					rotAng = (legAlt and legAlt.RotAngle) or (legMain and (-legMain.RotAngle + math.pi) or rotAng);
				elseif legMain then
					rotAng = legMain.RotAngle;
				end
				--Flail arms in tandem with leg movement or raise them them up for a push if aiming
				-- if self.controller:IsState(Controller.AIM_SHARP) then
					-- arm.IdleOffset = Vector(0, 1):RadRotate(aimAngle);
				-- else
					-- arm.IdleOffset = Vector(0, armLength * 0.7):RadRotate(rotAng * self.FlipFactor + 1.5 + (i * 0.2));
				-- end
				if self.shoved or (self.EquippedItem and IsTDExplosive(self.EquippedItem) and self.controller:IsState(Controller.WEAPON_FIRE)) then
					self.ArmSwingRate = 0;
					arm.IdleOffset = Vector(armLength + (pushStrength * armLength), 0):RadRotate(aimAngle);
					local handVector = SceneMan:ShortestDistance(self.lastHandPos[i], arm.HandPos, SceneMan.SceneWrapsX);
					--Diminish hand relocation vector to prevent superhuman pushing powers
					handVector:SetMagnitude(math.min(handVector.Magnitude, 1 + armLength * 0.1));
					local armStrength = (arm.Mass + arm.Material.StructuralIntegrity * 0.5) * pushStrength;

					shove.Pos = shove.Pos and shove.Pos + SceneMan:ShortestDistance(shove.Pos, arm.HandPos, SceneMan.SceneWrapsX) * 0.5 or arm.HandPos;
					shove.Power = shove.Power and shove.Power + armStrength or armStrength;
					shove.Vector = shove.Vector and shove.Vector + handVector * 0.5 or handVector * 0.5;
				else
					self.ArmSwingRate = 1;
					arm.IdleOffset = Vector(0, armLength * 0.7);
				end
				self.lastHandPos[i] = arm.HandPos;
			end
		end
		if shove.Pos then
		
			local shoveVector = SceneMan:ShortestDistance(self.Pos, shove.Pos, SceneMan.SceneWrapsX);
			local angleFlip = self.HFlipped and -math.pi or 0
			
			--local moCheck = SceneMan:GetMOIDPixel(shove.Pos.X + self.FlipFactor, shove.Pos.Y - 1);
			local moCheck = SceneMan:CastMORay(shove.Pos, shove.Vector, self.ID, self.Team, rte.airID, false, shove.Vector.Magnitude - 1);
			if moCheck ~= rte.NoMOID then
				local MO = MovableMan:GetMOFromID(MovableMan:GetMOFromID(moCheck).ID);
				local rootMO = MovableMan:GetMOFromID(MovableMan:GetMOFromID(moCheck).RootID);
				if rootMO and rootMO.Team ~= self.Team and IsActor(rootMO) then
				
					if IsAttachable(MO) and ToAttachable(MO):IsAttached() and (IsArm(MO) or IsLeg(MO) or (IsAHuman(actorHit) and ToAHuman(actorHit).Head and MO.UniqueID == ToAHuman(actorHit).Head.UniqueID)) then
						-- two different ways to dismember: 1. if limb is close to being gibbed, dismember it instead 2. low hp and rng
						local attachable = ToAttachable(MO);
						if attachable.WoundCount + 5 >= attachable.GibWoundLimit then
							attachable:RemoveFromParent(true, true);
							self.stickMO = attachable;
							self.stickMOAngle = attachable.RotAngle - shoveVector.AbsRadAngle;
						elseif ToActor(rootMO).Health < 20 and math.random(0, 100) < 20 then
							attachable:RemoveFromParent(true, true);
							self.stickMO = attachable;
							self.stickMOAngle = attachable.RotAngle - shoveVector.AbsRadAngle;
						end
					end					
				
					if self.shoveSoundsPlayed == false then -- ought to rename this..
					
						if self.Mass > rootMO.Mass then
							ToActor(rootMO).Health = ToActor(rootMO).Health - (2 * self.Mass/rootMO.Mass)
						end
						
						if IsAttachable(MO) and ToAttachable(MO):IsAttached() and (IsArm(MO) or IsLeg(MO) or (IsAHuman(rootMO) and ToAHuman(rootMO).Head and MO.UniqueID == ToAHuman(rootMO).Head.UniqueID)) then
							-- two different ways to dismember: 1. if limb is close to being gibbed, dismember it instead 2. low hp and rng
							local MO = ToAttachable(MO);
							if MO.WoundCount + 5 >= MO.GibWoundLimit then
								MO:RemoveFromParent(true, true);
								self.stickMO = MO;
								self.stickMOAngle = MO.RotAngle - (shoveVector.AbsRadAngle + angleFlip);
								self.stickMOOrigHits = self.stickMO.HitsMOs;
							elseif ToActor(rootMO).Health < 20 and math.random(0, 100) < 20 then
								MO:RemoveFromParent(true, true);
								self.stickMO = MO;
								self.stickMOAngle = MO.RotAngle - (shoveVector.AbsRadAngle + angleFlip);
								self.stickMOOrigHits = self.stickMO.HitsMOs;
							end
						end								
						
						self.shoveSoundsPlayed = true;
						self.tackleImpactGenericSound:Play(self.Pos);
						
						local material = rootMO.Material.PresetName
						if string.find(material,"Metal") or string.find(material,"Stuff") then
							self.tackleImpactMetalActorSound:Play(rootMO.Pos);
						end
					end
					if self.Mass > rootMO.Mass then
						ToActor(rootMO).Status = Actor.UNSTABLE;
						--Simulate target actor weight with an attachable
						local weight = CreateAttachable("Null Attachable");
						weight.Mass = rootMO.Mass;
						weight.Lifetime = 1;
						self:AddAttachable(weight);
						local shoveVel = shove.Vector/rte.PxTravelledPerFrame;
						rootMO.Vel = rootMO.Vel * 0.5 + shoveVel:SetMagnitude(math.min(shoveVel.Magnitude, math.sqrt(self.IndividualDiameter))) - SceneMan.GlobalAcc * GetMPP() * rte.PxTravelledPerFrame;
						rootMO.AngularVel = (aimAngle - self.lastAngle) * self.FlipFactor * math.pi;
					else
						rootMO:AddForce(shove.Vector * (self.Mass * 0.5) * shove.Power, Vector());
					end
				end
			end
			
			if self.stickMO then
			
				local stickObstructionCheckRay = SceneMan:CastStrengthSumRay(self.Pos, self.Pos + shoveVector, 4, 0);
				if stickObstructionCheckRay > 100 then
					self.stickMO = nil;
				end
				
				if self.stickMO and MovableMan:ValidMO(self.stickMO) then				
					self.stickMO.Vel = self.Vel
					if self.stickMOLastPos then
						self.stickMO.Vel = self.Vel + SceneMan:ShortestDistance(self.stickMOLastPos, shove.Pos, SceneMan.SceneWrapsX);
						self.stickMO.Vel = self.stickMO.Vel * 2
					end
					self.stickMO.Pos = shove.Pos + Vector(self.stickMO.Radius * 0.6, 0):RadRotate(shoveVector.AbsRadAngle)
					self.stickMO.RotAngle = (shoveVector.AbsRadAngle + angleFlip) + self.stickMOAngle;
					self.stickMO.ToSettle = false;
					self.stickMOLastPos = shove.Pos;
					self.stickMO.HitsMOs = false;
				else
					self.stickMO = nil;
				end
				
			end
			
			local crouching = self.controller:IsState(Controller.BODY_CROUCH)
			
			if (not self.grabbingStone) and crouching and self.Vel.Magnitude < 2 then
				if self.stoneTossCheckTimer:IsPastSimMS(self.stoneTossCheckTime) then
					self.stoneTossCheckTimer:Reset();
					
					local concPixels = 0;
					local dirtPixels = 0;
					local sandPixels = 0;
					local solidMetalPixels = 0;
					
					for i = 1, 14 do	
						-- count how many of each material we find in a line perpendicular to the shove angleMovement
						-- cool reusage of a mechanic, huh??? isnt it cool??? i couldve just put a new hotkey in you know
						self.stoneTossCheckI = self.stoneTossCheckI % 13 + 1
						
						local checkOrigin = Vector(shove.Pos.X, shove.Pos.Y) + Vector(1, -10 + (self.stoneTossCheckI - 1) * 3):RadRotate(flippedAimAngle - (0.5 * self.FlipFactor))
						local checkPix = SceneMan:GetTerrMatter(checkOrigin.X, checkOrigin.Y)
						
						--PrimitiveMan:DrawLinePrimitive(checkOrigin, checkOrigin, 5);
						
						if checkPix == 12 or checkPix == 164 or checkPix == 177 then
							concPixels = concPixels + 1;
						elseif checkPix == 9 or checkPix == 10 or checkPix == 11 or checkPix == 128 then
							dirtPixels = dirtPixels + 1;
						elseif checkPix == 6 or checkPix == 8 then
							sandPixels = sandPixels + 1;
						elseif checkPix == 178 or checkPix == 179 or checkPix == 180 or checkPix == 181 or checkPix == 182 then
							solidMetalPixels = solidMetalPixels + 1;
						end
						
					end
					
					if concPixels + dirtPixels + sandPixels + solidMetalPixels > 13 then
						if concPixels > 8 or ((concPixels + solidMetalPixels) > 9 and solidMetalPixels < 9) then -- concrete is often accompanied by metal so just account for that
							self.stoneTossCheckTime = 200;
							self.grabbingStone = true;
							self.grabStoneType = "Concrete";
							self.grabStonePhase = "Initial";
							self.grabStoneAngle = aimAngle;
						elseif solidMetalPixels > 8  then
							self.stoneTossCheckTime = 200;
							self.grabbingStone = true;
							self.grabStoneType = "Metal";
							self.grabStonePhase = "Initial";
							self.grabStoneAngle = aimAngle;
						elseif dirtPixels > 8 then
						elseif sandPixels > 8 then
						else
						end
					end

				end	
			elseif self.grabbingStone == true then
				if not (crouching and self.Vel.Magnitude < 3) or (aimAngle < self.grabStoneAngle - 0.25 or aimAngle > self.grabStoneAngle + 0.25) then
					self.grabbingStone = false;
					self.stoneTossCheckTime = 200;
				elseif self.stoneTossCheckTimer:IsPastSimMS(self.stoneTossCheckTime) then
					self.stoneTossCheckTime = self.stoneTossCheckTime + 1000;
					self.stoneTossCheckTimer:Reset();
					local soundContainer = CreateSoundContainer(self.grabStoneType .. " Pick Up " .. self.grabStonePhase .. " Rock StoneToss", "Massive.rte");
					soundContainer:Play(self.Pos);
					if self.grabStonePhase == "Initial" then
						self.grabStonePhase = "Second";
						self.AngularVel = self.AngularVel + RangeRand(2,6) * (math.random(0,1) * 2.0 - 1.0)
						local smokePos = Vector(0, 0)
						SceneMan:CastObstacleRay(self.Pos, shoveVector, Vector(0, 0), smokePos, self.ID, 1, 128, 1);
						
						if self.grabStoneType == "Concrete" then
							for i = 1, 20 do
								local spread = (math.pi * 2) * RangeRand(-1, 1)
								local velocity = 50 * RangeRand(0.1, 0.9) * 0.4;
								
								local particle = CreateMOSParticle(math.random(0, 100) < 70 and "Tiny Smoke Ball 1" or "Small Smoke Ball 1");
								particle.Pos = smokePos
								particle.Vel = self.Vel + Vector(velocity * self.FlipFactor,0):RadRotate(self.RotAngle + spread)
								particle.Lifetime = particle.Lifetime * RangeRand(0.9, 1.6)
								particle.AirThreshold = particle.AirThreshold * 0.5
								particle.GlobalAccScalar = 0
								MovableMan:AddParticle(particle);
							end
						elseif self.grabStoneType == "Metal" then
						
							for i = 1, 7 do
								local spread = (math.pi * 2) * RangeRand(-1, 1)
								local velocity = 50 * RangeRand(0.1, 0.9) * 0.4;
								
								local particle = CreateMOPixel(math.random(0, 100) < 70 and "Spark Yellow 1" or "Spark Yellow 2");
								particle.Pos = smokePos
								particle.Vel = self.Vel + Vector(velocity * self.FlipFactor,0):RadRotate(self.RotAngle + spread)
								particle.Lifetime = particle.Lifetime * RangeRand(0.9, 1.6)
								MovableMan:AddParticle(particle);
							end
							
						end
						
					elseif self.grabStonePhase == "Second" then
						ZedmassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Vocalize, 4, 2)
						self.grabStonePhase = "Final";
						self.AngularVel = self.AngularVel + RangeRand(2,6) * (math.random(0,1) * 2.0 - 1.0)
						local smokePos = Vector(0, 0)
						SceneMan:CastObstacleRay(self.Pos, shoveVector, Vector(0, 0), smokePos, self.ID, 1, 128, 1);
						
						if self.grabStoneType == "Concrete" then
							for i = 1, 35 do
								local spread = (math.pi * 2) * RangeRand(-1, 1)
								local velocity = 50 * RangeRand(0.1, 0.9) * 0.4;
								
								local particle = CreateMOSParticle(math.random(0, 100) < 70 and "Tiny Smoke Ball 1" or "Small Smoke Ball 1");
								particle.Pos = smokePos
								particle.Vel = self.Vel + Vector(velocity * self.FlipFactor,0):RadRotate(self.RotAngle + spread)
								particle.Lifetime = particle.Lifetime * RangeRand(0.9, 1.6) * 1.5
								particle.AirThreshold = particle.AirThreshold * 0.5
								particle.GlobalAccScalar = 0
								MovableMan:AddParticle(particle);
							end
						elseif self.grabStoneType == "Metal" then
							for i = 1, 4 do
								local spread = (math.pi * 2) * RangeRand(-1, 1)
								local velocity = 50 * RangeRand(0.1, 0.9) * 0.4;
								
								local particle = CreateMOPixel(math.random(0, 100) < 70 and "Spark Yellow 1" or "Spark Yellow 2");
								particle.Pos = smokePos
								particle.Vel = self.Vel + Vector(velocity * self.FlipFactor,0):RadRotate(self.RotAngle + spread)
								particle.Lifetime = particle.Lifetime * RangeRand(0.9, 1.6)
								MovableMan:AddParticle(particle);
							end						
						
						end
						
					else
						self.stoneTossCheckTime = 200;
						self.grabbingStone = false;
						self:UnequipFGArm()
						self:UnequipBGArm()
						self.AngularVel = self.AngularVel + (12 * self.FlipFactor);
						local smokePos = Vector(0, 0)
						SceneMan:CastObstacleRay(self.Pos, shoveVector, Vector(0, 0), smokePos, self.ID, 1, 128, 1);
						
						if self.grabStoneType == "Concrete" then
						
							self:AddInventoryItem(CreateHeldDevice("Ripped-up " .. self.grabStoneType .. " Chunk", "Massive.rte"));
						
							for i = 1, 70 do
								local spread = (math.pi * 2) * RangeRand(-1, 1)
								local velocity = 80 * RangeRand(0.1, 0.9) * 0.4;
								
								local particle = CreateMOSParticle(math.random(0, 100) < 70 and "Tiny Smoke Ball 1" or "Small Smoke Ball 1");
								particle.Pos = smokePos
								particle.Vel = self.Vel + Vector(velocity * self.FlipFactor,0):RadRotate(self.RotAngle + spread)
								particle.Lifetime = particle.Lifetime * RangeRand(0.9, 1.6) * 2.0
								particle.AirThreshold = particle.AirThreshold * 0.5
								particle.GlobalAccScalar = 0
								MovableMan:AddParticle(particle);
							end
						elseif self.grabStoneType == "Metal" then
						
							self:AddInventoryItem(CreateHeldDevice("Ripped-up " .. self.grabStoneType .. " Chunk", "Massive.rte"));
						
							for i = 1, 50 do
								local spread = (math.pi * 2) * RangeRand(-1, 1)
								local velocity = 50 * RangeRand(0.1, 0.9) * 0.4;
								
								local particle = CreateMOPixel(math.random(0, 100) < 70 and "Spark Yellow 1" or "Spark Yellow 2");
								particle.Pos = smokePos
								particle.Vel = self.Vel + Vector(velocity * self.FlipFactor,0):RadRotate(self.RotAngle + spread)
								particle.Lifetime = particle.Lifetime * RangeRand(0.9, 1.6)
								MovableMan:AddParticle(particle);
							end
						end
						
						local shakenessParticle = CreateMOPixel("Shakeness Particle Massive", "Massive.rte");
						shakenessParticle.Pos = self.Pos;
						shakenessParticle.Mass = 25;
						shakenessParticle.Lifetime = 500;
						MovableMan:AddParticle(shakenessParticle);
					end
				end
			end
		else
			if self.stickMO and MovableMan:ValidMO(self.stickMO) then
				self.stickMO.HitsMOs = self.stickMOOrigHits;
				self.stickMO = nil;
			end
			self.shoveSoundsPlayed = false;
			self.grabbingStone = false;
			self.stoneTossCheckTime = 200;
		end
		self.lastAngle = aimAngle;
	else
		self.lastAngle = aimAngle;
		self.lastHandPos = {self.Pos, self.Pos};
	end
end

function ZedmassiveAIBehaviours.handleHeadLoss(self)
	if not (self.Head) then
		self.allowedToDie = true;
		self.voiceSounds = {};
		if self.deathFinal ~= true then
			self.voiceSound:Stop(-1);
		end
	end
end