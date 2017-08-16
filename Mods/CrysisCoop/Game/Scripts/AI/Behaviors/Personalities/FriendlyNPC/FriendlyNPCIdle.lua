
AIBehaviour.FriendlyNPCIdle = {
	Name = "FriendlyNPCIdle",
	alertness = 0,
	
	-----------------------------------------------------
	Constructor = function (self, entity)
		entity:InitAIRelaxed();

		AI.ChangeParameter(entity.id, AIPARAM_COMBATCLASS, AICombatClasses.Squadmate);

		AI.ChangeParameter(entity.id, AIPARAM_AIM_TURNSPEED, 50);
		AI.ChangeParameter(entity.id, AIPARAM_FIRE_TURNSPEED, 40);
		AI.ChangeParameter(entity.id, AIPARAM_LOOKIDLE_TURNSPEED, 80);
		AI.ChangeParameter(entity.id, AIPARAM_LOOKCOMBAT_TURNSPEED, 80);

		---------------------------------------------
		AI.BeginGoalPipe("fn_simple_flinch");
			AI.PushGoal("ignoreall",0,1);
			AI.PushGoal("+firecmd",0,0);
			AI.PushGoal("+bodypos",0,BODYPOS_STAND);
--			AI.PushGoal("+signal",1,1,"flashbang_hit",SIGNALID_READIBILITY,115);
			AI.PushGoal("+animation",0,AIANIM_SIGNAL,"flinch");
			AI.PushGoal("+timeout",1,2,3);
			AI.PushGoal("+ignoreall",0,0);
			AI.PushGoal("+signal",0,1,"FLASHBANG_GONE",0);
		AI.EndGoalPipe();

		---------------------------------------------
		AI.BeginGoalPipe("fn_protect_path");
			AI.PushGoal("firecmd",0,1);
			AI.PushGoal("run",0,2,1,7);
			AI.PushGoal("signal",0,1,"CHOOSE_DEFEND_POS",0);
			AI.PushGoal("+locate",0,"refpoint");
			AI.PushGoal("+approach",1,1.5,AILASTOPRES_USE+AI_REQUEST_PARTIAL_PATH,15);
			AI.PushGoal("locate", 0, "probtarget");
			AI.PushGoal("+adjustaim",0,0,1);
			AI.PushGoal("firecmd",0,FIREMODE_BURST);
			AI.PushGoal("timeout",1,1.0,2.0);
			AI.PushGoal("firecmd",0,0);
			AI.PushGoal("timeout",1,0.3,0.5);
			AI.PushGoal("+signal",0,1,"DEFEND_CYCLE",0);
		AI.EndGoalPipe();

		entity.AI.defending = false;

	end,

	-----------------------------------------------------
	Destructor = function(self,entity)
	end,

	---------------------------------------------
	OnQueryUseObject = function ( self, entity, sender, extraData )
	end,

	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance, data )
		entity:Readibility("first_contact",1,2, 0.3,0.5);
		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_ATTACK",entity.id);
	end,

	---------------------------------------------
	OnNoTarget = function(self,entity,sender)
	end,

	---------------------------------------------
	OnTargetDead = function( self, entity )
	end,
	
	--------------------------------------------------
	OnNoHidingPlace = function( self, entity, sender,data )
	end,	

	---------------------------------------------
	OnBackOffFailed = function(self,entity,sender)
	end,

	---------------------------------------------
	OnEnemyMemory = function( self, entity )
	end,
	
	---------------------------------------------
	OnSomethingSeen = function( self, entity )
		if (entity.AI.defending == true) then
			entity:Readibility("interest_see",1,1, 0.1,0.4);
		end
	end,
	
	---------------------------------------------
	OnThreateningSeen = function( self, entity )
		if (entity.AI.defending == true) then
			entity:GettingAlerted();
			entity:Readibility("interest_see",1,1, 0.1,0.4);
		end
	end,
	
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		if (entity.AI.defending == true) then
			entity:Readibility("interest_hear",1,1, 0.1,0.4);
		end
	end,

	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity, fDistance )
		if (entity.AI.defending == true) then
			entity:GettingAlerted();
			entity:Readibility("idle_alert_threat_hear",1,1, 0.1,0.4);
		end
	end,

	--------------------------------------------------
	OnCoverRequested = function ( self, entity, sender)
	end,

	---------------------------------------------
	OnDamage = function ( self, entity, sender)
		if (entity.AI.defending == true) then
			-- called when the enemy is damaged
			entity:Readibility("taking_fire",1,1, 0.3,0.5);
			entity:GettingAlerted();
		end
	end,

	---------------------------------------------
	OnFriendlyDamage = function ( self, entity, sender, data)

		if(data.id == g_localActor.id) then 
		
			local health = entity.actor:GetHealth();
			local maxHealth = entity.actor:GetMaxHealth();
		
			if (health < maxHealth * 0.9) then
				entity:Readibility("friendly_fire",1,1, 0.6,1);
