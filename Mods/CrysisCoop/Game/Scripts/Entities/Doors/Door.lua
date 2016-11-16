--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2005.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Mission Objective
--  
--------------------------------------------------------------------------
--  History:
--  - 10:5:2005 : Created by Filippo De Luca
--
--------------------------------------------------------------------------

Door = 
{
	Properties = 
	{
		soclasses_SmartObjectClass = "Door",

		fileModel = "Objects/library/furnishings/doors/toiletstall_door_local.cgf",
		
		Sounds = 
		{
			soundSoundOnMove 				= "sounds/doors/wooddooropen.wav",
			soundSoundOnStop 				= "",
			soundSoundOnStopClosed 	= "",
			fVolume = 200,
			fRange = 50,
		},		
		Rotation = 
		{
			fSpeed 					= 200.0,
			fAcceleration 	= 500.0,
			fStopTime 			= 0.125,
			fRange 					= 90,
			sAxis 					= "z",
			bRelativeToUser = 1,
			sFrontAxis			= "y",
		},
		Slide = 
		{
			fSpeed	 				= 2.0,
			fAcceleration 	= 3.0,
			fStopTime				= 0.5,
			fRange	 				= 0,
			sAxis		 				= "x",
		},
		fUseDistance = 2.5,
		bLocked = 0,
		bSquashPlayers = 0,
		bActivatePortal = 0,
  },
  	
	PhysParams = 
	{ 
		mass = 0,
		density = 0,
	},
	
	sounds = {},
	
	Server = {},
	Client = {},
}

DoorVars =
{
	goalAngle = {x=0,y=0,z=0},
	currAngle = {x=0,y=0,z=0},
	modelAngle = {x=0,y=0,z=0},
	
	goalPos = {x=0,y=0,z=0},
	currPos = {x=0,y=0,z=0},
	modelPos = {x=0,y=0,z=0},
	
	locked = false,
}

function CreateDoor(door)
	mergef(door,DoorVars,1);
end

DOOR_TOGGLE = 0;
DOOR_OPEN = 1;
DOOR_CLOSE = 2;



Net.Expose {
	Class = Door,
	ClientMethods = {
		ClSlide = { RELIABLE_UNORDERED, POST_ATTACH, BOOL },
		ClRotate = { RELIABLE_UNORDERED, POST_ATTACH, BOOL, BOOL },
	},
	ServerMethods = {
		SvRequestOpen = { RELIABLE_UNORDERED, POST_ATTACH, ENTITYID, BOOL },
	},
	ServerProperties = {
	},
};


function Door:CanShatter()
	return false;
end



----------------------------------------------------------------------------------------------------
function Door:OnPreFreeze(freeze, vapor)
	if (freeze) then
		return false; -- don't allow freezing
	end
end

-------------------------------------------------------
function Door:OnLoad(table)
	self.rotationUpdate = table.rotationUpdate
	self.slideUpdate = table.slideUpdate
	self.goalAngle = table.goalAngle 
	self.currAngle = table.currAngle 
	self.modelAngle = table.modelAngle 	
	self.goalPos = table.goalPos 
	self.currPos = table.currPos 
	self.modelPos = table.modelPos 
	self.locked = table.locked 
end

-------------------------------------------------------
function Door:OnSave(table)
	table.rotationUpdate = self.rotationUpdate
	table.slideUpdate = self.slideUpdate
	table.goalAngle = self.goalAngle 
	table.currAngle = self.currAngle 
	table.modelAngle = self.modelAngle 	
	table.goalPos = self.goalPos 
	table.currPos = self.currPos 
	table.modelPos = self.modelPos 
	table.locked = self.locked 
end

function Door:OnPropertyChange()
	self.bNeedReload = 1;
	self:Reset();
end

function Door:OnReset()
	self:Reset();
end

function Door:OnSpawn()	
	CryAction.CreateGameObjectForEntity(self.id);
	CryAction.BindGameObjectToNetwork(self.id);
	CryAction.ForceGameObjectUpdate(self.id, true);	
	
	self.isServer=CryAction.IsServer();
	self.isClient=CryAction.IsClient();

	self:Reset(1);
end

function Door:OnDestroy()
end

--function Door.Server:OnInit()
	--self.bNeedReload = 1;
	--self:Reset();
--end

--function Door.Client:OnInit()
	--self.bNeedReload = 1;
	--self:Reset();
--end


