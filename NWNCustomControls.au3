#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.16.1
 Author:         Jeff Gaydos

 Script Function:
	This script has the complex task of calibrating the look movement.
	Basically, we need a point in which we know we can start our click
	and move our mouse around without touching any of the other
	controls in the game. We calibrate this by using a busy wait that can
	detect the down state of the mouse
	
	Why calibrate? Well because I have a lot of different layouts that I
	could see myself using on different screens, and I don't want to have
	to go back in here and recalibrate everything. Plus, this makes it
	quite extensible to other games if you want to add mappings to
	different touch screen buttons (game dependent).
	
	To this end, we could use a config file to help users remember which
	actions they are calibrating to which inputs, but for now we hard-code
	it in.
	
	See https://www.autoitscript.com/forum/topic/8982-detect-mouse-click/ for button codes...

#ce ----------------------------------------------------------------------------
#Include <WinAPI.au3> ;for mouse settings changes...
#include <MsgBoxConstants.au3>
#include <AutoItConstants.au3>

; internal locals
Local $BasePeriod = 10
Local $IterationTimeout = 500
Local $Title = "NWN Gamepad Control System"

; saved state
Local $SaveFolder = "./SaveState/"
Local $SV_CenterX = $SaveFolder & "saved_position_x.txt"
Local $SV_CenterY = $SaveFolder & "saved_position_y.txt"

; game-related locals
;;; Movement
Local $P_Center[2]
Local $MouseOffset = 120
Local $MouseSpeed = 50
Local $A = 0
Local $LStickIn = 0
Local $LMenu = 0
Local $RMenu = 0

; control-related locals
Local $IP = "./InputPipe/"
Local $IP_exe = "InputPipe.exe"
Local $IP_LStick = $IP & "Controls_LStick.txt"
Local $IP_RStick = $IP & "Controls_RStick.txt"
Local $IP_LStickIn = $IP & "Controls_LStickIn.txt"
Local $IP_RStickIn = $IP & "Controls_RStickIn.txt"
Local $IP_A = $IP & "Controls_A.txt"
Local $IP_B = $IP & "Controls_B.txt"
Local $IP_X = $IP & "Controls_X.txt"
Local $IP_Y = $IP & "Controls_Y.txt"
Local $IP_RBump = $IP & "Controls_RBump.txt"
Local $IP_LBump = $IP & "Controls_LBump.txt"
Local $IP_RTrigger = $IP & "Controls_RTrigger.txt"
Local $IP_LTrigger = $IP & "Controls_LTrigger.txt"
Local $IP_RMenu = $IP & "Controls_RMenu.txt"
Local $IP_LMenu = $IP & "Controls_LMenu.txt"

; NOT an event based system, requires busy wait
Func _IsPressed($HexKey)
   Local $AR
   $HexKey = '0x' & $HexKey
   $AR = DllCall("user32","int","GetAsyncKeyState","int",$HexKey)
   If NOT @Error And BitAND($AR[0],0x8000) = 0x8000 Then Return 1
   Return 0
EndFunc

; Returns true if mouse input was found, false if we timedout
Func _WaitForMouseInput()
	$I = 0
	While (Not _IsPressed('01')) AND ($I < $IterationTimeout)
		Sleep($BasePeriod)
		$I = $I + 1
	WEnd
	Return $I < $IterationTimeout
EndFunc

; Parses a Unity Vector2 string into an AutoIT Array
Local $ParseError = 81246378278
Func _ArrayFromUnityVector2String($vector2)
	Local $removeParen = StringMid($vector2, 2, StringLen($vector2) - 2) ;FYI 1-indexed
	Local $rawSplit = StringSplit($removeParen, ",")
	Local $values[2]
	If $rawSplit[0] = 2 Then
		$values[0] = $rawSplit[1]
		$values[1] = $rawSplit[2]
		Return $values
	EndIf
	$values[0] = $ParseError
	$values[1] = $ParseError
	Return $values
EndFunc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Calibration Phase
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Local $previousCenterX = FileRead($SV_CenterX)
;Local $previousCenterY = FileRead($SV_CenterY)
Local $shouldUseSaved = $IDCANCEL
;If StringLen($previousCenterX) > 0 Then
	;$shouldUseSaved = MsgBox($MB_OKCANCEL, $Title, "Saved center position found. Press OK to skip calibration or cancel to recalibrate")
