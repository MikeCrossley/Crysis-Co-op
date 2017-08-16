--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Threatened behavior for Alien Trooper. 
--  
--------------------------------------------------------------------------
--  History:
--  - 7/7/2005     : Created by Mikko Mononen
--
--------------------------------------------------------------------------
AIBehaviour.TrooperThreatened = {
	Name = "TrooperThreatened",
	Base = "TROOPERDEFAULT",
	NOPREVIOUS = 1,
	alertness = 2,
	
	---------------------------------------------
	Constructor = function (self, entity)
		entity:MakeAlerted();
		entity:Event_UnCloak();
	end,

	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		entity:TriggerEvent(AIEVENT_CLEAR);
	end,

	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the enemy can no longer see its foe, but remembers where it saw it last
	end,

	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
	end,

	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
		entity:TriggerEvent(AIEVENT_CLEAR);
	end,

	---------------------------------------------
	OnReceivingDamage = function ( self, entity, sender)
	end,

	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender)	
	end,

	--------------------------------------------------
	OnGrenadeSeen = function( self, entity, fDistance )
	end,

	---------------------------------------------
	OnGroupMemberDied = function( self, entity )
		-- called when a member of the group dies
	end,

	--------------------------------------------------
	OnGroupMemberDiedNearest = function ( self, entity, sender)
	end,

	--------------------------------------------------
	HEADS_UP_GUYS = function (self, entity, sender)
	end,

	---------------------------------------------
	INCOMING_FIRE = function (self, entity, sender)
	end,

	---------------------------------------------
	FINISH_RUN_TO_FRIEND = function (self, entity, sender)
		entity:TriggerEvent(AIEVENT_CLEAR);
	end,
	
}