function Create(self)
	self.heatMax = 25
	self.heat = self.heatMax
end

function OnCollideWithMO(self, MO, rootMO)
	
	if IsActor(rootMO) then
		local heatOnHit = math.max(math.min(self.heatMax * 0.5, self.heat), 0)
		self.heat = self.heat - heatOnHit / rootMO.Mass * 133
		
		local actor = ToActor(rootMO)
		if actor:NumberValueExists("ActorHeat") then
			actor:SetNumberValue("ActorHeat", actor:GetNumberValue("ActorHeat") + heatOnHit)
		else
			local heatHandler = CreateAttachable("RealHeat Handler", "Massives.rte")
			actor:AddAttachable(heatHandler)
			actor:SetNumberValue("ActorHeat", 0 + heatOnHit)
		end
		
		if self.heat <= 0 then
			self:DisableScript("Massive.rte/Devices/Weapons/Handheld/Flamethrower/FlameBall.lua");
		end
	end
	
end
