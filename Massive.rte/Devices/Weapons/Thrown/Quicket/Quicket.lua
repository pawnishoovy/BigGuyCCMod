function Create(self)

	self.activateSound = CreateSoundContainer("Activate Quicket", "Massive.rte");
	
	self.trackingSound = CreateSoundContainer("Tracking Quicket", "Massive.rte");
	self.trackEndSound = CreateSoundContainer("Track End Quicket", "Massive.rte");
	self.staticSound = CreateSoundContainer("Static Quicket", "Massive.rte");
	
	self.activated = false;
	
	self.blipTimer = Timer();
	
	self.Timer = Timer();
	self.trackDelay = math.random(6000, 9000);
	self.gibAfterTrackDelay = 12000;
	
	self.bounceSound = CreateSoundContainer("Terrain Impact Quicket", "Massive.rte");
	
	self.lastVel = Vector(self.Vel.X, self.Vel.Y)
	self.impulse = Vector()
	self.bounceSoundTimer = Timer()		
	
end

function Update(self)

	self.impulse = (self.Vel - self.lastVel) / TimerMan.DeltaTimeSecs * self.Vel.Magnitude * 0.1
	self.lastVel = Vector(self.Vel.X, self.Vel.Y)

	if self:IsActivated() and self.activated == false then
		self.activateSound:Play(self.Pos);
		self.trackingSound:Play(self.Pos);
		self.Timer:Reset();
		self.activated = true;
		
		self.Missile = CreateAEmitter("Missile Quicket", "Massive.rte");
		self.Missile.Pos = Vector(self.Pos.X, -300);
		MovableMan:AddParticle(self.Missile);
		self.Missile:SetNumberValue("Parent Grenade ID", self.UniqueID);
		
	end
	
	if self.activated then
		
		if self.blipTimer:IsPastSimMS(60) then 
			self.blipTimer:Reset();
			self.Frame = (self.Frame + 1) % 2
			if self.Frame == 1 then
				local blipParticle = CreateMOPixel("Blip Glow Quicket", "Massive.rte");
				blipParticle.Pos = self.Pos;
				MovableMan:AddParticle(blipParticle);
			end
		end
		
		self.trackingSound.Pos = self.Pos;
		self.staticSound.Pos = self.Pos;
		self.trackEndSound.Pos = self.Pos;
		
		if self.Timer:IsPastSimMS(self.trackDelay) then
			if not self.finalSoundsPlayed then
				self.Missile:SetNumberValue("Tracked", 1);
				self.finalSoundsPlayed = true;
				self.trackEndSound:Play(self.Pos);
				self.trackingSound:FadeOut(50);
				self.staticSound:Play(self.Pos);
			end
			
			if self.Timer:IsPastSimMS(self.trackDelay + self.gibAfterTrackDelay) then
				self:GibThis();
				if MovableMan:ValidMO(self.Missile) then
					self.Missile:SetNumberValue("Abort", 1);
				end
			end
		end	
	end
	
end

function OnCollideWithTerrain(self, terrainID)
	if self.bounceSoundTimer:IsPastSimMS(50) then
		if self.impulse.Magnitude > 15 then -- Hit
			self.bounceSound:Play(self.Pos);
			self.bounceSoundTimer:Reset()
		end
	end
end

function Destroy(self)

	self.trackingSound:Stop(-1);
	self.trackEndSound:Stop(-1);
	self.staticSound:Stop(-1);

	if self.Missile and MovableMan:ValidMO(self.Missile) then
		self.Missile:SetNumberValue("Abort", 1);
	end

end