--[[ MainBuilder: Entry point that requires WorldBuilder and runs it when the game starts ]]

local WorldBuilder = require(script.Parent:WaitForChild("WorldBuilder"))

local MainBuilder = {}

function MainBuilder.Run()
	print("[MainBuilder] Starting world construction...")
	WorldBuilder.BuildAll()
	print("[MainBuilder] World construction complete.")
end

return MainBuilder