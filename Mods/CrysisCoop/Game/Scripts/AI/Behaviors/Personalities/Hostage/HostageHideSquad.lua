--------------------------------------------------
--   Created By: Luciano
--   Description: Hostage hides nearby
--------------------------

AIBehaviour.HostageHideSquad = {
	Name = "HostageHideSquad",
	--TASK = 1,

	Constructor = function(self, entity,data)
--		entity:SelectPipe(0,"hold");
--		entity:InsertSubpipe(0,"approach_refpoint");
--		entity:InsertSubpipe(0,"do_it_running");
--		entity:InsertSubpipe(0,"do_it_standing");
--		entity:InsertSubpipe(0,"clear_all");
		entity:SelectPipe(0,"hostage_hide");
		--AI.SetIgnorant(entity.id,1);
		entity.AI.hidden = false;
	end,
	---------------------------------------------
	Destructor = function(self, entity)
		--AI.SetIgnorant(entity.id,0);
	end,

	---------------------------------------------
	OnNoTarget = function( self, entity )
--		entity:SelectPipe(0,"confirm_targetloss");
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, distance )
	end,
	---------------------------------------------
--	OnEnemyMemory = function( self, entity, fDistance )
--		-- try to re-establish contact
--		entity:SelectPipe(0,"seek_target");
--		entity:InsertSubpipe(0,"reload");
--
--		if (fDistance > 10) then 
--			entity:InsertSubpipe(0,"do_it_running");
--		else
--			entity:InsertSubpipe(0,"do_it_walking");
--		end
--				
--	end,
	---------------------------------------------
	OnReload = function( self, entity )

	end,

	---------------------------------------------
	OnGroupMemberDied = function( self, entity )
	end,

	--------------------------------------------------
	OnGroupMemberDiedNearest = function ( self, entity, sender)
		self:OnBulletRain(entity,sender,data);
	end,

	---------------------------------------------
	OnNoHidingPlace = function( self, entity, sender )
	end,	


	--------------------------------------------------
	-- CUSTOM SIGNALS
	--------------------------------------------------
	---------------------------------------------
	LOOK_FOR_TARGET = function (self, entity, sender)
		-- do nothing on this signal
		entity:SelectPipe(0,"look_around");
	end,	


	---------------------------------------------
	LOOK_LEFT = function (self, entity, sender)
	
		local direction = math.random(2,6)*(-10)-50;
		entity:InsertSubpipe(0,"LookAround"..direction);	
		
	end, 
	
	---------------------------------------------
	LOOK_RIGHT = function (self, entity, sender)
		
		local direction = math.random(2,6)*10 +50;
		entity:InsertSubpipe(0,"LookAround"..direction);
		
	end,
	
	---------------------------------------------
	FORMATION_REACHED = function (self, entity, sender)
--		entity.bIgnoreEnemy = false;
	end, 

	---------------------------------------------
	START_HIDE = function (self, entity, sender)
		entity.AI.hidden = false;
		entity.AI.Cower = false;
	end,
	---------------------------------------------
	END_HIDE = function (self, entity, sender)
		entity:SelectPipe(0,"hostage_stay_hidden");
		entity.AI.hidden = true;
		if(entity.AI.Cower) then 
			entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"hostage_cower");
		end
		--AI.SetIgnorant(entity.id,0);
	end,
	
	---------------------------------------------
	HIDE_FAILED = function (self, entity, sender)
--		entity:SetTimer(CHECK_HIDE_TIMER,5000);
	end,
	
--	---------------------------------------------
--	OnHideSpotFound = function (self, entity, sender,data)
--		AI.SetRefpointPosition(entity.id,data.point);
--		entity:SelectPipe(0,"hostage_hide_refpoint")
--	end,
--	
--	---------------------------------------------
--	OnHideSpotNotFound = function (self, entity, sender,data)
--		entity:SetTimer(CHECK_HIDE_TIMER,5000);
--	end,
	
	---------------------------------------------
	CHECK_DANGER = function (self, entity, sender)
		local targetType = AI.GetGroupTarget(entity.id);
		if(targetType == AITARGET_NONE or targetType ==AITARGET_FRIENDLY) then
			AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_FOLLOW",entity.id);
		end
	end,	
	
	---------------------------------------------
	OnThreateningSoundHeard= function (self, entity, sender)
		-- redo timeout again after gunshots
	end,	
	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender,data)
		self:OnBulletRain(entity,sender,data);
	end,
	---------------------------------------------
	OnFriendlyDamage = function ( self, entity, sender,data)
		self:OnBulletRain(entity,sender,data);
	end,
	---------------------------------------------
	OnBulletRain = function ( self, entity, sender,data)
		--entity:Readibility("GETTING_SHOT_AT",1);
		if(entity.AI.hidden) then 
--			entity:SelectPipe(0,"do_nothing");
--			entity:SelectPipe(0,"hostage_hold");
			if(not entity.AI.Cower) then 
				entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"hostage_cower");
			end
		end
		entity.AI.Cower = true;
	end,
	
	---------------------------------------------
	OnNearMiss = function ( self, entity, sender,data)
		self:OnBulletRain(entity,sender,data);
	end,

	---------------------------------------------
	CHECK_COWER = function (self, entity, sender)
		entity.AI.Cower = true;
		AIBehaviour.CivilianIdle:SearchCower(entity);
	end,
	---------------------------------------------
	GoHiding = function (entity,timerId)
	end,
	
	---------------------------------------------
	ORDER_FOLLOW = function ( self, entity, sender )

	end,

	---------------------------------------------
	ORDER_FOLLOW_FIRE = function ( self, entity, sender )
		entity:SelectPipe(0,"do_nothing");
		entity:SelectPipe(0,"hostage_hide");
		--AI.SetIgnorant(entity.id,1);
	end,
	
	---------------------------------------------
	OnLeaderMoving = function ( self, entity, sender )
		entity:SelectPipe(0,"do_nothing");
		entity:SelectPipe(0,"hostage_hide");
		--AI.SetIgnorant(entity.id,1);
	end,

}
	