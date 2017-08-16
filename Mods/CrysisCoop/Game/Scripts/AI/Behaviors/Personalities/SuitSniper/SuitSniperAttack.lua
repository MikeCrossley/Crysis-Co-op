--------------------------------------------------
-- SuitSniperAttack
--------------------------
--   created: Mikko Mononen 28-4-2007


AIBehaviour.SuitSniperAttack = {
	Name = "SuitSniperAttack",
	alertness = 2,

	-----------------------------------------------------
	Constructor = function (self, entity)

		entity:MakeAlerted();

		entity.AI.lastBulletReactionTime = _time - 10;
		entity.AI.lastTargetSeenTime = _time;
		
		AI.SetPFBlockerRadius(entity.id, PFB_ATT_TARGET, 10);
		
		AI.ChangeParameter(entity.id, AIPARAM_GRENADE_THROWDIST, 0.65);
		
		self:COVER_NORMALATTACK(entity);
		
		entity.AI.meleeBlock = 0;
		entity.AI.reloadBlock = 0;
		entity.AI.stuntBlock = 0;
		entity.AI.lastStuntAnchorId = NULL_ENTITY;

		if (AI_Utils:CanThrowSmokeGrenade(entity) == 1) then
			AI.ChangeParameter(entity.id, AIPARAM_GRENADE_THROWDIST, 1.0);
			entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"su_throw_smoke");
		end

	end,

	-----------------------------------------------------
	Destructor = function(self,entity)
	end,
	
	---------------------------------------------
	FOUND_CLOSE_CONTANT = function (self, entity, sender)
		entity.AI.sniper = false;
	end,
	
	---------------------------------------------
	COVER_NORMALATTACK = function (self, entity, sender)
		
		entity.AI.meleeBlock = 0;
		entity.AI.reloadBlock = 0;
		entity.AI.stuntBlock = 0;
		local target = AI.GetTargetType(entity.id);

		local stuntElapsed = _time - entity.AI.lastStuntTime;
		if (stuntElapsed > 25.0) then -- and AI_Utils:IsUnitStuntAllowed(entity) == 1) then
--			local anchorName = AI.GetAnchor(entity.id, AIAnchorTable.SUIT_SPOT, 13, AIANCHOR_RANDOM_IN_RANGE);
			
			local	objectPos = g_Vectors.temp_v1;
			local	objectDir = g_Vectors.temp_v2;

			local anchorName = AI.FindObjectOfType(entity.id, 10.0, AIAnchorTable.SUIT_SPOT,
																						AIFO_NONOCCUPIED+AIFO_CHOOSE_RANDOM+AIFO_NONOCCUPIED_REFPOINT, objectPos, objectDir);
			
			if (anchorName) then
				local anchor = System.GetEntityByName(anchorName);
				if (anchor) then -- and entity.AI.lastStuntAnchorId ~= anchor.id) then

					entity.AI.lastStuntTime = _time;
				
					-- do not allow to use the same anchor twice in a row.
					if (entity.AI.lastStuntAnchorId ~= anchor.id) then
						entity.AI.lastStuntAnchorId = anchor.id;
						-- If found attack anchor, goto to the anchor.
						AI.SetRefPointPosition(entity.id, objectPos);
						entity:SelectPipe(0,"su_stunt");
						entity.AI.stuntBlock = 1;
						do return end;
					end
				end
			end
		end

		AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_ADVANCING);
		entity:SelectPipe(0,"su_advance");
		
	end,

	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance, data )
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		
--		if (entity.AI.sniper == true) then
--			if (entity.AI.seek == true) then
--				entity:SelectPipe(0,"su_sniper");
--				entity.AI.seek = false;
--			end
--		else
--			entity:Readibility("during_combat",1,1,0.3,6);
--			if (entity.AI.seek == true) then
--				entity:SelectPipe(0,"su_fast_close_range");
--				entity.AI.seek = false;
--			end
--		end
		
		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 1, "ENEMYSEEN_DURING_COMBAT",entity.id);
	end,

	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		entity.AI.lastTargetSeenTime = _time;
	end,

	--------------------------------------------------
	OnCloseContact = function ( self, entity, sender,data)
		-- Do melee at close range.
		if (entity.AI.meleeBlock == 0 and AI.CanMelee(entity.id)) then
			entity:NanoSuitMode( BasicAI.SuitMode.SUIT_POWER );
			AI.ChangeParameter(entity.id, AIPARAM_AIM_TURNSPEED, -1);
			AI.ChangeParameter(entity.id, AIPARAM_FIRE_TURNSPEED, -1);
