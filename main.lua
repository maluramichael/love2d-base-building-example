Class = require "thirdparty.classic.classic"
Vec = require "thirdparty.hump.vector"

local Worker = Class:extend()
local Brain = Class:extend()
local Hive = Class:extend()
local State = Class:extend()
local Food = Class:extend()
local Base = Class:extend()

local priorities = {
  "attacking",
  "gathering",
  "taking_back",
  "building",
  "idling"
}

local states = {
  idling = {
    actions = {
      gather = "gathering",
      build = "building",
      attack = "attacking",
      take_back = "taking_back"
    },
    check = function(dt, host) return true end,
    run = function(dt, host) end
  },
  gathering = {
    actions = {
      idle = "idling",
      build = "building",
      attack = "attacking",
      take_back = "taking_back"
    },
    check = function(dt, host) return #food >= 1 end,
    run = function(dt, host)
      local shortestDistance = 999999
      local next = nil
      for i, f in ipairs(food) do
        local distance = host.position:dist(f.position)
        if distance < shortestDistance then
          next = f
          shortestDistance = distance
        end
      end
      if next ~= nil then
        if next.position:dist(host.position) < 10 then
          table.insert(host.hands, next)
          for i, f in ipairs(food) do
            if f == next then
              table.remove(food, i)
              break
            end
          end
        else 
          host.position = host.position + (next.position - host.position):normalized() * dt * host.speed
        end
      end
    end
  },
  building = {
    actions = {
      idle = "idling",
      gather = "gathering",
      attack = "attacking",
      take_back = "taking_back"
    },
    check = function(dt, host) return #food >= 1 end,
    run = function(dt)
    end
  },
  attacking = {
    actions = {
      idle = "idling",
      gather = "gathering",
      build = "building",
      take_back = "taking_back"
    },
    check = function(dt, host)
      local mx, my = love.mouse.getPosition()
      local mouse = Vec(mx, my)
      return mouse:dist(host.position) < host.attackRadius
    end,
    run = function(dt, host)
      local mx, my = love.mouse.getPosition()
      local mouse = Vec(mx, my)
      host.position = host.position + (mouse - host.position):normalized() * dt * host.speed
    end
  },
  taking_back = {
    actions = {
      idle = "idling",
      gather = "gathering",
      build = "building",
      attack = "attacking"
    },
    check = function(dt, host) return #host.hands >= 1 end,
    run = function(dt, host)
      local distance = base.position:dist(host.position)
      if distance < 10 then
        for i, h in ipairs(host.hands) do
          base.food = base.food + h.amount
        end
        host.hands = {}
      else
        host.position = host.position + (base.position - host.position):normalized() * dt * host.speed
      end
    end
  }
}

-- #############################################################################
-- 
-- #############################################################################
function Food:new(x, y)
  self.position = Vec(x, y)
  self.amount = math.random(1, 10)
end

-- #############################################################################
-- 
-- #############################################################################
function Base:new(x, y)
  self.position = Vec(x, y)
  self.food = 0
end

-- #############################################################################
-- Represents a working unit 
-- #############################################################################
function Worker:new()
  self.brain = Brain(self, 'idling', states)
  self.position = Vec(150, 150)
  self.speed = 100
  self.attackRadius = 150
  self.hands = {}
end
function Worker:update(dt)
  self.brain:update(dt)
end

-- #############################################################################
-- Just a state machine without any logic
-- #############################################################################
function Brain:new(parent, start, states)
  self.parent = parent
  self.current = start
  self.previous = nil
  self.states = states
end
function Brain:run(dt)
  self:check(dt)
  return self.states[self.current].run(dt, self.parent)
end
function Brain:check(dt)
  for i, p in ipairs(priorities) do
    if self.states[p].check(dt, self.parent) then
      self.current = p
      return p
    end
  end
  return priorities[#priorities]
end
function Brain:transitionTo(action)
  if self.states[self.current].actions[action] ~= nil then
    self.previous = self.current
    local next = self.states[self.current].actions[action]
    print("[+]Next state: " .. next)
    self.current = next
  end
  return self.current
end
function Brain:pop()
  if self.previous ~= nil then
    print("[+]Pop state to: " .. self.previous)
    self.current = self.previous
    self.previous = nil
  end
end
function Brain:canTransitionTo(action)
  return self.states[self.current].actions[action] ~= nil
end

-- #############################################################################
-- Contains the logic and tells the brain when to transition into another state
-- #############################################################################
function Hive:update(dt)
  for i, w in ipairs(workers) do
    local next = w.brain:run(dt)
    if next ~= nil and w.brain:canTransitionTo(next) then
      w.brain:transitionTo(next)
    end
  end
end

-- ########################################################
-- ########################################################
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
