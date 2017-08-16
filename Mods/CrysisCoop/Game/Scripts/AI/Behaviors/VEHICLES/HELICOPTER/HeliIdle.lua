--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2005.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Helocipter Behaviour SCRIPT
--  
--------------------------------------------------------------------------
--  History:
--  - 09/06/2005   : Created by Kirill Bulatsev
--
--------------------------------------------------------------------------

AIBehaviour.HeliIdle = {
	Name = "HeliIdle",
	Base = "VehicleIdle",
	alertness = 0,

	-- SYSTEM EVENTS			-----
	---------------------------------------------
	Constructor = function( self, entity )

		entity.vehicle:SetMovementSoundVolume(1.0);

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
								if (w.weapon:GetAmmoType()=="helicoptermissile") then
									seat.seat:SetAIWeapon( weaponId );
								end
							end
						end
					end
				end
			end
		end

		--System.Log(entity:GetName().." HeliIdle REQUEST DISABLE= 1 ");
		--AI.AutoDisable( entity.id, 1 );
		if ( entity.currentCombatClass ) then
--			System.Log("current combatclass "..entity.currentCombatClass);
		end
		if ( entity.currentCombatClass ~= AICombatClasses.ascensionVTOL ) then
			AI.ChangeParameter(entity.id,AIPARAM_COMBATCLASS,AICombatClasses.Heli);
			entity.currentCombatClass = AICombatClasses.Heli;
		end
				
		AIBehaviour.HELIDEFAULT:heliRemoveID( entity );

		entity.AI.followVectors = { 
			{ x = 0.0, y = 0.0, z = 0.0 }, -- vectors[1].(x,y,z)
			{ x = 0.0, y = 0.0, z = 0.0 }, -- vectors[2].(x,y,z)
			{ x = 0.0, y = 0.0, z = 0.0 }, -- vectors[3].(x,y,z)
			{ x = 0.0, y = 0.0, z = 0.0 }, -- vectors[4].(x,y,z)
			{ x = 0.0, y = 0.0, z = 0.0 }, -- vectors[5].(x,y,z)
			{ x = 0.0, y = 0.0, z = 0.0 }, -- vectors[6].(x,y,z)
			{ x = 0.0, y = 0.0, z = 0.0 }, -- vectors[7].(x,y,z)
			{ x = 0.0, y = 0.0, z = 0.0 }, -- vectors[8].(x,y,z)
		}

		entity.AI.bFirstAttack = true;
		-- keep the first position to know the height of the ground roughly
		entity.AI.vSafePosition = {};
		entity.AI.vlastDamagePosition = {};
		entity.AI.DoMemoryAttack = false;
		entity.AI.time = System.GetCurrTime() - 100.0;
		entity.AI.stayPosition = 0;
		entity.AI.autoFire = 0;
		entity.AI.memoryCount =0;
		
		entity.AI.vZero = { x=0.0, y=0.0, z=0.0 };
		entity.AI.vUp = { x=0.0, y=0.0, z=1.0 };
		AI.SetForcedNavigation( entity.id, entity.AI.vZero );

		entity.AI.vSafePosition = {};
		CopyVector( entity.AI.vSafePosition , entity:GetPos() );
		--AI.LogEvent("safe position "..entity.AI.vSafePosition.x..","..entity.AI.vSafePosition.y..","..entity.AI.vSafePosition.z);
		if ( entity.AI.hoveringOffset == nil ) then
			entity.AI.hoveringOffset = 0.0;
		end

		entity.AI.isHeliAggressive = true; -- temporary

	end,

	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )

		if ( entity.AI.vehicleIgnorantIssued == true ) then
			return;
		end

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_HELI_ATTACK", entity.id);
		end

	end,

	---------------------------------------------
	OnObjectSeen = function( self, entity, fDistance, data )
		-- called when the AI sees an object registered for this kind of signal
		-- data.iValue = AI object type
		-- example
		-- if (data.iValue == 150) then -- grenade
		--	 ...
		if ( data.iValue == AIOBJECT_RPG) then
			entity:InsertSubpipe(0,"devalue_target");
		end

	end,

	--------------------------------------------------------------------------
	OnBulletRain = function ( self, entity, sender, data )	
		--self:OnEnemyDamage( entity, sender, data );
	end,
	--------------------------------------------------------------------------
	OnSoreDamage = function ( self, entity, sender, data )
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
	
	---------------------------------------------
	OnCollision = function ( self, entity, sender, data )
		if ( entity.vehicle:GetMovementDamageRatio()>0.49 ) then
			g_gameRules:CreateExplosion(entity.id,entity.id,5000,entity:GetPos(),nil,10);
		end
	end,

	TO_HELI_EMERGENCYLANDING = function( self, entity, sender, data )
		if ( entity.vehicle:GetMovementDamageRatio()>0.49 ) then
			g_gameRules:CreateExplosion(entity.id,entity.id,5000,entity:GetPos(),nil,10);
		end
	end,

	---------------------------------------------	
	--------------------------------------------
	GO_PATH = function( self,entity, sender )
		
