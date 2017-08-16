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
--  - 05/11/2005   : Created by Tetsuji Iwasaki
--
--------------------------------------------------------------------------

--------------------------------------------------------------------------
local XAxis = 0;
local YAxis = 1;
local ZAxis = 2;

--------------------------------------------------------------------------
local function request2ndGunnerShoot( entity )

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
						return;
					end
				end
			
			end
		end
	end	

end

--------------------------------------------------------------------------
local function tankCheckPlayerVehicle( entity )

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
			--AI.LogEvent(vehicle:GetName().." set TankHi");
		end
		return true;
	end

	return false;

end

--------------------------------------------------------------------------
local function tankGetTargetFowardDirection( entity, out )

	-- check the direction vector of the target.
	-- if he rides on the vehicles, returns a direction of the vehicle.

	local target = AI.GetAttentionTargetEntity( entity.id );
	if ( target and AI.Hostile( entity.id, target.id ) ) then

		if ( AI.GetTypeOf(target.id) == AIOBJECT_PLAYER ) then
			CopyVector( out, System.GetViewCameraDir() );
			return;
		end

		if ( AI.GetTypeOf(target.id) == AIOBJECT_VEHICLE ) then
			CopyVector( out, target:GetDirectionVector(YAxis) );
			return;
		end

		if ( target.actor ) then
			local vehicleId = target.actor:GetLinkedVehicleId();
			if ( vehicleId ) then
				local	vehicle = System.GetEntity( vehicleId );
				if( vehicle ) then
					CopyVector( out, vehicle:GetDirectionVector(YAxis) );
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
	
end


--------------------------------------------------------------------------
local function checkFriendInWay( entity , vDifference )

	-- returns 0 no obstacle
	-- returns 1 there are obstacles and all obstacles are not moving
	-- returns 2 there is an obstacle which is moving

	local result = 0;
	local objects = {};

	local myPosition = {};
	local vRot = {};
	local vTmp = {};
	vDifference.x =0.0;
	vDifference.y =0.0;
	vDifference.z =0.0;

	CopyVector( myPosition, entity:GetPos() );
	
	CopyVector( vRot, entity:GetVelocity() );
	local speed = LengthVector( vRot );
	if ( speed > 0.1 ) then
		NormalizeVector( vRot );
		FastScaleVector( vTmp, vRot, speed * 4.0 );
		FastSumVectors( vTmp, vTmp, entity:GetPos() );
		if ( System.GetTerrainElevation( vTmp ) - System.GetTerrainElevation( entity:GetPos() ) > 3.0 ) then
			FastScaleVector( vDifference, vRot, -1.0 );
			return 1;
		end
	end

	local i;
	local range = 30.0;
	local entities = System.GetPhysicalEntitiesInBox( entity:GetPos(), range );

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

end
--------------------------------------------------------------------------
local function tankFovCheck( entity, vPos )

	local vDir = {};
	SubVectors( vDir, vPos, entity:GetPos() );
	NormalizeVector( vDir );

	local bPlayer = tankCheckPlayerVehicle( entity );
	
	local t;
	local inFOV = math.cos( 60.0 * 3.1415 / 180.0 );

	if ( bPlayer == true ) then
		t	= dotproduct3d(	vDir, System.GetViewCameraDir() );
	else
		t	= dotproduct3d( vDir, entity:GetDirectionVector(YAxis) );
	end

	if ( t > inFOV ) then
		return true;
	else
		return false;
	end

end

