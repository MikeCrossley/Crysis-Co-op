--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Implementation of a simple outdoor indoor alien behavior
--  
--------------------------------------------------------------------------
--  History:
--  - 11/12/2004   : Created by Kirill Bulatsev
--  - 05/04/2005   : CXP Rush Clean up by Mikko Mononen
--	- 09/02/2006   : Add the combat patroll behavior by Tetsuji
--------------------------------------------------------------------------


--------------------------------------------------------------------------
AIBehaviour.ScoutPatrol = {
	Name = "ScoutPatrol",
	Base = "SCOUTDEFAULT",

	--------------------------------------------------------------------------
	Constructor = function ( self, entity, data )

		-- called when the behaviour is selected
		-- the extra data is from the signal that caused the behavior transition
		
		entity.AI.spiralCounter = 0;
		entity.AI.vPatrollPosition = {};
		
		CopyVector( entity.AI.vPatrollPosition , entity:GetPos() );
		
		if ( entity.AI.bUseAnchors == true ) then
			AI.CreateGoalPipe("scoutPatrolDefault2");
			AI.PushGoal("scoutPatrolDefault2","devalue",0,1);
			AI.PushGoal("scoutPatrolDefault2","timeout",1,0.3);
			AI.PushGoal("scoutPatrolDefault2","signal",0,1,"TO_SCOUT_CIRCLING",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"scoutPatrolDefault2");
		else
			AI.CreateGoalPipe("scoutPatrolDefault");
			AI.PushGoal("scoutPatrolDefault","devalue",0,1);
			AI.PushGoal("scoutPatrolDefault","timeout",1,0.3);
			AI.PushGoal("scoutPatrolDefault","signal",0,1,"SC_SCOUT_COMBAT_PATROLL",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"scoutPatrolDefault");
		end		


	end,

	---------------------------------------------
	Destructor = function ( self, entity, data )
		-- called when the behaviour is de-selected
		-- the extra data is from the signal that is causing the behavior transition
		entity:SelectPipe(0,"do_nothing");

	end,

	---------------------------------------------
	OnPathFound = function( self, entity, sender )
		-- called when the AI has requested a path and it's been computed succesfully
	end,	
	--------------------------------------------------------------------------
	OnNoTarget = function( self, entity )
		-- called when the AI stops having an attention target
	end,
	---------------------------------------------
	OnSomethingSeen = function( self, entity )
		-- called when the enemy sees a foe which is not a living player
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		-- called when the AI sees a living enemy
		-- Drop beacon and let the other know here's something to fight for.

		entity:TriggerEvent(AIEVENT_DROPBEACON);
		AI.Signal(SIGNALFILTER_GROUPONLY, 1, "GO_ENEMY_FOUND",entity.id);

		local target = AI.GetAttentionTargetEntity(entity.id);
		if(target) then 
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_SCOUT_ATTACK", target.id);
		end

	end,
	---------------------------------------------
	OnSeenByEnemy = function( self, entity, sender )
	end,
	---------------------------------------------
	OnCloseContact= function( self, entity )
		-- called when AI gets at close distance to an enemy
	end,
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the AI can no longer see its enemy, but remembers where it saw it last
	end,
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		-- called when the AI hears an interesting sound
	end,
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
		-- called when the AI hears a threatening sound
	end,
	
	--------------------------------------------------------------------------
	OnSoreDamage = function ( self, entity, sender, data )
		self:OnEnemyDamage(entity);
	end,
	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender, data )

		-- called when AI is damaged by an enemy AI
		-- data.id = damaging enemy's entity id
		-- local hitter = System.GetEntity(data.id);
		-- local hitterName = hitter:GetName()
	end,
	---------------------------------------------
	OnDamage = function ( self, entity, sender, data )

	end,
	---------------------------------------------
	OnGroupMemberDied = function( self, entity, sender )
		-- called when a member of same species dies nearby
	end,

	--------------------------------------------------------------------------
	SC_SCOUT_COMBAT_PATROLL = function ( self, entity )

		entity.AI.spiralCounter = entity.AI.spiralCounter +1;
		if ( entity.AI.spiralCounter == 24 ) then
			entity.AI.spiralCounter = 0;
		end
		
		local mod4 = entity.AI.spiralCounter - entity.AI.spiralCounter/4;

		local radian = ( 2.0 * 3.1416 * mod4 )/ 4.0 ;
		local refpos = {};

		local x  =20.0;
		local y  =0.0;
		
		refpos.x = math.cos( radian )*x - math.sin( radian )*y;
		refpos.y = math.sin( radian )*x + math.cos( radian )*y;
		
		if ( entity.AI.spiralCounter <12 ) then
			refpos.z = ( entity.AI.spiralCounter * 10.0 ) / 4.0;
		else
			refpos.z = ( (24.0-entity.AI.spiralCounter) * 10.0 ) / 4.0;
		end

		FastSumVectors( refpos, refpos, entity.AI.vPatrollPosition );
		
		AI.SetRefPointPosition( entity.id , refpos  );
		AIBehaviour.SCOUTDEFAULT:scoutAdjustRefPoint(  entity, 8.0 );

		if (AIBehaviour.SCOUTDEFAULT:scoutCheckNavOfRef( entity ) == true ) then

			entity:SelectPipe(0,"do_nothing");
			AI.CreateGoalPipe("scoutCombatPatroll");
			AI.PushGoal("scoutCombatPatroll","continuous",0,1);	
			AI.PushGoal("scoutCombatPatroll","locate",0,"refpoint");		
			AI.PushGoal("scoutCombatPatroll","approach",1,5.0,AILASTOPRES_USE,-1);
			AI.PushGoal("scoutCombatPatroll","signal",0,1,"SC_SCOUT_COMBAT_PATROLL",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"scoutCombatPatroll");

		else

			entity:SelectPipe(0,"do_nothing");
			AI.CreateGoalPipe("scoutCombatPatrollV2");
			AI.PushGoal("scoutCombatPatrollV2","timeout",0,5.0);	
			AI.PushGoal("scoutCombatPatrollV2","signal",0,1,"SC_SCOUT_COMBAT_PATROLL",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"scoutCombatPatrollV2");

		end

	end,

}

