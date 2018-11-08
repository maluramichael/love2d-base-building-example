Class = require "thirdparty.classic.classic"
Vec = require "thirdparty.hump.vector"

Worker = require "worker"
Brain = require "brain"
Hive = require "hive"
Base = require "base"
Food = require "food"

function love.load()
  workers = {
    Worker()
  }
  food = {
    Food(math.random(100, 700), math.random(100, 500)),
    Food(math.random(100, 700), math.random(100, 500))
  }
  base = Base(400, 300)
  hive = Hive()
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
    love.graphics.setColor(1, 0, 0, 0.3)
    love.graphics.circle("fill", x, y, w.attackRadius)
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", x, y, 10)
    love.graphics.print(
      string.format(
        "pos(%d, %d)\ndistance(%d)\nstate(%s)", 
        x, y, mouse:dist(w.position), w.brain.current
      ), x - 10, y + 20
    )
  end
  love.graphics.pop()

  -- Draw food
  love.graphics.push("all")
  for i, f in ipairs(food) do
    local x, y = math.floor(f.position.x), math.floor(f.position.y)
    love.graphics.setColor(0, 1, 1)
    love.graphics.circle("fill", x, y, 4)
    love.graphics.print(string.format("amount(%d)", f.amount), x, y)
  end
  love.graphics.pop()

  -- Draw base
  love.graphics.push("all")
  love.graphics.setColor(1, 1, 0)
  love.graphics.circle('line', base.position.x, base.position.y, 40)
  love.graphics.print(string.format("food(%d)", base.food), base.position.x - 40, base.position.y + 50)
  love.graphics.pop()
end

function love.update(dt)
  hive:update(dt)
end

function love.keypressed(key, code, isRepeat)
  if key == "escape" then
    love.event.quit()
  end
  if key == "r" then
    love.event.quit("restart")
  end
end
