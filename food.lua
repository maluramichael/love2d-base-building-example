Class = require "thirdparty.classic.classic"

local Food = Class:extend()
function Food:new(x, y)
  self.position = Vec(x, y)
  self.amount = math.random(1, 10)
end
return Food
