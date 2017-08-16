--------------------------------------------------
--   Created By: amanda lear
--   Description: run to alarm anchor
--------------------------

AIBehaviour.RunPath = {
	Name = "RunPath",
	alertness = 1,
	
	---------------------------------------------
	OnSpawn = function( self, entity )
		AI.CreateGoalPipe(entity.Properties.pathname.."RunPath");
		AI.PushGoal(entity.Properties.pathname.."RunPath","signal",0,1,"AI_AGGRESSIVE",SIGNALID_READIBILITY);	
		AI.PushGoal(entity.Properties.pathname.."RunPath","run",0,1);
		AI.PushGoal(entity.Properties.pathname.."RunPath","bodypos",0,0);
		AI.PushGoal(entity.Properties.pathname.."RunPath","firecmd",0,1);
		AI.PushGoal(entity.Properties.pathname.."RunPath","pathfind",1,entity.Properties.pathname);
		AI.PushGoal(entity.Properties.pathname.."RunPath","trace",1,1);
		AI.PushGoal(entity.Properties.pathname.."RunPath","signal",0,1,"PathDone",0);	
	end,
	
	RunPath = function( self, entity )	
		AI.LogEvent("ACTIVATING PATH");
		AI.CreateGoalPipe(entity.Properties.pathname.."RunPath");
		--AI.PushGoal(entity.Properties.pathname.."RunPath","signal",0,1,"AI_AGGRESSIVE",SIGNALID_READIBILITY);	
		AI.PushGoal(entity.Properties.pathname.."RunPath","run",0,0);
		AI.PushGoal(entity.Properties.pathname.."RunPath","bodypos",0,0);
		AI.PushGoal(entity.Properties.pathname.."RunPath","firecmd",0,1);
		AI.PushGoal(entity.Properties.pathname.."RunPath","pathfind",1,entity.Properties.pathname);
		AI.PushGoal(entity.Properties.pathname.."RunPath","trace",1,1);
		AI.PushGoal(entity.Properties.pathname.."RunPath","signal",0,1,"PathDone",0);	
		entity:SelectPipe(0,entity.Properties.pathname.."RunPath");	
	end,
	---------------------------------------------
	OnActivate = function( self, entity )
--	AI.LogEvent("\001"..entity:GetName().."+++++++++++++++++ RunToAlarm OnActivate");
		entity:SelectPipe(0,entity.Properties.pathname.."RunPath");	
	end,
	---------------------------------------------
	OnBored = function( self, entity )
	end,
	---------------------------------------------
	OnNoTarget = function( self, entity )
	
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )

	end,
	---------------------------------------------
	OnEnemySeen = function( self, entity )
		-- called when the enemy sees a foe which is not a living player
	end,
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the enemy can no longer see its foe, but remembers where it saw it last
	end,
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )

	end,
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
	end,
	---------------------------------------------
	OnReceivingDamage = function ( self, entity, sender)
	end,
	--------------------------------------------------
	OnCoverRequested = function ( self, entity, sender)
		-- called when the enemy is damaged
	end,
	---------------------------------------------
	OnBulletRain = function ( self, entity, sender)	

	end,
	--------------------------------------------------
	OnGrenadeSeen = function( self, entity, fDistance )

	end,
	--------------------------------------------------
	-- CUSTOM SIGNALS
	--------------------------------------------------
	
	PathDone= function (self, entity, sender)
		--entity:SelectPipe(0,"randomhide");
		--entity:InsertSubpipe(0,"force_reevaluate");
		AI.LogEvent("PATH DONE");
	end,

	OnGroupMemberDied = function( self, entity, sender)
	end,
	--------------------------------------------------
	OnGroupMemberDiedNearest = function ( self, entity, sender)

	end,
	--------------------------------------------------
	COVER_NORMALATTACK = function (self, entity, sender)
	end,
	--------------------------------------------------
	COVER_RELAX = function (self, entity, sender)
	end,
	--------------------------------------------------
	AISF_GoOn = function (self, entity, sender)
	end,
	--------------------------------------------------
	-- GROUP SIGNALS
	--------------------------------------------------
	HEADS_UP_GUYS = function (self, entity, sender)

	end,
	---------------------------------------------
	INCOMING_FIRE = function (self, entity, sender)

	end,
	---------------------------------------------
	KEEP_FORMATION = function (self, entity, sender)

	end,
	---------------------------------------------	
	MOVE_IN_FORMATION = function (self, entity, sender)

	end,
	---------------------------------------------	
	BREAK_FORMATION = function (self, entity, sender)
		-- the team can split
	end,
	---------------------------------------------	
	SINGLE_GO = function (self, entity, sender)
		-- the team leader has instructed this group member to approach the enemy
	end,
	---------------------------------------------	
	GROUP_COVER = function (self, entity, sender)
		-- the team leader has instructed this group member to cover his friends
	end,
	---------------------------------------------	
	IN_POSITION = function (self, entity, sender)
		-- some member of the group is safely in position
	end,
	
	---------------------------------------------	
	PHASE_RED_ATTACK = function (self, entity, sender)
		-- team leader instructs red team to attack
	end,
	---------------------------------------------	
	PHASE_BLACK_ATTACK = function (self, entity, sender)
		-- team leader instructs black team to attack
	end,
	---------------------------------------------	
	GROUP_MERGE = function (self, entity, sender)
		-- team leader instructs groups to merge into a team again
	end,
	---------------------------------------------	
	CLOSE_IN_PHASE = function (self, entity, sender)
		-- team leader instructs groups to initiate part one of assault fire maneuver
	end,
	---------------------------------------------	
	ASSAULT_PHASE = function (self, entity, sender)
		-- team leader instructs groups to initiate part one of assault fire maneuver
	end,
	---------------------------------------------	
	GROUP_NEUTRALISED = function (self, entity, sender)
		-- team leader instructs groups to initiate part one of assault fire maneuver
	end,
	
}