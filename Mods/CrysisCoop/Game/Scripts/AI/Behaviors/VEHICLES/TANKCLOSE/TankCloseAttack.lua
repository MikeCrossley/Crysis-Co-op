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
--
--------------------------------------------------------------------------

AIBehaviour.TankCloseAttack = {
	Name = "TankCloseAttack",
	alertness = 2,

	------------------------------------------------------------------------------------------
	-- SYSTEM HANDLERS
	------------------------------------------------------------------------------------------
	Constructor = function( self, entity )

		entity:SelectPipe(0,"tankclose_attack_start");

		entity.AI.bMemoryCount = 0;
		entity.AI.shootCounter =0;
		entity.AI.bShootNexttime = false;
		entity.AI.bUseMachineGun = false;
		entity.AI.lastAnchor = nil;
		entity.AI.random = random( 1, 65535 );
		entity.AI.approachCount = 0;

		entity.AI.bBack = false;
		entity.AI.bIsLoopPath =false;

		entity.AI.vMemoryPos = {};
		entity.AI.vLastPos = {};
		entity.AI.vLastPosHeSaw = {};
		entity.AI.vFollowTarget ={};

		entity.AI.FollowTimeOut = 0;
		entity.AI.FollowTimeOut2 = 0;
		entity.AI.patrollPoint = 0;

		CopyVector( entity.AI.vMemoryPos, entity:GetPos() );
		CopyVector( entity.AI.vLastPos, entity:GetPos() );
		CopyVector( entity.AI.vLastPosHeSaw,  entity:GetPos() );

		entity.AI.circleSec = System.GetCurrTime();

	end,

	--------------------------------------------------------------------------
	TANKCLOSE_RANDOM = function ( self, entity, low, high )
		entity.AI.random = math.mod( entity.AI.random * 5 + 1, 65536 );
		return math.abs( math.mod( entity.AI.random, high - low ) ) + low;
	end,

	------------------------------------------------------------------------------------------
	TANKCLOSE_INIT = function( self, entity )

		local segno = -1;
		
		if ( entity.AI.tankClosePathName ) then
			segno = AI.GetPathSegNoOnPath( entity.id, entity.AI.tankClosePathName, entity:GetPos() )
		end

		if ( segno < 0 ) then
			AI.Warning( entity:GetName().." can't get a path to follow" );
			entity:SelectPipe(0,"tankclose_____________error");
			return;
		end

		AI.SetPathToFollow( entity.id, entity.AI.tankClosePathName);

		CopyVector( entity.AI.vMemoryPos    , AI.GetPointOnPathBySegNo( entity.id, entity.AI.tankClosePathName, 20.0 ) );
		CopyVector( entity.AI.vLastPos      , AI.GetPointOnPathBySegNo( entity.id, entity.AI.tankClosePathName, 80.0 ) );
		CopyVector( entity.AI.vLastPosHeSaw , AI.GetPointOnPathBySegNo( entity.id, entity.AI.tankClosePathName, 50.0 ) );

		local vTmp2 = {};
		FastScaleVector( vTmp2, entity:GetDirectionVector(1), 10.0 );
		FastSumVectors( vTmp2, vTmp2, entity:GetPos() );
		local fwdSegNo		= AI.GetPathSegNoOnPath( entity.id, entity.AI.tankClosePathName, vTmp2 );
		local mySegNo			= AI.GetPathSegNoOnPath( entity.id, entity.AI.tankClosePathName, entity:GetPos() )
		entity.AI.bBack   = self:TANKCLOSE_CALCULATE_METRIC( entity, fwdSegNo, mySegNo );

		entity.AI.bIsLoopPath = AI.GetPathLoop( entity.id, entity.AI.tankClosePathName );


		local targetType = AI.GetTargetType( entity.id );
		if( targetType == AITARGET_MEMORY or targetType == AITARGET_SOUND ) then
			self:TANKCLOSE_MEMORYATTACK_START( entity);
		else
			self:TANKCLOSE_ATTACK_START( entity );
		end

	end,

	------------------------------------------------------------------------------------------
	OnGroupMemberDied = function( self, entity, sender )
	end,	

	-----------------------------------------------------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )

		entity.AI.bUseMachineGun = AIBehaviour.TANKDEFAULT:tankDoesUseMachineGun( entity );
		entity.AI.circleSec = System.GetCurrTime();

		if ( entity.AI.bUseMachineGun == false ) then
