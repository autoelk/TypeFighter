WizardCharacter = {}
setmetatable(WizardCharacter, {
    __index = BaseCharacter
})
WizardCharacter.__index = WizardCharacter

function WizardCharacter:new()
    local character = BaseCharacter:new("wizard", 50, 0, 0, 1)
    character.description = "hates doing anything other than damage."

    character.idleSprite = "wizardIdle"
    character.castSprite = "wizardCast"
    character.deathSprite = "wizardDeath"

    character.startingDeck = {"bolt", "bolt", "torrent", "torrent", "gem"}

    setmetatable(character, self)
    return character
end
