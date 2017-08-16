AIBehaviour.HostageTied = {
	Name = "HostageTied",
	
	Constructor = function(self,entity)
		entity:StartAnimation(0,"hostage_idleSit_01",6,0.5,1.0,true);
		entity.isFree = false;
	end,
	
	GET_UNTIED = function(self,entity,sender)
		entity:StartAnimation(0,"hostage_sitToStand_01",6);
		entity:SetAnimationStartEndEvents(0, "hostage_sitToStand_01", nil,AIBehaviour.HostageTied.AnimEnd)
	end,
	
	AnimEnd = function(entity,timerId)
		entity:StopAnimation(0,6);
		entity:Event_Follow(g_localActor);
	end,
}
