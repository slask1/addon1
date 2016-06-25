GoldTracker = {}
 
GoldTracker.name = "GoldTracker"
GoldTracker.StartGoldThisSession=0
GoldTracker.GoldInThisSession=0
GoldTracker.GoldOutThisSession=0
GoldTracker.StartGoldLastReset=0
GoldTracker.GoldInLastReset=0
GoldTracker.GoldOutLastReset=0
GoldTracker.diff=0

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

function GoldTracker:Initialize()
	GoldTracker.StartGoldThisSession=GetCurrentMoney()
	GoldTracker.GoldInThisSession=0
	GoldTracker.GoldOutThisSession=0
	GoldTracker.diff=0
	
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_MONEY_UPDATE, self.OnPlayerMoneyUpdate)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_BANKED_MONEY_UPDATE, self.OnBankMoneyUpdate)
	self.savedVariables = ZO_SavedVars:New("GoldTrackerSavedVariables", 1, nil, LastResetDefaults)
	self.savedVariablesAccount = ZO_SavedVars:NewAccountWide("GoldTrackerSavedVariables", 1, nil, AccountWideDefaults);
	self:RestorePosition();
	GoldTracker.UpdateCharList(GetUnitName("Player"));

	GoldTrackerIndicator:SetParent(ZO_PlayerInventory)
	
	GoldTracker:UpdateStartGoldLastResetText()
	GoldTracker:UpdateGoldInLastReset()
	GoldTracker:UpdateGoldOutLastReset()
	GoldTracker:UpdateStartGoldThisSessionText()
	GoldTracker:UpdateGoldInThisSession()
	GoldTracker:UpdateGoldOutThisSession()
	GoldTracker:UpdateBalance()
	GoldTracker:UpdateAllLastReset()
	GoldTracker:UpdateAllIncome()
	GoldTracker:UpdateAllExpenses()
	GoldTracker:UpdateAllBank()
	GoldTracker:UpdateAllBalance()

	GoldTrackerIndicatorPlayerNameText:SetText(GetUnitName("Player"));

	GoldTracker:UpdateAllAlts()

end

function GoldTracker.Reset()
	GoldTracker.StartGoldThisSession=GetCurrentMoney()
	GoldTracker.GoldInThisSession=0
	GoldTracker.GoldOutThisSession=0

	GoldTracker.savedVariables.resetBalance=GetCurrentMoney()
	GoldTracker.savedVariables.income=0
	GoldTracker.savedVariables.expenses=0
	GoldTracker.diff=0

	GoldTracker:UpdateStartGoldLastResetText()
	GoldTracker:UpdateGoldInLastReset()
	GoldTracker:UpdateGoldOutLastReset()
	GoldTracker:UpdateStartGoldThisSessionText()
	GoldTracker:UpdateGoldInThisSession()
	GoldTracker:UpdateGoldOutThisSession()
	GoldTracker:UpdateBalance()
	GoldTracker:UpdateAllLastReset()
	GoldTracker:UpdateAllIncome()
	GoldTracker:UpdateAllExpenses()
	GoldTracker:UpdateAllBank()
	GoldTracker:UpdateAllBalance()
	
	GoldTrackerIndicatorGoldInLastResetText:SetText("0g")
	GoldTrackerIndicatorGoldOutLastResetText:SetText("0g")
	GoldTrackerIndicatorGoldOutThisSessionText:SetText("0g")
	GoldTrackerIndicatorGoldOutThisSessionText:SetText("0g")
end
 
function GoldTracker.OnPlayerMoneyUpdate(eventCode, newMoney, oldMoney, reason)
	GoldTracker.diff=newMoney - oldMoney
	
	if GoldTracker.diff<0 then
		GoldTracker:UpdateGoldOutThisSession(GoldTracker.diff);
		GoldTracker:UpdateGoldOutLastReset(GoldTracker.diff)	
	elseif GoldTracker.diff>0 then
		GoldTracker:UpdateGoldInThisSession(GoldTracker.diff);
		GoldTracker:UpdateGoldInLastReset(GoldTracker.diff)
	end

	GoldTracker:UpdateBalance()
	GoldTracker:UpdateAllIncome()
	GoldTracker:UpdateAllExpenses()
	GoldTracker:UpdateAllBalance()
end

-- Update banked amount in account wide saved variables to keep
-- track of how much money is currently in bank
function GoldTracker.OnBankMoneyUpdate(eventCode, newMoney, oldMoney)
	GoldTracker.savedVariablesAccount.bank=newMoney;
	GoldTracker:UpdateAllBank()
	GoldTracker:UpdateAllBalance()
