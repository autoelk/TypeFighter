-- Vampire card definitions
require "spells.vampire.SwipeSpell"
require "spells.vampire.ShroudSpell"
require "spells.vampire.LacerateSpell"
require "spells.vampire.RageSpell"
require "spells.vampire.SliceSpell"
require "spells.vampire.SiphonSpell"
require "spells.vampire.CoagulateSpell"
require "spells.vampire.BloodPactSpell"
require "spells.vampire.NauseateSpell"
require "spells.vampire.BiteSpell"

local Keyword = require "enums.Keyword"

return {
    bloodpact = {
        character = "vampire",
        incantationLength = 5,
        spell = BloodPactSpell,
        spellData = {},
        keywords = { Keyword.Sacrifice, Keyword.Consume },
        description = function()
            return "whenever you sacrifice, draw a card. consume."
        end,
    },
    coagulate = {
        character = "vampire",
        incantationLength = 5,
        spell = CoagulateSpell,
        spellData = { healthCost = 5, shieldAmount = 20 },
        keywords = { Keyword.Sacrifice },
        description = function(d)
            return "sacrifice " .. d.healthCost .. " health, gain " .. d.shieldAmount .. " shield."
        end,
    },
    lacerate = {
        character = "vampire",
        incantationLength = 2,
        spell = LacerateSpell,
        spellData = { bleedAmount = 5 },
        keywords = { Keyword.Bleed },
        description = function(d)
            return "apply " .. d.bleedAmount .. " stacks of bleed."
        end,
    },
    rage = {
        character = "vampire",
        incantationLength = 5,
        spell = RageSpell,
        spellData = { damage = 30, healthCost = 10 },
        keywords = { Keyword.Sacrifice },
        description = function(d)
            return "sacrifice " .. d.healthCost .. " health, deal " .. d.damage .. " damage."
        end,
    },
    shroud = {
        character = "vampire",
        incantationLength = 1,
        spell = ShroudSpell,
        spellData = { shieldAmount = 5 },
        keywords = {},
        previewSprite = "vampireSpellPlaceholder",
        description = function(d)
            return "gain " .. d.shieldAmount .. " shield."
        end,
    },
    siphon = {
        character = "vampire",
        incantationLength = 2,
        spell = SiphonSpell,
        spellData = {},
        keywords = { Keyword.Bleed },
        description = function()
            return "gain shield equal to stacks of bleed on the target."
        end,
    },
    slice = {
        character = "vampire",
        incantationLength = 3,
        spell = SliceSpell,
        spellData = { ratio = 1 / 2 },
        keywords = {},
        previewSprite = "vampireSpellPlaceholder",
        description = function(d)
            return "deal damage equal to " .. math.floor(d.ratio * 100) .. "% of enemy health."
        end,
    },
    swipe = {
        character = "vampire",
        incantationLength = 1,
        spell = SwipeSpell,
        spellData = { damage = 5 },
        keywords = {},
        description = function(d)
            return "deal " .. d.damage .. " damage."
        end,
    },
    nauseate = {
        character = "vampire",
        incantationLength = 3,
        spell = NauseateSpell,
        spellData = {},
        keywords = { Keyword.Bleed, Keyword.Focus },
        description = function()
            return "reduce focus by stacks of bleed on the target."
        end,
    },
    bite = {
        character = "vampire",
        incantationLength = 3,
        spell = BiteSpell,
        spellData = { damage = 5, bleedAmount = 3 },
        keywords = { Keyword.Bleed },
        description = function(d)
            return "deal " .. d.damage .. " damage. apply " .. d.bleedAmount .. " stacks of bleed."
        end,
    },
}
