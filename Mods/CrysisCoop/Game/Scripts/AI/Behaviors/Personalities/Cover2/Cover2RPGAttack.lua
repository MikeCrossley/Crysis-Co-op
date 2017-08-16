--------------------------------------------------
--   Description: 	cover using RPG when target is a tank
--------------------------
--

AIBehaviour.Cover2RPGAttack = {
	Name = "Cover2RPGAttack",
	alertness = 2,
	exclusive = 1,
	fleeDistance = 15,

	-----------------------------------------------------
	Constructor = function(self,entity)

		entity:MakeAlerted(1);

		entity.actor:SelectItemByName("LAW");
		AI_Utils:ChangeRPGAttackSlot(entity,1);
		self:RPG_ATTACK(entity);
		entity.AI.hideTimer = nil;
		entity.AI.attackTimer = nil;		
	end,
	
	-----------------------------------------------------
	Destructor = function(self,entity)
		AI_Utils:ChangeRPGAttackSlot(entity,-1);
		entity:SelectPrimaryWeapon();

		if (entity.AI.hideTimer) then
			Script.KillTimer(entity.AI.hideTimer);
			entity.AI.hideTimer = nil;
		end
		AIBehaviour.Cover2AvoidTank.ResetAttackDelay(self,entity);		
	end,


	-- 
	--------------------------------------------------	
	FindRPGSpot  = function (self, entity, needToMove)
		-- Try to find good shot spot.
		local	attackPos = nil;
		if(needToMove) then
			attackPos = AI.GetDirectAnchorPos(entity.id, AIAnchorTable.RPG_SPOT, 2, 30);
		end
		if(attackPos == nil) then
			attackPos = AI.GetDirectAnchorPos(entity.id, AIAnchorTable.RPG_SPOT, 0, 30);
		end		
		if(attackPos) then
--			local	attTargPos = g_Vectors.temp_v1;
--			if(AI.GetBeaconPosition(entity.id, attTargPos)) then
--				local distToTarget = DistanceVectors(attackPos, attTargPos);
			local	attTargPos = g_Vectors.temp_v1;
			if(AI.GetAttentionTargetPosition(entity.id, attTargPos)) then
				local distToTarget = DistanceVectors(attackPos, attTargPos);
				if(distToTarget < AIBehaviour.Cover2RPGAttack.fleeDistance) then
--					return nil
					return AIBehaviour.Cover2RPGAttack.FindRPGSpot(self, entity, needToMove)
				end
			end	
			entity.AI.RPG_spot = {};
			CopyVector(entity.AI.RPG_spot, attackPos);
			return 1
		else
			entity.AI.RPG_spot = nil;
			return nil
		end	
	end,




	--------------------------------------------------
	ApproachRPGSpot  = function (self, entity, firstTime)
		
		local dist1 = DistanceVectors(entity.AI.RPG_spot, entity:GetWorldPos());
		if(dist1 < 1.5) then
			AI.Signal(SIGNALFILTER_SENDER,0,"RPG_ONSPOT",entity.id);
			return
		end
		AI.SetRefPointPosition(entity.id, entity.AI.RPG_spot );
		entity:SelectPipe(0,"approachRPG");
	end,


	--------------------------------------------------
	OnOutOfAmmo = function (self,entity, sender)
		-- just reload - AI should have unlimiter rockets
		-- player would not have Reload implemented
		if(entity.Reload == nil)then return end
		entity:Reload();
		
--		-- out of ammo, run!
--		entity:Readibility("explosion_imminent",1,1,0.1,0.4);
--		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_AVOID_TANK",entity.id);
	end,


	--------------------------------------------------
	RPG_ATTACK = function(self, entity, sender, data)

		local	distToTarget = AI.GetAttentionTargetDistance(entity.id);
		if((targetType == AITARGET_ENEMY or targetType == AITARGET_MEMORY) and distToTarget < AIBehaviour.Cover2RPGAttack.fleeDistance) then
		

			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_AVOID_TANK",entity.id);
			do return end
		end
	
		if(self:FindRPGSpot(entity) ~= nil) then
			self:ApproachRPGSpot(entity)
		else

			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_AVOID_TANK",entity.id);		
		end
	
	
	
--		local targetType = AI.GetTargetType(entity.id); -- ==AITARGET_NONE) then
--		local	distToTarget = AI.GetAttentionTargetDistance(entity.id);
--		if((targetType == AITARGET_ENEMY or targetType == AITARGET_MEMORY) and distToTarget > 20.0) then
--			-- If target is visibe and we are at safe range, just shoot!
--			entity:SelectPipe(0,"testRPG");
--		else
--			-- Try to find good shot spot.
--			local	attackPos = AI.GetDirectAttackPos(entity.id, 25, 30);
--			if(attackPos) then
--				AI.SetRefPointPosition(entity.id, attackPos);
--				entity:SelectPipe(0,"approachRPG");
--			else
--				-- Could not find good spot, run away.
--				entity:SelectPipe(0,"fleeRPG");
--			end
--		end
	end,

	--------------------------------------------------
	RPG_ONSPOT = function(self, entity, sender, data)
		local targetType = AI.GetTargetType(entity.id);
		local	distToTarget = AI.GetAttentionTargetDistance(entity.id);
		if((targetType == AITARGET_ENEMY or targetType == AITARGET_MEMORY) and distToTarget > AIBehaviour.Cover2RPGAttack.fleeDistance-3) then
			-- If target is visibe and we are at safe range, just shoot!
			entity:SelectPipe(0,"testRPG");
		else
