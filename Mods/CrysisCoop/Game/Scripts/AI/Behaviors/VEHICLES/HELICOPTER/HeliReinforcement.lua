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
--  - 12/06/2006   : the first implementation by Tetsuji
--
--------------------------------------------------------------------------
local Xaxis =0;
local Yaxis =1;
local Zaxis =2;
local minUpdateTime = 0.33;


AIBehaviour.HeliReinforcement = {
	Name = "HeliReinforcement",
	Base = "HeliBase",
	alertness = 0,

	-- SYSTEM EVENTS			-----
	---------------------------------------------
	Constructor = function( self, entity, sender, data )

		AI.AutoDisable( entity.id, 0 );

		-- for common signal handlers.

		entity.AI.heliDefaultSignal = "TO_HELI_ATTACK";
		entity.AI.heliMemorySignal = "TO_HELI_ATTACK";
		entity.AI.heliTimer2 = 0;

		entity.vehicle:RetractGears();
		entity.vehicle:BlockAutomaticDoors( true );
		entity.vehicle:CloseAutomaticDoors( );

		AIBehaviour.HELIDEFAULT:heliRequest2ndGunnerShoot( entity );

	end,
	
	ACT_DUMMY = function( self, entity, sender, data )
		self:HELI_LANDING_FOR_REINFORCEMNT( entity, data );
	end,

	---------------------------------------------
	Destructor = function ( self, entity, data )

		-- called when the behaviour is de-selected
		-- the extra data is from the signal that is causing the behavior transition
		entity.AI.vReinforcementSetPosition = nil;
		entity.AI.vReinforcementSetPosition2 = nil;
		entity.AI.vReinforcementSetDirection = nil;
		entity.AI.reinforcementId = nil;
		entity.AI.bExitPassengers = nil;
		entity.AI.bExitDrivers = nil;
		entity.AI.bFinishReinforcement = nil;
		entity.AI.bCancelReinforcement = nil;

		entity.vehicle:OpenAutomaticDoors(  );
		entity.vehicle:BlockAutomaticDoors( false );
		entity.vehicle:RetractGears();

		AIBehaviour.HELIDEFAULT:heliRequest2ndGunnerShoot( entity );

		AI.SetForcedNavigation( entity.id, entity.AI.vZero );
		if ( entity.AI.heliTimer2 ~= 0 ) then
			entity.AI.heliTimer2 = 0;
		end

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

		if ( entity.AI.vehicleIgnorantIssued == true ) then
			return;
		end

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_HELI_ATTACK", entity.id);
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
	OnSoreDamage = function ( self, entity, sender, data )
		self:OnEnemyDamage( entity );
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
	end,
	---------------------------------------------
	OnObjectSeen = function( self, entity, fDistance, data )
		-- called when the AI sees an object registered for this kind of signal
		-- data.iValue = AI object type
		-- example
		-- if (data.iValue == 150) then -- grenade
		--	 ...
		if ( data.iValue == AIOBJECT_RPG) then
			--entity:InsertSubpipe(0,"devalue_target");
		end

	end,

	---------------------------------------------
	HELI_LANDING_FOR_REINFORCEMNT = function( self, entity, data )
	
		AI.CreateGoalPipe("heliLandingForReinforcement");
		AI.PushGoal("heliLandingForReinforcement","signal",1,1,"HELI_LANDING_FOR_REINFORCEMNT_SUB",SIGNALFILTER_SENDER);
		AI.PushGoal("heliLandingForReinforcement","signal",1,1,"HELI_LANDING_CANCELORNOT",SIGNALFILTER_SENDER);
		AI.PushGoal("heliLandingForReinforcement","signal",1,1,"TO_HELI_IDLE",SIGNALFILTER_SENDER);
		entity:InsertSubpipe(0,"heliLandingForReinforcement",nil,data.iValue);

	end,

	---------------------------------------------
	HELI_LANDING_CANCELORNOT =  function( self, entity, data )

		if ( entity.AI.bCancelReinforcement == true ) then
			entity:CancelSubpipe();
			if ( entity.AI.vehicleIgnorantIssued == true ) then
				AI.SetIgnorant(entity.id,1);
			end
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_HELI_IDLE", entity.id);
		end

	end,
		
	---------------------------------------------
	HELI_LANDING_FOR_REINFORCEMNT_SUB = function( self, entity, data )
	
		entity.AI.bCancelReinforcement = false;
	
		if ( entity.AI.reinforcementId ~= nil and  entity.AI.reinforcementId ~= entity.id ) then
			local targetEntity = System.GetEntity( entity.AI.reinforcementId );
			if ( targetEntity ) then
				entity.AI.vReinforcementSetPosition = {};
				entity.AI.vReinforcementSetDirection = {};
				CopyVector( entity.AI.vReinforcementSetPosition, targetEntity:GetPos() );
				CopyVector( entity.AI.vReinforcementSetDirection, targetEntity:GetDirectionVector(1) );
			else
				CopyVector( entity.AI.vReinforcementSetDirection, entity:GetDirectionVector(1) );
			end
		end

		if ( entity.AI.vReinforcementSetPosition==nil or LengthVector(entity.AI.vReinforcementSetPosition) < 0.01 ) then
			AI.LogEvent(entity:GetName().." No landing point is specified ");
			return;
		end

		AI.CreateGoalPipe("heliLandingForReinforcement2");
		AI.PushGoal("heliLandingForReinforcement2","signal",1,1,"HELI_GET_LANDING_POINT0",SIGNALFILTER_SENDER);
		AI.PushGoal("heliLandingForReinforcement2","signal",1,1,"HELI_WAIT_LANDING",SIGNALFILTER_SENDER);
		AI.PushGoal("heliLandingForReinforcement2","signal",1,1,"HELI_GET_LANDING_POINT1",SIGNALFILTER_SENDER);
		AI.PushGoal("heliLandingForReinforcement2","signal",1,1,"HELI_GET_LANDING_POINT2",SIGNALFILTER_SENDER);
		AI.PushGoal("heliLandingForReinforcement2","signal",1,1,"HELI_UNLOAD_ALL_PASSENGERS",SIGNALFILTER_SENDER);
		AI.PushGoal("heliLandingForReinforcement2","timeout",1,3.0);
		AI.PushGoal("heliLandingForReinforcement2","lookat", 0, -500, 0);
		AI.PushGoal("heliLandingForReinforcement2","signal",1,1,"HELI_LANDING_END",SIGNALFILTER_SENDER);
		entity:InsertSubpipe(0,"heliLandingForReinforcement2");

	end,

	---------------------------------------------
	HELI_GET_LANDING_POINT0 = function( self, entity )

		if ( entity.AI.bCancelReinforcement == true ) then
			return;
		end

		local vSrc = {};
		local vDst = {};
		local vDir = { 0.0, 0.0, -200.0 };
		
		CopyVector( vSrc, entity:GetPos() );
		vSrc.z = vSrc.z + 100.0;

		local	hits = Physics.RayWorldIntersection(vSrc,vDir,1,ent_terrain+ent_static+ent_rigid+ent_sleeping_rigid,entity.id,nil,g_HitTable);
		if ( hits == 0 ) then
			entity.AI.bCancelReinforcement = true;
			return;
		end

		CopyVector( vSrc, entity:GetPos() );

		AI.LogEvent(entity:GetName().." HELI_GET_LANDING_POINT0 : my height "..vSrc.z);

		local firstHit = g_HitTable[1];
		AI.LogEvent(entity:GetName().." HELI_GET_LANDING_POINT0: terrain height "..firstHit.pos.z);

		CopyVector( vDst, firstHit.pos );
		if ( vSrc.z > vDst.z + 10.0 ) then
			-- heli has enough height in the air;
			return;
		end

		local vOffset = {};
		vDst.z = vDst.z + 10.0;
		FastScaleVector( vOffset, entity:GetDirectionVector(Yaxis), 5.0 );
		FastSumVectors( vDst, vDst, vOffset );
		AI.SetRefPointPosition( entity.id ,vDst );

		AI.CreateGoalPipe("heliHoverUp");
		AI.PushGoal("heliHoverUp","continuous",0,1);
		AI.PushGoal("heliHoverUp","run",0,1);
		AI.PushGoal("heliHoverUp","locate",0,"refpoint");
		AI.PushGoal("heliHoverUp","approach",1,5.0,AILASTOPRES_USE,-1);
		entity:InsertSubpipe(0,"heliHoverUp");

	end,

	---------------------------------------------
	HELI_WAIT_LANDING = function( self, entity )

		return;

	end,

	---------------------------------------------
	HELI_GET_LANDING_POINT1 = function( self, entity )

		if ( entity.AI.bCancelReinforcement == true ) then
			return;
		end

		if ( entity:GetName() == "US_VTOL4" ) then
			return;
		end

		local vSrc = {};
		local vDst = {};
		local vDir = { 0.0, 0.0, -200.0 };

		SubVectors( vSrc, entity:GetPos(), entity.AI.vReinforcementSetPosition );
		vSrc.z = 0;
		if ( LengthVector( vSrc ) < 100.0 ) then
			return;
		end

		CopyVector( vSrc, entity.AI.vReinforcementSetPosition );
		vSrc.z = vSrc.z + 50.0;

		local	hits = Physics.RayWorldIntersection(vSrc,vDir,1,ent_terrain+ent_static+ent_rigid+ent_sleeping_rigid,entity.id,nil,g_HitTable);
		if( hits == 0 ) then
			entity.AI.bCancelReinforcement = true;
			return;
		end

		CopyVector( vSrc, entity.AI.vReinforcementSetPosition );
		SubVectors( vSrc, vSrc, entity:GetPos() );
		vSrc.z = 0.0;
		local length = LengthVector( vSrc );

		NormalizeVector( vSrc );
		FastScaleVector( vSrc, vSrc, -25.0  );

		local firstHit = g_HitTable[1];
		CopyVector( vDst, firstHit.pos );
		if ( vSrc.z < 25.0 ) then
			vSrc.z =25.0;
		end
		FastSumVectors( vDst, vDst, vSrc );

		AI.SetRefPointPosition( entity.id ,vDst );

		AI.CreateGoalPipe("heliRunToTheDestination");
		AI.PushGoal("heliRunToTheDestination","continuous",0,0);
		if ( length > 120.0 ) then
			AI.PushGoal("heliRunToTheDestination","run",0,1);
		else
			AI.PushGoal("heliRunToTheDestination","run",0,0);
		end
		AI.PushGoal("heliRunToTheDestination","locate",0,"refpoint");
		AI.PushGoal("heliRunToTheDestination","approach",1,3.0,AILASTOPRES_USE,10);
		entity:InsertSubpipe(0,"heliRunToTheDestination");
	
	end,

	---------------------------------------------
	HELI_GET_LANDING_POINT2 = function( self, entity )

		if ( entity.AI.bCancelReinforcement == true ) then
			return;
		end

		local vMyPos = {};
		local vSrc = {};
		local vDst = {};
		local vDir = { 0.0, 0.0, -200.0 };
		
		CopyVector( vSrc, entity.AI.vReinforcementSetPosition );
		vSrc.z = vSrc.z + 100.0;

		local	hits = Physics.RayWorldIntersection(vSrc,vDir,1,ent_terrain+ent_static+ent_rigid+ent_sleeping_rigid,entity.id,nil,g_HitTable);

		if( hits == 0 ) then
			entity.AI.bCancelReinforcement = true;
			return;
		end

		local firstHit = g_HitTable[1];
		firstHit.pos.z = firstHit.pos.z + 0.1; 						 -- landing
		AI.SetRefPointPosition( entity.id ,firstHit.pos );

		entity.AI.vReinforcementSetPosition2 = {};
		CopyVector( entity.AI.vReinforcementSetPosition2, AI.GetRefPointPosition( entity.id ) );
		entity.AI.vReinforcementSetPosition2.z = entity.AI.vReinforcementSetPosition2.z + 4.0;

		SubVectors( vDst, firstHit.pos, entity:GetPos() );
		vDst.z = 0;
		local length = LengthVector( vDst );

		AI.CreateGoalPipe("heliLanding");
		AI.PushGoal("heliLanding","continuous",0,0);
		if ( length > 120.0 ) then
			if ( entity.AI.bExitPassengers == true ) then
				AI.PushGoal("heliLanding","run",0,2);	-- for reinforcement
			else
				AI.PushGoal("heliLanding","run",0,1);	-- landing
			end
		else
			AI.PushGoal("heliLanding","run",0,0);
		end

		AI.PushGoal("heliLanding","locate",0,"refpoint");
		AI.PushGoal("heliLanding","signal",1,1,"HELI_OBSTACLE_CHECK",SIGNALFILTER_SENDER);
		AI.PushGoal("heliLanding","timeout",1,0.2);
		AI.PushGoal("heliLanding","branch",1,-2);
		AI.PushGoal("heliLanding","signal",1,1,"HELI_GET_LANDING_POINT3",SIGNALFILTER_SENDER);

		entity:InsertSubpipe(0,"heliLanding");

	end,

	---------------------------------------------
	HELI_GET_LANDING_POINT3 = function( self, entity )

		if ( entity.id and System.GetEntity( entity.id ) ) then
		else
			return;
		end

		if ( entity.AI.vReinforcementSetPosition == nil ) then
			return;
		end
		if ( entity.AI.vReinforcementSetPosition2 == nil ) then
			return;
		end
		if ( entity.AI.vReinforcementSetDirection == nil ) then
			return;
		end

		entity.vehicle:ExtractGears();
		entity.AI.deltaTSystem = System.GetCurrTime();
		entity.AI.bFinishLanding = false;
		
		local vTmp = {};
		CopyVector( vTmp, entity.AI.vReinforcementSetDirection );
		vTmp.z = 0;
		NormalizeVector( vTmp );
		FastScaleVector( vTmp, vTmp, 30.0 );
		FastSumVectors( vTmp, vTmp, entity.AI.vReinforcementSetPosition2 );

		AI.SetRefPointPosition( entity.id ,vTmp );

		entity.AI.circleSec = System.GetCurrTime();

		entity.AI.vLastLandingAimPostion = {};
		CopyVector( entity.AI.vLastLandingAimPostion, entity:GetPos() );

		AI.CreateGoalPipe("vtolLanding");
		AI.PushGoal("vtolLanding","locate",0,"refpoint");
		AI.PushGoal("vtolLanding","lookat",0,0,0,true,1);		
		AI.PushGoal("vtolLanding", "waitsignal", 1, "HELI_GET_LANDING_POINT3_SUB_END", nil, 1000.0 );
		entity:InsertSubpipe(0,"vtolLanding");
		AIBehaviour.HELIDEFAULT:heliRequest2ndGunnerStopShoot( entity );

		if ( entity.AI.isVtol == true ) then

			local vVel = {};
			local vDir = {};
			entity:GetVelocity( vVel );
			vVel.z = 0;
			NormalizeVector( vVel );
			FastScaleVector( vDir, vVel, -1.0 );
			
			local speed = entity:GetSpeed();
			entity:AddImpulse( -1, entity:GetCenterOfMassPos(), vDir, entity:GetMass()*speed, 1 );	

		end

		entity.AI.heliTimer2 = 1;
		entity.AI.bLock = false;
		Script.SetTimerForFunction( minUpdateTime *1000, "AIBehaviour.HeliReinforcement.HELI_GET_LANDING_POINT3_SUB", entity );

	end,

	---------------------------------------------
	HELI_GET_LANDING_POINT3_SUB = function( entity )

		if ( entity.AI == nil or entity.AI.heliTimer2 == 0 or entity:GetSpeed() == nil ) then
			local myEntity = System.GetEntity( entity.id );
			if ( myEntity ) then
				local vZero = {x=0.0,y=0.0,z=0.0};
				AI.SetForcedNavigation( entity.id, vZero );
			end
				return;
		end

		if ( entity.AI.bFinishLanding == true ) then
			local vZero = {x=0.0,y=0.0,z=0.0};
			AI.SetForcedNavigation( entity.id, vZero );
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

		if ( AIBehaviour.HeliReinforcement.VTOL_OBSTACLE_CHECK( entity, entity.AI.vReinforcementSetPosition2 ) == false ) then
			entity.AI.bCancelReinforcement = true;
			entity:CancelSubpipe();
			if ( entity.AI.vehicleIgnorantIssued == true ) then
				AI.SetIgnorant(entity.id,1);
			end
			local vZero = {x=0.0,y=0.0,z=0.0};
			AI.SetForcedNavigation( entity.id, vZero );
			return;
		end

		entity.AI.heliTimer2 = 1;
		Script.SetTimerForFunction( minUpdateTime *1000, "AIBehaviour.HeliReinforcement.HELI_GET_LANDING_POINT3_SUB", entity );

		local vDirXY ={};
		local vDirZ ={};
		local vDir ={};
		local vTmp = {};
		local vTmp2 = {};

		SubVectors( vDir, entity.AI.vLastLandingAimPostion, entity:GetPos() );
		CopyVector( entity.AI.vLastLandingAimPostion, entity:GetPos() );

		SubVectors( vDir, entity.AI.vReinforcementSetPosition2, entity:GetPos() );
		CopyVector( vDirXY, vDir );
		CopyVector( vDirZ, vDir );

		vDirZ.x =0.0;
		vDirZ.y =0.0;
		vDirXY.z =0.0;

		local length1 = LengthVector( vDirXY );
		local length2 = LengthVector( vDirZ );

		if ( entity.AI.bLock == false ) then

			if ( length1 > 1.0 ) then
				NormalizeVector( vDirXY );
				if ( length1 > 29.0 ) then
					FastScaleVector( vDirXY, vDirXY, 12.0 );
				else
					FastScaleVector( vDirXY, vDirXY, length1 / 2.0  );
				end
				if ( entity.AI.isVtol == true ) then
					if ( length2 > 10.0 ) then
						vDirXY.z = -1.0;
					else
						vDirXY.z = 1.0;
					end
				else
					if ( length2 > 10.0 ) then
						vDirXY.z = -2.5;
					else
						vDirXY.z =  0.0;
					end
				end
				AI.SetForcedNavigation( entity.id, vDirXY );
				return;
			end
	
			if ( entity.AI.isVtol == true ) then
				if ( length2 > 1.0 ) then
					NormalizeVector( vDirZ );
					if ( length2 > 10.0 ) then
						FastScaleVector( vDirZ, vDirZ, 3.0 );
					else
						CopyVector( vTmp, entity.AI.vReinforcementSetDirection );
						vTmp.z = 0;
						NormalizeVector( vTmp );
						CopyVector( vTmp2, entity:GetDirectionVector(1) );
						vTmp2.z = 0;
						NormalizeVector( vTmp2 );
						local dot = dotproduct3d( vTmp, vTmp2 );
						if ( entity:GetSpeed() > 2.5 or dot < math.cos( 3.1416 * 3.0/180.0 ) ) then
							AI.SetForcedNavigation( entity.id, entity.AI.vZero );
							return;
						end
						length2 = length2 / 3.0;
						if ( length2 > 2.0 ) then
							length2 = 2.0;
						end
						FastScaleVector( vDirZ, vDirZ, length2 );
					end
					AI.SetForcedNavigation( entity.id, vDirZ );
					return;
				end
			else
				if ( length2 > 1.0 ) then
					entity:GetVelocity( vTmp );
					if ( entity:GetSpeed() > 2.0 ) then
						AI.SetForcedNavigation( entity.id, entity.AI.vZero );
						return;
					end
					NormalizeVector( vDirZ );
					AI.SetForcedNavigation( entity.id, vDirZ );
					return;
				end		
			end
			
			if ( entity.AI.bExitPassengers == true ) then
				if ( entity:GetSpeed() > 1.5 ) then
					AI.SetForcedNavigation( entity.id, entity.AI.vZero );
					return;
				end
				entity.vehicle:OpenAutomaticDoors( );
				entity.AI.bFinishLanding = true;
				vTmp.x = 0.0;
				vTmp.y = 0.0;
				vTmp.z = 1.0;
				AI.SetForcedNavigation( entity.id, vTmp );
				AI.Signal(SIGNALFILTER_SENDER, 1, "HELI_GET_LANDING_POINT3_SUB_END", entity.id);
				return;
			end
			entity.AI.bLock = true;
		end

--		System.Log(entity:GetName().." VTOL Landing Error "..LengthVector( vDirXY ) );

		local lenXY = LengthVector( vDirXY );
		if ( lenXY > 0.4 ) then
			NormalizeVector( vDirXY );
			FastScaleVector( vDirXY, vDirXY, lenXY * 0.8 );
			vDirXY.z =1.0;
			AI.SetForcedNavigation( entity.id, vDirXY );
			return;
		end			

		if ( LengthVector( vDirZ ) > 0.5 ) then
			NormalizeVector( vDirXY );
			FastScaleVector( vDirXY, vDirXY, lenXY * 0.8 );
			NormalizeVector( vDir );
			FastScaleVector( vDir, vDir, 0.45 );
			vDir.x = vDirXY.x;
			vDir.y = vDirXY.y;
			AI.SetForcedNavigation( entity.id, vDir );
			return;
		end	

		entity.AI.bFinishLanding = true;
		NormalizeVector( vDirXY );
		FastScaleVector( vDirXY, vDirXY, lenXY );
		vDir.x =vDirXY.x;
		vDir.y =vDirXY.y;
		vDir.z =-3.0;
		AI.SetForcedNavigation( entity.id, vDir );
		AI.Signal(SIGNALFILTER_SENDER, 1, "HELI_GET_LANDING_POINT3_SUB_END", entity.id);

	end,

	---------------------------------------------
	HELI_UNLOAD_ALL_PASSENGERS = function( self, entity )

		local i;

		if ( entity.AI.bCancelReinforcement == true ) then
			return;
		end

		if ( entity.AI.bExitDrivers == true ) then
	  	entity.vehicle:DisableEngine(1);
			return;
		end

		if ( entity.AI.bExitPassengers == false ) then
			return;
		end
	
		for i,seat in pairs(entity.Seats) do
			if( seat.passengerId ) then

				local member = System.GetEntity( seat.passengerId );
				if( member ~= nil ) then
			
				  if (seat.isDriver) then

				  	-- when a passenger is the driver.

				  elseif ( seat.seat:GetWeaponCount() > 0) then

				  	-- when a passenger is the gunner.

				  else
					  
						-- this guy should be a reinforcement.
						g_SignalData.fValue = randomF(1.0,100.0)/100.0;
						AI.Signal(SIGNALFILTER_SENDER, 1, "EXIT_VEHICLE_STAND_PRE", member.id, g_SignalData);

					end
			
				end
			end
		end	

		entity.AI.exitCheckCount = 0;

		AI.CreateGoalPipe("waitExiting");
		AI.PushGoal("waitExiting","signal",1,1,"HELI_CHECK_UNLOAD",SIGNALFILTER_SENDER);
		AI.PushGoal("waitExiting","timeout",1,1.0);
		AI.PushGoal("waitExiting","branch",1,-2);
		entity:InsertSubpipe(0,"waitExiting");

	end,

	--------------------------------------------------------------------------
	HELI_CHECK_UNLOAD = function( self, entity )

		local count = 0;

		for i,seat in pairs(entity.Seats) do
			if( seat.passengerId ) then

				local member = System.GetEntity( seat.passengerId );
				if( member ~= nil ) then
			
				  if (seat.isDriver) then
				  elseif ( seat.seat:GetWeaponCount() > 0) then
				  else
						count = count + 1;
					end
			
				end

			end
		end

		if ( entity.AI.exitCheckCount > 10 or count == 0 ) then
			entity:CancelSubpipe();
		end
	
		entity.AI.exitCheckCount =  entity.AI.exitCheckCount + 1;
	
	end,
	--------------------------------------------------------------------------
	VTOL_OBSTACLE_CHECK = function( entity, vVec )

		local vSrc ={};
		local vDst ={};
		local vTmp ={};
		
		CopyVector( vSrc, entity:GetPos() );
		CopyVector( vDst, vVec );

		SubVectors( vTmp, vDst, vSrc );
		vTmp.z =0;

		if ( LengthVector(vTmp) > 120.0 ) then
			return true;
		end

		if ( vSrc.z - vDst.z < 5.0 ) then
			return true;
		end

		local i;
		local targetEntity;
		local entities = System.GetPhysicalEntitiesInBox( vDst , 10.0 );

		if (entities) then

			for i,targetEntity in ipairs(entities) do
				local objEntity = targetEntity;
				if (objEntity.id ~= entity.id ) then
					local bbmin,bbmax = objEntity:GetLocalBBox();
					if ( DistanceVectors( bbmin , bbmax ) >  3.0 or objEntity:GetMass() > 300.0 ) then
						return false;
					end
				end
			end

		end	

		return true;

	end,

	--------------------------------------------------------------------------
	HELI_OBSTACLE_CHECK = function( self, entity )

		local vSrc ={};
		local vDst ={};
		local vTmp ={};
		
		CopyVector( vSrc, entity:GetPos() );
		CopyVector( vDst, AI.GetRefPointPosition( entity.id ) );

		SubVectors( vTmp, vDst, vSrc );
		vTmp.z =0;

		if ( LengthVector(vTmp) > 120.0 ) then
			return;
		end

		if ( vSrc.z - vDst.z < 5.0 ) then
			return;
		end

		local i;
		local targetEntity;
		local entities = System.GetPhysicalEntitiesInBox( vDst , 10.0 );

		if (entities) then
			for i,targetEntity in ipairs(entities) do
				local objEntity = targetEntity;
				if (objEntity.id ~= entity.id ) then
					local bbmin,bbmax = objEntity:GetLocalBBox();
					if ( DistanceVectors( bbmin , bbmax ) >  3.0 or objEntity:GetMass() > 300.0 ) then
						entity.AI.bCancelReinforcement = true;
						entity:CancelSubpipe();
						if ( entity.AI.vehicleIgnorantIssued == true ) then
							AI.SetIgnorant(entity.id,1);
						end
						return;
					end
				end
			end

		end	

	end,

	---------------------------------------------
}
