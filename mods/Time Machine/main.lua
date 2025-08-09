tmmc = RegisterMod("timemachine", 1)
--------------------------------------------------------------
tmmc.ver = "1.7"
--Don’t change config here, it will works in “tmmc_config.lua” first.
tmmc.speedmin = 0
tmmc.speeda = 0.05
tmmc.speedmax = 5
tmmc.enable = {
  true,   --1.Slot Machine
  true,   --2.Blood Donation Machine
  true,   --3.Fortune Telling Machine
  true,   --4.Beggar
  true,   --5.Devil Beggar
  false,  --6.Shell Game
  true,   --7.Key Master
  false,   --8.Donation Machine
  true,   --9.Bomb Bum
  false,  --10.Shop Restock Machine
  false,  --11.Greed Donation Machine
  false,  --12.Mom's Dressing Table
  true,   --13.Battery Bum
  false,  --14.Isaac (secret)
  false,  --15.Hell Game
  true,   --16.Crane Game
  true,   --17.Confessional
  true,   --18.Rotten Beggar
}
include("tmmc_config") 
----------
tmmc.game = Game()
tmmc.playernum = 1
tmmc.player = {Isaac.GetPlayer(0)}
tmmc.room = Game():GetRoom()
tmmc.machines = {}
--tmmc.isbeggar = {}
tmmc.speed = {tmmc.speedmin}
tmmc.tar = {false}
--
tmmc.test = 0
----------
function tmmc:new_room()
  tmmc.playernum = tmmc.game:GetNumPlayers()
  tmmc.room = tmmc.game:GetRoom()
  --tmmc.machines = Isaac.FindByType(6, -1, -1, false, false)
  --tmmc.isbeggar = {}
  for i = 1, tmmc.playernum do
    tmmc.player[i] = Isaac.GetPlayer(i-1)
    tmmc.speed[i] = tmmc.speedmin
  end 
  tmmc:find_slot()
end
---
function tmmc:find_slot()
  tmmc.machines = {}
  --[[
  local slots = Isaac.FindByType(6, -1, -1, false, false) --EntityType.ENTITY_SLOT 
  for _, slot in ipairs(slots) do
    if slot.Variant <= 3 or slot.Variant == 16 or slot.Variant == 17 then --16 = crane game
      table.insert(tmmc.machines, slot)
      table.insert(tmmc.isbeggar, false)
    elseif slot.Variant <= 5 or slot.Variant == 7 or slot.Variant == 9 or slot.Variant == 13 or slot.Variant == 18 then
      table.insert(tmmc.machines, slot)
      table.insert(tmmc.isbeggar, true)
    end
  end
  ]]--
  local slots = Isaac.FindByType(6, -1, -1, false, false) --EntityType.ENTITY_SLOT 
  for _, slot in ipairs(slots) do
    if tmmc.enable[slot.Variant] then
      table.insert(tmmc.machines, slot)
    end
  end
end
--------
--main--
--------
function tmmc:step()
  if tmmc.machines[1] and tmmc.room:IsClear() then
    local timeplus = 0
    --
    for i = 1, tmmc.playernum do
      local pl = tmmc.player[i]
      tmmc.tar[i] = false
      for m, slot in ipairs(tmmc.machines) do    
        ----[=[
        if pl.Position:Distance(slot.Position) <= (pl.Size + slot.Size) then 
          tmmc.tar[i] = true
          --
          --if tmmc.isbeggar[m] then
          local dx = pl.Position.X - slot.Position.X
          local dy = pl.Position.Y - slot.Position.Y
          if math.abs(dx) < math.max(5, 6*pl.MoveSpeed) then
            if ((Input.IsActionPressed(ButtonAction.ACTION_UP,pl.ControllerIndex) and dy > 0) or (Input.IsActionPressed(ButtonAction.ACTION_DOWN,pl.ControllerIndex) and dy < 0))
            and (not Input.IsActionPressed(ButtonAction.ACTION_RIGHT,pl.ControllerIndex)) and (not Input.IsActionPressed(ButtonAction.ACTION_LEFT,pl.ControllerIndex)) then
              --Isaac.RenderText("1", 50, 148, 1, 1, 1, 1)--test
              pl.Position = Vector(pl.Position.X - dx/2, pl.Position.Y + dy/math.abs(dy) * (pl.Size + slot.Size - math.abs(dy))*(pl.MoveSpeed + tmmc.speed[i])/2)
            else
              --Isaac.RenderText("0", 50, 148, 1, 1, 1, 1)--test
            end
          end
          --end
          --
          for j = 1, math.floor(tmmc.speed[i]-0.5+math.random()) do
            slot:Update()
            --pl:ResetDamageCooldown()
            local p = pl.Position
            pl:Update()
            pl.Position = p    
            --[[
            if (slot.Variant == 2 or slot.Variant == 17) and pl:HasInvincibility() then
              local p = pl.Position
              pl:Update()
              pl.Position = p
            end
            ]]--
          end
        end
        --]=]--
      end   
        --      
      if tmmc.tar[i] then
        if tmmc.speed[i] <= tmmc.speedmax then
          tmmc.speed[i] = tmmc.speed[i] + tmmc.speeda
        end
      else
        tmmc.speed[i] = tmmc.speedmin
        tmmc:find_slot()
      end--
      local tt = math.floor(tmmc.speed[i]-1)
      if tt > timeplus then
        timeplus = tt
      end
      --
    end
    --
    --tmmc.test = timeplus
    Game().TimeCounter = Game().TimeCounter + timeplus
    Game().BlueWombParTime = Game().BlueWombParTime - timeplus
		Game().BossRushParTime = Game().BossRushParTime - timeplus
  end
end
---
function tmmc:step2()
  -------------
  --testusing--
  -------------
  Isaac.RenderText(tmmc.test, 50, 148, 1, 1, 1, 1)
  Isaac.RenderText(Isaac.GetFrameCount().."/"..Game():GetFrameCount().."/"..Game().TimeCounter.."/"..Game().BlueWombParTime.."/"..Game().BossRushParTime,50, 160, 1, 1, 1, 1)
  --[[
  if tmmc.player[1]:HasInvincibility() then
    Isaac.RenderText("1", 50, 148, 1, 1, 1, 1)
  else
    Isaac.RenderText("0", 50, 148, 1, 1, 1, 1)
  end
  ]]
end
--
function tmmc:start()
  Game().BlueWombParTime = 54000
	Game().BossRushParTime = 36000
end
--------------------------------------------------------------
tmmc:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, tmmc.new_room)
tmmc:AddCallback(ModCallbacks.MC_USE_CARD, tmmc.new_room)
tmmc:AddCallback(ModCallbacks.MC_POST_UPDATE, tmmc.step)
tmmc:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, tmmc.start)
--tmmc:AddCallback(ModCallbacks.MC_POST_RENDER, tmmc.step2)