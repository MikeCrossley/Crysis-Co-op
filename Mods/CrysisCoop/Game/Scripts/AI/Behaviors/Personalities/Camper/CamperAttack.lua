--------------------------------------------------
-- SneakerAttack
--------------------------
--   created: Mikko Mononen 21-6-2006


AIBehaviour.CamperAttack = {
	Name = "CamperAttack",
	Base = "Cover2Attack",
	alertness = 2,

	Constructor = function (self, entity)
		AIBehaviour.Cover2Attack:Constructor(entity);
	end,
	---------------------------------------------
	Destructor = function (self, entity)
		AIBehaviour.Cover2Attack:Destructor(entity);
	end,

	---------------------------------------------
	COVER_NORMALATTACK = function (self, entity, sender)
		local target = AI.GetTargetType(entity.id);
		local state = GS_ADVANCE;
		
		if (target ~= AITARGET_ENEMY) then
			state =	AI.GetGroupTacticState(entity.id, 0, GE_GROUP_STATE);
		end

		local throwingGrenade = 0;

		if (state == GS_SEEK) then
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_SEEK",entity.id);
		elseif (state == GS_SEARCH or state == GS_ALERTED or state == GS_IDLE) then
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_SEARCH",entity.id);
		else
			
			AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_ADVANCING);

			local tacPoint = AI.GetGroupTacticPoint(entity.id, 0, GE_DEFEND_POS);
			if (not tacPoint) then
				AI.Warning(" Entity "..entity:GetName().." returned invalid group defend pos.");
				AI.SetRefPointPosition(entity.id,entity:GetPos());
				entity:SelectPipe(AIGOALPIPE_NOTDUPLICATE,"cm_defend");
			else
				local	distToDefendPos = DistanceVectors(entity:GetPos(), tacPoint);
				if (distToDefendPos > 10.0) then
					if (AI.GetGroupTacticState(entity.id, 0, GE_MOST_LOST_UNIT) == 1) then
						entity:Readibility("cover_me",1,3,0.1,0.4);
						entity:SelectPipe(AIGOALPIPE_NOTDUPLICATE,"cv_cohesion");
					else
						local signal = AI.GetGroupTacticState(entity.id, 0, GE_MOVEMENT_SIGNAL);
						if (signal ~= 0) then
							entity:SelectPipe(AIGOALPIPE_NOTDUPLICATE,"cv_signal_defend");
						else
							entity:SelectPipe(AIGOALPIPE_NOTDUPLICATE,"cv_advance");
							entity.AI.lastAdvanceTime = _time;
						end
						
					end
				else
					local	dtBullet = _time - entity.AI.lastBulletReactionTime;
					local	dtSignal = _time - AI_Utils:GetLastSignalTime(entity);
					if (dtBullet > 3.0 and dtSignal > 8.0) then
						AI_Utils:SetLastSignalTime(entity, _time);
						entity:Readibility("cover_me",1,3,0.1,0.4);
						entity:SelectPipe(AIGOALPIPE_NOTDUPLICATE,"cv_signal_defend");
					else
						entity:Readibility("during_combat",1,3,0.1,0.4);
						entity:SelectPipe(AIGOALPIPE_NOTDUPLICATE,"cm_defend");
						entity.AI.lastAdvanceTime = _time;
					end
				end
	
				if (AI_Utils:CanThrowGrenade(entity) == 1) then
					entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"sn_throw_grenade");
					throwingGrenade = 1;
				end
			end
		end

		if(throwingGrenade == 0 and target ~= AITARGET_ENEMY and entity:CheckCurWeapon() == 1) then
			entity:SelectPrimaryWeapon();
		end
	end,

	---------------------------------------------
	OnBulletRain = function(self, entity, sender)
--		local dta = _time - entity.AI.lastAdvanceTime;
--		if (dta > 3.0) then
--		if (AI.IsMoving(entity.id,2) == 0) then
			local	dt = _time - entity.AI.lastBulletReactionTime;
			local reactionTime = 0.5;
			if (AI.IsMoving(entity.id,1) == 1) then
				reactionTime = 1.5;
			end

			if(dt > reactionTime) then
				entity.AI.lastBulletReactionTime = _time;
				entity:Readibility("bulletrain",1,0.1,0.4);
				AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_HIDING);
				entity:SelectPipe(0,"do_nothing");
				entity:SelectPipe(0,"cv_bullet_reaction");
			end
--		end
		AI.NotifyGroupTacticState(entity.id, 0, GN_AVOID_CURRENT_POS);
	end,

	---------------------------------------------
	OnEnemyDamage = function(self, entity, sender)
--		local dta = _time - entity.AI.lastAdvanceTime;
--		if (dta > 3.0) then
--		if (AI.IsMoving(entity.id,2) == 0) then
			local	dt = _time - entity.AI.lastBulletReactionTime;
			local reactionTime = 0.5;
			if (AI.IsMoving(entity.id,1) == 1) then
				reactionTime = 1.5;
			end
			if(dt > reactionTime) then
				entity:Readibility("taking_fire",1);
				entity.AI.lastBulletReactionTime = _time;
				AI.NotifyGroupTacticState(entity.id, 0, GN_NOTIFY_HIDING);
				entity:SelectPipe(0,"do_nothing");
				entity:SelectPipe(0,"cv_bullet_reaction");
			end
--		end
		AI.NotifyGroupTacticState(entity.id, 0, GN_AVOID_CURRENT_POS);
	end,
}
