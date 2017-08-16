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
--	- 29/11/2005   : Revised for new attack patterns by Tetsuji Iwasaki
--------------------------------------------------------------------------


--------------------------------------------------------------------------
AIBehaviour.ScoutMelee = {
	Name = "ScoutMelee",
	Base = "SCOUTDEFAULT",

	--------------------------------------------------------------------------
	Constructor = function ( self, entity, data )

		-- called when the behaviour is selected

		-- -1: there is a friend don't melee
		--  0: attack the player
		--  1: attack the physics entity
		entity.AI.bContinueMelee =-1;

		-- Default action
		AI.CreateGoalPipe("scoutMeleeDefault");
		AI.PushGoal("scoutMeleeDefault","timeout",1,0.1);
		AI.PushGoal("scoutMeleeDefault","signal",0,1,"SC_SCOUT_START_MELEE",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"scoutMeleeDefault");

	end,

	---------------------------------------------
	Destructor = function ( self, entity, data )

		-- called when the behaviour is de-selected
		-- the extra data is from the signal that is causing the behavior transition

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
		self:OnEnemyDamage(entity);
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
	SC_SCOUT_START_MELEE = function ( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then
			entity.AI.meleeTargetEntity = target;
			entity.AI.meleeCout = 0;
			entity.AI.meleeDistance =30.0;
			entity.AI.bContinueMelee = AIBehaviour.SCOUTDEFAULT:scoutGetMeleeTarget( entity );
			AI.Signal(SIGNALFILTER_SENDER, 1, "SC_SCOUT_MELEE", entity.id);
		else
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_SCOUT_ATTACK", entity.id);
		end

	end,

	--------------------------------------------------------------------------
	SC_SCOUT_MELEE = function ( self, entity )

		local targetPos = {};
		local targetDir = {};

		AIBehaviour.SCOUTDEFAULT:scoutAdjustRefPoint( entity, 7.0 );
		if (AIBehaviour.SCOUTDEFAULT:scoutCheckNavOfRef( entity ) == false ) then
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_ATTACK", entity.id);
			return;
		end

		SubVectors( targetDir, AI.GetRefPointPosition( entity.id ), entity:GetPos() );
		local distance = LengthVector( targetDir );
	
		if (distance>20.0) then
			AI.CreateGoalPipe("scoutAttackMelee");
			AI.PushGoal("scoutAttackMelee","firecmd",0,0);
			AI.PushGoal("scoutAttackMelee","run",0,1);	
			AI.PushGoal("scoutAttackMelee","locate",0,"refpoint");		
			AI.PushGoal("scoutAttackMelee","approach",1,18.0,AILASTOPRES_USE,-1);
			AI.PushGoal("scoutAttackMelee","run",0,0);	
			AI.PushGoal("scoutAttackMelee","locate",0,"refpoint");		
			AI.PushGoal("scoutAttackMelee","approach",1,12.0,AILASTOPRES_USE,-1);
			AI.PushGoal("scoutAttackMelee","locate",0,"refpoint");		
			AI.PushGoal("scoutAttackMelee","acqtarget",0,"");
			AI.PushGoal("scoutAttackMelee","stick",1,5.0,AILASTOPRES_LOOKAT,1);
			AI.PushGoal("scoutAttackMelee","signal",0,1,"SC_SCOUT_MELEE2",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"scoutAttackMelee");
		else
			AI.CreateGoalPipe("scoutAttackMelee");
			AI.PushGoal("scoutAttackMelee","firecmd",0,0);
			AI.PushGoal("scoutAttackMelee","run",0,0);	
			AI.PushGoal("scoutAttackMelee","locate",0,"refpoint");		
			AI.PushGoal("scoutAttackMelee","acqtarget",0,"");
			AI.PushGoal("scoutAttackMelee","stick",1,5.0,AILASTOPRES_LOOKAT,1);
			AI.PushGoal("scoutAttackMelee","signal",0,1,"SC_SCOUT_MELEE2",SIGNALFILTER_SENDER);
			entity:SelectPipe(0,"scoutAttackMelee");
		end

	end,

	--------------------------------------------------------------------------
	SC_SCOUT_MELEE2 = function( self, entity )

		local attackPos = {};
		local diff = {};
		local myPos = {};
		local	dstPos = {}

		local v1 ={};
		local v2 ={};

		CopyVector( myPos, entity:GetPos());
		CopyVector( dstPos, AI.GetRefPointPosition( entity.id ) );

		SubVectors( diff, myPos, dstPos );
		local targetDist = LengthVector( diff );

		AIBehaviour.SCOUTDEFAULT:scoutGetScaledDirectionVector( entity, v1, myPos, dstPos, 1.0 );
		CopyVector( v2, entity:GetDirectionVector(1) );
		FastScaleVector( v2, v2, -1.0 );

		local innerproduct = dotproduct3d( v1, v2 );

		AI.LogEvent(entity:GetName().."SC_SCOUT_MELEE condition. distance:"..targetDist.." dot:"..innerproduct);

		if( targetDist < 20.0 and innerproduct > math.cos(3.1416*60.0/180.0)) then
			-- Make sure we are near enough to do the melee.
			--AI.LogComment(entity:GetName().."SC_SCOUT_MELEE start melee");

			AI.CreateGoalPipe("scoutAttackMeleeDelay");
			AI.PushGoal("scoutAttackMeleeDelay","acqtarget",0,entity.AI.meleeTargetEntity:GetName());
			AI.PushGoal("scoutAttackMeleeDelay","timeout",1,0.5);

			-- calculate naxt target
			if ( entity.AI.bContinueMelee == 1 ) then
				entity:MeleeAttack(1);
				entity.AI.bContinueMelee = AIBehaviour.SCOUTDEFAULT:scoutGetMeleeTarget( entity );
				AI.PushGoal("scoutAttackMeleeDelay","signal",0,1,"SC_SCOUT_MELEE",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"scoutAttackMeleeDelay");
			elseif ( entity.AI.bContinueMelee == 0 ) then
				entity:MeleeAttack(0);
				AI.PushGoal("scoutAttackMeleeDelay","signal",0,1,"TO_SCOUT_ATTACK",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"scoutAttackMeleeDelay");
			else
				--AI.LogComment(entity:GetName().."SC_SCOUT_MELEE failed. detected friend.");
				entity:SelectPipe(0,"do_nothing");
				AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_ATTACK", entity.id);							
			end

			return;

		end

		--AI.LogComment(entity:GetName().."SC_SCOUT_MELEE target too far.");

		if (entity.AI.meleeCout>2) then
			-- Fail the melee.
			--AI.LogComment(entity:GetName().."SC_SCOUT_MELEE failed.");
			entity:SelectPipe(0,"do_nothing");
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_ATTACK", entity.id);							
		else
			--AI.LogComment(entity:GetName().."SC_SCOUT_MELEE retry.");
			entity:SelectPipe(0,"do_nothing");
			entity.AI.bContinueMelee = AIBehaviour.SCOUTDEFAULT:scoutGetMeleeTarget( entity );
			AI.Signal(SIGNALFILTER_SENDER,1,"SC_SCOUT_MELEE", entity.id);							
		end

	end,

}

