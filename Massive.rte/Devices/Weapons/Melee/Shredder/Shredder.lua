function Create(self)

	self.parentSet = false;

	self.keyPressTimer = Timer();
	self.sustainDelay = 5000;
	self.sustainOffDelay = 250
	self.sustainTimer = Timer();
	
	self.cSharpMuted = CreateSoundContainer("C Sharp Muted Shredder", "Massive.rte");
	self.dMuted = CreateSoundContainer("D Muted Shredder", "Massive.rte");
	self.eMuted = CreateSoundContainer("E Muted Shredder", "Massive.rte");
	self.fMuted = CreateSoundContainer("F Muted Shredder", "Massive.rte");
	
	self.cSharpSustain = CreateSoundContainer("C Sharp Sustain Shredder", "Massive.rte");
	self.dSustain = CreateSoundContainer("D Sustain Shredder", "Massive.rte");
	self.dSharpSustain = CreateSoundContainer("D Sharp Sustain Shredder", "Massive.rte");
	self.eSustain = CreateSoundContainer("E Sustain Shredder", "Massive.rte");
	self.fSustain = CreateSoundContainer("F Sustain Shredder", "Massive.rte");
	
	self.cSharp1Sustain = CreateSoundContainer("C1 Sharp Sustain Shredder", "Massive.rte");
	self.d1Sustain = CreateSoundContainer("D1 Sustain Shredder", "Massive.rte");
	self.dSharp1Sustain = CreateSoundContainer("D1 Sharp Sustain Shredder", "Massive.rte");
	self.e1Sustain = CreateSoundContainer("E1 Sustain Shredder", "Massive.rte");
	
	self.release = CreateSoundContainer("Release Shredder", "Massive.rte");
	self.release.Volume = 0.2
	self.fx = CreateSoundContainer("FX Shredder", "Massive.rte");

end

