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

local		fHELI_HOVERATTACK3_DONOTHING			= 0;
local 	fHELI_HOVERATTACK3_GETDAMAGESMALL = 1;
local 	fHELI_HOVERATTACK3_EVADELAW				= 13;
local 	fHELI_HOVERATTACK3_SHOOTMISSILE		= 16;
local 	fHELI_HOVERATTACK3_SHOOTMISSILE2	= 17;
local 	fHELI_HOVERATTACK3_EMERGENCYSTOP	= 18;
local 	fHELI_HOVERATTACK3_ADVANCE				= 19;
local		fHELI_HOVERATTACK3_GOOVERVEHICLE  = 20;
local		fHELI_HOVERATTACK3_GOOVERVEHICLE2 = 21;
local		fHELI_HOVERATTACK3_GOOVERVEHICLE3 = 22;
local		fHELI_HOVERATTACK3_HIDE						= 24;
local   fHELI_HOVERATTACK3_HIDE2					= 25;
local   fHELI_HOVERATTACK3_HIDE3					= 26;
local		fHELI_HOVERATTACK3_JUSTWAIT 			= 27;
local		fHELI_HOVERATTACK3_GOOVERBOAT			= 28;
local		fHELI_HOVERATTACK3_GOOVERBOAT2		= 29;
local		fHELI_HOVERATTACK3_GOOVERBOAT3		= 30;

