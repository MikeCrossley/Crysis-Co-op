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
AIBehaviour.HelivsAir = {
	Name = "HeliVsAir",
	Base = "HeliBase",
	alertness = 2,

	--------------------------------------------------------------------------
	Constructor = function ( self, entity, data )

		-- for common signal handlers.

		entity.AI.heliDefaultSignal = "HELI_VSAIR_START";
		entity.AI.heliMemorySignal = "TO_HELI_ATTACK";
		entity.AI.vAirBattlePoint = {};
		entity.AI.bAirBattlePoint = false;
		CopyVector( entity.AI.vAirBattlePoint, entity:GetPos() );

		-- called when the behaviour is selected

		AI.CreateGoalPipe("heliVsAirDefault");
		AI.PushGoal("heliVsAirDefault","timeout",1,0.3);
		AI.PushGoal("heliVsAirDefault","signal",0,1,"HELI_VSAIR_START",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"heliVsAirDefault");

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

--[[
		if ( entity.AI.bBlockSignal == false ) then
			entity.AI.bBlockSignal = true;
			AI.Signal(SIGNALFILTER_SENDER, 1, "HELI_VSBOAT", entity.id);
		end
--]]

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
	-- handlers as common functions
	--------------------------------------------------------------------------
	HELI_VSAIR_GET_FLIGHTHEIGHT = function( self, entity )
		
		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			local myLevel = System.GetTerrainElevation( entity:GetPos() );
			local myWaterLevel = AI.IsPointInWaterRegion( entity:GetPos() )
			if ( myWaterLevel  > 0.0 ) then
				myLevel = myLevel + myWaterLevel;
			end

			local targetLevel = System.GetTerrainElevation( target:GetPos() );
			local targetWaterLevel = AI.IsPointInWaterRegion( target:GetPos() );
			if ( targetWaterLevel  > 0.0 ) then
				targetLevel = targetLevel + targetWaterLevel;
			end

			local idealLevel = ( myLevel + targetLevel + 120.0 ) / 2.0;
		
			return idealLevel;
	
		else
	
			local vMyPos = {};
			CopyVector( vMyPos, entity:GetPos() );
			return vMyPos.z;
	
		end
	
	end,

	--------------------------------------------------------------------------
	-- local signal handers
	--------------------------------------------------------------------------
	HELI_VSAIR_START = function( self, entity )

		local speed = entity:GetSpeed();
		
		if ( speed < 5.0 ) then
			if ( entity.AI.isVtol == true ) then
				self:VTOL_VSAIR( entity );
			else
				self:HELI_VSAIR( entity );
			end
		else
			entity:SelectPipe(0,"do_nothing");
			if ( entity.AI.isVtol == true ) then
				AI.CreateGoalPipe("vtolVsAirWaitStop");
				AI.PushGoal("vtolVsAirWaitStop","continuous",0,0);
				AI.PushGoal("vtolVsAirWaitStop","firecmd",0,0);
				AI.PushGoal("vtolVsAirWaitStop","locate",0,"atttarget");
				AI.PushGoal("vtolVsAirWaitStop","lookat",0,0,0,true,1);
				AI.PushGoal("vtolVsAirWaitStop","signal",1,1,"HELI_AUTOFIRE_CHECK",SIGNALFILTER_SENDER);
				AI.PushGoal("vtolVsAirWaitStop","timeout",1,0.3);	
				AI.PushGoal("vtolVsAirWaitStop","signal",0,1,"HELI_VSAIR_START",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"vtolVsAirWaitStop");
			else
				AI.CreateGoalPipe("heliVsAirWaitStop");
				AI.PushGoal("heliVsAirWaitStop","timeout",1,0.3);
				AI.PushGoal("heliVsAirWaitStop","signal",0,1,"HELI_VSAIR_START",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"heliVsAirWaitStop");
			end
		end

	end,

	--------------------------------------------------------------------------
	VTOL_VSAIR = function( self, entity )

		local vMyPos = {};
		CopyVector( vMyPos, entity:GetPos() );

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			-- get a battle point. he will stay within 200m from this point.

			if ( entity.AI.bAirBattlePoint == false ) then
				entity.AI.bAirBattlePoint = true;
				FastSumVectors( entity.AI.vAirBattlePoint, entity:GetPos(), target:GetPos() );
				FastScaleVector( entity.AI.vAirBattlePoint, entity.AI.vAirBattlePoint, 0.5 );
			end

			-- check if the target is heli or vtol

			entity:SelectPipe(0,"do_nothing");

			local bHeli = false;
			if ( target.actor ) then
				local vehicleId = target.actor:GetLinkedVehicleId();
				if ( vehicleId ) then
					local	vehicle = System.GetEntity( vehicleId );
					if( vehicle ) then
						if ( AI.GetTypeOf( vehicleId ) == AIOBJECT_VEHICLE and AI.GetSubTypeOf( vehicleId ) == AIOBJECT_HELICOPTER ) then
							bHeli = true;
						end
					end
				end
			end

			if ( AI.GetTypeOf( target.id ) == AIOBJECT_VEHICLE and AI.GetSubTypeOf( target.id ) == AIOBJECT_HELICOPTER ) then
				bHeli = true;
			end

			if ( bHeli == false ) then
				AI.Signal(SIGNALFILTER_SENDER, 1, "TO_HELI_ATTACK", entity.id);
				return;
			end

			-- stay in the air/ each other

			local idealLevel = self:HELI_VSAIR_GET_FLIGHTHEIGHT( entity );

			local vNextPoint = {};
			SubVectors( vNextPoint, entity:GetPos(), entity.AI.vAirBattlePoint );
			NormalizeVector( vNextPoint );
			FastScaleVector( vNextPoint,  vNextPoint, 150.0 );

			local angle;
			local pat = random(2,3);

			if ( pat == 1 ) then
				self:HELI_VSAIR_STRAFE( entity );
				return;
			end

			if ( pat == 2 ) then
				angle = 30;
			else
				angle = 60;
			end

			if ( random( 1, 2 ) == 1 ) then
				angle = angle * -1.0;
			end

			local vNextPointR = {};
			local vUp = { x = 0.0, y = 0.0, z = 1.0 };
			RotateVectorAroundR( vNextPointR, vNextPoint, vUp, 3.1416* 2.0 * angle / 360.0 );
			FastSumVectors( vNextPoint, vNextPointR, entity.AI.vAirBattlePoint );
			vNextPoint.z = idealLevel;

			local index = 1;
			AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, entity:GetPos(), index );

			index = index + 1;
			AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vNextPoint, index );

			local accuracy = 10;
			if ( AIBehaviour.HELIDEFAULT:heliCheckLineVoid( entity, entity:GetPos(), vNextPoint, 70.0 ) == true ) then
				accuracy = 40;
			end

			if ( AIBehaviour.HELIDEFAULT:heliCommitPathLine( entity, index, false ) == false ) then
				entity:SelectPipe(0,"heliVsAirDefault");
				return;
			end

			entity.AI.autoFire = 0;

			AI.SetRefPointPosition( entity.id , entity.AI.followVectors[index] );

			AI.CreateGoalPipe("VtolVsAirHover");
			AI.PushGoal("VtolVsAirHover","continuous",0,1);
			AI.PushGoal("VtolVsAirHover","firecmd",0,0);
			AI.PushGoal("VtolVsAirHover","timeout",1,0.5);
			AI.PushGoal("VtolVsAirHover","run",0,1);	
			if ( pat ~= 3 ) then
				AI.PushGoal("VtolVsAirHover","locate",0,"atttarget");
				AI.PushGoal("VtolVsAirHover","lookat",0,0,0,true,1);
			end
			AI.PushGoal("VtolVsAirHover","followpath", 0, false, false, false, 0, accuracy, true );
			AI.PushGoal("VtolVsAirHover","signal",1,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
			AI.PushGoal("VtolVsAirHover","signal",1,1,"HELI_AUTOFIRE_CHECK",SIGNALFILTER_SENDER);

			if ( pat ~= 3 ) then
				AI.PushGoal("VtolVsAirHover","locate",0,"atttarget");
				AI.PushGoal("VtolVsAirHover","lookat",0,0,0,true,1);
				AI.PushGoal("VtolVsAirHover","timeout",1,0.2);
				AI.PushGoal("VtolVsAirHover","branch",1,-5);
			else
				AI.PushGoal("VtolVsAirHover","timeout",1,0.2);
				AI.PushGoal("VtolVsAirHover","branch",1,-3);
			end
			AI.PushGoal("VtolVsAirHover","locate",0,"atttarget");
			AI.PushGoal("VtolVsAirHover","lookat",0,0,0,true,1);
			AI.PushGoal("VtolVsAirHover","timeout",1,3.0);
			AI.PushGoal("VtolVsAirHover","signal",1,1,"HELI_HOVER_ENABLE_REACTION",SIGNALFILTER_SENDER);

			if ( random( 1, 3 ) == 1 ) then
				AI.PushGoal("VtolVsAirHover","signal",1,1,"HELI_VSAIR_LINESHOOT",SIGNALFILTER_SENDER);
			else
				AI.PushGoal("VtolVsAirHover","signal",1,1,"HELI_VSAIR_START",SIGNALFILTER_SENDER);
			end
			entity:SelectPipe(0,"VtolVsAirHover");

		else
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_HELI_ATTACK", entity.id);
		end

	end,

	HELI_VSAIR_LINESHOOT = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			local idealLevel = self:HELI_VSAIR_GET_FLIGHTHEIGHT( entity );


			local vWng = {};
			local vCheckPos = {};
			local vCheckPos2 = {};

			AIBehaviour.HELIDEFAULT:GetIdealWng( entity, vWng, 25.0 );

			SubVectors( vCheckPos, target:GetPos(), entity:GetPos() );
			NormalizeVector( vCheckPos );
			FastScaleVector( vCheckPos, vCheckPos, 30.0 );
			FastSumVectors( vCheckPos, vCheckPos, entity:GetPos() );
			vCheckPos.z = idealLevel;

			FastSumVectors( vCheckPos2, vCheckPos, vWng );
			vCheckPos2.z = idealLevel;

			local index = 1;
			AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, entity:GetPos(), index );
			index = index + 1;
			AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vCheckPos, index );
			index = index + 1;
			AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vCheckPos2, index );

			if ( AIBehaviour.HELIDEFAULT:heliCommitPathLine( entity, index, false ) == false ) then
				entity:SelectPipe(0,"heliVsAirDefault");
				return;
			end

			AI.SetRefPointPosition( entity.id , target:GetPos() ); -- look target

			entity.AI.autoFire = 0;
			AI.CreateGoalPipe("heliLineShoot");
			AI.PushGoal("heliLineShoot","firecmd",0,0);
			AI.PushGoal("heliLineShoot","locate",0,"refpoint");
			AI.PushGoal("heliLineShoot","lookat",0,0,0,true,1);
			AI.PushGoal("heliLineShoot","run",0,2);
			AI.PushGoal("heliLineShoot","continuous",0,1);
			AI.PushGoal("heliLineShoot","followpath", 0, false, false, false, 0, 10, true );
			AI.PushGoal("heliLineShoot","signal",1,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
			AI.PushGoal("heliLineShoot","signal",1,1,"HELI_AUTOFIRE_CHECK",SIGNALFILTER_SENDER);
			AI.PushGoal("heliLineShoot","locate",0,"atttarget");
			AI.PushGoal("heliLineShoot","lookat",0,0,0,true,1);
			AI.PushGoal("heliLineShoot","timeout",1,0.2);
			AI.PushGoal("heliLineShoot","branch",1,-5);
			AI.PushGoal("heliLineShoot","firecmd",0,0);
			AI.PushGoal("heliLineShoot","signal",0,1,"HELI_VSAIR_START",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"heliLineShoot");

		else
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_HELI_ATTACK", entity.id);
		end

	end,

	HELI_VSAIR_STRAFE = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			local idealLevel = self:HELI_VSAIR_GET_FLIGHTHEIGHT( entity );


			local vWng = {};
			local vCheckPos = {};
			local vCheckPos2 = {};

			AIBehaviour.HELIDEFAULT:GetIdealWng( entity, vWng, 25.0 );

			SubVectors( vCheckPos, target:GetPos(), entity:GetPos() );
			vCheckPos.z = 0;
			NormalizeVector( vCheckPos );
			FastScaleVector( vCheckPos2, vCheckPos, 150.0 );
			FastSumVectors( vCheckPos2, vCheckPos2, target:GetPos() );
			vCheckPos2.z = vCheckPos2.z + 60.0;

			FastScaleVector( vCheckPos, vCheckPos, 30.0 );
			FastSumVectors( vCheckPos, vCheckPos, entity:GetPos() );
			vCheckPos.z = idealLevel + 60.0;

			local index = 1;
			AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, entity:GetPos(), index );
			index = index + 1;
			AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vCheckPos2, index );
