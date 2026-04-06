VampireCharacter = {}
setmetatable(VampireCharacter, {
    __index = BaseCharacter
})
VampireCharacter.__index = VampireCharacter

function VampireCharacter:new()
    local character = BaseCharacter:new("vampire", 30)
    character.description = "sacrifices blood for power."

    character.idleSprite = "vampireIdle"
    character.castSprite = "vampireCast"
    character.deathSprite = "vampireDeath"

    character.startingDeck = { "poison", "poison", "block", "block", "rage", "slice" }
    character.startingWordBank = {"sacrificum", "mortuus", "cruentus", "sanguis", "vulnero", "absorbeo", "devoveo", "vulnus", "diabolus", "sanctifico"}

    setmetatable(character, self)
    return character
end