end


function GoldTracker.UpdateStartGoldLastResetText()
	GoldTrackerIndicatorStartGoldLastResetText:SetText(string.format(GoldTracker.savedVariables.resetBalance .. "g"))
end

function GoldTracker.UpdateGoldInLastReset()
	GoldTracker.savedVariables.income=GoldTracker.savedVariables.income+GoldTracker.diff
	GoldTrackerIndicatorGoldInLastResetText:SetText(string.format(GoldTracker.savedVariables.income .. "g"))
end

function GoldTracker.UpdateGoldOutLastReset()
	GoldTracker.savedVariables.expenses=GoldTracker.savedVariables.expenses+GoldTracker.diff
	GoldTrackerIndicatorGoldOutLastResetText:SetText(string.format(GoldTracker.savedVariables.expenses .. "g"))
end

function GoldTracker.UpdateStartGoldThisSessionText()
	GoldTrackerIndicatorStartGoldThisSessionText:SetText(string.format(GoldTracker.StartGoldThisSession .. "g"))
end

function GoldTracker.UpdateGoldInThisSession()
	GoldTracker.GoldInThisSession=GoldTracker.GoldInThisSession+GoldTracker.diff
	GoldTrackerIndicatorGoldInThisSessionText:SetText(string.format(GoldTracker.GoldInThisSession .. "g"))
end

function GoldTracker.UpdateGoldOutThisSession()
	GoldTracker.GoldOutThisSession=GoldTracker.GoldOutThisSession+GoldTracker.diff
	GoldTrackerIndicatorGoldOutThisSessionText:SetText(string.format(GoldTracker.GoldOutThisSession .. "g"))
end

function GoldTracker.UpdateBalance()
	GoldTrackerIndicatorBalanceText:SetText(string.format(GetCurrentMoney() .. "g"))
end

function GoldTracker.UpdateAllLastReset()
	local sum=0
	for i=1, #GoldTracker.savedVariablesAccount.charlist do
		charactername=GoldTracker.savedVariablesAccount.charlist[i];
		GoldTracker.savedVariablesAlt = ZO_SavedVars:New("GoldTrackerSavedVariables", 1, nil, LastResetDefaults, "Default", GetDisplayName(), charactername);
		sum = sum + GoldTracker.savedVariablesAlt.resetBalance;
	end
	GoldTrackerIndicatorAllLastResetText:SetText(string.format(sum .. "g"))
end

function GoldTracker.UpdateAllIncome()
	local sum=0
	for i=1, #GoldTracker.savedVariablesAccount.charlist do
		charactername=GoldTracker.savedVariablesAccount.charlist[i];
		GoldTracker.savedVariablesAlt = ZO_SavedVars:New("GoldTrackerSavedVariables", 1, nil, LastResetDefaults, "Default", GetDisplayName(), charactername);
		sum = sum + GoldTracker.savedVariablesAlt.income;
	end
	GoldTrackerIndicatorAllIncomeText:SetText(string.format(sum .. "g"))
end

function GoldTracker.UpdateAllExpenses()
	local sum=0
	for i=1, #GoldTracker.savedVariablesAccount.charlist do
		charactername=GoldTracker.savedVariablesAccount.charlist[i];
		GoldTracker.savedVariablesAlt = ZO_SavedVars:New("GoldTrackerSavedVariables", 1, nil, LastResetDefaults, "Default", GetDisplayName(), charactername);
		sum = sum + GoldTracker.savedVariablesAlt.expenses;
	end
	GoldTrackerIndicatorAllExpensesText:SetText(string.format(sum .. "g"))
end

function GoldTracker.UpdateAllBank()
	GoldTrackerIndicatorAllBankText:SetText(string.format(GoldTracker.savedVariablesAccount.bank .. "g"))
end

function GoldTracker.UpdateAllBalance()
	local sum=0
	for i=1, #GoldTracker.savedVariablesAccount.charlist do
		charactername=GoldTracker.savedVariablesAccount.charlist[i];
		GoldTracker.savedVariablesAlt = ZO_SavedVars:New("GoldTrackerSavedVariables", 1, nil, LastResetDefaults, "Default", GetDisplayName(), charactername);
		sum = sum + GoldTracker.savedVariablesAlt.resetBalance + GoldTracker.savedVariablesAlt.income + GoldTracker.savedVariablesAlt.expenses;
	end
	sum = sum + GoldTracker.savedVariablesAccount.bank;
	GoldTrackerIndicatorAllBalanceText:SetText(string.format(sum .. "g"))
