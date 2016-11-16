--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2006.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Switch entity for both FG and Prefab use.
--  
--------------------------------------------------------------------------
--  History:
--  - 19:5:2006 : Created by Sascha Gundlach
--
--------------------------------------------------------------------------

Switch = {
	Client = {},
	Server = {},
	Properties = {
		fileModel 					= "objects/library/installations/electric/lightswitch/lightswitch_local1.cgf",
		Switch 							= "",
		ModelSubObject			= "",
		fileModelDestroyed	= "",
		DestroyedSubObject	= "",
		fHealth = 100,
		bUsable	= 1,
		UseMessage = "USE",
		bTurnedOn = 1,
		Physics = {
			bRigidBody=0,
			bRigidBodyActive = 0,
			bRigidBodyAfterDeath =1,
			bResting = 1,
			Density = -1,
			Mass = 50,
		},
		Sound = {
			soundTurnOnSound = "",
			soundTurnOffSound = "",
		},
		SwitchPos = {
			bShowSwitch = 1,
			On = 45,
			Off = -45,
		},
		SmartSwitch =	{
			bUseSmartSwitch=0,
			Entity = "",
			TurnedOnEvent = "",
			TurnedOffEvent = "",
		},
		Breakage =
		{
			fLifeTime = 20,
			fExplodeImpulse = 0,
			bSurfaceEffects = 1,
		},
		Destruction =	{
			bExplode				= 1,
			Effect					= "explosions.rocket.wood",
			EffectScale			= 0.2,
			Radius					= 1,
			Pressure				= 12,
			Damage					= 0,
			Decal						= "",
			Direction				= {x=0, y=0.0, z=-1},
		},
	},
		Editor={
		Icon = "Item.bmp",
		IconOnTop=1,
	},
	States = {"TurnedOn","TurnedOff","Destroyed"},
	fCurrentSpeed = 0,
	fDesiredSpeed = 0,
	LastHit =
	{
		impulse = {x=0,y=0,z=0},
		pos = {x=0,y=0,z=0},
	},
	shooterId = nil,
}

Net.Expose {
	Class = Switch,
	ClientMethods = {
		ClUpdateEnabled = { RELIABLE_UNORDERED, POST_ATTACH, BOOL },
	},
	ServerMethods = {
		SvRequestTurnOn = { RELIABLE_UNORDERED, POST_ATTACH, ENTITYID },
	},
	ServerProperties = {
	},
};


function Switch:OnPropertyChange()
	self:OnReset();
end;

function Switch:OnSave(tbl)
	tbl.switch=self.switch;
end;

function Switch:OnLoad(tbl)
	self.switch=tbl.switch;
end;

function Switch:OnReset()
	local props=self.Properties;
	self.health=props.fHealth;
	self.usable=self.Properties.bUsable;
	if(not EmptyString(props.fileModel))then
		self:LoadSubObject(0,props.fileModel,props.ModelSubObject);
	end;
	if(not EmptyString(props.fileModelDestroyed))then
		self:LoadSubObject(1, props.fileModelDestroyed,props.DestroyedSubObject);
	elseif(not EmptyString(props.DestroyedSubObject))then
		self:LoadSubObject(1,props.fileModel,props.DestroyedSubObject);
	end;
	self:SetCurrentSlot(0);
	self:PhysicalizeThis(0);
	if(not EmptyString(self.Properties.Switch))then
		self:SpawnSwitch();
	end;
	if(self.Properties.bTurnedOn==1)then
		self:GotoState("TurnedOn");
	else
		self:GotoState("TurnedOff");
	end;
end;

function Switch:PhysicalizeThis(slot)
	local physics = self.Properties.Physics;
	EntityCommon.PhysicalizeRigid( self,slot,physics,1 );
end;

function Switch.Client:OnHit(hit, remote)
	CopyVector(self.LastHit.pos, hit.pos);
	CopyVector(self.LastHit.impulse, hit.dir);
	self.LastHit.impulse.x = self.LastHit.impulse.x * hit.damage;
	self.LastHit.impulse.y = self.LastHit.impulse.y * hit.damage;
	self.LastHit.impulse.z = self.LastHit.impulse.z * hit.damage;
end

function Switch.Server:OnHit(hit)
	self.shooterId=hit.shooterId;
	self.health=self.health-hit.damage;
	BroadcastEvent( self,"Hit" );
	if(self.health<=0)then
		self:GotoState("Destroyed");
	end;
end;

