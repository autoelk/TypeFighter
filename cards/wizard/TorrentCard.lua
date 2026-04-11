require "cards.BaseCard"
require "spells.wizard.TorrentSpell"

TorrentCard = {}
setmetatable(TorrentCard, {
    __index = BaseCard
})
TorrentCard.__index = TorrentCard

function TorrentCard:new(ctx, x, y)
    local card = BaseCard:new(ctx, x, y)
    card.name = "torrent"
    card.incantationLength = 3
    card:setCharacter("wizard")
    card.anim = ctx.resourceManager:newAnimation("card_" .. card.name)

    card.SpellClass = TorrentSpell
    card.spellData = { 
        damage = 5,
        focusAmount = 3
    }
    setmetatable(card, self)
    return card
end

function TorrentCard:getDescription()
    return "gain " .. self.spellData.focusAmount .. " focus. deal " .. self.spellData.damage .. " damage."
end
