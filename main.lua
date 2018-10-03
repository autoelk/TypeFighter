local utf8 = require("utf8")
require "cards"
require "player"

cards = {}
deck = {}
colors = {
  red = {250 / 255, 89 / 255, 52 / 255},
  orange = {250 / 255, 121 / 255, 33 / 255},
  yellow = {253 / 255, 231 / 255, 76 / 255},
  green = {155 / 255, 197 / 255, 61 / 255},
  blue = {91 / 255, 192 / 255, 235 / 255},
  grey = {77 / 255, 80 / 255, 87 / 255},
  white = {1, 1, 1},
  black = {0, 0, 0}
}

function love.load()
  math.randomseed(os.time())
  background = love.graphics.newImage("Assets/Background.png")
  titleFont = love.graphics.newFont("Assets/munro-small.ttf", 96)
  uiFont = love.graphics.newFont("Assets/munro-small.ttf", 36)
  font = love.graphics.newFont("Assets/munro-small.ttf", 24)
  cardTextFont = love.graphics.newFont("Assets/munro-small.ttf", 18)
  miniTextFont = love.graphics.newFont("Assets/munro-small.ttf", 15)

  --read each card into array cards
  io.input("Assets/Cards/cards.txt")
  numCards = io.read()
  for i = 1, numCards do
    cards[i] = Card:Create(i)
  end
  io.close()

  player1 = Player:Create(1)
  opp = Player:Create(2)

  --allow repeating input
  love.keyboard.setKeyRepeat(true)
  Setup()
end

function Setup()
  --initialize variables
  input = ""
  message = "Type P to Start"
  message2 = "[P]lay [B]rowse [Q]uit"
  gameStage = "menu"

  --opponent stats
  oppPickSpeed = 5
  oppCastSpeed = 2
  oppPickCooldown = oppPickSpeed
  oppCastCooldown = oppCastSpeed

  --scrolling
  scrollSpeed = 30
  posx, posy = 800 * 0.5, 200
  velx, vely = 0, 0 -- The scroll velocity

  --reset decks
  for i = 1, numCards do
    cards[i].deck = 0
  end

  --reset players
  player1.health = 50
  player1.healthRegen = 0
  player1.mana = 0
  player1.manaRegen = 1
  player1.spriteNum = 1
  player1.picks = 5
  player1.anim.currentTime = 0
  opp.health = 50
  opp.healthRegen = 0
  opp.mana = 0
  opp.manaRegen = 1
  opp.spriteNum = 1
  opp.picks = 5
  opp.anim.currentTime = 0

  --reset time
  gameTime = 0
end

function love.keypressed(key)
  --textbox
  if key == "backspace" then
    if utf8.offset(input, - 1) then
      input = string.sub(input, 1, utf8.offset(input, - 1) - 1)
    end
  end
  --erase message
  message = ""

  if key == "return" then
    --take input
    input = string.gsub(string.lower(input), "%s+", "")
    local location = findCard(input)
    --find location of card
    if gameStage == "menu" then
      if input == "p" or input == "play game" then
        --show instructions
        gameStage = "instructions"
        endInstruct = gameTime + 20
        input = ""
        message2 = "[P] to Skip [Q] to go back"
      elseif input == "b" then
        gameStage = "cardBrowse"
        message2 = "[Q] to go back"
      elseif input == "q" or input == "quit" then
        love.event.quit()
      end
    elseif gameStage == "cardBrowse" then
      if input == "q" then
        gameStage = "menu"
        Setup()
      end
    elseif gameStage == "instructions" then
      if input == "p" or input == "play game" then
        gameStage = "cardSelect"
        endInstruct = 0
        message2 = "[P]lay [Q] to go back"
      elseif input == "q" then
        gameStage = "menu"
        Setup()
      end
    elseif gameStage == "cardSelect" then
      if location > 0 then
        --add card to deck
        if cards[location].deck == 1 then
          cards[location].deck = 0
          message = cards[location].name .. " was removed from your deck"
          player1.picks = player1.picks + 1
        elseif cards[location].deck == 2 then
          message = "Sorry, but " .. cards[location].name .. " is already in your opponent's deck"
        elseif player1.picks <= 0 then
          message = "You have no picks remaining"
        else
          cards[location].deck = 1
          message = cards[location].name .. " was added to your deck"
          player1.picks = player1.picks - 1
        end
      elseif input == "start" or input == "p" then
        if player1.picks > 0 then -- switch gamestage to game when both are done picking
          message = "You stil have " .. player1.picks .. " picks left"
        elseif opp.picks > 0 then
          message = "Opponent stil has " .. opp.picks .. " picks left"
        else
          message = "Game Started"
          gameStage = "game"
        end
      elseif input == "q" or input == "quit" then
        Setup()
        gameStage = "menu"
      else
        message = "Type card names to choose them"
      end
    elseif gameStage == "game" then
      if location > 0 then
        --cast the spell
        player1:Cast(location)
      elseif input == "cardnamestocastthem" then
        opp:Damage(1000000000)
      elseif input == "q" or input == "quit" then
        gameStage = "cardSelect"
      else
        message = "Type card names to cast them"
      end
    elseif gameStage == "over" then
      if input == "q" or input == "quit" then
        love.event.quit()
      elseif input == "r" or input == "restart" then
        Setup()
        gameStage = "menu"
      end
    else
      message = "invalid input" --error message
    end

    input = "" -- clear input
  end
