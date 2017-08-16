--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2005.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: boat combat Behaviour SCRIPT
--  
--------------------------------------------------------------------------
--  History:
--  - 25/07/2005   : Created by Kirill Bulatsev
--
--------------------------------------------------------------------------

--------------------------------------------------------------------------
local function boatRequest2ndGunnerShoot( entity )

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
local function boatAdjustRefPointPosition( entity, scale )

	local vDestination = {};
	
	CopyVector( vDestination, AI.GetRefPointPosition(entity.id) );

	SubVectors( vDestination, vDestination, entity:GetPos() );
	FastScaleVector( vDestination, vDestination, scale );
	FastSumVectors( vDestination, vDestination, entity:GetPos() );

	if ( AI.IsPointInWaterRegion( vDestination ) <0.5 ) then
		AI.LogEvent("Water Level"..AI.IsPointInWaterRegion( vDestination ));
		CopyVector( vDestination,	entity.AI.vSafePosition );
		AI.SetRefPointPosition( entity.id, vDestination );
		AI.LogEvent("Water Level"..AI.IsPointInWaterRegion( vDestination ));
	end

end

--------------------------------------------------------------------------------------------------------------------
-- common function for the behavior
	
local function boat_stack_check( entity )
	
	-- check if the boat is stack in something( shore/obstacle etc )
	
	local target = AI.GetAttentionTargetEntity( entity.id );
	if ( target and AI.Hostile( entity.id, target.id ) ) then

		local vDestination = {};
		local vRotVecSrc = {};
		local vRotVec = {};
		local vCheck = {};
		local rotationAngle = 0.0;

		-- make sure there is enough space to combat.
		local bFound = false;
		local vSpaceDir = {};

		vSpaceDir.x = 0.0;
		vSpaceDir.y = 0.0;
		vSpaceDir.z = 0.0;
		
		local vUp = { x = 0.0, y = 0.0, z = 1.0 };
		
		for i = 1,16 do
			FastScaleVector( vRotVecSrc, entity:GetDirectionVector(Yaxis), 30.0 );
			rotationAngle = 3.1416 * 2.0 * ( i - 1.0 ) / 16.0;
			RotateVectorAroundR( vRotVec, vRotVecSrc, vUp, rotationAngle );
			FastSumVectors( vDestination, vRotVec, entity:GetPos() );
			if ( AI.IsPointInWaterRegion( vDestination ) > 0.5 ) then
				FastSumVectors( vSpaceDir, vSpaceDir, vRotVec );
			else
				bFound = true;
			end
		end

		-- if there is the ground near the boat, it should be avoided.
		if (bFound == true ) then
	
			SubVectors( vCheck, entity:GetPos(), entity.AI.vPositionRsv );
			local distance = LengthVector( vCheck );
			CopyVector( entity.AI.vPositionRsv, entity:GetPos() );

			if ( distance < 1.0 ) then

				-- maybe the boat is stuck, all passengers should get off.
				FastScaleVector( vDestination, entity:GetDirectionVector(Yaxis), -20.0 );
				FastSumVectors( vDestination, vDestination, entity:GetPos() );
				
				AI.SetRefPointPosition( entity.id, vDestination );
				AI.CreateGoalPipe("boatIamStuck");
				-- AI.PushGoal("boatIamStuck","continuous",0,1);
				AI.PushGoal("boatIamStuck","locate",0,"refpoint");
				AI.PushGoal("boatIamStuck","run",0,-2);
				AI.PushGoal("boatIamStuck","approach",0,3.0,AILASTOPRES_USE);
				AI.PushGoal("boatIamStuck","timeout",1,4.0);
				AI.PushGoal("boatIamStuck","signal",1,1,"BOAT_STUCK_CHECK",SIGNALFILTER_SENDER);
				AI.PushGoal("boatIamStuck","signal",1,1,"BOAT_ATTACK_START",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"boatIamStuck");
				return true;

			else
	
				-- go to get enough space.
				NormalizeVector( vSpaceDir );
				FastScaleVector( vSpaceDir, vSpaceDir, 20.0 );
				FastSumVectors( vDestination, vSpaceDir, entity:GetPos() );

				AI.SetRefPointPosition( entity.id, vDestination );
				AI.CreateGoalPipe("boatGoToSpace");
				-- AI.PushGoal("boatGoToSpace","continuous",0,1);
				AI.PushGoal("boatGoToSpace","locate",0,"refpoint");
				AI.PushGoal("boatGoToSpace","run",0,0);
				AI.PushGoal("boatGoToSpace","approach",0,3.0,AILASTOPRES_USE);
				AI.PushGoal("boatGoToSpace","timeout",1,4.0);
				AI.PushGoal("boatGoToSpace","signal",0,1,"BOAT_ATTACK_START",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"boatGoToSpace");
				return true;

			end

		end

	end
	
	return false;
	
end

--------------------------------------------------------------------------
local function boat_get_target_direction( entity ,axis, out )

	-- check the direction vector of the target.
	-- if he rides on the vehicles, returns a direction of the vehicle.

	local target = AI.GetAttentionTargetEntity( entity.id );
	if ( target and AI.Hostile( entity.id, target.id ) ) then

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

	end

	FastScaleVector( out, target:GetDirectionVector(Yaxis), -1.0 );
	return;

end

--------------------------------------------------------------------------
local function boat_get_target_velocity( entity , out )

	-- check the velocity of the target.
	-- if he rides on the vehicles, returns a velocity of the vehicle.

	local target = AI.GetAttentionTargetEntity( entity.id );
	if ( target and AI.Hostile( entity.id, target.id ) ) then

		local vehicleId = target.actor:GetLinkedVehicleId();
		if ( vehicleId ) then

			local	vehicle = System.GetEntity( vehicleId );
			if( vehicle ) then
				CopyVector( out, vehicle:GetVelocity() );
				return;
			end

		end

	end

	CopyVector( out, target:GetVelocity());
	return;

end

--------------------------------------------------------------------------
local function boat_get_target_spin_speed( entity )

	-- check the rotation velocity of the target.
	-- if he rides on the vehicles, returns a velocity of the vehicle.
	-- this function is used for expectation for the moving, a return value is not accurate.

	local target = AI.GetAttentionTargetEntity( entity.id );
	if ( target and AI.Hostile( entity.id, target.id ) ) then

		local vehicleId = target.actor:GetLinkedVehicleId();
		if ( vehicleId ) then

			local	vehicle = System.GetEntity( vehicleId );
			if( vehicle ) then

				local vVelocity = {};
				boat_get_target_velocity( entity, vVelocity );
				NormalizeVector( vVelocity );

				local vDir = {};
				boat_get_target_direction( entity, Yaxis, vDir );

				local s = dotproduct3d( vVelocity, vDir );
				
				-- special assamption that  FPS = 20;
				
				local deg = math.acos(s) * 20.0;
				return deg;

			end

		end

	end

	-- if the target is not on the vehicle, it's slow enough.
	return 0.0;

end

