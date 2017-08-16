-- idle talk behaviour - talks without moving
--------------------------


AIBehaviour.Idle_Talk = {
	Name = "Idle_Talk",
	NOPREVIOUS = 1,
	JOB = 2,


	CONVERSATION_FINISHED = function(self,entity,sender)
		entity.EventToCall = "OnJobContinue";	
	end,

	OnJobExit = function(self,entity,sender)
		if (entity.CurrentConversation) then
			entity.CurrentConversation:Stop(entity);
--			entity:StopDialog();
		end
	end
}