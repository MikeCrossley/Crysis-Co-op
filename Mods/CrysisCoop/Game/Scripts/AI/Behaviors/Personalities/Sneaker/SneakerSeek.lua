--------------------------------------------------
-- SneakerSeek
--------------------------
--   created: Mikko Mononen 21-6-2006


AIBehaviour.SneakerSeek = {
	Name = "SneakerSeek",
	Base = "SneakerAttack",	
	alertness = 2,

	Constructor = function (self, entity)
		AIBehaviour.Cover2Seek:Constructor(entity);
	end,
	---------------------------------------------
	Destructor = function (self, entity)
		AIBehaviour.Cover2Seek:Destructor(entity);
	end,
}
