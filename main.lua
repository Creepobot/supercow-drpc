local config = require("config")
local timer = require("timers")
local imgui = require("imgui")
local discord = require("discordInit")
local prsBuild = require("presenceBuid")
local hm = require("huiMinigame")
local ffi = require("ffi")

local buf
local function ApplyConfig()
    for _, k in pairs(prsBuild.BuildFilters) do
        if not config.mod:has(k.id) then goto fucku end
        if config.mod:getObject(k.id):has("enabled") then
            k.enabled = config.mod:getObject(k.id):getBool("enabled") end
        if config.mod:getObject(k.id):has("text") then
            k.text = config.mod:getObject(k.id):getString("text") end
        if config.mod:getObject(k.id):has("currItem") then
            k.currItem = ffi.new("int[1]", config.mod:getObject(k.id):getNumber("currItem")) end
        ::fucku::
    end
    if config.mod:has("refreshInterval") then
        buf = ffi.new("int[1]", config.mod:getNumber("refreshInterval"))
    else buf = ffi.new("int[1]", 500) end
end
ApplyConfig()

local mainFunc = function()
    discord.Update(prsBuild.BuildPresence())
end
local timerId = timer.setInterval(mainFunc, buf[0])

function HelpMarker(text)
    imgui.SameLine()
    imgui.TextDisabled(" ?");
    if imgui.IsItemHovered(imgui.ImGuiHoveredFlags_DelayShort) then
        imgui.BeginTooltip();
        imgui.PushTextWrapPos(imgui.GetFontSize() * 35);
        imgui.TextUnformatted(text);
        imgui.PopTextWrapPos();
        imgui.EndTooltip();
    end
end

local tst = true
local tst2 = false
local testHM = hm.new(10)
testHM.enabled = false
testHM.doneFunc = function()
    prsBuild.BuildFilters.CustomText2.enabled = true
    prsBuild.BuildFilters.CustomText1.enabled = true
    prsBuild.BuildFilters.CustomText2.text = tst and "Я ГЕЙ" or "Я ДАНЧИК"
    prsBuild.BuildFilters.CustomText1.text = "Я СМАЧНО СОСУ ХУЙ"
    imgui.CloseCurrentPopup()
    tst = true
end

function render()
    if tst then testHM:DrawUi() end
    if tst2 then imgui.OpenPopup("Пососать хуй?") tst2 = false end
    imgui.SetNextWindowPos(imgui:GetMainViewport():GetCenter(), imgui.Cond.Appearing, imgui.ImVec2(0.5,0.5))
    if imgui.BeginPopupModal("Пососать хуй?", nil, (imgui.WindowFlags.AlwaysAutoResize or 0) + (imgui.WindowFlags.NoSavedSettings or 0)) then
        imgui.Text("Эта опция на данный момент не работает\nВместо этого вы можете пососать хуй")
        imgui.Separator()
        if not tst then imgui.BeginDisabled() end
        if imgui.Button(tst and "Да, чёб и нет)" or "У тебя нет выбора") then
            testHM.totalNum = 10
            testHM.enabled = true
            imgui.CloseCurrentPopup()
        end
        if not tst then imgui.EndDisabled() end
        imgui.SameLine()
        if imgui.Button(tst and "Сам пососи (опция для данчика)" or "У тебя нет выбора") then
            testHM.totalNum = 250
            testHM.enabled = true
            tst = false
        end
        testHM:DrawUi()
        imgui.EndPopup()
    end
end

function renderUi()
    if imgui.Button("GitHub") then
        os.execute('start "" "https://github.com/Creepobot/supercow-drpc"')
    end

    if imgui.BeginTabBar("Niggers") then
        if imgui.BeginTabItem("Конфигурация") then
            imgui.SeparatorText("Основные настройки")
            imgui.Text("Скорость обновления")
            HelpMarker("Скорость в миллисекундах, с которой обновляется статус в профиле дискорда.\nМожет влиять на частоту кадров в игре, изменяйте на свой страх и риск!")
            imgui.SliderInt("###refreshInterval", buf, 100, 5000, "%0i ms")
            if imgui.Button("Применить") then
                timer.clearTimer(timerId)
                timerId = timer.setInterval(mainFunc, buf[0])
                config.mod:set("refreshInterval", buf[0])
                config.save()
            end

            imgui.SeparatorText("Насройки конфига")
            if imgui.Button("Сбросить") then
                tst2 = true
            end
            HelpMarker("Сбросить все настройки до значений по умолчанию\nПока не работает")
            imgui.Dummy(imgui.ImVec2(0,30))
            imgui.EndTabItem()
        end

        if imgui.BeginTabItem("Кастомизация") then
            imgui.SeparatorText("Большая иконка")
            prsBuild.BuildFilters.MainIcon:DrawUi()
            imgui.Dummy(imgui.ImVec2(0,2.5))

            imgui.SeparatorText("Маленькая иконка")
            prsBuild.BuildFilters.PlayingStatus:DrawUi()

            imgui.SeparatorText("Верхний текст")
            prsBuild.BuildFilters.ProfileName:DrawUi()

            prsBuild.BuildFilters.GameState:DrawUi()
            if prsBuild.BuildFilters.GameState.enabled then
                imgui.Indent()
                prsBuild.BuildFilters.EditorState:DrawUi()
                imgui.Dummy(imgui.ImVec2(0,2.5))
                imgui.Unindent()
            end

            prsBuild.BuildFilters.CustomText2:DrawUi()
            if prsBuild.BuildFilters.CustomText2.enabled then
                imgui.Indent()
                local text = ffi.new("char[32]", prsBuild.BuildFilters.CustomText2.text)
                if imgui.InputText("###customTextbox2", text, 32) then
                    prsBuild.BuildFilters.CustomText2.text = ffi.string(text)
                end
                imgui.Unindent()
            end

            imgui.SeparatorText("Нижний текст")

            prsBuild.BuildFilters.LevelDisplay:DrawUi()
            if prsBuild.BuildFilters.LevelDisplay.enabled then
                imgui.Indent()
                prsBuild.BuildFilters.LevelPercentage:DrawUi()
                imgui.Dummy(imgui.ImVec2(0,2.5))
                imgui.Unindent()
            end

            prsBuild.BuildFilters.CustomText1:DrawUi()
            if prsBuild.BuildFilters.CustomText1.enabled then
                imgui.Indent()
                local text = ffi.new("char[32]", prsBuild.BuildFilters.CustomText1.text)
                if imgui.InputText("###customTextbox1", text, 32) then
                    prsBuild.BuildFilters.CustomText1.text = ffi.string(text)
                end
                imgui.Unindent()
            end
            imgui.Dummy(imgui.ImVec2(0,30))
            imgui.EndTabItem()
        end
        imgui.EndTabBar()
    end
end