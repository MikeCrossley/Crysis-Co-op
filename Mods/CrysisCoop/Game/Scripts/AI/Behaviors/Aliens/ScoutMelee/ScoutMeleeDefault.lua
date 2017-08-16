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
--	- 15/01/2007   : Separated as the Melee Scout by Tetsuji Iwasaki
--------------------------------------------------------------------------

--------------------------------------------------------------------------
AIBehaviour.ScoutMeleeDefault = {
	Name = "ScoutMeleeDefault",

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

}