function Switch:Explode()
	local props=self.Properties;
	local hitPos = self.LastHit.pos;
	local hitImp = self.LastHit.impulse;
	self:BreakToPieces( 
		0, 0,
		props.Breakage.fExplodeImpulse,
		hitPos,
		hitImp,
		props.Breakage.fLifeTime, 
		props.Breakage.bSurfaceEffects
	);
	if(NumberToBool(self.Properties.Destruction.bExplode))then
		local explosion=self.Properties.Destruction;
 		g_gameRules:CreateExplosion(self.shooterId,self.id,explosion.Damage,self:GetWorldPos(),explosion.Direction,explosion.Radius,nil,explosion.Pressure,explosion.HoleSize,explosion.Effect,explosion.EffectScale);	
	end;
	self:SetCurrentSlot(1);
	if(props.Physics.bRigidBodyAfterDeath==1)then
		local tmp=props.Physics.bRigidBody;
		props.Physics.bRigidBody=1;
		self:PhysicalizeThis(1);
		props.Physics.bRigidBody=tmp;
	else
		self:PhysicalizeThis(1);
	end;
	self:RemoveDecals();
	self:AwakePhysics(1);
	self:OnDestroy();
end;

function Switch:SetCurrentSlot(slot)
	if (slot == 0) then
		self:DrawSlot(0, 1);
		self:DrawSlot(1, 0);
	else
		self:DrawSlot(0, 0);
		self:DrawSlot(1, 1);
	end;
	self.currentSlot = slot;
end


function Switch:SetSwitch(state)
	if(self.switch==nil)then return;end;
	local props=self.Properties.SwitchPos;
	if(props.bShowSwitch==0)then return;end;
	local props=self.Properties.SwitchPos;
	local rot={x=0,y=0,z=0};
	if(state==1)then
		self.switch:GetAngles(rot);
		rot.y=props.On*g_Deg2Rad;
	else
		self.switch:GetAngles(rot);
		rot.y=props.Off*g_Deg2Rad;
	end;
	self.switch:SetAngles(rot);
end;

function Switch:SpawnSwitch()
	if(self.switch)then
		Entity.DetachThis(self.switch.id,0);
		System.RemoveEntity(self.switch.id);
		self.switch=nil;
	end;
	
	local props=self.Properties.SwitchPos;
	if(props.bShowSwitch==0)then return;end;
	if(self.switch==nil)then
		if(self.Properties.Switch=="")then
			Log("No switch found for switch object "..self:GetName());
		else
			local spawnParams = {};
			spawnParams.class = "BasicEntity";
			Log("self.Properties.Switch: "..self.Properties.Switch);
			spawnParams.archetype=self.Properties.Switch;
			spawnParams.name = self:GetName().."_switch";
			spawnParams.flags = 0;
			spawnParams.position=self:GetPos();
			self.switch=System.SpawnEntity(spawnParams);
			
			self:AttachChild(self.switch.id,0);
			self.switch:SetWorldPos(self:GetPos());
			local rot={x=0,y=0,z=0};
			self:GetAngles(rot);
			
			if(self.Properties.bTurnedOn==1)then
				rot.y=props.On*g_Deg2Rad;
			else
				rot.y=props.Off*g_Deg2Rad;
			end;
			self.switch:SetAngles(rot);
		end;
	else
		if(self.Properties.bTurnedOn==1)then
			if(self.switch:GetAngles()~=props.On*g_Deg2Rad)then
				local rot={x=0,y=0,z=0};
				self:GetAngles(rot);
				rot.y=props.On*g_Deg2Rad;
				self.switch:SetAngles(rot);
			end;
		else
			if(self.switch:GetAngles()~=props.Off*g_Deg2Rad)then
				local rot={x=0,y=0,z=0};
				self:GetAngles(rot);
				rot.y=props.Off*g_Deg2Rad;
				self.switch:SetAngles(rot);
			end;
		end;
	end;
end;

function Switch:OnDestroy()	
	if(self.switch)then
		Entity.DetachThis(self.switch.id,0);
		System.RemoveEntity(self.switch.id);
		self.switch=nil;
	end;
end

----------------------------------------------------------------------------------------------------
function Switch.Server:OnInit()
	if(not self.bInitialized)then
		self:OnReset();
		self.bInitialized=1;
		self.usable=1;
	end;
end;

----------------------------------------------------------------------------------------------------
function Switch.Client:OnInit()
	if(not self.bInitialized)then
		self:OnReset();
		self.bInitialized=1;
	end;
end;

function Switch:OnUsed(user, idx)
	if (CryAction.IsServer()) then
		if(self:GetState()=="TurnedOn")then
			self:GotoState("TurnedOff");
		elseif(self:GetState()=="TurnedOff")then
			self:GotoState("TurnedOn");
			self:ActivateOutput("TurnedOn", user.id);
		elseif(self:GetState()=="Destroyed")then
			return
		end;
	else
		self.server:SvRequestTurnOn(user.id);
	end;
	BroadcastEvent(self, "Used");
end;

function Switch.Server:SvRequestTurnOn(userId)
	if (self.usable == 1) then
		self:GotoState("TurnedOn");
		self:ActivateOutput("TurnedOn", userId);
	end
end

function Switch.Client:ClUpdateEnabled(bool)
	if (bool) then
		self.usable=1;
		BroadcastEvent( self,"Enable" );
	else
		self.usable=0;
		BroadcastEvent( self,"Disable" );
	end;
end

