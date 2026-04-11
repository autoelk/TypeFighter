WizardCharacter = {}
setmetatable(WizardCharacter, {
    __index = BaseCharacter
})
WizardCharacter.__index = WizardCharacter

function WizardCharacter:new()
    local character = BaseCharacter:new("wizard", 50)
    character.description = "hates doing anything other than damage."

    character.idleSprite = "wizardIdle"
    character.castSprite = "wizardCast"
    character.deathSprite = "wizardDeath"

    character.startingDeck = {"bolt", "bolt", "forcefield", "forcefield", "gem", "fireball"}
    character.startingWordBank = {"ignis", "inflammatio", "accendo", "infervesco", "fulgeo", "aqua", "mare", "demergo", "liquidus", "flumen"}

    setmetatable(character, self)
    return character
end
