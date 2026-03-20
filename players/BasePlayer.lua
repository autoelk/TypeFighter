-- Model class for a player
BasePlayer = {}
BasePlayer.__index = BasePlayer

function BasePlayer:new(ctx, character)
    local player = {
        ctx = ctx,
        character = character,
        isAlive = true,
        health = nil,
        healthRegen = nil,
        mana = nil,
        manaRegen = nil,
        stackEffects = {}, -- Map of name to stack effect
        durationEffects = {}, -- List of duration effects

        -- Cards
        picks = MAX_DECK_SIZE,
        hand = {}, -- Current cards in hand
        library = {}, -- All cards available to draw from
        deck = {} -- All cards owned by the player
    }
    setmetatable(player, self)
    return player
end

function BasePlayer:reset()
    self.isAlive = true
    self.health = self.character.health
    self.healthRegen = self.character.healthRegen
    self.mana = self.character.mana
    self.manaRegen = self.character.manaRegen
    self.stackEffects = {}
    self.durationEffects = {}
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

-- Doesn't actually cast the card, just removes it from hand and deducts mana
function BasePlayer:castCard(card)
    self.mana = self.mana - card.mana
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
end

function BasePlayer:update(dt)
    local sm = self.ctx and self.ctx.sceneManager
    if not (sm and sm.getCurrentScene) then
        error("BasePlayer requires ctx.sceneManager")
    end
    local sceneName = sm:getCurrentScene().name

    if sceneName == "game" then
        self.mana = self.mana + dt * self.manaRegen
        if self.mana < 0 then
            self.mana = 0
        end
        self.health = self.health + dt * self.healthRegen
    end

    self:updateEffects(dt)
end

-- Add a card to the player's deck
function BasePlayer:addCard(card)
    table.insert(self.deck, card)
    self.picks = self.picks - 1
end

-- Remove a card from the player's deck
function BasePlayer:removeCard(card)
    local idx = indexOf(self.deck, card)
    if idx then
        table.remove(self.deck, idx)
        self.picks = self.picks + 1
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

    for _, effect in ipairs(self.durationEffects) do
        effect:update(dt)
        if effect.expired then
            table.remove(self.durationEffects, indexOf(self.durationEffects, effect))
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

function BasePlayer:canAfford(manaCost)
    return self.mana >= manaCost
end

function indexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end
