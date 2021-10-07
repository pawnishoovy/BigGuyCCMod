
dofile("Base.rte/Constants.lua")
require("AI/NativeHumanAI")  --dofile("Base.rte/AI/NativeHumanAI.lua")
package.path = package.path .. ";Massive.rte/?.lua";
require("Actors/Infantry/Massive/MassiveAIBehaviours")

function Create(self)
	self.AI = NativeHumanAI:Create(self)
	--You can turn features on and off here
	self.armSway = true;--true;
	self.automaticEquip = false;
	self.alternativeGib = true;
	self.visibleInventory = false;
	
	-- Start modded code --
	
	self.RTE = "Massive.rte";
	self.baseRTE = "Massive.rte";
	
	-- IDENTITY AND VOICE
	
	self.IdentityPrimary = "Massive";
	self:SetStringValue("IdentityPrimary", self.IdentityPrimary);
	
	self.voiceSounds = {
	AttackGrunt = CreateSoundContainer("VO " .. self.IdentityPrimary .. " AttackGrunt", "Massive.rte"),
	BattleScream = CreateSoundContainer("VO " .. self.IdentityPrimary .. " BattleScream", "Massive.rte"),
	BattleScreamReverb = CreateSoundContainer("VO " .. self.IdentityPrimary .. " BattleScreamReverb", "Massive.rte"),
	Breathing = CreateSoundContainer("VO " .. self.IdentityPrimary .. " Breathing", "Massive.rte"),
	Death = CreateSoundContainer("VO " .. self.IdentityPrimary .. " Death", "Massive.rte"),
	DeathSerious = CreateSoundContainer("VO " .. self.IdentityPrimary .. " DeathSerious", "Massive.rte"),
	Help = CreateSoundContainer("VO " .. self.IdentityPrimary .. " Help", "Massive.rte"),
	Hold = CreateSoundContainer("VO " .. self.IdentityPrimary .. " Hold", "Massive.rte"),
	Insult = CreateSoundContainer("VO " .. self.IdentityPrimary .. " Insult", "Massive.rte"),
	Intimidate = CreateSoundContainer("VO " .. self.IdentityPrimary .. " Intimidate", "Massive.rte"),
	Intro = CreateSoundContainer("VO " .. self.IdentityPrimary .. " Intro", "Massive.rte"),
	Laugh = CreateSoundContainer("VO " .. self.IdentityPrimary .. " Laugh", "Massive.rte"),
	Pain = CreateSoundContainer("VO " .. self.IdentityPrimary .. " Pain", "Massive.rte"),
	Scream = CreateSoundContainer("VO " .. self.IdentityPrimary .. " Scream", "Massive.rte"),
	Unphased = CreateSoundContainer("VO " .. self.IdentityPrimary .. " Unphased", "Massive.rte"),
	Warcry = CreateSoundContainer("VO " .. self.IdentityPrimary .. " Warcry", "Massive.rte")
	};
	
	self.battleScreamImpact = CreateSoundContainer("BattleScreamImpact Massive", "Massive.rte");
	
	self.warCryTimer = Timer();
	self.warCryDelay = 20000;
	self.warCryOldHealth = self.Health;
	
	-- EVERYTHING ELSE
	
	self.movementSounds = {
	BassLayer = CreateSoundContainer("BassLayer Massive", "Massive.rte"),
	Land = CreateSoundContainer("FoleyLand Massive", "Massive.rte"),
	FallDamage = CreateSoundContainer("FallDamage Massive", "Massive.rte"),
	Jump = CreateSoundContainer("FoleyJump Massive", "Massive.rte"),
	Crouch = CreateSoundContainer("FoleyStandToCrouch Massive", "Massive.rte"),
	Prone = CreateSoundContainer("FoleyStandToProne Massive", "Massive.rte"),
	SprintProne = CreateSoundContainer("FoleySprintToProne Massive", "Massive.rte"),
	Stand = CreateSoundContainer("FoleyCrouchToStand Massive", "Massive.rte"),
	FoleyTerrainImpact = CreateSoundContainer("FoleyTerrainImpact Massive", "Massive.rte"),
	WalkStepLeft = CreateSoundContainer("WalkStepLeft Massive", "Massive.rte"),
	WalkStepRight = CreateSoundContainer("WalkStepRight Massive", "Massive.rte"),
	SprintStepLeft = CreateSoundContainer("SprintStepLeft Massive", "Massive.rte"),
	SprintStepRight = CreateSoundContainer("SprintStepRight Massive", "Massive.rte"),
	FoleyWalk = CreateSoundContainer("FoleyWalk Massive", "Massive.rte"),
	FoleySprint = CreateSoundContainer("FoleySprint Massive", "Massive.rte"),
	FoleyGenericLight = CreateSoundContainer("FoleyGenericLight Massive", "Massive.rte"),
	FoleyGenericHeavy = CreateSoundContainer("FoleyGenericHeavy Massive", "Massive.rte"),
	AttackLight = CreateSoundContainer("FoleyGenericHeavy Massive", "Massive.rte"),
	AttackMedium = CreateSoundContainer("FoleyGenericHeavy Massive", "Massive.rte"),
	AttackLarge = CreateSoundContainer("FoleyGenericHeavy Massive", "Massive.rte"),
	AttackExtreme = CreateSoundContainer("FoleyDeviceSwitch Massive", "Massive.rte")};

	MassiveAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Intro, 3)

	self.voiceSound = CreateSoundContainer("FoleyLand Massive", "Massive.rte");
	self.oldStepFoley = CreateSoundContainer("FoleyLand Massive", "Massive.rte");
	-- MEANINGLESS!
	
	self.altitude = 0;
	self.wasInAir = false;
	
	self.moveSoundTimer = Timer();
	self.moveSoundWalkTimer = Timer();
	self.wasCrouching = false;
	self.wasMoving = false;

	self.healthUpdateTimer = Timer();
	self.oldHealth = self.Health;
	
	self.headWounds = 0;

	self.Suppression = 0;
	self.Suppressed = false;	
	
	self.suppressionUpdateTimer = Timer();
	self.suppressedVoicelineTimer = Timer();
	self.suppressedVoicelineDelay = 8000;
	
	self.gunShotCounter = 0;
	self.suppressingVoicelineTimer = Timer();
	self.suppressingVoicelineDelay = 15000;
	
	self.attackSuccessTimer = Timer();
	self.attackSuccessTime = 2000;
	
	self.attackKilledTimer = Timer();
	self.attackKilledTime = 2000;
	
	self.emotionTimer = Timer();
	self.emotionDuration = 0;
	
	-- experimental method for enhanced dying - don't let the actor actually die until we want him to.
	-- reason for this is because when the actor IsDead he will really want to settle and there's not much we can do about it.
	self.allowedToDie = false;	
	
	-- chance upon any non-headshot death to be incapacitated for a while before really dying
	self.incapacitationChance = 0;
	
	self.spotVoiceLineTimer = Timer();
	self.spotVoiceLineDelay = 15000;
	
	 -- in pixels
	self.spotDistanceClose = 50;
	self.spotDistanceMid = 520;
	--spotDistanceFar -- anything further than distanceMid
	
	 -- in MS
	self.spotDelayMin = 4000;
	self.spotDelayMax = 8000;
	
	 -- in percent
	self.spotIgnoreDelayChance = 10;
	self.spotNoVoicelineChance = 15;
	
	-- ragdoll
	self.ragdollTerrainImpactTimer = Timer();
	self.ragdollTerrainImpactDelay = math.random(200, 500);
	
	-- extremely epic, 2000-tier combat/idle mode system
	self.inCombat = false;
	self.combatExitTimer = Timer();
	self.combatExitDelay = 10000;
	
	self.passiveSuppressionTimer = Timer();
	self.passiveSuppressionDelay = 1000;
	self.passiveSuppressionAmountLower = 5;
	self.passiveSuppressionAmountUpper = 10;

	
	-- leg Collision Detection system
	self.foot = 0;
    self.feetContact = {false, false}
    self.feetTimers = {Timer(), Timer()}
	self.footstepTime = 100 -- 2 Timers to avoid noise
	
	-- custom Jumping
	self.isJumping = false
	self.jumpStrength = -3;
	self.jumpTimer = Timer();
	self.jumpDelay = 500;
	self.jumpStop = Timer();
	
	-- Sprint

	self.accelerationFactor = 0.1;
	self.moveMultiplier = 0.8;
	self.walkMultiplier = 0.7;
	self.sprintMultiplier = 1.2;

	self.sprintPushForceDenominator = 1.2 / 0.8
	
	self.limbPathDefaultSpeed0 = self:GetLimbPathSpeed(0)
	self.limbPathDefaultSpeed1 = self:GetLimbPathSpeed(1)
	self.limbPathDefaultSpeed2 = self:GetLimbPathSpeed(2)
	self.limbPathDefaultPushForce = self.LimbPathPushForce
	
	self.lastVel = Vector(0, 0)
	
	-- End modded code
