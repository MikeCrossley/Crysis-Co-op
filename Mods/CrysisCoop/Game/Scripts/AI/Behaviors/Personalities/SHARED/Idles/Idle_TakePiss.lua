-- idle take a piss behaviour - 
-- created by sten: 		14-10-2002
-- last modified by sten: 	24-10-2002
--------------------------


AIBehaviour.Idle_TakePiss = {
	Name = "Idle_TakePiss",
	JOB = 2,
		
	-- AnimTable =		{"_smoking_start","_smoking_end1","_smoking_end2"},
	AnimTableRandom = 	{"_idle_leanright","_idle_leanleft","_itchbutt"},
		
	-- SYSTEM EVENTS			-----
	---------------------------------------------
	Constructor = function(self,entity )
		entity.cnt.AnimationSystemEnabled = 1;
		entity:SelectPipe(0,"IdlePipe");
	end,
	----------------------------------------------------FUNCTIONS -------------------------------------------------------------
	GoOn = function (self, entity, sender)
		entity:SelectPipe(0,"IdlePipe");
	end,
	------------------------------------------------------------------------
	SelectAnchor = function (self, entity, sender)
		-- select the responsible anchor and approach it 
		if  (AI.FindObjectOfType(entity:GetPos(),20,AIAnchorTable.AIANCHOR_PISS)) then
			entity:InsertSubpipe(0,"AcqPissAnchor");
		end
	end,
	------------------------------------------------------------------------
	IdleStart = function (self, entity, sender)
		-- play the start animation
	end,
	------------------------------------------------------------------------
	IdleLoop = function (self, entity, sender)
	end,
	------------------------------------------------------------------------
	IdleRandom = function (self, entity, sender)
		-- insert a random loop-break animation
		local idx=random(1,2);
		local Animation = self.AnimTableRandom[idx];
		self.AnimTableRandom[idx]=self.AnimTableRandom[3];
		self.AnimTableRandom[3]=Animation;
		
		entity:StartAnimation(0,Animation);
	end,
	------------------------------------------------------------------------
	IdleEnd = function (self, entity, sender)
		-- play the end animation and go back to the job
		AI.Signal(0,1,"BackToJob",entity.id);
		entity:SelectPipe(0,"GoOn2sec");
	end,

}