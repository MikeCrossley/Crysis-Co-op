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
AIBehaviour.ScoutRoundAttack = {
	Name = "ScoutRoundAttack",
	Base = "SCOUTDEFAULT",

	--------------------------------------------------------------------------
	Constructor = function ( self, entity, data )

		-- called when the behaviour is selected

		AI.CreateGoalPipe("scoutRoundAttackDefault");
		AI.PushGoal("scoutRoundAttackDefault","timeout",1,0.1);
		AI.PushGoal("scoutRoundAttackDefault","signal",0,1,"SC_SCOUT_ROUNDATTACK2_START",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"scoutRoundAttackDefault");

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

	--------------------------------------------------------------------------
	SC_SCOUT_ROUNDATTACK2_START = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			local targetWngDir = {};
			local targetUpDir = {};
			local targetFwdDir = {};
			local vDst ={};

			FastScaleVector( targetWngDir , entity.AI.vWngUnit , -30.0 );
			FastScaleVector( targetUpDir  , entity.AI.vUpUnit  , 30.0 );
			FastScaleVector( targetFwdDir , entity.AI.vFwdUnit , 50.0 );

			FastSumVectors( vDst , target:GetPos() , targetUpDir   );
			FastSumVectors( vDst , vDst, targetFwdDir  );
			FastSumVectors( vDst , vDst, targetWngDir );

			AI.SetRefPointPosition( entity.id, vDst );

			AI.CreateGoalPipe("scoutRoundAttack2");
			AI.PushGoal("scoutRoundAttack2","continuous",0,1);		
			AI.PushGoal("scoutRoundAttack2","locate",0,"refpoint");		
			AI.PushGoal("scoutRoundAttack2","approach",1,1.0,AILASTOPRES_USE,-1);		
			AI.PushGoal("scoutRoundAttack2","signal",0,1,"SC_SCOUT_ROUNDATTACK2_1",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"scoutRoundAttack2");

		end

	end,

	SC_SCOUT_ROUNDATTACK2_1 = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			local targetWngDir = {};
			local targetUpDir = {};
			local targetFwdDir = {};
			local vDst ={};

			FastScaleVector( targetWngDir , entity.AI.vWngUnit , 0.0 );
			FastScaleVector( targetUpDir  , entity.AI.vUpUnit  , 10.0 );
			FastScaleVector( targetFwdDir , entity.AI.vFwdUnit , 100.0 );

			FastSumVectors( vDst , target:GetPos() , targetUpDir   );
			FastSumVectors( vDst , vDst, targetFwdDir  );
			FastSumVectors( vDst , vDst, targetWngDir );

			AI.SetRefPointPosition( entity.id, vDst );

			AI.CreateGoalPipe("scoutRoundAttack3");
			AI.PushGoal("scoutRoundAttack3","continuous",0,1);		
			AI.PushGoal("scoutRoundAttack3","locate",0,"refpoint");		
			AI.PushGoal("scoutRoundAttack3","approach",1,1.0,AILASTOPRES_USE,-1);		
			AI.PushGoal("scoutRoundAttack3","signal",0,1,"SC_SCOUT_ROUNDATTACK2_2",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"scoutRoundAttack3");

		end

	end,

	SC_SCOUT_ROUNDATTACK2_2 = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			local targetWngDir = {};
			local targetUpDir = {};
			local targetFwdDir = {};
			local vDst ={};

			FastScaleVector( targetWngDir , entity.AI.vWngUnit , 30.0 );
			FastScaleVector( targetUpDir  , entity.AI.vUpUnit  , 10.0 );
			FastScaleVector( targetFwdDir , entity.AI.vFwdUnit , 50.0 );

			FastSumVectors( vDst , target:GetPos() , targetUpDir   );
			FastSumVectors( vDst , vDst, targetFwdDir  );
			FastSumVectors( vDst , vDst, targetWngDir );

			AI.SetRefPointPosition( entity.id, vDst );

			AI.CreateGoalPipe("scoutRoundAttack4");
			AI.PushGoal("scoutRoundAttack4","continuous",0,1);		
			AI.PushGoal("scoutRoundAttack4","locate",0,"refpoint");		
			AI.PushGoal("scoutRoundAttack4","approach",1,1.0,AILASTOPRES_USE,-1);	
			AI.PushGoal("scoutRoundAttack4","signal",0,1,"SC_SCOUT_ROUNDATTACK2_3",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"scoutRoundAttack4");

		end

	end,

	SC_SCOUT_ROUNDATTACK2_3 = function( self, entity )

			AI.CreateGoalPipe("scoutRoundAttack4");
			AI.PushGoal("scoutRoundAttack4","timeout",0,200.0);
			entity:SelectPipe(0,"scoutRoundAttack4");

	end,

	--------------------------------------------------------------------------
	SC_SCOUT_ROUNDATTACK_START = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			entity.AI.vRoundAttackRef ={};
			entity.AI.vLookAt ={};

			local vSrc = {};
			local vDst = {};
			local vCenter = {};
			local vSrcUnit = {};
			local vDstUnit = {};
			local vSrcUnitRot = {};
			local vUp = {};

			CopyVector( vSrc, entity:GetPos() );
			CopyVector( vCenter, target:GetPos() );


			local targetWngDir = {};
			local targetUpDir = {};
			local targetFwdDir = {};
	
			FastScaleVector( targetWngDir , entity.AI.vWngUnit , -10.0 );
			FastScaleVector( targetUpDir  , entity.AI.vUpUnit  , 10.0 );
			FastScaleVector( targetFwdDir , entity.AI.vFwdUnit , 10.0 );

			FastSumVectors( vDst , entity.AI.vAttackCenterPos , targetUpDir   );
			FastSumVectors( vDst , vDst, targetFwdDir  );
			FastSumVectors( vDst , vDst, targetWngDir );

			SubVectors( vSrc, vSrc, vCenter );
			SubVectors( vDst, vDst, vCenter );

			CopyVector( vSrcUnit, vSrc );
			CopyVector( vDstUnit, vDst );

			NormalizeVector( vSrcUnit );
			NormalizeVector( vDstUnit );

			local dot = dotproduct3d( vSrcUnit, vDstUnit );
			local degree;
			
			crossproduct3d( vUp, vSrcUnit, vDstUnit );
			NormalizeVector( vUp );
			RotateVectorAroundR( vSrcUnitRot, vSrcUnit, vUp ,3.1416*90.0/180.0 );

			local dotRot = dotproduct3d( vSrcUnitRot, vDstUnit );
			local mark = sgn(dot) * sgn(dotRot); 
			local angle = math.acos(dot) * mark;

			local arc = LengthVector( vSrc ) * angle; 
			local arcStep = arc / 50.0;

			if ( arcStep < 1.0 ) then
				AI.CreateGoalPipe("scoutRoundAttackEnd");
				AI.PushGoal("scoutRoundAttackEnd","timeout",1,100.0);	
				AI.PushGoal("scoutRoundAttackEnd","signal",0,1,"TO_SCOUT_ATTACK",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"scoutRoundAttackEnd");
				return;
			end
	

			local lengthSrc = LengthVector( vSrc );
			local lengthDst = LengthVector( vDst );
			local length = ( lengthDst - lengthSrc ) / arcStep + lengthSrc;
			local deltaAngle = angle / arcStep;
			local vSrcRot = {};

			RotateVectorAroundR( vSrcRot, vSrc, vUp ,deltaAngle );

			NormalizeVector( vSrcRot );
			FastScaleVector( vSrcRot, vSrcRot, length );
			FastSumVectors( entity.AI.vRoundAttackRef, vSrcRot, vCenter );

			local vLookAt = {};
			
			CopyVector( vLookAt, vCenter );
			CopyVector( entity.AI.vLookAt, vLookAt );

--			AI.LogEvent("ARC "..arc);
--			AI.LogEvent("ARCSTEP "..arcStep);
--			AI.LogEvent("DELTAANGLE "..deltaAngle);
--			AI.LogEvent("LENGTH "..AIBehaviour.SCOUTDEFAULT:scoutGetDistanceOfPoints( entity.AI.vRoundAttackRef, entity:GetPos()) );

			AI.CreateGoalPipe("scoutRoundAttack");
			AI.PushGoal("scoutRoundAttack","signal",0,1,"SC_SCOUT_GETREF",SIGNALFILTER_SENDER);
			AI.PushGoal("scoutRoundAttack","locate",0,"refpoint");		
			AI.PushGoal("scoutRoundAttack","approach",1,1.0,AILASTOPRES_USE,-1);	
			AI.PushGoal("scoutRoundAttack","signal",0,1,"SC_SCOUT_ROUNDATTACK_START",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"scoutRoundAttack");

		else
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_ATTACK", entity.id);							
		end

	end,

	SC_SCOUT_GETLOOKAT = function( self, entity )
		AI.SetRefPointPosition( entity.id, entity.AI.vLookAt );
	end,
	SC_SCOUT_GETREF = function( self, entity )
		AI.SetRefPointPosition( entity.id, entity.AI.vRoundAttackRef );
	end,

}

