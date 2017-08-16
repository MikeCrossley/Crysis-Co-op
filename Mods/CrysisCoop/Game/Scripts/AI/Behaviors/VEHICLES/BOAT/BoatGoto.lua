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
--
--------------------------------------------------------------------------


AIBehaviour.BoatGoto = {
	Name = "BoatGoto",
	Base = "VehicleGoto",

	--------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
	--		entity:InsertSubpipe(0,"start_fire");
	end,
	
}
