---@diagnostic disable: param-type-mismatch
local imgui = require("imgui")
local memory = require("memory")
local addrs = require("memoryStorage")
local events = require("events")
local config = require("config")
local ffi = require("ffi")
local lostFocus = false

events.on("windowEvent", function (event)
    if event.msg == 0x8 then lostFocus = true
	elseif event.msg == 0x7 then lostFocus = false end
end)

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

local Filter = {
	name = "", ---@type string
	hint = "", ---@type string
	order = 0,
	enabled = false,
	func = nil  ---@type function
}
Filter.__index = Filter

function Filter:DrawUi()
	local checkbox = ffi.new("bool[1]", self.enabled)
	if imgui.Checkbox(self.name, checkbox) then
		self.enabled = checkbox[0]
		config.mod:getObject(self.name):set("enabled", checkbox[0])
		config.save()
	end
	if self.hint and self.hint ~= "" then
		HelpMarker(self.hint) end
end

function Filter.new()
    return setmetatable({}, Filter)
end

local mainIcon = Filter.new()
mainIcon.name = "Вид иконки"
mainIcon.hint = "Тут можно выбрать отображаемую иконку игры на свой вкус и цвет"
mainIcon.enabled = true
mainIcon.currItem = ffi.new("int[1]", 0)
mainIcon.DrawUi = function()
	imgui.Text(mainIcon.name)
	if mainIcon.hint and mainIcon.hint ~= "" then
		HelpMarker(mainIcon.hint) end
	if imgui.Combo_Str("###mainIcon", mainIcon.currItem, "Дефолт\0SuperCow Cowmoonity\0Свидетель Джим\0Мегабаза\0") then
		config.mod:getObject(mainIcon.name):set("currItem", mainIcon.currItem[0])
		config.save()
	end
end
mainIcon.func = function(prs)
	if mainIcon.currItem[0] == 0 then
		prs.largeImageKey = "cow"
	elseif mainIcon.currItem[0] == 1 then
		prs.largeImageKey = "scc"
	elseif mainIcon.currItem[0] == 2 then
		prs.largeImageKey = "svidetel"
	elseif mainIcon.currItem[0] == 3 then
		prs.largeImageKey = "baza" end
	return prs
end

local levelDisplay = Filter.new()
levelDisplay.name = "Отображать уровень"
levelDisplay.hint = "Показывать уровень на котором находится игрок\nВ меню работает не всегда точно"
levelDisplay.enabled = true
levelDisplay.func = function(prs)
	table.insert(prs.state, string.format("Level %i-%i ",
		addrs.stage:readInt() + 1, addrs.level:readInt() + 1))
	return prs
end

local levelPercentage = Filter.new()
levelPercentage.name = "Процент прохождения"
levelPercentage.hint = "Отображать процент прохождения уровня, если такой имеется"
levelPercentage.order = 1
levelPercentage.enabled = true
levelPercentage.func = function(prs)
	local baseId = addrs.currentScene:readInt()
	if not levelDisplay.enabled then goto fucku end
	if baseId == addrs.gameScene then
		table.insert(prs.state, "("..addrs.calculateStats().."%)") end
	::fucku::
	return prs
end

local customText1 = Filter.new()
customText1.name = "Свой текст "
customText1.hint = "Панель для ввода статичного текста"
customText1.order = 2
customText1.enabled = false
customText1.text = ""
customText1.func = function(prs)
	if customText1.text == "" then goto fucku end
	table.insert(prs.state, customText1.text)
	config.mod:getObject(customText1.name):set("text", customText1.text)
	config.save()
	::fucku::
	return prs
end

local gameState = Filter.new()
gameState.name = "Отображать статус"
gameState.hint = "Показывать ли где находится игрок?\nВ меню / в процессе игры / в редакторе"
gameState.enabled = true
gameState.func = function(prs)
	local baseId = addrs.currentScene:readInt()
	if baseId == addrs.gameScene then
		table.insert(prs.details, "In Game")
	elseif baseId == addrs.editorScene then
		table.insert(prs.details, "In Editor")
	else table.insert(prs.details, "In Menus") end
	return prs