--------------------------------------------------------------------------
local function predictTargetPositionError( entity, vPoint, vAssumingPos, vAssumingDir, assuming_time )

	-- get a expected position in the local coordination and y-direction vector after time(sec)

	local target = AI.GetAttentionTargetEntity( entity.id );
	if ( target and AI.Hostile( entity.id, target.id ) ) then

		local vPredictedPosition = {};
		local vTargetVelocity = {};
		local vTargetDir = {};
		local vTargetUpDir = {};
		local targetRotationSpeed = boat_get_target_spin_speed( entity );

		boat_get_target_direction( entity, Yaxis, vTargetDir );
		boat_get_target_direction( entity, Zaxis, vTargetUpDir );
		boat_get_target_velocity( entity, vTargetVelocity );

		local vPos = {};
		CopyVector( vPos, entity:GetPos() );

		-- predict a postion after this time has passed.
		FastScaleVector( vPredictedPosition, vTargetVelocity, assuming_time );
		FastSumVectors( vPredictedPosition, vPredictedPosition, vPoint );

		RotateVectorAroundR( vAssumingPos, vPredictedPosition, vTargetUpDir, targetRotationSpeed * assuming_time );
		RotateVectorAroundR( vAssumingDir, vTargetDir, vTargetUpDir, targetRotationSpeed * assuming_time );

		AI.LogEvent("current  position and direction: "..vPos.x..","..vPos.y..","..vPos.z.." / "..vTargetDir.x..","..vTargetDir.y..","..vTargetDir.z);
		AI.LogEvent("assuming position and direction: "..vAssumingPos.x..","..vAssumingPos.y..","..vAssumingPos.z.." / "..vAssumingDir.x..","..vAssumingDir.y..","..vAssumingDir.z);

	else
		FastScaleVector( vAssumingPos, entity:GetPos(), 0.0 );
		FastScaleVector( vAssumingDir, entity:GetPos(), 0.0 );
	end

end

--------------------------------------------------------------------------
local function boat_get_inFOV_time( entity )
	
	-- returns a time how long I have been caught by the target.

	local target = AI.GetAttentionTargetEntity( entity.id );
	if ( target and AI.Hostile( entity.id, target.id ) ) then

		local vDirFromTarget = {};
		local vTargetDirection = {};

		boat_get_target_direction( entity ,Yaxis, vTargetDirection )

		SubVectors( vDirFromTarget, entity:GetPos(), target:GetPos() );
		NormalizeVector( vDirFromTarget );
		local s = dotproduct3d( vDirFromTarget, vTargetDirection );
		local inFov = math.cos( 60.0 * 3.1416 / 180.0 );

		if ( s > inFov ) then
			-- AI.LogEvent("FOV TIME "..entity.AI.inFOVtime);
		else
			-- when I am NOT in FOV of the target, reset the counter
			entity.AI.inFOVtime = System.GetCurrTime();
		end

	else
		-- when I have no target, reset the counter
		entity.AI.inFOVtime = System.GetCurrTime();
	end

	return System.GetCurrTime() - entity.AI.inFOVtime;
	
end

--------------------------------------------------------------------------
local Xaxis = 0;
local Yaxis = 1;
local Zaxis = 2;

