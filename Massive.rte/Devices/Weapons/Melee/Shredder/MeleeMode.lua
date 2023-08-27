
function OnScriptEnable(self)
	
	self.stance = Vector(15, 3)
	
end

function stringInsert(str1, str2, pos)
    return str1:sub(1,pos)..str2..str1:sub(pos+1)
end


function playAttackAnimation(self, animation)
	self.attackAnimationIsPlaying = true
	self.currentAttackStart = false;
	self.currentAttackSequence = 1
	self.currentAttackAnimation = animation
	self.attackAnimationTimer:Reset()
	self.attackAnimationCanHit = true
	self.blockedNullifier = true;
	self.Recovering = false;
	self.partiallyRecovered = false;
	self.Attacked = false;
	if self.pseudoPhase then
	
		self.usePseudoPhase = true;
		
	end
	
	self.attackBuffered = false;
	self.stabBuffered = false;
	self.overheadBuffered = false;
	
	if self.Parrying == true then
		self:SetStringValue("Parrying Type", self.attackAnimationsTypes[self.currentAttackAnimation]);
	end
	
	return
end

-- function OnAttach(self)

	-- self.Frame = 1;
	-- self.equipSound:Play(self.Pos);
	-- self.equipAnim = true;
	-- self.equipAnimationTimer:Reset();
	-- self.unequipAnim = false;
	
-- end

function OnDetach(self)

	-- self.Frame = 6;
	-- self.unequipSound:Play(self.Pos);
	-- self.unequipAnim = true;
	-- self.equipAnimationTimer:Reset();
	-- self.equipAnim = false;
	
	
end

