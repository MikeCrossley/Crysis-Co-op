--------------------------------------------------
--    Created By: Luciano Morpurgo
--   Description: Trooper group fire behaviour - 
--		the trooper just tries to fire,and doesn't move/strafe if not requested
--------------------------
--

AIBehaviour.TrooperGroupFire = {
	Name = "TrooperGroupFire",
	Base = "TrooperGroupCombat",
	alertness = 2,

	Constructor = function ( self, entity )
	
		entity:Cloak(0);
		-- Avoid possible obstacles when the point is reached
		entity:SelectPipe(0,"tr_just_shoot");
		
		AI.Signal(SIGNALFILTER_LEADER,10,"ORD_DONE",entity.id);
		entity:MakeAlerted();
	end,

	---------------------------------------------
	Destructor = function(self,entity)
	end,

	---------------------------------------------
	OnFriendInWay = function(self,entity,sender,data)
	end,
		
}