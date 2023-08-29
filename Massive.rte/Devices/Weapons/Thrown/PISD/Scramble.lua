function Create(self)

	self.effectRadius = 175;
	self.strength = self.PinStrength;	--Affects the duration of the effect
	self.flashScreen = false;	--Do not turn on if you are prone to seizures
	
	self.actorTable = {};
	local actorCount = 0;	--Diminishes the effect the more actors are affected
	
	for mo in MovableMan:GetMOsInRadius(self.Pos, self.effectRadius, self.Team, true) do
		if IsActor(mo) then
			mo = ToActor(mo)
			local dist = SceneMan:ShortestDistance(self.Pos, mo.Pos, SceneMan.SceneWrapsX);
			if dist.Magnitude < self.effectRadius then
				if IsADoor(mo) then
					ToADoor(mo):OpenDoor();
					mo:FlashWhite(200)
				end
				local skipPx = 1 + (dist.Magnitude * 0.01);
				local strCheck = SceneMan:CastStrengthSumRay(self.Pos, self.Pos + dist, skipPx, rte.airID);
				if mo:IsMechanical() and strCheck < (100/skipPx) then
					--The effect is diminished by target mo mass, material strength and distance
					local resistance = math.sqrt(math.abs(mo.Mass) + mo.Material.StructuralIntegrity + dist.Magnitude + 1) + actorCount;
					mo:SetNumberValue("PISDEMP", math.floor(mo:GetNumberValue("PISDEMP") + self.strength/resistance));
					mo:FlashWhite(20);
					if self.flashScreen and mo:IsPlayerControlled() then
						local screen = ActivityMan:GetActivity():ScreenOfPlayer(mo:GetController().Player);
						local white, black = 254, 245;
						FrameMan:FlashScreen(screen, white, 1000);
					end
					mo.Health = mo.Health - ((25*15) / resistance)
					table.insert(self.actorTable, mo);
					actorCount = actorCount + 1;
				end
			end
		end
	end
	for team = Activity.TEAM_1, Activity.MAXTEAMCOUNT - 1 do
		if SceneMan:AnythingUnseen(team) then
			local size = self.effectRadius * 0.6;
			local dots = 10;
			SceneMan:RestoreUnseenBox(self.Pos.X - (size * 0.5), self.Pos.Y - (size * 0.5), size, size, team);
			for i = 1, dots do
				local vector = Vector(size, 0):RadRotate(6.28 * i/dots);
				local startPos = self.Pos + vector;
				SceneMan:RestoreUnseenBox(startPos.X - (size * 0.5), startPos.Y - (size * 0.5), size, size, team);
			end
		end
	end
end
function Update(self)
	self.ToSettle = false;
	local actorCount = 0;
	for i = 1, #self.actorTable do
		if IsADoor(actor) then
			ToADoor(actor):OpenDoor();
		end
		if MovableMan:IsActor(self.actorTable[i]) then
			local actor = ToActor(self.actorTable[i]);
			if actor:NumberValueExists("PISDEMP") and actor.Status < Actor.DYING then
				actorCount = actorCount + 1;
				local numberValue = actor:GetNumberValue("PISDEMP");
				if numberValue > 0 then
					actor.Status = Actor.UNSTABLE;
					local ctrl = actor:GetController();
					if math.random(50) < numberValue then
						for i = 0, 29 do	--Go through and disable the gameplay-related controller states
							ctrl:SetState(i, false);
						end
					end
					local framesPerFlash = 6;
					if (numberValue/framesPerFlash) - math.floor(numberValue/framesPerFlash) == 0 then
						actor:FlashWhite(1);
					end
					actor:SetNumberValue("PISDEMP", numberValue - 1);
				else
					actor:RemoveNumberValue("PISDEMP");
				end
			end
		end
	end
	if actorCount == 0 then
		self.ToDelete = true;
	end
end