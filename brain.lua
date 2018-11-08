Class = require "thirdparty.classic.classic"

Priorities = require "priorities"

local Brain = Class:extend()
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
  for i, p in ipairs(Priorities) do
    if self.states[p].check(dt, self.parent) then
      self.current = p
      return p
    end
  end
  return Priorities[#Priorities]
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
return Brain
