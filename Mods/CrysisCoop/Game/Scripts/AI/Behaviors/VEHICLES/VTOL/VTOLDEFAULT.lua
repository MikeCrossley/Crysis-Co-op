--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2005.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: VTOL Behaviour SCRIPT
--  
--------------------------------------------------------------------------
--  History:
--  - 15/03/2006   : Created by Tetsuji
--
--------------------------------------------------------------------------


	vtolAttackLocation = {};

	local stayPositionData = {
		
		{
			pat = {
				{ vec = {0.0, 30.0, 80.0}, },{ vec = {0.0, 45.0, 110.0}, },{ vec = {0.0, 30.0, 50.0}, },{ vec = {0.0, 30.0, 80.0}, },{ vec = {0.0, 47.0, 80.0}, },
			},
		},
		{
			pat = {
				{ vec = {-70.0, 40.0, 100.0}, },{ vec = {-30.0, 45.0, 130.0}, },{ vec = {-30.0, 30.0, 40.0}, },{ vec = {-50.0, 30.0, 50.0}, },{ vec = {-30.0, 47.0, 100.0}, },
			},
		},
		{
			pat = {
				{ vec = {70.0, 40.0, 100.0}, },{ vec = {30.0, 45.0, 130.0}, },{ vec = {30.0, 30.0, 40.0}, },{ vec = {50.0, 30.0, 50.0}, },{ vec = {30.0, 47.0, 100.0}, },
			},
		},
		{
			pat = {
				{ vec = {0.0, 80.0, 120.0}, },{ vec = {-30.0, 45.0, 130.0}, },{ vec = {-30.0, 50.0, 40.0}, },{ vec = {-30.0, 30.0, -50.0}, },{ vec = {-30.0, 67.0, 100.0}, },
			},
		},
		{
			pat = {
				{ vec = {0.0, 80.0, 100.0}, },{ vec = {-30.0, 45.0, 130.0}, },{ vec = {-30.0, 50.0, 40.0}, },{ vec = {-30.0, 30.0, -50.0}, },{ vec = {-30.0, 67.0, 100.0}, },
			},
		},

	};

	local checkPositionData = {
		{
			pat = {
				{ vec = {0.0, 50.0, 120.0}, },{ vec = {40.0, 50.0, 120.0}, },{ vec = {-40.0, 50.0, 120.0}, },
			},
		},
		{
			pat = {
				{ vec = {0.0, 50.0, -120.0}, },{ vec = {40.0, 50.0, -120.0}, },{ vec = {-40.0, 50.0, -120.0}, },
			},
		},

	};

