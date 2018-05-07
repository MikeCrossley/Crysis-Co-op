----------------------------------------------------------------------------------------------------
--  Crytek Source File.
--  Copyright (C), Crytek Studios, 2001-2004.
----------------------------------------------------------------------------------------------------
--  $Id$
--  $DateTime$
--  Description: Cinematic Trigger
--
----------------------------------------------------------------------------------------------------
--  History:
--  - 30:5:2005   19:16 : Created by Márcio Martins
--
----------------------------------------------------------------------------------------------------
CinematicTrigger =
{
	Properties =
	{
		fDimX							= 1,
		fDimY							= 1,
		fDimZ							= 1,
		bEnabled					= 1,
		ScriptCommand			= "",
		Sequence					= "",
		bTriggerOnce			= 0,
		fMaxDistance			= 200,
		fMinDistance			= 0,
		fMinVisibleTime		= 0.5,
		fDelay						= 0,
		fCheckTimer				= 0.25,
		fZoomMinimum			= 1,
	},
	
	VISIBILITY_TIMER_ID = 1,
	DELAY_TIMER_ID			= 2,
	
	Editor={
		Model="Editor/Objects/T.cgf",
		Icon="Trigger.bmp",
		ShowBounds = 1,
	},
};

function CinematicTrigger:OnLoad(props)
	self:OnReset()
	self.triggered = props.triggered
	self.last_visible_time = props.last_visible_time
end

function CinematicTrigger:OnSave(props)
	props.triggered = self.triggered
	props.last_visible_time = self.last_visible_time
end

----------------------------------------------------------------------------------------------------
function CinematicTrigger:Event_Enable(sender)
	if ((not self.tiggered) or (tonumber(self.Properties.bTriggerOnce) == 0)) then
		self:SetTimer(self.VISIBILITY_TIMER_ID, self.Properties.fCheckTimer*1000);
		self.last_visible_time = nil;
	end
end


----------------------------------------------------------------------------------------------------
function CinematicTrigger:Event_Disable(sender)
	self:KillTimer(self.VISIBILITY_TIMER_ID);
end


----------------------------------------------------------------------------------------------------
function CinematicTrigger:Event_Visible(sender)
	BroadcastEvent(self, "Visible");

	self:SetTimer(self.DELAY_TIMER_ID, self.Properties.fDelay*1000);
end


----------------------------------------------------------------------------------------------------
function CinematicTrigger:Event_Invisible(sender)
	BroadcastEvent(self, "Invisible");
	
	if (tonumber(self.Properties.bTriggerOnce) == 0) then
		self.triggered = nil;
	end
end


----------------------------------------------------------------------------------------------------
function CinematicTrigger:Event_Trigger(sender)
	self.triggered = true;

	if (tonumber(self.Properties.bTriggerOnce) ~= 0) then
		self:KillTimer(self.VISIBILITY_TIMER_ID);
	end
	
	if(string.len(self.Properties.ScriptCommand) > 0) then
		dostring(self.Properties.ScriptCommand);
	end

	if(string.len(self.Properties.Sequence) > 0) then
		Movie.PlaySequence(self.Properties.Sequence);
	end
	
	BroadcastEvent(self, "Trigger");
end


----------------------------------------------------------------------------------------------------
function CinematicTrigger:IsVisible()
	local point0 = g_Vectors.temp_v1;
	local point1 = g_Vectors.temp_v2;
	local point2 = g_Vectors.temp_v3;
	local point3 = g_Vectors.temp_v4;
	
	self.pos = self:GetWorldPos(self.pos);
	local p = self.pos;
	
	local dx = self.Properties.fDimX*0.5;
	local dy = self.Properties.fDimY*0.5;
	local dz = self.Properties.fDimZ*0.5;
	
	point0.x = p.x+dx; point0.y = p.y+dy; point0.z = p.z+dz;
	point1.x = p.x+dx; point1.y = p.y+dy; point1.z = p.z-dz;
	point2.x = p.x+dx; point2.y = p.y-dy; point2.z = p.z+dz;
	point3.x = p.x+dx; point3.y = p.y-dy; point3.z = p.z-dz;
	
	if (System.IsPointVisible(point0) and
			System.IsPointVisible(point1) and
			System.IsPointVisible(point2) and
			System.IsPointVisible(point3)) then
		point0.x = p.x-dx; point0.y = p.y+dy; point0.z = p.z+dz;
		point1.x = p.x-dx; point1.y = p.y+dy; point1.z = p.z-dz;
		point2.x = p.x-dx; point2.y = p.y-dy; point2.z = p.z+dz;
		point3.x = p.x-dx; point3.y = p.y-dy; point3.z = p.z-dz;
		
		if (System.IsPointVisible(point0) and
				System.IsPointVisible(point1) and
				System.IsPointVisible(point2) and
				System.IsPointVisible(point3)) then
		
			return true;
		end
	end
	
	return false;
