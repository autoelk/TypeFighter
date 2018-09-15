cards = {
    ["name"] = {},
    ["damage"] = {},
    ["mana"] = {},
    ["type"] = {}
}

function readCards()
    io.input("Assets/cards.txt")
    numCards = io.read()
    for i=1,numCards do
        io.read()
        cards.name[i] = io.read()
        cards.damage[i] = io.read()
        cards.mana[i] = io.read()
        cards.type[i] = io.read()
    end
    print("numCards: " .. numCards)
    for i=1,numCards do
        print("name: " .. cards.name[i])
        print("damage: " .. cards.damage[i])
        print("mana: " .. cards.mana[i])
        print("type: " .. cards.type[i])
    end
    io.close()
end

readCards()