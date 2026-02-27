local files = {
  "artist/core/context.lua",
  "artist/core/items.lua",
  "artist/gui/core.lua",
  "artist/gui/extra.lua",
  "artist/gui/interface.lua",
  "artist/gui/interface/pickup_chest.lua",
  "artist/gui/interface/turtle.lua",
  "artist/gui/item_list.lua",
  "artist/init.lua",
  "artist/items/annotate.lua",
  "artist/items/annotations.lua",
  "artist/items/cache.lua",
  "artist/items/dropoff.lua",
  "artist/items/furnaces.lua",
  "artist/items/inventories.lua",
  "artist/items/trashcan.lua",
  "artist/lib/class.lua",
  "artist/lib/concurrent.lua",
  "artist/lib/config.lua",
  "artist/lib/log.lua",
  "artist/lib/mediator.lua",
  "artist/lib/serialise.lua",
  "artist/lib/tbl.lua",
  "artist/lib/turtle.lua",
  "artist/lib/widget.lua",
  "launch.lua",
  "metis/input/keybinding.lua",
  "metis/string/fuzzy.lua",
}

print("Starting secure download sequence...")

for i, path in ipairs(files) do
  print("Fetching: " .. path)
  local url = "https://raw.githubusercontent.com/SquidDev-CC/artist/master/src/" .. path
  local req, err = http.get(url)
  
  if not req then 
    print(" -> ERROR: " .. tostring(err))
  else
    local save_path = ".artist.d/src/" .. path
    local file = fs.open(save_path, "w")
    if file then
      file.write(req.readAll())
      file.close()
    else
      print(" -> ERROR: Could not write to disk.")
    end
    req.close()
  end
end

print("Generating boot file...")
local boot_file = fs.open("artist.lua", "w")
boot_file.write('shell.run(".artist.d/src/launch.lua")')
boot_file.close()

print("Installation Complete! Run 'artist.lua' to start.")
