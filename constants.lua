-- Colors
-- using the resurrect 32 color pallete
-- https://lospec.com/palette-list/resurrect-32
COLORS = {
    RED = {232 / 255, 59 / 255, 59 / 255},
    ORANGE = {251 / 255, 107 / 255, 29 / 255},
    YELLOW = {251 / 255, 185 / 255, 84 / 255},
    GREEN = {145 / 255, 219 / 255, 105 / 255},
    BLUE = {77 / 255, 155 / 255, 230 / 255},
    GREY = {98 / 255, 85 / 255, 101 / 255},
    WHITE = {1, 1, 1},
    BLACK = {0, 0, 0}
}

-- UI constants
GAME_WIDTH = 1280
GAME_HEIGHT = 720
PIXEL_TO_GAME_SCALE = 4
SCROLL_SPEED = 64

-- Sprite constants
SPRITE_PIXEL_SIZE = 32
SPRITE_SIZE = SPRITE_PIXEL_SIZE * PIXEL_TO_GAME_SCALE

-- Card dimensions
LARGE_CARD_WIDTH = SPRITE_SIZE + 16
LARGE_CARD_HEIGHT = SPRITE_SIZE + 96
MINI_CARD_WIDTH = SPRITE_SIZE
MINI_CARD_HEIGHT = 64

-- Game constants
MAX_HAND_SIZE = 3
STARTING_HAND_SIZE = 3
