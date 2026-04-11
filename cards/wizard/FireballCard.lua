require "cards.BaseCard"
require "spells.wizard.FireballSpell"
local Keyword = require "enums.Keyword"

FireballCard = {}
setmetatable(FireballCard, {__index = BaseCard})
FireballCard.__index = FireballCard

function FireballCard:new(ctx, x, y)
    local card = BaseCard:new(ctx, x, y)
    card.name = "fireball"
    card.incantationLength = 2
    card:setCharacter("wizard")
    card.anim = ctx.resourceManager:newAnimation("card_" .. card.name, "loop")

    card.SpellClass = FireballSpell
    card.spellData = {
        damage = 15,
        focusAmount = -3
    }
    card.keywords = { Keyword.Focus }
    return setmetatable(card, self)
end

function FireballCard:getDescription()
    return "lose " .. math.abs(self.spellData.focusAmount) .. " focus. deal " .. self.spellData.damage .. " damage."
end
