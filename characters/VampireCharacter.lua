VampireCharacter = {}
setmetatable(VampireCharacter, {
    __index = BaseCharacter
})
VampireCharacter.__index = VampireCharacter

function VampireCharacter:new()
    local character = BaseCharacter:new("vampire", 30, 1, 0, 1)
    character.description = "sacrifices blood for power."

    -- TODO: Create vampire-specific sprites
    character.idleSprite = "wizardIdle"
    character.castSprite = "wizardCast"
    character.deathSprite = "wizardDeath"

    character.startingDeck = { "poison", "poison", "rage", "ritual", "slice" }

    setmetatable(character, self)
    return character
end
