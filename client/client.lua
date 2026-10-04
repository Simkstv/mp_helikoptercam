-- ============================================================
-- MrCatHat  - Michael Pollenski
-- ============================================================
local heliCam = nil
local activeVehicle = nil
local activeConfig = nil
local camPitch = 0.0
local camRotation = 0.0
local currentFov = 30.0
local visionMode = "normal"
local cameraActive = false
local lockTarget = nil
local lockTargetType = nil
local targetLocked = false
local vehicleCheckResult = nil
local vehicleCheckExpires = 0
-- ============================================================
-- HELPER
-- ============================================================
local function GetHelicopterConfig(vehicle)
  if not DoesEntityExist(vehicle) then
    return nil
  end
  local vehicleModel = GetEntityModel(vehicle)
  for modelName, config in pairs(Config.Cams) do
    if vehicleModel == joaat(modelName) then
      return config
    end
  end
  return nil
end
local function Clamp(value, minValue, maxValue)
  if value < minValue then
    return minValue
  end
  if value > maxValue then
    return maxValue
  end
  return value
end
-- ============================================================
-- CAMERA HUD
-- ============================================================
local function DrawHudText(x, y, text, scale, centre)
  SetTextFont(0)
  SetTextScale(0.0, scale)
  SetTextColour(255, 255, 255, 220)
  SetTextDropshadow(1, 0, 0, 0, 180)
  SetTextEdge(1, 0, 0, 0, 150)
  SetTextOutline()
  if centre then
    SetTextCentre(true)
  end
  BeginTextCommandDisplayText("STRING")
  AddTextComponentSubstringPlayerName(text)
  EndTextCommandDisplayText(x, y)
end
local function DrawHudLine(x, y, width, height)
  DrawRect(x, y, width, height, 255, 255, 255, 210)
end
local function DrawCameraCrosshair()
  local x = 0.5
  local y = 0.5
  -- Abstand um Mittelpunkt
  local gap = 0.008
  -- Länge
  local horizontalLength = 0.025
  local verticalLength = 0.035
  -- Dicke
  local thickness = 0.0015
  -- Links
  DrawHudLine(
    x - gap - (horizontalLength / 2),
    y,
    horizontalLength,
    thickness
  )
  -- Rechts
  DrawHudLine(
    x + gap + (horizontalLength / 2),
    y,
    horizontalLength,
    thickness
  )
  -- Oben
  DrawHudLine(
    x,
    y - gap - (verticalLength / 2),
    thickness,
    verticalLength
  )
  -- Unten
  DrawHudLine(
    x,
    y + gap + (verticalLength / 2),
    thickness,
    verticalLength
  )
  -- Mittelpunkt
  DrawRect(
    x,
    y,
    0.002,
    0.003,
    255,
    255,
    255,
    220
  )
end
local function DrawCorner(x, y, horizontalDirection, verticalDirection)
  local horizontalLength = 0.035
  local verticalLength = 0.055
  local thickness = 0.0015
  -- Horizontal
  DrawRect(
    x + ((horizontalLength / 2) * horizontalDirection),
    y,
    horizontalLength,
    thickness,
    255,
    255,
    255,
    190
  )
  -- Vertikal
  DrawRect(
    x,
    y + ((verticalLength / 2) * verticalDirection),
    thickness,
    verticalLength,
    255,
    255,
    255,
    190
  )
end
local function GetVisionLabel()
  if visionMode == "night" then
    return "NV"
  end
  if visionMode == "thermal" then
    return "THERMAL"
  end
  return "NORM"
end
local function GetZoomValue()
  if not activeConfig then
    return 1.0
  end
  -- Anzeige als relativer Zoomwert.
  -- max_fov = 1x
  -- kleineres FOV = höherer Zoom
  local safeFov = math.max(currentFov, 0.1)
  return activeConfig.max_fov / safeFov
