-- Default behaviour - implements all the system callbacks and does something
-- this is so that any enemy has a behaviour to fallback to
--------------------------

AIBehaviour.GUARDDEFAULT = {
	Name = "GUARDDEFAULT",

	-- max number of aliens attacking the same time.
	MaxAttack = 2,

	-- this signal should be sent only by smart objects
	OnReinforcementRequested = function(self, entity, sender, extraData)
		local pos = {};
		AI.GetBeaconPosition(extraData.id, pos);
--		AI.LogEvent("OnReinforcementRequested - beacon:"..pos.x..", "..pos.y..", "..pos.z);
		AI.SetBeaconPosition(entity.id, pos);
		AIBehaviour.GUARDDEFAULT:GotoPursue(entity,1);
	end,
	
	-- this signal should be sent only by smart objects
	OnCallReinforcement = function(self, entity, sender, extraData)
		--This signal is sent to the entity which should call the reinforcements.
		local	obj = System.GetEntity(extraData.id);
--		Log(">>>"..entity:GetName().." OnCallReinforcement ->"..obj:GetName());
		AIBehaviour.GUARDDEFAULT:GotoCallReinf(entity,1,extraData.id);
	end,
	
	---------------------------------------------
	CommonInit = function(self, entity)
	
		-- copy the initial settings from the properties.
		entity.AI.targetRange = entity.Properties.Behavior.targetRange;
		entity.AI.targetPos = {x=0,y=0,z=0};
		entity.AI.targetValid = false;
		entity.AI.targetEnt = nil;
		if(entity.Properties.Behavior.targetEntity) then
--			AI.LogEvent("GUARD CommonInit: "..entity.Properties.Behavior.targetEntity);
			entity.AI.targetEnt = System.GetEntityByName(entity.Properties.Behavior.targetEntity);
			if(entity.AI.targetEnt) then
				CopyVector(entity.AI.targetPos, entity.AI.targetEnt:GetPos());
				entity.AI.targetValid = true;
			end
--		else
--			AI.LogEvent("GUARD CommonInit: no target ent!");
		end

		AI.Signal(SIGNALFILTER_SENDER, 1, "CHARACTER_CHANGED",entity.id);

		entity.AI.lastMeleeTime = _time;
	end,

	---------------------------------------------
	AttTargetInPerimeter = function(self, entity, scaleAdj)
		-- if not protect point, the perimeter is infinite.
		if(not entity.AI.targetValid) then
			return true;
		end

		local targetType = AI.GetTargetType(entity.id);
		if(targetType == AITARGET_NONE) then
			return false;
		end

		local distToTarget = 10000;
		local	attPos = g_Vectors.temp_v1;
		AI.GetAttentionTargetPosition(entity.id, attPos);

		if(entity.AI.targetEnt) then
			distToTarget = DistanceVectors(entity.AI.targetEnt:GetPos(), attPos);
		else
			distToTarget = DistanceVectors(entity.AI.targetPos, attPos);
		end

		local scale = 2.0;
		if(scaleAdj) then
			scale = scale * scaleAdj;
		end

		if(distToTarget < entity.AI.targetRange * scale) then
			return true;
		else
			return false;
		end
	end,

	---------------------------------------------
	EntityInPerimeter = function(self, entity)
		-- if not protect point, the perimeter is infinite.
		if(not entity.AI.targetValid) then
			return true;
		end

		local distToTarget = 10000;
		if(entity.AI.targetEnt) then
			distToTarget = DistanceVectors(entity.AI.targetEnt:GetPos(), entity:GetPos());
		else
			distToTarget = DistanceVectors(entity.AI.targetPos, entity:GetPos());
		end

		if(distToTarget < entity.AI.targetRange * 2.0) then
			return true;
		else
			return false;
		end
	end,

	---------------------------------------------
	CheckToDefend = function(self, entity)
		if(not entity.AI.targetEnt) then
--			AI.LogEvent(entity:GetName().."CheckToDefend: no protect spot");
			return false;
		end

		if(not self:AttTargetInPerimeter(entity)) then

			-- the target is too far away from the point to protect, return to the vinicity of the point to protect.
			AI.SetRefPointPosition(entity.id,entity.AI.targetEnt:GetPos());

			local targetType = AI.GetTargetType(entity.id);
			if(targetType == AITARGET_ENEMY) then
--				AI.LogEvent(entity:GetName().."CheckToDefend: TO_DEFEND");
				AI.Signal(SIGNALFILTER_SENDER, 1, "TO_DEFENDER",entity.id);
			else
				AI.ModifySmartObjectStates(entity.id,"PrepareDefend");
				entity:SelectPipe(0,"gr_investigate_defend_spot","refpoint");
				AI.Signal(SIGNALFILTER_SENDER, 1, "TO_PURSUE",entity.id);
			end
			entity:InsertSubpipe(0,"do_it_running");

			return true;
		end

		return false;
	end,

	--
	-- Transition signals
	--------------------------------------------------
	GotoIdle = function (self, entity, num)
		g_SignalData.iValue = num;
		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_IDLE", entity.id,g_SignalData);
	end,
	--------------------------------------------------
	GotoInterested = function (self, entity, num)
		g_SignalData.iValue = num;
		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_INTERESTED",entity.id,g_SignalData);
	end,
	--------------------------------------------------
	GotoPursue = function (self, entity, num)
		g_SignalData.iValue = num;
		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_PURSUE",entity.id,g_SignalData);
	end,
	--------------------------------------------------
	GotoSearch = function (self, entity, num)
		g_SignalData.iValue = num;
		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_SEARCH",entity.id,g_SignalData);
	end,
	--------------------------------------------------
	GotoCallReinf = function(self, entity, num, target)
		g_SignalData.iValue = num;
		g_SignalData.id = target;
		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_CALLREINF",entity.id,g_SignalData);
	end,
	
	--------------------------------------------------
	GotoRunToFriend = function (self, entity, num, friend)
		if(friend) then
			g_SignalData.id = friend;
		else
			g_SignalData.id = NULL_ENTITY;
		end
		g_SignalData.iValue = num;
		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_RUNTOFRIEND",entity.id,g_SignalData);
	end,
	--------------------------------------------------
	GotoCover = function (self, entity, num, pt)
		if(pt) then
			CopyVector(g_SignalData.point, pt);
		else
			ZeroVector(g_SignalData.point);
		end
		g_SignalData.iValue = num;
		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_COVER",entity.id,g_SignalData);
	end,
	--------------------------------------------------
	GotoAttack = function (self, entity, num)
		g_SignalData.iValue = num;
		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_ATTACK",entity.id,g_SignalData);
	end,
	--------------------------------------------------
	GotoAmbient = function (self, entity, num)
		g_SignalData.iValue = num;
		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_AMBIENT",entity.id,g_SignalData);
	end,
	--------------------------------------------------
	GotoAssault = function (self, entity, num)
		g_SignalData.iValue = num;
		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_ASSAULT",entity.id,g_SignalData);
	end,
	--------------------------------------------------
	GotoDefend = function (self, entity, num)
		g_SignalData.iValue = num;
		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_DEFEND",entity.id,g_SignalData);
	end,
	--------------------------------------------------
	GotoEvade = function (self, entity, num)
		g_SignalData.iValue = num;
		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_EVADE",entity.id,g_SignalData);
	end,

	--------------------------------------------------
	DropBeacon = function (self, entity)
		local	targetType = AI.GetTargetType(entity.id);
		if(targetType == AITARGET_ENEMY or targetType == AITARGET_SOUND) then
			entity:TriggerEvent(AIEVENT_DROPBEACON);
		end
	end,

	--------------------------------------------------
	CheckToCallReinforcements = function (self, entity)

--		Log("***CheckToCallReinforcements "..entity:GetName());

		local groupId = AI.GetGroupOf(entity.id);
		local initCount = AI.GetGroupCount(entity.id,GROUP_ENABLED+GROUP_MAX);
		local curCount = AI.GetGroupCount(entity.id,GROUP_ENABLED);

--		Log(entity:GetName().." groupId:"..groupId);
--		Log(" -  init count:"..initCount);
--		Log(" -  init count:"..curCount);

--		AI.LogEvent(" - init count: "..initCount.." cur count:"..curCount);

		if(entity.Properties.Behavior.alarmLevel == 0) then
			-- level zero, do not alarm.
--			AI.ModifySmartObjectStates(entity.id, "-CallReinforcement");
--			AI.LogEvent(" - level 0: do not call");
			return;
		end
		
		if(entity.Properties.Behavior.alarmLevel >= 1) then
			-- level one, alarm if half the group is dead.
--			AI.LogEvent(" - level 1: "..curCount.."<"..initCount * 0.5);
			if(curCount < initCount * 0.5) then
				AI.SmartObjectEvent("CallReinforcement", entity.id);
--				AI.ModifySmartObjectStates(entity.id, "CallReinforcement");
--				AI.LogEvent(" - GOGO!");
				return;
			end
		end
		
		if(entity.Properties.Behavior.alarmLevel >= 2) then
			-- level two, alarm if one of the group has died.
--			AI.LogEvent(" - level 2: "..curCount.."<"..initCount);
			if(curCount < initCount) then
				AI.SmartObjectEvent("CallReinforcement", entity.id);
--				AI.ModifySmartObjectStates(entity.id, "CallReinforcement");
--				AI.LogEvent(" - GOGO!");
				return;
			end
		end

		if(entity.Properties.Behavior.alarmLevel >= 3) then
			-- level three, alarm when seeing the enemy.
			AI.SmartObjectEvent("CallReinforcement", entity.id);
--			AI.ModifySmartObjectStates(entity.id, "CallReinforcement");
--			AI.LogEvent(" - level 3: GOGO!");
			return;
		end
	end,

	--------------------------------------------------
	ReportEnemySeen = function (self, entity, doNotRunToFriends)
		self:CheckToCallReinforcements(entity);
		self:DropBeacon(entity);
		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT,0,"RPT_ENEMYSEEN",entity.id);
	end,

	--------------------------------------------------
	ReportThreatening = function (self, entity)
		self:CheckToCallReinforcements(entity);
		self:DropBeacon(entity);
		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT,0,"RPT_THREATENING",entity.id);
	end,

	--------------------------------------------------
	ReportIncoming = function (self, entity)
		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT,0,"RPT_INCOMING",entity.id);
	end,

	--------------------------------------------------
	OnQueryUseObject = function (self, entity, sender, extraData)
	--	AI.LogEvent("OnQueryUseObject in DEFAULT");
