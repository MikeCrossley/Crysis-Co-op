--------------------------------------------------
--   Created By: Luciano Morpurgo
--------------------------

AIBehaviour.HostageFollow = {
	Name = "HostageFollow",
	Base = "HostageRetrieve",

	Constructor = function( self, entity )	
		entity.AI.InSquad = 1;
		--AI.LogEvent(entity:GetName().." executes SQUADFOLLOW constructor");
		entity:SelectPipe(0,"squad_form");
		entity:InsertSubpipe(0,"do_it_standing");
		entity:InsertSubpipe(0,"random_very_short_timeout");
		if(entity.AI.CurrentConversation) then
			entity.AI.CurrentConversation:Stop(entity);
		end
		local leader = AI.GetLeader(entity.id);
		if(leader) then
			AI.ChangeParameter( entity.id, AIPARAM_SPECIES,AI.GetSpeciesOf(leader.id));
		end
--		entity.iLookTimer = Script.SetTimer(1,AIBehaviour.HostageIdle.CheckLook,entity)
		entity.AI.Cower = false;
		AI.SetIgnorant(entity.id,1);
	end,

	Destructor = function( self, entity )	
		AI.SetIgnorant(entity.id,0);
	end,

	
	FORMATION_REACHED = function(self,entity,sender)
--		AI.LogEvent(entity:GetName().." SquadFollow: FORMATION_REACHED attention target = "..AI.GetAttentionTargetOf(entity.id));
--		AI.Signal(SIGNALFILTER_LEADER,10,"ORD_DONE",entity.id);
		entity:SelectPipe(0,"stay_in_formation");
		entity:InsertSubpipe(0,"do_it_stealth");
		AI.SetIgnorant(entity.id,0);

	end,

--	OnClearIgnoreEnemy = function(self,entity,sender)
--		entity.bIgnoreEnemy = false;
--	end,
	---------------------------------------------
	OnCloseContact = function( self, entity, bender )
	end,

	---------------------------------------------
	OnSeenByEnemy = function( self, entity, sender )
	end,
	---------------------------------------------
--	OnNoTarget = function( self, entity )
--	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
	end,

	---------------------------------------------
	OnEnemyMemory = function( self, entity , distance)
	end,
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		-- called when the enemy hears an interesting sound
		entity:Readibility("idle_interest_group",1);

	end,
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )

	end,
	---------------------------------------------
	OnReload = function( self, entity )
	end,
	---------------------------------------------
	OnGroupMemberDied = function( self, entity )
	end,
	---------------------------------------------

	--------------------------------------------------
	OnGroupMemberDiedNearest = function ( self, entity, sender)
	end,
	---------------------------------------------
	OnNoHidingPlace = function( self, entity, sender )
	
	end,	

	----------------------------------
	OnLeaderTooFar =  function(self,entity,sender)
		entity:Readibility("player_too_far_ahead");
	end,

	--------------------------------------------------
--	OnBulletRain = function ( self, entity, sender)
--	end,
	
	--------------------------------------------------
--	OnVehicleDanger = function ( self, entity, sender)
--		-- ignored by now, TO DO : a smarter behaviour
--	end,

	--------------------------------------------------------------
--	ORDER_HOLD = function ( self, entity, sender, data ) 
--	end,
	
	--------------------------------------------------------------
--	ORDER_HIDE = function ( self, entity, sender, data)
--	end,
	
	--------------------------------------------------------------
--	ORDER_FORM = function ( self, entity, sender)
--		
--	end,

}
