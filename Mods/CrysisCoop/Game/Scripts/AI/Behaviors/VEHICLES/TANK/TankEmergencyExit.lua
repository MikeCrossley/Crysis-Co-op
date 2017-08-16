--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: 
--  
--------------------------------------------------------------------------
--  History:
--  - 06/02/2005   : Created by Kirill Bulatsev
--
--------------------------------------------------------------------------


AIBehaviour.TankEmergencyExit = {
	Name = "TankEmergencyExit",
	alertness = 2,

	---------------------------------------------------------------------------------------------------------------------------------------
	-- OnEnemyDamage and TankHide are not used now 06/12/05 Tetsuji

	---------------------------------------------
	Constructor = function( self , entity )

		AI.CreateGoalPipe("tankkillitself");
		AI.PushGoal("tankkillitself","timeout",1,3);	
		AI.PushGoal("tankkillitself","signal",0,1,"TANK_KILL_MYSELF",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"tankkillitself");

	end,

	TANK_KILL_MYSELF = function ( self, entity )

		entity:SelectPipe(0,"do_nothing");
		entity:SignalCrew("EXIT_VEHICLE_STAND");			
		g_gameRules:CreateExplosion(entity.id,entity.id,1000,entity:GetPos(),nil,3);

	end,

	---------------------------------------------
	Destructor = function ( self, entity, data )
		-- called when the behaviour is de-selected
		-- the extra data is from the signal that is causing the behavior transition
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
	---------------------------------------------
	OnObjectSeen = function( self, entity, fDistance, data )
		-- called when the AI sees an object registered for this kind of signal
		-- data.iValue = AI object type
		-- example
		-- if (data.iValue == 150) then -- grenade
		--	 ...
	end,
	
}
