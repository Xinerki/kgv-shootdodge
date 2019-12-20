
SetEntityCollision(PlayerPedId(), true, true)
origInertia = 1.75 -- yep, gotta script inertia..

function RaycastSphere(pos, radius)
	local x,y,z = table.unpack(pos)
	local ray = StartShapeTestCapsule(x, y, z-radius, x, y, z+radius, radius+.0, 31, PlayerPedId())
	local res, hit = GetShapeTestResult(ray)
	-- if hit[2] then -- wether something has been hit
	  -- return hit[3] -- position vector oh hit
	-- else
	  -- return nil
	-- end
	
	if hit == 1 then
		DrawMarker(28, bonepos, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, radius, radius, radius, 0, 255, 0, 127, false, false, false, false)
	else
		DrawMarker(28, bonepos, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, radius, radius, radius, 255, 0, 0, 127, false, false, false, false)
	end
		
	return hit
end

function clamp(x, min, max)
	return math.min(math.max(x, min), max)
end

Citizen.CreateThread(function()
	while true do
		if not IsPedDeadOrDying(PlayerPedId(), 1) and not IsPedFalling(PlayerPedId()) and not IsPedInAnyVehicle(PlayerPedId(), true) then
			if IsControlJustPressed(0, 73) then
				if not GetIsTaskActive(PlayerPedId(), 296) then
					TaskPlayAnim(PlayerPedId(), "move_jump", "dive_start_run", 8.0, 1.0, -1, 2.0, 0, 0, 0)
					Wait(500)
					inertia = origInertia
					inertia = origInertia*0.8
					ApplyForceToEntity(PlayerPedId(), 1, 0.0, 0.0, inertia*3.5, 0.0, 0.0, 0.0, 0, true, 0, true, 0, 0)
					TaskAimGunScripted(PlayerPedId(), GetHashKey("SCRIPTED_GUN_TASK_PLANE_WING"), 0, 0)	
					-- CreateNmMessage(true, 1)
					-- GivePedNmMessage(PlayerPedId())
					-- StartScreenEffect("FocusIn", 0, false)
					PlaySoundFrontend(-1, "FocusIn", "HintCamSounds", 1)
					-- SetTimeScale(0.25)
				else
					local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))
					local _, groundZ = GetGroundZFor_3dCoord(x,y,z+2.0, 0)
					if z - groundZ < 2.0 then SetEntityCoords(PlayerPedId(), x, y, groundZ) end
					SetPedToRagdoll(PlayerPedId(), 150, 150, 3)
					ClearPedTasks(PlayerPedId())
					-- StopScreenEffect("FocusIn")
					-- StartScreenEffect("FocusOut", 0, false)
					PlaySoundFrontend(-1, "FocusOut", "HintCamSounds", 1)
					SetTimeScale(1.0)
				end
			end
			
			local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))
			local _, groundZ = GetGroundZFor_3dCoord(x,y,z+2.0, 0)
			
			local z = z-1.25
			if z > groundZ and GetIsTaskActive(PlayerPedId(), 296) == 1 then
				SetEntityCollision(PlayerPedId(), false, true)
				SetGravityLevel(1)
				if inertia > 0.2 then
					inertia = inertia - 0.015
				elseif inertia < 0.2 then
					inertia = inertia - 0.0001
				end
				if inertia < 0.1 then inertia = 0.0 end
				ApplyForceToEntity(PlayerPedId(), 1, 0.0, inertia, 0.0, 0.0, 0.0, 0.0, 0, true, 0, true, 0, 0)
			elseif z < groundZ and GetIsTaskActive(PlayerPedId(), 296) == 1 then
				-- SetEntityCoords(PlayerPedId(), x, y, groundZ)
				SetEntityCollision(PlayerPedId(), true, true)
				SetGravityLevel(0)
			end
			
			local velocity = GetEntityVelocity(PlayerPedId())
			local rotation = GetEntityRotation(PlayerPedId())
			SetEntityRotation(PlayerPedId(), clamp(velocity.z*5.0, -80.0, 80.0), rotation.y, rotation.z)
		
			-- SetTextFont(4)
			-- SetTextProportional(1)
			-- SetTextScale(0.0, 0.45)
			-- SetTextColour(255, 255, 255, 255)
			-- SetTextDropshadow(0, 0, 0, 0, 255)
			-- SetTextEdge(2, 0, 0, 0, 150)
			-- SetTextDropShadow()
			-- SetTextOutline()
			-- SetTextEntry("STRING")
			-- SetTextCentre(1)
			-- AddTextComponentString(tostring(inertia))
			-- DrawText(0.5, 0.01)
			
			if GetIsTaskActive(PlayerPedId(), 296) ~= 1 then
				SetEntityCollision(PlayerPedId(), true, true)
			end
			
			if GetIsTaskActive(PlayerPedId(), 296) == 1 and z > groundZ then
				local bonepos = GetPedBoneCoords(PlayerPedId(), 31086, 0.0, 0.0, 0.0)
				local cast = RaycastSphere(bonepos, 0.05)
				if cast and cast == 1 then
					SetPedToRagdoll(PlayerPedId(), 150, 150, 3)
					ClearPedTasks(PlayerPedId())
					StopScreenEffect("FocusIn")
					StartScreenEffect("FocusOut", 0, false)
					PlaySoundFrontend(-1, "FocusOut", "HintCamSounds", 1)
					SetTimeScale(1.0)
				end
			end
		
			SetPlayerForcedAim(PlayerId(), GetIsTaskActive(PlayerPedId(), 296))
			SetPedCanRagdoll(PlayerPedId(), not GetIsTaskActive(PlayerPedId(), 296))
		end
		
		Citizen.Wait(1)
	end
end)