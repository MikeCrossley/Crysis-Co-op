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
--  - 15/03/2006   : Created by Tetsuji
--
--------------------------------------------------------------------------
local Xaxis =0;
local Yaxis =1;
local Zaxis =2;
local minUpdateTime = 0.33;
local minLift = 1.2;

local		fHELI_HOVERATTACK2_DONOTHING			= 0;
local 	fHELI_HOVERATTACK2_GETDAMAGESMALL = 1;
local 	fHELI_HOVERATTACK2								= 2;
local 	fHELI_HOVERATTACK2_STRAFING				= 3;
local 	fHELI_HOVERATTACK2_STRAFING2			= 4;
local 	fHELI_HOVERATTACK2_STRAFING3			= 5;
local 	fHELI_HOVERATTACK2_STRAFING4			= 6;
local 	fHELI_HOVERATTACK2_STRAFING5			= 7;
local 	fHELI_HOVERATTACK2_DASH						= 8;
local 	fHELI_HOVERATTACK2_MAKECURVE			= 9;
local 	fHELI_HOVERATTACK2_WAITLOOK				= 10;
local 	fHELI_HOVERATTACK2_NORMALDAMAGE		= 11;
local 	fHELI_HOVERATTACK2_NORMALDAMAGE2	= 12;
local 	fHELI_HOVERATTACK2_EVADELAW				= 13;
local 	fHELI_HOVERATTACK2_PATHATTACK			= 14;
local 	fHELI_HOVERATTACK2_GOAWAY					= 15;
local 	fHELI_HOVERATTACK2_SHOOTMISSILE		= 16;
local 	fHELI_HOVERATTACK2_SHOOTMISSILE2	= 17;
local 	fHELI_HOVERATTACK2_EMERGENCYSTOP	= 18;
local 	fHELI_HOVERATTACK2_ADVANCE				= 19;
local   fHELI_HOVERATTACK2_QUICKRETREAT		= 20;
local   fHELI_HOVERATTACK2_VSCLOAK				= 21;

