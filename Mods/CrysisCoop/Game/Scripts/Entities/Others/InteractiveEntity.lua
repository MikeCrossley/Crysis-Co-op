InteractiveEntity = {
	Client = {},
	Server = {},
	Properties = {
		fileModel 					= "objects/library/props/gasstation/vending_machine_drinks.cgf",
		ModelSubObject			= "main",
		fileModelDestroyed	= "",
		DestroyedSubObject	= "remain",
		bTurnedOn	= 0,
		bUsable	= 1,
		bTwoState	= 0,
		UseMessage = "",
		OnUse = {
			fUseDelay = 0,
			fCoolDownTime = 1,
			bEffectOnUse = 0,
			bSoundOnUse = 0,
			bSpawnOnUse = 0,
			bChangeMatOnUse = 0,
		},
		Sound = {
			soundSound = "sounds/physics:destructibles:body_shatter",
			soundTurnOnSound = "",
			soundTurnOffSound = "",
			
		},
		Effect = {
			ParticleEffect="explosions.gauss.hit",
			bPrime=0,
			Scale=1,
			CountScale=1,
			bCountPerUnit=0,
			AttachType="",
			AttachForm="Surface",
			PulsePeriod=0,
			SpawnPeriod=0,
			vOffset = {x=0, y=0, z=0},
			vRotation = {x=0, y=0, z=0},
		},
		fHealth = 75,
		Physics = {
			bRigidBody=1,
			bRigidBodyActive = 1,
			bResting = 1,
			Density = -1,
			Mass = 300,
      Buoyancy=
			{
				water_density = 1000,
				water_damping = 0,
				water_resistance = 1000,	
			},
			
			bStaticInDX9Multiplayer = 1,
		},
		Breakage =
		{
			fLifeTime = 10,
			fExplodeImpulse = 0,
			bSurfaceEffects = 1,
		},
		Destruction =	{
			bExplode				= 1,
			Effect					= "explosions.monitor.a",
			EffectScale			= 1,
			Radius					= 0,
			Pressure				= 0,
			Damage					= 0,
			Decal						= "",
			Direction				= {x=0, y=0.2, z=1},
			vOffset 				= {x=0, y=0, z=0},
		},
		Vulnerability	=
		{
			fDamageTreshold = 0,
			bExplosion = 1,
			bCollision = 1,
			bMelee		 = 1,
			bBullet		 = 1,
			bOther	   = 1,
		},
		SpawnEntity = {
			iSpawnLimit = 1,
			Archetype = "Props.gas_station.can_a",
			vOffset = {x=0, y=0, z=0},
			vRotation = {x=0, y=0, z=0},
			fImpulse = 1,
			vImpulseDir= {x=0, y=0, z=1},
		},
		ChangeMaterial = {
			fileMaterial = "",
			Duration = 0,
		},
		ScreenFunctions = {
			bHasScreenFunction = 0,
			FlashMatId = -1,
			Type = {
				bProgressBar = 0,
			},
		},
	},
		Editor={
		Icon = "Item.bmp",
		IconOnTop=1,
	},
	LastHit =
	{
		impulse = {x=0,y=0,z=0},
		pos = {x=0,y=0,z=0},
	},
	States = {"TurnedOn","TurnedOff","Destroyed"},
	health = 0,
	soundid = nil,
	turnoffsoundid = nil,
	FXSlot = -1,
	spawncount = 0,
	iDelayTimer 	= -1,
	iCoolDownTimer 	= -1,
	iTurnOffSoundTimer = -1,
	bCoolDown = 0,
	shooterId = 0,
	currentMat = nil,
	MatResetTimer = nil,
	progress = 0,
}

local Physics_DX9MP_Simple = {
	bPhysicalize = 1, -- True if object should be physicalized at all.
	bPushableByPlayers = 0,
		
	Density = -1,
	Mass = -1,
	bStaticInDX9Multiplayer = 1,
}

function InteractiveEntity:OnPropertyChange()

end;

function InteractiveEntity:OnSave(tbl)

end;

function InteractiveEntity:OnLoad(tbl)

end;

function InteractiveEntity:OnReset()

end;

function InteractiveEntity:PhysicalizeThis(slot)

