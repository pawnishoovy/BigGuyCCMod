MassiveAIBehaviours = {};

-- function MassiveAIBehaviours.createSoundEffect(self, effectName, variations)
	-- if effectName ~= nil then
		-- self.soundEffect = AudioMan:PlaySound(effectName .. math.random(1, variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 400, false);	
	-- end
-- end

-- no longer needed as of pre3!

function MassiveAIBehaviours.createEmotion(self, emotion, priority, duration, canOverridePriority)
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

function MassiveAIBehaviours.createVoiceSoundEffect(self, soundContainer, priority, emotion, canOverridePriority)
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
						MassiveAIBehaviours.createEmotion(self, emotion, priority, 0, canOverridePriority);
					end
					self.voiceSound:Stop();
					self.voiceSound = soundContainer;
					soundContainer:Play(self.Pos)
					self.lastPriority = priority;
					return true;
				end
			else
				if emotion then
					MassiveAIBehaviours.createEmotion(self, emotion, priority, 0, canOverridePriority);
				end
				self.voiceSound = soundContainer;
				soundContainer:Play(self.Pos)
				self.lastPriority = priority;
				return true;
			end
		else
			if emotion then
				MassiveAIBehaviours.createEmotion(self, emotion, priority, 0, canOverridePriority);
			end
			self.voiceSound = soundContainer;
			soundContainer:Play(self.Pos)
			self.lastPriority = priority;
			return true;
		end
	end
end

function MassiveAIBehaviours.handleMovement(self)

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
			if self.controller:IsState(Controller.MOVE_LEFT) == true then
				jumpVec.X = -jumpWalkX
			elseif self.controller:IsState(Controller.MOVE_RIGHT) == true then
				jumpVec.X = jumpWalkX
			end
			self.movementSounds.Jump:Play(self.Pos);

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
	
	if input then
		
		if self.moveMultiplier < self.sprintMultiplier then
			self.moveMultiplier = self.moveMultiplier + TimerMan.DeltaTimeSecs * self.accelerationFactor;
			if self.moveMultiplier > self.sprintMultiplier then
				self.isSprinting = true;
				self.moveMultiplier = self.sprintMultiplier;
			end
		end
		
		if self.isSprinting then
			MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Breathing, 1);
		end
		
		self:SetLimbPathSpeed(0, self.limbPathDefaultSpeed0 * self.moveMultiplier);
		self:SetLimbPathSpeed(1, self.limbPathDefaultSpeed1 * self.moveMultiplier);
		self:SetLimbPathSpeed(2, self.limbPathDefaultSpeed2 * self.moveMultiplier);
		self.LimbPathPushForce = self.limbPathDefaultPushForce * self.sprintPushForceDenominator
	else
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