AIBehaviour.VTOLDEFAULT = {
	Name = "VTOLDEFAULT",

	--------------------------------------------------------------------------
	-- shared functions 
	--------------------------------------------------------------------------
	vtolRequest2ndGunnerShoot = function( self, entity )

		for i,seat in pairs(entity.Seats) do
			if( seat.passengerId ) then
				local member = System.GetEntity( seat.passengerId );
				if( member ~= nil ) then
			
				  if (seat.isDriver) then
				  else
						local seatId = entity:GetSeatId(member.id);
				  	if ( seat.seat:GetWeaponCount() > 0) then
							bFound = true;
							g_SignalData.fValue = 200.0;
							AI.Signal(SIGNALFILTER_SENDER, 1, "INVEHICLEGUNNER_REQUEST_SHOOT", member.id, g_SignalData);
							return;
						end
					end
			
				end
			end
		end	

	end,

	--------------------------------------------------------------------------
	vtolGetDistanceOfPoints = function(self,src,dst)

		local vTmp = {};
		local distance;

		SubVectors(vTmp,src,dst);
		distance = LengthVector(vTmp);

		return	distance;

	end,
	
	--------------------------------------------------------------------------
	-- get direction vector which length is 'scale'
	vtolGetScaledDirectionVector = function(self,entity,outvec,src,dst,scale)

		SubVectors( outvec, dst, src );
		NormalizeVector( outvec );
		FastScaleVector( outvec, outvec, scale );

	end,

	-- get up vector which length is 'scale'
	vtolGetScaledUpVector = function(self,entity,outvec,scale)

		CopyVector( outvec, entity:GetDirectionVector(2) );
		FastScaleVector( outvec, outvec, scale );

	end,

	--------------------------------------------------------------------------
	-- check the pitch angle for attack
	vtolCheckPitchAngle = function( self, entity )
		
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
	vtolGetTargetDistanceFromTheGround = function( self, entity )

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
	vtolGetMyDistanceFromTheGround = function( self, entity )

		local distance;

		local myPos = {};
		CopyVector( myPos, entity:GetPos() );

		distance = System.GetTerrainElevation( myPos );
		distance = myPos.z - distance;

		return distance;

	end,

	--------------------------------------------------------------------------
	-- returns if a target is flying vehicle
	vtolIsTargetFlying = function( self, entity )

		local targetEntity = AI.GetAttentionTargetEntity( entity.id );
		if ( targetEntity and AI.Hostile( entity.id, targetEntity.id ) ) then
			if ( AI.GetTypeOf(targetEntity.id) == AIOBJECT_VEHICLE ) then
				local distance = self:vtolGetTargetDistanceFromTheGround( entity );
				if ( distance > 15.0 ) then
					return true;
				end
			elseif ( targetEntity.actor ~=nil and targetEntity.actor:GetLinkedVehicleId() ) then
				local distance = self:vtolGetTargetDistanceFromTheGround( entity );
				if ( distance > 15.0 ) then
					return true;
				end
			end
		end

		return false;

	end,

	vtolGetTargetFowardDirection = function( self, entity, out )

		-- check the direction vector of the target.
		-- if he rides on the vehicles, returns a direction of the vehicle.

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			if ( AI.GetTypeOf(target.id) == AIOBJECT_PLAYER) then
				CopyVector( out, System.GetViewCameraDir() );
				return;
			end

			if ( AI.GetTypeOf(target.id) == AIOBJECT_VEHICLE) then
				CopyVector( out, target:GetDirectionVector(1) );
				return;
			end

			if ( target.actor ) then
				local vehicleId = target.actor:GetLinkedVehicleId();
				if ( vehicleId ) then
					local	vehicle = System.GetEntity( vehicleId );
					if( vehicle ) then
						CopyVector( out, vehicle:GetDirectionVector(1) );
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
	-- getAvereageDirectionOftheVtol.
	vtolGetAlignedDirection = function( self, entity, vOut )

		-- implement a simple flocking.
		CopyVector( vOut, entity:GetDirectionVector(1) );

		local i;

		local entities = System.GetPhysicalEntitiesInBox( entity:GetPos(), 35.0 );
		local targetEntity;

		if (entities) then

			for i,targetEntity in ipairs(entities) do

				local objEntity = targetEntity;

				if ( objEntity.id ~= entity.id ) then
					if ( AI.GetTypeOf(  objEntity.id ) == AIOBJECT_VEHICLE ) then
						if ( AI.GetSubTypeOf(  objEntity.id ) == AIOBJECT_HELICOPTER ) then
							if( AI.Hostile( entity.id, objEntity.id ) ) then
							else
								local myTarget = AI.GetAttentionTargetEntity( entity.id );
								local hisTarget = AI.GetAttentionTargetEntity( objEntity.id );
								if ( myTarget.id == hisTarget.id ) then
									 FastSumVectors( vOut, vOut, entity:GetDirectionVector(1) );
								end
							end
						end
					end
				end
			end

		else
		end	

	end,

	--------------------------------------------------------------------------
	-- simple flocking.
	vtolAdjustRefPoint = function( self, entity, sw )

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
		if ( boxValue > 100.0 ) then
			boxValue = 100.0;
		end

		local entities = System.GetPhysicalEntitiesInBox( entity:GetPos(), boxValue );
		local targetEntity;

		if (entities) then

			for i,targetEntity in ipairs(entities) do

				local objEntity = targetEntity;

				if ( objEntity.id == entity.id ) then

				elseif ( objEntity:GetMass() < 100.0 or AI.GetTypeOf(objEntity.id) == AIOBJECT_PUPPET or AI.GetTypeOf(objEntity.id) == AIOBJECT_PLAYER ) then

				else

					local objPosition = {}
					CopyVector( objPosition, objEntity:GetPos() );

					local objDistDirN ={};
					local objDistDir ={};
					SubVectors( objDistDir, objPosition, myPosition );
					CopyVector( objDistDirN, objDistDir );
					NormalizeVector( objDistDirN );			

					local objDistance = LengthVector( objDistDir );
					if (objDistance < 1.0 ) then
						objDistance = 1.0;
					end
					
					--AI.LogEvent(entity:GetName().." vtolAdjustRefPoint : gets a vector from "..objEntity:GetName().." mass =  "..objEntity:GetMass() );
					objDistance = boxValue - objDistance;

					if ( objDistance < 0.0 ) then
						objDistance = 0.0;
					end

					objDistance = objDistance * -1.0;

					FastScaleVector( objDistDir, objDistDirN, objDistance );
					FastSumVectors( vDifference, vDifference, objDistDir );
					FastSumVectors( vNewRefPoint, vNewRefPoint, objDistDir );
					bResult = true;
	
				end

			end

		else
		end	
		
		--AI.LogEvent(entity:GetName()..":"..vDifference.x..","..vDifference.y..","..vDifference.z);
	
		if ( sw > 0.0 ) then
	
			local vSrc = {};
			local vDir = {};
			local vDown = {};
			local vUp = {};

			CopyVector( vUp, entity:GetDirectionVector(2) );
			CopyVector( vSrc, vNewRefPoint );

			FastScaleVector( vUp, vUp, sw );
			FastScaleVector( vDown, vUp, -1.0 );
			FastScaleVector( vDir, vDown, 2.0 );
			FastSumVectors( vSrc, vSrc, vUp );

			local	hits = Physics.RayWorldIntersection(vSrc,vDir,1,ent_terrain+ent_static+ent_rigid+ent_sleeping_rigid,entity.id,nil,g_HitTable);
			if( hits == 0 ) then
			else
				local firstHit = g_HitTable[1];
				FastSumVectors( vNewRefPoint, firstHit.pos, vUp );
--				AI.LogEvent(entity:GetName().." vtolAdjustRefPoint : gets a vector from RayWorldIntersection 1/"..sw );
				end					
		
			CopyVector( vDir, entity:GetVelocity() );
			FastScaleVector( vDir, vDir, 5.0 );
			hits = Physics.RayWorldIntersection( entity:GetPos(),vDir,1,ent_terrain+ent_static+ent_rigid+ent_sleeping_rigid,entity.id,nil,g_HitTable);
			if( hits == 0 ) then
			else
				local firstHit = g_HitTable[1];
				SubVectors( vDir, firstHit.pos, entity:GetPos() );
				NormalizeVector( vDir );
				FastScaleVector( vDir, vDir, -20.0 );
				FastSumVectors( vDir, vDir, entity:GetPos() );
				CopyVector( vNewRefPoint, vDir );
--				AI.LogEvent(entity:GetName().." vtolAdjustRefPoint : gets a vector from RayWorldIntersection 2/-20" );
			end					

		end
	
		AI.SetRefPointPosition( entity.id, vNewRefPoint );
		return bResult;

	end,

	--------------------------------------------------------------------------
	-- Get a position for a specific purpose in FOV
	vtolCheckNavOfRef = function( self, entity )

		local vTmp = {};
		SubVectors( vTmp, AI.GetRefPointPosition( entity.id ), entity:GetPos() );
		local distance = LengthVector( vTmp ) + 0.01;

		FastScaleVector( vTmp, vTmp, ( distance + 12.0 )/distance );
		FastSumVectors( vTmp, vTmp, entity:GetPos() );
		
		if ( AI.IsPointInFlightRegion( vTmp ) == false ) then
			--AI.LogComment(entity:GetName().." detected a bad ref point");
			return	false;			
		end
		
		return true;

	end,

	--------------------------------------------------------------------------
	-- Get a position for a specific purpose in FOV
	vtolRefreshStayAttackPosition = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			local targetPos = {};

			local cameraFwdDir = {};
			local cameraWingDir = {};
			local targetUpDir = {};
			local targetFwdDir = {};
			local targetWingDir = {};

			CopyVector( targetPos, target:GetPos() );
			self:vtolGetTargetFowardDirection( entity, cameraFwdDir );
			CopyVector( cameraWingDir, vecFrontToRight(cameraFwdDir) );
			
			-- for the vtol we can use updir = (0,0,1)
			targetUpDir.x =0;
			targetUpDir.y =0;
			targetUpDir.z =1.0;
			--CopyVector( targetUpDir, target:GetDirectionVector(2) );

			--Just in case, for scaling
			NormalizeVector(cameraFwdDir);
			NormalizeVector(targetUpDir);

			local t = dotproduct3d( cameraFwdDir , targetUpDir );

			--Avoid a singularity
			if ( t * t < 0.9 ) then

				ProjectVector( targetFwdDir  , cameraFwdDir  , targetUpDir );
				ProjectVector( targetWingDir , cameraWingDir , targetUpDir );
				NormalizeVector(targetFwdDir);
				NormalizeVector(targetWingDir);

				CopyVector( entity.vFwdUnit, targetFwdDir  );
				CopyVector( entity.vWngUnit, targetWingDir );
				CopyVector( entity.vUpUnit , targetUpDir   );
				CopyVector( entity.vAttackCenterPos, targetPos );

				return true;
	
			end

		end

		-- clear vectors; the vtol will stay the same position.

		local zeroVec ={};
		zeroVec.x = 0.0;
		zeroVec.y = 0.0;
		zeroVec.z = 0.0;
		CopyVector( entity.vFwdUnit, zeroVec );
		CopyVector( entity.vWngUnit, zeroVec );
		CopyVector( entity.vUpUnit, zeroVec );
		CopyVector( entity.vAttackCenterPos, entity:GetPos() );

		return	false;

	end,

	--------------------------------------------------------------------------
	vtolCheckStayAttackPosition = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			local targetPos = {};

			local cameraFwdDir = {};
			local cameraWingDir = {};
			local targetUpDir = {};
			local targetFwdDir = {};
			local targetWingDir = {};

			CopyVector( targetPos, target:GetPos() );
			CopyVector( cameraFwdDir, System.GetViewCameraDir() );
			CopyVector( cameraWingDir, vecFrontToRight(cameraFwdDir) );
			CopyVector( targetUpDir, target:GetDirectionVector(2) );

			--Just in case, for scaling
			NormalizeVector(cameraFwdDir);
			NormalizeVector(targetUpDir);

			local t = dotproduct3d( cameraFwdDir , targetUpDir );
			--Avoid a singularity
			if ( t * t < 0.9 ) then

				ProjectVector( targetFwdDir  , cameraFwdDir  , targetUpDir );
				ProjectVector( targetWingDir , cameraWingDir , targetUpDir );
				NormalizeVector(targetFwdDir);
				NormalizeVector(targetWingDir);

				local i;
				local j;
				local k;

				local scaleFactor;
				local vTmp = {};
				local vCheck = {};
				local bResult;		

				for i = 1,7 do
					scaleFactor = (11.0-i)/10.0;
					entity.vFormationScale.x = scaleFactor;
					entity.vFormationScale.y = scaleFactor;
					entity.vFormationScale.z = scaleFactor;
					for k = 1,2 do
						bResult = true;
						for j = 1,3 do
							FastScaleVector( vTmp, targetWingDir, checkPositionData[k].pat[j].vec[1] * entity.vFormationScale.x);
							CopyVector( vCheck, vTmp );
							FastScaleVector( vTmp, targetUpDir, checkPositionData[k].pat[j].vec[2] * entity.vFormationScale.z);
							FastSumVectors( vCheck, vCheck, vTmp );
							FastScaleVector( vTmp, targetFwdDir, checkPositionData[k].pat[j].vec[3] * entity.vFormationScale.y);
							FastSumVectors( vCheck, vCheck, vTmp );
							FastSumVectors( vCheck, vCheck, targetPos );
							if ( AI.IsPointInFlightRegion( vCheck ) == false ) then
								bResult = false;
							end
						end
						if (bResult==true) then
							if (k==2) then
								entity.vFormationScale.y = entity.vFormationScale.y* -1.0;
							end
							return true;
						end
					end
				end

			end
		end

		entity.vFormationScale.x = 0.0;
		entity.vFormationScale.y = 0.0;
		entity.vFormationScale.z = 0.0;
		return	false;

	end,

	--------------------------------------------------------------------------
	vtolGetStayAttackPosition = function( self, entity, X, pattern )

		-- X:       output position
		-- entity:  input  entitiy
		-- pattern: input  0 - attack position 1 - escape position. 2 - MOAR attack position 3 - for flyover

		-- when error, will return a current my position.

		local targetWngDir = {};
		local targetUpDir = {};
		local targetFwdDir = {};
		local vtolAttackCenterPos = {};

		if ( entity.stayPosition == 0 ) then

			CopyVector( X, entity.vDefaultPosition );

		elseif (LengthVector( entity.vFormationScale ) < 0.01 ) then
		
			CopyVector ( X, entity:GetPos() );
		
		else

			local distanceFromTheGround = self:vtolGetMyDistanceFromTheGround( entity );
			local targetDistanceFromTheGround = self:vtolGetTargetDistanceFromTheGround( entity );

			if ( self:vtolIsTargetFlying(entity) == true ) then
				-- vs flying target
				FastScaleVector( targetWngDir , entity.vWngUnit , stayPositionData[entity.stayPosition].pat[pattern+1].vec[1] * entity.vFormationScale.x);
				FastScaleVector( targetUpDir  , entity.vUpUnit  , stayPositionData[entity.stayPosition].pat[pattern+1].vec[2] * entity.vFormationScale.z /4.0 );
				FastScaleVector( targetFwdDir , entity.vFwdUnit , stayPositionData[entity.stayPosition].pat[pattern+1].vec[3] * entity.vFormationScale.y * 2.0 );
				FastSumVectors( vtolAttackCenterPos , entity.vAttackCenterPos, targetUpDir   );
				FastSumVectors( vtolAttackCenterPos , vtolAttackCenterPos    , targetFwdDir  );
				FastSumVectors( vtolAttackCenterPos , vtolAttackCenterPos    , targetWngDir );
			else
				-- vs ground target
				FastScaleVector( targetWngDir , entity.vWngUnit , stayPositionData[entity.stayPosition].pat[pattern+1].vec[1] * entity.vFormationScale.x);
				FastScaleVector( targetUpDir  , entity.vUpUnit  , stayPositionData[entity.stayPosition].pat[pattern+1].vec[2] * entity.vFormationScale.z);
				FastScaleVector( targetFwdDir , entity.vFwdUnit , stayPositionData[entity.stayPosition].pat[pattern+1].vec[3] * entity.vFormationScale.y);
				FastSumVectors( vtolAttackCenterPos , entity.vAttackCenterPos, targetUpDir   );
				FastSumVectors( vtolAttackCenterPos , vtolAttackCenterPos    , targetFwdDir  );
				FastSumVectors( vtolAttackCenterPos , vtolAttackCenterPos    , targetWngDir );
			end

			-- limit height
			if ( distanceFromTheGround > 150.0 ) then
				local myPos = {};
				CopyVector( myPos, entity:GetPos() );
				vtolAttackCenterPos.z = System.GetTerrainElevation( myPos ) + 150.0;
			end

			CopyVector ( X, vtolAttackCenterPos );

		end

	end,

	--------------------------------------------------------------------------
	vtolGetPickPosition = function( self, entity )

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
	vtolGetID = function( self, entity )

		-- 29/11/05 tetsuji

		local i=0;
		local j=0;

		local target = AI.GetAttentionTargetEntity( entity.id );

		if ( target and AI.Hostile( entity.id, target.id ) ) then

			-- clear list.
			for i= 1,5 do
				if ( vtolAttackLocation[i] == nil ) then
					vtolAttackLocation[i] = 0;
				end
			end

			-- clear list if a vtol has already resistered.
			for i= 1,5 do
				if ( vtolAttackLocation[i] ~= 0 ) then
					if ( vtolAttackLocation[i] == entity.id ) then
							vtolAttackLocation[i] = 0;
					else
						local vtolEntity = System.GetEntity( vtolAttackLocation[i] );
						if ( vtolEntity ) then
							if ( vtolEntity.health and vtolEntity.health <= 0 ) then
								vtolAttackLocation[i] = 0;
							end
						else
							vtolAttackLocation[i] = 0;
						end
					end
				end
			end

			-- check if there is a empty seat.
			for i= 1,5 do
				if ( vtolAttackLocation[i] == 0 ) then
					vtolAttackLocation[i] = entity.id;
					entity.stayPosition = i;
					return;
				end
			end

		else
		end

		entity.stayPosition = 0;

	end,

	--------------------------------------------------------------------------
	vtolDoStayAttack = function( self, entity )

		if ( System.GetCurrTime()- entity.time > 3.0 ) then
			AI.Signal(SIGNALFILTER_GROUPONLY, 1, "VTOL_REFLESH_POSITION",entity.id);
		end

		local vtolAttackCenterPos = {};
		self:vtolGetStayAttackPosition( entity , vtolAttackCenterPos , 0 );
		AI.SetRefPointPosition( entity.id , vtolAttackCenterPos  );
		entity:SelectPipe(0,"do_nothing");

		if ( entity.stayPosition == 0 ) then

			-- if he couldn't join a formation.
			AI.SetRefPointPosition( entity.id , entity:GetPos()  );
			self:vtolAdjustRefPoint( entity , 20.0 );
			
			AI.CreateGoalPipe("vtolAttackWait");
			AI.PushGoal("vtolAttackWait","locate",0,"atttarget");
			AI.PushGoal("vtolAttackWait","lookat",1,0,0,true);
			AI.PushGoal("vtolAttackWait","run",0,0);	
			AI.PushGoal("vtolAttackWait","locate",0,"refpoint");		
			AI.PushGoal("vtolAttackWait","approach",0,3.0,AILASTOPRES_USE);
			AI.PushGoal("vtolAttackWait","timeout",1,0.5);
			AI.PushGoal("vtolAttackWait","run",0,0);	
			AI.PushGoal("vtolAttackWait","signal",0,1,"VTOL_STAY_ATTACK",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"vtolAttackWait");
			return;

		end

		AI.SetRefPointPosition( entity.id , entity:GetPos()  );
		if ( self:vtolAdjustRefPoint( entity , 20.0 ) == false ) then
			-- means if a position is safe
			AI.SetRefPointPosition( entity.id , vtolAttackCenterPos  );
			self:vtolAdjustRefPoint( entity , 20.0 );
		end

		local currentDirLen = DistanceVectors( AI.GetRefPointPosition( entity.id ) ,entity:GetPos() );

		if ( currentDirLen < 20.0 ) then

			if ( random(1,3) == 1 ) then
				AI.CreateGoalPipe("vtolAttackStandByV3");
				AI.PushGoal("vtolAttackStandByV3","locate",0,"atttarget");
				AI.PushGoal("vtolAttackStandByV3","lookat",1,0,0,true);
				AI.PushGoal("vtolAttackStandByV3","run",0,0);
				AI.PushGoal("vtolAttackStandByV3","approach",0,3.0,AILASTOPRES_USE);
				--AI.PushGoal("vtolAttackStandByV3","firecmd",0,FIREMODE_FORCED);
				AI.PushGoal("vtolAttackStandByV3","firecmd",0,0);
				AI.PushGoal("vtolAttackStandByV3","timeout",1,3);
				AI.PushGoal("vtolAttackStandByV3","firecmd",0,0);
				AI.PushGoal("vtolAttackStandByV3","timeout",1,0.3);
				AI.PushGoal("vtolAttackStandByV3","signal",0,1,"VTOL_STAY_ATTACK",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"vtolAttackStandByV3");
			else
				AI.CreateGoalPipe("vtolAttackStandByV4");
				AI.PushGoal("vtolAttackStandByV4","locate",0,"atttarget");
				AI.PushGoal("vtolAttackStandByV4","lookat",1,0,0,true);
				AI.PushGoal("vtolAttackStandByV4","run",0,0);
				AI.PushGoal("vtolAttackStandByV4","approach",0,3.0,AILASTOPRES_USE);
				AI.PushGoal("vtolAttackStandByV4","timeout",1,3);
				AI.PushGoal("vtolAttackStandByV4","run",0,0);
				AI.PushGoal("vtolAttackStandByV4","signal",0,1,"VTOL_STAY_ATTACK",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"vtolAttackStandByV4");
			end

		else

			AI.CreateGoalPipe("vtolAttackStandByV2");
			AI.PushGoal("vtolAttackStandByV2","locate",0,"atttarget");
			AI.PushGoal("vtolAttackStandByV2","lookat",1,0,0,true);
			AI.PushGoal("vtolAttackStandByV2","run",0,0);		
			--AI.PushGoal("vtolAttackStandByV2","firecmd",0,FIREMODE_FORCED);
			AI.PushGoal("vtolAttackStandByV2","firecmd",0,0);
			AI.PushGoal("vtolAttackStandByV2","locate",0,"refpoint");		
			AI.PushGoal("vtolAttackStandByV2","approach",0,3.0,AILASTOPRES_USE);
			AI.PushGoal("vtolAttackStandByV2","timeout",1,3);
			AI.PushGoal("vtolAttackStandByV2","firecmd",0,0);
			AI.PushGoal("vtolAttackStandByV2","timeout",1,0.3);
			AI.PushGoal("vtolAttackStandByV2","signal",0,1,"VTOL_STAY_ATTACK",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"vtolAttackStandByV2");

		end

	end,

	--------------------------------------------------------------------------
	}

