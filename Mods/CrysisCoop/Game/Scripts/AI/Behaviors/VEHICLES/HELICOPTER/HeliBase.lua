--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2005.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Helocipter Behaviour SCRIPT common signal handlers
--  
--------------------------------------------------------------------------
--  History:
--  - 22/06/2006   : Created by Tetsuji
--
--------------------------------------------------------------------------

local Xaxis =0;
local Yaxis =1;
local Zaxis =2;

AIBehaviour.HeliBase = {

	Name = "HeliBase",

	------------------------------------------------------------------------------------------
	-- detect a confliction

	HELI_AUTOFIRE_CHECK_NOTARGET = function( self, entity )

		if ( entity.AI.autoFire == 0 ) then
			local vFwd = {};
			SubVectors( vFwd, entity.AI.autoFireTargetPos, entity:GetPos() );
			NormalizeVector( vFwd );
			if ( dotproduct3d( vFwd, entity:GetDirectionVector(Yaxis) ) > math.cos( 90.0 * 3.1415 / 180.0 ) ) then
				AI.SetRefPointPosition( entity.id, entity.AI.autoFireTargetPos );
				entity.AI.autoFire = entity.AI.autoFire + 1;
				AI.CreateGoalPipe("heliShootMissileA");
				AI.PushGoal("heliShootMissileA","locate",0,"refpoint");
				AI.PushGoal("heliShootMissileA","acqtarget",0,"");
				AI.PushGoal("heliShootMissileA","firecmd",0,FIREMODE_CONTINUOUS);
				entity:InsertSubpipe(0,"heliShootMissileA");
			end
		end

		if ( entity.AI.autoFire > 0 ) then
			if ( entity.AI.autoFire == 5 ) then
				AI.CreateGoalPipe("heliStopMissileA");
				AI.PushGoal("heliStopMissileA","firecmd",0,0);
				entity:InsertSubpipe(0,"heliStopMissileA");
			end
			entity.AI.autoFire = entity.AI.autoFire +1;
		end

	end,

	HELI_AUTOFIRE_CHECK = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then -- we need target
		
			if ( entity.AI.autoFire == 0 ) then
				local vFwd = {};
				SubVectors( vFwd, target:GetPos(), entity:GetPos() );
				NormalizeVector( vFwd );
				if ( dotproduct3d( vFwd, entity:GetDirectionVector(Yaxis) ) > math.cos( 90.0 * 3.1415 / 180.0 ) ) then
					if ( AIBehaviour.HELIDEFAULT:heliDoesUseMachineGun( entity ) == false ) then
						AI.SetRefPointPosition( entity.id, entity.AI.autoFireTargetPos );
						entity.AI.autoFire = entity.AI.autoFire + 1;
						AI.CreateGoalPipe("heliShootMissileB");
						AI.PushGoal("heliShootMissileB","firecmd",0,FIREMODE_CONTINUOUS);
						entity:InsertSubpipe(0,"heliShootMissileB");
					end
				end
			end

			if ( entity.AI.autoFire > 0 ) then
				if ( entity.AI.autoFire == 10 ) then
					AI.CreateGoalPipe("heliStopMissileB");
					AI.PushGoal("heliStopMissileB","firecmd",0,0);
					entity:InsertSubpipe(0,"heliStopMissileB");
				end
				entity.AI.autoFire = entity.AI.autoFire +1;
			end			

		end
	
	end,

	HELI_AUTOFIRE_CHECK_AGGRASSIVE = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then -- we need target
		
			if ( entity.AI.autoFire == 0 ) then
				local vFwd = {};
				SubVectors( vFwd, target:GetPos(), entity:GetPos() );
				NormalizeVector( vFwd );
				if ( dotproduct3d( vFwd, entity:GetDirectionVector(Yaxis) ) > math.cos( 30.0 * 3.1415 / 180.0 ) ) then

					entity.AI.autoFire = entity.AI.autoFire + 1;
					AI.CreateGoalPipe("heliShootMissileB");
					AI.PushGoal("heliShootMissileB","firecmd",0,FIREMODE_CONTINUOUS);
					entity:InsertSubpipe(0,"heliShootMissileB");

				end

			end

			if ( entity.AI.autoFire > 0 ) then
				if ( entity.AI.autoFire == 10 ) then
					AI.CreateGoalPipe("heliStopMissileB");
					AI.PushGoal("heliStopMissileB","firecmd",0,0);
					entity:InsertSubpipe(0,"heliStopMissileB");
				end
				entity.AI.autoFire = entity.AI.autoFire +1;
			end			

		end
	
	end,

	------------------------------------------------------------------------------------------
	-- detect a confliction

	HELI_HOVER_CHECK = function( self, entity )
	
		self:HELI_HOVER_CHECK2( entity );
		
		if ( AIBehaviour.HELIDEFAULT:heliCheckIsTargetPlayerVehicle( entity ) == true ) then
			local target = AI.GetAttentionTargetEntity( entity.id );
			if ( target and AI.Hostile( entity.id, target.id ) ) then
				local d = DistanceLineAndPoint( entity:GetPos(), System.GetViewCameraDir(), target:GetPos() );
				if ( d < 15.0 ) then
					AI.Signal(SIGNALFILTER_SENDER,1,"HELI_TAKE_EVADEACTION", entity.id);
				end
			end
		end

	end,

	HELI_HOVER_CHECK2 = function( self, entity )

		local vMyPos = {};
		CopyVector( vMyPos, entity:GetPos() );
		vMyPos.z = vMyPos.z + 10.0;

		--System.DrawLabel( vMyPos, 12, "ID:"..entity.AI.stayPosition, 1, 1, 1, 1);

		local vSumOfPotential ={};
		CopyVector( vSumOfPotential, AI.GetFlyingVehicleFlockingPos( entity.id,30.0,200.0,3.0,0.0) );

		if ( LengthVector(vSumOfPotential) > 0.0 ) then

			entity.AI.bBlockSignal = true;


			FastSumVectors( vSumOfPotential, vSumOfPotential, entity:GetPos() );

			FastSumVectors( vMyPos, vMyPos, vSumOfPotential );
			FastScaleVector( vMyPos, vMyPos, 0.5 );

			AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vMyPos, 1 );
			AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vSumOfPotential, 2 );

			if ( AIBehaviour.HELIDEFAULT:heliCommitPathLine( entity, 2, false ) == false ) then
				AI.Signal(SIGNALFILTER_SENDER,1,entity.AI.heliDefaultSignal, entity.id);
				return;
			end

			AI.CreateGoalPipe("heliAvoidConfliction");
			AI.PushGoal("heliAvoidConfliction","firecmd",0,0);
			AI.PushGoal("heliAvoidConfliction","followpath", 1, false, false, false, 0, 40, true );
			entity:InsertSubpipe(0,"heliAvoidConfliction");

		end

		local bMemoryIncrement = false;


		if ( entity.AI.memoryCount ~=nil ) then
			local targetEntity = AI.GetAttentionTargetEntity( entity.id );
			if ( targetEntity and AI.Hostile( entity.id, targetEntity.id ) ) then
				local targetType = AI.GetTargetType( entity.id );
				if( targetType == AITARGET_MEMORY ) then
					bMemoryIncrement = true;
				end
			end
		end
		
		if ( bMemoryIncrement == true ) then
			entity.AI.memoryCount = entity.AI.memoryCount + 1;
		else
			entity.AI.memoryCount =0;
		end

	end,
	
		
	------------------------------------------------------------------------------------------
	-- change behavior is the target is memory

	HELI_HOVER_DISABLE_REACTION = function( self, entity )

		entity.AI.bBlockSignal = true;

	end,
	
	HELI_HOVER_ENABLE_REACTION = function( self, entity )

		entity.AI.bBlockSignal = false;

	end,

	--------------------------------------------------------------------------
	HELI_HOVER_START_AIMING = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			if ( entity.AI.isHeliAggressive == nil ) then
				if ( AIBehaviour.HELIDEFAULT:heliDoesUseMachineGun( entity ) == true ) then
					if ( random(1,5) > 1 ) then
						return;
					end
				end
			end

			local myPos = {};
			local vMid = {};
			CopyVector( myPos, entity:GetPos() );
			AIBehaviour.HELIDEFAULT:GetAimingPosition( entity, myPos )

			if ( DistanceVectors( entity:GetPos(), myPos) > 3.0 ) then
			
				FastSumVectors( vMid, entity:GetPos(), myPos );
				FastScaleVector( vMid, vMid, 0.5 );
			
				AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vMid, 1 );
				AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, myPos, 2 );

				if ( AIBehaviour.HELIDEFAULT:heliCheckSpaceVoidMain( entity, 2, 15.0 ) == false ) then
					return;
				end

				AIBehaviour.HELIDEFAULT:heliCommitPathLineNoCheck( entity, 2, false );

				AI.CreateGoalPipe("heliAdjustShootPoint");
				AI.PushGoal("heliAdjustShootPoint","run",0,0);		
				AI.PushGoal("heliAdjustShootPoint","continuous",0,0);		
				AI.PushGoal("heliAdjustShootPoint","locate",0,"atttarget");
				AI.PushGoal("heliAdjustShootPoint","lookat",0,0,0,true,1);
				AI.PushGoal("heliAdjustShootPoint","timeout",1,0.5);
				AI.PushGoal("heliAdjustShootPoint","locate",0,"refpoint");		
				AI.PushGoal("heliAdjustShootPoint","followpath", 1, false, false, false, 0, 20.0, true );
				AI.PushGoal("heliAdjustShootPoint","signal",1,1,"HELI_HOVER_START_AIMING_NEXT",SIGNALFILTER_SENDER);
				entity:InsertSubpipe(0,"heliAdjustShootPoint");

			else
				self:HELI_HOVER_START_AIMING_NEXT( entity );
			end

		else
			AI.Signal(SIGNALFILTER_SENDER,1,entity.AI.heliDefaultSignal, entity.id);
		end

	end,

	HELI_HOVER_START_AIMING_NEXT = function( self, entity )

		if ( entity.AI.DoMemoryAttack ~= true ) then

			AI.CreateGoalPipe("heliAiming");
			AI.PushGoal("heliAiming","locate",0,"atttarget");
			AI.PushGoal("heliAiming","lookat",0,0,0,true,1);
			AI.PushGoal("heliAiming","timeout",1,0.5);
			AI.PushGoal("heliAiming","signal",1,1,"HELI_HOVER_START_AIMING_NEXT2",SIGNALFILTER_SENDER);
			entity:InsertSubpipe(0,"heliAiming");

		else
			self:HELI_HOVER_START_AIMING_NEXT2( entity );
		end

	end,

	HELI_HOVER_START_AIMING_NEXT2 = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			local myPos ={};
			local enemyPos ={};
			local vPos = {};
			local vTmp = {};		
			CopyVector( myPos, entity:GetPos() );
			AIBehaviour.HELIDEFAULT:heliGetTargetPosition( entity, enemyPos );
			if ( entity.AI.isVtol == true ) then
				FastScaleVector( vPos, entity:GetDirectionVector(Yaxis), 25.0  );
				FastScaleVector( vTmp, entity:GetDirectionVector(Zaxis), -6.0 );
				FastSumVectors( vPos, vPos, myPos );
				FastSumVectors( vPos, vPos, vTmp );
			else
				FastScaleVector( vPos, entity:GetDirectionVector(Yaxis), 20.0  );
				FastScaleVector( vTmp, entity:GetDirectionVector(Zaxis), 0.0 );
				FastSumVectors( vPos, vPos, myPos );
				FastSumVectors( vPos, vPos, vTmp );
			end

			FastSumVectors( vTmp, entity:GetPos() ,vPos );
			FastScaleVector( vTmp, vTmp, 0.5 );
			AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vTmp, 1 );
			AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vPos, 2 );

			if ( AIBehaviour.HELIDEFAULT:heliCommitPathLine( entity, 2, false ) == false ) then
				return;
			end

			if ( entity.AI.DoMemoryAttack == true ) then
				AI.CreateGoalPipe("heliShootMissile2");
				AI.PushGoal("heliShootMissile2","run",0,0);		
				AI.PushGoal("heliShootMissile2","continuous",0,1);		
				AI.PushGoal("heliShootMissile2","locate",0,"refpoint");		
				AI.PushGoal("heliShootMissile2","approach",0,0.01,AILASTOPRES_USE,-1);

				AI.PushGoal("heliShootMissile2","firecmd",0,FIREMODE_CONTINUOUS);
				AI.PushGoal("heliShootMissile2","signal",0,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
				AI.PushGoal("heliShootMissile2","timeout",1,0.5);
				AI.PushGoal("heliShootMissile2","firecmd",0,0);
				AI.PushGoal("heliShootMissile2","timeout",1,0.1);

				AI.PushGoal("heliShootMissile2","firecmd",0,FIREMODE_CONTINUOUS);
				AI.PushGoal("heliShootMissile2","signal",0,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
				AI.PushGoal("heliShootMissile2","timeout",1,0.5);
				AI.PushGoal("heliShootMissile2","firecmd",0,0);
				AI.PushGoal("heliShootMissile2","timeout",1,0.1);

				entity:InsertSubpipe(0,"heliShootMissile2");
				entity.AI.DoMemoryAttack = false;		
			else
				if ( entity.AI.isVtol == true ) then
					AI.CreateGoalPipe("vtolShootMissile");
					AI.PushGoal("vtolShootMissile","run",0,1);		
					AI.PushGoal("vtolShootMissile","continuous",0,1);	
					AI.PushGoal("vtolShootMissile","locate",0,"atttarget");
					AI.PushGoal("vtolShootMissile","lookat",0,0,0,true,1);
					AI.PushGoal("vtolShootMissile","locate",0,"refpoint");		
					AI.PushGoal("vtolShootMissile","approach",0,0.01,AILASTOPRES_USE,-1);
					AI.PushGoal("vtolShootMissile","firecmd",0,FIREMODE_CONTINUOUS);
					AI.PushGoal("vtolShootMissile","timeout",1,2.5);		
					AI.PushGoal("vtolShootMissile","firecmd",0,0);
					AI.PushGoal("vtolShootMissile","firecmd",0,0);
					AI.PushGoal("vtolShootMissile","signal",1,1,"HELI_HOVER_AIMING_END",SIGNALFILTER_SENDER);
					entity:InsertSubpipe(0,"vtolShootMissile");
				else
					AI.CreateGoalPipe("heliShootMissile");
					AI.PushGoal("heliShootMissile","run",0,2);		
					AI.PushGoal("heliShootMissile","continuous",0,1);		
					AI.PushGoal("heliShootMissile","locate",0,"atttarget");
					AI.PushGoal("heliShootMissile","lookat",0,0,0,true,1);
					AI.PushGoal("heliShootMissile","locate",0,"refpoint");
					AI.PushGoal("heliShootMissile","firecmd",0,FIREMODE_CONTINUOUS);
					AI.PushGoal("heliShootMissile","followpath", 0, false, false, false, 0, 10.0, true );
					AI.PushGoal("heliShootMissile","signal",1,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
					AI.PushGoal("heliShootMissile","timeout",1,0.2);
					AI.PushGoal("heliShootMissile","branch",1,-2);
					AI.PushGoal("heliShootMissile","firecmd",0,0);
					AI.PushGoal("heliShootMissile","signal",1,1,"HELI_HOVER_AIMING_END",SIGNALFILTER_SENDER);
					entity:InsertSubpipe(0,"heliShootMissile");
				end
			end

		else
			AI.Signal(SIGNALFILTER_SENDER,1,entity.AI.heliDefaultSignal, entity.id);
		end

	end,

	HELI_HOVER_AIMING_END = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			local pat = random(1,3);

			local vWng = {};
			local vFwd = {};
			local vPos = {};
			local vTmp = {};
			AIBehaviour.HELIDEFAULT:GetIdealWng2( entity, vWng, 25.0 ,target:GetPos() )

			SubVectors( vFwd, target:GetPos(), entity:GetPos() );
			vFwd.z = 0;
			NormalizeVector( vFwd );
			FastScaleVector( vFwd, vFwd, 15.0 );

			FastSumVectors( vPos, vWng, vFwd );
			FastSumVectors( vPos, vPos, vWng );
			FastSumVectors( vPos, vPos, vWng );
			FastSumVectors( vPos, vPos, entity:GetPos() );

			FastSumVectors( vTmp, entity:GetPos(), vPos );
			FastScaleVector( vTmp, vTmp, 0.5 );

			AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vTmp, 1 );
			AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vPos, 2 );

			if ( AIBehaviour.HELIDEFAULT:heliCommitPathLine( entity, 2, false ) == false ) then
				return;
			end

			AI.SetRefPointPosition( entity.id , target:GetPos() ); -- look target
			entity.AI.autoFire = 0;

			AI.CreateGoalPipe("HeliAimingEnd");
			AI.PushGoal("HeliAimingEnd","firecmd",0,0);
			if ( entity.AI.stayPosition == 1 or entity.AI.stayPosition == 2 ) then
				AI.PushGoal("HeliAimingEnd","locate",0,"refpoint");
				AI.PushGoal("HeliAimingEnd","lookat",0,-500,0);
			else
				AI.PushGoal("HeliAimingEnd","locate",0,"refpoint");
				AI.PushGoal("HeliAimingEnd","lookat",0,0,0,true,1);
			end
			AI.PushGoal("HeliAimingEnd","run",0,1);
			AI.PushGoal("HeliAimingEnd","continuous",0,1);
			AI.PushGoal("HeliAimingEnd","followpath", 0, false, false, false, 0, 10, true );
			AI.PushGoal("HeliAimingEnd","signal",1,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
			AI.PushGoal("HeliAimingEnd","timeout",1,0.2);
			AI.PushGoal("HeliAimingEnd","branch",1,-2);
			AI.PushGoal("HeliAimingEnd","firecmd",0,0);
			entity:InsertSubpipe(0,"HeliAimingEnd");
			return;	

		end

	end,

	HELI_GOT_BIGDAMAGE_SUB = function( self, entity )

		entity.AI.bBlockSignal = true;

		local updownScale = -1.0;
		if ( entity.AI.bShaken == true ) then
			entity.AI.bShaken = false;
			updownScale =1.0;
		else
			entity.AI.bShaken = true;
			updownScale =-0.5;
		end

		local vel = {};
		local vPos = {};

		local index = 1;
		FastScaleVector( vPos, entity:GetDirectionVector(2), 1.0 * updownScale )
		FastSumVectors( vPos, vPos, entity:GetPos() );
		AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vPos, index );

		index = index + 1;
		FastScaleVector( vPos, entity:GetDirectionVector(2), 4.0 * updownScale )
		vPos.x = vPos.x + random(-1,1) * 2;
		vPos.y = vPos.y + random(-1,1) * 2;
		FastSumVectors( vPos, vPos, entity:GetPos() );
		AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vPos, index );

		if ( AIBehaviour.HELIDEFAULT:heliCommitPathLine( entity, index, false ) == false ) then
			return;
		end

		AI.CreateGoalPipe("HeliGotBigDamageSub");
		AI.PushGoal("HeliGotBigDamageSub","firecmd",0,0);
		AI.PushGoal("HeliGotBigDamageSub","run",0,0);
		AI.PushGoal("HeliGotBigDamageSub","continuous",0,1);
		AI.PushGoal("HeliGotBigDamageSub","followpath", 1, false, false, false, 0, -1, true );
		entity:InsertSubpipe(0,"HeliGotBigDamageSub");

	end,
	
}