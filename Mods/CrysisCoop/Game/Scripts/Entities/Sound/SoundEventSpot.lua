SoundEventSpot = {
	type = "Sound",

	Properties = {
		soundName = "",
		bPlay = 0,	-- Immidiatly start playing on spawn.
		bOnce = 0,
		bEnabled = 1,
		bIgnoreCulling = 0,
		bIgnoreObstruction = 0,
	},
	
	started=0,
	Editor={
		Model="Editor/Objects/Sound.cgf",
		Icon="Sound.bmp",
	},
	
	Server = {},
	Client = {},
}

Net.Expose {
	Class = SoundEventSpot,
	ClientMethods = {
		ClExecuteSound = { RELIABLE_UNORDERED, POST_ATTACH, BOOL },
	},
	ServerMethods = {
	},
	ServerProperties = {
	},
};


function SoundEventSpot:OnSpawn()
	--self:SetFlags(ENTITY_FLAG_CLIENT_ONLY, 0);
	CryAction.CreateGameObjectForEntity(self.id);
	CryAction.BindGameObjectToNetwork(self.id);
	CryAction.ForceGameObjectUpdate(self.id, true);	
	
	self.isServer=CryAction.IsServer();
	self.isClient=CryAction.IsClient();
	
	Sound.Precache(self.Properties.soundName, 0);
end

function SoundEventSpot:OnSave(save)
	--WriteToStream(stm,self.Properties);
	--System.LogToConsole("SES: OnSave:");
	save.started = self.started;
	save.bEnabled = self.Properties.bEnabled;
	save.bOnce = self.Properties.bOnce;
	save.bIgnoreCulling = self.Properties.bIgnoreCulling;
	save.bIgnoreObstruction = self.Properties.bIgnoreObstruction;
	
	--System.LogToConsole("started:"..tostring(self.started));
	--System.LogToConsole("Once:"..tostring(self.Properties.bOnce));
end

function SoundEventSpot:OnLoad(load)
	--System.LogToConsole("SES: OnLoad:");
	--self.Properties=ReadFromStream(stm);
	--self:OnReset();
	self.started = load.started;
	self.Properties.bEnabled = load.bEnabled;
	self.Properties.bOnce = load.bOnce;
	self.Properties.bIgnoreCulling = load.bIgnoreCulling;
	self.Properties.bIgnoreObstruction = load.bIgnoreObstruction;
	
	--System.LogToConsole("started:"..tostring(self.started));
	--System.LogToConsole("Once:"..tostring(self.Properties.bOnce));
	
	if ((self.started==1) and (self.Properties.bOnce~=1)) then
		--System.LogToConsole("SES: OnLoad-Star:");
    self:Play();
	end	
end

function SoundEventSpot:OnPostSerialize()
--	System.LogToConsole("SES: PostSerial:");
	self:OnReset()
end

----------------------------------------------------------------------------------------
function SoundEventSpot:OnPropertyChange()
	-- all changes need a complete reset
	self:OnReset();
		
end
----------------------------------------------------------------------------------------
function SoundEventSpot:OnReset()
	
	-- Set basic sound params.
	--System.LogToConsole("Reset SES");
	--System.LogToConsole("self.Properties.bPlay:"..self.Properties.bPlay..", self.started:"..self.started);
  self.started = 0; -- [marco] fix playonce on reset for switch editor/game mode

	--if (self.Properties.bPlay == 0 and self.soundid ~= nil) then
		self:Stop();
	--end

	if (self.Properties.bPlay ~= 0) then -- and self.started == 0) then
		self:Play();
	end
	--self.Client:OnMove();


	--self.started = 0; -- [marco] fix playonce on reset for switch editor/game mode
end

----------------------------------------------------------------------------------------
SoundEventSpot["Server"] = {
	OnInit= function (self)
		self.started = 0;
		self:NetPresent(0);
	end,
	OnShutDown= function (self)
	end,
}

----------------------------------------------------------------------------------------
SoundEventSpot["Client"] = {
	----------------------------------------------------------------------------------------
	OnInit = function(self)
		--System.LogToConsole("OnInit");
		self.started = 0;
		--self.loop = self.Properties.bLoop;
		self.soundName = "";
		self.soundid = nil;
		self:NetPresent(0);

		if (self.Properties.bPlay==1) then
			self:Play();
			--System.LogToConsole("Play sound"..self.Properties.soundName);
		end
		--self.Client.OnMove(self);
	end,
	----------------------------------------------------------------------------------------
	OnShutDown = function(self)
		self:Stop();
	end,
	OnSoundDone = function(self)
	  self:ActivateOutput( "Done",true );
	  self.soundid = nil;
	  self.started = 0;
	  --System.LogToConsole("Done sound "..self.Properties.soundName);
	end,
	ClExecuteSound = function(self, bool)
		if (bool) then
			if (self.soundid ~= nil) then
				self:Stop();
			end
			--Log("Event_Play %d %d",self.Properties.bOnce, self.started)
			if(self.Properties.bOnce~=0 and self.started~=0) then
				return
			end
			
			self:Play();
		else
			if (bStop == true) then
				self:Stop();
			end
		end
	end,
}

