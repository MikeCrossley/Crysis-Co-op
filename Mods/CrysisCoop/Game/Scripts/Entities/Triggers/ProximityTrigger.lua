----------------------------------------------------------------------------
--
-- Description :		Delayed proxymity trigger
--
-- Create by Alberto :	03 March 2002
--
----------------------------------------------------------------------------
ProximityTrigger = {
	type = "Trigger",

	Properties = {
		DimX = 5,
		DimY = 5,
		DimZ = 5,
		bEnabled=1,
		EnterDelay=0,
		ExitDelay=0,
		bOnlyPlayer=1,
		bOnlyMyPlayer=0,
		bOnlyAI = 0,
		bOnlySpecialAI = 0,
		OnlySelectedEntity = "None",
		bKillOnTrigger=0,
		bTriggerOnce=0,
		ScriptCommand="",
		PlaySequence="",		
--		aianchorAIAction = "",
		TextInstruction= "",
		bActivateWithUseButton=0,
		bInVehicleOnly=0,		
		bOnlyOneEntity = 0,
		ReferenceName = "",	
	},
	States = {"Inactive","Empty","Occupied","OccupiedUse" },
	
	Editor={
		Model="Editor/Objects/T.cgf",
		Icon="Trigger.bmp",
		ShowBounds = 1,
	},
	
	trigger = true,
	
}

function ProximityTrigger:OnPropertyChange()
	self:OnReset();
end

function ProximityTrigger:OnInit()
	self:SetUpdatePolicy( ENTITY_UPDATE_PHYSICS );

--	self.Who = nil;
--	self.Entered = 0;
--	self.bLocked = 0;
--	self.bTriggered = 0;
--	self.EnterCount =0;
--	self.UpdateCounter = 0;
	self:OnReset();
end

function ProximityTrigger:OnShutDown()
end

function ProximityTrigger:OnSave(tbl)
	tbl.bTriggered = self.bTriggered
	tbl.Who = self.Who
	tbl.Entered = self.Entered
end


function ProximityTrigger:OnLoad(tbl)
	self.bTriggered = tbl.bTriggered
	self.Who = tbl.Who
	self.Entered = tbl.Entered
end

function ProximityTrigger:OnReset()
	self:KillTimer(0);
	self.Who = nil;
	self.Entered = 0;
	self:ActivateOutput("IsInside", self.Entered)
	self.bLocked = 0;
	self.bTriggered = 0;
	self.EnterCount =0;
	self.UpdateCounter = 0;
	self.bUseOrderEnabled = true;
	
	local Min = { x=-self.Properties.DimX/2, y=-self.Properties.DimY/2, z=-self.Properties.DimZ/2 };
	local Max = { x=self.Properties.DimX/2, y=self.Properties.DimY/2, z=self.Properties.DimZ/2 };
	self:SetTriggerBBox( Min, Max );
	--self:Log( "BBox:"..Min.x..","..Min.y..","..Min.z.."  "..Max.x..","..Max.y..","..Max.z );

	if(self.Properties.bEnabled==1)then
		self:GotoState( "Empty" );
	else
		self:GotoState( "Inactive" );
	end
end

function ProximityTrigger:Event_Enter( sender )
	-- to make it not trigger when event sent to inactive tringger
	
	if (self:GetState( ) == "Inactive") then return end
	if ((self.Entered ~= 0 and self.Properties.bOnlyOneEntity==1)) then
		return
	end
	if (self.Properties.bTriggerOnce == 1 and self.bTriggered == 1) then
		return
	end
	self.bTriggered = 1;
	self.Entered = 1;
	self:ActivateOutput("IsInside",self.Entered );
	-- Trigger script command on enter.
	if(self.Properties.ScriptCommand and self.Properties.ScriptCommand~="")then
		local f = loadstring(self.Properties.ScriptCommand);
		if (f~=nil) then
			f();
		end
	end
	if(self.Properties.PlaySequence~="")then
		Movie.PlaySequence( self.Properties.PlaySequence );
	end

	if (self.Who~=nil) then
		self:ActivateOutput("Sender", self.Who.id);
	end
	BroadcastEvent( self,"Enter" );
end


function ProximityTrigger:Event_Leave( sender )
	if (self.Entered == 0) then
		return
	end
	self.Entered = 0;
	if (self.Who~=nil) then
		self:ActivateOutput("Sender", self.Who.id);
	end
	self:ActivateOutput("IsInside",self.Entered );
	BroadcastEvent( self,"Leave" );


	if(self.Properties.bTriggerOnce==1)then
		self:GotoState("Inactive");
	end

end

function ProximityTrigger:Event_Enable( sender )
	self:GotoState("Empty")
	self.Who = sender;
	BroadcastEvent( self,"Enable" );
end

function ProximityTrigger:Event_Disable( sender )
	self:GotoState( "Inactive" );
	--AI:RegisterWithAI(self.id, 0);
	self.Who = sender;
	BroadcastEvent( self,"Disable" );
end

function ProximityTrigger:Log( msg )
	System.Log( msg );
end

