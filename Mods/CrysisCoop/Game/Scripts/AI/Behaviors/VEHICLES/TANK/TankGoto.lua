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


AIBehaviour.TankGoto = {
	Name = "TankGoto",
	Base = "VehicleGoto",
	alertness = 0,

	---------------------------------------------------------------------------------------------------------------------------------------
	OnBulletRain = function ( self, entity, sender )	

		-- called when there are bullet impacts nearby

		--If the tank get a damage During patorolling
		--06/12/05 Tetsuji

		if ( entity.AI.vehicleIgnorantIssued and entity.AI.vehicleIgnorantIssued ==true ) then
		else

			if ( entity.AI.VehicleConvoyRequester == nil ) then

				local senderEntity =System.GetEntity( sender.id );
				if ( senderEntity ) then
					AI.LogComment(entity:GetName().." TankGoto.OnBulletRain() from "..senderEntity:GetName());
				else
					AI.LogComment(entity:GetName().." TankGoto.OnBulletRain() from someone");
				end

				AI.Signal(SIGNALFILTER_ANYONEINCOMM,1,"TO_TANK_ALERT", entity.id);

			end

		end

	end,

	---------------------------------------------
	OnEnemyDamage = function( self, entity, sender, data )

		-- called when AI is damaged by an enemy AI
		-- data.id = damaging enemy's entity id
		-- local hitter = System.GetEntity(data.id);
		-- local hitterName = hitter:GetName()

		--If the tank get a damage During patorolling
		--06/12/05 Tetsuji

		if ( entity.AI.vehicleIgnorantIssued and entity.AI.vehicleIgnorantIssued ==true ) then
		else

			if ( entity.AI.VehicleConvoyRequester == nil ) then

				local senderEntity =System.GetEntity( data.id );
				if ( senderEntity ) then
					AI.LogComment(entity:GetName().." TankGoto.OnEnemyDamage() from "..senderEntity:GetName());
				else
					AI.LogComment(entity:GetName().." TankGoto.OnEnemyDamage() from someone");
				end
				AI.Signal(SIGNALFILTER_ANYONEINCOMM,1,"TO_TANK_ALERT", entity.id);

			end

		end
		
	end,

	--------------------------------------------------------------------------
	OnSomebodyDied = function( self, entity, sender )
	end,

	OnGroupMemberDied = function( self, entity, sender )
		if ( entity.AI.vehicleIgnorantIssued and entity.AI.vehicleIgnorantIssued == true ) then
		else
			if ( entity.AI.VehicleConvoyRequester ~= nil ) then
				entity:SelectPipe(0,"do_nothing");
				entity.AI.VehicleConvoyRequester = nil;
			end
		end
	end,

	OnGroupMemberDiedNearest = function( self, entity, sender, data )
		AI.Signal(SIGNALFILTER_GROUPONLY, 1, "OnGroupMemberDied",entity.id,data);
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
