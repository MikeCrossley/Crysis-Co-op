--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: 
--  "switch path" behaviour for the tank
--------------------------------------------------------------------------
--  History:
--  - 05/06/2007   : Duplicated by Tetsuji
--
--------------------------------------------------------------------------


AIBehaviour.TankCloseSwitchPath = {
	Name = "TankCloseSwitchPath",
	alertness = 0,

	---------------------------------------------------------------------------------------------------------------------------------------
	Constructor = function( self, entity )
	end,

	ACT_DUMMY = function( self, entity, sender, data )

		self:TANKCLOSE_SWITCHPATH( entity, data );

	end,

	------------------------------------------------------------------------------------------
	TANKCLOSE_SWITCHPATH = function( self, entity,  data )

		entity:SelectPipe(0,"do_nothing");

		local segno = -1;
		
		if ( entity.AI.tankClosePathName ) then
			segno = AI.GetPathSegNoOnPath( entity.id, entity.AI.tankClosePathName, entity:GetPos() )
		end

		if ( segno == nil or segno < 0 ) then
			AI.CreateGoalPipe("tankclose_switchpathfailed");
			AI.PushGoal("tankclose_switchpathfailed","signal",0,1,"TO_TANKCLOSE_IDLE",SIGNALFILTER_SENDER);
			entity:InsertSubpipe(AIGOALPIPE_SAMEPRIORITY,"switchpathfailed",nil,data.iValue);
			return;
		end

		AI.SetPathToFollow( entity.id, entity.AI.tankClosePathName);

		local vTmp ={};
		CopyVector( vTmp, AI.GetPointOnPathBySegNo( entity.id, entity.AI.tankClosePathName, 0 ) );
		AI.SetRefPointPosition( entity.id, vTmp );

		AI.CreateGoalPipe("tankclose_switchpath");
		AI.PushGoal("tankclose_switchpath","run",0,2);
		AI.PushGoal("tankclose_switchpath","followpath", 0, false, false, true, 0, 0, false );
		AI.PushGoal("tankclose_switchpath","+locate",0,"refpoint");
		AI.PushGoal("tankclose_switchpath","+approach",1,10.0,AILASTOPRES_USE,10.0);
		AI.PushGoal("tankclose_switchpath","signal",1,1,"TO_TANKCLOSE_ATTACK",SIGNALFILTER_SENDER);
		entity:InsertSubpipe(AIGOALPIPE_SAMEPRIORITY,"tankclose_switchpath",nil,data.iValue);

	end,


}

