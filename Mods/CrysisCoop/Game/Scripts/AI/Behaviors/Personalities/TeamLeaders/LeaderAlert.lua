--------------------------------------------------
--    Created By: Luciano Morpurgo
--   Description: Leader has been notified of enemy sight and wait from CLeader's orders
--   Like Idle, but ignoring furter notifications
--------------------------
--

AIBehaviour.LeaderAlert = {
	Name = "LeaderAlert",
	switched = 0,

	NotifyPlayerSeen	= function(self,entity,sender)
	end, 

}
