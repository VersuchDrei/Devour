ScriptName DevourMCM Extends SKI_ConfigBase

DevourLibs Property Libs Auto

Event OnConfigInit()
	Pages = New string[2]
	Pages[0] = "Settings"
	Pages[1] = "Debug"
EndEvent

Event OnPageReset(string Page)
	If Page == Pages[0]
		BuildSettingsPage()
	ElseIf Page == Pages[1]
		BuildDebugPage()
	EndIf
EndEvent

Function BuildSettingsPage()
	SetCursorFillMode(LEFT_TO_RIGHT)
	SetCursorPosition(0)
	AddHeaderOption("Blood Drain")
	SetCursorPosition(2)
	AddToggleOptionST("OID_BloodDrainRequired", "Blood Drain required", Libs.BloodDrainRequired)
	SetCursorPosition(4)
	AddToggleOptionST("OID_BloodDrainLethal", "Blood Drain lethal", Libs.BloodDrainLethal)
	SetCursorPosition(6)
	int bloodDrainTimeFlags = OPTION_FLAG_NONE
	If !Libs.BloodDrainRequired && !Libs.BloodDrainLethal
		bloodDrainTimeFlags = OPTION_FLAG_DISABLED
	EndIf
	AddSliderOptionST("OID_BloodDrainTime", "Blood Drain time", Libs.DevourBloodDrainTime.GetValue(), "{0}", bloodDrainTimeFlags)
EndFunction

Function BuildDebugPage()
	SetCursorFillMode(LEFT_TO_RIGHT)
	SetCursorPosition(0)
	AddToggleOptionST("OID_DebugSkipVampireCheck", "skip vampire check", Libs.DebugSkipVampireCheck)
	SetCursorPosition(2)
	AddToggleOptionST("OID_DebugSkipTargetCheck", "skip target check", Libs.DebugSkipTargetCheck)
EndFunction

State OID_BloodDrainRequired
	Event OnHighlightST()
		SetInfoText("When activated the vampire feed effect will only get triggered if the blood bar is fully empty.")
	EndEvent

	Event OnSelectST()
		float NewValue = 1 - Libs.DevourBloodDrainRequired.GetValue()
		Libs.DevourBloodDrainRequired.SetValue(NewValue)
		SetToggleOptionValueST(NewValue)
		If NewValue == 1
			SetOptionFlagsST(OPTION_FLAG_NONE, False, "OID_BloodDrainTime")
		ElseIf !Libs.BloodDrainLethal
			SetOptionFlagsST(OPTION_FLAG_DISABLED, False, "OID_BloodDrainTime")
		EndIf
	EndEvent
EndState

State OID_BloodDrainLethal
	Event OnHighlightST()
		SetInfoText("When activated fully emptying the blood bar will kill the victim.")
	EndEvent

	Event OnSelectST()
		float NewValue = 1 - Libs.DevourBloodDrainLethal.GetValue()
		Libs.DevourBloodDrainLethal.SetValue(NewValue)
		SetToggleOptionValueST(NewValue)
		If NewValue == 1
			SetOptionFlagsST(OPTION_FLAG_NONE, False, "OID_BloodDrainTime")
		ElseIf !Libs.BloodDrainRequired
			SetOptionFlagsST(OPTION_FLAG_DISABLED, False, "OID_BloodDrainTime")
		EndIf
	EndEvent
EndState

State OID_BloodDrainTime
	Event OnHighlightST()
		SetInfoText("Time in seconds it takes to suck a victim dry")
	EndEvent

	Event OnSliderOpenST()
		SetSliderDialogStartValue(Libs.DevourBloodDrainTime.GetValue())
		SetSliderDialogDefaultValue(10)
		SetSliderDialogRange(1, 20)
		SetSliderDialogInterval(1)
	EndEvent

	Event OnSliderAcceptST(float Value)
		Libs.DevourBloodDrainTime.SetValue(Value)
		SetSliderOptionValueST(Value, "{0}")
	EndEvent
EndState

State OID_DebugSkipVampireCheck
	Event OnHighlightST()
		SetInfoText("When activated the feed option will be available for every actor, not just vampires.")
	EndEvent

	Event OnSelectST()
		float NewValue = 1 - Libs.DevourDebugSkipVampireCheck.GetValue()
		Libs.DevourDebugSkipVampireCheck.SetValue(NewValue)
		SetToggleOptionValueST(NewValue)
	EndEvent
EndState

State OID_DebugSkipTargetCheck
	Event OnHighlightST()
		SetInfoText("When activated the feed option will be availabe on any target, not just non-vampires. Note that the amaranth feature of overhauls like Better Vampires or Sacrosanct is respected and this option is not required for that.")
	EndEvent

	Event OnSelectST()
		float NewValue = 1 - Libs.DevourDebugSkipTargetCheck.GetValue()
		Libs.DevourDebugSkipTargetCheck.SetValue(NewValue)
		SetToggleOptionValueST(NewValue)
	EndEvent
EndState