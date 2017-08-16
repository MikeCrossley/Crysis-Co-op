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
--  - 06/02/2005   : Created by Kirill Bulatsev
--  - 30/07/2007   : Duplicated by Tetsuji
--
--------------------------------------------------------------------------


AIBehaviour.TankCloseRunAway = {
	Name = "TankCloseRunAway",
	alertness = 0,

	---------------------------------------------------------------------------------------------------------------------------------------
	Constructor = function( self, entity )
	end,

	ACT_DUMMY = function( self, entity, sender, data )
		
		self:TANKCLOSE_RUNAWAY( entity, data );

	end,

	---------------------------------------------------------------------------------------------------------------------------------------
	TANKCLOSE_RUNAWAY = function( self, entity, data )

		if ( entity.AI.runAwayId == nil ) then
			AI.LogEvent(entity:GetName().."TankCloseRunAway : no runaway point is specified ");
			entity:CancelSubpipe();
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_TANKCLOSE_IDLE", entity.id);
			return;
		end

		local runAwayEntity = System.GetEntity( entity.AI.runAwayId );
		if ( runAwayEntity ) then
		else
			AI.LogEvent(entity:GetName().."TankCloseRunAway : no runaway entity is specified ");
			entity:CancelSubpipe();
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_TANKCLOSE_IDLE", entity.id);
			return;
		end

		local segno = -1;
		if ( entity.AI.tankClosePathName ) then
			segno = AI.GetPathSegNoOnPath( entity.id, entity.AI.tankClosePathName, entity:GetPos() );
		end

		if ( segno < 0 ) then
			AI.LogEvent(entity:GetName().."TankCloseRunAway : no ai path");
			entity:CancelSubpipe();
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_TANKCLOSE_IDLE", entity.id);
			return;
		end

		entity:SelectPipe(0,"do_nothing");

		entity.AI.bIsLoopPath = AI.GetPathLoop( entity.id, entity.AI.tankClosePathName );
		entity.AI.bRunAwayFailed = false;

		local runawayObject = System.GetEntity( entity.AI.runAwayId );

		AI.CreateGoalPipe("tankCloseRunAway");
		AI.PushGoal("tankCloseRunAway","signal",1,1,"TANKCLOSE_RUNAWAY1",SIGNALFILTER_SENDER);
		AI.PushGoal("tankCloseRunAway","signal",1,1,"TANKCLOSE_RUNAWAY2",SIGNALFILTER_SENDER);
		AI.PushGoal("tankCloseRunAway","timeout",1,1.0);
		AI.PushGoal("tankCloseRunAway","signal",1,1,"TANKCLOSE_RUNAWAY_END",SIGNALFILTER_SENDER);
		AI.PushGoal("tankCloseRunAway","signal",1,1,"TO_TANKCLOSE_IDLE",SIGNALFILTER_SENDER);
		entity:InsertSubpipe(AIGOALPIPE_SAMEPRIORITY,"tankCloseRunAway",nil,data.iValue);

	
	end,

	---------------------------------------------------------------------------------------------------------------------------------------
	TANKCLOSE_RUNAWAY_END = function( self, entity )

		if ( entity.AI.bRunAwayFailed == true ) then
			entity:CancelSubpipe();
		end

	end,

	---------------------------------------------------------------------------------------------------------------------------------------
	TANKCLOSE_RUNAWAY1 = function( self, entity, data )

		local runAwayEntity = System.GetEntity( entity.AI.runAwayId );
		if ( runAwayEntity ) then

			local vMyPathPos = {};
			local vTargetPathPos = {};
	
			local mySegNo			= AI.GetPathSegNoOnPath( entity.id, entity.AI.tankClosePathName, entity:GetPos() );
			local enemySegNo	= AI.GetPathSegNoOnPath( entity.id, entity.AI.tankClosePathName, runAwayEntity:GetPos() );
	
			CopyVector( vMyPathPos,	AI.GetNearestPointOnPath( entity.id, entity.AI.tankClosePathName, entity:GetPos() ) );
			CopyVector( vTargetPathPos, AI.GetNearestPointOnPath( entity.id, entity.AI.tankClosePathName, runAwayEntity:GetPos() ) );

			entity.AI.vFollowTarget ={};
			CopyVector( entity.AI.vFollowTarget, vTargetPathPos );
			AI.SetPathToFollow( entity.id, entity.AI.tankClosePathName);
			AI.SetPathAttributeToFollow( entity.id, true );
	
			entity.AI.FollowTimeOut = 0;
			entity.AI.FollowTimeOut2 = 0;
			local bReverse = self:TANKCLOSE_CALCULATE_METRIC( entity, enemySegNo, mySegNo );

			local pipename = "tankclose_runaway";
			AI.CreateGoalPipe(pipename);
			AI.PushGoal(pipename,"run",0,0);
			AI.PushGoal(pipename,"continuous",0,0);	

			if ( entity.AI.bIsLoopPath == true ) then
				AI.PushGoal(pipename,"followpath", 0, false, bReverse, true, 3, 0, false );
			else
				AI.PushGoal(pipename,"followpath", 0, false, bReverse, true, 0, 0, false );
			end
			AI.PushGoal(pipename,"signal",1,1,"TANKCLOSE_CHECK_POS",SIGNALFILTER_SENDER);
			AI.PushGoal(pipename,"timeout",1,0.1);
			AI.PushGoal(pipename,"branch",1,-2);
			entity:InsertSubpipe(AIGOALPIPE_SAMEPRIORITY,pipename);

		end

	end,

	---------------------------------------------------------------------------------------------------------------------------------------
	TANKCLOSE_RUNAWAY2 = function( self, entity, data )

		local runAwayEntity = System.GetEntity( entity.AI.runAwayId );
		if ( runAwayEntity ) then

			entity.AI.followVectors = { 
				{ x = 0.0, y = 0.0, z = 0.0 }, -- vectors[1].(x,y,z)
				{ x = 0.0, y = 0.0, z = 0.0 }, -- vectors[2].(x,y,z)
				{ x = 0.0, y = 0.0, z = 0.0 }, -- vectors[3].(x,y,z)
				{ x = 0.0, y = 0.0, z = 0.0 } -- vectors[4].(x,y,z)
			};
	
			CopyVector( entity.AI.followVectors[1], entity:GetPos() );
			FastSumVectors( entity.AI.followVectors[2], entity:GetPos(), runAwayEntity:GetPos() );
			FastScaleVector( entity.AI.followVectors[2], entity.AI.followVectors[2], 0.5 );
			CopyVector( entity.AI.followVectors[3], runAwayEntity:GetPos() );

			CopyVector( entity.AI.vFollowTarget, runAwayEntity:GetPos() );

			entity:TriggerEvent(AIEVENT_CLEARACTIVEGOALS);
			AI.SetPointListToFollow( entity.id, entity.AI.followVectors, 3 , true );

			local pipename = "tankclose_runaway2";

			AI.CreateGoalPipe(pipename);
			AI.PushGoal(pipename,"run",0,0);
			AI.PushGoal(pipename,"continuous",0,0);	
			AI.PushGoal(pipename,"followpath", 0, false, false, false, 0, -1, true );
			AI.PushGoal(pipename,"signal",1,1,"TANKCLOSE_CHECK_POS2",SIGNALFILTER_SENDER);
			AI.PushGoal(pipename,"timeout",1,0.1);
			AI.PushGoal(pipename,"branch",1,-2);
			entity:InsertSubpipe(AIGOALPIPE_SAMEPRIORITY,pipename);
	
		end

	end,

	---------------------------------------------------------------------------------------------------------------------------------------
	TANKCLOSE_CALCULATE_METRIC = function( self, entity, enemySegNo, mySegNo )

		if ( entity.AI.bIsLoopPath == true ) then
	
			if ( enemySegNo < mySegNo ) then
				enemySegNo = enemySegNo + 100.0;
			end				

			if ( enemySegNo - mySegNo < 50.0 ) then
				return false;
			end	

		else
			if ( enemySegNo > mySegNo ) then
				return false;
			end		
		end
		
		return true;

	end,

	---------------------------------------------
	TANKCLOSE_CHECK_POS = function( self, entity )

		if ( entity:GetSpeed()< 1.0 ) then
			entity.AI.FollowTimeOut2 = entity.AI.FollowTimeOut2 + 1;
		else
			entity.AI.FollowTimeOut2 = 0;
		end

		local distToTarget = DistanceVectors( entity.AI.vFollowTarget, entity:GetPos() );
		if ( distToTarget < 10.0 ) then
			entity:CancelSubpipe();
			return;
		end

		if ( entity.AI.FollowTimeOut2 > 5 ) then
			entity:CancelSubpipe();
			return;
		end
		
	end,

	---------------------------------------------
	TANKCLOSE_CHECK_POS2 = function( self, entity )

		if ( entity:GetSpeed()< 1.0 ) then
			entity.AI.FollowTimeOut2 = entity.AI.FollowTimeOut2 + 1;
		else
			entity.AI.FollowTimeOut2 = 0;
		end

		if ( entity.AI.FollowTimeOut2 > 5 ) then
			entity:CancelSubpipe();
			return;
		end

		if ( self:TANKCLOSE_OBSTACLE_CHECK( entity, entity.AI.vFollowTarget )==false ) then
			entity.AI.bRunAwayFailed = true;
			entity:CancelSubpipe();
			return;
		end
		
	end,

	--------------------------------------------------------------------------
	TANKCLOSE_OBSTACLE_CHECK = function( self, entity, vVec )

		local vSrc ={};
		local vDst ={};
		local vTmp ={};
		
		CopyVector( vSrc, entity:GetPos() );
		CopyVector( vDst, vVec );

		SubVectors( vTmp, vDst, vSrc );
		vTmp.z =0;

		if ( LengthVector( vTmp ) > 120.0 ) then
			return true;
		end

		local i;
		local targetEntity;
		local entities = System.GetPhysicalEntitiesInBox( vDst , 10.0 );

		if (entities) then

			for i,targetEntity in ipairs(entities) do
				local objEntity = targetEntity;
				if (objEntity.id ~= entity.id ) then
					local bbmin,bbmax = objEntity:GetLocalBBox();
					if ( DistanceVectors( bbmin , bbmax ) >  3.0 or objEntity:GetMass() > 300.0 ) then
						return false;
					end
				end
			end

		end	

		return true;

	end,

}
