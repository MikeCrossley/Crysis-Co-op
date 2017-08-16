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
--  - 15/03/2006   : Created by Tetsuji
--
--------------------------------------------------------------------------


	heliAttackLocation = {};

	local stayPositionData = {
		-- 0 : default position
		-- 1 : for the boat special
		-- 2 : for the air target
		-- 3 : for fly over
		{
			pat = {
				{ vec = {0.0, 30.0, 80.0}, },{ vec = {0.0, 30.0, 120.0}, },{ vec = {0.0, 0.0, 200.0}, },{ vec = {0.0, 30.0, 120.0}, },{ vec = {0.0, 47.0, 120.0}, },
			},
		},
		{
			pat = {
				{ vec = {30.0, 30.0, 80.0}, },{ vec = {0.0, 30.0, 120.0}, },{ vec = {0.0, 0.0, 200.0}, },{ vec = {30.0, 30.0, 120.0}, },{ vec = {0.0, 47.0, 120.0}, },
			},
		},
		{
			pat = {
				{ vec = {-30.0, 30.0, 80.0}, },{ vec = {0.0, 30.0, 120.0}, },{ vec = {0.0, 0.0, 200.0}, },{ vec = {-30.0, 30.0, 120.0}, },{ vec = {0.0, 47.0, 120.0}, },
			},
		},
		{
			pat = {
				{ vec = {30.0, 30.0, 110.0}, },{ vec = {0.0, 30.0, 120.0}, },{ vec = {0.0, 0.0, 200.0}, },{ vec = {30.0, 30.0, 120.0}, },{ vec = {0.0, 47.0, 120.0}, },
			},
		},
		{
			pat = {
				{ vec = {-30.0, 30.0, 110.0}, },{ vec = {0.0, 30.0, 120.0}, },{ vec = {0.0, 0.0, 200.0}, },{ vec = {-30.0, 30.0, 120.0}, },{ vec = {0.0, 47.0, 120.0}, },
			},
		},

	};

	local stayPositionData2 = {
		-- 0 : default position
		-- 1 : for the boat special
		-- 2 : for the air target
		-- 3 : for fly over
		{
			pat = {
				{ vec = {0.0, 5.0, 30.0}, },{ vec = {0.0, 5.0, 30.0}, },{ vec = {0.0, 0.0, 50.0}, },{ vec = {0.0, 10.0, 30.0}, },{ vec = {0.0, 10.0, 30.0}, },
			},
		},
		{
			pat = {
				{ vec = {0.0, 30.0, 180.0}, },{ vec = {30.0, 30.0, 120.0}, },{ vec = {70.0, 0.0, 200.0}, },{ vec = {-50.0, 30.0, 50.0}, },{ vec = {-30.0, 47.0, 100.0}, },
			},
		},
		{
			pat = {
				{ vec = {100.0, 25.0, 240.0}, },{ vec = {50.0, 20.0, 250.0}, },{ vec = {70.0, 0.0, 300.0}, },{ vec = {50.0, 30.0, 300.0}, },{ vec = {30.0, 47.0, 100.0}, },
			},
		},
		{
			pat = {
				{ vec = {-100.0, 30.0, 245.0}, },{ vec = {0.0, 20.0, 250.0}, },{ vec = {0.0, 0.0, 300.0}, },{ vec = {-50.0, 30.0, 300.0}, },{ vec = {-30.0, 67.0, 100.0}, },
			},
		},
		{
			pat = {
				{ vec = {0.0, 35.0, 250.0}, },{ vec = {0.0, 80.0, 100.0}, },{ vec = {-30.0, 80.0, 300.0}, },{ vec = {0.0, 80.0, 300.0}, },{ vec = {-30.0, 80.0, 100.0}, },
			},
		},

	};