function MassiveAIBehaviours.handleHealth(self)

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
			MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Scream, 16, 5);
		end
	
		self.oldHealth = self.Health;
		self.healthUpdateTimer:Reset();
		
		if not (self.FGArm) and (self.FGArmLost ~= true) then
			self.Suppression = self.Suppression + 100;
			self.FGArmLost = true;
			if self.Health < 50 then
				MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Scream, 5, 5);
			else
				MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Unphased, 4, 5);
			end
		end
		if not (self.BGArm) and (self.BGArmLost ~= true) then
			self.Suppression = self.Suppression + 100;
			self.BGArmLost = true;
			if self.Health < 50 then
				MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Scream, 5, 5);
			else
				MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Unphased, 4, 5);
			end
		end
		if not (self.FGLeg) and (self.FGLegLost ~= true) then
			self.Suppression = self.Suppression + 100;
			self.FGLegLost = true;
			if self.Health < 50 then
				MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Scream, 5, 5);
			else
				MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Unphased, 4, 5);
			end
		end
		if not (self.BGLeg) and (self.BGLegLost ~= true) then
			self.Suppression = self.Suppression + 100;
			self.BGLegLost = true;
			if self.Health < 50 then
				MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Scream, 5, 5);
			else
				MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Unphased, 4, 5);
			end
		end	
		
		if wasHeavilyInjured then
			if math.random(0, 100) < 50 then -- just don't be in pain sometimes
				if self.Health < 200 then
					MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Pain, 5, 2)
				elseif self.inCombat == true then
					MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Unphased, 4, 2)
				end
			end
			self.Suppression = self.Suppression + 100;
		elseif wasInjured then
			if math.random(0, 100) < 50 then -- just don't be in pain sometimes
				if self.Health < 100 then
					MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Pain, 5, 2)
				elseif self.inCombat == true then
					MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Unphased, 4, 2)
				end
			end
			self.Suppression = self.Suppression + 50;
		elseif wasLightlyInjured then
			if math.random(0, 100) < 50 then -- just don't be in pain sometimes
				if self.inCombat == true then
					if math.random(0, 100) < 50 then
						MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Unphased, 4, 2)
					else
						MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Laugh, 4, 2)
					end
				end
			end
			MassiveAIBehaviours.createEmotion(self, 2, 1, 500);
			self.Suppression = self.Suppression + math.random(15,25);
		end
		
		if (wasInjured or wasHeavilyInjured) and self.Head then
			
			if self.Health > 0 then
			else
				if math.random(0, 100) < 50 then
					MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Death, 10, 5)
				else
					MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.DeathSerious, 10, 5)
				end
				self.seriousDeath = true;
				self.deathSoundPlayed = true;
				-- for actor in MovableMan.Actors do
					-- if actor.Team == self.Team then
						-- local d = SceneMan:ShortestDistance(actor.Pos, self.Pos, true).Magnitude;
						-- if d < 300 then
							-- local strength = SceneMan:CastStrengthSumRay(self.Pos, actor.Pos, 0, 128);
							-- if strength < 500 and math.random(1, 100) < 65 then
								-- actor:SetNumberValue("Massive Friendly Down", self.Gender)
								-- break;  -- first come first serve
							-- else
								-- if IsAHuman(actor) and actor.Head then -- if it is a human check for head
									-- local strength = SceneMan:CastStrengthSumRay(self.Pos, ToAHuman(actor).Head.Pos, 0, 128);	
									-- if strength < 500 and math.random(1, 100) < 65 then		
										-- actor:SetNumberValue("Massive Friendly Down", self.Gender)
										-- break; -- first come first serve
									-- end
								-- end
							-- end
						-- end
					-- end
				-- end
				self.Dying = true;
				if (wasHeavilyInjured) and (self.Head.WoundCount > (self.headWounds + 1)) then
					-- insta death only on big headshots
					self.deathSoundPlayed = true;
					self.dyingSoundPlayed = true;
					if (self.voiceSound) and (self.voiceSound:IsBeingPlayed()) then
						self.voiceSound:Stop(-1);
					end
					self.allowedToDie = true;
					self.voiceSounds = {};
				end
			end
		end
		if self.Head then
			self.headWounds = self.Head.WoundCount
		end
	end
	
	if (self.allowedToDie == false and self.Health <= 0) or (self.Dying == true) then
		self.Health = 1;
		self.Dying = true;
		if self.Head then
			local wounds = self.Head.WoundCount;
			self.headWounds = wounds; -- to save variable rather than pointer to WoundCount
		end
		
		-- ??? Free performance ???
		for i = 1, self.InventorySize do
			local item = self:Inventory();
			if item then
				item.ToDelete = true
			end
			self:SwapNextInventory(item, true);
		end
		if math.random(1,2) < 2 then
			self.controller:SetState(Controller.WEAPON_DROP,true);
		end
	end	
	
end

function MassiveAIBehaviours.handleSuppression(self)

	-- local blinkTimerReady = self.blinkTimer:IsPastSimMS(self.blinkDelay);
	local suppressionTimerReady = self.suppressionUpdateTimer:IsPastSimMS(1500);
	
	-- if (blinkTimerReady) and (not self.Suppressed) and self.Head then
		-- if self.Head.Frame == self.baseHeadFrame then
			-- MassiveAIBehaviours.createEmotion(self, 1, 0, 100);
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
							MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.BattleScream, 6, 4);
						self.suppressedVoicelineTimer:Reset();
						self.suppressionUpdates = 0;
					elseif self.Suppression > 55 then
						if self.Health < 100 and math.random(0, 100) < 20 then
							MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Help, 5, 4);
						elseif chance < 50 then
							MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Laugh, 4, 4);
						elseif chance < 75 then
							MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Insult, 4, 4);
						else
							MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Intimidate, 4, 4);
						end
						self.suppressedVoicelineTimer:Reset();
						self.suppressionUpdates = 0;
					end
					if self.Suppressed == false then -- initial voiceline
						if self.Suppression > 55 then
							if chance < 25 then
								MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Laugh, 4, 4);
							elseif chance < 50 then
								MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Insult, 4, 4);
							elseif chance < 75 then
								MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Intimidate, 4, 4);
							else
								MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Hold, 4, 4);
							end
						else
							MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.suppressedLight, 5, 4);
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

