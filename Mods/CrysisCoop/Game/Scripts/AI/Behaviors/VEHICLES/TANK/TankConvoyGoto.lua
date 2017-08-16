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


AIBehaviour.TankConvoyGoto = {

	Name = "TankConvoyGoto",
	Base = "VehicleGoto",
	alertness = 0,

	---------------------------------------------------------------------------------------------------------------------------------------
	OnBulletRain = function ( self, entity, sender )	
		entity:SelectPipe(0,"do_nothing");
	end,

	---------------------------------------------
	OnEnemyDamage = function( self, entity, sender, data )
		entity:SelectPipe(0,"do_nothing");
	end,

	--------------------------------------------------------------------------
	OnSomebodyDied = function( self,entity,sender,data )
		entity:SelectPipe(0,"do_nothing");
	end,

	OnGroupMemberDied = function( self, entity, sender )
		entity:SelectPipe(0,"do_nothing");
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
