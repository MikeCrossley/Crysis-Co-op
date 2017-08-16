--------------------------------------------------
--   Created By: Luciano Morpurgo
--------------------------

AIBehaviour.HostageFollowHide = {
	Name = "HostageFollowHide",
	Base = "SquadFollowHide",
	TASK = 1,

	Constructor = function( self, entity, data )	
		entity.AI.InSquad = 1;
		--AI.LogEvent(entity:GetName().." executes SQUADFOLLOW constructor");
		local leader = AI.GetLeader(entity.id);
		if(leader) then
			AI.ChangeParameter( entity.id, AIPARAM_SPECIES,AI.GetSpeciesOf(leader.id));
		end
		AIBehaviour.SquadFollowHide.GotoHidePoint(entity,data);
		AI.SetPFProperties(entity.id, AIPATH_HUMAN_COVER);
	end,


}
