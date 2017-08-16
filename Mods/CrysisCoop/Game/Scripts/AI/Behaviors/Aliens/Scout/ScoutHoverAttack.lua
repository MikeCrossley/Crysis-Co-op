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
--	- 01/03/2006   : Created  by Tetsuji Iwasaki
--------------------------------------------------------------------------

--------------------------------------------------------------------------
AIBehaviour.ScoutHoverAttack = {
	Name = "ScoutHoverAttack",
	Base = "SCOUTDEFAULT",

	--------------------------------------------------------------------------
	Constructor = function ( self, entity, data )

		entity.AI.hoverCount = 0.0;
		entity.AI.hoverAngle = 0.0;
		entity.AI.hoverVec = {};
		entity.AI.hoverR = {};

		entity.AI.closeVec1 = {};
		entity.AI.closeVec2 = {};
		entity.AI.closeVec3 = {};

		-- for signals
		entity.AI.bBlockSignal = true;
		entity.AI.bBlockEscape = true;
		entity.AI.lastHealth =	entity.actor:GetHealth();

		if ( entity.AI.rsvForceView ) then
		
		else
			entity.AI.rsvForceView = entity.gameParams.forceView;
		end

		AI.CreateGoalPipe("scoutHoverAttackDefault");
		AI.PushGoal("scoutHoverAttackDefault","devalue",0,1);
		AI.PushGoal("scoutHoverAttackDefault","timeout",1,0.3);
		AI.PushGoal("scoutHoverAttackDefault","signal",0,1,"SC_SCOUT_HOVERATTACK_START",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"scoutHoverAttackDefault");


	end,
	---------------------------------------------
	Destructor = function ( self, entity, data )

		-- called when the behaviour is de-selected
		-- the extra data is from the signal that is causing the behavior transition

		entity.gameParams.forceView = entity.AI.rsvForceView;
		entity.actor:SetParams(entity.gameParams);
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
		-- called when the AI sees a living enemy
	end,
	---------------------------------------------
	OnObjectSeen = function( self, entity, fDistance, data )

		if ( data.iValue == AIOBJECT_RPG and entity.AI.bBlockEscape == false ) then

			entity.AI.bBlockEscape = true;

			-- calculate
			local targetName = AI.GetAttentionTargetOf(entity.id);

			if (targetName) then

				-- Suppose the scout is on the origin point.
				-- a rocket makes a line whose direction is the velocity of the rocket.
				-- then calculate a perpendicular line from the origin point to this line.
				-- If we make a line whose direction is opposite from the this perpendicular line,
				-- we can get a direction to ran away for the scout.

				-- P = U+tV, PV = 0 -> t = - UV/VV;
	
				local V ={};
				local U ={};
				local t;

				V.x = 0.0;
				V.y = 0.0;
				V.z = 0.0;

				AI.GetAttentionTargetPosition( entity.id, U );
				AI.GetAttentionTargetDirection( entity.id, V );

				AI.LogEvent(entity:GetName().." OnObjectSeen U "..U.x..","..U.y..","..U.z);
				AI.LogEvent(entity:GetName().." OnObjectSeen V "..V.x..","..V.y..","..V.z);

				if ( LengthVector( V ) > 0.0 ) then

					SubVectors( U, U, entity:GetPos() );

					local t = dotproduct3d( U , V ) * -1.0 / dotproduct3d( V , V );

					--AI.LogEvent(entity:GetName().." OnObjectSeen t "..t);

					-- when t<0 there is no possibility the rocket hits the scout.
					if ( t > 0 ) then

						local P = {};

						FastScaleVector( P, V, t );
						FastSumVectors( P, P, U );

						-- if the distance from the Scout to the rocket line is less than 15.0,
						-- there is a possibility the rocket hits the scout.
						
						local distance = LengthVector( P );
						
						--AI.LogEvent(entity:GetName().." OnObjectSeen distance "..distance);

						local lookDir = {};
						local projectedV = {};

						-- !!!!! entity:GetDirectionVector(1) means back direction of the scout
						CopyVector( lookDir , entity:GetDirectionVector(1) ); 

						ProjectVector( projectedV, V, entity:GetDirectionVector(2) );
						NormalizeVector(projectedV);

						local s = dotproduct3d( lookDir , projectedV );

						--AI.LogEvent(entity:GetName().." OnObjectSeen lookDir    "..lookDir.x..","..lookDir.y..","..lookDir.z);
						--AI.LogEvent(entity:GetName().." OnObjectSeen projectedV "..projectedV.x..","..projectedV.y..","..projectedV.z);
						--AI.LogEvent(entity:GetName().." OnObjectSeen inner "..s);

						if ( distance < 10.0 ) then

							-- if it is critical, calcurate the point to run away

							NormalizeVector( P );			
							FastScaleVector( P, P, -10.0 );
							FastSumVectors( P, P, entity:GetPos() );

							AI.SetRefPointPosition( entity.id, P );
							AIBehaviour.SCOUTDEFAULT:scoutAdjustRefPoint( entity, 12.0 );
							if (AIBehaviour.SCOUTDEFAULT:scoutCheckNavOfRef( entity ) == false ) then
								AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_ATTACK", entity.id);
							else
								AI.CreateGoalPipe("scoutEscapeFromRocket");
								AI.PushGoal("scoutEscapeFromRocket","firecmd",0,0);
								AI.PushGoal("scoutEscapeFromRocket","devalue",0,1);
								AI.PushGoal("scoutEscapeFromRocket","run",0,1);		
								AI.PushGoal("scoutEscapeFromRocket","locate",0,"refpoint");		
								AI.PushGoal("scoutEscapeFromRocket","approach",0,1.0,AILASTOPRES_USE,-1);
								AI.PushGoal("scoutEscapeFromRocket","timeout",1,0.5);		
								pat = random( 1, 10 );
								if ( pat == 1 or pat == 2 ) then
									AI.PushGoal("scoutEscapeFromRocket","signal",0,1,"TO_SCOUT_MELEE",SIGNALFILTER_SENDER);
								elseif ( pat == 2 or pat == 4) then
									AI.PushGoal("scoutEscapeFromRocket","signal",0,1,"TO_SCOUT_GRAB",SIGNALFILTER_SENDER);
								elseif ( pat == 5) then
									AI.PushGoal("scoutEscapeFromRocket","signal",0,1,"TO_SCOUT_FLYOVER",SIGNALFILTER_SENDER);
								else
									AI.PushGoal("scoutEscapeFromRocket","signal",0,1,"SC_SCOUT_HOVERATTACK",SIGNALFILTER_SENDER);
								end
								entity:SelectPipe(0,"scoutEscapeFromRocket");
							end
							return;

						elseif ( distance < 30.0 and s > math.cos( 45.0 * 3.1415 / 180.0 ) ) then
							-- to add a feeling that the scout has an emotion
							AI.CreateGoalPipe("scoutLookAtTheRocket");
							AI.PushGoal("scoutLookAtTheRocket","firecmd",0,0);
							AI.PushGoal("scoutLookAtTheRocket","timeout",1,1.5);
							AI.PushGoal("scoutLookAtTheRocket","devalue",0,1);
							AI.PushGoal("scoutLookAtTheRocket","signal",0,1,"SC_SCOUT_HOVERATTACK",SIGNALFILTER_SENDER);
							entity:SelectPipe(0,"scoutLookAtTheRocket");
							return;
						end
					end
				end
			end
		end

		entity:InsertSubpipe(0,"devalue_target");

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
--		if ( entity.AI.bBlockSignal ==true ) then

--		end

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			if ( target.AI.theVehicle == nil ) then

				if ( AIBehaviour.SCOUTDEFAULT:scoutListUpObjects( entity ) == true ) then
					AI.LogEvent(" OnEnemyMemory : selected grab attack for "..target:GetName());
					AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_GRAB", entity.id);
				else
					local pat = random(1,5);
					if ( pat < 5 ) then
						AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_PICKATTACK", entity.id);
					else
						AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_GRAB", entity.id);
					end
				end			

			end

		end

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

		if ( entity.AI.bBlockSignal ==true ) then
		
		else

			local damage = entity.AI.lastHealth - entity.actor:GetHealth();
			local maxHealth = entity.actor:GetMaxHealth();
			local pat;

			damage = maxHealth;
			if ( damage < maxHealth * 0.10) then

				pat = random( 1, 12 );
				if ( pat == 1 or pat == 2 ) then
					AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_MELEE", entity.id);
				elseif ( pat == 3 or pat == 4) then
					AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_GRAB", entity.id);
				elseif ( pat == 5) then
					AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_FLYOVER", entity.id);
				else
				end
		
			else
				pat = random( 1, 8 );
				if ( pat == 1 or pat == 2 ) then
					AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_MELEE", entity.id);
				elseif ( pat == 3 or pat == 4) then
					AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_GRAB", entity.id);
				elseif ( pat == 5) then
					AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_FLYOVER", entity.id);
				else
				end
			end

		end

		entity.AI.lastHealth =	entity.actor:GetHealth();
		
	end,
	---------------------------------------------
	OnDamage = function ( self, entity, sender, data )
	end,
	---------------------------------------------
	OnGroupMemberDied = function( self, entity, sender )
		-- called when a member of same species dies nearby
		AI.Signal(SIGNALFILTER_GROUPONLY, 1, "TO_SCOUT_ATTACK", entity.id);
	end,

	--------------------------------------------------------------------------
	SC_SCOUT_STAY_ATTACK = function( self, entity )
		
		AIBehaviour.SCOUTDEFAULT:scoutGetID( entity );
		AIBehaviour.SCOUTDEFAULT:scoutDoStayAttack( entity );

	end,
	--------------------------------------------------------------------------
	--------------------------------------------------------------------------
	SC_SCOUT_HOVERATTACK_START = function( self, entity )

		entity.AI.bBlockEscape = false;

		AIBehaviour.SCOUTDEFAULT:scoutGetID( entity );
		-- called when the behaviour is selected

		if ( entity.AI.stayPosition == 1 ) then

		else
			AI.CreateGoalPipe("scoutHoverAttackDefault2");
			AI.PushGoal("scoutHoverAttackDefault2","timeout",1,0.3);
			AI.PushGoal("scoutHoverAttackDefault2","signal",0,1,"SC_SCOUT_STAY_ATTACK",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"scoutHoverAttackDefault2");
		end

		entity.AI.bBlockSignal = true;

		local vScale ={};
		
		vScale.x =1.0;
		vScale.y =1.0;
		vScale.z =1.0;

		AIBehaviour.SCOUTDEFAULT:scoutRefreshStayAttackPosition( entity );

		local point1 = {};
		local point2 = {};
		local point1Unit = {};
		local point2Unit = {};
		local vTmp = {};
		local vR ={};
		local point1RUnit = {};

		if ( random( 1,2 ) == 1 ) then

			-- point1
			FastScaleVector( vTmp, entity.AI.vFwdUnit, 40.0 );
			CopyVector( point1, vTmp );
			FastScaleVector( vTmp, entity.AI.vWngUnit, -30.0 );
			FastSumVectors( point1, point1, vTmp );
			FastScaleVector( vTmp, entity.AI.vUpUnit, 10.0 );
			FastSumVectors( point1, point1, vTmp );
			CopyVector( point1Unit, point1 );
			NormalizeVector( point1Unit );

			-- point2
			FastScaleVector( vTmp, entity.AI.vFwdUnit, 40.0 );
			CopyVector( point2, vTmp );
			FastScaleVector( vTmp, entity.AI.vWngUnit, 30.0 );
			FastSumVectors( point2, point2, vTmp );
			FastScaleVector( vTmp, entity.AI.vUpUnit, 14.0 );
			FastSumVectors( point2, point2, vTmp );
			CopyVector( point2Unit, point2 );
			NormalizeVector( point2Unit );
	
		else
		
			-- point1
			FastScaleVector( vTmp, entity.AI.vFwdUnit, 40.0 );
			CopyVector( point1, vTmp );
			FastScaleVector( vTmp, entity.AI.vWngUnit, 30.0 );
			FastSumVectors( point1, point1, vTmp );
			FastScaleVector( vTmp, entity.AI.vUpUnit, 10.0 );
			FastSumVectors( point1, point1, vTmp );
			CopyVector( point1Unit, point1 );
			NormalizeVector( point1Unit );

			-- point2
			FastScaleVector( vTmp, entity.AI.vFwdUnit, 40.0 );
			CopyVector( point2, vTmp );
			FastScaleVector( vTmp, entity.AI.vWngUnit, -30.0 );
			FastSumVectors( point2, point2, vTmp );
			FastScaleVector( vTmp, entity.AI.vUpUnit, 14.0 );
			FastSumVectors( point2, point2, vTmp );
			CopyVector( point2Unit, point2 );
			NormalizeVector( point2Unit );

		end

		-- a center of the rotation
		crossproduct3d( vR, point1, point2 );
		NormalizeVector( vR );

		-- get an angle between point1 and point2
		RotateVectorAroundR( point1RUnit, point1Unit, vR ,3.1416*90.0/180.0 );

		local dot = dotproduct3d( point1Unit, point2Unit );
		local dotRot = dotproduct3d( point1RUnit, point2Unit );
		local mark = sgn(dot) * sgn(dotRot); 
		local angle = math.acos(dot) * mark;

		-- set paramters
		entity.AI.hoverCount = 0.0;
		entity.AI.hoverAngle = angle;
		CopyVector( entity.AI.hoverVec, point1 );
		CopyVector( entity.AI.hoverR, vR );

		-- start behavior
		
		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			AI.ChangeParameter( entity.id, AIPARAM_STRAFINGPITCH , 10.0 );
		
			local hoverStartPos = {};
			CopyVector( hoverStartPos, point1 );
			FastSumVectors( hoverStartPos, hoverStartPos, target:GetPos() );
			AI.SetRefPointPosition( entity.id, hoverStartPos );
			AIBehaviour.SCOUTDEFAULT:scoutAdjustRefPoint( entity, 20.0 );
			if (AIBehaviour.SCOUTDEFAULT:scoutCheckNavOfRef( entity ) == false ) then
				if ( random( 1,5 ) == 1 ) then
					AI.CreateGoalPipe("scoutHoverAttackEnd");
					AI.PushGoal("scoutHoverAttackEnd","firecmd",0,FIREMODE_FORCED);
					AI.PushGoal("scoutHoverAttackEnd","timeout",1,3.0);	
					AI.PushGoal("scoutHoverAttackEnd","firecmd",0,0);	
					AI.PushGoal("scoutHoverAttackEnd","timeout",1,3.0);	
					AI.PushGoal("scoutHoverAttackEnd","signal",0,1,"TO_SCOUT_ATTACK",SIGNALFILTER_SENDER);
					entity:SelectPipe(0,"scoutHoverAttackEnd");
				else
					AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_ATTACK", entity.id);
				end
				return;
			end

			AI.CreateGoalPipe("scoutHoverAttackStart");
			AI.PushGoal("scoutHoverAttackStart","firecmd",0,FIREMODE_FORCED);
			if (AIBehaviour.SCOUTDEFAULT:scoutGetDistanceOfPoints( hoverStartPos, entity:GetPos() )>25.0 ) then
				AI.PushGoal("scoutHoverAttackStart","run",0,1);	
			else
				AI.PushGoal("scoutHoverAttackStart","run",0,0);
			end	
			AI.PushGoal("scoutHoverAttackStart","continuous",0,1);		
			AI.PushGoal("scoutHoverAttackStart","locate",0,"refpoint");		
			AI.PushGoal("scoutHoverAttackStart","approach",1,20.0,AILASTOPRES_USE,-1);
			AI.PushGoal("scoutHoverAttackStart","firecmd",0,0);
			AI.PushGoal("scoutHoverAttackStart","run",0,0);	
			AI.PushGoal("scoutHoverAttackStart","locate",0,"refpoint");		
			AI.PushGoal("scoutHoverAttackStart","approach",1,4.0,AILASTOPRES_USE,-1);
			AI.PushGoal("scoutHoverAttackStart","firecmd",0,0);	
			AI.PushGoal("scoutHoverAttackStart","signal",0,1,"SC_SCOUT_HOVERATTACK",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"scoutHoverAttackStart");

		else
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_ATTACK", entity.id);
		end

	end,

	SC_SCOUT_HOVERATTACK = function( self, entity )

		-- specific. if the target is on the boat.
		if ( scoutSelected == nil ) then
			local target = AI.GetAttentionTargetEntity( entity.id );
			if ( target and AI.Hostile( entity.id, target.id ) ) then
				if ( AI.GetTypeOf( target.id ) ~= AIOBJECT_VEHICLE ) then
					local vehicleId = target.actor:GetLinkedVehicleId();
					if ( vehicleId ) then
						if ( AI.GetTypeOf( vehicleId ) == AIOBJECT_VEHICLE and AI.GetSubTypeOf( vehicleId ) == AIOBJECT_BOAT ) then
							AI.Signal(SIGNALFILTER_SENDER, 1, "TO_SCOUT_ATTACKVEHICLE", entity.id);
							scoutSelected = entity.id;
							return;
						end
					end
				end
			end
		end

		entity.AI.bBlockEscape = false;
		entity.AI.bBlockSignal = false;

		entity.gameParams.forceView = 40.0;
		entity.actor:SetParams(entity.gameParams);

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) and entity.AI.hoverCount < 3.1 ) then


			local angle = entity.AI.hoverAngle * entity.AI.hoverCount /3.0;
			local refpos = {};
			
			-- get an angle between point1 and point2
			RotateVectorAroundR( refpos, entity.AI.hoverVec, entity.AI.hoverR , angle );
			FastSumVectors( refpos, refpos, target:GetPos() );
			
			entity:SelectPipe(0,"do_nothing");
			AI.SetRefPointPosition( entity.id, refpos );
			AIBehaviour.SCOUTDEFAULT:scoutAdjustRefPoint( entity, 10.0 );
			if (AIBehaviour.SCOUTDEFAULT:scoutCheckNavOfRef( entity ) == false ) then
				AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_ATTACK", entity.id);
				return;
			end

			if ( entity.AI.hoverCount > 0.0 ) then
				if ( AIBehaviour.SCOUTDEFAULT:scoutGetDistanceOfPoints( entity:GetPos(), refpos ) > 120.0 ) then
					AI.Signal(SIGNALFILTER_SENDER,1,"SC_SCOUT_HOVERATTACK_START", entity.id);
					return;
				end
			end

			local targetType = AI.GetTargetType( entity.id );
			if( targetType == AITARGET_MEMORY ) then
				self:OnEnemyMemory( entity );
			end

			AI.CreateGoalPipe("scoutHoverAttack");
			local pat = random( 1,4 );
			pat = 4;
			if ( pat < 3 ) then
				AI.PushGoal("scoutHoverAttack","run",0,0);	
				AI.PushGoal("scoutHoverAttack","firecmd",0,FIREMODE_FORCED);	
				AI.PushGoal("scoutHoverAttack","continuous",0,1);		
				AI.PushGoal("scoutHoverAttack","locate",0,"refpoint");		
				AI.PushGoal("scoutHoverAttack","approach",1,3.0,AILASTOPRES_USE,-1);
				AI.PushGoal("scoutHoverAttack","firecmd",0,0);	
				AI.PushGoal("scoutHoverAttack","signal",0,1,"SC_SCOUT_HOVERATTACK",SIGNALFILTER_SENDER);
			elseif ( pat == 3) then
				AI.PushGoal("scoutHoverAttack","run",0,0);	
				AI.PushGoal("scoutHoverAttack","firecmd",0,FIREMODE_FORCED);	
				AI.PushGoal("scoutHoverAttack","continuous",0,1);		
				AI.PushGoal("scoutHoverAttack","locate",0,"refpoint");		
				AI.PushGoal("scoutHoverAttack","approach",1,3.0,AILASTOPRES_USE,-1);
				AI.PushGoal("scoutHoverAttack","firecmd",0,0);	
				AI.PushGoal("scoutHoverAttack","signal",0,1,"SC_SCOUT_LINE_SHOOT_START",SIGNALFILTER_SENDER);
			else

				pat = random( 1,2 );

				if ( pat == 1 ) then
					if ( AI.GetTypeOf( target.id ) == AIOBJECT_VEHICLE and AI.GetSubTypeOf( target.id ) == AIOBJECT_HELICOPTER ) then
						AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_MELEE", entity.id);
						return;
					end
					if ( target.AI.theVehicle ~=nil ) then
						AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_MELEE", entity.id);
						return;
					end
				end

				AI.PushGoal("scoutHoverAttack","run",0,0);	
				AI.PushGoal("scoutHoverAttack","firecmd",0,0);	
				AI.PushGoal("scoutHoverAttack","continuous",0,1);		
				AI.PushGoal("scoutHoverAttack","locate",0,"refpoint");		
				AI.PushGoal("scoutHoverAttack","approach",1,3.0,AILASTOPRES_USE,-1);
				AI.PushGoal("scoutHoverAttack","signal",0,1,"SC_SCOUT_ROUND_SHOOT_START",SIGNALFILTER_SENDER);

			end

			entity:SelectPipe(0,"scoutHoverAttack");

			entity.AI.hoverCount = entity.AI.hoverCount +1;

		else
			if ( random(1,2) ==2 ) then
				AI.Signal(SIGNALFILTER_SENDER,1,"SC_SCOUT_HOVER_CLOSER", entity.id);							
			else
				AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_ATTACK", entity.id);							
			end
		end

	end,

	SC_SCOUT_HOVERATTACK_WAIT = function( self, entity ) 

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			local	pos = {};
			CopyVector( pos, entity:GetPos() );