--------------------------------------------------------------------------
AIBehaviour.BoatAttack = {
	Name = "BoatAttck",
	alertness = 2,

	-- SYSTEM EVENTS			-----
	---------------------------------------------
	Constructor = function(self , entity )

		-- keep a default position as a safe point
		entity.AI.vSafePosition = {};
		CopyVector( entity.AI.vSafePosition, entity:GetPos() );
		entity.AI.vPatrollPosition = {};
		CopyVector( entity.AI.vPatrollPosition, entity:GetPos() );
		
		entity.AI.vPositionRsv = {};
		CopyVector( entity.AI.vPositionRsv, entity:GetPos() );
		
		entity.AI.attackCount = 0;
		
		-- keep a time ,which show us how long I have been caught by the target
		
		entity.AI.inFOVtime = System.GetCurrTime();
		entity.AI.inFOVescapeTime =  3.0 + random(0,3) ;

		-- Default action for the gunner
		boatRequest2ndGunnerShoot( entity );

		-- Default action
		AI.CreateGoalPipe("boatAttackDefault");
		AI.PushGoal("boatAttackDefault","timeout",1,0.5);
		AI.PushGoal("boatAttackDefault","signal",0,1,"BOAT_ATTACK_START",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"boatAttackDefault");

	end,
	
	---------------------------------------------
	---------------------------------------------

	----------------------------------------------------FUNCTIONS 

	---------------------------------------------
	CHOOSE_ATTACK_ACTION  = function ( self, entity, sender )
		entity:SelectPipe(0,"vehicle_chase");
	end,


	---------------------------------------------
	CHASE_DONE	  = function ( self, entity, sender )
		AI.Signal(SIGNALFILTER_SENDER, 1, "CHOOSE_ATTACK_ACTION",entity.id);	
	end,

	--------------------------------------------------------------------------------------------------------------------
	BOAT_STUCK_CHECK = function ( self, entity)
	
		local vCheck ={};

		SubVectors( vCheck, entity:GetPos(), entity.AI.vPositionRsv );
		local distance = LengthVector( vCheck );
		CopyVector( entity.AI.vPositionRsv, entity:GetPos() );

		if ( distance < 1.0 ) then
			entity:SignalCrew("EXIT_VEHICLE_STAND");
			entity:SelectPipe(0,"do_nothing");
		end

	end,

	--------------------------------------------------------------------------------------------------------------------
	-- to make the boat align the directions.
	
	BOAT_ALIGN_DIRECTION = function ( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			local assumingTime = 0.7;
			local vOffset= {};
			local vAssumingPos = {};
			local vAssumingDir = {};

			boat_get_target_direction( entity ,Xaxis, vOffset );
			FastScaleVector( vOffset, vOffset, 0.0 );

			predictTargetPositionError( entity, vOffset, vAssumingPos, vAssumingDir, assumingTime );

			


		else
			-- entity:SelectPipe(0,"do_nothing");
		end

	end,

	--------------------------------------------------------------------------------------------------------------------
	-- behaviors against the slow target in the water
	BOAT_ATTACK_BOAT = function ( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			-- to avoid shallow etc.
			if ( boat_stack_check( entity ) == true ) then
				return;
			end
			local fovTime = boat_get_inFOV_time( entity )
			AI.LogEvent("FOV time"..fovTime);
			-- if I have been caught for more than 5 sec, try to get rid of it.
			if ( fovTime > entity.AI.inFOVescapeTime ) then
				self:BOAT_TAKE_ESCAPE_ACTION( entity );
				return;
			end
			
			-- if I am caught by player , try to use machine gun.
			local vDirFromTarget = {};
			local vTargetDirection = {};
			local inPlayerFov = math.cos( 30.0 * 3.1416 / 180.0 );
			SubVectors( vDirFromTarget, entity:GetPos(), target:GetPos() );
			NormalizeVector( vDirFromTarget );

			boat_get_target_direction( entity ,Yaxis, vTargetDirection )

			local v = dotproduct3d( vTargetDirection, vDirFromTarget );
			if ( v > inPlayerFov ) then 
				boatRequest2ndGunnerShoot( entity );
			end

			-- analize the situation

			local vDestination = {};
			local vDirToTarget = {};
			local vDirFromTarget = {};
			local vDestinationRot = {};
			local vRotVecSrc = {};
			local vRotVec = {};
			local vTargetDirection = {};
			local rotationAngle = 0.0;

			entity:SelectPipe(0,"do_nothing");

			SubVectors( vDirToTarget, target:GetPos(), entity:GetPos() );
			NormalizeVector( vDirToTarget );
			SubVectors( vDirFromTarget, entity:GetPos(), target:GetPos() );
			NormalizeVector( vDirFromTarget );

			boat_get_target_direction( entity ,Yaxis, vTargetDirection )
	
			local t = dotproduct3d( vDirToTarget,entity:GetDirectionVector(Xaxis)); -- t>0 when the target is in the right side.
			local s = dotproduct3d( vDirToTarget,entity:GetDirectionVector(Yaxis)); -- s>0 when the target is in the front side.
			local u = dotproduct3d( vDirFromTarget, vTargetDirection ); -- u>0 when I am in fornt of the target
			local inFov = math.cos( 60.0 * 3.1416 / 180.0 );
			local inFov2 = math.cos( 70.0 * 3.1416 / 180.0 );
			local distance = entity:GetDistance( target.id );
			
			if ( s > inFov and u > inFov and distance > 30.0) then 
				-- If I and target can see eachother, starts parallell attack.
				AI.Signal(SIGNALFILTER_SENDER, 1, "BOAT_PARALLEL_ATTACK", entity.id);
				return;
			elseif ( s > 0 and u < inFov2 * -1.0 ) then
				-- When I can see the target and I am in the behind for the target, starts chaseattack
				AI.Signal(SIGNALFILTER_SENDER, 1, "BOAT_CHASE_ATTACK", entity.id);
				return;
			end
	
			-- depending on a quadrant, boat will take different actions.

			FastScaleVector( vDestination, entity:GetDirectionVector(Yaxis), 20.0 );

			local pipename = "pipename";
			
			--s =1.0;
			--t =1.0;

			-- if the target is too cloth, will run away
			if ( distance < 20.0 and random(1,3) == 1 ) then 
				self:BOAT_ESCAPE( entity );
				return;
			end

			if ( s > 0 ) then
				if ( t > 0 ) then
					rotationAngle = -60.0 * 3.1416 / 180.0;
					pipename = "boatAttackBoat_RightFront";
				else
					rotationAngle = 60.0 * 3.1416 / 180.0;
					pipename = "boatAttackBoat_LeftFront";
				end
			else
				if ( t > 0 ) then
					rotationAngle = -60.0 * 3.1416 / 180.0;
					pipename = "boatAttackBoat_RightBehind";
				else
					rotationAngle = 60.0 * 3.1416 / 180.0;
					pipename = "boatAttackBoat_LeftBehind";
				end
			end

			local vVelocity = {};

			RotateVectorAroundR( vDestinationRot, vDestination, entity:GetDirectionVector(Zaxis), rotationAngle );

			FastScaleVector( vVelocity, entity:GetVelocity(), 1.5 );
			FastSumVectors( vDestinationRot, vDestinationRot, entity:GetPos() );
			FastSumVectors( vDestinationRot, vDestinationRot, vVelocity );
			AI.SetRefPointPosition( entity.id, vDestinationRot );
				
			AI.CreateGoalPipe(pipename);
			AI.PushGoal(pipename,"continuous",0,1);
			AI.PushGoal(pipename,"run",0,0);
			AI.PushGoal(pipename,"locate",0,"refpoint");
			AI.PushGoal(pipename,"approach",0,3.0,AILASTOPRES_USE);
			AI.PushGoal(pipename,"timeout",1,0.7);
			AI.PushGoal(pipename,"signal",0,1,"BOAT_ATTACK_START",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,pipename);

		else
			entity:SelectPipe(0,"do_nothing");
		end

	end,

	---------------------------------------------
	BOAT_TAKE_ESCAPE_ACTION = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			local vDirToTarget = {};
			local vDirFromTarget = {};

			-- select actions depending on the direction and distance

			SubVectors( vDirToTarget, target:GetPos(), entity:GetPos() );
			SubVectors( vDirFromTarget, entity:GetPos(), target:GetPos() );
			NormalizeVector( vDirToTarget );
			NormalizeVector( vDirFromTarget );

			local s = dotproduct3d( vDirToTarget,entity:GetDirectionVector(Yaxis));
			local t = dotproduct3d( vDirFromTarget,target:GetDirectionVector(Xaxis));
			local inFov = math.cos( 60.0 * 3.1416 / 180.0 );
			local distance = entity:GetDistance( target.id );

			if (distance>=70.0) then
				self:BOAT_JUST_APPROACH( entity );
			elseif ( s > inFov and distance > 15.0 ) then
				self:BOAT_APPROACH_ATTACK( entity );
			elseif ( s < inFov and distance > 15.0 ) then
				if (t>0) then
					self:BOAT_ESCAPE_FORWARD( entity );
				else
					self:BOAT_ESCAPE_BACKWARD( entity );
				end
			else
				AI.CreateGoalPipe("boatWaitTime");
				AI.PushGoal("boatWaitTime","timeout",1,3.0);
				AI.PushGoal("boatWaitTime","signal",0,1,"BOAT_TAKE_ESCAPE_ACTION_END",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"boatWaitTime");
			end		

		else
			entity:SelectPipe(0,"do_nothing");
		end

	end,

	---------------------------------------------
	BOAT_TAKE_ESCAPE_ACTION_END = function( self, entity )
	
		-- if escape action finished, check if we can attack
	
		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			entity.AI.inFOVtime = System.GetCurrTime();
			entity.AI.inFOVescapeTime =  3.0 + random(0,3) ;

			local vDirToTarget = {};

			-- select actions depending on the direction and distance

			SubVectors( vDirToTarget, target:GetPos(), entity:GetPos() );
			NormalizeVector( vDirToTarget );

			local s = dotproduct3d( vDirToTarget,entity:GetDirectionVector(Yaxis));
			local inFov = math.cos( 70.0 * 3.1416 / 180.0 );
			local distance = entity:GetDistance( target.id );

			if ( s > inFov and distance > 10.0 ) then
				self:BOAT_APPROACH_ATTACK( entity );
			else
				AI.Signal(SIGNALFILTER_SENDER, 1, "BOAT_ATTACK_START", entity.id);
			end
		else
			entity:SelectPipe(0,"do_nothing");
		end

	end,

	---------------------------------------------
	BOAT_JUST_APPROACH = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then
			AI.SetRefPointPosition( entity.id, target:GetPos() );
			AI.CreateGoalPipe("boatJustApproach");
			AI.PushGoal("boatJustApproach","continuous",0,1);
			AI.PushGoal("boatJustApproach","run",0,0);
			AI.PushGoal("boatJustApproach","locate",0,"refpoint");
			AI.PushGoal("boatJustApproach","approach",0,70.0,AILASTOPRES_USE);
			AI.PushGoal("boatJustApproach","signal",0,1,"BOAT_JUST_APPROACH_CHECK",SIGNALFILTER_SENDER);
			AI.PushGoal("boatJustApproach","timeout",1,1.0);
			AI.PushGoal("boatJustApproach","branch",1,-2);
			AI.PushGoal("boatJustApproach","signal",0,1,"BOAT_TAKE_ESCAPE_ACTION_END",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"boatJustApproach");
		else
			-- if there is no target. BOAT_ATTACK_START handles this situation.
			AI.Signal(SIGNALFILTER_SENDER, 1, "BOAT_ATTACK_START", entity.id);
			return;
		end

	end,

	---------------------------------------------
	BOAT_JUST_APPROACH_CHECK = function ( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then
	
			local vDirToDestination = {};
			SubVectors( vDirToDestination, AI.GetRefPointPosition(entity.id), entity:GetPos() );
			if ( LengthVector( vDirToDestination ) < 70.0 ) then
				-- check for the distance to the destination. just in case when approach doesn't work
				AI.Signal(SIGNALFILTER_SENDER, 1, "BOAT_TAKE_ESCAPE_ACTION_END", entity.id);
				return;
			end

		else
			-- if there is no target. BOAT_ATTACK_START handles this situation.
			AI.Signal(SIGNALFILTER_SENDER, 1, "BOAT_ATTACK_START", entity.id);
			return;
		end

		self:BOAT_CONFLICTION_CHECK( entity );

	end,

	---------------------------------------------
	BOAT_ESCAPE_BACKWARD = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then
			local vDestination = {};
			FastScaleVector( vDestination, entity:GetDirectionVector(Yaxis), -30.0);
			FastSumVectors( vDestination, vDestination, entity:GetPos() );
			AI.SetRefPointPosition( entity.id, vDestination );
			AI.CreateGoalPipe("boatEscapeBackward");
			AI.PushGoal("boatEscapeBackward","continuous",0,1);
			AI.PushGoal("boatEscapeBackward","run",0,0);
			AI.PushGoal("boatEscapeBackward","locate",0,"refpoint");
			AI.PushGoal("boatEscapeBackward","approach",0,5.0,AILASTOPRES_USE);
			AI.PushGoal("boatEscapeBackward","signal",0,1,"BBOAT_ESCAPE_BACKWARD_CHECK",SIGNALFILTER_SENDER);
			AI.PushGoal("boatEscapeBackward","timeout",1,0.5);
			AI.PushGoal("boatEscapeBackward","signal",0,1,"BBOAT_ESCAPE_BACKWARD_CHECK",SIGNALFILTER_SENDER);
			AI.PushGoal("boatEscapeBackward","timeout",1,0.5);
			AI.PushGoal("boatEscapeBackward","signal",0,1,"BBOAT_ESCAPE_BACKWARD_CHECK",SIGNALFILTER_SENDER);
			AI.PushGoal("boatEscapeBackward","timeout",1,0.5);
			AI.PushGoal("boatEscapeBackward","signal",0,1,"BBOAT_ESCAPE_BACKWARD_CHECK",SIGNALFILTER_SENDER);
			AI.PushGoal("boatEscapeBackward","timeout",1,0.5);
			AI.PushGoal("boatEscapeBackward","signal",0,1,"BOAT_TAKE_ESCAPE_ACTION_END",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"boatEscapeBackward");
		else
			-- if there is no target. BOAT_ATTACK_START handles this situation.
			AI.Signal(SIGNALFILTER_SENDER, 1, "BOAT_ATTACK_START", entity.id);
			return;
		end

	end,

	---------------------------------------------
	BOAT_ESCAPE_BACKWARD_CHECK = function ( self, entity )

		self:BOAT_CONFLICTION_CHECK( entity );

	end,


	---------------------------------------------
	BOAT_ESCAPE_FORWARD = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then
			local vDestination = {};
			FastScaleVector( vDestination, entity:GetDirectionVector(Yaxis), 30.0);
			FastSumVectors( vDestination, vDestination, entity:GetPos() );
			AI.SetRefPointPosition( entity.id, vDestination );
			AI.CreateGoalPipe("boatEscapeForward");
			AI.PushGoal("boatEscapeForward","continuous",0,1);
			AI.PushGoal("boatEscapeForward","run",0,1);
			AI.PushGoal("boatEscapeForward","locate",0,"refpoint");
			AI.PushGoal("boatEscapeForward","approach",0,5.0,AILASTOPRES_USE);
			AI.PushGoal("boatEscapeForward","signal",0,1,"BOAT_ESCAPE_FORWARD_CHECK",SIGNALFILTER_SENDER);
			AI.PushGoal("boatEscapeForward","timeout",1,0.5);
			AI.PushGoal("boatEscapeForward","signal",0,1,"BOAT_ESCAPE_FORWARD_CHECK",SIGNALFILTER_SENDER);
			AI.PushGoal("boatEscapeForward","timeout",1,0.5);
			AI.PushGoal("boatEscapeForward","signal",0,1,"BOAT_ESCAPE_FORWARD_CHECK",SIGNALFILTER_SENDER);
			AI.PushGoal("boatEscapeForward","timeout",1,0.5);
			AI.PushGoal("boatEscapeForward","signal",0,1,"BOAT_ESCAPE_FORWARD_CHECK",SIGNALFILTER_SENDER);
			AI.PushGoal("boatEscapeForward","timeout",1,0.5);
			AI.PushGoal("boatEscapeForward","signal",0,1,"BOAT_TAKE_ESCAPE_ACTION_END",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"boatEscapeForward");
		else
			-- if there is no target. BOAT_ATTACK_START handles this situation.
			AI.Signal(SIGNALFILTER_SENDER, 1, "BOAT_ATTACK_START", entity.id);
			return;
		end

	end,

	---------------------------------------------
	BOAT_ESCAPE_FOWARD_CHECK = function ( self, entity )

		self:BOAT_CONFLICTION_CHECK( entity );

	end,


	---------------------------------------------
	BOAT_APPROACH_ATTACK = function( self, entity )
	
		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			local vDirFromTarget = {};
			local vDestination = {};
			local vRotVecSrc = {};
			local vRotVec = {};
			local vWing = {};

			local rotationAngle = 0.0;
			local inner = 0.0;

			boatRequest2ndGunnerShoot( entity );

			SubVectors( vDirFromTarget, entity:GetPos(), target:GetPos() );
			inner = dotproduct3d( vDirFromTarget,target:GetDirectionVector(Xaxis));

			if ( inner > 0 ) then 
				-- I am in the right side of the target 
				rotationAngle = - 15.0 * 3.1416 / 180.0;
			else
				rotationAngle =   15.0 * 3.1416 / 180.0;
			end

			FastScaleVector( vRotVecSrc, entity:GetDirectionVector(Yaxis), 20.0 );
			distance = DistanceLineAndPoint( target:GetPos() , vRotVecSrc, entity:GetPos() );

			RotateVectorAroundR( vRotVec, vRotVecSrc, entity:GetDirectionVector(Zaxis), rotationAngle  );
			FastSumVectors( vDestination, vRotVec, entity:GetPos() );

			entity:SelectPipe(0,"do_nothing");
			AI.SetRefPointPosition( entity.id, vDestination );
			AI.CreateGoalPipe("boatApproachAttack");
			AI.PushGoal("boatApproachAttack","continuous",0,1);
			AI.PushGoal("boatApproachAttack","run",0,0);
			AI.PushGoal("boatApproachAttack","locate",0,"refpoint");
			AI.PushGoal("boatApproachAttack","approach",0,5.0,AILASTOPRES_USE);
			AI.PushGoal("boatApproachAttack","signal",0,1,"BOAT_APPROACH_ATTACK_CHECK",SIGNALFILTER_SENDER);
			AI.PushGoal("boatApproachAttack","timeout",1,1.0);
			AI.PushGoal("boatApproachAttack","branch",1,-2);
			AI.PushGoal("boatApproachAttack","signal",0,1,"BOAT_ATTACK_START",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"boatApproachAttack");

		else
			-- if there is no target. BOAT_ATTACK_START handles this situation.
			AI.Signal(SIGNALFILTER_SENDER, 1, "BOAT_ATTACK_START", entity.id);
		end

	end,

	---------------------------------------------
	BOAT_APPROACH_ATTACK_CHECK = function ( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then
	
			local vDirToDestination = {};
			SubVectors( vDirToDestination, AI.GetRefPointPosition(entity.id), entity:GetPos() );
			if ( math.abs( vDirToDestination.x ) + math.abs( vDirToDestination.y ) < 5.0 ) then
				-- check for the distance to the destination. just in case when approach doesn't work
				AI.Signal(SIGNALFILTER_SENDER, 1, "BOAT_ATTACK_START", entity.id);
				return;
			end

		else
			-- if there is no target. BOAT_ATTACK_START handles this situation.
			AI.Signal(SIGNALFILTER_SENDER, 1, "BOAT_ATTACK_START", entity.id);
			return;
		end

		self:BOAT_CONFLICTION_CHECK( entity );

	end,

	---------------------------------------------
	BOAT_PARALLEL_ATTACK = function ( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			entity:SelectPipe(0,"do_nothing");

			local vDirToTarget = {};
			SubVectors( vDirToTarget, target:GetPos(), entity:GetPos() );
			NormalizeVector( vDirToTarget );

			local t = dotproduct3d( vDirToTarget,entity:GetDirectionVector(Xaxis)); -- t>0 when the target is in the right side.

			local wingScale;
			
			if (t>0) then
				wingScale = -20.0;
			else
				wingScale =  20.0;
			end

			boatRequest2ndGunnerShoot( entity );
	
			local vDestination = {};
			FastScaleVector( vDestination, entity:GetDirectionVector(Xaxis), wingScale );
			FastSumVectors( vDestination, vDestination, target:GetPos() );

			AI.SetRefPointPosition( entity.id, vDestination );
			
			AI.CreateGoalPipe("boatParallelAttack");
			AI.PushGoal("boatParallelAttack","continuous",0,1);
			AI.PushGoal("boatParallelAttack","run",0,1);
			AI.PushGoal("boatParallelAttack","locate",0,"refpoint");
			AI.PushGoal("boatParallelAttack","approach",0,3.0,AILASTOPRES_USE);
			AI.PushGoal("boatParallelAttack","signal",0,1,"BOAT_PARALLEL_ATTACK_CHECK",SIGNALFILTER_SENDER);
			AI.PushGoal("boatParallelAttack","timeout",1,1.0);
			AI.PushGoal("boatParallelAttack","branch",1,-2);
			AI.PushGoal("boatParallelAttack","signal",0,1,"BOAT_PARALLEL_ATTACK",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"boatParallelAttack");
	
		else
			-- if there is no target. BOAT_ATTACK_START handles this situation.
			AI.Signal(SIGNALFILTER_SENDER, 1, "BOAT_ATTACK_START", entity.id);
		end

	end,

	---------------------------------------------
	BOAT_PARALLEL_ATTACK_CHECK = function ( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			local vDirToDestination = {};
			SubVectors( vDirToDestination, AI.GetRefPointPosition(entity.id), entity:GetPos() );
			if ( math.abs( vDirToDestination.x ) + math.abs( vDirToDestination.y ) < 10.0 ) then
				-- check for the distance to the destination. just in case when approach doesn't work
				AI.Signal(SIGNALFILTER_SENDER, 1, "BOAT_ATTACK_START", entity.id);
				return;
			end

			local vDirToTarget = {};
			SubVectors( vDirToTarget, entity:GetPos(), target:GetPos() );
			local distance = LengthVector( vDirToTarget );
			local s = dotproduct3d( vDirToTarget,entity:GetDirectionVector(Yaxis)); -- s>0 when the target is in the front side.

			if ( distance > 20.0 and s < 0 ) then
				-- finish the attack when the boat is far away from the target
				AI.Signal(SIGNALFILTER_SENDER, 1, "BOAT_ATTACK_START", entity.id);
				return;
			end

		else
			-- if there is no target. BOAT_ATTACK_START handles this situation.
			AI.Signal(SIGNALFILTER_SENDER, 1, "BOAT_ATTACK_START", entity.id);
			return;
		end

		self:BOAT_CONFLICTION_CHECK( entity );

	end,

	---------------------------------------------
	BOAT_CHASE_ATTACK = function ( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			entity:SelectPipe(0,"do_nothing");

			local vDirToTarget = {};
			SubVectors( vDirToTarget, target:GetPos(), entity:GetPos() );
			NormalizeVector( vDirToTarget );

			local t = dotproduct3d( vDirToTarget,entity:GetDirectionVector(Xaxis)); -- t>0 when the target is in the right side.

			local wingScale;
			
			if (t>0) then
				wingScale = -10.0;
			else
				wingScale =  10.0;
			end

			boatRequest2ndGunnerShoot( entity );
	
			local vFoward = {};

			FastScaleVector( vFoward, entity:GetDirectionVector(Yaxis), 12.0 );
	
			local vDestination = {};

			FastScaleVector( vDestination, entity:GetDirectionVector(Xaxis), wingScale );
			FastSumVectors( vDestination, vDestination, vFoward );
			FastSumVectors( vDestination, vDestination, target:GetPos() );

			AI.SetRefPointPosition( entity.id, vDestination );
	
			local vDirToDestination = {};
			SubVectors( vDirToDestination, AI.GetRefPointPosition(entity.id), entity:GetPos() );
			local distance = LengthVector( vDirToDestination );

			AI.CreateGoalPipe("boatChaseAttack");
			AI.PushGoal("boatChaseAttack","continuous",0,1);
			AI.PushGoal("boatChaseAttack","run",0,1);
			AI.PushGoal("boatChaseAttack","locate",0,"refpoint");
			AI.PushGoal("boatChaseAttack","approach",0,3.0,AILASTOPRES_USE);
			AI.PushGoal("boatChaseAttack","signal",0,1,"BOAT_CHASE_ATTACK_CHECK",SIGNALFILTER_SENDER);
			AI.PushGoal("boatChaseAttack","timeout",1,0.5);
			AI.PushGoal("boatChaseAttack","signal",0,1,"BOAT_CHASE_ATTACK_CHECK",SIGNALFILTER_SENDER);
			AI.PushGoal("boatChaseAttack","timeout",1,0.5);
			AI.PushGoal("boatChaseAttack","signal",0,1,"BOAT_CHASE_ATTACK_CHECK",SIGNALFILTER_SENDER);
			AI.PushGoal("boatChaseAttack","timeout",1,0.5);
			AI.PushGoal("boatChaseAttack","signal",0,1,"BOAT_CHASE_ATTACK_CHECK",SIGNALFILTER_SENDER);
			AI.PushGoal("boatChaseAttack","timeout",1,0.5);
			AI.PushGoal("boatChaseAttack","signal",0,1,"BOAT_CHASE_ATTACK",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"boatChaseAttack");
			
		else
			-- if there is no target. BOAT_ATTACK_START handles this situation.
			AI.Signal(SIGNALFILTER_SENDER, 1, "BOAT_ATTACK_START", entity.id);
		end

	end,

	---------------------------------------------
	BOAT_CHASE_ATTACK_CHECK = function ( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			local vDirToDestination = {};
			SubVectors( vDirToDestination, AI.GetRefPointPosition(entity.id), entity:GetPos() );
			if ( math.abs( vDirToDestination.x ) + math.abs( vDirToDestination.y ) < 10.0 ) then
				-- check for the distance to the destination. just in case when approach doesn't work
				AI.Signal(SIGNALFILTER_SENDER, 1, "BOAT_ESCAPE", entity.id);
				return;
			end

			local vDirFromTarget = {};
			local vTargetDirection = {};

			boat_get_target_direction( entity ,Yaxis, vTargetDirection )

			SubVectors( vDirFromTarget, entity:GetPos(), target:GetPos() );
			local distance = LengthVector( vDirFromTarget );
			local s = dotproduct3d( vDirFromTarget, vTargetDirection ); -- s>0 when the target is in the front side.
			local inFov = math.cos( 60.0 * 3.1416 / 180.0 );

			if ( distance > 20.0 and s > inFov ) then
				-- finish the attack when the boat is far away from the target, and I will show me to the player
				AI.Signal(SIGNALFILTER_SENDER, 1, "BOAT_ESCAPE", entity.id);
				return;
			end

		else
			-- if there is no target. BOAT_ATTACK_START handles this situation.
			AI.Signal(SIGNALFILTER_SENDER, 1, "BOAT_ATTACK_START", entity.id);
			return;
		end

		self:BOAT_CONFLICTION_CHECK( entity );

	end,


	--------------------------------------------------------------------------------------------------------------------
	-- behaviors against the slow target in the water
	
	BOAT_ATTACK_START = function ( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then
			
			-- if the target is on the ground, select a special behavior
			if ( AI.IsPointInWaterRegion( target:GetPos() ) < 0.5 ) then
				self:BOAT_ATTACK_SHORE_START( entity );
				return;
			end

			-- if the target is on the boat, select a special behavior
--			if ( target:IsOnVehicle() ) then
			if ( target ) then
				self:BOAT_ATTACK_BOAT( entity );
				return;			
			end

			-- to avoid shallow etc.
			if ( boat_stack_check( entity ) == true ) then
				return;
			end

			-- analize the situation

			local vDirToTarget = {};
			local vDestination = {};
			local vDestinationRot = {};
			local vRotVecSrc = {};
			local vRotVec = {};
			local rotationAngle = 0.0;

			entity:SelectPipe(0,"do_nothing");

			SubVectors( vDirToTarget, target:GetPos(), entity:GetPos() );
			NormalizeVector( vDirToTarget );

			local t = dotproduct3d( vDirToTarget,entity:GetDirectionVector(Xaxis)); -- t>0 when the target is in the right side.
			local s = dotproduct3d( vDirToTarget,entity:GetDirectionVector(Yaxis)); -- s>0 when the target is in the front side.
			local inFov = math.cos( 45.0 * 3.1416 / 180.0 );
			local distance = entity:GetDistance( target.id );

			if ( distance < 20.0 ) then 

				-- if the target is too cloth, will run away
--				self:BOAT_ESCAPE( entity );
--				return;

			end

			if ( s > inFov ) then -- caught the target in the front

				if ( distance > 80.0 ) then

					-- if the boat is far away from the target, approach.

					boatRequest2ndGunnerShoot( entity );
					AI.SetRefPointPosition( entity.id, target:GetPos() );
	
					AI.CreateGoalPipe("boatAttackApproach");
					AI.PushGoal("boatAttackApproach","continuous",0,1);
					AI.PushGoal("boatAttackApproach","run",0,0);
					AI.PushGoal("boatAttackApproach","locate",0,"refpoint");
					AI.PushGoal("boatAttackApproach","approach",0,0.1,AILASTOPRES_USE);
					AI.PushGoal("boatAttackApproach","timeout",1,3.0);
					AI.PushGoal("boatAttackApproach","signal",0,1,"BOAT_ATTACK_START",SIGNALFILTER_SENDER);
					entity:SelectPipe(0,"boatAttackApproach");
					return;

				else
				
					-- 
					entity.AI.attackCount = 0;

					boatRequest2ndGunnerShoot( entity );
					AI.SetRefPointPosition( entity.id, target:GetPos() );
					boatAdjustRefPointPosition(	entity, 5.0 );

					AI.CreateGoalPipe("boatCatchInFOV");
					AI.PushGoal("boatCatchInFOV","timeout",1,1.0);
					AI.PushGoal("boatCatchInFOV","signal",0,1,"BOAT_LINER_ATTACK",SIGNALFILTER_SENDER);
					entity:SelectPipe(0,"boatCatchInFOV");
					return;

				end

			else

				-- depending on a quadrant, boat will take different actions.

				FastScaleVector( vDestination, entity:GetDirectionVector(Yaxis), 20.0 );

				local pipename = "pipename";
				
				if ( s > 0 ) then
					if ( t > 0 ) then
						rotationAngle = -45.0 * 3.1416 / 180.0;
						pipename = "boatAttack_RightFront";
					else
						rotationAngle = 45.0 * 3.1416 / 180.0;
						pipename = "boatAttack_LeftFront";
					end
				else
					if ( t > 0 ) then
						rotationAngle = -45.0 * 3.1416 / 180.0;
						pipename = "boatAttack_RightBehind";
					else
						rotationAngle = 45.0 * 3.1416 / 180.0;
						pipename = "boatAttack_LeftBehind";
					end
				end

				local vVelocity = {};

				RotateVectorAroundR( vDestinationRot, vDestination, entity:GetDirectionVector(Zaxis), rotationAngle );

				-- (debug) checking the rotation result
				--[[ 
				local vD = {};
				CopyVector( vD, vDestinationRot );
				NormalizeVector( vD );
				local tt =dotproduct3d( vD,entity:GetDirectionVector(Yaxis));
				local ss =dotproduct3d( vD,entity:GetDirectionVector(Xaxis));
				AI.LogEvent("boat inner "..tt.."/"..ss);
				--]]
				
				FastScaleVector( vVelocity, entity:GetVelocity(), 1.5 );
				FastSumVectors( vDestinationRot, vDestinationRot, entity:GetPos() );
				FastSumVectors( vDestinationRot, vDestinationRot, vVelocity );
				AI.SetRefPointPosition( entity.id, vDestinationRot );
				
				AI.CreateGoalPipe(pipename);
				AI.PushGoal(pipename,"continuous",0,1);
				AI.PushGoal(pipename,"run",0,0);
				AI.PushGoal(pipename,"locate",0,"refpoint");
				AI.PushGoal(pipename,"approach",0,3.0,AILASTOPRES_USE);
				AI.PushGoal(pipename,"timeout",1,1.3);
				AI.PushGoal(pipename,"signal",0,1,"BOAT_ATTACK_START",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,pipename);

			end

		else
			entity:SelectPipe(0,"do_nothing");
		end

	end,

	---------------------------------------------
	BOAT_LINER_ATTACK = function ( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			if ( entity.AI.attackCount == 2 ) then
				AI.Signal(SIGNALFILTER_SENDER, 1, "BOAT_ATTACK_START", entity.id);
				return;
			end

			entity.AI.attackCount = entity.AI.attackCount + 1;

			local vDestination = {};
			local vRotVecSrc = {};
			local vRotVec = {};
			local rotationAngle = 0.0;
			local distance;

			boatRequest2ndGunnerShoot( entity );

			FastScaleVector( vRotVecSrc, entity:GetDirectionVector(Yaxis), 20.0 );
			distance = DistanceLineAndPoint( target:GetPos() , vRotVecSrc, entity:GetPos() );

			-- avoid confliction between the player
			if ( distance < 10.0 ) then
				rnd = random( 1,2 );
				local rotationAngle = 0.0;
				if ( rnd == 1 ) then
					rotationAngle =   15.0 * 3.1416 / 180.0;
				else
					rotationAngle = - 15.0 * 3.1416 / 180.0;
				end
				RotateVectorAroundR( vRotVec, vRotVecSrc, entity:GetDirectionVector(Zaxis), rotationAngle  );
				FastSumVectors( vDestination, vRotVec, entity:GetPos() );

			else

				FastSumVectors( vDestination, vRotVecSrc, entity:GetPos() );
			
			end

			entity:SelectPipe(0,"do_nothing");
			AI.SetRefPointPosition( entity.id, vDestination );
			AI.CreateGoalPipe("boatLinerAttack");
			AI.PushGoal("boatLinerAttack","continuous",0,1);
			AI.PushGoal("boatLinerAttack","run",0,0);
			AI.PushGoal("boatLinerAttack","locate",0,"refpoint");
			AI.PushGoal("boatLinerAttack","approach",0,5.0,AILASTOPRES_USE);
			AI.PushGoal("boatLinerAttack","signal",0,1,"BOAT_LINERATTACK_CHECK",SIGNALFILTER_SENDER);
			AI.PushGoal("boatLinerAttack","timeout",1,1.0);
			AI.PushGoal("boatLinerAttack","branch",1,-2);
			AI.PushGoal("boatLinerAttack","signal",0,1,"BOAT_LINER_ATTACK",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"boatLinerAttack");

		end
		
	end,

	---------------------------------------------
	BOAT_LINERATTACK_CHECK = function ( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then
	
			local vDirToDestination = {};
			SubVectors( vDirToDestination, AI.GetRefPointPosition(entity.id), entity:GetPos() );
			if ( math.abs( vDirToDestination.x ) + math.abs( vDirToDestination.y ) < 5.0 ) then
				-- check for the distance to the destination. just in case when approach doesn't work
				AI.Signal(SIGNALFILTER_SENDER, 1, "BOAT_ATTACK_START", entity.id);
				return;
			end
	
			local vDirToTarget = {};
			local distance;
			SubVectors( vDirToTarget, entity:GetPos(), target:GetPos() );
			distance = LengthVector( vDirToTarget );

			if ( distance > 80.0 ) then
				-- finish the attack when the boat is far away from the target
				AI.Signal(SIGNALFILTER_SENDER, 1, "BOAT_ATTACK_START", entity.id);
				return;
			end

			NormalizeVector( vDirToTarget );
			local s = dotproduct3d( vDirToTarget,target:GetDirectionVector(Yaxis));
			if ( s > 0  ) then 
				-- finish the attack when the boat comes to the behind of the target
				AI.Signal(SIGNALFILTER_SENDER, 1, "BOAT_ATTACK_START", entity.id);
				return;
			end

		else
			-- if there is no target. BOAT_ATTACK_START handles this situation.
			AI.Signal(SIGNALFILTER_SENDER, 1, "BOAT_ATTACK_START", entity.id);
			return;
		end

		self:BOAT_CONFLICTION_CHECK( entity );

	end,

	---------------------------------------------
	BOAT_ESCAPE = function ( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			local vEscape = {};
			local vEscapeRot = {};

			SubVectors( vEscape, entity:GetPos(), target:GetPos() );
			NormalizeVector( vEscape );
			FastScaleVector( vEscape, vEscape, 30.0 );

			local rnd = random(-2,2);
	
			RotateVectorAroundR( vEscapeRot, vEscape, entity:GetDirectionVector(Zaxis), 10.0 * rnd *3.1416 / 180.0  );
			FastSumVectors( vEscapeRot, vEscapeRot, entity:GetPos() );
			AI.SetRefPointPosition( entity.id, vEscapeRot );

			AI.CreateGoalPipe("boatEscape");
			AI.PushGoal("boatEscape","continuous",0,1);
			AI.PushGoal("boatEscape","run",0,0);
			AI.PushGoal("boatEscape","locate",0,"refpoint");
			AI.PushGoal("boatEscape","approach",0,3.0,AILASTOPRES_USE);
			AI.PushGoal("boatEscape","signal",0,1,"BOAT_CONFLICTION_CHECK",SIGNALFILTER_SENDER);
			AI.PushGoal("boatEscape","timeout",1,1.0);
			AI.PushGoal("boatEscape","signal",0,1,"BOAT_CONFLICTION_CHECK",SIGNALFILTER_SENDER);
			AI.PushGoal("boatEscape","timeout",1,1.0);
			AI.PushGoal("boatEscape","signal",0,1,"BOAT_CONFLICTION_CHECK",SIGNALFILTER_SENDER);
			AI.PushGoal("boatEscape","timeout",1,1.0);
			AI.PushGoal("boatEscape","signal",0,1,"BOAT_ATTACK_START",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"boatEscape");

		else
			-- if there is no target. BOAT_ATTACK_START handles this situation.
			AI.Signal(SIGNALFILTER_SENDER, 1, "BOAT_ATTACK_START", entity.id);
		end

	end,

	---------------------------------------------
	BOAT_CONFLICTION_CHECK = function ( self, entity )
		
		local vRotVec = {};
		local vRotVecSrc = {};
		local vDestination = {};
		local rotationAngle = 0.0;

		local vDirToDestination = {};

		for i = 1,12 do
			FastScaleVector( vRotVecSrc, entity:GetDirectionVector(Yaxis), 10.0 );
			rotationAngle = 3.1416 * 2.0 * ( i - 1.0 ) / 12.0;
			RotateVectorAroundR( vRotVec, vRotVecSrc, entity:GetDirectionVector(Zaxis), rotationAngle );
			FastSumVectors( vDestination, vRotVec, entity:GetPos() );
			if ( AI.IsPointInWaterRegion( vDestination ) > 0.5 ) then
			else
				-- if there is not enough space. BOAT_ATTACK_START handles this situation.
				AI.Signal(SIGNALFILTER_SENDER, 1, "BOAT_ATTACK_START", entity.id);
			end
		end

	end,

	--------------------------------------------------------------------------------------------------------------------
	-- behaviors against the situation the target is on the shore.

	BOAT_ATTACK_SHORE_START = function ( self, entity )
		
		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			-- make sure there is enough space to combat.

			local vRotVec = {};
			local vRotVecSrc = {};
			local vDestination = {};
			local vDirToTarget = {};
			local bFound = false;
	
			-- to avoid shallow etc.
			if ( boat_stack_check( entity ) == true ) then
				return;
			end

			local distance = entity:GetDistance(target.id);

			if ( distance > 100.0 ) then

				-- if the boat is faraway to the target, just approach to the target

				boatRequest2ndGunnerShoot( entity );
				AI.SetRefPointPosition( entity.id, target:GetPos() );
	
				AI.CreateGoalPipe("boatAttackShoreApproach");
				AI.PushGoal("boatAttackShoreApproach","continuous",0,1);
				AI.PushGoal("boatAttackShoreApproach","run",0,0);
				AI.PushGoal("boatAttackShoreApproach","locate",0,"refpoint");
				AI.PushGoal("boatAttackShoreApproach","approach",0,3.0,AILASTOPRES_USE);
				AI.PushGoal("boatAttackShoreApproach","timeout",1,4.0);
				AI.PushGoal("boatAttackShoreApproach","signal",0,1,"BOAT_ATTACK_START",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"boatAttackShoreApproach");
				return;

			else

				rotationAngle = 45.0 * 3.1416 / 180.0 ;
				SubVectors( vRotVecSrc,  entity:GetPos(), target:GetPos() );
				NormalizeVector( vRotVecSrc );
				FastScaleVector( vRotVecSrc, vRotVecSrc, distance + 5.0 );

				for i = 1,7 do
					RotateVectorAroundR( vRotVec, vRotVecSrc, entity:GetDirectionVector(Zaxis), rotationAngle );
					FastSumVectors( vDestination, vRotVec, target:GetPos() );
					if ( AI.IsPointInWaterRegion( vDestination ) > 0.5 ) then
						bFound = true;
						break;
					end
					rotationAngle = rotationAngle + ( 45.0 * 3.1416 /180.0 ) ;
				end

				if ( distance < 30.0 or bFound == false ) then
					
					NormalizeVector( vRotVecSrc );
--					FastScaleVector( vRotVecSrc, vRotVecSrc, distance + 20.0 );
					FastSumVectors( vRotVecSrc, vRotVecSrc, target:GetPos() );			
					AI.SetRefPointPosition( entity.id, vRotVecSrc );
	
					AI.CreateGoalPipe("boatAttackShoreGoAway");
					AI.PushGoal("boatAttackShoreGoAway","continuous",0,1);
					AI.PushGoal("boatAttackShoreGoAway","run",0,0);
					AI.PushGoal("boatAttackShoreGoAway","locate",0,"refpoint");
					AI.PushGoal("boatAttackShoreGoAway","approach",0,3.0,AILASTOPRES_USE);
					AI.PushGoal("boatAttackShoreGoAway","timeout",1,1.0);
					AI.PushGoal("boatAttackShoreGoAway","signal",0,1,"BOAT_CONFLICTION_CHECK",SIGNALFILTER_SENDER);
					AI.PushGoal("boatAttackShoreGoAway","branch",1,-2);
					AI.PushGoal("boatAttackShoreGoAway","signal",0,1,"BOAT_ATTACK_START",SIGNALFILTER_SENDER);
					entity:SelectPipe(0,"boatAttackShoreGoAway");
					return;

				else
				
					boatRequest2ndGunnerShoot( entity );
					FastSumVectors( vRotVec, vRotVec, target:GetPos() );			
					AI.SetRefPointPosition( entity.id, vRotVec );
	
					AI.CreateGoalPipe("boatAttackShoreStrafe");
					AI.PushGoal("boatAttackShoreStrafe","continuous",0,1);
					AI.PushGoal("boatAttackShoreStrafe","run",0,0);
					AI.PushGoal("boatAttackShoreStrafe","locate",0,"refpoint");
					AI.PushGoal("boatAttackShoreStrafe","approach",0,3.0,AILASTOPRES_USE);
					AI.PushGoal("boatAttackShoreStrafe","timeout",1,1.0);
					AI.PushGoal("boatAttackShoreStrafe","signal",0,1,"BOAT_CONFLICTION_CHECK",SIGNALFILTER_SENDER);
					AI.PushGoal("boatAttackShoreStrafe","branch",1,-2);
					AI.PushGoal("boatAttackShoreStrafe","signal",0,1,"BOAT_ATTACK_START",SIGNALFILTER_SENDER);
					entity:SelectPipe(0,"boatAttackShoreStrafe");
					return;
				
				end

			end


		end

	end,


	--------------------------------------------------------------------------------------------------------------------
	OnNoTarget = function( self, entity )
		CopyVector( entity.AI.vPatrollPosition, entity:GetPos() );
		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_BOAT_ALERT", entity.id);
	end,

	---------------------------------------------
	-- CUSTOM
	---------------------------------------------

	---------------------------------------------
	REFPOINT_REACHED = function( self, entity, sender )
	end,

	--------------------------------------------
	GO_TO = function( self, entity, fDistance )
	end,

	--------------------------------------------
	ACT_GOTO = function( self, entity )
	end,

}