--		sender = System.GetEntity(extraData.id);
--		if (sender and sender.listPotentialUsers) then
--			i = 1;
--			repeat
--				while (entity) do
--					if (entity.id == sender.listPotentialUsers[i].id) then
--						entity = nil;
--					end
--					i = i+1;
--				end
--				if (i <= count(sender.listPotentialUsers)) then
--					entity = sender.listPotentialUsers[i];
--				end
--			until (entity == nil) or entity:IsTargetAimable(sender);
--			if (entity) then
--			--	AI.LogEvent("    delegating to "..entity:GetName());
--				AI.Signal(SIGNALFILTER_SENDER, 10, "OnQueryUseObject", entity.id, sender.id);
--			else
--			--	AI.LogEvent("    no more candidates");
--				sender.listPotentialUsers = nil;
--			end
--		end
	end,

	--------------------------------------------------
	OnFriendInWay = function (self, entity, sender)
	end,

	--------------------------------------------------
	OnReceivingDamage = function (self, entity, sender)
	end,

	--------------------------------------------------
	OnObjectSeen = function(self, entity, fDistance, signalData)
--		AI.LogEvent(entity:GetName().." GuardIdle.OnObjectSeen");
		
		-- called when the enemy sees an object
		if (signalData.iValue == AIOBJECT_RPG) then
			entity:InsertSubpipe(0,"devalue_target");
		end
		if (signalData.iValue == 150) then
			if (fDistance < 40) then
				AIBehaviour.GUARDDEFAULT:ReportIncoming(entity);
				entity:Readibility("INCOMING",1);
				AI.Signal(SIGNALFILTER_SENDER, 1, "TO_COVER",entity.id,g_SignalData);
			end
		end
	end,


	-- Everyone has to be able to warn anyone around him that he died
	--------------------------------------------------
	OnDeath = function (self, entity, sender)

