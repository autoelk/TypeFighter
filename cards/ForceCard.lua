require "cards.BaseCard"
require "spells.ForceSpell"

ForceCard = {}
setmetatable(ForceCard, {
    __index = BaseCard
})
ForceCard.__index = ForceCard

function ForceCard:new(x, y)
    local card = BaseCard:new(x, y)
    card.name = "force"
    card.mana = 15
    card.elem = "fire"
    card.anim = resourceManager:newAnimation("card_" .. card.name)

    card.SpellClass = ForceSpell
    card.spellData = { tradeAmount = 1 }
    setmetatable(card, self)
    return card
end

function ForceCard:getDescription()
    return "gain " ..
        self.spellData.tradeAmount .. " health regen, lose " .. self.spellData.tradeAmount .. " mana regen."
end