function Create(self)

	self.meleeOriginalStanceOffset = Vector(8, 7)
	
	self.originalBaseRotation = -130;
	self.baseRotation = 0;
	
	self.attackAnimations = {}
	self.attackAnimationCanHit = false
	self.attackAnimationsSounds = {}
	self.attackAnimationsGFX = {}
	self.attackAnimationsTypes = {}
	self.attackAnimationTimer = Timer();
	
	self.currentAttackAnimation = 0;
	self.currentAttackSequence = 0;
	self.currentAttackStart = false
	self.attackAnimationIsPlaying = false
	
	--TODO FIL
	-- change "charge" to stab and "regular" to slash/strike/normal
	
	self.terrainHitSounds = {
	[12] = CreateSoundContainer("Hit Shredder", "Massive.rte"),
	[164] = CreateSoundContainer("Hit Shredder", "Massive.rte"),
	[177] = CreateSoundContainer("Hit Shredder", "Massive.rte"),
	[9] = CreateSoundContainer("Hit Shredder", "Massive.rte"),
	[10] = CreateSoundContainer("Hit Shredder", "Massive.rte"),
	[11] = CreateSoundContainer("Hit Shredder", "Massive.rte"),
	[128] = CreateSoundContainer("Hit Shredder", "Massive.rte"),
	[6] = CreateSoundContainer("Hit Shredder", "Massive.rte"),
	[8] = CreateSoundContainer("Hit Shredder", "Massive.rte"),
	[178] = CreateSoundContainer("Hit Shredder", "Massive.rte"),
	[179] = CreateSoundContainer("Hit Shredder", "Massive.rte"),
	[180] = CreateSoundContainer("Hit Shredder", "Massive.rte"),
	[181] = CreateSoundContainer("Hit Shredder", "Massive.rte"),
	[182] = CreateSoundContainer("Hit Shredder", "Massive.rte")}
	
	local attackPhase
	local regularAttackSounds = {}
	local i
	
	self.blockedSound = CreateSoundContainer("Hit Shredder", "Massive.rte");
	
	self.blockSound = CreateSoundContainer("Block Shredder", "Massive.rte");
	
	self.blockGFX = {};
	self.blockGFX.Slash = "Slash Block Effect Massive";
	self.blockGFX.Stab = "Stab Block Effect Massive";
	self.blockGFX.Heavy = "Heavy Block Effect Massive";
	self.blockGFX.Parry = "Parry Effect Massive";
	
	self.parriedCooldown = false;
	self.parriedCooldownTimer = Timer();
	self.parriedCooldownDelay = 1200;
	
	-- Save the sounds inside a table, you can always reuse it for new attacks
	--regularAttackSounds.hitDefaultSound
	--regularAttackSounds.hitDefaultSoundVariations
	
	regularAttackSounds.hitDeflectSound = CreateSoundContainer("Hit Shredder", "Massive.rte");
	
	regularAttackSounds.hitFleshSound = CreateSoundContainer("Hit Shredder", "Massive.rte");
	
	regularAttackSounds.hitMetalSound = CreateSoundContainer("Hit Shredder", "Massive.rte");
	
	local stabAttackSounds = {}
	
	-- Save the sounds inside a table, you can always reuse it for new attacks
	--stabAttackSounds.hitDefaultSound
	--stabAttackSounds.hitDefaultSoundVariations
	
	stabAttackSounds.hitDeflectSound = CreateSoundContainer("Hit Shredder", "Massive.rte");
	
	stabAttackSounds.hitFleshSound = CreateSoundContainer("Hit Shredder", "Massive.rte");
	
	stabAttackSounds.hitMetalSound = CreateSoundContainer("Hit Shredder", "Massive.rte");
	
	local regularAttackGFX = {}
	
	regularAttackGFX.hitTerrainSoftGFX = "Melee Terrain Soft Effect Massive"
	regularAttackGFX.hitTerrainHardGFX = "Melee Terrain Hard Effect Massive"
	regularAttackGFX.hitFleshGFX = "Melee Flesh Effect Massive"
	regularAttackGFX.hitMetalGFX = "Melee Terrain Hard Effect Massive"
	regularAttackGFX.hitDeflectGFX = "Melee Terrain Hard Effect Massive"
	
	
	
	
	overheadAttackPhase = {}
	overheadAttackPhase.Type = "Slash";
	
	-- Prepare
	i = 1
	overheadAttackPhase[i] = {}
	overheadAttackPhase[i].durationMS = 300
	
	overheadAttackPhase[i].canBeBlocked = false
	overheadAttackPhase[i].canDamage = false
	overheadAttackPhase[i].attackDamage = 0
	overheadAttackPhase[i].attackStunChance = 0
	overheadAttackPhase[i].attackRange = 0
	overheadAttackPhase[i].attackPush = 0
	overheadAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	overheadAttackPhase[i].frameStart = 1
	overheadAttackPhase[i].frameEnd = 1
	overheadAttackPhase[i].angleStart = -115
	overheadAttackPhase[i].angleEnd = -60
	overheadAttackPhase[i].offsetStart = Vector(0, 0)
	overheadAttackPhase[i].offsetEnd = Vector(4,-15)
	
	-- Late Prepare
	i = 2
	overheadAttackPhase[i] = {}
	overheadAttackPhase[i].durationMS = 200
	
	overheadAttackPhase[i].lastPrepare = true
	overheadAttackPhase[i].canBeBlocked = false
	overheadAttackPhase[i].canDamage = false
	overheadAttackPhase[i].attackDamage = 0
	overheadAttackPhase[i].attackStunChance = 0
	overheadAttackPhase[i].attackRange = 0
	overheadAttackPhase[i].attackPush = 0
	overheadAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	overheadAttackPhase[i].frameStart = 1
	overheadAttackPhase[i].frameEnd = 1
	overheadAttackPhase[i].angleStart = -60
	overheadAttackPhase[i].angleEnd = -55
	overheadAttackPhase[i].offsetStart = Vector(4, -15)
	overheadAttackPhase[i].offsetEnd = Vector(0, -15)
	
	overheadAttackPhase[i].soundStart = nil
	overheadAttackPhase[i].soundStartVariations = 0
	
	overheadAttackPhase[i].soundEnd = nil
	overheadAttackPhase[i].soundEndVariations = 0
	
	-- Early Attack
	i = 3
	overheadAttackPhase[i] = {}
	overheadAttackPhase[i].durationMS = 60
	
	overheadAttackPhase[i].canBeBlocked = true
	overheadAttackPhase[i].canDamage = false
	overheadAttackPhase[i].attackDamage = 8
	overheadAttackPhase[i].attackStunChance = 0.9
	overheadAttackPhase[i].attackRange = 25
	overheadAttackPhase[i].attackPush = 0.8
	overheadAttackPhase[i].attackVector = Vector(2, 6) -- local space vector relative to position and rotation
	overheadAttackPhase[i].attackAngle = -235;
	
	overheadAttackPhase[i].frameStart = 1
	overheadAttackPhase[i].frameEnd = 1
	overheadAttackPhase[i].angleStart = -55
	overheadAttackPhase[i].angleEnd = -80
	overheadAttackPhase[i].offsetStart = Vector(0, -15)
	overheadAttackPhase[i].offsetEnd = Vector(6, -10)
	
	overheadAttackPhase[i].soundStart = CreateSoundContainer("Swing Shredder", "Massive.rte");
	
	overheadAttackPhase[i].soundEnd = nil
	
	-- Attack
	i = 4
	overheadAttackPhase[i] = {}
	overheadAttackPhase[i].durationMS = 180
	
	overheadAttackPhase[i].canBeBlocked = true
	overheadAttackPhase[i].canDamage = true
	overheadAttackPhase[i].attackDamage = 8
	overheadAttackPhase[i].attackStunChance = 0.9
	overheadAttackPhase[i].attackRange = 25
	overheadAttackPhase[i].attackPush = 1.0
	overheadAttackPhase[i].attackVector = Vector(2, 6) -- local space vector relative to position and rotation
	overheadAttackPhase[i].attackAngle = -205;
	
	overheadAttackPhase[i].frameStart = 1
	overheadAttackPhase[i].frameEnd = 1
	overheadAttackPhase[i].angleStart = -80
	overheadAttackPhase[i].angleEnd = -260
	overheadAttackPhase[i].offsetStart = Vector(6, -10)
	overheadAttackPhase[i].offsetEnd = Vector(15, 9)
	
	-- Early Recover
	i = 5
	overheadAttackPhase[i] = {}
	overheadAttackPhase[i].durationMS = 90
	
	overheadAttackPhase[i].firstRecovery = true	
	overheadAttackPhase[i].canBeBlocked = false
	overheadAttackPhase[i].canDamage = false
	overheadAttackPhase[i].attackDamage = 0
	overheadAttackPhase[i].attackStunChance = 0
	overheadAttackPhase[i].attackRange = 0
	overheadAttackPhase[i].attackPush = 0
	overheadAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	overheadAttackPhase[i].frameStart = 1
	overheadAttackPhase[i].frameEnd = 1
	overheadAttackPhase[i].angleStart = -260
	overheadAttackPhase[i].angleEnd = -305
	overheadAttackPhase[i].offsetStart = Vector(15, 9)
	overheadAttackPhase[i].offsetEnd = Vector(14, 9)
	
	-- Recover
	i = 6
	overheadAttackPhase[i] = {}
	overheadAttackPhase[i].durationMS = 100
	
	overheadAttackPhase[i].canBeBlocked = false
	overheadAttackPhase[i].canDamage = false
	overheadAttackPhase[i].attackDamage = 0
	overheadAttackPhase[i].attackStunChance = 0
	overheadAttackPhase[i].attackRange = 0
	overheadAttackPhase[i].attackPush = 0
	overheadAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	overheadAttackPhase[i].frameStart = 1
	overheadAttackPhase[i].frameEnd = 1
	overheadAttackPhase[i].angleStart = -305
	overheadAttackPhase[i].angleEnd = -310
	overheadAttackPhase[i].offsetStart = Vector(14, 9)
	overheadAttackPhase[i].offsetEnd = Vector(13, 9)
	
	-- Recover
	i = 7
	overheadAttackPhase[i] = {}
	overheadAttackPhase[i].durationMS = 400
	
	overheadAttackPhase[i].canBeBlocked = false
	overheadAttackPhase[i].canDamage = false
	overheadAttackPhase[i].attackDamage = 0
	overheadAttackPhase[i].attackStunChance = 0
	overheadAttackPhase[i].attackRange = 0
	overheadAttackPhase[i].attackPush = 0
	overheadAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	overheadAttackPhase[i].frameStart = 1
	overheadAttackPhase[i].frameEnd = 1
	overheadAttackPhase[i].angleStart = -345
	overheadAttackPhase[i].angleEnd = -160
	overheadAttackPhase[i].offsetStart = Vector(13, 9)
	overheadAttackPhase[i].offsetEnd = Vector(7, -2)
	
	-- Recover
	i = 8
	overheadAttackPhase[i] = {}
	overheadAttackPhase[i].durationMS = 200
	
	overheadAttackPhase[i].canBeBlocked = false
	overheadAttackPhase[i].canDamage = false
	overheadAttackPhase[i].attackDamage = 0
	overheadAttackPhase[i].attackStunChance = 0
	overheadAttackPhase[i].attackRange = 0
	overheadAttackPhase[i].attackPush = 0
	overheadAttackPhase[i].attackVector = Vector(4, 10) -- local space vector relative to position and rotation
	
	overheadAttackPhase[i].frameStart = 1
	overheadAttackPhase[i].frameEnd = 1
	overheadAttackPhase[i].angleStart = -160
	overheadAttackPhase[i].angleEnd = -135
	overheadAttackPhase[i].offsetStart = Vector(7, -2)
	overheadAttackPhase[i].offsetEnd = Vector(1, 0)
	
	-- Add the animation to the animation table
	self.attackAnimationsSounds[3] = regularAttackSounds
	self.attackAnimationsGFX[3] = regularAttackGFX
	self.attackAnimations[3] = overheadAttackPhase
	self.attackAnimationsTypes[3] = overheadAttackPhase.Type
	
	self.rotation = 0
	self.rotationInterpolation = 1 -- 0 instant, 1 smooth, 2 wiggly smooth
	self.rotationInterpolationSpeed = 25
	
	self.stance = Vector(0, 0)
	self.stanceInterpolation = 0 -- 0 instant, 1 smooth
	self.stanceInterpolationSpeed = 25
	
	self:DisableScript("Massive.rte/Devices/Weapons/Melee/Shredder/MeleeMode.lua");	
	
