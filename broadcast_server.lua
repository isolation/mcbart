local IN_DETECTOR_PROTOCOL_VERSION = 2
local OUT_SIGN_PROTOCOL_VERSION = 2
local SCRIPT_VERSION = "202203120458"

local function Split(s, delimeter)
  local result = {};
  for match in (s..delimeter):gmatch("(.-)"..delimeter) do
    table.insert(result, match);
  end
  return result;
end

local function format_line_one(terminus_name, minutes_until)
  local chars_present = string.len(terminus_name) + string.len(minutes_until) + string.len(" MIN")
  local spaces_needed = 29 - chars_present
  local formatted_line = ("%s%s%s MIN"):format(terminus_name, string.rep(" ", spaces_needed), minutes_until)
  return formatted_line
end

local function tell_sign(station_id, track_id, terminusName, minutesUntil)
  local line_one = format_line_one(terminusName, minutesUntil)
  local line_two = "2-CAR, 2-DOOR"
  -- protocol version | station id | track id | scaling | number of lines | line 1 [ | line 2 | line 3 | line 4 | line 5]
  --   note: don't use more than 1 line for scaling > 1.0
  local msg = ("%s|%s|%s|1.0|2|%s|%s"):format(OUT_SIGN_PROTOCOL_VERSION, station_id, track_id, line_one, line_two)
  print("sending station_sign message:")
  print(msg)
  rednet.broadcast(msg, "station_sign")
end

rednet.open("back")

print(("version %s"):format(SCRIPT_VERSION))
print("broadcast server active")

while true do
  local id, message = rednet.receive("rail_detector")
  local msg_payload = Split(message, "|") 
  -- protocol version, segment id, track id, detector id, side that got the signal
  -- putting these into vars to make life easier
  local protocol_ver = msg_payload[1]
  local segment_id = msg_payload[2]
  local track_id = msg_payload[3]
  local detector_id = msg_payload[4]
  local side_detected = msg_payload[5]
  -- debug output
  print(("protocol: %s"):format(protocol_ver))
  print(("segment: %s"):format(segment_id))
  print(("track: %s"):format(track_id))
  print(("detector: %s"):format(detector_id))
  print(("side: %s"):format(side_detected))
  -- eventually more logic around this
  if tonumber(protocol_ver) > tonumber(IN_DETECTOR_PROTOCOL_VERSION) then
    print("received message from unknown detector protocol version")
  end
  -- send to relevant signs
  if side_detected == "front" then -- it's going towards test base
    if segment_id == "1" then -- it's between test base and prod base
      tell_sign(1, 2, "TEST BASE", detector_id)
    end
  end
end
