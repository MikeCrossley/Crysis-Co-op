--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2007.
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
AIBehaviour.ScoutMeleeAttack = {
	Name = "ScoutMeleeAttack",
	Base = "ScoutMeleeDefault",
	alertness = 2,

	--------------------------------------------------------------------------
	Constructor = function ( self, entity, data )
		AIBehaviour.ScoutMeleeDefault:CLOAK( entity );
	end,
	--------------------------------------------------------------------------
	Destructor = function ( self, entity, data )
	end,

}