--				AI.Signal(SIGNALFILTER_GROUPONLY, 1, "SHOT_BY_PLAYER", entity.id);

--				AI.ChangeParameter(entity.id, AIPARAM_SPECIES, 5);
--				AI.ChangeParameter(entity.id, AIPARAM_GROUPID, 1);
			end
		end
	end,

	---------------------------------------------
	OnEnemyDamage = function (self, entity, sender, data)
	end,

	---------------------------------------------
	OnBulletRain = function(self, entity, sender, data)
		if (entity.AI.defending == true) then
			-- only react to hostile bullets.
			if(not AI.Hostile(entity.id, sender.id)) then
				if(sender==g_localActor) then 
					entity:Readibility("friendly_fire",1,1, 0.6,1);
					entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"look_at_player_5sec");			
					entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"do_nothing");		-- make the timeout goal in previous subpipe restart if it was there already
				end
			end
		end
	end,

	---------------------------------------------
	OnPlayerTeamKill = function(self,entity,sender,data)
		AI.ChangeParameter(entity.id, AIPARAM_SPECIES, 5);
	end,

	--------------------------------------------------
	OnCollision = function(self,entity,sender,data)
	end,	
	
	--------------------------------------------------
	OnCloseContact = function ( self, entity, sender,data)
	end,


	--------------------------------------------------
	OnGroupMemberDied = function(self, entity, sender, data)
		entity:Readibility("ai_down",1,1, 0.3,0.5);
	end,

	--------------------------------------------------
	OnGroupMemberDiedNearest = function(self, entity, sender, data)
	end,

	---------------------------------------------
	SHOT_BY_PLAYER = function( self, entity )
		AI.ChangeParameter(entity.id, AIPARAM_SPECIES, 5);
--		AI.ChangeParameter(entity.id, AIPARAM_GROUPID, 1);
	end,

	---------------------------------------------
	OnShapeEnabled = function (self, entity, sender, data)
	end,

	--------------------------------------------------
	OnCallReinforcements = function (self, entity, sender, data)
	end,

	--------------------------------------------------
	OnGroupChanged = function (self, entity)
	end,

	--------------------------------------------------
	OnExposedToFlashBang = function (self, entity, sender, data)
		if (entity.AI.defending == true) then
			if (data.iValue == 1) then
				-- near
				entity:SelectPipe(0,"sn_flashbang_reaction_flinch");
			else
				-- visible
				entity:SelectPipe(0,"sn_flashbang_reaction");
			end
		end
	end,

	--------------------------------------------------
	FLASHBANG_GONE = function (self, entity)
--		AI.Signal(SIGNALFILTER_SENDER, 1, "COVER_NORMALATTACK",entity.id);
		entity:GettingAlerted();
		if (entity.AI.defending == true) then
			self:DEFEND_CYCLE(entity);
		else
			entity:SelectPipe(0,"do_nothing");
		end
		-- Choose proper action after being interrupted.
--		AI_Utils:CommonContinueAfterReaction(entity);
	end,

	---------------------------------------------
	END_BACKOFF = function(self, entity, data)
		entity:GettingAlerted();
		if (entity.AI.defending == true) then
			self:DEFEND_CYCLE(entity);
		else
			entity:SelectPipe(0,"do_nothing");
		end
	end,

	--------------------------------------------------
	OnExposedToSmoke = function (self, entity)
		entity:Readibility("cough",1,115, 0.1,4.5);
	end,

	---------------------------------------------
	OnExposedToExplosion = function(self, entity, data)
		if (entity.AI.defending == true) then
			entity:SelectPipe(0,"fn_simple_flinch");
		end
--		entity:SelectPipe(0,"su_fast_threat_reaction");
	end,

	---------------------------------------------
	OnGroupMemberMutilated = function(self, entity)
	end,

	---------------------------------------------
	OnTargetCloaked = function(self, entity)
	end,

	--------------------------------------------------	
	OnOutOfAmmo = function (self,entity, sender)
		-- player would not have Reload implemented
		entity:Readibility("reloading",1,2, 0.3,0.5);
		if (entity.Reload == nil) then
