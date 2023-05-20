
function Create(self)
	---------------- AI variables start ----------------
	self.StuckTimer = Timer()
	self.HatchTimer = Timer()
	
	self.PlayerInterferedTimer = Timer()
	self.PlayerInterferedTimer:SetSimTimeLimitMS(500)
	
	if self.AIMode == Actor.AIMODE_BRAINHUNT then
		self.hoverAlt = self.Radius * 1.2
	elseif self.AIMode == Actor.AIMODE_BOMB then
		self.hoverAlt = self.Radius * 4
	else
		self.hoverAlt = self.Radius * 1.6	
	end

	self.LZpos = Vector(self.Pos.X, 100)
	self.Controller = self:GetController()
	self.LastAIMode = Actor.AIMODE_NONE
	
	if self.AIMode == Actor.AIMODE_DELIVER and self:IsInventoryEmpty() then
		self.AIMode = Actor.AIMODE_STAY	-- stop the craft from returning to orbit immediately
	end
	
	-- TODO: use self:GetLastAIWaypoint() as a LZ, that way the scene script can give orders to dropships
	
	-- The controller class
	PIDController = {}
	PIDController.mt = {__index = PIDController}
	function PIDController:New(p_in, i_in, d_in, last_in, integral_in)
		return setmetatable(
			{
				p = p_in,
				i = i_in,
				d = d_in,
				last = last_in or 0,
				integral = integral_in or 0
			},
			PIDController.mt)
	end
	
	function PIDController:Update(input, target)
		local err = input - target
		local change = input - self.last
		self.last = input
		self.integral = self.integral + err
		return self.p*err + self.i*self.integral + self.d*change
	end
	
	-- The controllers
	self.XposPID = PIDController:New(0.1, 0.00001, 1.5)
	self.YposPID = PIDController:New(0.1, 0, 2.5, self.LZpos.Y)
	self.AngPID = PIDController:New(10, 0.5, 2, self.RotAngle)
	
	---------------- AI variables end ----------------
	
	for attachable in self.Attachables do
		if string.find(attachable.PresetName, "Retro") then
			if string.find(attachable.PresetName, "Right") then
				self.retroThrusterRight = ToAEmitter(attachable)
				self.retroThrusterRight.EmitAngle = math.rad(0)
			elseif string.find(attachable.PresetName, "Left") then
				self.retroThrusterLeft = ToAEmitter(attachable)
				self.retroThrusterLeft.EmitAngle = math.rad(180)
			end
		end
	end	
	
end

--[[
local Craft = CreateACDropShip("CarryCorps He-88 Taurus LCC", "SPF.rte"); Craft.Team = 0; Craft.Pos = Vector(300, 0); Craft:AddInventoryItem(CreateTDExplosive("Grenade")); print(Craft.PresetName .. " reload = " .. Craft:ReloadScripts()); MovableMan:AddActor(Craft)
]]

function Update(self)
	local change = self.AngPID:Update(self.RotAngle + self.AngularVel*3, 0)
	if change > 15 then
		self:AddForce(Vector(0, change*25), Vector(53, 47))
	elseif change < -15 then
		self:AddForce(Vector(0, -change*25), Vector(-53, 47))
	end
	
	-- Engage cool thrusters for right/left movement, or automatic stabilization
	if self:IsPlayerControlled() then
		if self.Controller:IsState(Controller.MOVE_LEFT) or ((not self.Controller:IsState(Controller.MOVE_RIGHT)) and self.Vel.X > 1.2) then
		
			self.retroThrusterLeft:EnableEmission(false);
			self.retroThrusterRight:EnableEmission(true);
			
		elseif self.Controller:IsState(Controller.MOVE_RIGHT) or self.Vel.X < -1.2 then
		
			self.retroThrusterRight:EnableEmission(false);
			self.retroThrusterLeft:EnableEmission(true);
			
		else -- No left/right thrusters with no input
		
			self.retroThrusterRight:EnableEmission(false);
			self.retroThrusterLeft:EnableEmission(false);
			
		end	
	else
	
		if self.Vel.X > 1 then
		
			self.retroThrusterLeft:EnableEmission(false);
			self.retroThrusterRight:EnableEmission(true);
			
		elseif self.Vel.X < -1 then
		
			self.retroThrusterRight:EnableEmission(false);
			self.retroThrusterLeft:EnableEmission(true);
			
		else
		
			self.retroThrusterRight:EnableEmission(false);
			self.retroThrusterLeft:EnableEmission(false);
			
		end	
		
	end
	