function Update(self)
	
	if UInputMan:KeyPressed(Key.P) then
		if self.alternate ~= true then
			self.alternate = true;
		else
			self.alternate = false;
		end
	
	end

	self.cSharpMuted.Pos = self.Pos;
	self.dMuted.Pos = self.Pos;
	self.eMuted.Pos = self.Pos;
	self.fMuted.Pos = self.Pos;

	self.cSharpSustain.Pos = self.Pos;
	self.dSustain.Pos = self.Pos;
	self.dSharpSustain.Pos = self.Pos;
	self.eSustain.Pos = self.Pos;
	self.fSustain.Pos = self.Pos;
	
	self.cSharp1Sustain.Pos = self.Pos;
	self.d1Sustain.Pos = self.Pos;
	self.dSharp1Sustain.Pos = self.Pos;
	self.e1Sustain.Pos = self.Pos;
	
	self.release.Pos = self.Pos;
	self.fx.Pos = self.Pos;
	
	-- 8 H
	-- 10 J
	-- 11 K
	-- 12 L
	
	if self:GetRootParent().UniqueID == self.UniqueID then
		self.parent = nil;
		self.parentSet = false;
	elseif self.parentSet == false then
		self.parent = ToActor(self:GetRootParent());
		self.parentSet = true;
	end

	
	if not self:IsActivated() and self.parent and self.parent:IsPlayerControlled() then
	
		if self:NumberValueExists("Switch Mode") then
		
			self:SetNumberValue("Weapons - Mordhau Melee", 1);
		
			self.StanceOffset = Vector(10, 7);
			self.SharpStanceOffset = Vector(10, 7);
			self.meleeOriginalStanceOffset = Vector(10, 7);
			self.SharpLength = 0;
			self.JointOffset = Vector(6, -14);
			self.SupportOffset = Vector(7, -12);
		
			self:RemoveNumberValue("Switch Mode");
			self.meleeMode = true;
			
			self.InheritedRotAngleOffset = 0;
			
			self.originalBaseRotation = -140;
			self.baseRotation = 0;
			
			self:DisableScript("Massive.rte/Devices/Weapons/Melee/Shredder/Shredder.lua");
			self:EnableScript("Massive.rte/Devices/Weapons/Melee/Shredder/MeleeMode.lua");
			
			self.cSharpMuted:Stop(-1);
			self.dMuted:Stop(-1);
			self.eMuted:Stop(-1);
			self.fMuted:Stop(-1);

			self.cSharpSustain:Stop(-1);
			self.dSustain:Stop(-1);
			self.dSharpSustain:Stop(-1);
			self.eSustain:Stop(-1);
			self.fSustain:Stop(-1);
			
			self.cSharp1Sustain:Stop(-1);
			self.d1Sustain:Stop(-1);
			self.dSharp1Sustain:Stop(-1);
			self.e1Sustain:Stop(-1);
			
			self.release:Stop(-1);
			self.fx:Stop(-1);
			
			return
			
		end	
	
		if not self.alternate then
			
			if UInputMan:KeyPressed(Key.H) then
			
				local shakenessParticle = CreateMOPixel("Shakeness Particle Massive", "Massive.rte");
				shakenessParticle.Pos = self.MuzzlePos;
				shakenessParticle.Mass = 20;
				shakenessParticle.Lifetime = 100;
				MovableMan:AddParticle(shakenessParticle);				
			
				self.SupportOffset = Vector(7, -14);
				
				--self.JointOffset = self.JointOffset + Vector(3, 3);
			
				self.release:Stop(-1);
			
				self.sustain = false;
			
				self.dMuted:Stop(-1);
				self.eMuted:Stop(-1);
				self.fMuted:Stop(-1);
				
				self.dSustain:Stop(-1);
				self.eSustain:Stop(-1);
				self.fSustain:Stop(-1);
				
				self.cSharpSustain:Stop(-1);
				self.cSharpMuted:Stop(-1);
				self.cSharpMuted:Play(self.Pos);
				
				self.keyPressTimer:Reset();
				
			end
			
			if UInputMan:KeyPressed(Key.J) then
			
				local shakenessParticle = CreateMOPixel("Shakeness Particle Massive", "Massive.rte");
				shakenessParticle.Pos = self.MuzzlePos;
				shakenessParticle.Mass = 20;
				shakenessParticle.Lifetime = 100;
				MovableMan:AddParticle(shakenessParticle);	
			
				self.SupportOffset = Vector(6, -12);
				
				--self.JointOffset = self.JointOffset + Vector(3, 3);
			
				self.release:Stop(-1);
			
				self.sustain = false;
			
				self.cSharpMuted:Stop(-1);
				self.eMuted:Stop(-1);
				self.fMuted:Stop(-1);
				
				self.cSharpSustain:Stop(-1);
				self.eSustain:Stop(-1);
				self.fSustain:Stop(-1);
				
				self.dSustain:Stop(-1);
				self.dMuted:Stop(-1);
				self.dMuted:Play(self.Pos);
				
				self.keyPressTimer:Reset();
				
			end
			
			if UInputMan:KeyPressed(Key.K) then
			
				local shakenessParticle = CreateMOPixel("Shakeness Particle Massive", "Massive.rte");
				shakenessParticle.Pos = self.MuzzlePos;
				shakenessParticle.Mass = 20;
				shakenessParticle.Lifetime = 100;
				MovableMan:AddParticle(shakenessParticle);			
			
				self.SupportOffset = Vector(5, -10);
				
				--self.JointOffset = self.JointOffset + Vector(3, 3);
			
				self.release:Stop(-1);
			
				self.sustain = false;
			
				self.cSharpMuted:Stop(-1);
				self.dMuted:Stop(-1);
				self.fMuted:Stop(-1);
				
				self.cSharpSustain:Stop(-1);
				self.dSustain:Stop(-1);
				self.fSustain:Stop(-1);			
				
				self.eSustain:Stop(-1);
				self.eMuted:Stop(-1);
				self.eMuted:Play(self.Pos);
				
				self.keyPressTimer:Reset();
				
			end
			
			if UInputMan:KeyPressed(Key.L) then
			
				local shakenessParticle = CreateMOPixel("Shakeness Particle Massive", "Massive.rte");
				shakenessParticle.Pos = self.MuzzlePos;
				shakenessParticle.Mass = 20;
				shakenessParticle.Lifetime = 100;
				MovableMan:AddParticle(shakenessParticle);			
			
				self.SupportOffset = Vector(4, -8);
				
				--self.JointOffset = self.JointOffset + Vector(3, 3);
			
				self.release:Stop(-1);
			
				self.sustain = false;
			
				self.cSharpMuted:Stop(-1);
				self.dMuted:Stop(-1);
				self.eMuted:Stop(-1);
				
				self.cSharpSustain:Stop(-1);
				self.dSustain:Stop(-1);
				self.eSustain:Stop(-1);
				
				self.fSustain:Stop(-1);
				self.fMuted:Stop(-1);
				self.fMuted:Play(self.Pos);
				
				self.keyPressTimer:Reset();
				
			end
			
			if self.keyPressTimer:IsPastSimMS(self.sustainDelay) and self.sustain ~= true then
			
				if self.sustain ~= true and UInputMan:KeyHeld(8) then
					
					local shakenessParticle = CreateMOPixel("Shakeness Particle Massive", "Massive.rte");
					shakenessParticle.Pos = self.MuzzlePos;
					shakenessParticle.Mass = 30;
					shakenessParticle.Lifetime = 200;
					MovableMan:AddParticle(shakenessParticle);					
					
					self.sustain = true;
					
					self.cSharpMuted:Stop(-1);
					self.cSharpSustain:Play(self.Pos);
					
				end
				
				if self.sustain ~= true and UInputMan:KeyHeld(10) then
				
					local shakenessParticle = CreateMOPixel("Shakeness Particle Massive", "Massive.rte");
					shakenessParticle.Pos = self.MuzzlePos;
					shakenessParticle.Mass = 30;
					shakenessParticle.Lifetime = 200;
					MovableMan:AddParticle(shakenessParticle);		
				
					self.sustain = true;
					
					self.dMuted:Stop(-1);
					self.dSustain:Play(self.Pos);
					
				end
				
				if self.sustain ~= true and UInputMan:KeyHeld(11) then
				
					local shakenessParticle = CreateMOPixel("Shakeness Particle Massive", "Massive.rte");
					shakenessParticle.Pos = self.MuzzlePos;
					shakenessParticle.Mass = 30;
					shakenessParticle.Lifetime = 200;
					MovableMan:AddParticle(shakenessParticle);		
				
					self.sustain = true;
				
					self.eMuted:Stop(-1);
					self.eSustain:Play(self.Pos);
					
				end
				
				if self.sustain ~= true and UInputMan:KeyHeld(12) then
				
					local shakenessParticle = CreateMOPixel("Shakeness Particle Massive", "Massive.rte");
					shakenessParticle.Pos = self.MuzzlePos;
					shakenessParticle.Mass = 30;
					shakenessParticle.Lifetime = 200;
					MovableMan:AddParticle(shakenessParticle);		
				
					self.sustain = true;
					
					self.fMuted:Stop(-1);
					self.fSustain:Play(self.Pos);
					
				end	

			end
		
			-- V B M N 
			
			if UInputMan:KeyPressed(Key.V) then
				
				local shakenessParticle = CreateMOPixel("Shakeness Particle Massive", "Massive.rte");
				shakenessParticle.Pos = self.MuzzlePos;
				shakenessParticle.Mass = 30;
				shakenessParticle.Lifetime = 200;
				MovableMan:AddParticle(shakenessParticle);					
				
				self.sustain = true;
				
				self.SupportOffset = Vector(7, -14);
				
				self.release:Stop(-1);
				
				self.dMuted:Stop(-1);
				self.eMuted:Stop(-1);
				self.fMuted:Stop(-1);
				
				self.dSustain:Stop(-1);
				self.eSustain:Stop(-1);
				self.fSustain:Stop(-1);
				
				self.cSharpSustain:Stop(-1);
				self.cSharpMuted:Stop(-1);
				
				self.cSharpSustain:Play(self.Pos);
				
			end
			
			if UInputMan:KeyPressed(Key.B) then
			
				local shakenessParticle = CreateMOPixel("Shakeness Particle Massive", "Massive.rte");
				shakenessParticle.Pos = self.MuzzlePos;
				shakenessParticle.Mass = 30;
				shakenessParticle.Lifetime = 200;
				MovableMan:AddParticle(shakenessParticle);		
			
				self.sustain = true;
				
				self.SupportOffset = Vector(6, -12);
				
				self.release:Stop(-1);
				
				self.cSharpMuted:Stop(-1);
				self.eMuted:Stop(-1);
				self.fMuted:Stop(-1);
				
				self.cSharpSustain:Stop(-1);
				self.eSustain:Stop(-1);
				self.fSustain:Stop(-1);
				
				self.dSustain:Stop(-1);
				self.dMuted:Stop(-1);
				self.dSustain:Play(self.Pos);
				
			end
			
			if UInputMan:KeyPressed(Key.N) then
			
				local shakenessParticle = CreateMOPixel("Shakeness Particle Massive", "Massive.rte");
				shakenessParticle.Pos = self.MuzzlePos;
				shakenessParticle.Mass = 30;
				shakenessParticle.Lifetime = 200;
				MovableMan:AddParticle(shakenessParticle);		
			
				self.sustain = true;
				
				self.SupportOffset = Vector(5, -10);
				
				self.release:Stop(-1);
			
				self.cSharpMuted:Stop(-1);
				self.dMuted:Stop(-1);
				self.fMuted:Stop(-1);
				
				self.cSharpSustain:Stop(-1);
				self.dSustain:Stop(-1);
				self.fSustain:Stop(-1);			
				
				self.eSustain:Stop(-1);
				self.eMuted:Stop(-1);
				self.eSustain:Play(self.Pos);
				
			end
			
			if UInputMan:KeyPressed(Key.M) then
			
				local shakenessParticle = CreateMOPixel("Shakeness Particle Massive", "Massive.rte");
				shakenessParticle.Pos = self.MuzzlePos;
				shakenessParticle.Mass = 30;
				shakenessParticle.Lifetime = 200;
				MovableMan:AddParticle(shakenessParticle);		
			
				self.sustain = true;
				
				self.SupportOffset = Vector(4, -8);
				
				self.release:Stop(-1);
				
				self.cSharpMuted:Stop(-1);
				self.dMuted:Stop(-1);
				self.eMuted:Stop(-1);
				
				self.cSharpSustain:Stop(-1);
				self.dSustain:Stop(-1);
				self.eSustain:Stop(-1);
				
				self.fSustain:Stop(-1);
				self.fMuted:Stop(-1);
				self.fSustain:Play(self.Pos);
				
			end	
			
		end
		
		if self.alternate then
	
			-- V B M N 
			
			if UInputMan:KeyPressed(Key.V) then
				
				local shakenessParticle = CreateMOPixel("Shakeness Particle Massive", "Massive.rte");
				shakenessParticle.Pos = self.MuzzlePos;
				shakenessParticle.Mass = 30;
				shakenessParticle.Lifetime = 200;
				MovableMan:AddParticle(shakenessParticle);					
				
				self.sustain = true;
				
				self.SupportOffset = Vector(7, -14);
				
				self.release:Stop(-1);
				
				self.dMuted:Stop(-1);
				self.eMuted:Stop(-1);
				self.fMuted:Stop(-1);
				
				self.dSustain:Stop(-1);
				self.eSustain:Stop(-1);
				self.dSharpSustain:Stop(-1);
				self.fSustain:Stop(-1);
				
				self.cSharp1Sustain:Stop(-1);
				self.d1Sustain:Stop(-1);
				self.dSharp1Sustain:Stop(-1);
				self.e1Sustain:Stop(-1);
				
				self.cSharpSustain:Stop(-1);
				self.cSharpMuted:Stop(-1);
				
				self.cSharpSustain:Play(self.Pos);
				
			end
			
			if UInputMan:KeyPressed(Key.B) then
			
				local shakenessParticle = CreateMOPixel("Shakeness Particle Massive", "Massive.rte");
				shakenessParticle.Pos = self.MuzzlePos;
				shakenessParticle.Mass = 30;
				shakenessParticle.Lifetime = 200;
				MovableMan:AddParticle(shakenessParticle);		
			
				self.sustain = true;
				
				self.SupportOffset = Vector(6, -12);
				
				self.release:Stop(-1);
				
				self.cSharpMuted:Stop(-1);
				self.eMuted:Stop(-1);
				self.fMuted:Stop(-1);
				
				self.cSharpSustain:Stop(-1);
				self.eSustain:Stop(-1);
				self.dSharpSustain:Stop(-1);
				self.fSustain:Stop(-1);
				
				self.cSharp1Sustain:Stop(-1);
				self.d1Sustain:Stop(-1);
				self.dSharp1Sustain:Stop(-1);
				self.e1Sustain:Stop(-1);
				
				self.dSustain:Stop(-1);
				self.dMuted:Stop(-1);
				self.dSustain:Play(self.Pos);
				
			end
			
			if UInputMan:KeyPressed(Key.N) then
			
				local shakenessParticle = CreateMOPixel("Shakeness Particle Massive", "Massive.rte");
				shakenessParticle.Pos = self.MuzzlePos;
				shakenessParticle.Mass = 30;
				shakenessParticle.Lifetime = 200;
				MovableMan:AddParticle(shakenessParticle);		
			
				self.sustain = true;
				
				self.SupportOffset = Vector(5, -10);
				
				self.release:Stop(-1);
			
				self.cSharpMuted:Stop(-1);
				self.dMuted:Stop(-1);
				self.fMuted:Stop(-1);
				
				self.cSharpSustain:Stop(-1);
				self.dSustain:Stop(-1);
				self.eSustain:Stop(-1);		

				self.cSharp1Sustain:Stop(-1);
				self.d1Sustain:Stop(-1);
				self.dSharp1Sustain:Stop(-1);
				self.e1Sustain:Stop(-1);				
				
				self.dSharpSustain:Stop(-1);
				self.dSharpSustain:Play(self.Pos);
				
			end
			
			if UInputMan:KeyPressed(Key.M) then
			
				local shakenessParticle = CreateMOPixel("Shakeness Particle Massive", "Massive.rte");
				shakenessParticle.Pos = self.MuzzlePos;
				shakenessParticle.Mass = 30;
				shakenessParticle.Lifetime = 200;
				MovableMan:AddParticle(shakenessParticle);		
			
				self.sustain = true;
				
				self.SupportOffset = Vector(4, -8);
				
				self.release:Stop(-1);
				
				self.cSharpMuted:Stop(-1);
				self.dMuted:Stop(-1);
				self.fMuted:Stop(-1);
				
				self.cSharpSustain:Stop(-1);
				self.dSustain:Stop(-1);
				self.dSharpSustain:Stop(-1);
				self.fSustain:Stop(-1);		

				self.cSharp1Sustain:Stop(-1);
				self.d1Sustain:Stop(-1);
				self.dSharp1Sustain:Stop(-1);
				self.e1Sustain:Stop(-1);				
				
				self.eSustain:Stop(-1);
				self.eMuted:Stop(-1);
				self.eSustain:Play(self.Pos);
				
			end	
	
	
	
			if UInputMan:KeyPressed(Key.H) then
				
				local shakenessParticle = CreateMOPixel("Shakeness Particle Massive", "Massive.rte");
				shakenessParticle.Pos = self.MuzzlePos;
				shakenessParticle.Mass = 30;
				shakenessParticle.Lifetime = 200;
				MovableMan:AddParticle(shakenessParticle);					
				
				self.sustain = true;
				
				self.SupportOffset = Vector(7, -14);
				
				self.release:Stop(-1);
				
				self.cSharpMuted:Stop(-1);
				self.dMuted:Stop(-1);
				self.fMuted:Stop(-1);
				
				self.cSharpSustain:Stop(-1);
				self.dSustain:Stop(-1);
				self.eSustain:Stop(-1);		
				self.dSharpSustain:Stop(-1);
				self.fSustain:Stop(-1);		

				self.e1Sustain:Stop(-1);
				self.d1Sustain:Stop(-1);
				self.dSharp1Sustain:Stop(-1);		
				
				self.cSharp1Sustain:Stop(-1);
				self.eMuted:Stop(-1);
				self.cSharp1Sustain:Play(self.Pos);
				
			end
			
			if UInputMan:KeyPressed(Key.J) then
			
				local shakenessParticle = CreateMOPixel("Shakeness Particle Massive", "Massive.rte");
				shakenessParticle.Pos = self.MuzzlePos;
				shakenessParticle.Mass = 30;
				shakenessParticle.Lifetime = 200;
				MovableMan:AddParticle(shakenessParticle);		
			
				self.sustain = true;
				
				self.SupportOffset = Vector(6, -12);
				
				self.release:Stop(-1);
				
				self.cSharpMuted:Stop(-1);
				self.dMuted:Stop(-1);
				self.fMuted:Stop(-1);
				
				self.cSharpSustain:Stop(-1);
				self.dSustain:Stop(-1);
				self.eSustain:Stop(-1);		
				self.dSharpSustain:Stop(-1);
				self.fSustain:Stop(-1);		

				self.cSharp1Sustain:Stop(-1);
				self.e1Sustain:Stop(-1);
				self.dSharp1Sustain:Stop(-1);		
				
				self.d1Sustain:Stop(-1);
				self.eMuted:Stop(-1);
				self.d1Sustain:Play(self.Pos);
				
			end
			
			if UInputMan:KeyPressed(Key.K) then
			
				local shakenessParticle = CreateMOPixel("Shakeness Particle Massive", "Massive.rte");
				shakenessParticle.Pos = self.MuzzlePos;
				shakenessParticle.Mass = 30;
				shakenessParticle.Lifetime = 200;
				MovableMan:AddParticle(shakenessParticle);		
			
				self.sustain = true;
				
				self.SupportOffset = Vector(5, -10);
				
				self.release:Stop(-1);
			
				self.cSharpMuted:Stop(-1);
				self.dMuted:Stop(-1);
				self.fMuted:Stop(-1);
				
				self.cSharpSustain:Stop(-1);
				self.dSustain:Stop(-1);
				self.eSustain:Stop(-1);		
				self.dSharpSustain:Stop(-1);
				self.fSustain:Stop(-1);		

				self.cSharp1Sustain:Stop(-1);
				self.d1Sustain:Stop(-1);
				self.e1Sustain:Stop(-1);		
				
				self.dSharp1Sustain:Stop(-1);
				self.eMuted:Stop(-1);
				self.dSharp1Sustain:Play(self.Pos);
				
			end
			
			if UInputMan:KeyPressed(Key.L) then
			
				local shakenessParticle = CreateMOPixel("Shakeness Particle Massive", "Massive.rte");
				shakenessParticle.Pos = self.MuzzlePos;
				shakenessParticle.Mass = 30;
				shakenessParticle.Lifetime = 200;
				MovableMan:AddParticle(shakenessParticle);		
			
				self.sustain = true;
				
				self.SupportOffset = Vector(4, -8);
				
				self.release:Stop(-1);
				
				self.cSharpMuted:Stop(-1);
				self.dMuted:Stop(-1);
				self.fMuted:Stop(-1);
				
				self.cSharpSustain:Stop(-1);
				self.dSustain:Stop(-1);
				self.eSustain:Stop(-1);		
				self.dSharpSustain:Stop(-1);
				self.fSustain:Stop(-1);		

				self.cSharp1Sustain:Stop(-1);
				self.d1Sustain:Stop(-1);
				self.dSharp1Sustain:Stop(-1);		
				
				self.e1Sustain:Stop(-1);
				self.eMuted:Stop(-1);
				self.e1Sustain:Play(self.Pos);
				
			end		
	
	
		end
		
		
		
	end
	
	if self.sustain == true and self.sustainTimer:IsPastSimMS(self.sustainOffDelay) and
	not (UInputMan:KeyHeld(Key.H) or UInputMan:KeyHeld(Key.J) or UInputMan:KeyHeld(Key.K) or UInputMan:KeyHeld(Key.L)) and
	not (UInputMan:KeyHeld(Key.V) or UInputMan:KeyHeld(Key.B) or UInputMan:KeyHeld(Key.N) or UInputMan:KeyHeld(Key.M)) then
	
		self.cSharpSustain:Stop(-1);
		self.dSustain:Stop(-1);
		self.dSharpSustain:Stop(-1);
		self.eSustain:Stop(-1);
		self.fSustain:Stop(-1);
		
		self.cSharp1Sustain:Stop(-1);
		self.d1Sustain:Stop(-1);
		self.dSharp1Sustain:Stop(-1);
		self.e1Sustain:Stop(-1);
	
		self.sustain = false;
		self.release:Play(self.Pos);
	elseif (UInputMan:KeyHeld(Key.H) or UInputMan:KeyHeld(Key.J) or UInputMan:KeyHeld(Key.K) or UInputMan:KeyHeld(Key.L)) or
	(UInputMan:KeyHeld(Key.V) or UInputMan:KeyHeld(Key.B) or UInputMan:KeyHeld(Key.N) or UInputMan:KeyHeld(Key.M)) then
		self.sustainTimer:Reset();
	end
	
	if self:IsActivated() then
	
		if not self.activated then
		
			self.activated = true;

			self.cSharpSustain:Stop(-1);
			self.dSustain:Stop(-1);
			self.dSharpSustain:Stop(-1);
			self.eSustain:Stop(-1);
			self.fSustain:Stop(-1);
			
			self.cSharp1Sustain:Stop(-1);
			self.d1Sustain:Stop(-1);
			self.dSharp1Sustain:Stop(-1);
			self.e1Sustain:Stop(-1);
			
			self.cSharpMuted:Stop(-1);
			self.dMuted:Stop(-1);
			self.eMuted:Stop(-1);
			self.fMuted:Stop(-1);		
			
			self.release:Stop(-1);
			
			self.fx:Stop(-1);
			
			self.fx:Play(self.Pos);
			
		end
		
	else
	
		self.activated = false;
		
	end
		
				

end