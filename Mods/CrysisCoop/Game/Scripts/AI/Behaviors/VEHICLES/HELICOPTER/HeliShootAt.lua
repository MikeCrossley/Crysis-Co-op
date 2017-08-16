--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: 
--  "ShootAt" behaviour for the helicopter
--------------------------------------------------------------------------
--  History:
--  - 30/07/2006   : Created by Tetsuji
--
--------------------------------------------------------------------------
local Xaxis =0;
local Yaxis =1;
local Zaxis =2;

AIBehaviour.HeliShootAt = {
	Name = "HeliShootAt",
	alertness = 0,

	--------------------------------------------------------------------------
	-- hover and wait until the helicopter gets stable condition.

	HELI_HOVER_WAIT_STABLE = function( self, entity )

		local vPos ={};
		CopyVector( vPos, entity:GetVelocity() );
		local length = LengthVector( vPos );

		if ( length >2.0 ) then
			length = 2.0;
		end

		FastScaleVector( vPos, vPos, length );
		FastSumVectors( vPos, vPos, entity:GetPos() );

		AI.SetRefPointPosition( entity.id, vPos );

		AI.CreateGoalPipe("heliHoverWaitStable");
		AI.PushGoal("heliHoverWaitStable","run",0,0);		
		AI.PushGoal("heliHoverWaitStable","continuous",0,0);		
		AI.PushGoal("heliHoverWaitStable","locate",0,"refpoint");		
		AI.PushGoal("heliHoverWaitStable","approach",0,1.0,AILASTOPRES_USE,0);
		AI.PushGoal("heliHoverWaitStable","timeout",1,2.5);
		entity:InsertSubpipe(0,"heliHoverWaitStable");
			
	end,

	--------------------------------------------------------------------------
	HELI_HOVER_START_AIMING = function( self, entity )

			local myPos ={};
			local enemyPos ={};
			local vPos = {};
			
			CopyVector( myPos, entity:GetPos() );
			CopyVector( enemyPos, entity.AI.shootAtPoint );
			SubVectors( vPos, enemyPos, myPos );

			vPos.z =0;

			local distance = LengthVector( vPos );
			local idealheight = distance * math.sin( 25.0 * 3.1415 / 180.0 );
			local actuallheight = math.abs( myPos.z - enemyPos.z );
			local newposz;

			if ( actuallheight > idealheight ) then
				if ( myPos.z > enemyPos.z ) then
					newposz = enemyPos.z + idealheight ;
				else
					newposz = enemyPos.z - idealheight ;
				end

				CopyVector( myPos, entity:GetPos() );
				--AI.LogEvent(" adjust position "..myPos.z..">"..newposz);
				myPos.z = newposz;
				myPos.x = myPos.x;
				myPos.y = myPos.y;
				AI.SetRefPointPosition( entity.id, myPos );
				AIBehaviour.HELIDEFAULT:heliAdjustRefPoint( entity, 10.0 );

				local heightDifference = math.abs( actuallheight - idealheight );
		
				AI.CreateGoalPipe("heliAdjustShootPoint");
				AI.PushGoal("heliAdjustShootPoint","run",0,0);		
				AI.PushGoal("heliAdjustShootPoint","continuous",0,0);		
				AI.PushGoal("heliAdjustShootPoint","timeout",1,0.5);
				AI.PushGoal("heliAdjustShootPoint","locate",0,"refpoint");		
				AI.PushGoal("heliAdjustShootPoint","approach",1,5.0,AILASTOPRES_USE,-1);
				AI.PushGoal("heliAdjustShootPoint","timeout",1,0.5);
				AI.PushGoal("heliAdjustShootPoint","signal",1,1,"HELI_HOVER_START_AIMING_NEXT",SIGNALFILTER_SENDER);
				entity:InsertSubpipe(0,"heliAdjustShootPoint");
					

			else
				self:HELI_HOVER_START_AIMING_NEXT( entity );
			end

	end,

	HELI_HOVER_START_AIMING_NEXT = function( self, entity )

		local vPos = {};
		local vDir = {};
		entity.AI.aimingCounter = 0;

		SubVectors( vDir, entity.AI.shootAtPoint, entity:GetPos() );
		NormalizeVector( vDir );
		local dot = dotproduct3d( vDir, entity:GetDirectionVector(Zaxis) );
		entity.AI.lastDot = dot;

		FastScaleVector( vPos, entity:GetDirectionVector(Yaxis), 30.0  );
		FastSumVectors( vPos, vPos, entity:GetPos() );
		AI.SetRefPointPosition( entity.id, vPos );

		AI.CreateGoalPipe("heliShootMissile");
		AI.PushGoal("heliShootMissile","run",0,0);		
		AI.PushGoal("heliShootMissile","continuous",0,1);		
		AI.PushGoal("heliShootMissile","locate",0,"refpoint");		
		AI.PushGoal("heliShootMissile","approach",0,0.01,AILASTOPRES_USE,-1);
		AI.PushGoal("heliShootMissile","signal",1,1,"HELI_HOVER_SET_TARGET",SIGNALFILTER_SENDER);
		AI.PushGoal("heliShootMissile","locate",0,"refpoint");
		AI.PushGoal("heliShootMissile","acqtarget",0,"");
		AI.PushGoal("heliShootMissile","firecmd",0,FIREMODE_FORCED);
		AI.PushGoal("heliShootMissile","timeout",1,0.3);		
		AI.PushGoal("heliShootMissile","signal",1,1,"HELI_HOVER_AIMING_CHECK",SIGNALFILTER_SENDER);
		AI.PushGoal("heliShootMissile","firecmd",0,0);
		entity:InsertSubpipe(0,"heliShootMissile");

	end,

	HELI_HOVER_AIMING_CHECK = function( self, entity )

		entity.AI.aimingCounter =entity.AI.aimingCounter + 1;
		
		if ( entity.AI.aimingCounter < 10 ) then
		
			local vDir ={};
			
			SubVectors( vDir, entity.AI.shootAtPoint, entity:GetPos() );
			NormalizeVector( vDir );
			local dot = dotproduct3d( vDir, entity:GetDirectionVector(Zaxis) );
			local inFOV = math.cos( 90.0 * 3.1415 / 180.0 );
			--AI.LogEvent("DOT "..dot);
			if ( dot > entity.AI.lastDot and dot < inFOV ) then
				AI.CreateGoalPipe("heliAimingCheck");
				AI.PushGoal("heliAimingCheck","timeout",1,0.1);		
				AI.PushGoal("heliAimingCheck","signal",1,1,"HELI_HOVER_AIMING_CHECK",SIGNALFILTER_SENDER);
				entity:InsertSubpipe(0,"heliAimingCheck");
			end
			entity.AI.lastDot = dot;
		end

	end,

	HELI_HOVER_SET_TARGET = function( self, entity )

		AI.SetRefPointPosition( entity.id, entity.AI.shootAtPoint );

	end,

	HELI_SET_LOOKAT = function( self, entity )

		AI.SetRefPointPosition( entity.id, entity.AI.shootAtPoint );
		AI.CreateGoalPipe("helisetlookat");
		AI.PushGoal("helisetlookat","locate",0,"refpoint");		
		AI.PushGoal("helisetlookat","lookat",0,0,0,true,1);
		entity:InsertSubpipe(0,"helisetlookat");

	end,

	HELI_HOVER_END = function( self, entity )

		local vRef = {};
		CopyVector( vRef, entity:GetDirectionVector(Xaxis) );
		if ( dotproduct3d( vRef, entity.AI.shootVelocity ) > 0 ) then
			FastScaleVector( vRef, entity:GetDirectionVector(Xaxis), 40.0 );
		else
			FastScaleVector( vRef, entity:GetDirectionVector(Xaxis), -40.0 );
		end
--		FastSumVectors( vRef, vRef, entity:GetDirectionVector(Zaxis) );
--		FastSumVectors( vRef, vRef, entity:GetDirectionVector(Zaxis) );
		FastSumVectors( vRef, vRef, entity:GetDirectionVector(Yaxis) );
		FastSumVectors( vRef, vRef, entity:GetDirectionVector(Yaxis) );
		FastSumVectors( vRef, vRef, entity:GetDirectionVector(Yaxis) );
		FastSumVectors( vRef, vRef, entity:GetDirectionVector(Yaxis) );
		FastSumVectors( vRef, vRef, entity:GetDirectionVector(Yaxis) );
		FastSumVectors( vRef, vRef, entity:GetDirectionVector(Yaxis) );
		FastSumVectors( vRef, vRef, entity:GetPos() );
		AI.SetRefPointPosition( entity.id, vRef );

		AI.CreateGoalPipe("heliHoverEnd");
		AI.PushGoal("heliHoverEnd","+locate",0,"refpoint");		
		AI.PushGoal("heliHoverEnd","+approach",1,3,AILASTOPRES_USE,10);
--		AI.PushGoal("heliHoverEnd","timeout",1,1.5);
		entity:InsertSubpipe(0,"heliHoverEnd");

	end,


}

