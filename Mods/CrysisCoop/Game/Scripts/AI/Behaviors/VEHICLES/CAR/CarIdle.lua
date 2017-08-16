

AIBehaviour.CarIdle = {

	Name = "CarIdle",
	Base = "VehicleIdle",		

	---------------------------------------------
	Constructor = function(self , entity )

		AIBehaviour.VehicleIdle:Constructor( entity );
		AI.SetAdjustPath(entity.id,1);

		AI.ChangeParameter(entity.id,AIPARAM_SIGHTENVSCALE_NORMAL,1);
		AI.ChangeParameter(entity.id,AIPARAM_SIGHTENVSCALE_ALARMED,1);

	end,

	TO_CAR_SKID = function( self, entity, sender, data )

		AI.LogEvent(entity:GetName().." CAR_SKID"..data.point.x..","..data.point.y..","..data.point.z);
		entity.AI.vSkidDestination = {};
		CopyVector( entity.AI.vSkidDestination, data.point );

	end,

}
