Settings = require "settings"

function love.conf(t)
  t.window.width = Settings.width
  t.window.height = Settings.height

  t.window.title = "Love2D Base Building Example"
end
