function Create(self)
	self.strength = self.Mass * 1.3;
	self.range = self.Mass * 0.16;
	for i = 1 , MovableMan:GetMOIDCount() - 1 do
		local mo = MovableMan:GetMOFromID(i);
		if mo and mo.PinStrength == 0 then
			local dist = SceneMan:ShortestDistance(self.Pos, mo.Pos, SceneMan.SceneWrapsX);
			if dist.Magnitude < self.range then
				local strSumCheck = SceneMan:CastStrengthSumRay(self.Pos, self.Pos + dist, 3, rte.airID);
				if strSumCheck < self.strength then
					local massFactor = math.sqrt(1 + math.abs(mo.Mass));
					local distFactor = 1 + dist.Magnitude * 0.1;
					local forceVector =	dist:SetMagnitude((self.strength - strSumCheck)/distFactor);
					mo.Vel = mo.Vel + ((forceVector/massFactor) / 4);
					mo.AngularVel = mo.AngularVel - (forceVector.X/(massFactor + math.abs(mo.AngularVel)) / 2);
					mo:AddForce(forceVector * massFactor, Vector());
					-- Add some additional points damage to actors
					if IsActor(mo) then
						local actor = ToActor(mo);
						local impulse = ((forceVector.Magnitude * 3) * self.strength/massFactor) - actor.ImpulseDamageThreshold;
						local damage = impulse/(actor.GibImpulseLimit * 0.1 + actor.Material.StructuralIntegrity * 10);
						actor.Health = damage > 0 and actor.Health - damage or actor.Health;
						actor.Status = (actor.Status == Actor.STABLE and damage > (actor.Health * 0.4)) and Actor.UNSTABLE or actor.Status;
						if actor.Health < 5 and damage > 5 then
							for attachable in actor.Attachables do
								local part = ToAttachable(attachable)
								if math.random(0, 100) < 10 then
									ToMOSRotating(actor):RemoveAttachable(part, true, true)
								elseif math.random(0, 100) < 20 then
									part:GibThis();
								end
							end
						end
					end
				end
			end
		end	
	end
	self.ToDelete = true;
end