end

function OnCollideWithTerrain(self, terrainID)
	
	-- if self.impulse.Magnitude > self.ImpulseDamageThreshold then
		-- if self.impactSoundTimer:IsPastSimMS(700) then
			-- print("heavy")
			-- if self.terrainSounds.TerrainImpactHeavy[terrainID] ~= nil then
				-- self.terrainSounds.TerrainImpactHeavy[terrainID]:Play(self.Pos);
			-- else -- default to concrete
				-- self.terrainSounds.TerrainImpactHeavy[177]:Play(self.Pos);
			-- end
			-- self.impactSoundTimer:Reset();
		-- end
	-- elseif self.impulse.Magnitude > self.ImpulseDamageThreshold/5 then
		-- if self.impactSoundTimer:IsPastSimMS(700) then
			-- print("light")
			-- if self.terrainSounds.TerrainImpactLight[terrainID] ~= nil then
				-- self.terrainSounds.TerrainImpactLight[terrainID]:Play(self.Pos);
			-- else -- default to concrete
				-- self.terrainSounds.TerrainImpactLight[177]:Play(self.Pos);
			-- end
			-- self.impactSoundTimer:Reset();
		-- end
	-- end
	
	self.terrainCollided = true;
	self.terrainCollidedWith = terrainID;
end