AIBehaviour.HeliHoverAttack3 = {
	Name = "HeliHoverAttack3",
	Base = "HeliBase",

	alertness = 2,

	--------------------------------------------------------------------------
	Constructor = function ( self, entity, data )

		-- for signals
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

		entity.AI.heliTimer3 = 1;
		Script.SetTimerForFunction( minUpdateTime *1000, "AIBehaviour.HeliHoverAttack3.HELI_HOVERATTACK3_UPDATE", entity );

		entity.AI.circleSec = System.GetCurrTime();
		entity.AI.deltaT = System.GetCurrTime();
		entity.AI.deltaTSystem = System.GetCurrTime();
		entity.AI.vMyPosRsv = {};
		entity.AI.vTargetRsv = {};
		entity.AI.vDirectionRsv = {};
		entity.AI.vIdealVel = {};
		entity.AI.vBoatTarget = {};

		entity.AI.CurrentHook = 0;
		entity.AI.InterruptHook = 0;
		entity.AI.InterruptSec = System.GetCurrTime();
		entity.AI.vInterruptMyPosRsv = {};
		entity.AI.vInterruptTargetRsv = {};
		entity.AI.vInterruptDirectionRsv = {};
		entity.AI.Lastentityid = entity.id;

		entity.AI.vRefRsv = {};
		entity.AI.lookatPattern = 0;
		entity.AI.bRotDirec = false;
		entity.AI.resetLookAt = false;

		entity.AI.lastShooterId = nil;
		entity.AI.rotateDirection = false;
		entity.AI.tmpVal = 0.0;
		entity.AI.pathName = nil;

		CopyVector( entity.AI.vBoatTarget, entity:GetPos() );

		AI.CreateGoalPipe("heliHoverAttackDefault");
		AI.PushGoal("heliHoverAttackDefault","timeout",1,0.3);
		AI.PushGoal("heliHoverAttackDefault","signal",0,1,"HELI_HOVERATTACK3_GOOVERVEHICLE_START",SIGNALFILTER_SENDER);
		
		entity:SelectPipe(0,"heliHoverAttackDefault");

		AI.CreateGoalPipe("HeliMain");
		AI.PushGoal("HeliMain","+timeout",1,1);
		AI.CreateGoalPipe("HeliMain2");
		AI.PushGoal("HeliMain2","+timeout",1,1);

		AI.CreateGoalPipe("HeliLookat");
		AI.PushGoal("HeliLookat","locate",0,"atttarget");
		AI.PushGoal("HeliLookat","lookat",0,0,0,true,1);
		AI.PushGoal("HeliLookat","signal",1,1,"HELI_HOVERATTACK3_SETLOOKATATT",SIGNALFILTER_SENDER);

		AI.CreateGoalPipe("HeliLookat2");
		AI.PushGoal("HeliLookat","locate",0,"atttarget");
		AI.PushGoal("HeliLookat","lookat",0,0,0,true,1);
		AI.PushGoal("HeliLookat","signal",1,1,"HELI_HOVERATTACK3_SETLOOKATATT",SIGNALFILTER_SENDER);

		AI.CreateGoalPipe("HeliLookatRef");
		AI.PushGoal("HeliLookatRef","locate",0,"refpoint");
		AI.PushGoal("HeliLookatRef","lookat",0,0,0,true,1);
		AI.PushGoal("HeliLookatRef","signal",1,1,"HELI_HOVERATTACK3_SETLOOKATREF",SIGNALFILTER_SENDER);

		AI.CreateGoalPipe("HeliLookatRef2");
		AI.PushGoal("HeliLookatRef2","locate",0,"refpoint");
		AI.PushGoal("HeliLookatRef2","lookat",0,0,0,true,1);

		AI.CreateGoalPipe("HeliResetLookat");
		AI.PushGoal("HeliResetLookat","locate",0,"");
		AI.PushGoal("HeliResetLookat","lookat",0,-500,0);
		AI.PushGoal("HeliResetLookat","signal",1,1,"HELI_HOVERATTACK3_REFSETLOOKAT",SIGNALFILTER_SENDER);

		AI.CreateGoalPipe("HeliResetLookat2");
		AI.PushGoal("HeliResetLookat2","locate",0,"");
		AI.PushGoal("HeliResetLookat2","lookat",0,-500,0);
		AI.PushGoal("HeliResetLookat2","signal",1,1,"HELI_HOVERATTACK3_REFSETLOOKAT",SIGNALFILTER_SENDER);

		AI.CreateGoalPipe("HeliFireStart");
		AI.PushGoal("HeliFireStart","firecmd",0,FIREMODE_CONTINUOUS);

		AI.CreateGoalPipe("HeliFireStop");
		AI.PushGoal("HeliFireStop","firecmd",0,0);

	end,
	
	---------------------------------------------
	Destructor = function ( self, entity, data )

		-- called when the behaviour is de-selected
		-- the extra data is from the signal that is causing the behavior transition

		entity:SelectPipe(0,"do_nothing");
		AI.SetForcedNavigation( entity.id, entity.AI.vZero );
		if ( entity.AI.heliTimer3 ~= nil ) then
			entity.AI.heliTimer3 = nil;
		end
	end,

	TO_HELI_EMERGENCYLANDING = function( self, entity, sender, data )
	end,
	HELI_HOVERATTACK3_SETLOOKATATT = function ( self, entity )
		entity.AI.lookatPattern = 1;
	end,
	HELI_HOVERATTACK3_SETLOOKATREF = function ( self, entity )
		entity.AI.lookatPattern = 2;
		CopyVector( entity.AI.vRefRsv, AI.GetRefPointPosition(entity.id) );
	end,
	HELI_HOVERATTACK3_REFSETLOOKAT = function ( self, entity )
		entity.AI.lookatPattern = 0;
	end,

	HELI_HOVERATTACK3_RECOVERLOOKAT = function ( self, entity )
		entity.AI.bBlockSignal = false;
		entity.AI.resetLookAt = true;
	end,

	HELI_HOVERATTACK3_RECOVERLOOKAT_MAIN = function ( self, entity )

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

	 	if ( entity.AI.CurrentHook == fHELI_HOVERATTACK3_GOOVERVEHICLE2 ) then
	 		if ( random( 1, 100 ) > 50.0 ) then
		 		AI.Signal(SIGNALFILTER_SENDER,1,"HELI_HOVERATTACK3_GOOVERVEHICLE", entity.id);
		 	else
		 		AI.Signal(SIGNALFILTER_SENDER,1,"HELI_HOVERATTACK3_GOOVERVEHICLE3", entity.id);
		 	end
		end

	end,

	HELI_HOVERATTACK3_CHECKTARGET = function ( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			if ( AI.GetTypeOf( target.id ) == AIOBJECT_VEHICLE ) then
				AI.SetExtraPriority( target.id , 100.0 );
			elseif (  AI.GetTypeOf( target.id ) == AIOBJECT_PUPPET or AI.GetTypeOf( target.id ) == AIOBJECT_PLAYER ) then
				local objects = {};
				local numVehile = AI.GetNearestEntitiesOfType( target:GetPos(), AIOBJECT_VEHICLE, 10, objects, 0, 400.0 );
				if ( numVehile > 0 ) then
					local i;
					for i = 1,numVehile do
						local objEntity = System.GetEntity( objects[i].id );
						if ( objEntity and objEntity.AIMovementAbility.pathType == AIPATH_TANK ) then
							if ( objEntity  and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, objEntity )==true ) then
								AI.SetExtraPriority( objEntity .id , 100.0 );
								AI.Signal(SIGNALFILTER_SENDER, 1, "HELI_HOVERATTACK3_JUSTWAIT_START", entity.id);
								return 1;
							end
						end
						if ( objEntity and objEntity.AIMovementAbility.pathType == AIPATH_BOAT ) then
							if ( objEntity  and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, objEntity )==true ) then
								AI.SetExtraPriority( objEntity .id , 100.0 );
								AI.Signal(SIGNALFILTER_SENDER, 1, "HELI_HOVERATTACK3_JUSTWAIT_START", entity.id);
								return 1;
							end
						end
					end
					AI.Signal(SIGNALFILTER_SENDER, 1, "TO_HELI_ATTACK", entity.id);
					return 2;
				else
					AI.Signal(SIGNALFILTER_SENDER, 1, "TO_HELI_ATTACK", entity.id);
					return 2;
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
			entity.AI.resetLookAt = true
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

		--[[
		if ( ratio - entity.AI.lastDamage > 0.1 or entity.AI.damageCount > 40 ) then
			if ( entity.AI.bBlockSignal == false ) then

				entity.AI.lastDamage = ratio;
				entity.AI.damageCount =0;
				AI.Signal(SIGNALFILTER_SENDER,1,"HELI_HOVERATTACK3_HIDE_START", entity.id);

			end
		end

		--]]

	end,

	---------------------------------------------
	HELI_HOVERATTACK3_GETPARTSDAMAGE = function ( self, entity, sender, data )

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
			entity.AI.bBlockSignal = true;
			self:HELI_HOVERATTACK3_GETDAMAGESMALL_START ( entity, targetEntity );
		else


		end

	end,


	------------------------------------------------------------------------------------------
	HELI_TAKE_EVADEACTION = function ( self, entity, sender, data )

		local targetEntity = System.GetEntity( g_localActor.id );

		if ( targetEntity ) then

			if ( entity.AI.bBlockSignal == false ) then

				if ( random( 0, 256 ) < 48 ) then

					AIBehaviour.HELIDEFAULT:heliTakeEvadeAction2( entity, "HELI_HOVERATTACK3_START", targetEntity );
					return;

				end

			end
		
			AIBehaviour.HELIDEFAULT:heliTakeEvadeAction( entity, "HELI_HOVERATTACK3_START", targetEntity );

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
						self:HELI_HOVERATTACK3_EVADELAW_START( entity, P2, P2 );
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
	HELI_HOVERATTACK3_UPDATE = function( entity )
	
		if ( entity.AI == nil or entity.AI.heliTimer3 == nil or entity:GetSpeed() == nil ) then
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
			
		if ( dt < minUpdateTime*0.25 ) then
			return;
		end

		entity.AI.heliTimer3 = 1;
		Script.SetTimerForFunction( minUpdateTime *1000, "AIBehaviour.HeliHoverAttack3.HELI_HOVERATTACK3_UPDATE", entity );

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then
		else
			AIBehaviour.HeliHoverAttack3:OnNoTarget( entity );
			return;
		end

		if ( entity.AI.bBlockSignal == false ) then
			if (     entity.AI.CurrentHook == fHELI_HOVERATTACK3_DONOTHING ) then
				AIBehaviour.HeliHoverAttack3:HELI_HOVERATTACK3_DONOTHING( entity );
				return;
			elseif ( entity.AI.CurrentHook == fHELI_HOVERATTACK3_GETDAMAGESMALL ) then
				AIBehaviour.HeliHoverAttack3:HELI_HOVERATTACK3_GETDAMAGESMALL( entity );
			elseif ( entity.AI.CurrentHook == fHELI_HOVERATTACK3_EVADELAW ) then
				AIBehaviour.HeliHoverAttack3:HELI_HOVERATTACK3_EVADELAW( entity );
			elseif ( entity.AI.CurrentHook == fHELI_HOVERATTACK3_SHOOTMISSILE2 ) then
				AIBehaviour.HeliHoverAttack3:HELI_HOVERATTACK3_SHOOTMISSILE2( entity );
			elseif ( entity.AI.CurrentHook == fHELI_HOVERATTACK3_EMERGENCYSTOP ) then
				AIBehaviour.HeliHoverAttack3:HELI_HOVERATTACK3_EMERGENCYSTOP( entity );
			elseif ( entity.AI.CurrentHook == fHELI_HOVERATTACK3_ADVANCE ) then
				AIBehaviour.HeliHoverAttack3:HELI_HOVERATTACK3_ADVANCE( entity );
			elseif ( entity.AI.CurrentHook == fHELI_HOVERATTACK3_GOOVERVEHICLE ) then
				AIBehaviour.HeliHoverAttack3:HELI_HOVERATTACK3_GOOVERVEHICLE( entity );
			elseif ( entity.AI.CurrentHook == fHELI_HOVERATTACK3_GOOVERVEHICLE2 ) then
				AIBehaviour.HeliHoverAttack3:HELI_HOVERATTACK3_GOOVERVEHICLE2( entity );
			elseif ( entity.AI.CurrentHook == fHELI_HOVERATTACK3_GOOVERVEHICLE3 ) then
				AIBehaviour.HeliHoverAttack3:HELI_HOVERATTACK3_GOOVERVEHICLE3( entity );
			elseif ( entity.AI.CurrentHook == fHELI_HOVERATTACK3_HIDE ) then
				AIBehaviour.HeliHoverAttack3:HELI_HOVERATTACK3_HIDE( entity );
			elseif ( entity.AI.CurrentHook == fHELI_HOVERATTACK3_HIDE2 ) then
				AIBehaviour.HeliHoverAttack3:HELI_HOVERATTACK3_HIDE2( entity );
			elseif ( entity.AI.CurrentHook == fHELI_HOVERATTACK3_HIDE3 ) then
				AIBehaviour.HeliHoverAttack3:HELI_HOVERATTACK3_HIDE3( entity );
			elseif ( entity.AI.CurrentHook == fHELI_HOVERATTACK3_JUSTWAIT ) then
				AIBehaviour.HeliHoverAttack3:HELI_HOVERATTACK3_JUSTWAIT( entity );
			elseif ( entity.AI.CurrentHook == fHELI_HOVERATTACK3_GOOVERBOAT ) then
				AIBehaviour.HeliHoverAttack3:HELI_HOVERATTACK3_GOOVERBOAT( entity );
			elseif ( entity.AI.CurrentHook == fHELI_HOVERATTACK3_GOOVERBOAT2 ) then
				AIBehaviour.HeliHoverAttack3:HELI_HOVERATTACK3_GOOVERBOAT2( entity );
			elseif ( entity.AI.CurrentHook == fHELI_HOVERATTACK3_GOOVERBOAT3 ) then
				AIBehaviour.HeliHoverAttack3:HELI_HOVERATTACK3_GOOVERBOAT3( entity );
			end
		else
			if (     entity.AI.InterruptHook == fHELI_HOVERATTACK3_DONOTHING ) then
				AIBehaviour.HeliHoverAttack3:HELI_HOVERATTACK3_DONOTHING( entity );
				return;
			elseif ( entity.AI.InterruptHook == fHELI_HOVERATTACK3_GETDAMAGESMALL ) then
				AIBehaviour.HeliHoverAttack3:HELI_HOVERATTACK3_GETDAMAGESMALL( entity );
			elseif ( entity.AI.InterruptHook == fHELI_HOVERATTACK3_EVADELAW ) then
				AIBehaviour.HeliHoverAttack3:HELI_HOVERATTACK3_EVADELAW( entity );
			elseif ( entity.AI.InterruptHook == fHELI_HOVERATTACK3_SHOOTMISSILE ) then
				AIBehaviour.HeliHoverAttack3:HELI_HOVERATTACK3_SHOOTMISSILE( entity );
			elseif ( entity.AI.InterruptHook == fHELI_HOVERATTACK3_SHOOTMISSILE2 ) then
				AIBehaviour.HeliHoverAttack3:HELI_HOVERATTACK3_SHOOTMISSILE2( entity );
			elseif ( entity.AI.InterruptHook == fHELI_HOVERATTACK3_EMERGENCYSTOP ) then
				AIBehaviour.HeliHoverAttack3:HELI_HOVERATTACK3_EMERGENCYSTOP( entity );
			elseif ( entity.AI.InterruptHook == fHELI_HOVERATTACK3_GOOVERVEHICLE ) then
				AIBehaviour.HeliHoverAttack3:HELI_HOVERATTACK3_GOOVERVEHICLE( entity );
			elseif ( entity.AI.InterruptHook == fHELI_HOVERATTACK3_GOOVERVEHICLE2 ) then
				AIBehaviour.HeliHoverAttack3:HELI_HOVERATTACK3_GOOVERVEHICLE2( entity );
			elseif ( entity.AI.InterruptHook == fHELI_HOVERATTACK3_GOOVERVEHICLE3 ) then
				AIBehaviour.HeliHoverAttack3:HELI_HOVERATTACK3_GOOVERVEHICLE3( entity );
			elseif ( entity.AI.InterruptHook == fHELI_HOVERATTACK3_HIDE ) then
				AIBehaviour.HeliHoverAttack3:HELI_HOVERATTACK3_HIDE( entity );
			elseif ( entity.AI.InterruptHook == fHELI_HOVERATTACK3_HIDE2 ) then
				AIBehaviour.HeliHoverAttack3:HELI_HOVERATTACK3_HIDE2( entity );
			elseif ( entity.AI.InterruptHook == fHELI_HOVERATTACK3_HIDE3 ) then
				AIBehaviour.HeliHoverAttack3:HELI_HOVERATTACK3_HIDE3( entity );
			elseif ( entity.AI.InterruptHook == fHELI_HOVERATTACK3_JUSTWAIT ) then
				AIBehaviour.HeliHoverAttack3:HELI_HOVERATTACK3_JUSTWAIT( entity );
			elseif ( entity.AI.InterruptHook == fHELI_HOVERATTACK3_GOOVERBOAT ) then
				AIBehaviour.HeliHoverAttack3:HELI_HOVERATTACK3_GOOVERBOAT( entity );
			elseif ( entity.AI.InterruptHook == fHELI_HOVERATTACK3_GOOVERBOAT2 ) then
				AIBehaviour.HeliHoverAttack3:HELI_HOVERATTACK3_GOOVERBOAT2( entity );
			elseif ( entity.AI.InterruptHook == fHELI_HOVERATTACK3_GOOVERBOAT3 ) then
				AIBehaviour.HeliHoverAttack3:HELI_HOVERATTACK3_GOOVERBOAT3( entity );
			end
		end

		if ( entity.AI.resetLookAt == true ) then
			entity.AI.resetLookAt = false;
			AIBehaviour.HeliHoverAttack3:HELI_HOVERATTACK3_RECOVERLOOKAT_MAIN( entity );
		end

	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK3_DONOTHING = function( self, entity )
	
	end,


	--------------------------------------------------------------------------
	HELI_HOVERATTACK3_GETDAMAGESMALL_START = function ( self, entity, targetEntity )

		entity.AI.InterruptHook = fHELI_HOVERATTACK3_GETDAMAGESMALL;
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
		
		local bDir = AIBehaviour.HELIDEFAULT:GetIdealWng2( entity, vWng, 40.0, vFwd ); --targetEntity:GetPos() );

		if ( bDir == false ) then
			CopyVector( vWngUnit, vWng );
			vWngUnit.z = 0;
			NormalizeVector( vWngUnit );
			entity:GetVelocity( vVel );
			vVel.z = 0;
			NormalizeVector( vVel );

			local dot = dotproduct3d( vWngUnit, vVel );

		--			if ( dot > 0 ) then
						FastScaleVector( vWng, vWng, -1.0 );
		--			end

		end

		SubVectors( vFwd, targetEntity:GetPos(), entity:GetPos() );
		local zDef = -vFwd.z;

		if ( zDef < 40.0 ) then

			vWng.z = vWng.z + random( 10, 15 );
			
		else

			vWng.z = vWng.z + random( -7, -3 );
		
		end

		NormalizeVector( vWng );
		FastScaleVector( entity.AI.vIdealVel, vWng, 25.0 );

		AI.SetRefPointPosition( entity.id, targetEntity:GetPos() );
		entity:SelectPipe( 0, "do_nothing");
		entity:SelectPipe( 0, "HeliMain");
		entity:InsertSubpipe( 0, "HeliLookatRef2" );

		self:HELI_HOVERATTACK3_GETDAMAGESMALL( entity );

	end,
	
	HELI_HOVERATTACK3_GETDAMAGESMALL = function ( self, entity )

		local vWng = {};
		local vVel = {};
		
		entity:GetVelocity( vVel );
		
		CopyVector( vWng, entity.AI.vIdealVel );

		if ( AIBehaviour.HELIDEFAULT:heliSetForcedNavigation( entity, vWng, 5.0, 3.0 ) < 0 ) then

			local targetEntity = System.GetEntity( entity.AI.lastShooterId );
			local target = AI.GetAttentionTargetEntity( entity.id );
			if ( target and targetEntity and target.id == targetEntity.id ) then
				self:HELI_HOVERATTACK3_SHOOTMISSILE_START( entity, entity.AI.vInterruptMyPosRsv, entity.AI.vInterruptTargetRsv );
			else
				self:HELI_HOVERATTACK3_RECOVERLOOKAT( entity );
			end
			return false;
		end

		if ( LengthVector( vVel ) > 15.0 and System.GetCurrTime() - entity.AI.InterruptSec > 1.0 ) then
			local targetEntity = System.GetEntity( entity.AI.lastShooterId );
			local target = AI.GetAttentionTargetEntity( entity.id );
			if ( target and targetEntity and target.id == targetEntity.id ) then
				self:HELI_HOVERATTACK3_SHOOTMISSILE_START( entity, entity.AI.vInterruptMyPosRsv, entity.AI.vInterruptTargetRsv );
			else
				self:HELI_HOVERATTACK3_RECOVERLOOKAT( entity );
			end
			return;
		end

		AI.SetForcedNavigation( entity.id, vWng );

	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK3_EVADELAW_START = function( self, entity, vec, vec2 )

			entity.AI.InterruptSec = System.GetCurrTime();
			entity.AI.bBlockSignal = true;
			
			local vTmp  = {};
			local vTmp2  = {};
			local vVel  = {};
			
			entity.AI.InterruptHook = fHELI_HOVERATTACK3_EVADELAW;

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
					self:HELI_HOVERATTACK3_RECOVERLOOKAT( entity );
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
			entity:InsertSubpipe( 0, "HeliFireStart" );
	
			self:HELI_HOVERATTACK3_EVADELAW( entity );


	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK3_EVADELAW = function( self, entity )

		local sec = System.GetCurrTime() - entity.AI.InterruptSec;


		if ( sec > 1.9 or entity:GetSpeed() > 20.0 ) then

			local vTmp = {};

			vTmp.x = 0.0;			
			vTmp.y = 0.0;			
			vTmp.z = 1.2;

			AI.SetForcedNavigation( entity.id, vTmp );
			self:HELI_HOVERATTACK3_RECOVERLOOKAT( entity );
			
	--	if ( entity:GetSpeed() < 10.0 ) then	
	--	end

		end


	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK3_SHOOTMISSILE = function( self, entity )

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
			self:HELI_HOVERATTACK3_SHOOTMISSILE2_START( entity ); 
			return;
		end
		if (  entity:GetSpeed() < 3.0 ) then
			local sec = System.GetCurrTime() - entity.AI.InterruptSec;
			if ( sec > 5 ) then
				self:HELI_HOVERATTACK3_RECOVERLOOKAT( entity );
				return;
			end
		end

		local vPos = {}
		vPos.x = 0.0;
		vPos.y = 0.0;
		vPos.z = -0.5;

		local height = AIBehaviour.HELIDEFAULT:heliSetForcedNavigation( entity, vPos, 5.0, 3.0 );
		if ( height < 0 ) then
			self:HELI_HOVERATTACK3_RECOVERLOOKAT( entity );
			return;
		end

		AI.SetForcedNavigation( entity.id, vPos );

	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK3_SHOOTMISSILE2_START = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			entity.AI.InterruptSec = System.GetCurrTime();
			entity.AI.InterruptHook = fHELI_HOVERATTACK3_SHOOTMISSILE2;

			local vPos = {};
			CopyVector( vPos, entity.AI.vInterruptMyPosRsv );
			AIBehaviour.HELIDEFAULT:GetAimingPosition2( entity, vPos, entity.AI.vInterruptTargetRsv );
			SubVectors( vPos, vPos, entity:GetPos() );

			SubVectors( entity.AI.vInterruptDirectionRsv, entity.AI.vInterruptTargetRsv, entity.AI.vInterruptMyPosRsv );
			entity.AI.vInterruptDirectionRsv.z =0;
			FastSumVectors( entity.AI.vInterruptDirectionRsv, entity.AI.vInterruptDirectionRsv, vPos );

			NormalizeVector( entity.AI.vInterruptDirectionRsv );
			FastScaleVector( entity.AI.vInterruptDirectionRsv, entity.AI.vInterruptDirectionRsv, 15.0 );
			
			AI.SetRefPointPosition( entity.id, entity.AI.vInterruptTargetRsv );
			entity:SelectPipe( 0, "do_nothing");
			entity:SelectPipe( 0, "HeliMain");
			entity:InsertSubpipe( 0, "HeliLookatRef2");
			entity:InsertSubpipe( 0, "HeliFireStart" );

			AI.SetForcedNavigation( entity.id, entity.AI.vInterruptDirectionRsv );

			self:HELI_HOVERATTACK3_SHOOTMISSILE2( entity );

		end

	end,

	HELI_HOVERATTACK3_SHOOTMISSILE2 = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			local height = AIBehaviour.HELIDEFAULT:heliSetForcedNavigation( entity, entity.AI.vInterruptDirectionRsv, 5.0, 1.0 );

			local vPos = {};
			CopyVector( vPos, entity:GetPos() );

			if ( height < 0 or height > vPos.z  ) then
				entity:SelectPipe( 0, "do_nothing");
				entity:SelectPipe( 0, "HeliMain");
				entity:InsertSubpipe( 0, "HeliFireStop" );
				self:HELI_HOVERATTACK3_RECOVERLOOKAT( entity );
				return;
			end
	
			local sec = System.GetCurrTime() - entity.AI.InterruptSec;
			if ( sec > 2.0 ) then
				entity:SelectPipe( 0, "do_nothing");
				entity:SelectPipe( 0, "HeliMain");
				entity:InsertSubpipe( 0, "HeliFireStop" );
				self:HELI_HOVERATTACK3_RECOVERLOOKAT( entity );
				return;
			end

		end

	end,


	--------------------------------------------------------------------------
	HELI_HOVERATTACK3_JUSTWAIT_START = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			entity.AI.circleSec = System.GetCurrTime();
			CopyVector( entity.AI.vTargetRsv, target:GetPos() );
			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
			entity.AI.minZ = entity.AI.vTargetRsv.z + 35.0;
			entity.AI.tmpVal = 0;

			entity.AI.CurrentHook = fHELI_HOVERATTACK3_JUSTWAIT;

			entity:SelectPipe( 0, "do_nothing");
			entity:SelectPipe( 0, "HeliMain");
			entity:InsertSubpipe( 0, "HeliLookat" );

			self:HELI_HOVERATTACK3_JUSTWAIT( entity );
			
		end

	end,

	HELI_HOVERATTACK3_JUSTWAIT = function( self, entity )

		local vVel = {};
		entity:GetVelocity( vVel );
		vVel.z = 0;
		FastScaleVector( vVel, vVel, -0.95 );

		if ( System.GetCurrTime() - entity.AI.circleSec > 1.0 ) then
			entity.AI.tmpVal = entity.AI.tmpVal + 1;
			if ( entity.AI.tmpVal > 5 ) then
				AI.Signal(SIGNALFILTER_SENDER,1,"TO_HELI_ATTACK", entity.id);
				return;
			elseif ( self:HELI_HOVERATTACK3_CHECKTARGET( entity )> 0 ) then
				return;
			else
				entity.AI.circleSec = System.GetCurrTime();
				return;
			end
		end

		local height = AIBehaviour.HELIDEFAULT:heliSetForcedNavigation( entity, vVel, 1.0, 3.0 );
		if ( height < 0 ) then
			
		else
			AIBehaviour.HELIDEFAULT:heliUpdateMinZ( entity, vVel, height, 3.0 );
			AIBehaviour.HELIDEFAULT:heliStickToMinZ( entity, vVel );
		end

		AI.SetForcedNavigation( entity.id, vVel );

	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK3_EMERGENCYSTOP_START = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			entity.AI.circleSec = System.GetCurrTime();
			entity.AI.deltaT = System.GetCurrTime();
			entity.AI.bLock = false;
			entity.AI.goAwayLength = 30.0 + random( 0.0, 20.0 );

			CopyVector( entity.AI.vTargetRsv, target:GetPos() );
			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
			entity.AI.CurrentHook = fHELI_HOVERATTACK3_EMERGENCYSTOP;

			entity.AI.minZ = entity.AI.vMyPosRsv.z;

			entity:SelectPipe( 0, "do_nothing");
			entity:SelectPipe( 0, "HeliMain");
			entity:InsertSubpipe( 0, "HeliLookat" );

			self:HELI_HOVERATTACK3_EMERGENCYSTOP( entity );

		end

	end,

	HELI_HOVERATTACK3_EMERGENCYSTOP = function( self, entity )


		local vVel = {};
		entity:GetVelocity( vVel );
		vVel.z = 0;
		FastScaleVector( vVel, vVel, -0.95 );

		if ( LengthVector( vVel ) < 5.0 and System.GetCurrTime() - entity.AI.circleSec > 3.0 ) then

			local target = AI.GetAttentionTargetEntity( entity.id );
			if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

				CopyVector( entity.AI.vTargetRsv, target:GetPos() );
				CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
				SubVectors( entity.AI.vMyPosRsv, entity.AI.vTargetRsv, entity.AI.vMyPosRsv );
				NormalizeVector( entity.AI.vMyPosRsv );
				FastScaleVector( entity.AI.vMyPosRsv, entity.AI.vMyPosRsv, 5.0 );
				FastSumVectors( entity.AI.vMyPosRsv, entity.AI.vMyPosRsv, entity:GetPos() );
		
				AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, entity.AI.vMyPosRsv, 1 );
				AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, entity.AI.vTargetRsv, 2 );
		
				if ( AIBehaviour.HELIDEFAULT:heliCheckSpaceVoidMain( entity, 2, 5.0 ) ~= false ) then
					AI.Signal(SIGNALFILTER_SENDER,1,"HELI_HOVERATTACK3_GOOVERVEHICLE_START", entity.id);
					return;
				end

			end
		
		end

		local height = AIBehaviour.HELIDEFAULT:heliSetForcedNavigation( entity, vVel, 10.0, 3.0 );
		if ( height < 0 ) then
			return false;
		end

		AIBehaviour.HELIDEFAULT:heliUpdateMinZ( entity, vVel, height, 3.0 );
		AIBehaviour.HELIDEFAULT:heliStickToMinZ( entity, vVel );

		AI.SetForcedNavigation( entity.id, vVel );

	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK3_GOOVERVEHICLE_START = function( self, entity )

		if ( self:HELI_HOVERATTACK3_CHECKTARGET( entity )> 0 ) then
			return;
		end

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			if ( AI.GetTypeOf( target.id ) == AIOBJECT_VEHICLE ) then
				if ( target.AIMovementAbility.pathType == AIPATH_BOAT ) then
					self:HELI_HOVERATTACK3_GOOVERBOAT_START( entity );
					return;
				end
			end

			entity.AI.circleSec = System.GetCurrTime();
			entity.AI.deltaT = System.GetCurrTime();
			entity.AI.bLock = false;

			CopyVector( entity.AI.vTargetRsv, target:GetPos() );
			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );

			SubVectors( entity.AI.vDirectionRsv, target:GetPos(), entity:GetPos() );
			entity.AI.vDirectionRsv.z = 0;
			NormalizeVector( entity.AI.vDirectionRsv );

			entity.AI.CurrentHook = fHELI_HOVERATTACK3_GOOVERVEHICLE;

			entity.AI.minZ = entity.AI.vTargetRsv.z + 20.0;

			entity:SelectPipe( 0, "do_nothing");
			entity:SelectPipe( 0, "HeliMain");
			entity:InsertSubpipe( 0, "HeliLookat" );
			entity:InsertSubpipe( 0, "HeliFireStop" );

			if ( random(1,3)==2 ) then
				if ( entity.AI.rotateDirection == false ) then
					entity.AI.rotateDirection = true;
				else
					entity.AI.rotateDirection = false;
				end
			end

			self:HELI_HOVERATTACK3_GOOVERVEHICLE( entity );


		end

	end,

	HELI_HOVERATTACK3_GOOVERVEHICLE = function( self, entity )

		local vVel = {};
		local vTmp = {};
		entity:GetVelocity( vVel );

		CopyVector( vTmp, entity:GetDirectionVector(1) );
		vTmp.z = 0;
		NormalizeVector( vTmp );

		local dot = dotproduct3d( entity.AI.vDirectionRsv, vTmp );
		if ( LengthVector( vVel ) < 3.0 and dot > math.cos( 10.0 * 3.1416 /180.0 ) ) then
			AI.Signal(SIGNALFILTER_SENDER,1,"HELI_HOVERATTACK3_GOOVERVEHICLE2_START", entity.id);
			return;		
		end

		if ( System.GetCurrTime() - entity.AI.circleSec > 5.0 ) then
			AI.Signal(SIGNALFILTER_SENDER,1,"HELI_HOVERATTACK3_GOOVERVEHICLE2_START", entity.id);
			return;		
		end

		vVel.z = 0.5;
		FastScaleVector( vVel, vVel, 0.25 );

		local height = AIBehaviour.HELIDEFAULT:heliSetForcedNavigation( entity, vVel, 10.0, 3.0 );
		if ( height < 0 ) then
			return false;
		end

		AIBehaviour.HELIDEFAULT:heliUpdateMinZ( entity, vVel, height, 3.0 );
		AIBehaviour.HELIDEFAULT:heliStickToMinZ( entity, vVel );

		AI.SetForcedNavigation( entity.id, vVel );

	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK3_GOOVERVEHICLE2_START = function( self, entity )

		if ( self:HELI_HOVERATTACK3_CHECKTARGET( entity )> 0 ) then
			return;
		end

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			entity.AI.circleSec = System.GetCurrTime();
			entity.AI.deltaT = System.GetCurrTime();
			entity.AI.bLock = 0;
			entity.AI.goAwayLength = 10.0 + random( 0.0, 20.0 );

			CopyVector( entity.AI.vTargetRsv, target:GetPos() );
			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );

			SubVectors( entity.AI.vDirectionRsv, target:GetPos(), entity:GetPos() );
			entity.AI.vDirectionRsv.z = 0;
			NormalizeVector( entity.AI.vDirectionRsv );

			entity.AI.CurrentHook = fHELI_HOVERATTACK3_GOOVERVEHICLE2;
			entity.AI.minZ = entity.AI.vTargetRsv.z + 10.0;

			entity:SelectPipe(0,"do_nothing");
			entity:SelectPipe(0,"HeliMain");
			entity:InsertSubpipe( 0, "HeliLookat" );
			self:HELI_HOVERATTACK3_GOOVERVEHICLE2( entity );

		end

	end,
	
	HELI_HOVERATTACK3_GOOVERVEHICLE2 = function( self, entity )

		local vDist = {};
		local vVel = {};
		local vTmp = {};

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			if ( System.GetCurrTime()- entity.AI.circleSec > 2.3 and entity.AI.bLock == 1 ) then
				entity:InsertSubpipe( 0, "HeliFireStop" );
				entity.AI.bLock = 2;
			end

			AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, entity:GetPos(), 1 );
			FastScaleVector( vTmp, entity:GetDirectionVector(1), 20.0 );
			FastSumVectors( vTmp, vTmp, entity:GetPos() );
			AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vTmp, 2 );
			if ( AIBehaviour.HELIDEFAULT:heliCheckSpaceVoidMain( entity, 2, 1.0 ) == true ) then
				AIBehaviour.HELIDEFAULT:heliGetPathLine( entity, vDist, 2 );
				if ( vDist.z > vTmp.z + 1.5 ) then
					if ( entity.AI.bLock == 1 ) then
						entity:InsertSubpipe( 0, "HeliFireStop" );
						entity.AI.bLock = 0;
					end
				else
					if ( entity.AI.bLock == 0 ) then
						entity:InsertSubpipe( 0, "HeliFireStart" );
						entity.AI.circleSec = System.GetCurrTime();
						entity.AI.bLock = 1;
					end
				end
			end

			SubVectors( vDist, entity.AI.vTargetRsv, entity:GetPos() );
			vDist.z =0;
			local length = LengthVector( vDist );
			NormalizeVector( vDist );

			SubVectors( vTmp, entity.AI.vTargetRsv, entity.AI.vMyPosRsv );
			vTmp.z =0;
			NormalizeVector( vTmp );
			FastScaleVector( vTmp, vTmp, 2.0 );

			CopyVector( vVel, entity:GetDirectionVector(1) );
