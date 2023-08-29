function MCADHE(actor)

	local gun = ToAHuman(actor).EquippedItem;
	if gun ~= nil then
		local gun = ToHDFirearm(gun);
		local magSwitchName = "Magazine HE Massive MCAD";
		if gun.Magazine == nil or (gun.Magazine ~= nil and gun.Magazine.PresetName ~= magSwitchName) then
			gun:SetNextMagazineName(magSwitchName);
			if not gun:IsReloading() then
				gun.Reloadable = true;
				gun:Reload();
			end
			gun:RemoveNumberValue("DUAP Round");
			gun:SetNumberValue("Switched", 1);
		end
	end

end

function MCADDUAP(actor)

	local gun = ToAHuman(actor).EquippedItem;
	if gun ~= nil then
		local gun = ToHDFirearm(gun);
		local magSwitchName = "Magazine DUAP Massive MCAD";
		if gun.Magazine == nil or (gun.Magazine ~= nil and gun.Magazine.PresetName ~= magSwitchName) then
			gun:SetNextMagazineName(magSwitchName);
			if not gun:IsReloading() then
				gun.Reloadable = true;
				gun:Reload();
			end
			gun:SetNumberValue("DUAP Round", 1);
			gun:SetNumberValue("Switched", 1);
		end
	end

end