end

local editorState = Filter.new()
editorState.name = "Игра в редакторе"
editorState.hint = "Если происходит тест уровня через редактор, уточнять это"
editorState.order = 1
editorState.enabled = true
editorState.func = function(prs)
	local baseId = addrs.currentScene:readInt()
	if not gameState.enabled then goto fucku end
	if addrs.editor:readSBool() and baseId ~= addrs.editorScene then
		table.insert(prs.details, "From Editor") end
	::fucku::
	return prs
end

local profileName = Filter.new()
profileName.name = "Имя профиля"
profileName.hint = "Отображать имя текущего профиля"
profileName.order = -1
profileName.enabled = false
profileName.func = function(prs)
	table.insert(prs.details, memory.toStr(memory.toU8(addrs.currentName:readOffset():readAs("wchar_t*"))))
	return prs
end

local customText2 = Filter.new()
customText2.name = "Свой текст"
customText2.hint = "Панель для ввода статичного текста"
customText2.order = 2
customText2.enabled = false
customText2.text = ""
customText2.func = function(prs)
	if customText2.text == "" then goto fucku end
	table.insert(prs.details, customText2.text)
	config.mod:getObject(customText2.name):set("text", customText2.text)
	config.save()
	::fucku::
	return prs
end

local playingStatus = Filter.new()
playingStatus.name = "Показывать активность"
playingStatus.hint = "Отображать ли кружок в углу иконки игры в профиле?\nКружок меняет свой цвет в зависимости от того, поставлена ли игра на паузу"
playingStatus.order = 0
playingStatus.enabled = true
playingStatus.func = function(prs)
	local paused = addrs.pause:readBool()
	local baseId = addrs.currentScene:readInt()
	if not lostFocus and (baseId ~= addrs.gameScene or not paused) then
		prs.smallImageKey = "online" prs.smallImageText = "Playing"
	else prs.smallImageKey = "offline" prs.smallImageText = "Idle" end
	return prs
end

local eblanStatus = Filter.new()
eblanStatus.order = 1
eblanStatus.enabled = true
eblanStatus.func = function(prs)
	if addrs.stage:readInt() + 1 == 11 and addrs.level:readInt() + 1 == 48 then
		prs.smallImageKey = "eblan" prs.smallImageText = "Eblan"
	end
	return prs
end

local rusStatus = Filter.new()
rusStatus.order = 2
rusStatus.enabled = true
rusStatus.func = function(prs)
	local lang = memory.toStr(addrs.language:readAs("char*"))
	if lang == "ru" and not addrs.loaded:readBool() then
		prs.smallImageKey = "rus" prs.smallImageText = "ПОЛНОСТЬЮ НА РУССКОМ ЯЗЫКЕ"
	end
	return prs
end

local Builder = {
	BuildFilters = {
		MainIcon = mainIcon,
		LevelDisplay = levelDisplay,
		LevelPercentage = levelPercentage,
		GameState = gameState,
		EditorState = editorState,
		ProfileName = profileName,
		CustomText1 = customText1,
		CustomText2 = customText2,
		PlayingStatus = playingStatus,
		EblanStatus = eblanStatus,
		RusStatus = rusStatus
	}
}

function Builder.BuildPresence()
	local presence = {
		state = {},
    	details = {},
		smallImageKey = {},
    	smallImageText = {},
		largeImageKey = {}
	}
	local tkeys = {}
	for _, k in pairs(Builder.BuildFilters) do table.insert(tkeys, k) end
	table.sort(tkeys, function (a, b) return a.order < b.order end)
	for _, k in pairs(tkeys) do
		if not k.enabled then goto fucku end
		presence = k.func(presence)
        ::fucku::
	end
	for i, k in pairs(presence) do
		if type(k) ~= "table" then goto fucku end
		presence[i] = table.concat(presence[i], ", ")
		::fucku::
	end
	return presence
end

return Builder