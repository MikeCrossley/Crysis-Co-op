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
--  - 04/09/2006   : Duplicated by Tetsuji
--
--------------------------------------------------------------------------


AIBehaviour.TankCloseGotoPath = {
	Name = "TankCloseGotoPath",
	alertness = 0,

	---------------------------------------------------------------------------------------------------------------------------------------
	Constructor = function( self, entity )
	end,

	ACT_DUMMY = function( self, entity, sender, data )

		entity.AI.bMemoryCount = 0;
		entity.AI.shootCounter =0;
		entity.AI.bShootNexttime = false;
		entity.AI.bUseMachineGun = false;
		entity.AI.lastAnchor = nil;

		entity.AI.bIsLoopPath =false;

		entity.AI.vMemoryPos = {};
		entity.AI.vLastPos = {};
		entity.AI.vLastPosHeSaw = {};

		entity.AI.vFollowTarget ={};
		entity.AI.FollowTimeOut = 0;
		entity.AI.FollowTimeOut2 = 0;

		CopyVector( entity.AI.vMemoryPos, entity:GetPos() );
		CopyVector( entity.AI.vLastPos, entity:GetPos() );
		CopyVector( entity.AI.vLastPosHeSaw,  entity:GetPos() );
		entity.AI.patrollPoint = 0;
		
		self:TANKCLOSE_GOTOPATH(  entity, data  );

	end,

	---------------------------------------------------------------------------------------------------------------------------------------
	OnBulletRain = function ( self, entity, sender )	

	end,

	---------------------------------------------
	OnEnemyDamage = function( self, entity, sender, data )

	end,

	------------------------------------------------------------------------------------------
	TANKCLOSE_CALCULATE_METRIC = function( self, entity, enemySegNo, mySegNo )

		if ( entity.AI.bIsLoopPath == true ) then
	
			local es = enemySegNo;
	
			if ( es < mySegNo ) then
				es = es + 100.0;
			end				

			if ( es - mySegNo < 50.0 ) then
				return false;
			end	

		else
			if ( enemySegNo > mySegNo ) then
				return false;
			end		
		end
		
		return true;

	end,

	------------------------------------------------------------------------------------------
	TANKCLOSE_GOTOPATH = function( self, entity,  data )

		if ( entity.AI.tankClosePathName==nil or AI.GetPathSegNoOnPath( entity.id, entity.AI.tankClosePathName, entity:GetPos() ) < 0 ) then
			AI.Warning( entity:GetName().." can't get a path to follow" );
			AI.CreateGoalPipe("tankclose_____________error");
			AI.PushGoal("tankclose_____________error","timeout",1,30.0);
			entity:SelectPipe(0,"tankclose_____________error",nil,data.iValue);
			return;
		end

		entity.AI.bIsLoopPath = AI.GetPathLoop( entity.id, entity.AI.tankClosePathName );

		AI.CreateGoalPipe("tankclose_gotopath");
		AI.PushGoal("tankclose_gotopath","signal",1,1,"TANKCLOSE_GOTOPATH_SUB",SIGNALFILTER_SENDER);
		AI.PushGoal("tankclose_gotopath","signal",1,1,"TANKCLOSE_WAITSPEED_ZERO",SIGNALFILTER_SENDER);
		AI.PushGoal("tankclose_gotopath","signal",1,1,"TO_TANKCLOSE_IDLE",SIGNALFILTER_SENDER);
		entity:InsertSubpipe(0,"tankclose_gotopath",nil,data.iValue);

	end,

	TANKCLOSE_GOTOPATH_SUB = function( self, entity ) 

		local segno = -1;
		
		if ( entity.AI.tankClosePathName ) then
			segno = AI.GetPathSegNoOnPath( entity.id, entity.AI.tankClosePathName, entity:GetPos() )
		end

		if ( segno == nil or segno < 0 ) then
			return;
		end

		local vTmp2 = {};
		FastScaleVector( vTmp2, entity:GetDirectionVector(1), 7.0 );
		FastSumVectors( vTmp2, vTmp2, entity:GetPos() );
		local fwdSegNo		= AI.GetPathSegNoOnPath( entity.id, entity.AI.tankClosePathName, vTmp2 );
		local mySegNo			= AI.GetPathSegNoOnPath( entity.id, entity.AI.tankClosePathName, entity:GetPos() )
		entity.AI.bIsLoopPath = AI.GetPathLoop( entity.id, entity.AI.tankClosePathName );

		-----------------------------------------

		local vMyPathPos = {};
		local vTargetPathPos = {};

		local vTmp = {};
		CopyVector( vTmp, entity.AI.vPatrollPos );

		local mySegNo			= AI.GetPathSegNoOnPath( entity.id, entity.AI.tankClosePathName, entity:GetPos() );
		local enemySegNo	= AI.GetPathSegNoOnPath( entity.id, entity.AI.tankClosePathName, vTmp );

		CopyVector( vMyPathPos,	AI.GetNearestPointOnPath( entity.id, entity.AI.tankClosePathName, entity:GetPos() ) );
		CopyVector( vTargetPathPos, AI.GetNearestPointOnPath( entity.id, entity.AI.tankClosePathName, vTmp ) );

		CopyVector( entity.AI.vFollowTarget, vTargetPathPos );
		AI.SetPathToFollow( entity.id, entity.AI.tankClosePathName);

		entity.AI.FollowTimeOut = 0;
		entity.AI.FollowTimeOut2 = 0;

		local bReverse = self:TANKCLOSE_CALCULATE_METRIC( entity, enemySegNo, mySegNo );

		AI.SetPathToFollow( entity.id, entity.AI.tankClosePathName);
		AI.SetPathAttributeToFollow( entity.id, true );
		AI.CreateGoalPipe("tankclose_gotopathsub");

		if ( entity.AIMovementAbility and entity.AIMovementAbility.pathType == AIPATH_BOAT ) then
			AI.PushGoal("tankclose_gotopathsub","run",0,0);
		elseif ( bReverse == true ) then
			AI.PushGoal("tankclose_gotopathsub","run",0,-2);
		else
			AI.PushGoal("tankclose_gotopathsub","run",0,0);
		end

		AI.PushGoal("tankclose_gotopathsub","continuous",0,0);	
		if ( entity.AI.bIsLoopPath == true ) then
			AI.PushGoal("tankclose_gotopathsub","followpath", 0, false, bReverse, true, 3, 0, false );
		else
			AI.PushGoal("tankclose_gotopathsub","followpath", 0, false, bReverse, true, 0, 0, false );
		end
		AI.PushGoal("tankclose_gotopathsub","signal",1,1,"TANKCLOSE_CHECK_POS",SIGNALFILTER_SENDER);
		AI.PushGoal("tankclose_gotopathsub","timeout",1,0.1);
		AI.PushGoal("tankclose_gotopathsub","branch",1,-2,BRANCH_ALWAYS);
		entity:InsertSubpipe(0,"tankclose_gotopathsub");

	end,

	TANKCLOSE_CHECK_POS = function( self, entity )

		if ( entity.AIMovementAbility and entity.AIMovementAbility.pathType == AIPATH_BOAT ) then
			local vSrc = {};
			local vDst = {};
			CopyVector( vSrc, AI.GetNearestPointOnPath( entity.id, entity.AI.tankClosePathName, entity:GetPos() ) );
			CopyVector( vDst, AI.GetNearestPointOnPath( entity.id, entity.AI.tankClosePathName, entity.AI.vFollowTarget ) );
			SubVectors( vSrc, vDst, vSrc );
			if ( LengthVector( vSrc )< 5.0 ) then
				entity:CancelSubpipe();			
			end
			return;
		end

		local distToTarget = DistanceVectors( entity.AI.vFollowTarget, entity:GetPos() );
		if ( distToTarget < 5.0 ) then
			entity:CancelSubpipe();
		end

	end,

	TANKCLOSE_WAITSPEED_ZERO = function( self, entity )

		if ( entity:GetSpeed() > 0.5 ) then

			AI.CreateGoalPipe("tankclose_gotopathwait");
			AI.PushGoal("tankclose_gotopathwait","timeout",1,1.0);
			AI.PushGoal("tankclose_gotopathwait","signal",1,1,"TANKCLOSE_WAITSPEED_ZERO",SIGNALFILTER_SENDER);
			entity:InsertSubpipe(0,"tankclose_gotopathwait");

		end

	end,
	
}

