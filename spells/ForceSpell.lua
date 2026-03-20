require "spells.BaseSpell"

ForceSpell = {}
setmetatable(ForceSpell, { __index = BaseSpell })
ForceSpell.__index = ForceSpell

function ForceSpell:new(caster, target, spellData, anim)
    local spell = BaseSpell:new(caster, target, spellData, anim)
    spell.x = caster.renderer.x
    spell.y = caster.renderer.y
    spell:playOnce()
    setmetatable(spell, self)
    return spell
end

function ForceSpell:onStart()
    local player = self.caster.player
    player:applyEffect(ManaRegenEffect:new(self.spellData.effectName, player, nil, -self.spellData.tradeAmount))
    player:applyEffect(HealthRegenEffect:new(self.spellData.effectName, player, nil, self.spellData.tradeAmount))
end
