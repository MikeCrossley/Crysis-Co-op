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
--  - 18/05/2005   : Created by Tetsuji Iwasaki
--
--------------------------------------------------------------------------

--------------------------------------------------------------------------
local Xaxis = 0;
local Yaxis = 1;
local Zaxis = 2;

--------------------------------------------------------------------------
AIBehaviour.BoatAlert = {
	Name = "BoatAlert",
	alertness = 1,

	-- SYSTEM EVENTS			-----
	---------------------------------------------
	Constructor = function(self , entity )

		entity.AI.vPositionRsv = {};
		CopyVector( entity.AI.vPositionRsv, entity:GetPos() );

		entity.AI.alertPos = {};

		entity.AI.patrollsw = 0;
		entity.AI.blockSignal = false;
		self:BOAT_ALERT_PATROLL_START( entity );

	end,
	
	---------------------------------------------
	BOAT_ALERT_PATROLL_START = function( self, entity )

		local distance1 = DistanceVectors( entity:GetPos(), entity.AI.vSafePosition );
		local distance2 = DistanceVectors( entity:GetPos(), entity.AI.vPatrollPosition  );
	
		if ( math.abs( DistanceVectors( entity.AI.vPatrollPosition, entity.AI.vSafePosition ) ) < 1.0 ) then
			-- Patroll points are inappropriate because a distance is too close.
			-- Just stay there.
			entity:SelectPipe(0,"do_nothing");
			return;
		end

		if ( distance1 > distance2 ) then
			entity.AI.patrollsw =1;
		else
			entity.AI.patrollsw =0;
		end
	
		self:BOAT_ALERT_PATROLL( entity );

	end,

	---------------------------------------------
	BOAT_ALERT_PATROLL = function( self, entity )
	
		entity.AI.blockSignal = false;
	
		local vDestination = {};
		local vRotVecSrc = {};
		local vRotVec = {};
		local vCheck = {};
		local rotationAngle = 0.0;

		entity:SelectPipe(0,"do_nothing");

		-- make sure there is enough space to patroll.
		local bFound = false;
		local vSpaceDir = {};

		vSpaceDir.x = 0.0;
		vSpaceDir.y = 0.0;
		vSpaceDir.z = 0.0;
			
		for i = 1,12 do
			FastScaleVector( vRotVecSrc, entity:GetDirectionVector(Yaxis), 15.0 );
			rotationAngle = 3.1416 * 2.0 * ( i - 1.0 ) / 12.0;
			RotateVectorAroundR( vRotVec, vRotVecSrc, entity:GetDirectionVector(Zaxis), rotationAngle );
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
				FastScaleVector( vDestination, entity:GetDirectionVector(Yaxis), 15.0 );
				FastSumVectors( vDestination, vDestination, entity:GetPos() );
				
				AI.SetRefPointPosition( entity.id, vDestination );
				AI.CreateGoalPipe("boatIamStuck");
				AI.PushGoal("boatIamStuck","continuous",0,1);
				AI.PushGoal("boatIamStuck","locate",0,"refpoint");
				AI.PushGoal("boatIamStuck","approach",0,3.0,AILASTOPRES_USE);
				AI.PushGoal("boatIamStuck","timeout",1,3.0);
				AI.PushGoal("boatIamStuck","signal",0,1,"BOAT_ATTACK_START",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"boatIamStuck");
				return;

			else
	
				-- go to get enough space.
				NormalizeVector( vSpaceDir );
				FastScaleVector( vSpaceDir, vSpaceDir, 15.0 );
				FastSumVectors( vDestination, vSpaceDir, entity:GetPos() );

				AI.SetRefPointPosition( entity.id, vDestination );
				AI.CreateGoalPipe("boatGoToSpace");
				AI.PushGoal("boatGoToSpace","continuous",0,1);
				AI.PushGoal("boatGoToSpace","locate",0,"refpoint");
				AI.PushGoal("boatGoToSpace","approach",0,3.0,AILASTOPRES_USE);
				AI.PushGoal("boatGoToSpace","timeout",1,4.0);
				AI.PushGoal("boatGoToSpace","signal",0,1,"BOAT_ATTACK_START",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"boatGoToSpace");
				return;

			end
	
			local vPatrollDestination ={};
			if ( entity.AI.patrollsw == 0 ) then
				entity.AI.patrollsw = 1;
				CopyVector( vPatrollDestination, entity.AI.vSafePosition );
			else
				entity.AI.patrollsw = 0;
				CopyVector( vPatrollDestination, entity.AI.vPositionRsv );
			end

			AI.SetRefPointPosition( entity.id, vPatrollDestination );
			AI.CreateGoalPipe("boatAlertPatroll");
			AI.PushGoal("boatAlertPatroll","continuous",0,1);
			AI.PushGoal("boatAlertPatroll","locate",0,"refpoint");
			AI.PushGoal("boatAlertPatroll","approach",0,5.0,AILASTOPRES_USE);
			AI.PushGoal("boatAlertPatroll","signal",0,1,"BOAT_ALERT_CONFLICTION_CHECK",SIGNALFILTER_SENDER);
			AI.PushGoal("boatAlertPatroll","timeout",1,2.0);
			AI.PushGoal("boatAlertPatroll","branch",1,-2);
			AI.PushGoal("boatAlertPatroll","signal",0,1,"BOAT_ALERT_PATROLL",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"boatAlertPatroll");

		end
	
	end,

	---------------------------------------------
	BOAT_ALERT_APPROACH = function ( self, entity )

			AI.SetRefPointPosition( entity.id, entity.AI.alertPos );
			AI.CreateGoalPipe("boatAlertApproach");
			AI.PushGoal("boatAlertApproach","continuous",0,1);
			AI.PushGoal("boatAlertApproach","locate",0,"refpoint");
			AI.PushGoal("boatAlertApproach","approach",0,5.0,AILASTOPRES_USE);
			AI.PushGoal("boatAlertApproach","signal",0,1,"BOAT_ALERT_CONFLICTION_CHECK",SIGNALFILTER_SENDER);
			AI.PushGoal("boatAlertApproach","timeout",1,1.0);
			AI.PushGoal("boatAlertApproach","branch",1,-2);
			AI.PushGoal("boatAlertApproach","signal",0,1,"BOAT_ALERT_PATROLL",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"boatAlertApproach");

	end,
	
	---------------------------------------------
	BOAT_ALERT_CONFLICTION_CHECK = function ( self, entity )
		
		local vRotVec = {};
		local vRotVecSrc = {};
		local vDestination = {};
		local rotationAngle = 0.0;

		local vDirToDestination = {};

		SubVectors( vDirToDestination, AI.GetRefPointPosition(entity.id), entity:GetPos() );
		if ( math.abs( vDirToDestination.x ) + math.abs( vDirToDestination.y ) < 5.0 ) then
			-- check for the distance to the destination. just in case when approach doesn't work
			AI.Signal(SIGNALFILTER_SENDER, 1, "BOAT_ALERT_PATROLL", entity.id);
			return;
		end

		for i = 1,12 do
			FastScaleVector( vRotVecSrc, entity:GetDirectionVector(Yaxis), 10.0 );
			rotationAngle = 3.1416 * 2.0 * ( i - 1.0 ) / 12.0;
			RotateVectorAroundR( vRotVec, vRotVecSrc, entity:GetDirectionVector(Zaxis), rotationAngle );
			FastSumVectors( vDestination, vRotVec, entity:GetPos() );
			if ( AI.IsPointInWaterRegion( vDestination ) > 0.5 ) then
			else
				-- BOAT_ALERT_PATROLL handles this situation
				AI.Signal(SIGNALFILTER_SENDER, 1, "BOAT_ALERT_PATROLL", entity.id);
			end
		end
	
	end,
	---------------------------------------------------------------------------------------------------------------------------------------
	OnBulletRain = function ( self, entity, sender )	

		-- called when there are bullet impacts nearby

		if ( entity.AI.blockSignal==true ) then
			return;
		end

		local senderEntity =System.GetEntity( sender.id );
		if ( senderEntity ) then
			CopyVector( entity.AI.alertPos, senderEntity:GetPos() );
			self:BOAT_ALERT_APPROACH( entity );
		else
			-- just in case when we can't get an entity
		end

	end,

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender, data )

		-- called when AI is damaged by an enemy AI
		-- data.id = damaging enemy's entity id
		-- local hitter = System.GetEntity(data.id);
		-- local hitterName = hitter:GetName()

		if ( entity.AI.blockSignal==true ) then
			return;
		end

		local senderEntity =System.GetEntity( data.id );
		if ( senderEntity ) then
			CopyVector( entity.AI.alertPos, senderEntity:GetPos() );
			self:BOAT_ALERT_APPROACH( entity );
		else
			-- just in case when we can't get an entity
		end
	
	end,

	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_BOAT_ATTACK", entity.id);
	end,
	
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