--			AI.ChangeParameter(entity.id, AIPARAM_MELEE_DISTANCE, 4.0);

			entity:SelectPipe(0,"su_melee");
			entity.AI.meleeBlock = 1;
		end
	end,

	---------------------------------------------
	MELEE_DONE = function (self, entity)

--		entity:NanoSuitMode( BasicAI.SuitMode.SUIT_CLOAK );
--		AI.ChangeParameter(entity.id, AIPARAM_AIM_TURNSPEED, -1);
--		AI.ChangeParameter(entity.id, AIPARAM_FIRE_TURNSPEED, -1);

		AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_ADVANCING);
		entity:SelectPipe(0,"su_melee_retreat");
--		entity:SelectPipe(0,"su_melee_pause");

	end,
	
	---------------------------------------------
	OnMeleeExecuted = function (self, entity)

--		entity:NanoSuitMode( BasicAI.SuitMode.SUIT_CLOAK );
--		AI.ChangeParameter(entity.id, AIPARAM_AIM_TURNSPEED, -1);
--		AI.ChangeParameter(entity.id, AIPARAM_FIRE_TURNSPEED, -1);

		AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_ADVANCING);
		entity:SelectPipe(0,"su_melee_retreat");
--		entity:SelectPipe(0,"su_melee_pause");

	end,
	
	---------------------------------------------
	OnNoTargetVisible = function (self, entity)
		AI.Signal(SIGNALFILTER_SENDER,1,"TO_THREATENED",entity.id);
	end,
	
	---------------------------------------------
	OnNoTargetAwareness = function (self, entity)
		AI.Signal(SIGNALFILTER_SENDER,1,"TO_THREATENED",entity.id);
	end,

	---------------------------------------------
	OnEnemyDamage = function(self, entity, sender)
	
		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 1, "COVER_GRENADE",entity.id);
	
		local	dt = _time - entity.AI.lastBulletReactionTime;
		local reactionTime = 0.75;
		if (AI.IsMoving(entity.id,1) == 1) then
			reactionTime = 2.0;
		end
		if(dt > reactionTime and entity.AI.stuntBlock == 0) then
			entity.AI.lastBulletReactionTime = _time;
			entity:Readibility("bulletrain",1,2, 0,0.2);
			AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_HIDING);
			entity:SelectPipe(0,"do_nothing");
			entity:SelectPipe(0,"su_bullet_reaction");
		end
	
	end,
	
	---------------------------------------------
	OnBulletRain = function(self, entity, sender, data)
	
		local dist = 100.0;
		if (AI.GetTargetType(entity.id) ~= AITARGET_NONE) then
			dist = AI.GetAttentionTargetDistance(entity.id);
		end

		if (entity.AI.meleeBlock == 0 and entity.AI.stuntBlock == 0) then
			if (dist < 15.0) then
				entity:SelectPipe(0,"su_charge");
			end
		end
		
	end,

	--------------------------------------------------
	ENEMYSEEN_DURING_COMBAT = function (self, entity, sender)
	end,

	---------------------------------------------
	ENEMYSEEN_FIRST_CONTACT = function( self, entity )
	end,

	---------------------------------------------
	OnSomethingSeen = function( self, entity )
	end,
	
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
	end,

	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity, fDistance )
	end,

	--------------------------------------------------	
	OnOutOfAmmo = function (self,entity, sender)
	
		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 1, "COVER_GRENADE",entity.id);
	
		-- player would not have Reload implemented
		if (entity.Reload == nil) then
--			System.Log("  - no reload available");
			do return end
		end

		local dist = 100.0;
		if (AI.GetTargetType(entity.id) ~= AITARGET_NONE) then
			dist = AI.GetAttentionTargetDistance(entity.id);
		end

		if (dist < 5.0 and entity.AI.meleeBlock == 0) then
			entity:SelectPipe(0,"su_melee");
			entity.AI.meleeBlock = 1;
			entity.AI.reloadBlock = 1;
		else
			if (entity.AI.reloadBlock == 0) then
				entity:Reload();
			end
		end

--		if (AI.GetTargetType(entity.id) ~= AITARGET_NONE) then
--			if (AI.GetAttentionTargetDistance(entity.id) < entity.Properties.preferredCombatDistance) then
--				entity:SelectPipe(0,"su_cqb_dodge");
--				do return end;
--			end
--		end

	end,
	
}
