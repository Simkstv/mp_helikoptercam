-- ============================================================
-- FRAMEWORK
-- ============================================================
local framework = "standalone"

local function DetectFramework()
  if Config.VehicleCheck.framework and Config.VehicleCheck.framework ~= "auto" then
    return Config.VehicleCheck.framework
  end
  if GetResourceState("ox_core") == "started" then
    return "ox"
  end
  if GetResourceState("es_extended") == "started" then
    return "esx"
  end
  if GetResourceState("qb-core") == "started" then
    return "qb"
  end
  return "standalone"
end

local function IsSafeIdentifier(value)
  return type(value) == "string" and value:match("^[%w_]+$") ~= nil
end

local function TrimPlate(plate)
  if type(plate) ~= "string" then
    return nil
  end
  plate = plate:gsub("^%s*(.-)%s*$", "%1")
  if plate == "" or #plate > 16 then
    return nil
  end
  return plate
end

local function DecodeJson(value)
  if type(value) ~= "string" or value == "" then
    return nil
  end
  local ok, data = pcall(json.decode, value)
  if not ok then
    return nil
  end
  return data
end

local function GetDatabaseConfig()
  if not Config.VehicleCheck or not Config.VehicleCheck.database then
    return nil
  end
  return Config.VehicleCheck.database[framework]
end

local function GetVehicleByPlate(plate)
  local db = GetDatabaseConfig()
  if not db then
    return nil
  end

  local identifiers = {
    db.vehicleTable,
    db.plateColumn,
    db.ownerColumn,
    db.modelColumn
  }

  for _, identifier in ipairs(identifiers) do
    if not IsSafeIdentifier(identifier) then
      return nil
    end
  end

  local query = ("SELECT `%s` AS owner, `%s` AS model FROM `%s` WHERE `%s` = ? LIMIT 1"):format(
    db.ownerColumn,
    db.modelColumn,
    db.vehicleTable,
    db.plateColumn
  )

  return exports.oxmysql:single_async(query, { plate })
end

local function GetOwnerName(ownerId)
  local db = GetDatabaseConfig()
  if not db or not ownerId then
    return nil
  end

  local identifiers = {
    db.ownerTable,
    db.ownerIdColumn,
    db.firstNameColumn,
    db.lastNameColumn
  }

  for _, identifier in ipairs(identifiers) do
    if not IsSafeIdentifier(identifier) then
      return nil
    end
  end

  if framework == "qb" then
    local query = ("SELECT `%s` AS charinfo FROM `%s` WHERE `%s` = ? LIMIT 1"):format(
      db.firstNameColumn,
      db.ownerTable,
      db.ownerIdColumn
    )

    local owner = exports.oxmysql:single_async(query, { ownerId })

    if not owner then
      return nil
    end

    local charinfo = DecodeJson(owner.charinfo)

    if not charinfo then
      return nil
    end

    local firstName = charinfo.firstname or charinfo.firstName
    local lastName = charinfo.lastname or charinfo.lastName

    return ((firstName or "") .. " " .. (lastName or "")):gsub("^%s*(.-)%s*$", "%1")
  end

  local query = ("SELECT `%s` AS firstname, `%s` AS lastname FROM `%s` WHERE `%s` = ? LIMIT 1"):format(
    db.firstNameColumn,
    db.lastNameColumn,
    db.ownerTable,
    db.ownerIdColumn
  )

  local owner = exports.oxmysql:single_async(query, { ownerId })

  if not owner then
    return nil
  end

  return ((owner.firstname or "") .. " " .. (owner.lastname or "")):gsub("^%s*(.-)%s*$", "%1")
end

local function GetVehicleModel(value)
  if value == nil then
    return nil
  end

  if framework == "esx" then
    local vehicleData = DecodeJson(value)

    if vehicleData and vehicleData.model then
      return tostring(vehicleData.model)
    end
  end

  return tostring(value)
end

-- ============================================================
-- VEHICLE CHECK
-- ============================================================
RegisterNetEvent("mp_vehiclecam:server:vehicleCheck", function(plate)
  local source = source

  if not Config.VehicleCheck or Config.VehicleCheck.enabled ~= true then
    return
  end

  plate = TrimPlate(plate)

  if not plate then
    return
  end

  local vehicle = GetVehicleByPlate(plate)

  local result = {
    plate = plate,
    registered = vehicle ~= nil,
    owner = nil,
    model = nil
  }

  if vehicle then
    if Config.VehicleCheck.showOwner then
      result.owner = GetOwnerName(vehicle.owner)
    end

    if Config.VehicleCheck.showModel then
      result.model = GetVehicleModel(vehicle.model)
    end
  end

  TriggerClientEvent(
    "mp_vehiclecam:client:vehicleCheckResult",
    source,
    result
  )
end)

-- ============================================================
-- RESOURCE START
-- ============================================================
AddEventHandler("onResourceStart", function(resourceName)
  if resourceName ~= GetCurrentResourceName() then
    return
  end

  framework = DetectFramework()

  print("MP VEHICLECAM is Running")
  print(("MP VEHICLECAM Framework: %s"):format(framework))
end)