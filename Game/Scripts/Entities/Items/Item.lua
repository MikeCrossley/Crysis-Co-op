Item = {
	Properties={
		bPickable = 0,
		bPhysics = 0,
		bMounted = 0,
		bUsable = 0,
		HitPoints = 0,
		soclasses_SmartObjectClass = "",
		initialSetup = "",
	},
	
	Client = {},
	Server = {},
	
	Editor={
		Icon = "Item.bmp",
		IconOnTop=1,
	},
}


----------------------------------------------------------------------------------------------------
function Item:OnPropertyChange()
	self.item:Reset();
	
	if (self.OnReset) then
		self:OnReset();
	end
end


----------------------------------------------------------------------------------------------------
function Item:IsUsable(user)
	--if (self.item:CanPickUp(user.id) or self.item:CanUse(user.id)) then
	local mp = System.IsMultiplayer();
	if(mp and mp~=0 and (self.item:CanPickUp(user.id) or self.item:CanUse(user.id))) then
		return 1;
	elseif (((not mp) or mp==0) and self.item:CanUse(user.id)) then
		return 1;
	else
		return 0;
	end
end


----------------------------------------------------------------------------------------------------
function Item:GetUsableMessage()
	if (self.item:IsMounted()) then
		return "@use_mounted";
	else
		return "";
	--	return string.format("Press USE to pickup the %s!", self.class); --localization done in C++
	end
end


----------------------------------------------------------------------------------------------------
function Item:OnUsed(user)
	return self.item:OnUsed(user.id);
end

----------------------------------------------------------------------------------------------------
function Item:GetHealth()
	return self.item:GetHealth();
end

----------------------------------------------------------------------------------------------------
function Item:GetMaxHealth()
	return self.item:GetMaxHealth();
end


----------------------------------------------------------------------------------------------------
function Item:OnFreeze(shooterId, weaponId, value)
	if ((not g_gameRules:IsMultiplayer()) or g_gameRules.game:GetTeam(shooterId)~=g_gameRules.game:GetTeam(self.id)) then
		return true;
	end
	return false;
end

----------------------------------------------------------------------------------------------------
function Item.Server:OnHit(hit)
	local explosionOnly=tonumber(self.Properties.bExplosionOnly or 0)~=0;
  local hitpoints = self.Properties.HitPoints;
  
	if (hitpoints and (hitpoints > 0)) then
		local destroyed=self.item:IsDestroyed()
		if (hit.type=="repair") then
			self.item:OnHit(hit);
		elseif ((not explosionOnly) or (hit.explosion)) then
			if ((not g_gameRules:IsMultiplayer()) or g_gameRules.game:GetTeam(hit.shooterId)~=g_gameRules.game:GetTeam(self.id)) then	
				--patch1 hack: to compensate for decreased law damage
				--should have some kind of multiplier table per damage type
				--this will suffice for the time being
				if (hit.type=="law_rocket") then
					hit.damage=hit.damage*2.0;
				end

				self.item:OnHit(hit);
				if (not destroyed) then
					if (hit.damage>0) then
						if (g_gameRules.Server.OnTurretHit) then
							g_gameRules.Server.OnTurretHit(g_gameRules, self, hit);
						end
					end
				
					if (self.item:IsDestroyed()) then
						if(self.FlowEvents and self.FlowEvents.Outputs.Destroyed)then
							self:ActivateOutput("Destroyed",1);
						end
					end
				end
			end
		end
	end
end

----------------------------------------------------------------------------------------------------
function Item.Server:OnShattered(hit)
	g_gameRules.Server.OnTurretHit(g_gameRules, self, hit);
end

------------------------------------------------------------------------------------------------------
function Item:Event_Hide()
	self:Hide(1);
	self:ActivateOutput( "Hide", true );
end

------------------------------------------------------------------------------------------------------
function Item:Event_UnHide()
	self:Hide(0);
	self:ActivateOutput( "UnHide", true );
end

------------------------------------------------------------------------------------------------------
Item.FlowEvents =
{
	Inputs =
	{
		Hide = { Item.Event_Hide, "bool" },
		UnHide = { Item.Event_UnHide, "bool" },
	},
	Outputs =
	{
		Hide = "bool",
		UnHide = "bool",
	},
}

----------------------------------------------------------------------------------------------------
function MakeRespawnable(entity)
	if (entity.Properties) then
		entity.Properties.Respawn={
			nTimer=30,
			bUnique=0,
			bRespawn=0,
		};
	end
end


----------------------------------------------------------------------------------------------------
function CreateItemTable(name)
	if (not _G[name]) then
		_G[name] = new(Item);
	end
	MakeRespawnable(_G[name]);
end


----------------------------------------------------------------------------------------------------
CreateItemTable("CustomAmmoPickup");
CustomAmmoPickup.Properties.objModel="";
CustomAmmoPickup.Properties.bMounted=nil;
CustomAmmoPickup.Properties.HitPoints=nil;
CustomAmmoPickup.Properties.AmmoName="bullet";
CustomAmmoPickup.Properties.Count=30;


----------------------------------------------------------------------------------------------------
CreateItemTable("ShiTen");

ShiTen.Properties.bMounted=1;
ShiTen.Properties.bUsable=1;
ShiTen.Properties.MountedLimits = {
			pitchMin = -22,
			pitchMax = 60,
			yaw = 70,
			};


-----------------------------------------------------------------------------------------------------
function ShiTen:OnReset()
	self.item:SetMountedAngleLimits( self.Properties.MountedLimits.pitchMin,
																	self.Properties.MountedLimits.pitchMax,
																	self.Properties.MountedLimits.yaw	);
