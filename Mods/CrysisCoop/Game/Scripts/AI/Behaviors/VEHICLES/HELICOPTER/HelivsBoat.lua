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
--  - 15/03/2006   : Created by Tetsuji
--------------------------------------------------------------------------

local Xaxis = 0;
local Yaxis = 1;
local Zaxis = 2;

--------------------------------------------------------------------------
AIBehaviour.HelivsBoat = {
	Name = "HelivsBoat",
	Base = "HeliBase",
	alertness = 2,

	--------------------------------------------------------------------------
	Constructor = function ( self, entity, data )

		-- for common signal handlers.

		entity.AI.heliDefaultSignal = "HELI_VSBOAT_START";
		entity.AI.heliMemorySignal = "TO_HELI_ATTACK";

		-- called when the behaviour is selected

		AI.CreateGoalPipe("heliVsBoatDefault");
		AI.PushGoal("heliVsBoatDefault","timeout",1,0.3);
		AI.PushGoal("heliVsBoatDefault","signal",0,1,"HELI_VSBOAT_START",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"heliVsBoatDefault");

	end,

	---------------------------------------------
	OnPathFound = function( self, entity, sender )
		-- called when the AI has requested a path and it's been computed succesfully
	end,	
	--------------------------------------------------------------------------
	OnNoTarget = function( self, entity )
		-- called when the AI stops having an attention target
		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_HELI_ATTACK", entity.id);
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
		self:OnEnemyDamage(entity);
	end,
	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender, data )

		if ( AIBehaviour.HELIDEFAULT:heliCheckDamageRatio( entity ) == true ) then
			return;
		end
		if ( AIBehaviour.HELIDEFAULT:heliCheckDamage( entity, data ) == false ) then
			return;
		end

		if ( entity.AI.bBlockSignal == false ) then
			entity.AI.bBlockSignal = true;
			AI.Signal(SIGNALFILTER_SENDER, 1, "HELI_VSBOAT", entity.id);
		
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

	--------------------------------------------------------------------------
	-- local signal handers
	--------------------------------------------------------------------------
	HELI_VSBOAT_START = function( self, entity )

		local speed = entity:GetSpeed();
		
		if ( speed < 5.0 ) then
			self:HELI_VSBOAT( entity );
		else
			AI.CreateGoalPipe("heliVsBoatWaitStop");
			AI.PushGoal("heliVsBoatWaitStop","timeout",1,0.3);
			AI.PushGoal("heliVsBoatWaitStop","signal",0,1,"HELI_VSBOAT",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"heliVsBoatWaitStop");
		end

	end,

	--------------------------------------------------------------------------
	HELI_VSBOAT_ERROR = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			entity:SelectPipe(0,"do_nothing");
	
			local vPos = {};
			local vTargetPos = {};
			CopyVector( vPos, entity:GetPos() );
			vPos.z = vPos.z + 30.0;
	
			local index = 1;
			AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vPos, index );
	
			CopyVector( vTargetPos, target:GetPos() );
			vTargetPos.z = vPos.z;
	
			index = index + 1;
			AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vTargetPos, index );
	
			if ( AIBehaviour.HELIDEFAULT:heliCommitPathLine( entity, index, true ) == false ) then
				entity:SelectPipe(0,"heliVsBoatDefault");
				return;
			end


			entity.AI.autoFire = 0;

			AI.SetRefPointPosition( entity.id , entity.AI.followVectors[index] );
			local bRun = 2;
			if ( entity.AI.isVtol == true ) then
				bRun = 0;
			end

			AI.CreateGoalPipe("heliHoveringUp");
			AI.PushGoal("heliHoveringUp","firecmd",0,0);
			AI.PushGoal("heliHoveringUp","continuous",0,0);
			AI.PushGoal("heliHoveringUp","locate",0,"refpoint");
			AI.PushGoal("heliHoveringUp","lookat",0,0,0,true,1);
			AI.PushGoal("heliHoveringUp","timeout",1,0.3);
			AI.PushGoal("heliHoveringUp","run",0,bRun);	
			AI.PushGoal("heliHoveringUp","followpath", 0, false, false, false, 0, 10, true );
			AI.PushGoal("heliHoveringUp","signal",1,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
			AI.PushGoal("heliHoveringUp","timeout",1,0.2);
			AI.PushGoal("heliHoveringUp","branch",1,-2);
			AI.PushGoal("heliHoveringUp","locate",0,"atttarget");
			AI.PushGoal("heliHoveringUp","lookat",0,0,0,true,1);
			AI.PushGoal("heliHoveringUp","timeout",1,1.0);
			AI.PushGoal("heliHoveringUp","signal",1,1,"HELI_HOVER_ENABLE_REACTION",SIGNALFILTER_SENDER);
			AI.PushGoal("heliHoveringUp","signal",1,1,"HELI_VSBOAT_START",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"heliHoveringUp");

		else
			entity:SelectPipe(0,"heliVsBoatDefault");
			return;
		end

	end,

	--------------------------------------------------------------------------
	HELI_VSBOAT = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			-- check if the target is riding on the boat/car

			local bBoat = false;
			if ( target.actor ) then
				local vehicleId = target.actor:GetLinkedVehicleId();
				if ( vehicleId ) then
					local	vehicle = System.GetEntity( vehicleId );
					if( vehicle ) then
						if ( AI.GetTypeOf( vehicleId ) == AIOBJECT_VEHICLE and AI.GetSubTypeOf( vehicleId ) == AIOBJECT_BOAT ) then
							bBoat = true;
						end
						if ( AI.GetTypeOf( vehicleId ) == AIOBJECT_VEHICLE and AI.GetSubTypeOf( vehicleId ) == AIOBJECT_CAR ) then
							if ( vehicle.AIMovementAbility.pathType ~= AIPATH_TANK ) then
								bBoat = true;
							end
						end
					end
				end
			end

			if ( AI.GetTypeOf( target.id ) == AIOBJECT_VEHICLE and AI.GetSubTypeOf( target.id ) == AIOBJECT_BOAT ) then
				bBoat = true;
			end
			if ( AI.GetTypeOf( target.id ) == AIOBJECT_VEHICLE and AI.GetSubTypeOf( target.id ) == AIOBJECT_CAR ) then
				local	vehicle = System.GetEntity( target.id );
				if ( vehicle and vehicle.AIMovementAbility.pathType ~= AIPATH_TANK ) then
					bBoat = true;
				end
			end

			if ( bBoat == false ) then
				AI.Signal(SIGNALFILTER_SENDER, 1, "TO_HELI_ATTACK", entity.id);
				return;
			end

			if ( DistanceVectors( entity:GetPos(), target:GetPos() ) > 200.0 ) then
			
				local vPos = {};
				local vTargetPos = {};
				CopyVector( vPos, entity:GetPos() );
		
				local index = 1;
				AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vPos, index );
		
				CopyVector( vTargetPos, target:GetPos() );
				vTargetPos.z = vPos.z;
		
				index = index + 1;
				AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vTargetPos, index );

				local accuracy = 10;
				if ( AIBehaviour.HELIDEFAULT:heliCheckLineVoid( entity, vPos, vTargetPos, 40.0 ) == true ) then
					accuracy = 40;
				end
		
				if ( AIBehaviour.HELIDEFAULT:heliCommitPathLine( entity, index, true ) == false ) then
					entity:SelectPipe(0,"heliVsBoatDefault");
					return;
				end

				entity.AI.autoFire = 0;
	
				AI.SetRefPointPosition( entity.id , entity.AI.followVectors[index] );
				local bRun = 2;
				if ( entity.AI.isVtol == true ) then
					bRun = 0;
				end
	
				AI.CreateGoalPipe("heliChasePlayer");
				AI.PushGoal("heliChasePlayer","firecmd",0,0);
				AI.PushGoal("heliChasePlayer","continuous",0,0);
				AI.PushGoal("heliChasePlayer","locate",0,"refpoint");
				AI.PushGoal("heliChasePlayer","lookat",0,0,0,true,1);
				AI.PushGoal("heliChasePlayer","timeout",1,0.3);
				AI.PushGoal("heliChasePlayer","run",0,bRun);	
				AI.PushGoal("heliChasePlayer","followpath", 0, false, false, false, 0, accuracy, true );
				AI.PushGoal("heliChasePlayer","signal",1,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
				AI.PushGoal("heliChasePlayer","signal",1,1,"HELI_VSBOAT_DESTINATION_CHECK3",SIGNALFILTER_SENDER);
				AI.PushGoal("heliChasePlayer","timeout",1,0.2);
				AI.PushGoal("heliChasePlayer","branch",1,-3);
				AI.PushGoal("heliChasePlayer","signal",1,1,"HELI_HOVER_ENABLE_REACTION",SIGNALFILTER_SENDER);
				AI.PushGoal("heliChasePlayer","signal",1,1,"HELI_VSBOAT_START",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"heliChasePlayer");
			
				return;
			end

			-- expect the position after 10 sec

			local vVel = {};
			target:GetVelocity( vVel );
			FastScaleVector( vVel, vVel, 13.0 );

			AIBehaviour.HELIDEFAULT:heliGetID( entity );
			AIBehaviour.HELIDEFAULT:heliRefreshStayAttackPosition( entity );


			local heliAttackCenterPos = {};
			AIBehaviour.HELIDEFAULT:heliGetStayAttackPosition( entity, heliAttackCenterPos, 1 );

			local vTmp = {};
			FastSumVectors( vTmp, heliAttackCenterPos, vVel );

			if ( DistanceVectors( entity:GetPos(), vTmp ) < 50.0 ) then

				if (random(1,3) == 1) then
					AI.CreateGoalPipe("heliVsBoatWaitStop2");
					AI.PushGoal("heliVsBoatWaitStop2","timeout",1,1.3);
					AI.PushGoal("heliVsBoatWaitStop2","signal",0,1,"HELI_VSBOAT",SIGNALFILTER_SENDER);
					entity:SelectPipe(0,"heliVsBoatWaitStop2");
					return;
				end

				local vUnitDirToTarget = {};
				local vPos = {};

				local vWng = { x = 1.0, y = 0.0, z = 0.0 };
				local vUp = { x = 0.0, y = 0.0, z = 1.0 };

				SubVectors( vUnitDirToTarget, target:GetPos(), entity:GetPos() );
				NormalizeVector( vUnitDirToTarget );
				crossproduct3d( vWng, vUnitDirToTarget, vUp );
				
				local pat = random(1,3);
				if ( pat == 1 ) then
					FastScaleVector( vWng, vWng, 30.0 );
				elseif ( pat == 2 ) then
					FastScaleVector( vWng, vWng, -30.0 );
				end

				pat = random(1,3);
				if ( pat == 1 ) then
					FastScaleVector( vUp, vUp, 10.0 );
				elseif ( pat == 2 ) then
					FastScaleVector( vUp, vUp, -10.0 );
				end

				FastScaleVector( vUnitDirToTarget, vUnitDirToTarget, 30.0 );

				FastSumVectors( vPos, vWng, entity:GetPos() );
				FastSumVectors( vPos, vPos, vUp );
				FastSumVectors( vPos, vPos, vUnitDirToTarget );
				
				local index = 1;
				AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, entity:GetPos(), index );

				index = index + 1;
				AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vPos, index );

				if ( AIBehaviour.HELIDEFAULT:heliCommitPathLine( entity, index, true ) == false ) then
					AI.Signal(SIGNALFILTER_SENDER, 1, "HELI_VSBOAT_ERROR", entity.id);
					return;
				end

				local bRun = 1;
				if ( entity.AI.isVtol == true ) then
					bRun = 0;
				end

				entity.AI.autoFire = 0;

				AI.CreateGoalPipe("heliStayAroundTheBoat");
				AI.PushGoal("heliStayAroundTheBoat","firecmd",0,0);
				AI.PushGoal("heliStayAroundTheBoat","continuous",0,0);
				AI.PushGoal("heliStayAroundTheBoat","locate",0,"atttarget");
				AI.PushGoal("heliStayAroundTheBoat","lookat",0,0,0,true,1);
				AI.PushGoal("heliStayAroundTheBoat","timeout",1,0.3);
				AI.PushGoal("heliStayAroundTheBoat","run",0,bRun);	
				AI.PushGoal("heliStayAroundTheBoat","followpath", 0, false, false, false, 0, 10, true );
				AI.PushGoal("heliStayAroundTheBoat","signal",1,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
				AI.PushGoal("heliStayAroundTheBoat","signal",1,1,"HELI_AUTOFIRE_CHECK",SIGNALFILTER_SENDER);
				AI.PushGoal("heliStayAroundTheBoat","timeout",1,0.2);
				AI.PushGoal("heliStayAroundTheBoat","branch",1,-3);
				AI.PushGoal("heliStayAroundTheBoat","locate",0,"atttarget");
				AI.PushGoal("heliStayAroundTheBoat","lookat",0,0,0,true,1);
				AI.PushGoal("heliStayAroundTheBoat","timeout",1,1.0);
				AI.PushGoal("heliStayAroundTheBoat","signal",1,1,"HELI_HOVER_ENABLE_REACTION",SIGNALFILTER_SENDER);
				AI.PushGoal("heliStayAroundTheBoat","signal",1,1,"HELI_VSBOAT_START",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"heliStayAroundTheBoat");
				return;

			else
				local distance = DistanceVectors( target:GetPos(), entity:GetPos() );
				if (  distance > 50.0 and distance < 170.0 ) then
					if ( random(1,3) == 1 ) then

						local vDirToTarget = {};
						SubVectors( vDirToTarget, target:GetPos(), entity:GetPos() );
						vDirToTarget.z =0;
						FastSumVectors( vDirToTarget, vDirToTarget, target:GetPos() );

						local index = 1;
						AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, entity:GetPos(), index );

						index = index + 1;
						AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vDirToTarget, index );

						if ( AIBehaviour.HELIDEFAULT:heliCommitPathLine( entity, index, false ) == false ) then
							AI.Signal(SIGNALFILTER_SENDER, 1, "HELI_VSBOAT_ERROR", entity.id);
							return;
						end

						local bRun = 2;
						if ( entity.AI.isVtol == true ) then
							bRun = 0;
						end

						entity.AI.autoFire = 0;
		
						AI.SetRefPointPosition( entity.id , entity.AI.followVectors[index] );

						AI.CreateGoalPipe("heliRushToTheBoat2");
						AI.PushGoal("heliRushToTheBoat2","signal",1,1,"HELI_HOVER_DISABLE_REACTION",SIGNALFILTER_SENDER);
						AI.PushGoal("heliRushToTheBoat2","continuous",0,1);
						AI.PushGoal("heliRushToTheBoat2","locate",0,"refpoint");
						AI.PushGoal("heliRushToTheBoat2","lookat",0,0,0,true,1);
						AI.PushGoal("heliRushToTheBoat2","firecmd",0,0);
						AI.PushGoal("heliRushToTheBoat2","timeout",1,0.5);
						AI.PushGoal("heliRushToTheBoat2","run",0,bRun);	
						AI.PushGoal("heliRushToTheBoat2","followpath", 0, false, false, false, 0, 10, true );
						AI.PushGoal("heliRushToTheBoat2","signal",1,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
						AI.PushGoal("heliRushToTheBoat2","signal",1,1,"HELI_AUTOFIRE_CHECK",SIGNALFILTER_SENDER);
						AI.PushGoal("heliRushToTheBoat2","signal",1,1,"HELI_VSBOAT_DESTINATION_CHECK4",SIGNALFILTER_SENDER);
						AI.PushGoal("heliRushToTheBoat2","timeout",1,0.2);
						AI.PushGoal("heliRushToTheBoat2","branch",1,-4);
						AI.PushGoal("heliRushToTheBoat2","locate",0,"atttarget");
						AI.PushGoal("heliRushToTheBoat2","lookat",0,0,0,true,1);
						AI.PushGoal("heliRushToTheBoat2","timeout",1,1.0);
						AI.PushGoal("heliRushToTheBoat2","signal",0,1,"HELI_VSBOAT_START",SIGNALFILTER_SENDER);
						entity:SelectPipe(0,"heliRushToTheBoat2");
						return;
	
					end
				end

				local index = 1;
				AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, entity:GetPos(), index );

				index = index + 1;
				AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vTmp, index );

				if ( AIBehaviour.HELIDEFAULT:heliCommitPathLine( entity, index, false ) == false ) then
					AI.Signal(SIGNALFILTER_SENDER, 1, "HELI_VSBOAT_ERROR", entity.id);
					return;
				end

				local bRun = 2;
				if ( entity.AI.isVtol == true ) then
					bRun = 0;
				end


				entity.AI.autoFire = 0;

				AI.SetRefPointPosition( entity.id , vTmp );

				AI.CreateGoalPipe("heliRushToTheBoat");

				AI.PushGoal("heliRushToTheBoat","signal",1,1,"HELI_HOVER_DISABLE_REACTION",SIGNALFILTER_SENDER);
				AI.PushGoal("heliRushToTheBoat","continuous",0,1);
				AI.PushGoal("heliRushToTheBoat","lookat",0,-500,0);
				AI.PushGoal("heliRushToTheBoat","locate",0,"refpoint");
				AI.PushGoal("heliRushToTheBoat","lookat",0,0,0,true,1);
				AI.PushGoal("heliRushToTheBoat","firecmd",0,0);
				AI.PushGoal("heliRushToTheBoat","timeout",1,0.5);
				AI.PushGoal("heliRushToTheBoat","run",0,bRun);	
				AI.PushGoal("heliRushToTheBoat","followpath", 0, false, false, false, 0, 10, true );
				AI.PushGoal("heliRushToTheBoat","signal",1,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
				AI.PushGoal("heliRushToTheBoat","signal",1,1,"HELI_AUTOFIRE_CHECK",SIGNALFILTER_SENDER);
				AI.PushGoal("heliRushToTheBoat","signal",1,1,"HELI_VSBOAT_DESTINATION_CHECK4",SIGNALFILTER_SENDER);
				AI.PushGoal("heliRushToTheBoat","timeout",1,0.2);
				AI.PushGoal("heliRushToTheBoat","branch",1,-4);

				AI.PushGoal("heliRushToTheBoat","locate",0,"atttarget");
				AI.PushGoal("heliRushToTheBoat","lookat",0,0,0,true,1);
				AI.PushGoal("heliRushToTheBoat","timeout",1,1.0);

				AI.PushGoal("heliRushToTheBoat","signal",0,1,"HELI_VSBOAT_START",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"heliRushToTheBoat");
				return;
			end

		else
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_HELI_ATTACK", entity.id);
		end

	end,

	--------------------------------------------------------------------------
	HELI_VSBOAT_DESTINATION_CHECK3 = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			if ( DistanceVectors( entity:GetPos(), target:GetPos() ) < 100.0 ) then
				AI.Signal(SIGNALFILTER_SENDER, 1, "HELI_VSBOAT_START", entity.id);
			end

		end

	end,

	--------------------------------------------------------------------------
	HELI_VSBOAT_DESTINATION_CHECK4 = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			local distance = DistanceVectors( target:GetPos(), entity:GetPos() );
			if (  distance > 200.0 ) then
				AI.Signal(SIGNALFILTER_SENDER, 1, "HELI_VSBOAT_START", entity.id);
			end

		end

	end,

}

