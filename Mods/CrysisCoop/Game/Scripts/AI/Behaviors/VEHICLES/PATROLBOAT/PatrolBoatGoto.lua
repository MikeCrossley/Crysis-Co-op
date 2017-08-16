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


AIBehaviour.PatrolBoatGoto = {
	Name = "PatrolBoatGoto",
	Base = "VehicleGoto",

	--------------------------------------------------------------------------
	OnBulletRain = function ( self, entity, sender, data )	

		self:OnEnemyDamage( entity, sender, data );
		
	end,

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender, data )

		local targetEntity
		if ( data and data.id ) then
			targetEntity = System.GetEntity( data.id );
			entity.AI.bGotShoot = true;
			entity.AI.GotShootId = targetEntity.id;
		end
		AI.Signal(SIGNALFILTER_SENDER,1,"TO_PATROLBOAT_ATTACK", entity.id);

	end,

	--------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
	--		entity:InsertSubpipe(0,"start_fire");
	end,
	
}
