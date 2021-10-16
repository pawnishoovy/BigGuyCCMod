function Update(self)
	local Parent = self:GetParent();
	if Parent ~= nil then
		local Hatch;
		for i = 1,MovableMan:GetMOIDCount()-1 do
			Hatch = MovableMan:GetMOFromID(i);
			if Hatch.ClassName == "Attachable" and Hatch.RootID == Parent.ID then
				if Hatch.PresetName == "Freighter Left Hatch Null" then
					self.HatchLeft = ToAttachable(Hatch);
				end
				if Hatch.PresetName == "Freighter Right Hatch Null" then
					self.HatchRight = ToAttachable(Hatch);
				end
			end
		end
		if self.HatchLeft ~= nil and self.HatchRight ~= nil then
			self.Operate = true;
		end
	elseif Parent == nil then
		self.Operate = false;
		self:GibThis();
	end
	if self.Operate == true then
		self.Offset = Vector(self.JointOffset.X * -1,self.JointOffset.Y * -1);
		self.PosOnParent = Vector(self.ParentOffset.X,self.ParentOffset.Y);
		if self.PresetName == "Freighter Left Hatch" then
			self.RotAngle = self.HatchLeft.RotAngle;
			self.Pos = Parent.Pos + (self.PosOnParent:RadRotate(Parent.RotAngle)) + (self.Offset:RadRotate(self.HatchLeft.RotAngle));
		elseif self.PresetName == "Freighter Right Hatch" then
			self.RotAngle = self.HatchRight.RotAngle;
			self.Pos = Parent.Pos + (self.PosOnParent:RadRotate(Parent.RotAngle)) + (self.Offset:RadRotate(self.HatchRight.RotAngle));
		end
	end	
end