--		AI.LogEvent(">>>> OnDeath "..entity:GetName());

		-- tell your friends that you died anyway regardless of wheteher someone goes for reinforcement
		g_SignalData.id = entity.id;
		if (AI.GetGroupCount(entity.id) > 1) then
			-- tell your nearest that someone you have died only if you were not the only one
			AI.Signal(SIGNALFILTER_NEARESTINCOMM, 1, "OnGroupMemberDiedNearest",entity.id,g_SignalData); 
		else
			-- tell anyone that you have been killed, even outside your group
			AI.Signal(SIGNALFILTER_ANYONEINCOMM, 1, "OnSomebodyDied",entity.id, g_SignalData);
		end
			
	end,

	-- What everyone has to do when they get a notification that someone died
	--------------------------------------------------
	OnGroupMemberDiedNearest = function (self, entity, sender,data)

--		AI.LogEvent(">>>> OnGroupMemberDiedNearest "..entity:GetName());

		if (entity.ai) then 
			entity:MakeAlerted();

			entity:Readibility("anticipation",1);
			entity:InsertSubpipe(0,"DropBeaconAt",sender.id);

			-- bounce the dead friend notification to the group (you are going to investigate it)
			AI.Signal(SIGNALFILTER_GROUPONLY, 1, "OnGroupMemberDied",entity.id,data);
		else
			-- vehicle bounce the signals further
			AI.Signal(SIGNALFILTER_NEARESTINCOMM, 1, "OnGroupMemberDiedNearest",entity.id,data);
		end
		
	end,

	------------------------------------------------------------------------
	OnGroupMemberDied = function (self, entity, sender,data)
	end,
	
	------------------------------------------------------------------------
	USE_FREEZE_WEAPON = function(self,entity,sender)
		if(AI.GetTargetType(entity.id) == AITARGET_ENEMY) then 
			entity:InsertSubpipe(0,"tr_use_freeze_weapon");
		end
	end,

	------------------------------------------------------------------------
	SELECT_FREEZE_WEAPON = function(self,entity,sender)
		ItemSystem.SetActorItemByName(entity.id,"MOAR",false);
	end,

	------------------------------------------------------------------------
	SELECT_NORMAL_WEAPON = function(self,entity,sender)
		ItemSystem.SetActorItemByName(entity.id,"LightMOAC",false);
	end,
	
	------------------------------------------------------------------------
	GROUP_CLOAK = function(self,entity,sender)
		AI.Signal(SIGNALFILTER_GROUPONLY,0,"CLOAK",entity.id);
	end,

	------------------------------------------------------------------------
	CLOAK = function(self,entity,sender)
		entity:Event_Cloak();
	end,

	------------------------------------------------------------------------
	GROUP_UNCLOAK = function(self,entity,sender)
		AI.Signal(SIGNALFILTER_GROUPONLY,0,"UNCLOAK",entity.id);
	end,
	------------------------------------------------------------------------

	UNCLOAK = function(self,entity,sender)
		entity:Event_UnCloak();
	end,
	
	---------------------------------------------
	ORDER_ACQUIRE_TARGET = function(self , entity, sender, data)
		if(data.id ~= NULL_ENTITY) then
			entity:InsertSubpipe(0,"acquire_target",data.id);
		else
			entity:InsertSubpipe(0,"acquire_target",data.ObjectName);
		end
		AI.Signal(SIGNALFILTER_LEADER,10,"ORD_DONE",entity.id);
	end,
	
	---------------------------------------------
	SET_TARGET = function(self, entity, sender, data)
		-- Init
		if(data.id ~= NULL_ENTITY) then
			entity.AI.targetEnt = System.GetEntity(data.id);
			CopyVector(entity.AI.targetPos, entity.AI.targetEnt:GetPos()); 
		else
			CopyVector(entity.AI.targetPos, data.point); 
		end
		entity.AI.targetRange = data.fValue;	
		entity.AI.targetValid = true;
	end,
		
	-- Handle group commands.
	-- Group commands are sent from flow graph in order to change the behavior of hte group
	-- based on game progression.
	---------------------------------------------
	OnGroupCommandAssault = function(self, entity, sender, data)
