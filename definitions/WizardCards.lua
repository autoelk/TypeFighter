-- Wizard card definitions
require "spells.wizard.BoltSpell"
require "spells.wizard.ForceFieldSpell"
require "spells.wizard.FireballSpell"
require "spells.wizard.HealSpell"
require "spells.wizard.TorrentSpell"
require "spells.wizard.BlessingSpell"
require "spells.wizard.PortalSpell"
require "spells.wizard.GemSpell"

local Keyword = require "enums.Keyword"

return {
    blessing = {
        character = "wizard",
        incantationLength = 3,
        spell = BlessingSpell,
        spellData = { regenAmount = 5 },
        keywords = {},
        description = function(d)
            return "apply " .. d.regenAmount .. " stacks of health regeneration."
        end,
    },
    bolt = {
        character = "wizard",
        incantationLength = 1,
        spell = BoltSpell,
        spellData = { damage = 5 },
        keywords = {},
        description = function(d)
            return "deal " .. d.damage .. " damage."
        end,
    },
    fireball = {
        character = "wizard",
        incantationLength = 2,
        spell = FireballSpell,
        spellData = { damage = 15, focusAmount = -3 },
        keywords = { Keyword.Focus },
        description = function(d)
            return "lose " .. math.abs(d.focusAmount) .. " focus. deal " .. d.damage .. " damage."
        end,
    },
    forcefield = {
        character = "wizard",
        incantationLength = 1,
        spell = ForceFieldSpell,
        spellData = { shieldAmount = 5 },
        keywords = {},
        description = function(d)
            return "gain " .. d.shieldAmount .. " shield."
        end,
    },
    gem = {
        character = "wizard",
        incantationLength = 2,
        spell = GemSpell,
        spellData = { focusAmount = 5 },
        keywords = { Keyword.Focus },
        description = function(d)
            return "gain " .. d.focusAmount .. " focus."
        end,
    },
    heal = {
        character = "wizard",
        incantationLength = 2,
        spell = HealSpell,
        spellData = { healAmount = 10 },
        keywords = {},
        description = function(d)
            return "gain " .. d.healAmount .. " health."
        end,
    },
    portal = {
        character = "wizard",
        incantationLength = 10,
        spell = PortalSpell,
        spellData = { damage = 40 },
        keywords = {},
        description = function(d)
            return "deal " .. d.damage .. " damage."
        end,
    },
    torrent = {
        character = "wizard",
        incantationLength = 3,
        spell = TorrentSpell,
        spellData = { damage = 5, focusAmount = 3 },
        keywords = { Keyword.Focus },
        description = function(d)
            return "gain " .. d.focusAmount .. " focus. deal " .. d.damage .. " damage."
        end,
    },
}
