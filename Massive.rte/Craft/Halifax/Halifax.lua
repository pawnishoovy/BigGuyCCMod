
dofile("Base.rte/Constants.lua")
require("AI/NativeDropShipAI")
--dofile("Base.rte/Actors/AI/NativeDropShipAI.lua")

function Create(self)
	self.AI = NativeDropShipAI:Create(self)
	
	self.windLoopSound = CreateSoundContainer("WindLoop Halifax Massive", "Massive.rte");
	self.windLoopSound.Volume = 0;
	self.windLoopSound:Play(self.Pos);
	
	
	self.terrainImpactSlowSound = CreateSoundContainer("TerrainImpactSlow Halifax Massive", "Massive.rte");
	self.terrainImpactFastSound = CreateSoundContainer("TerrainImpactFast Halifax Massive", "Massive.rte");
	self.plummetSound = CreateSoundContainer("Plummet Halifax Massive", "Massive.rte");
	self.crashLandSound = CreateSoundContainer("Crash Halifax Massive", "Massive.rte");
	
	self.explosionTimer = Timer();
	
	self.height = ToMOSprite(self):GetSpriteHeight();
	self.width = ToMOSprite(self):GetSpriteWidth();
	
	self.explosionDelay = 5000/math.sqrt(self.width + self.height);	
	
	self.terrainImpactSoundTimer = Timer()
	
	self.plummetSoundPlayed = false;
	self.crashLandSoundPlayed = false;
	
end

function Update(self)

	local windEndPoint = Vector(0, 0);
	
	if SceneMan:CastObstacleRay(self.Pos, Vector(0, 500), windEndPoint, Vector(0, 0), self.ID, self.Team, 0, 25) >= 0 then
	
		if self.windLoopSound.Volume < 1 then
			self.windLoopSound.Volume = self.windLoopSound.Volume + 0.2 * TimerMan.DeltaTimeSecs;
			if self.windLoopSound.Volume > 1 then
				self.windLoopSound.Volume = 1;
			end
		end	
	
	else
	
		if self.windLoopSound.Volume > 0 then
			self.windLoopSound.Volume = self.windLoopSound.Volume - 0.2 * TimerMan.DeltaTimeSecs;
			if self.windLoopSound.Volume < 0 then
				self.windLoopSound.Volume = 0;
			end
		end
		
	end
	
	self.windLoopSound.Pos = windEndPoint;

	if self.TravelImpulse.Magnitude > 6000 and self.terrainImpactSoundTimer:IsPastSimMS(300) then

		if self.TravelImpulse.Magnitude > 14000 then -- Hit
			self.terrainImpactFastSound:Play(self.Pos);
			self.terrainImpactSoundTimer:Reset()
		else
			self.terrainImpactSlowSound:Play(self.Pos);
			self.terrainImpactSoundTimer:Reset()
		end
	end
	
	self.plummetSound.Pos = self.Pos;

	if self.plummetSoundPlayed == false and (not self.RightEngine and not self.LeftEngine) or (self:NumberValueExists("Engine Left Failed") and self:NumberValueExists("Engine Right Failed")) then
		self.plummetSoundPlayed = true;
		self.plummetSound:Play(self.Pos);
		self.windLoopSound:Stop(-1);
	end

	if self.Status > Actor.INACTIVE or self.AIMode == Actor.AIMODE_SCUTTLE then
		if self.explosionTimer:IsPastSimMS(self.explosionDelay) then
			self.explosionDelay = 500000
			self.explosionTimer:Reset();
			local explosion = CreateAEmitter("Halifax Scuttle Explosion");
			explosion.Pos = self.Pos + Vector(self.width * 0.5 * RangeRand(-0.9, 0.9), self.height * 0.5 * RangeRand(-0.9, 0.9)):RadRotate(self.RotAngle);
			explosion.Vel = self.Vel;
			MovableMan:AddParticle(explosion);
		end
	end
	
end

function OnCollideWithTerrain(self)

	if self.plummetSoundPlayed == true and self.crashLandSoundPlayed == false then
	
		self.crashLandSoundPlayed = true;
		self.crashLandSound:Play(self.Pos);
		
		if self.LeftEngine then self.LeftEngine:EnableEmission(false) end
		if self.RightEngine then self.RightEngine:EnableEmission(false) end
		
	end
	
end

function UpdateAI(self)
	self.AI:Update(self)
end

function Destroy(self)

	self.windLoopSound:Stop(-1);
	
end
