--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Implementation of a simple outdoor indoor alien behavior
--  
--------------------------------------------------------------------------
--  History:
--  - 11/12/2004   : Created by Kirill Bulatsev
--  - 05/04/2005   : CXP Rush Clean up by Mikko Mononen
--	- 29/11/2005   : Revised for new attack patterns by Tetsuji Iwasaki
--------------------------------------------------------------------------

--------------------------------------------------------------------------
AIBehaviour.ScoutMOARAttack = {
	Name = "ScoutMOARAttack",
	Base = "SCOUTDEFAULT",

	--------------------------------------------------------------------------
	Constructor = function ( self, entity, data )

		AIBehaviour.SCOUTDEFAULT:scoutCloseConnection( entity );	

		if ( entity.AI.bUseFreezeGun == true ) then
			-- For MOAR Scout
			AI.CreateGoalPipe("scoutMOARAttackDefault");
			AI.PushGoal("scoutMOARAttackDefault","timeout",1,0.1);
			AI.PushGoal("scoutMOARAttackDefault","signal",0,1,"SC_SCOUT_START_MOAR_ATTACK",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"scoutMOARAttackDefault");
		else
			AI.CreateGoalPipe("scoutMOARAttackDefaultV2");
			AI.PushGoal("scoutMOARAttackDefaultV2","timeout",1,0.1);
			AI.PushGoal("scoutMOARAttackDefaultV2","signal",0,1,"SC_SCOUT_STAY_ATTACK",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"scoutMOARAttackDefaultV2");
		end

	end,

	---------------------------------------------
	Destructor = function ( self, entity, data )

		-- called when the behaviour is de-selected
		-- the extra data is from the signal that is causing the behavior transition


		AIBehaviour.SCOUTDEFAULT:scoutCloseConnection( entity );

		entity:SelectPipe(0,"do_nothing");

	end,

	---------------------------------------------
	OnPathFound = function( self, entity, sender )
		-- called when the AI has requested a path and it's been computed succesfully
	end,	
	--------------------------------------------------------------------------
	OnNoTarget = function( self, entity )
		-- called when the AI stops having an attention target
	end,
	---------------------------------------------
	OnSomethingSeen = function( self, entity )
		-- called when the enemy sees a foe which is not a living player
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )

	end,
	---------------------------------------------
	OnSeenByEnemy = function( self, entity, sender )
	end,
	---------------------------------------------
	OnCloseContact= function( self, entity )
		-- called when AI gets at close distance to an enemy
	end,
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the AI can no longer see its enemy, but remembers where it saw it last
	end,
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		-- called when the AI hears an interesting sound
	end,
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
		-- called when the AI hears a threatening sound
	end,
	
	--------------------------------------------------------------------------
	OnSoreDamage = function ( self, entity, sender, data )
		self:OnEnemyDamage(entity);
	end,
	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender, data )
	end,
	---------------------------------------------
	OnDamage = function ( self, entity, sender, data )
	end,

	---------------------------------------------
	OnGroupMemberDied = function( self, entity, sender )

		-- called when a member of same species dies nearby

		local senderEntity =System.GetEntity( sender.id );
		AI.LogComment(entity:GetName().."OnGroupMemberDied from"..senderEntity:GetName());

		-- for team members
		if ( entity.AI.bConnected == true ) then
			if ( entity.AI.bIssuedConnect == false ) then
				if ( entity.AI.bApproved == true ) then
					local leaderEntity =System.GetEntity(entity.AI.connectionId);
					if ( leaderEntity ) then
						if ( leaderEntity.actor:GetHealth() < 1.0 ) then
							-- if the leader is dead.
							AI.Signal(SIGNALFILTER_GROUPONLY, 1, "TO_SCOUT_ATTACK", entity.id);
						end
					else
						-- if there is no leader.
						AI.Signal(SIGNALFILTER_SENDER, 1, "TO_SCOUT_ATTACK", entity.id);
					end					
				end
			end
		end


	end,

	--------------------------------------------------------------------------
	SC_SCOUT_GUARD = function ( self, entity )

		-- Just in case - When the connection has already been closed.
	
		if ( entity.AI.bConnected == false or entity.AI.bApproved == false or entity.AI.bIssuedConnect == true ) then
			AI.LogComment("SC_SCOUT_GUARD is illegally called !!!");
			return;
		end
			
		-- go to a guard point and protect a leader.

		local targetName = AI.GetAttentionTargetOf(entity.id);
		local projectedFwdDir ={};
		local projectedWngDir ={};
		local targetPos ={};
		local targetUpDir ={};
		local guardPos ={};

		local bFailed = false;
		if (targetName and AI.Hostile(entity.id,targetName)) then

			local target = System.GetEntityByName(targetName);

			CopyVector( targetPos, target:GetPos() );
			CopyVector( guardPos, entity.AI.vGuardPoint );

			local targetFwdDir ={};
			local targetWngDir ={};

			SubVectors( targetFwdDir, targetPos, guardPos );
			NormalizeVector( targetFwdDir );
			targetWngDir = vecFrontToRight( targetFwdDir );

			targetUpDir = target:GetDirectionVector(2);

			local t = dotproduct3d( targetFwdDir , targetUpDir );
				
			--Avoid a singularity
			if ( t * t < 0.9 ) then
				ProjectVector( projectedFwdDir , targetFwdDir , targetUpDir );
				ProjectVector( projectedWngDir , targetWngDir , targetUpDir );
				NormalizeVector(projectedFwdDir);
				NormalizeVector(projectedWngDir);
			else
				AI.LogComment(entity:GetName().."SC_SCOUT_GUARD failed. overflowed ");
				bFailed = true;
			end

		else
			-- close connections if there is no target.
			AI.LogComment(entity:GetName().."SC_SCOUT_GUARD failed. no target ");
			bFailed = true;
		end

		-- failed to calcurate the position.
		if ( bFailed == true ) then
			entity:SelectPipe(0,"do_nothing");
			return;
		end

		-- here's new position, make him go

		local vTmpVec ={};
		local vTmpVecWng ={};
		local vTmpVecFwd ={};
		local vTmpVecUp ={};
			
		CopyVector( vTmpVecFwd, projectedFwdDir );
		CopyVector( vTmpVecWng, projectedWngDir );
		CopyVector( vTmpVecUp, targetUpDir );

		if (entity.AI.connectListIndex==1) then
			FastScaleVector( vTmpVecWng, vTmpVecWng, 5.0 );
			FastScaleVector( vTmpVecFwd, vTmpVecFwd, -35.0 );
			FastScaleVector( vTmpVecUp, vTmpVecUp, 10.0 );
		else
			FastScaleVector( vTmpVecWng, vTmpVecWng, -5.0 );
			FastScaleVector( vTmpVecFwd, vTmpVecFwd, -35.0 );
			FastScaleVector( vTmpVecUp, vTmpVecUp, 10.0 );
		end

		FastSumVectors( vTmpVec, vTmpVecFwd, vTmpVecWng );
		FastSumVectors( vTmpVec, vTmpVec, vTmpVecUp );
		FastSumVectors( vTmpVec, vTmpVec, targetPos );
	
		local currentDirLen = DistanceVectors( entity:GetPos(), vTmpVec );

		if ( currentDirLen < 5.0 ) then

			-- when the player doesn't move just stay.
		
			AI.ChangeParameter( entity.id, AIPARAM_STRAFINGPITCH, 10.0 );
			AI.CreateGoalPipe("scoutGuardV2");
			AI.PushGoal("scoutGuardV2","firecmd",0,FIREMODE_FORCED);
			AI.PushGoal("scoutGuardV2","timeout",1,3);
			AI.PushGoal("scoutGuardV2","firecmd",0,0);
			AI.PushGoal("scoutGuardV2","timeout",1,0.3);
			AI.PushGoal("scoutGuardV2","signal",0,1,"SC_SCOUT_GUARD",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"scoutGuardV2");

		elseif ( currentDirLen < 10.0 ) then

			-- when the player doesn't move very much. move a little

			AI.SetRefPointPosition( entity.id, vTmpVec );
			AIBehaviour.SCOUTDEFAULT:scoutAdjustRefPoint( entity , 5.0 );


			AI.CreateGoalPipe("scoutGuardV3");
			AI.PushGoal("scoutGuardV3","locate",0,"refpoint");
			AI.PushGoal("scoutGuardV3","approach",1,3.0,AILASTOPRES_USE,-1);
			AI.PushGoal("scoutGuardV3","signal",0,1,"SC_SCOUT_GUARD",SIGNALFILTER_SENDER,-1);
			entity:SelectPipe(0,"scoutGuardV3");
		else
	
			-- when the player move a lot. run to the guard point.
	
			AI.ChangeParameter( entity.id, AIPARAM_STRAFINGPITCH , 10.0 );
			AI.SetRefPointPosition( entity.id, vTmpVec );
			AIBehaviour.SCOUTDEFAULT:scoutAdjustRefPoint( entity , 5.0 );

			AI.CreateGoalPipe("scoutGuard");
			AI.PushGoal("scoutGuard","run",0,1);
			AI.PushGoal("scoutGuard","firecmd",0,FIREMODE_FORCED);
			AI.PushGoal("scoutGuard","locate",0,"refpoint");
			AI.PushGoal("scoutGuard","approach",1,5.0,AILASTOPRES_USE,-1);
			AI.PushGoal("scoutGuard","firecmd",0,0);
			AI.PushGoal("scoutGuard","run",0,0);
			AI.PushGoal("scoutGuard","signal",0,1,"SC_SCOUT_GUARD",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"scoutGuard");
		end
	
	end,

	--------------------------------------------------------------------------
	SC_SCOUT_STAY_ATTACK = function( self, entity )
		
		AIBehaviour.SCOUTDEFAULT:scoutGetID( entity );
		AIBehaviour.SCOUTDEFAULT:scoutDoStayAttack( entity );

	end,

	--------------------------------------------------------------------------
	--------------------------------------------------------------------------
	--------------------------------------------------------------------------

	-- Protocols 09/12/06 Tetsuji

	--[[
 ------------------------------------------------------------------------------------
	[CONNECT/CONNECTED/ACCEPT/CLOSE]
	By this protocol, the leader get team members to whom the leader can ask commands.
	When a session ends, a leader send [CLOSE] to team members to close a connection.
	
	Leader																							Team members
	SC_SCOUT_CONNECT ---------->
																					<----------SC_SCOUT_ACCEPT
	SC_SCOUT_CONNECTED ---------->

	SC_SCOUT_CLOSE ---------->

 ------------------------------------------------------------------------------------
	[SENDDATA]
	By this protocols, The leader can comunicate with team members

	Leader																							Team members
	SC_SCOUT_SENDDATA ---------->

 ------------------------------------------------------------------------------------
	General protocol patterns
  
	Leader																							Team members

	SC_SCOUT_CONNECT ---------->
																					<----------SC_SCOUT_ACCEPT		(now he knows he is not free)
	SC_SCOUT_CONNECTED ---------->																				(he knows whether his connection was approved or not)

	SC_SCOUT_SENDDATA ---------->																					(he have to do a leader's request)

	SC_SCOUT_CLOSE ---------->                        										(he knows he is free again)

	]]--

	--------------------------------------------------------------------------
	-- functions for communication( for team members )


	--------------------------------------------------------------------------
	SC_SCOUT_CONNECT = function( self, entity, sender )

		-- respond to the recruit. state I can join as leader's guard.
		entity.AI.bLockAction = true;
	
		local senderEntity =System.GetEntity( sender.id );
	
		if ( entity.AI.bConnected == false ) then
			if ( entity.AI.bIssuedConnect == false ) then
				if ( entity.AI.bApproved == false ) then

					-- if he joins a formation --				
					if ( entity.AI.stayPosition ~= 0 ) then
						entity.AI.bConnected = true;
						entity.AI.connectionId = sender.id;

						AI.LogComment(entity:GetName().." rcv SC_SCOUT_CONNECT from "..senderEntity:GetName());
						AI.LogComment(entity:GetName().." snd SC_SCOUT_ACCEPT to "..senderEntity:GetName());
						AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 1, "SC_SCOUT_ACCEPT", entity.id);

					end

					-- reset all the scout's action
					self:SC_SCOUT_STAY_ATTACK(entity);

				end
			end
		end

	end,

	--------------------------------------------------------------------------
  SC_SCOUT_CONNECTED = function( self, entity, sender, data )

		-- a team member knows if his connection is approved or not.
		-- when his connection is approved ,he makes a connection otherwise he reset his connection.

		local senderEntity =System.GetEntity( sender.id );
	
		if ( entity.AI.bConnected == true and entity.AI.connectionId == sender.id ) then
			if ( entity.AI.bIssuedConnect == false ) then
				if ( entity.AI.bApproved == false ) then

					AI.LogComment(entity:GetName().." rcv SC_SCOUT_CONNECTED from "..senderEntity:GetName());
					if (data.id == entity.id) then
						entity.AI.connectListIndex = data.iValue;
						AI.LogComment(entity:GetName().." connection with "..senderEntity:GetName().." is approved "..entity.AI.connectListIndex);
						entity.AI.bApproved = true;
					else
						AI.LogComment(entity:GetName().." connection with "..senderEntity:GetName().." is resetted");
						entity.AI.bConnected =false;
					end
						
				end
			end
		end

	end,

	--------------------------------------------------------------------------
	SC_SCOUT_SENDDATA = function( self, entity, sender, data )

		-- a team member knows where he should stay and protect.

		local senderEntity =System.GetEntity( sender.id );

		-- for teammembers
		if ( entity.AI.bConnected == true and entity.AI.connectionId == sender.id and entity.id == data.id ) then
			if ( entity.AI.bApproved == true ) then
				if ( entity.AI.bIssuedConnect == false ) then

					AI.LogComment(entity:GetName().." rcv SC_SCOUT_SENDDATA from "..senderEntity:GetName());

					entity.AI.vGuardPoint ={};
					entity.AI.connectListIndex = data.iValue
					CopyVector( entity.AI.vGuardPoint , data.point );

					AI.Signal(SIGNALFILTER_SENDER, 1, "SC_SCOUT_GUARD", entity.id);

				end
			end
		end

	end,

	--------------------------------------------------------------------------
	SC_SCOUT_CLOSE = function( self, entity, sender )

		-- a team member knows, now he can quit gaurding.

		local senderEntity =System.GetEntity( sender.id );

		if ( entity.AI.bConnected == true and entity.AI.bApproved == true and entity.AI.connectionId == sender.id ) then
			if ( entity.AI.bIssuedConnect == false ) then

				AI.LogComment(entity:GetName().." rcv SC_SCOUT_CLOSE from "..senderEntity:GetName());

				local targetName = AI.GetAttentionTargetOf(entity.id);
				if (targetName and AI.Hostile(entity.id,targetName)) then
					local target = System.GetEntityByName(targetName);
					if (target) then

						local targetPos = {};
						local myPos = {};

						local vTargetUpVec = {};
						local destinationPos = {};
						local vDirVector = {};
						
						CopyVector( targetPos, target:GetPos() );
						CopyVector( myPos, entity:GetPos() );
						CopyVector( vTargetUpVec, target:GetDirectionVector(2) );
						
						SubVectors( vDirVector, myPos, targetPos );
						NormalizeVector( vDirVector );
						FastScaleVector( vDirVector, vDirVector, 10.0 );
						FastScaleVector( vTargetUpVec , vTargetUpVec , 20.0 );
						FastSumVectors( destinationPos , myPos , vTargetUpVec );
						FastSumVectors( destinationPos , destinationPos , vDirVector );

						AI.SetRefPointPosition( entity.id , destinationPos  );
						AIBehaviour.SCOUTDEFAULT:scoutAdjustRefPoint( entity, 0.0 );
	
						AI.CreateGoalPipe("scoutGuardEnd");
						AI.PushGoal("scoutGuardEnd","firecmd",0,FIREMODE_FORCED);
						AI.PushGoal("scoutGuardEnd","continuous",0,1);	
						AI.PushGoal("scoutGuardEnd","run",0,1);	
						AI.PushGoal("scoutGuardEnd","locate",0,"refpoint");		
						AI.PushGoal("scoutGuardEnd","approach",1,5.0,AILASTOPRES_USE);
						AI.PushGoal("scoutGuardEnd","firecmd",0,0);
						AI.PushGoal("scoutGuardEnd","run",0,0);	
						AI.PushGoal("scoutGuardEnd","timeout",1,0.5);
						AI.PushGoal("scoutGuardEnd","signal",0,1,"TO_SCOUT_ATTACK",SIGNALFILTER_SENDER);
						entity:SelectPipe(0,"scoutGuardEnd");

					else
						-- if there is no target
						AI.LogComment(entity:GetName().."SC_SCOUT_CLOSE failed. Can't resolve target.");
					end
				else
					-- if there is no target
					AI.LogComment(entity:GetName().."SC_SCOUT_CLOSE failed. No target.");
				end

			end
		end


	end,

	--------------------------------------------------------------------------
	-- functions for communication( for a leader )

	--------------------------------------------------------------------------
	SC_SCOUT_ACCEPT = function( self, entity, sender )

		-- a leader knows, there is someone for the guard.

		local senderEntity =System.GetEntity( sender.id );

		if ( entity.AI.bConnected == false ) then
			if ( entity.AI.bApproved == false ) then
				if ( entity.AI.bIssuedConnect == true ) then
					-- Get only one reqeust.
					if ( entity.AI.bIsReplayForConnect == false ) then
						--restrict a max conection.
						if ( entity.AI.connectListIndex < 2 ) then
							entity.AI.bIsReplayForConnect = true;
							AI.LogComment(entity:GetName().." rcv SC_SCOUT_ACCEPT from "..senderEntity:GetName());
							entity.AI.connectListIndex = entity.AI.connectListIndex +1;
							entity.AI.connectList[ entity.AI.connectListIndex ] = sender.id;
						end
					end
				end
			end
		end

	end,

	--------------------------------------------------------------------------
	-- (recruit guards for the MOAR attack  )

	SC_SCOUT_START_MOAR_ATTACK = function( self, entity )

		AIBehaviour.SCOUTDEFAULT:scoutGetID( entity );

		local scoutAttackCenterPos = {};
		AIBehaviour.SCOUTDEFAULT:scoutGetStayAttackPosition( entity, scoutAttackCenterPos, 0 );

		AI.SetRefPointPosition( entity.id , scoutAttackCenterPos );
		AIBehaviour.SCOUTDEFAULT:scoutAdjustRefPoint( entity , 0.0 );

		AI.CreateGoalPipe("scoutMOARAttackStart");
		AI.PushGoal("scoutMOARAttackStart","run",0,1);	
		AI.PushGoal("scoutMOARAttackStart","locate",0,"refpoint");		
		AI.PushGoal("scoutMOARAttackStart","approach",1,3.0,AILASTOPRES_USE,-1);
		AI.PushGoal("scoutMOARAttackStart","run",0,0);	
		AI.PushGoal("scoutMOARAttackStart","signal",0,1,"SC_SCOUT_GET_GUARD_1",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"scoutMOARAttackStart");
			
	end,

	SC_SCOUT_GET_GUARD_1 = function( self, entity )

		AI.LogComment(entity:GetName().." SC_SCOUT_GET_GUARD_1:");

		entity.AI.bIsReplayForConnect = false;
		entity.AI.bIssuedConnect = true;
		entity.AI.bLockAction = true;

		-- make connections.
		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 1, "SC_SCOUT_CONNECT", entity.id);

		AI.LogComment(entity:GetName().." snd SC_SCOUT_CONNECT by BroadCast");
		AI.CreateGoalPipe("scoutGetGuard2");
		AI.PushGoal("scoutGetGuard2","timeout",1,1.0);
		AI.PushGoal("scoutGetGuard2","signal",0,1,"SC_SCOUT_GET_GUARD_2",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"scoutGetGuard2");
	
	end,

	SC_SCOUT_GET_GUARD_2 = function( self, entity )

		AI.LogComment(entity:GetName().." SC_SCOUT_GET_GUARD_2:");

		-- if there is someone to protect me.
		if ( entity.AI.bIsReplayForConnect == true ) then

			--set an id to whom connect.
			g_SignalData.id = entity.AI.connectList[entity.AI.connectListIndex];
			g_SignalData.iValue = entity.AI.connectListIndex;

			--approve a connection
			local receiverEntity =System.GetEntity( g_SignalData.id );
			AI.LogComment(entity:GetName().." snd SC_SCOUT_CONNECTED to "..receiverEntity:GetName());

			AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 1, "SC_SCOUT_CONNECTED", entity.id, g_SignalData);

			AI.CreateGoalPipe("scoutGetGuard3");
			AI.PushGoal("scoutGetGuard3","timeout",1,0.0);
			AI.PushGoal("scoutGetGuard3","signal",0,1,"SC_SCOUT_GET_GUARD_3",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"scoutGetGuard3");

		else

			self:SC_SCOUT_GET_GUARD_5( entity );

		end;
	
	end,

	SC_SCOUT_GET_GUARD_3 = function( self, entity )

		AI.LogComment(entity:GetName().." SC_SCOUT_GET_GUARD_3:");

		--command of senddata to make teammembers start guarding.
		g_SignalData.id = entity.AI.connectList[entity.AI.connectListIndex];
		g_SignalData.iValue = entity.AI.connectListIndex;
		CopyVector( g_SignalData.point, entity:GetPos() );

		local receiverEntity =System.GetEntity( g_SignalData.id );
		AI.LogComment(entity:GetName().." snd SC_SCOUT_SENDDATA to "..receiverEntity:GetName());
		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 1, "SC_SCOUT_SENDDATA", entity.id, g_SignalData);

		self:SC_SCOUT_GET_GUARD_4( entity );

	end,
	
	SC_SCOUT_GET_GUARD_4 = function( self, entity )

		AI.LogComment(entity:GetName().." SC_SCOUT_GET_GUARD_4:");

		--check if the guard finishes going to the guard point.

		local connectionEntity;
		local targetEntity;

		local bConnectionReady = false;
		local bTargetReady = false;
		entity:SelectPipe(0,"do_nothing");

		-- check if there is a target	
		local targetName = AI.GetAttentionTargetOf( entity.id );
		if ( targetName and AI.Hostile( entity.id, targetName ) ) then
			targetEntity= System.GetEntityByName( targetName );
			if (targetEntity) then
				bTargetReady = true;
			end
		end
		
		-- if there is no target, close connections and go to the default formation.
		if ( bTargetReady == false ) then
			self:SC_SCOUT_GET_GUARD_5( entity );
			return;
		end

		-- Go to the next step
		-- when a team member sticks to the player
		-- when a team member is dead
		-- when there is no team member
				
		connectionEntity =System.GetEntity( entity.AI.connectList[ entity.AI.connectListIndex ] );
		if ( connectionEntity ) then
			AI.LogComment( entity:GetName().." SC_SCOUT_GET_GUARD_4:Checking Status".." HP "..connectionEntity.actor:GetHealth() .." distance "..DistanceVectors( connectionEntity:GetPos() , targetEntity:GetPos() ) );
			if ( connectionEntity.actor:GetHealth() < 1.0 ) then
				bConnectionReady = true;
			end
			local currentDirLen = DistanceVectors( connectionEntity:GetPos() , targetEntity:GetPos() );
			if ( currentDirLen < 80.0 ) then
				bConnectionReady = true;
			end
		else
			AI.LogComment( "no connection Entity");
			bConnectionReady =true;
		end
		

		-- if a teammember is ready
		if ( bConnectionReady == true) then

			self:SC_SCOUT_GET_GUARD_1( entity );
			return;

		end

		-- wait for teammembers

		local vAttackEscapePos = {};

		AIBehaviour.SCOUTDEFAULT:scoutGetStayAttackPosition(entity,vAttackEscapePos,1);
	
		AI.CreateGoalPipe("scoutGetGuard4");
		AI.SetRefPointPosition( entity.id , vAttackEscapePos );
		AIBehaviour.SCOUTDEFAULT:scoutAdjustRefPoint( entity, 0.0 );
		
		AI.PushGoal("scoutGetGuard4","run",0,1);		
		AI.PushGoal("scoutGetGuard4","locate",0,"refpoint");		
		AI.PushGoal("scoutGetGuard4","approach",0,5.0,AILASTOPRES_USE,-1);
		AI.PushGoal("scoutGetGuard4","timeout",1,2.0);
		AI.PushGoal("scoutGetGuard4","signal",0,1,"SC_SCOUT_GET_GUARD_4",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"scoutGetGuard4");

	end,


	SC_SCOUT_GET_GUARD_5 = function( self, entity )

		AI.LogComment(entity:GetName().." SC_SCOUT_GET_GUARD_5:");

		--send close to make gurads escape and start fire.

		AI.LogComment(entity:GetName().." snd SC_SCOUT_CLOSE");

		local vAttackCenterPos = {};

		AIBehaviour.SCOUTDEFAULT:scoutGetStayAttackPosition(entity,vAttackCenterPos,2);

		AI.ChangeParameter( entity.id, AIPARAM_STRAFINGPITCH , 44.0 );
		AI.SetRefPointPosition( entity.id , vAttackCenterPos );
		AIBehaviour.SCOUTDEFAULT:scoutAdjustRefPoint( entity, 0.0 );
	
		AI.CreateGoalPipe("scoutGetGuard6");
		AI.PushGoal("scoutGetGuard6","run",0,1);		
		AI.PushGoal("scoutGetGuard6","locate",0,"refpoint");		
		AI.PushGoal("scoutGetGuard6","approach",1,5.0,AILASTOPRES_USE,-1);
		AI.PushGoal("scoutGetGuard6","timeout",1,0.5);
		AI.PushGoal("scoutGetGuard6","firecmd",0,FIREMODE_FORCED);
		AI.PushGoal("scoutGetGuard6","timeout",1,1.0);
		AI.PushGoal("scoutGetGuard6","signal",0,1,"SC_SCOUT_CLOSE",SIGNALFILTER_GROUPONLY_EXCEPT);
		AI.PushGoal("scoutGetGuard6","timeout",1,6.5);
		AI.PushGoal("scoutGetGuard6","firecmd",0,0);
		AI.PushGoal("scoutGetGuard6","timeout",1,0.5);
		AI.PushGoal("scoutGetGuard6","signal",0,1,"SC_SCOUT_GET_GUARD_6",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"scoutGetGuard6");

	end,

	SC_SCOUT_GET_GUARD_6 = function( self, entity )

		AI.LogComment(entity:GetName().." SC_SCOUT_GET_GUARD_6:");

		--end of the freezing gun attack.
		AI.Signal(SIGNALFILTER_GROUPONLY, 1, "TO_SCOUT_ATTACK", entity.id);

	end,

}