--			FastSumVectors( vVel, vVel, vTmp );
			vVel.z =0;
			NormalizeVector( vVel );

			local dotEnd = dotproduct3d( entity.AI.vDirectionRsv, vDist );
			if ( dotEnd < 0 ) then
				AI.Signal(SIGNALFILTER_SENDER,1,"HELI_HOVERATTACK3_GOOVERVEHICLE3_START", entity.id);
				return;
			end

			SubVectors( vTmp, entity:GetPos(), entity.AI.vMyPosRsv );
			vTmp.z = 0;
			
			if ( LengthVector( vTmp ) > 250.0 ) then
				AI.Signal(SIGNALFILTER_SENDER,1,"HELI_HOVERATTACK3_GOOVERVEHICLE_START", entity.id);
				return;
			end

			local cof;
			if ( dotEnd < 0  ) then
				cof = 15.0;
			else
				cof =  System.GetCurrTime() - entity.AI.circleSec;
				if ( cof > 3.0 ) then
					cof = 3.0;
				end
				cof = cof * 4 + 12.0;
			end
			FastScaleVector( vVel, vVel, cof );

			local height = AIBehaviour.HELIDEFAULT:heliSetForcedNavigation( entity, vVel, 10.0, 3.0 );
			if ( height < 0 ) then
				self:HELI_HOVERATTACK3_EMERGENCYSTOP_START( entity );
				return false;
			end

			AIBehaviour.HELIDEFAULT:heliUpdateMinZ( entity, vVel, height, 3.0 );
			AIBehaviour.HELIDEFAULT:heliStickToMinZ( entity, vVel );

			AI.SetForcedNavigation( entity.id, vVel );

		end


	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK3_GOOVERVEHICLE3_START = function( self, entity )

		if ( self:HELI_HOVERATTACK3_CHECKTARGET( entity )> 0 ) then
			return;
		end

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			entity.AI.CurrentHook = fHELI_HOVERATTACK3_GOOVERVEHICLE3;
			entity.AI.bCircledHalf = false;
			entity.AI.circleSec = System.GetCurrTime();

			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
			CopyVector( entity.AI.vTargetRsv, target:GetPos() );

			entity:SelectPipe( 0, "do_nothing");
			entity:SelectPipe( 0, "HeliMain");
			entity:InsertSubpipe(0,"HeliLookat");
			entity:InsertSubpipe( 0, "HeliFireStop" );

			entity.AI.tmpVal = 40.0 + random( 40.0 );

			entity.AI.minZ = entity.AI.vTargetRsv.z + 20.0;

			self:HELI_HOVERATTACK3_GOOVERVEHICLE3( entity );

		end

	end,
	
	HELI_HOVERATTACK3_GOOVERVEHICLE3 = function( self, entity )

		local vWng = {};
		local vWngR = {};
		local vFwd = {};

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			local vTargetPos = {};
			local vMyPos = {};
	
			CopyVector( vTargetPos, target:GetPos() );
			CopyVector( vMyPos, entity:GetPos() );


			local vDist = {};
			SubVectors( vDist, target:GetPos(), entity:GetPos() );
			vDist.z =0;

			local scaleFactor = LengthVector( vDist );
			if ( scaleFactor > 85.0 ) then
				if ( random( 1, 100 ) > 70 ) then
					if ( self:HELI_HOVERATTACK3_HIDE_START( entity ) == false ) then
						AI.Signal(SIGNALFILTER_SENDER,1,"HELI_HOVERATTACK3_GOOVERVEHICLE_START", entity.id);
					end
				else
					AI.Signal(SIGNALFILTER_SENDER,1,"HELI_HOVERATTACK3_GOOVERVEHICLE_START", entity.id);
				end
				return;
			end

			SubVectors( vFwd, target:GetPos(), entity:GetPos() );
			NormalizeVector( vFwd );
			crossproduct3d( vWng, vFwd, entity.AI.vUp );
			vWng.z = 0;
			if ( entity.AI.rotateDirection == false ) then
				FastScaleVector( vWng, vWng, -1.0 );
			end

			NormalizeVector( vWng );
			FastScaleVector( vWng, vWng, entity.AI.tmpVal );
			FastSumVectors( vWng, vWng, entity:GetPos() );
	
			SubVectors( vFwd, vWng , target:GetPos()  );
			NormalizeVector( vFwd );
			FastScaleVector( vFwd, vFwd, 140.0 );
			FastSumVectors( vFwd, vFwd, target:GetPos() );
			SubVectors( vFwd, vFwd, entity:GetPos() );
			NormalizeVector( vFwd );

			if ( scaleFactor > 60.0 ) then
				scaleFactor = 80 - scaleFactor;
				if ( scaleFactor < 5 ) then
					scaleFactor = 5;
				elseif ( scaleFactor > 20 ) then
					scaleFactor = 20;
				end
			else
				scaleFactor = 20;
			end
			FastScaleVector( vFwd, vFwd, scaleFactor );

			local height = AIBehaviour.HELIDEFAULT:heliSetForcedNavigation( entity, vFwd, 5.0, 2.0 )
			if ( height < 0  ) then
				self:HELI_HOVERATTACK3_EMERGENCYSTOP_START( entity );
				return false;
			end

			AIBehaviour.HELIDEFAULT:heliUpdateMinZ( entity, vFwd, height, 3.0 );
			AIBehaviour.HELIDEFAULT:heliStickToMinZ( entity, vFwd );

			AI.SetForcedNavigation( entity.id, vFwd );

		end

	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK3_HIDE_START = function( self, entity )

		if ( self:HELI_HOVERATTACK3_CHECKTARGET( entity )> 0 ) then
			return;
		end

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			local objects = {};
			local numObjects = AI.GetNearestEntitiesOfType( target:GetPos(), AIAnchorTable.HELI_HIDE_SPOT, 3, objects, AIFAF_INCLUDE_DEVALUED, 400.0 );

			if ( numObjects > 0 ) then

				local vTargetPos = {};
				local vObjPos = {};
				local vMyPos = {};
				local vTmp = {};
				local bOK;
				
				CopyVector( vMyPos, entity:GetPos() );
				vMyPos.z = 0;

				CopyVector( vTargetPos, target:GetPos() );
				vTargetPos.z = 0;

				SubVectors( entity.AI.vDirectionRsv, target:GetPos(), entity:GetPos() );
				entity.AI.vDirectionRsv.z = 0;
				NormalizeVector( entity.AI.vDirectionRsv );

				for i = 1,numObjects do

					bOK = true;

					local objEntity = System.GetEntity( objects[i].id );
					CopyVector( vObjPos, objEntity:GetPos() );
					vObjPos.z = 0;

					SubVectors( vTmp, vObjPos, vMyPos );
					NormalizeVector( vTmp );
					local dot = dotproduct3d( vTmp, entity.AI.vDirectionRsv );
					if ( dot > 0 ) then
					--	bOK = false;
					end

					SubVectors( vTmp, vObjPos, vTargetPos );
					vTmp.z = 0;
					if ( LengthVector( vTmp ) < 50.0 ) then
						bOK = false;
					end

					if ( bOK == true and entity.AI.Lastentityid ~= objEntity.id) then
						
						entity.AI.Lastentityid = objEntity.id;
					
						entity.AI.CurrentHook = fHELI_HOVERATTACK3_HIDE;
						entity.AI.circleSec = System.GetCurrTime();
						CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
						CopyVector( entity.AI.vTargetRsv, objEntity:GetPos() );
						SubVectors( entity.AI.vDirectionRsv,  entity.AI.vTargetRsv , entity.AI.vMyPosRsv );

						local vTmp = {};
						local vTmp2 = {};

						CopyVector( vTmp, entity.AI.vDirectionRsv );
						NormalizeVector( vTmp );
						entity:GetVelocity( vTmp );


						entity.AI.bLock = true;
						if ( dotproduct3d( vTmp, entity:GetDirectionVector( 0 ) ) > 0 ) then
							entity.AI.bLock = false;
						end

						entity.AI.vDirectionRsv.z = 0;
						entity:SelectPipe( 0, "do_nothing");
						entity:SelectPipe( 0, "HeliMain");
						entity.AI.minZ = entity.AI.vTargetRsv.z + 10.0;

						SubVectors( vTmp2, entity.AI.vTargetRsv, entity:GetPos() );
						vTmp2.z =0;
						local length = LengthVector( vTmp2 );
		
						if ( length < 50.0 ) then
							self:HELI_HOVERATTACK3_HIDE2_START( entity );
							return;
						end

						self:HELI_HOVERATTACK3_HIDE( entity );
						return true;
					end

				end
			
			end

		end

		return false;

	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK3_HIDE = function( self, entity )

		local vTmp = {};
		local vTmp2 = {};

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			local arclen = LengthVector( entity.AI.vDirectionRsv );
			
			SubVectors( vTmp2, entity:GetPos(), entity.AI.vMyPosRsv );
			vTmp2.z =0;

			local dot = dotproduct3d( entity.AI.vDirectionRsv, vTmp2 ) / arclen;

			if ( dot < 0 ) then
				dot = 0;
			end

	 		dot = dot + 15.0;
			if ( dot > arclen ) then
 				dot = arclen;
 			end

			local rad = 3.1416 * dot / arclen;
			local wingLen = math.sin( rad ) * arclen  / 2.0 ;

			CopyVector( vTmp, entity.AI.vDirectionRsv );
			NormalizeVector( vTmp );
			crossproduct3d( vTmp2, vTmp, entity.AI.vUp );
			NormalizeVector( vTmp2 );
			if ( entity.AI.bLock == false ) then
				FastScaleVector( vTmp2, vTmp2, -1.0 );			
			end

			FastScaleVector( vTmp2, vTmp2, wingLen );
			FastScaleVector( vTmp, vTmp, dot );
			FastSumVectors( vTmp, vTmp, vTmp2 );

			FastSumVectors( vTmp, vTmp, entity.AI.vMyPosRsv );
			vTmp.z = entity.AI.minZ;

			SubVectors( vTmp, vTmp, entity:GetPos() );
			NormalizeVector( vTmp );
			FastScaleVector( vTmp, vTmp, 20.0 );

			if ( System.GetCurrTime() - entity.AI.circleSec > 20.0 ) then
				AI.Signal(SIGNALFILTER_SENDER, 1, "HELI_HOVERATTACK3_GOOVERVEHICLE_START", entity.id);
				return;
			end

			SubVectors( vTmp2, entity.AI.vTargetRsv, entity:GetPos() );
			vTmp2.z =0;
			local length = LengthVector( vTmp2 );
		
			if ( length < 33.0 ) then
				AI.Signal(SIGNALFILTER_SENDER, 1, "HELI_HOVERATTACK3_HIDE2_START", entity.id);
				return;
			end

			local height = AIBehaviour.HELIDEFAULT:heliSetForcedNavigation( entity, vTmp, 7.0, 3.0 );
			if ( height < 0  ) then
				self:HELI_HOVERATTACK3_EMERGENCYSTOP_START( entity );
				return false;
			end

			AIBehaviour.HELIDEFAULT:heliUpdateMinZ( entity, vTmp, height, 3.0 );
			AIBehaviour.HELIDEFAULT:heliStickToMinZ( entity, vTmp );

			AI.SetForcedNavigation( entity.id, vTmp );

		end

	end,


	--------------------------------------------------------------------------
	HELI_HOVERATTACK3_HIDE2_START = function( self, entity )

		if ( self:HELI_HOVERATTACK3_CHECKTARGET( entity )> 0 ) then
			return;
		end

		entity.AI.circleSec = System.GetCurrTime();
		entity.AI.CurrentHook = fHELI_HOVERATTACK3_HIDE2;
		entity.AI.bLock = false;

		local vTmp = {};
		FastScaleVector( vTmp, entity:GetDirectionVector(1) , 100.0 );
		FastSumVectors( vTmp, vTmp, entity:GetPos() );

		AI.SetRefPointPosition( entity.id, vTmp );
		entity:SelectPipe( 0, "do_nothing");
		entity:SelectPipe( 0, "HeliMain");
		entity:InsertSubpipe( 0, "HeliLookatRef" );

		self:HELI_HOVERATTACK3_HIDE2( entity );



	end,

	HELI_HOVERATTACK3_HIDE2 = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			local vTmp = {};
			SubVectors( vTmp, target:GetPos() , entity:GetPos() );
			vTmp.z = 0;
			local length = LengthVector( vTmp );
			if ( length < 40.0 ) then
				entity:SelectPipe( 0, "do_nothing");
				entity:SelectPipe( 0, "HeliMain");
				entity:InsertSubpipe(0,"HeliLookat");
				entity.AI.circleSec = System.GetCurrTime();
				entity.AI.bLock = true;
				AI.Signal(SIGNALFILTER_SENDER, 1, "HELI_HOVERATTACK3_HIDE3_START", entity.id);
				return;
			end
	
			SubVectors( vTmp, entity.AI.vTargetRsv, entity:GetPos() );
			local length = LengthVector( vTmp );
			if ( length > 8.0 ) then
				length = 8.0;
			end
	
			if ( entity.AI.bLock == false ) then
				if ( length < 3.0 ) then
					if ( System.GetCurrTime() - entity.AI.circleSec > 3.0 ) then
						entity:SelectPipe( 0, "do_nothing");
						entity:SelectPipe( 0, "HeliMain");
						entity:InsertSubpipe(0,"HeliLookat");
						entity.AI.circleSec = System.GetCurrTime();
						entity.AI.bLock = true;
					end
				end
			else
				if ( System.GetCurrTime() - entity.AI.circleSec > 5.0 ) then
					AI.Signal(SIGNALFILTER_SENDER, 1, "HELI_HOVERATTACK3_HIDE3_START", entity.id);
					return;
				end
			end
			
			NormalizeVector( vTmp );
			FastScaleVector( vTmp, vTmp, length );

			local vMyPos = {};
			CopyVector( vMyPos, entity:GetPos() );
			local height = AIBehaviour.HELIDEFAULT:heliSetForcedNavigation( entity, vTmp, 1.0, 0.5 );
			if ( height < 0 ) then
				self:HELI_HOVERATTACK3_EMERGENCYSTOP_START( entity );
				return false;
			end
	
			if ( length > 5.0 ) then
				if ( height > vMyPos.z  ) then
					vTmp.z = ( height - vMyPos.z )* minUpdateTime;
				end
			end
	
			AI.SetForcedNavigation( entity.id, vTmp );

		end

	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK3_HIDE3_START = function( self, entity )

		if ( self:HELI_HOVERATTACK3_CHECKTARGET( entity )> 0 ) then
			return;
		end

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			entity.AI.CurrentHook = fHELI_HOVERATTACK3_HIDE3;
			entity.AI.bCircledHalf = false;
			entity.AI.circleSec = System.GetCurrTime();
			entity.AI.bLock = false;

			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
			CopyVector( entity.AI.vTargetRsv, target:GetPos() );

			entity:SelectPipe( 0, "do_nothing");
			entity:SelectPipe( 0, "HeliMain");
			entity:InsertSubpipe(0,"HeliLookat");
			entity:InsertSubpipe( 0, "HeliFireStop" );

			entity.AI.minZ = entity.AI.vTargetRsv.z + 30.0;

			self:HELI_HOVERATTACK3_HIDE3( entity );

		end

	end,

	HELI_HOVERATTACK3_HIDE3 = function( self, entity )

		local vTmp = {};

		CopyVector( vTmp, entity:GetPos() );
		vTmp.z = entity.AI.minZ;
		SubVectors( vTmp, vTmp, entity:GetPos() );
		length = LengthVector( vTmp );
		if ( length > 8.0 ) then
			length = 8.0;
		end

		if ( length < 1.0 ) then
			if ( System.GetCurrTime() - entity.AI.circleSec > 3.0 ) then
				AI.Signal( SIGNALFILTER_SENDER, 1, "HELI_HOVERATTACK3_GOOVERVEHICLE_START", entity.id );
				return;
			end
		end

		NormalizeVector( vTmp );
		FastScaleVector( vTmp, vTmp, length );

		local height = AIBehaviour.HELIDEFAULT:heliSetForcedNavigation( entity, vTmp, 3.0, 3.0 );
		if ( height < 0 ) then
			self:HELI_HOVERATTACK3_EMERGENCYSTOP_START( entity );
			return false;
		end

		AI.SetForcedNavigation( entity.id, vTmp );

	end,


	--------------------------------------------------------------------------
	-- additional code for the boat vs the heli
	--------------------------------------------------------------------------
	HELI_HOVERATTACK3_GOOVERBOAT_START = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			entity.AI.circleSec = System.GetCurrTime()-10.0;
			entity.AI.deltaT = System.GetCurrTime();
			entity.AI.bLock = false;

			CopyVector( entity.AI.vDirectionRsv, target:GetDirectionVector(1) );
			entity.AI.vDirectionRsv.z =0;
			NormalizeVector( entity.AI.vDirectionRsv );
			CopyVector( entity.AI.vTargetRsv, target:GetDirectionVector(1) );

			if ( entity.AI.pathName == nil ) then
				entity.AI.pathName = AI.GetNearestPathOfTypeInRange( entity.id, target:GetPos(), 10000.0, AIAnchorTable.ALIEN_COMBAT_AMBIENT_PATH, 0.0, 0 );
			end


			entity.AI.CurrentHook = fHELI_HOVERATTACK3_GOOVERBOAT;

			entity:SelectPipe( 0, "do_nothing");
			entity:SelectPipe( 0, "HeliMain");
			entity:InsertSubpipe( 0, "HeliResetLookat");
			entity:InsertSubpipe( 0, "HeliFireStop" );

		end

	end,

	HELI_HOVERATTACK3_GOOVERBOAT = function( self, entity )

		if ( self:HELI_HOVERATTACK3_CHECKTARGET( entity ) > 0 ) then
			return;
		end

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			if ( self:HELI_HOVERATTACK3_CHECKTARGET( entity )> 0 ) then
				return;
			end

			local vVel = {};
			local vTmp = {};
			local vTmp2 = {};
			local vFwd = {};

			target:GetVelocity( vVel );
			vVel.z =0;
	
			if ( LengthVector( vVel ) < 5.0 ) then
				CopyVector( vVel, target:GetDirectionVector(1) );
			end
			NormalizeVector( vVel );

			if ( System.GetCurrTime() - entity.AI.circleSec > 2.0 ) then

			 	entity.AI.circleSec = System.GetCurrTime();
				FastScaleVector( vVel, vVel, 180.0 );
				vVel.z = 0;
				FastSumVectors( entity.AI.vBoatTarget, target:GetPos(), vVel );
				SubVectors( vTmp, entity.AI.vBoatTarget, entity:GetPos() );
				vTmp.z = 0;
				NormalizeVector( vTmp );
				CopyVector( entity.AI.vTargetRsv, vTmp );

				if ( entity.AI.pathName ~=nil ) then
					CopyVector( vTmp,	AI.GetNearestPointOnPath( target.id, entity.AI.pathName, entity.AI.vBoatTarget ) );
					SubVectors( vTmp, vTmp, entity:GetPos() );
					vTmp.z = 0;
					NormalizeVector( vTmp );
					CopyVector( entity.AI.vTargetRsv, vTmp );

					local vDir = {};
					entity:GetVelocity( vDir );
					vDir.z = 0;
					NormalizeVector( vDir );
					FastScaleVector( vDir, vDir, -1.0 );
		
					local speed = entity:GetSpeed();
					entity:AddImpulse( -1, entity:GetCenterOfMassPos(), entity.AI.vTargetRsv, entity:GetMass()*speed*0.5, 1 );	

				else
				end

			end
	
			FastScaleVector( vVel, entity.AI.vTargetRsv, 40.0  );

			local vMyPos = {};
			local vEnemyPos = {};
			CopyVector( vMyPos, entity:GetPos() );
			CopyVector( vEnemyPos, entity:GetPos() );

			if ( vEnemyPos.z + 35.0 < vMyPos.z  ) then
				vVel.z =-2.5;
			end			

			AIBehaviour.HELIDEFAULT:HeliCheckClearanceMain( entity, vVel, 5.0, 5.0 );
			AI.SetForcedNavigation( entity.id, vVel );

			CopyVector( vTmp2, target:GetDirectionVector(1) );
			vTmp2.z = 0.0;
			NormalizeVector( vTmp2 );
			SubVectors( vTmp, entity:GetPos(), target:GetPos() );
			vTmp.z = 0.0;
			local distance = LengthVector( vTmp );
			NormalizeVector( vTmp );
			local dot = dotproduct3d( vTmp, vTmp2 );

			if ( entity.AI.pathName ~=nil ) then
				if ( distance > 120.0 ) then
					if ( dot > 0.0 ) then
						CopyVector( vTmp,	AI.GetNearestPointOnPath( entity.id, entity.AI.pathName, entity:GetPos() ) );
						SubVectors( vTmp, vTmp, entity:GetPos() );
						if ( LengthVector( vTmp )< 80.0 ) then
							self:HELI_HOVERATTACK3_GOOVERBOAT3_START( entity );
							return;
						end
					end
				end

			else
				if ( distance > 100.0 ) then
					if ( dot > 0.0 ) then
						self:HELI_HOVERATTACK3_GOOVERBOAT3_START( entity );
						return;
					end
				end
			end

		end

	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK3_GOOVERBOAT2_START = function( self, entity )
	end,
	
	HELI_HOVERATTACK3_GOOVERBOAT2 = function( self, entity )
	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK3_GOOVERBOAT3_START = function( self, entity )

		if ( self:HELI_HOVERATTACK3_CHECKTARGET( entity )> 0 ) then
			return;
		end

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target ) == true ) then

			entity.AI.CurrentHook = fHELI_HOVERATTACK3_GOOVERBOAT3;
			entity.AI.bCircledHalf = false;
			entity.AI.circleSec = System.GetCurrTime();
			entity.AI.bLock = false;
			
			CopyVector( entity.AI.vMyPosRsv, entity:GetPos() );
			CopyVector( entity.AI.vTargetRsv, target:GetPos() );

			entity:SelectPipe( 0, "do_nothing");
			entity:SelectPipe( 0, "HeliMain2");
			entity:InsertSubpipe(0,"HeliLookat");

			entity.AI.minZ = entity.AI.vTargetRsv.z + 30.0;


			local vDir = {};
			entity:GetVelocity( vDir );
			vDir.z = 0;
			NormalizeVector( vDir );
			FastScaleVector( vDir, vDir, -1.0 );

			local speed = entity:GetSpeed();
			entity:AddImpulse( -1, entity:GetCenterOfMassPos(), vDir, entity:GetMass()*speed*0.5, 1 );	

			self:HELI_HOVERATTACK3_GOOVERBOAT3( entity );

		end

	end,
	
	HELI_HOVERATTACK3_GOOVERBOAT3 = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehaviour.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then

			if ( self:HELI_HOVERATTACK3_CHECKTARGET( entity )> 0 ) then
				return;
			end

			local vTargetPos = {};
			local vMyPos = {};
			local vFwd = {};
			local vTmp = {};
			local vTmp2 = {};
			local vTmp3 = {};

			if ( entity.AI.bLock == false ) then	
				SubVectors( vTmp, target:GetPos(), entity:GetPos() );
				vTmp.z = 0.0;
				NormalizeVector( vTmp );
			
				FastScaleVector( vFwd, vTmp, -40.0 );
				local vMyPos = {};
				local vEnemyPos = {};
				
				if ( entity.AI.pathName ~=nil ) then
					FastSumVectors( vTmp, vFwd, entity:GetPos() );
					CopyVector( vTmp2,	AI.GetNearestPointOnPath( entity.id, entity.AI.pathName, vTmp ) );
					SubVectors( vTmp2, vTmp2, entity:GetPos() );
					vTmp.z = 0;
					NormalizeVector( vTmp2 );
				else
				end
				
				CopyVector( vMyPos, entity:GetPos() );
				CopyVector( vEnemyPos, target:GetPos() );
				if ( vEnemyPos.z + 30.0 < vMyPos.z  ) then
					vFwd.z =-2.5;
				end
				entity.AI.circleSec = System.GetCurrTime();
			else
					SubVectors( vTmp, target:GetPos(), entity:GetPos() );
					vTmp.z = 0.0;
					NormalizeVector( vTmp );
					if ( System.GetCurrTime() - entity.AI.circleSec > 3.0 ) then
					local vDir = {};
					entity:GetVelocity( vDir );
					vDir.z = 0;
					NormalizeVector( vDir );
					FastScaleVector( vDir, vDir, -1.0 );
		
					local speed = entity:GetSpeed();
					entity:AddImpulse( -1, entity:GetCenterOfMassPos(), vDir, entity:GetMass()*speed*0.5, 1 );	

					self:HELI_HOVERATTACK3_GOOVERBOAT_START( entity );
					return;
				else
					FastScaleVector( vFwd, vTmp, 35.0 );
				end
			end

			SubVectors( vTmp, target:GetPos(), entity:GetPos() );
			vTmp.z = 0.0;
			NormalizeVector( vTmp );
			CopyVector( vTmp2, entity:GetDirectionVector(1) );
			vTmp2.z = 0;
			NormalizeVector( vTmp2 );

			if ( dotproduct3d( vTmp, vTmp2 ) >  math.cos( 30.0 * 3.1416 / 180.0  ) ) then
				if ( entity.AI.bLock == false ) then	
					entity:InsertSubpipe( 0, "HeliFireStart" );
					entity.AI.bLock = true;
				end
			end

			SubVectors( vTmp2, entity:GetPos(), target:GetPos() );
			vTmp2.z =0;
			NormalizeVector( vTmp2 );

			CopyVector( vTmp, target:GetDirectionVector(1) );
			vTmp.z =0;
			NormalizeVector( vTmp );

			if ( dotproduct3d( vTmp2, vTmp ) < 0 ) then

				local vDir = {};
				entity:GetVelocity( vDir );
				vDir.z = 0;
				NormalizeVector( vDir );
				FastScaleVector( vDir, vDir, -1.0 );
	
				local speed = entity:GetSpeed();
				entity:AddImpulse( -1, entity:GetCenterOfMassPos(), vDir, entity:GetMass()*speed*0.5, 1 );	

				self:HELI_HOVERATTACK3_GOOVERBOAT_START( entity );
				return;

			end

			AIBehaviour.HELIDEFAULT:HeliCheckClearanceMain( entity, vFwd, 5.0, 5.0 );
			AI.SetForcedNavigation( entity.id, vFwd );

		end

	end,

}
