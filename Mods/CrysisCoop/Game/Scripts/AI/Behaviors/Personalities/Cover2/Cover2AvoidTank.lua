--------------------------------------------------
--------------------------

AIBehaviour.Cover2AvoidTank = {
	Name = "Cover2AvoidTank",
	alertness = 2,
	exclusive = 1,

	-----------------------------------------------------
	Constructor = function(self,entity)
		entity:GettingAlerted();

		entity.AI.coverCompromized = false;	
		entity.AI.lastHideTime = _time;
		entity.AI.hideTimer = nil;
		entity.AI.attackTimer = nil;
		entity.AI.hideCounter = 0;

  	AI.SetPFBlockerRadius(entity.id, PFB_ATT_TARGET, 3);
  	AI.SetPFBlockerRadius(entity.id, PFB_BEACON, 0);
  	AI.SetPFBlockerRadius(entity.id, PFB_DEAD_BODIES, 0);
  	AI.SetPFBlockerRadius(entity.id, PFB_EXPLOSIVES, 3);

		

		self:HandleThreat(entity,true);
	end,
	
	-----------------------------------------------------
	Destructor = function(self,entity)
		if (entity.AI.hideTimer) then
			Script.KillTimer(entity.AI.hideTimer);
			entity.AI.hideTimer = nil;
		end
		self:ResetAttackDelay(entity);
	end,

	-----------------------------------------------------
	HandleThreat = function(self, entity, resetTimer)

		local target = AI.GetTargetType(entity.id);
		if(entity.AI.hideCounter > 2) then
			if(target==AITARGET_ENEMY or target==AITARGET_MEMORY) then
				if( AI_Utils:HasRPGAttackSlot(entity) and entity.inventory:GetItemByClass("LAW") 
						and AIBehaviour.Cover2RPGAttack.FindRPGSpot(self, entity) ~= nil) then
					AI.Signal(SIGNALFILTER_SENDER, 1, "TO_RPG_ATTACK", entity.id);
				else
					-- normally this is done in constructor of Cover2Hide 
					entity.AI.lastBulletReactionTime = _time - 10;
					AIBehaviour.Cover2Hide.HandleThreat(self, entity);
				end	
			else
				AI.Signal(SIGNALFILTER_SENDER, 1, "TO_SEEK", entity.id);
			end		
		end
		entity.AI.hideCounter = entity.AI.hideCounter+1;

		-- keep on hiding no matter what, and after the timer has fired, try to come out of cover.
		if(target==AITARGET_ENEMY or target==AITARGET_MEMORY) then
			-- Hide from attention target
			if(AI.GetAttentionTargetDistance(entity.id) < 5.0) then
				self:HandleBackoff(entity);
			else
				entity:Readibility("explosion_imminent",1,1,0.1,0.4);
				entity:SelectPipe(0,"cv_hide_from_tank");
			end
		else
			-- Hide from beacon
			entity:Readibility("explosion_imminent",1,1,0.1,0.4);
			entity:SelectPipe(0,"cv_hide_from_tank_beacon");
		end

	end,

	-----------------------------------------------------
	HandleBackoff = function(self, entity, resetTimer)
		entity:Readibility("explosion_imminent",1,1,0.1,0.4);
		entity:SelectPipe(0,"cv_backoff_from_tank");
	end,

	--------------------------------------------------
	HIDE_DONE = function(self, entity)
		self:HandleThreat(entity, false);
	end,

	--------------------------------------------------
	OnCoverCompromised = function(self, entity, sender, data)
		self:HandleThreat(entity, false);
	end,

	-----------------------------------------------------
	OnUnhideTimer = function(entity,timerid)
		--AI.LogEvent(entity:GetName().." OnUnhideTimer");
		entity.AI.hideTimer = nil;
		local target = AI.GetTargetType(entity.id);
		if(target==AITARGET_ENEMY or target==AITARGET_MEMORY) then
			AIBehaviour.Cover2AvoidTank:HandleThreat(entity, false);
		else
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_SEEK",entity.id);
		end
	end,

	-----------------------------------------------------
	OnAttackTimer = function(entity,timerid)
		--AI.LogEvent(entity:GetName().." OnUnhideTimer");
		entity.AI.attackTimer = nil;
		local target = AI.GetTargetType(entity.id);
		if(target==AITARGET_ENEMY or target==AITARGET_MEMORY) then
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_ATTACK",entity.id);
		else
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_SEEK",entity.id);
		end
	end,

	--------------------------------------------------
	ResetAttackDelay = function(self, entity, sender,data)
		if (entity.AI.attackTimer) then
			Script.KillTimer(entity.AI.attackTimer);
			entity.AI.attackTimer = nil;
		end
	end,

	--------------------------------------------------
	OnNoHidingPlace = function(self, entity, sender,data)
		self:HandleBackoff(entity);
	end,

	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the enemy stops having an attention target
	end,
	
	---------------------------------------------
	OnNoTarget = function( self, entity )
		-- called when the enemy stops having an attention target
	end,

	---------------------------------------------
	OnGroupMemberDied = function( self, entity )
		-- called when a member of the group dies
	end,

	---------------------------------------------
	OnGroupMemberDiedNearest = function ( self, entity, sender, data )
		AI.Signal(SIGNALFILTER_GROUPONLY, 1, "OnGroupMemberDied",entity.id, data );
	end,

	---------------------------------------------		
	OnPlayerSeen = function( self, entity, fDistance )
		entity:MakeAlerted();
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		-- switch to combat only after some delay
		entity.AI.attackTimer = Script.SetTimerForFunction(2*1000,"AIBehaviour.Cover2AvoidTank.OnAttackTimer",entity);		
	end,

	---------------------------------------------
	OnTankSeen = function( self, entity, fDistance )
		self:ResetAttackDelay(entity);
		if( AI_Utils:HasRPGAttackSlot(entity) and entity.inventory:GetItemByClass("LAW") 
				and AIBehaviour.Cover2RPGAttack.FindRPGSpot(self, entity) ~= nil) then
			entity:Readibility("suppressing_fire",1,1,0.1,0.4);
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_RPG_ATTACK",entity.id);
		else
			self:HandleThreat(entity, true);
		end
	end,
	
	---------------------------------------------
	OnHeliSeen = function( self, entity, fDistance )
		self:HandleThreat(entity, true);
	end,

	---------------------------------------------		
	OnInterestingSoundHeard = function( self, entity, fDistance )
		self:HandleThreat(entity, false);
	end,

	---------------------------------------------		
	OnThreateningSoundHeard = function( self, entity, fDistance )
		self:HandleThreat(entity, false);
	end,

	---------------------------------------------
	OnThreateningSeen = function( self, entity )
		self:HandleThreat(entity, false);
	end,

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender,data)

		-- called when the enemy is damaged
		self:HandleThreat(entity);
		
		-- set the beacon to the enemy pos
		local shooter = System.GetEntity(data.id);
		if(shooter) then
			AI.SetBeaconPosition(entity.id, shooter:GetPos());
			AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT,1,"INCOMING_FIRE",entity.id);
		end
		
		entity:Readibility("taking_fire",1,2,0.1,0.4);
		
	end,

	---------------------------------------------
	OnDamage = function ( self, entity, sender,data)
	end,

	--------------------------------------------------
	OnBulletRain = function(self, entity, sender, data)
		if(AI.Hostile(entity.id, data.id)) then
			self:HandleThreat(entity, false);
			entity:Readibility("bulletrain",1,1,0.1,0.4);
		end
	end,

	---------------------------------------------
	OnNearMiss = function(self, entity, sender)
		if(AI.Hostile(entity.id, sender.id)) then
			self:HandleThreat(entity, false);
			entity:Readibility("bulletrain",1,1,0.1,0.4);
		end
	end,

	---------------------------------------------
	OnReload = function( self, entity )
--		entity:Readibility("reloading",1);
	end,

	--------------------------------------------------------
	OnHideSpotReached = function(self,entity,sender)
	end,

	--------------------------------------------------
	OnLowHideSpot = function( self, entity, sender)
	end,

	--------------------------------------------------
	OnSomethingSeen = function(self,entity,sender)
	end,
	
	--------------------------------------------------
	ENEMYSEEN_FIRST_CONTACT = function(self,entity,sender)
	end,

	--------------------------------------------------
	ENEMYSEEN_DURING_COMBAT = function(self,entity,sender)
	end,
	
	--------------------------------------------------
	OnGroupMemberDiedNearest	= function(self,entity,sender)
	end,

	--------------------------------------------------
	MOUNTED_WEAPON_USABLE = function(self,entity,sender,data)
		-- sent by smart object rule
		if(data and data.id) then 
			local weapon = System.GetEntity(data.id);
			if(weapon) then
				AI.ModifySmartObjectStates(weapon.id,"Idle,-Busy");				
			end
		end
		AI.ModifySmartObjectStates(entity.id,"-Busy");				
	end,
	
}
