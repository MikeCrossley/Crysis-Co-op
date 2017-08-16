--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2005.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: patrolboat combat Behaviour SCRIPT
--  
--------------------------------------------------------------------------
--  History:
--  - 25/07/2005   : Created by Kirill Bulatsev
--
--------------------------------------------------------------------------

local		fPATROLBOAT_ATTACK2_DONOTHING = 0;
local 	fPATROLBOAT_ATTACK2 = 1;
local		fPATROLBOAT_ATTACK2_FULLBREAKING = 2;
local		fPATROLBOAT_ATTACK2_PARALELLMOVE = 3;
local		fPATROLBOAT_ATTACK2_GOINGBACK = 4;
local		fPATROLBOAT_ATTACK2_GOINGBACK2 = 5;

local 	minUpdateTime = 0.4;
--------------------------------------------------------------------------
local function patrolboatRequest2ndGunnerShoot( entity )

	for i,seat in pairs(entity.Seats) do
		if( seat.passengerId ) then
			local member = System.GetEntity( seat.passengerId );
			if( member ~= nil ) then
			
			  if (seat.isDriver) then
			  else
					local seatId = entity:GetSeatId(member.id);
			  	if ( seat.seat:GetWeaponCount() > 0) then
						bFound = true;
						g_SignalData.fValue = 400.0;
						AI.ChangeParameter( member.id, AIPARAM_STRAFINGPITCH, 30.0 );
						AI.Signal(SIGNALFILTER_SENDER, 1, "INVEHICLEGUNNER_REQUEST_SHOOT", member.id, g_SignalData);
						return true;
					end
				end
			
			end
		end
	end	

	return false;

end

