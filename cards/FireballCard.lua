require "cards.BaseCard"

FireballCard = {}
setmetatable(FireballCard, {__index = BaseCard})
FireballCard.__index = FireballCard

function FireballCard:new(cardData)
    local card = BaseCard:new(cardData)
    card.name = "fireball"
    card.damage = 7
    card.mana = 3
    card.type = "attack"
    card.elem = "fire"
    card.loc = "proj"
    setmetatable(card, self)
    return card
end

function FireballCard:getDescription()
    return "deal " .. self.damage .. " damage."
end

function FireballCard:cast(caster, target)
    -- Apply damage to target
    target:Damage(self.damage)
    return true
end