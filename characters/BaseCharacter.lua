BaseCharacter = {}
BaseCharacter.__index = BaseCharacter

function BaseCharacter:new(name, health, healthRegen, mana, manaRegen)
    local character = setmetatable({}, self)
    character.name = name
    character.description = nil

    character.health = health
    character.healthRegen = healthRegen
    character.mana = mana
    character.manaRegen = manaRegen

    character.idleSprite = nil
    character.castSprite = nil
    character.deathSprite = nil
    character.tint = COLORS.WHITE

    character.startingDeck = {}
    return character
end
