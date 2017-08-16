--------------------------------------------------
-- SuitHide
--------------------------
--   created: Kirill Bulatsev 26-10-2006
--
--------------------------	
--   Description: 	goes hiding under fire, make sure the health gets regenerated before quitting behavior
--------------------------

AIBehaviour.SuitHide = {
	Name = "SuitHide",
	Base = "Cover2Hide",
	alertness = 1,

	-----------------------------------------------------
	Constructor = function(self,entity)
		entity:GettingAlerted();

--		entity.AI.changeCoverLastTime = _time;
--		entity.AI.changeCoverInterval = random(7,11);
--		entity.AI.fleeLastTime = _time;
--		entity.AI.lastLiveEnemyTime = _time;
--		entity.AI.lastBulletReactionTime = _time - 10;
--		entity.AI.lastFriendInWayTime = _time - 10;

		entity.AI.coverCompromized = false;	
		entity.AI.lastHideTime = _time - 100;
		
--		AIBehaviour.Cover2Hide:HandleThreat(entity, true);
--		self:HandleThreat(entity,true);

		-- keep on hiding no matter what, and after the timer has fired, try to come out of cover.
		local target = AI.GetTargetType(entity.id);
		if(target==AITARGET_ENEMY or target==AITARGET_MEMORY) then
			-- Hide from attention target
			entity:SelectPipe(0,"su_keep_hiding");
		else
			-- Hide from beacon
			entity:SelectPipe(0,"su_keep_hiding_beacon");
		end

	end,
	
	-----------------------------------------------------
	Destructor = function(self,entity)
	end,

	---------------------------------------------		
	OnPlayerSeen = function( self, entity, fDistance )
		entity:MakeAlerted();
		entity:TriggerEvent(AIEVENT_DROPBEACON);
--		self:HandleThreat(entity,false);
--		if(AI.GetGroupTacticState(entity.id, 0, GE_LEADER_COUNT) > 0) then
--			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_ATTACK_GROUP",entity.id);
--		else
--			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_ATTACK",entity.id);
--		end

	end,

	---------------------------------------------		
	MORE_HIDE = function( self, entity, fDistance )
	
local healthPercent=entity:GetHealthPercentage();
AI.LogEvent( ">>>> suitHide --- health percentage "..healthPercent );
	
		if(entity:GetHealthPercentage()>75) then
--			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_STEALTH", entity.id);
			AI.Signal(SIGNALFILTER_SENDER, 1, "HIDE_DONE",entity.id);
		else
			entity:SelectPipe(0,"su_stay_hidden");
		end
		
	end,

	--------------------------------------------------
	OnCoverCompromised = function(self, entity, sender, data)
		self:MORE_HIDE(entity,false);
	end,


	---------------------------------------------
	OnEnemyDamage = function (self, entity, sender, data)
		entity:Readibility("taking_fire",1);
		entity:SelectPipe(0,"do_nothing");
		entity:SelectPipe(0,"su_stay_hidden");		
	end,
	
	--------------------------------------------------
}