function Door:DoPhysicalize()
	if (self.currModel ~= self.Properties.fileModel) then
		CryAction.ActivateExtensionForGameObject(self.id, "ScriptControlledPhysics", false);
		self:LoadObject( 0,self.Properties.fileModel );
		self:Physicalize(0,PE_RIGID,self.PhysParams);
		CryAction.ActivateExtensionForGameObject(self.id, "ScriptControlledPhysics", true);			
	end
	
	if (tonumber(self.Properties.bSquashPlayers)==0) then
		self:SetPhysicParams(PHYSICPARAM_FLAGS, {flags_mask=pef_cannot_squash_players, flags=pef_cannot_squash_players});
	end
	self.currModel = self.Properties.fileModel;
end

function Door:ResetAction()
	self.action = DOOR_CLOSE;
	self.rotationUpdate = nil;
	self.slideUpdate = nil;
	if AI then AI.ModifySmartObjectStates( self.id, "Closed-Open" ) end;
end

function Door:Reset(onSpawn)
	--Log( "Door:Reset" );

	if (self.bNeedReload and self.bNeedReload == 0) then
	  -- Skip Reloads when not neccesarry.
		do return end;
	end
	self.bNeedReload = 0;
	
	--Log( "Door:Reset Reload" );
	
	if (onSpawn) then
		CreateDoor(self);
	end
	
	self:Activate(0);
	
	if (onSpawn) then
		self:ResetAction();
	end
	
	self:DoPhysicalize();
			
	if (self.action == DOOR_CLOSE and not self.rotationUpdate and not self.slideUpdate) then
		self:GetWorldAngles(self.modelAngle);
		self:GetWorldPos(self.modelPos);
	end
	
	self:ResetAction();

	CopyVector(self.currAngle,self.modelAngle);
	CopyVector(self.goalAngle,self.modelAngle);
	
	CopyVector(self.currPos,self.modelPos);
	CopyVector(self.goalPos,self.modelPos);

	if (self.portal) then
		System.ActivatePortal(self:GetWorldPos(), 0, self.id);
	end
	--Log("Door: DeActivatePortal in Reset! "..self:GetName());

	self:UpdateRotation(0);
	self:UpdateSlide(0);
		
	self:AwakePhysics(1);
	
	self.locked = self.Properties.bLocked~=0;
	self.portal = self.Properties.bActivatePortal~=0;

	local axis=string.lower(self.Properties.Rotation.sFrontAxis);
	local neg=(axis=="-x") or (axis=="-y") or (axis=="-z");
	
	if (string.find(axis, "x")) then
		self.frontAxis=self:GetDirectionVector(0);
	elseif (string.find(axis, "y")) then
		self.frontAxis=self:GetDirectionVector(1);
	else
		self.frontAxis=self:GetDirectionVector(2);
	end
	
	if (neg) then
		self.frontAxis.x=-self.frontAxis.x;
		self.frontAxis.y=-self.frontAxis.y;
		self.frontAxis.z=-self.frontAxis.z;
	end
	

	if AI then
		if ( self.locked == true ) then
			AI.SetSmartObjectState( self.id, "Locked,Closed" );
		else
			AI.SetSmartObjectState( self.id, "Closed" );
		end	
	end
end

function Door:UpdateRotation(frameTime)	
	local currAngles=self:GetWorldAngles(g_Vectors.temp_v1);
	local goalAngles=self.goalAngle;
	
	if (currAngles.x<0 and goalAngles.x>0) then currAngles.x=currAngles.x+2*math.pi; end
	if (currAngles.x>0 and goalAngles.x<0) then currAngles.x=currAngles.x-2*math.pi; end
	if (currAngles.y<0 and goalAngles.y>0) then currAngles.y=currAngles.y+2*math.pi; end
	if (currAngles.y>0 and goalAngles.y<0) then currAngles.y=currAngles.y-2*math.pi; end
	if (currAngles.z<0 and goalAngles.z>0) then currAngles.z=currAngles.z+2*math.pi; end
	if (currAngles.z>0 and goalAngles.z<0) then currAngles.z=currAngles.z-2*math.pi; end
	
	local distSq=vecLenSq(vecSub(goalAngles, currAngles));
	
	if (distSq<0.0001) then
		self.rotationUpdate = nil;
		if (self.action == DOOR_CLOSE and not self.slideUpdate) then
			if (self.portal) then
				System.ActivatePortal(self:GetWorldPos(), 0, self.id);
			end
		end
	end
end

function Door:UpdateSlide(frameTime)
	local currPos=self:GetWorldPos(g_Vectors.temp_v1);
	local goalPos=self.goalPos;
	local distSq=vecLenSq(vecSub(goalPos, currPos));
		
	if (distSq<0.0001) then
		self.slideUpdate = nil;
		if (self.action == DOOR_CLOSE and not self.rotationUpdate) then
			if (self.portal) then
				System.ActivatePortal(self:GetWorldPos(), 0, self.id);
			end
			--Log("Door: DeActivatePortal in UpdateSlide! "..self:GetName());
		end
	end
