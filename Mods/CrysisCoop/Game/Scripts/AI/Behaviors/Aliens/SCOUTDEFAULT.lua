-- Default behaviour - implements all the system callbacks and does something
-- this is so that any enemy has a behaviour to fallback to
--------------------------

	scoutAttackLocation = {};
	scoutSelected = nil;

	local stayPositionData = {
		
		{
			pat = {
				{ vec = {0.0, 30.0, 80.0}, },{ vec = {0.0, 30.0, 110.0}, },{ vec = {0.0, 30.0, 50.0}, },{ vec = {0.0, 30.0, 80.0}, },{ vec = {0.0, 27.0, 80.0}, },
			},
		},
		{
			pat = {
				{ vec = {-30.0, 30.0, 100.0}, },{ vec = {-30.0, 30.0, 130.0}, },{ vec = {-30.0, 30.0, 40.0}, },{ vec = {-50.0, 30.0, 50.0}, },{ vec = {-30.0, 27.0, 100.0}, },
			},
		},
		{
			pat = {
				{ vec = {30.0, 30.0, 100.0}, },{ vec = {30.0, 30.0, 130.0}, },{ vec = {30.0, 30.0, 40.0}, },{ vec = {50.0, 30.0, 50.0}, },{ vec = {30.0, 27.0, 100.0}, },
			},
		},
		{
			pat = {
				{ vec = {-30.0, 50.0, 100.0}, },{ vec = {-30.0, 30.0, 130.0}, },{ vec = {-30.0, 50.0, 40.0}, },{ vec = {-30.0, 30.0, -50.0}, },{ vec = {-30.0, 47.0, 100.0}, },
			},
		},
		{
			pat = {
				{ vec = {30.0, 50.0, 100.0}, },{ vec = {30.0, 30.0, 130.0}, },{ vec = {30.0, 50.0, 40.0}, },{ vec = {30.0, 30.0, -50.0}, },{ vec = {30.0, 47.0, 100.0}, },
			},
		},

	};

	local checkPositionData = {
		{
			pat = {
				{ vec = {0.0, 50.0, 120.0}, },{ vec = {40.0, 50.0, 120.0}, },{ vec = {-40.0, 50.0, 120.0}, },
			},
		},
		{
			pat = {
				{ vec = {0.0, 50.0, -120.0}, },{ vec = {40.0, 50.0, -120.0}, },{ vec = {-40.0, 50.0, -120.0}, },
			},
		},

	};

