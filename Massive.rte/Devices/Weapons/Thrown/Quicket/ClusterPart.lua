function Create(self)
	--Some will pass through objects and cause havoc
	self.HitsMOs = math.random() < 0.5;
	self.ageLimit = math.random(50, 500);
end
function Update(self)
	if self.Age > self.ageLimit then
		self:GibThis();
	end
end