--			self:INVEHICLEGUNNER_FOUND_TARGET( entity );
		end
	
	end,

	-----------------------------------------------------------------------------------------
	OnEnemyDamage = function ( self, entity, sender, data )
		entity.AI.bShootNexttime = true;
	end,

	------------------------------------------------------------------------------------------
	OnSomethingSeen = function( self, entity )
	end,
	
	------------------------------------------------------------------------------------------
	OnEnemyMemory = function( self, entity, fDistance )
	
		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then
			CopyVector( entity.AI.vMemoryPos, target:GetPos() ); 
		else
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
	TANKCLOSE_ATTACK_START = function( self, entity, sender )

		-- approach the player then shoot

		entity:SelectPipe(0,"do_nothing");

		if ( entity:GetSpeed()>0.5 ) then
			entity:SelectPipe(0,"tankclose_speedzero");
		end

		entity.AI.bUseMachineGun = AIBehaviour.TANKDEFAULT:tankDoesUseMachineGun( entity );

		if ( entity.AI.bUseMachineGun == true ) then
			AIBehaviour.TANKDEFAULT:request2ndGunnerShoot( entity );
		end

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			local targetType = AI.GetTargetType( entity.id );
			if( targetType == AITARGET_MEMORY ) then
				entity.AI.bMemoryCount = entity.AI.bMemoryCount + 1;
				if ( entity.AI.bMemoryCount < 2 ) then
					entity:SelectPipe(0,"tankclose_wait4");
					return;
				else
					AI.Signal(SIGNALFILTER_SENDER, 1, "TANKCLOSE_MEMORYATTACK_START", entity.id);
					return;
				end
			else
				entity.AI.bMemoryCount = 0;
			end

			if ( self:TANKCLOSE_APPROACH( entity, true ) == true ) then
				return;
			end

		else
			AI.Signal(SIGNALFILTER_SENDER, 1, "TANKCLOSE_MEMORYATTACK_START", entity.id);
			return;
		end
		if ( AI.GetTypeOf( target.id ) == AIOBJECT_VEHICLE ) then
			--System.Log( entity:GetName().." approachCount "..entity.AI.approachCount );
			entity.AI.approachCount = entity.AI.approachCount + 1;
			if ( entity.AI.approachCount > 20 ) then
				self:TANKCLOSE_BREAKACTION_START( entity );
				entity.AI.approachCount = 0;
				return;			
			end
		else
			entity.AI.approachCount = 0;
		end

		entity:SelectPipe(0,"tankclose_wait4");
	end,

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
	TANKCLOSE_MEMORYATTACK_START = function( self, entity, sender )

		local bSpecial = false;
		local vPos = {};

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			local targetType = AI.GetTargetType( entity.id );
			if( targetType == AITARGET_MEMORY ) then

				local vDir = {};
				local vTargetPos = {};
				local vTmp = {};
	
				CopyVector( vTargetPos, target:GetPos() );

				local bbmin,bbmax = target:GetLocalBBox();
				vTargetPos.z = vTargetPos.z + bbmax.z;

				SubVectors( vDir, vTargetPos, entity:GetPos() );
			
				local	hits = 0;
				local	hits2 = 0;
				if ( LengthVector( vDir ) < 300.0 ) then
					hits = Physics.RayWorldIntersection(entity:GetPos(),vDir,1,ent_rigid+ent_sleeping_rigid,entity.id,target.id,g_HitTable);
					hits2 = Physics.RayWorldIntersection(entity:GetPos(),vDir,1,ent_terrain+ent_static,entity.id,target.id,g_HitTable);
				end

				if( hits ~= 0 and hits2 == 0 ) then
					entity.AI.shootCounter = 0;
					AIBehaviour.TANKDEFAULT:selectCannonForTheDriver( entity, true )
					entity:SelectPipe(0,"tankclose_memoryattack");
					return;
				else
					local vPathPos = {};
					local vPathPos2 = {};
					CopyVector( vPathPos,	AI.GetNearestPointOnPath( entity.id, entity.AI.tankClosePathName, vTargetPos ) );

					local vPathVec = {};
					local vPathVecUnit = {};
					SubVectors( vPathVecUnit, vPathPos, entity:GetPos() );
					NormalizeVector( vPathVecUnit );

					local step = -2;
					for i = 1,5 do

						FastScaleVector( vPathVec, vPathVecUnit, step * 5.0 );
						FastSumVectors( vPathPos2, vPathPos, vPathVec );
						CopyVector( vTmp,	AI.GetNearestPointOnPath( entity.id, entity.AI.tankClosePathName, vPathPos2 ) );
						CopyVector( vPathPos2, vTmp );
						
						vPathPos2.z =  self:TANKCLOSE_GETTERRAINLEVEL( entity, vPathPos2 ) + 1.0;

						SubVectors( vDir, vTargetPos, vPathPos2 );
						if ( LengthVector( vDir ) < 200.0 ) then
							local	hits = Physics.RayWorldIntersection(vPathPos2,vDir,1,ent_terrain+ent_static+ent_rigid+ent_sleeping_rigid,entity.id,target.id,g_HitTable);
							if( hits == 0 ) then
								CopyVector( vPos, vPathPos2 );
								bSpecial = true;
							end
						end
						step = step + 1;
					end

				end

			else
				entity.AI.bMemoryCount = 0;
				AI.Signal(SIGNALFILTER_SENDER, 1, "TANKCLOSE_ATTACK_START", entity.id);
				return;
			end
		end

		if ( bSpecial== false ) then

			if ( entity.AI.patrollPoint == 0 ) then
				CopyVector( vPos, entity.AI.vLastPosHeSaw );
			elseif ( entity.AI.patrollPoint == 1 ) then
				CopyVector( vPos, entity.AI.vMemoryPos );
			elseif ( entity.AI.patrollPoint == 2 ) then
				CopyVector( vPos, entity.AI.vLastPos );
			end
			entity.AI.patrollPoint = entity.AI.patrollPoint +1;
			if ( entity.AI.patrollPoint >2 ) then
				entity.AI.patrollPoint = 0;
			end
		end
		
		local vMyPathPos = {};
		local vTargetPathPos = {};

		local mySegNo			= AI.GetPathSegNoOnPath( entity.id, entity.AI.tankClosePathName, entity:GetPos() );
		local enemySegNo	= AI.GetPathSegNoOnPath( entity.id, entity.AI.tankClosePathName, vPos );

		CopyVector( vMyPathPos,	AI.GetNearestPointOnPath( entity.id, entity.AI.tankClosePathName, entity:GetPos() ) );
		CopyVector( vTargetPathPos, AI.GetNearestPointOnPath( entity.id, entity.AI.tankClosePathName, vPos ) );

		if ( bSpecial== false and DistanceVectors( entity:GetPos(), vTargetPathPos ) < 7.0 ) then
			self:TANKCLOSE_ALERT_ACTION( entity );
			return false;
		end

		CopyVector( entity.AI.vFollowTarget, vTargetPathPos );
		AI.SetPathToFollow( entity.id, entity.AI.tankClosePathName);

		entity.AI.FollowTimeOut = 0;
		entity.AI.FollowTimeOut2 = 0;
		local bReverse = self:TANKCLOSE_CALCULATE_METRIC( entity, enemySegNo, mySegNo );

		entity:SelectPipe(0,"do_nothing");
		
		local pipename;
		if (bSpecial==true) then
			pipename = "tankclose_patrol_special";
		else
			pipename = "tankclose_patrol";
		end
		---------------------------------------------
		AI.BeginGoalPipe(pipename);
			if ( entity.AIMovementAbility and entity.AIMovementAbility.pathType == AIPATH_BOAT ) then
				if ( DistanceVectors(entity:GetPos(),entity.AI.vFollowTarget)< 50.0 ) then
					AI.PushGoal("run",0,0);
				else
					AI.PushGoal("run",0,1);
				end
			elseif ( bReverse==false ) then
				if ( DistanceVectors(entity:GetPos(),entity.AI.vFollowTarget)< 50.0 ) then
					AI.PushGoal("run",0,0);
				else
					AI.PushGoal("run",0,1);
				end
			else	
				if ( DistanceVectors(entity:GetPos(),entity.AI.vFollowTarget)< 50.0 ) then
					AI.PushGoal("run",0,-2);
				else
					AI.PushGoal("run",0,-3);
				end			
			end
			
			AI.SetPathAttributeToFollow( entity.id, true );
			AI.PushGoal("continuous",0,0);	
			if ( entity.AI.bIsLoopPath == true ) then
				AI.PushGoal("followpath", 0, false, bReverse, true, 3, 0, false );
			else
				AI.PushGoal("followpath", 0, false, bReverse, true, 0, 0, false );
			end
			AI.PushGoal("signal",1,1,"TANKCLOSE_CHECK_POS2",SIGNALFILTER_SENDER);
			AI.PushGoal("timeout",1,0.1);
			AI.PushGoal("branch",1,-2);
		AI.EndGoalPipe();			
		entity:SelectPipe(0,pipename);
	end,


	---------------------------------------------
	TANKCLOSE_BREAKACTION_START = function( self, entity )

		local vPos = {};

		if ( entity.AI.patrollPoint == 0 ) then
			CopyVector( vPos, AI.GetPointOnPathBySegNo( entity.id, entity.AI.tankClosePathName, 20.0 ) );
		elseif ( entity.AI.patrollPoint == 1 ) then
			CopyVector( vPos, AI.GetPointOnPathBySegNo( entity.id, entity.AI.tankClosePathName, 80.0 ) );
		elseif ( entity.AI.patrollPoint == 2 ) then
			CopyVector( vPos, AI.GetPointOnPathBySegNo( entity.id, entity.AI.tankClosePathName, 50.0 ) );
		end

		entity.AI.patrollPoint = entity.AI.patrollPoint +1;
		if ( entity.AI.patrollPoint >2 ) then
			entity.AI.patrollPoint = 0;
		end
	
		local vMyPathPos = {};
		local vTargetPathPos = {};

		local mySegNo			= AI.GetPathSegNoOnPath( entity.id, entity.AI.tankClosePathName, entity:GetPos() );
		local enemySegNo	= AI.GetPathSegNoOnPath( entity.id, entity.AI.tankClosePathName, vPos );

		CopyVector( vMyPathPos,	AI.GetNearestPointOnPath( entity.id, entity.AI.tankClosePathName, entity:GetPos() ) );
		CopyVector( vTargetPathPos, AI.GetNearestPointOnPath( entity.id, entity.AI.tankClosePathName, vPos ) );

		CopyVector( entity.AI.vFollowTarget, vTargetPathPos );
		AI.SetPathToFollow( entity.id, entity.AI.tankClosePathName);

		entity.AI.FollowTimeOut = 0;
		entity.AI.FollowTimeOut2 = 0;
		local bReverse = self:TANKCLOSE_CALCULATE_METRIC( entity, enemySegNo, mySegNo );

		entity:SelectPipe(0,"do_nothing");
		
		local pipename = "tankclose_breakaction";
		
		---------------------------------------------
		AI.BeginGoalPipe("tankclose_breakaction");
			if ( entity.AIMovementAbility and entity.AIMovementAbility.pathType == AIPATH_BOAT ) then
				if ( DistanceVectors(entity:GetPos(),entity.AI.vFollowTarget)< 50.0 ) then
					AI.PushGoal("run",0,0);
				else
					AI.PushGoal("run",0,1);
				end
			elseif ( bReverse==false ) then
				if ( DistanceVectors(entity:GetPos(),entity.AI.vFollowTarget)< 50.0 ) then
					AI.PushGoal("run",0,0);
				else
					AI.PushGoal("run",0,1);
				end
			else	
				if ( DistanceVectors(entity:GetPos(),entity.AI.vFollowTarget)< 50.0 ) then
					AI.PushGoal("run",0,-2);
				else
					AI.PushGoal("run",0,-3);
				end			
			end
	
			AI.SetPathAttributeToFollow( entity.id, true );
	
			AI.PushGoal("continuous",0,0);	
			if ( entity.AI.bIsLoopPath == true ) then
				AI.PushGoal("followpath", 0, false, bReverse, true, 3, 0, false );
			else
				AI.PushGoal("followpath", 0, false, bReverse, true, 0, 0, false );
			end
			AI.PushGoal("signal",1,1,"TANKCLOSE_CHECK_POS",SIGNALFILTER_SENDER);
			AI.PushGoal("timeout",1,0.1);
			AI.PushGoal("branch",1,-2);
		AI.EndGoalPipe();
		entity:SelectPipe(0,pipename);

	end,


	---------------------------------------------------------------------------------------------------------------------------------------
	TANKCLOSE_ALERT_ACTION = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then
			local targetType = AI.GetTargetType( entity.id );
			if( targetType == AITARGET_MEMORY ) then

			else
				entity:SelectPipe(0,"tankclose_wait3");
				return;
			end
		else
		end
		
		local vUp = { x=0.0, y=0.0, z=1.0 };
		local vDest = {};
		local angle = random ( -60, 60 ) * 3.1416 *2 / 360.0;

		RotateVectorAroundR( vDest, entity:GetDirectionVector( 1 ), vUp, angle )

		FastScaleVector( vDest, vDest, 10.0 );
		FastSumVectors( vDest, vDest, entity:GetPos() );
		AI.SetRefPointPosition( entity.id , vDest );

		entity:SelectPipe(0,"tankclose_alert_action");

	end,
	---------------------------------------------
	TANKCLOSE_GETTERRAINLEVEL = function( self, entity, vTmp )

		local targetLevel = System.GetTerrainElevation( vTmp );
		local targetWaterLevel = AI.IsPointInWaterRegion( vTmp );
		if ( targetWaterLevel  > 0.0 ) then
			targetLevel = targetLevel + targetWaterLevel;
		end
		
		return targetLevel;
			
	end,
	---------------------------------------------
	TANKCLOSE_APPROACH = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			local vMyPathPos = {};
			local vTargetPathPos = {};
			local vTargetPos = {};
			local vTmp = {};
		
			local mySegNo			= AI.GetPathSegNoOnPath( entity.id, entity.AI.tankClosePathName, entity:GetPos() );
			local enemySegNo	= AI.GetPathSegNoOnPath( entity.id, entity.AI.tankClosePathName, target:GetPos() );

			CopyVector( vMyPathPos,	    AI.GetNearestPointOnPath( entity.id, entity.AI.tankClosePathName, entity:GetPos() ) );
			CopyVector( vTargetPathPos, AI.GetNearestPointOnPath( entity.id, entity.AI.tankClosePathName, target:GetPos() ) );
	
			local bGoFarAway = false;
			local pmul = 1.0;
			if ( entity.AIMovementAbility and entity.AIMovementAbility.pathType ~= AIPATH_BOAT ) then
				pmul = 0.75;
			end

			if ( DistanceVectors( entity:GetPos(), target:GetPos() ) < 12.0 ) then

				FastScaleVector( vTmp, entity:GetDirectionVector(1), 15.0 );
				FastSumVectors( vTmp, vTmp, target:GetPos() );
	
				mySegNo			= AI.GetPathSegNoOnPath( entity.id, entity.AI.tankClosePathName, entity:GetPos() );
				enemySegNo	= AI.GetPathSegNoOnPath( entity.id, entity.AI.tankClosePathName, vTmp );

				CopyVector( vMyPathPos,	    AI.GetNearestPointOnPath( entity.id, entity.AI.tankClosePathName, entity:GetPos() ) );
				CopyVector( vTargetPathPos, AI.GetNearestPointOnPath( entity.id, entity.AI.tankClosePathName, vTmp ) );
			
				if ( DistanceVectors( target:GetPos(), vTargetPathPos ) < 12.0 ) then

					FastScaleVector( vTmp, entity:GetDirectionVector(1), -15.0 );
					FastSumVectors( vTmp, vTmp, target:GetPos() );
		
					mySegNo			= AI.GetPathSegNoOnPath( entity.id, entity.AI.tankClosePathName, entity:GetPos() );
					enemySegNo	= AI.GetPathSegNoOnPath( entity.id, entity.AI.tankClosePathName, vTmp );
	
					CopyVector( vMyPathPos,	    AI.GetNearestPointOnPath( entity.id, entity.AI.tankClosePathName, entity:GetPos() ) );
					CopyVector( vTargetPathPos, AI.GetNearestPointOnPath( entity.id, entity.AI.tankClosePathName, vTmp ) );

					if ( DistanceVectors( target:GetPos(), vTargetPathPos ) < 12.0  ) then
						return false;
					end
					
				end

				bGoFarAway = true;

			else

				if ( bGoFarAway == false and targetType ~= AITARGET_MEMORY) then

					if ( DistanceVectors( vMyPathPos, target:GetPos() ) < 15.0 ) then
						return false;
					end
					if ( DistanceVectors( vTargetPathPos, entity:GetPos() ) < 15.0 ) then
						return false;
					end

				end
				
			end

			CopyVector( vTargetPos, target:GetPos() );

			local bbmin,bbmax = target:GetLocalBBox();
			vTargetPos.z = vTargetPos.z + bbmax.z;

			CopyVector( vTmp, vTargetPathPos );
			vTmp.z = self:TANKCLOSE_GETTERRAINLEVEL( entity, vTargetPathPos ) + 1.0;

			local vDir = {};
			SubVectors( vDir, vTargetPos , vTmp );
			local	hits = 1;
			if ( LengthVector( vDir ) < 400.0 * pmul ) then
				hits = Physics.RayWorldIntersection( vTmp,vDir,1,ent_terrain+ent_static+ent_rigid+ent_sleeping_rigid,entity.id,target.id,g_HitTable);
			end

			FastSumVectors( vDir, vDir, vTmp );
