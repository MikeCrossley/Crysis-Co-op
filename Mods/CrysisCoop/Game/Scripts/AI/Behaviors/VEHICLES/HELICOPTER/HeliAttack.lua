--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2005.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Helocipter Behaviour SCRIPT
--  
--------------------------------------------------------------------------
--  History:
--  - 21/06/2005   : Created by Kirill Bulatsev
--
--------------------------------------------------------------------------
AIBehaviour.HeliAttack = {
	Name = "HeliAttack",
	Base = "HeliBase",
	alertness = 2,

	-- SYSTEM EVENTS			-----
	---------------------------------------------
	Constructor = function(self , entity )

		-- for refreshing position;

--		AI.CreateGoalPipe("h_attack");
----		AI.PushGoal("h_attack","firecmd",0,1);		
--		AI.PushGoal("h_attack","acqtarget",1,"");
----		AI.PushGoal("h_attack","approach",1,3);
--		AI.PushGoal("h_attack","stick",1,25,0,1);		
--		AI.PushGoal("h_attack","signal",0,1,"PatrolPath",SIGNALFILTER_SENDER);
--		entity.AI.PathStep = 0;

--		AI.Signal(SIGNALFILTER_SENDER, 1, "H_CHOOSE_ATTACK_ACTION",entity.id);

	--	AI.ChangeParameter(entity.id,AIPARAM_SIGHTRANGE,800.0); -- test

		-- for refreshing position;

		if (entity.AI.vFormationScale==nil) then
			entity.AI.vFormationScale = {};
			entity.AI.vFormationScale.x =1.0;
			entity.AI.vFormationScale.y =1.0;
			entity.AI.vFormationScale.z =1.0;
		end

		entity.AI.time = System.GetCurrTime() - 100.0;

		-- Position imfomation, at what seat the heli is located.
		entity.AI.bBlockSignal = true;

		entity.AI.stayPosition = 0;
		entity.AI.vDefaultPosition = {};
		entity.AI.vAttackCenterPos = {};
		entity.AI.vFwdUnit = {};
		entity.AI.vWngUnit = {};
		entity.AI.vUpUnit = {};
	
		local defaultVec = {};
		defaultVec.x = 0.0;
		defaultVec.y = 0.0;
		defaultVec.z = 0.0;

		CopyVector( entity.AI.vDefaultPosition, entity:GetPos() );
		CopyVector( entity.AI.vAttackCenterPos, entity:GetPos() );
		CopyVector( entity.AI.vFwdUnit, defaultVec );
		CopyVector( entity.AI.vWngUnit, defaultVec );
		CopyVector( entity.AI.vUpUnit, defaultVec );

		-- how long has the helicopter been waiting

		entity.AI.waitCounter  = 0;

		-- for common signal handlers.

		entity.AI.heliDefaultSignal = "HELI_STAY_ATTACK_START";
		entity.AI.heliMemorySignal = "TO_HELI_PICKATTACK";

		-- Default action
			AI.CreateGoalPipe("heliJustStay");
			AI.PushGoal("heliJustStay","locate",0,"atttarget");
			AI.PushGoal("heliJustStay","lookat",0,0,0,true,1);
			AI.PushGoal("heliJustStay","signal",1,1,"HELI_HOVER_ENABLE_REACTION",SIGNALFILTER_SENDER);
			AI.PushGoal("heliJustStay","signal",0,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
			AI.PushGoal("heliJustStay","timeout",1,1.0);	
			AI.PushGoal("heliJustStay","signal",0,1,"HELI_STAY_ATTACK_START",SIGNALFILTER_SENDER);


		if ( entity.AI.bFirstAttack == true ) then
		
				if (entity.AI.isHeliAggressive == nil ) then

					entity.AI.bFirstAttack = false;		
					-- start expanding formation to avoid confliction.
					AI.CreateGoalPipe("heliAttackDefault2");
					AI.PushGoal("heliAttackDefault2","signal",0,1,"HELI_EXPAND_FORMATION",SIGNALFILTER_SENDER);
					entity:SelectPipe(0,"heliAttackDefault2");
					return;
					
				else

					AIBehaviour.HELIDEFAULT:heliRequest2ndGunnerShoot( entity );
				
				end

		end

		AI.CreateGoalPipe("heliAttackDefault");
		AI.PushGoal("heliAttackDefault","timeout",1,0.3);
		AI.PushGoal("heliAttackDefault","signal",0,1,"HELI_STAY_ATTACK_START",SIGNALFILTER_SENDER);
		entity:InsertSubpipe(0,"heliAttackDefault");
		return;


	end,
	--------------------------------------------------------------------------
	TO_HELI_EMERGENCYLANDING = function( self, entity, sender, data )
	end,

	--------------------------------------------------------------------------
	HELI_REFLESH_POSITION = function( self, entity, sender, data )

		AIBehaviour.HELIDEFAULT:heliRefreshStayAttackPosition( entity );

		entity.AI.time = System.GetCurrTime();

	end,

	--------------------------------------------------------------------------
	HELI_STAY_ATTACK_START = function( self, entity )

		AI.Signal(SIGNALFILTER_SENDER,1,"HELI_STAY_ATTACK", entity.id);

	end,

	--------------------------------------------------------------------------
	HELI_EXPAND_FORMATION = function( self, entity )

		AIBehaviour.HELIDEFAULT:heliGetID( entity );
		AIBehaviour.HELIDEFAULT:heliRequest2ndGunnerShoot( entity );

		local vFwd = {};
		local vWng = {};
		local vCheckPos = {};
		local vVel = {};
		local vPos = {};
		local bHaveTarget = false;
		
		CopyVector( vPos, entity:GetPos() );
		AIBehaviour.HELIDEFAULT:GetIdealWng( entity, vWng, 40.0 );

		entity:GetVelocity( vVel );
		FastScaleVector( vVel, vVel, 3.0 );

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then
			SubVectors( vFwd, target:GetPos(), entity:GetPos() );
			vFwd.z = 0;
			NormalizeVector( vFwd );
			bHaveTarget = true;
		else
			CopyVector( vFwd, entity:GetDirectionVector(1) );
			vFwd.z = 0;
			NormalizeVector( vFwd );
			bHaveTarget = false;
		end

		FastScaleVector( vCheckPos, vFwd, 50.0 );
		FastSumVectors( vCheckPos, vCheckPos, vWng );
		FastSumVectors( vCheckPos, vCheckPos, entity:GetPos() );
		FastSumVectors( vCheckPos, vCheckPos, vVel );
		AIBehaviour.HELIDEFAULT:GetAimingPosition(entity, vCheckPos );
		vCheckPos.z = vCheckPos.z-10.0;
		FastSumVectors( vPos, entity:GetPos(), vCheckPos );
		FastScaleVector( vPos, vPos, 0.5 );
		local index = 1;
		AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vPos, index );
		index = index + 1;
		AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vCheckPos, index );

		if ( AIBehaviour.HELIDEFAULT:heliCommitPathLine( entity, index, false ) == false ) then
			AI.Signal(SIGNALFILTER_SENDER,1,"HELI_STAY_ATTACK_START", entity.id);
			return;
		end

		local bRun = 1;
		if ( entity.AI.isVtol == true ) then
			bRun = 0;
		end
		local accuracy = 10;
		if ( AIBehaviour.HELIDEFAULT:heliCheckLineVoid( entity, vPos, vCheckPos, 40.0 ) == true ) then
			accuracy = 40;
		end

		FastScaleVector( vFwd, vFwd, 300.0 );
		FastSumVectors( vFwd, vFwd, entity:GetPos() );

		AI.SetRefPointPosition( entity.id , vFwd ); -- look target

		entity.AI.autoFire = 0;
		AI.CreateGoalPipe("ExpandFormation");
		AI.PushGoal("ExpandFormation","signal",1,1,"HELI_HOVER_DISABLE_REACTION",SIGNALFILTER_SENDER);
		if ( bHaveTarget == true ) then
			AI.PushGoal("ExpandFormation","locate",0,"atttarget");
			AI.PushGoal("ExpandFormation","lookat",0,0,0,true,1);
		else
			AI.PushGoal("ExpandFormation","locate",0,"refpoint");
			AI.PushGoal("ExpandFormation","lookat",0,0,0,true,1);
		end
		AI.PushGoal("ExpandFormation","firecmd",0,0);
		AI.PushGoal("ExpandFormation","run",0,bRun);
		AI.PushGoal("ExpandFormation","continuous",0,1);
		AI.PushGoal("ExpandFormation","followpath", 0, false, false, false, 0, accuracy, true );
		AI.PushGoal("ExpandFormation","signal",1,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
		AI.PushGoal("ExpandFormation","signal",1,1,"HELI_AUTOFIRE_CHECK",SIGNALFILTER_SENDER);
		AI.PushGoal("ExpandFormation","timeout",1,0.2);
		AI.PushGoal("ExpandFormation","branch",1,-3);
		AI.PushGoal("ExpandFormation","firecmd",0,0);
		AI.PushGoal("ExpandFormation","signal",0,1,"HELI_STAY_ATTACK_START",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"ExpandFormation");
	
	end,

	--------------------------------------------------------------------------
	HELI_STAY_ATTACK = function( self, entity )

		-- formation control

		-- While doing their attack approach, 
		-- they will try to get into the players FOV, 
		-- but will continue their run even if the player looks away.

		-- aquire the position
		AIBehaviour.HELIDEFAULT:heliGetID( entity );

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			if ( entity.AI.isHeliAggressive ~= nil ) then
				local target = AI.GetAttentionTargetEntity( entity.id );
				if ( target and AI.Hostile( entity.id, target.id ) ) then
					if ( AI.GetTypeOf( target.id ) == AIOBJECT_VEHICLE ) then
						if ( target.AIMovementAbility.pathType == AIPATH_TANK or target.AIMovementAbility.pathType == AIPATH_BOAT ) then
							AI.SetExtraPriority( target.id , 100.0 );
							AI.Signal(SIGNALFILTER_SENDER, 1, "TO_HELI_HOVERATTACK3", entity.id);
							return;
						end
					end
				end
				AI.Signal(SIGNALFILTER_SENDER, 1, "TO_HELI_HOVERATTACK2", entity.id);
				return;
			end

			if ( target.actor ) then
				local vehicleId = target.actor:GetLinkedVehicleId();
				if ( vehicleId ) then
					local	vehicle = System.GetEntity( vehicleId );
					if( vehicle ) then
						if ( AI.GetTypeOf( vehicleId ) == AIOBJECT_VEHICLE and AI.GetSubTypeOf( vehicleId ) == AIOBJECT_HELICOPTER ) then
							AI.Signal(SIGNALFILTER_SENDER, 1, "TO_HELI_VSAIR", entity.id);
							return;
						end
						if ( AI.GetTypeOf( vehicleId ) == AIOBJECT_VEHICLE and AI.GetSubTypeOf( vehicleId ) == AIOBJECT_BOAT ) then
							AI.Signal(SIGNALFILTER_SENDER, 1, "TO_HELI_VSBOAT", entity.id);
							return;
						end
						if ( AI.GetTypeOf( vehicleId ) == AIOBJECT_VEHICLE and AI.GetSubTypeOf( vehicleId ) == AIOBJECT_CAR ) then
							if ( entity.AI.stayPosition == 1 and vehicle.AIMovementAbility.pathType ~= AIPATH_TANK ) then
								AI.Signal(SIGNALFILTER_SENDER, 1, "TO_HELI_VSBOAT", entity.id);
								return;
							end
						end
					end
				end
			end
			if (AI.GetTypeOf( target.id ) == AIOBJECT_VEHICLE and AI.GetSubTypeOf( target.id ) == AIOBJECT_HELICOPTER ) then
				AI.Signal(SIGNALFILTER_SENDER, 1, "TO_HELI_VSAIR", entity.id);
				return;
			end
			if (AI.GetTypeOf( target.id ) == AIOBJECT_VEHICLE and AI.GetSubTypeOf( target.id ) == AIOBJECT_BOAT ) then
				AI.Signal(SIGNALFILTER_SENDER, 1, "TO_HELI_VSBOAT", entity.id);
				return;
			end
			if ( AI.GetTypeOf( target.id ) == AIOBJECT_VEHICLE and AI.GetSubTypeOf( target.id ) == AIOBJECT_CAR ) then
				local	vehicle = System.GetEntity( target.id );
				if ( vehicle and entity.AI.stayPosition == 1 and vehicle.AIMovementAbility.pathType ~= AIPATH_TANK ) then
					AI.Signal(SIGNALFILTER_SENDER, 1, "TO_HELI_VSBOAT", entity.id);
					return;
				end
			end
		else

			if ( entity.AI.isHeliAggressive ~= nil ) then
				entity.AI.waitCounter = 0;
				AI.Signal(SIGNALFILTER_SENDER,1,"TO_HELI_PATROL", entity.id);
				return;
			end
		
			if ( entity.AI.waitCounter < 5 ) then

				entity.AI.waitCounter = entity.AI.waitCounter + 1;

				AI.CreateGoalPipe("heliAttackWait2");
				AI.PushGoal("heliAttackWait2","signal",1,1,"HELI_HOVER_ENABLE_REACTION",SIGNALFILTER_SENDER);
				AI.PushGoal("heliAttackWait2","signal",0,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
				AI.PushGoal("heliAttackWait2","timeout",1,1.0);
				AI.PushGoal("heliAttackWait2","signal",0,1,"HELI_STAY_ATTACK_START",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"heliAttackWait2");
				return;
				
			else

				entity.AI.waitCounter = 0;
				AI.Signal(SIGNALFILTER_SENDER,1,"TO_HELI_PATROL", entity.id);
				return;
			
			end
		end


		if ( entity.AI.stayPosition == 1 or entity.AI.stayPosition == 2 ) then
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_HELI_HOVERATTACK", entity.id);
			return;
		end
		
		-- AI.LogEvent(entity:GetName().." selected stayattack");
		self:heliDoStayAttack( entity );

	end,

	---------------------------------------------
	OnPathFound = function( self, entity, sender )
		-- called when the AI has requested a path and it's been computed succesfully
	end,	
	---------------------------------------------
	OnNoTarget = function( self, entity )
		-- called when the AI stops having an attention target
	end,
	---------------------------------------------
	OnSomethingSeen = function( self, entity )
		-- called when the enemy sees a foe which is not a living player
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		-- called when the AI sees a living enemy
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
	OnBulletRain = function ( self, entity, sender, data )	
		self:OnEnemyDamage( entity, sender, data );
	end,
	--------------------------------------------------------------------------
	OnSoreDamage = function ( self, entity, sender, data )
		self:OnEnemyDamage( entity, sender, data );
	end,
	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender, data )

		if ( AIBehaviour.HELIDEFAULT:heliCheckDamageRatio( entity ) == true ) then
			return;
		end
		if ( AIBehaviour.HELIDEFAULT:heliCheckDamage( entity, data ) == false ) then
			return;
		end

		if ( entity.AI.bBlockSignal ==true ) then
		
		elseif ( data.fValue > 0.0 ) then

			local targetEntity;
			if ( data and data.id ) then
				targetEntity = System.GetEntity( data.id );
			else
				return;
			end

			if ( targetEntity ) then

			else
				return;
			end

			AIBehaviour.HELIDEFAULT:heliTakeEvadeAction( entity, "HELI_STAY_ATTACK_START", targetEntity );
		
		end

	end,
	
	---------------------------------------------
	HELI_TAKE_EVADEACTION = function ( self, entity, sender, data )

		local targetEntity = System.GetEntity( g_localActor.id );

		if ( targetEntity ) then

			AIBehaviour.HELIDEFAULT:heliTakeEvadeAction( entity, "HELI_STAY_ATTACK_START", targetEntity );

		end

	end,	
	---------------------------------------------
	OnDamage = function ( self, entity, sender, data )
	end,
	
	---------------------------------------------
	OnGroupMemberDied = function( self, entity, sender )
		-- called when a member of same species dies nearby
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
	
	---------------------------------------------
	---------------------------------------------
	----------------------------------------------------FUNCTIONS 
	PatrolPath = function (self, entity, sender)
		-- select next tagpoint for patrolling
		local name = entity:GetName();
		local tpname = name.."_P"..entity.AI.PathStep;
		local TagPoint = System.GetEntityByName(tpname);
		if (TagPoint== nil) then 		
			entity.AI.PathStep = 0;
			tpname = name.."_P"..entity.AI.PathStep;
AI.LogEvent(">>>>helipath looping "..tpname);
		end
AI.LogEvent(">>>>helipath selecting "..tpname);		
		entity:SelectPipe(0,"h_attack",tpname);
		entity.AI.PathStep = entity.AI.PathStep + 1;
	end,
	

	---------------------------------------------
	Relocate = function( self, entity )


		-- Use the current target or the last seen enemy.
		if( not entity.AI.targetName ) then
			local targetName = AI.GetAttentionTargetOf(entity.id);
			if( targetName ) then
				entity.AI.targetName = targetName;
			else
				entity.AI.targetName = entity.AI.lastSeenName;
			end
		end
		
		-- Approach the target.
		if( entity.AI.targetName ) then
		
AI.LogEvent(">>>>heliattack target >> "..entity.AI.targetName);		
		
			local attackPos = g_Vectors.temp_v1;
			local attackDir = g_Vectors.temp_v2;
			local validPos = 0;

			local enemy = System.GetEntityByName(entity.AI.targetName);
			if( enemy ) then

				local targetPos = enemy:GetPos();
				local targetDir = enemy:GetDirectionVector();

--				validPos = AI.GetHeliAdvancePoint( entity.id, 0, targetPos, targetDir, attackPos, attackDir );
				validPos = AI.GetAlienApproachParams( entity.id, 0, targetPos, targetDir, attackPos, attackDir );
			end

			if( validPos > 0 ) then
				-- found valid target position
				AI.SetRefPointPosition( entity.id, attackPos );
				AI.SetRefPointDirection( entity.id, attackDir );
				entity:SelectPipe(0,"h_attack_approach", entity.AI.targetName);
			else
				AI.Signal( SIGNALFILTER_SENDER, 1, "GO_ENEMY_LOST", entity.id);
			end
		else
		
AI.LogEvent(">>>>heliattack NO TARGET ");
--			AI.Signal( SIGNALFILTER_SENDER, 1, "GO_ENEMY_LOST", entity.id);
		end
	end,
	
	---------------------------------------------
	H_CHOOSE_ATTACK_ACTION  = function (self, entity, sender)
	
		AI.Signal(SIGNALFILTER_SENDER, 1, "Relocate", entity.id);
	
	end,
	
	--------------------------------------------------------------------------
	heliDoStayAttack = function( self, entity )

		entity:SelectPipe(0,"do_nothing");

		AIBehaviour.HELIDEFAULT:heliRefreshStayAttackPosition( entity );
		local heliAttackCenterPos = {};
		AIBehaviour.HELIDEFAULT:heliGetStayAttackPosition( entity , heliAttackCenterPos , 0 );
		AI.SetRefPointPosition( entity.id , heliAttackCenterPos  );
		entity:SelectPipe(0,"do_nothing");

		-- when he can'g get a target
		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then
		else
				if ( entity.AI.waitCounter < 5 ) then

					entity.AI.waitCounter = entity.AI.waitCounter + 1;

					AI.CreateGoalPipe("heliAttackWait2");
					AI.PushGoal("heliAttackWait2","signal",1,1,"HELI_HOVER_ENABLE_REACTION",SIGNALFILTER_SENDER);
					AI.PushGoal("heliAttackWait2","signal",0,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
					AI.PushGoal("heliAttackWait2","timeout",1,1.0);
					AI.PushGoal("heliAttackWait2","signal",0,1,"HELI_STAY_ATTACK_START",SIGNALFILTER_SENDER);
					entity:SelectPipe(0,"heliAttackWait2");
					return;
					
				else

					entity.AI.waitCounter = 0;
					AI.Signal(SIGNALFILTER_SENDER,1,"TO_HELI_PATROL", entity.id);
					return;
				
				end
			

		end

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			local vVec = {};
			local vMid = {};
			SubVectors( vVec, heliAttackCenterPos, entity:GetPos() );

			local	length = LengthVector( vVec );
			if ( length < 30.0 ) then
				CopyVector( vVec , entity:GetPos() );
				if ( random( 0, 1 ) == 0 ) then
					vVec.z = vVec.z + 15.0;
				else
					vVec.z = vVec.z - 15.0;
				end

				local index = 1;
				FastSumVectors( vMid, vVec, entity:GetPos() );
				FastScaleVector( vMid, vMid, 0.5 );
				AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vMid, index );

				index = index +1;
				AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vVec, index );
				if ( AIBehaviour.HELIDEFAULT:heliCommitPathLine( entity, index, true ) == false ) then
					--System.DrawLabel( entity:GetPos(), 8, "COMMIT FAILED", 1, 1, 1, 1);
					entity:SelectPipe(0,"heliJustStay");
					return;
				end
				entity:SelectPipe(0,"do_nothing");
				AI.CreateGoalPipe("heliStandBy");
				AI.PushGoal("heliStandBy","signal",1,1,"HELI_HOVER_ENABLE_REACTION",SIGNALFILTER_SENDER);
				AI.PushGoal("heliStandBy","firecmd",0,0);
				AI.PushGoal("heliStandBy","locate",0,"refpoint");
				AI.PushGoal("heliStandBy","lookat",0,0,0,true,1);
				AI.PushGoal("heliStandBy","run",0,0);
				AI.PushGoal("heliStandBy","continuous",0,1);
				AI.PushGoal("heliStandBy","timeout",1,3);
				AI.PushGoal("heliStandBy","followpath", 0, false, false, false, 0, 10, true );
				AI.PushGoal("heliStandBy","signal",1,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
				AI.PushGoal("heliStandBy","timeout",1,0.2);
				AI.PushGoal("heliStandBy","branch",1,-2);
				AI.PushGoal("heliStandBy","firecmd",0,0);
				AI.PushGoal("heliStandBy","signal",1,1,"HELI_HOVER_START_AIMING",SIGNALFILTER_SENDER);
				AI.PushGoal("heliStandBy","signal",1,1,"HELI_STAY_ATTACK_START",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"heliStandBy");
				return;
			end

			local vVel = {};
	
			FastSumVectors( vVec, heliAttackCenterPos, entity:GetPos() );
			FastScaleVector( vVec, vVec, 0.5 );
			SubVectors( vVec, vVec, target:GetPos() );
			vVec.z = 0;
			NormalizeVector( vVec );
			FastScaleVector( vVec, vVec, DistanceVectors( target:GetPos(), heliAttackCenterPos ) );
			FastSumVectors( vVec, vVec, target:GetPos() );
			vVec.z = heliAttackCenterPos.z;

			FastSumVectors( vVel, vVec, entity:GetPos() );
			FastScaleVector( vVel, vVel, 0.5 );

			local index = 1;
			AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vVel, index );

			index = index + 1;
			AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vVec, index );

			index = index + 1;
			AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, heliAttackCenterPos, index );
	
			if ( AIBehaviour.HELIDEFAULT:heliCommitPathLine( entity, index, true ) == false ) then
				index = index - 1;
				if ( AIBehaviour.HELIDEFAULT:heliCommitPathLine( entity, index, true ) == false ) then
					--System.DrawLabel( entity:GetPos(), 8, "COMMIT FAILED", 1, 1, 1, 1);
					entity:SelectPipe(0,"heliJustStay");
					return;
				end
			end

			AI.SetRefPointPosition( entity.id , target:GetPos() ); -- look target
	
			entity:SelectPipe(0,"do_nothing");
			AI.CreateGoalPipe("heliAttack");
			AI.PushGoal("heliAttack","signal",1,1,"HELI_HOVER_ENABLE_REACTION",SIGNALFILTER_SENDER);
			AI.PushGoal("heliAttack","firecmd",0,0);
			AI.PushGoal("heliAttack","locate",0,"refpoint");
			AI.PushGoal("heliAttack","lookat",0,0,0,true,1);
			AI.PushGoal("heliAttack","run",0,0);
			AI.PushGoal("heliAttack","continuous",0,1);
			AI.PushGoal("heliAttack","followpath", 0, false, false, false, 0, 10, true );
			AI.PushGoal("heliAttack","signal",1,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
			AI.PushGoal("heliAttack","timeout",1,0.2);
			AI.PushGoal("heliAttack","branch",1,-2);
			AI.PushGoal("heliAttack","firecmd",0,0);
			AI.PushGoal("heliAttack","signal",1,1,"HELI_HOVER_START_AIMING",SIGNALFILTER_SENDER);
			AI.PushGoal("heliAttack","signal",1,1,"HELI_STAY_ATTACK_START",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"heliAttack");

		else
			--System.DrawLabel( entity:GetPos(), 8, "HOGE", 1, 1, 1, 1);
			entity:SelectPipe(0,"heliJustStay");
			return;
		end		

	end,

}