function MassiveAIBehaviours.handleAITargetLogic(self)
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
						MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Intro, 4, 4);
					else
						MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Intimidate, 4, 4);
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
				MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Breathing, 2, 0);
			end
		end
		if self.LastTargetID ~= -1 then
			self.LastTargetID = -1
			-- Target lost
			--print("TARGET LOST!")
		end
	end
end

function MassiveAIBehaviours.handleVoicelines(self)

	if self:NumberValueExists("Death By Fire") then
		self:RemoveNumberValue("Death By Fire");
		MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Scream, 16, 5);
	end
	
	if self:NumberValueExists("Catapulted") then
		self:RemoveNumberValue("Catapulted");
		local randomChance = math.random(0, 100);
		if randomChance > 75 then
			MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Laugh, 4, 2);
		elseif randomChance > 50 then
			MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Warcry, 6, 4);
		elseif randomChance > 25 then
			MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.BattleScream, 6, 4);
		else
			MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Intimidate, 5, 4);			
		end
	end	
	
	self:RemoveNumberValue("Warcried");
	
	if (self:IsPlayerControlled() and UInputMan:KeyPressed(24)) and self.warCryTimer:IsPastSimMS(self.warCryDelay) then
		MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.BattleScreamReverb, 9, 4);
		self.battleScreamImpact:Play(self.Pos);
		self.warCryTimer:Reset();
		
		self:SetNumberValue("Warcried", 1);
		
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
		shakenessParticle.Mass = 30;
		shakenessParticle.Lifetime = 2500;
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
		MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Insult, 3, 0);
	end
	
	if self:NumberValueExists("Blocked Mordhau") then
		self:RemoveNumberValue("Blocked Mordhau");
		self.Suppression = self.Suppression + 3;
		MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.AttackGrunt, 2, 0);
		if self:NumberValueExists("Blocked Heavy Mordhau") then
			self:RemoveNumberValue("Blocked Heavy Mordhau");
			self.Suppression = self.Suppression + 7;
			MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.AttackGrunt, 3, 0);
		end
	end

	-- DEVICE RELATED VOICELINES
	
	if (self.attackSuccess == true) and (not self.voiceSound:IsBeingPlayed() or self.attackSuccessTimer:IsPastSimMS(self.attackSuccessTime)) then
		self.attackSuccess = false;
		MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Laugh, 3, 3);
	end
	
	if (self.attackKilled == true) and (not self.voiceSound:IsBeingPlayed() or self.attackKilledTimer:IsPastSimMS(self.attackKilledTime)) then
		self.attackKilled = false;
		MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Insult, 5, 4);
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
						MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.BattleScream, 3, 3);
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
					MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.AttackGrunt, 3, 3);
					self.movementSounds.AttackLight:Play(self.Pos);
				elseif self:NumberValueExists("Medium Attack") then
					self:RemoveNumberValue("Medium Attack");
					MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.AttackGrunt, 3, 3);
					self.movementSounds.AttackMedium:Play(self.Pos);
				elseif self:NumberValueExists("Large Attack") then
					self:RemoveNumberValue("Large Attack");
					MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.AttackGrunt, 3, 3);
					self.movementSounds.AttackLarge:Play(self.Pos);
				elseif self:NumberValueExists("Extreme Attack") then
					self:RemoveNumberValue("Extreme Attack");
					MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.AttackGrunt, 3, 3);
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
				
			elseif ToHeldDevice(self.EquippedItem):NumberValueExists("Tackle Sprint Cooldown") then
				self.noSprint = true;
			else
				self.noSprint = false;
			end
			
			if self.EquippedBGItem and ToHeldDevice(self.EquippedBGItem):NumberValueExists("Tackle Sprint Cooldown") then
				self.noSprint = true;
			else
				self.noSprint = false;
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
					-- --MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.throwGrenade, 3, 4);
					-- self.throwGrenadeVoicelinePlayed = true;
				-- end
			else
				-- self.throwGrenadeVoicelinePlayed = false;
				if self.activatedExplosive then
					self.activatedExplosive = false;
					self.movementSounds.FoleyGenericHeavy:Play(self.Pos);
					MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.AttackGrunt, 3, 3);

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
			
			-- MassiveAIBehaviours.createVoiceSoundEffect(self, Sounds, 4, 4, true);		
			-- self.friendlyDownTimer:Reset();
		-- end
		-- self:RemoveNumberValue("Massive Friendly Down")
	-- end	