end

function UpdateAI(self)
	if self.PlayerInterferedTimer:IsPastSimTimeLimit() then
		local FuturePos = self.Pos + self.Vel*20
		
		-- Make sure FuturePos is inside the scene
		if FuturePos.X > SceneMan.SceneWidth then
			if SceneMan.SceneWrapsX then
				FuturePos.X = FuturePos.X - SceneMan.SceneWidth
			else
				FuturePos.X = SceneMan.SceneWidth - self.Radius
			end
		elseif FuturePos.X < 0 then
			if SceneMan.SceneWrapsX then
				FuturePos.X = FuturePos.X + SceneMan.SceneWidth
			else
				FuturePos.X = self.Radius
			end
		end
		
		local Dist = SceneMan:ShortestDistance(FuturePos, self.LZpos, false)
		if math.abs(Dist.X) > 100 then
			if self.DeliveryState == ACraft.LAUNCH then
				self.LZpos.X = FuturePos.X
			else
				self.LZpos = SceneMan:MovePointToGround(FuturePos, self.hoverAlt, 5)
			end
		end
	end
	
	self.PlayerInterferedTimer:Reset()
	
	if self.AIMode ~= self.LastAIMode then
		self.LastAIMode = self.AIMode

		if self.AIMode == Actor.AIMODE_RETURN then
			self.DeliveryState = ACraft.LAUNCH
			self.LZpos = Vector(self.Pos.X, -500)	-- Go to orbit
		else -- Actor.AIMODE_STAY and Actor.AIMODE_DELIVER
			local FuturePos = self.Pos + self.Vel*20
			
			-- Make sure FuturePos is inside the scene
			if FuturePos.X > SceneMan.SceneWidth then
				if SceneMan.SceneWrapsX then
					FuturePos.X = FuturePos.X - SceneMan.SceneWidth
				else
					FuturePos.X = SceneMan.SceneWidth - self.Radius
				end
			elseif FuturePos.X < 0 then
				if SceneMan.SceneWrapsX then
					FuturePos.X = FuturePos.X + SceneMan.SceneWidth
				else
					FuturePos.X = self.Radius
				end
			end
			
			self.LZpos = SceneMan:MovePointToGround(FuturePos, self.hoverAlt, 5)
			self.DeliveryState = ACraft.FALL
		end
	end
	
	-- Control right/left movement
	local dist = SceneMan:ShortestDistance(self.Pos+self.Vel*10, self.LZpos, false).X
	local change = self.XposPID:Update(dist, 0)
	if change > 2 then
		self.Controller.AnalogMove = Vector(change/30, 0)
	elseif change < -2 then
		self.Controller.AnalogMove = Vector(change/30, 0)
	end

	-- Control up/down movement
	change = self.YposPID:Update(self.Vel.Y-(self.LZpos.Y-self.Pos.Y), 0)
	if change > 1 then
		self.AltitudeMoveState = ACraft.ASCEND
	elseif change < -1 then
		self.AltitudeMoveState = ACraft.DESCEND
	end

	-- Delivery Sequence logic
	if self.DeliveryState == ACraft.FALL then
		-- Don't descend if we have nothing to deliver
		if self:IsInventoryEmpty() then
			if self.AIMode ~= Actor.AIMODE_STAY then
				self.DeliveryState = ACraft.LAUNCH
				self.HatchTimer:Reset()
				self.LZpos.Y = -500	-- Go to orbit
			end
		else
			dist = SceneMan:ShortestDistance(self.Pos, self.LZpos, false).Magnitude
			if dist < 20 and math.abs(change) < 2 and self.Vel.Magnitude < 4 then	-- If we passed the hover check, start unloading
				if self.AIMode ~= Actor.AIMODE_STAY then
					self.DeliveryState = ACraft.UNLOAD
					self.HatchTimer:Reset()
				end
			else	-- Check for something in the way of our descent, and hover to the side to avoid it
				self.search = not self.search	-- Search every second update
				if self.search then
					local obstID = self:DetectObstacle(self.Radius * 7)
					if obstID > 0 then
						local MO = MovableMan:GetMOFromID(MovableMan:GetRootMOID(obstID))
						if MO.ClassName == "ACDropShip" or MO.ClassName == "ACRocket" then
							self.LZpos.X = self.LZpos.X + 15
							self.AltitudeMoveState = ACraft.HOVER
						end
					end
				else
					local Free = Vector()
					local Start = self.Pos + Vector(self.Radius, 0)
					local Trace = self.Vel * (self.Radius/4) + Vector(0,50)
					if PosRand() < 0.5 then
						Start.X = Start.X - self.Diameter
					end
					
					if SceneMan:CastStrengthRay(Start, Trace, 0, Free, 4, 0, true) then
						self.LZpos.X = self.Pos.X
						self.LZpos.Y = Free.Y - self.hoverAlt
					end
				end
			end
		end
	elseif self.DeliveryState == ACraft.UNLOAD then
		if self.HatchTimer:IsPastSimMS(1000) then	-- Start unloading if there's something to unload
			self.HatchTimer:Reset()
			
			-- Randomly choose a direction to be going when unloading
			if PosRand() > 0.5 then
				self.LZpos.X = self.LZpos.X - 50
			else
				self.LZpos.X = self.LZpos.X + 50
			end
			
			if SceneMan.SceneWrapsX then
				if self.LZpos.X > SceneMan.SceneWidth then
					self.LZpos.X = self.LZpos.X - SceneMan.SceneWidth
				elseif self.LZpos.X < 0 then
					self.LZpos.X = self.LZpos.X + SceneMan.SceneWidth
				end
			end
			
			self.LZpos = SceneMan:MovePointToGround(Vector(self.LZpos.X, self.LZpos.Y - self.Diameter), self.hoverAlt, 6)
			self.Controller:SetState(Controller.PRESS_FACEBUTTON, true)
			self.DeliveryState = ACraft.FALL
		end
	elseif self.DeliveryState == ACraft.LAUNCH then
		if self.HatchTimer:IsPastSimMS(1000) then
			self.HatchTimer:Reset()
			self:CloseHatch()
		end

		-- Check for something in the way of our ascent, and hover to the side to avoid it
		self.search = not self.search	-- Search every second update
		if self.search then
			local obstID = self:DetectObstacle(self.Radius * 7)
			if obstID > 0 then
				local MO = MovableMan:GetMOFromID(MovableMan:GetRootMOID(obstID))
				if MO.ClassName == "ACDropShip" or MO.ClassName == "ACRocket" then
					self.LZpos.X = self.LZpos.X - 15
					self.AltitudeMoveState = ACraft.HOVER
				end
			end
		end
	end

	-- If we are hopelessly stuck, self destruct
	if self.Vel.Magnitude > 1 then
		self.StuckTimer:Reset()
	elseif self.StuckTimer:IsPastSimMS(20000) then
		--self:GibThis()
	end

	-- Input translation
	if self.AltitudeMoveState == ACraft.ASCEND then
		self.Controller:SetState(Controller.MOVE_UP, true)
	elseif self.AltitudeMoveState == ACraft.DESCEND then
		self.Controller:SetState(Controller.MOVE_DOWN, true)
	else
		self.Controller:SetState(Controller.MOVE_UP, false)
		self.Controller:SetState(Controller.MOVE_DOWN, false)
	end
end
