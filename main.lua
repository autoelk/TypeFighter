local utf8 = require("utf8")
require "cards"
require "player"

cards = {}

function love.load()
  math.randomseed(os.time())
  background = love.graphics.newImage("Assets/Background.png")
  person = love.graphics.newImage("Assets/Person.png")
  titleFont = love.graphics.newFont("Assets/munro.ttf", 96)
  uiFont = love.graphics.newFont("Assets/munro.ttf", 36)
  font = love.graphics.newFont("Assets/munro-narrow.ttf", 24)
  --initialize variables
  input = ""
  message = "Type P to Start"
  gameStage = "menu"

  --opponent stats
  oppPickCooldown = 0
  oppCastCooldown = 0
  oppPickSpeed = 2
  oppCastSpeed = 3

  --read each card into array cards
  io.input("Assets/Cards/cards.txt")
  numCards = io.read()
  for i = 1, numCards do
    cards[i] = Card:Create()
  end
  io.close()

  player1 = Player:Create(1)
  player2 = Player:Create(2)

  --allow repeating input
  love.keyboard.setKeyRepeat(true)
  --scrolling
  scrollSpeed = 30
  posx, posy = 800 * 0.5, 200
  velx, vely = 0, 0 -- The scroll velocity
end

function love.keypressed(key)
  --erase message
  message = ""
  --textbox
  if key == "backspace" then
    if utf8.offset(input, - 1) then
      input = string.sub(input, 1, utf8.offset(input, - 1) - 1)
    end
  end
  if key == "return" then
    --take input
    input = string.gsub(string.lower(input), "%s+", "")
    local location = findCard(input)
    --find location of card
    if (input == "p" or input == "play game") and gameStage == "menu" then
      --start game
      gameStage = "cardSelect"
      input = ""
      message = 'Type "deck" to view current deck and type "start" when you are done'
    elseif (input == "q" or input == "quit") and gameStage == "menu" then
      love.event.quit()
    elseif location > 0 and gameStage == "cardSelect" then
      --add card to deck
      if player1.picks <= 0 then
        message = "You have no picks remaining"
      elseif cards[location].deck == 1 then
        message = "Sorry, but " .. cards[location].name .. " is already in your deck"
      elseif cards[location].deck == 2 then
        message = "Sorry, but " .. cards[locaiton].name .. " is already in your opponent's deck"
      else
        cards[location].deck = 1
        message = cards[location].name .. " was added to you deck"
        player1.picks = player1.picks - 1
      end
    elseif input == "start" and gameStage == "cardSelect" then
      if player1.picks > 0 then -- switch gamestage to game when both are done picking
        message = "You stil have " .. player1.picks .. " picks left"
        -- elseif player2.picks > 0 then
        --     message = "Opponent stil has " .. player2.picks .. " picks left"
      else
        message = "Game Started"
        gameStage = "game"
      end
    elseif (input == "q" or input == "quit") and gameStage == "cardSelect" then
      gameStage = "menu"
    elseif location > 0 and gameStage == "game" then
      --cast the spell
      player1:Cast(location)
    elseif (input == "q" or input == "quit") and gameStage == "game" then
      gameStage = "cardSelect"
    elseif input == "deck" then
      message = printDeck()
    else
      message = "invalid input" --error message
    end
    input = "" -- clear input
  end
end

function love.update(dt)
  if input ~= "" then
    message = ""
  end
  --animations
  for i = 1, numCards do
    cards[i].anim.currentTime = cards[i].anim.currentTime + dt
    if cards[i].anim.currentTime >= cards[i].anim.duration then
      cards[i].anim.currentTime = cards[i].anim.currentTime - cards[i].anim.duration
    end
  end
  --scrolling
  if posy >= 200 then
    posy = 200
  end
  posx = posx + velx * scrollSpeed * dt
  posy = posy + vely * scrollSpeed * dt

  -- Gradually reduce the velocity to create smooth scrolling effect.
  velx = velx - velx * math.min(dt * 10, 1)
  vely = vely - vely * math.min(dt * 10, 1)

  --opponent logic stuff
  if gameStage == "cardSelect" then
    oppPickCooldown = oppPickCooldown - dt
    if oppPickCooldown <= 0 then
      cardToPick = math.random(1, numCards)
      -- cards[cardToPick].location = 2
      oppPickCooldown = oppPickCooldown + oppPickSpeed
    end
    oppPickCooldown = math.max(oppPickCooldown,0)
  elseif gameStage == "game" then
    oppCastCooldown = oppCastCooldown - dt
    if oppCastCooldown <= 0 then
      cardToPick = math.random(1, numCards)
      player2:Cast(cardToPick)
      oppCastCooldown = oppCastCooldown + oppCastSpeed
    end
    oppCastCooldown = math.max(oppCastCooldown,0)
  end
end

function love.draw()
  --background
  love.graphics.draw(background, 0, 0)
  love.graphics.setFont(font)
  love.graphics.draw(person, 100, 320)
  love.graphics.draw(person, 700, 320, 0, - 1, 1)
  if gameStage == "menu" then
    --title
    love.graphics.setColor(0, 0, 0, 0.75)
    love.graphics.rectangle("fill", 0, 205, 800, 160)
    love.graphics.setColor(255, 255, 255)
    love.graphics.setFont(titleFont) --set font to title font
    love.graphics.printf("TypeFighter", 0, 200, 800, "center")
    --menu
    love.graphics.setFont(font)
    love.graphics.printf("[P]lay Game\n[Q]uit", 0, 300, 800, "center")
    -- love.graphics.printf("Music by Eric Matyas www.soundimage.org", 0, 540, 800, "right")
    --animation
    local spriteNum0 = math.floor(cards[findCard("torrent")].anim.currentTime / cards[findCard("torrent")].anim.duration * #cards[findCard("torrent")].anim.quads) + 1
    local spriteNum1 = math.floor(cards[findCard("fireball")].anim.currentTime / cards[findCard("fireball")].anim.duration * #cards[findCard("fireball")].anim.quads) + 1
    love.graphics.draw(cards[findCard("torrent")].anim.spriteSheet, cards[findCard("torrent")].anim.quads[spriteNum0], 50, 180, 0, 1)
    love.graphics.draw(cards[findCard("fireball")].anim.spriteSheet, cards[findCard("fireball")].anim.quads[spriteNum1], 750, 345, 3.14159, 1)
  elseif gameStage == "cardSelect" then --Stage of card selection
    --Display card select title
    love.graphics.setFont(titleFont) --set font to title font
    love.graphics.printf("Select Cards", 0, posy - 135, 800, "center")

    for i = 1, numCards do
      Card:Display(i)
    end
  elseif gameStage == "game" then
    love.graphics.setFont(uiFont)
    love.graphics.printf(player1.health, 25, 25, 800, "left")
    love.graphics.printf(player2.health, - 25, 25, 800, "right")
  end

  --input box at bottom of screen
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle("fill", 0, 570, 800, 30)
  love.graphics.setFont(font)
  love.graphics.setColor(255, 255, 255) -- reset colors
  love.graphics.printf(message, 5, 570, 800, "left")
  love.graphics.printf(input, 5, 570, 800, "left")
end

function printDeck()
  local deck = ""
  for i = 1, numCards do
    if cards[i].deck == 1 then
      deck = deck .. cards[i].name .. " "
    end
  end
  if deck == "" then
    deck = "Your deck is currently empty, add cards by typing their names"
  end
  return deck
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
