--------------------------------------------------
-- SneakerAttack
--------------------------
--   created: Mikko Mononen 21-6-2006


AIBehaviour.SneakerAttack = {
	Name = "SneakerAttack",
	Base = "Cover2Attack",
	alertness = 2,

	Constructor = function (self, entity)
		AIBehaviour.Cover2Attack:Constructor(entity);
	end,
	---------------------------------------------
	Destructor = function (self, entity)
		AIBehaviour.Cover2Attack:Destructor(entity);
	end,


}
