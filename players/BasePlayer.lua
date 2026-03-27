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
        stackEffects = {}, -- Map of name to stack effect
        durationEffects = {}, -- List of duration effects
        
        -- Cards
        selectedCard = nil, -- Card being cast by the player
        hand = {}, -- Current cards in hand
        library = {}, -- All cards available to draw from
        deck = {} -- All cards owned by the player
    }
    setmetatable(player, self)
    return player
end

function BasePlayer:reset()
    self.isAlive = true
    self.stackEffects = {}
    self.durationEffects = {}
    self.selectedCard = nil
    self.hand = {}
    self.deck = {}

    for _, cardName in ipairs(self.character.startingDeck) do
        local cm = self.ctx and self.ctx.cardManager
        if not cm then
            error("BasePlayer requires ctx.cardManager")
        end
        self:addCard(cm:createCard(cardName))
    end
end

-- Doesn't actually cast the card, just removes it from hand
function BasePlayer:castCard(card)
    table.remove(self.hand, indexOf(self.hand, card))
    table.insert(self.library, card)
end

function BasePlayer:cardInHand(card)
    return indexOf(self.hand, card) ~= nil
end

function BasePlayer:damage(amt)
    self.health = math.max(0, self.health - amt)
    if self.health <= 0 then
        self.isAlive = false
    end
    if self.onDamage then
        self.onDamage(amt)
    end
end

function BasePlayer:update(dt)
    self:updateEffects(dt)

    self.health = math.min(self.health, self.maxHealth)
end

-- Add a card to the player's deck
function BasePlayer:addCard(card)
    table.insert(self.deck, card)
end

-- Remove a card from the player's deck
function BasePlayer:removeCard(card)
    local idx = indexOf(self.deck, card)
    if idx then
        table.remove(self.deck, idx)
    end
end

function BasePlayer:applyEffect(effect)
    if effect.type == "stack" then
        if self.stackEffects[effect.name] then
            self.stackEffects[effect.name]:addStacks(effect.stacks)
        else
            self.stackEffects[effect.name] = effect
            effect:onApply()
        end
    elseif effect.type == "duration" then
        table.insert(self.durationEffects, effect)
        effect:onApply()
    else
        error("Invalid effect type: " .. effect.type)
    end
end

function BasePlayer:updateEffects(dt)
    for name, effect in pairs(self.stackEffects) do
        effect:update(dt)
        if effect.expired then
            self.stackEffects[name] = nil
            effect:onExpire()
        end
    end

    for i = #self.durationEffects, 1, -1 do
        local effect = self.durationEffects[i]
        effect:update(dt)
        if effect.expired then
            table.remove(self.durationEffects, i)
            effect:onExpire()
        end
    end
end

function BasePlayer:drawCard()
    if #self.hand >= MAX_HAND_SIZE then
        return false
    end

    table.insert(self.hand, self.library[1])
    table.remove(self.library, 1)
    return true
end

function indexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end