end

function Door:IsUsable(user)

	if (not user) then
		return 0;
	end

	local delta = g_Vectors.temp_v1;
	local mypos,bbmax = self:GetWorldBBox();
		
	FastSumVectors(mypos,mypos,bbmax);
	ScaleVectorInPlace(mypos,0.5);
	user:GetWorldPos(delta);
			
	SubVectors(delta,delta,mypos);
	
	local useDistance = self.Properties.fUseDistance;
	if (LengthSqVector(delta)<useDistance*useDistance) then
		return 1;
	else
		return 0;
	end
end


function Door:GetUsableMessage(idx)
	return "@use_door"
end


function Door:OnUsed(user)	

--if (self.locked == 1) then
--		return nil
--	end
	
		-- Dejan --
		--		I removed this check to allow aliens to use doors from any distance
		--		with a flow graph node. However, there is already another check for
		--		the player's use button, so this check is not really needed...
--	if (self:IsUsable(user) ~= 1) then
--		return nil;
--	end

	self.server:SvRequestOpen(user.id, self.action~=DOOR_OPEN);
end

function Door.Server:OnUpdate(frameTime)
	self:Update(frameTime);
end

function Door.Client:OnUpdate(frameTime)
	if (not self.isServer) then
		self:Update(frameTime);
	end
end

function Door:Update(frameTime)
	local stopped = false;
	
	if (self.rotationUpdate) then
		self:UpdateRotation(frameTime);
	end
	
	if (self.slideUpdate) then
		self:UpdateSlide(frameTime);
	end
	
	if ((not self.slideUpdate) and (not self.rotationUpdate)) then
		self:Activate(0);
		stopped=true;
	end
	
	--update sounds
	if (stopped and (not self.stopSoundPlayed)) then
		local soundsP = self.Properties.Sounds;	
		Sound.Play(soundsP.soundSoundOnStop, self:GetWorldPos(), SOUND_DEFAULT_3D, SOUND_SEMANTIC_MECHANIC_ENTITY);

		if (self.action==DOOR_CLOSE) then
			Sound.Play(soundsP.soundSoundOnStopClosed, self:GetWorldPos(), SOUND_DEFAULT_3D, SOUND_SEMANTIC_MECHANIC_ENTITY);
		end

		self.stopSoundPlayed = true;
	end
end

function Door.Server:OnInitClient(channelId)
	if (self.Properties.Rotation.fRange ~= 0) then					
		local open=self.action == DOOR_OPEN;
		self.onClient:ClRotate(channelId, open, self.fwd or false);
	end
	
	if (self.Properties.Slide.fRange ~= 0) then			
		local open=(self.action == DOOR_OPEN);
		self.onClient:ClSlide(channelId, open);
	end
end

function Door.Server:SvRequestOpen(userId, open)
	local mode=DOOR_TOGGGLE;
	if (open) then
		mode=DOOR_OPEN;
	else
		mode=DOOR_CLOSE;
	end

	local user=System.GetEntity(userId);
	self:Open(user, mode);
end


function Door.Client:ClRotate(open, fwd)
	if (not self.isServer or g_gameRules.game:IsDemoMode() ~= 0) then
		if (open) then
			self.action=DOOR_OPEN;
		else
			self.action=DOOR_CLOSE;
		end
		self:Rotate(open, fwd);
	end	
end


function Door.Client:ClSlide(open)
	if (not self.isServer or g_gameRules.game:IsDemoMode() ~= 0) then
		if (open) then
			self.action=DOOR_OPEN;
		else
			self.action=DOOR_CLOSE;
		end
		self:Slide(open);
	end
end


function Door:Slide(open)
	if (open) then
		local axis = self.Properties.Slide.sAxis;
		local range = self.Properties.Slide.fRange;
		local dir=g_Vectors.temp_v1;

		if (axis == "X" or axis == "x") then
			dir=self:GetDirectionVector(0);
		elseif (axis == "Y" or axis == "y") then
			dir=self:GetDirectionVector(1);
		else
			dir=self:GetDirectionVector(2);
		end
		
		self.goalPos.x=self.modelPos.x+dir.x*range;
		self.goalPos.y=self.modelPos.y+dir.y*range;
		self.goalPos.z=self.modelPos.z+dir.z*range;		
	else
		CopyVector(self.goalPos,self.modelPos);
	end
	
	self.scp:MoveTo(self.goalPos, self:GetSpeed(), self.Properties.Slide.fSpeed, self.Properties.Slide.fAcceleration, self.Properties.Slide.fStopTime);

	if (self.portal) then
		System.ActivatePortal(self:GetWorldPos(), 1, self.id);
	end

	self.slideUpdate = 1;
	self.bNeedReload = 1;

	self:Activate(1);
	self:Sound(open);
