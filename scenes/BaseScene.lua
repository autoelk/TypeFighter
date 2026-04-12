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
    }
    return setmetatable(scene, self)
end

function BaseScene:enter() end

function BaseScene:exit() end

function BaseScene:update(dt) end

function BaseScene:draw() end

function BaseScene:drawInputInterface()
    local ui = self.ctx.ui
    local inputRectHeight = 32
    local inputY = GAME_HEIGHT - inputRectHeight
    local leftPadding = 8
    local rightPadding = 8
    local cursorWidth = 10
    local cursorHeight = 2

    lg.setColor(COLORS.BLACK)
    lg.rectangle("fill", 0, inputY, GAME_WIDTH, inputRectHeight)
    
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
    local inputWidth = GAME_WIDTH - leftPadding - rightPadding - rightMessageWidth - cursorWidth - 8
    inputWidth = math.max(inputWidth, 0)

    local drawX = leftPadding
    local textWidth = font:getWidth(text)
    local textOffsetX = 0
    if isTyping and textWidth > inputWidth then
        -- current horizontal "scroll" amount for the input
        textOffsetX = inputWidth - textWidth
    end

    local prevScissorX, prevScissorY, prevScissorW, prevScissorH = lg.getScissor()
    lg.setScissor(drawX, inputY, inputWidth, inputRectHeight)
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
    local cursorY = inputY + font:getHeight() * font:getLineHeight() + 2

    -- main text
    lg.print(text, drawX + textOffsetX, inputY)
    lg.setScissor(prevScissorX, prevScissorY, prevScissorW, prevScissorH)

    -- feedback message
    lg.setColor(COLORS.GREY)
    lg.printf(rightMessage, -rightPadding, inputY, GAME_WIDTH, "right")

    -- cursor
    lg.setColor(COLORS.WHITE)
    lg.rectangle("fill", cursorX, cursorY, cursorWidth, cursorHeight)
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
    if key == "tab" and self.suggestedCommand and self.suggestedCommandAutocomplete then
        self.ctx.ui.input = self.suggestedCommand
        self.suggestedCommand = nil
        self.suggestedCommandAutocomplete = false
    end
end

function BaseScene:textinput(t)
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
