--------------------------------------------------
-- SuitIdle
--------------------------
--   created: Kirill Bulatsev 26-10-2006
--
--	
--

AIBehaviour.SuitThreatened = {
	Name = "SuitThreatened",
	alertness = 1,
	
	---------------------------------------------
	Constructor = function (self, entity)

		-- store original position.
		if(not entity.AI.idlePos) then
			entity.AI.idlePos = {x=0, y=0, z=0};
			CopyVector(entity.AI.idlePos, entity:GetPos());
		end

		entity:MakeAlerted();

		-- store last target position
		local target = AI.GetTargetType(entity.id);
		local	attPos = g_Vectors.temp_v1;
		if(target == AITARGET_NONE) then
			AI.GetBeaconPosition(entity.id, attPos);		
		else
			AI.GetAttentionTargetPosition(entity.id, attPos);
		end
		if(not entity.AI.target) then
			entity.AI.target = {x=0, y=0, z=0};
		end
		CopyVector(entity.AI.target, attPos);

		---------------------------------------------
		AI.BeginGoalPipe("su_fast_threatened");
			AI.PushGoal("strafe",0,100,100);
			AI.PushGoal("bodypos",0,BODYPOS_STAND,1);
			AI.PushGoal("run",0,0);
			AI.PushGoal("firecmd",0,FIREMODE_AIM);
--			AI.PushGoal("lookaround",0,30,3,100,100,AI_BREAK_ON_LIVE_TARGET);
			AI.PushGoal("locate", 0,"probtarget_in_territory");
			AI.PushGoal("+approach",1,-20,AILASTOPRES_USE,15.0);
			AI.PushGoal("firecmd",0,FIREMODE_AIM);
			AI.PushGoal("signal",0,1,"INVESTIGATE_READABILITY",0);
			AI.PushGoal("lookaround",1,60,2,4,2,AI_BREAK_ON_LIVE_TARGET);
			AI.PushGoal("signal",0,1,"INVESTIGATE_READABILITY",0);
		AI.EndGoalPipe();

		---------------------------------------------
		AI.BeginGoalPipe("su_fast_threatened_sniper");
			AI.PushGoal("locate",0,"probtarget");
			AI.PushGoal("+adjustaim",0,0,1);
			AI.PushGoal("timeout",1,1,2);
			AI.PushGoal("strafe",0,100,100);
			AI.PushGoal("bodypos",0,BODYPOS_STAND,1);
			AI.PushGoal("run",0,0);
			AI.PushGoal("firecmd",0,FIREMODE_AIM);
			AI.PushGoal("locate", 0,"probtarget_in_territory");
			AI.PushGoal("+approach",1,-10,AILASTOPRES_USE,15.0);
		AI.EndGoalPipe();
		
--		entity:SelectPipe(0,"su_fast_threatened");
		entity:SelectPipe(0,"su_fast_threatened_sniper");

		entity:NanoSuitMode(BasicAI.SuitMode.SUIT_ARMOR);

		AI.EnableWeaponAccessory(entity.id, AIWEPA_LASER, false);

		entity.AI.firstContact = true;
		entity.AI.lastCheckTime = _time;
	end,

	---------------------------------------------
	Destructor = function (self, entity)
	end,

	---------------------------------------------
	INVESTIGATE_READABILITY = function( self, entity)
		entity:Readibility("taunt",1,3,0.3,0.6);
	end,

	---------------------------------------------
	OnNoTarget = function (self, entity)
		AI.SetRefPointPosition(entity.id,entity.AI.idlePos);
		entity:SelectPipe(0,"cv_get_back_to_idlepos");
	end,

	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance, data )
		-- called when the enemy sees a living player
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 1, "ENEMYSEEN_DURING_COMBAT",entity.id);
		AI.Signal(SIGNALFILTER_SENDER,1,"TO_ATTACK",entity.id);
	end,

	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the enemy can no longer see its foe, but remembers where it saw it last
	end,

	---------------------------------------------
	CheckToChangeTarget = function( self, entity )
		-- If the attention target has changed a lot, choose new approach.
		local	attPos = g_Vectors.temp_v1;
		AI.GetAttentionTargetPosition(entity.id, attPos);
		local dist = DistanceVectors(attPos, entity.AI.target);
		local dt = _time - entity.AI.lastCheckTime;
		if(dist > 5.0 or dt > 3.0) then
			local	attPos = g_Vectors.temp_v1;
			AI.GetAttentionTargetPosition(entity.id, attPos);
			CopyVector(entity.AI.target, attPos);
			entity:SelectPipe(0,"do_nothing");
			
--			entity:SelectPipe(0,"su_fast_threatened");
			entity:SelectPipe(0,"su_fast_threatened_sniper");
			
			entity.AI.lastCheckTime = _time;
		elseif(dist > 3.0) then
			entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"cv_look_at_target");
		end
	end,

	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		entity:Readibility("alert_interest_hear",1,1,0.3,0.6);
		self:CheckToChangeTarget(entity);
	end,
	
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		entity:Readibility("alert_interest_hear",1,1,0.3,0.6);
		self:CheckToChangeTarget(entity);
	end,

	---------------------------------------------
	OnSomethingSeen = function( self, entity )
		entity:Readibility("alert_interest_see",1,1,0.3,0.6);
		self:CheckToChangeTarget(entity);
	end,

	---------------------------------------------
	OnReload = function( self, entity )
	end,

	---------------------------------------------
	OnDamage = function ( self, entity, sender)
	end,

	---------------------------------------------
	ENEMYSEEN_DURING_COMBAT = function (self, entity, sender)
		if(AI.GetTargetType(entity.id) ~= AITARGET_ENEMY) then
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_ATTACK",entity.id);
		end
	end,
	
	---------------------------------------------
	ENEMYSEEN_FIRST_CONTACT = function (self, entity, sender)
	end,

	--------------------------------------------------
	INCOMING_FIRE = function (self, entity, sender)
		-- do nothing on this signal
	end,

	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity, fDistance )
	end,

}