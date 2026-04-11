require "effects.BaseEffect"

BloodPactEffect = {}
setmetatable(BloodPactEffect, {__index = BaseEffect})
BloodPactEffect.__index = BloodPactEffect

function BloodPactEffect:new(player, initialStacks)
    local effect = BaseEffect:new("blood pact", player, initialStacks)
    return setmetatable(effect, self)
end

function BloodPactEffect:onTick(card, incantation)
    if card.spellData.healthCost then
        for i = 1, self.stacks do
            self.player:drawCard()
        end
    end
end