-- Check if source entity is valid for triggering.
function ProximityTrigger:IsValidSource( entity )
	local Properties = self.Properties;

	if (Properties.bOnlyPlayer ~= 0 and entity.type ~= "Player") then
		return false;
	end

	if (Properties.bOnlySpecialAI ~= 0 and entity.ai ~= nil and entity.Properties.special==0) then 
		return false;
	end

	-- if Only for AI, then check
	if (Properties.bOnlyAI ~=0 and entity.ai == nil) then
		return false;
	end

		-- Ignore if not my player.
	if (Properties.bOnlyMyPlayer ~= 0 and entity ~= g_localActor) then
		return false;
	end

	-- if only in vehicle - check if collider is in vehicle
	if (Properties.bInVehicleOnly ~= 0 and not entity.vehicle) then
		return false;
	end

	if(Properties.OnlySelectedEntity~="None" and Properties.OnlySelectedEntity~="" and entity:GetName()~=Properties.OnlySelectedEntity) then
		return false;
	end
	--if (entity.cnt.health <= 0) then
	--	return false;
	--end
	self.EnterCount = self.EnterCount+1;
	return true;
end


-------------------------------------------------------------------------------
-- Inactive State -------------------------------------------------------------
-------------------------------------------------------------------------------
ProximityTrigger.Inactive =
{
	OnBeginState = function( self )
		--AI:RegisterWithAI(self.id, 0);
	end,
	OnEndState = function( self )
	end,
}
-------------------------------------------------------------------------------
-- Empty State ----------------------------------------------------------------
-------------------------------------------------------------------------------
ProximityTrigger.Empty =
{
	-------------------------------------------------------------------------------
	OnBeginState = function( self )
		self.Who = nil;
		self.UpdateCounter = 0;
		self.Entered = 0;
		self:ActivateOutput("IsInside",self.Entered );
		if (self.Properties.aianchorAIAction~="") then
			--AI:RegisterWithAI(self.id, AIAnchor[self.Properties.aianchorAIAction]);
		end
  	self:InvalidateTrigger();
	end,

	OnTimer = function( self )
		self:GotoState( "Occupied" );
	end,

	-------------------------------------------------------------------------------
	OnEnterArea = function( self,entity,areaId )
		--System.Log("EnterArea");
		if (not self:IsValidSource(entity) ) then
			return
		end
		
		if (entity.ai==nil) then
			if (self.Properties.bActivateWithUseButton~=0) then
				self.Who = entity;
				self:GotoState( "OccupiedUse" );
				do return end;
			end
		end
		
		if (self.Properties.EnterDelay > 0) then
			if (self.Who == nil) then
				-- Not yet triggered.
				self.Who = entity;
				self:SetTimer( 0,self.Properties.EnterDelay*1000 );
			end
		else
			self.Who = entity;
			self:GotoState( "Occupied" );
		end
	end,


}

-------------------------------------------------------------------------------
-- Occupied State ----------------------------------------------------------------
-------------------------------------------------------------------------------
ProximityTrigger.Occupied =
{
	-------------------------------------------------------------------------------
	OnBeginState = function( self )
		self:Event_Enter(self.Who);

		if(self.Properties.bKillOnTrigger==1)then
			Server:RemoveEntity(self.id);
		end
	end,

	-------------------------------------------------------------------------------
	OnTimer = function( self )
		self:Event_Leave( self,self.Who );
		if(self.Properties.bTriggerOnce~=1)then
			self:GotoState("Empty");
		end
	end,

	-------------------------------------------------------------------------------
	OnLeaveArea = function( self,entity,areaId )
		-- Ignore if disabled.
		--add a very small delay(so is immediate)
		if (not self:IsValidSource(entity) ) then
			return
		end
		
		if(self.Properties.ExitDelay==0) then
			self.Properties.ExitDelay=0.01;
		end
		self:SetTimer( 0,self.Properties.ExitDelay*1000 );
	end,
}

-------------------------------------------------------------------------------
-- OccupiedText State ---------------------------------------------------------
-------------------------------------------------------------------------------
ProximityTrigger.OccupiedUse =
{
	-------------------------------------------------------------------------------
	OnBeginState = function( self )
		self.Who.actor:SetExtensionParams( "Interactor", {locker = self.id, lockId = self.id, lockIdx = 1} )
	end,
	-------------------------------------------------------------------------------
	OnEndState = function( self )
		self.Who.actor:SetExtensionParams( "Interactor", {locker = self.id, lockId = NULL_ENTITY, lockIdx = 0} )
		self:Activate(0);
	end,
	-------------------------------------------------------------------------------
	OnUsed = function( self, user)
		if (self.Properties.EnterDelay > 0) then
			self:SetTimer( 0,self.Properties.EnterDelay*1000 );
		else
--			System.Log("Occupied 2");
			self:GotoState( "Occupied" );
		end
	end,
	-------------------------------------------------------------------------------
	OnTimer = function( self )
--		System.Log("Occupied 1");
		self:GotoState( "Occupied" );
	end,
	-------------------------------------------------------------------------------
	GetUsableMessage = function( self, idx )
		return self.Properties.TextInstruction or "<unset TextInstruction>"
	end,
	-------------------------------------------------------------------------------
	OnLeaveArea = function( self,entity,areaId )
		if (self.Who == entity) then
			self:GotoState( "Empty" );
		end
	end,
}

ProximityTrigger.FlowEvents =
{
	Inputs =
	{
		Disable = { ProximityTrigger.Event_Disable, "bool" },
		Enable = { ProximityTrigger.Event_Enable, "bool" },
		Enter = { ProximityTrigger.Event_Enter, "bool" },
		Leave = { ProximityTrigger.Event_Leave, "bool" },
	},
	Outputs =
	{
		IsInside = "bool",
		Disable = "bool",
		Enable = "bool",
		Enter = "bool",
		Leave = "bool",
		Sender = "entity",
	},
}
