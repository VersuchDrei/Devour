ScriptName DevourEvents Extends Quest

DevourLibs Property Libs Auto

; scene registry
bool registryOn = False
string[] baseScenesDouble
string[] replacerScenesDouble
string[] baseScenesMale
string[] replacerScenesMale
string[] baseScenesFemale
string[] replacerScenesFemale

OSexIntegrationMain OStim
OBarsScript OBars
bool lastAnimFeeding = False
float bloodBarPercent = 1.0

Event OnInit()
	Maintenance()
EndEvent

Function Maintenance()
	OStim = OUtils.GetOStim()
	OBars = OStim.GetBarScript()

	RegisterForModEvent("ostim_scenechanged", "OnSceneChange")
	RegisterForModEvent("ostim_end", "OnEnd")

	InitBloodBar()
	BuildRegistry()
EndFunction

Function InitBloodBar()
	Libs.BloodBar.HAnchor = "left"
	Libs.BloodBar.VAnchor = "bottom"
	Libs.BloodBar.X = 493
	Libs.BloodBar.Y = 100
	Libs.BloodBar.Alpha = 0.0
	Libs.BloodBar.SetPercent(1.0)
	Libs.BloodBar.FillDirection = "right"
	Libs.BloodBar.FadedOut = True
	Libs.BloodBar.SetColors(0xB0B0B0, 0x800000, 0xFFFFFF)
EndFunction

Function BuildRegistry()
	string[] files = JsonUtil.JsonInFolder("../Devour")

	bool first = True
	int i = files.Length
	registryOn = i

	While i
		i -= 1
		string fileName = "../Devour/" + files[i]
		JsonUtil.Load(fileName)

		If first
			first = False
			baseScenesDouble = JsonUtil.PathStringElements(fileName, "baseScenesDouble")
			replacerScenesDouble = JsonUtil.PathStringElements(fileName, "replacerScenesDouble")
			baseScenesMale = JsonUtil.PathStringElements(fileName, "baseScenesMale")
			replacerScenesMale = JsonUtil.PathStringElements(fileName, "replacerScenesMale")
			baseScenesFemale = JsonUtil.PathStringElements(fileName, "baseScenesFemale")
			replacerScenesFemale = JsonUtil.PathStringElements(fileName, "replacerScenesFemale")
		Else
			baseScenesDouble = PapyrusUtil.MergeStringArray(baseScenesDouble, JsonUtil.PathStringElements(fileName, "baseScenesDouble"))
			replacerScenesDouble = PapyrusUtil.MergeStringArray(replacerScenesDouble, JsonUtil.PathStringElements(fileName, "replacerScenesDouble"))
			baseScenesMale = PapyrusUtil.MergeStringArray(baseScenesMale, JsonUtil.PathStringElements(fileName, "baseScenesMale"))
			replacerScenesMale = PapyrusUtil.MergeStringArray(replacerScenesMale, JsonUtil.PathStringElements(fileName, "replacerScenesMale"))
			baseScenesFemale = PapyrusUtil.MergeStringArray(baseScenesFemale, JsonUtil.PathStringElements(fileName, "baseScenesFemale"))
			replacerScenesFemale = PapyrusUtil.MergeStringArray(replacerScenesFemale, JsonUtil.PathStringElements(fileName, "replacerScenesFemale"))
		EndIf

		JsonUtil.Unload(fileName, False)
	EndWhile
EndFunction

Event OnSceneChange(string eventName, string strArg, float numArg, Form sender)
	Actor Dom = OStim.GetDomActor()
	Actor Sub = OStim.GetSubActor()

	If lastAnimFeeding
		lastAnimFeeding = False
		OBars.SetBarVisible(Libs.BloodBar, False)
		UnregisterForUpdate()
		If bloodBarPercent == 0 || !Libs.BloodDrainRequired
			If Dom == Libs.PlayerRef
				VampireFeedProxy.VampireFeed(Sub, False)
			ElseIf Sub == Libs.PlayerRef
				VampireFeedProxy.VampireFeed(Dom, False)
			EndIf
		EndIf
	EndIf

	String sceneID = OStim.GetCurrentAnimationSceneID()

	CheckForAnimationReplacing(Dom, Sub, sceneID)

	If Libs.PlayerRef.HasKeyword(Libs.Vampire) && (Dom == Libs.PlayerRef && StringUtil.Find(sceneID, "VampireBiteMale") != -1 || Sub == Libs.PlayerRef && StringUtil.Find(sceneID, "VampireBiteFemale") != -1) && StringUtil.Find(sceneId, "GoTo") == -1 && StringUtil.Find(sceneId, "GoBack") == -1
		lastAnimFeeding = True
		If Libs.BloodDrainRequired || Libs.BloodDrainLethal
			bloodBarPercent = 1.0
			Libs.BloodBar.SetPercent(1.0, True)
			OBars.SetBarVisible(Libs.BloodBar, True)
			RegisterForUpdate(0.2)
		EndIf
	Else
		lastAnimFeeding = False
	EndIf
EndEvent

Event OnUpdate()
	bloodBarPercent -= 0.2 / Libs.DevourBloodDrainTime.GetValue()
	If bloodBarPercent < 0
		If Libs.BloodDrainLethal
			OBars.SetBarVisible(Libs.BloodBar, False)
			UnregisterForUpdate()
			Actor Dom = OStim.GetDomActor()
			Actor Sub = OStim.GetSubActor()
			If Dom == Libs.PlayerRef
				VampireFeedProxy.VampireFeed(Sub, True)
			ElseIf Sub == Libs.PlayerRef
				VampireFeedProxy.VampireFeed(Dom, True)
			EndIf
			OStim.EndAnimation(False)
			Return
		EndIf
		bloodBarPercent = 0
	EndIf
	Libs.BloodBar.SetPercent(bloodBarPercent)
EndEvent

Event OnEnd(string eventName, string strArg, float numArg, Form sender)
	lastAnimFeeding = False
	UnregisterForUpdate()

	Utility.Wait(0.5)
	OBars.SetBarVisible(Libs.BloodBar, False)
EndEvent

Function CheckForAnimationReplacing(Actor Dom, Actor Sub, string SceneID)
	If !registryOn
		Return
	EndIf

	bool maleCanFeed = (Libs.DebugSkipVampireCheck || Dom.HasKeyword(Libs.Vampire)) && (Libs.DebugSkipTargetCheck || VampireFeedProxy.CanFeedOn(Dom, Sub))
	bool femaleCanFeed = (Libs.DebugSkipVampireCheck || Sub.HasKeyword(Libs.Vampire)) && (Libs.DebugSkipTargetCheck || VampireFeedProxy.CanFeedOn(Sub, Dom))

	If maleCanFeed && femaleCanFeed
		int i = baseScenesDouble.Find(SceneID)
		If i != -1
			OStim.WarpToAnimation(replacerScenesDouble[i])
			Return
		EndIf
	EndIf

	If maleCanFeed
		int i = baseScenesMale.Find(SceneID)
		If i != -1
			OStim.WarpToAnimation(replacerScenesMale[i])
			Return
		EndIf
	EndIf

	If femaleCanFeed
		int i = baseScenesFemale.Find(SceneID)
		If i != -1
			OStim.WarpToAnimation(replacerScenesFemale[i])
			Return
		EndIf
	EndIf
EndFunction