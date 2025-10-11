require "cards.BaseCard"

ForceCard = {}
setmetatable(ForceCard, {
    __index = BaseCard
})
ForceCard.__index = ForceCard

function ForceCard:new(cardData)
    local card = BaseCard:new(cardData)
    card.name = "force"
    card.mana = 15
    card.tradeAmount = 1 -- Amount of health/mana regen to trade
    card.type = "misc"
    card.elem = "fire"
    card.loc = "self"
    setmetatable(card, self)
    return card
end

function ForceCard:getDescription()
    return "gain " .. self.tradeAmount .. " health regen, lose " .. self.tradeAmount .. " mana regen."
end

function ForceCard:cast(caster, target)
    caster.manaRegen = caster.manaRegen - self.tradeAmount
    caster.healthRegen = caster.healthRegen + self.tradeAmount
    return true
end