AIBehaviour.SCOUTDEFAULT = {
	Name = "SCOUTDEFAULT",

	-- this signal should be sent only by smart objects
	OnReinforcementRequested = function ( self, entity, sender, extraData )
		local pos = {};
		AI.GetBeaconPosition( extraData.id, pos );
--		AI.LogEvent( "OnReinforcementRequested - beacon:"..pos.x..", "..pos.y..", "..pos.z );
		AI.SetBeaconPosition( entity.id, pos );
		AIBehaviour.GUARDDEFAULT:GotoPursue(entity,1);
	end,
	
	--------------------------------------------------------------------------
	-- shared functions 
	--------------------------------------------------------------------------
	--------------------------------------------------------------------------
	scoutGetDistanceOfPoints = function(self,src,dst)

		local vTmp = {};
		local distance;

		SubVectors(vTmp,src,dst);
		distance = LengthVector(vTmp);

		return	distance;

	end,
	
	--------------------------------------------------------------------------
	-- get direction vector which length is 'scale'
	scoutGetScaledDirectionVector = function(self,entity,outvec,src,dst,scale)

		SubVectors( outvec, dst, src );
		NormalizeVector( outvec );
		FastScaleVector( outvec, outvec, scale );

	end,

	-- get up vector which length is 'scale'
	scoutGetScaledUpVector = function(self,entity,outvec,scale)

		CopyVector( outvec, entity:GetDirectionVector(2) );
		FastScaleVector( outvec, outvec, scale );

	end,

	--------------------------------------------------------------------------
	-- get target's height from the ground
	scoutGetDistanceFromTheGround = function( self, entity )

		local distance;
		local targetEntity = AI.GetAttentionTargetEntity( entity.id );

		if ( targetEntity and AI.Hostile( entity.id, targetEntity.id ) ) then

			local vSrc = {};
			local vDir = {};
			local vDown = {};
			local vUp = {};
		
			CopyVector( vUp, targetEntity:GetDirectionVector(2) );
			CopyVector( vSrc, targetEntity:GetPos() );

			FastScaleVector( vUp, vUp, 5.0 );
			FastScaleVector( vDown, vUp, -1.0 );
			FastScaleVector( vDir, vDown, 2.0 );
			FastSumVectors( vSrc, vSrc, vUp );

			local	hits = Physics.RayWorldIntersection(vSrc,vDir,1,ent_terrain+ent_static+ent_rigid+ent_sleeping_rigid+ent_living,targetEntity.id,nil,g_HitTable);
			if( hits == 0 ) then
				distance = 100.0;
			else
				local firstHit = g_HitTable[1];
				CopyVector( vSrc, targetEntity:GetPos() );
				SubVectors( vSrc, vSrc, firstHit.pos );
				distance = LengthVector( vSrc );
			end					

		else
			distance = 100.0;
		end

		return distance;

	end,

	--------------------------------------------------------------------------
	-- simple flocking.
	scoutAdjustRefPoint = function( self, entity, sw )

		-- implement a simple flocking.

		local groupCount = AI.GetGroupCount( entity.id, GROUP_ENABLED );
		local i;
	
		local vOrgRefPoint ={};
		local vNewRefPoint = {};
		local vVecTmp = {};

		CopyVector( vOrgRefPoint, AI.GetRefPointPosition( entity.id ) );
		CopyVector( vNewRefPoint, vOrgRefPoint );

		if ( groupCount > 1 ) then
			for i= 1,groupCount do
				local member = AI.GetGroupMember( entity.id, i, GROUP_ENABLED );
				if( member ~= nul and member.id ~= entity.id ) then
					local distance = DistanceVectors( vOrgRefPoint, member:GetPos() );
					distance = distance * distance;
					length = 50.0 / distance;
					if ( length > 30.0 ) then
						length =30.0;
					end
					SubVectors( vVecTmp, vOrgRefPoint, member:GetPos() );
					NormalizeVector( vVecTmp );
					FastScaleVector( vVecTmp, vVecTmp, length );
					FastSumVectors( vNewRefPoint, vNewRefPoint, vVecTmp );
				end
			end
			for i= 1,groupCount do
				local member = AI.GetGroupMember( entity.id, i, GROUP_ENABLED );
				if( member ~= nul and member.id ~= entity.id ) then
					local distance = DistanceVectors( vOrgRefPoint, member:GetPos() );
					distance = distance * distance;
					length = 50.0 / distance;
					if ( length > 30.0 ) then
						length =30.0;
					end
					SubVectors( vVecTmp, entity:GetPos(), member:GetPos() );
					NormalizeVector( vVecTmp );
					FastScaleVector( vVecTmp, vVecTmp, length );
					FastSumVectors( vNewRefPoint, vNewRefPoint, vVecTmp );
				end
			end
		
		end
	
		if ( sw >0.0 ) then
	
			local vSrc = {};
			local vDir = {};
			local vDown = {};
			local vUp = {};

			CopyVector( vUp, entity:GetDirectionVector(2) );
			CopyVector( vSrc, vNewRefPoint );

			FastScaleVector( vUp, vUp, sw );
			FastScaleVector( vDown, vUp, -1.0 );
			FastScaleVector( vDir, vDown, 2.0 );
			FastSumVectors( vSrc, vSrc, vUp );

			local	hits = Physics.RayWorldIntersection(vSrc,vDir,1,ent_terrain+ent_static+ent_rigid+ent_sleeping_rigid+ent_living,entity.id,nil,g_HitTable);
			--AI.LogComment(entity:GetName().." scoutAdjustRefPoint hits".. hits);
			if( hits == 0 ) then
			else
				--AI.LogComment(entity:GetName().." scoutAdjustRefPoint detect a collision");
				local firstHit = g_HitTable[1];
				FastSumVectors( vNewRefPoint, firstHit.pos, vUp );
			end					
	
		end
	
		AI.SetRefPointPosition( entity.id, vNewRefPoint );

	end,

	--------------------------------------------------------------------------
	-- Get a position for a specific purpose in FOV
	scoutCheckNavOfRef = function( self, entity )

		local vTmp = {};
		SubVectors( vTmp, AI.GetRefPointPosition( entity.id ), entity:GetPos() );
		local distance = LengthVector( vTmp ) + 0.01;

		FastScaleVector( vTmp, vTmp, ( distance + 12.0 )/distance );
		FastSumVectors( vTmp, vTmp, entity:GetPos() );
		
		if ( AI.IsPointInFlightRegion( vTmp ) == false ) then
			--AI.LogComment(entity:GetName().." detected a bad ref point");
			return	false;			
		end
		
		return true;

	end,

	--------------------------------------------------------------------------
	scoutCheckStayAttackPosition = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			local targetPos = {};

			local cameraFwdDir = {};
			local cameraWingDir = {};
			local targetUpDir = {};
			local targetFwdDir = {};
			local targetWingDir = {};

			CopyVector( targetPos, target:GetPos() );

			if ( AI.GetAttentionTargetType(entity.id) == AIPROJECT_PLAYER ) then 
				CopyVector( cameraFwdDir, System.GetViewCameraDir() );
				CopyVector( cameraWingDir, vecFrontToRight(cameraFwdDir) );
				CopyVector( targetUpDir, target:GetDirectionVector(2) );
			else
				CopyVector( cameraFwdDir, target:GetDirectionVector(0) );
				CopyVector( cameraWingDir, vecFrontToRight(cameraFwdDir) );
				CopyVector( targetUpDir, target:GetDirectionVector(2) );
			end

			--Just in case, for scaling
			NormalizeVector(cameraFwdDir);
			NormalizeVector(targetUpDir);

			local t = dotproduct3d( cameraFwdDir , targetUpDir );
			--Avoid a singularity
			if ( t * t < 0.9 ) then

				ProjectVector( targetFwdDir  , cameraFwdDir  , targetUpDir );
				ProjectVector( targetWingDir , cameraWingDir , targetUpDir );
				NormalizeVector(targetFwdDir);
				NormalizeVector(targetWingDir);

				local i;
				local j;
				local k;

				local scaleFactor;
				local vTmp = {};
				local vCheck = {};
				local bResult;		

				for i = 1,7 do
					scaleFactor = (11.0-i)/10.0;
					entity.AI.vFormationScale.x = scaleFactor;
					entity.AI.vFormationScale.y = scaleFactor;
					entity.AI.vFormationScale.z = scaleFactor;
					for k = 1,2 do
						bResult = true;
						for j = 1,3 do
							FastScaleVector( vTmp, targetWingDir, checkPositionData[k].pat[j].vec[1] * entity.AI.vFormationScale.x);
							CopyVector( vCheck, vTmp );
							FastScaleVector( vTmp, targetUpDir, checkPositionData[k].pat[j].vec[2] * entity.AI.vFormationScale.z);
							FastSumVectors( vCheck, vCheck, vTmp );
							FastScaleVector( vTmp, targetFwdDir, checkPositionData[k].pat[j].vec[3] * entity.AI.vFormationScale.y);
							FastSumVectors( vCheck, vCheck, vTmp );
							FastSumVectors( vCheck, vCheck, targetPos );
							if ( AI.IsPointInFlightRegion( vCheck ) == false ) then
								bResult = false;
							end
						end
						if (bResult==true) then
							--AI.LogEvent(entity:GetName().."selected scale"..scaleFactor.."/"..k);
							if (k==2) then
								entity.AI.vFormationScale.y = entity.AI.vFormationScale.y* -1.0;
							end
							return true;
						end
					end
				end

			end
		end

		entity.AI.vFormationScale.x = 0.0;
		entity.AI.vFormationScale.y = 0.0;
		entity.AI.vFormationScale.z = 0.0;
		return	false;

	end,


	scoutRefreshStayAttackPosition = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			local targetPos = {};

			local cameraFwdDir = {};
			local cameraWingDir = {};
			local targetUpDir = {};
			local targetFwdDir = {};
			local targetWingDir = {};

			CopyVector( targetPos, target:GetPos() );
			CopyVector( cameraFwdDir, System.GetViewCameraDir() );
			CopyVector( cameraWingDir, vecFrontToRight(cameraFwdDir) );
			CopyVector( targetUpDir, target:GetDirectionVector(2) );

			--Just in case, for scaling
			NormalizeVector(cameraFwdDir);
			NormalizeVector(targetUpDir);

			local t = dotproduct3d( cameraFwdDir , targetUpDir );

			--Avoid a singularity
			if ( t * t < 0.9 ) then

				ProjectVector( targetFwdDir  , cameraFwdDir  , targetUpDir );
				ProjectVector( targetWingDir , cameraWingDir , targetUpDir );
				NormalizeVector(targetFwdDir);
				NormalizeVector(targetWingDir);

				--AI.LogComment(entity:GetName().." scoutRefreshStayAttackPosition UPDIR "..targetUpDir.x..","..targetUpDir.y..","..targetUpDir.z);
				--AI.LogComment(entity:GetName().." scoutRefreshStayAttackPosition FWDIR "..targetFwdDir.x..","..targetFwdDir.y..","..targetFwdDir.z);
				--AI.LogComment(entity:GetName().." scoutRefreshStayAttackPosition WGDIR "..targetWingDir.x..","..targetWingDir.y..","..targetWingDir.z);

				CopyVector( entity.AI.vWngUnit, targetWingDir );
				CopyVector( entity.AI.vUpUnit , targetUpDir   );
				CopyVector( entity.AI.vFwdUnit, targetFwdDir  );
				CopyVector( entity.AI.vAttackCenterPos, targetPos );

				return	true;

			end

		end

		-- clear vectors; the scout will stay the same position.

		--AI.LogComment(entity:GetName().." scoutRefreshStayAttackPosition vectors cleared");
		local zeroVec ={};
		zeroVec.x = 0.0;
		zeroVec.y = 0.0;
		zeroVec.z = 0.0;
		CopyVector( entity.AI.vFwdUnit, zeroVec );
		CopyVector( entity.AI.vWngUnit, zeroVec );
		CopyVector( entity.AI.vUpUnit, zeroVec );
		CopyVector( entity.AI.vAttackCenterPos, entity:GetPos() );

		return	false;

	end,

	--------------------------------------------------------------------------
	scoutGetStayAttackPosition = function( self, entity, X, pattern )

		-- X:       output position
		-- entity:  input  entitiy
		-- pattern: input  0 - attack position 1 - escape position. 2 - MOAR attack position 3 - for flyover

		-- when error, will return a current my position.

		local targetWngDir = {};
		local targetUpDir = {};
		local targetFwdDir = {};
		local scoutAttackCenterPos = {};

		if ( entity.AI.stayPosition == 0 ) then

			CopyVector( X, entity.AI.vDefaultPosition );

		elseif (LengthVector( entity.AI.vFormationScale ) < 0.01 ) then
		
			CopyVector ( X, entity:GetPos() );
		
		else
	
			FastScaleVector( targetWngDir , entity.AI.vWngUnit , stayPositionData[entity.AI.stayPosition].pat[pattern+1].vec[1] * entity.AI.vFormationScale.x);
			FastScaleVector( targetUpDir  , entity.AI.vUpUnit  , stayPositionData[entity.AI.stayPosition].pat[pattern+1].vec[2] * entity.AI.vFormationScale.z);
			FastScaleVector( targetFwdDir , entity.AI.vFwdUnit , stayPositionData[entity.AI.stayPosition].pat[pattern+1].vec[3] * entity.AI.vFormationScale.y);

			FastSumVectors( scoutAttackCenterPos , entity.AI.vAttackCenterPos , targetUpDir   );
			FastSumVectors( scoutAttackCenterPos , scoutAttackCenterPos    , targetFwdDir  );
			FastSumVectors( scoutAttackCenterPos , scoutAttackCenterPos    , targetWngDir );

			CopyVector ( X, scoutAttackCenterPos );

		end

	end,

	--------------------------------------------------------------------------
	-- Get a hidespot near the entity.
	scoutSearchHideSpotCheck = function( self, entity, pos )

		local targetEntity = AI.GetAttentionTargetEntity( entity.id );
		if ( targetEntity and AI.Hostile( entity.id, targetEntity.id ) ) then

			local vSrc ={};
			local vDir ={};

			CopyVector( vSrc, pos );
			SubVectors( vDir, targetEntity:GetPos() ,vSrc );

			local	hits = Physics.RayWorldIntersection(vSrc,vDir,1,ent_terrain+ent_static+ent_rigid+ent_sleeping_rigid+ent_living,entity.id,targetEntity.id,g_HitTable);
					
			if( hits == 0 ) then

			else
				return true;
			end

		end
		
		return false;

	end,

	scoutSearchHideSpot = function( self, entity, hidepos , peeppos)

		local targetName = AI.GetAttentionTargetOf( entity.id );

		local targetType = AI.GetTargetType( entity.id );
		if( targetType == AITARGET_MEMORY ) then
			-- need to have real target not memory
			-- return false;
		end

		local targetEntity = AI.GetAttentionTargetEntity( entity.id )
		if ( targetEntity and AI.Hostile( entity.id, targetEntity.id ) ) then

			if ( entity:GetDistance( targetEntity.id) <30.0 ) then
				--AI.LogComment(entity:GetName().." scoutSearchHideSpot target too close");
				return	false;
			end

			local anchorName = AI.GetAnchor(entity.id,AIAnchorTable.ALIEN_HIDESPOT,100.0,AIANCHOR_BEHIND_IN_RANGE);	
			if( not anchorName ) then
				anchorName = AI.GetAnchor(entity.id,AIAnchorTable.ALIEN_HIDESPOT,100.0,AIANCHOR_NEAREST);	
			end
			if( anchorName ) then
			
				local anchorEntity = System.GetEntityByName(anchorName);
				if ( anchorEntity ) then
	
					local vSrc = {};
					local vDir = {};
					local vDown = {};
					local vUp = {};

					CopyVector( vUp, anchorEntity:GetDirectionVector(2) );
					CopyVector( vSrc, anchorEntity:GetPos() );

					FastScaleVector( vUp, vUp, 7.5 );
					FastScaleVector( vDown, vUp, -1.0 );
					FastScaleVector( vDir, vDown, 2.0 );
					FastSumVectors( vSrc, vSrc, vUp );

					local	hits = Physics.RayWorldIntersection(vSrc,vDir,1,ent_terrain+ent_static+ent_rigid+ent_sleeping_rigid+ent_living,entity.id,nil,g_HitTable);
					if ( hits == 0 ) then
						CopyVector( hidepos, anchorEntity:GetPos());
						FastScaleVector( vUp, anchorEntity:GetDirectionVector(2), 40.0 );
						FastSumVectors( peeppos, hidepos, vUp );
					else
						local firstHit = g_HitTable[1];
						FastSumVectors( hidepos, firstHit.pos, vUp );
						FastScaleVector( vUp, anchorEntity:GetDirectionVector(2), 40.0 );
						FastSumVectors( peeppos, hidepos, vUp );
					end					
					return true;

				else
					--AI.LogComment(entity:GetName().." scoutSearchHideSpot no anchor entity");
				end
				
			else
				--AI.LogComment(entity:GetName().." scoutSearchHideSpot no anchor");
			end

		else
			--AI.LogComment(entity:GetName().." scoutSearchHideSpot no taget");
		end

		return	false;
	
	end,

	--------------------------------------------------------------------------
	-- To avoid the conflicts, make approach point exclusive.
	scoutGetID = function( self, entity )

		-- 29/11/05 tetsuji

		local i=0;
		local j=0;

		local target = AI.GetAttentionTargetEntity( entity.id );

		if ( target and AI.Hostile( entity.id, target.id ) ) then

			-- clear list.
			for i= 1,5 do
				if ( scoutAttackLocation[i] == nil ) then
					scoutAttackLocation[i] = 0;
				end
			end

			-- clear list if a scout has already resistered.
			for i= 1,5 do
				if ( scoutAttackLocation[i] ~= 0 ) then
					if ( scoutAttackLocation[i] == entity.id ) then
							scoutAttackLocation[i] = 0;
					else
						local scoutEntity = System.GetEntity( scoutAttackLocation[i] );
						if ( scoutEntity ) then
							if ( scoutEntity.actor ) then
								if ( scoutEntity.actor:GetHealth() < 1.0 ) then
										scoutAttackLocation[i] = 0;
								end
							else
								scoutAttackLocation[i] = 0;
							end
						else
							scoutAttackLocation[i] = 0;
						end
					end
				end
			end		

			-- check if there is a empty seat.
			for i= 1,5 do
				if ( scoutAttackLocation[i] == 0 ) then
					scoutAttackLocation[i] = entity.id;
					entity.AI.stayPosition = i;
--					AI.LogEvent(entity:GetName().." gets "..entity.AI.stayPosition);
					return;
				end
			end

			entity.AI.stayPosition = 0;
		end

	end,

	--------------------------------------------------------------------------
	scoutListUpObjects = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			local targetEntity;
			local entities = System.GetPhysicalEntitiesInBox( target:GetPos(), 20.0 );

			-- AI.LogEvent(entity:GetName().." list up entities--------------------------");
			if (entities) then
				for i,targetEntity in ipairs(entities) do
					-- AI.LogEvent(targetEntity:GetName());
					local bSameSpecies = false;
					if( entity.Properties.species and targetEntity.Properties.species ) then
						if( entity.Properties.species == targetEntity.Properties.species ) then
							bSameSpecies = true;
						end
					end
					if ( bSameSpecies == false ) then
						if ( targetEntity~=target and targetEntity~=entity and target.AI.theVehicle~=nil and target.AI.theVehicle ~= targetEntity ) then
							local maxMass =100000.0;
							if ( entity.grabParams.mass ) then
								maxMass = entity.grabParams.mass;
							end
							if ( targetEntity:GetMass() > 100.0 and AI.GetTypeOf(targetEntity.id) ~= AIOBJECT_PUPPET and AI.GetTypeOf(targetEntity.id) ~= AIOBJECT_PLAYER ) then
								AI.LogEvent( entity:GetName().." list up grab target "..targetEntity:GetName() );
								return	true;
							end
						end
					end
				end
			end

		end

		return	false;

	end,

	--------------------------------------------------------------------------
	scoutGetMeleeTarget = function( self, entity )
	
		local targetEntity;
		local i;

		if (entity.AI.meleeCout<2) then

			entity.AI.meleeDistance = entity.AI.meleeDistance -5.0;
			if (entity.AI.meleeDistance< 4.0) then
				entity.AI.meleeDistance =4.0;
			end

			local entities = System.GetPhysicalEntitiesInBox( entity.AI.meleeTargetEntity:GetPos(), entity.AI.meleeDistance );
	
			if (entities) then
				-- calculate damage for each entity
				for i,targetEntity in ipairs(entities) do
					if( entity.Properties.species and targetEntity.Properties.species ) then
						if( entity.Properties.species == targetEntity.Properties.species ) then
							return	-1;
						end
					end
					-- and not sameSpecies
					if ( entity ~= targetEntity and entity.AI.meleeTargetEntity ~= targetEntity) then
						if ( targetEntity:GetMass() > 100.0 and AI.GetTypeOf(targetEntity.id) ~= AIOBJECT_PUPPET and AI.GetTypeOf(targetEntity.id) ~= AIOBJECT_PLAYER) then
							local distance = DistanceVectors( targetEntity:GetPos(), entity.AI.meleeTargetEntity:GetPos() );
							if (distance < entity.AI.meleeDistance) then
								--if (targetEntity.AI.scoutGameKey ==nil or  targetEntity.AI.scoutGameKey~=scoutGameKey) then
									local dir ={};
									local dir2 ={};
									CopyVector(dir,entity:GetPos());
									SubVectors(dir,dir,entity.AI.meleeTargetEntity:GetPos());
									CopyVector(dir2,targetEntity:GetPos());
									SubVectors(dir2,dir2,entity.AI.meleeTargetEntity:GetPos());
									NormalizeVector(dir);
									NormalizeVector(dir2);
									local t = dotproduct3d( dir,dir2 );
									if (t>math.cos(3.1416*60.0/180.0)) then
										--targetEntity.AI.scoutGameKey = scoutGameKey;
										entity.AI.meleeDistance =distance;
										--AI.LogEvent(entity:GetName().." scoutGetMeleeTarget:found melee target "..targetEntity:GetName() );
										local refpos ={};
										CopyVector( refpos, targetEntity:GetPos() );
										SubVectors( refpos, refpos, entity:GetPos());
										NormalizeVector( refpos );
										FastScaleVector( refpos, refpos, -5.0 *0.8);
										FastSumVectors( refpos, refpos, targetEntity:GetPos() );
										AI.SetRefPointPosition( entity.id, refpos );
										entity.AI.meleeCout =entity.AI.meleeCout +1;
										return	1;
									end
								--end
							end
						end
					end
				end
			end
		end
	
		local refpos ={};
		CopyVector( refpos, entity.AI.meleeTargetEntity:GetPos() );
		SubVectors( refpos, refpos, entity:GetPos() );
		NormalizeVector( refpos );
		FastScaleVector( refpos, refpos, -10.0 *0.8);
		FastSumVectors( refpos, refpos, entity.AI.meleeTargetEntity:GetPos() );
		AI.SetRefPointPosition( entity.id, refpos );
		--AI.LogEvent(entity:GetName().." scoutGetMeleeTarget:found melee target "..entity.meleeTargetEntity:GetName() );
		AI.SetRefPointPosition( entity.id , refpos );

		entity.AI.meleeCout = entity.AI.meleeCout +1;

		return	0;
	
	end,

	--------------------------------------------------------------------------
	scoutGetGrabTarget = function( self, entity )
	
		local targetEntity;
		local i;

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			local entities = System.GetPhysicalEntitiesInBox( target:GetPos(), 20.0 );
	
			if (entities) then
				-- calculate damage for each entity
				for i,targetEntity in ipairs(entities) do
					if( entity.Properties.species and targetEntity.Properties.species ) then
						if( entity.Properties.species == targetEntity.Properties.species ) then
							return	-1;
						end
					end
					-- and not sameSpecies
					if ( entity ~= targetEntity and target ~= targetEntity and target.AI.theVehicle~=nil and target.AI.theVehicle.id ~= targetEntity.id ) then
							local maxMass =100000.0;
							if ( entity.grabParams.mass ) then
								maxMass = entity.grabParams.mass;
							end
							if ( targetEntity:GetMass() > 100.0 and AI.GetTypeOf(targetEntity.id) ~= AIOBJECT_PUPPET and AI.GetTypeOf(targetEntity.id) ~= AIOBJECT_PLAYER ) then
								local distance = DistanceVectors( targetEntity:GetPos(), target:GetPos() );
								local dir ={};
								local dir2 ={};
								CopyVector(dir,entity:GetPos());
								SubVectors(dir,dir,target:GetPos());
								CopyVector(dir2,targetEntity:GetPos());
								SubVectors(dir2,dir2,target:GetPos());
								NormalizeVector(dir);
								NormalizeVector(dir2);
								local t = dotproduct3d( dir,dir2 );
								if (t>math.cos(3.1416*60.0/180.0)) then
									--AI.LogComment(entity:GetName().." scoutGetGrabTarget:found target "..targetEntity:GetName() );
									local refpos ={};
									CopyVector( refpos, targetEntity:GetPos() );
									SubVectors( refpos, refpos, entity:GetPos());
									NormalizeVector( refpos );
									FastScaleVector( refpos, refpos, -3.0 );
									FastSumVectors( refpos, refpos, targetEntity:GetPos() );
									AI.SetRefPointPosition( entity.id, refpos );
									entity.AI.captureTargetEntity = targetEntity;
									return	1;
								end

						end
					end
				end
			end
		end
	
		return	0;
	
	end,

	--------------------------------------------------------------------------
	scoutGetPickPosition = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

			local vR = {};
			local vUp = {};
			local vFwd = {};
			local vDir = {};
			local vRot = {};

			CopyVector( vR, target:GetDirectionVector(2) );
			FastScaleVector( vUp, vR, 10.0);
			FastScaleVector( vFwd, target:GetDirectionVector(2), 15.0 );
			FastSumVectors( vDir, vUp, vFwd );

			for i = 1,6 do

				RotateVectorAroundR( vRot, vDir, vR, 3.1416* 2.0 * i / 6.0 );
				local	hits = Physics.RayWorldIntersection(target:GetPos(),vRot,1,ent_terrain+ent_static+ent_rigid+ent_sleeping_rigid+ent_living,entity.id,target.id,g_HitTable);
				if ( hits == 0 ) then
					FastSumVectors( vDir, vDir, target:GetPos() );
					AI.SetRefPointPosition( entity.id , vDir );
					return	true;
				end				
			end

		end

		return	false;

	end,

	--------------------------------------------------------------------------
	scoutCloseConnection = function( self, entity )

		entity.AI.bIssuedConnect = false;
		entity.AI.bConnected = false;
		entity.AI.bApproved = false;

		entity.AI.bIsReplayForConnect =false;
		entity.AI.connectListIndex =0;
		entity.AI.connectList = {};

		entity.AI.vGuardPoint = {};

	end,

	--------------------------------------------------------------------------
	scoutDoStayAttack = function( self, entity )

		if ( System.GetCurrTime()- entity.AI.time > 3.0 ) then
			AI.Signal(SIGNALFILTER_GROUPONLY, 1, "SC_SCOUT_REFLESH_POSITION",entity.id);
		end

		entity.AI.ignoreDamage = false;

		entity:SelectPipe(0,"do_nothing"); 

		if ( entity.AI.stayPosition == 0 ) then
			-- if he couldn't join a formation.
			local scoutAttackCenterPos = {};
			self:scoutGetStayAttackPosition( entity , scoutAttackCenterPos , 0 );
			AI.SetRefPointPosition( entity.id , scoutAttackCenterPos  );
			entity:SelectPipe(0,"scoutAttackWait");
			return;

		end

		local scoutAttackCenterPos = {};
		self:scoutGetStayAttackPosition( entity , scoutAttackCenterPos , 0 );
		local currentDirLen = DistanceVectors( scoutAttackCenterPos ,entity:GetPos() );

		entity.AI.loopInLoopCounter = 0;
		AI.ChangeParameter( entity.id, AIPARAM_STRAFINGPITCH, 10.0 );
		AI.SetRefPointPosition( entity.id , scoutAttackCenterPos  );
		self:scoutAdjustRefPoint( entity , 10.0 );
		if ( self:scoutCheckNavOfRef( entity ) == false ) then
			AI.SetRefPointPosition( entity.id , entity:GetPos() );
		end

		-- For MOAC Scout
		if ( currentDirLen < 20.0 ) then
			entity:SelectPipe(0,"do_nothing");
			if ( random(1,3) == 1 ) then
				entity:SelectPipe(0,"scoutAttackStandByV3");
			else
				entity:SelectPipe(0,"scoutAttackStandByV4");
			end
		elseif ( currentDirLen < 50.0 ) then
			entity:SelectPipe(0,"scoutAttackStandByV2");
		else
			entity:SelectPipe(0,"scoutAttackStandBy");
		end

	end,
	

	--------------------------------------------------------------------------
	-- signal handers ( system )
	--------------------------------------------------------------------------
	--------------------------------------------------------------------------
	OnObjectSeen = function( self, entity, fDistance, data )
		-- called when the AI sees an object registered for this kind of signal
		-- data.iValue = AI object type
		-- example
		-- if (data.iValue == 150) then -- grenade
		--	 ...
		if ( data.iValue == AIOBJECT_RPG) then
			entity:InsertSubpipe(0,"devalue_target");
		end

	end,

	---------------------------------------------
	OnVehicleDanger = function (self,entity,sender,data)
		-- called when a vehicle is going towards the AI
		-- data.point = vehicle movement direction
		-- data.point2 = AI direction with respect to vehicle
	end,

	--------------------------------------------------------------------------
	-- signal handers ( Scout specific )
	--------------------------------------------------------------------------

	--------------------------------------------------------------------------
	SC_SCOUT_REFLESH_POSITION = function( self, entity, sender, data )

		AIBehaviour.SCOUTDEFAULT:scoutCheckStayAttackPosition( entity );
		AIBehaviour.SCOUTDEFAULT:scoutRefreshStayAttackPosition( entity );

		entity.AI.time = System.GetCurrTime();

	end,

	--------------------------------------------------------------------------
	SC_SCOUT_CHECK_ATTACK = function ( self, entity )

		-- A kind of sub-function for SC_SCOUT_STAY_ATTACK.
		-- During approaching, check if the scout can shoot at the player.

		if ( entity.AI.loopInLoopCounter ==0 and random(1,6)==1 ) then
			local target = AI.GetAttentionTargetEntity( entity.id );
			if ( target and AI.Hostile( entity.id, target.id ) ) then

				local scoutAttackCenterPos ={};
				self:scoutGetStayAttackPosition( entity , scoutAttackCenterPos , 0 );

				local distance = DistanceVectors( scoutAttackCenterPos , entity:GetPos() );
				
				if ( distance >30.0 ) then

					local inFOV = math.cos( 45.0 * 3.1415 / 180.0 );

					local cameraFwdDir = {};
					local targetPos = {};
					local myPos = {};
					local targetUpDir = {};
					local targetFwdDir = {};
					local currentDir = {};

					CopyVector( targetPos, target:GetPos() );
					CopyVector( myPos, entity:GetPos() );
					CopyVector( targetUpDir, target:GetDirectionVector(2) );
					CopyVector( cameraFwdDir, System.GetViewCameraDir() );

					ProjectVector( targetFwdDir, cameraFwdDir, targetUpDir );
					NormalizeVector(targetFwdDir);

					SubVectors( currentDir, myPos, targetPos );
					NormalizeVector(currentDir);

					local t = dotproduct3d( targetFwdDir , currentDir );
					local currentDirLen = DistanceVectors( myPos, targetPos );

						-- if the scout is in FOV of the player.
					if ( t > inFOV and currentDirLen > 60 ) then

						local vTmpVec = {};
						local vTmpUpVec = {};
						local vTmpDirVec = {};
						local vRefVec = {};
						
						CopyVector( vRefVec, AI.GetRefPointPosition( entity.id ) );
						
						SubVectors( vTmpDirVec, vRefVec, myPos );
						NormalizeVector( vTmpDirVec );
						FastScaleVector( vTmpDirVec, vTmpDirVec, 10.0);
						
						CopyVector( vTmpUpVec, targetUpDir );
						FastScaleVector( vTmpUpVec, vTmpUpVec, 15.0 );

						FastSumVectors( vTmpVec, vTmpDirVec, vTmpUpVec );
						FastSumVectors( vTmpVec, vTmpVec, vRefVec );

						AI.SetRefPointPosition( entity.id, vTmpVec );
						self:scoutAdjustRefPoint( entity, 0.0 );
						if ( self:scoutCheckNavOfRef( entity ) == false ) then
							AI.SetRefPointPosition( entity.id , entity:GetPos() );
						end

						entity:SelectPipe(0,"scoutCheckAttack");
						entity.AI.loopInLoopCounter =1;
					
					end
	
				end
	
			end
		elseif ( entity.AI.loopInLoopCounter == 1 ) then
		
			local target = AI.GetAttentionTargetEntity( entity.id );
			if ( target and AI.Hostile( entity.id, target.id ) ) then

				local targetPos = {};
				local myPos = {};
				local targetUpDir = {};
				local vTmpVec = {};
				local vTmpUpVec = {};

				CopyVector( targetPos, target:GetPos() );
				CopyVector( myPos, entity:GetPos() );
				CopyVector( targetUpDir, target:GetDirectionVector(2) );
				CopyVector( vTmpUpVec, targetUpDir);

				FastScaleVector ( vTmpUpVec, vTmpUpVec, 0.0 );
					
				SubVectors( vTmpVec, targetPos, myPos );
				NormalizeVector( vTmpVec );
				FastScaleVector( vTmpVec, vTmpVec, 20.0);
				FastSumVectors( vTmpVec, vTmpVec, myPos );
				FastSumVectors( vTmpVec, vTmpVec, vTmpUpVec );

				AI.ChangeParameter( entity.id, AIPARAM_STRAFINGPITCH , 10.0 );
				AI.SetRefPointPosition( entity.id, vTmpVec );
				self:scoutAdjustRefPoint( entity, 0.0 );
				if ( self:scoutCheckNavOfRef( entity ) == false ) then
					AI.SetRefPointPosition( entity.id , entity:GetPos() );
				end
			
				entity:SelectPipe(0,"scoutCheckAttackV2");
				entity.AI.loopInLoopCounter =0;

			else
				AI.Signal(SIGNALFILTER_SENDER,1,"SC_SCOUT_STAY_ATTACK", entity.id);
				entity.AI.loopInLoopCounter =0;
			end

		end

	end,

	--------------------------------------------------------------------------
	ScoutCheckClearance = function ( self, entity, vForcedNav, sec, radious )

			self:ScoutCheckFlock( entity, vForcedNav, sec, radious );
			return self:ScoutCheckClearanceMain( entity, vForcedNav, sec, radious );

	end,

	--------------------------------------------------------------------------
	ScoutCheckFlock = function ( self, entity, vForcedNav, sec, radious )

		--------------------------------------------------------------------------
		local vSumOfPotential ={};

		CopyVector( vSumOfPotential, AI.GetFlyingVehicleFlockingPos( entity.id,40.0,200.0,2.0,0.0 ) );
		local flocking = true;
		if ( LengthVector( vSumOfPotential )> 0.0 ) then
			entity.gameParams.forceView = 0.0;
			entity.actor:SetParams(entity.gameParams);
			CopyVector( vForcedNav, vSumOfPotential );
			return true;	
		end
		return false;

	end,

	--------------------------------------------------------------------------
	ScoutCheckClearanceMain = function ( self, entity, vForcedNav, sec, radious )

		local vMyPos  ={};
		local vRet  ={};
		local vVel  ={};
		local vVel2  ={};
		local vResult = {};

		--------------------------------------------------------------------------

		CopyVector( vMyPos, entity:GetPos() );
		entity:GetVelocity( vVel );
		FastScaleVector( vVel2, vForcedNav, sec );
		FastSumVectors( vVel, vVel, vVel2 );

--		AI.CheckVehicleColision( entity.id, vMyPos, vVel, radious );
		CopyVector( vResult, AI.IsFlightSpaceVoidByRadius( vMyPos, vVel, radious ) );

		if ( LengthVector( vResult ) < 0.001 ) then

			local hitPoint = {};
			local vVelLess = {};
			FastScaleVector( vVelLess, vVel, 0.5 );

			CopyVector( hitPoint, AI.CheckVehicleColision( entity.id, vMyPos, vVelLess, 1.0 ) );
			if ( LengthVector( hitPoint ) < 0.001 ) then
				return 0;
			else
				local vWng = {};
				SubVectors( hitPoint, hitPoint, entity:GetPos() );
				NormalizeVector( hitPoint );
				crossproduct3d( vWng, hitPoint, entity.AI.vUp );
				NormalizeVector( vWng );
				FastScaleVector( vVel, vWng, 30.0 );
				vVel.z = 0.0;

				entity.gameParams.forceView = 0.0;
				entity.actor:SetParams(entity.gameParams);

				return 1;
			end
		end

		entity.gameParams.forceView = 0.0;
		entity.actor:SetParams(entity.gameParams);


		if ( vResult.z > vMyPos.z ) then
			if ( vResult.z - vMyPos.z < 100.0 ) then
				vForcedNav.x = ( vResult.x - vMyPos.x ) * 0.5;
				vForcedNav.y = ( vResult.y - vMyPos.y ) * 0.5;
				vForcedNav.z = 0;
				
				local length2d = LengthVector( vForcedNav );
				if ( length2d > 16.0 ) then
					length2d = 16.0
				end
				NormalizeVector( vForcedNav );
				FastScaleVector( vForcedNav, vForcedNav, length2d );
				vForcedNav.z = ( vResult.z - vMyPos.z ) * 3.5;

			end
		end

		if ( vResult.z < vMyPos.z ) then
			if ( ( vMyPos.z - vResult.z ) < 5.0 ) then
				vForcedNav.z = 5.0 - ( vMyPos.z - vResult.z );
			else
				vForcedNav.z = 0;
			end
		end
		
		if ( vForcedNav.z > 30.0 ) then
			vForcedNav.z =30.0;
		end
		if ( vForcedNav.z < -30.0 ) then
			vForcedNav.z =-30.0;
		end
				
		do return 1; end

		local vUp = { x=0.0, y=0.0, z=1.0 };
		local vFwd = {};
		local vWng = {};
		CopyVector( vFwd, vForcedNav );
		NormalizeVector( vFwd );


		for i= 1,4 do

			crossproduct3d( vWng, vFwd, vUp );
			FastScaleVector( vWng, vWng, 4.0 * i );
			FastSumVectors( vMyPos, entity:GetPos(), vWng );
			CopyVector( vResult, AI.IsFlightSpaceVoidByRadius( vMyPos, vVel, radious ) );
	
			if ( LengthVector( vResult ) < 0.001 ) then
				CopyVector( vRet, vMyPos );
				return 2;
			end
	
			crossproduct3d( vWng, vFwd, vUp );
			FastScaleVector( vWng, vWng, -4.0 * i );
			FastSumVectors( vMyPos, entity:GetPos(), vWng );
			CopyVector( vResult, AI.IsFlightSpaceVoidByRadius( vMyPos, vVel, radious ) );
	
			if ( LengthVector( vResult ) < 0.001 ) then
				CopyVector( vRet, vMyPos );
				return 2;
			end

		end

		vRet.z = vResult.z - vMyPos.z;
		return 3;
		
	end,
	
	--------------------------------------------------	
	OnOutOfAmmo = function (self,entity, sender)
		-- player would not have Reload implemented
		if(entity.Reload == nil)then
			do return end
		end
		entity:Reload();
	end,

}
