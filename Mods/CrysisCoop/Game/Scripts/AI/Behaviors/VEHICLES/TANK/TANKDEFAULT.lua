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
--  - 10/07/2006   : Created by Tetsuji
--
--------------------------------------------------------------------------

AIBehaviour.TANKDEFAULT = {
	Name = "TANKDEFAULT",

	--------------------------------------------------------------------------
	-- shared functions 
	--------------------------------------------------------------------------

	--------------------------------------------------------------------------
	request2ndGunnerShoot = function( self, entity )

		for i,seat in pairs(entity.Seats) do
			if( seat.passengerId ) then
				local member = System.GetEntity( seat.passengerId );
				if( member ~= nil ) then
			
				  if (seat.isDriver) then
				  else
						local seatId = entity:GetSeatId(member.id);
				  	if ( seat.seat:GetWeaponCount() > 0) then
							bFound = true;
							g_SignalData.fValue = entity.Properties.attackrange;
							AI.Signal(SIGNALFILTER_SENDER, 1, "INVEHICLEGUNNER_REQUEST_SHOOT", member.id, g_SignalData);
							return true;
						end
					end
			
				end
			end
		end	

		return false;

	end,

	--------------------------------------------------------------------------
	selectCannonForTheDriver = function( self, entity, sw )

		local i;
		local j;

		for i,seat in pairs(entity.Seats) do
			if( seat.passengerId ) then
				local member = System.GetEntity( seat.passengerId );
				if( member ~= nil ) then
				  if (seat.isDriver) then
						local howManyWeapons = seat.seat:GetWeaponCount();
						--System.Log(entity:GetName().." drvier has weapons #"..howManyWeapons );
						if ( howManyWeapons > 0 ) then
							for j = 1,howManyWeapons do
								local weaponId = seat.seat:GetWeaponId(j);
								local w = System.GetEntity(weaponId);
								--System.Log(entity:GetName().." weapon no "..j.." "..w.weapon:GetAmmoType()  );
								if ( entity.AI.isAAA ~=nil and  entity.AI.isAAA == true ) then
									if (sw==true) then
										if (w.weapon:GetAmmoType()=="dumbaamissile") then
											seat.seat:SetAIWeapon( weaponId );
										end
									else
										if (w.weapon:GetAmmoType()=="tankaa") then
											seat.seat:SetAIWeapon( weaponId );
										end
									end
								elseif ( entity.AI.isAPC ~=nil and  entity.AI.isAPC == true ) then
									if (sw==true) then
										if (w.weapon:GetAmmoType()=="towmissile") then
											seat.seat:SetAIWeapon( weaponId );
										end
									else
										if (w.weapon:GetAmmoType()=="tank30") then
											seat.seat:SetAIWeapon( weaponId );
										end
									end
								else
									if (sw==true) then
										if (w.weapon:GetAmmoType()=="tank125") then
											seat.seat:SetAIWeapon( weaponId );
										end
									else
										if (w.weapon:GetAmmoType()=="MGbullet") then
											seat.seat:SetAIWeapon( weaponId );
										end
									end
								end
							end
						end
					end
				end
			end
		end

	end,

	--------------------------------------------------------------------------
	tankHasGunner = function( self, entity )

		for i,seat in pairs(entity.Seats) do
			if( seat.passengerId ) then
				local member = System.GetEntity( seat.passengerId );
				if( member ~= nil ) then
			
				  if (seat.isDriver) then
				  else
						local seatId = entity:GetSeatId(member.id);
				  	if ( seat.seat:GetWeaponCount() > 0) then
							return true;
						end
					end
			
				end
			end
		end	

		return false;

	end,
	
	--------------------------------------------------------------------------
	tankCheckPlayerVehicle = function( self, entity )

		if ( AI.GetTypeOf( entity.id ) == AIOBJECT_VEHICLE ) then

			local i;
 
			for i,seat in pairs(entity.Seats) do
				if( seat.passengerId ) then
					local member = System.GetEntity( seat.passengerId );
					if( member ~= nil ) then
						if (member.actor and member.actor:IsPlayer()) then
							AI.ChangeParameter( entity.id,AIPARAM_COMBATCLASS,AICombatClasses.TankHi);
							return true;			  	
						end
					end
				end
			end
		
		end
	
		if ( AI.GetTypeOf( entity.id ) == AIOBJECT_PLAYER ) then
			local vehicleId = entity.actor:GetLinkedVehicleId();
			if ( vehicleId ) then
				local vehicle = System.GetEntity( vehicleId );
				AI.ChangeParameter( vehicle.id,AIPARAM_COMBATCLASS,AICombatClasses.TankHi);
				AI.LogEvent(vehicle:GetName().." set TankHi");
			end
			return true;
		end

		return false;

	end,

	--------------------------------------------------------------------------
	IsTargetVehicle = function( self, entity )

		if ( AI.GetTypeOf( entity.id ) == AIOBJECT_VEHICLE ) then
			return true;
		end
		
		if ( entity.actor ) then
			local vehicleId = entity.actor:GetLinkedVehicleId();
			if ( vehicleId ) then
				return true;
			end
		end

		return false;

	end,

	--------------------------------------------------------------------------
	tankGetTargetFowardDirection = function( self, entity )

		-- check the direction vector of the target.
		-- if he rides on the vehicles, returns a direction of the vehicle.

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			if ( AI.GetTypeOf(target.id) == AIOBJECT_PLAYER ) then
				CopyVector( out, System.GetViewCameraDir() );
				return;
			end

			if ( AI.GetTypeOf(target.id) == AIOBJECT_VEHICLE ) then
				CopyVector( out, target:GetDirectionVector(Yaxis) );
				return;
			end

			if ( target.actor ) then
				local vehicleId = target.actor:GetLinkedVehicleId();
				if ( vehicleId ) then
					local	vehicle = System.GetEntity( vehicleId );
					if( vehicle ) then
						CopyVector( out, vehicle:GetDirectionVector(Yaxis) );
						return;
					end
				end
			end
			
			FastScaleVector( out, target:GetDirectionVector(1), -1.0 );
			return;

		else

			FastScaleVector( out, entity:GetDirectionVector(1), -1.0 );
			return;

		end
	
	end,

	--------------------------------------------------------------------------
	tankDoesUseMachineGun = function( self, entity )

	-- check there is the 2nd gunner.

		if ( entity.AIMovementAbility.pathType == AIPATH_BOAT ) then
			return true;
		end

		if ( entity.AIMovementAbility.pathType == AIPATH_CAR ) then
			return true;
		end

		local bFound = false;
		local i;

  	--[[
		for i,seat in pairs(entity.Seats) do
			if( seat.passengerId ) then
				local member = System.GetEntity( seat.passengerId );
				if( member ~= nil ) then
			
				  if (seat.isDriver) then
				  else
						local seatId = entity:GetSeatId(member.id);
				  	if ( seat.seat:GetWeaponCount() > 0) then
						  if (member.actor:GetHealth() < 1.0) then
						  	-- if the gunner is dead, use the main gun
						  else
								bFound = true;
							end
						end
					end
			
				end
			end
		end
		--]]

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			local targetPos = {};
			CopyVector( targetPos, target:GetPos() );

			-- check the distance. if the distance is less than 25m, always use machine gun in any case

			local distanceToTheTarget = entity:GetDistance(target.id);

			if ( distanceToTheTarget < 25.0 ) then
				--AI.LogEvent(entity:GetName().." tankDoesUseMachineGun less than 25m");
				return true;
			end

			-- if he is on the vehicle use main gun.
			if ( target.actor ~=nil ) then
				vehicleId = target.actor:GetLinkedVehicleId();
				if ( vehicleId ) then
					vehicleEntity = System.GetEntity( vehicleId );
					if ( vehicleEntity ) then
						if ( entity.AI.isAPC ~= nil and entity.AI.isAPC == true ) then
							if ( AI.GetTypeOf( target.id ) == AIOBJECT_VEHICLE and AI.GetSubTypeOf( target.id ) == AIOBJECT_HELICOPTER ) then
								-- APC use bullet gun for the heli/VTOL
								return true;
							end
						end
						return false;
					end
				end
			end

			if ( entity.AI.isAPC ~= nil and entity.AI.isAPC == true ) then
				if ( AI.GetTypeOf( target.id ) == AIOBJECT_VEHICLE and AI.GetSubTypeOf( target.id ) == AIOBJECT_HELICOPTER ) then
					return true;
				end
			end

			if ( AI.GetTypeOf( target.id ) == AIOBJECT_VEHICLE ) then
				return false;
			end

			if ( entity.AI.isAPC ~= nil and entity.AI.isAPC == true ) then
					return true;
			end
			-- if there are a lot of soldier, use the main gun.

			local enemycnt = 0;
			local objects = {};
			local numObjects = AI.GetNearestEntitiesOfType( targetPos, AIOBJECT_PUPPET, 10, objects );

			for i = 1,numObjects do
				local objEntity = System.GetEntity( objects[i].id );
				if ( AI.Hostile( entity.id, objEntity.id ) ) then
					enemycnt = enemycnt + 1;
				end
			end
			--AI.LogEvent(entity:GetName().." tankDoesUseMachineGun puppet "..enemycnt.."/"..numObjects);

			if ( enemycnt > 2 ) then
				--AI.LogEvent(entity:GetName().." tankDoesUseMachineGun more than 3 enemy");
				return false;
			end

			-- if there is an enemy vehicle use the main gun.

			local enemycnt = 0;
			local hostilecnt = 0;
			local nospeciescnt = 0;
			local objects = {};
			local numObjects = AI.GetNearestEntitiesOfType( targetPos, AIOBJECT_VEHICLE, 10, objects ,AIOBJECTFILTER_INCLUDEINACTIVE);

			for i = 1,numObjects do
				local objEntity = System.GetEntity( objects[i].id );
				--AI.LogEvent(objEntity:GetName().."detected ");
				local species = AI.GetSpeciesOf(objEntity.id);
				if ( species ) then
					if ( species<0 ) then
						nospeciescnt = nospeciescnt +1;
						enemycnt = enemycnt + 1;
					elseif ( AI.Hostile( entity.id, objEntity.id ) ) then
						hostilecnt = hostilecnt +1;
						enemycnt = enemycnt + 1;
					else
						--AI.LogEvent(entity:GetName().." species "..AI.GetSpeciesOf(objEntity.id) );
					end
				else
					nospeciescnt = nospeciescnt +1;
					enemycnt = enemycnt + 1;
				end
			end

			--AI.LogEvent(entity:GetName().." tankDoesUseMachineGun vehicle "..enemycnt.."/"..numObjects.."("..hostilecnt..","..nospeciescnt..")");

			if ( enemycnt > 0 ) then
				--AI.LogEvent(entity:GetName().." tankDoesUseMachineGun nearby vehicle");
				return false;
			end

		
			-- if the target is the player, the tank should tend to use machine gun.

			if ( AI.GetTypeOf(target.id) == AIOBJECT_PLAYER ) then

				-- if the player is 100m far from the tank. the tank uses main gun.

				if ( distanceToTheTarget > 100.0 ) then
					--AI.LogEvent(entity:GetName().." tankDoesUseMachineGun player is morethan 100m");
					return false;
				end 

				--AI.LogEvent(entity:GetName().." tankDoesUseMachineGun player is within 100m");
				return	true;

			end

		else
			-- if the tank has no target.
	
			return false;
	
		end

		--AI.LogEvent(entity:GetName().." tankDoesUseMachineGun default");
		return false;		

	end,

	--------------------------------------------------------------------------
	checkFriendInWay = function( self, entity , vDifference )

		-- returns 0 no obstacle
		-- returns 1 there are obstacles and all obstacles are not moving
		-- returns 2 there is an obstacle which is moving

		local result = 0;
		local objects = {};

		local myPosition = {};
		local vRot = {};
	
		vDifference.x =0.0;
		vDifference.y =0.0;
		vDifference.z =0.0;

		CopyVector( myPosition, entity:GetPos() );
	
		CopyVector( vRot, entity:GetVelocity() );
		if ( LengthVector(vRot) < 0.1 ) then
			CopyVector( vRot, entity:GetDirectionVector(Yaxis) );
		end
		NormalizeVector( vRot );

		local i;

		local entities = System.GetPhysicalEntitiesInBox( entity:GetPos(), 30.0 );
		local targetEntity;

		if (entities) then

			-- calculate damage for each entity
			for i,targetEntity in ipairs(entities) do

				local objEntity = targetEntity;

				if ( objEntity.id == entity.id or objEntity:GetMass()< 200.0 ) then

				else

					local objPosition = {}
					CopyVector( objPosition, objEntity:GetPos() );

					if ( math.abs(myPosition.z - objPosition.z ) < 10.0 ) then -- if the object is not flying.

						local objDestDirN ={};
						local objDestDir ={};
						SubVectors( objDestDir, objPosition, myPosition );
						CopyVector( objDestDirN, objDestDir );
						NormalizeVector( objDestDirN );			
	
						local objDestance = LengthVector( objDestDir );
						if (objDestance < 1.0 ) then
							objDestance = 1.0;
						end
						objDestance = 30.0 - objDestance;
						if ( objDestance < 0.0 ) then
							objDestance = 0.0;
						end
						objDestance = objDestance * -1.0;

						FastScaleVector( objDestDir, objDestDirN, objDestance );
						FastSumVectors( vDifference, vDifference, objDestDir );

						local t = dotproduct3d( objDestDirN, vRot );
						--AI.LogComment("tankNoFriendInWay "..entity:GetName().." innter product with "..objEntity:GetName().." is "..t );

						if ( t > 0 ) then

							local objDistance = DistanceVectors( objPosition, myPosition );
							if ( objDistance < 15.0 ) then 
								--AI.LogComment("tankNoFriendInWay "..entity:GetName().." detected friend 3 "..objEntity:GetName() );
								if ( objEntity:GetSpeed() < 0.5 ) then
									if ( result == 0 ) then
										result = 1;
									end
								else
									result =  2;
								end
							end

							local d = DistanceLineAndPoint( objPosition, vRot, myPosition );
							if ( objDistance < 30.0 and d < 15.0 ) then
								--AI.LogComment("tankNoFriendInWay "..entity:GetName().." detected friend 2 "..objEntity:GetName() );
								if ( objEntity:GetSpeed() < 0.5 ) then
									if ( result == 0 ) then
										result = 1;
									end
								else
									result =  2;
								end
							end

						end

					end
				end
			end

		else
			--AI.LogComment("tankNoFriendInWay "..entity:GetName().." can't get entities");
		end	

		if ( result == true ) then
			--AI.LogComment("tankNoFriendInWay "..entity:GetName().." has no friend in way");
		else
			--AI.LogComment("tankNoFriendInWay "..entity:GetName().." has a friend in way");
		end

		return	result;

	end,

	--------------------------------------------------------------------------
	tankFovCheck = function( self, entity, vPos )

		local vDir = {};
		SubVectors( vDir, vPos, entity:GetPos() );
		NormalizeVector( vDir );

		local bPlayer = self:tankCheckPlayerVehicle( entity );
	
		local t;
		local inFOV = math.cos( 60.0 * 3.1415 / 180.0 );

		if ( bPlayer == true ) then
			t	= dotproduct3d(	vDir, System.GetViewCameraDir() );
		else
			t	= dotproduct3d( vDir, entity:GetDirectionVector(1) );
		end

		if ( t > inFOV ) then
			return true;
		else
			return false;
		end

	end,

	--------------------------------------------------------------------------
	tankFovCheck2 = function( self, entity, vPos )

		local vDir = {};
		SubVectors( vDir, vPos, entity:GetPos() );
		NormalizeVector( vDir );

		t	= dotproduct3d( vDir, entity:GetDirectionVector(1) );

		if ( t > 0 ) then
			return true;
		else
			return false;
		end

	end,

	---------------------------------------------
	tankGetIdealWng = function ( self, entity, vTargetPos, vWng, distance )

		local vMyPos = {};
		local vTmp = {};
		local vTmp2 = {};
		local vTmp3 = {};
		local vWngSrc = {};
		local vUp = { x=0.0, y=0.0, z=0.0 };

		local	bSucceedR = true;
		local	bSucceedL = true;
		
		CopyVector( vMyPos, entity:GetPos() );
		SubVectors( vTmp, vTargetPos, vMyPos );
		NormalizeVector( vTmp );
		crossproduct3d( vWngSrc, vTmp, vUp );
		NormalizeVector( vWngSrc );


		-------------------------------------- R
		
		FastScaleVectors(  vTmp, vWngSrc, distance );
		FastSumVectors( vTmp, vTmp, entity:GetPos() );

		CopyVector( vTmp2, AI.IntersectsForbidden( entity:GetPos() , vTmp ) );
		if ( DistanceVectors( vTmp2, vTmp ) > 0.0 ) then
			bSucceedR = false;
		else

			local level = System.GetTerrainElevation( vTmp );
			if ( math.abs( level - vMyPos.z) > 5.0 ) then
				bSucceedR = false;
			else

				vTmp2.x = vTmp.x;
				vTmp2.y = vTmp.y;
				vTmp2.z = vMyPos.z + 2.0;
	
				vTmp3.x = vMyPos.x;
				vTmp3.y = vMyPos.y;
				vTmp3.z = vMyPos.z + 2.0;
	
				SubVectors( vTmp2, vTmp2, vTmp3 );
	
				local	hits = Physics.RayWorldIntersection( vMyPos ,vTmp2,1,ent_terrain+ent_static+ent_rigid+ent_sleeping_rigid+ent_living,entity.id,nil,g_HitTable);
				if( hits > 0 ) then
					bSucceedR = false;
				end

			end

		end

		-------------------------------------- L

		FastScaleVectors(  vTmp, vWngSrc, distance * -1.0 );
		FastSumVectors( vTmp, vTmp, entity:GetPos() );

		vResult  = AI.IntersectsForbidden( entity:GetPos() , vTmp );
		if ( DistanceVectors( vResult, vTmp ) > 0.0 ) then
			bSucceedL = false;
		else

			local level = System.GetTerrainElevation( vTmp );
			if ( math.abs( level - vMyPos.z) > 5.0 ) then
				bSucceedL = false;
			else

				vTmp2.x = vTmp.x;
				vTmp2.y = vTmp.y;
				vTmp2.z = vMyPos.z + 2.0;
	
				vTmp3.x = vMyPos.x;
				vTmp3.y = vMyPos.y;
				vTmp3.z = vMyPos.z + 2.0;
	
				SubVectors( vTmp2, vTmp2, vTmp3 );
	
				local	hits = Physics.RayWorldIntersection( vMyPos ,vTmp2,1,ent_terrain+ent_static+ent_rigid+ent_sleeping_rigid+ent_living,entity.id,nil,g_HitTable);
				if( hits > 0 ) then
					bSucceedL = false;
				end

			end

		end

		if ( bSucceedR == true and bSucceedL == true ) then

			if ( random(1,2) == 1 ) then 
				FastScaleVectors(  vWng, vWngSrc, distance );
				return true;
			else
				FastScaleVectors(  vWng, vWngSrc, distance*-1.0 );
				return true;
			end

		else
			
			if ( bSucceedR == true ) then 
				FastScaleVectors(  vWng, vWngSrc, distance );
				return true;
			else
				FastScaleVectors(  vWng, vWngSrc, distance*-1.0 );
				return true;
			end
		
		end

		return false;

	end,
	
	---------------------------------------------
	tankTakeEvadeAction = function ( self, entity, signalname, targetEntity )

		if ( entity.AI.bBlockSignal ~= true ) then

			entity.AI.bBlockSignal = true;

			if ( targetEntity ) then
			
			else
				return;
			end

			local vWng = {};

			local bResult = AIBehaviour.TANKDEFAULT:tankGetIdealWng( entity, vWng, 30.0 );
			if ( bResult == false ) then
				return false;
			end

			FastSumVectors( vWng, vWng, entity:GetPos() );
			



		end	
	
	end,	

}

	

