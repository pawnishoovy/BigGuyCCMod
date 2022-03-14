function BunkerBusterPlantingMode(actor)
	local shield = ToAHuman(actor).BGEquippedItem;
	if shield ~= nil and shield.PresetName == "RINOBI Bunker Buster" then
		local shield = ToHeldDevice(shield);
		shield:SetNumberValue("Enter Planting Mode", 1);
	else
		shield = ToAHuman(actor).EquippedItem;
		if shield ~= nil and shield.PresetName == "RINOBI Bunker Buster" then
			local shield = ToHeldDevice(shield);
			shield:SetNumberValue("Enter Planting Mode", 1);
		else
			print("Checked for both BG and FG equipped item but still could not find bunker buster! how'd you manage that?")
		end
	end
end