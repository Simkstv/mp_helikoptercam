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
    0.115,
    0.035,
    0,
    0,
    0,
    140
  )

  DrawHudText(
    0.5,
    0.914,
    "[ N ]  Modus ändern",
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
  if GetPedInVehicleSeat(vehicle, -1) == ped then
    return
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

  if DoesCamExist(heliCam) then
    DestroyCam(heliCam, false)
  end

  heliCam = nil
  activeVehicle = nil
  activeConfig = nil

  cameraActive = false
end


-- ============================================================
-- CAMERA ROTATION
-- ============================================================

local function HandleCameraMovement()
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
    print("^1[SBR HELICAM]^7 Du sitzt in keinem Fahrzeug.")
    return
  end

  local config = GetHelicopterConfig(vehicle)

  if not config then
    print("^1[SBR HELICAM]^7 Dieses Fahrzeug besitzt keine Kamera.")
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


