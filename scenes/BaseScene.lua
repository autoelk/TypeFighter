local utf8 = require("utf8")
local Text = require("util.Text")

-- Base class for all game scenes
BaseScene = {}
BaseScene.__index = BaseScene

function BaseScene:new(ctx)
    if not ctx then
        error("BaseScene:new(ctx) requires ctx")
    end
    local scene = {
        ctx = ctx,
        
        -- Map of commands available to the player currently
        -- { command = autocomplete }
        availableCommands = {},
        suggestedCommand = nil,
        suggestedCommandAutocomplete = false,

        inputBar = {
            x = 0,
            y = GAME_HEIGHT - 32,
            height = 32,
            width = GAME_WIDTH,
            padding = 8,
            cursor = {
                width = 10,
                height = 2,
                idleDuration = 0.1, -- how long to wait before blinking the cursor
                idleTime = 0,
                blinkDuration = 0.5, -- how long to blink the cursor for
                blinkTime = 0,
            }
        }
    }
    return setmetatable(scene, self)
end

function BaseScene:enter() end

function BaseScene:exit() end

function BaseScene:update(dt) end

function BaseScene:draw() end

function BaseScene:registerTypingActivity()
    self.inputBar.cursor.idleTime = 0
    self.inputBar.cursor.blinkTime = 0
end

function BaseScene:updateCursorBlink(dt)
    self.inputBar.cursor.idleTime = self.inputBar.cursor.idleTime + dt
    if self.inputBar.cursor.idleTime >= self.inputBar.cursor.idleDuration then
        self.inputBar.cursor.blinkTime = self.inputBar.cursor.blinkTime + dt
    end
end

function BaseScene:shouldDrawCursor()
    if self.inputBar.cursor.idleTime < self.inputBar.cursor.idleDuration then
        return true
    end
    
    return math.floor(self.inputBar.cursor.blinkTime / self.inputBar.cursor.blinkDuration) % 2 == 0
end

function BaseScene:drawInputInterface()
    local ui = self.ctx.ui

    lg.setColor(COLORS.BLACK)
    lg.rectangle("fill", self.inputBar.x, self.inputBar.y, self.inputBar.width, self.inputBar.height)
    
    local text = ui.input
    local color = COLORS.WHITE
    local isTyping = ui.input ~= ""
    if text == "" then
        text = ui.messageLeft or ""
        color = COLORS.GREY
    end
    
    local font = self.ctx.fonts.fontM
    lg.setFont(font)
    lg.setColor(color)

    local rightMessage = ui.messageRight or ""
    local rightMessageWidth = font:getWidth(rightMessage)
    local inputWidth = self.inputBar.width - (self.inputBar.padding * 2) - rightMessageWidth - self.inputBar.cursor.width - 8
    inputWidth = math.max(inputWidth, 0)

    local drawX = self.inputBar.x + self.inputBar.padding
    local textWidth = font:getWidth(text)
    local textOffsetX = 0
    if isTyping and textWidth > inputWidth then
        -- current horizontal "scroll" amount for the input
        textOffsetX = inputWidth - textWidth
    end

    local prevScissorX, prevScissorY, prevScissorW, prevScissorH = lg.getScissor()
    lg.setScissor(drawX, self.inputBar.y, inputWidth, self.inputBar.height)
    if isTyping and self.suggestedCommand then
        text = {
            COLORS.WHITE, text,
            COLORS.GREY, string.sub(self.suggestedCommand, #text + 1, -1),
        }
    end
    
    local cursorX = drawX + font:getWidth(ui.input)
    if textWidth > inputWidth then
        cursorX = drawX + inputWidth
    end
    local cursorY = self.inputBar.y + font:getHeight() * font:getLineHeight() + 2

    -- main text
    lg.print(text, drawX + textOffsetX, self.inputBar.y)
    lg.setScissor(prevScissorX, prevScissorY, prevScissorW, prevScissorH)

    -- feedback message
    lg.setColor(COLORS.GREY)
    lg.printf(rightMessage, self.inputBar.x - self.inputBar.padding, self.inputBar.y, self.inputBar.width, "right")

    -- cursor
    if self:shouldDrawCursor() then
        lg.setColor(COLORS.WHITE)
        lg.rectangle("fill", cursorX, cursorY, self.inputBar.cursor.width, self.inputBar.cursor.height)
    end
end

function BaseScene:updateSuggestedCommand()
    local matchingCommands = self:getAvailableCommands(self.ctx.ui.input)
    if #matchingCommands == 1 then
        self.suggestedCommand = matchingCommands[1]
        self.suggestedCommandAutocomplete = self.availableCommands[self.suggestedCommand]
    else
        self.suggestedCommand = nil
        self.suggestedCommandAutocomplete = false
    end
end

-- For single key presses
function BaseScene:keypressed(key)
    local uiInput = self.ctx.ui.input
    if key == "backspace" and utf8.offset(uiInput, -1) then
        uiInput = string.sub(uiInput, 1, utf8.offset(uiInput, -1) - 1)
        self.ctx.ui.input = uiInput
        self:updateSuggestedCommand()
        self:registerTypingActivity()
    elseif key == "return" then
        if self.suggestedCommand and self.suggestedCommandAutocomplete then
            uiInput = self.suggestedCommand
        end
        uiInput = Text.trim(uiInput)
        self.ctx.ui.input = "" -- clear user input field
        self:updateSuggestedCommand()
        self:handleInput(uiInput)
    elseif key == "tab" and self.suggestedCommand and self.suggestedCommandAutocomplete then
        self.ctx.ui.input = self.suggestedCommand
        self.suggestedCommand = nil
        self.suggestedCommandAutocomplete = false
    end
end

function BaseScene:textinput(t)
    if t == " " and self.ctx.ui.input:sub(-1) == " " then
        return -- don't allow consecutive spaces
    end
    self.ctx.ui.input = self.ctx.ui.input .. t
    self.ctx.ui.messageLeft = "" -- clears placeholder that shares the input area
    self:registerTypingActivity()
    self:updateSuggestedCommand()
end

function BaseScene:handleInput(userInput) end

function BaseScene:wheelmoved(x, y) end

function BaseScene:addAvailableCommand(command, autocomplete)
    if command == nil or command == "" then
        return
    end
    if autocomplete == nil then
        autocomplete = true
    end
    self.availableCommands[command] = autocomplete
end

function BaseScene:removeAvailableCommand(command)
    self.availableCommands[command] = nil
end

function BaseScene:getAvailableCommands(prefix)
    prefix = prefix or ""

    local commands = {}
    for command, autocomplete in pairs(self.availableCommands) do
        if string.sub(command, 1, #prefix) == prefix then
            table.insert(commands, command)
        end
    end

    return commands
end
