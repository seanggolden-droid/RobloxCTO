--[[ CollectEnergy RemoteEvent ]]
-- Client fires this to collect energy from the environment

local remoteEvent = Instance.new("RemoteEvent")
remoteEvent.Name = "CollectEnergy"
remoteEvent.Parent = script.Parent

return remoteEvent