--------------------------------------------------
--    Created By: Luciano
--   Description: Team Leader orders teammates to search for the enemy around
--------------------------
--

AIBehaviour.LeaderSearch = {
	Name = "LeaderSearch",
	Base = "CoverSearch",
	alertness = 1,
--	JOB = 1,
	-- COMMANDER ORDERS --
	----------------------
	
	Constructor = function(self, entity)
		AI.Signal(SIGNALFILTER_LEADER, 0,"OnAbortAction",entity.id);
		AI.Signal(SIGNALFILTER_GROUPONLY, 0,"SEARCH_AROUND",entity.id);
		AIBehaviour.CoverSearch.LOOKING_DONE(self,entity,entity);
		
	end,
	
	CORD_FOLLOW = function( self, entity )
	end,
	
	CORD_IDLE = function (self,entity,sender)
		AI.Signal(SIGNALFILTER_GROUPONLY, 0,"RETURN_TO_FIRST",entity.id);
	end,		
		
}