--			System.DrawLine(vTmp, vDir, 1, 1, 1, 1);

			if ( hits > 0 and bGoFarAway ==false) then

				local bFound = false;
	
				local vPathPos = {};
				local vPathPos2 = {};
				CopyVector( vPathPos,	AI.GetNearestPointOnPath( entity.id, entity.AI.tankClosePathName, vTargetPathPos ) );
	
				local vPathVec = {};
				local vPathVecUnit = {};
				SubVectors( vPathVecUnit, vPathPos, entity:GetPos() );
				NormalizeVector( vPathVecUnit );

				local step = -2;
				for i = 1,5 do
	
					FastScaleVector( vPathVec, vPathVecUnit, step * 5.0 );

					FastSumVectors( vPathPos2, vPathPos, vPathVec );

					CopyVector( vTmp,	AI.GetNearestPointOnPath( entity.id, entity.AI.tankClosePathName, vPathPos2 ) );
					CopyVector( vPathPos2, vTmp );

					vPathPos2.z = self:TANKCLOSE_GETTERRAINLEVEL( entity, vPathPos2 ) + 1.0;

					SubVectors( vDir, vTargetPos, vPathPos2 );
					if ( LengthVector( vDir ) < 300.0 * pmul ) then
						local	hits = Physics.RayWorldIntersection(vPathPos2,vDir,1,ent_terrain+ent_static+ent_rigid+ent_sleeping_rigid,entity.id,target.id,g_HitTable);
	
						FastSumVectors( vDir, vDir, vPathPos2 );
