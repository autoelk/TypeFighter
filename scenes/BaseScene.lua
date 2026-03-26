-- Base class for all game scenes
BaseScene = {}
BaseScene.__index = BaseScene

function BaseScene:new(ctx)
    if not ctx then
        error("BaseScene:new(ctx) requires ctx")
    end
    return setmetatable({ ctx = ctx }, self)
end

function BaseScene:enter() end

function BaseScene:exit() end

function BaseScene:update(dt) end

function BaseScene:draw() end

function BaseScene:drawInputInterface()
    local ui = self.ctx.ui
    local inputRectHeight = 32
    lg.setColor(COLORS.BLACK)
    lg.rectangle("fill", 0, GAME_HEIGHT - inputRectHeight, GAME_WIDTH, inputRectHeight)
    
    local text = ui.input
    local color = COLORS.WHITE
    if text == "" then
        text = ui.messageLeft or ""
        color = COLORS.GREY
    end
    
    -- Blinking caret
    if ui.input ~= "" then
        local caretOn = math.floor(love.timer.getTime() * 2) % 2 == 0
        if caretOn then
            text = text .. "|"
        end
    end
    
    lg.setFont(self.ctx.fonts.fontM)
    lg.setColor(color)
    lg.printf(text, 8, GAME_HEIGHT - inputRectHeight, GAME_WIDTH, "left")

    lg.setColor(COLORS.GREY)
    lg.printf(ui.messageRight, -8, GAME_HEIGHT - inputRectHeight, GAME_WIDTH, "right")
end

-- For single key presses
function BaseScene:keypressed(key) end

-- For handling player text input
function BaseScene:handleInput(userInput) end

function BaseScene:wheelmoved(x, y) end