end
-- This function will create new labels in the stats gui for all alts and populate the info
function GoldTracker.UpdateAllAlts()
	local numchars = #GoldTracker.savedVariablesAccount.charlist
	if (numchars == 1) then
		return
	end
	GoldTrackerIndicator:SetDimensions(255,305+numchars*20);
	GoldTrackerIndicatorBackdrop:SetDimensions(255,305+numchars*20);
	local mylabel = ""
	local altstatus = ""
	local index = 1
	for i=1, numchars do
		charname = GoldTracker.savedVariablesAccount.charlist[i];
		if (charname ~= GetUnitName("Player")) then
			mylabel = "GoldTrackerIndicatorAlt"..index
			Alt = wm:CreateControl(mylabel, GoldTrackerIndicator, CT_LABEL);
			Alt:SetColor(0.53, 0.61, 0.49, 1)
			Alt:SetFont("ZoFontChat")
			Alt:SetWrapMode(TRUNCATE)
			Alt:SetDrawLayer(1)
			Alt:SetAnchor(TOPLEFT, GoldTrackerIndicator, TOPLEFT, 8 , 175+20*index)
			Alt:SetDimensions(245, 30)
			Alt:SetScale(1)
			Alt:SetText(GoldTracker.savedVariablesAccount.charlist[i]);
			mylabel = "GoldTrackerIndicatorAltText"..index
			Alt = wm:CreateControl(mylabel, GoldTrackerIndicator, CT_LABEL);
			Alt:SetColor(0.53, 0.61, 0.49, 1)
			Alt:SetFont("ZoFontChat")
			Alt:SetWrapMode(TRUNCATE)
			Alt:SetDrawLayer(1)
			Alt:SetAnchor(TOPLEFT, GoldTrackerIndicator, TOPLEFT, 8 , 175+20*index)
			Alt:SetDimensions(245, 30)
			Alt:SetScale(1)
			Alt:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
			GoldTracker.savedVariablesAlt = ZO_SavedVars:New("GoldTrackerSavedVariables", 1, nil, LastResetDefaults, "Default", GetDisplayName(), charname);
			altstatus = GoldTracker.savedVariablesAlt.income + GoldTracker.savedVariablesAlt.expenses
			altstatus = altstatus.."/"..GoldTracker.savedVariablesAlt.resetBalance
			Alt:SetText(altstatus);
			index = index + 1
		end
	end
end

function GoldTracker.OnAddOnLoaded(event, addonName)
  if addonName == GoldTracker.name then
    GoldTracker:Initialize()
  end
end

function GoldTracker.OnIndicatorMoveStop()
  GoldTracker.savedVariables.left = GoldTrackerIndicator:GetLeft()
  GoldTracker.savedVariables.top = GoldTrackerIndicator:GetTop()
end

function GoldTracker:RestorePosition()
  local left = self.savedVariables.left
  local top = self.savedVariables.top
 
  GoldTrackerIndicator:ClearAnchors()
  GoldTrackerIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

-- Adds the charactername to the list of characters using this addon
-- I couldn't find any API function getting list of characters in the
-- saved variables file so I created this function to keep track of this.
function GoldTracker.UpdateCharList(charactername)
	for i=1, #GoldTracker.savedVariablesAccount.charlist do
		if (GoldTracker.savedVariablesAccount.charlist[i]==charactername) then
			return;
		end
	end
	table.insert(GoldTracker.savedVariablesAccount.charlist, charactername);
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
		d("Available Gold Tracker commands");
		d("/goldtracker reset (resets current characters stats)");
		d("/goldtracker resetall (resets all characters stats)");
		return;
	end
	
	if ("reset" == command[1]) then
		GoldTracker:Reset();
		d("reset this chacracter");
		return;
	end

	if ("resetall" == command[1]) then
		GoldTracker:Reset();
		d("reset all characters");
		return;
	end
	
	if ("debug" == command[1]) then
		d("Kilroy was here");
		return;
	end
end
SLASH_COMMANDS["/goldtracker"] = slashHandler;
 
EVENT_MANAGER:RegisterForEvent(GoldTracker.name, EVENT_ADD_ON_LOADED, GoldTracker.OnAddOnLoaded)