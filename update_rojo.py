import json

with open('/home/team/shared/repo/default.project.json', 'r') as f:
    config = json.load(f)

remote_events = config['tree']['ReplicatedStorage']['MonsterMash']['RemoteEvents']

# Map of what each should be
special = {'HatchEgg': 'RemoteFunction', 'RequestInventory': 'RemoteFunction'}

for name, data in remote_events.items():
    if name == '$className':
        continue
    # Change $path from .lua file to just the folder name
    old_path = data.get('$path', '')
    if old_path:
        folder_name = name
        data['$path'] = f"src/ReplicatedStorage/MonsterMash/RemoteEvents/{folder_name}"
    # Remove $className since Rojo v7 infers it from init.lua content
    if '$className' in data:
        del data['$className']

with open('/home/team/shared/repo/default.project.json', 'w') as f:
    json.dump(config, f, indent=4)

print("Updated default.project.json")