--			System.Log("  - no reload available");
			do return end
		end
		entity:Reload();
	end,

	---------------------------------------------
	OnGrenadeDanger = function( self, entity, sender, signalData )
		if (entity.AI.defending == true) then
			local dist = AI.SetRefPointToGrenadeAvoidTarget(entity.id, signalData.point, 15.0);
			if (dist > 0.0) then
				entity:SelectPipe(0,"cv_backoff_from_explosion");
				entity:Readibility("incoming",0,5);
			end
		end
	end,

	---------------------------------------------
	OnCloseCollision = function(self, entity, data)
		if (entity.AI.defending == true) then
			entity:SelectPipe(0,"fn_simple_flinch");
		end
	end,


	---------------------------------------------
	DEFEND_STOP = function(self, entity, data)
		entity.AI.protectPath = nil;
		entity:SelectPipe(0,"do_nothing");
		entity.AI.defending = false;
	end,
	
	---------------------------------------------
	DEFEND_START = function(self, entity, data)
	
		if (data and data.ObjectName and data.ObjectName ~= "") then
			entity.AI.protectPath = data.ObjectName;
			if (not entity.AI.protectPath) then
				AI.Warning("DEFEND_START "..entity:GetName()..": Path specified in the signal does not exists!");
				return;
			end
		else
			entity.AI.protectPath = AI.GetNearestPathOfTypeInRange(entity.id, entity:GetPos(), 5.0, AIAnchorTable.COMBAT_PROTECT_THIS_POINT, 0.0, 0);
			if (not entity.AI.protectPath) then
				AI.Warning("DEFEND_START "..entity:GetName()..": Cannot find path of type COMBAT_PROTECT_THIS_POINT within 5.0 meters!");
				return;
			end
		end
		
		self:DEFEND_CYCLE(entity);
		entity.AI.defending = true;
	end,

	---------------------------------------------
	CHOOSE_DEFEND_POS = function(self, entity)
		local target = AI.GetTargetType(entity.id);
		local	targetPos = g_Vectors.temp_v1;
		if (target == AITARGET_NONE) then
			CopyVector(targetPos, entity:GetPos());
		else
			AI.GetAttentionTargetPosition(entity.id, targetPos);
		end
		AI.SetRefPointPosition(entity.id, AI.GetNearestPointOnPath(entity.id, entity.AI.protectPath, targetPos));
	end,

	---------------------------------------------
	DEFEND_CYCLE = function(self, entity)
		entity:SelectPipe(0,"fn_protect_path");
	end,

	---------------------------------------------
	OnFallAndPlayWakeUp = function( self, entity )
		-- check if we should check the sound or not.
		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_ATTACK",entity.id);
	end,

	---------------------------------------------
	OnPlayerLooking = function(self,entity,sender,data)
	
		if(DialogSystem.IsEntityInDialog(entity.id)) then return end
		-- data.fValue = player distance
		if(data.fValue<6) then 
			-- react, readability
			entity:Readibility("staring",1,0,1,2);
			--entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"look_at_player_5sec");			
		end
	end,

	---------------------------------------------
	OnPlayerLookingAway = function(self,entity,sender,data)
	
--		if(DialogSystem.IsEntityInDialog(entity.id)) then return end
--		-- data.fValue = player distance
--		AI.LogEvent("Player looking away from "..entity:GetName());
--		entity:SelectPipe(0,"stand_only");
--		entity:InsertSubpipe(0,"clear_all");
--		entity:InsertSubpipe(0,"reset_lookat");
--		entity:InsertSubpipe(0,"random_timeout");
	end,


	---------------------------------------------
	OnPlayerSticking = function(self,entity,sender,data)
		if(DialogSystem.IsEntityInDialog(entity.id)) then return end
		-- data.fValue = player distance
--		AI.LogEvent("Player sticking to "..entity:GetName());
			-- react, readabIlity
		entity:Readibility("staring",1,0,1,2);
--		entity:SelectPipe(0,"look_at_player");			
	end,

	----------------------------------
	OnPlayerGoingAway = function(self,entity,sender,data)
--		-- data.fValue = player distance
--		AI.LogEvent("Player going away from "..entity:GetName());
--		AIBehaviour.FriendlyNPCIdle:OnPlayerLookingAway(entity,sender,data);
	end,


	---------------------------------------------

}
