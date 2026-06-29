local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Guess My Number",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Guess My Number | Reveal & Hints",
   LoadingSubtitle = "by Be4rainbows",
   ShowText = "Rayfield", -- for mobile users to unhide Rayfield, change if you'd like
   Theme = "Amethyst", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "M", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from emitting warnings when the script has a version mismatch with the interface.

   -- ScriptID = "sid_xxxxxxxxxxxx", -- Your Script ID from developer.sirius.menu — enables analytics, managed keys, and script hosting

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "Guess My Number R&H B4R"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include Discord.gg/. E.g. Discord.gg/ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the Discord every time they load it up
   },

   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique, as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Hello"} -- List of keys that the system will accept, can be RAW file links (pastebin, github, etc.) or simple strings ("hello", "key22")
   }
})

local Home = Window:CreateTab("🏠 Home", nil) -- Title, Image

local function isontable()
    local userid = game.Players.LocalPlayer.UserId
    local Tables_dir = game.workspace:FindFirstChild("1-100 Tables")
    local Custom_dir = game.workspace:FindFirstChild("1-1000 Tables")
    for _, child in ipairs(Tables_dir:GetChildren()) do
        if child:IsA("Model") and child.Name == tostring("Table") then
            config_players = child:FindFirstChild("Configuration"):FindFirstChild("Players")
            for _, c in ipairs(config_players:GetChildren()) do
                if c:IsA("Folder") then
                    for _, p in ipairs(c:GetChildren()) do
                        if p:IsA("IntValue") and p.Value == userid then
                            return true
                        end
                    end
                end
            end
        end
    end
    for _, child in ipairs(Custom_dir:GetChildren()) do
        if child:IsA("Model") and child.Name == tostring("CustomTable") then
            config_players = child:FindFirstChild("Configuration"):FindFirstChild("Players")
            for _, c in ipairs(config_players:GetChildren()) do
                if c:IsA("Folder") then
                    for _, p in ipairs(c:GetChildren()) do
                        if p:IsA("IntValue") and p.Value == userid then
                            return true
                        end
                    end
                end
            end
        end
    end
    Rayfield:Notify({
        Title = "You're not in a table!",
        Content = "You must be sitting at a table",
        Duration = 4,
        Image = "alert-circle",
    })
    return false
end

local MainSect = Home:CreateSection("Main")
local Button = Home:CreateButton({
   Name = "Reveal Number",
   Callback = function()
        if isontable() then
            local event = game:GetService("ReplicatedStorage").Events.Remote.UseRevealNumber
            event:FireServer()
        end
   end,
})
local Button = Home:CreateButton({
   Name = "Reveal Hint",
   Callback = function()
        if isontable() then
            local event = game:GetService("ReplicatedStorage").Events.Remote.UseHint
            event:FireServer()
        end
   end,
})

local Fun = Window:CreateTab("🎉 Fun", nil) -- Title, Image
local Section = Fun:CreateSection("Movement")

local Slider_speed = Fun:CreateSlider({
   Name = "WalkSpeed",
   Range = {0, 500},
   Increment = 10,
   Suffix = "speed",
   CurrentValue = 16,
   Flag = "Speed", -- A flag is the identifier for the configuration file; make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
   end,
})
local Slider_jump = Fun:CreateSlider({
   Name = "JumpPower",
   Range = {0, 500},
   Increment = 10,
   Suffix = "power",
   CurrentValue = 50,
   Flag = "Jump", -- A flag is the identifier for the configuration file; make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.JumpHeight = Value
   end,
})
local Reset = Fun:CreateButton({
   Name = "Reset Movement",
   Callback = function()
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
        game.Players.LocalPlayer.Character.Humanoid.JumpHeight = 50
        Slider_speed:Set(16)
        Slider_jump:Set(7)
   -- The function that takes place when the button is pressed
   end,
})

-- Fly Variables
local flying = false
local flySpeed = 50
local bodyVelocity = nil
local bodyGyro = nil
local connection = nil

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

local function startFly()
    if flying then return end
    flying = true
    
    humanoid.PlatformStand = true
    
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Name = "EDEN_FlyVelocity"
    bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = root
    
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.Name = "EDEN_FlyGyro"
    bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bodyGyro.P = 3000
    bodyGyro.D = 500
    bodyGyro.Parent = root
    
    connection = game:GetService("RunService").Heartbeat:Connect(function()
        if not flying or not root then return end
        
        local moveDir = Vector3.new(0, 0, 0)
        local cam = workspace.CurrentCamera
        
        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.W) then
            moveDir = moveDir + cam.CFrame.LookVector
        end
        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.S) then
            moveDir = moveDir - cam.CFrame.LookVector
        end
        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.A) then
            moveDir = moveDir - cam.CFrame.RightVector
        end
        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.D) then
            moveDir = moveDir + cam.CFrame.RightVector
        end
        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) then
            moveDir = moveDir + Vector3.new(0, 1, 0)
        end
        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftShift) then
            moveDir = moveDir - Vector3.new(0, 1, 0)
        end
        
        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit * flySpeed
        end
        
        bodyVelocity.Velocity = moveDir
        bodyGyro.CFrame = cam.CFrame
    end)
end

local function stopFly()
    if not flying then return end
    flying = false
    
    if connection then
        connection:Disconnect()
        connection = nil
    end
    
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
    
    humanoid.PlatformStand = false
end

-- Rayfield Toggle
Fun:CreateToggle({
    Name = "Enable Fly",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(Value)
        if Value then
            startFly()
            Rayfield:Notify({
                Title = "Flight Engaged",
                Content = "Flight engaged. don't get caught.",
                Duration = 3
            })
        else
            stopFly()
            Rayfield:Notify({
                Title = "Flight Disengaged",
                Content = "Flight disengaged. you are now grounded.",
                Duration = 3
            })
        end
    end,
})

Fun:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 200},
    Increment = 5,
    CurrentValue = 50,
    Flag = "FlySpeed",
    Callback = function(Value)
        flySpeed = Value
    end,
})

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    root = newChar:WaitForChild("HumanoidRootPart")
    if flying then
        stopFly()
        task.wait(0.5)
        startFly()
    end
end)