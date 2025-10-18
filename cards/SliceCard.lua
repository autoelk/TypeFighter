require "cards.BaseCard"
require "spells.SliceSpell"

SliceCard = {}
setmetatable(SliceCard, {
    __index = BaseCard
})
SliceCard.__index = SliceCard

function SliceCard:new(x, y)
    local card = BaseCard:new(x, y)
    card.name = "slice"
    card.mana = 15
    card.elem = "fire"
    card.anim = resourceManager:newAnimation("card_" .. card.name)

    card.SpellClass = SliceSpell
    card.spellData = { ratio = 1 / 2 }
    setmetatable(card, self)
    return card
end

function SliceCard:getDescription()
    return "deal damage equal to " .. math.floor(self.spellData.ratio * 100) .. "% of enemy health."
end
