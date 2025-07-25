

-- made by Freakman#1689 but modified to get custom gfx for chargebars

local defaultName = 'gfx/chargebar.anm2'

local Chargebar = setmetatable({

    SetCharge = function (self, amount, max)
        local last_charge = self.charge
        self.charge = amount
        self.max = max

        if amount <= 0 then
            if last_charge > 0 then -- play disappear if we had charge last frame
                self.state = "Disappear"
            end
            self.isCharged = false
        elseif amount < max then
            self.state = "Charging"
        elseif amount >= max and not self.isCharged then
            self.isCharged = true
            self.state = "StartCharged"
        end
    end,

    Render = function (self, pos, crop_min, crop_max)

        if self.state == "Charging" then -- handle charging state differently
            self.spr:SetFrame(self.state, math.floor((self.charge / self.max) * 100))
        elseif self.state ~= "None" then
            if self.spr:IsFinished(self.state) then -- transition to next state
                if self.state == "StartCharged" then
                    self.state = "Charged"
                elseif self.state == "Disappear" then
                    self.state = "None"
                end
            end

            if not self.spr:IsPlaying(self.state) then -- start playing current state if not playing already
                self.spr:Play(self.state, true)
            else
                if not self.inRenderClbk or self.inRenderClbk and Isaac.GetFrameCount() % 2 == 0 and not Game():IsPaused() then -- has to be played at half speed since we do it in render callback
                    self.spr:Update() -- update state :)
                end
            end
        elseif self.state == "None" then
            return
        end
        
        if Game():GetRoom():GetRenderMode() ~= 5 then --check added by me
            self.spr:Render(pos, crop_min, crop_max)
        end

    end

}, {
    __call = function (self, name, isRenderCallback)
        local sprite, check = Sprite(name, true)
        if not check then
            sprite = Sprite(defaultName, true)
        end
        local c = setmetatable({
            state = "None",
            charge = 0,
            max = 0,
            isCharged = false,
            spr = sprite,
            inRenderClbk = isRenderCallback
        }, {__index = self})
        return c
    end
})

return Chargebar