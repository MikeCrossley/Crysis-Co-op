--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2005.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: boat Behaviour SCRIPT
--  
--------------------------------------------------------------------------
--  History:
--  - 11/07/2005   : Created by Kirill Bulatsev
--
--------------------------------------------------------------------------

AIBehaviour.BoatIdle = {
	Name = "BoatIdle",
	Base = "VehicleIdle",		

	---------------------------------------------
	Constructor = function( self , entity )
		
		AI.ChangeParameter(entity.id,AIPARAM_COMBATCLASS,AICombatClasses.BOAT);		
		AI.SetAdjustPath(entity.id,1);
		AIBehaviour.VehicleIdle:Constructor( entity );

	end,

	

	--------------------------------------------
	---------------------------------------------
	
}