function OnStride(self)

	local sound = self.isSprinting and self.movementSounds.FoleySprint or self.movementSounds.FoleyWalk

	if self.BGFoot and self.FGFoot then
	
		-- if math.random(0, 100) < 30 then
			-- if self.EquippedItem and IsHDFirearm(self.EquippedItem) then
				-- local gun = ToHDFirearm(self.EquippedItem)
				-- if gun:NumberValueExists("Gun Rattle Type") then
					-- if self.gunRattles[gun:GetNumberValue("Gun Rattle Type")] then
						-- self.gunRattles[gun:GetNumberValue("Gun Rattle Type")]:Play(gun.Pos);
					-- end
				-- end
			-- end	
		-- end

		local startPos = self.foot == 0 and self.BGFoot.Pos or self.FGFoot.Pos
		self.foot = (self.foot + 1) % 2
		
		local pos = Vector(0, 0);
		SceneMan:CastObstacleRay(startPos, Vector(0, 9), pos, Vector(0, 0), self.ID, self.Team, 0, 3);				
		local terrPixel = SceneMan:GetTerrMatter(pos.X, pos.Y)
		
		if terrPixel ~= 0 then -- 0 = air
			self.oldStepFoley:FadeOut(200);
			sound:Play(self.Pos);
			self.oldStepFoley = sound;
			if self.isSprinting then
				local step = self.foot == 0 and self.movementSounds.SprintStepLeft or self.movementSounds.SprintStepRight;
				step:Play(self.Pos);
			else
				local step = self.foot == 0 and self.movementSounds.WalkStepLeft or self.movementSounds.WalkStepRight;
				step:Play(self.Pos);
			end
		else
			self.movementSounds.FoleyGenericLight:Play(self.Pos);
		end
		
	elseif self.BGFoot then
	
		-- if math.random(0, 100) < 30 then
			-- if self.EquippedItem and IsHDFirearm(self.EquippedItem) then
				-- local gun = ToHDFirearm(self.EquippedItem)
				-- if gun:NumberValueExists("Gun Rattle Type") then
					-- if self.gunRattles[gun:GetNumberValue("Gun Rattle Type")] then
						-- self.gunRattles[gun:GetNumberValue("Gun Rattle Type")]:Play(gun.Pos);
					-- end
				-- end
			-- end	
		-- end
	
		local startPos = self.BGFoot.Pos
		
		local pos = Vector(0, 0);
		SceneMan:CastObstacleRay(startPos, Vector(0, 9), pos, Vector(0, 0), self.ID, self.Team, 0, 3);				
		local terrPixel = SceneMan:GetTerrMatter(pos.X, pos.Y)
		
		if terrPixel ~= 0 then -- 0 = air
			self.oldStepFoley:FadeOut(200);
			sound:Play(self.Pos);
			self.oldStepFoley = sound;
			local step = math.random(0, 50) < 50 and self.movementSounds.WalkStepLeft or self.movementSounds.WalkStepRight;
			step:Play(self.Pos);
		else
			self.movementSounds.FoleyGenericLight:Play(self.Pos);
		end
		
	elseif self.FGFoot then
	
		-- if math.random(0, 100) < 30 then
			-- if self.EquippedItem and IsHDFirearm(self.EquippedItem) then
				-- local gun = ToHDFirearm(self.EquippedItem)
				-- if gun:NumberValueExists("Gun Rattle Type") then
					-- if self.gunRattles[gun:GetNumberValue("Gun Rattle Type")] then
						-- self.gunRattles[gun:GetNumberValue("Gun Rattle Type")]:Play(gun.Pos);
					-- end
				-- end
			-- end	
		-- end
	
		local startPos = self.FGFoot.Pos
		
		local pos = Vector(0, 0);
		SceneMan:CastObstacleRay(startPos, Vector(0, 9), pos, Vector(0, 0), self.ID, self.Team, 0, 3);				
		local terrPixel = SceneMan:GetTerrMatter(pos.X, pos.Y)
		
		if terrPixel ~= 0 then -- 0 = air
			self.oldStepFoley:FadeOut(200);
			sound:Play(self.Pos);
			self.oldStepFoley = sound;
			local step = math.random(0, 50) < 50 and self.movementSounds.WalkStepLeft or self.movementSounds.WalkStepRight;
			step:Play(self.Pos);
		else
			self.movementSounds.FoleyGenericLight:Play(self.Pos);
		end
		
	end
	
