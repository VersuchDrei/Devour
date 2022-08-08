ScriptName DevourLibs Extends Quest

Actor Property PlayerRef Auto
Keyword Property Vampire Auto
OSexBar Property BloodBar Auto

GlobalVariable Property DevourBloodDrainTime Auto
GlobalVariable Property DevourBloodDrainRequired Auto
bool Property BloodDrainRequired
	bool Function Get()
		Return DevourBloodDrainRequired.GetValue() == 1
	EndFunction
EndProperty
GlobalVariable Property DevourBloodDrainLethal Auto
bool Property BloodDrainLethal
	bool Function Get()
		Return DevourBloodDrainLethal.GetValue() == 1
	EndFunction
EndProperty

GlobalVariable Property DevourDebugSkipVampireCheck Auto
bool Property DebugSkipVampireCheck
	bool Function Get()
		Return DevourDebugSkipVampireCheck.GetValue() == 1
	EndFunction
EndProperty
GlobalVariable Property DevourDebugSkipTargetCheck Auto
bool Property DebugSkipTargetCheck
	bool Function Get()
		Return DevourDebugSkipTargetCheck.GetValue() == 1
	EndFunction
EndProperty