end

function MassiveAIBehaviours.handleDying(self)

	self.controller.Disabled = true;
	self.HUDVisible = false
	if self.allowedToDie == false then
		self.Health = 1;
		self.Status = 3;
	else
		-- if self.Head then
			-- self.Head.Frame = self.baseHeadFrame + 1; -- (+1: eyes closed. rest in peace grunt)
		-- end
		self.Health = -1;
		self.Status = 4;
	end


	if self.Head then
		--self.Head.CollidesWithTerrainWhenAttached = false
		
		if self.Head.WoundCount > self.headWounds then
			self.deathSoundPlayed = true;
			self.dyingSoundPlayed = true;
			if (self.voiceSound) and (self.voiceSound:IsBeingPlayed()) then
				self.voiceSound:Stop(-1);
			end
			self.allowedToDie = true;
		end
		if self.deathSoundPlayed ~= true then
			-- Addational Velocity
			self.Vel = self.Vel + Vector(RangeRand(-2, 2), RangeRand(-2.0, 0.5))
			self.AngularVel = self.AngularVel + RangeRand(4,12) * (math.random(0,1) * 2.0 - 1.0)
			--self.AngularVel = self.AngularVel + RangeRand(-5,5)
			
			self.deathSoundPlayed = true;
			if math.random(1, 100) < 80 then
				MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Death, 15, 5)
			else
				MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.DeathSerious, 15, 5)
			end
			-- for actor in MovableMan.Actors do
				-- if actor.Team == self.Team then
					-- local d = SceneMan:ShortestDistance(actor.Pos, self.Pos, true).Magnitude;
					-- if d < 300 then
						-- local strength = SceneMan:CastStrengthSumRay(self.Pos, actor.Pos, 0, 128);
						-- if strength < 500 and math.random(1, 100) < 65 then
							-- actor:SetNumberValue("Massive Friendly Down", self.Gender)
							-- break;  -- first come first serve
						-- else
							-- if IsAHuman(actor) and actor.Head then -- if it is a human check for head
								-- local strength = SceneMan:CastStrengthSumRay(self.Pos, ToAHuman(actor).Head.Pos, 0, 128);	
								-- if strength < 500 and math.random(1, 100) < 65 then		
									-- actor:SetNumberValue("Massive Friendly Down", self.Gender)
									-- break; -- first come first serve
								-- end
							-- end
						-- end
					-- end
				-- end
			-- end
		end
		if self.dyingSoundPlayed ~= true then
			if not (self.voiceSound) or (not self.voiceSound:IsBeingPlayed()) then
				self:NotResting();
				local attachable
				for attachable in self.Attachables do
					attachable:NotResting();
				end
				self.ToSettle = false;
				self.RestThreshold = -1;
				self.dyingSoundPlayed = true;
				if self.inCombat == true and (math.random(1, 100) < self.incapacitationChance) then
					if self.seriousDeath == true then
						MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Incap, 14, 2)
					else
						MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.incapSpoken, 14, 2)
					end
					self.incapacitated = true
				end
			end
		end
		if self.incapacitated and (self.dyingSoundPlayed and self.Vel.Magnitude < 1) then
			self.Vel = self.Vel + Vector(RangeRand(-2, 2), RangeRand(-0.5, 0.5)) * TimerMan.DeltaTimeSecs * 62.5
		end
		
		if self.voiceSound:IsBeingPlayed() then
			self:NotResting();
			local attachable
			for attachable in self.Attachables do
				attachable:NotResting();
			end
			self.ToSettle = false;
			self.RestThreshold = -1;
		elseif self.dyingSoundPlayed == true then
			self.allowedToDie = true;
		end
	end
end

function MassiveAIBehaviours.handleRagdoll(self)
	
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

function MassiveAIBehaviours.handleHeadFrames(self)
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

