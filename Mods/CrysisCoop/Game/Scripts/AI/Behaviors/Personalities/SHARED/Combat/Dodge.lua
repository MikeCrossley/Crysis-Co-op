--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Trooper Dodges shoots, ignore all other events while doing it. 
--  
--------------------------------------------------------------------------
--  History:
--  - 12/1/2006     : Created by Luciano Morpurgo
--
--------------------------------------------------------------------------
AIBehaviour.Dodge = {
	Name = "Dodge",
	alertness = 2,

	---------------------------------------------
	Constructor = function (self, entity,data)
		local range = data.fValue;
		if(range == nil or range==0) then 
			range = 1;
		end
		local navType = data.iValue;
		local dodgeDir = g_Vectors.temp;
		local srcPoint = g_Vectors.temp_v3;
		
		CopyVector(srcPoint,entity:GetWorldPos());

		if(IsNullVector(data.point)) then 
			if(AI.GetTargetType(entity.id)~=AITARGET_NONE) then 
				AI.GetAttentionTargetPosition(entity.id,g_Vectors.temp_v2);
				FastDifferenceVectors(dodgeDir, g_Vectors.temp_v2,srcPoint);
			else
				CopyVector(dodgeDir,entity:GetDirectionVector(1));
			end
		else
			FastDifferenceVectors(dodgeDir, data.point,srcPoint);
		end
		
		if(random(1,2)==1) then 
			VecRotate90_Z(dodgeDir);
		else			
			VecRotateMinus90_Z(dodgeDir);
		end
		
		local norm = LengthVector(dodgeDir);
		dodgeDir.x = dodgeDir.x + norm*(math.random()*0.5-0.25);
		dodgeDir.y = dodgeDir.y + norm*(math.random()*0.5-0.25);
		
		if(norm>0) then 
			ScaleVectorInPlace(dodgeDir, range/norm);
			local destPoint = g_Vectors.temp_v1;
			
			FastSumVectors(destPoint, srcPoint, dodgeDir);
			AI.SetRefPointPosition(entity.id,	destPoint);
			srcPoint.z = srcPoint.z+0.2;
			
			for i=1,3 do
				local	hits = Physics.RayWorldIntersection(srcPoint,dodgeDir,10,ent_static+ent_rigid+ent_sleeping_rigid+ent_living ,entity.id,nil,g_HitTable);
				if(hits~=0) then
					self:DODGE1_FAILED(entity,sender);
					return;
				end
				srcPoint.z = srcPoint.z+0.8;
			end
			entity:SelectPipe(0,"tr_dodge1");
			entity:InsertSubpipe(0,"do_it_sprinting");
			
		end		
	end,

	---------------------------------------------
	Destructor = function (self, entity)
	end,
	---------------------------------------------
	OnEnemyDamage = function(self,entity,sender,data)
--		local shooter = System.GetEntity(data.id);
--		System.Log(entity:GetName().." TROOPERDODGE ON ENEMY DAMAGE");
--		if(AIBehaviour.TROOPERDEFAULT:ReevaluateShooterTarget(entity,shooter)) then 
--			if(entity.AI.InSquad ==1) then 
--				AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_GROUP_ATTACK",entity.id);
--			else
--				AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_ATTACK",entity.id);
--			end
--		end
	end,
	
	---------------------------------------------
	DODGE_SUCCESSFUL = function(self,entity,sender)
	end,
	---------------------------------------------
	DODGE2_FAILED = function(self,entity,sender)
	end,
	
	------------------------------------------------------------------------
	DODGE1_FAILED = function(self,entity,sender)
		local dodgeDir = g_Vectors.temp;
		local srcPoint = g_Vectors.temp_v3;
		CopyVector(srcPoint,entity:GetWorldPos());
		FastDifferenceVectors(dodgeDir, AI.GetRefPointPosition(entity.id),srcPoint);
		dodgeDir.x = -dodgeDir.x;
		dodgeDir.y = -dodgeDir.y;
		dodgeDir.z = -dodgeDir.z;
		FastSumVectors(g_Vectors.temp_v1, srcPoint, dodgeDir);
		AI.SetRefPointPosition(entity.id,	g_Vectors.temp_v1);
		srcPoint.z = srcPoint.z+0.2;
		for i=1,3 do
			local	hits = Physics.RayWorldIntersection(srcPoint,dodgeDir,10,ent_static+ent_rigid+ent_sleeping_rigid+ent_living ,entity.id,nil,g_HitTable);
			if(hits~=0) then
				AI.Signal(SIGNALFILTER_SENDER,1,"DODGE2_FAILED", entity.id);
				return;
			end
			srcPoint.z = srcPoint.z+0.8;
		end
		entity:SelectPipe(0,"tr_dodge2");
		local navType = AI.GetNavigationType(entity.id);
		if(navType ~= NAV_WAYPOINT_HUMAN and navType ~= NAV_WAYPOINT_3DSURFACE) then 
			entity:InsertSubpipe(0,"do_it_running");
		else
			entity:InsertSubpipe(0,"do_it_walking");
		end
	end,
	
	---------------------------------------------
	OnNoTarget = function( self, entity )
	
		--AI.Signal(SIGNALFILTER_GROUPONLY, 1, "GunnerLostTarget",entity.id);
		
		--AI.LogEvent("\001 gunner in vehicle lost target ");
		-- caLled when the enemy stops having an attention target
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )
		if(entity.AI.InSquad ~=1) then 	
			entity:TriggerEvent(AIEVENT_DROPBEACON);
		end
		-- called when the enemy sees a living player
	end,

	---------------------------------------------
	OnSeenByEnemy = function( self, entity )
		
	end,

	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the enemy can no longer see its foe, but remembers where it saw it last
		if(entity.AI.InSquad ~=1) then 	
			entity:TriggerEvent(AIEVENT_DROPBEACON);
		end
	end,
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		-- called when the enemy hears an interesting sound
		if(entity.AI.InSquad ~=1) then 	
			entity:TriggerEvent(AIEVENT_DROPBEACON);
		end
	end,
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
		-- called when the enemy hears a scary sound
		if(entity.AI.InSquad ~=1) then 	
			entity:TriggerEvent(AIEVENT_DROPBEACON);
		end
	end,
	---------------------------------------------
	OnReload = function( self, entity )
		-- called when the enemy goes into automatic reload after its clip is empty
	end,
	---------------------------------------------
	OnGroupMemberDied = function( self, entity )
		-- called when a member of the group dies
	end,
	OnGroupMemberDiedNearest = function ( self, entity, sender)
	end,
	---------------------------------------------
	OnNoHidingPlace = function( self, entity, sender )
		-- called when no hiding place can be found with the specified parameters
	end,	
	--------------------------------------------------
	OnNoFormationPoint = function ( self, entity, sender)
		-- called when the enemy found no formation point
	end,
	---------------------------------------------
	OnReceivingDamage = function ( self, entity, sender)
		-- called when the enemy is damaged
	end,
	---------------------------------------------
	OnCoverRequested = function ( self, entity, sender)
		-- called when the enemy is damaged
	end,
	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender)
		-- called when the enemy detects bullet trails around him
	end,
	--------------------------------------------------
	OnDeath = function( self,entity )

	end,
}
