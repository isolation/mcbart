local IN_SIGN_PROTOCOL_VERSION = 2
local SCRIPT_VERSION = "202203112056"

local track_id_file = fs.open("/track_id.txt", "r")
local track_id = track_id_file.readAll()
track_id_file.close()

local station_id_file = fs.open("/station_id.txt", "r")
local station_id = station_id_file.readAll()
station_id_file.close()

local function Split(s, delimeter)
  local result = {};
  for match in (s..delimeter):gmatch("(.-)"..delimeter) do
    table.insert(result, match);
  end
  return result;
end

local mon_left = peripheral.wrap("left")
local mon_right = peripheral.wrap("right")

mon_left.setTextScale(1.0)
mon_right.setTextScale(1.0)
mon_left.clear()
mon_right.clear()
mon_left.setCursorPos(1,1)
mon_right.setCursorPos(1,1)
mon_left.write("Screen left started")
mon_right.write("Screen right started")

rednet.open("top")

print(("version %s"):format(SCRIPT_VERSION))
print(("running as station %s track %s"):format(station_id, track_id))
print(("understanding sign protocol version %s"):format(IN_SIGN_PROTOCOL_VERSION))

while true do
  local id, message = rednet.receive("station_sign")
  local msg_payload = Split(message, "|")
  -- protocol version | station id | track id | scaling | number of lines | line 1 [ | line 2 | line 3 | line 4 | line 5]
  local msg_protocol = msg_payload[1]
  local msg_station_id = msg_payload[2]
  local msg_track_id = msg_payload[3]
  local msg_scaling = msg_payload[4] -- unused for now
  local msg_line_count = msg_payload[5]
  --
  -- msg_payload[6] and beyond are lines to print
  --
  if msg_station_id == station_id and msg_track_id == track_id then
    mon_left.clear()
    mon_left.setCursorPos(1,1)
    mon_right.clear()
    mon_right.setCursorPos(1,1)
    local lines_printed = 0
    repeat
      mon_left.write(msg_payload[6+lines_printed])
      mon_right.write(msg_payload[6+lines_printed])
      local cur_x, cur_y = mon_left.getCursorPos()
      mon_left.setCursorPos(1, cur_y+1)
      mon_right.setCursorPos(1, cur_y+1)
      lines_printed = lines_printed+1
    until(lines_printed > tonumber(msg_line_count))
  end
end

rednet.close("top")
