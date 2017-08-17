--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Scout
--  
--------------------------------------------------------------------------
--  History:
--  - 11/12/2004   : Created by Kirill Bulatsev
--  - 05/04/2005   : CXP Rush Clean up by Mikko Mononen
--	- 29/11/2005   : Revised for new attack patterns by Tetsuji Iwasaki
--	- 15/01/2007   : Separated as the MOAC Scout by Tetsuji Iwasaki
--------------------------------------------------------------------------

--------------------------------------------------------------------------
AIBehaviour.ScoutMOACDefault = {
	Name = "ScoutMOACDefault",

	--------------------------------------------------------------------------
	-- shared signals
	--------------------------------------------------------------------------
	OnReinforcementRequested = function ( self, entity, sender, extraData )
	end,
	--------------------------------------------------------------------------
	OnCallReinforcement = function(self, entity, sender, extraData)
	end,
	--------------------------------------------------------------------------
	OnPathFound = function( self, entity, sender )
	end,	
	--------------------------------------------------------------------------
	OnNoTarget = function( self, entity )
	end,
	--------------------------------------------------------------------------
	OnSomethingSeen = function( self, entity )
	end,
	--------------------------------------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
	end,
	--------------------------------------------------------------------------
	OnSeenByEnemy = function( self, entity, sender )
	end,
	--------------------------------------------------------------------------
	OnCloseContact= function( self, entity )
	end,
	--------------------------------------------------------------------------
	OnEnemyMemory = function( self, entity )
	end,
	--------------------------------------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
	end,
	--------------------------------------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
	end,
	--------------------------------------------------------------------------
	OnBulletRain = function ( self, entity, sender, data )	
	end,
	--------------------------------------------------------------------------
	OnSoreDamage = function ( self, entity, sender, data )
	end,
	--------------------------------------------------------------------------
	OnEnemyDamage = function ( self, entity, sender, data )
	end,
	--------------------------------------------------------------------------
	OnDamage = function ( self, entity, sender, data )
	end,
	--------------------------------------------------------------------------
	OnGroupMemberDied = function( self, entity, sender )
	end,
	--------------------------------------------------------------------------
	OnGroupMemberDiedNearest = function ( self, entity, sender,data)
	end,
	--------------------------------------------------------------------------
	OnObjectSeen = function( self, entity, fDistance, data )
		entity:InsertSubpipe(0,"devalue_target");
	end,
	--------------------------------------------------------------------------
	OnVehicleDanger = function (self,entity,sender,data)
	end,
	--------------------------------------------------------------------------
	CLOAK = function(self,entity,sender)
		entity:Event_Cloak();
	end,
	--------------------------------------------------------------------------
	UNCLOAK = function(self,entity,sender)
		entity:Event_UnCloak();
	end,
	--------------------------------------------------------------------------
	SET_MOVEMENT_MODE = function( self, entity, sender, data )
			entity.gameParams.forceView = data.fValue;
			entity.actor:SetParams(entity.gameParams);
	end,

	--------------------------------------------------------------------------
	SET_BEAM_ON = function( self, entity, sender, data )

		local vDown = { x=0, y=12.0, z = -1 };
		NormalizeVector( vDown );
		entity:SetSearchBeamDir(vDown);  
		entity:EnableSearchBeam(entity.AI.bEnableBeam);
	end,

	--------------------------------------------------------------------------
	SET_BEAM_OFF = function( self, entity, sender, data )

		entity:EnableSearchBeam(false);

	end,

	--------------------------------------------------------------------------
	SCOUT_CHANGESOUND = function( self, entity)

		entity.gameParams.turnSound              = "sounds/alien:scout_big_rolloff:acceleration_body";	
		entity.gameParams.destruct_charge_sound  = "Sounds/alien:scout_big_rolloff:self_destruct_charge";
		entity.gameParams.destruct_explode_sound = "Sounds/alien:scout_big_rolloff:self_destruct_explode";
		entity.gameParams.death_explode_sound    = "Sounds/alien:scout_big_rolloff:death_explode";
		entity.actor:SetParams(entity.gameParams);

		ActorShared[entity.voiceType].pain      = { {"sounds/alien:scout_big_rolloff:pain"}  };
		ActorShared[entity.voiceType].death     = { {"sounds/alien:scout_big_rolloff:death"} };
		ActorShared[entity.voiceType].idle      = { {"sounds/alien:scout_big_rolloff:idle"}  };

		entity.AI.bBigRolloff = true;

		entity:StopSounds();
		entity:InitSoundTables();
		entity:PlayIdleSound(entity.voiceTable.idle);

	end,
	
	--------------------------------------------------------------------------
	SCOUT_ASCENSION = function( self, entity, sender, data )

		AI.ChangeParameter(entity.id,AIPARAM_COMBATCLASS,AICombatClasses.ascensionScout);		
		self:SCOUT_CHANGESOUND( entity );
		entity.AI.bEnableBeam = false;
		entity.AI.ascensionScout = true;

	end,

	--------------------------------------------------------------------------
	SCOUT_ASCENSION_LIKESTANK = function( self, entity, sender, data )

		AI.ChangeParameter(entity.id,AIPARAM_COMBATCLASS,AICombatClasses.ascensionScout2);		
		self:SCOUT_CHANGESOUND( entity );
		entity.AI.bEnableBeam = false;
		entity.AI.ascensionScout = true;

	end,

	--------------------------------------------------------------------------
	SCOUTMOAC_ANTICIPATION_RESPONSE = function( self, entity, sender, data )
		local wtime = 2000 + random(1,2000);
		Script.SetTimerForFunction( wtime , "AIBehaviour.ScoutMOACDefault.SCOUTMOAC_ANTICIPATION_RESPONSE2", entity );
	end,

	--------------------------------------------------------------------------
	SCOUTMOAC_ANTICIPATION_RESPONSE2 = function( entity )

		if ( entity.AI == nil or entity:GetSpeed() == nil ) then
			return;
		end

		if ( entity.id and System.GetEntity( entity.id ) ) then
		else
			return;
		end

		if ( entity:IsActive() and AI.IsEnabled(entity.id) ) then
		else
			return;
		end

		if ( entity.AI.bBigRolloff and entity.AI.bBigRolloff == true ) then
			entity.actor:PlayNetworkedSoundEvent("sounds/alien:scout_big_rolloff:anticipation_response", entity.AI.vZero, entity:GetDirectionVector(1), SOUND_DEFAULT_3D, SOUND_SEMANTIC_AI_READABILITY);
		else
			entity.actor:PlayNetworkedSoundEvent("sounds/alien:scout:anticipation_response", entity.AI.vZero, entity:GetDirectionVector(1), SOUND_DEFAULT_3D, SOUND_SEMANTIC_AI_READABILITY);
		end
	end,

	------------------------------------------------------------------------
	-- important group signals 

	HEADS_UP_GUYS = function (self, entity, sender)
	end,
	INCOMING_FIRE = function (self, entity, sender)
	end,
	GET_ALERTED = function( self, entity )
	end,
	ORDER_SEARCH = function( self, entity )
	end,

	--------------------------------------------------------------------------
	ACT_SHOOTAT_END = function( entity )

		if ( entity.AI == nil or entity:GetSpeed() == nil ) then
			return;
		end

		if ( entity.id and System.GetEntity( entity.id ) ) then
		else
			return;
		end

		if ( entity:IsActive() and AI.IsEnabled(entity.id) ) then
		else
			return;
		end

		AI.CreateGoalPipe("action_shoot_at_end");
		AI.PushGoal("action_shoot_at_end", "firecmd",0,0);
		AI.PushGoal("action_shoot_at_end", "lookat",0,-500,0);		
		entity:InsertSubpipe( AIGOALPIPE_SAMEPRIORITY, "action_shoot_at_end" , nil, entity.AI.shootAtGoalPipeId );
		entity.AI.scoutTimer3 =0;

	end,

	--------------------------------------------------------------------------
	ACT_SHOOTAT = function( self, entity, sender, data )

		-- use dynamically created goal pipe to set shooting time
		entity:SelectPrimaryWeapon();
		if ( entity.AI.scoutTimer3 == 1 ) then
			AI.CreateGoalPipe("action_shoot_cancel");
			AI.PushGoal("action_shoot_cancel", "+firecmd",0,FIREMODE_FORCED,AILASTOPRES_USE);
			entity:InsertSubpipe( AIGOALPIPE_SAMEPRIORITY, "action_shoot_cancel", nil, data.iValue );
			return;
		end

		AI.CreateGoalPipe("action_shoot_at");
		AI.PushGoal("action_shoot_at", "locate", 0, "refpoint");
		AI.PushGoal("action_shoot_at", "+lookat",0,0,0,true,1);		
		AI.PushGoal("action_shoot_at", "+firecmd",0,FIREMODE_FORCED,AILASTOPRES_USE);
		AI.SetRefPointPosition( entity.id, data.point );
		entity:InsertSubpipe( AIGOALPIPE_SAMEPRIORITY, "action_shoot_at" );
		entity.AI.shootAtGoalPipeId = data.iValue;
	
		if ( data.fValue > 0.0 ) then
			AI.ChangeParameter( entity.id, AIPARAM_STRAFINGPITCH, -1.0 );
			entity.AI.scoutTimer3 =1;
		  Script.SetTimerForFunction( data.fValue *1000, "AIBehaviour.ScoutMOACDefault.ACT_SHOOTAT_END", entity );
		end

	end,

	--------------------------------------------------------------------------
	ACT_FOLLOWPATH = function( self, entity, sender, data )

		AI.SetPathAttributeToFollow( entity.id, true );
		AIBehaviour.DEFAULT:ACT_FOLLOWPATH( entity, sender, data );

	end,
	
	--------------------------------------------------------------------------
	scoutCheckHostile = function ( self, entity, target )

		if ( AI.Hostile( entity.id, target.id ) ) then
			return true;
		end

		return false;

	end,


}

