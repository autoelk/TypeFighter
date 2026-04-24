require "players.BasePlayerRenderer"
local CastResult = require "enums.CastResult"
local Text = require "util.Text"

-- Abstract controller class for players
BasePlayerController = {}
BasePlayerController.__index = BasePlayerController

function BasePlayerController:new(ctx, player, renderer)
    if not ctx then
        error("BasePlayerController:new(ctx, player) requires ctx")
    end
    local controller = {
        ctx = ctx,
        player = player,
        renderer = renderer,
        isHuman = nil,
        opponent = nil,
        incantation = nil,
    }
    player.onDamage = function(amt)
        controller.renderer:showDamage(amt)
    end
    return setmetatable(controller, self)
end

function BasePlayerController:reset()
    self.player:reset()
    self.renderer:reset()
end

function BasePlayerController:getOpponent()
    if not self.opponent then
        error("Opponent not set for player controller")
    end
    return self.opponent
end

function BasePlayerController:setOpponent(opponentController)
    self.opponent = opponentController
end

function BasePlayerController:draw()
    self.renderer:draw()
end

function BasePlayerController:update(dt)
    self.player:update(dt)
    self.renderer:update(dt)
end

function BasePlayerController:generateIncantation(length)
    local result = ""

    for i = 1, length do
        local word = self.player.wordBank[math.random(1, #self.player.wordBank)]
        result = result .. " " .. word
    end

    result = self:_applyFocus(result)
    result = self:_applyShifted(result)

    return Text.trim(result)
end

function BasePlayerController:_applyFocus(incantation)
    local alphabet = "abcdefghijklmnopqrstuvwxyz"
    local words = {}
    for word in incantation:gmatch("%S+") do
        table.insert(words, word)
    end

    for i, word in ipairs(words) do
        if self.player.focus < 0 then
            -- if focus is negative, add random letters to the incantation
            for j = 1, -self.player.focus do
                local breakpoint = math.random(0, #words[i])
                local randomIdx = math.random(1, #alphabet)
                local randomLetter = string.sub(alphabet, randomIdx, randomIdx)
                words[i] = string.sub(words[i], 1, breakpoint) .. randomLetter .. string.sub(words[i], breakpoint + 1)
            end
        elseif self.player.focus > 0 then
            -- if focus is positive, remove letters from the end of each word in the incantation
            local newWordLen = #words[i] - self.player.focus
            if newWordLen <= 0 then
                words[i] = ""
            else
                words[i] = string.sub(words[i], 1, newWordLen)
            end
        end
    end

    return table.concat(words, " ")
end

-- randomly capitalize letters in each word of the incantation equal to the player's shifted stat
function BasePlayerController:_applyShifted(incantation)
    if self.player.shifted <= 0 then
        return incantation
    end

    local words = {}
    for word in incantation:gmatch("%S+") do
        local chars = {}
        for i = 1, #word do
            table.insert(chars, string.sub(word, i, i))
        end

        local indices = {}
        for i = 1, #chars do
            table.insert(indices, i)
        end

        for i = 1, self.player.shifted do
            if #indices == 0 then
                break
            end
            local randomIdx = math.random(1, #indices)
            local charIdx = indices[randomIdx]
            chars[charIdx] = string.upper(chars[charIdx])
            table.remove(indices, randomIdx)
        end

        table.insert(words, table.concat(chars))
    end

    return table.concat(words, " ")
end

function BasePlayerController:castSelectedCard()
    if not self.player.selectedCard then
        return
    end

    local card = self.player.selectedCard
    local castResult = card:canCast(self.player)    
    if castResult == CastResult.Success then
        self.player:tickEffects(card, self.incantation)
        self.renderer:startCastAnimation()
        self.player:castSelectedCard()
        local spell = card:cast(self, self:getOpponent())
        table.insert(self.ctx.sceneManager:getCurrentScene().activeSpells, spell)
    end
    return castResult
end

function BasePlayerController:drawCard()
    return self.player:drawCard()
end
