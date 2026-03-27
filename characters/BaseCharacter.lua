BaseCharacter = {}
BaseCharacter.__index = BaseCharacter

function BaseCharacter:new(name, health, healthRegen)
    local character = setmetatable({}, self)
    character.name = name
    character.description = nil

    character.health = health
    character.healthRegen = healthRegen

    character.idleSprite = nil
    character.castSprite = nil
    character.deathSprite = nil
    character.tint = COLORS.WHITE

    character.startingDeck = {}
    return character
end