function MassiveAIBehaviours.DoArmSway(self, pushStrength)
	local aimAngle = self:GetAimAngle(false);
	if self.Status == Actor.STABLE and self.lastHandPos then
		--Flail around if aiming around too fast
		local angleMovement = self.lastAngle - aimAngle;
		self.AngularVel = self.AngularVel - (2 * angleMovement * self.FlipFactor)/(math.abs(self.AngularVel) * 0.1 + 1);
		--Shove when unarmed
		if self.controller:IsState(Controller.WEAPON_FIRE) and (self.FGArm or self.BGArm) and not (self.EquippedItem or self.EquippedBGItem) then
			self.AngularVel = self.AngularVel/(self.shoved and 1.3 or 3) + (aimAngle - self.RotAngle * self.FlipFactor - 1.57) * (self.shoved and 0.3 or 3) * self.FlipFactor/(1 + math.abs(self.RotAngle));
			if not self.shoved then
				MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.AttackGrunt, 3, 3);
				self.Vel = self.Vel + Vector(2/(1 + self.Vel.Magnitude), 0):RadRotate(self:GetAimAngle(true)) * math.abs(math.cos(self:GetAimAngle(true)));
				self.shoved = true;
			end
		else
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
				if self.controller:IsState(Controller.AIM_SHARP) then
					arm.IdleOffset = Vector(0, 1):RadRotate(aimAngle);
				else
					arm.IdleOffset = Vector(0, armLength * 0.7):RadRotate(rotAng * self.FlipFactor + 1.5 + (i * 0.2));
				end
				if self.shoved or (self.EquippedItem and IsTDExplosive(self.EquippedItem) and self.controller:IsState(Controller.WEAPON_FIRE)) then
					arm.IdleOffset = Vector(armLength + (pushStrength * armLength), 0):RadRotate(aimAngle);
					local handVector = SceneMan:ShortestDistance(self.lastHandPos[i], arm.HandPos, SceneMan.SceneWrapsX);
					--Diminish hand relocation vector to prevent superhuman pushing powers
					handVector:SetMagnitude(math.min(handVector.Magnitude, 1 + armLength * 0.1));
					local armStrength = (arm.Mass + arm.Material.StructuralIntegrity * 0.5) * pushStrength;

					shove.Pos = shove.Pos and shove.Pos + SceneMan:ShortestDistance(shove.Pos, arm.HandPos, SceneMan.SceneWrapsX) * 0.5 or arm.HandPos;
					shove.Power = shove.Power and shove.Power + armStrength or armStrength;
					shove.Vector = shove.Vector and shove.Vector + handVector * 0.5 or handVector * 0.5;
				end
				self.lastHandPos[i] = arm.HandPos;
			end
		end
		if shove.Pos then
			--local moCheck = SceneMan:GetMOIDPixel(shove.Pos.X + self.FlipFactor, shove.Pos.Y - 1);
			local moCheck = SceneMan:CastMORay(shove.Pos, shove.Vector, self.ID, self.Team, rte.airID, false, shove.Vector.Magnitude - 1);
			if moCheck ~= rte.NoMOID then
				local mo = MovableMan:GetMOFromID(MovableMan:GetMOFromID(moCheck).RootID);
				if mo and mo.Team ~= self.Team and IsActor(mo) then
					if self.shoveSoundsPlayed == false then
						self.shoveSoundsPlayed = true;
						self.tackleImpactGenericSound:Play(self.Pos);
						
						local material = mo.Material.PresetName
						if string.find(material,"Metal") or string.find(material,"Stuff") then
							self.tackleImpactMetalActorSound:Play(mo.Pos);
						end
					end
					if self.Mass > mo.Mass then
						ToActor(mo).Status = Actor.UNSTABLE;
						--Simulate target actor weight with an attachable
						local weight = CreateAttachable("Null Attachable");
						weight.Mass = mo.Mass;
						weight.Lifetime = 1;
						self:AddAttachable(weight);
						local shoveVel = shove.Vector/rte.PxTravelledPerFrame;
						mo.Vel = mo.Vel * 0.5 + shoveVel:SetMagnitude(math.min(shoveVel.Magnitude, math.sqrt(self.IndividualDiameter))) - SceneMan.GlobalAcc * GetMPP() * rte.PxTravelledPerFrame;
						mo.AngularVel = (aimAngle - self.lastAngle) * self.FlipFactor * math.pi;
					else
						mo:AddForce(shove.Vector * (self.Mass * 0.5) * shove.Power, Vector());
					end
				end
			end
		else
			self.shoveSoundsPlayed = false;
		end
		self.lastAngle = aimAngle;
	else
		self.lastAngle = aimAngle;
		self.lastHandPos = {self.Pos, self.Pos};
	end
end

function MassiveAIBehaviours.handleHeadLoss(self)
	if not (self.Head) then
		self.allowedToDie = true;
		self.voiceSounds = {};
		self.voiceSound:Stop(-1);
	end
end