end
local function DrawCameraHUD()
  if not cameraActive or not activeVehicle then
    return
  end
  -- --------------------------------------------------------
  -- BEDIENHINWEIS UNTEN MITTIG
  -- --------------------------------------------------------
  DrawRect(
    0.5,
    0.925,
    0.315,
    0.035,
    0,
    0,
    0,
    140
  )
  DrawHudText(
    0.5,
    0.914,
    "[ N ]  Modus ändern [ L ] Target Lock [ G ] Fahrzeuginfo",
    0.32,
    true
  )
  -- --------------------------------------------------------
  -- schwarze leichte Balken
  -- --------------------------------------------------------
  DrawRect(
    0.5,
    0.025,
    1.0,
    0.05,
    0,
    0,
    0,
    100
  )
  DrawRect(
    0.5,
    0.975,
    1.0,
    0.05,
    0,
    0,
    0,
    100
  )
  -- --------------------------------------------------------
  -- Kameraecken
  -- --------------------------------------------------------
  DrawCorner(0.055, 0.09, 1, 1)
  DrawCorner(0.945, 0.09, -1, 1)
  DrawCorner(0.055, 0.91, 1, -1)
  DrawCorner(0.945, 0.91, -1, -1)
  -- --------------------------------------------------------
  -- Fadenkreuz
  -- --------------------------------------------------------
  DrawCameraCrosshair()
  -- --------------------------------------------------------
  -- Fahrzeugdaten
  -- --------------------------------------------------------
  local heading = GetEntityHeading(activeVehicle)
  local coords = GetEntityCoords(activeVehicle)
  -- GTA-Meter -> Fuß
  local altitudeFeet = coords.z * 3.28084
  local speed = GetEntitySpeed(activeVehicle)
  -- m/s -> knots
  local knots = speed * 1.94384
  -- --------------------------------------------------------
  -- Zoom
  -- --------------------------------------------------------
  local zoom = GetZoomValue()
  -- --------------------------------------------------------
  -- LINKS OBEN
  -- --------------------------------------------------------
  DrawHudText(
    0.065,
    0.095,
    activeConfig.name or "AIR UNIT",
    0.38,
    false
  )
  -- --------------------------------------------------------
  -- RECHTS OBEN
  -- --------------------------------------------------------
  DrawHudText(
    0.865,
    0.095,
    "CAM ACTIVE",
    0.35,
    false
  )
  -- --------------------------------------------------------
  -- LINKS UNTEN
  -- --------------------------------------------------------
  DrawHudText(
    0.065,
    0.810,
    GetVisionLabel(),
    0.38,
    false
  )
  DrawHudText(
    0.065,
    0.835,
    string.format(
      "HDG %03d",
      math.floor(heading)
    ),
    0.34,
    false
  )
  DrawHudText(
    0.065,
    0.860,
    string.format(
      "CAM ROT %+.0f",
      camRotation
    ),
    0.34,
    false
  )
  DrawHudText(
    0.065,
    0.885,
    string.format(
      "SPD %03d KT",
      math.floor(knots)
    ),
    0.34,
    false
  )
  -- --------------------------------------------------------
  -- RECHTS UNTEN
  -- --------------------------------------------------------
  DrawHudText(
    0.850,
    0.835,
    string.format(
      "ZOOM %.1fx",
      zoom
    ),
    0.36,
    false
  )
  DrawHudText(
    0.850,
    0.860,
    string.format(
      "ALT %04d FT",
      math.floor(altitudeFeet)
    ),
    0.34,
    false
  )
  local lockLabel = "LOCK ----"
  if targetLocked and lockTargetType then
    lockLabel = "LOCK " .. lockTargetType
  end
  DrawHudText(
    0.850,
    0.885,
    lockLabel,
    0.34,
    false
  )
  if vehicleCheckResult and GetGameTimer() < vehicleCheckExpires then
  local status = vehicleCheckResult.registered and "REGISTERED" or "NOT REGISTERED"

  DrawHudText(
    0.065,
    0.440,
    "VEHICLE CHECK",
    0.38,
    false
  )

  if Config.VehicleCheck.showPlate then
    DrawHudText(
      0.065,
      0.465,
      "PLATE " .. (vehicleCheckResult.plate or "----"),
      0.34,
      false
    )
  end

  DrawHudText(
    0.065,
    0.490,
    "STATUS " .. status,
    0.34,
    false
  )

  if Config.VehicleCheck.showOwner and vehicleCheckResult.owner and vehicleCheckResult.owner ~= "" then
    DrawHudText(
      0.065,
      0.515,
      "OWNER " .. vehicleCheckResult.owner,
      0.34,
      false
    )
  end

  if Config.VehicleCheck.showModel and vehicleCheckResult.model and vehicleCheckResult.model ~= "" then
    DrawHudText(
      0.065,
      0.540,
      "MODEL " .. vehicleCheckResult.model,
      0.34,
      false
    )
  end
  elseif vehicleCheckResult then
    vehicleCheckResult = nil
  end