--			FastSumVectors( pos, pos, target:GetDirectionVector(2) );
			FastSumVectors( pos, pos, target:GetDirectionVector(2) );
			FastSumVectors( pos, pos, target:GetDirectionVector(2) );
			FastSumVectors( pos, pos, target:GetDirectionVector(2) );

			AI.SetRefPointPosition( entity.id, pos );
			AIBehaviour.SCOUTDEFAULT:scoutAdjustRefPoint( entity, 10.0 );
			if (AIBehaviour.SCOUTDEFAULT:scoutCheckNavOfRef( entity ) == false ) then
				AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_ATTACK", entity.id);
				return;
			end
			AI.CreateGoalPipe("scoutHoverAttackWait");
			AI.PushGoal("scoutHoverAttackWait","locate",0,"refpoint");
			AI.PushGoal("scoutHoverAttackWait","approach",1,1.0,AILASTOPRES_USE,-1);
			AI.PushGoal("scoutHoverAttackWait","timeout",1,2);	
			AI.PushGoal("scoutHoverAttackWait","signal",0,1,"SC_SCOUT_HOVERATTACK",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"scoutHoverAttackWait");

		else

			AI.CreateGoalPipe("scoutHoverAttackWaitV2");
			AI.PushGoal("scoutHoverAttackWaitV2","timeout",1,2);	
			AI.PushGoal("scoutHoverAttackWaitV2","signal",0,1,"SC_SCOUT_HOVERATTACK",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"scoutHoverAttackWaitV2");
	
		end

	end,
	
	--------------------------------------------------------------------------
	SC_SCOUT_ROUND_SHOOT_START = function( self, entity ) 

		entity.AI.bBlockEscape = false;

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			entity.AI.bBlockSignal = true;

			local	vPos = {};
	
			FastScaleVector( vPos, target:GetDirectionVector(2), 2.0 );
			FastSumVectors( vPos, vPos, entity:GetPos() );

			AI.SetRefPointPosition( entity.id, vPos );
			AIBehaviour.SCOUTDEFAULT:scoutAdjustRefPoint( entity, 10.0 );
			if (AIBehaviour.SCOUTDEFAULT:scoutCheckNavOfRef( entity ) == false ) then
				AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_ATTACK", entity.id);
				return;
			end
			AI.CreateGoalPipe("roundShootStart");
			AI.PushGoal("roundShootStart","continuous",0,1);
			AI.PushGoal("roundShootStart","locate",0,"refpoint");
			AI.PushGoal("roundShootStart","approach",1,1.0,AILASTOPRES_USE,-1);
			AI.PushGoal("roundShootStart","signal",0,1,"SC_SCOUT_ROUND_SHOOT",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"roundShootStart");

		else
			AI.Signal(SIGNALFILTER_SENDER, 1, "SC_SCOUT_HOVERATTACK", entity.id);
		end

	end,

	SC_SCOUT_ROUND_SHOOT = function( self, entity ) 
	
		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			if ( random(1,2) == 1 ) then
				entity.AI.roundShootAngle = -3.1416 * 30.0 / 180.0;
				entity.AI.roundShootAngleAdd = 3.1416 * 5.0 / 180.0;
			else
				entity.AI.roundShootAngle = 3.1416 * 30.0 / 180.0;
				entity.AI.roundShootAngleAdd = -3.1416 * 5.0 / 180.0;
			end		
			entity.AI.roundShootVec = {};
			entity.AI.roundUpVec = {};

			CopyVector( entity.AI.roundUpVec, target:GetDirectionVector(2) );
			SubVectors( entity.AI.roundShootVec, target:GetPos(), entity:GetPos() );
			
			local shootPos = {};
			local projectedShootPos = {};

			RotateVectorAroundR( shootPos, entity.AI.roundShootVec, entity.AI.roundUpVec, entity.AI.roundShootAngle );
			ProjectVector( projectedShootPos, shootPos, entity.AI.roundUpVec )

			local len = LengthVector( projectedShootPos );
			NormalizeVector( projectedShootPos );

			FastSumVectors( shootPos, shootPos, entity:GetPos() );
	
			AI.ChangeParameter( entity.id, AIPARAM_STRAFINGPITCH, 25.0 );
	
			AI.SetRefPointPosition( entity.id, shootPos );
		
			AI.CreateGoalPipe("roundShootTest");
			AI.PushGoal("roundShootTest","ignoreall",0,1);
			AI.PushGoal("roundShootTest","locate",0,"refpoint");
			AI.PushGoal("roundShootTest","acqtarget",0,"");
			AI.PushGoal("roundShootTest","lookat",1,0,0,true);
			AI.PushGoal("roundShootTest","timeout",1,1.0);
			AI.PushGoal("roundShootTest","firecmd",0,FIREMODE_FORCED);
			AI.PushGoal("roundShootTest","timeout",1,1.0);
			for i = 1, 24, 1 do
				AI.PushGoal("roundShootTest","lookat",1,0,0,true);
				AI.PushGoal("roundShootTest","signal",0,1,"SC_SCOUT_ROUND_SHOOT_REFLESH",SIGNALFILTER_SENDER);
			end
			AI.PushGoal("roundShootTest","firecmd",0,0);
			AI.PushGoal("roundShootTest","locate",0,"player");
			AI.PushGoal("roundShootTest","acqtarget",0,"");
			AI.PushGoal("roundShootTest","ignoreall",0,0);
			AI.PushGoal("roundShootTest","timeout",0,0.5);
			AI.PushGoal("roundShootTest","signal",0,1,"SC_SCOUT_ROUND_SHOOT_END",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"roundShootTest");

		else
			AI.Signal(SIGNALFILTER_SENDER, 1, "SC_SCOUT_HOVERATTACK", entity.id);
		end
		
	end,
	
	SC_SCOUT_ROUND_SHOOT_END = function( self, entity ) 

		entity.AI.bBlockSignal = false;
		
		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then
			AI.SetRefPointPosition( entity.id, target:GetPos() );
			AI.CreateGoalPipe("roundShootTestEnd");
			AI.PushGoal("roundShootTestEnd","locate",0,"refpoint");
			AI.PushGoal("roundShootTestEnd","lookat",1,0,0,true);
			AI.PushGoal("roundShootTestEnd","timeout",1,0.3);	
			AI.PushGoal("roundShootTestEnd","signal",0,1,"SC_SCOUT_HOVERATTACK",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"roundShootTestEnd");
		end

	end,
	
	SC_SCOUT_ROUND_SHOOT_REFLESH = function( self, entity ) 

			entity.AI.roundShootAngle = entity.AI.roundShootAngle + entity.AI.roundShootAngleAdd;

			local shootPos = {};
			local projectedShootPos = {};

			RotateVectorAroundR( shootPos, entity.AI.roundShootVec, entity.AI.roundUpVec, entity.AI.roundShootAngle );
			ProjectVector( projectedShootPos, shootPos, entity.AI.roundUpVec )

			local len = LengthVector( projectedShootPos );
			NormalizeVector( projectedShootPos );

			FastSumVectors( shootPos, shootPos, entity:GetPos() );
			FastSumVectors( shootPos, shootPos, projectedShootPos );
			AI.SetRefPointPosition( entity.id, shootPos );

	end,

	--------------------------------------------------------------------------
	SC_SCOUT_LINE_SHOOT_START = function( self, entity ) 

		entity.AI.bBlockEscape = false;
		self:SC_SCOUT_LINE_SHOOT( entity );

	end,
	
	SC_SCOUT_LINE_SHOOT = function( self, entity ) 

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

		local	vPos = {};
		RotateVectorAroundR( vPos, entity:GetDirectionVector(2), target:GetDirectionVector(2) ,3.1416 /2.0);
		FastScaleVector( vPos, target:GetDirectionVector(2), 3.0 );
		FastSumVectors( vPos, vPos, entity:GetPos() );
		
		AI.ChangeParameter( entity.id, AIPARAM_STRAFINGPITCH, 20.0 );

		AI.SetRefPointPosition( entity.id, vPos );
		AI.CreateGoalPipe("scoutLineShoot");
		AI.PushGoal("scoutLineShoot","continuous",0,1);		
		AI.PushGoal("scoutLineShoot","locate",0,"refpoint");
		AI.PushGoal("scoutLineShoot","firecmd",0,FIREMODE_FORCED);
		AI.PushGoal("scoutLineShoot","approach",0,1.0,AILASTOPRES_USE,-1);
		AI.PushGoal("scoutLineShoot","timeout",1,2.0);	
		AI.PushGoal("scoutLineShoot","continuous",0,0);		
		AI.PushGoal("scoutLineShoot","timeout",1,1.0);	
		AI.PushGoal("scoutLineShoot","firecmd",0,0);
		AI.PushGoal("scoutLineShoot","timeout",1,1);
		if ( random( 1,3 ) ==1 ) then
			AI.PushGoal("scoutLineShoot","signal",0,1,"TO_SCOUT_FLYOVER",SIGNALFILTER_SENDER);
		else
			AI.PushGoal("scoutLineShoot","signal",0,1,"SC_SCOUT_HOVERATTACK",SIGNALFILTER_SENDER);
		end
		entity:SelectPipe(0,"scoutLineShoot");

		end

	end,


	--------------------------------------------------------------------------
	SC_SCOUT_HOVER_CLOSER = function( self, entity )

		entity.AI.bBlockEscape = true;

		entity.gameParams.forceView = 0.0;
		entity.actor:SetParams(entity.gameParams);

		AIBehaviour.SCOUTDEFAULT:scoutRefreshStayAttackPosition( entity );

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			local vTarget = {};
			AIBehaviour.SCOUTDEFAULT:scoutGetScaledDirectionVector(entity,vTarget,target:GetPos(),entity:GetPos(),1.0 );

			local dot = dotproduct3d( vTarget, target:GetDirectionVector(0) );
			local dotRot = dotproduct3d( vTarget, target:GetDirectionVector(1) );
			local mark = sgn(dot) * sgn(dotRot); 

			local vTmp = {};

			if ( mark > 0 ) then -- if the scout is in the right side of the player.

				FastScaleVector( vTmp, entity.AI.vWngUnit, -40.0 );
				FastSumVectors( entity.AI.closeVec1, entity:GetPos(), vTmp );
				FastScaleVector( vTmp, entity.AI.vFwdUnit, 10.0 );
				FastSumVectors( entity.AI.closeVec1, entity.AI.closeVec1, vTmp );

				FastScaleVector( vTmp, entity.AI.vUpUnit, 15.0 );
				FastSumVectors( entity.AI.closeVec2, entity.AI.closeVec1, vTmp );
				FastScaleVector( vTmp, entity.AI.vWngUnit, -40.0 );
				FastSumVectors( entity.AI.closeVec2, entity.AI.closeVec2, vTmp );


			else

				FastScaleVector( vTmp, entity.AI.vWngUnit, 40.0 );
				FastSumVectors( entity.AI.closeVec1, entity:GetPos(), vTmp );
				FastScaleVector( vTmp, entity.AI.vFwdUnit, 10.0 );
				FastSumVectors( entity.AI.closeVec1, entity.AI.closeVec1, vTmp );

				FastScaleVector( vTmp, entity.AI.vUpUnit, 15.0 );
				FastSumVectors( entity.AI.closeVec2, entity.AI.closeVec1, vTmp );
				FastScaleVector( vTmp, entity.AI.vWngUnit, 40.0 );
				FastSumVectors( entity.AI.closeVec2, entity.AI.closeVec2, vTmp );

		
			end

			AI.SetRefPointPosition( entity.id, entity.AI.closeVec1 );
			AIBehaviour.SCOUTDEFAULT:scoutAdjustRefPoint( entity, 12.0 );
			if (AIBehaviour.SCOUTDEFAULT:scoutCheckNavOfRef( entity ) == false ) then
				AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_ATTACK", entity.id);
				return;
			end
			
			AI.CreateGoalPipe("scoutHoverCloseV1");
			AI.PushGoal("scoutHoverCloseV1","firecmd",0,0);
			AI.PushGoal("scoutHoverCloseV1","continuous",0,1);
			AI.PushGoal("scoutHoverCloseV1","run",0,0);
			AI.PushGoal("scoutHoverCloseV1","locate",0,"refpoint");
			AI.PushGoal("scoutHoverCloseV1","approach",0,3.0,AILASTOPRES_USE,-1);
			AI.PushGoal("scoutHoverCloseV1","timeout",1,2.0);
			AI.PushGoal("scoutHoverCloseV1","signal",0,1,"SC_SCOUT_HOVER_CLOSER_B",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"scoutHoverCloseV1");
		
		else
		end

	end,

	SC_SCOUT_HOVER_CLOSER_B = function( self, entity )

			AI.CreateGoalPipe("scoutHoverCloseV1_b");
			AI.PushGoal("scoutHoverCloseV1_b","run",0,1);
			AI.PushGoal("scoutHoverCloseV1_b","locate",0,"refpoint");
			AI.PushGoal("scoutHoverCloseV1_b","approach",1,3.0,AILASTOPRES_USE,-1);
			AI.PushGoal("scoutHoverCloseV1_b","signal",0,1,"SC_SCOUT_HOVER_CLOSER2",SIGNALFILTER_SENDER);
			AI.PushGoal("scoutHoverCloseV1_b","run",0,1);
			AI.PushGoal("scoutHoverCloseV1_b","continuous",0,0);
			AI.PushGoal("scoutHoverCloseV1_b","locate",0,"refpoint");
			AI.PushGoal("scoutHoverCloseV1_b","approach",1,3.0,AILASTOPRES_USE,-1);
			AI.PushGoal("scoutHoverCloseV1_b","firecmd",0,FIREMODE_FORCED);
			AI.PushGoal("scoutHoverCloseV1_b","timeout",1,2.5);
			AI.PushGoal("scoutHoverCloseV1_b","firecmd",0,0);
			if ( random( 1,5 ) ==1 ) then
				AI.PushGoal("scoutHoverCloseV1_b","signal",0,1,"TO_SCOUT_FLYOVER",SIGNALFILTER_SENDER);
			else
				AI.PushGoal("scoutHoverCloseV1_b","signal",0,1,"TO_SCOUT_ATTACK",SIGNALFILTER_SENDER);
			end
			entity:SelectPipe(0,"scoutHoverCloseV1_b");

	end,

	SC_SCOUT_HOVER_CLOSER2 = function( self, entity )

			entity.gameParams.forceView = entity.AI.rsvForceView;
			entity.actor:SetParams(entity.gameParams);

			AI.SetRefPointPosition( entity.id, entity.AI.closeVec2 );
			AIBehaviour.SCOUTDEFAULT:scoutAdjustRefPoint( entity, 0.0 );
			AI.ChangeParameter( entity.id, AIPARAM_STRAFINGPITCH, 20.0 );
			if (AIBehaviour.SCOUTDEFAULT:scoutCheckNavOfRef( entity ) == false ) then
				AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_ATTACK", entity.id);
				return;
			end

	end

	--------------------------------------------------------------------------

}