--			if(self:FindRPGSpot(entity) ~= nil) then
--				self:ApproachRPGSpot(entity)
--			else
				entity:SelectPipe(0,"fleeRPG");
--			end
		end
	end,
	
	
	---------------------------------------------
	WPN_SHOOT = function( self, entity)
		entity:SelectPipe(0,"waitRPG");
	end,

	---------------------------------------------
	---------------------------------------------		
	OnPlayerSeen = function( self, entity, fDistance )
		entity:MakeAlerted();
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		-- switch to combat only after some delay
		entity.AI.attackTimer = Script.SetTimerForFunction(2*1000,"AIBehaviour.Cover2AvoidTank.OnAttackTimer",entity);		
	end,


	---------------------------------------------
	OnTankSeen = function( self, entity, fDistance )
		AIBehaviour.Cover2AvoidTank.ResetAttackDelay(self,entity);
		local	distToTarget = AI.GetAttentionTargetDistance(entity.id);
		if(distToTarget < AIBehaviour.Cover2RPGAttack.fleeDistance-3) then
			entity:SelectPipe(0,"fleeRPG");
		end
	end,
	
	---------------------------------------------
	OnTargetApproaching	= function (self, entity)
		entity:SelectPipe(0,"fleeRPG");
	end,
	
	---------------------------------------------
	OnHeliSeen = function( self, entity, fDistance )
	end,

	--------------------------------------------------
	OnCoverCompromised = function(self, entity, sender, data)
	end,

	--------------------------------------------------
	OnNoHidingPlace = function(self, entity, sender,data)
	end,

	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		if (entity.AI.hideTimer) then
			Script.KillTimer(entity.AI.hideTimer);
			entity.AI.hideTimer = nil;
		end
		entity.AI.hideTimer = Script.SetTimerForFunction(15*1000,"AIBehaviour.Cover2RPGAttack.OnUnhideTimer",entity);
	end,

	-----------------------------------------------------
	OnUnhideTimer = function(entity,timerid)
		entity.AI.hideTimer = nil;
		local target = AI.GetTargetType(entity.id);
		if(target==AITARGET_ENEMY) then
			AI.Signal(SIGNALFILTER_SENDER,1,"RPG_ATTACK",entity.id);
		else
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_SEEK",entity.id);
		end
	end,
	
	---------------------------------------------
	OnNoTarget = function( self, entity )
	end,

	---------------------------------------------		
	OnObjectSeen = function( self, entity, fDistance )
	end,

	---------------------------------------------		
	OnInterestingSoundHeard = function( self, entity, fDistance )
	end,

	---------------------------------------------		
	OnThreateningSoundHeard = function( self, entity, fDistance )
	end,

	---------------------------------------------
	OnThreateningSeen = function( self, entity )
	end,

	---------------------------------------------
	OnNearMiss = function ( self, entity, sender,data)
--		AI.Signal(SIGNALFILTER_SENDER,1,"RPG_ATTACK",entity.id);
	end,

	---------------------------------------------
	OnCloseCollision = function ( self, entity, sender,data)
--		AIBehaviour.Cover2RPGAttack.OnEnemyDamage(self,entity);
	end,

	
	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender,data)
--		AI.Signal(SIGNALFILTER_SENDER,1,"RPG_ATTACK",entity.id);

		local	distToTarget = AI.GetAttentionTargetDistance(entity.id);
		if((targetType == AITARGET_ENEMY or targetType == AITARGET_MEMORY) 
				and distToTarget < AIBehaviour.Cover2RPGAttack.fleeDistance-3) then
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_AVOID_TANK",entity.id);		
			do return end
		end
	
		if(self:FindRPGSpot(entity, 1) ~= nil) then
			self:ApproachRPGSpot(entity)
		else
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_AVOID_TANK",entity.id);		
		end

	end,

	---------------------------------------------
	OnReload = function( self, entity )
	end,

	--------------------------------------------------------
	OnHideSpotReached = function(self,entity,sender)
	end,

	--------------------------------------------------
	OnLowHideSpot = function( self, entity, sender)
	end,

	--------------------------------------------------
	END_HIDE = function(self,entity,sender)
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
	
	---------------------------------------------
	PANIC_DONE = function(self, entity)
	end,
	
	---------------------------------------------
	OnExposedToExplosion = function(self, entity, data)
	end,

}
