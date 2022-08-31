function ShredderSwitchMode(actor)
	local gun = ToAHuman(actor).EquippedItem;
	if gun ~= nil then
		local gun = ToHDFirearm(gun);
		gun:SetNumberValue("Switch Mode", 1);
	end
end