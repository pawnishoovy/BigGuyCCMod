function Create(self)

	self.veryWeakHitSound = CreateSoundContainer("Impact Metal Small Massive", "Massive.rte");
	self.weakHitSound = CreateSoundContainer("Impact Metal Tight Massive", "Massive.rte");
	self.moderateHitSound = CreateSoundContainer("Impact Metal Solid Massive", "Massive.rte");
	self.moderatelyStrongHitSound = CreateSoundContainer("Impact Metal Basic Massive", "Massive.rte");
	self.strongHitSound = CreateSoundContainer("Impact Metal Clang Massive", "Massive.rte");
	self.veryStrongHitSound = CreateSoundContainer("Impact Metal Rip Massive", "Massive.rte");
	
	self.actualGibWoundLimit = self.GibWoundLimit;
	self.GibWoundLimit = 200;
	
	self.oldWoundCount = 0;

end
function Update(self)

	if self.WoundCount > self.oldWoundCount then
		local strengthCheck = self.WoundCount - self.oldWoundCount;
		if strengthCheck < 2 then
			self.veryWeakHitSound:Play(self.Pos);
		elseif strengthCheck < 3 then
			self.weakHitSound:Play(self.Pos);
		elseif strengthCheck < 4 then
			self.moderateHitSound:Play(self.Pos);
		elseif strengthCheck < 5 then
			self.moderatelyStrongHitSound:Play(self.Pos);
		elseif strengthCheck < 6 then
			self.strongHitSound:Play(self.Pos);
		else
			self.veryStrongHitSound:Play(self.Pos);
		end
		if strengthCheck > 10 then
			self:RemoveWounds((self.WoundCount - self.oldWoundCount) / 2)
		end
		print(self.WoundCount)
		print(strengthCheck)
		print(self.actualGibWoundLimit)
		if strengthCheck > 1 and self.WoundCount > self.actualGibWoundLimit then
			self:GibThis();
		end
	end
	
	self.oldWoundCount = self.WoundCount;

end