--		AI.LogEvent(entity:GetName().." OnGroupCommandAssault: ");
		-- change character
		entity.AI.noCharacterInit = true;
		AI.SetCharacter(entity.id, "GuardAssault");
		-- Init
		AIBehaviour.GUARDDEFAULT:CommonInit(entity);
		if(data.id ~= NULL_ENTITY) then
			entity.AI.targetEnt = System.GetEntity(data.id);
			CopyVector(entity.AI.targetPos, entity.AI.targetEnt:GetPos()); 
		else
			CopyVector(entity.AI.targetPos, data.point); 
		end
		entity.AI.targetRange = data.fValue;	
		entity.AI.targetValid = true;
		entity.AI.returnToTarget = false;
		self:SetDefendPoint(entity);
		-- Goto the action.
		if(data.iValue2 == 1) then
--			self:GotoAssault(entity,3);
			self:GotoPursue(entity,3);
		end
	end,

	---------------------------------------------
	OnGroupCommandDefend = function(self, entity, sender, data)
		-- change character
		entity.AI.noCharacterInit = true;
		AI.SetCharacter(entity.id, "GuardDefend");
		-- Init
		AIBehaviour.GUARDDEFAULT:CommonInit(entity);
		if(data.id ~= NULL_ENTITY) then
			entity.AI.targetEnt = System.GetEntity(data.id);
