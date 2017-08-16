--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2005.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Helocipter Behaviour SCRIPT
--  
--------------------------------------------------------------------------
--  History:
--  - 12/06/2006   : the first implementation by Tetsuji
--
--------------------------------------------------------------------------

AIBehaviour.HeliEmergencyLanding = {
	Name = "HeliEmergencyLanding",
	alertness = 0,

	-- SYSTEM EVENTS			-----
	---------------------------------------------
	Constructor = function( self, entity, sender, data )

		AI.CreateGoalPipe("heliHoverAttackDefault");
		AI.PushGoal("heliHoverAttackDefault","timeout",1,0.3);
		AI.PushGoal("heliHoverAttackDefault","signal",0,1,"HELI_EMERGENCY_LANDING_START",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"heliHoverAttackDefault");
		local vec = {x=0.0,y=0.0,z=0.0};
		AI.SetForcedNavigation( entity.id, vec );

	end,
	--------------------------------------------------------------------------
	HELI_EMERGENCY_LANDING_START = function( self, entity )

		self:HELI_EMERGENCY_LANDING_END( entity );

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
	--------------------------------------------------------------------------
	HELI_EMERGENCY_LANDING_END = function( self, entity )

		AI.CreateGoalPipe("heliEmergencyLanding2");
		AI.PushGoal("heliEmergencyLanding2","timeout",1,5);
		AI.PushGoal("heliEmergencyLanding2","signal",1,1,"HELI_EMERGENCY_LANDING_END2",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"heliEmergencyLanding2");

	end,
	--------------------------------------------------------------------------
	HELI_EMERGENCY_LANDING_END2 = function( self, entity )

		g_gameRules:CreateExplosion(entity.id,entity.id,5000,entity:GetPos(),nil,10);


	end,
	--------------------------------------------------------------------------


}
