--------------------------------------------------
--   Created By: Luciano
--   Description: The cover gets in close contact with the enemy and tries to take distance


AIBehaviour.CoverBackOff = {
	Name = "CoverBackOff",
	alertness = 2,

	Constructor = function (self, entity)
		entity:SelectPipe(0,"backoff_firing");		
	end,

	Destructor = function(self,entity)
		entity.backoffFailed = nil;
		entity:SelectPipe(0,"cover_scramble");
	end,
	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender,data)
		-- data.id: the shooter
	end,


	OnLeftLean  = function( self, entity, sender)
	end,
	---------------------------------------------
	OnRightLean  = function( self, entity, sender)
	end,
	--------------------------------------------------

	---------------------------------------------
	OnLowHideSpot = function( self, entity, sender)

		--entity:SelectPipe(0,"do_nothing");--in case it was already in dig_in_attack
	end,
	---------------------------------------------
	OnHideSpotReached = function( self, entity, sender)

	end,
	---------------------------------------------
	OnNoTarget = function( self, entity )
	end,
	---------------------------------------------
	OnPlayerSeen = function( self, entity, fDistance )

	end,
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
	end,
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
	end,
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
		-- called when the enemy hears a scary sound
	end,
	---------------------------------------------
	OnReload = function( self, entity )
		-- called when the enemy goes into automatic reload after its clip is empty
--		System.Log("--------OnReload");
--		entity:SelectPipe(0,"cover_scramble");
	end,
	---------------------------------------------
	OnGroupMemberDied = function( self, entity )
		-- called when a member of the group dies
	end,
	--------------------------------------------------
	OnGroupMemberDiedNearest = function ( self, entity, sender)
		AIBehaviour.DEFAULT:OnGroupMemberDiedNearest(entity,sender);	
	end,
	---------------------------------------------
	OnNoHidingPlace = function( self, entity, sender )
	end,	
	---------------------------------------------
	OnDamage = function ( self, entity, sender,data)
		-- called when the enemy is damaged

	end,
	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender)
	end,
	--------------------------------------------------
	OnClipNearlyEmpty = function ( self, entity, sender)

	end,
	--------------------------------------------------
	-- CUSTOM SIGNALS
	--------------------------------------------------
	---------------------------------------------
	---------------------------------------------
	HEADS_UP_GUYS = function (self, entity, sender)
		-- do nothing on this signal
	end,
	---------------------------------------------
	INCOMING_FIRE = function (self, entity, sender)
		-- do nothing on this signal
	end,
	--------------------------------------------------
	-- GROUP SIGNALS
	--------------------------------------------------
	------------------------------------------------------------------------
	GET_ALERTED = function( self, entity )
	end,

	------------------------------------------------------------------------
	
	OnCloseContact = function(self,entity,sender)
		--System.Log("BACKOFF CLOSE CONTACT");
	end,

	------------------------------------------------------------------------
	OnBackOffFailed = function(self,entity,sender)
		entity.backoffFailed = true;
--		System.Log("BACKOFF FAILED");
		if(AI.Hostile(entity.id,AI.GetAttentionTargetOf(entity.id))) then
			local targetPos = g_Vectors.temp;
			local moveDir = g_Vectors.temp_v1;
			AI.GetAttentionTargetPosition(entity.id,targetPos);
			FastDifferenceVectors(moveDir,targetPos,entity:GetWorldPos());
			if(random(1,2)==1) then
				FastSumVectors(moveDir,moveDir,entity:GetDirectionVector(0));
			else
				FastDifferenceVectors(moveDir,moveDir,entity:GetDirectionVector(0));
			end
			ScaleVectorInPlace(moveDir,2.5);
			FastSumVectors(moveDir,moveDir,entity:GetWorldPos());
			AI.SetRefPointPosition(entity.id,moveDir);
			entity:SelectPipe(0,"approach_refpoint");
		end 
	end,

	
	------------------------------------------------------------------------
	END_BACKOFF = function(self,entity,sender)
--		if(not entity.backoffFailed) then
--			entity:SelectPipe(0,"cover_scramble");
			AI.Signal(SIGNALFILTER_SENDER,0,"BackToAttack",entity.id);
--		end
		
	end,
	------------------------------------------------------------------------
}
