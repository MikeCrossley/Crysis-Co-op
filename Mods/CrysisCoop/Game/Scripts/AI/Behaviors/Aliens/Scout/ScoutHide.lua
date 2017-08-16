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
--	- 09/02/2006   : Add the combat patroll behavior by Tetsuji
--------------------------------------------------------------------------

--------------------------------------------------------------------------
AIBehaviour.ScoutHide = {
	Name = "ScoutHide",
	Base = "SCOUTDEFAULT",

	--------------------------------------------------------------------------
	Constructor = function ( self, entity, data )

		-- called when the behaviour is selected
		-- the extra data is from the signal that caused the behavior transition

		-- for hiding action
		entity.AI.hidingState = 0;
		entity.AI.hidePat = 0;	
		entity.AI.hidePos = {};
		entity.AI.peepPos = {};
		entity.AI.hideRetryCount = 0;
		entity.AI.bFoundAnchor = false;

		-- for round shooting
		entity.AI.roundShootAngle = 0.0;
		entity.AI.roundShootVec = {};
		entity.AI.roundUpVec = {};

		-- for signals
		entity.AI.bBlockSignal = false;
	
		-- Default action
		AI.CreateGoalPipe("scoutHideDefault");
		AI.PushGoal("scoutHideDefault","timeout",1,0.1);
		AI.PushGoal("scoutHideDefault","signal",0,1,"SC_SCOUT_START_HIDE",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"scoutHideDefault");
		
	end,

	---------------------------------------------
	Destructor = function ( self, entity, data )
		-- called when the behaviour is de-selected
		-- the extra data is from the signal that is causing the behavior transition
	end,

	---------------------------------------------
	OnPathFound = function( self, entity, sender )
		-- called when the AI has requested a path and it's been computed succesfully
	end,	
	--------------------------------------------------------------------------
	OnNoTarget = function( self, entity )
		-- called when the AI stops having an attention target
		if ( entity.AI.bBlockSignal == false ) then 
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_SCOUT_PATROLL", entity.id);
		end
	end,
	---------------------------------------------
	OnSomethingSeen = function( self, entity )
		-- called when the enemy sees a foe which is not a living player
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )

		if ( entity.AI.bBlockSignal==true) then
			return;
		end

		-- called when the AI sees a living enemy
		if ( entity.AI.hidingState==2 ) then
			if (fDistance > 50.0 ) then
				AI.Signal(SIGNALFILTER_SENDER, 1, "SC_SCOUT_GOTO_HIDE", entity.id);
			else
				AI.Signal(SIGNALFILTER_GROUPONLY, 1, "TO_SCOUT_ATTACK", entity.id);
			end
		end

		if ( entity.AI.hidingState==3 ) then
			AI.Signal(SIGNALFILTER_SENDER, 1, "SC_SCOUT_HIDEATTACK", entity.id);
		end
	
	end,
	---------------------------------------------
	OnObjectSeen = function( self, entity, fDistance, data )

		if ( data.iValue == AIOBJECT_RPG) then

			entity.AI.bBlockSignal = true;
			entity.AI.bRoundShooting = false;

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

				if ( LengthVector( V ) > 0.0 ) then

					SubVectors( U, U, entity:GetPos() );

					local t = dotproduct3d( U , V ) * -1.0 / dotproduct3d( V , V );

					-- when t<0 there is no possibility the rocket hits the scout.
					if ( t > 0 ) then

						local P ={};

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
							FastScaleVector( P, P, -10.0 );
							FastSumVectors( P, P, entity:GetPos() );

							AI.SetRefPointPosition( entity.id, P );
							AIBehaviour.SCOUTDEFAULT:scoutAdjustRefPoint( entity, 12.0 );
							if (AIBehaviour.SCOUTDEFAULT:scoutCheckNavOfRef( entity ) == false ) then
								AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_ATTACK", entity.id);
							else
								AI.CreateGoalPipe("scoutEscapeFromRocket");
								AI.PushGoal("scoutEscapeFromRocket","devalue",0,1);
								AI.PushGoal("scoutEscapeFromRocket","run",0,1);		
								AI.PushGoal("scoutEscapeFromRocket","locate",0,"refpoint");		
								AI.PushGoal("scoutEscapeFromRocket","approach",0,1.0,AILASTOPRES_USE,-1);
								AI.PushGoal("scoutEscapeFromRocket","timeout",1,0.5);		
								AI.PushGoal("scoutEscapeFromRocket","signal",0,1,"TO_SCOUT_ATTACK",SIGNALFILTER_SENDER);
								entity:SelectPipe(0,"scoutEscapeFromRocket");
							end
							return;
						elseif ( distance < 30.0 and s > math.cos( 45.0 * 3.1415 / 180.0 ) ) then
							AI.CreateGoalPipe("scoutLookAtTheRocket");
							AI.PushGoal("scoutLookAtTheRocket","firecmd",0,0);
							AI.PushGoal("scoutLookAtTheRocket","timeout",1,1.5);
							AI.PushGoal("scoutLookAtTheRocket","devalue",0,1);
							AI.PushGoal("scoutLookAtTheRocket","signal",0,1,"TO_SCOUT_ATTACK",SIGNALFILTER_SENDER);
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

		if ( entity.AI.bBlockSignal==true) then
			return;
		end

		if ( entity.AI.hidingState==1 ) then
			self:SC_SCOUT_HIDE( entity );
		end
		if ( entity.AI.hidingState==4 ) then
			self:SC_SCOUT_HIDE( entity );
		end

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
		AI.Signal(SIGNALFILTER_GROUPONLY, 1, "TO_SCOUT_ATTACK", entity.id);
	end,
	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender, data )

		-- called when AI is damaged by an enemy AI
		-- data.id = damaging enemy's entity id
		-- local hitter = System.GetEntity(data.id);
		-- local hitterName = hitter:GetName()

		entity.AI.hidePat = entity.AI.hidePat + 1;
		if ( entity.AI.hidePat > 7 ) then
			AI.Signal(SIGNALFILTER_GROUPONLY, 1, "TO_SCOUT_ATTACK", entity.id);
			return;
		end
		if ( entity.AI.hidingState==3 ) then
			AI.Signal(SIGNALFILTER_SENDER, 1, "SC_SCOUT_CHANGE_HIDE", entity.id);
			return;
		end
		if ( entity.AI.hidingState==4 ) then
			AI.Signal(SIGNALFILTER_SENDER, 1, "SC_SCOUT_GOTO_HIDE", entity.id);
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

	--------------------------------------------------------------------------
	SC_SCOUT_START_HIDE = function( self, entity )

		if ( AIBehaviour.SCOUTDEFAULT:scoutSearchHideSpot( entity, entity.AI.hidePos, entity.AI.peepPos ) == true ) then
			entity.AI.bFoundAnchor = true;
			self:SC_SCOUT_CHANGE_HIDE( entity );
		else
			if ( entity.AI.bFoundAnchor == false ) then
				AI.Signal(SIGNALFILTER_SENDER, 1, "TO_SCOUT_ATTACK", entity.id);
			else
				-- reuse last anchor
				self:SC_SCOUT_GOTO_HIDE( entity );
			end
		end

	end,

	--------------------------------------------------------------------------

	SC_SCOUT_GOTO_HIDE = function( self, entity )

		entity:SelectPipe(0,"do_nothing");
		if ( AIBehaviour.SCOUTDEFAULT:scoutSearchHideSpotCheck( entity, entity.AI.hidePos ) == true ) then

			entity.AI.hideRetryCount = 0;
			entity.AI.hidingState = 1;

			AI.SetRefPointPosition( entity.id, entity.AI.hidePos );

			if (AIBehaviour.SCOUTDEFAULT:scoutCheckNavOfRef( entity ) == false ) then
				AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_ATTACK", entity.id);
				return;
			end
		
			AI.CreateGoalPipe("scoutGoToHide");
			AI.PushGoal("scoutGoToHide","run",0,0);	
			AI.PushGoal("scoutGoToHide","locate",0,"refpoint");		
			AI.PushGoal("scoutGoToHide","approach",1,3.0,AILASTOPRES_USE,-1);
			AI.PushGoal("scoutGoToHide","timeout",1,0.5);	
			AI.PushGoal("scoutGoToHide","signal",0,1,"SC_SCOUT_HIDE_FAILED",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"scoutGoToHide");

		else

			entity.AI.hideRetryCount = entity.AI.hideRetryCount +1;
			if ( entity.AI.hideRetryCount > 3 ) then
				local targetEntity = AI.GetAttentionTargetEntity( entity.id );
				if ( targetEntity and AI.Hostile( entity.id, targetEntity.id ) ) then
					if ( entity:GetDistance( targetEntity.id ) < 100.0 ) then				
						AI.Signal(SIGNALFILTER_GROUPONLY, 1, "TO_SCOUT_ATTACK", entity.id);
						return;
					end
				end
				entity.AI.hidingState = 1;
				AI.SetRefPointPosition( entity.id, entity.AI.hidePos );
				if (AIBehaviour.SCOUTDEFAULT:scoutCheckNavOfRef( entity ) == false ) then
					AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_ATTACK", entity.id);
					return;
				end

				AI.CreateGoalPipe("scoutGoToHideV2");
				AI.PushGoal("scoutGoToHideV2","run",0,0);	
				AI.PushGoal("scoutGoToHideV2","locate",0,"refpoint");		
				AI.PushGoal("scoutGoToHideV2","approach",1,3.0,AILASTOPRES_USE,-1);
				AI.PushGoal("scoutGoToHideV2","timeout",1,0.5);	
				AI.PushGoal("scoutGoToHideV2","signal",0,1,"SC_SCOUT_HIDE_FAILED",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"scoutGoToHideV2");
			else
				AI.CreateGoalPipe("scoutSearcHideWait2");
				AI.PushGoal("scoutSearcHideWait2","timeout",1,0.2);	
				AI.PushGoal("scoutSearcHideWait2","signal",0,1,"SC_SCOUT_START_HIDE",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"scoutSearcHideWait2");
			end
		end

	end,

	SC_SCOUT_HIDE = function( self, entity )

		entity.AI.hidingState = 2;

		AI.CreateGoalPipe("scoutHide");
		AI.PushGoal("scoutHide","timeout",1,1.0);	
		AI.PushGoal("scoutHide","timeout",1,random(2,4));
		AI.PushGoal("scoutHide","signal",0,1,"SC_SCOUT_PEEP",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"scoutHide");

	end,

	SC_SCOUT_HIDE_FAILED = function( self, entity )

		local targetName = AI.GetAttentionTargetOf( entity.id );

		if ( targetName ) then
			if ( not System.GetEntityByName(targetName) ) then
				AI.Signal(SIGNALFILTER_SENDER, 1, "SC_SCOUT_PEEP", entity.id);
			else
				AI.CreateGoalPipe("scoutHideAttackV2");
				AI.PushGoal("scoutHideAttackV2","firecmd",0,FIREMODE_FORCED);
				AI.PushGoal("scoutHideAttackV2","timeout",1,3);
				AI.PushGoal("scoutHideAttackV2","firecmd",0,0);
				AI.PushGoal("scoutHideAttackV2","signal",0,1,"SC_SCOUT_START_HIDE",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"scoutHideAttackV2");
			end
		else
			AI.CreateGoalPipe("scoutHideError");
			AI.PushGoal("scoutHideError","timeout",1,random(2,4));
			AI.PushGoal("scoutHideError","signal",0,1,"SC_SCOUT_HIDE_FAILED",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"scoutHideError");
		end


	end,

	SC_SCOUT_PEEP = function( self, entity )

		entity.AI.hidingState = 3;
		
		local vPos = {};
		AI.SetRefPointPosition( entity.id, entity.AI.peepPos );
		if (AIBehaviour.SCOUTDEFAULT:scoutCheckNavOfRef( entity ) == false ) then
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_ATTACK", entity.id);
			return;
		end
		
		AI.CreateGoalPipe("scoutPeep");
		AI.PushGoal("scoutPeep","run",0,0);	
		AI.PushGoal("scoutPeep","locate",0,"refpoint");		
		AI.PushGoal("scoutPeep","approach",1,3.0,AILASTOPRES_USE,-1);
		AI.PushGoal("scoutPeep","timeout",1,2);
		AI.PushGoal("scoutPeep","signal",0,1,"SC_SCOUT_PEEPCHECK",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"scoutPeep");
		
	end,

	SC_SCOUT_PEEPCHECK = function( self, entity )

		local targetType = AI.GetTargetType( entity.id );
		if( targetType == AITARGET_MEMORY ) then
			AI.Signal(SIGNALFILTER_SENDER, 1, "SC_SCOUT_CHANGE_HIDE", entity.id);
			return;
		end

		AI.Signal(SIGNALFILTER_SENDER, 1, "SC_SCOUT_GOTO_HIDE", entity.id);

	end,

	SC_SCOUT_HIDEATTACK = function( self, entity )

		self:SC_SCOUT_ROUND_SHOOT_START( entity );

		--[[

		AI.ChangeParameter( entity.id, AIPARAM_STRAFINGPITCH, 10.0 );
		AI.CreateGoalPipe("scoutHideAttack");
		AI.PushGoal("scoutHideAttack","firecmd",0,FIREMODE_FORCED);
		if (entity.AI.bUseFreezeGun == true ) then
			AI.PushGoal("scoutHideAttack","timeout",1,7);
		else
			AI.PushGoal("scoutHideAttack","timeout",1,3);
		end
		AI.PushGoal("scoutHideAttack","firecmd",0,0);
		AI.PushGoal("scoutHideAttack","timeout",1,0.3);
		AI.PushGoal("scoutHideAttack","signal",0,1,"SC_SCOUT_CHANGE_HIDE",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"scoutHideAttack");

		--]]

	end,

	SC_SCOUT_CHANGE_HIDE = function( self, entity ) 

		entity.AI.hidingState = 4;

		if ( AIBehaviour.SCOUTDEFAULT:scoutSearchHideSpot( entity, entity.AI.hidePos, entity.AI.peepPos ) == true ) then
			local target = AI.GetAttentionTargetEntity( entity.id );
			if ( target and AI.Hostile( entity.id, target.id ) ) then

				vDir = {};
				vNewDir = {};

				local distanceToTarget = entity:GetDistance( target.id );
				if ( distanceToTarget < 100.0 ) then				
					entity.AI.hidePat = entity.AI.hidePat + 1 ;
				end

				CopyVector( vDir, entity.AI.hidePos );
				SubVectors( vDir, vDir, entity:GetPos() );				
				ProjectVector( vNewDir, vDir, target:GetDirectionVector(2) );
				FastSumVectors( vNewDir, vNewDir, entity:GetPos() );

				AI.SetRefPointPosition( entity.id, vNewDir);
				if (AIBehaviour.SCOUTDEFAULT:scoutCheckNavOfRef( entity ) == false ) then
					AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_ATTACK", entity.id);
					return;
				end
		
				AI.CreateGoalPipe("scoutChangeHide");
				AI.PushGoal("scoutChangeHide","run",0,0);	
				AI.PushGoal("scoutChangeHide","locate",0,"refpoint");		
				AI.PushGoal("scoutChangeHide","approach",1,3.0,AILASTOPRES_USE,-1);
				AI.PushGoal("scoutChangeHide","run",0,0);	
				if ( entity.AI.hidePat == 0 ) then
					AI.PushGoal("scoutChangeHide","timeout",1,4);
					AI.PushGoal("scoutChangeHide","signal",0,1,"SC_SCOUT_ROUND_SHOOT_START",SIGNALFILTER_SENDER);
				else
					AI.PushGoal("scoutChangeHide","signal",0,1,"SC_SCOUT_GOTO_HIDE",SIGNALFILTER_SENDER);
				end
				entity:SelectPipe(0,"scoutChangeHide");
				return;

			end
		end

		AI.Signal(SIGNALFILTER_SENDER, 1, "SC_SCOUT_GOTO_HIDE", entity.id);

	end,

	SC_SCOUT_ROUND_SHOOT_START = function( self, entity ) 
	
		entity.AI.hidingState = 5;

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			local distanceToTarget = entity:GetDistance( target.id );
			if ( distanceToTarget < 100.0 ) then				
				entity.AI.hidePat = entity.AI.hidePat + 1 ;
				AI.ChangeParameter( entity.id, AIPARAM_STRAFINGPITCH, 20.0 );
				AI.CreateGoalPipe("alertShoot");
				AI.PushGoal("alertShoot","firecmd",0,FIREMODE_FORCED);
				AI.PushGoal("alertShoot","timeout",1,3.0);
				AI.PushGoal("alertShoot","firecmd",0,0);
				AI.PushGoal("alertShoot","timeout",1,2.0);
				AI.PushGoal("alertShoot","signal",0,1,"SC_SCOUT_ROUND_SHOOT_END",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"alertShoot");
				return;
			end

			entity.AI.bBlockSignal = true;
			entity.AI.roundShootAngle = -3.1416 * 30.0 / 180.0;
			entity.AI.roundShootVec = {};
			entity.AI.roundUpVec = {};

			CopyVector( entity.AI.roundUpVec, entity:GetDirectionVector(2) );
			SubVectors( entity.AI.roundShootVec, target:GetPos(), entity:GetPos() );
			
			local shootPos = {};
			local projectedShootPos = {};

			RotateVectorAroundR( shootPos, entity.AI.roundShootVec, entity.AI.roundUpVec, entity.AI.roundShootAngle );
			ProjectVector( projectedShootPos, shootPos, entity.AI.roundUpVec )

			local len = LengthVector( projectedShootPos );
			NormalizeVector( projectedShootPos );
			FastScaleVector( projectedShootPos, projectedShootPos, 10.0 );

			FastSumVectors( shootPos, shootPos, entity:GetPos() );
	
			AI.ChangeParameter( entity.id, AIPARAM_STRAFINGPITCH, 20.0 );
	
			AI.SetRefPointPosition( entity.id, shootPos );
			if (AIBehaviour.SCOUTDEFAULT:scoutCheckNavOfRef( entity ) == false ) then
				AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_ATTACK", entity.id);
				return;
			end

			AI.CreateGoalPipe("roundShootTest");
			AI.PushGoal("roundShootTest","ignoreall",0,1);
			AI.PushGoal("roundShootTest","locate",0,"refpoint");
			AI.PushGoal("roundShootTest","acqtarget",0,"");
			AI.PushGoal("roundShootTest","lookat",1,0,0,true);
			AI.PushGoal("roundShootTest","firecmd",0,FIREMODE_FORCED);
			for i = 1, 24, 1 do
				AI.PushGoal("roundShootTest","lookat",1,0,0,true);
				AI.PushGoal("roundShootTest","signal",0,1,"SC_SCOUT_ROUND_SHOOT_REFLESH",SIGNALFILTER_SENDER);
			end
			AI.PushGoal("roundShootTest","firecmd",0,0);
			AI.PushGoal("roundShootTest","locate",0,"player");
			AI.PushGoal("roundShootTest","acqtarget",0,"");
			AI.PushGoal("roundShootTest","ignoreall",0,0);
			AI.PushGoal("roundShootTest","timeout",1,2.0);
			AI.PushGoal("roundShootTest","signal",0,1,"SC_SCOUT_ROUND_SHOOT_END",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"roundShootTest");

		else
			AI.Signal(SIGNALFILTER_SENDER, 1, "SC_SCOUT_CHANGE_HIDE", entity.id);
		end
		
	end,
	
	SC_SCOUT_ROUND_SHOOT_END = function( self, entity ) 

		entity.AI.bBlockSignal = false;
		AI.Signal(SIGNALFILTER_SENDER, 1, "SC_SCOUT_CHANGE_HIDE", entity.id);

	end,
	
	SC_SCOUT_ROUND_SHOOT_REFLESH = function( self, entity ) 

			entity.AI.roundShootAngle = entity.AI.roundShootAngle + 3.1416 * 5.0 / 180.0;

			local shootPos = {};
			local projectedShootPos = {};

			RotateVectorAroundR( shootPos, entity.AI.roundShootVec, entity.AI.roundUpVec, entity.AI.roundShootAngle );
			ProjectVector( projectedShootPos, shootPos, entity.AI.roundUpVec )

			local len = LengthVector( projectedShootPos );
			NormalizeVector( projectedShootPos );
--			FastScaleVector( projectedShootPos, projectedShootPos, 10.0 );

			FastSumVectors( shootPos, shootPos, entity:GetPos() );
			FastSumVectors( shootPos, shootPos, projectedShootPos );
			AI.SetRefPointPosition( entity.id, shootPos );

	end,

	SC_SCOUT_LISTUP_ENTITIES = function( self, entity )
	
		AIBehaviour.SCOUTDEFAULT:scoutListUpObjects( entity );
	
	end

}

