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
    local alphabet = "abcdefghijklmnopqrstuvwxyz"
    for i = 1, length do
        local word = self.player.wordBank[math.random(1, #self.player.wordBank)]
        if self.player.focus < 0 then
            -- if focus is negative, add random letters to the incantation
            for j = 1, -self.player.focus do
                local breakpoint = math.random(0, #word)
                local randomIdx = math.random(1, #alphabet)
                local randomLetter = string.sub(alphabet, randomIdx, randomIdx)
                word = string.sub(word, 1, breakpoint) .. randomLetter .. string.sub(word, breakpoint + 1)
            end
        elseif self.player.focus > 0 then
            -- if focus is positive, remove random letters from the incantation
            local letters = {}
            for char in word:gmatch(".") do
                table.insert(letters, char)
            end
            local amtToRemove = math.min(self.player.focus, #letters)
            for j = 1, amtToRemove do
                local randomIdx = math.random(1, #letters)
                table.remove(letters, randomIdx)
            end
            word = table.concat(letters)
        end

        if #word > 0 then
            result = result .. " " .. word
        end
    end
    return Text.trim(result)
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
