--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--   Description: reaction on grenade - ingnore everything and run away
--  
--------------------------------------------------------------------------
--  History:
--  - 23/nov/2005   : Created by Kirill Bulatsev
--	- Mar/2006			: Rewritten by Luciano Morpurgo (smartobject usage)
--------------------------------------------------------------------------



AIBehaviour.HBaseTranquilized = {
	Name = "HBaseTranquilized",
	Base = "Dumb",
	alertness = 1,
	exclusive = 1,

	Constructor = function(self,entity,data)
		AI.ModifySmartObjectStates(entity.id,"Busy");
		entity:InsertSubpipe( AIGOALPIPE_HIGHPRIORITY, "cv_tranquilized", nil, -190 );
		entity:TriggerEvent(AIEVENT_SLEEP);
	end,	
	---------------------------------------------
	Destructor = function(self,entity)
		AI.ModifySmartObjectStates(entity.id,"-Busy");
		entity:CancelSubpipe( -190 );
	end,
	---------------------------------------------
	-- being waken up from fall & play
--	FALL_AND_PLAY_WAKEUP	= function(self, entity, data)
--		entity:SelectPipe(0,"cv_tranquilized_wakeup");
--	end,
	---------------------------------------------
	OnSeenByEnemy = function( self, entity, sender )
	end,
	---------------------------------------------
	OnQueryUseObject = function ( self, entity, sender, extraData )
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
	end,
	---------------------------------------------
	OnTargetDead = function( self, entity )
	end,
	
	--------------------------------------------------
	OnBulletHit = function( self, entity, sender,data )
	end,


	---------------------------------------------
	OnSomethingSeen = function( self, entity )
	end,
	---------------------------------------------
	OnThreateningSeen = function( self, entity )
	end,
	--------------------------------------------------
	OnNoHidingPlace = function( self, entity, sender,data )
	end,	
	---------------------------------------------
	OnBackOffFailed = function(self,entity,sender)
	end,
	---------------------------------------------
	GET_ALERTED = function( self, entity )
	end,
	---------------------------------------------
	DRAW_GUN = function( self, entity )
	end,
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the enemy can no longer see its foe, but remembers where it saw it last
	end,
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
	end,
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity, fDistance )
	end,
	--------------------------------------------------
	OnCoverRequested = function ( self, entity, sender)
		-- called when the enemy is damaged
	end,
	---------------------------------------------
	OnDamage = function ( self, entity, sender)
	end,
	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender,data)
	end,
	---------------------------------------------
	OnReload = function( self, entity )
	end,
	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender,data)
	end,
	--------------------------------------------------
	OnObjectSeen = function( self, entity, fDistance, signalData )
	end,
	---------------------------------------------
	OnCloseContact = function(self,entity,sender)
	end,
	---------------------------------------------
	OnPathFound = function(self,entity,sender)
	end,
	---------------------------------------------
	OnNoTarget = function(self,entity,sender)
	end,
	--------------------------------------------------
	-- CUSTOM SIGNALS
	--------------------------------------------------

	--------------------------------------------------
	OnSomebodyDied = function( self, entity, sender)
	end,
	--------------------------------------------------
	OnGroupMemberDiedNearest = function ( self, entity, sender,data)
	end,
	--------------------------------------------------
	INVESTIGATE_TARGET = function (self, entity, sender)
	end,
	---------------------------------------------
	-- GROUP SIGNALS
	--------------------------------------------------
	HEADS_UP_GUYS = function (self, entity, sender)
	end,
	---------------------------------------------
	INCOMING_FIRE = function (self, entity, sender)
	end,
	---------------------------------------------
	OnHideSpotReached = function ( self, entity, sender,data)
	end,
	-------------------------------------------------
}