--			Log(entity:GetName().." target:"..entity.AI.targetEnt:GetName());
			CopyVector(entity.AI.targetPos, entity.AI.targetEnt:GetPos()); 
		else
--			Log(entity:GetName().." not target!");
			CopyVector(entity.AI.targetPos, data.point); 
		end

		entity.AI.targetRange = data.fValue;	
		entity.AI.targetValid = true;
		entity.AI.returnToTarget = true;
		self:SetDefendPoint(entity);
		-- Goto the action.
		if(data.iValue2 == 1) then
--			self:GotoDefend(entity,3);
			self:GotoPursue(entity,3);
		end
	end,

	---------------------------------------------
	OnGroupCommandEvade = function(self, entity, sender, data)
		-- change character
		entity.AI.noCharacterInit = true;
		AI.SetCharacter(entity.id, "GuardEvade");
		-- Init
		AIBehaviour.GUARDDEFAULT:CommonInit(entity);
		if(data.id ~= NULL_ENTITY) then
			entity.AI.targetEnt = System.GetEntity(data.id);
			CopyVector(entity.AI.targetPos, entity.AI.targetEnt:GetPos()); 
		else
			CopyVector(entity.AI.targetPos, data.point); 
		end
		entity.AI.targetRange = data.fValue;	
		entity.AI.targetValid = true;
		entity.AI.returnToTarget = false;
		self:SetDefendPoint(entity);
		-- Goto the action.
		if(data.iValue2 == 1) then
			self:GotoEvade(entity,3);
		end
	end,

	---------------------------------------------
	OnGroupCommandHide = function(self, entity, sender, data)
		-- change character
		entity.AI.noCharacterInit = true;
		AI.SetCharacter(entity.id, "GuardHide");
		-- Init
		AIBehaviour.GUARDDEFAULT:CommonInit(entity);
		if(data.id ~= NULL_ENTITY) then
			entity.AI.targetEnt = System.GetEntity(data.id);
			CopyVector(entity.AI.targetPos, entity.AI.targetEnt:GetPos()); 
		else
			CopyVector(entity.AI.targetPos, data.point); 
		end
		entity.AI.targetRange = data.fValue;	
		entity.AI.targetValid = true;
		entity.AI.returnToTarget = true;
		self:SetDefendPoint(entity);
		-- Goto the action.
		if(data.iValue2 == 1) then
			self:GotoHide(entity,3);
		end
	end,

	---------------------------------------------
	SetDefendPoint = function(self, entity)
		if(entity.AI.targetValid) then
			AI.SetRefPointPosition(entity.id, entity.AI.targetPos);
			AI.NotifyGroupTacticState(entity.id, 1, GN_MARK_DEFEND_POS, entity.AI.targetRange);
		end
	end,

	---------------------------------------------
	InitAssault = function(self, entity, sender, data)
		AIBehaviour.GUARDDEFAULT:CommonInit(entity);
		entity.AI.returnToTarget = false;
	end,

	---------------------------------------------
	InitMelee = function(self, entity, sender, data)
		AIBehaviour.GUARDDEFAULT:CommonInit(entity);
		entity.AI.returnToTarget = false;
	end,

	---------------------------------------------
	InitDefend = function(self, entity, sender, data)
		AIBehaviour.GUARDDEFAULT:CommonInit(entity);
		-- If not defend point is selected, select the closest one.
