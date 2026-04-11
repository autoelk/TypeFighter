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

    character.startingDeck = { "swipe", "swipe", "shroud", "shroud", "lacerate", "rage" }
    character.startingWordBank = {"sacrificum", "mortuus", "cruentus", "sanguis", "vulnero", "absorbeo", "devoveo", "vulnus", "diabolus", "sanctifico"}

    setmetatable(character, self)
    return character
end