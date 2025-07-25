local ____lualib = require("lualib_bundle")
local __TS__Class = ____lualib.__TS__Class
local Error = ____lualib.Error
local RangeError = ____lualib.RangeError
local ReferenceError = ____lualib.ReferenceError
local SyntaxError = ____lualib.SyntaxError
local TypeError = ____lualib.TypeError
local URIError = ____lualib.URIError
local __TS__New = ____lualib.__TS__New
local ____exports = {}
local ____CueTypeAnimationName = require("CueTypeAnimationName")
local CueTypeAnimationName = ____CueTypeAnimationName.CueTypeAnimationName
____exports.CueRenderer = __TS__Class()
local CueRenderer = ____exports.CueRenderer
CueRenderer.name = "CueRenderer"
function CueRenderer.prototype.____constructor(self, cueTypeAnimationName, cueAnimationName)
    self.cueTypeAnimationName = cueTypeAnimationName
    self.cueAnimationName = cueAnimationName
    self.cueSprite = Sprite()
    self.cueTypeSprite = Sprite()
    self.cueSprite:Load("gfx/cues.anm2", true)
    self.cueTypeSprite:Load("gfx/cue_types.anm2", true)
end
function CueRenderer.prototype.reset(self)
    self.cueSprite:Play(self.cueAnimationName, true)
    self.cueTypeSprite:Play(self.cueTypeAnimationName, true)
end
function CueRenderer.prototype.render(self, x, y, initialFrame)
    local currentAnimationFrame = Game():GetFrameCount() - initialFrame
    if currentAnimationFrame > ____exports.CueRenderer.RENDER_DURATION_FRAMES then
        return
    end
    self.cueSprite:Render(Vector(x, y))
    if self:shouldRenderCueTypeSprite(currentAnimationFrame) then
        self.cueTypeSprite:Render(Vector(x + ____exports.CueRenderer.CUE_TYPE_ICON_X_OFFSET, y + ____exports.CueRenderer.CUE_TYPE_ICON_Y_OFFSET))
    end
end
function CueRenderer.prototype.shouldRenderCueTypeSprite(self, currentAnimationFrame)
    if self.cueTypeAnimationName == CueTypeAnimationName.Info then
        return math.sin(math.pi * currentAnimationFrame / ____exports.CueRenderer.INFO_ICON_FLASH_DURATION_FRAMES) > 0
    end
    if self.cueTypeAnimationName == CueTypeAnimationName.Danger then
        return math.sin(math.pi * currentAnimationFrame / ____exports.CueRenderer.DANGER_ICON_FLASH_DURATION_FRAMES) > 0
    end
    error(
        __TS__New(Error, self.cueTypeAnimationName),
        0
    )
end
CueRenderer.RENDER_DURATION_FRAMES = 150
CueRenderer.INFO_ICON_FLASH_DURATION_FRAMES = 25
CueRenderer.DANGER_ICON_FLASH_DURATION_FRAMES = 10
CueRenderer.CUE_TYPE_ICON_X_OFFSET = 32
CueRenderer.CUE_TYPE_ICON_Y_OFFSET = 10
return ____exports
