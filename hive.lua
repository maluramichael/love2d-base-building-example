Class = require "thirdparty.classic.classic"

local Hive = Class:extend()
function Hive:update(dt)
  for i, w in ipairs(workers) do
    local next = w.brain:run(dt)
    if next ~= nil and w.brain:canTransitionTo(next) then
      w.brain:transitionTo(next)
    end
  end
end
return Hive