--			index = index + 1;
--			AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vCheckPos2, index );

			if ( AIBehaviour.HELIDEFAULT:heliCommitPathLine( entity, index, false ) == false ) then
				entity:SelectPipe(0,"heliVsAirDefault");
				return;
			end

			AI.SetRefPointPosition( entity.id , target:GetPos() ); -- look target

			entity.AI.autoFire = 0;
			AI.CreateGoalPipe("helistrafe");
			AI.PushGoal("helistrafe","firecmd",0,0);
			AI.PushGoal("helistrafe","run",0,2);
			AI.PushGoal("helistrafe","continuous",0,1);
			AI.PushGoal("helistrafe","followpath", 0, false, false, false, 0, 10, true );
			AI.PushGoal("helistrafe","signal",1,1,"HELI_AUTOFIRE_CHECK",SIGNALFILTER_SENDER);
			AI.PushGoal("helistrafe","timeout",1,0.2);
			AI.PushGoal("helistrafe","branch",1,-2);
			AI.PushGoal("helistrafe","firecmd",0,0);
			AI.PushGoal("helistrafe","signal",0,1,"HELI_VSAIR_START",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"helistrafe");

		else
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_HELI_ATTACK", entity.id);
		end

	end,

						
	--------------------------------------------------------------------------
	HELI_VSAIR = function( self, entity )

		local vMyPos = {};
		CopyVector( vMyPos, entity:GetPos() );

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			-- get a battle point. he will stay within 200m from this point.

			if ( entity.AI.bAirBattlePoint == false ) then
				entity.AI.bAirBattlePoint = true;
				FastSumVectors( entity.AI.vAirBattlePoint, entity:GetPos(), target:GetPos() );
				FastScaleVector( entity.AI.vAirBattlePoint, entity.AI.vAirBattlePoint, 0.5 );
			end

			-- check if the target is heli or vtol

			entity:SelectPipe(0,"do_nothing");

			local bHeli = false;
			if ( target.actor ) then
				local vehicleId = target.actor:GetLinkedVehicleId();
				if ( vehicleId ) then
					local	vehicle = System.GetEntity( vehicleId );
					if( vehicle ) then
						if ( AI.GetTypeOf( vehicleId ) == AIOBJECT_VEHICLE and AI.GetSubTypeOf( vehicleId ) == AIOBJECT_HELICOPTER ) then
							bHeli = true;
						end
					end
				end
			end

			if ( AI.GetTypeOf( target.id ) == AIOBJECT_VEHICLE and AI.GetSubTypeOf( target.id ) == AIOBJECT_HELICOPTER ) then
				bHeli = true;
			end

			if ( bHeli == false ) then
				AI.Signal(SIGNALFILTER_SENDER, 1, "TO_HELI_ATTACK", entity.id);
				return;
			end

			-- stay in the air/ each other

			local idealLevel = self:HELI_VSAIR_GET_FLIGHTHEIGHT( entity );

			local vNextPoint = {};
			local vUp = { x = 0.0, y = 0.0, z = 1.0 };
			local vFwd = { x = 20.0, y = 0.0, z = 0.0 };
			RotateVectorAroundR( vNextPoint, vFwd, vUp, 3.1416* 2.0 * random( 1, 360 ) / 360.0 );
			FastSumVectors( vNextPoint, vNextPoint, entity.AI.vAirBattlePoint );
			vNextPoint.z = idealLevel;
			

			local index = 1;
			AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, entity:GetPos(), index );

			index = index + 1;
			AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vNextPoint, index );

			if ( AIBehaviour.HELIDEFAULT:heliCommitPathLine( entity, index, false ) == false ) then
				entity:SelectPipe(0,"heliVsAirDefault");
				return;
			end

			entity.AI.autoFire = 0;

			AI.CreateGoalPipe("heliVsAirHover");
			AI.PushGoal("heliVsAirHover","continuous",0,0);
			AI.PushGoal("heliVsAirHover","locate",0,"atttarget");
			AI.PushGoal("heliVsAirHover","lookat",0,0,0,true,1);
			AI.PushGoal("heliVsAirHover","firecmd",0,0);
			AI.PushGoal("heliVsAirHover","timeout",1,0.5);
			AI.PushGoal("heliVsAirHover","run",0,0);	
			AI.PushGoal("heliVsAirHover","followpath", 0, false, false, false, 0, 10, true );
			AI.PushGoal("heliVsAirHover","signal",1,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
			AI.PushGoal("heliVsAirHover","signal",1,1,"HELI_AUTOFIRE_CHECK",SIGNALFILTER_SENDER);
			AI.PushGoal("heliVsAirHover","lookat",0,-500,0);
			AI.PushGoal("heliVsAirHover","locate",0,"atttarget");
			AI.PushGoal("heliVsAirHover","lookat",0,0,0,true,1);
			AI.PushGoal("heliVsAirHover","timeout",1,0.2);
			AI.PushGoal("heliVsAirHover","branch",1,-6);
			AI.PushGoal("heliVsAirHover","signal",1,1,"HELI_HOVER_ENABLE_REACTION",SIGNALFILTER_SENDER);
			AI.PushGoal("heliVsAirHover","signal",1,1,"HELI_VSAIR_START",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"heliVsAirHover");

		else
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_HELI_ATTACK", entity.id);
		end

	end,


}

