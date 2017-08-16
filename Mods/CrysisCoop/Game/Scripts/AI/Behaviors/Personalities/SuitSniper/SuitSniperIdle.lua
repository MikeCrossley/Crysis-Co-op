--------------------------------------------------
-- SuitSniperIdle
--------------------------
--   created: Mikko Mononen 28-4-2007

AIBehaviour.SuitSniperIdle = {
	Name = "SuitSniperIdle",
	alertness = 0,
	
	-----------------------------------------------------
	Constructor = function (self, entity)
		entity:InitAIRelaxed();

		entity:NanoSuitMode(BasicAI.SuitMode.SUIT_ARMOR);
		
		entity:SelectPipe(0,"do_nothing");

--		entity:NanoSuitMode(BasicAI.SuitMode.SUIT_POWER);

--		entity.actor:SelectItemByName("DSG1");
--		entity:SelectPrimaryWeapon();

		AI.EnableWeaponAccessory(entity.id, AIWEPA_LASER, false);

		AI.ChangeParameter(entity.id, AIPARAM_MELEE_DISTANCE, 4.0);

--		entity:DrawWeaponNow();

--		entity.AI.protect = 0;

--		AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_ADVANCING);

		entity.AI.lastBulletReactionTime = _time - 10.0;
		entity.AI.lastStuntTime = _time - 100;
		
		entity.AI.temp = 0;
		
		entity.AI.dodgeHealthDec = entity.actor:GetMaxHealth() / 8;
		entity.AI.dodgeHealthThr = entity.actor:GetHealth() - entity.AI.dodgeHealthDec;
		
	end,

	-----------------------------------------------------
	Destructor = function(self,entity)
	end,

	---------------------------------------------
	OnQueryUseObject = function ( self, entity, sender, extraData )
	end,

	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance, data )
--		entity:MakeAlerted();
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		entity.AI.firstContact = true;
		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 1, "ENEMYSEEN_FIRST_CONTACT",entity.id);
	
		AI.Signal(SIGNALFILTER_SENDER,1,"TO_ATTACK",entity.id);
	
--		if (entity.AI.temp == 0) then
--			AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_ADVANCING);
--			entity:SelectPipe(0,"su_advance");
--			entity:SelectPipe(0,"su_melee2");
--			entity.AI.temp = 1;
--		end
	
--		if (entity.AI.protect == 1) then
--			AI.Signal(SIGNALFILTER_SENDER,1,"TO_PROTECT",entity.id);
--		else
--			AI.Signal(SIGNALFILTER_SENDER,1,"TO_ATTACK",entity.id);
--		end
	
	end,

	---------------------------------------------
	COVER_NORMALATTACK = function (self, entity, sender)
		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_THREATENED",entity.id);
	end,

	---------------------------------------------
	OnNoTarget = function(self,entity,sender)
	end,

	---------------------------------------------
	OnTargetDead = function( self, entity )
		-- called when the attention target died
		entity:Readibility("target_down",1,1,0.3,0.5);
	end,
	
	--------------------------------------------------
	OnNoHidingPlace = function( self, entity, sender,data )
	end,	

	---------------------------------------------
	OnBackOffFailed = function(self,entity,sender)
	end,

	---------------------------------------------
	SEEK_KILLER = function(self, entity)
--		AI.Signal(SIGNALFILTER_SENDER,1,"TO_THREATENED",entity.id);
	end,
	
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the enemy can no longer see its foe, but remembers where it saw it last
	end,
	
	---------------------------------------------
	OnSomethingSeen = function( self, entity )
		-- called when the enemy sees a foe which is not a living player
		entity:Readibility("idle_interest_see",1,1,0.6,1);
		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_THREATENED",entity.id);
	end,

	---------------------------------------------
	OnThreateningSeen = function( self, entity )
		-- called when the enemy sees a foe which is not a living player
		entity:Readibility("idle_interest_see",1,1,0.6,1);
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_THREATENED",entity.id);
	end,
	
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		-- check if we should check the sound or not.
		entity:Readibility("idle_interest_hear",1,1,0.6,1);
		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_THREATENED",entity.id);
	end,

	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity, fDistance )
		-- called when the enemy hears a scary sound
		entity:Readibility("idle_alert_threat_hear",1,1,0.6,1);
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_THREATENED",entity.id);
	end,

	--------------------------------------------------
