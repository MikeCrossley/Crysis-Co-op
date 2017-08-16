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


AIBehaviour.HeliGoto = {
	Name = "HeliGoto",
	Base = "VehicleGoto",
	alertness = 0,
	--------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )

		if ( entity.AI.vehicleIgnorantIssued == true ) then
			return;
		end

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_HELI_ATTACK", entity.id);
		end

	end,
	--------------------------------------------------------------------------
	OnBulletRain = function ( self, entity, sender, data )	
		self:OnEnemyDamage( entity, sender, data );
	end,
	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender, data )

		if ( entity.AI.vehicleIgnorantIssued == true ) then
			return;
		end

		if ( AIBehaviour.HELIDEFAULT:heliCheckDamage( entity, data ) == false ) then
			return;
		end
		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_HELI_PATROL", entity.id);

	end,

}
