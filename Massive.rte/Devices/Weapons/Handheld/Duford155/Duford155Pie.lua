function Duford155ArtilleryMode(actor)
	local gun = ToAHuman(actor).EquippedItem;
	if gun ~= nil then
		local gun = ToHDFirearm(gun);
		gun:SetNumberValue("Enter Artillery Mode", 1);
	end
end