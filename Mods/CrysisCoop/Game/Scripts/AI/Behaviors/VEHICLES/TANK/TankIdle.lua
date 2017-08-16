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


AIBehaviour.TankIdle = {
	Name = "TankIdle",
	Base = "VehicleIdle",	
	alertness = 0,

	---------------------------------------------
	Constructor = function( self , entity )
		
		AI.SetAdjustPath(entity.id,1);
		
		entity.AI.strategy = 0;
		entity.AI.protect = nil;
		entity.AI.vDefultPos = {};
		CopyVector ( entity.AI.vDefultPos, entity:GetPos() );

		AIBehaviour.VehicleIdle:Constructor( entity );

	end,

	--------------------------------------------------------------------------
	TANK_PROTECT_ME = function( self, entity, sender )

		if ( AI.GetSpeciesOf(entity.id) == AI.GetSpeciesOf(sender.id) ) then

			entity.AI.protect = sender.id;

			if ( entity.id == sender.id ) then
				if (entity.AI.mindType == 3 ) then
					entity.AI.mindType = 2;
				end
			else
				if (entity.AI.mindType == 2 ) then
					entity.AI.mindType = 3;
				end
			end

		end

	end,
	
}
