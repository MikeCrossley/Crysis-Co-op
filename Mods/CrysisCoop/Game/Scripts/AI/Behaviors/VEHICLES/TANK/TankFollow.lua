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


AIBehaviour.TankFollow = {
	Name = "TankFollow",
	Base = "Car_follow",	
	alertness = 0,

	-- SYSTEM EVENTS			-----
	OnPlayerSeen = function( self, entity, fDistance )
	end,	
	
	OnEnemyMemory = function( self, entity, fDistance )
	end,


}
