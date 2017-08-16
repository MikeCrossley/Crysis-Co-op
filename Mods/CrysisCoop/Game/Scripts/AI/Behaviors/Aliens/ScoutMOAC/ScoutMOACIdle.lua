--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2007.
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
AIBehaviour.ScoutMOACIdle = {
	Name = "ScoutMOACIdle",
	Base = "ScoutMOACDefault",
	alertness = 0,

	--------------------------------------------------------------------------
	Constructor = function ( self, entity, data )

		--AI.AutoDisable( entity.id, 1 );
--		entity:Event_UnCloak();
		entity:EnableSearchBeam(false);

		entity:HolsterItem(true);
		entity:HolsterItem(false);
		entity:DrawWeaponNow(1);
		AI.ChangeParameter( entity.id, AIPARAM_STRAFINGPITCH, 30.0 );
		
		entity.AI.vUp = { x=0.0,y=0.0,z=1.0 };
		entity.AI.vZero = { x=0.0,y=0.0,z=0.0 };
		AI.SetForcedNavigation( entity.id, entity.AI.vZero );
		entity.AI.vLastEnemyPosition = {};
		CopyVector( entity.AI.vLastEnemyPosition, entity:GetPos() );

		entity.AI.scoutTimer3 =0;
		entity.AI.bEnableBeam = true;

		-- check the jammer area
		local objects = {};
		local numObjects = AI.GetNearestEntitiesOfType( entity:GetPos(), AIAnchorTable.ALIEN_SCOUT_JAMMERSPHERE, 1, objects, AIFAF_INCLUDE_DEVALUED, 300.0 );
		entity.AI.bJammer = false;
		entity.AI.vJammer = {};
		CopyVector( entity.AI.vJammer, entity:GetPos() );
		if ( numObjects > 0 ) then
			local objEntity = System.GetEntity( objects[1].id );
			if ( objEntity ~=nil ) then
				entity.AI.bJammer = true;
				CopyVector( entity.AI.vJammer, objEntity:GetPos() );
			end
		end

		-- set the movement mode
		entity.gameParams.forceView = 0.0;
		entity.actor:SetParams(entity.gameParams);

		AI.ChangeParameter(entity.id,AIPARAM_SIGHTENVSCALE_NORMAL,1);
		AI.ChangeParameter(entity.id,AIPARAM_SIGHTENVSCALE_ALARMED,1);

	end,
	--------------------------------------------------------------------------
	Destructor = function ( self, entity, data )
	end,
	--------------------------------------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_SCOUTMOAC_ATTACK", entity.id);
	end,
	--------------------------------------------------------------------------
	OnBulletRain = function ( self, entity, sender, data )
		self:OnEnemyDamage( entity, sender, data );
	end,
	--------------------------------------------------------------------------
	OnSoreDamage = function ( self, entity, sender, data )
		self:OnEnemyDamage( entity, sender, data );
	end,
	--------------------------------------------------------------------------
	OnEnemyDamage = function ( self, entity, sender, data )
		if ( AI.GetAIParameter( entity.id, AIPARAM_PERCEPTIONSCALE_VISUAL ) > 0.0 ) then
			if ( data and data.id == entity.id ) then
			else
			AI.Signal( SIGNALFILTER_SENDER, 1, "TO_SCOUTMOAC_PATROL", entity.id );
			end
		end
	end,
	--------------------------------------------------	
	GRAB_OBJECTS_NOW = function( self, entity, sender )
		--Log ("GRAB_OBJECTS_NOW")
		entity:GrabMultiple();
	end,
	--------------------------------------------------	
	ACT_GRAB_OBJECT = function( self, entity, sender, data )

		local GrabObj = System.GetEntity( sender.id );
		if ( GrabObj ) then
		else
			entity:InsertSubpipe( AIGOALPIPE_SAMEPRIORITY, "action_dummy", nil, data.iValue );
			return;
		end

		AI.AutoDisable( sender.id, 0 );

		AI.CreateGoalPipe("action_scout_grab");
		AI.PushGoal("action_scout_grab", "signal", 1, 1, "GRAB_OBJECTS_NOW", 0);

		entity:InsertSubpipe( AIGOALPIPE_SAMEPRIORITY, "action_dummy", nil, data.iValue );
		entity:InsertSubpipe( AIGOALPIPE_SAMEPRIORITY, "action_scout_grab" );
	
		local index = table.getn(entity.objects_to_be_grabbed)+1;
		
		entity.objects_to_be_grabbed[index] = sender.id;

	end,
	--------------------------------------------------	
	ACT_DROP_OBJECT = function( self, entity, sender, data )

		entity:PlaySoundEvent("Sounds/alien:scout:drop_trooper", entity.AI.vZero, entity:GetDirectionVector(1), SOUND_DEFAULT_3D, SOUND_SEMANTIC_AI_READABILITY);
		entity:DropObject( true, data.point, 0 );
		entity:InsertSubpipe( AIGOALPIPE_SAMEPRIORITY, "action_dummy", nil, data.iValue );
	end,
	
	-------------------------------------------------------
	-- debug
	CHECK_TROOPER_GROUP = function(self,entity,sender)
		AI.Warning(entity:GetName().. " IS IN SAME GROUP WITH TROOPER "..sender:GetName()..", groupid = "..AI.GetGroupOf(entity.id));
	end,
}

