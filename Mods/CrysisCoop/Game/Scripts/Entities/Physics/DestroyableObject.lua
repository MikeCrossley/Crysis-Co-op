----------------------------------------------------------------------------------------------------
--  Crytek Source File.
--  Copyright (C), Crytek Studios, 2001-2004.
----------------------------------------------------------------------------------------------------
--  $Id$
--  $DateTime$
--  Description: Destroyable Object Entity
--
----------------------------------------------------------------------------------------------------
--  History:
--  - 16:8:2005   10:38 : Created by Márcio Martins
--
----------------------------------------------------------------------------------------------------
DestroyableObject =
{
	Client = {},
	Server = {},
	States = {"Alive","Dead" },
	
	Properties =
	{
		soclasses_SmartObjectClass = "",
		bAutoGenAIHidePts = 0,

		object_Model 					= "objects/box.cgf",							-- Pre-destroyed model/submodel.
		ModelSubObject				= "Main",
		object_ModelDestroyed	= "",															-- Post-destroyed model/submodel (same as Model if blank).
		DestroyedSubObject		= "Remain",

		bPlayerOnly 			= 1,																	-- Damaged only by player.
		fHealth						= 100,
		fDamageTreshold		= 0,																	-- Only accept damage higher than this value.
		bExplode					= 0,																	-- Create explosion, using Explosion props

		Vulnerability	=
		{
			bExplosion = 1,
			bCollision = 1,
			bMelee		 = 1,
--			bNormal		 = 1,
			bBullet		 = 1,
			bOther	   = 1,
		},
		
		DamageMultipliers = 
		{
		  fCollision = 1.0,
		  fBullet    = 1.0,		  
		},

		Breakage =																							-- => BreakToPieces
		{
			fLifeTime = 10,																					-- Average lifetime of particle pieces
			fExplodeImpulse = 0,																		-- Applies central impulse to pieces, in addition to hit impulse
			bSurfaceEffects = 1,																		-- Generate secondary particle effects from surface type
		},
		
		Explosion =																							-- => Explosion
		{
			Delay 					= 0,																		
			Effect					= "explosions.grenade_air.explosion",
			EffectScale			= 1,
			MinRadius				= 5,
			Radius					= 10,
			MinPhysRadius		= 2.5,
			PhysRadius			= 5,
			Pressure				= 1000,
			Damage					= 1000,
			Decal						= "textures/decal/explo_decal.dds",
			HoleSize				= 10,
			TerrainHoleSize	= 5,
			Direction				= {x=0, y=0, z=1},
			vOffset 				= {x=0, y=0, z=0},
			DelayEffect	=
			{
				bHasDelayEffect = 0,
				Effect					= "",
				vOffset					= {x=0, y=0, z=0},
				vRotation				= {x=0, y=0, z=0},
				Params ={
					SpawnPeriod			= 0,
					Scale						= 1,
					CountScale			= 1,
					bCountPerUnit		= 0,
					bSizePerUnit		= 0,
					AttachType			= "none",
					AttachForm			= "none",
					bPrime					= 0,
				},
			},
		},

		Sounds = {
			sound_Alive = "",
			sound_Dead = "",
			sound_Dying = "",
			fAISoundRadius = 30,
		},
				
		Physics = {																							-- Particle pieces always physicalised as rigid bodies
			bRigidBody=1,																						-- True if rigid body.
			bRigidBodyActive = 1,																		-- If rigid body is originally created (1) OR will be created only on OnActivate (0).
			bRigidBodyAfterDeath = 1,																-- True if rigid body after death too.
			bActivateOnDamage = 0,																	-- Activate when a rocket hit the entity.
			Density = -1,
			Mass = -1,
			bPushableByPlayers = 0,
			bCanBreakOthers = 0,
			Simulation =
			{
				max_time_step = 0.02,
				sleep_speed = 0.04,
				damping = 0,
			},
		},
	},
}

local Physics_DX9MP_Simple = {																							-- Particle pieces always physicalised as rigid bodies
	bRigidBody=0,																						-- True if rigid body.
	bRigidBodyActive = 1,																		-- If rigid body is originally created (1) OR will be created only on OnActivate (0).
	bRigidBodyAfterDeath = 0,																-- True if rigid body after death too.
	bActivateOnDamage = 0,																	-- Activate when a rocket hit the entity.
	Density = -1,
	Mass = -1,
}

MakeUsable(DestroyableObject);
MakePickable(DestroyableObject);

