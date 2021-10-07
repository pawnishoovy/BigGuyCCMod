function Create(self)

	self.oldWoundCount = 0;
	self.actualGibWoundLimit = self.GibWoundLimit;
	self.GibWoundLimit = 200;

end
function Update(self)

	if self.WoundCount > self.oldWoundCount then
		if self.WoundCount - self.oldWoundCount > 10 then
			self:RemoveWounds((self.WoundCount - self.oldWoundCount) / 2)
		end
		if self.WoundCount > self.actualGibWoundLimit then
			self:GibThis();
		end
	end
	
	self.oldWoundCount = self.WoundCount;

end