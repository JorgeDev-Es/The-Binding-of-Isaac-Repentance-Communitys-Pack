local ____exports = {}
--- These enums loop after 31, so 32 = D_PAD_LEFT, 63 = D_PAD_LEFT, and so on.
-- 
-- There appears to be no input key for joystick movement.
____exports.Controller = {}
____exports.Controller.D_PAD_LEFT = 0
____exports.Controller[____exports.Controller.D_PAD_LEFT] = "D_PAD_LEFT"
____exports.Controller.D_PAD_RIGHT = 1
____exports.Controller[____exports.Controller.D_PAD_RIGHT] = "D_PAD_RIGHT"
____exports.Controller.D_PAD_UP = 2
____exports.Controller[____exports.Controller.D_PAD_UP] = "D_PAD_UP"
____exports.Controller.D_PAD_DOWN = 3
____exports.Controller[____exports.Controller.D_PAD_DOWN] = "D_PAD_DOWN"
____exports.Controller.BUTTON_A = 4
____exports.Controller[____exports.Controller.BUTTON_A] = "BUTTON_A"
____exports.Controller.BUTTON_B = 5
____exports.Controller[____exports.Controller.BUTTON_B] = "BUTTON_B"
____exports.Controller.BUTTON_X = 6
____exports.Controller[____exports.Controller.BUTTON_X] = "BUTTON_X"
____exports.Controller.BUTTON_Y = 7
____exports.Controller[____exports.Controller.BUTTON_Y] = "BUTTON_Y"
____exports.Controller.BUMPER_LEFT = 8
____exports.Controller[____exports.Controller.BUMPER_LEFT] = "BUMPER_LEFT"
____exports.Controller.TRIGGER_LEFT = 9
____exports.Controller[____exports.Controller.TRIGGER_LEFT] = "TRIGGER_LEFT"
____exports.Controller.STICK_LEFT = 10
____exports.Controller[____exports.Controller.STICK_LEFT] = "STICK_LEFT"
____exports.Controller.BUMPER_RIGHT = 11
____exports.Controller[____exports.Controller.BUMPER_RIGHT] = "BUMPER_RIGHT"
____exports.Controller.TRIGGER_RIGHT = 12
____exports.Controller[____exports.Controller.TRIGGER_RIGHT] = "TRIGGER_RIGHT"
____exports.Controller.STICK_RIGHT = 13
____exports.Controller[____exports.Controller.STICK_RIGHT] = "STICK_RIGHT"
____exports.Controller.BUTTON_BACK = 14
____exports.Controller[____exports.Controller.BUTTON_BACK] = "BUTTON_BACK"
____exports.Controller.BUTTON_START = 15
____exports.Controller[____exports.Controller.BUTTON_START] = "BUTTON_START"
return ____exports
