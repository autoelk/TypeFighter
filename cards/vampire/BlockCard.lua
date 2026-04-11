require "cards.BaseCard"
require "spells.vampire.BlockSpell"

BlockCard = {}
setmetatable(BlockCard, {
    __index = BaseCard
})
BlockCard.__index = BlockCard

function BlockCard:new(ctx, x, y)
    local card = BaseCard:new(ctx, x, y)
    card.name = "block"
    card.incantationLength = 1
    card:setCharacter("vampire")
    card.anim = ctx.resourceManager:newAnimation("card_" .. card.name)

    card.SpellClass = BlockSpell
    card.spellData = {
        shieldAmount = 5
    }
    setmetatable(card, self)
    return card
end

function BlockCard:getDescription()
    return "gain " .. self.spellData.shieldAmount .. " shield."
end
