--[[ EvolveMonster RemoteEvent ]]
-- Client fires to request evolution (combine 5 same monsters into shiny)

local remoteEvent = Instance.new("RemoteEvent")
remoteEvent.Name = "EvolveMonster"
remoteEvent.Parent = script.Parent

return remoteEvent