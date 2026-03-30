require "cards.BaseCard"
require "spells.TorrentSpell"

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
    card.spellData = { damage = 15 }
    setmetatable(card, self)
    return card
end

function TorrentCard:getDescription()
    return "deal " .. self.spellData.damage .. " damage. draw a card."
end
