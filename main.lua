Class = require "thirdparty.classic.classic"
Vec = require "thirdparty.hump.vector"

Settings = require "settings"

Worker = require "worker"
Brain = require "brain"
Hive = require "hive"
Base = require "base"
Food = require "food"

function love.load()
  love.math.setRandomSeed(love.timer.getTime())
  love.graphics.setDefaultFilter("nearest", "nearest")

  imageApple = love.graphics.newImage("assets/images/apple.png")
  workerImage = love.graphics.newImage("assets/images/worker.png")
  workerQuad = love.graphics.newQuad(0, 0, 16, 16, workerImage:getDimensions())

  workers = {}
  food = {}
  base = Base(Settings.width * 0.5, Settings.height * 0.5)
  hive = Hive()

  for i = 1, 10 do
    table.insert(workers, Worker(math.random(100, Settings.width - 100), math.random(100, Settings.height - 100)))
  end

  foodSpawnTimer = 0.3
end

-- system
function love.draw()
  local mx, my = love.mouse.getPosition()
  local mouse = Vec(mx, my)

  love.graphics.clear(0.1, 0.1, 0.1)

  -- Draw worker
  love.graphics.push("all")
  love.graphics.print(string.format("%d, %d", mx, my))
  for i, w in ipairs(workers) do
    local x, y = math.floor(w.position.x), math.floor(w.position.y)
    love.graphics.setColor(1, 0, 0, 0.1)
    love.graphics.circle("fill", x, y, w.attackRadius)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(workerImage, workerQuad, x - 16, y - 16, 0, 2)
    love.graphics.print(
      string.format(
        "pos(%d, %d)\ndistance(%d)\nstate(%s)\nweight(%f/%d)",
        x,
        y,
        mouse:dist(w.position),
        w.brain.current,
        w.weight,
        w.maxWeight
      ),
      x,
      y + 20
    )
  end
  love.graphics.pop()

  -- Draw food
  love.graphics.push("all")
  for i, f in ipairs(food) do
    local x, y = math.floor(f.position.x), math.floor(f.position.y)
    love.graphics.draw(imageApple, x - 16, y - 16, 0, 2)
    love.graphics.print(string.format("amount(%d)", f.amount), x, y)
  end
  love.graphics.pop()

  -- Draw base
  love.graphics.push("all")
  love.graphics.setColor(1, 1, 0)
  love.graphics.circle("line", base.position.x, base.position.y, 40)
  love.graphics.print(string.format("food(%d)", base.food), base.position.x - 40, base.position.y + 50)
  love.graphics.pop()
end

function love.update(dt)
  hive:update(dt)

  foodSpawnTimer = foodSpawnTimer - dt
  if foodSpawnTimer <= 0 then
    foodSpawnTimer = 0.3
    spawnFood()
  end
end

function love.keypressed(key, code, isRepeat)
  if key == "escape" then
    love.event.quit()
  end
  if key == "r" then
    love.event.quit("restart")
  end
end

function spawnFood()
  if #food <= 20 then
    table.insert(food, Food(math.random(100, Settings.width - 100), math.random(100, Settings.height - 100)))
  end
end
