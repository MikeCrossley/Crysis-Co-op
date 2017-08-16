--------------------------------------------------
-- SuitReaload
-- : Handle reloading during combat for nano-suit AI.
-- AI with nano suit
--------------------------
--   created: Kirill Bulatsev 30-10-2006


AIBehaviour.SuitReload = {
	Name = "SuitReload",
	Base = "Cover2Reload",
	alertness = 2,

	-----------------------------------------------------
	Constructor = function(self,entity)

		AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_UNAVAIL);

		entity:GettingAlerted();
  	AI.SetPFBlockerRadius(entity.id, PFB_ATT_TARGET, 0);
  	AI.SetPFBlockerRadius(entity.id, PFB_BEACON, 0);
  	AI.SetPFBlockerRadius(entity.id, PFB_DEAD_BODIES, 0);
  	AI.SetPFBlockerRadius(entity.id, PFB_EXPLOSIVES, 0);

--		Log(entity:GetName().." Out of ammo");

		local target = AI.GetTargetType(entity.id);
		local targetDist = AI.GetAttentionTargetDistance(entity.id);
		local range = entity.Properties.preferredCombatDistance/2;
		if(AI.GetNavigationType(entity.id) == NAV_WAYPOINT_HUMAN) then
			range = range / 2;
		end
		
--entity:SelectPipe(0,"cv_cqb_melee");
--do return end
		
		if(target==AITARGET_ENEMY and targetDist < range and random(1,10) < 4 and not entity.AI.lastOutOfAmmoMelee) then
--		if(target==AITARGET_ENEMY and not entity.AI.lastOutOfAmmoMelee) then
			--Log(" - melee");
			-- Try melee
			entity.AI.lastPlayerLookingTime = _time + 5.0;
			entity.AI.lastFriendInWayTime = _time + 5.0;
			entity:SelectPipe(0,"cv_cqb_melee");
			entity.AI.lastOutOfAmmoMelee = true;
		else
			-- Reload
--			Log(" - try reload in cover");
			entity:SelectPipe(0,"sn_use_cover_reload");
			entity.AI.tryingToReload = true;
			entity.AI.lastOutOfAmmoMelee = false;
		end
	end,
	
	-----------------------------------------------------
	Destructor = function(self,entity)
	end,

	---------------------------------------------
	---------------------------------------------
	OnEnemyDamage = function (self, entity, sender, data)
		entity:Readibility("taking_fire",1);
		-- avoid this poit for some time.
		if(AI.GetNavigationType(entity.id) == NAV_WAYPOINT_HUMAN) then
			AI.NotifyGroupTacticState(entity.id, 0, GN_AVOID_CURRENT_POS, 2);
		else
			AI.NotifyGroupTacticState(entity.id, 0, GN_AVOID_CURRENT_POS, 15);
		end
		
		entity:NanoSuitMode( BasicAI.SuitMode.SUIT_ARMOR );
		-- suit guy hides only if health is low
		if(entity:GetHealthPercentage()<50) then
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_HIDE",entity.id);
		end
	end,
	
	------------------------------------------------------------------------
	HANDLE_RELOAD = function(self,entity,sender)
		entity:SelectPipe(0,"do_nothing");
		entity:Readibility("reloading",1,0.1,0.4);
		entity:Reload();
	end,
	
	--------------------------------------------------
}
