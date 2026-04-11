local Table = require "util.Table"
local Sound = require "util.Sound"

-- Model class for a player
BasePlayer = {}
BasePlayer.__index = BasePlayer

function BasePlayer:new(ctx, character)
    local player = {
        ctx = ctx,
        character = character,
        isAlive = true,
        health = character.health,
        maxHealth = character.maxHealth,
        shield = 0,

        -- Statuses
        effects = {}, -- Map of effect name to effect instance for stack effects
        focus = 0, -- How many letters to add/subtract from each word in an incantation
        
        -- Cards
        selectedCard = nil, -- Card being cast by the player
        hand = {}, -- Current cards in hand
        library = {}, -- All cards available to draw from
        deck = {}, -- All cards owned by the player

        -- Words
        wordBank = {} -- List of words that can appear in the player's incantations
    }
    for _, cardName in ipairs(character.startingDeck) do
        local cm = ctx and ctx.cardManager
        if not cm then
            error("BasePlayer requires ctx.cardManager")
        end
        table.insert(player.deck, cm:createCard(cardName))
    end

    for _, word in ipairs(character.startingWordBank) do
        table.insert(player.wordBank, word)
    end
    return setmetatable(player, self)
end

-- Used between battles
function BasePlayer:reset()
    self.isAlive = true
    self.shield = 0
    self.focus = 0
    self.effects = {}

    self.selectedCard = nil
    self.hand = {}
    self.library = {}
    for _, card in ipairs(self.deck) do
        table.insert(self.library, card)
    end
end

function BasePlayer:castSelectedCard()
    if not self.selectedCard then
        return
    end
    table.insert(self.library, self.selectedCard)
    self.selectedCard = nil
end

function BasePlayer:cardInHand(card)
    return Table.indexOf(self.hand, card) ~= nil
end

function BasePlayer:damage(amount)
    local remDmg = amount
    remDmg = math.max(0, remDmg - self.shield)
    self.shield = math.max(0, self.shield - amount)
    self.health = math.max(0, self.health - remDmg)
    if self.health <= 0 then
        self.isAlive = false
    end
    self.onDamage(amount)
    Sound.playSound(self.ctx.resourceManager:getSound("hurt"))
end

function BasePlayer:heal(amount)
    self.health = math.min(self.health + amount, self.maxHealth)
    self.onDamage(-amount)
end

function BasePlayer:addShield(amount)
    self.shield = math.max(0, self.shield + amount)
    -- self.onDamage(-amount)
end

function BasePlayer:update(dt)
    self.health = math.min(self.health, self.maxHealth)
end

-- Add a card to the player's deck
function BasePlayer:addCard(card)
    table.insert(self.deck, card)
end

-- Remove a card from the player's deck
function BasePlayer:removeCard(card)
    local idx = Table.indexOf(self.deck, card)
    if idx then
        table.remove(self.deck, idx)
    end
end

function BasePlayer:applyEffect(effect)
    if self.effects[effect.name] then
        self.effects[effect.name]:addStacks(effect.stacks)
    else
        self.effects[effect.name] = effect
    end
    effect:onApply()
end

function BasePlayer:tickEffects(card, incantation)
    for name, effect in pairs(self.effects) do
        effect:onTick(card, incantation)
        if effect.stacks == 0 then
            effect:onExpire()
            self.effects[name] = nil
        end
    end
end

function BasePlayer:canDrawCard()
    return #self.hand < MAX_HAND_SIZE and #self.library > 0
end

function BasePlayer:drawCard()
    if not self:canDrawCard() then
        return false
    end

    table.insert(self.hand, self.library[1])
    table.remove(self.library, 1)
    return true
end