end

function Update(self)

	local act = self:GetRootParent();
	local actor = IsAHuman(act) and ToAHuman(act) or nil;
	local player = false
	local controller = nil
	if actor then
		--ToActor(actor):GetController():SetState(Controller.WEAPON_RELOAD,false);
		controller = actor:GetController();
		controller:SetState(Controller.AIM_SHARP,false);
		self.parent = actor;
		if actor:IsPlayerControlled() then
			player = true
		end
	end
	
	if controller then --          :-)
	
		if self:NumberValueExists("Switch Mode") then
		
			self:RemoveNumberValue("Weapons - Mordhau Melee");
		
			self.StanceOffset = Vector(8, 8);
			self.SharpStanceOffset = Vector(8, 8);
			self.SharpLength = 0;
			self.JointOffset = Vector(-2, 3);
			self.SupportOffset = Vector(7, -14);
		
			self:RemoveNumberValue("Switch Mode");
			self.meleeMode = false;
			self.rotation = 0
			self.rotationTarget = 0;
			
			self:DisableScript("Massive.rte/Devices/Weapons/Melee/Shredder/MeleeMode.lua");
			self:EnableScript("Massive.rte/Devices/Weapons/Melee/Shredder/Shredder.lua");
			
			return
			
		end
	
		-- INPUT
		local attack
		local activated
		if self.parriedCooldown == false then
			if player then
				attack = controller:IsState(Controller.PRESS_PRIMARY);
				if self:IsActivated() and self.attackCooldown == true then
					self:Deactivate();
				else
					self.attackCooldown = false;
				end
			else
				-- stab = (math.random(0, 100) < 50) and true;
				-- overhead = true;
				-- if stab or overhead or flourish or throw or warcry then
					-- controller:SetState(Controller.PRESS_PRIMARY, true)
					-- self:Activate();
				-- end
			end
			activated = self:IsActivated();
		elseif self.parriedCooldownTimer:IsPastSimMS(self.parriedCooldownDelay) then
			self.parriedCooldown = false;
		end
		local attacked = false
		
		-- if player then -- PLAYER INPUT
			-- charge = (self:IsActivated() and not self.isCharged) or (self.isCharging and not self.isCharged)
		-- else -- AI
		attacked = activated and not self.attackAnimationIsPlaying
		-- end
		
		-- replace with your own code if you wish
		-- default "regular attack and charged attack behaviour"
		
		-- if charge and not self.attackAnimationIsPlaying then
			-- if not self.startedCharging then
				-- self.startedCharging = true
			-- end
			-- if not self.isCharging and self.chargeStartTimer:IsPastSimMS(self.chargeStartTime) then
				-- self.isCharging = true
				-- if self.chargeSound then
					-- self.chargeSound:Play(self.Pos);
				-- end
			-- end
			
			-- if self.isCharging then
				-- if self.chargeTimer:IsPastSimMS(self.chargeTime) then
					-- if not self.isCharged then
						-- self.isCharged = true
					-- end
				-- end
			-- end
		-- else
			-- self.chargeStartTimer:Reset()
			-- self.chargeTimer:Reset()
			-- if self.isCharging or self.startedCharging then
				-- self.isCharging = false
				-- self.startedCharging = false
				-- if self.chargeEndSound then
					-- self.chargeEndSound:Play(self.Pos);
				-- end
				-- attacked = true
			-- end
		-- end
		
		-- INPUT TO OUTPUT
		
		-- replace with your own code if you wish
		-- default "regular attack and charged attack behaviour"
		if attacked then
		
			self.chargeDecided = false;
		
		
			if self.Blocking == true then
				
				self.Parrying = true;
			
				self.Blocking = false;
				self:RemoveNumberValue("Blocking");
				
				stanceTarget = Vector(0, 0);
				
				self.originalBaseRotation = -130;
				self.baseRotation = -145;
				
			end
			
			playAttackAnimation(self, 3) -- regular attack
			
			-- if self.isCharged then
				-- self.isCharged = false
				-- self.wasCharged = true;
				-- playAttackAnimation(self, 2) -- charged attack
				-- self.parent:SetNumberValue("Medium Attack", 1); --here for extra movement sounds on parent knight
			-- else
				--playAttackAnimation(self, 1) -- regular attack
			-- end
		end
		
		self:RemoveNumberValue("Warcried");
		
		-- ANIMATION PLAYER
		local stanceTarget = Vector(0, 0)
		local rotationTarget = 0
		
		local canBeBlocked = false
		local canDamage = false
		local damageVector = Vector(0,0)
		local damageRange = 1
		local damageStun = 0
		local damagePush = 1
		local damage = 0
	
		if self.attackAnimationIsPlaying and currentAttackAnimation ~= 0 then -- play the animation
		
			self.rotationInterpolationSpeed = 25;
		
			local animation = self.currentAttackAnimation
			local attackPhases = self.attackAnimations[animation]
			local currentPhase = attackPhases[self.currentAttackSequence]
			if self.pseudoPhase then
				currentPhase = self.pseudoPhase;
			end
			local nextPhase = attackPhases[self.currentAttackSequence + 1]
			
			if self.chargeDecided == false and nextPhase and nextPhase.canBeBlocked == true and currentPhase.canBeBlocked == false then
				self.chargeDecided = true;
				if activated then
					self.attackCooldown = true;
					self.wasCharged = true;
					self.parent:SetNumberValue("Large Attack", 1);
				else
					self.wasCharged = false;
					self.parent:SetNumberValue("Medium Attack", 1);	
				end
			elseif currentPhase.firstRecovery == true then
				self.Recovering = true;
			elseif self.chargeDecided == false then
				-- block cancelling
				if player then
					local keyPress = UInputMan:KeyPressed(MassiveSettings.MeleeBlockHotkey);
					if keyPress then
						self.Throwing = false;
						self.wasCharged = false;
						self.currentAttackAnimation = 0
						self.currentAttackSequence = 0
						self.attackAnimationIsPlaying = false			
						self.parent:SetNumberValue("Block Foley", 1);
					
						self.Blocking = true;
						
						self:SetNumberValue("Blocking", 1);
						
						stanceTarget = Vector(4, -3);
						
						self.originalBaseRotation = -125;
						self.baseRotation = -120;
					end
				end
			end
			
			local factor = self.attackAnimationTimer.ElapsedSimTimeMS / currentPhase.durationMS
			if factor > 1 then
				factor = 1;
			end
			
			if not self.currentAttackStart then -- Start of the sequence
				self.currentAttackStart = true
				if currentPhase.soundStart then
					currentPhase.soundStart.Pitch = self.wasCharged and 0.9 or 1.0;
					currentPhase.soundStart:Play(self.Pos);
				end
			end
			
			local heavyAttackFactor = (self.wasCharged and currentPhase.lastPrepare == true) and (currentPhase.durationMS * 2) or 0;
			local workingDuration = currentPhase.durationMS + heavyAttackFactor;
			
			canBeBlocked = currentPhase.canBeBlocked or false
			canDamage = currentPhase.canDamage or false
			if self.blockedNullifier == false then
				canDamage = false;
				canBeBlocked = false;
			end
			if canDamage == true then
				self.Attacked = true;
			end
			damage = currentPhase.attackDamage or 0
			damageVector = currentPhase.attackVector or Vector(0,0)
			damageAngle = currentPhase.attackAngle or 0
			damageRange = currentPhase.attackRange or 0
			damageStun = currentPhase.attackStunChance or 0
			damagePush = currentPhase.attackPush or 0
			
			if self.wasCharged == true then
				damage = damage * 1.3;
				damageStun = damageStun * 1.3;
				damagePush = damagePush * 1.3;
			end
				
			
			rotationTarget = rotationTarget + (currentPhase.angleStart * (1 - factor) + currentPhase.angleEnd * factor) / 180 * math.pi -- interpolate rotation
			stanceTarget = stanceTarget + (currentPhase.offsetStart * (1 - factor) + currentPhase.offsetEnd * factor) -- interpolate stance offset
			local frameChange = currentPhase.frameEnd - currentPhase.frameStart
			self.Frame = math.floor(currentPhase.frameStart + math.floor(frameChange * factor, 0.55))
			
			if (self.Attacked == true and attack) and not self.attackBuffered then
				self.attackBuffered = true;
				self.attackAnimationBuffered = 3;
				
			end	

			if self.partiallyRecovered == true and (self.attackBuffered or self.stabBuffered or self.overheadBuffered) then
			
				self.chargeDecided = false;
				playAttackAnimation(self, self.attackAnimationBuffered)
				
				self.attackBuffered = false;
			
				-- construct pseudo phase to get us from where we are now through the first phase of the buffered attack, if we buffered one
				-- doesn't THAT sound scientific
				
				local attackPhases = self.attackAnimations[self.attackAnimationBuffered]
				local currentPhase = attackPhases[1]
				
				self.pseudoPhase = {}
				self.pseudoPhase.durationMS = (currentPhase.durationMS * 1.8) or 0
				
				self.pseudoPhase.canBeBlocked = currentPhase.canBeBlocked or false
				self.pseudoPhase.canDamage = currentPhase.canDamage or false
				self.pseudoPhase.attackDamage = currentPhase.attackDamage or 0
				self.pseudoPhase.attackStunChance = currentPhase.attackStunChance or 0
				self.pseudoPhase.attackRange = currentPhase.attackRange or 0
				self.pseudoPhase.attackPush = currentPhase.attackPush or 0
				self.pseudoPhase.attackVector = currentPhase.attackVector or Vector(0, 0)
				self.pseudoPhase.attackAngle = currentPhase.attackAngle or 0
				
				self.pseudoPhase.frameStart = self.Frame
				self.pseudoPhase.frameEnd = currentPhase.frameEnd or 6
				self.pseudoPhase.angleStart = (self.rotation * self.FlipFactor) * (180/math.pi)
				self.pseudoPhase.angleEnd = currentPhase.angleEnd or 0
				self.pseudoPhase.offsetStart = self.stance
				self.pseudoPhase.offsetEnd = currentPhase.offsetEnd or Vector(0, 0)
				
				self.pseudoPhase.soundStart = currentPhase.soundStart or nil
				
				self.pseudoPhase.soundEnd = currentPhase.soundEnd or nil
					
				
			end			
			
			-- DEBUG
			-- PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(-20, 40), "animation = "..animation, true, 0);
			-- PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(-20, 20), "sequence = "..self.currentAttackSequence, true, 0);
			-- PrimitiveMan:DrawTextPrimitive(self.Pos + Vector(-20, 30), "factor = "..math.floor(factor * 100).."/100", true, 0);
			if self.attackAnimationTimer:IsPastSimMS(workingDuration) then
				if (self.currentAttackSequence+1) <= #attackPhases then
					self.currentAttackSequence = self.currentAttackSequence + 1
				else
					if not self.attackBuffered == true then
						self.attackCooldown = true;
					end
					self.wasCharged = false;
					self.currentAttackAnimation = 0
					self.currentAttackSequence = 0
					self.attackAnimationIsPlaying = false
				end
				
				if currentPhase.soundEnd then
					currentPhase.soundEnd:Play(self.Pos);
				end
				
				self:RemoveStringValue("Parrying Type");
				self.Parrying = false;
				
				self.pseudoPhase = nil;
				
				if self.Recovering == true then
					self.partiallyRecovered = true;
				end
				
				self.currentAttackStart = false
				self.attackAnimationTimer:Reset()
				self.attackAnimationCanHit = true
				canDamage = false
			end
			
			if self:NumberValueExists("Mordhau Flinched") or self.parent:NumberValueExists("Mordhau Flinched") then
				self:RemoveNumberValue("Mordhau Flinched")
				self.parent:RemoveNumberValue("Mordhau Flinched");
				-- nahhhh mate
				-- self.attackCooldown = true;
				-- self.wasCharged = false;
				-- self.currentAttackAnimation = 0
				-- self.currentAttackSequence = 0
				-- self.attackAnimationIsPlaying = false
				-- self.Parrying = false;
				-- self:RemoveStringValue("Parrying Type");
			end
			
		else -- default behaviour, modify it if you wish
			if self:NumberValueExists("Mordhau Flinched") or self.parent:NumberValueExists("Mordhau Flinched") then
				self:RemoveNumberValue("Mordhau Flinched")
				self.parent:RemoveNumberValue("Mordhau Flinched");
			end		
			if self.baseRotation < self.originalBaseRotation then
				self.baseRotation = self.baseRotation + 1;
			elseif self.baseRotation > self.originalBaseRotation then
				self.baseRotation = self.baseRotation + -1;
			end
			
			rotationTarget = self.baseRotation / 180 * math.pi;
			
			if player then
				local keyPress = UInputMan:KeyPressed(MassiveSettings.MeleeBlockHotkey) or (UInputMan:KeyHeld(MassiveSettings.MeleeBlockHotkey) and self.Blocking == false);
				if keyPress and not (self.attackAnimationIsPlaying) then
				
					self.parent:SetNumberValue("Block Foley", 1);
				
					self.Blocking = true;
					
					self:SetNumberValue("Blocking", 1);
					
					stanceTarget = Vector(4, -3);
					
					self.originalBaseRotation = -145;
					self.baseRotation = -120;
				
				elseif self.Blocking == true and UInputMan:KeyHeld(MassiveSettings.MeleeBlockHotkey) and not (self.attackAnimationIsPlaying) then
				
					self.originalBaseRotation = -145;
				
					stanceTarget = Vector(4, -3);
				
				elseif UInputMan:KeyReleased(18) then
				
					self.parent:SetNumberValue("Block Foley", 1);
				
					self.Blocking = false;
					
					self:RemoveNumberValue("Blocking");
					
					self.originalBaseRotation = -130;
					self.baseRotation = -130;
				
				else
					
					self.Blocking = false;
					
					self:RemoveNumberValue("Blocking");
					
					self.originalBaseRotation = -145;
					self.baseRotation = -130;
					
				end
			elseif not self.attackAnimationIsPlaying then
			
				self.Blocking = true;
				
				self:SetNumberValue("Blocking", 1);
				
				stanceTarget = Vector(4, -3);
				
				self.originalBaseRotation = -145;
				self.baseRotation = -135;
				
			end
				
			
			if self:IsAttached() then
				self.Frame = 6;
			else
				self.Frame = 1;
			end
		end
		
		if self.Blocking == true or self.Parrying == true then
			
			if self:StringValueExists("Blocked Type") then
			
				if self.parent then
					self.parent:SetNumberValue("Blocked Mordhau", 1);
				end
			
				self.rotationInterpolationSpeed = 50;
				self.baseRotation = self.baseRotation - (math.random(1, 2) * -1)
				
				self.blockSound:Play(self.Pos);
				self:RemoveStringValue("Blocked Type");
				if self:NumberValueExists("Blocked Heavy") then
				
					if self.parent then
						self.parent:SetNumberValue("Blocked Heavy Mordhau", 1);
					end				
				
					self:RemoveNumberValue("Blocked Heavy");
					self.baseRotation = self.baseRotation - (math.random(2, 3) * -1)
				end
				
				if self.Parrying == true then
					self.parrySound:Play(self.Pos);
				end
				
			end
		end
		
		if self.stanceInterpolation == 0 then
			self.stance = stanceTarget
		elseif self.stanceInterpolation == 1 then
			self.stance = (self.stance + stanceTarget * TimerMan.DeltaTimeSecs * self.stanceInterpolationSpeed) / (1 + TimerMan.DeltaTimeSecs * self.stanceInterpolationSpeed);
		end
		
		rotationTarget = rotationTarget * self.FlipFactor
		if self.rotationInterpolation == 0 then
			self.rotation = rotationTarget
		elseif self.rotationInterpolation == 1 then
			self.rotation = (self.rotation + rotationTarget * TimerMan.DeltaTimeSecs * self.rotationInterpolationSpeed) / (1 + TimerMan.DeltaTimeSecs * self.rotationInterpolationSpeed);
		end
		local pushVector = Vector(10 * self.FlipFactor, 0):RadRotate(self.RotAngle)
		
		self.StanceOffset = self.meleeOriginalStanceOffset + self.stance
		--self.InheritedRotAngleOffset = self.rotation
		self.RotAngle = self.RotAngle + self.rotation
		
		local jointOffset = Vector(self.JointOffset.X * self.FlipFactor, self.JointOffset.Y):RadRotate(self.RotAngle);
		self.Pos = self.Pos - jointOffset + Vector(jointOffset.X, jointOffset.Y):RadRotate(-self.rotation);
		
		-- COLLISION DETECTION
		
		--self.attackAnimationsSounds[1]
		if canBeBlocked and self.attackAnimationCanHit then -- Detect collision
			--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + attackOffset,  13);
			local hit = false
			local hitType = 0
			local team = 0
			if actor then team = actor.Team end
			local rayVec = Vector(damageRange * self.FlipFactor, 0):RadRotate(self.RotAngle):DegRotate(damageAngle*self.FlipFactor)--damageVector:RadRotate(self.RotAngle) * Vector(self.FlipFactor, 1)
			local rayOrigin = Vector(self.Pos.X, self.Pos.Y) + Vector(damageVector.X * self.FlipFactor, damageVector.Y):RadRotate(self.RotAngle)
			
			--PrimitiveMan:DrawLinePrimitive(rayOrigin, rayOrigin + rayVec,  5);
			--PrimitiveMan:DrawCirclePrimitive(self.Pos, 3, 5);
			
			local moCheck = SceneMan:CastMORay(rayOrigin, rayVec, self.ID, self.Team, 0, false, 2); -- Raycast
			if moCheck and moCheck ~= rte.NoMOID then
				local rayHitPos = SceneMan:GetLastRayHitPos()
				local MO = MovableMan:GetMOFromID(moCheck)
				if (IsMOSRotating(MO) and canDamage) and not ((MO:IsInGroup("Weapons - Mordhau Melee") or ToMOSRotating(MO):NumberValueExists("Weapons - Mordhau Melee"))
				or (MO:IsInGroup("Mordhau Counter Shields") and (ToMOSRotating(MO):StringValueExists("Parrying Type")
				and ToMOSRotating(MO):GetStringValue("Parrying Type") == self.attackAnimationsTypes[self.currentAttackAnimation]))) then
					hit = true
					MO = ToMOSRotating(MO)
					MO.Vel = MO.Vel + (self.Vel + pushVector) / MO.Mass * 15 * (damagePush)
					local crit = RangeRand(0, 1) < damageStun
					local woundName = MO:GetEntryWoundPresetName()
					local woundNameExit = MO:GetExitWoundPresetName()
					local woundOffset = (rayHitPos - MO.Pos):RadRotate(MO.RotAngle * -1.0)
					
					local material = MO.Material.PresetName
					--if crit then
					--	woundName = woundNameExit
					--end
					
					if string.find(material,"Flesh") or string.find(woundName,"Flesh") or string.find(woundNameExit,"Flesh") or string.find(material,"Bone") or string.find(woundName,"Bone") or string.find(woundNameExit,"Bone") then
						hitType = 1
					else
						hitType = 2
					end
					if string.find(material,"Flesh") or string.find(woundName,"Flesh") or string.find(woundNameExit,"Flesh") then
						if self.attackAnimationsGFX[self.currentAttackAnimation].hitFleshGFX then
							local effect = CreateMOSRotating(self.attackAnimationsGFX[self.currentAttackAnimation].hitFleshGFX);
							if effect then
								effect.Pos = rayHitPos - rayVec:SetMagnitude(3)
								MovableMan:AddParticle(effect);
								effect:GibThis();
							end
						end
					elseif string.find(material,"Metal") or string.find(woundName,"Metal") or string.find(woundNameExit,"Metal") or string.find(material,"Stuff") or string.find(woundName,"Dent") or string.find(woundNameExit,"Dent") then
						if self.attackAnimationsGFX[self.currentAttackAnimation].hitMetalGFX then
							local effect = CreateMOSRotating(self.attackAnimationsGFX[self.currentAttackAnimation].hitMetalGFX);
							if effect then
								effect.Pos = rayHitPos - rayVec:SetMagnitude(3)
								MovableMan:AddParticle(effect);
								effect:GibThis();
							end
						end
					end
					
					if MO:IsDevice() and math.random(1,3) >= 2 then
						if self.attackAnimationsGFX[self.currentAttackAnimation].hitDeflectGFX then
							local effect = CreateMOSRotating(self.attackAnimationsGFX[self.currentAttackAnimation].hitDeflectGFX);
							if effect then
								effect.Pos = rayHitPos - rayVec:SetMagnitude(3)
								MovableMan:AddParticle(effect);
								effect:GibThis();
							end
						end
						
						crit = true
					end
					
					if MO:IsInGroup("Shields") then
						self.blockedSound:Play(self.Pos);
					end
					
					local woundsToAdd = math.floor((damage) + RangeRand(0,0.9))
					
					-- Hurt the actor, add extra damage
					local actorHit = MovableMan:GetMOFromID(MO.RootID)
					if (actorHit and IsActor(actorHit)) then-- and (MO.RootID == moCheck or (not IsAttachable(MO) or string.find(MO.PresetName,"Arm") or string.find(MO,"Leg") or string.find(MO,"Head"))) then -- Apply addational damage
					
						actorHit = ToActor(actorHit)
						actorHit.Vel = actorHit.Vel + (self.Vel + pushVector) / actorHit.Mass * ((50 + self.Mass) * (actorHit.Mass / 100)) * (damagePush) * 0.8
						
						--print(actorHit.Material.StructuralIntegrity)
						--actor.Health = actor.Health - 8 * damageMulti;
						
						local addWounds = true;
						
						if (actorHit.Health - (damage * 10)) < 0 then -- bad estimation, but...
							if math.random(0, 100) < 15 then
								self.parent:SetNumberValue("Attack Killed", 1); -- celebration!!
							end
						end
						
						if addWounds == true and woundName then
							MO:SetNumberValue("Mordhau Flinched", 1);
							--local flincher = CreateAttachable("Mordhau Flincher", "Mordhau.rte")
							--MO:AddAttachable(flincher)
							for i = 1, woundsToAdd do
								MO:AddWound(CreateAEmitter(woundName), woundOffset, true)
							end
						end
						
						if self.wasCharged then
							if crit then
								actorHit:GetController():SetState(Controller.BODY_CROUCH,true);
								actorHit:GetController():SetState(Controller.WEAPON_CHANGE_NEXT,false);
								actorHit:GetController():SetState(Controller.WEAPON_CHANGE_PREV,false);
								actorHit:GetController():SetState(Controller.WEAPON_FIRE,false);
								actorHit:GetController():SetState(Controller.AIM_SHARP,false);
								actorHit:GetController():SetState(Controller.WEAPON_PICKUP,false);
								actorHit:GetController():SetState(Controller.WEAPON_DROP,false);
								actorHit:GetController():SetState(Controller.BODY_JUMP,false);
								actorHit:GetController():SetState(Controller.BODY_JUMPSTART,false);
								actorHit:GetController():SetState(Controller.MOVE_LEFT,false);
								actorHit:GetController():SetState(Controller.MOVE_RIGHT,false);
								actorHit:FlashWhite(150);
								if math.random(0, 100) < 30 then
									self.parent:SetNumberValue("Attack Success", 1); -- celebration!!
								end
							end
						else
							if crit then
								actorHit:GetController():SetState(Controller.BODY_CROUCH,true);
								actorHit:GetController():SetState(Controller.WEAPON_CHANGE_NEXT,false);
								actorHit:GetController():SetState(Controller.WEAPON_CHANGE_PREV,false);
								actorHit:GetController():SetState(Controller.WEAPON_FIRE,false);
								actorHit:GetController():SetState(Controller.AIM_SHARP,false);
								actorHit:GetController():SetState(Controller.WEAPON_PICKUP,false);
								actorHit:GetController():SetState(Controller.WEAPON_DROP,false);
								actorHit:GetController():SetState(Controller.BODY_JUMP,false);
								actorHit:GetController():SetState(Controller.BODY_JUMPSTART,false);
								actorHit:GetController():SetState(Controller.MOVE_LEFT,false);
								actorHit:GetController():SetState(Controller.MOVE_RIGHT,false);
								actorHit:FlashWhite(50);
							end
						end
					elseif woundName then -- generic wound adding for non-actors
						for i = 1, woundsToAdd do
							MO:AddWound(CreateAEmitter(woundName), woundOffset, true)
						end
					end
				elseif (MO:IsInGroup("Weapons - Mordhau Melee") or ToMOSRotating(MO):NumberValueExists("Weapons - Mordhau Melee")) or MO:IsInGroup("Mordhau Counter Shields") then
					hit = true;
					MO = ToHeldDevice(MO);
					if MO:NumberValueExists("Blocking") or (MO:StringValueExists("Parrying Type")
					and (MO:GetStringValue("Parrying Type") == self.attackAnimationsTypes[self.currentAttackAnimation] or MO:GetStringValue("Parrying Type") == "Flourish")) then
						self.attackCooldown = true;
						if MO:StringValueExists("Parrying Type") then
							self.attackBuffered = false;
							self.stabBuffered = false;
							self.overheadBuffered = false;
							self.parriedCooldown = true;
							self.parriedCooldownTimer:Reset();
							local effect = CreateMOSRotating(self.blockGFX.Parry, "Mordhau.rte");
							if effect then
								effect.Pos = rayHitPos - rayVec:SetMagnitude(3)
								MovableMan:AddParticle(effect);
								effect:GibThis();
							end
						end
						self.blockedNullifier = false;
						self.attackAnimationCanHit = false;
						self.blockedSound:Play(self.Pos);
						MO:SetStringValue("Blocked Type", self.attackAnimationsTypes[self.currentAttackAnimation]);
						local effect = CreateMOSRotating(self.blockGFX[self.attackAnimationsTypes[self.currentAttackAnimation]], "Mordhau.rte");
						if effect then
							effect.Pos = rayHitPos - rayVec:SetMagnitude(3)
							MovableMan:AddParticle(effect);
							effect:GibThis();
						end
						if self.wasCharged then
							local effect = CreateMOSRotating(self.blockGFX.Heavy, "Massive.rte");
							if effect then
								effect.Pos = rayHitPos - rayVec:SetMagnitude(3)
								MovableMan:AddParticle(effect);
								effect:GibThis();
							end
							MO:SetNumberValue("Blocked Heavy", 1);
						end
						
					else
						hit = false; -- keep going and looking
					end
				end
			elseif canDamage then
				local terrCheck = SceneMan:CastMaxStrengthRay(rayOrigin, rayOrigin + rayVec, 2); -- Raycast
				if terrCheck > 5 then
					local rayHitPos = SceneMan:GetLastRayHitPos()
					hit = true
					self.attack = false
					self.charged = false
					
					local terrPixel = SceneMan:GetTerrMatter(rayHitPos.X, rayHitPos.Y)
			
					if terrPixel ~= 0 then -- 0 = air
						if self.terrainHitSounds[terrPixel] ~= nil then
							self.terrainHitSounds[terrPixel]:Play(self.Pos);
						else -- default to concrete
							self.terrainHitSounds[177]:Play(self.Pos);
						end
					end
					
					if terrCheck >= 100 then
						if self.attackAnimationsGFX[self.currentAttackAnimation].hitTerrainHardGFX then
							local effect = CreateMOSRotating(self.attackAnimationsGFX[self.currentAttackAnimation].hitTerrainHardGFX);
							if effect then
								effect.Pos = rayHitPos - rayVec:SetMagnitude(3)
								MovableMan:AddParticle(effect);
								effect:GibThis();
							end
						end
						
						hitType = 4 -- Hard
					else
						if self.attackAnimationsGFX[self.currentAttackAnimation].hitTerrainSoftGFX then
							local effect = CreateMOSRotating(self.attackAnimationsGFX[self.currentAttackAnimation].hitTerrainHardGFX);
							if effect then
								effect.Pos = rayHitPos - rayVec:SetMagnitude(3)
								MovableMan:AddParticle(effect);
								effect:GibThis();
							end
						end
						
						hitType = 3 -- Soft
					end
				end
			end
			
			if hit then
				if hitType == 0 then -- Default
					if self.attackAnimationsSounds[self.currentAttackAnimation].hitDefaultSound then
						self.attackAnimationsSounds[self.currentAttackAnimation].hitDefaultSound:Play(self.Pos);
					end
				elseif hitType == 1 then -- Flesh
					if self.attackAnimationsSounds[self.currentAttackAnimation].hitFleshSound then
						self.attackAnimationsSounds[self.currentAttackAnimation].hitFleshSound:Play(self.Pos);
					end
				elseif hitType == 2 then -- Metal
					if self.attackAnimationsSounds[self.currentAttackAnimation].hitMetalSound then
						self.attackAnimationsSounds[self.currentAttackAnimation].hitMetalSound:Play(self.Pos);
					end
				end
				self.attackAnimationCanHit = false
			end
		end
	end
end