end
-- ============================================================
-- VISION
-- ============================================================
local function ResetVision()
  SetNightvision(false)
  SetSeethrough(false)
  visionMode = "normal"
end
local function ChangeVisionMode()
  if not cameraActive or not activeConfig then
    return
  end
  -- Normal -> Nightvision
  if visionMode == "normal" then
    if activeConfig.nightVision then
      SetNightvision(true)
      SetSeethrough(false)
      visionMode = "night"
      return
    end
    if activeConfig.thermalVision then
      SetNightvision(false)
      SetSeethrough(true)
      visionMode = "thermal"
      return
    end
  end
  -- Nightvision -> Thermal
  if visionMode == "night" then
    if activeConfig.thermalVision then
      SetNightvision(false)
      SetSeethrough(true)
      visionMode = "thermal"
      return
    end
    SetNightvision(false)
    SetSeethrough(false)
    visionMode = "normal"
    return
  end
  -- Thermal -> Normal
  if visionMode == "thermal" then
    SetNightvision(false)
    SetSeethrough(false)
    visionMode = "normal"
    return
  end
end
-- ============================================================
-- CAMERA CREATE
-- ============================================================
local function OpenHelicopterCamera(vehicle, config)
  local ped = PlayerPedId()
  if not Config.DevMode then
    if GetPedInVehicleSeat(vehicle, -1) == ped then
      return
    end
  end
  if cameraActive then
    return
  end
  activeVehicle = vehicle
  activeConfig = config
  camPitch = config.min_pitch
  camRotation = 0.0
  currentFov = config.max_fov
  local relativeCoords = config.relativeCoords
  heliCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
  AttachCamToEntity(
    heliCam,
    vehicle,
    relativeCoords.x,
    relativeCoords.y,
    relativeCoords.z,
    true
  )
  SetCamRot(
    heliCam,
    camPitch,
    0.0,
    relativeCoords.w + camRotation,
    2
  )
  SetCamFov(
    heliCam,
    currentFov
  )
  SetCamActive(
    heliCam,
    true
  )
  RenderScriptCams(
    true,
    false,
    0,
    true,
    true
  )
  cameraActive = true
  ResetVision()
end
-- ============================================================
-- CAMERA CLOSE
-- ============================================================
local function CloseHelicopterCamera()
  if not cameraActive then
    return
  end
  ResetVision()
  RenderScriptCams(
    false,
    false,
    0,
    true,
    true
  )
  if heliCam and DoesCamExist(heliCam) then
    StopCamPointing(heliCam)
    DestroyCam(heliCam, false)
  end
  heliCam = nil
  activeVehicle = nil
  activeConfig = nil
  lockTarget = nil
  lockTargetType = nil
  targetLocked = false
  vehicleCheckResult = nil
  vehicleCheckExpires = 0
  cameraActive = false
end
local function RotationToDirection(rotation)
  local adjustedRotation = vector3(
    math.rad(rotation.x),
    math.rad(rotation.y),
    math.rad(rotation.z)
  )
  return vector3(
    -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
    math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
    math.sin(adjustedRotation.x)
  )
