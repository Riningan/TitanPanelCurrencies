local AddonName, Addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale("Titan", true)

local _ID = "Currencies";
local _AllCurrencies = {
	group_1 = {
		cur01_81   = false, -- Награда гурмана
		cur02_515  = true,  -- Призовой купон ярмарки Новолуния
		cur03_1166 = true,  -- Искаженный временем знак
		cur04_1191 = false  -- Доблесть
	},
	group_2 = {
		cur01_61   = false, -- Даларанский знак ювелира 
		cur02_241  = false  -- Печать чемпиона 
	}, 
	group_3 = {
		cur01_416  = false, -- Знак Древа Жизни 
		cur02_391  = false, -- Рекомендательный значок Тол Барада 
		cur03_614  = false, -- Частица тьмы 
		cur04_615  = false, -- Порочная энергия Смертокрыла 
		cur05_361  = false  -- Жетон прославленного ювелира 
	}, 
	group_4 = {
		cur01_738  = false, -- Малый амулет удачи 
		cur02_697  = false, -- Большой амулет удачи
		cur03_752  = false, -- Руна судьбы могу
		cur04_776  = false, -- Закаленная в бою печать
		cur05_777  = false, -- Вневременная монета
		cur06_789  = false  -- Окровавленная монета
	}, 
	group_5 = {
		cur01_824  = false, -- Ресурсы гарнизона
		cur02_1101 = false, -- Нефть
		cur03_823  = false, -- Апекситовый кристалл
		cur04_994  = false, -- Печать закаленной судьбы
		cur05_1129 = false  -- Печать неизбежной судьбы 
	},
	group_6 = {
		cur01_1226 = false, -- Осколок пустоты 
		cur02_1220 = true,  -- Ресурсы оплота класса
		cur03_1149 = false, -- Незрячий глаз
		cur04_1155 = false, -- Древняя мана
		cur05_1273 = true,  -- Печать сломанной судьбы
		cur06_1299 = false, -- Бойцовское золото
		cur07_1268 = false, -- Видавший виды артефакт
		cur08_1508 = true,  -- Дымчатый аргунит
		cur09_1275 = false, -- Любопытная монета
		cur10_1356 = false, -- Отголоски битвы
		cur11_1357 = false, -- Отголоски торжества
		cur12_1342 = false, -- Припасы Армии погибели Легиона
		cur13_1314 = true,  -- Фрагмент неупокоенной души
		cur14_1355 = true   -- Эссенция Скверны
	}
};

function pairsByKeys(t, f)
	local a = {};
	for n in pairs(t) do 
		table.insert(a, n);
	end
	table.sort(a, f);
	local i = 0;
	local iter = function ()  
		i = i + 1;
		if a[i] == nil then 
			return nil;
		else 
			return a[i], t[a[i]];
		end
	end
	return iter;
end

function find(t, val)
    for k, v in pairs(t) do
        if v == val then return k end
    end
    return nil
end

function TitanPanelCurrenciesButton_OnLoad(pSelf)
	pSelf.ADDON_LOADED = nil;
	pSelf.registry = {
		id = _ID,
		menuText = "Titan Panel Currencies by Riningan",
		buttonTextFunction = "TitanPanelCurrenciesButton_GetButtonText",
		tooltipTitle = "Titan Panel Currencies by Riningan",
		tooltipTextFunction = "TitanPanelCurrenciesButton_GetTooltipText",
		frequency = 0.5,
		category = "Information",
		icon = "Interface\\AddOns\\TitanGold\\Artwork\\TitanGold",
		iconWidth = 16,
		savedVariables = _AllCurrencies
	};
	pSelf:RegisterEvent("PLAYER_ENTERING_WORLD");
end

function TitanPanelCurrenciesButton_OnEvent(pSelf, pEvent, pUnit)
	if pEvent == "PLAYER_ENTERING_WORLD" then
		TitanPanelCurrenciesButton_GetButtonText();
	end
end

function TitanPanelCurrenciesButton_OnClick(pSelf, pButton)
	if (pButton == "LeftButton") then
		ToggleCharacter("TokenFrame");
	end
end

function TitanPanelCurrenciesButton_OnUpdate(pSelf, pElapsed)
	TitanPanelButton_UpdateButton(_ID);
end

function TitanPanelCurrenciesButton_GetButtonText()
	local buttonText = "";
	for groupId, value in pairsByKeys(_AllCurrencies) do
		local currencies = TitanGetVar(_ID, groupId);
		for currency, value in pairsByKeys(currencies) do
			if value then
				local currencyCode = currency:gsub("cur%d%d_", "");
				local _, amount, icon = GetCurrencyInfo(currencyCode);
				buttonText = buttonText .. " |T" .. icon .. ":16|t" .. TitanUtils_GetGreenText(amount);
			end
		end
	end
	return buttonText;
end

function TitanPanelCurrenciesButton_GetTooltipText()
	local tooltipText = "";
	for groupId, value in pairsByKeys(_AllCurrencies) do
		tooltipText = tooltipText .. format("\n");
		local currencies = TitanGetVar(_ID, groupId);
		for currency, value in pairsByKeys(currencies) do
			local currencyCode = currency:gsub("cur%d%d_", "");
			local name, amount, icon, earnedThisWeek, weeklyMax, totalMax, isDiscovered, quality = GetCurrencyInfo(currencyCode);
			if totalMax == 0 then
				totalMax = "";
			else 
				totalMax = "/" .. totalMax;
			end
			tooltipText = tooltipText .. format(TitanUtils_GetGoldText(name) .. ":\t" .. TitanUtils_GetHighlightText(amount) .. TitanUtils_GetRedText(totalMax) .. " |T" .. icon .. ":16|t\n");
		end
	end
	return tooltipText;
end

function TitanPanelRightClickMenu_PrepareCurrenciesMenu()
	for groupId, value in pairsByKeys(_AllCurrencies) do
		local currencies = TitanGetVar(_ID, groupId);
		for currency, value in pairsByKeys(currencies) do
			local currencyCode = currency:gsub("cur%d%d_", "");
			local name, _, _ = GetCurrencyInfo(currencyCode);
			local info = {};
			info.text = name;
			info.checked = value;
			info.func = function() 
				currencies = TitanGetVar(_ID, groupId);
				if currencies[currency] then
					currencies[currency] = false;
				else
					currencies[currency] = true;
				end
				TitanSetVar(_ID, groupId, currencies);
				TitanPanelButton_UpdateButton(_ID);
			end
			L_UIDropDownMenu_AddButton(info, _G["UIDROPDOWNMENU_MENU_LEVEL"]);
		end
		TitanPanelRightClickMenu_AddSpacer();
	end
	TitanPanelRightClickMenu_AddCommand(L["TITAN_PANEL_MENU_HIDE"], _ID, TITAN_PANEL_MENU_FUNC_HIDE);
end