--------------------------------------------------------------------------
local function tankMakeApproachPipe( entity, vPos, pipename, range, sw )

	local vTmp = {};

	CopyVector( entity.AI.vLastPosition, entity:GetPos() );
		
	SubVectors( vTmp, vPos, entity:GetPos() );

	local approachlen = LengthVector( vTmp ) - range;
	if ( approachlen < 0 ) then
		approachlen = 0;
	end

	entity.AI.fireCounter = 0;

	AI.SetRefPointPosition( entity.id , vPos );

	entity:SelectPipe(0,"do_nothing");
	AI.CreateGoalPipe(pipename);

	local inFOV = math.cos( 120.0 * 3.1415 / 180.0 );

	if ( sw == false ) then
		NormalizeVector( vTmp );
		if ( dotproduct3d( vTmp, entity:GetDirectionVector(1) ) > inFOV ) then
			AI.PushGoal(pipename,"run",0,1);	
		else
			AI.PushGoal(pipename,"run",0,-2);	
		end
	else
		NormalizeVector( vTmp );
		if ( dotproduct3d( vTmp, entity:GetDirectionVector(1) ) > inFOV ) then
			AI.PushGoal(pipename,"run",0,2);	
		else
			AI.PushGoal(pipename,"run",0,-2);	
		end
	end


	AI.PushGoal(pipename,"continuous",0,1);	
	AI.PushGoal(pipename,"+locate",0,"refpoint");
	AI.PushGoal(pipename,"+approach",0,range,AILASTOPRES_USE,10.0);	

	local waitCount = approachlen / 10.0;

	if ( waitCount < 1.0 ) then

		AI.PushGoal(pipename,"signal",0,1,"TANK_MOVE_CHECK_FIRE",SIGNALFILTER_SENDER);
		AI.PushGoal(pipename,"signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
		AI.PushGoal(pipename,"timeout",1,3.0);

	else

		for i = 1,waitCount do
			AI.PushGoal(pipename,"signal",0,1,"TANK_MOVE_CHECK_FIRE",SIGNALFILTER_SENDER);
			AI.PushGoal(pipename,"signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
			AI.PushGoal(pipename,"timeout",1,0.4);
			AI.PushGoal(pipename,"signal",0,1,"TANK_MOVE_CHECK_FIRE",SIGNALFILTER_SENDER);
			AI.PushGoal(pipename,"signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
			AI.PushGoal(pipename,"timeout",1,0.4);
		end;

	end

	AI.PushGoal(pipename,"signal",0,1,"TANK_MOVE_CHECK_FIRE_END",SIGNALFILTER_SENDER);
	entity:SelectPipe(0,pipename);

end

--------------------------------------------------------------------------
local function tankGoBack( entity )

	local vTmp = {};
	local vWng = {};
	local distance = 3.0;
	local run = 1;

	local target = AI.GetAttentionTargetEntity( entity.id );
	if ( target and AI.Hostile( entity.id, target.id ) ) then

		FastScaleVector( vWng, entity:GetDirectionVector(XAxis), random( -5, 5 ) );
		SubVectors( vTmp, target:GetPos(), entity:GetPos() );
		if ( LengthVector( vTmp ) < 40.0 ) then
			NormalizeVector( vTmp );
			FastScaleVector( vTmp, vTmp, -15.0 );
			FastSumVectors( vTmp, vTmp, vWng );
			FastSumVectors( vTmp, vTmp, entity:GetPos() );
			AI.SetRefPointPosition( entity.id , vTmp );

			local inFOV = math.cos( 120.0 * 3.1415 / 180.0 );
			SubVectors( vTmp, vTmp, entity:GetPos() );
			NormalizeVector( vTmp );

			if ( dotproduct3d( vTmp, entity:GetDirectionVector(1) ) > inFOV ) then
				run = 1;	
			else
				run = -2;	
			end

		else

			NormalizeVector( vTmp );
			FastScaleVector( vTmp, vTmp, 5.0 );
			FastSumVectors( vTmp, vTmp, vWng );
			FastSumVectors( vTmp, vTmp, entity:GetPos() );
			AI.SetRefPointPosition( entity.id , vTmp );
			run = 1;	-- to turn toward the target.

		end
	else
	
		FastScaleVector( vWng, entity:GetDirectionVector(XAxis), random( -5, 5 ) );
		FastScaleVector( vTmp, entity:GetDirectionVector(YAxis), -10.0 );
		FastSumVectors( vTmp, vTmp, vWng );
		FastSumVectors( vTmp, vTmp, entity:GetPos() );
		AI.SetRefPointPosition( entity.id , vTmp );

		local inFOV = math.cos( 120.0 * 3.1415 / 180.0 );
		SubVectors( vTmp, vTmp, entity:GetPos() );
		NormalizeVector( vTmp );

		if ( dotproduct3d( vTmp, entity:GetDirectionVector(1) ) > inFOV ) then
			run = 1;	
		else
			run = -2;	
		end

	end



	entity.AI.fireCounter = 0;

	AI.CreateGoalPipe("tank_goback");
	AI.PushGoal("tank_goback","run",0,run);	
	AI.PushGoal("tank_goback","continuous",0,1);	
	AI.PushGoal("tank_goback","+locate",0,"refpoint");
	AI.PushGoal("tank_goback","+approach",0,3.0,AILASTOPRES_USE,10.0);	

	local maxCounter = random(4,6);
	for i = 1,maxCounter do
		AI.PushGoal("tank_goback","signal",0,1,"TANK_MOVE_CHECK_FIRE",SIGNALFILTER_SENDER);
		AI.PushGoal("tank_goback","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
		AI.PushGoal("tank_goback","timeout",1,0.3);
	end
	AI.PushGoal("tank_goback","signal",0,1,"TANK_MOVE_CHECK_FIRE_END",SIGNALFILTER_SENDER);
	entity:SelectPipe(0,"tank_goback");

end

local function dumpVector( vector, vector2 )

--	AI.LogEvent(vector.x..","..vector.y..","..vector.z.." -> "..vector2.x..","..vector2.y..","..vector2.z);

end
--------------------------------------------------------------------------
local function tankFindAnchorNearByMain( entity, vPos, bCheckInner )

	local vTmp = {};
	local vTmp2 = {};
	local vTmp3 = {};
	local vMyPos ={};
	CopyVector( vMyPos, entity:GetPos() );

	local vInnerVec = {};
	CopyVector( vInnerVec, entity:GetDirectionVector(YAxis) );

	if ( bCheckInner == true ) then

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then
			SubVectors( vInnerVec, target:GetPos(), entity:GetPos() );
			NormalizeVector( vInnerVec );
		else
			bCheckInner = false;
		end
	end

	local length = DistanceVectors( entity:GetPos(), vPos );
	if ( length > 100.0 ) then
		local vTmp = {};
		SubVectors( vTmp, vPos, entity:GetPos() );
		NormalizeVector( vTmp );
		FastScaleVector( vTmp, vTmp, 100.0 );
		CopyVector( vTmp3, vTmp ); 
		--AI.LogEvent(entity:GetName().." set length to less than 100m < "..length );
		dumpVector( vPos, vTmp3 );
		FastSumVectors( vPos, vTmp, entity:GetPos() );
		length = 100.0;
	end
	
	if ( length < 50.0 ) then
		length = 50.0;
	end

	local i;
	local bSafe =1;
	local objects = {};
	local numObjects = AI.GetNearestEntitiesOfType( entity:GetPos(), AIAnchorTable.TANK_SPOT, 10, objects, AIFAF_INCLUDE_DEVALUED, length );

	if ( numObjects > 1 ) then	-- at least 2 anchors
		--AI.LogEvent(entity:GetName().." find anchors #"..numObjects );

		local vG ={};
		local vTmp ={};
	
		CopyVector( vG, entity:GetPos() );
		for i = 1,numObjects do
			local objEntity = System.GetEntity( objects[i].id );
			FastSumVectors( vG, vG, objEntity:GetPos());
		end

		FastScaleVector( vG, vG, 1.0/(numObjects+1.0) );
		--AI.LogEvent(entity:GetName().." calculat gravity point:" );
		dumpVector( vPos, vG );

		if ( DistanceVectors( entity:GetPos(), vPos ) < 50.0 ) then
			--AI.LogEvent(entity:GetName().." safe condition " );
			bSafe = 3;
		else
			bSafe = 2;
			--AI.LogEvent(entity:GetName().." isolate condition " );
		end

	elseif ( numObjects == 1 ) then
		bSafe = 1;
		--AI.LogEvent(entity:GetName().." find anchors 1");
		local objEntity = System.GetEntity( objects[1].id );
		CopyVector( vPos, objEntity:GetPos()  );
	else
		bSafe = 0;
		return false;	
	end

	local maxDistance = 10000.0;
	local findObjEntity;
	local lengthtmp;

	if ( bSafe == 3 or bSafe == 2 ) then

		for i = 1,numObjects do
			local objEntity = System.GetEntity( objects[i].id );
			local lengthtmp = DistanceVectors( objEntity:GetPos(), vPos );
			
			if ( bCheckInner ==true ) then
				SubVectors( vTmp, objEntity:GetPos(), entity:GetPos() );
				NormalizeVector( vTmp );
				if ( dotproduct3d( vTmp, vInnerVec ) > math.cos( 90.0 * 3.1415 / 180.0 ) ) then
					lengthtmp = 300.0;
				end
			end

			local target = AI.GetAttentionTargetEntity( entity.id );
			if ( target and AI.Hostile( entity.id, target.id ) ) then
				SubVectors( vTmp, target:GetPos(), objEntity:GetPos() );
				if ( LengthVector( vTmp )< 30.0 ) then
					lengthtmp = 300.0;
				end
			end
			
			if ( lengthtmp < maxDistance ) then
				findObjEntity = objEntity;
				maxDistance = lengthtmp;
			end

		end

		lengthtmp = DistanceVectors( findObjEntity:GetPos(), vPos );

		if ( bSafe == 3 ) then
			SubVectors( vTmp, findObjEntity:GetPos(), vPos );
			local lengthTmp = LengthVector( vTmp );
			if ( lengthTmp > 30.0 ) then
					FastScaleVector( vTmp, vTmp, 30.0/lengthTmp );
			end
			FastSumVectors( vTmp, vTmp, vPos );
			--AI.LogEvent(entity:GetName().." adjusted a point 1" );
			CopyVector( vPos, vTmp );
		else
			CopyVector( vTmp, findObjEntity:GetPos() );
			--AI.LogEvent(entity:GetName().." adjusted a point 1-1" );
			CopyVector( vPos, vTmp );
		end

	else
		return false;	
		
	end

		SubVectors( vTmp2, vTmp, entity:GetPos() );
		lengthTmp = LengthVector( vTmp2 );
		FastScaleVector( vTmp3, vTmp2, (lengthTmp+15.0)/lengthTmp );

		vTmp  = AI.IntersectsForbidden( vMyPos, vTmp3 );

		if ( DistanceVectors( vTmp, vTmp3 ) > 0.0 ) then
			CopyVector( vTmp3, vTmp );
			SubVectors( vTmp, vTmp, vPos );
			lengthTmp = LengthVector( vTmp );
			FastScaleVector( vTmp, vTmp, (lengthTmp-15.0)/lengthTmp );
			FastSumVectors( vTmp, vTmp, vPos );
			--AI.LogEvent(entity:GetName().." adjusted a point 2" );
			dumpVector( vTmp, vTmp3 );
		end
		
		vTmp2.x = vTmp.x;
		vTmp2.y = vTmp.y;
		vTmp2.z = vMyPos.z + 2.0;

		vTmp3.x = vMyPos.x;
		vTmp3.y = vMyPos.y;
		vTmp3.z = vMyPos.z + 2.0;

		SubVectors( vTmp2, vTmp2, vTmp3 );

		local	hits = Physics.RayWorldIntersection( vMyPos ,vTmp2,1,ent_terrain+ent_static+ent_rigid+ent_sleeping_rigid+ent_living,entity.id,nil,g_HitTable);
		if( hits > 0 ) then
			CopyVector( vTmp3, vTmp );
			local firstHit = g_HitTable[1];
			CopyVector( vTmp, firstHit.pos );
			SubVectors( vTmp, vTmp, vPos );
			lengthTmp = LengthVector( vTmp );
			FastScaleVector( vTmp, vTmp, (lengthTmp-10.0)/lengthTmp );
			FastSumVectors( vTmp, vTmp, vMyPos );
			--AI.LogEvent(entity:GetName().." adjusted a point 3" );
			dumpVector( vTmp, vTmp3 );
		end

	return true;

end

--------------------------------------------------------------------------
local function tankFindAnchorNearBy( entity, vPos )

	return tankFindAnchorNearByMain( entity, vPos, false );

end
--------------------------------------------------------------------------
local function tankRunDownThePlayer( entity )

	local target = System.GetEntity( g_localActor.id ); -- get player's situation
	if ( target and target.actor and AI.GetTypeOf( target.id ) == AIOBJECT_PLAYER and AI.Hostile( entity.id, target.id ) ) then
		local vehicleId = target.actor:GetLinkedVehicleId();
		if ( vehicleId ) then
		else
			local length = DistanceVectors( entity:GetPos(), target:GetPos() );
			if ( length < 50.0 ) then

				local objects = {};

				local numObjects = AI.GetNearestEntitiesOfType( target:GetPos(), AIOBJECT_VEHICLE, 10, objects, AIFAF_INCLUDE_DEVALUED, 50 );
				if ( numObjects < 2 ) then	

					local inFOV = math.cos( 60.0 * 3.1415 / 180.0 );
	
					vDirToTarget = {};
					CopyVector( vDirToTarget, target:GetPos(), entity:GetPos() );
					NormalizeVector( vDirToTarget );
					local dot = dotproduct3d( vDirToTarget, entity:GetDirectionVector(YAxis) );
	
					if (  dot > inFOV or dot < -inFOV ) then
				
						FastScaleVector( vDirToTarget, vDirToTarget ,0.0 );
						FastSumVectors( vDirToTarget, vDirToTarget, target:GetPos() );

						local vInput = {};
						CopyVector( vInput , vDirToTarget );

						local result = tankFindAnchorNearBy( entity, vInput );
						if ( result == false ) then
							return false;
						end

						if ( DistanceVectors( vInput, vDirToTarget ) > 20.0 ) then
							return false;
						end

						local vDir = {};
						local vTargetPos = {};
						CopyVector( vTargetPos, target:GetPos() );
						local level = System.GetTerrainElevation( vTargetPos )

						if ( vTargetPos.z - level <1.0 ) then
							vTargetPos.z = vTargetPos.z + 1.0;
						end

						SubVectors( vDir, vTargetPos, entity:GetPos() );

						if ( vDir.z > 2.5 and vDir.z < -2.5 ) then
							return false;
						end

						local	hits = Physics.RayWorldIntersection(entity:GetPos(),vDir,1,ent_static+ent_rigid+ent_sleeping_rigid,entity.id,target.id,g_HitTable);
						if( hits == 0 ) then
							pipename = "tankRunOverThePlayer";
							tankMakeApproachPipe( entity, vDirToTarget, pipename, 3, true );
							return true;
						else
						end
					end
				end
			end
		end
	end

	return false;

end

--------------------------------------------------------------------------
local function tankGetInFov( entity ,vPos )

	-- analize the situation

	local vDestination = {};
	local vDestinationRot = {};

	local vDirToTarget = {};

	local vRotVecSrc = {};
	local vRotVec = {};
	local myPos = {};
		
	local rotationAngle = 0.0;

	local target = AI.GetAttentionTargetEntity( entity.id );
	if ( target and AI.Hostile( entity.id, target.id ) ) then

		CopyVector( myPos, entity:GetPos() );

		SubVectors( vDirToTarget, target:GetPos(), entity:GetPos() );
		vDirToTarget.z = 0.0;
		NormalizeVector( vDirToTarget );

		local XAxis2d = {};
		local YAxis2d = {};

		CopyVector( XAxis2d, entity:GetDirectionVector(XAxis) );
		XAxis2d.z =0;
		NormalizeVector( XAxis2d );
		
		CopyVector( YAxis2d, entity:GetDirectionVector(YAxis) );
		YAxis2d.z =0;
		NormalizeVector( YAxis2d );

		local t = dotproduct3d( vDirToTarget, XAxis2d ); -- t>0 when the target is in the right side.
		local s = dotproduct3d( vDirToTarget, YAxis2d ); -- s>0 when the target is in the front side.

		-- depending on a quadrant.

		if ( t < 0.0 ) then
			rotationAngle = 30.0 * 3.1416 / 180.0;
		else
			rotationAngle = -30.0 * 3.1416 / 180.0;
		end

		local vUp = { x=0, y=0, z=1.0 };

		FastScaleVector( vDestination, YAxis2d, 20.0 );
		RotateVectorAroundR( vDestinationRot, vDestination, vUp, rotationAngle );

		FastSumVectors( vDestinationRot, vDestinationRot, entity:GetPos() );
		vDestinationRot.z = myPos.z;

		CopyVector( vPos, vDestinationRot );

	end

end


--------------------------------------------------------------------------
local function tankSetMindType( entity )

	-- when the tank first see the target
	-- mindType is decided like below

	-- 1: If he is behaind of the target     -> he just fire.
	-- 2: If the target is closer	than 100m  -> he will attack hard.
	-- 3: If the target is far than 100m     -> he will keep a distance to the targets.
	-- 4: player's side                      -> 

	if ( entity.AI.mindType == 0 ) then

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			if ( AI.GetSpeciesOf(entity.id) == 0 ) then
				entity.AI.mindType = 4;
				return;
			end

			local vDir = {};
			SubVectors( vDir, entity:GetPos(), target:GetPos() );
			local length = LengthVector( vDir );
			NormalizeVector( vDir );

			local vTargetFwd = {};
			tankGetTargetFowardDirection( entity, vTargetFwd );
			
			local t = dotproduct3d( vDir, vTargetFwd );
			if ( t < 0 ) then
				entity.AI.mindType = 1;
			end
			if ( length < 100.0 ) then
				entity.AI.mindType = 2;
			else
				entity.AI.mindType = 3;
			end

		end
	end

end


--------------------------------------------------------------------------
local function tankExpandFormation( entity )

	-- keep a distance anyway

	local target = AI.GetAttentionTargetEntity( entity.id );
	if ( target and AI.Hostile( entity.id, target.id ) ) then

		local vDir = {};
		local vMyPos = {};
		
		CopyVector( vDir, target:GetPos() );
		CopyVector( vMyPos, entity:GetPos() );
		
		vDir.z = vMyPos.z;
	
		SubVectors( vDir, vDir, vMyPos );
		local length = LengthVector( vDir );
		NormalizeVector( vDir );

		if ( length < 30.0 ) then
			FastScaleVector( vDir, vDir, -30.0 );
			FastSumVectors( vDir, vDir, entity:GetPos() );
			local result = tankFindAnchorNearBy( entity, vDir );
			if ( result == false ) then
				return false;
			end
			pipename = "tankExpandFormation";
			tankMakeApproachPipe( entity, vDir, pipename, 5.0, true )
			entity.AI.bShootNexttime = true;
			entity.fireCounter = 0;
			return true;

		end
	end
	return false;
	
end
--------------------------------------------------------------------------
local function tankMindTypeAAA( entity )

	-- keep a distance anyway

	local target = AI.GetAttentionTargetEntity( entity.id );
	if ( target and AI.Hostile( entity.id, target.id ) ) then

		local vDir = {};
		local vMyPos = {};
		
		CopyVector( vDir, target:GetPos() );
		CopyVector( vMyPos, entity:GetPos() );
		
		vDir.z = vMyPos.z;
	
		SubVectors( vDir, vDir, vMyPos );
		local length = LengthVector( vDir );
		NormalizeVector( vDir );

		if ( length < 80.0 ) then
			FastScaleVector( vDir, vDir, -30.0 );
			FastSumVectors( vDir, vDir, entity:GetPos() );
			local result = tankFindAnchorNearBy( entity, vDir );
			if ( result == false ) then
				entity.AI.tr =0;
				tankGoBack( entity );
				return true;
			end
			pipename = "tankMindAAA_1";
			tankMakeApproachPipe( entity, vDir, pipename, 10.0, false )
			entity.AI.bShootNexttime = true;
			entity.fireCounter = 0;
			return true;
		else


			local vWing ={};
				
			CopyVector( vWing, entity:GetDirectionVector(XAxis));

			local pat = random( 1,2 );
			if ( pat == 1 ) then
				FastScaleVector( vWing, vWing, -50.0 );
			else
				FastScaleVector( vWing, vWing, 50.0 );
			end


			FastSumVectors( vWing, vWing, entity:GetPos() );
			local result = tankFindAnchorNearBy( entity, vWing );
			if ( result == true ) then
				pipename = "tankMindAAA_B";
				tankMakeApproachPipe( entity, vWing, pipename, 10.0, false  )
				return true;
			end
		
			if ( entity.AI.tr == 0 ) then
				entity.AI.bShootNexttime = true;
				entity.fireCounter = 0;
				entity.AI.tr =1;
				AI.CreateGoalPipe("aaa_aggrasive_shoot_aaa");
				AI.PushGoal("aaa_aggrasive_shoot_aaa","timeout",1,0.5);
				AI.PushGoal("aaa_aggrasive_shoot_aaa","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
				AI.PushGoal("aaa_aggrasive_shoot_aaa","timeout",1,0.5);
				AI.PushGoal("aaa_aggrasive_shoot_aaa","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
				AI.PushGoal("aaa_aggrasive_shoot_aaa","timeout",1,0.5);
				AI.PushGoal("aaa_aggrasive_shoot_aaa","signal",0,1,"TANK_MOVE_START",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"aaa_aggrasive_shoot_aaa");
				return true;

			else

				entity.AI.tr =0;
				tankGoBack( entity );
				return true;

			end
		
		end

	else
		return false;
	end
	
end

--------------------------------------------------------------------------
-- the tank behind of the target

local function tankMindType1( entity )

	if ( tankRunDownThePlayer( entity ) == true ) then
		return true;	
	end

	local target = AI.GetAttentionTargetEntity( entity.id );
	if ( target and AI.Hostile( entity.id, target.id ) ) then

		local vDir = {};
		SubVector( vDir, entity:GetPos(), target:GetPos() );
		local length = LengthVector( vDir );
		NormalizeVector( vDir );
		
		local vTargetFwd = {};
		tankGetTargetFowardDirection( entity, vTargetFwd );
		
		local t = dotproduct3d( vDir, vTargetFwd );
		local inFOV = math.cos( 60.0 * 3.1415 / 180.0 );

		if ( t < inFOV ) then
			-- when it is not a good position any more.
			-- reset and reload.
			entity.AI.mindType = 0;
			tankSetMindType( entity );
			return false;
		end
		
		AI.CreateGoalPipe("tank_behind_shoot");
		AI.PushGoal("tank_behind_shoot","timeout",1,0.5);
		AI.PushGoal("tank_behind_shoot","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
		AI.PushGoal("tank_behind_shoot","timeout",1,0.5);
		AI.PushGoal("tank_behind_shoot","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
		AI.PushGoal("tank_behind_shoot","timeout",1,0.5);
		AI.PushGoal("tank_behind_shoot","signal",0,1,"TANK_MOVE_START",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"tank_behind_shoot");

		return true;
			
	else

		return false;	

	end

end

--------------------------------------------------------------------------
-- the ace tank

local function tankMindType2( entity )

	if ( tankRunDownThePlayer( entity ) == true ) then
		return true;	
	end

	local target = AI.GetAttentionTargetEntity( entity.id );
	if ( target and AI.Hostile( entity.id, target.id ) ) then

		AI.Signal(SIGNALFILTER_ANYONEINCOMM, 1, "TANK_PROTECT_ME", entity.id);

		local length = entity:GetDistance( target.id );
		if ( length < 80.0 ) then

			if ( tankFovCheck( target, entity:GetPos() ) == true ) then

				local vUp = { x=0.0, y=0.0, z=1.0 };
				local vWing ={};
				local vDirToTarget = {};

				SubVectors( vDirToTarget, target:GetPos(), entity:GetPos() );
				NormalizeVector( vDirToTarget );
				
				crossproduct3d( vWing, vDirToTarget, vUp )

				local pat = random( 1,2 );
				if ( pat == 1 ) then
					FastScaleVector( vWing, vWing, -50.0 );
				else
					FastScaleVector( vWing, vWing, 50.0 );
				end

				FastSumVectors( vWing, vWing, entity:GetPos() );
				local result = tankFindAnchorNearBy( entity, vWing );
				if ( result == false ) then
					return false;
				end
				pipename = "tankMindType2_R";
				tankMakeApproachPipe( entity, vWing, pipename, 10.0, false  )

				entity.AI.bShootNexttime = true;
				entity.fireCounter = 0;

				return true;

			else

				if ( entity.AI.tr == 0 ) then
					entity.AI.tr =1;
					AI.CreateGoalPipe("tank_aggrasive_shoot");
					AI.PushGoal("tank_aggrasive_shoot","timeout",1,0.5);
					AI.PushGoal("tank_aggrasive_shoot","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
					AI.PushGoal("tank_aggrasive_shoot","timeout",1,0.5);
					AI.PushGoal("tank_aggrasive_shoot","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
					AI.PushGoal("tank_aggrasive_shoot","timeout",1,0.5);
					AI.PushGoal("tank_aggrasive_shoot","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
					AI.PushGoal("tank_aggrasive_shoot","timeout",1,0.5);
					AI.PushGoal("tank_aggrasive_shoot","signal",0,1,"TANK_MOVE_START",SIGNALFILTER_SENDER);
					entity:SelectPipe(0,"tank_aggrasive_shoot");
					return true;

				else
					entity.AI.tr =0;
					tankGoBack( entity );
					return true;

				end

			end

		end

		local vMid = {};
		SubVectors( vMid, target:GetPos(), entity:GetPos() );
		FastScaleVector( vMid, vMid, 0.8 );
		FastSumVectors( vMid, vMid, entity:GetPos() );

		if ( tankFovCheck( entity, vMid ) == true ) then
			local result = tankFindAnchorNearBy( entity, vMid );
			if ( result == false ) then
				return false;	
			end
			pipename = "tankMindType2";
			tankMakeApproachPipe( entity, vMid, pipename, 10.0, false  );
		else
			tankGetInFov( entity ,vMid );
			local result = tankFindAnchorNearBy( entity, vMid );
			if ( result == false ) then
				return false;	
			end
			pipename = "tankMindType2_G";
			tankMakeApproachPipe( entity, vMid, pipename, 5.0, false  );
		end

		return true;
	
	else

		return false;	

	end

end

--------------------------------------------------------------------------
-- guard for the ace

local function tankMindType3( entity )

	if ( tankRunDownThePlayer( entity ) == true ) then
		return true;	
	end

	local target = AI.GetAttentionTargetEntity( entity.id );
	if ( target and AI.Hostile( entity.id, target.id ) ) then

		local bReselect = false;
		if ( entity.AI.protect ~= nil ) then

			local targetType = AI.GetAttentionTargetType(entity.AI.protect);
		
			if ( targetType ~= AIOBJECT_NONE and targetType ~= AIOBJECT_DUMMY ) then
				target2 = AI.GetAttentionTargetEntity( entity.AI.protect );
				if ( target2 and AI.Hostile( entity.id, target2.id ) ) then
					target = target2;
				end
			else
				bReselect = true;
			end
		else
			bReselect = true;
		end

		if ( bReselect == true ) then
			AI.LogEvent( entity:GetName().." attempted to switch protecter");

			AI.Signal(SIGNALFILTER_ANYONEINCOMM, 1, "TANK_PROTECT_ME", entity.id);
			AI.CreateGoalPipe("tank_wait");
			AI.PushGoal("tank_wait","timeout",1,0.5);
			AI.PushGoal("tank_wait","signal",0,1,"TANK_MOVE_START",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"tank_wait");			
			return false;

		end

		local vUp = { x=0, y=0, z=1.0 };
		local vFwd = { x=0, y=90.0, z=0.0 };
		local vDestination = {};
		local vIdealPos = {};
		local vTmp ={};
		local vRot ={};
		local idealdistance = 100000.0;
		local length;
		local bFound = false;
		local j;
		local i;
	
		for i = 1,7 do

			RotateVectorAroundR( vRot, vFwd, vUp, 3.1416 * 2.0 * i / 8.0);
			FastSumVectors( vDestination, vRot, target:GetPos() );

			SubVectors( vTmp, vDestination, entity:GetPos() );
			length = LengthVector( vTmp );

			if ( length < idealdistance ) then

				bFound = false;

				local entities = System.GetPhysicalEntitiesInBox( vDestination, 20.0 );
				local targetEntity;

				if (entities) then
					for j,targetEntity in ipairs(entities) do
						local objEntity = targetEntity;
						-- AI.LogEvent(entity:GetName().." found entity "..objEntity:GetName());
						if ( objEntity.id == entity.id or objEntity:GetMass() < 200.0 ) then
						else
							bFound = true;
						end
					end
				end

				if ( bFound == false ) then
					FastScaleVector( vTmp, vRot, 1.2 ); 
					FastSumVectors( vTmp, vTmp, target:GetPos() );
					--AI.LogEvent(entity:GetName().." region "..vTmp.x..","..vTmp.y..","..vTmp.z );
					local vTmp2 = AI.IntersectsForbidden( vTmp, target:GetPos());
					if ( DistanceVectors( vTmp2, target:GetPos() ) < 1.0 ) then
						idealdistance = length;
						CopyVector( vIdealPos, vDestination );
					end
				end
			end

		end
		
		if ( idealdistance > 1000.0 ) then

			if ( entity.AI.tr == 0 ) then
				entity.AI.tr =1;
				AI.CreateGoalPipe("tank_point_not_found");
				AI.PushGoal("tank_point_not_found","timeout",1,0.5);
				AI.PushGoal("tank_point_not_found","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
				AI.PushGoal("tank_point_not_found","timeout",1,0.5);
				AI.PushGoal("tank_point_not_found","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
				AI.PushGoal("tank_point_not_found","timeout",1,0.5);
				AI.PushGoal("tank_point_not_found","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
				AI.PushGoal("tank_point_not_found","timeout",1,0.5);
				AI.PushGoal("tank_point_not_found","signal",0,1,"TANK_MOVE_START",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"tank_point_not_found");
				return true;
			else
				entity.AI.tr =0;
				tankGoBack( entity );
				return true;
			end

		end

		local result = tankFindAnchorNearBy( entity, vIdealPos );
		if ( result == false ) then
			return false;
		end
		SubVectors( vTmp, vIdealPos, entity:GetPos() );
		if ( LengthVector( vTmp ) < 20.0 ) then

			if ( entity.AI.tr == 0 ) then
				entity.AI.tr = 1;
				entity.AI.bShootNexttime = true;
				entity.fireCounter = 0;
				AI.CreateGoalPipe("tank_protect_shoot2");
				AI.PushGoal("tank_protect_shoot2","timeout",1,0.5);
				AI.PushGoal("tank_protect_shoot2","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
				AI.PushGoal("tank_protect_shoot2","timeout",1,0.5);
				AI.PushGoal("tank_protect_shoot2","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
				AI.PushGoal("tank_protect_shoot2","timeout",1,0.5);
				AI.PushGoal("tank_protect_shoot2","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
				AI.PushGoal("tank_protect_shoot2","timeout",1,0.5);
				AI.PushGoal("tank_protect_shoot2","signal",0,1,"TANK_MOVE_START",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"tank_protect_shoot2");
				return true;
			else
				entity.AI.tr = 0;
				tankGoBack( entity );
				return true;
			end

		else
			pipename = "tankMindType3";
			tankMakeApproachPipe( entity, vIdealPos, pipename, 10.0, false  )
			return true;
		end
	
	else

		return false;	

	end

end

--------------------------------------------------------------------------
-- team member of the player

local function tankMindType4( entity )

	local target = AI.GetAttentionTargetEntity( entity.id );
	if ( target and AI.Hostile( entity.id, target.id ) ) then

		-- if the player rides on the vehicle, tank stops following him
		if ( AI.GetTypeOf( g_localActor.id ) == AIOBJECT_PLAYER ) then
			local vehicleId = g_localActor.actor:GetLinkedVehicleId();
			if ( vehicleId ) then
			else
				entity.AI.mindType = 3;
				return false;
			end
		end

		local playerPos = {};
		CopyVector( playerPos ,g_localActor:GetPos() );

		local vDir = {};
	
		SubVectors( vDir, playerPos, entity:GetPos() );
		local distance = LengthVector( vDir );

		if (distance > 50.0 ) then

			local result = tankFindAnchorNearBy( entity, playerPos );
			if ( result == false ) then
				return false;
			end
			pipename = "tankMindType4";
			tankMakeApproachPipe( entity, playerPos, pipename, 46.0, false  )
			return true;
	
		else

			local pat = random( 1, 2 );
	
			if ( entity.AI.tr == 0 ) then
				entity.AI.tr = 1;

				if ( DistanceVectors( entity:GetPos(), entity.AI.vDefultPos ) >10.0 ) then
					return false;
				else

					local vAlign = {};
	
					CopyVector( vAlign, g_localActor:GetDirectionVector(YAxis) );
					NormalizeVector( vAlign );
					
					local t = dotproduct3d( entity:GetDirectionVector(YAxis), vAlign );
					local inFOV = math.cos( 120.0 * 3.1415 / 180.0 );

					if ( t < inFOV ) then

						FastScaleVector( vAlign, vAlign, 5.0 );
						FastSumVectors( vAlign, vAlign, entity:GetPos() );
						AI.SetRefPointPosition( entity.id ,vAlign );

						SubVectors( vAlign, vAlign, entity:GetPos() );
						NormalizeVector( vAlign );

						AI.CreateGoalPipe("tank_align");
						if ( dotproduct3d( vAlign, entity:GetDirectionVector(1) ) > inFOV ) then
							AI.PushGoal("tank_align","run",0,1);	
						else
							AI.PushGoal("tank_align","run",0,-2);	
						end
						AI.PushGoal("tank_align","continuous",0,1);	
						AI.PushGoal("tank_align","+locate",0,"refpoint");
						AI.PushGoal("tank_align","+approach",0,3.0,AILASTOPRES_USE,0.0);	
						AI.PushGoal("tank_align","signal",0,1,"TANK_MOVE_CHECK_FIRE",SIGNALFILTER_SENDER);
						AI.PushGoal("tank_align","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
						AI.PushGoal("tank_align","timeout",1,0.5);
						AI.PushGoal("tank_align","signal",0,1,"TANK_MOVE_CHECK_FIRE",SIGNALFILTER_SENDER);
						AI.PushGoal("tank_align","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
						AI.PushGoal("tank_align","timeout",1,0.5);
						AI.PushGoal("tank_align","signal",0,1,"TANK_MOVE_CHECK_FIRE_END",SIGNALFILTER_SENDER);
						entity:SelectPipe(0,"tank_align");
						return true;
					
					else

						entity.AI.bShootNexttime = true;
						entity.fireCounter = 0;

						AI.CreateGoalPipe("tank_protect_shoot4");
						AI.PushGoal("tank_protect_shoot4","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
						AI.PushGoal("tank_protect_shoot4","timeout",1,0.5);
						AI.PushGoal("tank_protect_shoot4","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
						AI.PushGoal("tank_protect_shoot4","timeout",1,0.5);
						AI.PushGoal("tank_protect_shoot4","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
						AI.PushGoal("tank_protect_shoot4","timeout",1,0.5);
						AI.PushGoal("tank_protect_shoot4","signal",0,1,"TANK_MOVE_START",SIGNALFILTER_SENDER);
						entity:SelectPipe(0,"tank_protect_shoot4");
						return true;
					
					end

				end

		else

				entity.AI.tr = 0;
				entity.AI.bShootNexttime = true;
				entity.fireCounter = 0;

				AI.CreateGoalPipe("tank_protect_shoot3");
				AI.PushGoal("tank_protect_shoot3","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
				AI.PushGoal("tank_protect_shoot3","timeout",1,0.5);
				AI.PushGoal("tank_protect_shoot3","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
				AI.PushGoal("tank_protect_shoot3","timeout",1,0.5);
				AI.PushGoal("tank_protect_shoot3","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
				AI.PushGoal("tank_protect_shoot3","timeout",1,0.5);
				AI.PushGoal("tank_protect_shoot3","signal",0,1,"TANK_MOVE_START",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"tank_protect_shoot3");
				return true;

			end
		end

	else
		return false;
	end

end


--------------------------------------------------------------------------
AIBehaviour.TankMove = {
	Name = "TankMove",
	alertness = 2,

	-- SYSTEM EVENTS			-----
	---------------------------------------------
	Constructor = function( self, entity )

		entity.AI.vRefPositionRsv = {};
		CopyVector( entity.AI.vRefPositionRsv, entity:GetPos() );

		entity.AI.tr =0;
		entity.AI.bBlockSignal = false;
		entity.AI.stopCount = 0;
		entity.AI.fireCounter =0;
		entity.AI.noTargetCount =0;
		entity.AI.bFirst =true;

		entity.AI.shootCounter = 0;				-- how many times the tank fired during approach
		entity.AI.bNoTarget = false;   		-- the tank has a target or not.    

		entity.AI.bUseMachineGun = false;	-- the target is aimed by the Machine gun or not.

		entity.AI.bShootNexttime = false;

		AI.CreateGoalPipe("tankMoveDefault");
		AI.PushGoal("tankMoveDefault","timeout",1,0.3);
		AI.PushGoal("tankMoveDefault","signal",0,1,"TANK_MOVE_DEFAULT",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"tankMoveDefault");

		entity.AI.mindType = 0;
		entity.AI.vLastPosition = {};
		entity.AI.vDefultPos = {};
		entity.AI.vLastTargetPos = {};

		CopyVector( entity.AI.vLastPosition , entity:GetPos() );
		CopyVector( entity.AI.vDefultPos, entity:GetPos() );
		CopyVector( entity.AI.vLastTargetPos, entity:GetPos() );

		AIBehaviour.TANKDEFAULT:selectCannonForTheDriver( entity, true );

	end,

	---------------------------------------------
	Destructor = function ( self, entity, data )

		-- called when the behaviour is de-selected
		-- the extra data is from the signal that is causing the behavior transition
		entity:SelectPipe(0,"do_nothing");
		entity:InsertSubpipe(0, "clear_all");

	end,

	--------------------------------------------------------------------------
	OnNoTarget = function( self, entity )
		-- called when the AI stops having an attention target
	end,
	---------------------------------------------
	OnSomethingSeen = function( self, entity )
		-- called when the enemy sees a foe which is not a living player
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		-- called when the AI sees a living enemy
	end,
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the AI can no longer see its enemy, but remembers where it saw it last
	end,
	---------------------------------------------
	OnObjectSeen = function( self, entity, fDistance, data )
		-- called when the AI sees an object registered for this kind of signal
		-- data.iValue = AI object type
		-- example
		-- if (data.iValue == 150) then -- grenade
		--	 ...

		if ( data.iValue == AIOBJECT_RPG and entity.AI.bBlockSignal ~= true ) then

			local targetName = AI.GetAttentionTargetOf(entity.id);
			if (targetName) then

				local U ={};
				local V ={};
				
				AI.GetAttentionTargetPosition( entity.id, U );
				AI.GetAttentionTargetDirection( entity.id, V );
				
				local distance = DistanceLineAndPoint( entity:GetPos(), V, U );
				--AI.LogEvent("HOGEHOGE A "..distance);
				if ( distance < 30.0 ) then
					local UU = {};
					SubVectors( UU, entity:GetPos(), U );
					NormalizeVector( UU );
					local inner = dotproduct3d( UU, V );

					--AI.LogEvent("HOGEHOGE B "..inner);
					if ( inner > 0 ) then
			
						entity.AI.bBlockSignal = true;

						local vUp = { x=0.0, y=0.0, z=1.0 };
						local vWing ={};
						local vDirToTarget = {};	

						SubVectors( vDirToTarget, U, entity:GetPos() );
						NormalizeVector( vDirToTarget );
				
						crossproduct3d( vWing, vDirToTarget, vUp )
						local inner2 = dotproduct3d( vWing, vDirToTarget );
						if ( inner2 > 0 ) then
							FastScaleVector( vWing, vWing, -10.0 );
						else
							FastScaleVector( vWing, vWing, 10.0 );
						end

						FastSumVectors( vWing, vWing, entity:GetPos() );
		
						AI.SetRefPointPosition( entity.id , vTmp );

						AI.CreateGoalPipe("tank_evade_rockets");
						AI.PushGoal("tank_evade_rockets","+run",0,1);	
						AI.PushGoal("tank_evade_rockets","+continuous",0,1);	
						AI.PushGoal("tank_evade_rockets","+locate",0,"refpoint");
						AI.PushGoal("tank_evade_rockets","+approach",0,3.0,AILASTOPRES_USE);	
						AI.PushGoal("tank_evade_rockets","signal",0,1,"TANK_MOVE_CHECK_FIRE",SIGNALFILTER_SENDER);
						AI.PushGoal("tank_evade_rockets","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
						AI.PushGoal("tank_evade_rockets","timeout",1,0.5);
						AI.PushGoal("tank_evade_rockets","signal",0,1,"TANK_MOVE_CHECK_FIRE_END",SIGNALFILTER_SENDER);
						entity:SelectPipe(0,"tank_evade_rockets");

					end
				end
			end
		end

		if ( data.iValue == AIOBJECT_RPG) then
			entity:InsertSubpipe(0,"devalue_target");
		end

	end,
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		-- called when the AI hears an interesting sound
	end,
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
		-- called when the AI hears a threatening sound
	end,

	--------------------------------------------------------------------------
	OnBulletRain = function ( self, entity, sender, data )	

		self:OnEnemyDamage( entity, sender, data );
		
	end,

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender, data )

			local ratioEngine = entity.vehicle:GetComponentDamageRatio("engine");
			if ( ratioEngine == nil ) then
				ratioEngine = 0;
			end
			local ratioTurret = entity.vehicle:GetComponentDamageRatio("turret");
			if ( ratioTurret == nil ) then
				ratioTurret = 0;
			end

			if ( ratioEngine>0.9 or ratioTurret>0.9 ) then
				AI.Signal(SIGNALFILTER_SENDER, 1, "TO_TANK_EMERGENCYEXIT", entity.id);
				return;
			end

	
		-- called when AI is damaged by an enemy AI
		-- data.id = damaging enemy's entity id
		-- local hitter = System.GetEntity(data.id);
		-- local hitterName = hitter:GetName()

		local hitter = System.GetEntity(data.id);
		local bIsPlayer;
		if ( hitter ) then
			bIsPlayer = tankCheckPlayerVehicle( hitter );
		end

		if ( data.id and AI.Hostile( entity.id, data.id ) ) then
		else
			return;
		end

		if ( entity.AI.bBlockSignal == true ) then
			return;
		end

--		entity:InsertSubpipe(0,"devalue_target");

		entity.AI.bUseMachineGun = AIBehaviour.TANKDEFAULT:tankDoesUseMachineGun( entity );

		if ( entity.AI.bUseMachineGun == true ) then
			if ( random(1,2) == 1 ) then
				request2ndGunnerShoot( entity );
			end
		else
			-- called when there are bullet impacts nearby
				entity.AI.bBlockSignal = true;
				entity.AI.bShootNexttime = true;
				entity.fireCounter = 0;

			--[[
			local pat = random(1,4);
			if ( pat == 1 ) then
				entity.AI.bBlockSignal = true;
				entity.AI.bShootNexttime = true;
				entity.fireCounter = 0;
			else
				if ( bIsPlayer == true and pat > 2 ) then
				
					entity.AI.fireCounter = 0;

					AI.SetRefPointPosition( entity.id , hitter:GetPos() );

					AI.CreateGoalPipe("tank_lookatplayer");
					AI.PushGoal("tank_lookatplayer","run",0,1);	
					AI.PushGoal("tank_lookatplayer","continuous",0,1);	
					AI.PushGoal("tank_lookatplayer","+locate",0,"refpoint");
					AI.PushGoal("tank_lookatplayer","+approach",0,3.0,AILASTOPRES_USE,10.0);	
					AI.PushGoal("tank_lookatplayer","signal",0,1,"TANK_MOVE_CHECK_FIRE",SIGNALFILTER_SENDER);
					AI.PushGoal("tank_lookatplayer","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
					AI.PushGoal("tank_lookatplayer","timeout",1,0.3);
					AI.PushGoal("tank_lookatplayer","signal",0,1,"TANK_MOVE_CHECK_FIRE",SIGNALFILTER_SENDER);
					AI.PushGoal("tank_lookatplayer","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
					AI.PushGoal("tank_lookatplayer","timeout",1,0.3);
					AI.PushGoal("tank_lookatplayer","signal",0,1,"TANK_MOVE_CHECK_FIRE_END",SIGNALFILTER_SENDER);
					entity:SelectPipe(0,"tank_lookatplayer");
			
				end
			end
			--]]

		end

	end,

	---------------------------------------------
	OnDamage = function ( self, entity, sender, data )
	end,

	---------------------------------------------
	-- CUSTOM
	---------------------------------------------

	--------------------------------------------
	DRIVER_IN = function( self,entity, sender )
	end,	
	
	---------------------------------------------
--	DRIVER_OUT = function( self,entity,sender )
--	end,	

	---------------------------------------------
	on_spot = function( self,entity,sender )
	end,	

	--------------------------------------------------------------------------
	VEHICLE_DESTROYED = function( self, entity, sender )
		AI.LogEvent(entity:GetName().." gets VEHICLE_DESTROYED" );
		if (entity.AI.mindType == 3 ) then
			entity.AI.mindType = 2;
		end
	end,

	--------------------------------------------
	TANK_MOVE_DEFAULT = function( self, entity )

		-- set mind type

		tankSetMindType( entity );

		-- for the first action

		entity.AI.bUseMachineGun = AIBehaviour.TANKDEFAULT:tankDoesUseMachineGun( entity );

		local vDifference ={}
		local obstacles = checkFriendInWay( entity, vDifference );

		if ( obstacles == 0 ) then

			if ( entity.AI.bUseMachineGun == true ) then

				request2ndGunnerShoot( entity );
				AI.Signal(SIGNALFILTER_SENDER, 1, "TANK_MOVE_START", entity.id);
				return;

			else

				FastScaleVector( vDifference, vDifference, 3.0 );
				local destination = {};
				FastSumVectors( destination, entity:GetPos(), vDifference );
				AI.SetRefPointPosition( entity.id , destination );

				AI.CreateGoalPipe("tank_move_first");
				AI.PushGoal("tank_move_first","run",0,0);
				AI.PushGoal("tank_move_first","locate",0,"refpoint");
				AI.PushGoal("tank_move_first","approach",0,3.0,AILASTOPRES_USE,5.0);
				AI.PushGoal("tank_move_first","signal",0,1,"TANK_MOVE_CHECK_FIRE2",SIGNALFILTER_SENDER);
				AI.PushGoal("tank_move_first","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
				AI.PushGoal("tank_move_first","timeout",1,0.5);
				AI.PushGoal("tank_move_first","branch",1,-3);
				AI.PushGoal("tank_move_first","signal",0,1,"TANK_MOVE_START",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"tank_move_first");

			end

		else

			AI.Signal(SIGNALFILTER_SENDER, 1, "TANK_MOVE_START", entity.id);
			return;

		end

	end,
	--------------------------------------------
	TANK_MOVE_START = function( self, entity )

		entity.AI.bBlockSignal = false;
		entity.AI.bUseMachineGun = AIBehaviour.TANKDEFAULT:tankDoesUseMachineGun( entity );
		if ( entity.AI.bUseMachineGun == true ) then
			if ( random(1,2) == 1 ) then
				request2ndGunnerShoot( entity );
			end
		end

		local bResult = false;
		entity:SelectPipe(0,"do_nothing");

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then
			entity.AI.noTargetCount = 0;
			CopyVector( entity.AI.vLastTargetPos, target:GetPos() );
		else
			entity.AI.noTargetCount = entity.AI.noTargetCount + 1;
			if ( entity.AI.noTargetCount == 1 ) then
				AI.CreateGoalPipe("tank_notarget");
				AI.PushGoal("tank_notarget","timeout",1,1.5);
				AI.PushGoal("tank_notarget","firecmd",1,0);
				AI.PushGoal("tank_notarget","signal",0,1,"TANK_MOVE_START",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"tank_notarget");
			elseif ( entity.AI.noTargetCount == 2 ) then
				pipename = "tankSeekTarget";
				tankMakeApproachPipe( entity, entity.AI.vLastTargetPos, pipename, 12.0, false  )
			else
				AI.Signal(SIGNALFILTER_SENDER, 1, "TO_TANK_ALERT2", entity.id);
			end
			return;

		end
		

		if ( AI.GetTypeOf( target.id ) == AIOBJECT_PUPPET and target.actor and random(1,3)==1 ) then
			local vehicleId = target.actor:GetLinkedVehicleId();
			if ( vehicleId ) then
			else
				entity.AI.bFirst	= false;
			end
		end

		if ( entity.AI.bFirst	== true and entity.AI.isAPC~=nil and entity.AI.isAPC == true) then

			entity.AI.bFirst = false;
			bResult = tankExpandFormation( entity );
			if ( bResult == false ) then
				AI.Signal(SIGNALFILTER_SENDER, 1, "TANK_MOVE_START", entity.id);
				return;
			end

		elseif ( entity.AI.isAAA~=nil and entity.AI.isAAA == true ) then
		
			bResult = tankMindTypeAAA( entity );
		
		elseif ( entity.AI.mindType == 0 ) then
		
			AI.CreateGoalPipe("tank_error");
			AI.PushGoal("tank_error","timeout",1,0.5);
			AI.PushGoal("tank_error","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
			AI.PushGoal("tank_error","timeout",1,0.5);
			AI.PushGoal("tank_error","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
			AI.PushGoal("tank_error","timeout",1,0.5);
			AI.PushGoal("tank_error","signal",0,1,"TANK_MOVE_START",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"tank_error");
		
		elseif (  entity.AI.mindType == 1 ) then

			bResult = tankMindType1( entity );
		
		elseif (  entity.AI.mindType == 2 ) then

			bResult = tankMindType2( entity );
		
		elseif (  entity.AI.mindType == 3 ) then

			bResult = tankMindType3( entity );

		elseif (  entity.AI.mindType == 4 ) then
		
			bResult = tankMindType4( entity );

		else
		
		end

		if ( bResult == false ) then

			local target = AI.GetAttentionTargetEntity( entity.id );
			if ( target and AI.Hostile( entity.id, target.id ) ) then
				local vTmp = {};
				SubVectors( vTmp,	target:GetPos(), entity:GetPos() );
				local destance = LengthVector( vTmp );
				if ( destance > 80.0 ) then
					NormalizeVector( vTmp );
					FastScaleVector( vTmp, vTmp, 15.0 );
					FastSumVectors( vTmp, vTmp, entity:GetPos() );
					pipename = "tankJustApproachTheTarget";
					tankMakeApproachPipe( entity, vTmp, pipename, 10.0, false  );
					return;
				else
					if ( entity.AI.tr == 0 ) then
						entity.AI.tr =1;
						AI.CreateGoalPipe("tank_aggrasive_shoot");
						AI.PushGoal("tank_aggrasive_shoot","timeout",1,0.5);
						AI.PushGoal("tank_aggrasive_shoot","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
						AI.PushGoal("tank_aggrasive_shoot","timeout",1,0.5);
						AI.PushGoal("tank_aggrasive_shoot","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
						AI.PushGoal("tank_aggrasive_shoot","timeout",1,0.5);
						AI.PushGoal("tank_aggrasive_shoot","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
						AI.PushGoal("tank_aggrasive_shoot","timeout",1,0.5);
						AI.PushGoal("tank_aggrasive_shoot","signal",0,1,"TANK_MOVE_START",SIGNALFILTER_SENDER);
						entity:SelectPipe(0,"tank_aggrasive_shoot");
						return;
	
					else
						entity.AI.tr =0;
						tankGoBack( entity );
						return;
					end
				end
			end
			
			entity.AI.fireCounter = 0;
			
			local vTmp = {};
			SubVectors( vTmp,	entity:GetPos() , entity.AI.vDefultPos );
			NormalizeVector( vTmp );
			FastScaleVector( vTmp, vTmp, 30.0 );
			FastSumVectors( vTmp, vTmp, entity.AI.vDefultPos );
			
			pipename = "tank_retreat";
			tankMakeApproachPipe( entity, vTmp, pipename, 10.0, false  )

		end

	end,

	---------------------------------------------
	TANK_MOVE_CHECK_FIRE = function( self, entity )

		local vDifference = {};
		local destination = {};
		local obstacles = checkFriendInWay( entity, vDifference );

		if ( obstacles == 0 ) then

			-- if there is no obstacle.

		elseif (obstacles == 1 ) then
		
				CopyVector( entity.AI.vLastPosition, entity:GetPos() );
		
				entity.AI.bBlockSignal = true;

				-- if there is still a obstacle, take an evading action.
				NormalizeVector( vDifference );
				local sw;
				if ( dotproduct3d( vDifference, entity:GetDirectionVector(YAxis) ) >0.0 ) then
					sw =1;
				else
					sw =-2;
				end

				FastScaleVector( vDifference, vDifference, 18.0 );
				vDifference.x = vDifference.x + random( -3,3 );
				vDifference.y = vDifference.y + random( -3,3 );
				local destination = {};
				FastSumVectors( destination, entity:GetPos(), vDifference );
				AI.SetRefPointPosition( entity.id, destination );

				AI.CreateGoalPipe("tank_move_avoid_deadlock");
				AI.PushGoal("tank_move_avoid_deadlock","run",0,sw);
				AI.PushGoal("tank_move_avoid_deadlock","+locate",0,"refpoint");
				AI.PushGoal("tank_move_avoid_deadlock","+approach",0,3.0,AILASTOPRES_USE,10.0);
				AI.PushGoal("tank_move_avoid_deadlock","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
				AI.PushGoal("tank_move_avoid_deadlock","timeout",1,0.5);
				AI.PushGoal("tank_move_avoid_deadlock","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
				AI.PushGoal("tank_move_avoid_deadlock","timeout",1,0.5);
				AI.PushGoal("tank_move_avoid_deadlock","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
				AI.PushGoal("tank_move_avoid_deadlock","timeout",1,0.5);
				AI.PushGoal("tank_move_avoid_deadlock","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
				AI.PushGoal("tank_move_avoid_deadlock","timeout",1,0.5);
				AI.PushGoal("tank_move_avoid_deadlock","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
				AI.PushGoal("tank_move_avoid_deadlock","timeout",1,0.5);
				AI.PushGoal("tank_move_avoid_deadlock","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
				AI.PushGoal("tank_move_avoid_deadlock","timeout",1,0.5);
				AI.PushGoal("tank_move_avoid_deadlock","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
				AI.PushGoal("tank_move_avoid_deadlock","timeout",1,0.5);
				AI.PushGoal("tank_move_avoid_deadlock","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
				AI.PushGoal("tank_move_avoid_deadlock","timeout",1,0.5);
				AI.PushGoal("tank_move_avoid_deadlock","signal",0,1,"TANK_MOVE_CHECK_FIRE_END",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"tank_move_avoid_deadlock");
		
		else

			-- wait until there is no obstacle.
			entity.AI.bBlockSignal = true;
			entity.AI.stopCount = 0;
			AI.CreateGoalPipe("tank_emergency_stop");
			AI.PushGoal("tank_emergency_stop","signal",1,1,"TANK_MOVE_CHECK_FIRE2",0);
			AI.PushGoal("tank_emergency_stop","timeout",1,0.5);
			AI.PushGoal("tank_emergency_stop","signal",1,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"tank_emergency_stop");

		end

	end,

	---------------------------------------------
	TANK_MOVE_CHECK_FIRE2 = function( self, entity )

		local vDifference = {};
		local destination = {};

		if ( checkFriendInWay( entity, vDifference ) == 0 ) then
		
			-- now can move again.
			AI.Signal(SIGNALFILTER_SENDER, 1, "TANK_MOVE_START", entity.id);
			return;

		else

			entity.AI.stopCount = entity.AI.stopCount + 1;

			if ( entity.AI.stopCount == 3 ) then

				CopyVector( entity.AI.vLastPosition, entity:GetPos() );

				entity.AI.bBlockSignal = true;

				-- if there is still a obstacle, take an evading action.
				NormalizeVector( vDifference );
				local sw;
				if ( dotproduct3d( vDifference, entity:GetDirectionVector(YAxis)) > 0.0 ) then
					sw =1;
				else
					sw =-2;
				end

				local destination = {};
				FastScaleVector( vDifference, vDifference, 25.0 );
				vDifference.x = vDifference.x + random( -3,3 );
				vDifference.y = vDifference.y + random( -3,3 );
				FastSumVectors( destination, entity:GetPos(), vDifference );
				AI.SetRefPointPosition( entity.id, destination );

				AI.CreateGoalPipe("tank_move_avoid_deadlock");
				AI.PushGoal("tank_move_avoid_deadlock","run",0,sw);
				AI.PushGoal("tank_move_avoid_deadlock","+locate",0,"refpoint");
				AI.PushGoal("tank_move_avoid_deadlock","+approach",0,3.0,AILASTOPRES_USE,10.0);
				AI.PushGoal("tank_move_avoid_deadlock","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
				AI.PushGoal("tank_move_avoid_deadlock","timeout",1,0.5);
				AI.PushGoal("tank_move_avoid_deadlock","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
				AI.PushGoal("tank_move_avoid_deadlock","timeout",1,0.5);
				AI.PushGoal("tank_move_avoid_deadlock","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
				AI.PushGoal("tank_move_avoid_deadlock","timeout",1,0.5);
				AI.PushGoal("tank_move_avoid_deadlock","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
				AI.PushGoal("tank_move_avoid_deadlock","timeout",1,0.5);
				AI.PushGoal("tank_move_avoid_deadlock","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
				AI.PushGoal("tank_move_avoid_deadlock","timeout",1,0.5);
				AI.PushGoal("tank_move_avoid_deadlock","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
				AI.PushGoal("tank_move_avoid_deadlock","timeout",1,0.5);
				AI.PushGoal("tank_move_avoid_deadlock","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
				AI.PushGoal("tank_move_avoid_deadlock","timeout",1,0.5);
				AI.PushGoal("tank_move_avoid_deadlock","signal",0,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
				AI.PushGoal("tank_move_avoid_deadlock","timeout",1,0.5);
				AI.PushGoal("tank_move_avoid_deadlock","signal",0,1,"TANK_MOVE_CHECK_FIRE_END",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"tank_move_avoid_deadlock");

			end

		end

	end,

	---------------------------------------------
	TANK_MOVE_CHECK_FIRE_END = function( self, entity )

		if ( DistanceVectors( entity.AI.vLastPosition, entity:GetPos() )< 1.0 ) then
			CopyVector( entity.AI.vLastPosition, entity:GetPos() );
			entity:SelectPipe(0,"do_nothing");
			
			local vTmp = {};
			local elevation =entity.AI.vLastPosition.z;
			local minval = 10000;
			local height;

			FastScaleVector( vTmp, entity:GetDirectionVector(YAxis), -5.0 );
			FastSumVectors( vTmp, vTmp, entity:GetPos() );
			height = System.GetTerrainElevation( vTmp );
			if ( math.abs(height - elevation) < minval ) then
				minval = math.abs(height - elevation);
				AI.SetRefPointPosition( entity.id, vTmp );
			end				

			FastScaleVector( vTmp, entity:GetDirectionVector(YAxis), 5.0 );
			FastSumVectors( vTmp, vTmp, entity:GetPos() );
			height = System.GetTerrainElevation( vTmp );
			if ( math.abs(height - elevation) < minval ) then
				minval = math.abs(height - elevation);
				AI.SetRefPointPosition( entity.id, vTmp );
			end				

			FastScaleVector( vTmp, entity:GetDirectionVector(XAxis), -5.0 );
			FastSumVectors( vTmp, vTmp, entity:GetPos() );
			height = System.GetTerrainElevation( vTmp );
			if ( math.abs(height - elevation) < minval ) then
				minval = math.abs(height - elevation);
				AI.SetRefPointPosition( entity.id, vTmp );
			end				

			FastScaleVector( vTmp, entity:GetDirectionVector(XAxis), 5.0 );
			FastSumVectors( vTmp, vTmp, entity:GetPos() );
			height = System.GetTerrainElevation( vTmp );
			if ( math.abs(height - elevation) < minval ) then
				minval = math.abs(height - elevation);
				AI.SetRefPointPosition( entity.id, vTmp );
			end				

			entity:SelectPipe(0,"do_nothing");
			AI.CreateGoalPipe("make_firbidden_here");
			AI.PushGoal("make_firbidden_here","run",0,-10.0);
			AI.PushGoal("make_firbidden_here","+locate",0,"refpoint");
			AI.PushGoal("make_firbidden_here","+approach",0,3.0,AILASTOPRES_USE,0.0);
			AI.PushGoal("make_firbidden_here","timeout",1,0.5);
			AI.PushGoal("make_firbidden_here","signal",1,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
			AI.PushGoal("make_firbidden_here","timeout",1,0.5);
			AI.PushGoal("make_firbidden_here","signal",1,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
			AI.PushGoal("make_firbidden_here","timeout",1,0.5);
			AI.PushGoal("make_firbidden_here","signal",1,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
			AI.PushGoal("make_firbidden_here","timeout",1,0.5);
			AI.PushGoal("make_firbidden_here","signal",1,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
			AI.PushGoal("make_firbidden_here","timeout",1,0.5);
			AI.PushGoal("make_firbidden_here","signal",1,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
			AI.PushGoal("make_firbidden_here","timeout",1,0.5);
			AI.PushGoal("make_firbidden_here","signal",1,1,"TANK_MOVE_CHECK_SHOOT",SIGNALFILTER_SENDER);
			AI.PushGoal("make_firbidden_here","signal",1,1,"TANK_MOVE_CHECK_FIRE_END",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"make_firbidden_here");
			return;

		end

		AI.Signal(SIGNALFILTER_SENDER, 1, "TANK_MOVE_START", entity.id);

	end,
	---------------------------------------------
	TANK_MOVE_CHECK_SHOOT_AAA = function( self, entity )

		local bMissile = false;
		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			local subType = AI.GetSubTypeOf( target.id );
			if ( subType == AIOBJECT_CAR ) then
			  if ( target.AIMovementAbility.pathType == AIPATH_TANK ) then
			  	bMissile = true;
			  end
			end

			if ( target.actor ~=nil ) then
				vehicleId = target.actor:GetLinkedVehicleId();
				if ( vehicleId ) then
					vehicleEntity = System.GetEntity( vehicleId );
					if ( vehicleEntity ) then
					  if ( vehicleEntity.AIMovementAbility.pathType == AIPATH_TANK ) then
					  	bMissile = true;
					  end
					end
				end
			end

			local enemyPos = {};
			local randomFactor;
			CopyVector( enemyPos, target:GetPos() );

			if ( enemyPos.z - System.GetTerrainElevation( enemyPos ) > 10.0 ) then
				randomFactor =1; -- for more frequesnt shot for the air target.
			else
				randomFactor =3;
			end

			if ( entity.AI.shootCounter == 0 ) then
				if ( random( 1, randomFactor ) == 1 or entity.AI.bShootNexttime == true) then
					entity.AI.bShootNexttime = false;
					if ( bMissile == true ) then
						entity.AI.shootCounter = 1;
					else
						entity.AI.shootCounter = 21;
					end
					AIBehaviour.TANKDEFAULT:selectCannonForTheDriver( entity, bMissile );
				end
			end

			if ( entity.AI.shootCounter > 20 ) then
				entity.AI.shootCounter = entity.AI.shootCounter + 1;
				if ( entity.AI.shootCounter == 22 ) then
					AI.CreateGoalPipe("tank_fire");
					AI.PushGoal("tank_fire","firecmd",0,FIREMODE_CONTINUOUS);
					entity:InsertSubpipe(0,"tank_fire");
				end
				if ( entity.AI.shootCounter > 40 or bMissile == true ) then
					AI.CreateGoalPipe("tank_nofire");
					AI.PushGoal("tank_nofire","firecmd",0,0);
					entity:InsertSubpipe(0,"tank_nofire");
					entity.AI.shootCounter = 0;
				end
			elseif ( entity.AI.shootCounter > 0 ) then
				entity.AI.shootCounter = entity.AI.shootCounter + 1;
				if ( entity.AI.shootCounter == 2 ) then
					AI.CreateGoalPipe("tank_fire");
					AI.PushGoal("tank_fire","firecmd",0,1);
					entity:InsertSubpipe(0,"tank_fire");
				end
				if ( entity.AI.shootCounter == 3 or bMissile == false ) then
					AI.CreateGoalPipe("tank_nofire");
					AI.PushGoal("tank_nofire","firecmd",0,0);
					entity:InsertSubpipe(0,"tank_nofire");
				end
				if ( entity.AI.shootCounter == 12 or bMissile == false ) then
					entity.AI.shootCounter = 0;
				end

			end
		
		else

			if ( entity.AI.shootCounter > 0 ) then
				AI.CreateGoalPipe("tank_nofire");
				AI.PushGoal("tank_nofire","firecmd",0,0);
				entity:InsertSubpipe(0,"tank_nofire");
				entity.AI.shootCounter = 0;
			end

		end

	end,

	---------------------------------------------
	TANK_MOVE_CHECK_SHOOT = function( self, entity )

		if ( entity.AI.isAAA and entity.AI.isAAA == true ) then
			self:TANK_MOVE_CHECK_SHOOT_AAA( entity );
			return;
		end

		entity.AI.bUseMachineGun = AIBehaviour.TANKDEFAULT:tankDoesUseMachineGun( entity );

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then
		
			local enemyPos = {};
			local randomFactor;
			CopyVector( enemyPos, target:GetPos() );

			if ( enemyPos.z - System.GetTerrainElevation( enemyPos ) > 10.0 ) then
				randomFactor =1; -- for more frequesnt shot for the air target.
			else
				randomFactor =7;
			end

			if ( entity.AI.shootCounter == 0 ) then
				if ( random( 1, randomFactor ) == 1 or entity.AI.bShootNexttime == true) then
					entity.AI.bShootNexttime = false;
					if ( entity.AI.bUseMachineGun ~=true ) then
						local vDirToTarget = {};
						SubVectors( vDirToTarget, target:GetPos(), entity:GetPos() );
						vDirToTarget.z = 0.0;
						if ( LengthVector( vDirToTarget ) < 20.0 ) then
							-- entity:InsertSubpipe(0,"devalue_target");
						else
							entity.AI.shootCounter = 1;
							AIBehaviour.TANKDEFAULT:selectCannonForTheDriver( entity, true )

							if ( entity.AI.isAPC and entity.AI.isAPC == true ) then
								if ( random(1,2)==1 ) then
									AIBehaviour.TANKDEFAULT:selectCannonForTheDriver( entity, false )
									entity.AI.shootCounter = 21;
								end
							end

						end
					else
						entity.AI.shootCounter = 21;
						AIBehaviour.TANKDEFAULT:selectCannonForTheDriver( entity, false )
					end
				end
			end
		else

			if ( entity.AI.shootCounter > 0 ) then
				AI.CreateGoalPipe("tank_nofire");
				AI.PushGoal("tank_nofire","firecmd",0,0);
				entity:InsertSubpipe(0,"tank_nofire");
				entity.AI.shootCounter = 0;
			end

		end

		if ( entity.AI.shootCounter > 20 ) then
			entity.AI.shootCounter = entity.AI.shootCounter + 1;
			if ( entity.AI.shootCounter == 22 ) then
				AI.CreateGoalPipe("tank_fire");
				AI.PushGoal("tank_fire","firecmd",0,FIREMODE_SECONDARY);
				entity:InsertSubpipe(0,"tank_fire");
			end
			if ( entity.AI.shootCounter > 40 ) then
				AI.CreateGoalPipe("tank_nofire");
				AI.PushGoal("tank_nofire","firecmd",0,0);
				entity:InsertSubpipe(0,"tank_nofire");
				entity.AI.shootCounter = 0;
			end
		elseif ( entity.AI.shootCounter > 0 ) then
			entity.AI.shootCounter = entity.AI.shootCounter + 1;
			if ( entity.AI.shootCounter == 2 ) then
				AI.CreateGoalPipe("tank_fire");
				AI.PushGoal("tank_fire","firecmd",0,1);
				entity:InsertSubpipe(0,"tank_fire");
			end
			if ( entity.AI.shootCounter > 7 ) then
				AI.CreateGoalPipe("tank_nofire");
				AI.PushGoal("tank_nofire","firecmd",0,0);
				entity:InsertSubpipe(0,"tank_nofire");
				entity.AI.shootCounter = 0;
			end
		end

	end,

	--------------------------------------------------------------------------
	TANK_PROTECT_ME = function( self, entity, sender )

		if ( AI.GetSpeciesOf(entity.id) == AI.GetSpeciesOf(sender.id) ) then

			entity.AI.protect = sender.id;

--			AI.LogEvent(entity:GetName().." get TANK_PROTECT_ME from "..sender:GetName() );

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