end


function Door:Rotate(open, fwd)
	if (open) then
		local range = math.rad(self.Properties.Rotation.fRange);		
		if (not fwd) then
			range=-range;
		end
	
		local axis = self.Properties.Rotation.sAxis;
		if (axis == "X" or axis == "x") then
			self.goalAngle.x = self.modelAngle.x + range;
		elseif (axis == "Y" or axis == "y") then
			self.goalAngle.y = self.modelAngle.y + range;
		else
			self.goalAngle.z = self.modelAngle.z + range;
		end
	else
		CopyVector(self.goalAngle,self.modelAngle);
	end
		
	if (self.portal) then
		System.ActivatePortal(self:GetWorldPos(), 1, self.id);
	end
	
	self.scp:RotateToAngles(self.goalAngle, self.scp:GetAngularSpeed(), self.Properties.Rotation.fSpeed, self.Properties.Rotation.fAcceleration, self.Properties.Rotation.fStopTime);

	self.rotationUpdate = 1;	
	self.bNeedReload = 1;
	
	self:Activate(1);
	self:Sound(open);
end


function Door:Sound(open)
	--sounds
	local soundsP = self.Properties.Sounds;	
	Sound.Play(soundsP.soundSoundOnMove, self:GetWorldPos(), SOUND_DEFAULT_3D, SOUND_SEMANTIC_MECHANIC_ENTITY);
	self.stopSoundPlayed = nil;		
end


-- this is only safe to be called from server
function Door:Open(user, mode)
	local lastAction = self.action;
	
	if (mode == DOOR_TOGGLE) then
		if (self.action == DOOR_OPEN) then
			self.action = DOOR_CLOSE;
		else
			self.action = DOOR_OPEN;
		end
	else
		self.action = mode;
	end
	
	if (lastAction == self.action) then
		return 0;
	end
	
	if (self.Properties.Rotation.fRange ~= 0) then					
		local open=false;
		local fwd=true;
		
		if (self.action == DOOR_OPEN) then			
			if (user and (tonumber(self.Properties.Rotation.bRelativeToUser) ~=0)) then
				local userForward=g_Vectors.temp_v2;
				local myPos=self:GetWorldPos(g_Vectors.temp_v3);
				local userPos=user:GetWorldPos(g_Vectors.temp_v4);
				SubVectors(userForward,myPos,userPos);
				NormalizeVector(userForward);
				
				local dot = dotproduct3d(self.frontAxis, userForward);
							
				if (dot<0) then
					fwd=false;
				end
			end
			
			open=true;
		end
		
		self.fwd=fwd;
		self:Rotate(open, fwd);
		self.allClients:ClRotate(open, fwd);
	end
	
	if (self.Properties.Slide.fRange ~= 0) then
		local open=(self.action == DOOR_OPEN);
		
		self:Slide(open);
		self.allClients:ClSlide(open);
	end

	if AI then
		if (self.action == DOOR_OPEN) then
			AI.ModifySmartObjectStates( self.id, "Open-Closed" );
			BroadcastEvent(self, "Open");
		elseif (self.action == DOOR_CLOSE) then
			AI.ModifySmartObjectStates( self.id, "Closed-Open" );
			BroadcastEvent(self, "Close");
		end
	end
	
	return 1;
end

function Door:Event_Open(sender)	
	if (sender == self) then return; end
	
	self:Open(sender,DOOR_OPEN);
end

function Door:Event_Close(sender)
	if (sender == self) then return; end
		
	self:Open(sender,DOOR_CLOSE);
end

function Door:Event_UnLock(sender)	
	if (self.locked ~= 0) then
		self.bNeedReload = 1;
	end
	self.locked = 0;
	if AI then AI.ModifySmartObjectStates( self.id, "-Locked" ) end;
end

function Door:Event_Lock(sender)
	if (self.locked ~= 1) then
		self.bNeedReload = 1;
	end
	self.locked = 1;
	if AI then AI.ModifySmartObjectStates( self.id, "Locked" ) end;
end

Door.FlowEvents =
{
	Inputs =
	{
		Close = { Door.Event_Close, "bool" },
		Open = { Door.Event_Open, "bool" },
		Lock = { Door.Event_Lock, "bool" },
		UnLock = { Door.Event_UnLock, "bool" },
	},
	Outputs =
	{
		Close = "bool",
		Open = "bool",
		Lock = "bool",
		UnLock = "bool",
	},
}