----------------------------------------------------------------------------------------
function SoundEventSpot:Play()

	if (self.Properties.bEnabled == 0 ) then 
		do return end;
	end

  if (self.soundid ~= nil) then
		self:Stop(); -- entity proxy
	end

	--local sndFlags = bor(SOUND_EVENT, SOUND_LOOP);
	local sndFlags = SOUND_EVENT;
	
	if (self.Properties.bIgnoreCulling == 0) then
	  sndFlags = bor(sndFlags, SOUND_CULLING);
	end;  

	if (self.Properties.bIgnoreObstruction == 0) then
	  sndFlags = bor(sndFlags, SOUND_OBSTRUCTION);
	end;  
	
	
	--sndFlags = bor(sndFlags, SOUND_EVENT);
	--if (self.Properties.bLoop ~=0 ) then
		--sndFlags = bor(sndFlags, SOUND_LOOP);
	--end;  
  
	self.soundid = self:PlaySoundEvent(self.Properties.soundName, g_Vectors.v000, g_Vectors.v010, sndFlags, SOUND_SEMANTIC_SOUNDSPOT);
	self.soundName = self.Properties.soundName;

	--System.LogToConsole( "Play Sound ID: "..tostring(self.soundid));
	
	if (self.soundid ~= nil) then
	  self.started = 1;
	end;
	
end

----------------------------------------------------------------------------------------
function SoundEventSpot:Stop()


	--System.LogToConsole( "Stop Sound ID: "..tostring(self.soundid));
		
	if (self.soundid ~= nil) then
		self:StopSound(self.soundid); -- stopping through entity proxy
		--System.LogToConsole( "Stop Sound" );

		self.soundid = nil;
		--System.LogToConsole( "Stop Sound ID: "..tostring(self.soundid));
	end
	self.started = 0;
end

----------------------------------------------------------------------------------------
function SoundEventSpot:Event_Play( sender )
	
	--[[if (self.soundid ~= nil) then
		self:Stop();
	end
	--Log("Event_Play %d %d",self.Properties.bOnce, self.started)
	if(self.Properties.bOnce~=0 and self.started~=0) then
		return
	end
	self:Play();]]
	
	if (self.isClient) then
		self.Client:ClExecuteSound(true);
	end
	
	if (self.isServer) then
		self.allClients:ClExecuteSound(true);
		System.LogAlways("SoundEventSpot - Execute on Clients");
	end
	
	--BroadcastEvent( self,"Play" );
end

------------------------------------------------------------------------------------------------------
-- Event Handlers
------------------------------------------------------------------------------------------------------

function SoundEventSpot:Event_SoundName( sender, sSoundName )
  self.Properties.soundName = sSoundname;
  --BroadcastEvent( self,"SoundName" );
  self:OnPropertyChange();
end

function SoundEventSpot:Event_Enable( sender, bEnable )
  self.Properties.bEnabled = bEnable;
  --BroadcastEvent( self,"Enable" );
  self:OnPropertyChange();
end

function SoundEventSpot:Event_Stop( sender, bStop )
	--[[if (bStop == true) then
		self:Stop();
	end]]
	
	if (self.isClient) then
		self.Client:ClExecuteSound(true);
	end	
	
	if (self.isServer) then
		self.allClients:ClExecuteSound(false);
	end

	--BroadcastEvent( self,"Stop" );
end

function SoundEventSpot:Event_Once( sender, bOnce )
	if (bOnce == true) then
		self.Properties.bOnce = 1;
	else
	  self.Properties.bOnce = 0;
	end
	--BroadcastEvent( self,"Once" );
end


SoundEventSpot.FlowEvents =
{
	Inputs =
	{
	  SoundName = { SoundEventSpot.Event_SoundName, "string" },
		Enable = { SoundEventSpot.Event_Enable, "bool" },
		Play = { SoundEventSpot.Event_Play, "bool" },
		Stop = { SoundEventSpot.Event_Stop, "bool" },
		Once = { SoundEventSpot.Event_Once, "bool" },
	},
	Outputs =
	{
	  Done = "bool",
	},
}