--	INVESTIGATE_BEACON = function (self, entity, sender)
--		entity:Readibility("ok_battle_state",1,1,0.6,1);
--		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_THREATENED",entity.id);
--	end,
		
	---------------------------------------------
	OnDamage = function ( self, entity, sender)
		-- called when the enemy is damaged
--		entity:Readibility("taking_fire",1,1,0.3,0.5);
--		entity:GettingAlerted();
	end,

	---------------------------------------------
	OnEnemyDamage = function (self, entity, sender, data)
		-- called when the enemy is damaged
		entity:GettingAlerted();

		-- set the beacon to the enemy pos
		local shooter = System.GetEntity(data.id);
		if(shooter) then
			AI.SetBeaconPosition(entity.id, shooter:GetPos());
		else
			entity:TriggerEvent(AIEVENT_DROPBEACON);
		end

		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT,1,"INCOMING_FIRE",entity.id);

		-- dummy call to this one, just to make sure that the initial position is checked correctly.
--		AI_Utils:IsTargetOutsideStandbyRange(entity);

		entity.AI.lastBulletReactionTime = _time;
--		entity:Readibility("bulletrain",1,0.1,0.4);

--		entity:SelectPipe(0,"su_fast_bullet_reaction");
	end,

	--------------------------------------------------
	OnBulletRain = function(self, entity, sender)
		-- only react to hostile bullets.
		if(AI.Hostile(entity.id, sender.id)) then
			entity:GettingAlerted();
			if(AI.GetTargetType(entity.id)==AITARGET_NONE) then
				local	closestCover = AI.GetNearestHidespot(entity.id, 3, 15, sender:GetPos());
				if(closestCover~=nil) then
					AI.SetBeaconPosition(entity.id, closestCover);
				else
					AI.SetBeaconPosition(entity.id, sender:GetPos());
				end
			else
				entity:TriggerEvent(AIEVENT_DROPBEACON);
			end
--			entity:Readibility("bulletrain",1,1,0.1,0.4);

			AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT,1,"INCOMING_FIRE",entity.id);
--			AI.Signal(SIGNALFILTER_SENDER,1,"TO_THREATENED",entity.id);

			entity.AI.lastBulletReactionTime = _time;
--			entity:Readibility("bulletrain",1,0.1,0.4);
--			entity:SelectPipe(0,"su_fast_bullet_reaction");

		end
	end,

	--------------------------------------------------
	OnCollision = function(self,entity,sender,data)
	end,	
	
	--------------------------------------------------
	OnCloseContact = function ( self, entity, sender,data)
--		entity:SelectPipe(0,"su_melee2");
--		entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"melee_close");
	end,

	--------------------------------------------------
	OnGroupMemberDied = function(self, entity, sender, data)
		--AI.LogEvent(entity:GetName().." OnGroupMemberDied!");
		entity:GettingAlerted();
--		AI.Signal(SIGNALFILTER_SENDER,1,"TO_THREATENED",entity.id);
	end,

	---------------------------------------------
--	ENEMYSEEN_FIRST_CONTACT = function( self, entity )
--		if(AI.GetTargetType(entity.id) ~= AITARGET_ENEMY) then
--			entity:Readibility("idle_interest_see",1,1,0.6,1);
--			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_THREATENED",entity.id);
--		end
--	end,

	--------------------------------------------------
--	ENEMYSEEN_DURING_COMBAT = function (self, entity, sender)
--		entity:GettingAlerted();
--		if(AI.GetTargetType(entity.id) ~= AITARGET_ENEMY) then
--			if (entity.AI.protect == 1) then
--				AI.Signal(SIGNALFILTER_SENDER,1,"TO_PROTECT",entity.id);
--			else
--				AI.Signal(SIGNALFILTER_SENDER,1,"TO_ATTACK",entity.id);
--			end
--		end
--	end,

	--------------------------------------------------
	OnCallReinforcements = function (self, entity, sender, data)
	end,

	--------------------------------------------------
