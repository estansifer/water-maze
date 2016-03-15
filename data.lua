-- Copied from data/base/prototypes/tile/tiles.lua
function water_autoplace_settings(from_depth, rectangles)
  local ret =
  {
    {
      -- Water and deep water have absolute priority. We simulate this by giving
      -- them absurdly large influence
      influence = 1e3 + from_depth,
      elevation_optimal = -5000 - from_depth,
      elevation_range = 5000,
      elevation_max_range = 5000, -- everywhere below elevation 0 and nowhere else
    }
  }

  if rectangles == nil then
    ret[2] = { influence = 1 }
  end

  -- autoplace_utils.peaks(rectangles, ret)

  return { peaks = ret }
end

local t = data.raw.tile
local x = water_autoplace_settings(10000)

t.water.autoplace = x
t.deepwater.autoplace = x
t['water-green'].autoplace = x
t['deepwater-green'].autoplace = x
