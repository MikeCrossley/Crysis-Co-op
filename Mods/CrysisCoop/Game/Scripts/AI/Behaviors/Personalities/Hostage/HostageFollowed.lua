AIBehaviour.HostageFollowed = {
	Name = "HostageFollowed",
	
	Constructor = function(self,entity,data)
		entity.AI.RefPointMemory = {};
		CopyVector(entity.AI.RefPointMemory, data.point);
		entity:SelectPipe(0,"do_nothing");
		entity:SelectPipe(0,"squad_form_special");
		entity:InsertSubpipe(0,"do_it_standing");
		--remove hostage from team
		AI.Signal(SIGNALFILTER_LEADER,10,"OnUnitBusy",entity.id);	
	end,
	
	FORMATION_REACHED = function(self,entity,sender)
		AI.SetRefPointPosition(entity.id,entity.AI.RefPointMemory);
		entity:Readibility("FOLLOW_ME",1);
		entity:SelectPipe(0,"GoOn2sec");
	end,
	
	GoOn = function(self,entity,sender)
		entity:SelectPipe(0,"approach_refpoint");
		entity:InsertSubpipe(0,"do_it_running");
		entity:InsertSubpipe(0,"clear_all");
	end,
	
	ORDER_FORM = function(self,entity,sender)
	end,

	ORDER_FOLLOW = function(self,entity,sender)
	end,

	ORDER_HOLD = function(self,entity,sender)
	end,
}