Class = require "thirdparty.classic.classic"

local Base = Class:extend()
function Base:new(x, y)
  self.position = Vec(x, y)
  self.food = 0
end
return Base
