local module = {}

local player = game.Players.LocalPlayer
local subtitleUi = player.PlayerGui.Subtitles.Frame
local referenceSubtitle = subtitleUi.ReferanceSubtitle

function module.newSubtitle(subtitle: string, speaker: string, colour: Color3, duration: number)
	local subtitleUI = referenceSubtitle:Clone()
	subtitleUI.Parent = subtitleUi
	subtitleUI.Text = speaker..": "..subtitle
	subtitleUI.TextColor3 = colour
	subtitleUI.Size = UDim2.new(0.5,0,0,30*math.ceil(subtitleUI.TextBounds.X/subtitleUI.AbsoluteSize.X))
	subtitleUI.TextWrapped = true
	subtitleUI.Visible = true
	task.spawn(function()
		task.wait(duration)
		subtitleUI:Destroy()
	end)
end

return module
