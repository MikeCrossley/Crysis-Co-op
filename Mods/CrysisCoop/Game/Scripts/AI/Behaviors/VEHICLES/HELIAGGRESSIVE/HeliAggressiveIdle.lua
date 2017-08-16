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
--  31/10/2006   : Created by Tetsuji
--
--------------------------------------------------------------------------

AIBehaviour.HeliAggressiveIdle = {
	Name = "HeliAggressiveIdle",
	Base = "HeliIdle",	

	---------------------------------------------
	Constructor = function( self , entity )
	
		AIBehaviour.HeliIdle:Constructor( entity );
		entity.AI.isHeliAggressive = true; -- temporary

		AI.ChangeParameter(entity.id,AIPARAM_SIGHTENVSCALE_NORMAL,1);
		AI.ChangeParameter(entity.id,AIPARAM_SIGHTENVSCALE_ALARMED,1);

	end,
	
}