end
local function GetCameraTarget()
  if not heliCam or not DoesCamExist(heliCam) then
    return nil, nil
  end
  local camCoords = GetCamCoord(heliCam)
  local camRotation = GetCamRot(heliCam, 2)
  local direction = RotationToDirection(camRotation)
  local distance = 2000.0
  local destination = camCoords + (direction * distance)
  local ray = StartShapeTestRay(
    camCoords.x,
    camCoords.y,
    camCoords.z,
    destination.x,
    destination.y,
    destination.z,
    -1,
    activeVehicle,
    0
  )
  local _, hit, _, _, entity = GetShapeTestResult(ray)
  if hit ~= 1 or entity == 0 or not DoesEntityExist(entity) then
    return nil, nil
  end
  if IsEntityAVehicle(entity) then
    return entity, "VEHICLE"
  end
  if IsEntityAPed(entity) then
    return entity, "PERSON"
  end
  return nil, nil
end
local function ClearTargetLock()
  if heliCam and DoesCamExist(heliCam) then
    StopCamPointing(heliCam)
  end
  lockTarget = nil
  lockTargetType = nil
  targetLocked = false
end
local function ToggleTargetLock()
  if not cameraActive or not activeConfig or activeConfig.lockOn == false then
    return
  end
  if targetLocked then
    ClearTargetLock()
    return
  end
  local entity, targetType = GetCameraTarget()
  if not entity then
    return
  end
  lockTarget = entity
  lockTargetType = targetType
  targetLocked = true
end
local function HandleTargetLock()
  if not targetLocked then
    return
  end
  if not lockTarget or not DoesEntityExist(lockTarget) then
    ClearTargetLock()
    return
  end
  local targetCoords
  if lockTargetType == "PERSON" then
    local boneIndex = GetPedBoneIndex(lockTarget, 24818)
    targetCoords = GetWorldPositionOfEntityBone(lockTarget, boneIndex)
  else
    targetCoords = GetEntityCoords(lockTarget)
  end
  PointCamAtCoord(
    heliCam,
    targetCoords.x,
    targetCoords.y,
    targetCoords.z
  )
end
-- ============================================================
-- VEHICLE CHECK
-- ============================================================
local function VehicleCheck()
  if not cameraActive or not activeConfig or activeConfig.vehicleCheck ~= true then
    return
  end
  if not Config.VehicleCheck or Config.VehicleCheck.enabled ~= true then
    return
  end
  local vehicle = nil
  if targetLocked and lockTargetType == "VEHICLE" and lockTarget and DoesEntityExist(lockTarget) then
    vehicle = lockTarget
  else
    local entity, targetType = GetCameraTarget()
    if entity and targetType == "VEHICLE" then
      vehicle = entity
    end
  end
  if not vehicle then
    return
  end
  local plate = GetVehicleNumberPlateText(vehicle)
  if not plate then
    return
  end
  plate = plate:gsub("^%s*(.-)%s*$", "%1")
  if plate == "" then
    return
  end
  TriggerServerEvent("mp_vehiclecam:server:vehicleCheck", plate)
end

RegisterNetEvent("mp_vehiclecam:client:vehicleCheckResult", function(result)
  if not cameraActive or type(result) ~= "table" then
    return
  end
  vehicleCheckResult = result
  vehicleCheckExpires = GetGameTimer() + (Config.VehicleCheck.displayTime or 8000)
end)
-- ============================================================
-- CAMERA ROTATION
-- ============================================================
local function HandleCameraMovement()
  if targetLocked then
    return
  end
  if not cameraActive then
    return
  end
  if not activeConfig then
    return
  end
  DisableControlAction(0, 1, true)
  DisableControlAction(0, 2, true)
  local mouseX = GetDisabledControlNormal(0, 1)
  local mouseY = GetDisabledControlNormal(0, 2)
  local sensitivity = 4.0
  camRotation = camRotation - (mouseX * sensitivity)
  camPitch = camPitch - (mouseY * sensitivity)
  camRotation = Clamp(
    camRotation,
    activeConfig.min_rot,
    activeConfig.max_rot
  )
  camPitch = Clamp(
    camPitch,
    activeConfig.min_pitch,
    activeConfig.max_pitch
  )
  local baseRotation = activeConfig.relativeCoords.w
  SetCamRot(
    heliCam,
    camPitch,
    0.0,
    baseRotation + camRotation,
    2
  )
