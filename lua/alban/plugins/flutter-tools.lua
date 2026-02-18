-- import plugin safely
local setup, flutter = pcall(require, "flutter-tools")
if not setup then
  print("Error while require(flutter-tools)")
  return
end

flutter.setup {}
