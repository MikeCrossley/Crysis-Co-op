--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2006.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: 
--  "Go to" behaviour for the vtol
--------------------------------------------------------------------------
--  History:
-- - 13/06/2005   : the first version by Tetsuji Iwasaki
--
--------------------------------------------------------------------------


AIBehaviour.VtolGoto = {
	Name = "VtolGoto",
	Base = "HeliGoto",
	alertness = 0,

	OnPlayerSeen = function( self, entity, fDistance )
		AIBehaviour.HELIDEFAULT:heliRequest2ndGunnerShoot( entity );
	end,

}
