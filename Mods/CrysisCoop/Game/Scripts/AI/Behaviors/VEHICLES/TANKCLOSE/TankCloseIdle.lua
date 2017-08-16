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
--  - 10/07/2006   : Duplicated by Tetsuji
--
--------------------------------------------------------------------------


AIBehaviour.TankCloseIdle = {
	Name = "TankCloseIdle",
	Base = "VehicleIdle",	
	alertness = 0,

	---------------------------------------------
	Constructor = function(self , entity )

		AI.SetAdjustPath(entity.id,1);
		entity.AI.vDefultPos = {};
		CopyVector ( entity.AI.vDefultPos, entity:GetPos() );
		-- entity.AI.tankClosePathId = "defaultpathname";
		-- entity.AI.tankClosePathName = "defaultpath";

		AIBehaviour.VehicleIdle:Constructor( entity );
		if ( entity.AIMovementAbility.pathType == AIPATH_BOAT ) then
	    AI.ChangeParameter(entity.id,AIPARAM_SIGHTENVSCALE_NORMAL,0.25 * 1.1);
	    AI.ChangeParameter(entity.id,AIPARAM_SIGHTENVSCALE_ALARMED,0.50 * 1.1);
		else
			AI.ChangeParameter(entity.id,AIPARAM_SIGHTENVSCALE_NORMAL,0.70);
			AI.ChangeParameter(entity.id,AIPARAM_SIGHTENVSCALE_ALARMED,0.85);
		end

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then
			self:OnPlayerSeen( entity, 0 );
		end

	end,
	-----------------------------------------------------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )

		AI.CreateGoalPipe("tankclose_findplayer");
		AI.PushGoal("tankclose_findplayer","timeout",1,0.5);
		AI.PushGoal("tankclose_findplayer","signal",1,1,"TO_TANKCLOSE_ATTACK",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"tankclose_findplayer");
	
	end,

	---------------------------------------------
	-- to give a pathname for the pathfollow
	TANKCLOSE_PATHNAME = function( self, entity, sender, data )

		if ( data and  data.ObjectName ) then
			entity.AI.tankClosePathName =  data.ObjectName;
		end

	end,

	ACT_FOLLOWPATH = function( self, entity, sender, data )

		AI.SetPathAttributeToFollow( entity.id, true );

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

	TO_TANKCLOSE_GOTOPATH = function( self, entity, sender, data )

		AI.LogEvent(entity:GetName().." TO_TANKCLOSE_GOTOPATH "..data.point.x..","..data.point.y..","..data.point.z);

		entity.AI.vPatrollPos = {};
		CopyVector( entity.AI.vPatrollPos , data.point );

	end,

	TO_TANKCLOSE_SWITCHPATH = function( self, entity, sender, data )

		if ( data and  data.ObjectName ) then
			entity.AI.tankClosePathName =  data.ObjectName;
		end
		--System.Log("switch to "..entity.AI.tankClosePathName );

	end,

	TO_TANKCLOSE_PATROL = function( self, entity, sender, data )

		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_TANKCLOSE_ATTACK", entity.id);

	end,

	TO_TANKCLOSE_RUNAWAY = function( self, entity, sender, data )

		if ( data and data.id ) then
			entity.AI.runAwayId =  data.id;
		end

	end,

}