AIBehaviour.HeliHoverAttack2 = {
	Name = "HeliHoverAttack2",
	Base = "HeliBase",

	alertness = 2,

	--------------------------------------------------------------------------
	Constructor = function ( self, entity, data )

		-- for signals
		-- System.Log("HeliHoverAttack2 REQUEST DISABLE= 0 ");
		AI.AutoDisable( entity.id, 0 );

		entity.AI.bBlockSignal = false;

		-- for common signal handlers.
		local ratio = entity.vehicle:GetComponentDamageRatio("Hull");
		if ( ratio == nil ) then
			ratio = entity.vehicle:GetComponentDamageRatio("hull");
		end
		if ( ratio == nil ) then
			entity.AI.lastDamage = 0;
		else
			entity.AI.lastDamage = ratio;
		end
		entity.AI.damageCount = 0;

		entity.AI.heliTimer = Script.SetTimerForFunction( minUpdateTime *1000, "AIBehaviour.HeliHoverAttack2.HELI_HOVERATTACK2_UPDATE", entity );

		entity.AI.circleSec = System.GetCurrTime();
		entity.AI.deltaT = System.GetCurrTime();
		entity.AI.deltaTSystem = System.GetCurrTime();
		entity.AI.memorySec = System.GetCurrTime();

		entity.AI.vMyPosRsv = {};
		entity.AI.vTargetRsv = {};
		entity.AI.vDirectionRsv = {};
		entity.AI.vIdealVel = {};

		entity.AI.CurrentHook = 0;
		entity.AI.InterruptHook = 0;
		entity.AI.InterruptSec = System.GetCurrTime();
		entity.AI.vInterruptMyPosRsv = {};
		entity.AI.vInterruptTargetRsv = {};
		entity.AI.vInterruptDirectionRsv = {};

		entity.AI.vRefRsv = {};
		entity.AI.lookatPattern = 0;
		entity.AI.bRotDirec = false;
		entity.AI.resetLookAt = false;

		entity.AI.lastShooterId = nil;
		entity.AI.rotateDirection = false;
		
		AI.CreateGoalPipe("heliHoverAttackDefault");
		AI.PushGoal("heliHoverAttackDefault","timeout",1,0.3);
		AI.PushGoal("heliHoverAttackDefault","signal",0,1,"HELI_HOVERATTACK2_ADVANCE_START",SIGNALFILTER_SENDER);
		
		entity:SelectPipe(0,"heliHoverAttackDefault");

		AI.CreateGoalPipe("HeliMain");
		AI.PushGoal("HeliMain","+timeout",1,1);

		AI.CreateGoalPipe("HeliLookat");
		AI.PushGoal("HeliLookat","firecmd",0,0);
		AI.PushGoal("HeliLookat","locate",0,"atttarget");
		AI.PushGoal("HeliLookat","lookat",0,0,0,true,1);
		AI.PushGoal("HeliLookat","+timeout",1,0.1);
		AI.PushGoal("HeliLookat","signal",1,1,"HELI_HOVERATTACK2_SETLOOKATATT",SIGNALFILTER_SENDER);

		AI.CreateGoalPipe("HeliLookatRef");
		AI.PushGoal("HeliLookatRef","firecmd",0,0);
		AI.PushGoal("HeliLookatRef","locate",0,"refpoint");
		AI.PushGoal("HeliLookatRef","lookat",0,0,0,true,1);
		AI.PushGoal("HeliLookatRef","+timeout",1,0.1);
		AI.PushGoal("HeliLookatRef","signal",1,1,"HELI_HOVERATTACK2_SETLOOKATREF",SIGNALFILTER_SENDER);

		AI.CreateGoalPipe("HeliResetLookat2");
		AI.PushGoal("HeliResetLookat2","firecmd",0,0);
		AI.PushGoal("HeliResetLookat2","locate",0,"");
		AI.PushGoal("HeliResetLookat2","lookat",0,-500,0);
		AI.PushGoal("HeliResetLookat2","signal",1,1,"HELI_HOVERATTACK2_REFSETLOOKAT",SIGNALFILTER_SENDER);

		AI.CreateGoalPipe("HeliLookatRef2");
		AI.PushGoal("HeliLookatRef2","locate",0,"refpoint");
		AI.PushGoal("HeliLookatRef2","lookat",0,0,0,true,1);

		AI.CreateGoalPipe("HeliFireStart");
		AI.PushGoal("HeliFireStart","firecmd",0,FIREMODE_CONTINUOUS);

		AI.CreateGoalPipe("HeliFireStartRef");
		AI.PushGoal("HeliFireStartRef","locate", 0, "refpoint");
		AI.PushGoal("HeliFireStartRef","firecmd",0,FIREMODE_CONTINUOUS,AILASTOPRES_USE);

		AI.CreateGoalPipe("HeliFireStop");
		AI.PushGoal("HeliFireStop","firecmd",0,0);

	end,
	
	---------------------------------------------
	Destructor = function ( self, entity, data )

		-- called when the behaviour is de-selected
		-- the extra data is from the signal that is causing the behavior transition

		local vVel = {};

		entity:GetVelocity( vVel );
		vVel.z = 0;
		NormalizeVector( vVel );
		FastScaleVector( vVel, vVel, -1.0 );
		
		local speed = entity:GetSpeed();
		entity:AddImpulse( -1, entity:GetCenterOfMassPos(), vVel, entity:GetMass()*speed*0.5, 1 );	

		AI.SetForcedNavigation( entity.id, entity.AI.vZero );
		if ( entity.AI.heliTimer ~= nil ) then
			Script.KillTimer(entity.AI.heliTimer);
			entity.AI.heliTimer = nil;
		end

	end,

	TO_HELI_EMERGENCYLANDING = function( self, entity, sender, data )
	end,
	HELI_HOVERATTACK2_SETLOOKATATT = function ( self, entity )
		entity.AI.lookatPattern = 1;
	end,
	HELI_HOVERATTACK2_SETLOOKATREF = function ( self, entity )
		entity.AI.lookatPattern = 2;
		CopyVector( entity.AI.vRefRsv, AI.GetRefPointPosition(entity.id) );
	end,
	HELI_HOVERATTACK2_REFSETLOOKAT = function ( self, entity )
		entity.AI.lookatPattern = 0;
	end,

	HELI_HOVERATTACK2_RECOVERLOOKAT = function ( self, entity )
		entity.AI.memorySec = System.GetCurrTime();
		entity.AI.bBlockSignal = false;
		entity.AI.resetLookAt = true;
	end,

	HELI_HOVERATTACK2_RECOVERLOOKAT_MAIN = function ( self, entity )

		if ( entity.AI.lookatPattern == 1 ) then
			entity:SelectPipe( 0, "do_nothing");
			entity:SelectPipe( 0, "HeliMain");
			entity:InsertSubpipe( 0, "HeliLookat" );
		end
		if ( entity.AI.lookatPattern == 2 ) then
			AI.SetRefPointPosition( entity.id, entity.AI.vRefRsv );
			entity:SelectPipe( 0, "do_nothing");
			entity:SelectPipe( 0, "HeliMain");
			entity:InsertSubpipe( 0, "HeliLookatRef" );
		end
		if ( entity.AI.lookatPattern == 0 ) then
			entity:SelectPipe( 0, "do_nothing");
			entity:SelectPipe( 0, "HeliMain");
			entity:InsertSubpipe( 0, "HeliResetLookat2" );
		end

	end,

	HELI_HOVERATTACK2_CHECKTARGET = function ( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then
			if ( AI.GetTypeOf( target.id ) == AIOBJECT_VEHICLE ) then
				if ( target.AIMovementAbility.pathType == AIPATH_TANK or target.AIMovementAbility.pathType == AIPATH_BOAT ) then
					AI.SetExtraPriority( target.id , 100.0 );
					AI.Signal(SIGNALFILTER_SENDER, 1, "TO_HELI_ATTACK", entity.id);
					return 1;
				end
			end
		end
		
		return 0;

	end,

	---------------------------------------------
	OnPathFound = function( self, entity, sender )
		-- called when the AI has requested a path and it's been computed succesfully
	end,	
	--------------------------------------------------------------------------
	OnNoTarget = function( self, entity )
		-- called when the AI stops having an attention target
		AIBehaviour.HELIDEFAULT:heliRequest2ndGunnerStopShoot( entity );
		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_HELI_ATTACK", entity.id);
	end,
	---------------------------------------------
	OnSomethingSeen = function( self, entity )
		-- called when the enemy sees a foe which is not a living player
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		-- called when the AI sees a living enemy
		if ( entity.AI.bBlockSignal == false ) then
			entity.AI.resetLookAt = true;
		end
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
		if ( entity.AI.bBlockSignal == true ) then
			return;
		end

		entity.AI.damageCount = entity.AI.damageCount +1;
		local ratio = entity.vehicle:GetComponentDamageRatio("Hull");
		if ( ratio == nil ) then
			ratio = entity.vehicle:GetComponentDamageRatio("hull");
		end
		if ( ratio == nil ) then
			return;
		end

		if ( ratio - entity.AI.lastDamage > 0.1 or entity.AI.damageCount > 40 ) then
			if ( entity.AI.bBlockSignal == false ) then

				entity.AI.lastDamage = ratio;
				entity.AI.damageCount =0;

				local target = AI.GetAttentionTargetEntity( entity.id );
				if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then
				
					local vMyPos = {};
					local vTargetPos = {};
					CopyVector( vMyPos , entity:GetPos() );
					CopyVector( vTargetPos , target:GetPos() );
					SubVectors( vTargetPos, vTargetPos, vMyPos );
					vTargetPos.z = 0;
					local len = LengthVector( vTargetPos );
					if ( entity.AI.CurrentHook == fHELI_HOVERATTACK2 ) then
	
						pat = random( 1,256 );
						if ( pat < 128 and len < 45.0 ) then
							AI.Signal(SIGNALFILTER_SENDER,1,"HELI_HOVERATTACK2_MAKECURVE_START", entity.id);
						else
							if ( entity.AI.rotateDirection == true ) then
								entity.AI.rotateDirection = false;
							else
								entity.AI.rotateDirection = true;
							end
							AI.Signal(SIGNALFILTER_SENDER,1,"HELI_HOVERATTACK2", entity.id);
						end
	
					elseif (  entity.AI.CurrentHook == fHELI_HOVERATTACK2_PATHATTACK ) then
	
						if ( len > 100.0 ) then
							AI.Signal(SIGNALFILTER_SENDER,1,"HELI_HOVERATTACK2_ADVANCE_START", entity.id);
						else
							AI.Signal(SIGNALFILTER_SENDER,1,"HELI_HOVERATTACK2_START", entity.id);
						end
	
					end
				end

			end
		end

	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK2_CHECKGOAWAY = function( self, entity, distance )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			local vDist = {};
			SubVectors( vDist, target:GetPos(), entity:GetPos() );
			vDist.z =0;

			local length = LengthVector( vDist );

			if ( length > distance ) then
				AI.Signal(SIGNALFILTER_SENDER, 1, "HELI_HOVERATTACK2_GOAWAY_START", entity.id);
				return true;
			end

		end

		return false;
		
	end,

	---------------------------------------------
	HELI_HOVERATTACK2_GETPARTSDAMAGE = function ( self, entity, sender, data )

		data.id = data.iValue;

		local ratio = entity.vehicle:GetComponentDamageRatio("Hull");
		if ( ratio == nil ) then
			ratio = entity.vehicle:GetComponentDamageRatio("hull");
		end
		if ( ratio == nil ) then
			ratio = 0;
		end

		entity.AI.lastDamage = ratio;
		entity.AI.damageCount =0;
		
		if ( AIBehaviour.HELIDEFAULT:heliCheckDamageRatio( entity ) == true ) then
			return;
		end
		if ( AIBehaviour.HELIDEFAULT:heliCheckDamage( entity, data ) == false ) then
			return;
		end

		entity.AI.lastShooterId = nil;

		local targetEntity;
		if ( data and data.id ) then
			entity.AI.lastShooterId = data.id;
			targetEntity = System.GetEntity( data.id );
			if ( targetEntity ) then
			else
				return;
			end
		else
			local targetEntity = AI.GetAttentionTargetEntity( entity.id );
			if ( targetEntity and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, targetEntity )==true ) then
			else
				return;
			end
		end

		if ( entity.AI.bBlockSignal == false ) then

			if ( self:HELI_HOVERATTACK2_CHECKTARGET( entity )> 0 ) then
				return;
			end

			entity.AI.bBlockSignal = true;
			self:HELI_HOVERATTACK2_GETDAMAGESMALL_START ( entity, targetEntity );
		else


		end

	end,


	------------------------------------------------------------------------------------------
	HELI_TAKE_EVADEACTION = function ( self, entity, sender, data )

		local targetEntity = System.GetEntity( g_localActor.id );

		if ( targetEntity ) then

			if ( entity.AI.bBlockSignal == false ) then

				if ( random( 0, 256 ) < 48 ) then

					AIBehaviour.HELIDEFAULT:heliTakeEvadeAction2( entity, "HELI_HOVERATTACK2_START", targetEntity );
					return;

				end

			end
		
			AIBehaviour.HELIDEFAULT:heliTakeEvadeAction( entity, "HELI_HOVERATTACK2_START", targetEntity );

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

			-- P = U+tV, PV = 0 -> t = - UV/VV;

			local U ={};
			local V ={};
			local W ={};
			local t;

			AI.GetAttentionTargetPosition( entity.id, U );
			AI.GetAttentionTargetDirection( entity.id, V );


			if ( LengthVector( V ) > 0.0 ) then

				SubVectors( W, entity:GetPos(), U );

				local t = dotproduct3d( W , V ) 
				
				FastScaleVector( V, V, t );
				FastSumVectors( V, V, U );

				-- when t<0 there is no possibility the rocket hits the scout.
				if ( t > 0 ) then

					local P ={};
					local P2 ={};

					SubVectors( P, entity:GetPos() , V );
	
					if ( LengthVector( P ) < 10.0 ) then


			U.z = U.z - 16.0;
				SubVectors( W, entity:GetPos(), U );

				local t = dotproduct3d( W , V ) 
				
				FastScaleVector( V, V, t );
				FastSumVectors( V, V, U );
					SubVectors( P, entity:GetPos() , V );

						-- calcurate the point to run away

						NormalizeVector( P );			

						local N = {};
						
						SubVectors( N, U, entity:GetPos() );
						N.z = 0;
						NormalizeVector( N );

						ProjectVector( P2, P, N )

						entity.AI.bBlockSignal = true;
						self:HELI_HOVERATTACK2_EVADELAW_START( entity, P2, P2 );
						return;

					end
				end
			end

		end

		entity:InsertSubpipe( 0, "devalue_target" );

	end,

	--------------------------------------------------------------------------
	-- local signal handers
	--------------------------------------------------------------------------
	HELI_REFLESH_POSITION = function( self, entity, sender, data )

		AIBehaviour.HELIDEFAULT:heliRefreshStayAttackPosition( entity );

		entity.AI.time = System.GetCurrTime();

	end,

	HELI_STAY_ATTACK = function( self, entity )
		
		--AIBehaviour.HELIDEFAULT:heliGetID( entity );
		--AIBehaviour.HELIDEFAULT:heliDoStayAttack( entity );

	end,

	
	--------------------------------------------------------------------------
	HELI_HOVERATTACK2_UPDATE = function( entity )

		if ( entity.AI == nil or entity.AI.heliTimer == nil or entity:GetSpeed() == nil ) then
			local myEntity = System.GetEntity( entity.id );
			if ( myEntity ) then
				local vZero = {x=0.0,y=0.0,z=0.0};
				AI.SetForcedNavigation( entity.id, vZero );
			end
			return;
		end

		if ( entity.id and System.GetEntity( entity.id ) ) then
		else
			local vZero = {x=0.0,y=0.0,z=0.0};
			AI.SetForcedNavigation( entity.id, vZero );
			return;
		end

		if ( entity:IsActive() and AI.IsEnabled(entity.id) ) then
		else
			local vZero = {x=0.0,y=0.0,z=0.0};
			AI.SetForcedNavigation( entity.id, vZero );
			return;
		end

		local dt = System.GetCurrTime() - entity.AI.deltaTSystem;
		entity.AI.deltaTSystem = System.GetCurrTime();
--		System.Log("dt "..dt);
		if ( dt < minUpdateTime*0.25 ) then
			return;
		end

		entity.AI.heliTimer = Script.SetTimerForFunction( minUpdateTime *1000, "AIBehaviour.HeliHoverAttack2.HELI_HOVERATTACK2_UPDATE", entity );

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			if ( AI.GetTargetType( entity.id ) == AITARGET_MEMORY ) then
				local bClockedTarget = false;
				if ( target.actor and target.actor:GetNanoSuitMode() == 2 ) then
					bClockedTarget = true;
					if ( entity.AI.CurrentHook ~= fHELI_HOVERATTACK2_VSCLOAK ) then
						AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_VSCLOAK_START( entity );
					end
				end
				if ( entity.AI.bBlockSignal == false  ) then

					if ( System.GetCurrTime() - entity.AI.memorySec > 7.0 and bClockedTarget == false ) then

						local vMyPos = {};
						local vTargetPos = {};
						local vDir = {};
		
						CopyVector( vMyPos, entity:GetPos() );
						CopyVector( vTargetPos, target:GetPos() );
		
						vMyPos.z = vMyPos.z - 2.0
						vTargetPos.z = vTargetPos.z + 2.0;
						SubVectors( vDir, vTargetPos, vMyPos );
					
						local	hits = Physics.RayWorldIntersection(vMyPos,vDir,1,ent_terrain,target.id,entity.id,g_HitTable);
						if ( hits == 0 ) then
							entity.AI.bBlockSignal = true;
							AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_QUICKRETREAT_START( entity );
						end

					end
				end
			else
				entity.AI.memorySec = System.GetCurrTime();
			end

		else
			AIBehaviour.HeliHoverAttack2:OnNoTarget( entity );
			return;
		end

		if ( entity.AI.bBlockSignal == false ) then
			if (     entity.AI.CurrentHook == fHELI_HOVERATTACK2_DONOTHING ) then
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DEBUGLABEL( entity:GetPos(), "HELI_HOVERATTACK2_DONOTHING" );
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DONOTHING( entity );
				return;
			elseif ( entity.AI.CurrentHook == fHELI_HOVERATTACK2_GETDAMAGESMALL ) then
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DEBUGLABEL( entity:GetPos(), "HELI_HOVERATTACK2_GETDAMAGESMALL" );
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_GETDAMAGESMALL( entity );
			elseif ( entity.AI.CurrentHook == fHELI_HOVERATTACK2 ) then
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DEBUGLABEL( entity:GetPos(), "HELI_HOVERATTACK2" );
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2( entity );
			elseif ( entity.AI.CurrentHook == fHELI_HOVERATTACK2_STRAFING ) then
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DEBUGLABEL( entity:GetPos(), "HELI_HOVERATTACK2_STRAFING" );
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_STRAFING( entity );
			elseif ( entity.AI.CurrentHook == fHELI_HOVERATTACK2_STRAFING2 ) then
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DEBUGLABEL( entity:GetPos(), "HELI_HOVERATTACK2_STRAFING2" );
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_STRAFING2( entity );
			elseif ( entity.AI.CurrentHook == fHELI_HOVERATTACK2_STRAFING3 ) then
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DEBUGLABEL( entity:GetPos(), "HELI_HOVERATTACK2_STRAFING3" );
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_STRAFING3( entity );
			elseif ( entity.AI.CurrentHook == fHELI_HOVERATTACK2_STRAFING4 ) then
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DEBUGLABEL( entity:GetPos(), "HELI_HOVERATTACK2_STRAFING4" );
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_STRAFING4( entity );
			elseif ( entity.AI.CurrentHook == fHELI_HOVERATTACK2_STRAFING5 ) then
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DEBUGLABEL( entity:GetPos(), "HELI_HOVERATTACK2_STRAFING5" );
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_STRAFING5( entity );
			elseif ( entity.AI.CurrentHook == fHELI_HOVERATTACK2_DASH ) then
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DEBUGLABEL( entity:GetPos(), "HELI_HOVERATTACK2_DASH" );
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DASH( entity );
			elseif ( entity.AI.CurrentHook == fHELI_HOVERATTACK2_MAKECURVE ) then
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DEBUGLABEL( entity:GetPos(), "HELI_HOVERATTACK2_MAKECURVE" );
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_MAKECURVE( entity );
			elseif ( entity.AI.CurrentHook == fHELI_HOVERATTACK2_WAITLOOK ) then
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DEBUGLABEL( entity:GetPos(), "HELI_HOVERATTACK2_WAITLOOK" );
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_WAITLOOK( entity );
			elseif ( entity.AI.CurrentHook == fHELI_HOVERATTACK2_NORMALDAMAGE ) then
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DEBUGLABEL( entity:GetPos(), "HELI_HOVERATTACK2_NORMALDAMAGE" );
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_NORMALDAMAGE( entity );
			elseif ( entity.AI.CurrentHook == fHELI_HOVERATTACK2_NORMALDAMAGE2 ) then
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DEBUGLABEL( entity:GetPos(), "HELI_HOVERATTACK2_NORMALDAMAGE2" );
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_NORMALDAMAGE2( entity );
			elseif ( entity.AI.CurrentHook == fHELI_HOVERATTACK2_EVADELAW ) then
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DEBUGLABEL( entity:GetPos(), "HELI_HOVERATTACK2_EVADELAW" );
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_EVADELAW( entity );
			elseif ( entity.AI.CurrentHook == fHELI_HOVERATTACK2_PATHATTACK ) then
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DEBUGLABEL( entity:GetPos(), "HELI_HOVERATTACK2_PATHATTACK" );
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_PATHATTACK( entity );
			elseif ( entity.AI.CurrentHook == fHELI_HOVERATTACK2_GOAWAY ) then
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DEBUGLABEL( entity:GetPos(), "HELI_HOVERATTACK2_GOAWAY" );
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_GOAWAY( entity );
			elseif ( entity.AI.CurrentHook == fHELI_HOVERATTACK2_SHOOTMISSILE ) then
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DEBUGLABEL( entity:GetPos(), "HELI_HOVERATTACK2_SHOOTMISSILE" );
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_SHOOTMISSILE( entity );
			elseif ( entity.AI.CurrentHook == fHELI_HOVERATTACK2_SHOOTMISSILE2 ) then
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DEBUGLABEL( entity:GetPos(), "HELI_HOVERATTACK2_SHOOTMISSILE2" );
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_SHOOTMISSILE2( entity );
			elseif ( entity.AI.CurrentHook == fHELI_HOVERATTACK2_EMERGENCYSTOP ) then
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DEBUGLABEL( entity:GetPos(), "HELI_HOVERATTACK2_EMERGENCYSTOP" );
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_EMERGENCYSTOP( entity );
			elseif ( entity.AI.CurrentHook == fHELI_HOVERATTACK2_ADVANCE ) then
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DEBUGLABEL( entity:GetPos(), "HELI_HOVERATTACK2_ADVANCE" );
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_ADVANCE( entity );
			elseif ( entity.AI.CurrentHook == fHELI_HOVERATTACK2_QUICKRETREAT ) then
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DEBUGLABEL( entity:GetPos(), "HELI_HOVERATTACK2_QUICKRETREAT" );
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_QUICKRETREAT( entity );
			elseif ( entity.AI.CurrentHook == fHELI_HOVERATTACK2_VSCLOAK ) then
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DEBUGLABEL( entity:GetPos(), "HELI_HOVERATTACK2_VSCLOAK" );
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_VSCLOAK( entity );
			end
		else
			if (     entity.AI.InterruptHook == fHELI_HOVERATTACK2_DONOTHING ) then
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DEBUGLABEL( entity:GetPos(), "HELI_HOVERATTACK2_DONOTHING" );
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DONOTHING( entity );
				return;
			elseif ( entity.AI.InterruptHook == fHELI_HOVERATTACK2_GETDAMAGESMALL ) then
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DEBUGLABEL( entity:GetPos(), "HELI_HOVERATTACK2_GETDAMAGESMALL" );
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_GETDAMAGESMALL( entity );
			elseif ( entity.AI.InterruptHook == fHELI_HOVERATTACK2 ) then
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DEBUGLABEL( entity:GetPos(), "HELI_HOVERATTACK2" );
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2( entity );
			elseif ( entity.AI.InterruptHook == fHELI_HOVERATTACK2_STRAFING ) then
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DEBUGLABEL( entity:GetPos(), "HELI_HOVERATTACK2_STRAFING" );
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_STRAFING( entity );
			elseif ( entity.AI.InterruptHook == fHELI_HOVERATTACK2_STRAFING2 ) then
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DEBUGLABEL( entity:GetPos(), "HELI_HOVERATTACK2_STRAFING2" );
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_STRAFING2( entity );
			elseif ( entity.AI.InterruptHook == fHELI_HOVERATTACK2_STRAFING3 ) then
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DEBUGLABEL( entity:GetPos(), "HELI_HOVERATTACK2_STRAFING3" );
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_STRAFING3( entity );
			elseif ( entity.AI.InterruptHook == fHELI_HOVERATTACK2_STRAFING4 ) then
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DEBUGLABEL( entity:GetPos(), "HELI_HOVERATTACK2_STRAFING4" );
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_STRAFING4( entity );
			elseif ( entity.AI.InterruptHook == fHELI_HOVERATTACK2_STRAFING5 ) then
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DEBUGLABEL( entity:GetPos(), "HELI_HOVERATTACK2_STRAFING5" );
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_STRAFING5( entity );
			elseif ( entity.AI.InterruptHook == fHELI_HOVERATTACK2_DASH ) then
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DEBUGLABEL( entity:GetPos(), "HELI_HOVERATTACK2_DASH" );
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DASH( entity );
			elseif ( entity.AI.InterruptHook == fHELI_HOVERATTACK2_MAKECURVE ) then
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DEBUGLABEL( entity:GetPos(), "HELI_HOVERATTACK2_MAKECURVE" );
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_MAKECURVE( entity );
			elseif ( entity.AI.InterruptHook == fHELI_HOVERATTACK2_WAITLOOK ) then
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DEBUGLABEL( entity:GetPos(), "HELI_HOVERATTACK2_WAITLOOK" );
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_WAITLOOK( entity );
			elseif ( entity.AI.InterruptHook == fHELI_HOVERATTACK2_NORMALDAMAGE ) then
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DEBUGLABEL( entity:GetPos(), "HELI_HOVERATTACK2_NORMALDAMAGE" );
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_NORMALDAMAGE( entity );
			elseif ( entity.AI.InterruptHook == fHELI_HOVERATTACK2_NORMALDAMAGE2 ) then
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DEBUGLABEL( entity:GetPos(), "HELI_HOVERATTACK2_NORMALDAMAGE2" );
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_NORMALDAMAGE2( entity );
			elseif ( entity.AI.InterruptHook == fHELI_HOVERATTACK2_EVADELAW ) then
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DEBUGLABEL( entity:GetPos(), "HELI_HOVERATTACK2_EVADELAW" );
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_EVADELAW( entity );
			elseif ( entity.AI.InterruptHook == fHELI_HOVERATTACK2_PATHATTACK ) then
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DEBUGLABEL( entity:GetPos(), "HELI_HOVERATTACK2_PATHATTACK" );
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_PATHATTACK( entity );
			elseif ( entity.AI.InterruptHook == fHELI_HOVERATTACK2_GOAWAY ) then
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DEBUGLABEL( entity:GetPos(), "HELI_HOVERATTACK2_GOAWAY" );
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_GOAWAY( entity );
			elseif ( entity.AI.InterruptHook == fHELI_HOVERATTACK2_SHOOTMISSILE ) then
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DEBUGLABEL( entity:GetPos(), "HELI_HOVERATTACK2_SHOOTMISSILE" );
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_SHOOTMISSILE( entity );
			elseif ( entity.AI.InterruptHook == fHELI_HOVERATTACK2_SHOOTMISSILE2 ) then
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DEBUGLABEL( entity:GetPos(), "HELI_HOVERATTACK2_SHOOTMISSILE2" );
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_SHOOTMISSILE2( entity );
			elseif ( entity.AI.InterruptHook == fHELI_HOVERATTACK2_EMERGENCYSTOP ) then
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DEBUGLABEL( entity:GetPos(), "HELI_HOVERATTACK2_EMERGENCYSTOP" );
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_EMERGENCYSTOP( entity );
			elseif ( entity.AI.InterruptHook  == fHELI_HOVERATTACK2_QUICKRETREAT ) then
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DEBUGLABEL( entity:GetPos(), "HELI_HOVERATTACK2_QUICKRETREAT" );
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_QUICKRETREAT( entity );
			elseif ( entity.AI.InterruptHook  == fHELI_HOVERATTACK2_VSCLOAK ) then
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_DEBUGLABEL( entity:GetPos(), "HELI_HOVERATTACK2_VSCLOAK" );
				AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_VSCLOAK( entity );
			end
		end

		if ( entity.AI.resetLookAt == true ) then
			entity.AI.resetLookAt = false;
			AIBehaviour.HeliHoverAttack2:HELI_HOVERATTACK2_RECOVERLOOKAT_MAIN( entity );
		end

	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK2_DEBUGLABEL = function( self, pos, label )
		local vVec ={};
		CopyVector( vVec, pos );
		vVec.z = vVec.z + 10.0;
--		System.DrawLabel( vVec, 2, label, 1, 1, 1, 1);
	end,
	--------------------------------------------------------------------------
	HELI_HOVERATTACK2_DONOTHING = function( self, entity )
	
	end,


	--------------------------------------------------------------------------
	HELI_HOVERATTACK2_GETDAMAGESMALL_START = function ( self, entity, targetEntity )

		entity.AI.InterruptHook = fHELI_HOVERATTACK2_GETDAMAGESMALL;
		entity.AI.InterruptSec = System.GetCurrTime();
		entity.AI.bBlockSignal = true;

		local vFwd = {};
		local vWng = {};
		local vWngUnit = {};
		local vVel = {};
		local vPos = {};

		CopyVector( entity.AI.vInterruptMyPosRsv, entity:GetPos() );
		CopyVector( entity.AI.vInterruptTargetRsv, targetEntity:GetPos() );
		
		AIBehaviour.HELIDEFAULT:heliGetID( entity );
		CopyVector( vPos, entity:GetPos() );
		
		FastScaleVector( vFwd, entity:GetDirectionVector(1) ,100.0 );
		FastSumVectors( vFwd, vFwd, entity:GetPos() );
		
		local bDir = AIBehaviour.HELIDEFAULT:GetIdealWng2( entity, vWng, 40.0, vFwd );

		if ( bDir == false ) then
			FastScaleVector( vWng, vWng, -1.0 );
		end

		SubVectors( vFwd, targetEntity:GetPos(), entity:GetPos() );
		local zDef = -vFwd.z;

		if ( zDef < 40.0 ) then
			vFwd.z = 0;
			NormalizeVector( vFwd );
			FastScaleVector( vFwd, vFwd, - 10.0 );
			vWng.z = vWng.z + random( 10, 15 );
			FastSumVectors( vWng, vWng, vFwd );
		else
			vFwd.z = 0;
			FastScaleVector( vFwd, vFwd, - 10.0 );
			vWng.z = vWng.z + random( -7, -3 );
			FastSumVectors( vWng, vWng, vFwd );
		end

		NormalizeVector( vWng );
		FastScaleVector( entity.AI.vIdealVel, vWng, 25.0 );

		AI.SetRefPointPosition( entity.id, targetEntity:GetPos() );
		entity:SelectPipe( 0, "do_nothing");
		entity:SelectPipe( 0, "HeliMain");
		entity:InsertSubpipe( 0, "HeliLookatRef2" );

		self:HELI_HOVERATTACK2_GETDAMAGESMALL( entity );

	end,
	
	HELI_HOVERATTACK2_GETDAMAGESMALL = function ( self, entity )

		local vWng = {};
		local vVel = {};
		
		entity:GetVelocity( vVel );
		
		CopyVector( vWng, entity.AI.vIdealVel );

		if ( AIBehaviour.HELIDEFAULT:heliSetForcedNavigation( entity, vWng, 5.0, 3.0 ) < 0 ) then

			local targetEntity = System.GetEntity( entity.AI.lastShooterId );
			local target = AI.GetAttentionTargetEntity( entity.id );
			if ( target and targetEntity and target.id == targetEntity.id ) then
				self:HELI_HOVERATTACK2_SHOOTMISSILE_START( entity, entity.AI.vInterruptMyPosRsv, entity.AI.vInterruptTargetRsv );
			else
				self:HELI_HOVERATTACK2_RECOVERLOOKAT( entity );
			end
			return false;
		end

		if ( LengthVector( vVel ) > 15.0 and System.GetCurrTime() - entity.AI.InterruptSec > 1.0 ) then
			local targetEntity = System.GetEntity( entity.AI.lastShooterId );
			local target = AI.GetAttentionTargetEntity( entity.id );
			if ( target and targetEntity and target.id == targetEntity.id ) then
				self:HELI_HOVERATTACK2_SHOOTMISSILE_START( entity, entity.AI.vInterruptMyPosRsv, entity.AI.vInterruptTargetRsv );
			else
				self:HELI_HOVERATTACK2_RECOVERLOOKAT( entity );
			end
			return;
		end

		AI.SetForcedNavigation( entity.id, vWng );

	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK2_START = function( self, entity )

		if ( self:HELI_HOVERATTACK2_CHECKTARGET( entity )> 0 ) then
			return;
		end

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			AIBehaviour.HELIDEFAULT:heliRequest2ndGunnerShoot( entity );

			entity.AI.CurrentHook = fHELI_HOVERATTACK2;
			entity.AI.bCircledHalf = false;
			entity.AI.circleSec = System.GetCurrTime();

			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
			CopyVector( entity.AI.vTargetRsv, target:GetPos() );

			entity:SelectPipe( 0, "do_nothing");
			entity:SelectPipe( 0, "HeliMain");
			entity:InsertSubpipe(0,"HeliLookat");

			entity.AI.minZ = entity.AI.vTargetRsv.z + 20.0;

			self:HELI_HOVERATTACK2( entity );

		end

	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK2 = function( self, entity )

		local vWng = {};
		local vWngR = {};
		local vFwd = {};

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			if ( self:HELI_HOVERATTACK2_CHECKGOAWAY( entity, 150 ) == true ) then
				return;
			end

			local vTargetPos = {};
			local vMyPos = {};
	
			CopyVector( vTargetPos, target:GetPos() );
			CopyVector( vMyPos, entity:GetPos() );

			local vTmp = {};
			local vTmp2 = {};

			SubVectors( vTmp, target:GetPos(), entity:GetPos() );
			vTmp.z =0;
			NormalizeVector( vTmp );

			SubVectors( vTmp2, entity.AI.vTargetRsv, entity.AI.vMyPosRsv );
			vTmp2.z =0;
			NormalizeVector( vTmp2 );

			local dot = dotproduct3d( vTmp, vTmp2 );
			if ( dot <  math.cos( 160.0 * 3.1416 / 180.0  ) ) then
				entity.AI.bCircledHalf = true;
			end

			if ( entity.AI.bCircledHalf == true ) then

				if ( self:HELI_HOVERATTACK2_CHECKTARGET( entity )> 0 ) then
					return;
				end

				if ( dot >  math.cos( 20.0 * 3.1416 / 180.0 ) ) then
					AI.Signal(SIGNALFILTER_SENDER,1,"HELI_HOVERATTACK2_MAKECURVE_START",entity.id);
					return;
				end
			end

			local vDist = {};
			SubVectors( vDist, target:GetPos(), entity:GetPos() );
			vDist.z =0;

			SubVectors( vFwd, target:GetPos(), entity:GetPos() );
			NormalizeVector( vFwd );
			crossproduct3d( vWng, vFwd, entity.AI.vUp );
			vWng.z = 0;
			if ( entity.AI.rotateDirection == false ) then
				FastScaleVector( vWng, vWng, -30.0 );
			end

			NormalizeVector( vWng );
			FastScaleVector( vWng, vWng, 30.0 );
			FastSumVectors( vWng, vWng, entity:GetPos() );
	
			SubVectors( vFwd, vWng , target:GetPos()  );
			NormalizeVector( vFwd );
			FastScaleVector( vFwd, vFwd, 30.0 );
			FastSumVectors( vFwd, vFwd, target:GetPos() );
			SubVectors( vFwd, vFwd, entity:GetPos() );
			NormalizeVector( vFwd );
			FastScaleVector( vFwd, vFwd, 12.0 );

			local height = AIBehaviour.HELIDEFAULT:heliSetForcedNavigation( entity, vFwd, 5.0, 3.5 )
			if ( height < 0  ) then
				self:HELI_HOVERATTACK2_EMERGENCYSTOP_START( entity );
				return false;
			end

			AIBehaviour.HELIDEFAULT:heliUpdateMinZ( entity, vFwd, height, 2.0 );
			AIBehaviour.HELIDEFAULT:heliStickToMinZ( entity, vFwd );

			--System.Log("hight speed "..vFwd.z);
			AI.SetForcedNavigation( entity.id, vFwd );

		end

	end,

	HELI_HOVERATTACK2_ADVANCE_START  = function( self, entity )

		if ( self:HELI_HOVERATTACK2_CHECKTARGET( entity )> 0 ) then
			return;
		end

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			entity.AI.circleSec = System.GetCurrTime();
			CopyVector( entity.AI.vTargetRsv, target:GetPos() );
			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
			entity.AI.CurrentHook = fHELI_HOVERATTACK2_ADVANCE;
			entity.AI.minZ = entity.AI.vTargetRsv.z + 30.0;

			AI.SetRefPointPosition(entity.id,entity.AI.vTargetRsv);

			entity:SelectPipe(0,"do_nothing");
			entity:SelectPipe(0,"HeliMain");
			entity:InsertSubpipe(0,"HeliLookatRef");
			self:HELI_HOVERATTACK2_ADVANCE( entity );

		end
		
	end,

	HELI_HOVERATTACK2_ADVANCE  = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			if ( self:HELI_HOVERATTACK2_CHECKGOAWAY( entity, 180 ) == true ) then
				return;
			end

			local vMyPos = {};
			local vFwd = {};
			local vTmp = {};
			local vTmp2= {};
			local vDist= {};

			CopyVector( vMyPos, entity:GetPos() );

			CopyVector( vTmp, entity.AI.vTargetRsv );
			vTmp.z = vTmp.z + 25.0;

			SubVectors( vFwd, vTmp, entity.AI.vMyPosRsv );
			NormalizeVector( vFwd );

			entity:GetVelocity( vTmp );
			NormalizeVector( vTmp );

			local dot = dotproduct3d( vFwd, vTmp );
			if ( dot < 0 ) then
				dot = 0;
			end

			SubVectors( vDist, entity.AI.vTargetRsv, entity:GetPos() );
			vDist.z = 0;

			local cof = LengthVector( vDist )- 30.0;

			if ( cof > 100.0 ) then
				cof = 100.0;
			end

			if ( cof < 0.0 ) then
				cof = 0.0;
			end

			cof = cof * 20.0 /100.0;
			if ( cof < 5.0 ) then
				cof = 5.0 ;
			end

			FastScaleVector( vFwd, vFwd, cof );
			vFwd.z = vFwd.z + ( 1.0 - dot )* 5.0;

			if ( LengthVector( vDist ) < 60.0 ) then
			
				CopyVector( vTmp, entity:GetDirectionVector( 0 ) );
				if ( entity.AI.rotateDirection == false ) then
					FastScaleVector( vTmp, vTmp, -1.0 );
				end

				entity:GetVelocity( vTmp2 );
				
				local currentSpeed = LengthVector( vTmp2 );
				if ( currentSpeed > 16.0 ) then
					currentSpeed = 16.0 + ( currentSpeed - 1.0 )* 0.8;
				end
				NormalizeVector( vFwd );
				FastScaleVector( vFwd, vFwd, currentSpeed );
				NormalizeVector( vTmp2 );
				local dot = dotproduct3d( vTmp2, vTmp );
				FastScaleVector( vTmp, vTmp, 6.0 * dot + 3.0 );
				FastSumVectors( vFwd, vFwd, vTmp );

			else
				entity.AI.circleSec = System.GetCurrTime();
			end

			if ( LengthVector( vDist ) < 30.0 or System.GetCurrTime() - entity.AI.circleSec > 3.0 ) then
				AI.Signal(SIGNALFILTER_SENDER,1,"HELI_HOVERATTACK2_START", entity.id);
				return;
			end
			
			local height = AIBehaviour.HELIDEFAULT:heliSetForcedNavigation( entity, vFwd, 5.0, 3.5 );
			if ( height < 0 ) then
				self:HELI_HOVERATTACK2_EMERGENCYSTOP_START( entity );
				return false;
			end

			AIBehaviour.HELIDEFAULT:heliUpdateMinZ( entity, vFwd, height, 3.0 );
			AIBehaviour.HELIDEFAULT:heliStickToMinZ( entity, vFwd );

			AI.SetForcedNavigation( entity.id, vFwd );

		end


	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK2_QUICKRETREAT_START  = function( self, entity )
		
		if ( self:HELI_HOVERATTACK2_CHECKTARGET( entity )> 0 ) then
			return;
		end

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			entity.AI.InterruptSec = System.GetCurrTime();
			entity.AI.InterruptHook = fHELI_HOVERATTACK2_QUICKRETREAT;

			CopyVector( entity.AI.vInterruptMyPosRsv, entity:GetPos() );
			CopyVector( entity.AI.vInterruptTargetRsv, target:GetPos() );
			
			SubVectors( entity.AI.vInterruptDirectionRsv, entity:GetPos(), entity.AI.vInterruptTargetRsv );
			entity.AI.vInterruptDirectionRsv.z = 0;

			NormalizeVector( entity.AI.vInterruptDirectionRsv );

			AI.SetRefPointPosition( entity.id, entity.AI.vInterruptTargetRsv );
			entity:SelectPipe( 0, "do_nothing");
			entity:SelectPipe( 0, "HeliMain");
			entity:InsertSubpipe( 0, "HeliLookatRef2");

			self:HELI_HOVERATTACK2_QUICKRETREAT( entity );

		end

	end,

	HELI_HOVERATTACK2_QUICKRETREAT = function( self, entity )
	
		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			local vTmp= {};
			local vTmp2= {};
			local vMyPos= {};
			local vDist = {};

			FastScaleVector( vTmp, entity.AI.vInterruptDirectionRsv, 10.0 );
			SubVectors( vDist, entity.AI.vInterruptTargetRsv, entity:GetPos() );
			CopyVector( vMyPos, entity:GetPos() );
			vDist.z = 0;
			vTmp.z = 2.0;

			if ( LengthVector( vDist ) > 60.0 ) then

				local vDir = {};
				local vResult = {};
				SubVectors( vDir, entity.AI.vInterruptTargetRsv, entity:GetPos() );
				NormalizeVector( vDir );
				FastScaleVector( vDir, vDir, 20.0 );
				CopyVector( vResult, AI.IsFlightSpaceVoidByRadius( entity:GetPos(), vDir, 8.0 ) );

				if ( LengthVector( vResult ) >0.0 ) then
					vTmp.z = 10.0;
				else
					local vMyPos = {};
					local vTargetPos = {};
	
					CopyVector( vMyPos, entity:GetPos() );
					CopyVector( vTargetPos, entity.AI.vInterruptTargetRsv );
	
					vMyPos.z = vMyPos.z - 2.0
					vTargetPos.z = vTargetPos.z + 2.0;
					SubVectors( vDir, vTargetPos, vMyPos );
				
					local	hits = Physics.RayWorldIntersection(vMyPos,vDir,1,ent_terrain,target.id,entity.id,g_HitTable);
					if( hits > 0 or vMyPos.z < entity.AI.vInterruptTargetRsv.z + 30.0 ) then
						vTmp.x = 0.0;
						vTmp.y = 0.0;
						vTmp.z = 2.0;
						height = AIBehaviour.HELIDEFAULT:heliSetForcedNavigation( entity, vTmp, 8.0, 3.5 );
						if ( height < 0 ) then
							self:HELI_HOVERATTACK2_RECOVERLOOKAT( entity );
							return false;
						end
						AI.SetForcedNavigation( entity.id, vTmp );
						return;
					else
						CopyVector( vTargetPos, entity.AI.vInterruptTargetRsv );
						self:HELI_HOVERATTACK2_SHOOTMISSILE_START( entity, vMyPos, vTargetPos );
						return;
					end
				end
			end

			height = AIBehaviour.HELIDEFAULT:heliSetForcedNavigation( entity, vTmp, 8.0, 3.5 );
			if ( height < 0 ) then
				self:HELI_HOVERATTACK2_RECOVERLOOKAT( entity );
				return false;
			end

			if ( height > vMyPos.z ) then
			
				vTmp.z = ( height - vMyPos.z )/3.0;
			
			end

			local sec = System.GetCurrTime() - entity.AI.InterruptSec;
			if ( sec > 10 ) then
				self:HELI_HOVERATTACK2_RECOVERLOOKAT( entity );
				return false;
			end
	
			AI.SetForcedNavigation( entity.id, vTmp );

		end


	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK2_STRAFERETREAT_START  = function( self, entity )
		
		if ( self:HELI_HOVERATTACK2_CHECKTARGET( entity )> 0 ) then
			return;
		end

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			entity.AI.circleSec = System.GetCurrTime();
			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
			CopyVector( entity.AI.vTargetRsv, target:GetPos() );

			AI.SetRefPointPosition(entity.id,entity.AI.vTargetRsv);
			entity:SelectPipe( 0, "do_nothing");
			entity:SelectPipe( 0, "HeliMain");
			entity:InsertSubpipe( 0, "HeliLookatRef" );

			entity.AI.minZ = entity.AI.vTargetRsv.z + 30.0;
			entity.AI.CurrentHook = fHELI_HOVERATTACK2_STRAFERETREAT;

			self:HELI_HOVERATTACK2_STRAFERETREAT( entity );

		end

	end,

	HELI_HOVERATTACK2_STRAFERETREAT  = function( self, entity )

		
		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			local vFwd = {};
			local vTmp= {};
			local vTmp2= {};
			local vDist = {};
	
			SubVectors( vFwd, entity.AI.vMyPosRsv, entity.AI.vTargetRsv );
			vFwd.z =0;
			NormalizeVector( vFwd );
			FastScaleVector( vFwd, vFwd, 80.0 );
			vFwd.z =30;
			FastSumVectors( vFwd, vFwd, entity.AI.vTargetRsv );
			SubVectors( vFwd, vFwd, entity.AI.vMyPosRsv );

			NormalizeVector( vFwd );

			entity:GetVelocity( vTmp );
			NormalizeVector( vTmp );

			local dot = dotproduct3d( vFwd, vTmp );
			if ( dot < 0 ) then
				dot = 0;
			end

			FastScaleVector( vFwd, vFwd, 15.0 );

			vFwd.z = vFwd.z + ( 1.0 - dot )* 5.0;

			SubVectors( vDist, entity.AI.vTargetRsv, entity:GetPos() );
			vDist.z = 0;


			if ( LengthVector( vDist ) > 80.0 ) then
				AI.Signal(SIGNALFILTER_SENDER,1,"HELI_HOVERATTACK2_STRAFING_START", entity.id);
				return;
			end

			height = AIBehaviour.HELIDEFAULT:heliSetForcedNavigation( entity, vFwd, 8.0, 3.5 );
			if ( height < 0 ) then
				self:HELI_HOVERATTACK2_EMERGENCYSTOP_START( entity );
				return false;
			end

			AIBehaviour.HELIDEFAULT:heliUpdateMinZ( entity, vFwd, height, 3.0 );
			AIBehaviour.HELIDEFAULT:heliStickToMinZ( entity, vFwd );

			AI.SetForcedNavigation( entity.id, vFwd );

		end
	

	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK2_STRAFING_START = function( self, entity )

		if ( self:HELI_HOVERATTACK2_CHECKTARGET( entity )> 0 ) then
			return;
		end

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			entity.AI.circleSec = System.GetCurrTime();
			CopyVector( entity.AI.vTargetRsv, target:GetPos() );
			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
			SubVectors( entity.AI.vDirectionRsv, target:GetPos(), entity:GetPos() );
	
			entity.AI.CurrentHook = fHELI_HOVERATTACK2_STRAFING;

			entity.AI.minZ = entity.AI.vTargetRsv.z + 30.0;

			entity:SelectPipe( 0, "do_nothing");
			entity:SelectPipe( 0, "HeliMain");
			entity:InsertSubpipe( 0, "HeliResetLookat2" );

			self:HELI_HOVERATTACK2_STRAFING( entity );

		end


	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK2_STRAFING = function( self, entity )

		local vWng = {};
		local vFwd = {};

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			if ( self:HELI_HOVERATTACK2_CHECKGOAWAY( entity, 200 ) == true ) then
				return;
			end

			SubVectors( vFwd, entity.AI.vMyPosRsv, entity.AI.vTargetRsv );
			vFwd.z = 0;
			NormalizeVector( vFwd );
			crossproduct3d( vWng, vFwd, entity.AI.vUp );
			if ( entity.AI.rotateDirection == false ) then
				FastScaleVector( vWng, vWng, -1.0 );			
			end
			FastScaleVector( vWng, vWng, 20.0 );

			vWng.z = 5.0;

			local height = AIBehaviour.HELIDEFAULT:heliSetForcedNavigation( entity, vWng, 7.0, 3.5 )
			if ( height < 0 ) then
				self:HELI_HOVERATTACK2_EMERGENCYSTOP_START( entity );
				return false;
			end

			AIBehaviour.HELIDEFAULT:heliUpdateMinZ( entity, vWng, height, 3.0 );
			AIBehaviour.HELIDEFAULT:heliStickToMinZ( entity, vWng );
	
			if ( System.GetCurrTime() - entity.AI.circleSec > 2.0 ) then
				AI.Signal(SIGNALFILTER_SENDER,1,"HELI_HOVERATTACK2_STRAFING2_START", entity.id);
				return;
			end
	
			AI.SetForcedNavigation( entity.id, vWng );

		end

	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK2_STRAFING2_START = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			entity.AI.circleSec = System.GetCurrTime();
			entity.AI.deltaT = System.GetCurrTime();
			entity.AI.bLock = false;

			CopyVector( entity.AI.vTargetRsv, target:GetPos() );
			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );

			entity.AI.CurrentHook = fHELI_HOVERATTACK2_STRAFING2;

			entity.AI.minZ = entity.AI.vTargetRsv.z + 30.0;

			self:HELI_HOVERATTACK2_STRAFING2( entity );

		end

	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK2_STRAFING2 = function( self, entity )

		local vVel = {};
		local vVelRot = {};
		local vWng = {};
		local vFwd = {};
		local vDist = {};

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			if ( self:HELI_HOVERATTACK2_CHECKGOAWAY( entity, 200 ) == true ) then
				return;
			end

			SubVectors( vDist, target:GetPos(), entity:GetPos() );
			vDist.z =0;

			SubVectors( vFwd, target:GetPos(), entity:GetPos() );
			vFwd.z = 0;
			NormalizeVector( vFwd );

			CopyVector( vWng, entity:GetDirectionVector(0) );
			if ( entity.AI.rotateDirection == false ) then
				FastScaleVector( vWng, vWng, -1.0 );			
			end

			CopyVector( vVel, entity:GetDirectionVector(1) );
			vVel.z =0;
			NormalizeVector( vVel );
			FastScaleVector( vVel, vVel, 20.0 );

			local dot = dotproduct3d( vFwd, vWng );
			local deltaT = System.GetCurrTime() -  entity.AI.deltaT;
			if (deltaT > 1.0 ) then
				deltaT = 1.0;
			end


			if ( entity.AI.bLock == false ) then

			if ( entity.AI.rotateDirection == false ) then
				if ( dot < 0 ) then --needs to turn right
					RotateVectorAroundR( vVelRot, vVel, entity.AI.vUp, -3.1416* 30.0 * deltaT / 180.0 );
				else
					RotateVectorAroundR( vVelRot, vVel, entity.AI.vUp, 3.1416* 30.0 * deltaT / 180.0 );
				end
			else
				if ( dot < 0 ) then --needs to turn right
					RotateVectorAroundR( vVelRot, vVel, entity.AI.vUp, 3.1416* 30.0 * deltaT / 180.0 );
				else
					RotateVectorAroundR( vVelRot, vVel, entity.AI.vUp, -3.1416* 30.0 * deltaT / 180.0 );
				end
			end
				entity.AI.circleSec = System.GetCurrTime();

			else
				CopyVector( vVelRot, vVel );
			end

			CopyVector( vVel, entity:GetDirectionVector(1) );
			vVel.z =0;
			NormalizeVector( vVel );

			SubVectors( vFwd, target:GetPos(), entity:GetPos() );
			vFwd.z = 0;
			NormalizeVector( vFwd );

			local dot = dotproduct3d( vVel, vFwd );
			if ( dot >  math.cos( 15.0 * 3.1416 / 180.0  ) ) then
				entity.AI.bLock = true;
			end

			if (	entity.AI.bLock == true  ) then

				if ( LengthVector( vDist )< 70.0 or System.GetCurrTime() - entity.AI.circleSec > 8 ) then
						AI.Signal(SIGNALFILTER_SENDER,1,"HELI_HOVERATTACK2_STRAFING3_START", entity.id);
						return;
				end

			end

			height = AIBehaviour.HELIDEFAULT:heliSetForcedNavigation( entity, vVelRot, 8.0, 3.5 );
			if ( height < 0  ) then
				self:HELI_HOVERATTACK2_EMERGENCYSTOP_START( entity );
				return false;
			end

			AIBehaviour.HELIDEFAULT:heliUpdateMinZ( entity, vVelRot, height, 3.0 );
			AIBehaviour.HELIDEFAULT:heliStickToMinZ( entity, vVelRot );

			entity.AI.deltaT = System.GetCurrTime();

			AI.SetForcedNavigation( entity.id, vVelRot );

		end

	end,


	--------------------------------------------------------------------------
	HELI_HOVERATTACK2_STRAFING3_START = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			entity.AI.circleSec = System.GetCurrTime();
			entity.AI.deltaT = System.GetCurrTime();
			entity.AI.bLock = false;


			CopyVector( entity.AI.vTargetRsv, target:GetPos() );
			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
			entity.AI.CurrentHook = fHELI_HOVERATTACK2_STRAFING3;

			entity.AI.minZ = entity.AI.vTargetRsv.z + 30.0;

			self:HELI_HOVERATTACK2_STRAFING3( entity );

		end

	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK2_STRAFING3 = function( self, entity )

		local vWng = {};
		local vFwd = {};

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			if ( self:HELI_HOVERATTACK2_CHECKGOAWAY( entity, 200 ) == true ) then
				return;
			end

			CopyVector( vFwd, entity.AI.vDirectionRsv );
			vFwd.z = 0;
			NormalizeVector( vFwd );
			crossproduct3d( vWng, vFwd, entity.AI.vUp );
			if ( entity.AI.rotateDirection == false ) then
				FastScaleVector( vWng, vWng, -1.0 );			
			end
			FastScaleVector( vWng, vWng, -18.0 );

			local vTmp = {};
			entity:GetVelocity( vTmp );
			FastSumVectors( vWng, vWng, vTmp );
			FastScaleVector( vWng, vWng, 0.5 );

			vWng.z = 5.0;

			local height = AIBehaviour.HELIDEFAULT:heliSetForcedNavigation( entity, vWng, 8.0, 3.5 )
			if ( height < 0 ) then
				self:HELI_HOVERATTACK2_EMERGENCYSTOP_START( entity );
				return false;
			end

			AIBehaviour.HELIDEFAULT:heliUpdateMinZ( entity, vWng, height, 3.0 );
			AIBehaviour.HELIDEFAULT:heliStickToMinZ( entity, vWng );
	
			if ( System.GetCurrTime() - entity.AI.circleSec > 2.0 ) then
				AI.Signal(SIGNALFILTER_SENDER,1,"HELI_HOVERATTACK2_STRAFING4_START", entity.id);
				return;
			end
	
			AI.SetForcedNavigation( entity.id, vWng );

		end

	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK2_STRAFING4_START = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			entity.AI.circleSec = System.GetCurrTime();
			entity.AI.deltaT = System.GetCurrTime();
			entity.AI.bLock = false;

			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
			NormalizeVector( entity.AI.vDirectionRsv );
			FastScaleVector( entity.AI.vDirectionRsv, entity.AI.vDirectionRsv, 110.0 );
			FastSumVectors( entity.AI.vTargetRsv, entity.AI.vDirectionRsv, target:GetPos() );


			entity.AI.minZ = entity.AI.vTargetRsv.z + 30.0;

			entity.AI.CurrentHook = fHELI_HOVERATTACK2_STRAFING4;

			self:HELI_HOVERATTACK2_STRAFING4( entity );

		end

	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK2_STRAFING4 = function( self, entity )

		local vVel = {};
		local vVelRot = {};
		local vWng = {};
		local vFwd = {};
		local vDist = {};

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			if ( self:HELI_HOVERATTACK2_CHECKGOAWAY( entity, 200 ) == true ) then
				return;
			end

			SubVectors( vDist, entity.AI.vTargetRsv, entity:GetPos() );
			vDist.z =0;

			SubVectors( vFwd, entity.AI.vTargetRsv, entity:GetPos() );
			vFwd.z = 0;
			NormalizeVector( vFwd );

			CopyVector( vWng, entity:GetDirectionVector(0) );
			if ( entity.AI.rotateDirection == false ) then
				FastScaleVector( vWng, vWng, -1.0 );			
			end

			CopyVector( vVel, entity:GetDirectionVector(1) );
			vVel.z =0;
			NormalizeVector( vVel );
			FastScaleVector( vVel, vVel, 20.0 );

			local dot = dotproduct3d( vFwd, vWng );
			local deltaT = System.GetCurrTime() -  entity.AI.deltaT;
			if (deltaT > 1.0 ) then
				deltaT = 1.0;
			end

			if ( entity.AI.bLock == false ) then

				if ( entity.AI.rotateDirection == false ) then
					if ( dot < 0 ) then --needs to turn right
						RotateVectorAroundR( vVelRot, vVel, entity.AI.vUp, -3.1416* 30.0 * deltaT / 180.0 );
					else
						RotateVectorAroundR( vVelRot, vVel, entity.AI.vUp, 3.1416* 30.0 * deltaT / 180.0 );
					end
				else	
					if ( dot < 0 ) then --needs to turn right
						RotateVectorAroundR( vVelRot, vVel, entity.AI.vUp, 3.1416* 30.0 * deltaT / 180.0 );
					else
						RotateVectorAroundR( vVelRot, vVel, entity.AI.vUp, -3.1416* 30.0 * deltaT / 180.0 );
					end
				end
				
			else
				CopyVector( vVelRot, vVel );
			end

			CopyVector( vVel, entity:GetDirectionVector(1) );
			vVel.z =0;
			NormalizeVector( vVel );

			SubVectors( vFwd, entity.AI.vTargetRsv, entity:GetPos() );
			vFwd.z = 0;
			NormalizeVector( vFwd );

			local dot = dotproduct3d( vVel, vFwd );
			if ( dot >  math.cos( 15.0 * 3.1416 / 180.0  ) ) then
				entity.AI.bLock = true;
			end

			if (	entity.AI.bLock == true ) then

				if ( LengthVector( vDist ) < 20.0 ) then
						AI.Signal(SIGNALFILTER_SENDER,1,"HELI_HOVERATTACK2_STRAFING5_START", entity.id);
						return;
				end

			end

			if ( System.GetCurrTime() - entity.AI.circleSec > 20.0 ) then
				AI.Signal(SIGNALFILTER_SENDER,1,"HELI_HOVERATTACK2_STRAFING5_START", entity.id);
				return;
			end 

			entity.AI.deltaT = System.GetCurrTime();

			local height = AIBehaviour.HELIDEFAULT:heliSetForcedNavigation( entity, vVelRot, 8.0, 3.5 );
			if ( height < 0 ) then
				self:HELI_HOVERATTACK2_EMERGENCYSTOP_START( entity );
				return false;
			end

			AIBehaviour.HELIDEFAULT:heliUpdateMinZ( entity, vVelRot, height, 3.0 );
			AIBehaviour.HELIDEFAULT:heliStickToMinZ( entity, vVelRot );

			AI.SetForcedNavigation( entity.id, vVelRot );

		end

	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK2_STRAFING5_START = function( self, entity )

		if ( self:HELI_HOVERATTACK2_CHECKTARGET( entity )> 0 ) then
			return;
		end

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			entity.AI.circleSec = System.GetCurrTime();
			entity.AI.deltaT = System.GetCurrTime();
			entity.AI.bLock = false;

			CopyVector( entity.AI.vTargetRsv, target:GetPos() );
			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
			entity.AI.minZ = entity.AI.vTargetRsv.z + 35.0;
			entity.AI.CurrentHook = fHELI_HOVERATTACK2_STRAFING5;

			entity:SelectPipe( 0, "do_nothing");
			entity:SelectPipe( 0, "HeliMain");
			entity:InsertSubpipe(0,"HeliLookat");

			self:HELI_HOVERATTACK2_STRAFING5( entity );

		end

	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK2_STRAFING5 = function( self, entity )

		local vHover = {};
		
		vHover.x = 0.0;
		vHover.y = 0.0; 
		vHover.z = 5.0; 

		if ( self:HELI_HOVERATTACK2_CHECKGOAWAY( entity, 200 ) == true ) then
			return;
		end

		if ( System.GetCurrTime() - entity.AI.circleSec > 3.0 ) then
			if ( random(1,256) > 200 ) then
				AI.Signal(SIGNALFILTER_SENDER,1,"HELI_HOVERATTACK2_ADVANCE_START", entity.id);
			else
				AI.Signal(SIGNALFILTER_SENDER,1,"HELI_HOVERATTACK2_GOAWAY_START", entity.id);
			end
			return;
		end

		local height = AIBehaviour.HELIDEFAULT:heliSetForcedNavigation( entity, vHover, 7.0, 3.5 );
		if ( height < 0 ) then
				self:HELI_HOVERATTACK2_EMERGENCYSTOP_START( entity );
				return false;
		end

