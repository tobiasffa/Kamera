-- ███╗░░░███╗███████╗░██████╗████████╗███████╗██████╗░██████╗░░█████╗░██████╗░██╗░░░░░░█████╗░
--████╗░████║██╔════╝██╔════╝╚══██╔══╝██╔════╝██╔══██╗██╔══██╗██╔══██╗██╔══██╗██║░░░░░██╔══██╗
--██╔████╔██║█████╗░░╚█████╗░░░░██║░░░█████╗░░██████╔╝██████╔╝███████║██████╦╝██║░░░░░██║░░██║
--██║╚██╔╝██║██╔══╝░░░╚═══██╗░░░██║░░░██╔══╝░░██╔══██╗██╔═══╝░██╔══██║██╔══██╗██║░░░░░██║░░██║
--██║░╚═╝░██║███████╗██████╔╝░░░██║░░░███████╗██║░░██║██║░░░░░██║░░██║██████╦╝███████╗╚█████╔╝
--╚═╝░░░░░╚═╝╚══════╝╚═════╝░░░░╚═╝░░░╚══════╝╚═╝░░╚═╝╚═╝░░░░░╚═╝░░╚═╝╚═════╝░╚══════╝░╚════╝░
local cameraActive = false
local currentCameraIndex = 0
local currentCameraIndexIndex = 0
local createdCamera = 0


Citizen.CreateThread(function()
    while true do
        for a = 1, #SecurityCamConfig.Locations do
            local ped = GetPlayerPed(PlayerId())
            local pedPos = GetEntityCoords(ped, false)
            local pedHead = GetEntityRotation(ped, 2)
            local distance = Vdist(pedPos.x, pedPos.y, pedPos.z, SecurityCamConfig.Locations[a].camBox.x, SecurityCamConfig.Locations[a].camBox.y, SecurityCamConfig.Locations[a].camBox.z)
            if SecurityCamConfig.DebugMode then
                DrawText3Ds(pedPos.x, pedPos.y, pedPos.z + 0.6, tostring("X: " .. pedPos.x))
                DrawText3Ds(pedPos.x, pedPos.y, pedPos.z + 0.4, tostring("Y: " .. pedPos.y))
                DrawText3Ds(pedPos.x, pedPos.y, pedPos.z + 0.2, tostring("Z: " .. pedPos.z))
                DrawText3Ds(pedPos.x, pedPos.y, pedPos.z, tostring("H: " .. pedHead))
            end
            local pedAllowed = false
            if #SecurityCamConfig.Locations[a].allowedModels >= 1 then
                pedAllowed = IsPedAllowed(ped, SecurityCamConfig.Locations[a].allowedModels)
            else
                pedAllowed = true
            end

            if pedAllowed then
                if distance <= 5.0 then
                    local box_label = SecurityCamConfig.Locations[a].camBox.label
                    local box_x = SecurityCamConfig.Locations[a].camBox.x
                    local box_y = SecurityCamConfig.Locations[a].camBox.y
                    local box_z = SecurityCamConfig.Locations[a].camBox.z
                    DrawText3Ds(box_x, box_y, box_z-0.8, tostring("~r~[H]~w~ for at se " .. box_label .. "'s overvågning"))
                    if IsControlJustPressed(1, 304) and createdCamera == 0 and distance <= 5 then
                        local firstCamx = SecurityCamConfig.Locations[a].cameras[1].x
                        local firstCamy = SecurityCamConfig.Locations[a].cameras[1].y
                        local firstCamz = SecurityCamConfig.Locations[a].cameras[1].z
                        local firstCamr = SecurityCamConfig.Locations[a].cameras[1].r
                        SetFocusArea(firstCamx, firstCamy, firstCamz, firstCamx, firstCamy, firstCamz)
                        ChangeSecurityCamera(firstCamx, firstCamy, firstCamz, firstCamr)
                        SendNUIMessage({
                            type = "enablecam",
                            label = SecurityCamConfig.Locations[a].cameras[1].label,
                            box = SecurityCamConfig.Locations[a].camBox.label
                        })
                        currentCameraIndex = a
                        currentCameraIndexIndex = 1
                        FreezeEntityPosition(GetPlayerPed(PlayerId()), true)
                    end
                end
            end

            if createdCamera ~= 0 then
                local instructions = CreateInstuctionScaleform("instructional_buttons")
                DrawScaleformMovieFullscreen(instructions, 255, 255, 255, 255, 0)
                SetTimecycleModifier("scanline_cam_cheap")
                SetTimecycleModifierStrength(2.0)

                if SecurityCamConfig.HideRadar then
                    DisplayRadar(false)
                end

                -- CLOSE CAMERAS
                if IsControlJustPressed(1, 194) then
                    CloseSecurityCamera()
                    SendNUIMessage({
                        type = "disablecam",
                    })
			if SecurityCamConfig.HideRadar then
                    	   DisplayRadar(true)
                	end
                end

                -- GO BACK CAMERA
                if IsControlJustPressed(1, 174) then
                    local newCamIndex

                    if currentCameraIndexIndex == 1 then
                        newCamIndex = #SecurityCamConfig.Locations[currentCameraIndex].cameras
                    else
                        newCamIndex = currentCameraIndexIndex - 1
                    end

                    local newCamx = SecurityCamConfig.Locations[currentCameraIndex].cameras[newCamIndex].x
                    local newCamy = SecurityCamConfig.Locations[currentCameraIndex].cameras[newCamIndex].y
                    local newCamz = SecurityCamConfig.Locations[currentCameraIndex].cameras[newCamIndex].z
                    local newCamr = SecurityCamConfig.Locations[currentCameraIndex].cameras[newCamIndex].r
                    SetFocusArea(newCamx, newCamy, newCamz, newCamx, newCamy, newCamz)
                    SendNUIMessage({
                        type = "updatecam",
                        label = SecurityCamConfig.Locations[currentCameraIndex].cameras[newCamIndex].label
                    })
                    ChangeSecurityCamera(newCamx, newCamy, newCamz, newCamr)
                    currentCameraIndexIndex = newCamIndex
                end

                -- GO FORWARD CAMERA
                if IsControlJustPressed(1, 175) then
                    local newCamIndex
                    
                    if currentCameraIndexIndex == #SecurityCamConfig.Locations[currentCameraIndex].cameras then
                        newCamIndex = 1
                    else
                        newCamIndex = currentCameraIndexIndex + 1
                    end

                    local newCamx = SecurityCamConfig.Locations[currentCameraIndex].cameras[newCamIndex].x
                    local newCamy = SecurityCamConfig.Locations[currentCameraIndex].cameras[newCamIndex].y
                    local newCamz = SecurityCamConfig.Locations[currentCameraIndex].cameras[newCamIndex].z
                    local newCamr = SecurityCamConfig.Locations[currentCameraIndex].cameras[newCamIndex].r
                    SetFocusArea(newCamx, newCamy, newCamz, newCamx, newCamy, newCamz)
                    SendNUIMessage({
                        type = "updatecam",
                        label = SecurityCamConfig.Locations[currentCameraIndex].cameras[newCamIndex].label
                    })
                    ChangeSecurityCamera(newCamx, newCamy, newCamz, newCamr)
                    currentCameraIndexIndex = newCamIndex
                end

                ---------------------------------------------------------------------------
                -- CAMERA ROTATION CONTROLS
                ---------------------------------------------------------------------------
                if SecurityCamConfig.Locations[currentCameraIndex].cameras[currentCameraIndexIndex].canRotate then
                    local getCameraRot = GetCamRot(createdCamera, 2)

                    -- ROTATE UP
                    if IsControlPressed(1, 32) then
                        if getCameraRot.x <= 0.0 then
                            SetCamRot(createdCamera, getCameraRot.x + 0.7, 0.0, getCameraRot.z, 2)
                        end
                    end

                    -- ROTATE DOWN
                    if IsControlPressed(1, 33) then
                        if getCameraRot.x >= -50.0 then
                            SetCamRot(createdCamera, getCameraRot.x - 0.7, 0.0, getCameraRot.z, 2)
                        end
                    end

                    -- ROTATE LEFT
                    if IsControlPressed(1, 34) then
                        SetCamRot(createdCamera, getCameraRot.x, 0.0, getCameraRot.z + 0.7, 2)
                    end

                    -- ROTATE RIGHT
                    if IsControlPressed(1, 35) then
                        SetCamRot(createdCamera, getCameraRot.x, 0.0, getCameraRot.z - 0.7, 2)
                    end
                end
            end
        end
        Citizen.Wait(0)
    end
end)

