-- Originally made using ddeeddii.github.io/ezitems-web/

local mod = RegisterMod("Epic copyright infringement", 1)

local items = {
  { 527, "Mr. Meeseeks",   "Caaan do!" },
  { 382, "Pokeball",       "Gotta catch em all!" },
  { 353, "Bomberman",      "Explosive blast!" },
  { 147, "Notchs Axe",     "Rocks dont stand a chance" },
  { 125, "Bomb-omb",       "Homing bombs" },
  { 12,  "Super Mushroom", "All stats up!" },
  { 93,  "The GameBoy",    "Temporary Pac-Man" },
}

local game = Game()
if EID then
  for _, item in ipairs(items) do
    local EIDdescription = EID:getDescriptionData(5, 100, item[1])[3]
    EID:addCollectible(item[1], EIDdescription, item[2], "en_us")
  end
end

if Encyclopedia then
  for _, item in ipairs(items) do
    Encyclopedia.UpdateItem(item[1], {
      Name = item[2],
      Description = item[3],
    })
  end
end

if #items ~= 0 then
  local i_queueLastFrame
  local i_queueNow
  mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
    i_queueNow = player.QueuedItem.Item
    if (i_queueNow ~= nil) then
      for _, item in ipairs(items) do
        if (i_queueNow.ID == item[1] and i_queueNow:IsCollectible() and i_queueLastFrame == nil) then
          game:GetHUD():ShowItemText(item[2], item[3])
        end
      end
    end
    i_queueLastFrame = i_queueNow
  end)
end