;EndIf

If $shouldUseSaved = $IDCANCEL Then
	MsgBox(0, $Title, "Get in-game, press this box's ok, and left click (and hold) on the center of your character in-game (until the next message appears)");

	If _WaitForMouseInput() Then
		$P_Center = MouseGetPos()
	Else
		MsgBox(0, $Title, "Calibration timed out...")
		Exit
	EndIf

	;$shouldSave = MsgBox($MB_YESNO, $title, "Would you like to save this position for the next time you run this script?")
	;If $shouldSave = $IDYES Then
		;FileWrite($SV_CenterX, $P_Center[0])
		;FileWrite($SV_CenterY, $P_Center[1])
	;EndIf
Else
	;$P_Center[0] = $previousCenterX
	;$P_Center[1] = $previousCenterY
EndIf
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;MsgBox(0, $Title, "Opening the input piper to get gamepad controls in the background")
Run("./InputPipe/InputPipe.exe", "./InputPipe")
;Sleep(3000)

MsgBox(0, $Title, "Begining mouse-jacking loop, press k to exit")
$i = 0
While (Not _IsPressed('4B'))
	If $A = 0 Then 
		MouseUp("primary")
	EndIf
	
	If $LStickIn = 0 Then
		MouseUp("secondary")
	EndIf
	
	If $LMenu = 0 Then 
		Send("{i up}")
	EndIf
	
	If $RMenu = 0 Then 
		Send("{ESC up}")
	EndIf
	
	Local $LStick = FileRead($IP_LStick)
	Local $LStickArr = _ArrayFromUnityVector2String($LStick)
	Local $RStick = FileRead($IP_RStick)
	Local $RStickArr = _ArrayFromUnityVector2String($RStick)
	If ($LStickArr[0] <> $ParseError And ($LStickArr[0] <> 0.00 Or $LStickArr[1] <> 0.00) And ($RStickArr[0] = 0.00 Or $RStickArr[1] = 0.00)) Or (($RStickArr[0] = 0.00 And $RStickArr[1] = 0.00) And ($LStickArr[0] = 0.00 And $LStickArr[1] = 0.00)) Then
		MouseMove($P_Center[0] + $LStickArr[0] * $MouseOffset, $P_Center[1] - $LStickArr[1] * $MouseOffset, 0) ;Move to position
	EndIf
	If $RStickArr[0] <> $ParseError And ($RStickArr[0] <> 0.00 Or $RStickArr[1] <> 0.00) And ($LStickArr[0] = 0.00 Or $LStickArr[1] = 0.00) Then
		Local $Current = MouseGetPos()
		MouseMove($Current[0] + $RStickArr[0] * $MouseSpeed, $Current[1] - $RStickArr[1] * $MouseSpeed, 0)
	EndIf
	
	$A = FileRead($IP_A)
	If Not _IsPressed('01') And $A = 1 Then
		MouseDown("primary")
	EndIf
	
	$LStickIn = FileRead($IP_LStickIn)
	If Not _IsPressed('02') And $LStickIn = 1 Then
		MouseDown('secondary')
	EndIf
	
	$RTrigger = FileRead($IP_RTrigger)
	If $RTrigger > 0.5 Then
		Send("{UP down}")
	Else
		Send("{UP up}")
	EndIf
	
	$LTrigger = FileRead($IP_LTrigger)
	If $LTrigger > 0.5 Then
		Send("{DOWN down}")
	Else
		Send("{DOWN up}")
	EndIf
	
	$RBump = FileRead($IP_RBump)
	If $RBump = 1 Then
		Send("{RIGHT down}")
	EndIf
	If $RBump = 0 Then
		Send("{RIGHT up}")
	EndIf
	
	$LBump = FileRead($IP_LBump)
	If $LBump = 1 Then
		Send("{LEFT down}")
	EndIf
	If $LBump = 0 Then
		Send("{LEFT up}")
	EndIf
	
	$LMenu = FileRead($IP_LMenu)
	If $LMenu = 1 Then
		Send("{i down}")
	EndIf
	
	$RMenu = FileRead($IP_RMenu)
	If $RMenu = 1 Then
		Send("{ESC down}")
	EndIf
	
	Sleep($BasePeriod)
	$i = $i + 1
WEnd
MsgBox(0, $Title, "Successfully cancelled. Manually close the InputPipe.exe window to fully close this down.")