VampireCharacter = {}
setmetatable(VampireCharacter, {
    __index = BaseCharacter
})
VampireCharacter.__index = VampireCharacter

function VampireCharacter:new()
    local character = BaseCharacter:new("vampire", 30)
    character.description = "sacrifices blood for power."

    -- TODO: Create vampire-specific sprites
    character.idleSprite = "wizardIdle"
    character.castSprite = "wizardCast"
    character.deathSprite = "wizardDeath"

    character.startingDeck = { "poison", "poison", "block", "block", "rage", "slice" }
    character.startingWordBank = {"sacrificum", "mortuus", "cruentus", "sanguis", "vulnero", "absorbeo", "devoveo", "vulnus", "diabolus", "sanctifico"}

    setmetatable(character, self)
    return character
end
