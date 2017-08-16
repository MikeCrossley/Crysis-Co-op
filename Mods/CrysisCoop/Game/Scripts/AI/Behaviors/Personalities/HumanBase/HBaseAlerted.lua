--------------------------------------------------
--    Created By: kirill
--   Description: same as idle, but draw weapon go crouch and look around 
--------------------------
--

AIBehaviour.HBaseAlerted = {
	Name = "HBaseAlerted",
	Base = "Cover2Idle",
	alertness = 1,

	-----------------------------------------------------
	Constructor = function(self,entity)
		entity:GettingAlerted();
		
		entity:SelectPipe(0,"random_look_around");
		
	end,
	
	-----------------------------------------------------
	Destructor = function(self,entity)
	end,

	-----------------------------------------------------
	--------------------------------------------------
}