end;

function InteractiveEntity.Server:OnHit(hit)

end;

function InteractiveEntity.Client:OnHit(hit, remote)

end

function InteractiveEntity:OnUsed(user, idx)

end;

InteractiveEntity.ResetMat = function(self)

end;

InteractiveEntity.EndCoolDown = function(self)

end;

InteractiveEntity.Use = function(self)

end;


function InteractiveEntity:IsUsable(user)
	
end;

function InteractiveEntity:GetUsableMessage(idx)

end;

function InteractiveEntity:DoSpawn()

end;

function InteractiveEntity:DoMaterialChange()

end;

function InteractiveEntity:DoEffect()

end;

function InteractiveEntity:RemoveEffect()

end;

function InteractiveEntity:Play()

end;

function InteractiveEntity:Stop(stopsound)

end;

function InteractiveEntity:Explode()

end;

----------------------------------------------------------------------------------------------------
function InteractiveEntity:SetProgress()

end;

function InteractiveEntity:SetCurrentSlot(slot)

end

----------------------------------------------------------------------------------------------------
function InteractiveEntity.Server:OnInit()

	
end;

----------------------------------------------------------------------------------------------------
function InteractiveEntity.Client:OnInit()

end;


----------------------------------------------------------------------------------
------------------------------------Events----------------------------------------
----------------------------------------------------------------------------------
function InteractiveEntity:Event_TurnedOn()
	BroadcastEvent(self, "TurnedOn");
	self:GotoState("TurnedOn");
end;

function InteractiveEntity:Event_TurnedOff()
	BroadcastEvent(self, "TurnedOff");
	self:GotoState("TurnedOff");
end;

function InteractiveEntity:Event_Destroyed()
	BroadcastEvent(self, "Destroyed");
	self:GotoState("Destroyed");
end;

function InteractiveEntity:Event_Hit(sender)
	BroadcastEvent( self,"Hit" );
end;

function InteractiveEntity:Event_SetProgress()
	--Fix
	self:SetProgress();
end;

function InteractiveEntity:Event_ResetProgress()

end;

function InteractiveEntity:Event_Use(sender)
	self:OnUsed(self,0);
end;

function InteractiveEntity:Event_Hide()
	self:Hide(1);
end;

function InteractiveEntity:Event_UnHide()
	self:Hide(0);
end;

function InteractiveEntity:Event_EnableUsable()
	self.bUsable=1;
	--self.Properties.bUsable=1;
end;

function InteractiveEntity:Event_DisableUsable()
	self.bUsable=0;
	--self.Properties.bUsable=0;
end;

----------------------------------------------------------------------------------
------------------------------------States----------------------------------------
----------------------------------------------------------------------------------

InteractiveEntity.Server.TurnedOn =
{

}

InteractiveEntity.Server.TurnedOff =
{

}

InteractiveEntity.Server.Destroyed=
{

}

----------------------------------------------------------------------------------
-------------------------------Flow-Graph Ports-----------------------------------
----------------------------------------------------------------------------------

InteractiveEntity.FlowEvents =
{
	Inputs =
	{
		TurnedOn = { InteractiveEntity.Event_TurnedOn, "bool" },
		TurnedOff = { InteractiveEntity.Event_TurnedOff, "bool" },
		Destroyed = { InteractiveEntity.Event_Destroyed, "bool" },
		Hit = { InteractiveEntity.Event_Hit, "bool" },
		SetProgress = { InteractiveEntity.Event_SetProgress, "bool" },
		ResetProgress = { InteractiveEntity.Event_ResetProgress, "bool" },
		Use = { InteractiveEntity.Event_Use, "bool" },
		Hide = { InteractiveEntity.Event_Hide, "bool" },
		UnHide = { InteractiveEntity.Event_UnHide, "bool" },
		EnableUsable = { InteractiveEntity.Event_EnableUsable, "bool" },
		DisableUsable = { InteractiveEntity.Event_DisableUsable, "bool" },
	},
	Outputs =
	{
		TurnedOn = "bool",
		TurnedOff = "bool",
		Destroyed = "bool",
		Hit = "bool",
		Progress = "float",
		Used = "bool",
	},
}
