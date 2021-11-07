function Create(self)

	self.num = 0;
	
end

function Update(self)

	if self:GetParent() then

		if IsHDFirearm(self:GetRootParent()) then
			self.CollidesWithTerrainWhileAttached = true;
			self.HitsMOs = true;
			self.GetsHitByMOs = true;
		else
			self.CollidesWithTerrainWhileAttached = false;
			self.HitsMOs = false;
			self.GetsHitByMOs = false;
		end
		
		if self:GetParent():NumberValueExists("Turned On") then
			self.num = self.num + 1 % 50;
			if self.num == 0 then
				self.Frame = self.Frame + 1 % 2;
			end
		end
		
	end
	
end