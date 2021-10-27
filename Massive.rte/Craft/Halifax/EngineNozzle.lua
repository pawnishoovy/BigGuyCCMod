function Create(self)

	self.weakHitSound = CreateSoundContainer("TinyBulletImpact Halifax Massive", "Massive.rte");
	self.moderateHitSound = CreateSoundContainer("BulletImpact Halifax Massive", "Massive.rte");
	self.strongHitSound = CreateSoundContainer("HeavyBulletImpact Halifax Massive", "Massive.rte");
	
	self.oldWoundCount = 0;
	
	self.parentWound = CreateAEmitter("Halifax Base Wound Massive", "Massive.rte");

end
function Update(self)

	local parent = self:GetParent();
	if parent then

		if self.WoundCount % 5 > 1 then
			if self.addedWound ~= true then
				local wound = self.parentWound:Clone();
				ToMOSRotating(parent):AddWound(wound, Vector(0, 0), true);
				self.addedWound = true;
			end
		else
			self.addedWound = false;
		end
			
	else
		self.ToDelete = true;
	end

	if self.WoundCount > self.oldWoundCount then
		local strengthCheck = self.WoundCount - self.oldWoundCount;
		if strengthCheck < 2 then
			self.weakHitSound:Play(self.Pos);
		elseif strengthCheck < 5 then
			self.moderateHitSound:Play(self.Pos);
		else
			self.strongHitSound:Play(self.Pos);
		end
	end
	
	self.oldWoundCount = self.WoundCount;

end