end


----------------------------------------------------------------------------------------------------
function CinematicTrigger:CheckZoom()
	if(self.Properties.fZoomMinimum>1.0)then
		local fov= System.GetViewCameraFov()/math.pi*180.0;
		local client=System.GetCVar("cl_fov");
		local zoom=client/fov;
		if(zoom>=self.Properties.fZoomMinimum)then
			return true;
		else
			return false;
		end;
	else
		return true
	end;
end;

----------------------------------------------------------------------------------------------------
function CinematicTrigger:IsInRange()
	if (not g_localActor) then
		return;
	end
	
	local pos = self:GetWorldPos(g_Vectors.temp_v1);
	local actorpos = g_localActor:GetWorldPos(g_Vectors.temp_v2);
	local distance = vecDistanceSq(pos, actorpos);
	local mind = self.Properties.fMinDistance;
	local maxd = self.Properties.fMaxDistance;
	
	if ((distance < mind*mind) or (distance > maxd*maxd)) then
		return false;
	end
	
	return true;
end


----------------------------------------------------------------------------------------------------
function CinematicTrigger:OnReset()
	local bbmin = g_Vectors.temp_v1;
	local bbmax = g_Vectors.temp_v2;
	
	local dx = self.Properties.fDimX*0.5;
	local dy = self.Properties.fDimY*0.5;
	local dz = self.Properties.fDimZ*0.5;
	
	bbmin.x = -dx; bbmin.y = -dy; bbmin.z = -dz;
	bbmax.x = dx; bbmax.y = dy; bbmax.z = dz;
	
	self.triggered = nil;

	self:SetTriggerBBox(bbmin, bbmax);
	self:Activate(0);
	if (self.Properties.bEnabled == 1) then
		self:SetTimer(self.VISIBILITY_TIMER_ID, self.Properties.fCheckTimer*1000);
	else
		self:KillTimer(self.VISIBILITY_TIMER_ID);
	end
end


----------------------------------------------------------------------------------------------------
function CinematicTrigger:OnPropertyChange()
	self:OnReset();
end


----------------------------------------------------------------------------------------------------
function CinematicTrigger:OnInit()
	self:OnReset();
end


----------------------------------------------------------------------------------------------------
function CinematicTrigger:OnTimer(timerId, time)
	if (timerId == self.VISIBILITY_TIMER_ID) then
		if (self:IsInRange() and self:IsVisible() and self:CheckZoom()) then
			if (not self.triggered) then
				if (not self.last_visible_time) then
					self.last_visible_time = _time;
				end
	
				if (_time-self.last_visible_time > self.Properties.fMinVisibleTime) then
					self:Event_Visible();
				end
			end
		else
			if (self.last_visible_time) then
				self:Event_Invisible();
			end
			self.last_visible_time = nil;
		end
		self:SetTimer(self.VISIBILITY_TIMER_ID, self.Properties.fCheckTimer*1000);
	elseif (timerId == self.DELAY_TIMER_ID) then
		self:Event_Trigger(self);
	end
end

CinematicTrigger.FlowEvents =
{
	Inputs =
	{
		Disable = { CinematicTrigger.Event_Disable, "bool" },
		Enable = { CinematicTrigger.Event_Enable, "bool" },
		Invisible = { CinematicTrigger.Event_Invisible, "bool" },
		Visible = { CinematicTrigger.Event_Visible, "bool" },
		Trigger = { CinematicTrigger.Event_Trigger, "bool" },
	},
	Outputs =
	{
		Disable = "bool",
		Enable = "bool",
		Invisible = "bool",
		Visible = "bool",
		Trigger = "bool",
	},
}
