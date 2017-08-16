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
--  - 15/03/2006   : Created by Tetsuji
--------------------------------------------------------------------------

local Xaxis = 0;
local Yaxis = 1;
local Zaxis = 2;

--------------------------------------------------------------------------
AIBehaviour.HeliPickAttack = {
	Name = "HeliPickAttack",
	Base = "HeliBase",
	alertness = 2,

	--------------------------------------------------------------------------
	Constructor = function ( self, entity, data )

		-- for common signal handlers.

		entity.AI.heliDefaultSignal = "TO_HELI_ATTACK";
		entity.AI.heliMemorySignal = "TO_HELI_PICKATTACK";


		-- called when the behaviour is selected

		AI.CreateGoalPipe("heliRoundAttackDefault");
		AI.PushGoal("heliRoundAttackDefault","timeout",1,0.1);
		AI.PushGoal("heliRoundAttackDefault","signal",0,1,"HELI_PICKATTACK_START",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"heliRoundAttackDefault");

	end,

	---------------------------------------------
	OnPathFound = function( self, entity, sender )
		-- called when the AI has requested a path and it's been computed succesfully
	end,	
	--------------------------------------------------------------------------
	OnNoTarget = function( self, entity )
		-- called when the AI stops having an attention target
		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_HELI_ATTACK", entity.id);
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
		self:OnEnemyDamage(entity);
	end,
	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender, data )

		if ( AIBehaviour.HELIDEFAULT:heliCheckDamageRatio( entity ) == true ) then
			return;
		end
		if ( AIBehaviour.HELIDEFAULT:heliCheckDamage( entity, data ) == false ) then
			return;
		end

	end,
	---------------------------------------------
	OnDamage = function ( self, entity, sender, data )
	end,
	
	---------------------------------------------
	OnGroupMemberDied = function( self, entity, sender )
		-- called when a member of same species dies nearby
	end,

	---------------------------------------------
	OnObjectSeen = function( self, entity, fDistance, data )
		-- called when the AI sees an object registered for this kind of signal
		-- data.iValue = AI object type
		-- example
		-- if (data.iValue == 150) then -- grenade
		--	 ...
		if ( data.iValue == AIOBJECT_RPG) then
			entity:InsertSubpipe(0,"devalue_target");
		end

	end,

	--------------------------------------------------------------------------
	-- flow graph masks
	---------------------------------------------------------------------------------------------------------------------------------------
	ACT_GOTO = function( self,entity,sender,data )
	end,
	
	---------------------------------------------------------------------------------------------------------------------------------------
	GO_TO = function( self,entity,sender,data )
	end,

	--------------------------------------------------------------------------
	-- local signal handers
	--------------------------------------------------------------------------

	--------------------------------------------------------------------------
	HELI_PICKATTACK_START = function( self, entity )

		if ( AIBehaviour.HELIDEFAULT:heliGetPickPosition( entity ) == true ) then

			AIBehaviour.HELIDEFAULT:heliAdjustRefPoint( entity, 10.0 );
			if (AIBehaviour.HELIDEFAULT:heliCheckNavOfRef( entity ) == false ) then
				AI.Signal(SIGNALFILTER_SENDER,1,"TO_HELI_ATTACK", entity.id);
				return;
			end

			AI.CreateGoalPipe("heliPickAttack");
			AI.PushGoal("heliPickAttack","run",0,0);	
			AI.PushGoal("heliPickAttack","continuous",0,1);	
			AI.PushGoal("heliPickAttack","locate",0,"refpoint");		
			AI.PushGoal("heliPickAttack","approach",0,3.0,AILASTOPRES_USE,-1);
			AI.PushGoal("heliPickAttack","timeout",1,1);	
			AI.PushGoal("heliPickAttack","signal",0,1,"HELI_PICKATTACK_START_B",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"heliPickAttack");

		else
		
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_HELI_ATTACK", entity.id);

		end

	end,

	--------------------------------------------------------------------------
	HELI_PICKATTACK_START_B = function( self, entity )



		AI.CreateGoalPipe("heliPickAttack_b");
		AI.PushGoal("heliPickAttack_b","run",0,0);	
		AI.PushGoal("heliPickAttack","continuous",0,1);	
		AI.PushGoal("heliPickAttack_b","locate",0,"refpoint");		
		AI.PushGoal("heliPickAttack_b","approach",0,8.0,AILASTOPRES_USE,-1);

		AI.PushGoal("heliPickAttack_b","signal",0,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
		AI.PushGoal("heliPickAttack_b","timeout",1,0.5);
		AI.PushGoal("heliPickAttack_b","signal",0,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
		AI.PushGoal("heliPickAttack_b","timeout",1,0.5);
		AI.PushGoal("heliPickAttack_b","signal",0,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
		AI.PushGoal("heliPickAttack_b","timeout",1,0.5);
		AI.PushGoal("heliPickAttack_b","signal",0,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
		AI.PushGoal("heliPickAttack_b","timeout",1,0.5);
		AI.PushGoal("heliPickAttack_b","signal",0,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
		AI.PushGoal("heliPickAttack_b","timeout",1,0.5);
		AI.PushGoal("heliPickAttack_b","signal",0,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
		AI.PushGoal("heliPickAttack_b","timeout",1,0.5);

--		AI.PushGoal("heliPickAttack_b","firecmd",0,FIREMODE_FORCED);
		AI.PushGoal("heliPickAttack_b","firecmd",0,0);
		AI.PushGoal("heliPickAttack_b","timeout",1,1.0);
		AI.PushGoal("heliPickAttack_b","signal",0,1,"TO_HELI_ATTACK",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"heliPickAttack_b");

	end,
	--------------------------------------------------------------------------
	HELI_REFLESH_FORMATION_SCALE = function( self, entity, sender, data )

		--CopyVector( entity.AI.vFormationScale, data.point );

	end,
	--------------------------------------------------------------------------
	HELI_REFLESH_POSITION = function( self, entity, sender, data )

		--AIBehaviour.HELIDEFAULT:heliRefreshStayAttackPosition( entity , entity.AI.vFormationScale );

	end,


}

