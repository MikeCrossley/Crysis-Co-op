-- Generic Idle behaviour - just change animations to make it something else
-- created by petar
--------------------------


Idle_Any = {
	Name = "Idle_Any",
	JOB = 2,
	NOPREVIOUS = 1,

	RemoveAttachments = function(self,entity)

		if (self.Attachment) then 
			for i,value in pairs(self.Attachment) do
				entity:DetachObjectToBone(value.strBoneName,entity.JOB_ATTACHMENTS);
				entity:DrawObject(i,0);
			end
		end

	end,

	AttachNow = function(self,entity)

		if (self.Attachment) then 
			if (entity.JOB_ATTACHMENTS==nil) then
				entity.JOB_ATTACHMENTS = {};
			end
			for i,value in pairs(self.Attachment) do
				if (value.USE_KEYFRAME) then
					entity:LoadObject(value.fileObject,i,0);
					entity:DrawObject(i,0);
					entity.JOB_ATTACHMENTS[i] = entity:AttachObjectToBone(i,value.strBoneName,1);
				end
			end
		end
	end,


	-- SYSTEM EVENTS			-----
	---------------------------------------------
	Constructor = function(self,entity )
		entity.cnt.AnimationSystemEnabled = 1;
		
		
		if (self.BreakDelay) then
			AI.CreateGoalPipe("special_idle_stand");
			AI.PushGoal("special_idle_stand","timeout",1,self.BreakDelay[1],self.BreakDelay[2]);
			AI.PushGoal("special_idle_stand","signal",1,-1,"DECIDE_TO_BREAK_OR_NOT",0);
			entity:SelectPipe(0,"special_idle_stand");
		else	
			entity:SelectPipe(0,"any_idle_stand");
		end
		

		if (self.NumberOfBreaks) then 
			entity:InsertSubpipe(0,"any_break_anim");
			self.NrBreaks = random(self.NumberOfBreaks[1],self.NumberOfBreaks[2]);
		else
			self.NrBreaks = nil;
		end


		if (self.ANCHOR_TO_APPROACH) then 
			local approach_target = AI.FindObjectOfType(entity:GetPos(),30,self.ANCHOR_TO_APPROACH);
			if (approach_target) then
				entity:InsertSubpipe(0,"any_idle_reach_lastop",approach_target);
				if (self.RUN) then 
					entity:InsertSubpipe(0,"do_it_running");
				end
			end		
		end

		entity:InsertSubpipe(0,"setup_idle");
	end,

	
	
	----------------------------------------------------FUNCTIONS --

	OnJobExit = function (self,entity,sender)

		if (self.BaseLoopAnimation) then
			entity.cnt.AnimationSystemEnabled = 1;
		end

		entity:StartAnimation(0,"NULL",3);

		if (entity.AI_ParticleHandle) then
			Particle.Detach(entity.id,entity.AI_ParticleHandle);
		end

		self:RemoveAttachments(entity);

		if (self.WITHOUT_WEAPON) then 
			entity.cnt:HoldGun();
		end


	end,
	
	----------------------------------------------------	
	BackToJob = function (self,entity,sender)
		
		if (self.BaseLoopAnimation) then
			entity.cnt.AnimationSystemEnabled = 1;
		end

		entity:StartAnimation(0,"NULL",3);

		entity.EventToCall = "OnJobContinue";

		if (entity.AI_ParticleHandle) then
			Particle.Detach(entity.id,entity.AI_ParticleHandle);
		end

		self:RemoveAttachments(entity);

		if (self.WITHOUT_WEAPON) then 
			entity.cnt:HoldGun();
		end

	end,

	----------------------------------------------------
	ANCHOR_REACHED = function (self,entity,sender)

		if (self.AFFECT_POSITION) then
			local pos = {x=0,y=0,z=0};
			local approach_target = AI.FindObjectOfType(entity:GetPos(),3,self.ANCHOR_TO_APPROACH,0,pos);
			if (approach_target == nil) then 
				Hud:AddMessage("------ NO TARGET -----");
			end
			entity:SetPos(pos);
		end

		if (self.BaseLoopAnimation) then
			entity.cnt.AnimationSystemEnabled = 0;
			local anim_table = self:GetOneAnimation(self.BaseLoopAnimation,entity);
			entity:StartAnimation(0,anim_table[1],3,anim_table[4]);
		end	


		if (self.Attachment) then 
	
			entity.JOB_ATTACHMENTS = {};
			for i,value in pairs(self.Attachment) do
				if (value.USE_KEYFRAME == nil) then
					entity:LoadObject(value.fileObject,i,0);
					entity:DrawObject(i,0);
					entity.JOB_ATTACHMENTS[i] = entity:AttachObjectToBone(i,value.strBoneName,1);
				end
			end
		end

		if (self.StartAnimation) then 
			local anim_table = self:GetOneAnimation(self.StartAnimation,entity);
			entity:InsertAnimationPipe(anim_table[1],3,"START_ANIM_FINISHED",anim_table[4]);
			if (self.TRIGGER_EVENT) then
				if (entity.Event_SPECIAL_ANIM_START) then 
					entity.Event_SPECIAL_ANIM_START(entity);
				end
			end
		end

		if (self.WITHOUT_WEAPON) then 
			entity.cnt:HolsterGun();
		end

	end,

	----------------------------------------------------
	START_ANIM_FINISHED = function (self,entity,sender)
		if (self.SmokeParticles) then 
			entity.AI_ParticleHandle = Particle.Attach(entity.id,self.SmokeParticles,10,"Bip01 L Hand");
		end


		if (self.CustomStartEffects) then
			self:CustomStartEffects(entity);
		end
		entity:SetAnimationSpeed(1);	
	end,

	----------------------------------------------------
	END_ANIM_FINISHED = function (self,entity,sender)
		if (self.CustomEndEffects) then
			self:CustomEndEffects(entity);
		end
		entity:SetAnimationSpeed(1);	
	end,

	----------------------------------------------------
	BREAK_ANIM_STARTED = function (self,entity,sender)
		if (self.CustomBreakStartEffects) then
			self:CustomBreakStartEffects(entity);
		end
	end,

	----------------------------------------------------
	BREAK_ANIM_FINISHED = function (self,entity,sender)
		if (self.CustomBreakEndEffects) then
			self:CustomBreakEndEffects(entity);
		end
		entity:SetAnimationSpeed(1);	
	end,



	----------------------------------------------------
	PLAY_BREAK_ANIMATION = function (self,entity,sender)
		if (self.BreakAnimation) then
			local anim_table = self:GetOneAnimation(self.BreakAnimation,entity);
			entity:InsertAnimationPipe(anim_table[1],3,BREAK_ANIM_FINISHED,anim_table[4]);
		end
		self.NrBreaks = self.NrBreaks-1;
	end,

	----------------------------------------------------
	DECIDE_TO_BREAK_OR_NOT = function (self,entity,sender)

		if (self.NrBreaks) then
			if (self.NrBreaks > 0) then 
				entity:InsertSubpipe(0,"any_break_anim");
			else

				if (self.BaseLoopAnimation) then
					entity:StartAnimation(0,"NULL",3);
					entity:StartAnimation(0,"sidle");
				end

				entity:SelectPipe(0,"any_end_idle");

				if (self.EndAnimation) then
					local anim_table = self:GetOneAnimation(self.EndAnimation,entity);
					entity:InsertAnimationPipe(anim_table[1],3,END_ANIM_FINISHED,anim_table[4]);
					if (entity.AI_ParticleHandle)then
						Particle.Detach(entity.id,entity.AI_ParticleHandle);
					end
				end

			end
		else
			entity:SelectPipe(0,"any_end_idle");
		end
	end,

	------------------------------------------------------------------------
	-- GROUP SIGNALS
	------------------------------------------------------------------------
	MOVE_IN_FORMATION = function (self, entity, sender)
	end,
	------------------------------------------------------------------------
	BREAK_AND_IDLE = function (self, entity, sender)
	end,
	------------------------------------------------------------------------

	GetOneAnimation = function (self,table,entity)
		local nr_rnd = count(table);
		local rnd = random(1,nr_rnd);

		if (table[rnd].times_PLAYED==nil) then
			table[rnd].times_PLAYED = 0;
		end

		table[rnd].times_PLAYED = table[rnd].times_PLAYED+1;

		if (table[rnd].times_PLAYED > table[rnd][2]) then
			table[rnd].times_PLAYED = 0;
			rnd=rnd+1;
			if (rnd>nr_rnd) then
				rnd = 1;
			end
		end

--		if (table[rnd][2] == 0) then 
--			-- this animation cannot be repeated, grab next one if this one played last
--			if (table[rnd].played_LAST) then
--				rnd=rnd+1;
--				if (rnd>nr_rnd) then
--					rnd = 1;
--				end
--			end
--		end
--		-- reset played last
		for index,tbl in pairs(table) do 
			if (index ~= rnd) then
				tbl.times_PLAYED = 0;
			end
		end

		-- set the animation speed
		if (table[rnd][3]) then 
			local time_rnd = random(table[rnd][3][1]*100,table[rnd][3][2]*100);
			entity:SetAnimationSpeed(time_rnd/100);
		end
		-- set only for current one
--		table[rnd].played_LAST = 1;
		return table[rnd];
	end,
}


----------------------------------------------------------------------------------
function CreateIdleBehaviour(table, priority)

	local NewBehaviour={};
	mergef(NewBehaviour,Idle_Any,1);
	mergef(NewBehaviour,table,1);

	AIBehaviour.INTERNAL[table.Name] = "Scripts/AI/Behaviors/Personalities/SHARED/Idles/AnimIdles.lua";

	-- add it to the bored manager
	local newSignalTableEntry = {};
	newSignalTableEntry.anchorType = table.ANCHOR_TO_APPROACH;
	newSignalTableEntry.signal = "GO_"..table.Name;
	newSignalTableEntry.tag = 0;
	if (priority) then
		newSignalTableEntry.priority = priority;
	else
		newSignalTableEntry.priority = 0;
	end
	if (table.ANCHOR_TO_APPROACH) then
		AI_BoredManager.ASTable[table.Name] = newSignalTableEntry;
	end

	-- now add the necessary character info to change in and out of this behaviour
	AICharacter.DEFAULT.NoBehaviorFound[newSignalTableEntry.signal] = table.Name;

	return NewBehaviour;
end