AIBehaviour.HELIDEFAULT = {
	Name = "HELIDEFAULT",

	--------------------------------------------------------------------------
	-- shared functions 
	--------------------------------------------------------------------------
	heliGetTargetPosition= function( self, entity, out )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then
			CopyVector( out, target:GetPos() );
			if ( entity.AI.hoveringOffset ~=nil ) then
				out.z = out.z + entity.AI.hoveringOffset;
			end
		else
			CopyVector( out, entity:GetPos() );
		end
				
	end,

	heliCheckIsTargetPlayerVehicle = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			local flg = false;

			if ( AI.GetTypeOf(target.id) == AIOBJECT_VEHICLE ) then
				flg = true;
			elseif ( target.actor ) then
				local vehicleId = target.actor:GetLinkedVehicleId();
				if ( vehicleId ) then
					local	vehicle = System.GetEntity( vehicleId );
					if( vehicle ) then
						target  = vehicle;
						flg = true;
					end
				end
			end


			if ( flg == true ) then

				if ( target and target.AIMovementAbility.pathType == AIPATH_TANK ) then
				else
					return false;
				end
			
				for i,seat in pairs(target.Seats) do	
					if( seat.passengerId ) then
					local member = System.GetEntity( seat.passengerId );
						if( member ~= nil ) then
							if ( member.ai  ~= 1 ) then
								--AI.LogEvent("heliCheckIsTargetAIVehicle : detected player vehicle "..target:GetName() );
								return true;
							end
						end
					end
				end	
			end

			if ( AI.GetTypeOf( target.id ) == AIOBJECT_PLAYER ) then
				if ( AI.GetTargetType(entity.id) ~= AITARGET_MEMORY ) then
					if ( target.inventory ~=nil ) then
						local weapon = target.inventory:GetCurrentItem();
						if( weapon and weapon.class~=nil and weapon.class == "LAW" ) then
							local vPos = {};
							SubVectors( vPos, entity:GetPos(), target:GetPos() );
							local hdif = vPos.z;
							vPos.z = 0;
							if ( LengthVector( vPos ) < 25.0 ) then
								return true;
							end
						end
					end
				end
			end

		end

		return false;

	end,

	heliRequest2ndGunnerShoot = function( self, entity )

		for i,seat in pairs(entity.Seats) do
			if( seat.passengerId ) then
				local member = System.GetEntity( seat.passengerId );
				if( member ~= nil ) then

				  if (seat.isDriver) then
				  else
						local seatId = entity:GetSeatId(member.id);
				  	if ( seat.seat:GetWeaponCount() > 0 ) then
							g_SignalData.fValue = 400.0;
							AI.ChangeParameter( member.id, AIPARAM_STRAFINGPITCH, -16.0 );
							AI.Signal(SIGNALFILTER_SENDER, 1, "INVEHICLEGUNNER_REQUEST_SHOOT", member.id, g_SignalData);
							return;
						end
					end
			
				end
			end
		end	

	end,

	heliRequest2ndGunnerStopShoot = function( self, entity )

		for i,seat in pairs(entity.Seats) do
			if( seat.passengerId ) then
				local member = System.GetEntity( seat.passengerId );
				if( member ~= nil ) then

				  if (seat.isDriver) then
				  else
						local seatId = entity:GetSeatId(member.id);
				  	if ( seat.seat:GetWeaponCount() > 0 ) then
							AI.Signal(SIGNALFILTER_SENDER, 1, "INVEHICLEGUNNER_REQUEST_STOP_SHOOT", member.id, g_SignalData);
							return;
						end
					end
			
				end
			end
		end	

	end,

	--------------------------------------------------------------------------
	GetIdealWng = function( self, entity, vWng, fScale )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			return self:GetIdealWng2( entity, vWng, fScale, target:GetPos() );
				
		else

			local vPos = {};
			FastScaleVector( vPos, entity:GetDirectionVector(1), 50.0 );
			FastSumVectors( vPos, vPos, entity:GetPos() );
			return self:GetIdealWng2( entity, vWng, fScale, vPos );

		end
		
	end,

	--------------------------------------------------------------------------
	GetIdealWng2 = function( self, entity, vWng, fScale ,vTargetPos )

			local vDir = {};
			SubVectors( vDir, vTargetPos, entity:GetPos() );
			NormalizeVector( vDir );
			
			local vUp = { x=0.0, y=0.0, z=1.0 };
			
			crossproduct3d( vWng, vDir, vUp );
			NormalizeVector( vWng );

			local vCheckPos = {}
			
			FastScaleVector( vCheckPos, vWng, fScale *3.0/4.0 );
			FastSumVectors( vCheckPos, vCheckPos, entity:GetPos() );

			local rightCnt = AIBehaviour.HELIDEFAULT:heliCheckFormation( entity, vCheckPos, fScale );

			FastScaleVector( vCheckPos, vWng, -fScale *3.0/4.0 );
			FastSumVectors( vCheckPos, vCheckPos, entity:GetPos() );

			local leftCnt  = AIBehaviour.HELIDEFAULT:heliCheckFormation( entity, vCheckPos, fScale );

			if ( rightCnt == 0 and leftCnt == 0 ) then
				if ( random(1,2) == 1 ) then
					FastScaleVector( vWng, vWng, fScale );
				else
					FastScaleVector( vWng, vWng, -fScale );
				end
				return false;

			else
				if ( rightCnt > leftCnt ) then
					FastScaleVector( vWng, vWng, fScale );
				else
					FastScaleVector( vWng, vWng, -fScale );
				end
			end

			return true;
				
		
	end,

	--------------------------------------------------------------------------
	GetAimingPosition = function( self, entity, myPos )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			local vEnemyPos = {};
			self:heliGetTargetPosition( entity, vEnemyPos );
			return self:GetAimingPosition2( entity, myPos, vEnemyPos )

		end
		
		return false;
		
	end,

	--------------------------------------------------------------------------
	GetAimingPosition2 = function( self, entity, myPos, enemyPos )

			local vPos = {};
			
			SubVectors( vPos, enemyPos, myPos );

			vPos.z =0;

			local distance = LengthVector( vPos );
			if ( distance < 30.0 ) then
				return false;
			end

			local idealheight = distance * math.sin( 20.0 * 3.1415 / 180.0 );
			if ( entity.AI.isVtol == true ) then
				idealheight = distance * math.sin( 15.0 * 3.1415 / 180.0 );
			end

			local actuallheight = math.abs( myPos.z - enemyPos.z );
			local newposz;

			if ( actuallheight > idealheight ) then

				if ( myPos.z > enemyPos.z ) then
					newposz = enemyPos.z + idealheight ;
				else
					newposz = enemyPos.z - idealheight ;
				end

				--AI.LogEvent(" adjust position "..myPos.z..">"..newposz);
				myPos.z = newposz;
				myPos.x = myPos.x;
				myPos.y = myPos.y;
				
				return true;
				
			else

				return true;

			end
		
	end,


	--------------------------------------------------------------------------
	heliDoesUseMachineGun = function( self, entity )

		-- do return false; end
		-- check there is the 2nd gunner.

		local bFound = false;
		local i;
  	
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

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			if ( AI.GetTargetType(entity.id) == AITARGET_MEMORY ) then
				local vDir = {};
				local vTargetPos = {};
				CopyVector( vTargetPos, target:GetPos() );
				local level = System.GetTerrainElevation( vTargetPos )
				if ( vTargetPos.z - level <1.0 ) then
					vTargetPos.z = vTargetPos.z + 1.0;
				end

				SubVectors( vDir, vTargetPos, entity:GetPos() );

				local	hits = Physics.RayWorldIntersection(entity:GetPos(),vDir,1,ent_static+ent_rigid+ent_sleeping_rigid,entity.id,nil,g_HitTable);
				if( hits == 0 ) then
				else
					local firstHit = g_HitTable[1];
					--AI.LogEvent( entity:GetName().." find "..firstHit.entity:GetName() );
					if ( firstHit.entity and firstHit.entity.Properties.Physics and firstHit.entity.Properties.Physics.bRigidBodyActive and firstHit.entity.Properties.Physics.bRigidBodyActive==1 ) then
						--AI.LogEvent( entity:GetName().." use missiles to break"..firstHit.entity:GetName() );
						entity.AI.DoMemoryAttack =true;
						return false;
					end
				end
			end

			local targetPos = {};
			AIBehaviour.HELIDEFAULT:heliGetTargetPosition( entity, targetPos );


			-- check the distance. if the distance is less than 25m, always use machine gun in any case

			local distanceToTheTarget = entity:GetDistance(target.id);

			if ( distanceToTheTarget < 25.0 ) then
				--AI.LogEvent(entity:GetName().." heliDoesUseMachineGun less than 25m");
				return true;
			end

			-- if there is no 2nd gunner use the main gun.
			if ( bFound == false ) then
				--AI.LogEvent(entity:GetName().." heliDoesUseMachineGun 2nd gunner not found");
				return false;
			end

			-- if the target is vehicle or rides on a vehicle. use main gun.

			if ( AI.GetTypeOf(target.id) == AIOBJECT_VEHICLE ) then
				--AI.LogEvent(entity:GetName().." heliDoesUseMachineGun target is vehicle");
				return false;
			end

			if ( self:heliIsTargetVehicle( entity ) == true ) then
				--AI.LogEvent(entity:GetName().." heliDoesUseMachineGun target rides on a vehicle");
				return false;
			end

			-- if the target is too heavy ( it means huge ) use main gun.
		
			if ( target:GetMass() > 300.0 ) then
				--AI.LogEvent(entity:GetName().." heliDoesUseMachineGun target is huge");
				return	false;
			end
		
			-- if the target is the player, the heli should tend to use machine gun.

			if ( AI.GetTypeOf(target.id) == AIOBJECT_PLAYER ) then

				-- if the player is 200m far from the heli. the heli uses main gun.

				if ( distanceToTheTarget >200.0 ) then
					--AI.LogEvent(entity:GetName().." heliDoesUseMachineGun player is morethan 200m");
					return false;
				end 

				--AI.LogEvent(entity:GetName().." heliDoesUseMachineGun player is within 200m");
				return	true;

			end

		else
			-- if the heli has no target.
	
			--AI.LogEvent(entity:GetName().." heliDoesUseMachineGun has no target");
			return true;
	
		end

		--AI.LogEvent(entity:GetName().." heliDoesUseMachineGun default");
		return true;		

	end,

	--------------------------------------------------------------------------
	heliGetDistanceOfPoints = function(self,src,dst)

		local vTmp = {};
		local distance;

		SubVectors(vTmp,src,dst);
		distance = LengthVector(vTmp);

		return	distance;

	end,
	
	--------------------------------------------------------------------------
	-- get direction vector which length is 'scale'
	heliGetScaledDirectionVector = function(self,entity,outvec,src,dst,scale)

		SubVectors( outvec, dst, src );
		NormalizeVector( outvec );
		FastScaleVector( outvec, outvec, scale );

	end,

	-- get up vector which length is 'scale'
	heliGetScaledUpVector = function(self,entity,outvec,scale)

		CopyVector( outvec, entity:GetDirectionVector(2) );
		FastScaleVector( outvec, outvec, scale );

	end,

	--------------------------------------------------------------------------
	-- check the pitch angle for attack
	heliCheckPitchAngle = function( self, entity )
		
		local vFwd = {};
		local vCmp = {};
		CopyVector( vFwd, entity:GetDirectionVector(1) );

		vCmp.x =vFwd.x
		vCmp.y =vFwd.y
		vCmp.z =0.0;

		NormalizeVector( vCmp );
		if ( dotproduct3d( vCmp, vFwd ) > math.cos( 30.0 * 3.1416 / 180.0 ) ) then
			return true;
		end

		return false;

	end,

	--------------------------------------------------------------------------
	-- get target's height from the ground
	heliGetTargetDistanceFromTheGround = function( self, entity )

		local distance;
		local targetEntity = AI.GetAttentionTargetEntity( entity.id );

		if ( targetEntity and AI.Hostile( entity.id, targetEntity.id ) ) then

			local targetPos = {};
			CopyVector( targetPos, targetEntity:GetPos() );

			distance = System.GetTerrainElevation( targetPos );
			distance = targetPos.z - distance;
			if ( distance < 0 ) then
				distance = 0;
			end

		else
			-- for safety
			distance = 0.0;
		end

		return distance;

	end,

	--------------------------------------------------------------------------
	-- get a height from the ground
	heliGetMyDistanceFromTheGround = function( self, entity )

		local distance;

		local myPos = {};
		CopyVector( myPos, entity:GetPos() );

		distance = System.GetTerrainElevation( myPos );
		distance = myPos.z - distance;

		return distance;

	end,

	--------------------------------------------------------------------------
	-- returns if a target is flying vehicle
	heliIsTargetFlying = function( self, entity )

		local targetEntity = AI.GetAttentionTargetEntity( entity.id );
		if ( targetEntity and AI.Hostile( entity.id, targetEntity.id ) ) then
			if ( AI.GetTypeOf(targetEntity.id) == AIOBJECT_VEHICLE ) then
				local distance = self:heliGetTargetDistanceFromTheGround( entity );
				if ( distance > 15.0 ) then
					return true;
				end
			elseif ( targetEntity.actor ~=nil and targetEntity.actor:GetLinkedVehicleId() ) then
				local distance = self:heliGetTargetDistanceFromTheGround( entity );
				if ( distance > 15.0 ) then
					return true;
				end
			end
		end

		return false;

	end,

	--------------------------------------------------------------------------
	heliIsTargetVehicle = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			if ( AI.GetTypeOf(target.id) == AIOBJECT_VEHICLE ) then
				return	true;
			end

			if ( target.actor ) then
				local vehicleId = target.actor:GetLinkedVehicleId();
				if ( vehicleId ) then
					local	vehicle = System.GetEntity( vehicleId );
					if( vehicle ) then
						return true;
					end
				end
			end

		end

		return false;

	end,

	--------------------------------------------------------------------------
	heliGetTargetFowardDirection = function( self, entity, out )

		-- check the direction vector of the target.
		-- if he rides on the vehicles, returns a direction of the vehicle.

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			if ( AI.GetTypeOf(target.id) == AIOBJECT_PLAYER ) then
				CopyVector( out, System.GetViewCameraDir() );
				out.z = 0;
				NormalizeVector( out );
				return;
			end
			
			if ( self:heliCheckIsTargetPlayerVehicle( entity ) == true ) then
				CopyVector( out, System.GetViewCameraDir() );
				out.z = 0;
				NormalizeVector( out );
				return;
			end
			
		end

		--AI.LogEvent(entity:GetName().." heliGetTargetFowardDirection : selected 1,0,0 ");
		out.x =1.0;
		out.y =0.0;
		out.z =0.0;
		
		return;

	end,

	--------------------------------------------------------------------------
	-- simple flocking.
	heliAdjustRefPoint = function( self, entity, sw )

		-- implement a simple flocking.
		local bResult = false;

		local myPosition = {};
		local vDifference = { x=0.0, y=0.0, z=0,0 };

		CopyVector( myPosition, entity:GetPos() );

		local vOrgRefPoint ={};
		local vNewRefPoint = {};
		local vVecTmp = {};

		CopyVector( vOrgRefPoint, AI.GetRefPointPosition( entity.id ) );
		CopyVector( vNewRefPoint, vOrgRefPoint );

		local i;
		local boxValue = entity:GetSpeed() * 5.0;
		if ( boxValue > 80.0 ) then
			boxValue = 80.0;
		end
		if ( boxValue < 40.0 ) then
			boxValue = 40.0;
		end

		boxValue = 50.0;
		
		local entities = System.GetPhysicalEntitiesInBox( entity:GetPos(), boxValue );
		local targetEntity;

		if (entities) then

			for i,targetEntity in ipairs(entities) do

				local objEntity = targetEntity;
				-- AI.LogEvent(entity:GetName().." entity list "..objEntity:GetName().."mass "..objEntity:GetMass() );

				if ( objEntity.id == entity.id ) then

				elseif ( objEntity:GetMass() < 200.0 or AI.GetTypeOf(objEntity.id) == AIOBJECT_PUPPET or AI.GetTypeOf(objEntity.id) == AIOBJECT_PLAYER ) then

				elseif ( AI.GetTypeOf( objEntity.id ) == AIOBJECT_VEHICLE and AI.GetSubTypeOf( objEntity.id ) == AIOBJECT_CAR ) then

				elseif ( AI.GetTypeOf( objEntity.id ) == AIOBJECT_VEHICLE) then

					local objPosition = {}
					local vel ={};
					CopyVector( objPosition, objEntity:GetPos() );
					--CopyVector( vel, objEntity:GetVelocity() );
					--FastScaleVector( objPosition, vel ,1.0 );

					local objDistDirN ={};
					local objDistDir ={};
					SubVectors( objDistDir, objPosition, myPosition );
					CopyVector( objDistDirN, objDistDir );
					NormalizeVector( objDistDirN );			

					local objDistance = LengthVector( objDistDir );
					if (objDistance < 1.0 ) then
						objDistance = 1.0;
					end
					if ( objDistance > boxValue ) then
						objDistance = boxValue;
					end
					
					objDistance = (boxValue - objDistance)/boxValue;
					objDistance = objDistance * objDistance * 2;
					objDistance = objDistance * boxValue;
					if ( objDistance > boxValue ) then
						objDistance = boxValue;
					end

					if ( objDistance < 0.0 ) then
						objDistance = 0.0;
					end

					objDistance = objDistance * -1.0;
					-- AI.LogEvent(" added  "..objEntity:GetName().."  :"..objDistance);

					FastScaleVector( objDistDir, objDistDirN, objDistance );
					FastSumVectors( vDifference, vDifference, objDistDir );
					FastSumVectors( vNewRefPoint, vNewRefPoint, objDistDir );
					bResult = true;
	
				end

			end

		else
		end	
	
		AI.SetRefPointPosition( entity.id, vNewRefPoint );
		return bResult;

	end,

	--------------------------------------------------------------------------
	-- checkFormation.
	heliCheckFormation = function( self, entity, vCheckPos, radius )

		local count = 0;
		
		local entities = System.GetPhysicalEntitiesInBox( vCheckPos, radius );
		local targetEntity;
		local vPos = {};

		if (entities) then

			for i,targetEntity in ipairs(entities) do

				local objEntity = targetEntity;
	
				if ( objEntity.id == entity.id ) then

				elseif ( AI.GetTypeOf( objEntity.id ) == AIOBJECT_VEHICLE ) then

				  CopyVector( vPos, objEntity:GetPos() );
					local height = System.GetTerrainElevation( vPos );
				  if ( vPos.z > height + 10.0 ) then
						count = count + 1;
					end

				end

			end

		end	
	
		return count;

	end,

	--------------------------------------------------------------------------
	-- Get a position for a specific purpose in FOV
	heliCheckNavOfRef = function( self, entity )

		local vTmp = {};
		SubVectors( vTmp, AI.GetRefPointPosition( entity.id ), entity:GetPos() );
		local distance = LengthVector( vTmp ) + 0.01;

		FastScaleVector( vTmp, vTmp, ( distance + 15.0 )/distance );
		FastSumVectors( vTmp, vTmp, entity:GetPos() );
		
		if ( AI.IsPointInFlightRegion( vTmp ) == false ) then
			--AI.LogComment(entity:GetName().." detected a bad ref point");
			return	false;			
		end
		
		return true;

	end,

	heliCheckNav = function( self, entity, vSrc, vDst )

		local vTmp = {};
		SubVectors( vTmp, vDst, vSrc );
		local distance = LengthVector( vTmp ) + 0.01;

		FastScaleVector( vTmp, vTmp, ( distance + 15.0 )/distance );
		FastSumVectors( vTmp, vTmp, vSrc );
		
		if ( AI.IsPointInFlightRegion( vTmp ) == false ) then
			--AI.LogComment(entity:GetName().." detected a bad ref point");
			return	false;			
		end
		
		return true;

	end,

	--------------------------------------------------------------------------
	-- Get a position for a specific purpose in FOV
	heliRefreshStayAttackPosition = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			local targetPos = {};

			local cameraFwdDir = {};
			local cameraWingDir = {};
			local targetUpDir = {};
			local targetFwdDir = {};
			local targetWingDir = {};

			AIBehaviour.HELIDEFAULT:heliGetTargetPosition( entity, targetPos );
			self:heliGetTargetFowardDirection( entity, cameraFwdDir );
			CopyVector( cameraWingDir, vecFrontToRight(cameraFwdDir) );

			-- for the helicopter we can use updir = (0,0,1)
			targetUpDir.x =0;
			targetUpDir.y =0;
			targetUpDir.z =1.0;

			--Just in case, for scaling
			NormalizeVector(cameraFwdDir);
			NormalizeVector(targetUpDir);

			local t = dotproduct3d( cameraFwdDir , targetUpDir );

			--Avoid a singularity
			if ( t * t < 0.9 ) then

				crossproduct3d( targetWingDir , cameraFwdDir  , targetUpDir );
				NormalizeVector(targetWingDir);
				crossproduct3d( targetFwdDir  , targetWingDir , targetUpDir );
				NormalizeVector(targetFwdDir);
	
				if ( dotproduct3d( cameraFwdDir , targetFwdDir ) < 0 ) then
					FastScaleVector( targetFwdDir, targetFwdDir, -1.0 );
					FastScaleVector( targetWingDir, targetWingDir, -1.0 );
				end
	
				CopyVector( entity.AI.vFwdUnit, targetFwdDir  );
				CopyVector( entity.AI.vWngUnit, targetWingDir );
				CopyVector( entity.AI.vUpUnit , targetUpDir   );
				CopyVector( entity.AI.vAttackCenterPos, targetPos );

				return true;
	
			end

		end

		-- clear vectors; the heli will stay the same position.

		local zeroVec ={};
		zeroVec.x = 0.0;
		zeroVec.y = 0.0;
		zeroVec.z = 0.0;
		CopyVector( entity.AI.vFwdUnit, zeroVec );
		CopyVector( entity.AI.vWngUnit, zeroVec );
		CopyVector( entity.AI.vUpUnit, zeroVec );
		CopyVector( entity.AI.vAttackCenterPos, entity:GetPos() );

		return	false;

	end,


	--------------------------------------------------------------------------
	heliGetStayAttackPosition = function( self, entity, X, pattern )

		-- X:       output position
		-- entity:  input  entitiy
		-- pattern: input 

		-- when error, will return a current my position.

		local targetWngDir = {};
		local targetUpDir = {};
		local targetFwdDir = {};
		local heliAttackCenterPos = {};
		--AI.LogEvent("heliGetStayAttackPosition: entity "..entity:GetName());
	
		if ( entity.AI.stayPosition == 0 ) then
			--AI.LogEvent("heliGetStayAttackPosition: stayPosition == 0");
			CopyVector( X, entity.AI.vDefaultPosition );

		else
	
			local distanceFromTheGround = self:heliGetMyDistanceFromTheGround( entity );
			local targetDistanceFromTheGround = self:heliGetTargetDistanceFromTheGround( entity );

			local isVehicle = self:heliIsTargetVehicle(entity);
			local isFlying = self:heliIsTargetFlying(entity);

			--AI.LogEvent("heliGetStayAttackPosition: default");
			if ( entity.AI.isHeliAggressive ~=nil ) then
				FastScaleVector( targetWngDir , entity.AI.vWngUnit , stayPositionData2[entity.AI.stayPosition].pat[pattern+1].vec[1] );
				FastScaleVector( targetUpDir  , entity.AI.vUpUnit  , stayPositionData2[entity.AI.stayPosition].pat[pattern+1].vec[2] );
				FastScaleVector( targetFwdDir , entity.AI.vFwdUnit , stayPositionData2[entity.AI.stayPosition].pat[pattern+1].vec[3] );
			else
				FastScaleVector( targetWngDir , entity.AI.vWngUnit , stayPositionData[entity.AI.stayPosition].pat[pattern+1].vec[1] );
				FastScaleVector( targetUpDir  , entity.AI.vUpUnit  , stayPositionData[entity.AI.stayPosition].pat[pattern+1].vec[2] );
				FastScaleVector( targetFwdDir , entity.AI.vFwdUnit , stayPositionData[entity.AI.stayPosition].pat[pattern+1].vec[3] );
			end

			FastSumVectors( heliAttackCenterPos , entity.AI.vAttackCenterPos, targetUpDir   );
			FastSumVectors( heliAttackCenterPos , heliAttackCenterPos    , targetFwdDir  );
			FastSumVectors( heliAttackCenterPos , heliAttackCenterPos    , targetWngDir );

			-- limited height
			if ( distanceFromTheGround > 150.0 ) then
				heliAttackCenterPos.z = System.GetTerrainElevation( entity:GetPos() ) + 150.0;
			end

			CopyVector ( X, heliAttackCenterPos );

		end

	end,

	--------------------------------------------------------------------------
	heliGetPickPosition = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			local vR = {};
			local vUp = {};
			local vFwd = {};
			local vDir = {};
			local vRot = {};

			CopyVector( vR, target:GetDirectionVector(2) );
			FastScaleVector( vUp, vR, 10.0);
			FastScaleVector( vFwd, target:GetDirectionVector(2), 15.0 );
			FastSumVectors( vDir, vUp, vFwd );

			for i = 1,6 do

				RotateVectorAroundR( vRot, vDir, vR, 3.1416* 2.0 * i / 6.0 );
				local	hits = Physics.RayWorldIntersection(target:GetPos(),vRot,1,ent_terrain+ent_static+ent_rigid+ent_sleeping_rigid+ent_living,entity.id,target.id,g_HitTable);
				if ( hits == 0 ) then
					FastSumVectors( vDir, vDir, target:GetPos() );
					AI.SetRefPointPosition( entity.id , vDir );
					return	true;
				end				
			end

		end

		return	false;

	end,

	--------------------------------------------------------------------------
	-- To avoid the conflicts, make approach point exclusive.
	heliRemoveID = function( self, entity )

		for i= 1,10 do
			if ( heliAttackLocation[i] ~= 0 ) then
				if ( heliAttackLocation[i] == entity.id ) then
					heliAttackLocation[i] = 0;
				end
			end
		end

	end,

	--------------------------------------------------------------------------
	-- To avoid the conflicts, make approach point exclusive.
	heliGetID = function( self, entity )

		entity.AI.stayPosition = 0;

	end,

	--------------------------------------------------------------------------
	heliCheckDamageRatio = function( self, entity )

		--System.Log( entity:GetName().." GetMovementDamageRatio "..entity.vehicle:GetMovementDamageRatio() );
		if ( entity.vehicle:GetMovementDamageRatio()>0.49 ) then
			self:heliCheckEmergencyLanding( entity );
			return true;
		end

		return false;

	end,

	--------------------------------------------------------------------------

	heliCheckEmergencyLanding = function( self, entity )

		AI.Signal(SIGNALFILTER_SENDER,1,"TO_HELI_EMERGENCYLANDING", entity.id);

	end,

	--------------------------------------------------------------------------
	-- To avoid the conflicts, make approach point exclusive.
	heliCheckDamage = function( self, entity, data )

		if ( data and data.id ) then
			local shooterEntity = System.GetEntity( data.id );
			if ( shooterEntity ) then
				if ( shooterEntity and AI.Hostile( entity.id, shooterEntity.id ) ) then
				else
					return false;
				end
			else
				return false;
			end
		else
			return false;
		end

		return true;

	end,

	--------------------------------------------------------------------------
	heliCheckLineVoid = function( self, entity, vSrc, vDst, fwdoffset )

		local vUp = { x=0.0, y=0.0, z=1.0 };
		local vWng = {};
		local vFwd = {};
		local vPos = {};
		local vTmp = {};
		local vResult = {};

		local maxHeight = vSrc.z;
		local minHeight = vSrc.z;

		if ( maxHeight < vDst.z ) then
			maxHeight = vDst.z;
		end
		if ( minHeight > vDst.z ) then
			minHeight = vDst.z;
		end

		SubVectors( vFwd, vDst, vSrc );
		local len = LengthVector( vFwd );

		NormalizeVector( vFwd );
		crossproduct3d( vWng, vFwd, vUp );
		NormalizeVector( vWng );
		crossproduct3d( vUp, vFwd, vWng );
		if ( vUp.z < 0 ) then
			FastScaleVector( vUp, vUp, -1.0 );
		end

		FastScaleVector( vTmp, vFwd, -5.0 );
		FastSumVectors( vPos, vSrc, vTmp );
		FastScaleVector( vTmp, vWng, -20.0 );
		FastSumVectors( vPos, vPos, vTmp );
		FastScaleVector( vTmp, vUp, -5.0 );
		FastSumVectors( vPos, vPos, vTmp );

		FastScaleVector( vFwd, vFwd, len + 5.0 + fwdoffset );
		FastScaleVector( vWng, vWng, 40.0 );
		FastScaleVector( vUp, vUp, 10.0 );

		CopyVector( vResult, AI.IsFlightSpaceVoid( vPos, vFwd, vWng, vUp ) );

		if ( LengthVector( vResult ) > 0.0 ) then
			return false;
		end
		
		FastSumVectors( vTmp, vPos, vFwd );

		if ( self:heliCheckNav( entity, vPos, vTmp ) == false ) then
			return false;
		end

		return true;

	end,
	
	--------------------------------------------------------------------------
	heliCheckSpaceVoidMain = function( self, entity, index, spaceScale )

		local vFwd ={};
		local vWng ={};
		local vUp ={};
		local vFwdUnit ={};
		local vResult ={};
		local vOffset ={};
		local vPos = {};
		local vTmp = {};
		local offset = 0;

 		local offset = 0;
  
 
		local maxHeight = entity.AI.followVectors[1].z;
		local minHeight = entity.AI.followVectors[1].z;

		for i =1, index do
			if ( maxHeight < entity.AI.followVectors[i].z ) then
				maxHeight = entity.AI.followVectors[i].z;
			end
			if ( minHeight > entity.AI.followVectors[i].z ) then
				minHeight = entity.AI.followVectors[i].z;
			end
		end

		SubVectors( vFwd, entity.AI.followVectors[1], entity:GetPos() );
		if ( LengthVector( vFwd ) > 1.0 ) then

			CopyVector( vFwdUnit, vFwd );
			NormalizeVector( vFwdUnit );
				
			local dot0 = math.abs(dotproduct3d( vFwdUnit,entity:GetDirectionVector(0) ));
			local dot1 = math.abs(dotproduct3d( vFwdUnit,entity:GetDirectionVector(1) ));
			local dot2 = math.abs(dotproduct3d( vFwdUnit,entity:GetDirectionVector(2) ));
			
			if ( dot0<dot1 and dot0<dot2 ) then
				CopyVector( vWng , entity:GetDirectionVector(0));
			end
			if ( dot1<dot0 and dot1<dot2 ) then
				CopyVector( vWng , entity:GetDirectionVector(1));
			end
			if ( dot2<dot0 and dot2<dot1 ) then
				CopyVector( vWng , entity:GetDirectionVector(2));
			end
			
			crossproduct3d( vUp, vWng, vFwdUnit );
			crossproduct3d( vWng, vUp, vFwdUnit );

			FastScaleVector( vUp,  vUp,  spaceScale );
			FastScaleVector( vWng, vWng, spaceScale );
			FastScaleVector( vTmp, vFwdUnit, spaceScale ); 

			SubVectors( vPos, entity:GetPos(), vWng );
			SubVectors( vPos, vPos, vUp );
			SubVectors( vPos, vPos, vTmp );
	
			FastScaleVector( vWng, vWng, 2.0 );
			FastScaleVector( vUp , vUp , 2.0 );
			FastScaleVector( vTmp, vTmp, 2.0 );
			FastSumVectors( vFwd, vFwd, vTmp );

			CopyVector( vResult, AI.IsFlightSpaceVoid( vPos, vFwd, vWng, vUp ) );

			if ( LengthVector( vResult ) > 0.0 ) then
				vResult.z = vResult.z + (spaceScale/2.0);
				if ( vResult.z > minHeight and offset < vResult.z - minHeight ) then
					offset = vResult.z - minHeight;
					--AI.LogEvent("minHeight/result/offset"..minHeight..","..offset..","..vResult.z);
					if ( offset > 50.0 ) then
						return false;
					end
				end
			end

		end

		for i = 1, index-1 do

			SubVectors( vFwd, entity.AI.followVectors[i+1], entity.AI.followVectors[i+0] );
			CopyVector( vFwdUnit, vFwd );
			NormalizeVector( vFwdUnit );
			
			local dot0 = math.abs(dotproduct3d( vFwdUnit,entity:GetDirectionVector(0) ));
			local dot1 = math.abs(dotproduct3d( vFwdUnit,entity:GetDirectionVector(1) ));
			local dot2 = math.abs(dotproduct3d( vFwdUnit,entity:GetDirectionVector(2) ));
			
			if ( dot0<=dot1 and dot0<=dot2 ) then
				CopyVector( vWng , entity:GetDirectionVector(0));
			end
			if ( dot1<=dot0 and dot1<=dot2 ) then
				CopyVector( vWng , entity:GetDirectionVector(1));
			end
			if ( dot2<=dot0 and dot2<=dot1 ) then
				CopyVector( vWng , entity:GetDirectionVector(2));
			end
			
			crossproduct3d( vUp, vWng, vFwdUnit );
			crossproduct3d( vWng, vUp, vFwdUnit );

			FastScaleVector( vUp,  vUp,  spaceScale );
			FastScaleVector( vWng, vWng, spaceScale );
			FastScaleVector( vTmp, vFwdUnit, spaceScale ); 

			SubVectors( vPos, entity.AI.followVectors[i+0], vWng );
			SubVectors( vPos, vPos, vUp );
			SubVectors( vPos, vPos, vTmp );
	
			FastScaleVector( vWng, vWng, 2.0 );
			FastScaleVector( vUp , vUp , 2.0 );
			FastScaleVector( vTmp, vTmp, 2.0 );
			FastSumVectors( vFwd, vFwd, vTmp );

			CopyVector( vResult, AI.IsFlightSpaceVoid( vPos, vFwd, vWng, vUp ) );

			if ( LengthVector( vResult ) > 0.0 ) then
				vResult.z = vResult.z + (spaceScale/2.0);
				if ( vResult.z > minHeight and offset < vResult.z - minHeight ) then
					offset = vResult.z - minHeight;
					--AI.LogEvent("minHeight/offset/result/"..minHeight..","..offset..","..vResult.z);
					if ( offset > 50.0 ) then
						return false;
					end
				end
			end
			
		end

		if ( offset ~=0 ) then
			offset = offset +(spaceScale/2.0);
		end

		vOffset.x = 0;
		vOffset.y = 0;
		vOffset.z = offset;

		for i = 1, index do
			FastSumVectors( entity.AI.followVectors[i], entity.AI.followVectors[i], vOffset );
		end

		for i =1, index-1 do
			if ( self:heliCheckNav( entity, entity.AI.followVectors[i], entity.AI.followVectors[i+1] ) == false ) then
				return false;
			end
		end

		return true;

	end,

	--------------------------------------------------------------------------
	heliCheckSpaceVoid  = function( self, entity, index )
	
	 	local spaceScale = 10.0;
		if ( entity.AI.isVtol and entity.AI.isVtol == true ) then
			spaceScale = 15.0;
		elseif ( entity.AI.isHeliAggressive ~= nil ) then
			spaceScale = 2.0;
		else
			spaceScale = 10.0;
		end

		return 	self:heliCheckSpaceVoidMain( entity, index, spaceScale );
	
	end,

	--------------------------------------------------------------------------
	heliMakePathHover = function( self, entity, vIdealDestination )

		local vMyPos = {};
		local index = 0;
		CopyVector( vMyPos, entity:GetPos() );

		index = index + 1;
		FastSumVectors( entity.AI.followVectors[index], vIdealDestination, vMyPos );
		FastScaleVector( entity.AI.followVectors[index],entity.AI.followVectors[index], 0.5 );
		entity.AI.followVectors[index].z = entity.AI.followVectors[index].z - 10.0;

		index = index + 1;
		CopyVector( entity.AI.followVectors[index], vIdealDestination );
	
		index = index + 1;
		CopyVector( entity.AI.followVectors[index], vIdealDestination );
		entity.AI.followVectors[index].z = entity.AI.followVectors[index].z + 5.0;

		return index;
	
	end,

	--------------------------------------------------------------------------
	heliMakePathHover2 = function( self, entity, vIdealDestination )

		local vMyPos = {};
		local index = 0;
		CopyVector( vMyPos, entity:GetPos() );

		index = index + 1;
		FastSumVectors( entity.AI.followVectors[index], vIdealDestination, vMyPos );
		FastScaleVector( entity.AI.followVectors[index],entity.AI.followVectors[index], 0.5 );
		entity.AI.followVectors[index].z = entity.AI.followVectors[index].z - 5.0;

		index = index + 1;
		CopyVector( entity.AI.followVectors[index], vIdealDestination );
	
		index = index + 1;
		CopyVector( entity.AI.followVectors[index], vIdealDestination );
		entity.AI.followVectors[index].z = entity.AI.followVectors[index].z + 3.5;

		return index;
	
	end,

	--------------------------------------------------------------------------
	heliMakePathArc = function( self, entity, vIdealDestination, radius, flip )

		local vMyPos = {};
		local vUp = { x = 0.0, y = 0.0, z =1.0 };
		
		local vWng ={};
		local vFwd ={};
		
		SubVectors( vFwd, vIdealDestination, entity:GetPos() );
		NormalizeVector( vFwd );
		crossproduct3d( vWng, vFwd, vUp );

		FastScaleVector( vWng, vWng, radius * flip );
		
		local index = 0;

		index = index + 1;
		CopyVector( entity.AI.followVectors[index], entity:GetPos() );

		index = index + 1;
		FastSumVectors( entity.AI.followVectors[index], vIdealDestination, entity:GetPos() );
		FastScaleVector( entity.AI.followVectors[index], entity.AI.followVectors[index], 0.5 );
		FastSumVectors( entity.AI.followVectors[index], entity.AI.followVectors[index], vWng );

		index = index + 1;
		CopyVector( entity.AI.followVectors[index], vIdealDestination );

		return index;

	end,

	--------------------------------------------------------------------------
	heliMakePathCircle = function( self, entity, radius, flip )
			
		-- for circle
	
		--local radius	= 70.0;
		--local flip		= -0.5;
	
		local vFwdUnit = {};
		local vWngUnit = {};
		local vTmp = {};

		-- vectors

		local vMyPos = {};
		CopyVector( vMyPos, entity:GetPos() );

		CopyVector( vFwdUnit, entity:GetDirectionVector(1) );
		vFwdUnit.z = 0;
		NormalizeVector( vFwdUnit )

		CopyVector( vWngUnit, entity:GetDirectionVector(0) );
		vWngUnit.z = 0;
		NormalizeVector( vWngUnit )

		-- actual positions

		local index = 0;

		index = index + 1;
		CopyVector( entity.AI.followVectors[index], vMyPos );

		index = index + 1;
		FastScaleVector( vTmp, vWngUnit, -radius*flip );
		FastSumVectors( entity.AI.followVectors[index], vTmp, vMyPos );
		FastScaleVector( vTmp, vFwdUnit, radius );
		FastSumVectors( entity.AI.followVectors[index], vTmp, entity.AI.followVectors[index] );

		index = index + 1;
		FastScaleVector( vTmp, vWngUnit, -radius*2.0*flip );
		FastSumVectors( entity.AI.followVectors[index], vTmp, vMyPos );

		index = index + 1;
		FastScaleVector( vTmp, vWngUnit, -radius*2.0*flip );
		FastSumVectors( entity.AI.followVectors[index], vTmp, vMyPos );
		FastScaleVector( vTmp, vFwdUnit, -radius );
		FastSumVectors( entity.AI.followVectors[index], vTmp, entity.AI.followVectors[index] );

		index = index + 1;
		FastScaleVector( vTmp, vWngUnit, -radius*flip );
		FastSumVectors( entity.AI.followVectors[index], vTmp, vMyPos );
		FastScaleVector( vTmp, vFwdUnit, -radius*2.0 );
		FastSumVectors( entity.AI.followVectors[index], entity.AI.followVectors[index], vTmp );

		return index;

	end,

	--------------------------------------------------------------------------
	heliMakePathCircle2 = function( self, entity, radius, flip )

		-- for circle
	
		--local radius	= 70.0;
		--local flip		= -0.5;
	
		local vFwdUnit = {};
		local vWngUnit = {};
		local vTmp = {};

		-- vectors

		local vMyPos = {};
		CopyVector( vMyPos, entity:GetPos() );

		CopyVector( vFwdUnit, entity:GetDirectionVector(1) );
		vFwdUnit.z = 0;
		NormalizeVector( vFwdUnit )

		CopyVector( vWngUnit, entity:GetDirectionVector(0) );
		vWngUnit.z = 0;
		NormalizeVector( vWngUnit )

		-- actual positions

		local index = 0;

		index = index + 1;
		CopyVector( entity.AI.followVectors[index], vMyPos );

		index = index + 1;
		FastScaleVector( vTmp, vWngUnit, radius*flip );
		FastSumVectors( entity.AI.followVectors[index], vTmp, vMyPos );
		FastScaleVector( vTmp, vFwdUnit, radius );
		FastSumVectors( entity.AI.followVectors[index], vTmp, entity.AI.followVectors[index] );

		index = index + 1;
		FastScaleVector( vTmp, vWngUnit, radius*flip*2.0 );
		FastSumVectors( entity.AI.followVectors[index], vTmp, vMyPos );

		index = index + 1;
		FastScaleVector( vTmp, vWngUnit, radius*flip );
		FastSumVectors( entity.AI.followVectors[index], vTmp, vMyPos );
		FastScaleVector( vTmp, vFwdUnit, -radius );
		FastSumVectors( entity.AI.followVectors[index], entity.AI.followVectors[index], vTmp );

		index = index + 1;
		CopyVector( entity.AI.followVectors[index], vMyPos );

		return index;

	end,

	--------------------------------------------------------------------------
	heliAddPathLine = function( self, entity, vPos, index )
			
		-- for line
	
		CopyVector( entity.AI.followVectors[index], vPos );

		return true;

	end,
	--------------------------------------------------------------------------
	heliGetPathLine = function( self, entity, vPos, index )
			
		-- for line
	
		CopyVector( vPos, entity.AI.followVectors[index] );

		return true;

	end,

	--------------------------------------------------------------------------
	heliCommitPathLine = function( self, entity, index, bSpline )

		if ( self:heliCheckSpaceVoid( entity, index ) == false ) then
			return false;
		end

		entity:TriggerEvent(AIEVENT_CLEARACTIVEGOALS);
		return AI.SetPointListToFollow( entity.id, entity.AI.followVectors, index , bSpline );

	end,

	--------------------------------------------------------------------------
	heliCommitPathLineNoCheck = function( self, entity, index, bSpline )

		entity:TriggerEvent(AIEVENT_CLEARACTIVEGOALS);
		return AI.SetPointListToFollow( entity.id, entity.AI.followVectors, index , bSpline );

	end,

	---------------------------------------------
	heliTakeEvadeAction = function ( self, entity, signalname, targetEntity )

		if ( entity.AI.bBlockSignal ~= true ) then

			entity.AI.bBlockSignal = true;

			if ( targetEntity ) then
			
			else
				return;
			end

			AIBehaviour.HELIDEFAULT:heliGetID( entity );

	
			local vFwd = {};
			local vWng = {};
			local vCheckPos = {};
			local vVel = {};
			local vPos = {};
			
			CopyVector( vPos, entity:GetPos() );
			local bDir = AIBehaviour.HELIDEFAULT:GetIdealWng( entity, vWng, 30.0 );

			if ( bDir == false ) then
				local vVel = {};
				local vWngUnit = {};
				CopyVector( vWngUnit, vWng );
				NormalizeVector( vWngUnit );
				entity:GetVelocity( vVel );
				NormalizeVector( vVel );
				if ( dotproduct3d( vWngUnit, vVel ) > 0 ) then
					FastScaleVector( vWng, vWng, -1.0 );
				end
			end
	
			entity:GetVelocity( vVel );
			FastScaleVector( vVel, vVel, 0.0 );
	
			SubVectors( vFwd, targetEntity:GetPos(), entity:GetPos() );
			local zDef = -vFwd.z;
			vFwd.z = 0;
			NormalizeVector( vFwd );

			if ( zDef < 40.0 ) then
				vWng.z = vWng.z + random( 10, 30 );
			else
				vWng.z = vWng.z - random( 10, 30 );
			end
			
			FastSumVectors( vCheckPos, vWng, entity:GetPos() );
			FastSumVectors( vCheckPos, vCheckPos, vVel );
			FastSumVectors( vPos, entity:GetPos(), vCheckPos );
			FastScaleVector( vPos, vPos, 0.5 );

			local index = 1;
			AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vPos, index );
			index = index + 1;
			AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vCheckPos, index );
	
			if ( AIBehaviour.HELIDEFAULT:heliCommitPathLine( entity, index, false ) == false ) then
				return;
			end
	
			local bRun = 1;
			if ( entity.AI.isVtol == true ) then
				bRun = 0;
			end

			local accuracy = 10;
			if ( AIBehaviour.HELIDEFAULT:heliCheckLineVoid( entity, vPos, vCheckPos, 10.0 ) == true ) then
				accuracy = 40;
			end
	
			FastScaleVector( vFwd, vFwd, 300.0 );
			FastSumVectors( vFwd, vFwd, entity:GetPos() );
			AI.SetRefPointPosition( entity.id , vFwd ); -- look target
	
			entity.AI.autoFire = 0;
			AI.CreateGoalPipe("HeliEscapeToSide");
			AI.PushGoal("HeliEscapeToSide","signal",1,1,"HELI_HOVER_DISABLE_REACTION",SIGNALFILTER_SENDER);
			AI.PushGoal("HeliEscapeToSide","locate",0,"atttarget");
			AI.PushGoal("HeliEscapeToSide","lookat",0,0,0,true,1);
			AI.PushGoal("HeliEscapeToSide","firecmd",0,0);
			AI.PushGoal("HeliEscapeToSide","run",0,bRun);
			AI.PushGoal("HeliEscapeToSide","continuous",0,1);
			AI.PushGoal("HeliEscapeToSide","followpath", 0, false, false, false, 0, accuracy, true );
			AI.PushGoal("HeliEscapeToSide","signal",1,1,"HELI_HOVER_CHECK2",SIGNALFILTER_SENDER);
			AI.PushGoal("HeliEscapeToSide","signal",1,1,"HELI_AUTOFIRE_CHECK",SIGNALFILTER_SENDER);
			AI.PushGoal("HeliEscapeToSide","timeout",1,0.2);
			AI.PushGoal("HeliEscapeToSide","branch",1,-3);
			AI.PushGoal("HeliEscapeToSide","firecmd",0,0);
			AI.PushGoal("HeliEscapeToSide","signal",1,1,signalname,SIGNALFILTER_SENDER);
			AI.PushGoal("HeliEscapeToSide","signal",1,1,"HELI_HOVER_ENABLE_REACTION",SIGNALFILTER_SENDER);
			entity:InsertSubpipe(0,"HeliEscapeToSide");

		end	
	
	end,	

	heliTakeEvadeActionWithBigDamage = function ( self, entity, signalname, targetEntity )

		if ( targetEntity ) then
		
		else
			return;
		end

		entity.AI.bShaken = true;
			
		AI.CreateGoalPipe("HeliGotBigDamage");
		AI.PushGoal("HeliGotBigDamage","signal",1,1,"HELI_HOVER_DISABLE_REACTION",SIGNALFILTER_SENDER);
		AI.PushGoal("HeliGotBigDamage","signal",1,1,"HELI_GOT_BIGDAMAGE_SUB",SIGNALFILTER_SENDER);
		AI.PushGoal("HeliGotBigDamage","signal",1,1,"HELI_GOT_BIGDAMAGE_SUB",SIGNALFILTER_SENDER);
		AI.PushGoal("HeliGotBigDamage","signal",1,1,"HELI_GOT_BIGDAMAGE_SUB",SIGNALFILTER_SENDER);
		AI.PushGoal("HeliGotBigDamage","signal",1,1,"HELI_HOVER_ENABLE_REACTION",SIGNALFILTER_SENDER);
		AI.PushGoal("HeliGotBigDamage","signal",1,1,signalname,SIGNALFILTER_SENDER);
		entity:InsertSubpipe(0,"HeliGotBigDamage");

	end,	

	---------------------------------------------
	heliTakeEvadeAction2 = function ( self, entity, signalname, targetEntity )

		-- for counter attack

		if ( entity.AI.bBlockSignal ~= true ) then

			entity.AI.bBlockSignal = true;

			if ( targetEntity ) then
			
			else
				return;
			end

			AIBehaviour.HELIDEFAULT:heliGetID( entity );

	
			local vFwd = {};
			local vMyPos = {};
			local vTmp = {};

			CopyVector( vMyPos, entity:GetPos() );
			SubVectors( vFwd, targetEntity:GetPos(), entity:GetPos() );

			if ( LengthVector( vFwd ) < 30.0 ) then
				return;
			end

			NormalizeVector( vFwd );
			FastScaleVector( vFwd, vFwd, 20.0 );
			FastSumVectors( vFwd, vFwd, vMyPos );
			self:GetAimingPosition( entity, vFwd );

			local index = 1;
			AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vFwd, index );

			CopyVector( vTmp, targetEntity:GetPos() );
			vFwd.x = vTmp.x;
			vFwd.y = vTmp.y;
			vTmp.z = ( vFwd.z + vTmp.z ) * 0.6;

			index = index + 1;
			AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vFwd, index );
			
			SubVectors( vFwd, targetEntity:GetPos(), entity:GetPos() );
			NormalizeVector( vFwd );
			FastScaleVector( vFwd, vFwd, 30.0 );
			vFwd.z =0.0;
			FastSumVectors( vFwd, vFwd, vTmp );

			index = index + 1;
			AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vFwd, index );
	
			if ( AIBehaviour.HELIDEFAULT:heliCommitPathLine( entity, index, false ) == false ) then
				return;
			end
	
			local bRun = 1;
			if ( entity.AI.isVtol == true ) then
				bRun = 0;
			end

			local accuracy = 10;
			if ( AIBehaviour.HELIDEFAULT:heliCheckLineVoid( entity, entity:GetPos() , vFwd, 10.0 ) == true ) then
				accuracy = 40;
			end
	
			FastScaleVector( vFwd, vFwd, 300.0 );
			FastSumVectors( vFwd, vFwd, entity:GetPos() );
			AI.SetRefPointPosition( entity.id , vFwd ); -- look target
	
			entity.AI.autoFire = 0;
			AI.CreateGoalPipe("HeliCounterFly");
			AI.PushGoal("HeliCounterFly","signal",1,1,"HELI_HOVER_DISABLE_REACTION",SIGNALFILTER_SENDER);
			AI.PushGoal("HeliCounterFly","locate",0,"atttarget");
			AI.PushGoal("HeliCounterFly","lookat",0,0,0,true,1);
			AI.PushGoal("HeliCounterFly","firecmd",0,0);
			AI.PushGoal("HeliCounterFly","run",0,bRun);
			AI.PushGoal("HeliCounterFly","continuous",0,1);
			AI.PushGoal("HeliCounterFly","followpath", 0, false, false, false, 0, accuracy, true );
			AI.PushGoal("HeliCounterFly","signal",1,1,"HELI_HOVER_CHECK2",SIGNALFILTER_SENDER);
			AI.PushGoal("HeliCounterFly","signal",1,1,"HELI_AUTOFIRE_CHECK",SIGNALFILTER_SENDER);
			AI.PushGoal("HeliCounterFly","timeout",1,0.2);
			AI.PushGoal("HeliCounterFly","branch",1,-3);
			AI.PushGoal("HeliCounterFly","firecmd",0,0);
			AI.PushGoal("HeliCounterFly","signal",1,1,signalname,SIGNALFILTER_SENDER);
			AI.PushGoal("HeliCounterFly","signal",1,1,"HELI_HOVER_ENABLE_REACTION",SIGNALFILTER_SENDER);
			entity:InsertSubpipe(0,"HeliCounterFly");

		end	
	
	end,	


	---------------------------------------------
	heliSetForcedNavigation = function ( self, entity, vFwd, scale, sec )

			local vTmp  = {};
			local vVel  = {};
			local vMyPos  = {};
			local vResult  = {};
			local vResult2  = {};
			local vSumOfPotential = {};

			CopyVector( vSumOfPotential, AI.GetFlyingVehicleFlockingPos( entity.id,40.0,8000.0,2.0,12.0 ) );
			if ( LengthVector( vSumOfPotential )> 0.0 ) then
				return -1;
			end

			entity:GetVelocity( vVel );
			FastScaleVector( vTmp, vVel, sec );

			CopyVector( vMyPos, entity:GetPos() );
			CopyVector( vResult, AI.IsFlightSpaceVoidByRadius( vMyPos, vTmp, scale ) );

			local res = vResult.z - vMyPos.z;

			if ( res > 15.0 ) then
					return -1.0;			
			end

			vTmp.x  = 0.0;
			vTmp.y  = 0.0;
			vTmp.z  = -10.0;
			CopyVector( vResult2, AI.IsFlightSpaceVoidByRadius( vMyPos, vTmp, 10.0 ) );
			local res2 = vResult.z - vMyPos.z;


			if ( LengthVector( vResult ) < 0.001 ) then

				if ( LengthVector( vResult2 ) < 0.001 ) then

					local TerrainHeight = System.GetTerrainElevation( entity:GetPos() );
					return TerrainHeight + scale;
					
				else

					--System.Log("B ######### Hight "..vResult.z.."diff "..res.."Hight "..vResult2.z.."diff "..res2);			
					return vResult2.z + 5.0;
			
				end
			
			else

			--System.Log("A ######### Hight "..vResult.z.."diff "..res.."Hight "..vResult2.z.."diff "..res2);			


				if ( LengthVector( vResult2 ) < 0.001 ) then

					return vResult.z + scale;
					
				end
				if ( vResult2.z > vResult.z ) then

					return vResult2.z + 5.0;
					
				else

					return vResult.z + scale;

				end

			end

	end,
	---------------------------------------------
	heliUpdateMinZ = function ( self, entity, vVel, height, sec )

		local vMyPos = {};

		CopyVector( vMyPos, entity:GetPos() );

		if ( entity.AI.minZ == nil ) then
			entity.AI.minZ = vMyPos.z;
		end

		if ( height > 0 ) then
			if ( height > entity.AI.minZ ) then
				entity.AI.minZ = height;
			end
		end

		vVel.z = ( entity.AI.minZ - vMyPos.z )/sec;

	end,
	---------------------------------------------
	heliStickToMinZ = function ( self, entity, vVel )

		local vMyPos = {};
		CopyVector( vMyPos, entity:GetPos() );

		if ( vMyPos.z > entity.AI.minZ + 5.0 ) then
			local v = vMyPos.z - entity.AI.minZ - 5.0;
			v = v * v / 50.0;
			if ( v > 5.0 ) then
				v = 5.0 ;
			end
			vVel.z = v * -1.0;
		end

	end,

	---------------------------------------------
	heliCheckHostile = function ( self, entity, target )

		AI.ChangeParameter( entity.id, AIPARAM_FORGETTIME_TARGET, 16.0 );
		AI.ChangeParameter( entity.id, AIPARAM_FORGETTIME_SEEK, 20.0 );
		AI.ChangeParameter( entity.id, AIPARAM_FORGETTIME_MEMORY, 20.0 );
		if ( AI.Hostile( entity.id, target.id ) ) then
			return true;
		end
		
		if ( AI.GetTargetType(entity.id) == AITARGET_MEMORY ) then
			AI.ChangeParameter( entity.id, AIPARAM_FORGETTIME_TARGET, 0.01 );
			AI.ChangeParameter( entity.id, AIPARAM_FORGETTIME_SEEK, 0.01 );
			AI.ChangeParameter( entity.id, AIPARAM_FORGETTIME_MEMORY, 0.01 );
			return true;
		end

		return false;

	end,
	--------------------------------------------------------------------------
	HeliCheckClearanceMain = function ( self, entity, vForcedNav, sec, radious )

		local vMyPos  ={};
		local vRet  ={};
		local vVel  ={};
		local vVel2  ={};
		local vResult = {};

		--------------------------------------------------------------------------

		CopyVector( vMyPos, entity:GetPos() );
		entity:GetVelocity( vVel );
		FastScaleVector( vVel2, vForcedNav, sec );
		FastSumVectors( vVel, vVel, vVel2 );

--		AI.CheckVehicleColision( entity.id, vMyPos, vVel, radious );
		CopyVector( vResult, AI.IsFlightSpaceVoidByRadius( vMyPos, vVel, radious ) );
		if ( LengthVector( vResult ) < 0.001 ) then
			return 1;
		end

		if ( vResult.z > vMyPos.z ) then
			if ( vResult.z - vMyPos.z < 100.0 ) then

				vForcedNav.z = ( vResult.z - vMyPos.z ) * 5.0;

			end
		end

		if ( vResult.z < vMyPos.z ) then
			if ( ( vMyPos.z - vResult.z ) < 10.0 ) then
				vForcedNav.z = 10.0 - ( vMyPos.z - vResult.z );
			else
				vForcedNav.z = 0;
			end
		end
		
		return 1;
	end,
	}

		