AIBehaviour.PatrolBoatAttack2 = {
	Name = "PatrolBoatAttack2",
	alertness = 2,

	------------------------------------------------------------------------------------------
	-- SYSTEM HANDLERS
	------------------------------------------------------------------------------------------
	Constructor = function( self, entity )

		AI.CreateGoalPipe("patrollboat_____________error");
		AI.PushGoal("patrollboat_____________error","timeout",1,3.0);

		if ( entity.AI.patrollBoatPathNameMain == nil or entity.AI.patrollBoatPathNameSub == nil ) then
			AI.Warning( entity:GetName().." can't get a path to follow ");
			entity:SelectPipe(0,"patrollboat_____________error");
			return;
		end

		local segNoMain = AI.GetPathSegNoOnPath( entity.id, entity.AI.patrollBoatPathNameMain, entity:GetPos() )
		local segNoSub = AI.GetPathSegNoOnPath( entity.id, entity.AI.patrollBoatPathNameSub, entity:GetPos() )
		if ( segNoMain < 0 and segNoSub < 0 ) then
			AI.Warning( entity:GetName().." can't get a path to follow "..segNoMain..","..segNoSub );
			entity:SelectPipe(0,"patrollboat_____________error");
			return;
		end

		entity.AI.boatTimer			= Script.SetTimerForFunction( minUpdateTime *1000, "AIBehaviour.PatrolBoatAttack2.PATROLBOAT_ATTACK2_UPDATE", entity );
		entity.AI.deltaTSystem	= System.GetCurrTime();
		entity.AI.circleSec			= System.GetCurrTime();

		entity.AI.vTargetRsv		= {};
		entity.AI.vMyPosRsv			= {};
		entity.AI.vDirectionRsv	= {};

		CopyVector( entity.AI.vTargetRsv, entity:GetPos() );
		CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );

		entity.AI.CurrentHook = fPATROLBOAT_ATTACK2_DONOTHING;

		-- start shooting
		patrolboatRequest2ndGunnerShoot( entity );
		entity.AI.bRotDirec = true;

		AI.CreateGoalPipe("patrolboatDefault");
		AI.PushGoal("patrolboatDefault","timeout",1,0.3);
		AI.PushGoal("patrolboatDefault","signal",0,1,"PATROLBOAT_ATTACK2_START",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"patrolboatDefault");

	end,

	---------------------------------------------
	Destructor = function ( self, entity, data )

		-- called when the behaviour is de-selected
		-- the extra data is from the signal that is causing the behavior transition

		entity:SelectPipe(0,"do_nothing");
		AI.SetForcedNavigation( entity.id, entity.AI.vZero );
		Script.KillTimer(entity.AI.boatTimer);

	end,


	------------------------------------------------------------------------------------------
	PATROLBOAT_ATTACK2_DONOTHING = function( self, entity )

		
		
	end,

	------------------------------------------------------------------------------------------
	PATROLBOAT_ATTACK2_UPDATE = function( entity )

		if ( entity.AI.boatTimer == nil ) then
			return;
		end

		entity.AI.boatTimer = Script.SetTimerForFunction( minUpdateTime *1000, "AIBehaviour.PatrolBoatAttack2.PATROLBOAT_ATTACK2_UPDATE", entity );
		local t = entity.AI.deltaTSystem;
		entity.AI.deltaTSystem = System.GetCurrTime();

		if ( entity.AI.deltaTSystem - t < minUpdateTime * 0.8 ) then
			return;
		end

		if (     entity.AI.CurrentHook == fPATROLBOAT_ATTACK2_DONOTHING ) then
			AIBehaviour.PatrolBoatAttack2:PATROLBOAT_ATTACK2_DONOTHING( entity );
		elseif ( entity.AI.CurrentHook == fPATROLBOAT_ATTACK2 ) then
			AIBehaviour.PatrolBoatAttack2:PATROLBOAT_ATTACK2( entity );
		elseif ( entity.AI.CurrentHook == fPATROLBOAT_ATTACK2_FULLBREAKING ) then
			AIBehaviour.PatrolBoatAttack2:PATROLBOAT_ATTACK2_FULLBREAKING( entity );
		elseif ( entity.AI.CurrentHook == fPATROLBOAT_ATTACK2_PARALELLMOVE ) then
			AIBehaviour.PatrolBoatAttack2:PATROLBOAT_ATTACK2_PARALELLMOVE( entity );
		elseif ( entity.AI.CurrentHook == fPATROLBOAT_ATTACK2_GOINGBACK ) then
			AIBehaviour.PatrolBoatAttack2:PATROLBOAT_ATTACK2_GOINGBACK( entity );
		elseif ( entity.AI.CurrentHook == fPATROLBOAT_ATTACK2_GOINGBACK2 ) then
			AIBehaviour.PatrolBoatAttack2:PATROLBOAT_ATTACK2_GOINGBACK2( entity );
		end

	end,

	------------------------------------------------------------------------------------------
	OnGroupMemberDied = function( self, entity, sender )
	end,	

	-----------------------------------------------------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
	end,

	--------------------------------------------------------------------------
	OnBulletRain = function ( self, entity, sender, data )	

		self:OnEnemyDamage( entity, sender, data );
		
	end,

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender, data )
	end,

	--------------------------------------------------------------------------
	OnNoTarget = function( self, entity )
		AI.SetForcedNavigation( entity.id, entity.AI.vZero );
	end,

	------------------------------------------------------------------------------------------
	OnSomethingSeen = function( self, entity )
	end,
	
	------------------------------------------------------------------------------------------
	OnEnemyMemory = function( self, entity, fDistance )
	end,
	
	------------------------------------------------------------------------------------------
	OnTargetTooClose = function( self, entity, sender, data )
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

	------------------------------------------------------------------------------------------
	-- common function
	------------------------------------------------------------------------------------------

	PATROLBOAT_ATTACK2_CHECKCLEARANCE = function( self, entity, vDestination, height )

		local vDir = {};
		SubVectors( vDir, vDestination, entity:GetPos() );
		local length = LengthVector( vDir );

		local count = length / 3.0;
		
		FastScaleVector( vDir, vDir, 3.0 / length );
		local vCheckPoint = {};

		CopyVector( vCheckPoint, entity:GetPos() );


		for i= 1,count do
			FastSumVectors( vCheckPoint, vCheckPoint, vDir );
			if ( AI.IsPointInWaterRegion( vCheckPoint ) < height ) then
				return false;
			end
		end

		local vUp = { x=0.0, y=0.0, z=1.0 };
		local vWng = {};
		local vFwd = {};
		CopyVector( vFwd, vDir );
		NormalizeVector( vFwd );

		crossproduct3d( vWng, vFwd, vUp );
		FastScaleVector( vWng, vWng, 3.0 );

		CopyVector( vCheckPoint, entity:GetPos() );

		FastSumVectors( vCheckPoint, vCheckPoint, vWng );

		for i= 1,count do
			FastSumVectors( vCheckPoint, vCheckPoint, vDir );
			if ( AI.IsPointInWaterRegion( vCheckPoint ) < height ) then
				return false;
			end
		end

		CopyVector( vCheckPoint, entity:GetPos() );

		SubVectors( vCheckPoint, vCheckPoint, vWng );
		for i= 1,count do
			FastSumVectors( vCheckPoint, vCheckPoint, vDir );
			if ( AI.IsPointInWaterRegion( vCheckPoint ) < height ) then
				return false;
			end
		end

		return true;

	end,
	
	------------------------------------------------------------------------------------------
	-- Behaviors
	------------------------------------------------------------------------------------------
	PATROLBOAT_ATTACK2_START = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) == true ) then

			patrolboatRequest2ndGunnerShoot( entity );

			entity.AI.circleSec = System.GetCurrTime();
			entity.AI.deltaT = System.GetCurrTime();
			CopyVector( entity.AI.vTargetRsv, target:GetPos() );
			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );

			entity.AI.scaleFactor = 26.0;
	
			entity.AI.CurrentHook = fPATROLBOAT_ATTACK2;
			entity:SelectPipe(0,"do_nothing");
	
			self:PATROLBOAT_ATTACK2( entity );

		end
		
	end,
	
	PATROLBOAT_ATTACK2 = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) == true ) then

			local vVel = {};
			local vVelRot = {};
			local vWng = {};
			local vFwd = {};
			local vDist = {};
			local vActualVel = {};
			local vTmp = {};
			local distanceToTheTarget = 0;
			local Speed = 0;

			SubVectors( vFwd, target:GetPos(), entity:GetPos() );
			vFwd.z =0;
			distanceToTheTarget = LengthVector( vFwd );
			NormalizeVector( vFwd );

			entity:GetVelocity( vActualVel );
			Speed = LengthVector( vActualVel );

			if ( Speed > 5.0 ) then
				FastScaleVector( vTmp, vActualVel, 5.0 );
				NormalizeVector( vActualVel );
			else
				NormalizeVector( vActualVel );
				FastScaleVector( vTmp, vActualVel, 5.0 );
			end
			FastSumVectors( vTmp, vTmp, entity:GetPos() );

			if ( self:PATROLBOAT_ATTACK2_CHECKCLEARANCE( entity, vTmp, 1.5 ) == false ) then
				entity.AI.scaleFactor = entity.AI.scaleFactor - 2.0 ;
			else
				entity.AI.scaleFactor = entity.AI.scaleFactor + 1.0;
			end

			if ( entity.AI.scaleFactor > 26.0 ) then
				entity.AI.scaleFactor = 26.0;
			end

			if ( entity.AI.scaleFactor < 0.0 ) then
				AI.Signal(SIGNALFILTER_SENDER,1,"PATROLBOAT_ATTACK2_GOINGBACK2_START", entity.id);
				return;
			end
		
			if ( distanceToTheTarget < 60.0 ) then
				if ( self:PATROLBOAT_ATTACK2_CHECKCLEARANCE( entity, target:GetPos(), 1.5 ) == false ) then
					AI.Signal(SIGNALFILTER_SENDER,1,"PATROLBOAT_ATTACK2_GOINGBACK_START", entity.id);
					return;
				end
				if ( dotproduct3d( entity:GetDirectionVector(1), target:GetDirectionVector(1) ) > math.cos( 30.0 * 3.1416  / 120.0  ) ) then
					AI.Signal(SIGNALFILTER_SENDER,1,"PATROLBOAT_ATTACK2_PARALELLMOVE_START", entity.id);
					return;
				end
			end
		
			CopyVector( vWng, entity:GetDirectionVector(0) );
			CopyVector( vVel, entity:GetDirectionVector(1) );

			local dot = dotproduct3d( vFwd, vWng );
			local dot2 = dotproduct3d( vFwd, vVel );
			local dot3 = dotproduct3d( entity:GetDirectionVector(1), vActualVel );
			
			if ( dot3 < 0 ) then
				dot3 = 0;
			end			

			local deltaT = System.GetCurrTime() -  entity.AI.deltaT;
			if (deltaT > 1.0 ) then
				deltaT = 1.0;
			end
			entity.AI.deltaT = System.GetCurrTime();

			local actionAngle = math.acos( dot2 );
			if ( actionAngle > 3.1416* 45.0 / 180.0 ) then
				actionAngle = 3.1416* 45.0 / 180.0;
			end

			FastScaleVector( vVel, vVel, entity.AI.scaleFactor * ( ( math.abs( dot2 ) + 1.0 ) )* 0.5 + 1.0 );

			if ( dot2 >  math.cos( 30.0 * 3.1416  / 180.0  ) ) then
				CopyVector( vVelRot, vVel );
			else
				if ( dot>0 ) then
					RotateVectorAroundR( vVelRot, vVel, entity.AI.vUp, -1.0 * actionAngle );
				else
					RotateVectorAroundR( vVelRot, vVel, entity.AI.vUp, actionAngle );
				end
			end

			AI.SetForcedNavigation( entity.id, vVelRot );

		end

	end,

	------------------------------------------------------------------------------------------
	PATROLBOAT_ATTACK2_FULLBREAKING_START = function( self, entity )

		patrolboatRequest2ndGunnerShoot( entity );

		entity.AI.CurrentHook = fPATROLBOAT_ATTACK2_FULLBREAKING;
		entity:SelectPipe(0,"do_nothing");
	
		self:PATROLBOAT_ATTACK2_FULLBREAKING( entity );

	end,

	PATROLBOAT_ATTACK2_FULLBREAKING = function( self, entity )
	
		local vActualVel = {};
		
		entity:GetVelocity( vActualVel );
		FastScaleVector( vActualVel, vActualVel, 0 );
		AI.SetForcedNavigation( entity.id, vActualVel );

	end,

	------------------------------------------------------------------------------------------
	PATROLBOAT_ATTACK2_PARALELLMOVE_START = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) == true ) then

			patrolboatRequest2ndGunnerShoot( entity );

			entity.AI.circleSec = System.GetCurrTime();
			entity.AI.deltaT = System.GetCurrTime();
			CopyVector( entity.AI.vTargetRsv, target:GetPos() );
			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );

			entity.AI.scaleFactor = 26.0;
	
			entity.AI.CurrentHook = fPATROLBOAT_ATTACK2_PARALELLMOVE;
			entity:SelectPipe(0,"do_nothing");
	
			self:PATROLBOAT_ATTACK2_PARALELLMOVE( entity );

		end

	end,
	
	PATROLBOAT_ATTACK2_PARALELLMOVE = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) == true ) then

			local vVel = {};
			local vVelRot = {};
			local vWng = {};
			local vFwd = {};
			local vDist = {};
			local vActualVel = {};
			local vTmp = {};
			local distanceToTheTarget = 0;
			local Speed = 0;

			SubVectors( vFwd, target:GetPos(), entity:GetPos() );
			vFwd.z =0;
			distanceToTheTarget = LengthVector( vFwd );
			NormalizeVector( vFwd );

			entity:GetVelocity( vActualVel );
			Speed = LengthVector( vActualVel );

			if ( Speed > 5.0 ) then
				FastScaleVector( vTmp, vActualVel, 5.0 );
				NormalizeVector( vActualVel );
			else
				NormalizeVector( vActualVel );
				FastScaleVector( vTmp, vActualVel, 5.0 );
			end
			FastSumVectors( vTmp, vTmp, entity:GetPos() );

			if ( self:PATROLBOAT_ATTACK2_CHECKCLEARANCE( entity, vTmp, 1.5 ) == false ) then
				AI.Signal(SIGNALFILTER_SENDER,1,"PATROLBOAT_ATTACK2_GOINGBACK_START", entity.id);
				return;
			end

			entity.AI.scaleFactor =  target:GetSpeed() + 7.0;
			if ( entity.AI.scaleFactor > 26.0 ) then
				entity.AI.scaleFactor = 26.0;
			end

			if ( entity.AI.scaleFactor < 10.0 ) then
				entity.AI.scaleFactor = 1.0;
			end
		
			if ( distanceToTheTarget > 80.0 ) then
				AI.Signal(SIGNALFILTER_SENDER,1,"PATROLBOAT_ATTACK2_START", entity.id);
				return;
			end
		
			CopyVector( vWng, entity:GetDirectionVector(0) );
			CopyVector( vVel, entity:GetDirectionVector(1) );

			local dot = dotproduct3d( target:GetDirectionVector(1), vWng );
			local dot2 = dotproduct3d( target:GetDirectionVector(1), vVel );
			local dot3 = dotproduct3d( entity:GetDirectionVector(1), vActualVel );
			
			if ( dot3 < 0 ) then
				dot3 = 0;
			end			

			local deltaT = System.GetCurrTime() -  entity.AI.deltaT;
			if (deltaT > 1.0 ) then
				deltaT = 1.0;
			end
			entity.AI.deltaT = System.GetCurrTime();

			local actionAngle = math.acos( dot2 );
			if ( actionAngle > 3.1416* 45.0 / 180.0 ) then
				actionAngle = 3.1416* 45.0 / 180.0;
			end

			FastScaleVector( vVel, vVel, entity.AI.scaleFactor * ( ( math.abs( dot2 ) + 1.0 ) )* 0.5 + 1.0 );

			if ( dot2 >  math.cos( 30.0 * 3.1416  / 180.0  ) ) then
				CopyVector( vVelRot, vVel );
			else
				if ( dot>0 ) then
					RotateVectorAroundR( vVelRot, vVel, entity.AI.vUp, -1.0 * actionAngle );
				else
					RotateVectorAroundR( vVelRot, vVel, entity.AI.vUp, actionAngle );
				end
			end

			AI.SetForcedNavigation( entity.id, vVelRot );

		end

	end,

	------------------------------------------------------------------------------------------
	PATROLBOAT_ATTACK2_GOINGBACK_START = function( self, entity )

		--CopyVector( entity.AI.vTargetRsv,	AI.GetNearestPointOnPath( entity.id, entity.AI.patrollBoatPathNameMain, entity:GetPos() ) );
		patrolboatRequest2ndGunnerShoot( entity );
		entity.AI.circleSec = System.GetCurrTime();

		FastScaleVector( entity.AI.vDirectionRsv, entity:GetDirectionVector(1), -1.0 );
		entity.AI.CurrentHook = fPATROLBOAT_ATTACK2_GOINGBACK;
		entity:SelectPipe(0,"do_nothing");
	
		self:PATROLBOAT_ATTACK2_GOINGBACK( entity );

	end,


	PATROLBOAT_ATTACK2_GOINGBACK = function( self, entity )

		local vTmp = {};
		
		FastScaleVector( vTmp, entity:GetDirectionVector(1), 30.0 );
		
		if (  System.GetCurrTime() - entity.AI.circleSec > 3.0 ) then
			FastSumVectors( vTmp, vTmp, entity:GetPos() );
			if ( self:PATROLBOAT_ATTACK2_CHECKCLEARANCE( entity, vTmp, 1.5 ) == true ) then
				AI.Signal(SIGNALFILTER_SENDER,1,"PATROLBOAT_ATTACK2_GOINGBACK2_START", entity.id);
				return;
			end
		end

		FastScaleVector( vTmp, entity.AI.vDirectionRsv, 10.0 );
		FastSumVectors( vTmp, vTmp, entity:GetPos() );
		if ( self:PATROLBOAT_ATTACK2_CHECKCLEARANCE( entity, vTmp, 1.5 ) == false ) then
			AI.Signal(SIGNALFILTER_SENDER,1,"PATROLBOAT_ATTACK2_FULLBREAKING_START", entity.id);
			return;
		end
		
		FastScaleVector( vTmp, entity.AI.vDirectionRsv, 8.0 );
		AI.SetForcedNavigation( entity.id, vTmp );

	end,

	------------------------------------------------------------------------------------------
	PATROLBOAT_ATTACK2_GOINGBACK2_START = function( self, entity )

		--CopyVector( entity.AI.vTargetRsv,	AI.GetNearestPointOnPath( entity.id, entity.AI.patrollBoatPathNameMain, entity:GetPos() ) );
		patrolboatRequest2ndGunnerShoot( entity );
		entity.AI.circleSec = System.GetCurrTime();

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) == true ) then

			SubVectors( entity.AI.vDirectionRsv, entity:GetPos(), target:GetPos() );
			NormalizeVector( entity.AI.vDirectionRsv );

			entity.AI.CurrentHook = fPATROLBOAT_ATTACK2_GOINGBACK2;
			entity:SelectPipe(0,"do_nothing");
	
			self:PATROLBOAT_ATTACK2_GOINGBACK2( entity );

		end

	end,


	PATROLBOAT_ATTACK2_GOINGBACK2 = function( self, entity )

		local vTmp = {};

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) == true ) then

			SubVectors( vTmp, target:GetPos(), entity:GetPos() );
			vTmp.z =0;
			local distanceToTheTarget = LengthVector( vTmp );
			if ( distanceToTheTarget < 80.0 ) then
				AI.SetForcedNavigation( entity.id, entity.AI.vZero );
				entity.AI.circleSec = System.GetCurrTime();
				return;
			end
		
			if (  System.GetCurrTime() - entity.AI.circleSec > 5.0 ) then
					AI.Signal(SIGNALFILTER_SENDER,1,"PATROLBOAT_ATTACK2", entity.id);
					return;
			end
	
			FastScaleVector( vTmp, entity.AI.vDirectionRsv, 10.0 );
			FastSumVectors( vTmp, vTmp, entity:GetPos() );
			if ( self:PATROLBOAT_ATTACK2_CHECKCLEARANCE( entity, vTmp, 0.5 ) == false ) then
				AI.Signal(SIGNALFILTER_SENDER,1,"PATROLBOAT_ATTACK2_FULLBREAKING_START", entity.id);
				return;
			end
			
			FastScaleVector( vTmp, entity.AI.vDirectionRsv, 12.0 );
			AI.SetForcedNavigation( entity.id, vTmp );

		end

	end,


}
