return function(context)
  local items = context:require "artist.core.items"
  local furnaces = context:require "artist.items.furnaces"
  
  -- Pointing directly to your specific monitor
  local monitor = peripheral.wrap("monitor_3")
  if not monitor then return end

  -- Custom progress bar to replace the missing widget library
  local function drawBar(y, value, max_value)
    local width, height = monitor.getSize()
    if max_value == 0 then max_value = 1 end
    local fill = math.floor((value / max_value) * width)
    if fill > width then fill = width end
    
    monitor.setCursorPos(1, y)
    monitor.setBackgroundColour(colours.gray)
    monitor.write(string.rep(" ", width))
    
    monitor.setCursorPos(1, y)
    monitor.setBackgroundColour(colours.blue)
    monitor.write(string.rep(" ", fill))
    monitor.setBackgroundColour(colours.black)
  end

  local function redraw()
    monitor.setTextColour(colours.white)
    monitor.setBackgroundColour(colours.black)
    monitor.clear()

    local used_slots, total_slots = 0, 0
    for _, inventory in pairs(items.inventories) do
      for _, slot in pairs(inventory.slots or {}) do
        total_slots = total_slots + 1
        if slot.count > 0 then
          used_slots = used_slots + 1
        end
      end
    end

    if total_slots == 0 then total_slots = 1 end

    monitor.setCursorPos(1, 1)
    monitor.write(("Slots: %d/%d"):format(used_slots, total_slots))
    drawBar(2, used_slots, total_slots)

    local hot_furnaces, cold_furnaces = 0, 0
    for _ in pairs(furnaces.hot_furnaces) do hot_furnaces = hot_furnaces + 1 end
    for _ in pairs(furnaces.cold_furnaces) do cold_furnaces = cold_furnaces + 1 end
    local total_furnaces = hot_furnaces + cold_furnaces
    if total_furnaces == 0 then total_furnaces = 1 end

    monitor.setCursorPos(1, 4)
    monitor.write(("Furnaces: %d/%d"):format(hot_furnaces, total_furnaces))
    drawBar(5, hot_furnaces, total_furnaces)
  end

  local next_redraw = nil
  local function queue_redraw()
    if next_redraw then return end
    next_redraw = os.startTimer(0.2)
  end

  context.mediator:subscribe("items.inventories_change", queue_redraw)
  context.mediator:subscribe("items.change", queue_redraw)
  context.mediator:subscribe("furnaces.change", queue_redraw)

  context:spawn(function(id)
    redraw()
    while true do
      local _, id = os.pullEvent("timer")
      if id == next_redraw then
        next_redraw = nil
        redraw()
      end
    end
  end)
end
