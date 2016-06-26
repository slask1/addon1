-- Get the window manager for later creation if dynamic labels for gui xml file
local wm = GetWindowManager()

-------------------------------------------------------------------------------
-- Overview Gui functions
-------------------------------------------------------------------------------
function GoldTracker.UpdatePlayerName()
	GoldTrackerGuiOverviewPlayerName:SetText(GetUnitName("Player"))
end

function GoldTracker.UpdateStartGoldLastReset()
	GoldTrackerGuiOverviewStartGoldLastReset:SetText(string.format(GoldTracker.savedVariables.resetBalance .. "g"))
end

function GoldTracker.UpdateGoldInLastReset()
	GoldTracker.savedVariables.income=GoldTracker.savedVariables.income+GoldTracker.diff
	GoldTrackerGuiOverviewGoldInLastReset:SetText(string.format(GoldTracker.savedVariables.income .. "g"))
end

function GoldTracker.UpdateGoldOutLastReset()
	GoldTracker.savedVariables.expenses=GoldTracker.savedVariables.expenses+GoldTracker.diff
	GoldTrackerGuiOverviewGoldOutLastReset:SetText(string.format(GoldTracker.savedVariables.expenses .. "g"))
end

function GoldTracker.UpdateStartGoldThisSession()
	GoldTrackerGuiOverviewStartGoldThisSession:SetText(string.format(GoldTracker.StartGoldThisSession .. "g"))
end

function GoldTracker.UpdateGoldInThisSession()
	GoldTracker.GoldInThisSession=GoldTracker.GoldInThisSession+GoldTracker.diff
	GoldTrackerGuiOverviewGoldInThisSession:SetText(string.format(GoldTracker.GoldInThisSession .. "g"))
end

function GoldTracker.UpdateGoldOutThisSession()
	GoldTracker.GoldOutThisSession=GoldTracker.GoldOutThisSession+GoldTracker.diff
	GoldTrackerGuiOverviewGoldOutThisSession:SetText(string.format(GoldTracker.GoldOutThisSession .. "g"))
end

function GoldTracker.UpdateBalance()
	GoldTrackerGuiOverviewBalance:SetText(string.format(GetCurrentMoney() .. "g"))
end

function GoldTracker.UpdateAllLastReset()
	local sum=0
	for i=1, #GoldTracker.savedVariablesAccount.charlist do
		charactername=GoldTracker.savedVariablesAccount.charlist[i];
		GoldTracker.savedVariablesAlt = ZO_SavedVars:New("GoldTrackerSavedVariables", 1, nil, LastResetDefaults, "Default", GetDisplayName(), charactername);
		sum = sum + GoldTracker.savedVariablesAlt.resetBalance;
	end
	GoldTrackerGuiOverviewAllLastReset:SetText(string.format(sum .. "g"))
end

function GoldTracker.UpdateAllIncome()
	local sum=0
	for i=1, #GoldTracker.savedVariablesAccount.charlist do
		charactername=GoldTracker.savedVariablesAccount.charlist[i];
		GoldTracker.savedVariablesAlt = ZO_SavedVars:New("GoldTrackerSavedVariables", 1, nil, LastResetDefaults, "Default", GetDisplayName(), charactername);
		sum = sum + GoldTracker.savedVariablesAlt.income;
	end
	GoldTrackerGuiOverviewAllIncome:SetText(string.format(sum .. "g"))
end

function GoldTracker.UpdateAllExpenses()
	local sum=0
	for i=1, #GoldTracker.savedVariablesAccount.charlist do
		charactername=GoldTracker.savedVariablesAccount.charlist[i];
		GoldTracker.savedVariablesAlt = ZO_SavedVars:New("GoldTrackerSavedVariables", 1, nil, LastResetDefaults, "Default", GetDisplayName(), charactername);
		sum = sum + GoldTracker.savedVariablesAlt.expenses;
	end
	GoldTrackerGuiOverviewAllExpenses:SetText(string.format(sum .. "g"))
end

function GoldTracker.UpdateAllBank()
	GoldTrackerGuiOverviewAllBank:SetText(string.format(GoldTracker.savedVariablesAccount.bank .. "g"))
end

function GoldTracker.UpdateAllBalance()
	local sum=0
	for i=1, #GoldTracker.savedVariablesAccount.charlist do
		charactername=GoldTracker.savedVariablesAccount.charlist[i];
		GoldTracker.savedVariablesAlt = ZO_SavedVars:New("GoldTrackerSavedVariables", 1, nil, LastResetDefaults, "Default", GetDisplayName(), charactername);
		sum = sum + GoldTracker.savedVariablesAlt.resetBalance + GoldTracker.savedVariablesAlt.income + GoldTracker.savedVariablesAlt.expenses;
	end
	sum = sum + GoldTracker.savedVariablesAccount.bank;
	GoldTrackerGuiOverviewAllBalance:SetText(string.format(sum .. "g"))
end

-- This function will create new labels in the overview gui for all alts and populate the info
function GoldTracker.UpdateAllAlts()
	local numchars = #GoldTracker.savedVariablesAccount.charlist
	if (numchars == 1) then
		return
	end
	GoldTrackerGuiOverview:SetDimensions(255,305+numchars*20);
	GoldTrackerGuiOverviewBackdrop:SetDimensions(255,305+numchars*20);
	local mylabel = ""
	local altstatus = ""
	local index = 1
	for i=1, numchars do
		charname = GoldTracker.savedVariablesAccount.charlist[i];
		if (charname ~= GetUnitName("Player")) then
			mylabel = "GoldTrackerGuiOverviewAltLabel"..index
			Alt = wm:CreateControl(mylabel, GoldTrackerGuiOverview, CT_LABEL);
			Alt:SetColor(0.53, 0.61, 0.49, 1)
			Alt:SetFont("ZoFontChat")
			Alt:SetWrapMode(TRUNCATE)
			Alt:SetDrawLayer(1)
			Alt:SetAnchor(TOPLEFT, GoldTrackerGuiOverview, TOPLEFT, 8 , 175+20*index)
			Alt:SetDimensions(245, 30)
			Alt:SetScale(1)
			Alt:SetText(GoldTracker.savedVariablesAccount.charlist[i]);
			mylabel = "GoldTrackerGuiOverviewAlt"..index
			Alt = wm:CreateControl(mylabel, GoldTrackerGuiOverview, CT_LABEL);
			Alt:SetColor(0.53, 0.61, 0.49, 1)
			Alt:SetFont("ZoFontChat")
			Alt:SetWrapMode(TRUNCATE)
			Alt:SetDrawLayer(1)
			Alt:SetAnchor(TOPLEFT, GoldTrackerGuiOverview, TOPLEFT, 8 , 175+20*index)
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

function GoldTracker.OnGuiOverviewMoveStop()
  GoldTracker.savedVariables.left = GoldTrackerGuiOverview:GetLeft()
  GoldTracker.savedVariables.top = GoldTrackerGuiOverview:GetTop()
end

function GoldTracker:RestorePosition()
  local left = self.savedVariables.left
  local top = self.savedVariables.top
 
  GoldTrackerGuiOverview:ClearAnchors()
  GoldTrackerGuiOverview:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end