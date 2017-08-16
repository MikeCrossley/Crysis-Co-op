--------------------------------------------------
-- SuitAttack
-- this is modifyed Cover2Attack behavior
-- AI with nano suit, using Hurricane weapon - basiaclly turren
--------------------------
--   created: Kirill Bulatsev 25-10-2006


AIBehaviour.SuitHurricaneAttack = {
	Name = "SuitHurricaneAttack",
	alertness = 2,

	-----------------------------------------------------
	Constructor = function (self, entity)
--		entity:SelectPipe(0,"do_nothing");

		entity.AI.lastBulletReactionTime = _time - 10;
		entity.AI.lastTargetSeenTime = _time;
		
		entity.AI.standing = true;

		entity:NanoSuitMode(BasicAI.SuitMode.SUIT_ARMOR);
		
		self:COVER_NORMALATTACK(entity);
	end,

	-----------------------------------------------------
	Destructor = function(self,entity)
	end,
	
	---------------------------------------------
	COVER_NORMALATTACK = function (self, entity, sender)
		
		local dt = _time - entity.AI.lastTargetSeenTime;

		entity:Readibility("during_combat",1,1,0.3,6);
		
		AI.ChangeParameter(entity.id, AIPARAM_AIM_TURNSPEED, 20);
		AI.ChangeParameter(entity.id, AIPARAM_FIRE_TURNSPEED, 15);
		AI.ChangeParameter(entity.id, AIPARAM_LOOKIDLE_TURNSPEED, 20);
		AI.ChangeParameter(entity.id, AIPARAM_LOOKCOMBAT_TURNSPEED, 30);
		AI.ChangeParameter(entity.id, AIPARAM_MELEE_DISTANCE, 4.0);
		
		if (dt > 6.0 and AI.GetTargetType(entity.id) ~= AITARGET_ENEMY) then
			entity:SelectPipe(0,"su_attack_move");
			entity.AI.standing = false;
			entity:NanoSuitMode( BasicAI.SuitMode.SUIT_SPEED );
		else
			entity:SelectPipe(0,"su_attack_stand");
			entity.AI.standing = true;
			entity:NanoSuitMode( BasicAI.SuitMode.SUIT_ARMOR );
		end

	end,

	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance, data )
		entity:Readibility("during_combat",1,1,0.3,6);
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		
		if (entity.AI.standing == false) then
			entity:SelectPipe(0,"su_attack_stop_and_shoot");
			entity.AI.standing = true;
		end
		
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
		if(AI.CanMelee(entity.id)) then
			entity:NanoSuitMode( BasicAI.SuitMode.SUIT_POWER );

			AI.ChangeParameter(entity.id, AIPARAM_AIM_TURNSPEED, 40);
			AI.ChangeParameter(entity.id, AIPARAM_FIRE_TURNSPEED, 100);
			AI.ChangeParameter(entity.id, AIPARAM_MELEE_DISTANCE, 4.0);

			entity:SelectPipe(0,"su_melee");
		end
	end,
	
	---------------------------------------------
	OnNoTargetAwareness = function (self, entity)
		AI.Signal(SIGNALFILTER_SENDER,1,"TO_THREATENED",entity.id);
	end,

	---------------------------------------------
	OnEnemyDamage = function(self, entity, sender)
		local	dt = _time - entity.AI.lastBulletReactionTime;
		if(dt > 4.0) then
--			entity:Readibility("taking_fire",1);
			entity.AI.lastBulletReactionTime = _time;
			entity:SelectPipe(0,"su_bullet_reaction");
		end
	end,
	
	---------------------------------------------
	OnBulletRain = function(self, entity, sender, data)
	end,

	--------------------------------------------------
	OnNearMiss = function(self, entity, sender)
	end,

	
}
