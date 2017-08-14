--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2005.
--------------------------------------------------------------------------
--
--	Description: BasicAIEvents - moved out all the events from BasicAI
--	
--  
--------------------------------------------------------------------------
--  History:
--  - 13/06/2005   15:36 : created by Kirill Bulatsev
--
--------------------------------------------------------------------------


BasicAIEvent =
{

}

MakeUsable(BasicAIEvent);


--
--
--------------------------------------------------------------------------------------------------------
function BasicAIEvent:Event_Dead( params )
	BroadcastEvent(self, "Dead");
end


--
--
--------------------------------------------------------------------------------------------------------
function BasicAIEvent:Event_WakeUp( params )

	if (self.actor:GetPhysicalizationProfile() == "sleep") then
		self.actor:StandUp();
	end
end

--
--
--------------------------------------------------------------------------------------------------------
function BasicAIEvent:Event_Sleep( params )
--System.Log(">>>>>>> BasicAIEvent:Event_Sleep "..self:GetName());
	if(not self.isFallen) then
		BroadcastEvent(self, "Sleep");
	end	
	self.isFallen = 1;
end


--------------------------------------------------------------------------------------------------------
function BasicAIEvent:Event_Enabled( params )
	BroadcastEvent(self, "Enabled");
end


--
--
--------------------------------------------------------------------------------------------------------
function BasicAIEvent:Event_OnAlert( params )
	BroadcastEvent( self, "OnAlert" );
end

--
--
--------------------------------------------------------------------------------------------------------
function BasicAIEvent:Event_Disable(params)
	--hide does enable/disable physics as well
	self:Hide(1)
	--self:EnablePhysics(0);
	self:TriggerEvent(AIEVENT_DISABLE);
	--AI.LogEvent(" >>> BasicAI:Event_Disable  "..self:GetName());
end
 
--
--
--------------------------------------------------------------------------------------------------------
function BasicAIEvent:Event_Enable(params)
	if (not self:IsDead() ) then 
		-- hide does enable/disable physics as well
		self:Hide(0)
		self:Event_Enabled(self);
		if(self.voiceTable and self.PlayIdleSound) then 
			if (self.cloaked == 1 and self.voiceTable.idleCloak) then
				self:PlayIdleSound(self.voiceTable.idleCloak);
			elseif(self.voiceTable.idle) then 
				self:PlayIdleSound(self.voiceTable.idle);
			end
		end
	end
end


--
--	This event will kill the actor 
--------------------------------------------------------------------------------------------------------
function BasicAIEvent:Event_Kill(params)
	--Log("BasicAIEvent:Event_Kill");
	if (not self:IsDead()) then 
		g_gameRules:CreateHit(self.id,self.id,self.id,100000,nil,nil,nil,"event");
	end
end


---------------------------------------------------------------------------------------------------------
--
--
--			below are old events - to-be-removed candidates
--
---------------------------------------------------------------------------------------------------------
--
--
--------------------------------------------------------------------------------------------------------
function BasicAIEvent:Event_Follow(sender)
	BroadcastEvent(self, "Follow");
	local newGroupId;
	if(sender.Who and sender.Who.id and sender.Who.id~=NULL_ENTITY) then -- it's a trigger
		newGroupId = AI.GetGroupOf(sender.Who.id);
	else
		newGroupId = AI.GetGroupOf(sender.id);
	end
	AI.ChangeParameter(self.id,AIPARAM_GROUPID,newGroupId);
	AI.Signal(SIGNALFILTER_SENDER,0,"FOLLOW_LEADER",self.id);
end

--
--
--------------------------------------------------------------------------------------------------------
function BasicAIEvent:Event_Test(sender)
--
--	AI.SetPFProperties(self.id, AIPATH_HUMAN);
--do return end
--	self:StartAnimation(0,"swim_idle_nw_01",4,.1);
--do return end
--
--	local point = System.GetEntityByName("place");
--	if (point) then 
--		g_SignalData.point = point:GetWorldPos();
--		AI.Signal(SIGNALFILTER_SENDER, 0, "ORDER_MOVE", self.id, g_SignalData);
--	end
--		
	g_SignalData.fValue = 2;
	AI.Signal(SIGNALFILTER_LEADER,0,"OnScaleFormation",self.id,g_SignalData);
end

--
--
--------------------------------------------------------------------------------------------------------
function BasicAIEvent:Event_TestStealth(sender)
	AI.SetPFProperties(self.id, AIPATH_HUMAN_COVER);
end


--function BasicAIEvent:Event_AlertStatus(sender)
--	AI.LogEvent("ALERT STATUS CHANGING TO "..sender.Properties.ReferenceName);
--	AI.Signal(SIGNALFILTER_LEADER, 0, "OnAlertStatus_"..sender.Properties.ReferenceName, self.id);
--end



BasicAIEvent.FlowEvents =
{
	Inputs =
	{
		Used = { BasicAIEvent.Event_Used, "bool" },
		EnableUsable = { BasicAIEvent.Event_EnableUsable, "bool" },
		DisableUsable = { BasicAIEvent.Event_DisableUsable, "bool" },
		
		Disable = { BasicAIEvent.Event_Disable, "bool" },
		Enable = { BasicAIEvent.Event_Enable, "bool" },
		Kill = { BasicAIEvent.Event_Kill, "bool" },
		
		WakeUp = { BasicAIEvent.Event_WakeUp, "bool" },		-- fall-and-play stand up
	},
	Outputs =
	{
		Used = "bool",

		Dead = "bool",
		OnAlert = "bool",
		Sleep = "bool",				-- fall-and-play falling
--		Awake = "bool",
		
		Enabled = "bool",
	},
}
