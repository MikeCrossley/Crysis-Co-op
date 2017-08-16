--------------------------------------------------
-- SneakerAttack
--------------------------
--   created: Mikko Mononen 21-6-2006


AIBehaviour.Cover2RushAttack = {
	Name = "Cover2RushAttack",
	Base = "Cover2Attack",
	alertness = 2,

	Constructor = function (self, entity)

		entity:MakeAlerted();
		
		local target = AI.GetTargetType(entity.id);
		local targetDist = AI.GetAttentionTargetDistance(entity.id);

		local range = entity.Properties.preferredCombatDistance;
		local radius = 4.0;
		if(AI.GetNavigationType(entity.id) == NAV_WAYPOINT_HUMAN) then
			range = range / 2;
			radius = 2.5;
		end
  	AI.SetPFBlockerRadius(entity.id, PFB_ATT_TARGET, 0);
  	AI.SetPFBlockerRadius(entity.id, PFB_BEACON, 0);
  	AI.SetPFBlockerRadius(entity.id, PFB_EXPLOSIVES, radius);
  	AI.SetPFBlockerRadius(entity.id, PFB_DEAD_BODIES, radius/2);

		local ammoLeft = entity:GetAmmoLeftPercent();
		if(ammoLeft < 0.3) then
			entity:Reload();
		end
		
		entity:SelectPipe(0,"sn_rush_attack");
	end,
	---------------------------------------------
	COVER_NORMALATTACK = function (self, entity, sender)
		AI.Signal(SIGNALFILTER_SENDER,1,"TO_ATTACK",entity.id);
	end,
	---------------------------------------------
	OnTargetApproaching	= function (self, entity)
		-- empty
	end,
	---------------------------------------------
	OnTargetFleeing	= function (self, entity)
		-- empty
	end,
	--------------------------------------------------
	OnAdvanceTargetCompromised = function(self, entity, sender, data)
		-- empty
	end,
	--------------------------------------------------
	OnCoverCompromised = function(self, entity, sender, data)
		-- empty
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		-- empty
		entity:TriggerEvent(AIEVENT_DROPBEACON);
	end,
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		entity.AI.lastLiveEnemyTime = _time;
	end,
	---------------------------------------------
	OnGroupMemberDied = function(self, entity)
		-- empty
	end,
	--------------------------------------------------
	OnGroupMemberDiedNearest = function (self, entity, sender, data)
		-- empty
		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 1, "OnGroupMemberDied",entity.id, data);
	end,
	--------------------------------------------------
	OnBulletRain = function(self, entity, sender, data)
		-- empty
	end,
	--------------------------------------------------
	OnNearMiss = function(self, entity, sender)
		-- empty
	end,
	---------------------------------------------
	OnEnemyDamage = function (self, entity, sender, data)
		entity:Readibility("taking_fire",1);
		entity:SelectPipe(0,"do_nothing");
		entity:SelectPipe(0,"sn_bullet_reaction");
		-- avoid this poit for some time.
		if(AI.GetNavigationType(entity.id) == NAV_WAYPOINT_HUMAN) then
			AI.NotifyGroupTacticState(entity.id, 0, GN_AVOID_CURRENT_POS, 2);
		else
			AI.NotifyGroupTacticState(entity.id, 0, GN_AVOID_CURRENT_POS, 15);
		end
		-- Allow to change cover quickly.
		entity.AI.changeCoverInterval = 0;
	end,
	---------------------------------------------
	OnBadHideSpot = function ( self, entity, sender,data)
		-- empty
	end,
	--------------------------------------------------
	OnNoHidingPlace = function( self, entity, sender,data )
		-- empty
	end,	
	--------------------------------------------------
	OnNoPathFound = function( self, entity, sender,data )
		-- failed the rush, back to normal attack.
		AI.Signal(SIGNALFILTER_SENDER,1,"TO_ATTACK",entity.id);
	end,	
	--------------------------------------------------
	OnOutOfAmmo = function (self,entity, sender)
			-- Try to choose secondary weapon first.
		if(entity:CheckCurWeapon(1) == 0) then
			if(entity:SelectSecondaryWeapon()) then
				return;
			end
		end
		AI.Signal(SIGNALFILTER_SENDER,1,"TO_RELOAD",entity.id);
	end,

	--------------------------------------------------
	OnFriendInWay = function(self, entity)
	end,

	--------------------------------------------------
	OnPlayerLooking = function(self, entity)
	end,

	--------------------------------------------------
	MAN_DOWN = function(self, entity)
	end,
}
