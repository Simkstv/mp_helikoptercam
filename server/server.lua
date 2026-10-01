-- ============================================================
-- RESOURCE START
-- ============================================================

AddEventHandler("onResourceStart", function(resourceName)
  if resourceName ~= GetCurrentResourceName() then
    return
  end
  print('MP VEHICLECAM is Running')
end)