--	OnGroupChanged = function (self, entity)
--		AI.BeginGoalPipe("temp_goto_beacon");
--			AI.PushGoal("locate",0,"beacon");
--			AI.PushGoal("approach",1,4,AILASTOPRES_USE);
--		AI.EndGoalPipe();
--		entity:SelectPipe(0,"temp_goto_beacon");
--	end,

	--------------------------------------------------
	OnExposedToFlashBang = function (self, entity, sender, data)
	end,

	--------------------------------------------------
	FLASHBANG_GONE = function (self, entity)
--		AI.Signal(SIGNALFILTER_SENDER, 1, "COVER_NORMALATTACK",entity.id);
--		entity:SelectPipe(0,"do_nothing");
		-- Choose proper action after being interrupted.
--		AI_Utils:CommonContinueAfterReaction(entity);
	end,

	--------------------------------------------------
	OnExposedToSmoke = function (self, entity)
	end,

	---------------------------------------------
	OnExposedToExplosion = function(self, entity, data)
--		entity:SelectPipe(0,"su_fast_threat_reaction");
		entity:SelectPipe(0,"su_bullet_reaction");
	end,

	---------------------------------------------
	OnGroupMemberMutilated = function(self, entity)
--		System.Log(">>"..entity:GetName().." OnGroupMemberMutilated");
--		AI.Signal(SIGNALFILTER_SENDER,1,"TO_PANIC",entity.id);
	end,

	---------------------------------------------
	OnTargetCloaked = function(self, entity)
--		AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_UNAVAIL);
--		entity:SelectPipe(0,"sn_target_cloak_reaction");
	end,

	--------------------------------------------------	
	OnOutOfAmmo = function (self,entity, sender)
		-- player would not have Reload implemented
		if (entity.Reload == nil) then
--			System.Log("  - no reload available");
			do return end
		end
		entity:Reload();
	end,

	---------------------------------------------
	OnGrenadeDanger = function(self, entity, sender, data)
--		if (data and data.iValue == 2) then
			-- nearby grenade dropped on ground
--			entity:SelectPipe(0,"su_fast_threat_reaction");
--		end
		entity:SelectPipe(0,"su_bullet_reaction");
	end,

	---------------------------------------------
	OnCloseCollision = function(self, entity, data)
--		entity:SelectPipe(0,"su_fast_threat_reaction");
	end,

	--------------------------------------------------
	SETUP_PROTECT_SPOT = function (self, entity, sender, signalData)
		entity.AI.protect = 1;
		entity.AI.protectSpot = {x=0,y=0,z=0};
		CopyVector(entity.AI.protectSpot, signalData.point);
	end,

	---------------------------------------------
	SETUP_SECONDARY = function (self, entity, sender)
		entity:SelectSecondaryWeapon();

		AI.EnableWeaponAccessory(entity.id, AIWEPA_LASER, false);
		AI.ChangeParameter(entity.id, AIPARAM_AIM_TURNSPEED, -1);
		AI.ChangeParameter(entity.id, AIPARAM_FIRE_TURNSPEED, -1);
		AI.ChangeParameter(entity.id, AIPARAM_FOVPRIMARY, entity.Properties.Perception.FOVPrimary);
		AI.ChangeParameter(entity.id, AIPARAM_FOVSECONDARY, entity.Properties.Perception.FOVSecondary);
	end,
	
	---------------------------------------------
	SETUP_SNIPER = function (self, entity, sender)
		entity:SelectPrimaryWeapon();
		
		AI.EnableWeaponAccessory(entity.id, AIWEPA_LASER, true);
		AI.ChangeParameter(entity.id, AIPARAM_AIM_TURNSPEED, 20);
		AI.ChangeParameter(entity.id, AIPARAM_FIRE_TURNSPEED, 15);
		AI.ChangeParameter(entity.id, AIPARAM_FOVPRIMARY, 10);
		AI.ChangeParameter(entity.id, AIPARAM_FOVSECONDARY, 40);
	end,

	---------------------------------------------
	UNDO_SNIPER = function (self, entity, sender)
		entity:SelectPrimaryWeapon();
		
		AI.EnableWeaponAccessory(entity.id, AIWEPA_LASER, false);
		AI.ChangeParameter(entity.id, AIPARAM_AIM_TURNSPEED, 90);
		AI.ChangeParameter(entity.id, AIPARAM_FIRE_TURNSPEED, 90);
		AI.ChangeParameter(entity.id, AIPARAM_FOVPRIMARY, entity.Properties.Perception.FOVPrimary);
		AI.ChangeParameter(entity.id, AIPARAM_FOVSECONDARY, entity.Properties.Perception.FOVSecondary);
	end,
	
	---------------------------------------------
	CHOOSE_WEAPON = function (self, entity, sender)
		local dist = 100.0;
		if (AI.GetTargetType(entity.id) ~= AITARGET_NONE) then
			dist = AI.GetAttentionTargetDistance(entity.id);
		end
		if (dist < 35) then
			-- shotgun/pistol
			entity:SelectSecondaryWeapon();
