GoldStats = {}
 
GoldStats.name = "GoldStats"
GoldStats.StartGoldThisSession=0
GoldStats.GoldInThisSession=0
GoldStats.GoldOutThisSession=0
GoldStats.StartGoldLastReset=0
GoldStats.GoldInLastReset=0
GoldStats.GoldOutLastReset=0
GoldStats.diff=0

-- Get the window manager for later creaton if dynamic labels for gui xml file
local wm = GetWindowManager()

local LastResetDefaults = {
	resetBalance = GetCurrentMoney(),
	income = 0,
	expenses = 0
}

local AccountWideDefaults = {
	charlist = {GetUnitName("Player")},
	bank = 0
}

function GoldStats:Initialize()
	GoldStats.StartGoldThisSession=GetCurrentMoney()
	GoldStats.GoldInThisSession=0
	GoldStats.GoldOutThisSession=0
	GoldStats.diff=0
	
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_MONEY_UPDATE, self.OnPlayerMoneyUpdate)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_BANKED_MONEY_UPDATE, self.OnBankMoneyUpdate)
	self.savedVariables = ZO_SavedVars:New("GoldStatsSavedVariables", 1, nil, LastResetDefaults)
	self.savedVariablesAccount = ZO_SavedVars:NewAccountWide("GoldStatsSavedVariables", 1, nil, AccountWideDefaults);
	self:RestorePosition();
	GoldStats.UpdateCharList(GetUnitName("Player"));

	GoldStatsIndicator:SetParent(ZO_PlayerInventory)
	
	GoldStats:UpdateStartGoldLastResetText()
	GoldStats:UpdateGoldInLastReset()
	GoldStats:UpdateGoldOutLastReset()
	GoldStats:UpdateStartGoldThisSessionText()
	GoldStats:UpdateGoldInThisSession()
	GoldStats:UpdateGoldOutThisSession()
	GoldStats:UpdateBalance()
	GoldStats:UpdateAllLastReset()
	GoldStats:UpdateAllIncome()
	GoldStats:UpdateAllExpenses()
	GoldStats:UpdateAllBank()
	GoldStats:UpdateAllBalance()

	GoldStatsIndicatorPlayerNameText:SetText(GetUnitName("Player"));

	GoldStats:UpdateAllAlts()

end

function GoldStats.Reset()
	GoldStats.StartGoldThisSession=GetCurrentMoney()
	GoldStats.GoldInThisSession=0
	GoldStats.GoldOutThisSession=0

	GoldStats.savedVariables.resetBalance=GetCurrentMoney()
	GoldStats.savedVariables.income=0
	GoldStats.savedVariables.expenses=0
	GoldStats.diff=0

	GoldStats:UpdateStartGoldLastResetText()
	GoldStats:UpdateGoldInLastReset()
	GoldStats:UpdateGoldOutLastReset()
	GoldStats:UpdateStartGoldThisSessionText()
	GoldStats:UpdateGoldInThisSession()
	GoldStats:UpdateGoldOutThisSession()
	GoldStats:UpdateBalance()
	GoldStats:UpdateAllLastReset()
	GoldStats:UpdateAllIncome()
	GoldStats:UpdateAllExpenses()
	GoldStats:UpdateAllBank()
	GoldStats:UpdateAllBalance()
	
	GoldStatsIndicatorGoldInLastResetText:SetText("0g")
	GoldStatsIndicatorGoldOutLastResetText:SetText("0g")
	GoldStatsIndicatorGoldOutThisSessionText:SetText("0g")
	GoldStatsIndicatorGoldOutThisSessionText:SetText("0g")
end
 
function GoldStats.OnPlayerMoneyUpdate(eventCode, newMoney, oldMoney, reason)
	GoldStats.diff=newMoney - oldMoney
	
	if GoldStats.diff<0 then
		GoldStats:UpdateGoldOutThisSession(GoldStats.diff);
		GoldStats:UpdateGoldOutLastReset(GoldStats.diff)	
	elseif GoldStats.diff>0 then
		GoldStats:UpdateGoldInThisSession(GoldStats.diff);
		GoldStats:UpdateGoldInLastReset(GoldStats.diff)
	end

	GoldStats:UpdateBalance()
	GoldStats:UpdateAllIncome()
	GoldStats:UpdateAllExpenses()
	GoldStats:UpdateAllBalance()
end

-- Update banked amount in account wide saved variables to keep
-- track of how much money is currently in bank
function GoldStats.OnBankMoneyUpdate(eventCode, newMoney, oldMoney)
	GoldStats.savedVariablesAccount.bank=newMoney;
	GoldStats:UpdateAllBank()
	GoldStats:UpdateAllBalance()
