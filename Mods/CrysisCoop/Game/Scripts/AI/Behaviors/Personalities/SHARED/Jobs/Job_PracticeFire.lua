
-- created by petar
--------------------------


AIBehaviour.Job_PracticeFire = {
	Name = "Job_PracticeFire",				
	JOB = 1,


	---------------------------------------------
	Constructor = function(self,entity )
		entity:InitAIRelaxed();

		local shoot_target = entity:GetName().."_SHOOT";

		-- try to get tagpoint of the same name as yourself first
		local TagPoint = System.GetEntityByName(shoot_target);
 		if (TagPoint==nil) then
			-- try to fish for a observation anhor within 2 meter from yourself
			shoot_target = AI.FindObjectOfType(entity.id,100,AIAnchorTable.SHOOTING_TARGET);
		end

		if (shoot_target) then 
			entity:SelectPipe(0,"practice_shot",shoot_target);	
		else
			AI.Warning( "[AI] Entity "..entity:GetName().." has practice fire job assigned to it but no shooting target.");
		end

		

		entity:InsertSubpipe(0,"setup_idle");
		entity:InsertSubpipe(0,"DRAW_GUN");
	end,

	OnActivate = function(self,entity )
		self:OnSpawn(entity);
	end,

	DO_SOMETHING_SPECIAL = function(self,entity,sender )
		local mounted = AI.FindObjectOfType(entity.id,2,AIOBJECT_MOUNTEDWEAPON);

		if (mounted) then		
	
			entity.gun = System.GetEntityByName(mounted);

			if (entity.gun.user) then	
				do return end
			end

			if (entity.gun) then
				entity.gun:SetGunner( entity );
			end
		end		
	end,


	OnJobExit = function(self,entity,sender )
		if (entity.gun) then
			entity.gun:AbortUse(entity);
		end
	end,


	OnReload = function(self,entity,sender )
		
	end,

	
}


