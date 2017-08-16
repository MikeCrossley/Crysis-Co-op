

AIBehaviour.CarSkid = {
	Name = "CarSkid",

	---------------------------------------------
	Constructor = function( self, entity, sender, data )

		entity.AI.followVectors = { 
			{ x = 0.0, y = 0.0, z = 0.0 }, -- vectors[1].(x,y,z)
			{ x = 0.0, y = 0.0, z = 0.0 }, -- vectors[2].(x,y,z)
			{ x = 0.0, y = 0.0, z = 0.0 }, -- vectors[3].(x,y,z)
			{ x = 0.0, y = 0.0, z = 0.0 }, -- vectors[4].(x,y,z)
			{ x = 0.0, y = 0.0, z = 0.0 }, -- vectors[5].(x,y,z)
			{ x = 0.0, y = 0.0, z = 0.0 }, -- vectors[6].(x,y,z)
			{ x = 0.0, y = 0.0, z = 0.0 }, -- vectors[7].(x,y,z)
			{ x = 0.0, y = 0.0, z = 0.0 }, -- vectors[8].(x,y,z)
		}

	end,
	
	ACT_DUMMY = function( self, entity, sender, data )
		self:CAR_SKID_START( entity, data );
	end,

	---------------------------------------------
	Destructor = function ( self, entity, data )

	end,
	
	---------------------------------------------
	CAR_SKID_START = function( self, entity, data )

		entity.AI.tagCounter = 1;

		AI.CreateGoalPipe("carSkidMain");
		AI.PushGoal("carSkidMain","run",0,2);
		AI.PushGoal("carSkidMain","signal",1,1,"CAR_SKID_ACTION1",SIGNALFILTER_SENDER);
		AI.PushGoal("carSkidMain","signal",1,1,"TO_CAR_IDLE",SIGNALFILTER_SENDER);
		entity:InsertSubpipe(0,"carSkidMain",nil,data.iValue);

	end,

	CAR_SKID_ACTION1 = function( self, entity )

		local vUp = { x = 0.0, y = 0.0, z = 1.0 };
		local vDir = {};
		local vWng = {};
		local vPos = {};

	
		SubVectors( vDir, entity.AI.vSkidDestination, entity:GetPos() );
		NormalizeVector( vDir );

		FastSumVectors( vPos, entity:GetPos(), vDir );
		CopyVector( entity.AI.followVectors[1], vPos );

		crossproduct3d( vWng, vDir, vUp );
		NormalizeVector( vWng );
		FastScaleVector( vWng, vWng, 5.0 );

		FastScaleVector( vPos, vDir, -30.0 );
		FastSumVectors( vPos, vPos, entity.AI.vSkidDestination );

		CopyVector( entity.AI.followVectors[2], vPos );

		FastScaleVector( vPos, vDir, -15.0 );
		FastSumVectors( vPos, vPos, vWng );
		FastSumVectors( vPos, vPos, entity.AI.vSkidDestination );
		CopyVector( entity.AI.followVectors[3], vPos );
		CopyVector( entity.AI.followVectors[4], entity.AI.vSkidDestination );

		FastScaleVector( vPos, vDir, 0 );
		FastScaleVector( vWng, vWng, -0.4 );
		FastSumVectors( vPos, vPos, vWng );

		FastSumVectors( vPos, vPos, entity.AI.vSkidDestination );
		CopyVector( entity.AI.followVectors[5], vPos );

		AI.SetPointListToFollow( entity.id, entity.AI.followVectors, 5 , false , NAV_ROAD );

		AI.CreateGoalPipe("carskid");
		AI.PushGoal("carskid","continuous",0,1);	
		AI.PushGoal("carskid","run",0,2);
		AI.PushGoal("carskid","followpath",1, false, false, true, 0, -1, true );
		entity:SelectPipe(0,"carskid");

	end,

}
