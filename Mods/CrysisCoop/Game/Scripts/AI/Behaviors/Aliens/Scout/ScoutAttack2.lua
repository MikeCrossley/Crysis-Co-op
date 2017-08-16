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
reqpat = 0;

--------------------------------------------------------------------------
AIBehaviour.ScoutAttack = {

	Name = "ScoutAttack",
	Base = "SCOUTDEFAILT",

	--------------------------------------------------------------------------
	-- system functions

	Constructor = function ( self, entity, data )

		-- called when the behaviour is selected
		-- the extra data is from the signal that caused the behavior transition

		-- for refreshing position;

		entity.AI.time = System.GetCurrTime() - 100.0;

		-- Position imfomation, at what seat the scout is located.
		entity.AI.bBlockSignal = false;

		entity.AI.stayPosition = 0;
		entity.AI.vDefaultPosition = {};
		entity.AI.vAttackCenterPos = {};
		entity.AI.vFwdUnit = {};
		entity.AI.vWngUnit = {};
		entity.AI.vUpUnit = {};
	
		local defaultVec = {};
		defaultVec.x = 0.0;
		defaultVec.y = 0.0;
		defaultVec.z = 0.0;

		CopyVector( entity.AI.vDefaultPosition, entity:GetPos() );
		CopyVector( entity.AI.vAttackCenterPos, entity:GetPos() );
		CopyVector( entity.AI.vFwdUnit, defaultVec );
		CopyVector( entity.AI.vWngUnit, defaultVec );
		CopyVector( entity.AI.vUpUnit, defaultVec );

		-- target counter

		entity.AI.waitCounter = 0;

		-- Default action
		AI.CreateGoalPipe("scoutAttackDefault");
		AI.PushGoal("scoutAttackDefault","timeout",1,0.1);
		AI.PushGoal("scoutAttackDefault","signal",0,1,"SC_SCOUT_STAY_ATTACK_START",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"scoutAttackDefault");

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
		--self:SC_SCOUT_STAY_ATTACK( entity );
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
		-- local hitter = System.GetEntity(data.id);
		-- local hitterName = hitter:GetName()
		self:OnEnemyDamage(entity);
	end,

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender, data )

		if ( entity.AI.bBlockSignal == true ) then
			return;
		end

		if ( entity.AI.bUseFreezeGun == true ) then
			-- for MOAR Scout
			AI.Signal(SIGNALFILTER_GROUPONLY, 1, "TO_SCOUT_MOARATTACK", entity.id);
		else
			-- for MOAC Scout
			local rnd = 5;--random(1,6);
			if ( rnd < 3 ) then

				AI.ChangeParameter( entity.id, AIPARAM_STRAFINGPITCH, 20.0 );
				AI.CreateGoalPipe("scoutAttackStandByV3");
				AI.PushGoal("scoutAttackStandByV3","firecmd",0,FIREMODE_FORCED);
				AI.PushGoal("scoutAttackStandByV3","timeout",1,3);
				AI.PushGoal("scoutAttackStandByV3","firecmd",0,0);
				AI.PushGoal("scoutAttackStandByV3","timeout",1,0.3);
				AI.PushGoal("scoutAttackStandByV3","signal",0,1,"SC_SCOUT_STAY_ATTACK",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"scoutAttackStandByV3");

			elseif ( rnd == 5 ) then
				-- Goto location just in front of the player, and do the melee there.		
				if (reqpat == 0) then
					AI.Signal(SIGNALFILTER_GROUPONLY, 1, "TO_SCOUT_FLYOVER", entity.id);
					reqpat =reqpat +1;
				elseif (reqpat == 1 ) then
					AI.Signal(SIGNALFILTER_SENDER, 1, "TO_SCOUT_MELEE", entity.id);
					reqpat =reqpat +1;
				elseif (reqpat == 2 ) then
					AI.Signal(SIGNALFILTER_SENDER, 1, "TO_SCOUT_GRAB", entity.id);
					reqpat = 0 ;
				end

			end
	
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
	SC_SCOUT_STAY_ATTACK_START = function( self, entity )
		AIBehaviour.SCOUTDEFAULT:scoutGetID(entity);
		AIBehaviour.SCOUTDEFAULT:scoutDoStayAttack( entity );
		self:SC_SCOUT_STAY_ATTACK(entity);
	end,

	--------------------------------------------------------------------------
	SC_SCOUT_STAY_ATTACK = function( self, entity )

		-- formation control

		-- While doing their attack approach, 
		-- they will try to get into the players FOV, 
		-- but will continue their run even if the player looks away.

		-- if he doesn't have a target

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

				entity.AI.waitCounter  = 0;

		else

			if ( entity.AI.waitCounter < 5 ) then

				entity.AI.waitCounter = entity.AI.waitCounter + 1;

				AI.CreateGoalPipe("scoutAttackWait2");
				AI.PushGoal("scoutAttackWait2","timeout",1,1.0);
				AI.PushGoal("scoutAttackWait2","signal",0,1,"SC_SCOUT_STAY_ATTACK_START",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"scoutAttackWait2");
				return;
					
			else

				entity.AI.waitCounter = 0;
				AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_PATROL", entity.id);
				return;
				
			end
			
		end

		-- aquire the position

		AIBehaviour.SCOUTDEFAULT:scoutGetID(entity);
--			AI.Signal(SIGNALFILTER_GROUPONLY, 1, "TO_SCOUT_MOARATTACK", entity.id);
--			AI.Signal(SIGNALFILTER_GROUPONLY, 1, "TO_SCOUT_FLYOVER", entity.id);

		if ( entity.AI.stayPosition == 1 ) then
--		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_SCOUT_MELEE", entity.id);
--		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_SCOUT_GRAB", entity.id);
		end
		

		if (entity.AI.bBlockHide == false) then
			entity.AI.bBlockHide = true;
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_SCOUT_HIDE", entity.id);
			return;
		end

		AI.Signal(SIGNALFILTER_GROUPONLY, 1, "TO_SCOUT_HOVERATTACK", entity.id);

		AIBehaviour.SCOUTDEFAULT:scoutDoStayAttack( entity );


	end,

}