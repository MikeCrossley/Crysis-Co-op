-- Created by Petar; 
--------------------------


AIBehaviour.MorpherJob_Morph = {
	Name = "MorpherJob_Morph",
	JOB = 1,
	
	-- SYSTEM EVENTS			-----
	---------------------------------------------
	OnActivate = function(self,entity )

		
		entity:SelectPipe(0,"standingthere");

		local morph_target = AI.FindObjectOfType(entity.id,30,AIAnchorTable.MORPH_HERE);
		if (morph_target) then
			entity:InsertSubpipe(0,"morpher_morph_at",morph_target);
		end		
	end,



}