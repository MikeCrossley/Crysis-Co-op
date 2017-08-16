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
AIBehaviour.TrooperAvoidExplosion = {
	Name = "TrooperAvoidExplosion",
	Base = "TrooperDodge",
	alertness = 2,

	---------------------------------------------
	Constructor = function (self, entity,data)
		AI.Signal(SIGNALFILTER_LEADER,10,"OnPause",entity.id);
		if(data and data.id) then 
			entity:InsertSubpipe(0,"tr_backoff_from_explosion",data.id);
			local exploder = System.GetEntity(data.id);
			if(exploder and exploder.RegisterWithExplosion) then 
				exploder:RegisterWithExplosion(entity);
			end
		else
			self:SelectNext(entity);
		end
	end,
	
	Constructor_old = function (self, entity,data)
		local target = AI.GetAttentionTargetEntity(entity.id);
		if(not target) then 
			self:END_DODGE_GRENADE(entity);
			return;
		end
		
		local dodgeDir = g_Vectors.temp;
		local srcPoint = g_Vectors.temp_v3;
		local targetPoint = g_Vectors.temp_v2;
		local targetVel = g_Vectors.temp_v1;
		CopyVector(srcPoint,entity:GetWorldPos());

		target:GetVelocity(targetVel);
		local targetSpeed = LengthVector(targetVel);

		if(targetSpeed >10) then 
			dodgeDir = targetVel;
		else
			AI.GetAttentionTargetPosition(entity.id,targetPoint);
			FastDifferenceVectors(dodgeDir, srcPoint,targetPoint);
		end		
		local norm = LengthVector(dodgeDir);
		
		if(norm==0) then 
			CopyVector(dodgeDir,entity:GetDirectionVector(1));
			norm = 1; --theoretically should be -1
		end
		
		ScaleVectorInPlace(dodgeDir, 8/norm);
		local destPoint = g_Vectors.temp_v1;
		
		FastSumVectors(destPoint, srcPoint, dodgeDir);
		AI.SetRefPointPosition(entity.id,	destPoint);
		srcPoint.z = srcPoint.z+0.4;
		
		for i=1,3 do
			local	hits = Physics.RayWorldIntersection(srcPoint,dodgeDir,10,ent_static+ent_rigid+ent_sleeping_rigid+ent_living ,entity.id,nil,g_HitTable);
			if(hits~=0) then
				self:DODGE0_FAILED(entity,sender);
				return;
			end
			srcPoint.z = srcPoint.z+0.8;
		end
		entity:SelectPipe(0,"tr_dodge0");
		entity:InsertSubpipe(0,"do_it_running");
		entity.AI.Strafe = true;			
	end,

	---------------------------------------------
	Destructor = function (self, entity)
		entity.AI.Strafe = false;			
		AI.Signal(SIGNALFILTER_LEADER,10,"ORD_DONE",entity.id);
		AI.ModifySmartObjectStates(entity.id,"-AvoidExplosion");
	end,
	
	------------------------------------------------------------------------
	DODGE0_FAILED = function(self,entity,sender)
		local navType = AI.GetNavigationType(entity.id);
		if(navType ~= NAV_WAYPOINT_HUMAN and navType ~= NAV_WAYPOINT_3DSURFACE) then 
			g_SignalData.fValue = 4;
		else
			g_SignalData.fValue = 6;
		end
		g_SignalData.iValue = navType;
		AI.GetAttentionTargetPosition(entity.id,g_SignalData.point);
		AIBehaviour.TrooperDodge:Constructor(entity,g_SignalData);
	end,

	------------------------------------------------------------------------
	DODGE2_FAILED = function(self,entity,sender)
		entity:SelectPipe(0,"tr_wait_explosion");
		entity.AI.Strafe = false;			
	end,
	
	------------------------------------------------------------------------
	OnExplosion = function(self,entity,sender)
		self:SelectNext(entity);
	end,
	
	OnPlayerSeen = function(self,entity,distance)
--		if(not entity.AI.Strafe) then 
--			self:SelectNext(entity);		
--		end
	end,
	
	--------------------------------------------------
	OnBulletHit = function( self, entity, sender,data )
	end,

	--------------------------------------------------
	OnPathFound = function(self,entity,sender)
		entity:PlayAccelerationSound();
	end,
	
	------------------------------------------------------------------------
	DODGE_SUCCESSFUL = function(self,entity,sender)
		self:SelectNext(entity);
	end,

	------------------------------------------------------------------------
	END_BACKOFF = function(self,entity,sender)
		self:SelectNext(entity);
	end,
	
	---------------------------------------------
	SelectNext = function(self,entity)
		entity.AI.Strafe = false;		
		if(AI.GetAttentionTargetType(entity.id)==150) then
			entity:SelectPipe(0,"tr_end_dodge_grenade");
			entity:InsertSubpipe(0,"devalue_target");
		else
			self:END_DODGE_GRENADE(entity);
		end
	end,
	
	---------------------------------------------
	OnObjectSeen = function(self,entity,sender,data)
		if ( data.iValue == AIOBJECT_RPG) then
			entity:InsertSubpipe(0,"devalue_target");
		end
	end,
	
	---------------------------------------------
	END_DODGE_GRENADE = function(self,entity)
		if(entity.AI.InSquad ==1) then 
			AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_GROUP_ATTACK",entity.id);
		else
			local targetType = AI.GetTargetType(entity.id);
			if(targetType==AITARGET_ENEMY) then 
				AI.Signal(SIGNALFILTER_SENDER,0,"StickPlayerAndShoot",entity.id);
			else
				AI.Signal(SIGNALFILTER_SENDER,0,"GO_TO_SEARCH",entity.id);
			end
		end
	end,

	--------------------------------------------------
	IS_PLAYER_ENGAGED = function(self,entity,sender)
		if(AI.GetAttentionTargetEntity(entity.id)==g_localActor) then 
			if(AI.GetGroupOf(entity.id) ~= AI.GetGroupOf(sender.id)) then 
				AI.Signal(SIGNALFILTER_GROUPONLY, 0,"PLAYER_ENGAGED",sender.id);
			end
		end
	end,

}