end


function GoldStats.UpdateStartGoldLastResetText()
	GoldStatsIndicatorStartGoldLastResetText:SetText(string.format(GoldStats.savedVariables.resetBalance .. "g"))
end

function GoldStats.UpdateGoldInLastReset()
	GoldStats.savedVariables.income=GoldStats.savedVariables.income+GoldStats.diff
	GoldStatsIndicatorGoldInLastResetText:SetText(string.format(GoldStats.savedVariables.income .. "g"))
end

function GoldStats.UpdateGoldOutLastReset()
	GoldStats.savedVariables.expenses=GoldStats.savedVariables.expenses+GoldStats.diff
	GoldStatsIndicatorGoldOutLastResetText:SetText(string.format(GoldStats.savedVariables.expenses .. "g"))
end

function GoldStats.UpdateStartGoldThisSessionText()
	GoldStatsIndicatorStartGoldThisSessionText:SetText(string.format(GoldStats.StartGoldThisSession .. "g"))
end

function GoldStats.UpdateGoldInThisSession()
	GoldStats.GoldInThisSession=GoldStats.GoldInThisSession+GoldStats.diff
	GoldStatsIndicatorGoldInThisSessionText:SetText(string.format(GoldStats.GoldInThisSession .. "g"))
end

function GoldStats.UpdateGoldOutThisSession()
	GoldStats.GoldOutThisSession=GoldStats.GoldOutThisSession+GoldStats.diff
	GoldStatsIndicatorGoldOutThisSessionText:SetText(string.format(GoldStats.GoldOutThisSession .. "g"))
end

function GoldStats.UpdateBalance()
	GoldStatsIndicatorBalanceText:SetText(string.format(GetCurrentMoney() .. "g"))
end

function GoldStats.UpdateAllLastReset()
	local sum=0
	for i=1, #GoldStats.savedVariablesAccount.charlist do
		charactername=GoldStats.savedVariablesAccount.charlist[i];
		GoldStats.savedVariablesAlt = ZO_SavedVars:New("GoldStatsSavedVariables", 1, nil, LastResetDefaults, "Default", GetDisplayName(), charactername);
		sum = sum + GoldStats.savedVariablesAlt.resetBalance;
	end
	GoldStatsIndicatorAllLastResetText:SetText(string.format(sum .. "g"))
end

function GoldStats.UpdateAllIncome()
	local sum=0
	for i=1, #GoldStats.savedVariablesAccount.charlist do
		charactername=GoldStats.savedVariablesAccount.charlist[i];
		GoldStats.savedVariablesAlt = ZO_SavedVars:New("GoldStatsSavedVariables", 1, nil, LastResetDefaults, "Default", GetDisplayName(), charactername);
		sum = sum + GoldStats.savedVariablesAlt.income;
	end
	GoldStatsIndicatorAllIncomeText:SetText(string.format(sum .. "g"))
end

function GoldStats.UpdateAllExpenses()
	local sum=0
	for i=1, #GoldStats.savedVariablesAccount.charlist do
		charactername=GoldStats.savedVariablesAccount.charlist[i];
		GoldStats.savedVariablesAlt = ZO_SavedVars:New("GoldStatsSavedVariables", 1, nil, LastResetDefaults, "Default", GetDisplayName(), charactername);
		sum = sum + GoldStats.savedVariablesAlt.expenses;
	end
	GoldStatsIndicatorAllExpensesText:SetText(string.format(sum .. "g"))
end

function GoldStats.UpdateAllBank()
	GoldStatsIndicatorAllBankText:SetText(string.format(GoldStats.savedVariablesAccount.bank .. "g"))
end

function GoldStats.UpdateAllBalance()
	local sum=0
	for i=1, #GoldStats.savedVariablesAccount.charlist do
		charactername=GoldStats.savedVariablesAccount.charlist[i];
		GoldStats.savedVariablesAlt = ZO_SavedVars:New("GoldStatsSavedVariables", 1, nil, LastResetDefaults, "Default", GetDisplayName(), charactername);
		sum = sum + GoldStats.savedVariablesAlt.resetBalance + GoldStats.savedVariablesAlt.income + GoldStats.savedVariablesAlt.expenses;
	end
	sum = sum + GoldStats.savedVariablesAccount.bank;
	GoldStatsIndicatorAllBalanceText:SetText(string.format(sum .. "g"))
