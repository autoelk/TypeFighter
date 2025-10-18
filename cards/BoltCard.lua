require "cards.BaseCard"
require "spells.BoltSpell"

BoltCard = {}
setmetatable(BoltCard, {
    __index = BaseCard
})
BoltCard.__index = BoltCard

function BoltCard:new(x, y)
    local card = BaseCard:new(x, y)
    card.name = "bolt"
    card.mana = 1
    card.elem = "fire"
    card.anim = resourceManager:newAnimation("card_" .. card.name)

    card.SpellClass = BoltSpell
    card.spellData = {
        damage = 4
    }
    setmetatable(card, self)
    return card
end

function BoltCard:getDescription()
    return "deal " .. self.spellData.damage .. " damage."
end
