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
--	- 01/03/2006   : Created  by Tetsuji Iwasaki
--------------------------------------------------------------------------

--------------------------------------------------------------------------
AIBehaviour.ScoutPickAttack = {
	Name = "ScoutPickAttack",
	Base = "SCOUTDEFAULT",

	--------------------------------------------------------------------------
	Constructor = function ( self, entity, data )

		-- called when the behaviour is selected

		AI.CreateGoalPipe("scoutPickAttackDefault");
		AI.PushGoal("scoutPickAttackDefault","timeout",1,0.1);
		AI.PushGoal("scoutPickAttackDefault","signal",0,1,"SC_SCOUT_PICKATTACK_START",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"scoutPickAttackDefault");

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
	end,
	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender, data )
	end,
	---------------------------------------------
	OnDamage = function ( self, entity, sender, data )
	end,
	---------------------------------------------
	OnGroupMemberDied = function( self, entity, sender )
		-- called when a member of same species dies nearby
	end,


	--------------------------------------------------------------------------
	SC_SCOUT_PICKATTACK_START = function( self, entity )

		if ( AIBehaviour.SCOUTDEFAULT:scoutGetPickPosition( entity ) == true ) then

			AI.ChangeParameter( entity.id, AIPARAM_STRAFINGPITCH , 20.0 );
			AIBehaviour.SCOUTDEFAULT:scoutAdjustRefPoint( entity, 10.0 );
			if (AIBehaviour.SCOUTDEFAULT:scoutCheckNavOfRef( entity ) == false ) then
				AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_ATTACK", entity.id);
				return;
			end

			AI.CreateGoalPipe("scoutPickAttack");
			AI.PushGoal("scoutPickAttack","run",0,0);	
			AI.PushGoal("scoutPickAttack","continuous",0,1);	
			AI.PushGoal("scoutPickAttack","locate",0,"refpoint");		
			AI.PushGoal("scoutPickAttack","approach",0,3.0,AILASTOPRES_USE,-1);
			AI.PushGoal("scoutPickAttack","timeout",1,1);	
			AI.PushGoal("scoutPickAttack","signal",0,1,"SC_SCOUT_PICKATTACK_START_B",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"scoutPickAttack");

		else
		
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_SCOUT_ATTACK", entity.id);

		end

	end,

	--------------------------------------------------------------------------
	SC_SCOUT_PICKATTACK_START_B = function( self, entity )

		AI.CreateGoalPipe("scoutPickAttack_b");
		AI.PushGoal("scoutPickAttack_b","run",0,1);	
		AI.PushGoal("scoutPickAttack_b","locate",0,"refpoint");		
		AI.PushGoal("scoutPickAttack_b","approach",1,17.0,AILASTOPRES_USE,-1);
		AI.PushGoal("scoutPickAttack_b","run",0,0);	
		AI.PushGoal("scoutPickAttack_b","locate",0,"refpoint");		
		AI.PushGoal("scoutPickAttack_b","approach",1,8.0,AILASTOPRES_USE,-1);
		AI.PushGoal("scoutPickAttack_b","firecmd",0,FIREMODE_FORCED);
		AI.PushGoal("scoutPickAttack_b","timeout",1,3.0);
		AI.PushGoal("scoutPickAttack_b","firecmd",0,0);
		AI.PushGoal("scoutPickAttack_b","signal",0,1,"TO_SCOUT_ATTACK",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"scoutPickAttack_b");

	end,

}

