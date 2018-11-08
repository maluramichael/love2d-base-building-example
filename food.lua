Class = require "thirdparty.classic.classic"

local Food = Class:extend()
function Food:new(x, y)
  self.position = Vec(x, y)
  self.amount = math.random(5, 30)
  self.weight = 0.1
end
return Food
