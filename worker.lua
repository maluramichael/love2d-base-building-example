Class = require "thirdparty.classic.classic"
Vec = require "thirdparty.hump.vector"

States = require "states"

local Worker = Class:extend()
function Worker:new()
  self.brain = Brain(self, 'idling', States)
  self.position = Vec(150, 150)
  self.speed = 100
  self.attackRadius = 150
  self.hands = {}
end
function Worker:update(dt)
  self.brain:update(dt)
end
return Worker