--		AI.LogEvent("AICharacter.GuardDefend.Constructor:"..entity:GetName());
		if(not entity.AI.targetValid) then
--			AI.LogEvent(" - No inital target.");
			local anchorName = AI.FindObjectOfType(entity:GetPos(), 50, AIAnchorTable.COMBAT_PROTECT_THIS_POINT);
			if(anchorName) then
				entity.AI.targetEnt = System.GetEntityByName(anchorName);
				if(entity.AI.targetEnt) then
					CopyVector(entity.AI.targetPos, entity.AI.targetEnt:GetPos());
					entity.AI.targetValid = true;
				end
			end
		end

		self:SetDefendPoint(entity);
		
		if(not entity.AI.targetValid) then
			AI.LogEvent(" - still no target!");
		else
			AI.LogEvent(" - target:"..entity.AI.targetEnt:GetName());
		end
	
		entity.AI.returnToTarget = true;
	end,

	---------------------------------------------
	InitMeleeDefend = function(self, entity, sender, data)
		AIBehaviour.GUARDDEFAULT:CommonInit(entity);
		-- If not defend point is selected, select the closest one.
--		AI.LogEvent("AICharacter.GuardDefend.Constructor:"..entity:GetName());
		if(not entity.AI.targetValid) then
--			AI.LogEvent(" - No inital target.");
			local anchorName = AI.FindObjectOfType(entity:GetPos(), 50, AIAnchorTable.COMBAT_PROTECT_THIS_POINT);
			if(anchorName) then
				entity.AI.targetEnt = System.GetEntityByName(anchorName);
				if(entity.AI.targetEnt) then
					CopyVector(entity.AI.targetPos, entity.AI.targetEnt:GetPos());
					entity.AI.targetValid = true;
				end
			end
		end
		
		self:SetDefendPoint(entity);
		
		if(not entity.AI.targetValid) then
			AI.LogEvent(" - still no target!");
		else
			AI.LogEvent(" - target:"..entity.AI.targetEnt:GetName());
		end
	
		entity.AI.returnToTarget = true;
	end,


	---------------------------------------------
	InitEvade = function(self, entity, sender, data)
		AIBehaviour.GUARDDEFAULT:CommonInit(entity);
		-- If not evade point is selected, select the closest one.
		if(not entity.AI.targetValid) then
			local anchorName = AI.FindObjectOfType(entity:GetPos(), 50, AIAnchorTable.ALIEN_AMBUSH_AREA);
			if(anchorName) then
				entity.AI.targetEnt = System.GetEntityByName(anchorName);
				if(entity.AI.targetEnt) then
					CopyVector(entity.AI.targetPos, entity.AI.targetEnt:GetPos());
					entity.AI.targetValid = true;
				end
			end
		end
		
		self:SetDefendPoint(entity);
		
		entity.AI.returnToTarget = false;
	end,

--	--------------------------------------------------
--	OnCloseContact = function(self,entity,sender)
--		-- The melee here is ment to be for something that is in close contact
--		-- but the alien is not aware of it. This should be mainly because
--		-- the player is approaching the alien from back or if he is cloaked.
--		if(AI.GetTargetType(entity.id) ~= AITARGET_ENEMY and AI.GetTargetType(entity.id) ~= AITARGET_MEMORY) then
--			local curTime = _time;
--			local timePassed = curTime - entity.AI.lastMeleeTime;
--			if(timePassed  > 10.0) then
----				AI.LogEvent("Doing melee "..entity:GetName());
----				entity:Readibility("ALERT_COMBAT",1);
--				entity:MeleeAttack(0);
--				entity.AI.lastMeleeTime = curTime;
--			end
--		end
--	end,

	---------------------------------------------
	SET_MELEE_TARGET = function(self, entity)
		local	dir = g_Vectors.temp_v1;
		local	enemyPos = g_Vectors.temp_v2;
		local	meleePos = g_Vectors.temp_v3;
		AI.GetAttentionTargetPosition(entity.id,enemyPos);
		
		FastDifferenceVectors(dir, enemyPos, entity:GetPos());
		
		local	len = LengthVector(dir);
		
		ScaleVectorInPlace(dir, (len + 5)/len);
		FastSumVectors(meleePos, entity:GetPos(), dir);

		AI.SetRefPointPosition(entity.id, meleePos);
	end,

	---------------------------------------------
	DO_MELEE = function(self , entity)