-------------------------------------------------------
function DestroyableObject:OnLoad(table)	
  local wasDead = self.dead;
	self.bTemporaryUsable = table.bTemporaryUsable;
	self.shooterId = table.shooterId;
	self.health = table.health;
	self.dead = table.dead;
	self.FXSlot = table.FXSlot;
	self.exploded = table.exploded;
	self.rigidBodySlot = table.rigidBodySlot;
	self.isRigidBody = table.isRigidBody;
	self.currentSlot = table.currentSlot;
	self.LastHit = table.LastHit;
		
	self:SetCurrentSlot(self.currentSlot);


	if (self.dead) then	
		if (self.Properties.Physics.bRigidBodyAfterDeath == 1) then
			-- temprarolly set bRigidBody to 1, because EntityCommon checks it!
			local aux = self.Properties.Physics.bRigidBody;
			self.Properties.Physics.bRigidBody = 1;
			self:PhysicalizeThis(self.currentSlot);
			self.Properties.Physics.bRigidBody = aux;
		end
	else
		if (string.sub(self:GetName(),1,6)~="Plank_" and string.sub(self:GetName(),1,11)~="Bridge_Knot" or wasDead ~= table.dead) then
			self:PhysicalizeThis(self.currentSlot);
		end	
	end
	
	if (self:GetState() ~= table.state) then
	  self:GotoState(table.state)
	end
end

-------------------------------------------------------
function DestroyableObject:OnSave(table)  	
	table.bTemporaryUsable = self.bTemporaryUsable;
	table.shooterId = self.shooterId;
	table.health = self.health;
	table.FXSlot = self.FXSlot;
	table.dead = self.dead;
	table.exploded = self.exploded;
	table.rigidBodySlot = self.rigidBodySlot;
	table.isRigidBody = self.isRigidBody;
	table.currentSlot = self.currentSlot;
	table.LastHit = self.LastHit;
	table.state = self:GetState();
end

----------------------------------------------------------------------------------------------------
function DestroyableObject:CommonInit()
	self.bReloadGeoms = 1;
	self.bTemporaryUsable=0;
	if (not self.bInitialized) then
		self.LastHit = {
			impulse = {x=0,y=0,z=0},
			pos = {x=0,y=0,z=0},
		};
		self:Reload();
		self.bInitialized = 1;
		self:GotoState( "Alive" );
	end
end

----------------------------------------------------------------------------------------------------
function DestroyableObject.Server:OnInit()
	self:CommonInit();
	self:PreLoadParticleEffect( self.Properties.Explosion.Effect );
end

----------------------------------------------------------------------------------------------------
function DestroyableObject.Client:OnInit()
	self:CommonInit();
end

----------------------------------------------------------------------------------------------------
function DestroyableObject:OnPropertyChange()
	self.bReloadGeoms = 1;
	self:Reload();
end


----------------------------------------------------------------------------------------------------
function DestroyableObject:OnShutDown()
end

----------------------------------------------------------------------------------------------------
function DestroyableObject:CanShatter()
	return false;
end

----------------------------------------------------------------------------------------------------
function DestroyableObject:OnReset()
	self:RemoveEffect();
	if(self.timerShooterId)then
		--Log("self.timerShooterId: "..self.timerShooterId);
	end;
	
	if (self:GetState() ~= "Alive") then
		self:Reload();
	end
	self:AwakePhysics(0);
end

----------------------------------------------------------------------------------------------------
function DestroyableObject:RemoveEffect()
	if(self.FXSlot)then
		self:FreeSlot(self.FXSlot);
		self.FXSlot= -1;
	end;
end;

----------------------------------------------------------------------------------------------------
function DestroyableObject:Reload()
	self:ResetOnUsed();
	local props = self.Properties;
	self.bTemporaryUsable=self.Properties.bUsable;
	self.shooterId = NULL_ENTITY;
	self.health = props.fHealth;
	self.dead = nil;
	self.exploded = nil;
	self.rigidBodySlot = nil;
	self.isRigidBody = nil;

	if (self.bReloadGeoms == 1) then
		if (not EmptyString(props.object_Model)) then
			self:LoadObject(3,props.object_Model); -- First load whole object in slot 3.
			self:DrawSlot(3,0); -- Make it invisible
			self:LoadSubObject(0,props.object_Model, props.ModelSubObject);
		end
	
		if (not EmptyString(props.object_ModelDestroyed)) then
			self:LoadSubObject(1, props.object_ModelDestroyed, props.DestroyedSubObject);
		elseif (not EmptyString(props.DestroyedSubObject)) then
			self:LoadSubObject(1, props.object_Model, props.DestroyedSubObject);
		end
		
		self:SetCurrentSlot(0);
		self:PhysicalizeThis(0);
	end
	
	-- stop old sounds
	self:StopAllSounds();
	self.bReloadGeoms = 0;
	self:GotoState( "Alive" );
	
		-- Mark AI hideable flag.
	if (props.bAutoGenAIHidePts == 1) then
		self:SetFlags(ENTITY_FLAG_AI_HIDEABLE, 0); -- set
	else
		self:SetFlags(ENTITY_FLAG_AI_HIDEABLE, 2); -- remove
	end
	

