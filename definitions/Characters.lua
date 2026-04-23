require "constants"

local characters = {
    wizard = {
        name = "wizard",
        description = "hates doing anything other than damage.",
        maxHealth = 50,
        idleSprite = "wizardIdle",
        castSprite = "wizardCast",
        deathSprite = "wizardDeath",
        spellPlaceholderSprite = "wizardSpellPlaceholder",
        mirrorCharSprite = true,
        color = COLORS.BLUE,
        startingDeck = { "bolt", "bolt", "forcefield", "forcefield", "gem", "fireball" },
        startingWordBank = { "ignis", "inflammatio", "accendo", "infervesco", "fulgeo", "aqua", "mare", "demergo", "liquidus", "flumen" },
    },
    vampire = {
        name = "vampire",
        description = "sacrifices blood for power.",
        maxHealth = 50,
        idleSprite = "vampireIdle",
        castSprite = "vampireCast",
        deathSprite = "vampireDeath",
        spellPlaceholderSprite = "vampireSpellPlaceholder",
        mirrorCharSprite = true,
        color = COLORS.RED,
        startingDeck = { "swipe", "swipe", "shroud", "shroud", "lacerate", "rage" },
        startingWordBank = { "sacrificum", "mortuus", "cruentus", "sanguis", "vulnero", "absorbeo", "devoveo", "vulnus", "diabolus", "sanctifico" },
    },
    shiftKey = {
        name = "shiftKey",
        description = "messes with your capitalization.",
        maxHealth = 50,
        idleSprite = "shiftKeyIdle",
        castSprite = "shiftKeyIdle",
        deathSprite = "shiftKeyIdle",
        spellPlaceholderSprite = "wizardSpellPlaceholder",
        mirrorCharSprite = false, -- Don't mirror the character sprite
        color = COLORS.WHITE,
        startingDeck = { "shiftKey", "bolt", "forcefield" },
        startingWordBank = { "SHIFT", "KEY" },
    }
}

local humanCharacters = { "vampire", "wizard" }
local enemyCharacters = { "shiftKey" }
local bossCharacters = { "vampire", "wizard" } -- TODO: Create boss characters

return {
    characters = characters,
    humanCharacters = humanCharacters,
    enemyCharacters = enemyCharacters,
    bossCharacters = bossCharacters,
}
