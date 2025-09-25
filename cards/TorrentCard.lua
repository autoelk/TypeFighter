require "cards.BaseCard"

TorrentCard = {}
setmetatable(TorrentCard, {__index = BaseCard})
TorrentCard.__index = TorrentCard

function TorrentCard:new(cardData)
    local card = BaseCard:new(cardData)
    card.name = "torrent"
    card.damage = 15
    card.mana = 7
    card.type = "attack"
    card.elem = "water"
    card.loc = "proj"
    setmetatable(card, self)
    return card
end

function TorrentCard:getDescription()
    return "deal " .. self.damage .. " damage."
end

function TorrentCard:cast(caster, target)
    target:Damage(self.damage)
    return true
end