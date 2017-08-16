--------------------------------------------------
--	Created  Luciano Morpurgo
--   Description: Group combat: AI unhides, fires and then he's ready to hide again
--------------------------

AIBehaviour.GroupUnHide = {
	Name = "GroupUnHide",

	Constructor = function ( self, entity )
		entity:SelectPipe(0,"do_nothing");
		if(AI.GetTargetType(entity.id)==AITARGET_ENEMY) then
			entity:InsertSubpipe(0,"unhide_and_fire");		
		else
			entity:InsertSubpipe(0,"unhide");		
		end		
	end,
	-----------------------------------------------------
	Destructor = function(self,entity)
		AI.SetPFBlockerRadius( entity.id, PFB_ATT_TARGET, 0);
		AI.SetPFBlockerRadius( entity.id, PFB_BEACON, 0);
		entity:InsertSubpipe(0,"stop_fire");		
	end,
	
	-----------------------------------------------------
	OnLeaderActionCompleted = function(self,entity,sender,data)
		if(entity.AI.bIsLeader) then
			AIBehaviour.LeaderIdle:OnLeaderActionCompleted(entity,sender,data);
		end
	end,
	-----------------------------------------------------
	OnPlayerSeen = function( self, entity, sender )
		entity:SelectPipe(0,"fire_and_hide");		
	end,	
	
	-----------------------------------------------------
	OnSeenByEnemy = function( self, entity, sender )
	end,
	---------------------------------------------
	OnNoTarget = function(self, entity,sender)
		if(entity.AI.InSquad ==0) then 
			AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_IDLE",entity.id);
		end
	end,
	---------------------------------------------
	OnPlayerSeenByEnemy = function( self, entity, sender )
	end,
	
	---------------------------------------------
	NotifyPlayerSeen = function( self, entity, sender )
		-- Already notified
	end,

	---------------------------------------------
	OnEnemyMemory = function ( self, entity, distance)
		entity:InsertSubpipe(0,"stop_fire");
		local attDist = AI.GetAttentionTargetDistance(entity.id);
		AI.SetPFBlockerRadius( entity.id, PFB_ATT_TARGET, 0);
	end,
	
	---------------------------------------------
	OnDamage = function ( self, entity, sender, data)
	end,
	
	---------------------------------------------
	OnFriendlyDamage = function ( self, entity, sender, data)
		-- TO DO: Readability "Watch your fire!"
	end,
	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender, data)
		-- data.id: the shooter
		entity:Readibility("GETTING_SHOT_AT",1);

		if (not entity.AI.bAllowedFire) then
			AI.Signal(SIGNALFILTER_LEADER, 1, "OnEnableFire",entity.id);
		end
		
	end,

	---------------------------------------------
	CORD_ATTACK = function( self, entity, sender )
		-- Ignore this order!
	end,

	---------------------------------------------	
	-- Orders --
	---------------------------------------------


	ORDER_FIRE = function( self, entity )
		AI.Signal(SIGNALFILTER_LEADER,10,"ORD_DONE",entity.id);
	end,
	
	---------------------------------------------
	OnCloseContact = function( self, entity )
	end,


	---------------------------------------------

	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		-- called when the AI hears an interesting sound
		AI.SetPFBlockerRadius( entity.id, PFB_ATT_TARGET, 0);
		AI.Signal(SIGNALFILTER_SENDER, 1, "END_UNHIDE",entity.id);
	end,
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
		-- called when the AI hears a scary sound
		AI.Signal(SIGNALFILTER_SENDER, 1, "END_UNHIDE",entity.id);
		AIBehaviour.DEFAULT:SetTargetDistance(entity,10);
	end,
	---------------------------------------------
	OnReload = function( self, entity )
		-- called when the enemy goes into automatic reload after its clip is empty
--		entity:InsertSubpipe(0, "reload_combat");
	end,
	---------------------------------------------
	OnGroupMemberDied = function( self, entity )
		-- called when a member of the group dies
	end,
	---------------------------------------------
	OnSomebodyDied = function( self, entity )
		
	end,
	---------------------------------------------
	OnGroupMemberDiedNearest = function ( self, entity, sender,data)
	end,
	---------------------------------------------
	OnNoHidingPlace = function( self, entity, sender )
		-- called when no hiding place can be found with the specified parameters
	end,	
	--------------------------------------------------
	OnNoFormationPoint = function ( self, entity, sender)
		-- called when the enemy found no formation point
	end,
	---------------------------------------------
	OnReceivingDamage = function ( self, entity, sender)
		-- called when the enemy is damaged
	end,
	---------------------------------------------
	OnCoverRequested = function ( self, entity, sender)
		-- called when the enemy is damaged
	end,
	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender)
		-- called when the enemy detects bullet trails around him
		if (not entity.AI.bAllowedFire) then
			AI.Signal(SIGNALFILTER_LEADER, 1, "OnEnableFire",entity.id);
		end
	end,

	---------------------------------------------
	INCOMING_FIRE = function(self, entity, sender)
	end,
	--------------------------------------------------

}
