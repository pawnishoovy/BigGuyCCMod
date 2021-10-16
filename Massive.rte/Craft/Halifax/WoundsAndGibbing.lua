function Create(self)

	self.weakHitSound = CreateSoundContainer("TinyBulletImpact Halifax Massive", "Massive.rte");
	self.moderateHitSound = CreateSoundContainer("BulletImpact Halifax Massive", "Massive.rte");
	self.strongHitSound = CreateSoundContainer("HeavyBulletImpact Halifax Massive", "Massive.rte");
	self.veryStrongHitSound = CreateSoundContainer("ExtremeBulletImpact Halifax Massive", "Massive.rte");
	
	self.actualGibWoundLimit = self.GibWoundLimit;
	self.GibWoundLimit = 500;
	
	self.oldWoundCount = 0;

end
function Update(self)

	if self.WoundCount > self.oldWoundCount then
		local strengthCheck = self.WoundCount - self.oldWoundCount;
		if strengthCheck < 2 then
			self.weakHitSound:Play(self.Pos);
		elseif strengthCheck < 5 then
			self.moderateHitSound:Play(self.Pos);
		elseif strengthCheck < 15 then
			self.strongHitSound:Play(self.Pos);
		else
			self.veryStrongHitSound:Play(self.Pos);
		end
		if strengthCheck > 10 and self.WoundCount > self.actualGibWoundLimit then
			self:GibThis();
		end
	end
	
	self.oldWoundCount = self.WoundCount;

end