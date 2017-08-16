--------------------------------------------------
-- SuitSniperThreatened
--------------------------
--   created: Mikko Mononen 28-4-2007

AIBehaviour.SuitSniperThreatened = {
	Name = "SuitSniperThreatened",
	alertness = 1,
	
	---------------------------------------------
	Constructor = function (self, entity)

		entity:NanoSuitMode(BasicAI.SuitMode.SUIT_CLOAK);

		AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_ALERTED);
		
		entity:MakeAlerted();
		AI_Utils:CheckThreatened(entity, 30.0);

		local range = entity.Properties.preferredCombatDistance/2;
		local radius = 4.0;
		if(AI.GetNavigationType(entity.id) == NAV_WAYPOINT_HUMAN) then
			range = range / 2;
			radius = 2.5;
		end
  	AI.SetPFBlockerRadius(entity.id, PFB_DEAD_BODIES, radius);
  	AI.SetPFBlockerRadius(entity.id, PFB_EXPLOSIVES, radius);

		if (AI_Utils:CanThrowSmokeGrenade(entity) == 1) then
			AI.ChangeParameter(entity.id, AIPARAM_GRENADE_THROWDIST, 1.0);
			entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"su_throw_smoke");
		end

		entity.AI.firstContact = true;
	end,

	---------------------------------------------
	Destructor = function (self, entity)
	end,

	---------------------------------------------
	SEEK_KILLER = function (self, entity)
		AI_Utils:CheckThreatened(entity, 15.0);
	end,

	---------------------------------------------
	OnNoTarget = function (self, entity)
--		AI.SetRefPointPosition(entity.id,entity.AI.idlePos);
--		entity:SelectPipe(0,"cv_get_back_to_idlepos");
	end,

	---------------------------------------------
	INVESTIGATE_DONE = function( self, entity )
		local target = AI.GetTargetType(entity.id);
		if(target == AITARGET_ENEMY) then
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_ATTACK",entity.id);
		else
			entity:NanoSuitMode(BasicAI.SuitMode.SUIT_ARMOR);
			entity:SelectPipe(0,"cv_seek_target_random");
		end
	end,

	---------------------------------------------
	INVESTIGATE_CONTINUE = function( self, entity )
		entity:SelectPipe(0,"cv_investigate_threat_closer");
	end,

	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance, data )
		-- called when the enemy sees a living player
		entity:TriggerEvent(AIEVENT_DROPBEACON);

		AI.Signal(SIGNALFILTER_SENDER,1,"TO_ATTACK",entity.id);
	end,

	---------------------------------------------
	OnEnemySeen = function( self, entity )
		-- called when the enemy sees a foe which is not a living player
	end,

	---------------------------------------------
	OnFriendSeen = function( self, entity )
		-- called when the enemy sees a friendly target
	end,

	---------------------------------------------
	OnDeadBodySeen = function( self, entity )
		-- called when the enemy a dead body
	end,

	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the enemy can no longer see its foe, but remembers where it saw it last
	end,

	---------------------------------------------
	CheckToChangeTarget = function( self, entity )
		-- If the attention target has changed a lot, choose new approach.
--		local	attPos = g_Vectors.temp_v1;
--		AI.GetAttentionTargetPosition(entity.id, attPos);
--		local dist = DistanceVectors(attPos, entity.AI.target);
--		if(dist > 5.0) then
			AI_Utils:CheckThreatened(entity, 15.0);
--		elseif(dist > 3.0) then
--			entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"cv_look_at_target");
--		end
	end,

	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
--		entity:TriggerEvent(AIEVENT_CLEAR);
--		entity:Readibility("alert_interest_hear",1,1,0.3,0.6);
		self:CheckToChangeTarget(entity);
	end,
	
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
--		entity:TriggerEvent(AIEVENT_CLEAR);
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		entity:Readibility("alert_interest_hear",1,1,0.3,0.6);
		self:CheckToChangeTarget(entity);
	end,

	---------------------------------------------
	OnThreateningSeen = function( self, entity )
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		entity:Readibility("alert_interest_see",1,1,0.3,0.6);
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
		if(AI.GetTargetType(entity.id) ~= AITARGET_ENEMY) then
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_ATTACK",entity.id);
		end
	end,

	--------------------------------------------------
	INCOMING_FIRE = function (self, entity, sender)
		-- do nothing on this signal
	end,

}