function Switch:IsUsable(user)
	if((self:GetState()~="Destroyed") and self.usable==1)then
		return 2;
	else
		return 0;
	end;
end;

function Switch:GetUsableMessage(idx)
	if(self.Properties.bUsable==1)then
		return self.Properties.UseMessage;
	else
		return "@grab_object";
	end;
end;

function Switch:PlaySound(sound)
	if(sound and sound~="")then
		local snd=self.Properties.Sound["sound"..sound];
		local sndFlags=bor(SOUND_DEFAULT_3D, 0);
		if(snd and snd~="")then
				self.soundid=self:PlaySoundEvent(snd,g_Vectors.v000,g_Vectors.v010,sndFlags,SOUND_SEMANTIC_MECHANIC_ENTITY);
		else
			--System.Log("Failed to play "..sound.." sound!");
		end;
	end;
end;

function Switch:CheckSmartSwitch(switch)
	local props=self.Properties.SmartSwitch;
	if(props.bUseSmartSwitch==1)then
		local entities=System.GetEntitiesInSphere(self:GetPos(),50);
		local targets={};
		for i,v in ipairs(entities) do
			if(v:GetName()==props.Entity)then
				table.insert(targets,v);
			end;
		end
		--Get closest
		table.sort(targets, function(a, b)
				local dista=self:GetDistance(a.id);
				local distb=self:GetDistance(b.id);
				if(dista<distb)then
					return true;
				end
		end);
		local target=targets[1];
		if(target)then
			if(props[switch]~="")then
				local evtName="Event_"..props[switch];
				local evtProc=target[evtName];
				if(type(evtProc)=="function")then
				  --System.Log("Sending: "..switch.." to "..target:GetName());
				  evtProc(target);
				else
					System.Log(self:GetName().." was trying to send an invalid event! Check entity properties!");
				end;
			end;
		end;
	end;
end;


----------------------------------------------------------------------------------
------------------------------------Events----------------------------------------
----------------------------------------------------------------------------------
function Switch:Event_Destroyed()
	BroadcastEvent(self, "Destroyed");
	self:GotoState("Destroyed");
end;

function Switch:Event_TurnedOn()
	--BroadcastEvent(self, "TurnedOn");
	self:GotoState("TurnedOn");
end;

function Switch:Event_TurnedOff()
	BroadcastEvent(self, "TurnedOff");
	self:GotoState("TurnedOff");
end;


function Switch:Event_Switch()
	if(self:GetState()~="Destroyed")then
		if(self:GetState()=="TurnedOn")then
			self:GotoState("TurnedOff");
		elseif(self:GetState()=="TurnedOff")then
			self:GotoState("TurnedOn");
		end;
	end;
end;

function Switch:Event_Hit(sender)
	BroadcastEvent( self,"Hit" );
end;

function Switch:Event_Enable(sender)
	self.usable=1;
	BroadcastEvent( self,"Enable" );
	self.allClients:ClUpdateEnabled(true);
end;

function Switch:Event_Disable(sender)
	self.usable=0;
	BroadcastEvent( self,"Disable" );
	self.allClients:ClUpdateEnabled(false);
end;


----------------------------------------------------------------------------------
------------------------------------States----------------------------------------
----------------------------------------------------------------------------------

Switch.Server.TurnedOn =
{
	OnBeginState = function( self )
		self:PlaySound("TurnOnSound");
		--temporarily disabled
		self:SetSwitch(1);
		self:CheckSmartSwitch("TurnedOnEvent");
		--BroadcastEvent(self, "TurnedOn");
	end,
	OnEndState = function( self )

	end,
}

Switch.Server.TurnedOff =
{
	OnBeginState = function( self )
		self:PlaySound("TurnOffSound");
		--temporarily disabled
		self:SetSwitch(0);
		self:CheckSmartSwitch("TurnedOffEvent");
		BroadcastEvent(self, "TurnedOff")
	end,
	OnEndState = function( self )

	end,
}

Switch.Server.Destroyed=
{
	OnBeginState = function( self )
		self:Explode();
		BroadcastEvent(self, "Destroyed")
	end,
	OnEndState = function( self )
		
	end,
}

----------------------------------------------------------------------------------
-------------------------------Flow-Graph Ports-----------------------------------
----------------------------------------------------------------------------------

Switch.FlowEvents =
{
	Inputs =
	{
		Switch = { Switch.Event_Switch },
		TurnedOn = { Switch.Event_TurnedOn },
		TurnedOff = { Switch.Event_TurnedOff },
		Hit = { Switch.Event_Hit, "bool" },
		Destroyed = { Switch.Event_Destroyed, "bool" },
		Disable = { Switch.Event_Disable, "bool" },
		Enable = { Switch.Event_Enable, "bool" },
	},
	Outputs =
	{
		Hit = "bool",
		TurnedOn = "entity",
		TurnedOff = "bool",
		Destroyed = "bool",
		Disable = "bool",
		Enable = "bool",
	},
}