end

------------------------------------------------------------------------------------------------------
function DestroyableObject:PhysicalizeThis( nSlot )
	local Physics = self.Properties.Physics;
	if (CryAction.IsImmersivenessEnabled() == 0) then
		Physics = Physics_DX9MP_Simple;
	end
	-- Init physics.
	EntityCommon.PhysicalizeRigid( self,nSlot,Physics,self.bRigidBodyActive );
end

----------------------------------------------------------------------------------------------------
function DestroyableObject:SetCurrentSlot(slot)
	if (slot == 0) then
		self:DrawSlot(0, 1);
		self:DrawSlot(1, 0);
	else
		self:DrawSlot(0, 0);
		self:DrawSlot(1, 1);
	end
	self.currentSlot = slot;
end

----------------------------------------------------------------------------------------------------
function DestroyableObject:Explode()
	if (CryAction.IsImmersivenessEnabled() == 0) then
		return;
	end

	local Properties = self.Properties;
	self.bTemporaryUsable=0;
	self.bReloadGeoms = 1;
	
	local hitPos = self.LastHit.pos;
	local hitImp = self.LastHit.impulse;
		
	self:BreakToPieces( 
		0, 0,
		Properties.Breakage.fExplodeImpulse,
		hitPos,
		hitImp,
		Properties.Breakage.fLifeTime, 
		Properties.Breakage.bSurfaceEffects
	);
	
	self:RemoveDecals();
	local bDeleteEntity = false;
		
	self:SetCurrentSlot(1);
	
	if (Properties.object_ModelDestroyed ~="" or Properties.DestroyedSubObject ~="") then
		if (Properties.Physics.bRigidBodyAfterDeath == 1) then
			-- temprarolly set bRigidBody to 1, because EntityCommon checks it!
			local aux = Properties.Physics.bRigidBody;
			Properties.Physics.bRigidBody = 1;
			self:PhysicalizeThis(1);
			Properties.Physics.bRigidBody = aux;
			self:AwakePhysics(1);
		else
			self:PhysicalizeThis(1);
			self:AwakePhysics(1);
		end	
	else
		-- if No destroyed model, this entity must be killed.
		bDeleteEntity = true;
	end

	
	if (NumberToBool(self.Properties.bExplode)) then
		local expl = self.Properties.Explosion;
		
		local pos = self:GetWorldPos();
		local dirX = self:GetDirectionVector(0);
		local dirY = self:GetDirectionVector(1);
		local dirZ = self:GetDirectionVector(2);
		local offset={x=0,y=0,z=0};
		CopyVector(offset,expl.vOffset);
		
		pos.x = pos.x + dirX.x * offset.x + dirY.x * offset.y + dirZ.x * offset.z;
		pos.y = pos.y + dirX.y * offset.x + dirY.y * offset.y + dirZ.y * offset.z;
		pos.z = pos.z + dirX.z * offset.x + dirY.z * offset.y + dirZ.z * offset.z;
		local explo_pos=pos;
		g_gameRules:CreateExplosion(self.shooterId,self.id,expl.Damage,explo_pos,expl.Direction,expl.Radius,nil,expl.Pressure,expl.HoleSize,expl.Effect,expl.EffectScale, expl.MinRadius, expl.MinPhysRadius, expl.PhysRadius);
	end
	
	-- play the dead sound after explosion
	if (self.dead ~= true) then
		self:PlaySoundEvent(self.Properties.Sounds.sound_Dying,g_Vectors.v000,g_Vectors.v001,0,SOUND_SEMANTIC_MECHANIC_ENTITY);
	end
	self:PlaySoundEvent(self.Properties.Sounds.sound_Dead,g_Vectors.v000,g_Vectors.v001,0,SOUND_SEMANTIC_MECHANIC_ENTITY);
	
	self.exploded = true;
	
	-- ai sound event	
	local aiRadius = self.Properties.Sounds.fAISoundRadius;
	if (aiRadius > 0) then
		if(self.shooterId) then
			AI.SoundEvent(self:GetWorldPos(), aiRadius, AISE_EXPLOSION, self.shooterId);
		else
			Log("AI.SoundEvent invalid parameter self.shooterId");
		end
	end
	BroadcastEvent( self,"Explode" );
	
	-- Must be in the last line.
	if (bDeleteEntity == true) then
		--self:DeleteThis();
		self:Hide(1);
	end
