ActorHolder = {}

function Create(self)

	if IsAHuman(self:GetRootParent()) then
		self.parent = ToAHuman(self:GetRootParent());
		self.parent:SetNumberValue("Massive Disable Movement", 0);
	else
		self.parent = nil
	end

	self.checkTimer = Timer()	--Sometimes the turret delets itslef and doesn't run its Destroy script, so here's a temporary fix 
	self.checkDelay = 100

end

function Update(self)

	if self.parent then

		if self.checkTimer:IsPastSimMS(self.checkDelay) then
			if self.Sharpness == 2 then
				self.Sharpness = 1
			else
				ActorHolder.delet(self)	
			end
			self.checkTimer:Reset()
		end
		
		if not self:IsAttached() then
			ActorHolder.delet(self)
		end
		
	else
		self.ToDelete = true
	end
end

function ActorHolder.delet(self)

	self.parent.AIMode = Actor.AIMODE_SENTRY
	self.parent:SetControllerMode(2 , self.parent:GetController().Player)
	self.parent.HUDVisible = true
	self.parent:RemoveNumberValue("Massive Disable Movement");
	
	self.ToDelete = true

end