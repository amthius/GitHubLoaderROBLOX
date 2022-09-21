--[[
	GitHub Repository loader (FOR ROBLOX)
	This all goes based off the github API
	
	Author: https://github.com/dann0001

	LIMITATIONS:
	- 200,000 Character max per .lua file (ROBLOX Limitation for setting strings, which includes Source as well)
		- https://create.roblox.com/docs/reference/engine/classes/StringValue
	- GitHub may not load massive repo's due to rate limit, however this was never tested.
]]--


local GithubRepo = "OWNER/REPOSITORY" 
local Location = game:GetService("ReplicatedStorage")

local Http = game:GetService("HttpService")
local HttpEnabled = Http.HttpEnabled
Http.HttpEnabled = true
local Repo = Http:JSONDecode(Http:GetAsync("https://api.github.com/repos/"..GithubRepo.."/commits"))
local Tree = Http:JSONDecode(Http:GetAsync(Repo[1].commit.tree.url.."?recursive=1"))


local function Build(Path)
	local Current = Location

	for i,v in pairs(string.split(Path, "/")) do
		if string.match(v, ".lua") then
			if not Current:FindFirstChild(v) then
				
				local Raw = "https://raw.githubusercontent.com/"..GithubRepo.."/main/"..Path
				
				local File = Instance.new("ModuleScript")
				File.Name = v
				File.Source = Http:GetAsync(Raw)
				File.Parent = Current
			end
		else
			if not Current:FindFirstChild(v) then
				local DirectoryFolder = Instance.new("Folder")
				DirectoryFolder.Name = v
				DirectoryFolder.Parent = Current
				Current = DirectoryFolder
			else
				Current = Current:FindFirstChild(v)
			end
		end
	end
end

local Start = os.clock()
print("Loading repository:", GithubRepo)

for i,v in next, Tree.tree do
	if string.find(v.path, ".lua") then
		Build(v.path)
	end
end

print("Load completed!")
print("Time taken:", os.clock() - Start)

Http.HttpEnabled = HttpEnabled
