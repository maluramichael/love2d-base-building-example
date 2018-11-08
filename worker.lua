Class = require "thirdparty.classic.classic"
Vec = require "thirdparty.hump.vector"

States = require "states"

local Worker = Class:extend()
function Worker:new(x, y)
  self.brain = Brain(self, "idling", States)
  self.position = Vec(x, y)

  self.bag = {}

  self.speed = 150
  self.attackRadius = 50
  self.weight = 0
  self.maxWeight = 5
end
function Worker:calculateWeight()
  self.weight = 0
  for index, item in ipairs(self.bag) do
    self.weight = self.weight + item.weight * item.amount
  end
  return self.weight
end
function Worker:getSpeed()
  self:calculateWeight()
  if self.weight > self.maxWeight then
    return self.speed * 0.5
  else
    return self.speed
  end
end
function Worker:update(dt)
  self.brain:update(dt)
end
return Worker
