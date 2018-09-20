Player = {}

function Player:Create(number)
    local player = {
        num = number,
        picks = 5,
        maxMana = 50,
        maxHealth = 50,
        health = 0,
        mana = 0,
        manaRegen = 0
    }
    return player
end