end


----------------------------------------------------------------------------------------------------
function DestroyableObject:Die(shooterId)
	self.shooterId = shooterId;
	self.dead = true;
	if (self.health > 0) then
		self.health = 0;
	end
	
	self:PlaySoundEvent(self.Properties.Sounds.sound_Dying,g_Vectors.v000,g_Vectors.v001,0,SOUND_SEMANTIC_MECHANIC_ENTITY);

	-- if we didn't explode yet
	if (not self.exploded) then
		local explosion=self.Properties.Explosion;
		if(explosion.Delay>0 and not explosion.DelayEffect.bHasDelayEffect==1)then
			self:SetTimer(0,explosion.Delay*1000);
		else
			self:GotoState("Dead");
		end
	end
end

----------------------------------------------------------------------------------------------------
function DestroyableObject:IsDead()
	return (self.health <= 0) or self.dead == true;
end

----------------------------------------------------------------------------------------------------
function DestroyableObject:GetHealth()
  return self.health;
end

----------------------------------------------------------------------------------------------------
function DestroyableObject.Server:OnHit(hit)
	if (hit.dir) then
		self:AddImpulse(hit.partId or -1,hit.pos,hit.dir, hit.damage, 1);
	end
		
	CopyVector(self.LastHit.pos, hit.pos);
	CopyVector(self.LastHit.impulse, hit.dir or g_Vectors.v000);
	self.LastHit.impulse.x = self.LastHit.impulse.x * hit.damage;
	self.LastHit.impulse.y = self.LastHit.impulse.y * hit.damage;
	self.LastHit.impulse.z = self.LastHit.impulse.z * hit.damage;
	
	local damage = hit.damage;	
	local vul = self.Properties.Vulnerability;
	local mult = self.Properties.DamageMultipliers;
	
	local pass = true;
	if (hit.explosion) then pass = NumberToBool(vul.bExplosion);
	elseif (hit.type=="collision") then pass = NumberToBool(vul.bCollision); damage = damage * mult.fCollision;
	elseif (hit.type=="bullet") then pass = NumberToBool(vul.bBullet); damage = damage * mult.fBullet;
	elseif (hit.type=="melee") then pass = NumberToBool(vul.bMelee); 
	else pass = NumberToBool(vul.bOther); end	
	
	pass = pass and damage > self.Properties.fDamageTreshold;	-- damage needs to be higher than treshold
	--Log("%s != %s", tostring(hit.shooterId), tostring(g_localActorId));
	
	if (pass and NumberToBool(self.Properties.bPlayerOnly) and (hit.shooterId and (not hit.shooter.actor:IsPlayer())) then -- damage must come from player
		pass=false;
	end
	
	BroadcastEvent( self,"Hit" );

	if (pass) then
		self.health = self.health - damage;
	
		if (self.health <= 0) then
			self:Die(hit.shooterId);
		end
		
		if (NumberToBool(self.Properties.bActivateOnDamage)) then
			self:AwakePhysics(1);
		end		
		local explosion=self.Properties.Explosion;
		if(explosion.DelayEffect.bHasDelayEffect==1)then
			if(not self.FXSlot or self.FXSlot==(-1))then
				local rnd=randomF(0,1.5)
				--Log("Setting Delay on "..self:GetName()..": "..explosion.Delay+rnd);
				self:SetTimer(0,(explosion.Delay+rnd)*1000);
				if(not EmptyString(explosion.DelayEffect.Effect))then
					self.FXSlot=self:LoadParticleEffect( -1,explosion.DelayEffect.Effect,explosion.DelayEffect.Params);
					if (self.FXSlot) then
						self:SetSlotPos(self.FXSlot,explosion.DelayEffect.vOffset);
						self:SetSlotAngles(self.FXSlot,explosion.DelayEffect.vRotation);
					end
				end;
			end;
		end;
	end
	
	return (self.health <= 0);
end


----------------------------------------------------------------------------------------------------
function DestroyableObject.Server:OnTimer(timerId, msec)
	if (timerId == 0) then
		self:GotoState("Dead");
	end
end

----------------------------------------------------------------------------------------------------
-- Alive State
----------------------------------------------------------------------------------------------------
DestroyableObject.Client.Alive =
{
	OnBeginState=function(self)
		self:PlaySoundEvent(self.Properties.Sounds.sound_Alive,g_Vectors.v000,g_Vectors.v001,0,SOUND_SEMANTIC_MECHANIC_ENTITY);
	end,
}
DestroyableObject.Server.Alive =
{
	OnTimer = function(self,timerId,msec)
		if (timerId == 0) then
			self:GotoState( "Dead" );
		end
	end,
}

----------------------------------------------------------------------------------------------------
-- Dead State
----------------------------------------------------------------------------------------------------
DestroyableObject.Client.Dead =
{
	OnBeginState=function(self)
		self:StopAllSounds();
		if (not CryAction.IsServer()) then
			self:RemoveEffect();
			self:Explode();
			self.dead = true;	
		end
	end,
}
DestroyableObject.Server.Dead =
{
	OnBeginState=function(self)
		self:RemoveEffect();
		self:Explode();
		self.dead = true;
	end,
}

----------------------------------------------------------------------------------------------------
function DestroyableObject:Event_Reset( sender )
	self:OnReset();
	BroadcastEvent( self,"Reset" );
end

----------------------------------------------------------------------------------------------------
function DestroyableObject:Event_Hit( sender )
	BroadcastEvent( self,"Hit" );
end

----------------------------------------------------------------------------------------------------
function DestroyableObject:Event_Explode( sender )
	if self:GetState()=="Dead" then return end
	if self.exploded then return end

	BroadcastEvent( self,"Explode" );
	BroadcastEvent( self, "Break" )

	self:Die(NULL_ENTITY);
end

function DestroyableObject:OnUsed(user, idx)
	if idx == 2 then
		BroadcastEvent(self, "Used")
	end
end

------------------------------------------------------------------------------------------------------
function DestroyableObject.Client:OnPhysicsBreak( vPos,nPartId,nOtherPartId )
	self:ActivateOutput("Break",nPartId+1 );
end

----------------------------------------------------------------------------------------------------
function DestroyableObject:IsUsable(user)

	local ret = nil
	if (self.Properties.bUsable == 1 and self.bTemporaryUsable == 1) then
		ret = 2
	else
		local PhysProps = self.Properties.Physics;
		if (PhysProps.bRigidBody == 1 and PhysProps.bRigidBodyActive == 1 and user.CanGrabObject) then
			ret = user:CanGrabObject(self);
		end
	end
		
	return ret or 0
end

function DestroyableObject:GetUsableMessage(idx)
	if (self.Properties.bUsable == 1 and self.bTemporaryUsable == 1) then
		return self.Properties.UseText;
	else
		return "@grab_object";
	end;
end

------------------------------------------------------------------------------------------------------
function DestroyableObject:Event_Hide()
	self:Hide(1);
	BroadcastEvent( self, "Hide" );
	--self:DrawObject(0,0);
	--self:DestroyPhysics();
end

------------------------------------------------------------------------------------------------------
function DestroyableObject:Event_UnHide()
	self:Hide(0);
	BroadcastEvent( self, "UnHide" );
	--self:DrawObject(0,1);
	--self:SetPhysicsProperties( 1,self.bRigidBodyActive );
end

DestroyableObject.FlowEvents =
{
	Inputs =
	{
		Explode = { DestroyableObject.Event_Explode, "bool" },
		Reset = { DestroyableObject.Event_Reset, "bool" },
		Used = { DestroyableObject.Event_Used, "bool" },
		EnableUsable = { DestroyableObject.Event_EnableUsable, "bool" },
		DisableUsable = { DestroyableObject.Event_DisableUsable, "bool" },
		Hit = { DestroyableObject.Event_Hit, "bool" },
		Hide = { DestroyableObject.Event_Hide, "bool" },
		UnHide = { DestroyableObject.Event_UnHide, "bool" },
	},
	Outputs =
	{
		Explode = "bool",
		Reset = "bool",
		Used = "bool",
		EnableUsable = "bool",
		DisableUsable = "bool",
		Hit = "bool",
		Hide = "bool",
		UnHide = "bool",
		Break = "int",
	},
}