end

function love.update(dt)
  --animations
  for i = 1, numCards do
    cards[i].anim.currentTime = cards[i].anim.currentTime + dt
    if cards[i].anim.currentTime >= cards[i].anim.duration then
      cards[i].anim.currentTime = cards[i].anim.currentTime - cards[i].anim.duration
    end
  end
  if player1.health <= 0 then
    player1.anim.currentTime = player1.anim.currentTime + dt
    if player1.anim.currentTime >= player1.anim.duration then
      player1.anim.currentTime = player1.anim.currentTime - player1.anim.duration
    end
  elseif opp.health <= 0 then
    opp.anim.currentTime = opp.anim.currentTime + dt
    if opp.anim.currentTime >= opp.anim.duration then
      opp.anim.currentTime = opp.anim.currentTime - opp.anim.duration
    end
  end

  for k, v in pairs(deck) do
    deck[k] = nil
  end
  for i = 1, numCards do
    if cards[i].deck == 1 then
      table.insert(deck, i)
    end
  end

  --scrolling
  if posy >= 200 then
    posy = 200
  elseif posy <= (math.ceil(numCards / 3) - 1) * - 317 + 25 then
    posy = (math.ceil(numCards / 3) - 1) * - 317 + 25
  end
  posx = posx + velx * scrollSpeed * dt
  posy = posy + vely * scrollSpeed * dt

  -- Gradually reduce the velocity to create smooth scrolling effect.
  velx = velx - velx * math.min(dt * 10, 1)
  vely = vely - vely * math.min(dt * 10, 1)

  gameTime = gameTime + dt
  if gameStage == "instructions" and gameTime >= endInstruct then
    gameStage = "cardSelect"
    message2 = "[P]lay"
  end

  --health and mana regen
  if gameStage == "game" then
    player1.mana = player1.mana + dt * player1.manaRegen
    if player1.mana < 0 then
      player1.mana = 0
    end
    opp.mana = opp.mana + dt * opp.manaRegen
    if opp.mana < 0 then
      opp.mana = 0
    end
    player1.health = player1.health + dt * player1.healthRegen
    opp.health = opp.health + dt * opp.healthRegen
  end

  --opponent action
  if gameStage == "cardSelect" then
    oppPickSpeed = player1.picks + 1
    oppPickCooldown = oppPickCooldown - dt
    if oppPickCooldown <= 0 then
      local cardToPick = math.random(1, numCards)
      if cards[cardToPick].deck == 0 and cards[cardToPick].name ~= "ritual" and opp.picks > 0 then
        cards[cardToPick].deck = 2
        opp.picks = opp.picks - 1
        oppPickCooldown = oppPickCooldown + oppPickSpeed
      end
    end
    oppPickCooldown = math.max(oppPickCooldown, 0)
  elseif gameStage == "game" then
    oppCastCooldown = oppCastCooldown - dt
    if oppCastCooldown <= 0 then
      local cardToPick = math.random(1, numCards)
      local castChance = math.random(1, 100)
      if cards[cardToPick].deck == 2 and cards[cardToPick].mana <= opp.mana and castChance >= 80 then
        opp:Cast(cardToPick)
        oppCastCooldown = oppCastCooldown + oppCastSpeed
      end
    end
    oppCastCooldown = math.max(oppCastCooldown, 0)
  end
end