--		entity.actor:SetAnimationInput("Signal","meleeThreaten");
--		entity:Readibility("scare",1, 6);

--		entity.actor:SetAnimationInput("SignalSticky","alien_meleeMoveBender");

--		local distToTarget = AI.GetAttentionTargetDistance(entity.id);
--		if(distToTarget < 4) then

--			entity:MeleeAttack(1);

--		else
--			entity:Readibility("ENEMY_TARGET_LOST",1, 2, 0.1,0.5);
--			AI.Signal(SIGNALFILTER_SENDER, 1, "END_ATTACK",entity.id);
--		end

	end,

	---------------------------------------------
	CLEAR_ALL = function(self, entity)
		entity:SelectPipe(0,"_nothing_");
	end,

	---------------------------------------------
	OnChargeStart = function(self, entity)
--		Log("-->"..entity:GetName().." OnChargeStart");
--		entity:Readibility("MELEE_ATTACK",1);

--		entity.actor:SetAnimationInput("SignalSticky","none");
--		entity.actor:SetAnimationInput("Signal","meleeAttackBender");

--		entity:Readibility("MELEE_ACCELERATE",1, 4);

		local sound = GetRandomSound(entity.voiceTable.accelerate);
		entity:PlaySoundEvent(sound[1], g_Vectors.v000, g_Vectors.v010, SOUND_DEFAULT_3D, SOUND_SEMANTIC_LIVING_ENTITY);

	end,

	---------------------------------------------
	OnChargeHit = function(self, entity, sender, data)

		local sound = GetRandomSound(entity.voiceTable.melee);
		entity:PlaySoundEvent(sound[1], g_Vectors.v000, g_Vectors.v010, SOUND_DEFAULT_3D, SOUND_SEMANTIC_WEAPON);

		-- the charge has hit the enemy, do damage.
		local enemy = System.GetEntity(data.id);
		if (enemy) then
			AI_Utils:AlienMeleePush(entity, enemy, 1000.0);
--		else
--			Log("could not find enemy");
		end
	end,

	---------------------------------------------
	OnChargeMiss = function(self, entity)
	end,

	---------------------------------------------
	OnChargeBailOut = function(self, entity)
	end,

	---------------------------------------------
	CHARGE_DONE = function(self, entity)
	end,

	---------------------------------------------
	OnHideFromTrooper = function(self, entity, sender, extraData)
		AI.ModifySmartObjectStates(entity.id, "Fleeing,Busy");
		AI.SetBeaconPosition(entity.id, System.GetEntity(extraData.id):GetPos());
		entity:SelectPipe(0,"gr_flee_trooper");

		if (entity.AI.trooperFleeTimer) then
			Script.KillTimer(entity.AI.trooperFleeTimer);
		end
		entity.AI.trooperFleeTimer = Script.SetTimerForFunction(5*1000.0,"AIBehaviour.GUARDDEFAULT.FleeTrooperTimer",entity);
	end,

	---------------------------------------------
	FleeTrooperTimer = function(entity,timerid)
		-- run to friends if they are not yet alerted.
		AI.ModifySmartObjectStates(entity.id, "-Fleeing,-Busy");
		if(entity.Behaviour.alertness == 0) then
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_IDLE",entity.id);
		else
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_AMBIENT",entity.id);
		end
		entity.AI.trooperFleeTimer = nil;
	end,

	---------------------------------------------
	FLEE_TROOPER_DONE = function( self, entity )
		-- run to friends if they are not yet alerted.
		AI.ModifySmartObjectStates(entity.id, "-Fleeing,-Busy");
		if(entity.Behaviour.alertness == 0) then
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_IDLE",entity.id);
		else
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_AMBIENT",entity.id);
		end
		
		if (entity.AI.trooperFleeTimer) then
			Script.KillTimer(entity.AI.trooperFleeTimer);
		end
		entity.AI.trooperFleeTimer = nil;
	end,

	--------------------------------------------------	
	OnOutOfAmmo = function (self,entity, sender)
		-- player would not have Reload implemented
		if(entity.Reload == nil)then
			do return end
		end
		entity:Reload();
	end,

}
