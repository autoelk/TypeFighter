-- Model class for a player
BasePlayer = {}
BasePlayer.__index = BasePlayer

function BasePlayer:new(character)
    local player = {
        character = character,
        isAlive = true,
        health = nil,
        healthRegen = nil,
        mana = nil,
        manaRegen = nil,
        effects = {},

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
    self.effects = {}
    self.hand = {}
    self.deck = {}

    for _, cardName in ipairs(self.character.startingDeck) do
        self:addCard(cardManager:createCard(cardName))
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
    if sceneManager:getCurrentScene().name == "game" then
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

function BasePlayer:applyEffect(id, cfg)
    if not cfg then
        error("applyEffect requires a configuration table")
    end

    --[[ three modes: stack, refresh, ignore
    stack - refresh duration and add a stack, up to maxStacks
    refresh - refresh duration only
    ignore - do nothing if effect already exists ]]
    local eff = self.effects[id]
    if eff then
        local mode = cfg.stackMode or eff.stackMode or "refresh"
        if mode == "stack" then
            local newStacks = eff.stacks + 1
            if (cfg.maxStacks or eff.maxStacks) then
                local limit = cfg.maxStacks or eff.maxStacks
                newStacks = math.min(limit, newStacks)
                eff.maxStacks = limit
            end
            eff.stacks = newStacks
            eff.timeLeft = cfg.duration or eff.timeLeft
        elseif mode == "refresh" then
            eff.timeLeft = cfg.duration or eff.timeLeft
        elseif mode == "ignore" then
            return eff
        end
        return eff
    end

    eff = {
        id = id,
        timeLeft = cfg.duration,
        tickInterval = cfg.tickInterval,
        tickTimer = 0,
        stacks = 1,
        maxStacks = cfg.maxStacks,
        stackMode = cfg.stackMode or "refresh",
        onTick = cfg.onTick,
        onExpire = cfg.onExpire,
        onApply = cfg.onApply
    }
    self.effects[id] = eff
    if eff.onApply then
        eff.onApply(self, eff)
    end
    return eff
end

function BasePlayer:updateEffects(dt)
    for id, eff in pairs(self.effects) do
        if eff.timeLeft then
            eff.timeLeft = eff.timeLeft - dt
            if eff.timeLeft <= 0 then
                if eff.onExpire then
                    eff.onExpire(self, eff)
                end
                self.effects[id] = nil
            else
                if eff.tickInterval then
                    eff.tickTimer = eff.tickTimer + dt
                    while eff.tickTimer >= eff.tickInterval do
                        eff.tickTimer = eff.tickTimer - eff.tickInterval
                        if eff.onTick then
                            eff.onTick(self, eff)
                        end
                    end
                end
            end
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
