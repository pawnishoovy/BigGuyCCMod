function Create(self)

	self.effectRadius = 150
	
	self.actorTable = {};
	
	self.updateTimer = Timer();
	
	for actor in MovableMan.Actors do
		local dist = SceneMan:ShortestDistance(self.Pos, actor.Pos, SceneMan.SceneWrapsX);
		if dist.Magnitude < self.effectRadius then
			local skipPx = 1 + (dist.Magnitude * 0.01);
			local strCheck = SceneMan:CastStrengthSumRay(self.Pos, self.Pos + dist, skipPx, rte.airID);
			if ToActor(actor):IsOrganic() and strCheck < (100/skipPx) then
				table.insert(self.actorTable, actor);
			end
		end
	end

end

function Update(self)
	
	self.ToSettle = false;

	if self.updateTimer:IsPastSimMS(500) then
	
		self.actorTable = {};
	
		self.updateTimer:Reset();

		for actor in MovableMan.Actors do
			local dist = SceneMan:ShortestDistance(self.Pos, actor.Pos, SceneMan.SceneWrapsX);
			if dist.Magnitude < self.effectRadius then
				local skipPx = 1 + (dist.Magnitude * 0.01);
				local strCheck = SceneMan:CastStrengthSumRay(self.Pos, self.Pos + dist, skipPx, rte.airID);
				if ToActor(actor):IsOrganic() and strCheck < (100/skipPx) then
					table.insert(self.actorTable, actor);
				end
			end
		end
	end
	
	for i = 1, #self.actorTable do
		if MovableMan:IsActor(self.actorTable[i]) then
			local actor = ToActor(self.actorTable[i]);
			actor.Health = actor.Health - (TimerMan.DeltaTimeSecs * 0.8)
		end
	end	
	
	
end