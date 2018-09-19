cards = {}

cards.name = {}
cards.damage = {}
cards.mana = {}
cards.type = {}
cards.elem = {}
cards.anim = {}

function readCards()
  --read each card into array cards
  io.input("Assets/Cards/cards.txt")
  numCards = io.read()
  for i = 1, numCards do
      local tempTable = split(io.read(), " ")
      cards.name[i] = tempTable[1]
      cards.damage[i] = tempTable[2]
      cards.mana[i] = tempTable[3]
      cards.type[i] = tempTable[4]
      cards.elem[i] = tempTable[5]
      if fileCheck("Assets/Cards/" .. tempTable[6]) then
          cards.anim[i] = newAnimation(love.graphics.newImage("Assets/Cards/" .. tempTable[6]), 160, 160, 1)
      else
          cards.anim[i] = newAnimation(love.graphics.newImage("Assets/Placeholder.png"), 160, 160, 1)
      end
  end
  io.close()
  return numCards
end

function findCard(thingToFind)
    thingToFind = string.lower(thingToFind)
    for i = 1, numCards do
        if cards.name[i] == thingToFind then
            return i
        end
    end
    return 0
end
