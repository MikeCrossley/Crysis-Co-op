--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: 
--  "Go to" behaviour for the tank
--------------------------------------------------------------------------
--  History:
--  - 06/02/2005   : Created by Luciano Morputho
--  - 10/07/2006   : Duplicated by Tetsuji
--
--------------------------------------------------------------------------


AIBehaviour.TankCloseGoto = {
	Name = "TankCloseGoto",
	Base = "VehicleGoto",
	alertness = 0,

	---------------------------------------------------------------------------------------------------------------------------------------
	OnBulletRain = function ( self, entity, sender )	

	end,

	---------------------------------------------
	OnEnemyDamage = function( self, entity, sender, data )

	end,

}
