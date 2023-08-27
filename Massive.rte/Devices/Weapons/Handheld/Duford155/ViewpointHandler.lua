function Create(self)

	self.activity = ToGameActivity(ActivityMan:GetActivity())

	self.actorParent = ToActor(MovableMan:FindObjectByUniqueID(self.Mass));
	self.gunParent = ToHDFirearm(MovableMan:FindObjectByUniqueID(self.Sharpness));
	
	self.Mouse = self.actorParent.ViewPoint;

end

function Update(self)

	self.Mouse = Vector(self.Mouse.X + UInputMan:GetMouseMovement(self.actorParent.Team).X, SceneMan.SceneHeight * -1);
	
	self.actorParent.ViewPoint = SceneMan:MovePointToGround(self.Mouse, 50, 25);
	
	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do	
		
		if self.activity:PlayerActive(player) and self.activity:PlayerHuman(player) then
		
			local cursorPos = CameraMan:GetScrollTarget(player)
			local cursorSize = 15
			PrimitiveMan:DrawCirclePrimitive(player, cursorPos, cursorSize, 122)
			PrimitiveMan:DrawLinePrimitive(player, cursorPos + Vector(0, -cursorSize * 0.5), cursorPos + Vector(0, cursorSize * 0.5), 122);
			PrimitiveMan:DrawLinePrimitive(player, cursorPos + Vector(-cursorSize * 0.5, 0), cursorPos + Vector(cursorSize * 0.5, 0), 122);
			
			PrimitiveMan:DrawTextPrimitive(player, cursorPos + Vector(0, -30), "Press H to exit artillery mode", true, 1)
			
		end
		
	end
	
end