--			AI.EnableWeaponAccessory(entity.id, AIWEPA_LASER, false);
--			AI.ChangeParameter(entity.id, AIPARAM_AIM_TURNSPEED, -1);
--			AI.ChangeParameter(entity.id, AIPARAM_FIRE_TURNSPEED, -1);
--			AI.ChangeParameter(entity.id, AIPARAM_FOVPRIMARY, entity.Properties.Perception.FOVPrimary);
--		AI.ChangeParameter(entity.id, AIPARAM_FOVSECONDARY, entity.Properties.Perception.FOVSecondary);
		else
			-- sniper
			entity:SelectPrimaryWeapon();
--			AI.EnableWeaponAccessory(entity.id, AIWEPA_LASER, true);
--			AI.ChangeParameter(entity.id, AIPARAM_AIM_TURNSPEED, 60);
--			AI.ChangeParameter(entity.id, AIPARAM_FIRE_TURNSPEED, 35);
--			AI.ChangeParameter(entity.id, AIPARAM_FOVPRIMARY, 10);
--			AI.ChangeParameter(entity.id, AIPARAM_FOVSECONDARY, 40);
		end
	end,

	---------------------------------------------
	SUIT_STRENGTH_MODE = function (self, entity, sender)
		entity:NanoSuitMode(BasicAI.SuitMode.SUIT_POWER);
	end,

	---------------------------------------------
	SUIT_ARMOR_MODE = function (self, entity, sender)
		entity:NanoSuitMode(BasicAI.SuitMode.SUIT_ARMOR);
	end,

	---------------------------------------------
	SUIT_CLOAK_MODE = function (self, entity, sender)
		entity:NanoSuitMode(BasicAI.SuitMode.SUIT_CLOAK);
	end,

	---------------------------------------------
	OnFallAndPlayWakeUp = function( self, entity )
		-- check if we should check the sound or not.
		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_THREATENED",entity.id);
	end,

	---------------------------------------------
	COVER_GRENADE = function(self, entity, sender)
		if (entity.AI.reloadBlock == 0) then
			if (AI_Utils:CanThrowGrenade(entity) == 1) then
				AI.ChangeParameter(entity.id, AIPARAM_GRENADE_THROWDIST, 0.65);
				entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"sn_throw_grenade");
			end
		end
	end,

	---------------------------------------------
	SET_DEFEND_POS = function(self, entity, sender, data)
--		System.Log(">>>>"..entity:GetName().." SET_DEFEND_POS");
		if (data and data.point) then
			AI.SetRefPointPosition(entity.id,data.point);
			AI.NotifyGroupTacticState(entity.id, 0, GN_MARK_DEFEND_POS);
		end
	end,

	---------------------------------------------
	CLEAR_DEFEND_POS = function(self, entity, sender, data)
		AI.NotifyGroupTacticState(entity.id, 0, GN_CLEAR_DEFEND_POS);
	end,

}

