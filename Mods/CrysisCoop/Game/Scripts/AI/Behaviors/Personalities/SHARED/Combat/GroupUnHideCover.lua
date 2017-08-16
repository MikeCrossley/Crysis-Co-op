--------------------------------------------------
--	Created  Luciano Morpurgo
--   Description: Group combat: AI unhides, fires and then he's ready to hide again
-- Same as GroupUnHide, but different transitions in character (doesn't return to hide when finished)
--------------------------

AIBehaviour.GroupUnHideCover = {
	Name = "GroupUnHideCover",
	Base = "GroupUnHide",
	
	Constructor = function( self, entity )
		AI.Signal(SIGNALFILTER_LEADER,10,"ORD_DONE",entity.id);
		AIBehaviour.GroupUnHide:Constructor(entity)
	end,
	
	OnPlayerSeen = function( self, entity, sender )
		entity:InsertSubpipe(0,"start_fire");
	end,	
	
}