---------------------------------------------------------------------------
-- FUNCTIONS
---------------------------------------------------------------------------
function ChangeSecurityCamera(x, y, z, r)
    if createdCamera ~= 0 then
        DestroyCam(createdCamera, 0)
        createdCamera = 0
    end

    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
    SetCamCoord(cam, x, y, z)
    SetCamRot(cam, r.x, r.y, r.z, 2)
    RenderScriptCams(1, 0, 0, 1, 1)
    Citizen.Wait(250)
    createdCamera = cam
end

function CloseSecurityCamera()
    DestroyCam(createdCamera, 0)
    RenderScriptCams(0, 0, 1, 1, 1)
    createdCamera = 0
    ClearTimecycleModifier("scanline_cam_cheap")
    SetFocusEntity(GetPlayerPed(PlayerId()))
    if SecurityCamConfig.HideRadar then
        DisplayRadar(true)
    end
    FreezeEntityPosition(GetPlayerPed(PlayerId()), false)
end

function DrawText3Ds(x,y,z, text)
	local onScreen,_x,_y=World3dToScreen2d(x,y,z)
	local px,py,pz=table.unpack(GetGameplayCamCoords())
	SetTextScale(0.35, 0.35)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextColour(255, 255, 255, 215)
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(text)
	DrawText(_x,_y)
	local factor = (string.len(text)) / 370
	DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

function IsPedAllowed(ped, pedList)
    for i = 1, #pedList do
		if GetHashKey(pedList[i]) == GetEntityModel(ped) then
			return true
		end
	end
    return false
end

function CreateInstuctionScaleform(scaleform)
    local scaleform = RequestScaleformMovie(scaleform)
    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(0)
    end
    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()
    
    PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(0)
    InstructionButton(GetControlInstructionalButton(1, 175, true))
    InstructionButtonMessage("Næste kamera")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(1)
    InstructionButton(GetControlInstructionalButton(1, 194, true))
    InstructionButtonMessage("Luk overvågning")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(2)
    InstructionButton(GetControlInstructionalButton(1, 174, true))
    InstructionButtonMessage("Forrige kamera")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(80)
    PopScaleformMovieFunctionVoid()

    return scaleform
end

function InstructionButton(ControlButton)
    N_0xe83a3e3557a56640(ControlButton)
end

function InstructionButtonMessage(text)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(text)
    EndTextCommandScaleformString()
end