end

function Update(self)

	self.controller = self:GetController();
	
	if self.alternativeGib then
		HumanFunctions.DoAlternativeGib(self);
	end
	if self.automaticEquip then
		HumanFunctions.DoAutomaticEquip(self);
	end
	if self.armSway then
		HumanFunctions.DoArmSway(self, (self.Health/self.MaxHealth));	--Argument: shove strength
	end
	if self.visibleInventory then
		HumanFunctions.DoVisibleInventory(self, false);	--Argument: whether to show all items
	end
	
	-- Start modded code--
	
	self.impulse = (self.Vel - self.lastVel) / TimerMan.DeltaTimeSecs * self.Vel.Magnitude * 0.1
	self.lastVel = Vector(self.Vel.X, self.Vel.Y)
	
	self.voiceSound.Pos = self.Pos;
	
	if (self.Dying ~= true) then
		
		MassiveAIBehaviours.handleMovement(self);
		
		MassiveAIBehaviours.handleHealth(self);
		
		MassiveAIBehaviours.handleSuppression(self);
		
		MassiveAIBehaviours.handleAITargetLogic(self);
		
		MassiveAIBehaviours.handleVoicelines(self);
		
		--MassiveAIBehaviours.handleHeadFrames(self);

	else
	
		MassiveAIBehaviours.handleDying(self);
	
		MassiveAIBehaviours.handleHeadLoss(self);
	
		MassiveAIBehaviours.handleMovement(self);
		
	end
	
	if self.Status == 1 or self.Dying then
		MassiveAIBehaviours.handleRagdoll(self)
	end

	-- clear terrain stuff after we did everything that used em
	
	self.terrainCollided = false;
	self.terrainCollidedWith = nil;

end
-- End modded code --
function UpdateAI(self)
	self.AI:Update(self)

end

function Destroy(self)
	--self.AI:Destroy(self)
	
	-- Start modded code --

	if not self.ToSettle then -- we have been gibbed
		self.voiceSound:Stop(-1);		
	end
	
	-- End modded code --
	
end
