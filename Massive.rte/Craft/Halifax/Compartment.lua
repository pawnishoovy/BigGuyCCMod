function Create(self)

	if string.find(self.PresetName, "Left") then
		self.left = true;
		self.leftFactor = -1;
	else
		self.leftFactor = 1;
	end
	

	self.detachSound = CreateSoundContainer("CompartmentDetach Halifax Massive", "Massive.rte");
	
	self.realWoundLimit = self.GibWoundLimit;
	self.GibWoundLimit = 1000;
	

end
function Update(self)

	if self.detachAttempted ~= true and self.WoundCount > self.realWoundLimit / 2 and self:IsAttached() then
		self.detachAttempted = true;
		if math.random(0, 100) < 35 then
			self:GetParent():SetNumberValue("Damage Reaction", 1);
			if self.left then
				self:GetParent():SetNumberValue("Lost Left Compartment", 1);
			else
				self:GetParent():SetNumberValue("Lost Right Compartment", 1);
			end
			self.detachSound:Play(self.Pos);
			self.ToDelete = true;
			local looseMOSRotating = self.left and CreateMOSRotating("Halifax Massive Compartment Left Loose", "Massive") or CreateMOSRotating("Halifax Massive Compartment Right Loose", "Massive");
			looseMOSRotating.Pos = self.Pos + Vector(43 * self.leftFactor, 20):RadRotate(self.RotAngle);
			looseMOSRotating.RotAngle = self.RotAngle
			looseMOSRotating.Vel = self.Vel
			MovableMan:AddParticle(looseMOSRotating);
		end
	elseif self.WoundCount > self.realWoundLimit then
		self:GetParent():SetNumberValue("Damage Reaction", 1);
		if self.left then
			self:GetParent():SetNumberValue("Lost Left Compartment", 1);
		else
			self:GetParent():SetNumberValue("Lost Right Compartment", 1);
		end
		self.ToDelete = true;
		self.looseMOSRotating = self.left and CreateMOSRotating("Halifax Massive Compartment Left Loose", "Massive") or CreateMOSRotating("Halifax Massive Compartment Right Loose", "Massive");
		self.looseMOSRotating.Pos = self.Pos + Vector(43 * self.leftFactor, 20):RadRotate(self.RotAngle);
		self.looseMOSRotating.RotAngle = self.RotAngle
		self.looseMOSRotating.Vel = self.Vel
		MovableMan:AddParticle(self.looseMOSRotating);
		self.looseMOSRotating:GibThis();
	end

end

function OnDetach(self, formerParent)

	if not self.detachAttempted then
		self.ToDelete = true;
		local looseMOSRotating = self.left and CreateMOSRotating("Halifax Massive Compartment Left Loose", "Massive") or CreateMOSRotating("Halifax Massive Compartment Right Loose", "Massive");
		looseMOSRotating.Pos = self.Pos + Vector(43 * self.leftFactor, 20):RadRotate(self.RotAngle);
		looseMOSRotating.RotAngle = self.RotAngle
		looseMOSRotating.Vel = self.Vel
		MovableMan:AddParticle(looseMOSRotating);
	end
	
end