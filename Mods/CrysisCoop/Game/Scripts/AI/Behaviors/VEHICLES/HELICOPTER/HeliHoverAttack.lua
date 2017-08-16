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
local function HeliGetDistanceToTheRefPoint( entity )

	local vRefPos = {};

	CopyVector( vRefPos, AI.GetRefPointPosition( entity.id ) );
	SubVectors( vRefPos, vRefPos, entity:GetPos() );
	
	local distance = LengthVector( vRefPos );
	
	return distance;

end

local Xaxis =0;
local Yaxis =1;
local Zaxis =2;

AIBehaviour.HeliHoverAttack = {
	Name = "HeliHoverAttack",
	Base = "HeliBase",
	alertness = 2,
	--------------------------------------------------------------------------
	Constructor = function ( self, entity, data )

		-- for signals
		entity.AI.bBlockSignal = true;

		-- for common signal handlers.

		entity.AI.heliDefaultSignal = "TO_HELI_ATTACK";
		entity.AI.heliMemorySignal = "TO_HELI_PICKATTACK";

		entity.AI.roundDirection = 1.0;
		if ( random( 0, 1 ) == 0 ) then
			entity.AI.roundDirection = -1.0;
		end

		entity.AI.lastPat = 2;
		entity.AI.evadeCount = 0;

		AI.CreateGoalPipe("heliJustStay2");
		AI.PushGoal("heliJustStay2","signal",1,1,"HELI_HOVER_ENABLE_REACTION",SIGNALFILTER_SENDER);
		AI.PushGoal("heliJustStay2","signal",1,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
		AI.PushGoal("heliJustStay2","timeout",1,0.3);	
		AI.PushGoal("heliJustStay2","signal",1,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
		AI.PushGoal("heliJustStay2","timeout",1,0.3);	
		AI.PushGoal("heliJustStay2","signal",1,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
		AI.PushGoal("heliJustStay2","timeout",1,0.3);	
		AI.PushGoal("heliJustStay2","signal",1,1,"HELI_HOVER_START_AIMING",SIGNALFILTER_SENDER);
		AI.PushGoal("heliJustStay2","signal",1,1,"HELI_HOVERATTACK_START",SIGNALFILTER_SENDER);

		AI.CreateGoalPipe("heliHoverAttackDefault");
		AI.PushGoal("heliHoverAttackDefault","timeout",1,0.3);
		AI.PushGoal("heliHoverAttackDefault","signal",0,1,"HELI_HOVERATTACK_START",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"heliHoverAttackDefault");

	end,
	
	---------------------------------------------
	Destructor = function ( self, entity, data )

		-- called when the behaviour is de-selected
		-- the extra data is from the signal that is causing the behavior transition

		entity:SelectPipe(0,"do_nothing");

	end,
	--------------------------------------------------------------------------
	TO_HELI_EMERGENCYLANDING = function( self, entity, sender, data )
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

		entity.AI.roundDirection = entity.AI.roundDirection * -1.0;

		local targetEntity
		if ( data and data.id ) then
			targetEntity = System.GetEntity( data.id );
		else
			return;
		end

		if ( targetEntity ) then

		else
			return;
		end

		local bBigDamage = false;
		if ( AI.GetTypeOf( targetEntity.id ) == AIOBJECT_PLAYER ) then
			if ( AI.GetTargetType(entity.id) ~= AITARGET_MEMORY ) then
				if ( targetEntity.inventory ~=nil ) then
					local weapon = targetEntity.inventory:GetCurrentItem();
					if( weapon and weapon.class~=nil and weapon.class == "LAW" ) then
						bBigDamage = true;
					end
				end
			end
		end

		if ( data.fValue > 100.0 ) then
			bBigDamage = true;
		end

		if ( entity.AI.bBlockSignal ==true ) then
			if ( bBigDamage == true ) then
				AIBehaviour.HELIDEFAULT:heliTakeEvadeActionWithBigDamage( entity, "HELI_HOVERATTACK_START", targetEntity );
			end
		elseif ( data.fValue > 0.0 ) then

			if ( entity.AI.isHeliAggressive == nil ) then
				if ( random( 0, 256 ) < 48 ) then
					AIBehaviour.HELIDEFAULT:heliTakeEvadeAction2( entity, "HELI_HOVERATTACK_START", targetEntity );
				else
					AIBehaviour.HELIDEFAULT:heliTakeEvadeAction( entity, "HELI_HOVERATTACK_START", targetEntity );
				end
			else
				if ( random( 0, 256 ) < 128 ) then
					AI.Signal(SIGNALFILTER_SENDER,1,"TO_HELI_FLYOVER", entity.id);
				else
					if ( bBigDamage == true ) then
						AIBehaviour.HELIDEFAULT:heliTakeEvadeActionWithBigDamage( entity, "HELI_HOVERATTACK_START", targetEntity );
					else
						AIBehaviour.HELIDEFAULT:heliTakeEvadeAction( entity, "HELI_HOVERATTACK_START", targetEntity );
					end
				end
			end

		end

	end,
	
	---------------------------------------------
	HELI_TAKE_EVADEACTION = function ( self, entity, sender, data )

		local targetEntity = System.GetEntity( g_localActor.id );

		if ( targetEntity ) then

			if ( entity.AI.bBlockSignal == false ) then

				if ( random( 0, 256 ) < 48 ) then

					AIBehaviour.HELIDEFAULT:heliTakeEvadeAction2( entity, "HELI_HOVERATTACK_START", targetEntity );
					return;

				end

			end
		
			AIBehaviour.HELIDEFAULT:heliTakeEvadeAction( entity, "HELI_HOVERATTACK_START", targetEntity );

		end

	end,	
	
	---------------------------------------------
	HELI_RETREAT = function ( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			local vPos = {};
			local vDir = {};
			local vWng = {};
			local vMyPos = {};
			local vLookPos = {};
			
			CopyVector( vMyPos, entity:GetPos() );
			SubVectors( vDir, target:GetPos(), vMyPos );
			vDir.z = 0;
			NormalizeVector( vDir );
			FastScaleVector( vDir, vDir, -10 );			
			AIBehaviour.HELIDEFAULT:GetIdealWng( entity, vWng, 20.0 );
			vWng.z = 0;

			FastScaleVector( vLookPos, vDir, -1 );			
			FastSumVectors( vLookPos, vLookPos, vWng );
			FastSumVectors( vLookPos, vLookPos, entity:GetPos() );
			
			FastSumVectors( vPos, vDir, entity:GetPos() );
			vDir.z = -5;

			local index = 1;
			AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vPos, index );

			vDir.x = vDir.x +5;
			vDir.z = -10;
			FastSumVectors( vPos, vDir, entity:GetPos() );

			AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vPos, index );

			if ( AIBehaviour.HELIDEFAULT:heliCommitPathLine( entity, index, false ) == false ) then
					return;
			end

			AI.SetRefPointPosition( entity.id , vLookPos ); -- look target

			AI.CreateGoalPipe("heliRetreat");
			AI.PushGoal("heliRetreat","signal",1,1,"HELI_HOVER_DISABLE_REACTION",SIGNALFILTER_SENDER);
			AI.PushGoal("heliRetreat","firecmd",0,0);
			AI.PushGoal("heliRetreat","run",0,2);
			AI.PushGoal("heliRetreat","continuous",0,0);
			AI.PushGoal("heliRetreat","followpath", 0, false, false, false, 0, -1, true );
			AI.PushGoal("heliRetreat","signal",1,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
			AI.PushGoal("heliRetreat","timeout",1,0.2);
			AI.PushGoal("heliRetreat","branch",1,-2);
			AI.PushGoal("heliRetreat","timeout",1,1);
			AI.PushGoal("heliRetreat","signal",0,1,"HELI_HOVERATTACK_START",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"heliRetreat");
			return;
			
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

			if ( entity.AI.isHeliAggressive == nil or entity.AI.bBlockSignal==true ) then
				entity:InsertSubpipe(0,"devalue_target");
				return;
			end
			-- P = U+tV, PV = 0 -> t = - UV/VV;

			local V ={};
			local U ={};
			local t;

			V.x = 0.0;
			V.y = 0.0;
			V.z = 0.0;

			AI.GetAttentionTargetPosition( entity.id, U );
			AI.GetAttentionTargetDirection( entity.id, V );

			if ( LengthVector( V ) > 0.0 ) then

				SubVectors( U, U, entity:GetPos() );

				local t = dotproduct3d( U , V ) * -1.0 / dotproduct3d( V , V );

				-- when t<0 there is no possibility the rocket hits the scout.
				if ( t > 0 ) then

					local P ={};
					local P2 ={};

					FastScaleVector( P, V, t );
					FastSumVectors( P, P, U );

					-- if the distance from the Scout to the rocket line is less than 15.0,
					-- there is a possibility the rocket hits the scout.
					
					local distance = LengthVector( P );
					
					local lookDir = {};
					local projectedV = {};
					
					CopyVector( lookDir , entity:GetDirectionVector(1) );
					ProjectVector( projectedV, V, entity:GetDirectionVector(2) );
					NormalizeVector(projectedV);

					local s = dotproduct3d( lookDir , projectedV );
					if ( distance < 10.0 ) then

						-- calcurate the point to run away

						NormalizeVector( P );			
						FastScaleVector( P2, P, -7.0 );
						FastScaleVector( P, P, -5.0 );
						FastSumVectors( P, P, entity:GetPos() );
						FastSumVectors( P2, P2, entity:GetPos() );

						local index = 1;
				
						AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, P, index );
				
						index = index + 1;
						AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, P2, index );

						if ( AIBehaviour.HELIDEFAULT:heliCheckSpaceVoidMain( entity, index, 15.0 ) == false ) then
							entity:InsertSubpipe(0,"devalue_target");
							return;
						end

						AIBehaviour.HELIDEFAULT:heliCommitPathLineNoCheck( entity,  index, false );
				
						AI.CreateGoalPipe("HeliEvadeLAW");
						AI.PushGoal("HeliEvadeLAW","firecmd",0,0);
						AI.PushGoal("HeliEvadeLAW","run",0,1);
						AI.PushGoal("HeliEvadeLAW","continuous",0,1);
						AI.PushGoal("HeliEvadeLAW","followpath", 1, false, false, false, 0, 40, true );
						entity:InsertSubpipe(0,"HeliEvadeLAW");

					end
				end
			end

			entity:InsertSubpipe(0,"devalue_target");

		end

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
	HELI_HOVERATTACK_START = function( self, entity )

		if ( entity.AI.isHeliAggressive ~= nil ) then
			self:HELI_HOVERATTACK_AGGRASSIVE( entity );
		else
			self:HELI_HOVERATTACK( entity );
		end

	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK = function( self, entity )

		AIBehaviour.HELIDEFAULT:heliGetID( entity );
		AIBehaviour.HELIDEFAULT:heliRefreshStayAttackPosition(entity);

		local heliAttackCenterPos = {};
		AIBehaviour.HELIDEFAULT:heliGetStayAttackPosition( entity, heliAttackCenterPos, 1 );

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			entity:SelectPipe(0,"do_nothing");

			-- select an attack pattern

			if ( entity.AI.isVtol == true ) then
				pat = random( 3, 6 );
			else
				pat = random( 3, 7 );
			end

			-- prevent invoking the same action

			if (pat==entity.AI.lastPat) then
				pat = 3;
			end
			entity.AI.lastPat = pat;

			-- if there is a big difference about z position, adjust it

			local vDef ={};
			SubVectors( vDef, target:GetPos(), entity:GetPos() );

			if ( math.abs( vDef.z ) > 50.0 ) then
	
				FastScaleVector( vDef, vDef, 0.5 );
				vDef.x = 0.0;
				vDef.y = 0.0;
				FastSumVectors( vDef, vDef, entity:GetPos() );

				local vMid = {};
				FastSumVectors( vMid, entity:GetPos(), vDef );
				FastScaleVector( vMid, vMid, 0.5 );

				local index = 1;
				AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vMid, index );
				index = index + 1;
				AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vDef, index );

				if ( AIBehaviour.HELIDEFAULT:heliCommitPathLine( entity, index, false ) == false ) then
					-- just go to the next step if there is a problem about the navigation
					entity:SelectPipe(0,"heliJustStay2");
					return;
				end
	
				AI.CreateGoalPipe("HeliGoDown");
				AI.PushGoal("HeliGoDown","signal",1,1,"HELI_HOVER_ENABLE_REACTION",SIGNALFILTER_SENDER);
				AI.PushGoal("HeliGoDown","locate",0,"atttarget");
				AI.PushGoal("HeliGoDown","lookat",0,0,0,true,1);
				AI.PushGoal("HeliGoDown","firecmd",0,0);
				AI.PushGoal("HeliGoDown","run",0,1);	
				AI.PushGoal("HeliGoDown","continuous",0,0);
				AI.PushGoal("HeliGoDown","followpath", 0, false, false, false, 0, 3.0, true );
				AI.PushGoal("HeliGoDown","signal",1,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
				AI.PushGoal("HeliGoDown","signal",1,1,"HELI_AUTOFIRE_CHECK",SIGNALFILTER_SENDER);
				AI.PushGoal("HeliGoDown","timeout",1,0.2);
				AI.PushGoal("HeliGoDown","branch",1,-3);
				AI.PushGoal("HeliGoDown","signal",1,1,"HELI_HOVER_START_AIMING",SIGNALFILTER_SENDER);
				AI.PushGoal("HeliGoDown","signal",0,1,"HELI_HOVERATTACK_START",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"HeliGoDown");
				return;

			end

			SubVectors( vDef, entity:GetPos(), target:GetPos() );
			vDef.z = 0;
			local bAct = false;
			if ( entity.AI.stayPosition == 1 ) then
				if ( LengthVector( vDef ) < 50.0 ) then
					bAct = true;
				end
			else
				if ( LengthVector( vDef ) < 100.0 ) then
					bAct = true;
				end
			end

			if ( bAct == true ) then



				local vDir = {};
				local vRefPos = {};
				
				SubVectors( vDir, entity:GetPos(), target:GetPos() );
				vDir.z =0;
				NormalizeVector( vDir );

				local vUp = { x=0.0, y=0.0, z=1.0 };
				if ( entity.AI.stayPosition == 1 ) then
					RotateVectorAroundR( vRefPos, vDir, vUp , 3.1416 * 210.0 * entity.AI.roundDirection /180.0 );
					FastScaleVector( vRefPos, vRefPos, 100.0 );
					vRefPos.z = 20.0;
				else
					RotateVectorAroundR( vRefPos, vDir, vUp , 3.1416 * 120.0 * entity.AI.roundDirection /180.0 );
					FastScaleVector( vRefPos, vRefPos, 180.0 );
					vRefPos.z = 30.0;
				end
				FastSumVectors( vRefPos, vRefPos, target:GetPos() );

				local index = 1;
				local vVel = {};
				local vVec = {};
				entity:GetVelocity( vVel );

				FastSumVectors( vVec, vRefPos, entity:GetPos() );
				FastScaleVector( vVec, vVec, 0.5 );
				SubVectors( vVec, vVec, target:GetPos() );
				vVec.z = 0;
				NormalizeVector( vVec );
				if ( entity.AI.stayPosition == 1 ) then
					FastScaleVector( vVec, vVec, 100.0 );
				else
					FastScaleVector( vVec, vVec, 180.0 );
				end

				FastSumVectors( vVec, vVec, target:GetPos() );
				vVec.z = vVec.z + 25.0;

				FastSumVectors( vVel, entity:GetPos(), vVec );
				FastScaleVector( vVel, vVel, 0.5 );

				local index = 1;
				AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vVel, index );

				index = index + 1;
				AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vVec, index );

				index = index + 1;
				AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vRefPos, index );

				if ( AIBehaviour.HELIDEFAULT:heliCommitPathLine( entity, index, false ) == false ) then
					-- just go to the next step if there is a problem about the navigation
					entity:SelectPipe(0,"heliJustStay2");
					return;
				end

				local bRun = 1;
				if ( entity.AI.isVtol == true ) then
					bRun = 0;
				end

				AI.CreateGoalPipe("heliHoverAttack3");
				AI.PushGoal("heliHoverAttack3","signal",1,1,"HELI_HOVER_ENABLE_REACTION",SIGNALFILTER_SENDER);
				AI.PushGoal("heliHoverAttack3","firecmd",0,0);
				AI.PushGoal("heliHoverAttack3","run",0,bRun);	
				AI.PushGoal("heliHoverAttack3","continuous",0,0);
				AI.PushGoal("heliHoverAttack3","followpath", 0, false, false, false, 0, 10, true );
				AI.PushGoal("heliHoverAttack3","signal",1,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
				AI.PushGoal("heliHoverAttack3","signal",1,1,"HELI_AUTOFIRE_CHECK",SIGNALFILTER_SENDER);
				AI.PushGoal("heliHoverAttack3","timeout",1,0.2);
				AI.PushGoal("heliHoverAttack3","branch",1,-3);
				AI.PushGoal("heliHoverAttack3","signal",1,1,"HELI_HOVER_START_AIMING",SIGNALFILTER_SENDER);
				AI.PushGoal("heliHoverAttack3","signal",0,1,"HELI_HOVERATTACK_START",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"heliHoverAttack3");

		
			elseif ( pat < 5 ) then



				local vDir = {};
				local vRefPos = {};
				
				SubVectors( vDir, entity:GetPos(), target:GetPos() );
				vDir.z =0;
				NormalizeVector( vDir );

				local vUp = { x=0.0, y=0.0, z=1.0 };

				if ( entity.AI.stayPosition == 1 ) then
					if ( random(1,3) == 1) then
						RotateVectorAroundR( vRefPos, vDir, vUp , 3.1416 * 90.0 * entity.AI.roundDirection /180.0 );
						FastScaleVector( vRefPos, vRefPos, 100.0 );
					else
						RotateVectorAroundR( vRefPos, vDir, vUp , 3.1416 * 45.0 * entity.AI.roundDirection /180.0 );
						FastScaleVector( vRefPos, vRefPos, 100.0 );
					end
					vRefPos.z = 20.0;
				else
					if ( random(1,3) == 1) then
						RotateVectorAroundR( vRefPos, vDir, vUp , 3.1416 * 60.0 * entity.AI.roundDirection /180.0 );
						FastScaleVector( vRefPos, vRefPos, 180.0 );
					else
						RotateVectorAroundR( vRefPos, vDir, vUp , 3.1416 * 30.0 * entity.AI.roundDirection /180.0 );
						FastScaleVector( vRefPos, vRefPos, 180.0 );
					end
					vRefPos.z = 30.0;
				end
				FastSumVectors( vRefPos, vRefPos, target:GetPos() );

				local points = AIBehaviour.HELIDEFAULT:heliMakePathHover( entity, vRefPos );
				if ( AIBehaviour.HELIDEFAULT:heliCommitPathLine( entity,  points, false ) == false ) then
					-- just go to the next step if there is a problem about the navigation
					entity:SelectPipe(0,"heliJustStay2");
					return;
				end

				AI.CreateGoalPipe("heliHoverAttack2");
				AI.PushGoal("heliHoverAttack2","signal",1,1,"HELI_HOVER_ENABLE_REACTION",SIGNALFILTER_SENDER);
				AI.PushGoal("heliHoverAttack2","locate",0,"atttarget");
				AI.PushGoal("heliHoverAttack2","lookat",0,0,0,true,1);
				AI.PushGoal("heliHoverAttack2","firecmd",0,0);
				AI.PushGoal("heliHoverAttack2","run",0,1);	
				AI.PushGoal("heliHoverAttack2","continuous",0,0);
				AI.PushGoal("heliHoverAttack2","followpath", 0, false, false, false, 0, 10, true );
				AI.PushGoal("heliHoverAttack2","signal",1,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
				AI.PushGoal("heliHoverAttack2","signal",1,1,"HELI_AUTOFIRE_CHECK",SIGNALFILTER_SENDER);
				AI.PushGoal("heliHoverAttack2","timeout",1,0.2);
				AI.PushGoal("heliHoverAttack2","branch",1,-3);
				AI.PushGoal("heliHoverAttack2","signal",1,1,"HELI_HOVER_START_AIMING",SIGNALFILTER_SENDER);
				AI.PushGoal("heliHoverAttack2","signal",0,1,"HELI_HOVERATTACK_START",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"heliHoverAttack2");

			elseif ( pat == 5 ) then
			
				AI.Signal(SIGNALFILTER_SENDER,1,"TO_HELI_FLYOVER", entity.id);
				return;

			elseif ( pat == 6 ) then

				AI.Signal(SIGNALFILTER_SENDER,1,"HELI_LINE_SHOOT", entity.id);
				return;

			elseif ( pat == 7 ) then

				AI.Signal(SIGNALFILTER_SENDER,1,"HELI_STICK_TO_THE_GROUND", entity.id);
				return;

			end

		else
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_HELI_ATTACK", entity.id);							
		end

	end,

	--------------------------------------------------------------------------
	HELI_HOVERATTACK_AGGRASSIVE = function( self, entity )

		AIBehaviour.HELIDEFAULT:heliGetID( entity );
		AIBehaviour.HELIDEFAULT:heliRefreshStayAttackPosition(entity);

		local heliAttackCenterPos = {};
		AIBehaviour.HELIDEFAULT:heliGetStayAttackPosition( entity, heliAttackCenterPos, 1 );

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			entity:SelectPipe(0,"do_nothing");
			-- if there is a big difference about z position, adjust it

			if ( entity.AI.memoryCount and entity.AI.memoryCount > 8 ) then
				entity.AI.memoryCount = 0;
				AI.CreateGoalPipe("AheliShootMissile");
				AI.PushGoal("AheliShootMissile","signal",1,1,"HELI_HOVER_START_AIMING",SIGNALFILTER_SENDER);
				AI.PushGoal("AheliShootMissile","signal",0,1,"HELI_HOVERATTACK_START",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"AheliShootMissile");
				return;
			end

		--------------------------------------------------------------------------------------------------------
		-- see if heli can intimidate the player

			local vDir = {};
			SubVectors( vDir, entity:GetPos(), target:GetPos() );
			if ( random(0,256)< 48 and vDir.z < 30.0 and vDir.z > 10.0 ) then
				vDir.z =0;
				local distance2D = LengthVector( vDir );
				if ( distance2D > 30 and distance2D < 50 ) then
					
					local myPos = {};
					local enemyPos = {};
			
					local vUp = { x=0.0, y=0.0, z= 1.0 };
					local vWng = {};
					local vUpVec ={};
					local vProjectedDir = {};
					local targetPos = {};
					local targetPos2 = {};
			
					CopyVector( myPos, entity:GetPos() );
					AIBehaviour.HELIDEFAULT:heliGetTargetPosition( entity, enemyPos );
			
					NormalizeVector( vDir );
	
					local rand = random(0,360);
					rand = rand * 1.0;
					RotateVectorAroundR( vProjectedDir, vDir, vUp , 3.1416 * rand /180.0 );
					FastScaleVector( vProjectedDir, vProjectedDir, 10.0 );
					FastSumVectors( enemyPos, enemyPos, vProjectedDir );

					SubVectors( vDir, entity:GetPos(), enemyPos );
					vDir.z = 0;
					NormalizeVector( vDir );
					FastScaleVector( vProjectedDir, vDir, 15 );
					FastSumVectors( targetPos, vProjectedDir, enemyPos );
					FastScaleVector( vUpVec, vUp, 8.0 );
					FastSumVectors( targetPos, targetPos, vUpVec );
					
					SubVectors( vDir, entity:GetPos(), enemyPos );
					vDir.z = 0;
					NormalizeVector( vDir );
					FastScaleVector( vProjectedDir, vDir, 0 );
					FastSumVectors( targetPos2, vProjectedDir, enemyPos );
					FastScaleVector( vUpVec, vUp, 10.0 );
					FastSumVectors( targetPos2, targetPos2, vUpVec );
		
					AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, targetPos, 1 );
					AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, targetPos2, 2 );
					if ( AIBehaviour.HELIDEFAULT:heliCheckSpaceVoidMain( entity, 2, 3.0 ) == true ) then
		
						AIBehaviour.HELIDEFAULT:heliCommitPathLineNoCheck( entity,  2, false );
		
						local vDef ={};
						SubVectors( vDef, target:GetPos(), entity:GetPos() );
		
						entity.AI.autoFire = 0;
		
						SubVectors( vDir, targetPos2, entity:GetPos() );
						vDir.z = myPos.z;
						NormalizeVector( vDir );
						FastScaleVector( vDir, vDir, 20.0 );
						FastSumVectors( vDir, vDir, targetPos2 );			
						AI.SetRefPointPosition( entity.id , vDir ); -- look target
		
						AI.CreateGoalPipe("AheliSupriseAttack");
						AI.PushGoal("AheliSupriseAttack","signal",1,1,"HELI_HOVER_ENABLE_REACTION",SIGNALFILTER_SENDER);
						AI.PushGoal("AheliSupriseAttack","continuous",0,1);
						AI.PushGoal("AheliSupriseAttack","locate",0,"refpoint");
						AI.PushGoal("AheliSupriseAttack","lookat",0,0,0,true,1);
						AI.PushGoal("AheliSupriseAttack","firecmd",0,0);
						AI.PushGoal("AheliSupriseAttack","run",0,2);	
						AI.PushGoal("AheliSupriseAttack","followpath", 0, false, false, false, 0, 10, true );
						AI.PushGoal("AheliSupriseAttack","signal",1,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
						AI.PushGoal("AheliSupriseAttack","timeout",1,0.2);
						AI.PushGoal("AheliSupriseAttack","branch",1,-2);
						AI.PushGoal("AheliSupriseAttack","timeout",1,3);
						
						AI.PushGoal("AheliSupriseAttack","signal",0,1,"HELI_HOVERATTACK_START",SIGNALFILTER_SENDER);
						entity:SelectPipe(0,"AheliSupriseAttack");
						return;

					end
				end
			end
		
		--------------------------------------------------------------------------------------------------------
		-- enclose the heli height 10-50m from the player

			local vDef = {};
			SubVectors( vDef, target:GetPos(), entity:GetPos() );
			if ( math.abs( vDef.z ) > 50.0 ) then
	
				FastScaleVector( vDef, vDef, 0.5 );
				vDef.x = 0.0;
				vDef.y = 0.0;
				FastSumVectors( vDef, vDef, entity:GetPos() );

				local vMid = {};
				FastSumVectors( vMid, entity:GetPos(), vDef );
				FastScaleVector( vMid, vMid, 0.5 );

				local index = 1;
				AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vMid, index );
				index = index + 1;
				AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vDef, index );

				if ( AIBehaviour.HELIDEFAULT:heliCommitPathLine( entity, index, false ) == false ) then
					-- just go to the next step if there is a problem about the navigation
					entity:SelectPipe(0,"AheliJustStay2");
					return;
				end
	
				AI.CreateGoalPipe("AheliGoDown");
				AI.PushGoal("AheliGoDown","signal",1,1,"HELI_HOVER_ENABLE_REACTION",SIGNALFILTER_SENDER);
				AI.PushGoal("AheliGoDown","locate",0,"atttarget");
				AI.PushGoal("AheliGoDown","lookat",0,0,0,true,1);
				AI.PushGoal("AheliGoDown","firecmd",0,0);
				AI.PushGoal("AheliGoDown","run",0,1);	
				AI.PushGoal("AheliGoDown","continuous",0,0);
				AI.PushGoal("AheliGoDown","followpath", 0, false, false, false, 0, 3.0, true );
				AI.PushGoal("AheliGoDown","signal",1,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
				AI.PushGoal("AheliGoDown","timeout",1,0.2);
				AI.PushGoal("AheliGoDown","branch",1,-2);
				AI.PushGoal("AheliGoDown","signal",0,1,"HELI_HOVERATTACK_START",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"AheliGoDown");
				return;

			end

			-- enclose the heli 10-50m from the player

			SubVectors( vDef, entity:GetPos(), target:GetPos() );
			vDef.z = 0;
			local bAct = false;
			if ( entity.AI.stayPosition == 1 ) then
				if ( LengthVector( vDef ) > 60.0 ) then
					bAct = true;
				end
			else
				if ( LengthVector( vDef ) < 20.0 ) then
					bAct = true;
				end
			end

			if ( bAct == true ) then

				local vDir = {};
				local vRefPos = {};
				
				SubVectors( vDir, entity:GetPos(), target:GetPos() );
				vDir.z =0;
				NormalizeVector( vDir );

				local vUp = { x=0.0, y=0.0, z=1.0 };

				RotateVectorAroundR( vRefPos, vDir, vUp , 3.1416 * 210.0 * entity.AI.roundDirection /180.0 );
				FastScaleVector( vRefPos, vRefPos, 40.0 );
				vRefPos.z = 5.0;
				FastSumVectors( vRefPos, vRefPos, target:GetPos() );

				local index = 1;
				local vVec = {};

				FastSumVectors( vVec, vRefPos, entity:GetPos() );
				FastScaleVector( vVec, vVec, 0.5 );
				SubVectors( vVec, vVec, target:GetPos() );
				vVec.z = 0;
				NormalizeVector( vVec );
				FastScaleVector( vVec, vVec, 40.0 );

				FastSumVectors( vVec, vVec, target:GetPos() );
				vVec.z = vVec.z + 5.0;

				local index = 1;
				AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vVec, index );

				index = index + 1;
				AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vRefPos, index );

		

				if ( AIBehaviour.HELIDEFAULT:heliCheckSpaceVoidMain( entity, index, 5.0 ) == false ) then
					AI.Signal(SIGNALFILTER_SENDER,1,"TO_HELI_ATTACK", entity.id);
					entity:SelectPipe(0,"heliJustStay2");
					return;
				end

				AIBehaviour.HELIDEFAULT:heliCommitPathLineNoCheck( entity,  index, false );

				local bRun = 1;
	
				AI.CreateGoalPipe("AheliHoverAttack3");
				AI.PushGoal("AheliHoverAttack3","signal",1,1,"HELI_HOVER_ENABLE_REACTION",SIGNALFILTER_SENDER);
				AI.PushGoal("AheliHoverAttack3","firecmd",0,0);
				AI.PushGoal("AheliHoverAttack3","run",0,bRun);	
				AI.PushGoal("AheliHoverAttack3","continuous",0,0);
				AI.PushGoal("AheliHoverAttack3","followpath", 0, false, false, false, 0, 10, true );
				AI.PushGoal("AheliHoverAttack3","signal",1,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
				AI.PushGoal("AheliHoverAttack3","timeout",1,0.2);
				AI.PushGoal("AheliHoverAttack3","branch",1,-2);
				AI.PushGoal("AheliHoverAttack3","signal",0,1,"HELI_HOVERATTACK_START",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"AheliHoverAttack3");

		
			else

				local vDir = {};
				local vRefPos = {};
				
				SubVectors( vDir, entity:GetPos(), target:GetPos() );
				vDir.z =0;
				NormalizeVector( vDir );

				local vUp = { x=0.0, y=0.0, z=1.0 };


 				if ( random(1,3) == 1) then
 					RotateVectorAroundR( vRefPos, vDir, vUp , 3.1416 * 30.0 * entity.AI.roundDirection /180.0 );
 					FastScaleVector( vRefPos, vRefPos, 15.0 );
 				else
 					RotateVectorAroundR( vRefPos, vDir, vUp , 3.1416 * 60.0 * entity.AI.roundDirection /180.0 );
 					FastScaleVector( vRefPos, vRefPos, 40.0 );
				end

				vRefPos.z = 5.0;
				FastSumVectors( vRefPos, vRefPos, target:GetPos() );

				local points = AIBehaviour.HELIDEFAULT:heliMakePathHover2( entity, vRefPos );
				if ( AIBehaviour.HELIDEFAULT:heliCommitPathLine( entity,  points, false ) == false ) then
					-- just go to the next step if there is a problem about the navigation
					entity:SelectPipe(0,"AheliJustStay2");
					return;
				end

				AI.CreateGoalPipe("AheliHoverAttack2");
				AI.PushGoal("AheliHoverAttack2","signal",1,1,"HELI_HOVER_ENABLE_REACTION",SIGNALFILTER_SENDER);
				AI.PushGoal("AheliHoverAttack2","locate",0,"atttarget");
				AI.PushGoal("AheliHoverAttack2","lookat",0,0,0,true,1);
				AI.PushGoal("AheliHoverAttack2","firecmd",0,0);
				AI.PushGoal("AheliHoverAttack2","run",0,1);	
				AI.PushGoal("AheliHoverAttack2","continuous",0,0);
				AI.PushGoal("AheliHoverAttack2","followpath", 0, false, false, false, 0, 10, true );
				AI.PushGoal("AheliHoverAttack2","signal",1,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
				AI.PushGoal("AheliHoverAttack2","timeout",1,0.2);
				AI.PushGoal("AheliHoverAttack2","branch",1,-2);
				AI.PushGoal("AheliHoverAttack2","timeout",1,0.5);
				AI.PushGoal("AheliHoverAttack2","signal",0,1,"HELI_HOVERATTACK_START",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"AheliHoverAttack2");

			end

		else
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_HELI_ATTACK", entity.id);							
		end

	end,

	--------------------------------------------------------------------------
	HELI_LINE_SHOOT = function( self, entity ) 

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then



			local vWng = {};
			local vCheckPos = {};
			local vCheckPos2 = {};
			AIBehaviour.HELIDEFAULT:GetIdealWng( entity, vWng, 15.0 );

			FastSumVectors( vCheckPos, entity:GetPos(), vWng );
			vCheckPos.z = vCheckPos.z + 8;

			SubVectors( vCheckPos2, entity:GetPos(), vWng );
			vCheckPos2.z = vCheckPos.z + 22;

			local vMid = {};
			FastSumVectors( vMid, entity:GetPos(), vCheckPos );
			FastScaleVector( vMid, vMid, 0.5 );

			local index = 1;
			AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vMid, index );
			index = index + 1;
			AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vCheckPos, index );
			index = index + 1;
			AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vCheckPos2, index );

			if ( AIBehaviour.HELIDEFAULT:heliCommitPathLine( entity, index, false ) == false ) then
				entity:SelectPipe(0,"heliJustStay2");
				return;
			end

			AI.SetRefPointPosition( entity.id , target:GetPos() ); -- look target

			AI.CreateGoalPipe("heliLineShoot");
			AI.PushGoal("heliLineShoot","signal",1,1,"HELI_HOVER_ENABLE_REACTION",SIGNALFILTER_SENDER);
			AI.PushGoal("heliLineShoot","firecmd",0,0);
			AI.PushGoal("heliLineShoot","locate",0,"refpoint");
			AI.PushGoal("heliLineShoot","lookat",0,0,0,true,1);
			AI.PushGoal("heliLineShoot","run",0,1);
			AI.PushGoal("heliLineShoot","continuous",0,0);
			AI.PushGoal("heliLineShoot","followpath", 0, false, false, false, 0, 10, true );
			AI.PushGoal("heliLineShoot","signal",1,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
			AI.PushGoal("heliLineShoot","timeout",1,0.2);
			AI.PushGoal("heliLineShoot","branch",1,-2);
			AI.PushGoal("heliLineShoot","firecmd",0,0);
			AI.PushGoal("heliLineShoot","signal",0,1,"HELI_HOVERATTACK_START",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"heliLineShoot");
			return;

		end

		entity:SelectPipe(0,"heliJustStay2");

	end,

	--------------------------------------------------------------------------
	HELI_STICK_TO_THE_GROUND = function( self, entity ) 

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then



			local vMyPos ={};
			local vEnemyPos ={};

			CopyVector( vMyPos, entity:GetPos() );
			CopyVector( vEnemyPos, target:GetPos() );

			if ( math.abs( vMyPos.z - vEnemyPos.z + 10.0 ) < 5.0 ) then
				entity:SelectPipe(0,"heliJustStay2");
				return;
			end

			vMyPos.z = vEnemyPos.z + 7.0;
			FastSumVectors( vMyPos, vMyPos, entity:GetDirectionVector(1) );

			local vMid = {};
			FastSumVectors( vMid, entity:GetPos(), vMyPos );
			FastScaleVector( vMid, vMid, 0.5 );

			local index = 1;
			AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vMid, index );
			index = index + 1;
			AIBehaviour.HELIDEFAULT:heliAddPathLine( entity, vMyPos, index );


			if ( AIBehaviour.HELIDEFAULT:heliCommitPathLine( entity, index, false ) == false ) then
				entity:SelectPipe(0,"heliJustStay2");
				return;
			end

			local bRun = 1;
			if ( entity.AI.isVtol == true ) then
				bRun = 0;
			end

			AI.SetRefPointPosition( entity.id , target:GetPos() ); -- look target
			entity.AI.autoFire = 0;
			entity.AI.autoFireTargetPos = {};
			CopyVector( entity.AI.autoFireTargetPos, target:GetPos() );
			entity.AI.autoFireTargetPos.z = vMyPos.z ;
			
			AI.CreateGoalPipe("StickToTheGround");
			AI.PushGoal("StickToTheGround","signal",1,1,"HELI_HOVER_ENABLE_REACTION",SIGNALFILTER_SENDER);
			AI.PushGoal("StickToTheGround","firecmd",0,0);
			AI.PushGoal("StickToTheGround","locate",0,"refpoint");
			AI.PushGoal("StickToTheGround","lookat",0,0,0,true,1);
			AI.PushGoal("StickToTheGround","timeout",1,2);
			AI.PushGoal("StickToTheGround","run",0,bRun);
			AI.PushGoal("StickToTheGround","continuous",0,0);
			AI.PushGoal("StickToTheGround","followpath", 0, false, false, false, 0, 10, true );
			AI.PushGoal("StickToTheGround","signal",1,1,"HELI_HOVER_CHECK",SIGNALFILTER_SENDER);
			AI.PushGoal("StickToTheGround","signal",1,1,"HELI_AUTOFIRE_CHECK_NOTARGET",SIGNALFILTER_SENDER);
			AI.PushGoal("StickToTheGround","timeout",1,0.2);
			AI.PushGoal("StickToTheGround","branch",1,-3);
			AI.PushGoal("StickToTheGround","signal",0,1,"HELI_HOVERATTACK_START",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"StickToTheGround");
			return;	

		end

		entity:SelectPipe(0,"heliJustStay2");
	
	end,


}

