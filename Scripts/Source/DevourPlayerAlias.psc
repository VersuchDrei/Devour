ScriptName DevourPlayerAlias Extends ReferenceAlias

Event OnPlayerLoadGame()
	(GetOwningQuest() As DevourEvents).Maintenance()
EndEvent