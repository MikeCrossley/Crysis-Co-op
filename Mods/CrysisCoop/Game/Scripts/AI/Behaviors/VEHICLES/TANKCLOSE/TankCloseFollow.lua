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
--  - 10/07/2006   : Duplicated by Tetsuji
--
--------------------------------------------------------------------------


AIBehaviour.TankCloseFollow = {
	Name = "TankCloseFollow",
	Base = "Car_follow",	
	alertness = 0,

	-- SYSTEM EVENTS			-----
  -- I made dummy functions which prevent from invoking base functions 26/10/05 tiwasaki
	OnPlayerSeen = function( self, entity, fDistance )
	end,	
	
	OnEnemyMemory = function( self, entity, fDistance )
	end,

}
