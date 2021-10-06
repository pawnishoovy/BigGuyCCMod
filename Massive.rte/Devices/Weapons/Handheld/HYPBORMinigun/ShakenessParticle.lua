function Create(self)

	self.shakeTable = {}
	for actor in MovableMan.Actors do
		actor = ToActor(actor)
		table.insert(self.shakeTable, actor);
	end
	
	self.shake = 100
	
	self.ToSettle = false
end
function Update(self)
	local factor = math.min(self.Age/14500, 1)
	
	-- Shake
	if self.shakeTable then
		for i = 1, #self.shakeTable do
			local actor = self.shakeTable[i];
			if actor and IsActor(actor) then
				actor = ToActor(actor)
				
				actor.ViewPoint = actor.ViewPoint + Vector(self.shake * RangeRand(-1, 1), self.shake * RangeRand(-1, 1)) * factor;
			end
		end
	end
	
	self.ToSettle = false
	--self.ToDelete = true;
end