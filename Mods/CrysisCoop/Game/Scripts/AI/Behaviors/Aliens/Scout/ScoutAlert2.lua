--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: simple behaviour for testing 3d navigation
--  
--------------------------------------------------------------------------
--  History:
--  - 11/12/2004   : Created by Kirill Bulatsev
--  - 05/04/2005   : CXP Rush Clean up by Mikko Mononen
--	- 29/11/2005   : Revised for new attack patterns by Tetsuji Iwasaki
--------------------------------------------------------------------------


AIBehaviour.ScoutAlert = {
	Name = "ScoutAlert",

	--------------------------------------------------------------------------
	Constructor = function ( self, entity, data )

		-- called when the behaviour is selected
		-- the extra data is from the signal that caused the behavior transition
		self:SC_SCOUT_ALERT_START( entity );

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

		-- first send him OnSeenByEnemy signal
--		local target = AI.GetAttentionTargetEntity(entity.id);
--		if(target) then 
--			AI.Signal(SIGNALFILTER_SUPERGROUP, 1, "OnSeenByEnemy", target.id);
--		end

		-- Drop beacon and let the other know here's something to fight for.
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		AI.Signal(SIGNALFILTER_GROUPONLY, 1, "GO_ENEMY_FOUND",entity.id);

		AI.Signal(SIGNALFILTER_SENDER,1,"TO_SCOUT_ATTACK", entity.id);	

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

		-- called when AI is damaged by an enemy AI
		-- data.id = damaging enemy's entity id

		local hitter = System.GetEntity(data.id);
		if ( hitter ) then

			local hitterName = hitter:GetName()

			AI.SetRefPointPosition( entity.id , hitter:GetPos() );
			AIBehaviour.SCOUTDEFAULT:scoutAdjustRefPoint( entity, 12.0 );
			if (AIBehaviour.SCOUTDEFAULT:scoutCheckNavOfRef( entity ) == true ) then
				AI.CreateGoalPipe("scoutHovering2");
				AI.PushGoal("scoutHovering2","locate",0,"refpoint");
				AI.PushGoal("scoutHovering2","approach",1,20.0,AILASTOPRES_USE,-1);
				AI.PushGoal("scoutHovering2","signal",0,1,"SC_SCOUT_ALERT_START",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"scoutHovering2");
			else
				AI.CreateGoalPipe("scoutHovering2V2");
				AI.PushGoal("scoutHovering2V2","timeout",0,5.0);
				AI.PushGoal("scoutHovering2V2","signal",0,1,"SC_SCOUT_ALERT_START",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"scoutHovering2V2");
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
	SC_SCOUT_ALERT_START = function( self, entity )

		if( AI.GetBeaconPosition( entity.id,g_Vectors.temp ) ) then

			AI.SetRefPointPosition( entity.id, g_Vectors.temp );
			AIBehaviour.SCOUTDEFAULT:scoutAdjustRefPoint( entity, 12.0 );
			if (AIBehaviour.SCOUTDEFAULT:scoutCheckNavOfRef( entity ) == true ) then
				AI.CreateGoalPipe("scoutAlert");
				AI.PushGoal("scoutAlert","locate",0,"beacon");	
				AI.PushGoal("scoutAlert","acqtarget",0,"");
				AI.PushGoal("scoutAlert","run",0,1);	
				AI.PushGoal("scoutAlert","approach",1,20,-1);
				AI.PushGoal("scoutAlert","signal",0,1,"SC_SCOUT_ALERT_START",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"scoutAlert");
			else
				AI.CreateGoalPipe("scoutAlertV2");
				AI.PushGoal("scoutAlertV2","locate",0,"beacon");	
				AI.PushGoal("scoutAlertV2","acqtarget",0,"");
				AI.PushGoal("scoutAlertV2","timeout",1,5.0);	
				AI.PushGoal("scoutAlertV2","signal",0,1,"SC_SCOUT_ALERT_START",SIGNALFILTER_SENDER);
				entity:SelectPipe(0,"scoutAlertV2");
			end

		else
			-- No beacon, start searching.
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_SCOUT_IDLE",entity.id);
		end

	end,
}