end
-- This function will create new labels in the stats gui for all alts and populate the info
function GoldStats.UpdateAllAlts()
	local numchars = #GoldStats.savedVariablesAccount.charlist
	if (numchars == 1) then
		return
	end
	GoldStatsIndicator:SetDimensions(255,305+numchars*20);
	GoldStatsIndicatorBackdrop:SetDimensions(255,305+numchars*20);
	local mylabel = ""
	local altstatus = ""
	local index = 1
	for i=1, numchars do
		charname = GoldStats.savedVariablesAccount.charlist[i];
		if (charname ~= GetUnitName("Player")) then
			mylabel = "GoldStatsIndicatorAlt"..index
			Alt = wm:CreateControl(mylabel, GoldStatsIndicator, CT_LABEL);
			Alt:SetColor(0.53, 0.61, 0.49, 1)
			Alt:SetFont("ZoFontChat")
			Alt:SetWrapMode(TRUNCATE)
			Alt:SetDrawLayer(1)
			Alt:SetAnchor(TOPLEFT, GoldStatsIndicator, TOPLEFT, 8 , 175+20*index)
			Alt:SetDimensions(245, 30)
			Alt:SetScale(1)
			Alt:SetText(GoldStats.savedVariablesAccount.charlist[i]);
			mylabel = "GoldStatsIndicatorAltText"..index
			Alt = wm:CreateControl(mylabel, GoldStatsIndicator, CT_LABEL);
			Alt:SetColor(0.53, 0.61, 0.49, 1)
			Alt:SetFont("ZoFontChat")
			Alt:SetWrapMode(TRUNCATE)
			Alt:SetDrawLayer(1)
			Alt:SetAnchor(TOPLEFT, GoldStatsIndicator, TOPLEFT, 8 , 175+20*index)
			Alt:SetDimensions(245, 30)
			Alt:SetScale(1)
			Alt:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
			GoldStats.savedVariablesAlt = ZO_SavedVars:New("GoldStatsSavedVariables", 1, nil, LastResetDefaults, "Default", GetDisplayName(), charname);
			altstatus = GoldStats.savedVariablesAlt.income + GoldStats.savedVariablesAlt.expenses
			altstatus = altstatus.."/"..GoldStats.savedVariablesAlt.resetBalance
			Alt:SetText(altstatus);
			index = index + 1
		end
	end
end

function GoldStats.OnAddOnLoaded(event, addonName)
  if addonName == GoldStats.name then
    GoldStats:Initialize()
  end
end

function GoldStats.OnIndicatorMoveStop()
  GoldStats.savedVariables.left = GoldStatsIndicator:GetLeft()
  GoldStats.savedVariables.top = GoldStatsIndicator:GetTop()
end

function GoldStats:RestorePosition()
  local left = self.savedVariables.left
  local top = self.savedVariables.top
 
  GoldStatsIndicator:ClearAnchors()
  GoldStatsIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

-- Adds the charactername to the list of characters using this addon
-- I couldn't find any API function getting list of characters in the
-- saved variables file so I created this function to keep track of this.
function GoldStats.UpdateCharList(charactername)
	for i=1, #GoldStats.savedVariablesAccount.charlist do
		if (GoldStats.savedVariablesAccount.charlist[i]==charactername) then
			return;
		end
	end
	table.insert(GoldStats.savedVariablesAccount.charlist, charactername);
end


local function slashHandler(userInput)
	local parsedUserInput = {string.match(userInput,"^(%S*)%s*(.-)$")}
	local command = {}
	local n = #parsedUserInput;
	command[1] = "help";
	for i=1, n do
		if (parsedUserInput[i] ~= nil and parsedUserInput[i] ~= "") then
			command[i] = string.lower(parsedUserInput[i]);
		end
	end

	if ("help" == command[1]) then
		d("Available Goldstats commands");
		d("/goldstats reset (resets current characters stats)");
		d("/goldstats resetall (resets all characters stats)");
		return;
	end
	
	if ("reset" == command[1]) then
		GoldStats:Reset();
		d("reset this chacracter");
		return;
	end

	if ("resetall" == command[1]) then
		GoldStats:Reset();
		d("reset all characters");
		return;
	end
	
	if ("debug" == command[1]) then
		d("Kilroy was here");
		return;
	end
end
SLASH_COMMANDS["/goldstats"] = slashHandler;
 
EVENT_MANAGER:RegisterForEvent(GoldStats.name, EVENT_ADD_ON_LOADED, GoldStats.OnAddOnLoaded)