end
-- ============================================================
-- CAMERA ZOOM
-- ============================================================
local function HandleCameraZoom()
  if not cameraActive then
    return
  end
  if not activeConfig then
    return
  end
  -- Mouse Wheel Up
  if IsControlJustPressed(0, 241) then
    currentFov = currentFov - 2.0
  end
  -- Mouse Wheel Down
  if IsControlJustPressed(0, 242) then
    currentFov = currentFov + 2.0
  end
  currentFov = Clamp(
    currentFov,
    activeConfig.min_fov,
    activeConfig.max_fov
  )
  SetCamFov(
    heliCam,
    currentFov
  )
end
-- ============================================================
-- MAIN CAMERA THREAD
-- ============================================================
CreateThread(function()
  while true do
    if cameraActive then
      -- Kamera verlassen
      DisableControlAction(0, 177, true)
      if IsDisabledControlJustPressed(0, 177) then
        CloseHelicopterCamera()
      end
      -- Prüfen, ob Fahrzeug noch existiert
      if not DoesEntityExist(activeVehicle) then
        CloseHelicopterCamera()
      else
          -- Prüfen, ob Spieler noch im gleichen Fahrzeug sitzt
          local ped = PlayerPedId()
          local currentVehicle = GetVehiclePedIsIn(ped, false)
          if currentVehicle ~= activeVehicle then
            CloseHelicopterCamera()
          end
      end
      if cameraActive then
        HandleCameraMovement()
        HandleCameraZoom()
        HandleTargetLock()
        DrawCameraHUD()
        -- N = Vision Mode wechseln
        if IsControlJustPressed(0, 249) then
          ChangeVisionMode()
        end
      end
      Wait(0)
    else
      Wait(500)
    end
  end
end)
-- ============================================================
-- COMMAND
-- ============================================================
RegisterCommand("helicam", function()
  local ped = PlayerPedId()
  if cameraActive then
    CloseHelicopterCamera()
    return
  end
  local vehicle = GetVehiclePedIsIn(ped, false)
  if vehicle == 0 then
    if Config.DevMode then
      print("^1[SBR HELICAM]^7 Du sitzt in keinem Fahrzeug.")
    end
    return
  end
  local config = GetHelicopterConfig(vehicle)
  if not config then
    if Config.DevMode then
      print("^1[SBR HELICAM]^7 Dieses Fahrzeug besitzt keine Kamera.")
    end
    return
  end
  OpenHelicopterCamera(
    vehicle,
    config
  )
end, false)
-- ============================================================
-- KEYBIND
-- ============================================================
-- ============================================================
-- TARGET LOCK
-- ============================================================
RegisterCommand("helicam_lock", function()
  if not cameraActive then
    return
  end
  ToggleTargetLock()
end, false)
RegisterKeyMapping(
  "helicam_lock",
  "Helikopterkamera Ziel fixieren",
  "keyboard",
  "L"
)
RegisterCommand("helicam_vehiclecheck", function()
  VehicleCheck()
end, false)
RegisterKeyMapping(
  "helicam_vehiclecheck",
  "Helikopterkamera Fahrzeugabfrage",
  "keyboard",
  "G"
)
RegisterKeyMapping(
  "helicam",
  "Helikopterkamera öffnen",
  "keyboard",
  "E"
)
-- ============================================================
-- RESOURCE STOP
-- ============================================================
AddEventHandler("onResourceStop", function(resourceName)
  if resourceName ~= GetCurrentResourceName() then
    return
  end
  if cameraActive then
    CloseHelicopterCamera()
  end
  SetNightvision(false)
  SetSeethrough(false)
end)