end

----------------------------------------------------------------------------------------------------
function ShiTen:OnSpawn()
	self:OnReset();
end


----------------------------------------------------------------------------------------------------
function ShiTen:OnUsed(user)
	if (user.actor:IsPlayer()) then
		Item.OnUsed(self, user);
	else
		g_SignalData.id = self.id;
		AI.Signal(SIGNALFILTER_SENDER,0,"USE_MOUNTED_WEAPON_INIT",user.id,g_SignalData);
	end
end

----------------------------------------------------------------------------------------------------
function CreateTurret(name)
	CreateItemTable(name);	
	
	local Turret = _G[name];
	
	Turret.Properties.species = 0;	
	Turret.Properties.teamName = "";
	Turret.Properties.GunTurret = 
	{
		bSurveillance = 1,
		bVehiclesOnly = 0,
		bAirVehiclesOnly = 0,
		bEnabled = 1,
		bSearching = 0,
		bSearchOnly = 0,
		MGRange = 50,
		RocketRange = 50,
		TACDetectRange = 300,
		TurnSpeed = 1.5,
		SearchSpeed = 0.5,
		UpdateTargetTime = 2.0,
		AbandonTargetTime = 0.5,
		TACCheckTime = 0.2,
		YawRange = 360,
		MinPitch = -45,
		MaxPitch = 45,
		AimTolerance = 20,
		Prediction = 1,
		BurstTime = 0.0,
		BurstPause = 0.0,
		SweepTime = 0.0,
		LightFOV = 0.0,
		bFindCloaked = 1,
		bExplosionOnly = 0,
	};
	
	Turret.Server.OnInit = function(self)
		self:OnReset();
	end;
	
	Turret.OnReset = function(self)
		local teamId=g_gameRules.game:GetTeamId(self.Properties.teamName) or 0;
		g_gameRules.game:SetTeam(teamId, self.id);
	end;

	Turret.Properties.objModel="";
	Turret.Properties.objBarrel="";
  Turret.Properties.objBase="";
  Turret.Properties.objDestroyed="";
  
  Turret.Properties.bUsable=nil;
  Turret.Properties.bPickable=nil;
		
  Turret.Event_EnableTurret = function(self)
    self.Properties.GunTurret.bEnabled=1; 
  end;  
  Turret.Event_DisableTurret = function(self)
    self.Properties.GunTurret.bEnabled=0; 
  end;
  
  Turret.FlowEvents.Inputs.EnableTurret = { Turret.Event_EnableTurret, "bool" };
  Turret.FlowEvents.Inputs.DisableTurret = { Turret.Event_DisableTurret, "bool" };  
  Turret.FlowEvents.Outputs.Destroyed =  "bool";
  
  return Turret;
  
end

CreateTurret("AlienTurret");
CreateTurret("WarriorMOARTurret");
CreateTurret("AutoTurret").Properties.bExplosionOnly=1;
CreateTurret("AutoTurretAA").Properties.bExplosionOnly=1;


function AutoTurret.Server:OnHit(hit)
	if(g_gameRules:IsMultiplayer())then
		return;
	else
		Item.Server:OnHit(self, hit);
	end;
end

function AutoTurretAA.Server:OnHit(hit)
	if(g_gameRules:IsMultiplayer())then
		return;
	else
		Item.Server:OnHit(self, hit);
	end;
end

function AutoTurret:OnFreeze(shooterId, weaponId, value)
	return false;
end

function AutoTurretAA:OnFreeze(shooterId, weaponId, value)
	return false;
end

----------------------------------------------------------------------------------------------------
AlienTurret.Properties.DamageMultipliers = {
	Bullet = 1.0,
	Explosion = 1.0,
	Collision = 1.0,
	Melee = 1.0,
};

AlienTurret.Properties.GunTurret.bVulnerable=1;

function AlienTurret.Server:OnHit(hit)
	if(self.Properties.GunTurret.bVulnerable==0)then
		return;
	end;
	
	local dmg=hit.damage;
	local mul=self.Properties.DamageMultipliers;
	if(hit.type=="bullet")then dmg=dmg*mul.Bullet;end;
	if(hit.type=="collision")then dmg=dmg*mul.Collision;end;
	if(hit.type=="melee")then dmg=dmg*mul.Melee;end;
	if(hit.explosion)then
		dmg=dmg*mul.Explosion;
	end;
	
	hit.damage=dmg;
	
	local explosionOnly=tonumber(self.Properties.bExplosionOnly or 0)~=0;
  local hitpoints = self.Properties.HitPoints;
  
	if (hitpoints and (hitpoints > 0)) then
		local destroyed=self.item:IsDestroyed()
		if (hit.type=="repair") then
			self.item:OnHit(hit);
		elseif ((not explosionOnly) or (hit.explosion)) then
			if ((not g_gameRules:IsMultiplayer()) or g_gameRules.game:GetTeam(hit.shooterId)~=g_gameRules.game:GetTeam(self.id)) then
				self.item:OnHit(hit);
				if (not destroyed) then
					if (hit.damage>0) then
						if (g_gameRules.Server.OnTurretHit) then
							g_gameRules.Server.OnTurretHit(g_gameRules, self, hit);
						end
					end
				
					if (self.item:IsDestroyed()) then
						if(self.FlowEvents and self.FlowEvents.Outputs.Destroyed)then
							self:ActivateOutput("Destroyed",1);
						end
					end
				end
			end
		end
	end
end


----------------------------------------------------------------------------------------------------
--Script.ReloadScript("scripts/entities/items/crosshairs.lua");
--Script.ReloadScript("scripts/entities/items/ui/newweaponui.lua");

