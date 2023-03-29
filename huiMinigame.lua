local imgui = require("imgui")

local ChlenMinigame = {
    title = "Соси хуй!",
    totalNum = 10,
    num = 0,
    clickFunc = function() end,
    doneFunc = function() end,
    enabled = true
}
ChlenMinigame.__index = ChlenMinigame

function ChlenMinigame.new(count)
    local self = setmetatable({}, ChlenMinigame)
    if count then self.totalNum = count end
    return self
end

function ChlenMinigame:DrawUi()
    if not self.enabled then goto fucku end
    imgui.SetNextWindowSize(imgui.ImVec2(300,300))
    imgui.Begin(self.title, nil, (imgui.WindowFlags.AlwaysAutoResize or 0) + (imgui.WindowFlags.NoSavedSettings or 0) + (imgui.WindowFlags.NoCollapse or 0))
    imgui.Text("Хуй пососан "..self.num.."/"..self.totalNum.." раз")
    imgui.SetCursorPos(imgui.ImVec2(125,75))
    if imgui.Button(" ", imgui.ImVec2(50,25)) then
        self.num = self.num + 1
        self.clickFunc()
        if self.num >= self.totalNum then
            self.num = 0
            self.doneFunc()
            self.enabled = false
        end
    end
    imgui.BeginDisabled()
    imgui.SetCursorPos(imgui.ImVec2(125,100))
    imgui.Button(" ", imgui.ImVec2(50,100))
    imgui.SetCursorPos(imgui.ImVec2(90,175))
    imgui.Button(" ", imgui.ImVec2(50,40))
    imgui.SetCursorPos(imgui.ImVec2(150,150))
    imgui.Button(" ", imgui.ImVec2(50,75))
    imgui.EndDisabled()
    imgui.End()
    ::fucku::
end

return ChlenMinigame