--		AIBehaviour.HELIDEFAULT:heliUpdateMinZ( entity, vHover, height, 3.0 );
--		AIBehaviour.HELIDEFAULT:heliStickToMinZ( entity, vHover );

		AI.SetForcedNavigation( entity.id, vHover );

	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK2_DASH_START = function( self, entity )

		if ( self:HELI_HOVERATTACK2_CHECKTARGET( entity )> 0 ) then
			return;
		end

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			entity.AI.circleSec = System.GetCurrTime();
			entity.AI.deltaT = System.GetCurrTime();
			entity.AI.bLock = false;

			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
			CopyVector( entity.AI.vTargetRsv, target:GetPos() );
			entity.AI.CurrentHook = fHELI_HOVERATTACK2_DASH;

			SubVectors( entity.AI.vDirectionRsv, entity:GetPos(), target:GetPos()  );
			entity.AI.vDirectionRsv.z =0;
			NormalizeVector( entity.AI.vDirectionRsv );
			FastScaleVector( entity.AI.vDirectionRsv, entity.AI.vDirectionRsv, 200.0 );

			entity:SelectPipe( 0, "do_nothing");
			entity:SelectPipe( 0, "HeliMain");
			entity:InsertSubpipe( 0, "HeliResetLookat2" );

			local vTmp = {};
	
			CopyVector( vTmp, entity:GetDirectionVector(1) );
			vTmp.z =0.0;
			NormalizeVector( vTmp );
			FastScaleVector( vTmp, vTmp, 30.0 );
			vTmp.z =4.0;

			entity.AI.vDashVec = {};
	
			CopyVector( entity.AI.vDashVec, vTmp );
			
			self:HELI_HOVERATTACK2_DASH( entity );
			--self:HELI_HOVERATTACK2_MAKECURVE_START ( entity );

		end

	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK2_DASH = function( self, entity )

		local vTmp = {};

		CopyVector( vTmp, entity.AI.vDashVec );

		if ( AIBehaviour.HELIDEFAULT:heliSetForcedNavigation( entity, vTmp, 2.0, 3.0 )  < 0  ) then
			self:HELI_HOVERATTACK2_EMERGENCYSTOP_START( entity );
			return false;
		end

		if ( System.GetCurrTime() - entity.AI.circleSec > 1.0 ) then
				AI.Signal(SIGNALFILTER_SENDER, 1, "HELI_HOVERATTACK2_MAKECURVE_START", entity.id);
				return;
		end

		AI.SetForcedNavigation( entity.id, vTmp );

	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK2_MAKECURVE_START = function( self, entity )

		if ( self:HELI_HOVERATTACK2_CHECKTARGET( entity )> 0 ) then
			return;
		end

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			local vDist = {};
			SubVectors( vDist, target:GetPos(), entity:GetPos() );
			vDist.z =0;

			entity.AI.circleSec = System.GetCurrTime();
			entity.AI.deltaT = System.GetCurrTime();
			entity.AI.bLock = false;

			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
			CopyVector( entity.AI.vTargetRsv, target:GetPos() );

			entity.AI.minZ = entity.AI.vTargetRsv.z + 30.0;

			SubVectors( entity.AI.vDirectionRsv, entity:GetPos(), target:GetPos()  );
			entity.AI.vDirectionRsv.z =0;
			NormalizeVector( entity.AI.vDirectionRsv );
			FastScaleVector( entity.AI.vDirectionRsv, entity.AI.vDirectionRsv, 200.0 );

			entity.AI.CurrentHook = fHELI_HOVERATTACK2_MAKECURVE;

			entity:SelectPipe( 0, "do_nothing");
			entity:SelectPipe( 0, "HeliMain");
			entity:InsertSubpipe( 0, "HeliResetLookat2" );

			self:HELI_HOVERATTACK2_MAKECURVE( entity );

		end

	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK2_MAKECURVE = function( self, entity )

		local vTmp = {};
		local vTmp2 = {};
		local vTmp3 = {};
		local vTmp4 = {};

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			if ( self:HELI_HOVERATTACK2_CHECKGOAWAY( entity, 200 ) == true ) then
				return;
			end

			CopyVector( vTmp , entity.AI.vDirectionRsv );
			vTmp.z =0;

			SubVectors( vTmp2 , entity:GetPos(), entity.AI.vTargetRsv );
			vTmp2.z =0;
			CopyVector( vTmp3, vTmp2 );

			local dot = dotproduct3d( vTmp, vTmp2 )/LengthVector( vTmp );
			
 			dot = dot + 25.0;
 			if ( dot > 100.0 ) then
 				dot = 100.0;
 			end
			local rad = 3.1416 * dot / 100.0;
			local wingLen = math.sin( rad ) * 50.0;

			NormalizeVector( vTmp );
			crossproduct3d( vTmp2, vTmp, entity.AI.vUp );
			NormalizeVector( vTmp2 );
			if ( entity.AI.rotateDirection == false ) then
				FastScaleVector( vTmp2, vTmp2, -1.0 );			
			end
			FastScaleVector( vTmp2, vTmp2, - wingLen );
			FastScaleVector( vTmp, vTmp, dot );
			FastSumVectors( vTmp, vTmp, vTmp2 );

			local height = 50.0 * dot /100.0;
			vTmp.z = height;
			FastSumVectors( vTmp, vTmp, entity.AI.vTargetRsv );

			SubVectors( vTmp, vTmp, entity:GetPos() );
			NormalizeVector( vTmp );
			FastScaleVector( vTmp, vTmp, 16.0 );

			local length = LengthVector( vTmp3 );
			NormalizeVector( vTmp3 );
			CopyVector( vTmp2, entity.AI.vDirectionRsv );
			NormalizeVector( vTmp2 );

			local dot = dotproduct3d( vTmp2, vTmp3 );

			if ( System.GetCurrTime() - entity.AI.circleSec > 20.0) then
				AI.Signal(SIGNALFILTER_SENDER, 1, "HELI_HOVERATTACK2_STRAFING_START", entity.id);
				return;
			end

			CopyVector( vTmp3 , entity.AI.vDirectionRsv );
			vTmp3.z =0;
			NormalizeVector( vTmp3 );

			SubVectors( vTmp4, entity:GetPos(), entity.AI.vTargetRsv );
			vTmp4.z =0;
			NormalizeVector( vTmp4 );
	
			local dot = dotproduct3d( vTmp3, vTmp4 );
		
			if ( length > 80.0 and dot > math.cos( 20.0 * 3.1416 / 180.0 ) ) then
				AI.Signal(SIGNALFILTER_SENDER, 1, "HELI_HOVERATTACK2_STRAFING_START", entity.id);
				return;
			end

			local height = AIBehaviour.HELIDEFAULT:heliSetForcedNavigation( entity, vTmp, 7.0, 3.5 );
			if ( height < 0  ) then
				self:HELI_HOVERATTACK2_EMERGENCYSTOP_START( entity );
				return false;
			end

			AIBehaviour.HELIDEFAULT:heliUpdateMinZ( entity, vTmp, height, 3.0 );
			AIBehaviour.HELIDEFAULT:heliStickToMinZ( entity, vTmp );

			AI.SetForcedNavigation( entity.id, vTmp );

		end

	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK2_WAITLOOK_START = function( self, entity )

		if ( self:HELI_HOVERATTACK2_CHECKTARGET( entity )> 0 ) then
			return;
		end

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			entity.AI.circleSec = System.GetCurrTime();
			entity.AI.deltaT = System.GetCurrTime();
			entity.AI.bLock = false;

			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
			CopyVector( entity.AI.vTargetRsv, target:GetPos() );
			SubVectors( entity.AI.vDirectionRsv, target:GetPos(), entity:GetPos() );
			entity.AI.vDirectionRsv.z = 0;
			NormalizeVector( entity.AI.vDirectionRsv );

			entity.AI.CurrentHook = fHELI_HOVERATTACK2_WAITLOOK;

			AI.SetRefPointPosition( entity.id, target:GetPos() );
			entity:SelectPipe( 0, "do_nothing");
			entity:SelectPipe( 0, "HeliMain");
			entity:InsertSubpipe( 0, "HeliLookatRef2" );

			self:HELI_HOVERATTACK2_WAITLOOK( entity );

		end

	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK2_WAITLOOK = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			if ( self:HELI_HOVERATTACK2_CHECKGOAWAY( entity, 200 ) == true ) then
				return;
			end

			local vTmp = {};
			CopyVector( vTmp, entity:GetDirectionVector(1) );
			vTmp.z = 0;
			NormalizeVector( vTmp );

			local vTmp2 = {};
			SubVectors( vTmp2, target:GetPos(), entity:GetPos() );
			vTmp2.z = 0;
			NormalizeVector( vTmp2 );

			if ( dotproduct3d( vTmp, vTmp2 ) > math.cos( 15.0 * 3.1416 / 180.0 ) and entity:GetSpeed() < 5.0 ) then
				AI.Signal(SIGNALFILTER_SENDER, 1, "HELI_HOVERATTACK2_NORMALDAMAGE_START", entity.id);
				return;			
			end

			local vHover = {};
			vHover.x = 0.0;
			vHover.y = 0.0; 
			vHover.z = 1.2; 

			AI.SetForcedNavigation( entity.id, vHover );

		end

	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK2_NORMALDAMAGE_START = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			entity.AI.circleSec = System.GetCurrTime();
			entity.AI.deltaT = System.GetCurrTime();
			entity.AI.bLock = false;

			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
			CopyVector( entity.AI.vTargetRsv, target:GetPos() );
			SubVectors( entity.AI.vDirectionRsv, target:GetPos(), entity:GetPos() );
			entity.AI.vDirectionRsv.z = 0;
			NormalizeVector( entity.AI.vDirectionRsv );

			entity.AI.CurrentHook = fHELI_HOVERATTACK2_NORMALDAMAGE;

			entity:SelectPipe( 0, "do_nothing");
			entity:SelectPipe( 0, "HeliMain");
			entity:InsertSubpipe( 0, "HeliResetLookat2" );

			self:HELI_HOVERATTACK2_NORMALDAMAGE( entity );

		end

	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK2_NORMALDAMAGE = function( self, entity )

		local vDirection = {};
		local vActuallDirection = {};
		local DirLen = 0;
		local ActuallLen = 0;
		
		local vVel = {};
		local vTmp = {};
		local vTmp2 = {};

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			SubVectors( vDirection, entity.AI.vTargetRsv, entity:GetPos() );
			vDirection.z = 0 ;
			DirLen = LengthVector( vDirection );
			NormalizeVector( vDirection );

			SubVectors( vActuallDirection, target:GetPos(), entity:GetPos() );
			vActuallDirection.z = 0 ;
			ActuallLen = LengthVector( vActuallDirection );
			NormalizeVector( vActuallDirection );

			local dot = dotproduct3d( vDirection, entity.AI.vDirectionRsv );

			if ( ActuallLen < 60.0 ) then
				FastScaleVector( vVel, vDirection, 20.0 );
				SubVectors( vTmp, target:GetPos(), entity:GetPos() );
				vTmp.z = vTmp.z + 10.0;
				vVel.z = vTmp.z/(40.0/20.0);
			else
				FastScaleVector( vVel, vDirection, 12.0 );
				SubVectors( vTmp, target:GetPos(), entity:GetPos() );
				if ( vTmp.z < -30.0 ) then
					vVel.z = 1.0;
				end
				if ( vTmp.z < -35.0 ) then
					vVel.z = -1.5;
				end
			end

			if ( ActuallLen < 15.0 or dot < 0.0 ) then
				AI.Signal(SIGNALFILTER_SENDER, 1, "HELI_HOVERATTACK2_NORMALDAMAGE2_START", entity.id);
				return;
			end

			if ( AIBehaviour.HELIDEFAULT:heliSetForcedNavigation( entity, vVel, 2.0, 3.0 )  < 0  ) then
				self:HELI_HOVERATTACK2_EMERGENCYSTOP_START( entity );
				return false;
			end

			AI.SetForcedNavigation( entity.id, vVel );

		end

	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK2_NORMALDAMAGE2_START = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			entity.AI.circleSec = System.GetCurrTime();
			entity.AI.deltaT = System.GetCurrTime();
			entity.AI.bLock = false;

			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
			CopyVector( entity.AI.vTargetRsv, target:GetPos() );

			local vTmp = {};
			CopyVector( vTmp, entity:GetDirectionVector(1) );
			vTmp.z = 0;
			NormalizeVector( vTmp );
			crossproduct3d( entity.AI.vDirectionRsv, vTmp, entity.AI.vUp );
			entity.AI.vDirectionRsv.z  = 0;
			NormalizeVector( entity.AI.vDirectionRsv );
			
			FastScaleVector( vTmp, entity:GetDirectionVector(1), 100.0 );
			FastSumVectors( vTmp, vTmp, entity:GetPos() );

			AI.SetRefPointPosition( entity.id, vTmp );
			entity:SelectPipe( 0, "do_nothing");
			entity:SelectPipe( 0, "HeliMain");
			entity:InsertSubpipe( 0, "devalue_target" );
			entity:InsertSubpipe( 0, "HeliLookatRef" );
			
			entity.AI.CurrentHook = fHELI_HOVERATTACK2_NORMALDAMAGE2;

			self:HELI_HOVERATTACK2_NORMALDAMAGE2( entity );

		end

	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK2_NORMALDAMAGE2 = function( self, entity )

			local sec = System.GetCurrTime() - entity.AI.circleSec;

			local vTmp = {};
			FastScaleVector( vTmp, entity.AI.vDirectionRsv, 16 );

			if ( sec > 3.0 ) then
				AI.Signal(SIGNALFILTER_SENDER, 1, "HELI_HOVERATTACK2_START", entity.id);
				return;
			end

			if ( AIBehaviour.HELIDEFAULT:heliSetForcedNavigation( entity, vTmp, 2.0, 3.0 )  < 0  ) then
				self:HELI_HOVERATTACK2_EMERGENCYSTOP_START( entity );
				return false;
			end

			AI.SetForcedNavigation( entity.id, vTmp );

	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK2_EVADELAW_START = function( self, entity, vec, vec2 )

			entity.AI.InterruptSec = System.GetCurrTime();
			entity.AI.bBlockSignal = true;
			
			local vTmp  = {};
			local vTmp2  = {};
			local vVel  = {};
			
			entity.AI.InterruptHook = fHELI_HOVERATTACK2_EVADELAW;

			NormalizeVector( vec );
			FastScaleVector( vTmp, vec, 20.0 );

			entity:GetVelocity( vVel );

			local assumSpeed = dotproduct3d( vVel, vTmp );

			if ( assumSpeed < 10.0 ) then
				FastScaleVector( vTmp, vec, 40.0 );
			end

			local vMyPos = {};
			CopyVector( vMyPos, entity:GetPos() );

			local height = AIBehaviour.HELIDEFAULT:heliSetForcedNavigation( entity, vTmp, 10.0, 2.0 );
			if ( height  < 0 ) then
				vTmp.z = vTmp.z * 0.5;
				height = AIBehaviour.HELIDEFAULT:heliSetForcedNavigation( entity, vTmp, 10.0, 2.0 );
				if ( height  < 0 ) then
					self:HELI_HOVERATTACK2_RECOVERLOOKAT( entity );
					return false;
				end
			end

			if ( height > 0 ) then
				if ( vMyPos.z > height ) then
					vTmp.z = vTmp.z * -1.0;
				else
					vTmp.z = (height - vMyPos.z )/2.0 ;
				end
			end

			AI.SetForcedNavigation( entity.id, vTmp );


			FastScaleVector( vTmp, vTmp, 2.0 );
			FastSumVectors( vTmp, vTmp, entity:GetPos() )
			System.DrawLine( vMyPos, vTmp, 1,1,1,1);



			FastScaleVector( vTmp, entity:GetDirectionVector(1), 100.0 );
			FastSumVectors( vTmp, vTmp, entity:GetPos() )


			AI.SetRefPointPosition( entity.id, vTmp );
			entity:SelectPipe( 0, "do_nothing");
			entity:SelectPipe( 0, "HeliMain");
			entity:InsertSubpipe( 0, "HeliLookatRef2" );
			entity:InsertSubpipe( 0, "devalue_target" );
	
			self:HELI_HOVERATTACK2_EVADELAW( entity );


	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK2_EVADELAW = function( self, entity )

		local sec = System.GetCurrTime() - entity.AI.InterruptSec;


		if ( sec > 1.9 or entity:GetSpeed() > 20.0 ) then

			local vTmp = {};

			vTmp.x = 0.0;			
			vTmp.y = 0.0;			
			vTmp.z = 1.2;

			AI.SetForcedNavigation( entity.id, vTmp );
			self:HELI_HOVERATTACK2_RECOVERLOOKAT( entity );
			
	--	if ( entity:GetSpeed() < 10.0 ) then	
	--	end

		end


	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK2_PATHATTACK_START = function( self, entity )

		if ( self:HELI_HOVERATTACK2_CHECKTARGET( entity )> 0 ) then
			return;
		end

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			entity.AI.circleSec = System.GetCurrTime();
			entity.AI.deltaT = System.GetCurrTime();
			entity.AI.bLock = false;

			if ( random(1,3)==2 ) then
				if ( entity.AI.bRotDirec == false ) then
					entity.AI.bRotDirec = true;
				else
					entity.AI.bRotDirec = false;
				end
			end

			CopyVector( entity.AI.vTargetRsv, target:GetPos() );
			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
			entity.AI.CurrentHook = fHELI_HOVERATTACK2_PATHATTACK;

			entity.AI.minZ = entity.AI.vTargetRsv.z + 20.0;

			entity:SelectPipe( 0, "do_nothing");
			entity:SelectPipe( 0, "HeliMain");
			entity:InsertSubpipe( 0, "HeliResetLookat2" );

			self:HELI_HOVERATTACK2_PATHATTACK( entity );

		end

	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK2_PATHATTACK = function( self, entity )

		local vVel = {};
		local vVelRot = {};
		local vWng = {};
		local vFwd = {};
		local vDist = {};

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			if ( self:HELI_HOVERATTACK2_CHECKGOAWAY( entity, 200 ) == true ) then
				return;
			end

			SubVectors( vDist, target:GetPos(), entity:GetPos() );
			vDist.z =0;

			SubVectors( vFwd, target:GetPos(), entity:GetPos() );
			vFwd.z = 0;
			NormalizeVector( vFwd );

			CopyVector( vWng, entity:GetDirectionVector(0) );

			CopyVector( vVel, entity:GetDirectionVector(1) );
			vVel.z =0;
			NormalizeVector( vVel );

			local vActualVel = {};
			entity:GetVelocity( vActualVel );
			NormalizeVector( vActualVel );

			local dot = dotproduct3d( vFwd, vWng );
			local dot2 = dotproduct3d( vFwd, vVel );
			local dot3 = dotproduct3d( entity:GetDirectionVector(1), vActualVel );
			
			if ( dot3 < 0 ) then
				dot3 = 0;
			end			

			local deltaT = System.GetCurrTime() -  entity.AI.deltaT;
			if (deltaT > 1.0 ) then
				deltaT = 1.0;
			end
			entity.AI.deltaT = System.GetCurrTime();

			FastScaleVector( vVel, vVel, 20.0 );
			CopyVector( vVelRot, vVel );

			local actionAngle = math.acos( dot2 );
			if ( actionAngle > 3.1416* 30.0 / 180.0 ) then
				actionAngle = 3.1416* 30.0 / 180.0;
			end

			if ( entity.AI.bRotDirec == false ) then -- right turn
					RotateVectorAroundR( vVelRot, vVel, entity.AI.vUp, actionAngle * deltaT );
			else
					RotateVectorAroundR( vVelRot, vVel, entity.AI.vUp, actionAngle * deltaT );
			end				

			if ( dot2 >  math.cos( 30.0 * 3.1416 * deltaT / 180.0  ) ) then
				if ( random(1,256) < 80 ) then
					AI.Signal(SIGNALFILTER_SENDER,1,"HELI_HOVERATTACK2_ADVANCE_START", entity.id);
				else
					AI.Signal(SIGNALFILTER_SENDER,1,"HELI_HOVERATTACK2_GOAWAY_START", entity.id);
				end
				return;
			end

			if ( math.abs( dot ) >  math.cos( 60.0 * 3.1416 / 180.0  ) ) then
				if ( LengthVector( vDist ) < 50.0 ) then
					if ( random(1,256) < 80 ) then
						AI.Signal(SIGNALFILTER_SENDER,1,"HELI_HOVERATTACK2_ADVANCE_START", entity.id);
					else
						AI.Signal(SIGNALFILTER_SENDER,1,"HELI_HOVERATTACK2_GOAWAY_START", entity.id);
					end
					return;
				end
			end

			local vMyPos = {};
			local vTargetPos = {};

			CopyVector( vMyPos, entity:GetPos() );
			CopyVector( vTargetPos, target:GetPos() );

			local ofs = (1.0 - dot3) * 5.0;
			vVelRot.z = ofs;

			entity.AI.deltaT = System.GetCurrTime();

			local height = AIBehaviour.HELIDEFAULT:heliSetForcedNavigation( entity, vVelRot, 10.0, 3.5 );
			if ( height < 0 ) then
				self:HELI_HOVERATTACK2_EMERGENCYSTOP_START( entity );
				return false;
			end

			AIBehaviour.HELIDEFAULT:heliUpdateMinZ( entity, vVelRot, height, 3.0 );
			AIBehaviour.HELIDEFAULT:heliStickToMinZ( entity, vVelRot );

			AI.SetForcedNavigation( entity.id, vVelRot );

		end

	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK2_GOAWAY_START = function( self, entity )

		if ( self:HELI_HOVERATTACK2_CHECKTARGET( entity )> 0 ) then
			return;
		end

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			entity.AI.circleSec = System.GetCurrTime();
			entity.AI.deltaT = System.GetCurrTime();
			entity.AI.bLock = false;
			entity.AI.goAwayLength = 30.0 + random( 0.0, 20.0 );

			CopyVector( entity.AI.vTargetRsv, target:GetPos() );
			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
			entity.AI.CurrentHook = fHELI_HOVERATTACK2_GOAWAY;
			entity.AI.minZ = entity.AI.vTargetRsv.z + 20.0;

			self:HELI_HOVERATTACK2_GOAWAY( entity );



		end

	end,
	
	HELI_HOVERATTACK2_GOAWAY = function( self, entity )

		local vDist = {};
		local vVel = {};
		local vTmp = {};

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			SubVectors( vDist, entity.AI.vTargetRsv, entity:GetPos() );
			vDist.z =0;
			local length = LengthVector( vDist );
			NormalizeVector( vDist );

			SubVectors( vTmp, entity.AI.vTargetRsv, entity.AI.vMyPosRsv );
			vTmp.z =0;
			NormalizeVector( vTmp );
			FastScaleVector( vTmp, vTmp, 2.0 );

			CopyVector( vVel, entity:GetDirectionVector(1) );
			FastSumVectors( vVel, vVel, vTmp );
			vVel.z =0;
			NormalizeVector( vVel );

			local dotEnd = dotproduct3d( vVel, vDist );
			if ( length > entity.AI.goAwayLength and dotEnd < 0  ) then
				AI.Signal(SIGNALFILTER_SENDER,1,"HELI_HOVERATTACK2_PATHATTACK_START", entity.id);
				return;
			end

			SubVectors( vTmp, entity:GetPos(), entity.AI.vMyPosRsv );
			vTmp.z = 0;
			
			if ( LengthVector( vTmp ) > 250.0 ) then
				AI.Signal(SIGNALFILTER_SENDER,1,"HELI_HOVERATTACK2_ADVANCE_START", entity.id);
				return;
			end

			local cof;
			if ( dotEnd < 0  ) then
				cof = 25.0;
			else
				cof =  System.GetCurrTime() - entity.AI.circleSec;
				if ( cof > 3.0 ) then
					cof = 3.0;
				end
				cof = cof * 5 + 22.0;
			end

			FastScaleVector( vVel, vVel, cof );

			local height = AIBehaviour.HELIDEFAULT:heliSetForcedNavigation( entity, vVel, 10.0, 3.5 );
			if ( height < 0 ) then
				self:HELI_HOVERATTACK2_EMERGENCYSTOP_START( entity );
				return false;
			end

			AIBehaviour.HELIDEFAULT:heliUpdateMinZ( entity, vVel, height, 3.0 );
			AIBehaviour.HELIDEFAULT:heliStickToMinZ( entity, vVel );

			AI.SetForcedNavigation( entity.id, vVel );

		end


	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK2_SHOOTMISSILE_START = function( self, entity, myPos, enemyPos )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			CopyVector( entity.AI.vInterruptMyPosRsv, myPos );
			CopyVector( entity.AI.vInterruptTargetRsv, enemyPos );

			entity.AI.InterruptSec = System.GetCurrTime();
			entity.AI.InterruptHook = fHELI_HOVERATTACK2_SHOOTMISSILE;

			AI.SetRefPointPosition( entity.id, entity.AI.vInterruptTargetRsv );
			entity:SelectPipe( 0, "do_nothing");
			entity:SelectPipe( 0, "HeliMain");
			entity:InsertSubpipe( 0, "HeliLookatRef2");
			self:HELI_HOVERATTACK2_SHOOTMISSILE( entity );
			return;

		end

	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK2_SHOOTMISSILE = function( self, entity )

		local vDir = {};
		local vDir2 = {};

		SubVectors( vDir, entity.AI.vInterruptTargetRsv, entity:GetPos() );
		CopyVector( vDir2, entity:GetDirectionVector(1) );

		vDir.z =0;
		vDir2.z =0;

		NormalizeVector( vDir );
		NormalizeVector( vDir2 );
		local dot = dotproduct3d( vDir, vDir2 );

		if ( entity:GetSpeed() < 3.0 and dot > math.cos( 30.0 * 3.1416 / 180.0  ) ) then
			local vDir = {};
			local vResult = {};
			SubVectors( vDir, entity.AI.vInterruptTargetRsv, entity:GetPos() );
			NormalizeVector( vDir );
			FastScaleVector( vDir, vDir, 20.0 );
			CopyVector( vResult, AI.IsFlightSpaceVoidByRadius( entity:GetPos(), vDir, 8.0 ) );
			if ( LengthVector( vResult ) >0.0 ) then
			else
				self:HELI_HOVERATTACK2_SHOOTMISSILE2_START( entity ); 
				return;
			end
		end

		if (  entity:GetSpeed() < 3.0 ) then
			local sec = System.GetCurrTime() - entity.AI.InterruptSec;
			if ( sec > 5 ) then
				self:HELI_HOVERATTACK2_RECOVERLOOKAT( entity );
				return;
			end
		end

		local vPos = {}
		vPos.x = 0.0;
		vPos.y = 0.0;
		vPos.z = -0.5;

		local height = AIBehaviour.HELIDEFAULT:heliSetForcedNavigation( entity, vPos, 5.0, 3.0 );
		if ( height < 0 ) then
			self:HELI_HOVERATTACK2_RECOVERLOOKAT( entity );
			return;
		end

		AI.SetForcedNavigation( entity.id, vPos );

	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK2_SHOOTMISSILE2_START = function( self, entity )

		entity.AI.InterruptSec = System.GetCurrTime();
		entity.AI.InterruptHook = fHELI_HOVERATTACK2_SHOOTMISSILE2;

		local vPos = {};
		CopyVector( vPos, entity.AI.vInterruptMyPosRsv );
		AIBehaviour.HELIDEFAULT:GetAimingPosition2( entity, vPos, entity.AI.vInterruptTargetRsv );
		SubVectors( vPos, vPos, entity:GetPos() );

		SubVectors( entity.AI.vInterruptDirectionRsv, entity.AI.vInterruptTargetRsv, entity.AI.vInterruptMyPosRsv );
		entity.AI.vInterruptDirectionRsv.z =0;
		FastSumVectors( entity.AI.vInterruptDirectionRsv, entity.AI.vInterruptDirectionRsv, vPos );

		NormalizeVector( entity.AI.vInterruptDirectionRsv );
		FastScaleVector( entity.AI.vInterruptDirectionRsv, entity.AI.vInterruptDirectionRsv, 15.0 );
		AI.ChangeParameter( entity.id, AIPARAM_ACCURACY, 1 );
		AI.SetRefPointPosition( entity.id, entity.AI.vInterruptTargetRsv );
		entity:SelectPipe( 0, "do_nothing");
		entity:SelectPipe( 0, "HeliMain");
		entity:InsertSubpipe( 0, "HeliLookatRef2");
		entity:InsertSubpipe( 0, "HeliFireStartRef" );
		AI.SetForcedNavigation( entity.id, entity.AI.vInterruptDirectionRsv );

		self:HELI_HOVERATTACK2_SHOOTMISSILE2( entity );


	end,

	HELI_HOVERATTACK2_SHOOTMISSILE2 = function( self, entity )

		local height = AIBehaviour.HELIDEFAULT:heliSetForcedNavigation( entity, entity.AI.vInterruptDirectionRsv, 5.0, 1.0 );

		local vPos = {};
		CopyVector( vPos, entity:GetPos() );

		if ( height < 0 or height > vPos.z  ) then
			self:HELI_HOVERATTACK2_RECOVERLOOKAT( entity );
			AI.ChangeParameter( entity.id, AIPARAM_ACCURACY, entity.Properties.accuracy );
			return;
		end

		local sec = System.GetCurrTime() - entity.AI.InterruptSec;
		if ( sec > 2.0 ) then
			self:HELI_HOVERATTACK2_RECOVERLOOKAT( entity );
			AI.ChangeParameter( entity.id, AIPARAM_ACCURACY, entity.Properties.accuracy );
			return;
		end

	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK2_EMERGENCYSTOP_START = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			entity.AI.circleSec = System.GetCurrTime();
			entity.AI.deltaT = System.GetCurrTime();
			entity.AI.bLock = false;
			entity.AI.goAwayLength = 30.0 + random( 0.0, 20.0 );

			CopyVector( entity.AI.vTargetRsv, target:GetPos() );
			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
			entity.AI.CurrentHook = fHELI_HOVERATTACK2_EMERGENCYSTOP;

			entity.AI.minZ = entity.AI.vMyPosRsv.z;

			entity:SelectPipe( 0, "do_nothing");
			entity:SelectPipe( 0, "HeliMain");
			entity:InsertSubpipe( 0, "HeliLookat" );

			local vVel = {};
			local vDir = {};
			entity:GetVelocity( vVel );
			vVel.z = 0;
			NormalizeVector( vVel );
			FastScaleVector( vDir, vVel, -1.0 );
			
			local speed = entity:GetSpeed();
			entity:AddImpulse( -1, entity:GetCenterOfMassPos(), vDir, entity:GetMass()*speed*0.5, 1 );	

			if ( speed < 5.0 ) then
				SubVectors( vVel, target:GetPos(), entity:GetPos() );
				vVel.z = 0;	
				NormalizeVector( vVel );					
			end

			FastScaleVector( entity.AI.vDirectionRsv, vVel, -5.0 );
			local vTmp = { x=0.0, y=0.0, z =1.0 };
			AI.SetForcedNavigation( entity.id, vTmp );

		end

	end,

	HELI_HOVERATTACK2_EMERGENCYSTOP = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			if ( entity.AI.bLock == true ) then
	
				local vTmp = {};
				local vVel = {};

				FastScaleVector( vTmp, entity.AI.vDirectionRsv, 10.0 );

				local height = AIBehaviour.HELIDEFAULT:heliSetForcedNavigation( entity, vTmp, 5.0, 3.0 );
				if ( height < 0 ) then
		
				else
					AIBehaviour.HELIDEFAULT:heliUpdateMinZ( entity, vTmp, height, 3.0 );
					AIBehaviour.HELIDEFAULT:heliStickToMinZ( entity, vTmp );
				end
		
		
				AI.SetForcedNavigation( entity.id, vTmp );
	
				if ( System.GetCurrTime() - entity.AI.circleSec > 5.0 ) then
					if ( entity.AI.rotateDirection == true ) then
						entity.AI.rotateDirection = false;
					else
						entity.AI.rotateDirection = true;
					end
					AI.Signal(SIGNALFILTER_SENDER,1,"HELI_HOVERATTACK2_START", entity.id);
					return;
				end

				CopyVector( vVel, entity.AI.vDirectionRsv );
				local height = AIBehaviour.HELIDEFAULT:heliSetForcedNavigation( entity, vVel, 10.0, 3.0 );
				if ( height < 0 ) then
		
				else
					AIBehaviour.HELIDEFAULT:heliUpdateMinZ( entity, vVel, height, 3.0 );
					AIBehaviour.HELIDEFAULT:heliStickToMinZ( entity, vVel );
				end
		
				vVel.z = vVel.z + 1.0;
				AI.SetForcedNavigation( entity.id, vVel );
		
			else
		
				local vTmp = {};
				local vTmp2 = {};
				local vMyPos = {};

				CopyVector( vMyPos, entity:GetPos() );

				if ( System.GetCurrTime() - entity.AI.circleSec > 3.0 ) then

					for i = 1,6 do	

						RotateVectorAroundR( vTmp, entity.AI.vDirectionRsv, entity.AI.vUp, -3.1416* 30.0 * i / 180.0 );
						FastScaleVector( vTmp2, vTmp, 5.0 );
						hight = AIBehaviour.HELIDEFAULT:heliSetForcedNavigation( entity, vTmp2, 5.0, 5.0 );
						if ( hight < 0 ) then
						elseif ( hight > vMyPos.z ) then
						else
							bFlg = true;
							CopyVector( entity.AI.vDirectionRsv, vTmp);
							break;
						end

						RotateVectorAroundR( vTmp, entity.AI.vDirectionRsv, entity.AI.vUp, 3.1416* 30.0 * i / 180.0 );
						FastScaleVector( vTmp2, vTmp, 5.0 );
						hight = AIBehaviour.HELIDEFAULT:heliSetForcedNavigation( entity, vTmp2, 5.0, 5.0 );
						if ( hight < 0 ) then
						elseif ( hight > vMyPos.z ) then
						else
							bFlg = true;
							CopyVector( entity.AI.vDirectionRsv, vTmp);
							break;
						end

					end
					
					if ( bFlg == true ) then
						entity.AI.circleSec = System.GetCurrTime();
						entity.AI.bLock = true;
						self:HELI_HOVERATTACK2_EMERGENCYSTOP( entity );
						return;
					end

				end

				vTmp.x =0;
				vTmp.y =0;
				vTmp.z =1.0;

				AI.SetForcedNavigation( entity.id, entity.AI.vZero );
		
			end
		
		end
		
	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK2_VSCLOAK_START = function( self, entity )

		if ( self:HELI_HOVERATTACK2_CHECKTARGET( entity )> 0 ) then
			return;
		end

		AIBehaviour.HELIDEFAULT:heliRequest2ndGunnerStopShoot( entity );

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			entity.AI.CurrentHook = fHELI_HOVERATTACK2_VSCLOAK;
			entity.AI.bCircledHalf = false;
			entity.AI.circleSec = System.GetCurrTime();

			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
			CopyVector( entity.AI.vTargetRsv, target:GetPos() );

			entity:SelectPipe( 0, "do_nothing");
			entity:SelectPipe( 0, "HeliMain");
			entity:InsertSubpipe( 0, "HeliResetLookat2" );

			entity.AI.minZ = entity.AI.vTargetRsv.z + 20.0;

			self:HELI_HOVERATTACK2_VSCLOAK( entity );

		end

	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK2_VSCLOAK = function( self, entity )

		local bClockedTarget = false;

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then
			if ( AI.GetTargetType( entity.id ) == AITARGET_MEMORY ) then
				if ( target.actor and target.actor:GetNanoSuitMode() == 2 ) then
					bClockedTarget = true;
				end
			end
		end
		
		if ( bClockedTarget==false ) then
			if ( System.GetCurrTime() - entity.AI.circleSec > 3.0 ) then
				self:HELI_HOVERATTACK2_START( entity );
				return;
			end
		end
		
		if ( System.GetCurrTime() - entity.AI.circleSec < 3.0 ) then
			AI.SetForcedNavigation( entity.id, entity.AI.vZero );
			return;
		end
		
		local vWng = {};
		local vWngR = {};
		local vFwd = {};

		local vTargetPos = {};
		local vMyPos = {};

		CopyVector( vTargetPos, entity.AI.vTargetRsv );
		CopyVector( vMyPos, entity:GetPos() );

		local vTmp = {};
		local vTmp2 = {};

		SubVectors( vTmp, entity.AI.vTargetRsv, entity:GetPos() );
		vTmp.z =0;
		NormalizeVector( vTmp );

		SubVectors( vTmp2, entity.AI.vTargetRsv, entity.AI.vMyPosRsv );
		vTmp2.z =0;
		NormalizeVector( vTmp2 );

		local vDist = {};
		SubVectors( vDist, entity.AI.vTargetRsv, entity:GetPos() );
		vDist.z =0;

		SubVectors( vFwd, entity.AI.vTargetRsv, entity:GetPos() );
		NormalizeVector( vFwd );
		crossproduct3d( vWng, vFwd, entity.AI.vUp );
		vWng.z = 0;
		if ( entity.AI.rotateDirection == false ) then
			FastScaleVector( vWng, vWng, -30.0 );
		end

		NormalizeVector( vWng );
		FastScaleVector( vWng, vWng, 30.0 );
		FastSumVectors( vWng, vWng, entity:GetPos() );

		SubVectors( vFwd, vWng , entity.AI.vTargetRsv  );
		NormalizeVector( vFwd );
		FastScaleVector( vFwd, vFwd, 30.0 );
		FastSumVectors( vFwd, vFwd, entity.AI.vTargetRsv );
		SubVectors( vFwd, vFwd, entity:GetPos() );
		NormalizeVector( vFwd );
		FastScaleVector( vFwd, vFwd, 12.0 );

		local height = AIBehaviour.HELIDEFAULT:heliSetForcedNavigation( entity, vFwd, 5.0, 3.5 )
		if ( height < 0  ) then
			self:HELI_HOVERATTACK2_EMERGENCYSTOP_START( entity );
			return false;
		end

		AIBehaviour.HELIDEFAULT:heliUpdateMinZ( entity, vFwd, height, 2.0 );
		AIBehaviour.HELIDEFAULT:heliStickToMinZ( entity, vFwd );

		AI.SetForcedNavigation( entity.id, vFwd );

	end,

}

