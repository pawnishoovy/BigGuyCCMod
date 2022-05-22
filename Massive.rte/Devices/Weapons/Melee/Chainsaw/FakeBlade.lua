function Create(self)

	self.chainVelocity = 0
	self.chainFactor = 0
	
	self.CollidesWithTerrainWhileAttached = false;
	self.HitsMOs = false;
	self.GetsHitByMOs = false;
end

function Update(self)

	local parent = self:GetParent()
	if parent and IsHDFirearm(parent) then
		parent = ToHDFirearm(parent)
		
		-- if IsHDFirearm(self:GetRootParent()) then
			-- self.CollidesWithTerrainWhileAttached = true;
			-- self.HitsMOs = true;
			-- self.GetsHitByMOs = true;
		-- else
			-- self.CollidesWithTerrainWhileAttached = false;
			-- self.HitsMOs = false;
			-- self.GetsHitByMOs = false;
		-- end
		
		if parent:NumberValueExists("Turned On") and parent:IsActivated() then
			self.chainVelocity = math.min(self.chainVelocity + TimerMan.DeltaTimeSecs * 0.8, 1)
		else
			self.chainVelocity = math.max(self.chainVelocity - TimerMan.DeltaTimeSecs * 0.8, 0)
		end
	else
		self.chainVelocity = math.max(self.chainVelocity - TimerMan.DeltaTimeSecs * 2, 0)
	end
	
	self.chainFactor = self.chainFactor + math.min(self.chainVelocity, 0.7) * TimerMan.DeltaTimeSecs * 60
	if self.chainFactor >= 1 then
		self.chainFactor = self.chainFactor - math.floor(self.chainFactor)
	end
	if self.chainVelocity >= 0.9 then
		self.Frame = 4 + math.floor(self.chainFactor * 1 + 0.5)
	else
		self.Frame = math.floor(self.chainFactor * 3 + 0.5)
	end
	print(self.chainVelocity)
	
end

-- function Create(self)

	-- self.num = 0;
	
-- end

-- function Update(self)

	-- if self:GetParent() then

		-- if IsHDFirearm(self:GetRootParent()) then
			-- self.CollidesWithTerrainWhileAttached = true;
			-- self.HitsMOs = true;
			-- self.GetsHitByMOs = true;
		-- else
			-- self.CollidesWithTerrainWhileAttached = false;
			-- self.HitsMOs = false;
			-- self.GetsHitByMOs = false;
		-- end
		
		-- if self:GetParent():NumberValueExists("Turned On") then
			-- self.num = self.num + 1 % 50;
			-- if self.num == 0 then
				-- self.Frame = self.Frame + 1 % 2;
			-- end
		-- end
		
	-- end
	
-- end