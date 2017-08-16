--------------------------------------------------
--	Created  Luciano Morpurgo
--   Description: The group hide behaviour 
--------------------------

AIBehaviour.GroupHide = {
	Name = "GroupHide",

	Constructor = function ( self, entity,data )
		if(data and IsNotNullVector(data.point)) then 
			AI.SetRefPointPosition(entity.id,data.point);
			AI.LogEvent(entity:GetName().." Group Hide at "..Vec2Str(data.point));
		end
		
		local target = AI.GetGroupTarget(entity.id,true,true);
--		local target;
--		if(targetId) then
--			target = System.GetEntity(targetId);
--		end
		if(target	and target.isAlien) then 
			AI.SetPFBlockerRadius( entity.id, PFB_ATT_TARGET, 8);
			AI.SetPFBlockerRadius( entity.id, PFB_BEACON, 10);
		else
--			AI.SetPFBlockerRadius( entity.id, PFB_ATT_TARGET, 5);
			AI.SetPFBlockerRadius( entity.id, PFB_BEACON, 7);
		end
		
		if(data and data.iValue==1) then 
			entity:SelectPipe(0,"hide_fast_nosame");		
		elseif(data==nil or data.iValue==2) then
			entity:SelectPipe(0,"hide_fast");		
		else
			entity:SelectPipe(0,"hide_fast_fire");		
		end
		entity:MakeAlerted();
	end,
	-----------------------------------------------------
	Destructor = function(self,entity)
		AI.SetPFBlockerRadius( entity.id, PFB_ATT_TARGET, 0);
		AI.SetPFBlockerRadius( entity.id, PFB_BEACON, 0);
		entity:SelectPipe(0,"do_nothing");-- for when leader action is finished
	end,
	
	-----------------------------------------------------
	OnPlayerSeen = function(self,entity, distance)
		AI.SetPFBlockerRadius( entity.id, PFB_ATT_TARGET, 8);
	end,

	-----------------------------------------------------
	OnLeaderActionCompleted = function(self,entity,sender,data)
		if(entity.AI.bIsLeader) then
			AIBehaviour.LeaderIdle:OnLeaderActionCompleted(entity,sender,data);
		end
	end,

	---------------------------------------------
	OnLeaderDied = function ( self, entity, sender)
		entity.AI.InSquad = 0;
	end,
	---------------------------------------------
	OnNoTarget = function(self, entity,sender)
		if(entity.AI.InSquad ==0) then 
			AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_IDLE",entity.id);
		end
	end,
	---------------------------------------------
	OnSeenByEnemy = function( self, entity, sender )
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
		--entity:InsertSubpipe(0,"stop_fire");
--		local attDist = AI.GetAttentionTargetDistance(entity.id);
--		AI.SetPFBlockerRadius( entity.id, PFB_ATT_TARGET, 0);
--		if(entity.AI.InSquad~=1) then 
--			
--		end
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

		
	end,

	---------------------------------------------
	CORD_ATTACK = function( self, entity, sender )
		-- Ignore this order!
	end,

	---------------------------------------------	
	-- Orders --
	---------------------------------------------


	ORDER_FIRE = function( self, entity )
	end,
	
	---------------------------------------------
	OnCloseContact = function( self, entity )
	end,


	---------------------------------------------

	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		-- called when the enemy hears an interesting sound
		AI.SetPFBlockerRadius( entity.id, PFB_ATT_TARGET, 0);
	end,
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
		-- called when the enemy hears a scary sound
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

	end,

	---------------------------------------------
	END_HIDE_FIRE = function(self, entity, sender)
		entity:SelectPipe(0,"just_shoot");
		AI.Signal(SIGNALFILTER_LEADER,10,"ORD_DONE",entity.id);
	end,
	---------------------------------------------
	END_HIDE = function(self, entity, sender)
		entity:SelectPipe(0,"just_shoot");
		AI.Signal(SIGNALFILTER_LEADER,10,"ORD_DONE",entity.id);
	end,
	---------------------------------------------
	INCOMING_FIRE = function(self, entity, sender)
	end,
	--------------------------------------------------

}
