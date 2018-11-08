return {
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