--						System.DrawLine(vPathPos2, vDir, 0, 1, 1, 1);
	
						if( hits == 0 ) then
							CopyVector( vTargetPathPos, vPathPos2 );
							bFound = true;
							break;
						end
					end
					step = step + 1;
				end
	
				if ( bFound==false ) then
					return false;
				end

			end

			CopyVector( entity.AI.vFollowTarget, vTargetPathPos );
					
			local targetType = AI.GetTargetType(entity.id);
			if ( bGoFarAway == false and targetType ~= AITARGET_MEMORY) then
				if ( DistanceVectors( target:GetPos(), entity:GetPos() ) < 30.0 ) then
					return false;
				end
			end
	
			AI.SetPathToFollow( entity.id, entity.AI.tankClosePathName );

			entity.AI.FollowTimeOut = 0;
			entity.AI.FollowTimeOut2 = 0;

			local bReverse = self:TANKCLOSE_CALCULATE_METRIC( entity, enemySegNo, mySegNo );

			entity:SelectPipe(0,"do_nothing");
			---------------------------------------------
			AI.BeginGoalPipe("tankclose_approach");
				if ( entity.AIMovementAbility and entity.AIMovementAbility.pathType == AIPATH_BOAT ) then
					if ( DistanceVectors(entity:GetPos(),entity.AI.vFollowTarget)< 30.0) then
						AI.PushGoal("run",0,0);
					else
						AI.PushGoal("run",0,1);
					end
				elseif ( bReverse==false ) then
					if ( DistanceVectors(entity:GetPos(),entity.AI.vFollowTarget)< 30.0) then
						AI.PushGoal("run",0,0);
					else
						AI.PushGoal("run",0,1);
					end
					if ( bGoFarAway == true ) then
						AI.PushGoal("run",0,2);
					end
				else	
					if ( DistanceVectors(entity:GetPos(),entity.AI.vFollowTarget)< 30.0) then
						AI.PushGoal("run",0,-2);
					else
						AI.PushGoal("run",0,-3);
					end			
					if ( bGoFarAway == true ) then
						AI.PushGoal("run",0,-4);
					end
				end
	
				AI.SetPathAttributeToFollow( entity.id, true );
	
				AI.PushGoal("continuous",0,0);	
				if ( entity.AI.bIsLoopPath == true ) then
					AI.PushGoal("followpath", 0, false, bReverse, true, 3, 0, false );
				else
					AI.PushGoal("followpath", 0, false, bReverse, true, 0, 0, false );
				end
				if ( bGoFarAway ==false ) then
					AI.PushGoal("signal",1,1,"TANKCLOSE_CHECK_POS",SIGNALFILTER_SENDER);
				else
					AI.PushGoal("signal",1,1,"TANKCLOSE_CHECK_POS3",SIGNALFILTER_SENDER);
				end
				AI.PushGoal("timeout",1,0.1);
				AI.PushGoal("branch",1,-2);
		
				AI.PushGoal("signal",1,1,"TANKCLOSE_ALERT_ACTION",SIGNALFILTER_SENDER);
			AI.EndGoalPipe();			
			entity:SelectPipe(0,"tankclose_approach");
			entity.AI.approachCount = 0;
			return true;
		end
		return false;
	end,

	---------------------------------------------
	TANKCLOSE_CHECK_POS = function( self, entity )

		entity.AI.FollowTimeOut = entity.AI.FollowTimeOut + 1;
		if ( entity.AI.FollowTimeOut == 5 ) then
			entity.AI.FollowTimeOut = 0;
			self:TANKCLOSE_CHECK_SHOOT( entity );
		end

		local checkval =7.0;
		if ( entity.AIMovementAbility and entity.AIMovementAbility.pathType == AIPATH_BOAT ) then
			checkval =10.0;
		end

		if ( entity:GetSpeed()< 1.0 ) then
			entity.AI.FollowTimeOut2 = entity.AI.FollowTimeOut2 + 1;
		else
			entity.AI.FollowTimeOut2 = 0;
		end

		if ( entity.AIMovementAbility and entity.AIMovementAbility.pathType == AIPATH_BOAT ) then
			local vSrc = {};
			local vDst = {};
			CopyVector( vSrc, AI.GetNearestPointOnPath( entity.id, entity.AI.tankClosePathName, entity:GetPos() ) );
			CopyVector( vDst, AI.GetNearestPointOnPath( entity.id, entity.AI.tankClosePathName, entity.AI.vFollowTarget ) );
			SubVectors( vSrc, vDst, vSrc );
			if ( LengthVector( vSrc )< 7.0 or entity.AI.FollowTimeOut2 > 5 ) then
				AI.Signal(SIGNALFILTER_SENDER, 1, "TANKCLOSE_ATTACK_START", entity.id);
			end
			return;
		end

		local distToTarget = DistanceVectors( entity.AI.vFollowTarget, entity:GetPos() );
		if ( distToTarget < checkval or  entity.AI.FollowTimeOut2 > 5 ) then
			AI.Signal(SIGNALFILTER_SENDER, 1, "TANKCLOSE_ATTACK_START", entity.id);
			return;
		end
		
	end,

	---------------------------------------------
	TANKCLOSE_CHECK_POS2 = function( self, entity )

		entity.AI.FollowTimeOut = entity.AI.FollowTimeOut + 1;
		if ( entity.AI.FollowTimeOut == 5 ) then
			entity.AI.FollowTimeOut = 0;
			self:TANKCLOSE_CHECK_SHOOT( entity );
		end

		local checkval =7.0;
		if ( entity.AIMovementAbility and entity.AIMovementAbility.pathType == AIPATH_BOAT ) then
			checkval =10.0;
		end

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then
			local targetType = AI.GetTargetType( entity.id );
			if( targetType == AITARGET_MEMORY ) then
			else
				AI.Signal(SIGNALFILTER_SENDER, 1, "TANKCLOSE_ATTACK_START", entity.id);
			end
		end

		if ( entity:GetSpeed()< 1.0 ) then
			entity.AI.FollowTimeOut2 = entity.AI.FollowTimeOut2 + 1;
		else
			entity.AI.FollowTimeOut2 = 0;
		end

		if ( entity.AIMovementAbility and entity.AIMovementAbility.pathType == AIPATH_BOAT ) then
			local vSrc = {};
			local vDst = {};
			CopyVector( vSrc, AI.GetNearestPointOnPath( entity.id, entity.AI.tankClosePathName, entity:GetPos() ) );
			CopyVector( vDst, AI.GetNearestPointOnPath( entity.id, entity.AI.tankClosePathName, entity.AI.vFollowTarget ) );
			SubVectors( vSrc, vDst, vSrc );
			if ( LengthVector( vSrc )< 7.0 or  entity.AI.FollowTimeOut2 > 5 ) then
				AI.Signal(SIGNALFILTER_SENDER, 1, "TANKCLOSE_ALERT_ACTION", entity.id);
			end
			return;
		end

		local distToTarget = DistanceVectors( entity.AI.vFollowTarget, entity:GetPos() );
		if ( distToTarget < checkval or  entity.AI.FollowTimeOut2 > 5 ) then
			AI.Signal(SIGNALFILTER_SENDER, 1, "TANKCLOSE_ALERT_ACTION", entity.id);
			return;
		end
		
	end,

	---------------------------------------------
	TANKCLOSE_CHECK_POS3 = function( self, entity )

		entity.AI.FollowTimeOut = entity.AI.FollowTimeOut + 1;
		if ( entity.AI.FollowTimeOut == 5 ) then
			entity.AI.FollowTimeOut = 0;
			self:TANKCLOSE_CHECK_SHOOT( entity );
		end

		local checkval =7.0;
		if ( entity.AIMovementAbility and entity.AIMovementAbility.pathType == AIPATH_BOAT ) then
			checkval =10.0;
		end

		if ( entity:GetSpeed()< 1.0 ) then
			entity.AI.FollowTimeOut2 = entity.AI.FollowTimeOut2 + 1;
		else
			entity.AI.FollowTimeOut2 = 0;
		end

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then
			local distToTarget = DistanceVectors( target:GetPos(), entity:GetPos() );
			if ( distToTarget > 15.0 ) then
				AI.Signal(SIGNALFILTER_SENDER, 1, "TANKCLOSE_ATTACK_START", entity.id);
			end
		end

		if ( entity.AIMovementAbility and entity.AIMovementAbility.pathType == AIPATH_BOAT ) then
			local vSrc = {};
			local vDst = {};
			CopyVector( vSrc, AI.GetNearestPointOnPath( entity.id, entity.AI.tankClosePathName, entity:GetPos() ) );
			CopyVector( vDst, AI.GetNearestPointOnPath( entity.id, entity.AI.tankClosePathName, entity.AI.vFollowTarget ) );
			SubVectors( vSrc, vDst, vSrc );
			if ( LengthVector( vSrc )< 7.0 or  entity.AI.FollowTimeOut2 > 5 ) then
				AI.Signal(SIGNALFILTER_SENDER, 1, "TANKCLOSE_ALERT_ACTION", entity.id);
			end
			return;
		end

		local distToTarget = DistanceVectors( entity.AI.vFollowTarget, entity:GetPos() );
		if ( distToTarget < checkval or  entity.AI.FollowTimeOut2 > 5 ) then
			AI.Signal(SIGNALFILTER_SENDER, 1, "TANKCLOSE_ATTACK_START", entity.id);
			return;
		end
		
	end,

	---------------------------------------------
	TANKCLOSE_CHECK_SHOOT = function( self, entity )

		local bAPC = false;

		if ( entity.class == "US_apc" ) then
			bAPC = true;
			entity.AI.isAPC = true;
		end


		entity.AI.bUseMachineGun = AIBehaviour.TANKDEFAULT:tankDoesUseMachineGun( entity );

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			local targetType = AI.GetTargetType( entity.id );
			if( targetType ~= AITARGET_MEMORY ) then
				entity.AI.patrollPoint = 0;
				CopyVector( entity.AI.vLastPosHeSaw,  entity:GetPos() );
			end
		
			local enemyPos = {};
			local randomFactor;
			CopyVector( enemyPos, target:GetPos() );

			if ( enemyPos.z - System.GetTerrainElevation( enemyPos ) > 10.0 ) then
				randomFactor =1; -- for more frequesnt shot for the air target.
			else
				randomFactor =1;
			end

			if ( entity.AI.shootCounter == 0 ) then
				if ( bAPC == true ) then
					if( self:TANKCLOSE_RANDOM( entity, 1, 256 ) > 128 ) then
						return
					end
					if( AI.GetTargetType( entity.id ) == AITARGET_MEMORY ) then
						return;
					end
					local distance = DistanceVectors( target:GetPos(), entity:GetPos() );
					local timehasPassed = System.GetCurrTime() - entity.AI.circleSec;
					if ( timehasPassed < 7.0 and distance > 15.0 ) then
						if ( AI.GetTypeOf( target.id ) == AIOBJECT_VEHICLE ) then
							if ( target.AIMovementAbility and target.AIMovementAbility.pathType == AIPATH_TANK ) then
								AI.ChangeParameter( entity.id, AIPARAM_ACCURACY, 1.0 );
								AIBehaviour.TANKDEFAULT:selectCannonForTheDriver( entity, true )
							else
								AI.ChangeParameter( entity.id, AIPARAM_ACCURACY, entity.Properties.accuracy );
								AIBehaviour.TANKDEFAULT:selectCannonForTheDriver( entity, false )
							end
						else
							AI.ChangeParameter( entity.id, AIPARAM_ACCURACY, entity.Properties.accuracy );
							AIBehaviour.TANKDEFAULT:selectCannonForTheDriver( entity, false )
						end
					else
						AI.ChangeParameter( entity.id, AIPARAM_ACCURACY, entity.Properties.accuracy );
						AIBehaviour.TANKDEFAULT:selectCannonForTheDriver( entity, false )
					end

					if ( timehasPassed  > 22.5 ) then
						entity.AI.circleSec = System.GetCurrTime();
					end
					
					entity.AI.shootCounter = 101;
				elseif ( random( 1, randomFactor ) == 1 or entity.AI.bShootNexttime == true) then
				
					AI.ChangeParameter( entity.id, AIPARAM_ACCURACY, entity.Properties.accuracy );
				
					entity.AI.bShootNexttime = false;
					if ( entity.AI.bUseMachineGun ~=true ) then
						local vDirToTarget = {};
						SubVectors( vDirToTarget, target:GetPos(), entity:GetPos() );
						vDirToTarget.z = 0.0;
						if ( LengthVector( vDirToTarget ) < 20.0 ) then
							entity.AI.shootCounter = 21;
							AIBehaviour.TANKDEFAULT:selectCannonForTheDriver( entity, false );
						else
							entity.AI.shootCounter = 1;
							AIBehaviour.TANKDEFAULT:selectCannonForTheDriver( entity, true )
						end
					else
						entity.AI.shootCounter = 21;
						AIBehaviour.TANKDEFAULT:selectCannonForTheDriver( entity, false )
					end
				end
			end
		end

		if ( entity.AI.shootCounter > 100 ) then

			entity.AI.shootCounter = entity.AI.shootCounter + 1;

			if ( entity.AI.shootCounter == 102 ) then
				entity:InsertSubpipe(0,"tank_fire");
			end
			
			if ( entity.AI.shootCounter == 105 ) then
					entity:InsertSubpipe(0,"tank_nofire");
					entity.AI.shootCounter = 0;
			end

			if ( entity.AI.shootCounter > 106 ) then
					entity.AI.shootCounter = 0;
			end

		elseif ( entity.AI.shootCounter > 20 ) then
			entity.AI.shootCounter = entity.AI.shootCounter + 1;
			if ( entity.AI.shootCounter == 22 ) then
				entity:InsertSubpipe(0,"tank_fire_sec");
			end
			
			if ( entity.AI.shootCounter > 40 ) then
					entity:InsertSubpipe(0,"tank_nofire");
					entity.AI.shootCounter = 0;
			end

		elseif ( entity.AI.shootCounter > 0 ) then
			entity.AI.shootCounter = entity.AI.shootCounter + 1;
			if ( entity.AI.shootCounter == 2 ) then
				entity:InsertSubpipe(0,"tank_fire_burst");
			end
			if ( entity.AI.shootCounter > 7 ) then
				entity:InsertSubpipe(0,"tank_nofire");
				entity.AI.shootCounter = 0;
			end
		end

	end,

	---------------------------------------------
	TANKCLOSE_TARGET_CHECK = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			local targetType = AI.GetTargetType( entity.id );
			if( targetType ~= AITARGET_MEMORY ) then

				if ( entity.AI.bUseMachineGun == true ) then
					AIBehaviour.TANKDEFAULT:request2ndGunnerShoot( entity );
				end

				local distanceToTheTarget = DistanceVectors( target:GetPos(), entity:GetPos() );
				if ( distanceToTheTarget > 25.0 ) then
					entity:InsertSubpipe(0,"tankclose_wait");
				end
			else
			end

		end
	end,

	---------------------------------------------
	INVEHICLEGUNNER_FOUND_TARGET = function( self, entity )

	end,

	---------------------------------------------
	TANKCLOSE_TARGET_CHECK2 = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then
			AI.Signal(SIGNALFILTER_SENDER, 1, "TANKCLOSE_ATTACK_START", entity.id);
			return;
		end

	end,


}

