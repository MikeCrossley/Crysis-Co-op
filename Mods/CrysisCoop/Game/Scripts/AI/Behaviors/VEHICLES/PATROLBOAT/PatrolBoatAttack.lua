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

AIBehaviour.PatrolBoatAttack = {
	Name = "PatrolBoatAttack",
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

		AI.CreateGoalPipe("patrollboat_attack_start");
		AI.PushGoal("patrollboat_attack_start","timeout",1,0.5);
		AI.PushGoal("patrollboat_attack_start","signal",0,1,"PATROLBOAT_INIT",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"patrollboat_attack_start");

		entity.AI.shootCounter =0;
		entity.AI.bShootNexttime = false;

		entity.AI.vMemoryPos = {};
		entity.AI.vFollowTarget ={};

		entity.AI.FollowTimeOut = 0;
		entity.AI.FollowTimeOut2 = 0;

		entity.AI.bBlockSignal = false;

		CopyVector( entity.AI.vMemoryPos, entity:GetPos() );

	end,
	------------------------------------------------------------------------------------------
	PATROLBOAT_INIT = function( self, entity )

		if ( entity.AI.bGotShoot == true ) then

			entity.AI.bGotShoot = false;
			g_SignalData.id = entity.AI.GotShootId;

			if ( self:OnEnemyDamage( entity , self, g_SignalData ) == false ) then
				self:PATROLBOAT_ATTACK_START( entity );
			end

		else
	
			self:PATROLBOAT_ATTACK_START( entity );

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

		local targetEntity
		if ( data and data.id ) then
			targetEntity = System.GetEntity( data.id );
		else
			return false;
		end

		local currentTargetEntity = AI.GetAttentionTargetEntity( entity.id );
		if ( currentTargetEntity and AI.Hostile( entity.id, currentTargetEntity.id ) ) then
		else
			return false;
		end

		if ( entity.AI.bBlockSignal == false ) then
			entity.AI.bBlockSignal = true;
		else
			return false;
		end

		local vPos = {}
		SubVectors( vPos, targetEntity:GetPos(), entity:GetPos() );

		local length = LengthVector( vPos );
		local objective = 100;

		for i=1,4 do

			if ( length > objective ) then
		
				length = objective;

				NormalizeVector( vPos );
				FastScaleVector( vPos, vPos, length );
				FastSumVectors( vPos, vPos, entity:GetPos() );
		
				if ( self:PATROLBOAT_CHECKCLEARANCE( entity, vPos ) == true ) then
					entity.AI.FollowTimeOut = 0;
					entity.AI.FollowTimeOut2 = 0;
					CopyVector( entity.AI.vFollowTarget, vPos );
					AI.SetRefPointPosition( entity.id , vPos );
					AI.CreateGoalPipe("patrollboat_turn2");
					AI.PushGoal("patrollboat_turn2","run",0,0);	
					AI.PushGoal("patrollboat_turn2","continuous",0,0);
					AI.PushGoal("patrollboat_turn2","locate",0,"refpoint");		
					AI.PushGoal("patrollboat_turn2","approach",0,5.0,AILASTOPRES_USE,0.0);	
					AI.PushGoal("patrollboat_turn2","signal",1,1,"PATROLBOAT_CHECK_TIMEOUT",SIGNALFILTER_SENDER);
					AI.PushGoal("patrollboat_turn2","timeout",1,0.1);
					AI.PushGoal("patrollboat_turn2","branch",1,-2);
					AI.PushGoal("patrollboat_turn2","timeout",1,3.0);
					AI.PushGoal("patrollboat_turn2","signal",0,1,"PATROLBOAT_ATTACK_START",SIGNALFILTER_SENDER);
					entity:InsertSubpipe(0,"patrollboat_turn2");
					return true;
				end

			end
	
			objective = objective - 20.0;

		end

		if ( self:PATROLBOAT_AVOIDSTUCK( entity ) == true ) then
			return true;
		end

		entity.AI.bBlockSignal = false;
		return false;

	end,

	------------------------------------------------------------------------------------------
	OnSomethingSeen = function( self, entity )
	end,
	
	------------------------------------------------------------------------------------------
	OnEnemyMemory = function( self, entity, fDistance )
	
		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then
			entity.AI.vMemoryPos = {};
			CopyVector( entity.AI.vMemoryPos, target:GetPos() ); 
		else
			entity.AI.vMemoryPos = {};
			CopyVector( entity.AI.vMemoryPos, entity:GetPos() ); 
		end
	
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
	-- FG HANDLERS
	------------------------------------------------------------------------------------------
	REFPOINT_REACHED = function(self,entity,sender)
	end,

	------------------------------------------------------------------------------------------
	-- Behaviors
	------------------------------------------------------------------------------------------
	PATROLBOAT_ATTACK_START = function( self, entity, sender )

		entity.AI.bBlockSignal = false;

		entity.AI.FollowTimeOut = 0;
		entity.AI.FollowTimeOut2 = 0;

		entity:SelectPipe(0,"do_nothing");
		patrolboatRequest2ndGunnerShoot( entity );

		if ( entity:GetSpeed() >1.0 ) then
			AI.CreateGoalPipe("patrollboat_waitstop");
			AI.PushGoal("patrollboat_waitstop","timeout",1,1.0);
			AI.PushGoal("patrollboat_waitstop","signal",0,1,"PATROLBOAT_ATTACK_START",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"patrollboat_waitstop");
			return;
		end
	
		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			if ( AI.IsPointInWaterRegion( target:GetPos() ) < 1.5 ) then
				g_SignalData.id = target.id;
				if ( self:OnEnemyDamage( entity , self, g_SignalData ) == true ) then
					return;
				end
			end

			if ( self:PATROLBOAT_APPROACH( entity, true ) == true ) then
				return;
			end

		else
			local isPathLoop = AI.GetPathLoop( entity.id, entity.AI.patrollBoatPathName );

			if ( isPathLoop == true ) then

				AI.SetPathToFollow( entity.id, entity.AI.patrollBoatPathName );
				AI.CreateGoalPipe("patrollboat_patrol");
				AI.PushGoal("patrollboat_patrol","run",0,0);	
				AI.PushGoal("patrollboat_patrol","continuous",0,0);	
				AI.PushGoal("patrollboat_patrol","followpath", 0, false, false, true, 3, 0.0, true );
				AI.PushGoal("patrollboat_patrol","timeout",1,5.0);
				AI.PushGoal("patrollboat_patrol","signal",0,1,"PATROLBOAT_ATTACK_START",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"patrollboat_patrol");
				return;

			else
				local mySegNo			= AI.GetPathSegNoOnPath( entity.id, entity.AI.patrollBoatPathName, entity:GetPos() )
				if ( mySegNo > 50.0 ) then
					AI.SetPathToFollow( entity.id, entity.AI.patrollBoatPathName );
					AI.CreateGoalPipe("patrollboat_patrol2");
					AI.PushGoal("patrollboat_patrol2","run",0,0);	
					AI.PushGoal("patrollboat_patrol2","continuous",0,0);	
					AI.PushGoal("patrollboat_patrol2","followpath", 0, false, false, false, 0, 0.0, false );
					AI.PushGoal("patrollboat_patrol2","timeout",1,5.0);
					AI.PushGoal("patrollboat_patrol2","signal",0,1,"PATROLBOAT_ATTACK_START",SIGNALFILTER_SENDER);
					entity:SelectPipe(0,"patrollboat_patrol2");
					return;
				else
					AI.SetPathToFollow( entity.id, entity.AI.patrollBoatPathName );
					AI.CreateGoalPipe("patrollboat_patrol3");
					AI.PushGoal("patrollboat_patrol3","run",0,0);	
					AI.PushGoal("patrollboat_patrol3","continuous",0,0);	
					AI.PushGoal("patrollboat_patrol3","followpath", 0, false, true, false, 0, 0.0, false );
					AI.PushGoal("patrollboat_patrol3","timeout",1,5.0);
					AI.PushGoal("patrollboat_patrol3","signal",0,1,"PATROLBOAT_ATTACK_START",SIGNALFILTER_SENDER);
					entity:SelectPipe(0,"patrollboat_patrol3");
					return;
				end
			
			end
			
		end

		if ( target and AI.Hostile( entity.id, target.id ) and random(1,2)==1 ) then

			local vDir  = {};
			SubVectors( vDir, target:GetPos(), entity:GetPos() );
			if ( LengthVector( vDir ) > 30.0 ) then
				NormalizeVector( vDir );
				FastScaleVector( vDir, vDir, 10.0 );
				FastSumVectors( vDir, vDir, entity:GetPos() );
				if ( self:PATROLBOAT_CHECKCLEARANCE( entity, vDir ) == true ) then
					CopyVector( entity.AI.vFollowTarget, vDir );
					AI.SetRefPointPosition( entity.id , vDir );
					AI.CreateGoalPipe("patrollboat_turn");
					AI.PushGoal("patrollboat_turn","run",0,0);	
					AI.PushGoal("patrollboat_turn","continuous",0,0);
					AI.PushGoal("patrollboat_turn","locate",0,"refpoint");		
					AI.PushGoal("patrollboat_turn","approach",0,5.0,AILASTOPRES_USE,0.0);	
					AI.PushGoal("patrollboat_turn","signal",1,1,"PATROLBOAT_CHECK_TIMEOUT",SIGNALFILTER_SENDER);
					AI.PushGoal("patrollboat_turn","timeout",1,0.1);
					AI.PushGoal("patrollboat_turn","branch",1,-2);
					AI.PushGoal("patrollboat_turn","signal",0,1,"PATROLBOAT_ATTACK_START",SIGNALFILTER_SENDER);
					entity:SelectPipe(0,"patrollboat_turn");
					return;
				end
			end

		end

		if ( self:PATROLBOAT_AVOIDSTUCK( entity ) == true ) then
			return;
		end

		AI.CreateGoalPipe("patrollboat_wait");
		AI.PushGoal("patrollboat_wait","signal",0,1,"PATROLBOAT_CHECK_SHOOT",SIGNALFILTER_SENDER);
		AI.PushGoal("patrollboat_wait","timeout",1,0.5);
		AI.PushGoal("patrollboat_wait","signal",0,1,"PATROLBOAT_CHECK_SHOOT",SIGNALFILTER_SENDER);
		AI.PushGoal("patrollboat_wait","timeout",1,0.5);
		AI.PushGoal("patrollboat_wait","signal",0,1,"PATROLBOAT_CHECK_SHOOT",SIGNALFILTER_SENDER);
		AI.PushGoal("patrollboat_wait","timeout",1,0.5);
		AI.PushGoal("patrollboat_wait","signal",0,1,"PATROLBOAT_CHECK_SHOOT",SIGNALFILTER_SENDER);
		AI.PushGoal("patrollboat_wait","timeout",1,0.5);

		AI.PushGoal("patrollboat_wait","signal",0,1,"PATROLBOAT_ATTACK_START",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"patrollboat_wait");

		return;
		
	end,

	---------------------------------------------
	PATROLBOAT_LOADPATH = function( self, entity, sw )

		if ( sw == 1 ) then
			entity.AI.patrollBoatPathName = entity.AI.patrollBoatPathNameMain;
		elseif ( sw == 2 ) then
			entity.AI.patrollBoatPathName = entity.AI.patrollBoatPathNameSub;
		else
			entity.AI.patrollBoatPathName = "patherror";
		end

	end,
	
	---------------------------------------------
	PATROLBOAT_AVOIDSTUCK = function( self, entity, vResult )

		local vOfs = {};
		local bFlg = false;

		FastScaleVector( vOfs, entity:GetDirectionVector(0), 40.0 );
		FastSumVectors( vOfs, vOfs, entity:GetPos() );
		if ( self:PATROLBOAT_CHECKCLEARANCE( entity, vOfs ) == true ) then
			bFlg = true;
		end
		
		if ( bFlg == false ) then
			FastScaleVector( vOfs, entity:GetDirectionVector(0), -40.0 );
			FastSumVectors( vOfs, vOfs, entity:GetPos() );
			if ( self:PATROLBOAT_CHECKCLEARANCE( entity, vOfs ) == true ) then
				bFlg = true;
			end
		end

		if ( bFlg == false ) then
			FastScaleVector( vOfs, entity:GetDirectionVector(1), -40.0 );
			FastSumVectors( vOfs, vOfs, entity:GetPos() );
			if ( self:PATROLBOAT_CHECKCLEARANCE( entity, vOfs ) == true ) then
				bFlg = true;
			end
		end

		if ( bFlg == true ) then

				entity.AI.FollowTimeOut = 0;
				entity.AI.FollowTimeOut2 = 0;
				CopyVector( entity.AI.vFollowTarget, vOfs );
				AI.SetRefPointPosition( entity.id , vOfs );
				AI.CreateGoalPipe("patrollboat_avoidstuck");
				AI.PushGoal("patrollboat_avoidstuck","run",0,0);	
				AI.PushGoal("patrollboat_avoidstuck","continuous",0,0);
				AI.PushGoal("patrollboat_avoidstuck","locate",0,"refpoint");		
				AI.PushGoal("patrollboat_avoidstuck","approach",0,5.0,AILASTOPRES_USE,0.0);	
				AI.PushGoal("patrollboat_avoidstuck","signal",1,1,"PATROLBOAT_CHECK_TIMEOUT",SIGNALFILTER_SENDER);
				AI.PushGoal("patrollboat_avoidstuck","timeout",1,0.1);
				AI.PushGoal("patrollboat_avoidstuck","branch",1,-2);
				AI.PushGoal("patrollboat_avoidstuck","timeout",1,3.0);
				AI.PushGoal("patrollboat_avoidstuck","signal",0,1,"PATROLBOAT_ATTACK_START",SIGNALFILTER_SENDER);
				entity:InsertSubpipe(0,"patrollboat_avoidstuck");
				return true;

		end

		return false;


	end,
	
	---------------------------------------------
	PATROLBOAT_CHECKCLEARANCE = function( self, entity, vDestination )

		local vDir = {};
		SubVectors( vDir, vDestination, entity:GetPos() );
		local length = LengthVector( vDir ) + 20.0; -- takes 40m to stop

		local count = length / 5.0;
		
		FastScaleVector( vDir, vDir, 5.0/length );
		local vCheckPoint = {};

		CopyVector( vCheckPoint, entity:GetPos() );
		for i= 1,count do
			FastSumVectors( vCheckPoint, vCheckPoint, vDir );
			if ( AI.IsPointInWaterRegion( vCheckPoint ) < 1.5 ) then
				return false;
			end
		end

		local vUp = { x=0.0, y=0.0, z=1.0 };
		local vWng = {};
		local vFwd = {};
		CopyVector( vFwd, vDir );
		NormalizeVector( vFwd );

		crossproduct3d( vWng, vFwd, vUp );
		FastScaleVector( vWng, vWng, 10.0 );

		CopyVector( vCheckPoint, entity:GetPos() );
		FastSumVectors( vCheckPoint, vCheckPoint, vWng );
		for i= 1,count do
			FastSumVectors( vCheckPoint, vCheckPoint, vDir );
			if ( AI.IsPointInWaterRegion( vCheckPoint ) < 1.5 ) then
				return false;
			end
		end

		CopyVector( vCheckPoint, entity:GetPos() );
		SubVectors( vCheckPoint, vCheckPoint, vWng );
		for i= 1,count do
			FastSumVectors( vCheckPoint, vCheckPoint, vDir );
			if ( AI.IsPointInWaterRegion( vCheckPoint ) < 1.5 ) then
				return false;
			end
		end

		return true;

	end,
	
	PATROLBOAT_GETMATRIC = function( self, entity, isPathLoop, mySegNo, enemySegNo  )

		local bReverse = false;
		local pathMetricInOrder = enemySegNo - mySegNo;
		local pathMetricInReverse = mySegNo - enemySegNo;

		if ( isPathLoop == true ) then
			if ( pathMetricInOrder < 0 ) then
				pathMetricInOrder = pathMetricInOrder + 100.0;
			end
			if ( pathMetricInReverse < 0 ) then
				pathMetricInReverse = pathMetricInReverse + 100.0;
			end
			if ( enemySegNo > mySegNo ) then
				if ( pathMetricInOrder < pathMetricInReverse ) then
					pathMetric = pathMetricInOrder;
					bReverse = false;
				else
					pathMetric = pathMetricInReverse;
					bReverse = true;
				end
			else
				if ( pathMetricInOrder < pathMetricInReverse ) then
					pathMetric = pathMetricInOrder;
					bReverse = false;
				else
					pathMetric = pathMetricInReverse;
					bReverse = true;
				end
			end
		else
			if ( enemySegNo > mySegNo ) then
				pathMetric = enemySegNo - mySegNo;
				bReverse = false;
			else
				pathMetric = mySegNo - enemySegNo;
				bReverse = true;
			end
		end

		return pathMetric;
			
	end,

	---------------------------------------------
	PATROLBOAT_APPROACH = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then
			return self:PATROLBOAT_APPROACH_SUB( entity, target, true );
		end

		return false;

	end,

	---------------------------------------------
	PATROLBOAT_APPROACH_SUB = function( self, entity, target, flg )

		-- What is the path which is ideal to do a combat
		entity:SelectPipe(0,"do_nothing");

		local vTargetPathPos = {};
		local targetMinimumLen  =500.0;
		local targetMinimamArc = 10000.0;
		local targetMinimamPathNo = 0;
		local targetGoodPathNo = 0;
		local length;
		
		for i= 1,2 do
			self:PATROLBOAT_LOADPATH( entity, i );
			CopyVector( vTargetPathPos,	AI.GetNearestPointOnPath( entity.id, entity.AI.patrollBoatPathName, target:GetPos() ) );
			length = DistanceVectors( vTargetPathPos, target:GetPos() );
			if ( length < targetMinimumLen ) then
				targetMinimumLen = length;
				targetMinimamPathNo = i;
			end
			if ( length < 150.0 ) then
				local isPathLoop	= AI.GetPathLoop( entity.id, entity.AI.patrollBoatPathName );
				local mySegNo			= AI.GetPathSegNoOnPath( entity.id, entity.AI.patrollBoatPathName, entity:GetPos() );
				local enemySegNo	= AI.GetPathSegNoOnPath( entity.id, entity.AI.patrollBoatPathName, target:GetPos() );
				local metric			= self:PATROLBOAT_GETMATRIC(entity, isPathLoop, mySegNo, enemySegNo  );
				local arc					= AI.GetTotalLengthOfPath( entity.id, entity.AI.patrollBoatPathName ) * metric / 100.0;
				if ( arc < targetMinimamArc ) then
					targetMinimamArc = arc;
					targetGoodPathNo = i;
				end
			end
		end

		if ( targetGoodPathNo == 0 ) then
			targetGoodPathNo = targetMinimamPathNo;
		end

		-- if I am far away that path, once stick to the path

		local vMyPathPos = {};
		local MyMinimumLen  =1000.0;
		local MyMinimamPathNo = 0;

		self:PATROLBOAT_LOADPATH( entity, targetGoodPathNo );
		CopyVector( vMyPathPos,	AI.GetNearestPointOnPath( entity.id, entity.AI.patrollBoatPathName, entity:GetPos() ) );
		length = DistanceVectors( vMyPathPos, entity:GetPos() );

		if ( length > 50.0 ) then
			CopyVector( entity.AI.vFollowTarget, vMyPathPos );
			AI.SetRefPointPosition( entity.id , vMyPathPos );
			if ( self:PATROLBOAT_CHECKCLEARANCE( entity, vMyPathPos ) == true ) then
				AI.CreateGoalPipe("patrollboat_shortcut2");
				AI.PushGoal("patrollboat_shortcut2","run",0,0);	
				AI.PushGoal("patrollboat_shortcut2","continuous",0,0);
				AI.PushGoal("patrollboat_shortcut2","locate",0,"refpoint");		
				AI.PushGoal("patrollboat_shortcut2","approach",0,50.0,AILASTOPRES_USE,0.0);	
				AI.PushGoal("patrollboat_shortcut2","signal",1,1,"PATROLBOAT_CHECK_POS_TIMEOUT",SIGNALFILTER_SENDER);
				AI.PushGoal("patrollboat_shortcut2","timeout",1,0.1);
				AI.PushGoal("patrollboat_shortcut2","branch",1,-2);
				if ( flg == true ) then
					entity:SelectPipe(0,"patrollboat_shortcut2");
				else
					entity:InsertSubpipe(0,"patrollboat_shortcut2");
				end
				return true;
			else
				return false;
			end
		end

		-- calculate point and direction

		local mySegNo			= AI.GetPathSegNoOnPath( entity.id, entity.AI.patrollBoatPathName, entity:GetPos() )
		local enemySegNo	= AI.GetPathSegNoOnPath( entity.id, entity.AI.patrollBoatPathName, target:GetPos() )

		CopyVector( vMyPathPos,	AI.GetNearestPointOnPath( entity.id, entity.AI.patrollBoatPathName, entity:GetPos() ) );
		CopyVector( vTargetPathPos, AI.GetNearestPointOnPath( entity.id, entity.AI.patrollBoatPathName, target:GetPos() ) );

		if ( DistanceVectors( vMyPathPos, vTargetPathPos ) < 30.0 ) then
			return false;
		end

		local currentDistance = DistanceVectors( entity:GetPos(), target:GetPos() );
		local idealDistance = DistanceVectors( vTargetPathPos, target:GetPos() );
		if ( idealDistance + 10.0 > currentDistance ) then
			return false;
		end

		CopyVector( entity.AI.vFollowTarget, vTargetPathPos );
		AI.SetPathToFollow( entity.id, entity.AI.patrollBoatPathName);

		local isPathLoop = AI.GetPathLoop( entity.id, entity.AI.patrollBoatPathName );
		local bReverse = false;
		local pathMetricInOrder = enemySegNo - mySegNo;
		local pathMetricInReverse = mySegNo - enemySegNo;

		if ( isPathLoop == true ) then
			if ( pathMetricInOrder < 0 ) then
				pathMetricInOrder = pathMetricInOrder + 100.0;
			end
			if ( pathMetricInReverse < 0 ) then
				pathMetricInReverse = pathMetricInReverse + 100.0;
			end
			if ( enemySegNo > mySegNo ) then
				if ( pathMetricInOrder < pathMetricInReverse ) then
					pathMetric = pathMetricInOrder;
					bReverse = false;
				else
					pathMetric = pathMetricInReverse;
					bReverse = true;
				end
			else
				if ( pathMetricInOrder < pathMetricInReverse ) then
					pathMetric = pathMetricInOrder;
					bReverse = false;
				else
					pathMetric = pathMetricInReverse;
					bReverse = true;
				end
			end
		else
			if ( enemySegNo > mySegNo ) then
				pathMetric = enemySegNo - mySegNo;
				bReverse = false;
			else
				pathMetric = mySegNo - enemySegNo;
				bReverse = true;
			end
		end

		-- As it will be a long way ,try to short cut

		if ( isPathLoop == true ) then

			local assumedPathLength = AI.GetTotalLengthOfPath( entity.id, entity.AI.patrollBoatPathName ) * pathMetric / 100.0;
			if ( assumedPathLength > 200.0 ) then

				if ( self:PATROLBOAT_CHECKCLEARANCE( entity, vTargetPathPos ) == true ) then
					CopyVector( entity.AI.vFollowTarget, vTargetPathPos );
					AI.SetRefPointPosition( entity.id , vTargetPathPos );
					AI.CreateGoalPipe("patrollboat_shortcut");
					AI.PushGoal("patrollboat_shortcut","run",0,0);	
					AI.PushGoal("patrollboat_shortcut","continuous",0,0);
					AI.PushGoal("patrollboat_shortcut","locate",0,"refpoint");		
					AI.PushGoal("patrollboat_shortcut","approach",0,100.0,AILASTOPRES_USE,0.0);	
					AI.PushGoal("patrollboat_shortcut","signal",1,1,"PATROLBOAT_CHECK_POS_TIMEOUT",SIGNALFILTER_SENDER);
					AI.PushGoal("patrollboat_shortcut","timeout",1,0.1);
					AI.PushGoal("patrollboat_shortcut","branch",1,-2);
					if ( flg == true ) then
						entity:SelectPipe(0,"patrollboat_shortcut");
					else
						entity:InsertSubpipe(0,"patrollboat_shortcut");
					end
					return true;
				end

			end

		end
	
		-- selet a pipe finally

		AI.SetPathToFollow( entity.id, entity.AI.patrollBoatPathName );
		AI.CreateGoalPipe("patrollboat_approach");

		if ( bReverse == false ) then
			AI.PushGoal("patrollboat_approach","run",0,0);	
			AI.PushGoal("patrollboat_approach","continuous",0,0);	
			AI.PushGoal("patrollboat_approach","followpath", 0, true, false, true, 3, 0, 0.0, true );
		else
--				AI.PushGoal("patrollboat_approach","run",0,-2);	
			AI.PushGoal("patrollboat_approach","run",0,0);	
			AI.PushGoal("patrollboat_approach","continuous",0,0);	
			AI.PushGoal("patrollboat_approach","followpath", 0, true, true, true, 3, 0, 0.0, true );
		end

		AI.PushGoal("patrollboat_approach","signal",1,1,"PATROLBOAT_CHECK_POS",SIGNALFILTER_SENDER);
		AI.PushGoal("patrollboat_approach","timeout",1,0.1);
		AI.PushGoal("patrollboat_approach","branch",1,-2);

		AI.PushGoal("patrollboat_approach","signal",0,1,"PATROLBOAT_ATTACK_START",SIGNALFILTER_SENDER);

		if ( flg == true ) then
			entity:SelectPipe(0,"patrollboat_approach");
		else
			entity:InsertSubpipe(0,"patrollboat_approach");
		end

		return true;


	end,

	---------------------------------------------
	PATROLBOAT_CHECK_POS_TIMEOUT = function( self, entity )
		self:PATROLBOAT_CHECK_POS_MAIN( entity, false );
	end,

	PATROLBOAT_CHECK_POS = function( self, entity )
		self:PATROLBOAT_CHECK_POS_MAIN( entity, true );
	end,

	---------------------------------------------
	PATROLBOAT_CHECK_TIMEOUT = function( self, entity )
		entity.AI.FollowTimeOut = entity.AI.FollowTimeOut + 1;
		if ( entity.AI.FollowTimeOut == 5 ) then
			entity.AI.FollowTimeOut = 0;
			entity.AI.FollowTimeOut2 = entity.AI.FollowTimeOut2 +1;
			self:PATROLBOAT_CHECK_SHOOT( entity );
		end
		if ( entity.AI.FollowTimeOut2 > 12 ) then
			AI.Signal(SIGNALFILTER_SENDER, 1, "PATROLBOAT_ATTACK_START", entity.id);
		end
	end,

	---------------------------------------------
	PATROLBOAT_CHECK_POS_MAIN = function( self, entity, flg )

		entity.AI.FollowTimeOut = entity.AI.FollowTimeOut + 1;
		if ( entity.AI.FollowTimeOut == 5 ) then
			entity.AI.FollowTimeOut = 0;
			entity.AI.FollowTimeOut2 = entity.AI.FollowTimeOut2 +1;
			self:PATROLBOAT_CHECK_SHOOT( entity );
		end

		if ( flg == true ) then

			local vDir2D = {}; 
			
			SubVectors( vDir2D, entity.AI.vFollowTarget, entity:GetPos() );
			vDir2D.z = 0;
	
			local distToTarget = LengthVector( vDir2D );
			if ( distToTarget < 20.0 or entity.AI.FollowTimeOut2 > 12 ) then
				AI.Signal(SIGNALFILTER_SENDER, 1, "PATROLBOAT_ATTACK_START", entity.id);
			end
	

		else

			local vDir2D = {}; 
			
			SubVectors( vDir2D, entity.AI.vFollowTarget, entity:GetPos() );
			vDir2D.z =0;
	
			local distToTarget = LengthVector( vDir2D );
			if ( distToTarget < 20.0 or entity.AI.FollowTimeOut2 > 12 ) then
				AI.Signal(SIGNALFILTER_SENDER, 1, "PATROLBOAT_ATTACK_START", entity.id);
			end


		end

	end,

	---------------------------------------------
	PATROLBOAT_CHECK_SHOOT = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then
		
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
					entity.AI.shootCounter = 1;
					--AIBehaviour.TANKDEFAULT:selectCannonForTheDriver( entity, true )
					patrolboatRequest2ndGunnerShoot( entity );
				end
			end
		end


		if ( entity.AI.shootCounter > 0 ) then
			entity.AI.shootCounter = entity.AI.shootCounter + 1;
			if ( entity.AI.shootCounter == 2 ) then
				AI.CreateGoalPipe("boat_fire");
				AI.PushGoal("boat_fire","firecmd",0,1);
				entity:InsertSubpipe(0,"boat_fire");
			else
				if ( entity.AI.shootCounter > 7 ) then
					AI.CreateGoalPipe("boat_nofire");
					AI.PushGoal("boat_nofire","firecmd",0,0);
					entity:InsertSubpipe(0,"boat_nofire");
					entity.AI.shootCounter = 0;
				end
			end
		end

	end,

}
