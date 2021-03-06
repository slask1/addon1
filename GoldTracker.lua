-------------------------------------------------------------------------------
-- Initialization
-------------------------------------------------------------------------------
GoldTracker = {}
 
GoldTracker.name = "GoldTracker"
GoldTracker.StartGoldThisSession=0
GoldTracker.GoldInThisSession=0
GoldTracker.GoldOutThisSession=0
GoldTracker.StartGoldLastReset=0
GoldTracker.GoldInLastReset=0
GoldTracker.GoldOutLastReset=0
GoldTracker.diff=0

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

	GoldTrackerGuiOverview:SetParent(ZO_PlayerInventory)
	GoldTracker:UpdateStartGoldLastReset()
	GoldTracker:UpdateGoldInLastReset()
	GoldTracker:UpdateGoldOutLastReset()
	GoldTracker:UpdateStartGoldThisSession()
	GoldTracker:UpdateGoldInThisSession()
	GoldTracker:UpdateGoldOutThisSession()
	GoldTracker:UpdateBalance()
	GoldTracker:UpdateAllLastReset()
	GoldTracker:UpdateAllIncome()
	GoldTracker:UpdateAllExpenses()
	GoldTracker:UpdateAllBank()
	GoldTracker:UpdateAllBalance()
	GoldTracker:UpdatePlayerName()
	GoldTracker:UpdateAllAlts()
end


-------------------------------------------------------------------------------
-- GoldTracker functions
-------------------------------------------------------------------------------
function GoldTracker.Reset()
	GoldTracker.StartGoldThisSession=GetCurrentMoney()
	GoldTracker.GoldInThisSession=0
	GoldTracker.GoldOutThisSession=0
	GoldTracker.savedVariables.resetBalance=GetCurrentMoney()
	GoldTracker.savedVariables.income=0
	GoldTracker.savedVariables.expenses=0
	GoldTracker.diff=0

	GoldTracker:UpdateStartGoldLastReset()
	GoldTracker:UpdateGoldInLastReset()
	GoldTracker:UpdateGoldOutLastReset()
	GoldTracker:UpdateStartGoldThisSession()
	GoldTracker:UpdateGoldInThisSession()
	GoldTracker:UpdateGoldOutThisSession()
	GoldTracker:UpdateBalance()
	GoldTracker:UpdateAllLastReset()
	GoldTracker:UpdateAllIncome()
	GoldTracker:UpdateAllExpenses()
	GoldTracker:UpdateAllBank()
	GoldTracker:UpdateAllBalance()
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

 
-------------------------------------------------------------------------------
-- Event handling functions
-------------------------------------------------------------------------------
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

function GoldTracker.OnAddOnLoaded(event, addonName)
  if addonName == GoldTracker.name then
    GoldTracker:Initialize()
  end
end
 
EVENT_MANAGER:RegisterForEvent(GoldTracker.name, EVENT_ADD_ON_LOADED, GoldTracker.OnAddOnLoaded)