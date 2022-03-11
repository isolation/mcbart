local OUT_DETECTOR_PROTOCOL_VERSION = 2

local segment_id_file = fs.open("/segment_id.txt", "r")
local segment_id = segment_id_file.readAll()
segment_id_file.close()

local track_id_file = fs.open("/track_id.txt", "r")
local track_id = track_id_file.readAll()
track_id_file.close()

local detector_id_file = fs.open("/detector_id.txt", "r")
local detector_id = detector_id_file.readAll()
detector_id_file.close()

local function send_msg(side)
  -- protocol version, segment ID, track ID, detector ID, side of detection
  local msg = ("%s|%s|%s|%s|%s"):format(OUT_DETECTOR_PROTOCOL_VERSION, segment_id, track_id, detector_id, side)
  print("sending: ")
  print(msg)
  rednet.broadcast(msg, "rail_detector")
  sleep(2) -- terrible debounce method
end

rednet.open("left")

print("detector active")
print(("segment %s, track %s, detector %s"):format(segment_id, track_id, detector_id))
print(("speaking detector protocol version %s"):format(OUT_DETECTOR_PROTOCOL_VERSION))

while true do
  os.pullEvent("redstone")
  if rs.getInput("front") then
    send_msg("front")
  elseif rs.getInput("back") then
    send_msg("back")
  end
end

rednet.close("left")
