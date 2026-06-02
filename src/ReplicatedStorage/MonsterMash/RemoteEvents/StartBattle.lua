--[[ StartBattle RemoteEvent ]]
-- Client fires to notify server player has entered an arena

local remoteEvent = Instance.new("RemoteEvent")
remoteEvent.Name = "StartBattle"
remoteEvent.Parent = script.Parent

return remoteEvent