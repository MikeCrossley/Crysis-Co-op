-- carrY box between AIANCHOR_PICKUP and AIANCHOR_PUTDOWN anchors, 
-- crates need to be entity/other/AICrate
-- Created 2002-11-28 Amanda
--------------------------
AIBehaviour.Job_CarryBox = {
	Name = "Job_CarryBox",

	point_one = AIAnchorTable.AIANCHOR_PICKUP,
	point_two = AIAnchorTable.AIANCHOR_PUTDOWN,

	JOB = 1,
	------------------------------------------------------------------------ 	
	Constructor = function(self,entity)	
		entity:InitAIRelaxed();
		entity.AI_Carrying = nil;
		self:FIND_PICKUP(entity);
		entity:InsertSubpipe(0,"setup_idle");	
		--entity:LoadObject("Objects/Indoor/boxes/crates/crateCarry.cgf",1,1); -- filename, slot, scale
		--entity:DrawObject(1,0);
	end,
	------------------------------------------------------------------------ 	
	OnJobExit = function( self, entity )
		
		if (entity.AI_Carrying) then
			entity.AI_Carrying:DrawObject(0,1);
			entity:DetachObjectToBone("weapon_bone");
			local entpos = entity:GetPos();
			entpos.z=entpos.z+1;
			entpos.x=entpos.x+1;
			entity.AI_Carrying:SetPos(entpos);
			entity.AI_Carrying:AwakePhysics(1);
			entity.cnt:HoldGun();
			entity.cnt:HolsterGun();
			entity.cnt:HoldGun();
		
		end
		entity:DrawObject(1,0);
	end,

	START_PICKUP_ANIM = function( self, entity )
		if (AI.FindObjectOfType(entity:GetPos(),5,AIAnchorTable.AIOBJECT_CARRY_CRATE)) then
			entity:StartAnimation(0,"box_pickup",4);
			entity:StartAnimation(0,"box_carry",3);
		end
	end,

	START_PUTDOWN_ANIM = function( self, entity )
		entity:StartAnimation(0,"box_putdown",4);
		entity:StartAnimation(0,"NULL",3);
	end,


 	FIND_PICKUP = function(self,entity,sender)

		if (entity.AI_Carrying) then
			entity.AI_Carrying:DrawObject(0,1);
			entity:DetachObjectToBone("weapon_bone");
			local entpos = entity:GetPos();
			entpos.z=entpos.z+1;
			entpos.x=entpos.x+1;
			entity.AI_Carrying:SetPos(entpos);
			entity.AI_Carrying:AwakePhysics(1);
		end

		local pickup_point = AI.FindObjectOfType(entity:GetPos(),130,self.point_one);
		if (pickup_point) then
			entity:SelectPipe(0,"job_pickup_crate",pickup_point);
		else
			AI.Warning( "[AI] "..entity:GetName().." has a carry box behaviour but no pickup point");
		end

	end,


 	BIND_CRATE_TO_ME = function(self,entity,sender)
		local crate = AI.FindObjectOfType(entity:GetPos(),5,AIAnchorTable.AIOBJECT_CARRY_CRATE);		
		if (crate) then

			entity.AI_Carrying = System.GetEntityByName(crate);
			if (entity.AI_Carrying) then
				entity:AttachToBone(entity.AI_Carrying,"weapon_bone");
				entity.AI_Carrying:DrawObject(0,0);
			end



			local drop_point = AI.FindObjectOfType(entity:GetPos(),130,self.point_two);	
			if (drop_point)	then
				entity:SelectPipe(0,"job_drop_crate",drop_point);
			else
				AI.Warning( "[AI] "..entity:GetName().." has a carry box behaviour but no drop point");
			end
		else
			AI.Warning( "[AI] "..entity:GetName().." bounced");
			entity:StartAnimation(0,"NULL",3);
			local pttemp = self.point_one;
			self.point_one = self.point_two;
			self.point_two = pttemp;
			self:OnSpawn(entity);
		end
	end,

}

 