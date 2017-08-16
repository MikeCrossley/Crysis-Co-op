--------------------------------------------------
--   Created By: Luciano
--   Description: same as coverfollow, but not grouped
--------------------------
--   modified by: everyone

AIBehaviour.Job_WalkFollow = {
	Name = "Job_WalkFollow",

	Constructor = function( self, entity )	
		AI.LogEvent("Constructor of CoverFollow");
		entity:SelectPipe(0,"do_nothing");
		entity:SelectPipe(0,"squad_form");
		--entity:InsertSubpipe(0,"reserve_spot");
		entity:InsertSubpipe(0,"setup_combat");
		entity:InsertSubpipe(0,"short_wait");
		entity.IN_SQUAD = 0;
	end,
	
}