function love.draw()
  --background
  love.graphics.draw(background, 0, 0)
  love.graphics.setFont(font)
  --players
  player1:Draw()
  love.graphics.setColor(colors.red)
  opp:Draw()
  love.graphics.setColor(colors.white)

  if gameStage == "menu" then
    --title
    love.graphics.setFont(titleFont) --set font to title font
    love.graphics.printf("TypeFighter", 0, 200, 800, "center")
    --menu
    love.graphics.setFont(font)
    love.graphics.printf("[P]lay Game\n[B]rowse Cards\n[Q]uit", 0, 300, 800, "center")
    -- love.graphics.printf("Music by Eric Matyas www.soundimage.org", 0, 540, 800, "right")
    --animation
    local spriteNum0 = math.floor(cards[findCard("torrent")].anim.currentTime / cards[findCard("torrent")].anim.duration * #cards[findCard("torrent")].anim.quads) + 1
    local spriteNum1 = math.floor(cards[findCard("fireball")].anim.currentTime / cards[findCard("fireball")].anim.duration * #cards[findCard("fireball")].anim.quads) + 1
    love.graphics.draw(cards[findCard("torrent")].anim.spriteSheet, cards[findCard("torrent")].anim.quads[spriteNum0], 50, 180, 0, 1)
    love.graphics.draw(cards[findCard("fireball")].anim.spriteSheet, cards[findCard("fireball")].anim.quads[spriteNum1], 750, 345, 3.14159, 1)
  elseif gameStage == "cardBrowse" then
    love.graphics.setFont(titleFont) --set font to title font
    love.graphics.printf("Browse Cards", 0, posy - 135, 800, "center")
    for i = 1, numCards do
      local colNum, rowNum = i % 4, math.ceil(i / 4)
      if colNum == 0 then
        colNum = 4
      end
      cards[i]:Display(196 * (colNum - 1) + 16, 268 * (rowNum - 1) + posy)
    end
  elseif gameStage == "instructions" then
    --display instructions
    love.graphics.setFont(font)
    love.graphics.setColor(colors.black)
    love.graphics.rectangle("fill", 200, 150, 400, 300)
    love.graphics.setColor(colors.white)
    love.graphics.printf(
      "Choose 5 cards by typing their names before your opponent can chose them. You can remove cards from your deck by typing their name again. When you are done, type P to start.",
      210,
      160,
      380,
      "center"
    )
  elseif gameStage == "cardSelect" then --Stage of card selection
    --Display card select title
    love.graphics.setFont(titleFont) --set font to title font
    love.graphics.printf("Select Cards", 0, posy - 135, 580, "center")

    local cardsGone = 0
    for i = 1, numCards do
      if cards[i].deck == 1 then
        cardsGone = cardsGone + 1
      else
        local colNum, rowNum = (i - cardsGone) % 3, math.ceil((i - cardsGone) / 3)
        if colNum == 0 then
          colNum = 3
        end
        cards[i]:Display(190 * (colNum - 1) + 10, 262 * (rowNum - 1) + posy)
      end
    end
    --display deck for card selection
    for i = 1, #deck do
      cards[deck[i]]:Display(595, 25 * i)
    end
  elseif gameStage == "game" then
    player1:DrawUI()
    opp:DrawUI()
    --display deck
    for i = 1, #deck do
      cards[deck[i]]:DisplayMini(155 * (i - 1) + 25, 500)
    end
    if player1.health <= 0 or opp.health <= 0 then
      gameStage = "over"
    end
  elseif gameStage == "over" then
    love.graphics.setFont(titleFont)
    if player1.health <= 0 and opp.health <= 0 then
      gameOverMessage = "Tie"
    elseif player1.health <= 0 then
      gameOverMessage = "Player2 Wins"
    elseif opp.health <= 0 then
      gameOverMessage = "Player1 Wins"
    end
    love.graphics.printf(gameOverMessage, 0, 200, 800, "center")
    --menu
    love.graphics.setFont(font)
    love.graphics.printf("[R]estart Game\n[Q]uit", 0, 300, 800, "center")
  end

  --input box at bottom of screen
  love.graphics.setColor(colors.black)
  love.graphics.rectangle("fill", 0, 570, 800, 30)
  love.graphics.setFont(font)
  love.graphics.setColor(colors.white) -- reset colors
  love.graphics.printf(message, 5, 570, 800, "left")
  love.graphics.printf(message2, - 5, 570, 800, "right")
  love.graphics.printf(input, 5, 570, 800, "left")
end

function newAnimation(image, width, height, duration)
  local animation = {}
  animation.spriteSheet = image
  animation.quads = {}

  for y = 0, image:getHeight() - height, height do
    for x = 0, image:getWidth() - width, width do
      table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
    end
  end

  animation.duration = duration or 1
  animation.currentTime = 0

  return animation
end

function love.textinput(t)
  input = input .. t
end

function split(pString, pPattern)
  local Table = {}
  local fpat = "(.-)" .. pPattern
  local last_end = 1
  local s, e, cap = pString:find(fpat, 1)
  while s do
    if s ~= 1 or cap ~= "" then
      table.insert(Table, cap)
    end
    last_end = e + 1
    s, e, cap = pString:find(fpat, last_end)
  end
  if last_end <= #pString then
    cap = pString:sub(last_end)
    table.insert(Table, cap)
  end
  return Table
end

function fileCheck(file_name)
  local file_found = io.open(file_name, "r")

  if file_found == nil then
    file_found = false
  else
    file_found = true
  end
  return file_found
end

function love.wheelmoved(dx, dy)
  velx = velx + dx * 20
  vely = vely + dy * 20
end
