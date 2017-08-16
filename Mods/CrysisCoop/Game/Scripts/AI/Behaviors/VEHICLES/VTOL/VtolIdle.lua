--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2006.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Vtol
--  
--------------------------------------------------------------------------
--  History:
-- - 13/06/2005   : the first version by Tetsuji Iwasaki
--
--------------------------------------------------------------------------

AIBehaviour.VtolIdle = {
	Name = "VtolIdle",
	Base = "HeliIdle",
	alertness = 0,
	---------------------------------------------
	Constructor = function( self , entity )
		
		AIBehaviour.HeliIdle:Constructor( entity );

		for i,seat in pairs(entity.Seats) do
			if( seat.passengerId ) then
				local member = System.GetEntity( seat.passengerId );
				if( member ~= nil ) then
				  if (seat.isDriver) then
						local howManyWeapons = seat.seat:GetWeaponCount();
						if ( howManyWeapons > 0 ) then
							for j = 1,howManyWeapons do
								local weaponId = seat.seat:GetWeaponId(j);
								local w = System.GetEntity(weaponId);
								if (w.weapon:GetAmmoType()=="a2ahomingmissile") then
									seat.seat:SetAIWeapon( weaponId );
								end
								if (w.weapon:GetAmmoType()=="a2ahomingmissile_ascmod") then
									seat.seat:SetAIWeapon( weaponId );
								end
							end
						end
					end
				end
			end
		end

		entity.AI.isVtol = true;
		entity.vehicle:BlockAutomaticDoors( false );
		entity.vehicle:SetMovementMode(0);
		entity.vehicle:RetractGears();

		AI.ChangeParameter(entity.id,AIPARAM_SIGHTENVSCALE_NORMAL,1);
		AI.ChangeParameter(entity.id,AIPARAM_SIGHTENVSCALE_ALARMED,1);

	end,

	OnPlayerSeen = function( self, entity, fDistance )
		AIBehaviour.HELIDEFAULT:heliRequest2ndGunnerShoot( entity );
	end,

	VTOL_DOOR_OPEN = function( self, entity, sender, data )

			entity.vehicle:BlockAutomaticDoors( true );
			entity.vehicle:OpenAutomaticDoors();

	end,

	VTOL_DOOR_CLOSE = function( self, entity, sender, data )

			entity.vehicle:BlockAutomaticDoors( true );
			entity.vehicle:CloseAutomaticDoors();

	end,
	
	VTOL_DOOR_AUTO = function( self, entity, sender, data )

			entity.vehicle:BlockAutomaticDoors( false );

	end,

	VTOL_DOOR_BLOCK = function( self, entity, sender, data )

			entity.vehicle:BlockAutomaticDoors( true );
	
	end,

	VTOL_GUNNER_START = function( self, entity, sender, data )

		AIBehaviour.HELIDEFAULT:heliRequest2ndGunnerShoot( entity );

	end,

	VTOL_ASCENSION = function( self, entity, sender, data )
		AI.ChangeParameter(entity.id,AIPARAM_COMBATCLASS,AICombatClasses.ascensionVTOL);		
		entity.currentCombatClass = AICombatClasses.ascensionVTOL;
	end,

}