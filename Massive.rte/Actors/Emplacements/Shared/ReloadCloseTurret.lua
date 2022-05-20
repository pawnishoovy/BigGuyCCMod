function Create(self)

	if IsACrab(self:GetRootParent()) then
		self.parent = ToACrab(self:GetRootParent());
	else
		self.parent = nil
	end
	
	if IsAttachable(self:GetParent()) then
		self.motorParent = ToAttachable(self:GetParent())
	else
		self.motorParent = nil
	end

end

function Update(self)

	if self.Magazine == nil then
		if self.parent and self.motorParent then
			self.parent:GetController():SetState(Controller.AIM_SHARP,false);
		end
	end
end