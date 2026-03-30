require "players.BasePlayerRenderer"
local CastResult = require "enums.CastResult"

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

function BasePlayerController:damage(amount)
    self.player:damage(amount)
end

function BasePlayerController:castSelectedCard()
    if not self.player.selectedCard then
        return
    end

    local card = self.player.selectedCard
    local castResult = card:canCast(self.player)    
    if castResult == CastResult.Success then
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