--		entity:LoadPeople();
--		entity:Fly();		
--		entity:SelectPipe(0,"h_goto", entity.Properties.pathname..0);		
	end,
	

	---------------------------------------------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------------------------------------------
	--
	--	FlowGraph	actions 
	--
	---------------------------------------------------------------------------------------------------------------------------------------

	--------------------------------------------
	
	START_MOVING = function( self,entity,sender )
--		entity:InsertSubpipe(0,"vehicle_goto");
		entity:SelectPipe(0,"h_move");
	end,
	---------------------------------------------

	---------------------------------------------
	ACT_FOLLOWPATH = function( self, entity, sender, data )

		local pathfind = data.point.x;
		local reverse = data.point.y;
		local startNearest = data.point.z;
		local loops = data.fValue;

		local pipeName = "follow_path";
		if(pathfind > 0) then
			pipeName = pipeName.."_pathfind";
		end
		if(reverse > 0) then
			pipeName = pipeName.."_reverse";
		end
		if(startNearest > 0) then
			pipeName = pipeName.."_nearest";
		end
		
	  AI.CreateGoalPipe(pipeName);
    AI.PushGoal(pipeName, "followpath", 1, pathfind, reverse, startNearest, loops, 0, false );
		AI.PushGoal(pipeName, "signal", 1, 1, "END_ACT_FOLLOWPATH",0 );

    entity:InsertSubpipe( AIGOALPIPE_SAMEPRIORITY, pipeName, nil, data.iValue );

	end,

	HELI_SETVOLUME = function( self, entity, sender, data )
		if ( data.fValue ~=nil ) then
			local vol = data.fValue;
			if ( vol < 0.0 ) then
				vol = 0.0;
			end
			if ( vol > 0.0 ) then
				vol = 1.0;
			end
			entity.vehicle:SetMovementSoundVolume( data.fValue );
		end
	end,
	HELI_SETHOVEROFFSET = function( self, entity, sender, data )
		entity.AI.hoveringOffset = data.fValue;
		-- AI.LogEvent(entity:GetName().." changed hovering offset to "..entity.AI.hoveringOffset);
	end,
	TO_VTOL_FLY = function( self, entity, sender, data )
		entity.AI.vReinforcementSetPosition = {};
		CopyVector( entity.AI.vReinforcementSetPosition , data.point );
		entity.AI.flyPathName = nil;
		if ( data and  data.ObjectName ) then
			entity.AI.flyPathName =  data.ObjectName;
		end
	end,
	TO_HELI_FLY = function( self, entity, sender, data )
		entity.AI.vReinforcementSetPosition = {};
		CopyVector( entity.AI.vReinforcementSetPosition , data.point );
		entity.AI.flyPathName = nil;
		if ( data and  data.ObjectName ) then
			entity.AI.flyPathName =  data.ObjectName;
		end
	end,
	TO_HELI_REINFORCEMENT = function( self, entity, sender, data )
		AI.LogEvent(entity:GetName().." TO_HELI_REINFORCEMENT "..data.point.x..","..data.point.y..","..data.point.z);
		entity.AI.vReinforcementSetPosition = {};
		entity.AI.vReinforcementSetPosition2 = nil;
		entity.AI.vReinforcementSetDirection = {};
		entity.AI.reinforcementPat = data.iValue;
		entity.AI.reinforcementId = data.id;
		entity.AI.tagCounter = 1;
		CopyVector( entity.AI.vReinforcementSetPosition , data.point );
		entity.AI.bExitPassengers = true;
		entity.AI.bExitDrivers = false;
		entity.AI.bFinishReinforcement = false;
		entity.AI.bCancelReinforcement = false;
	end,
	TO_HELI_LANDING = function( self, entity, sender, data )
		AI.LogEvent(entity:GetName().." TO_HELI_LANDING "..data.point.x..","..data.point.y..","..data.point.z);
		entity.AI.vReinforcementSetPosition = {};
		entity.AI.vReinforcementSetPosition2 = nil;
		entity.AI.vReinforcementSetDirection = {};
		entity.AI.reinforcementPat = data.iValue;
		entity.AI.reinforcementId = data.id;
		entity.AI.tagCounter = 1;
		CopyVector( entity.AI.vReinforcementSetPosition , data.point );
		entity.AI.bExitPassengers = false;
		entity.AI.bExitDrivers = false;
		entity.AI.bFinishReinforcement = false;
		entity.AI.bCancelReinforcement = false;
	end,
	TO_HELI_LANDING2 = function( self, entity, sender, data )
		AI.LogEvent(entity:GetName().." TO_HELI_LANDING "..data.point.x..","..data.point.y..","..data.point.z);
		entity.AI.vReinforcementSetPosition = {};
		entity.AI.vReinforcementSetPosition2 = nil;
		entity.AI.vReinforcementSetDirection = {};
		entity.AI.reinforcementPat = data.iValue;
		entity.AI.reinforcementId = data.id;
		entity.AI.tagCounter = 1;
		CopyVector( entity.AI.vReinforcementSetPosition , data.point );
		entity.AI.bExitPassengers = false;
		entity.AI.bExitDrivers = true;
		entity.AI.bFinishReinforcement = false;
		entity.AI.bCancelReinforcement = false;
	end,
	TO_HELI_SMOOTHGOTO= function( self, entity, sender, data )
		entity.AI.smoothGotoId = data.id;
	end,
}