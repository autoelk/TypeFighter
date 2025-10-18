require "cards.BaseCard"
require "spells.BlessingSpell"

BlessingCard = {}
setmetatable(BlessingCard, {
    __index = BaseCard
})
BlessingCard.__index = BlessingCard

function BlessingCard:new(x, y)
    local card = BaseCard:new(x, y)
    card.name = "blessing"
    card.mana = 8
    card.elem = "earth"
    card.anim = resourceManager:newAnimation("card_" .. card.name)

    card.SpellClass = BlessingSpell
    card.spellData = {
        regenAmount = 1,
        duration = 15
    }
    setmetatable(card, self)
    return card
end

function BlessingCard:getDescription()
    return "+" .. self.spellData.regenAmount .. " health/sec for " .. self.spellData.duration .. " seconds."
end
