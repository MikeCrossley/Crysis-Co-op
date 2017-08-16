--------------------------------------------------
-- SuitIdle
--------------------------
--   created: Kirill Bulatsev 26-10-2006
--
--	
--

AIBehaviour.SuitBossIdle = {
	Name = "SuitBossIdle",
	Base = "SuitIdle",


	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
	
		entity:MakeAlerted();
	
		entity:Readibility("first_contact",1,3,0.1,0.4);
		entity:TriggerEvent(AIEVENT_DROPBEACON);

		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT,1,"GET_ALERTED",entity.id);

		entity.AI.firstContact = true;

		if(AI.GetGroupTacticState(entity.id, 0, GE_LEADER_COUNT) > 0) then
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_ATTACK_GROUP",entity.id);
		else
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_ATTACK",entity.id);
		end
	end,

	---------------------------------------------
	OnNoTarget = function(self,entity,sender)
--		entity:UseLAM(false);
	end,

	---------------------------------------------
	OnTargetDead = function( self, entity )
		-- called when the attention target died
		entity:Readibility("target_down",1,1,0.3,0.5);
	end,

	---------------------------------------------
	OnSomethingSeen = function( self, entity )
		-- called when the enemy sees a foe which is not a living player
		entity:Readibility("idle_interest_see",1,1,0.6,1);
		entity:MakeAlerted();
	end,
	
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		-- check if we should check the sound or not.
		entity:Readibility("idle_interest_hear",1,1,0.6,1);
		entity:MakeAlerted();		
	end,

	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity, fDistance )
		-- called when the enemy hears a scary sound
		entity:Readibility("idle_alert_threat_hear",1,1,0.6,1);
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		entity:MakeAlerted();		
	end,

	--------------------------------------------------
	OnNearMiss = function(self, entity, sender)
		-- only react to hostile bullets.

--		AI.RecComment(entity.id, "hostile="..tostring(AI.Hostile(entity.id, sender.id)));
		entity:Readibility("bulletrain",1,1,0.1,0.4);
		entity:NanoSuitMode( BasicAI.SuitMode.SUIT_ARMOR );
	end,
	
	---------------------------------------------
	OnBulletRain = function(self, entity, sender, data)
		self:OnNearMiss(entity,sender);
	end,

	--------------------------------------------------

	
	---------------------------------------------
	--------------------------------------------------	
	
}
