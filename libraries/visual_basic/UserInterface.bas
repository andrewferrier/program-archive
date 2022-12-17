Attribute VB_Name = "UserInterface"
' Module: UserInterface
' (C) Andrew Ferrier, Spheroid Software 1998.
'
' Version History:
' 1.0.1     Comments changed (07/07/1999)
' 1.0       Version History started (13/4/98)

Option Explicit

'This is to do with Wait, StopWait, and StopWaitAll
Private HourCount As Integer

'These Win32 API Functions and constants
'are used by the Forms_* functions
Private Const SW_HIDE = 0
Private Const SW_SHOW = 5
Private Const GW_CHILD = 5
Private Const WM_MDINEXT = &H224

Private Declare Function IsWindowVisible Lib "user32" (ByVal hwnd As Long) As Long
Private Declare Function ShowWindow Lib "user32" (ByVal hwnd As Long, ByVal nCmdShow As Long) As Long
Private Declare Function GetWindow Lib "user32" (ByVal hwnd As Long, ByVal wCmd As Long) As Long
Private Declare Function SendMessage Lib "user32" Alias "SendMessageA" (ByVal hwnd As Long, ByVal wMsg As Long, ByVal wParam As Long, lParam As Long) As Long
Private Declare Function BringWindowToTop Lib "user32" (ByVal hwnd As Long) As Long
Private Declare Function EnableWindow Lib "user32" (ByVal hwnd As Long, ByVal fEnable As Long) As Long
Sub Forms_Fit(tox As Form, inside As Form)
    '-------------------------------------------
    'Error Handler V21
    CheckErrHandler = ERRORHANDLER_V21
    If Not InDesign() Then On Error GoTo EH_Forms_Fit Else On Error GoTo 0
    ErrorTrace "Forms_Fit", ERRORTRACE_STARTSUB, ERRORHANDLER_V21
    '-------------------------------------------

    inside.WindowState = 0
    If inside.Top + inside.Height > tox.ScaleHeight Then
        inside.Top = 0
    End If
    If inside.Left + inside.Width > tox.ScaleWidth Then
        inside.Left = 0
    End If

    '-------------------------------------------
    'Error Handler V21
    GoTo EH2_Forms_Fit
EH_Forms_Fit:
    Select Case ErrorHandler()
    Case ERR_RESULT_RESUME
        Resume
    Case ERR_RESULT_ENDSUB
        Resume EH2_Forms_Fit
    End Select
EH2_Forms_Fit:
    ErrorTrace "Forms_Fit", ERRORTRACE_ENDSUB, ERRORHANDLER_V21
    '-------------------------------------------
End Sub

Sub Forms_Hide(F As Form, frmMain As Form)
    '-------------------------------------------
    'Error Handler V21
    CheckErrHandler = ERRORHANDLER_V21
    If Not InDesign() Then On Error GoTo EH_Forms_Hide Else On Error GoTo 0
    ErrorTrace "Forms_Hide", ERRORTRACE_STARTSUB, ERRORHANDLER_V21
    '-------------------------------------------

    Dim i As Integer
    Dim newhWnd As Integer

    'Not allowed vbMaximized or vbMinimized
    If F.WindowState = vbMaximized Or F.WindowState = vbMinimized Then
        F.WindowState = vbNormal
    End If
    F.Enabled = False
    i = ShowWindow(F.hwnd, SW_HIDE)
    newhWnd = GetWindow(frmMain.hwnd, GW_CHILD)
    i = SendMessage(newhWnd, WM_MDINEXT, 0, 0&)

    '-------------------------------------------
    'Error Handler V21
    GoTo EH2_Forms_Hide
EH_Forms_Hide:
    Select Case ErrorHandler()
    Case ERR_RESULT_RESUME
        Resume
    Case ERR_RESULT_ENDSUB
        Resume EH2_Forms_Hide
    End Select
EH2_Forms_Hide:
    ErrorTrace "Forms_Hide", ERRORTRACE_ENDSUB, ERRORHANDLER_V21
    '-------------------------------------------
End Sub

Sub Forms_PositionDialog(Dialog As Form)
    '-------------------------------------------
    'Error Handler V21
    CheckErrHandler = ERRORHANDLER_V21
    If Not InDesign() Then On Error GoTo EH_Forms_PositionDialog Else On Error GoTo 0
    ErrorTrace "Forms_PositionDialog", ERRORTRACE_STARTSUB, ERRORHANDLER_V21
    '-------------------------------------------

    Dialog.Left = Screen.Width / 2 - Dialog.Width / 2
    Dialog.Top = Screen.Height / 2 - Dialog.Height / 2

    '-------------------------------------------
    'Error Handler V21
    GoTo EH2_Forms_PositionDialog
EH_Forms_PositionDialog:
    Select Case ErrorHandler()
    Case ERR_RESULT_RESUME
        Resume
    Case ERR_RESULT_ENDSUB
        Resume EH2_Forms_PositionDialog
    End Select
EH2_Forms_PositionDialog:
    ErrorTrace "Forms_PositionDialog", ERRORTRACE_ENDSUB, ERRORHANDLER_V21
    '-------------------------------------------
End Sub

Sub Forms_Unhide(F As Form)
    '-------------------------------------------
    'Error Handler V21
    CheckErrHandler = ERRORHANDLER_V21
    If Not InDesign() Then On Error GoTo EH_Forms_Unhide Else On Error GoTo 0
    ErrorTrace "Forms_Unhide", ERRORTRACE_STARTSUB, ERRORHANDLER_V21
    '-------------------------------------------

    Dim i As Integer
    Dim newwnd As Integer
    
    newwnd = F.hwnd
    If IsWindowVisible(newwnd) = False Then
        i = ShowWindow(newwnd, SW_SHOW)
    End If
    BringWindowToTop (newwnd)
    i = EnableWindow(newwnd, True)
    F.Show

    '-------------------------------------------
    'Error Handler V21
    GoTo EH2_Forms_Unhide
EH_Forms_Unhide:
    Select Case ErrorHandler()
    Case ERR_RESULT_RESUME
        Resume
    Case ERR_RESULT_ENDSUB
        Resume EH2_Forms_Unhide
    End Select
EH2_Forms_Unhide:
    ErrorTrace "Forms_Unhide", ERRORTRACE_ENDSUB, ERRORHANDLER_V21
    '-------------------------------------------
End Sub




Sub StopWait()
    '-------------------------------------------
    'Error Handler V21
    CheckErrHandler = ERRORHANDLER_V21
    If Not InDesign() Then On Error GoTo EH_StopWait Else On Error GoTo 0
    ErrorTrace "StopWait", ERRORTRACE_STARTSUB, ERRORHANDLER_V21
    '-------------------------------------------

    HourCount = HourCount - 1
    If HourCount <= 0 Then
        Screen.MousePointer = vbDefault
        HourCount = 0
    End If

    '-------------------------------------------
    'Error Handler V21
    GoTo EH2_StopWait
EH_StopWait:
    Select Case ErrorHandler()
    Case ERR_RESULT_RESUME
        Resume
    Case ERR_RESULT_ENDSUB
        Resume EH2_StopWait
    End Select
EH2_StopWait:
    ErrorTrace "StopWait", ERRORTRACE_ENDSUB, ERRORHANDLER_V21
    '-------------------------------------------
End Sub
Sub StopWaitAll()
    '-------------------------------------------
    'Error Handler V21
    CheckErrHandler = ERRORHANDLER_V21
    If Not InDesign() Then On Error GoTo EH_StopWaitAll Else On Error GoTo 0
    ErrorTrace "StopWaitAll", ERRORTRACE_STARTSUB, ERRORHANDLER_V21
    '-------------------------------------------

    HourCount = 0
    Screen.MousePointer = vbDefault

    '-------------------------------------------
    'Error Handler V21
    GoTo EH2_StopWaitAll
EH_StopWaitAll:
    Select Case ErrorHandler()
    Case ERR_RESULT_RESUME
        Resume
    Case ERR_RESULT_ENDSUB
        Resume EH2_StopWaitAll
    End Select
EH2_StopWaitAll:
    ErrorTrace "StopWaitAll", ERRORTRACE_ENDSUB, ERRORHANDLER_V21
    '-------------------------------------------
End Sub
Sub Wait()
    '-------------------------------------------
    'Error Handler V21
    CheckErrHandler = ERRORHANDLER_V21
    If Not InDesign() Then On Error GoTo EH_Wait Else On Error GoTo 0
    ErrorTrace "Wait", ERRORTRACE_STARTSUB, ERRORHANDLER_V21
    '-------------------------------------------

    HourCount = HourCount + 1
    If HourCount >= 1 Then Screen.MousePointer = vbHourglass

    '-------------------------------------------
    'Error Handler V21
    GoTo EH2_Wait
EH_Wait:
    Select Case ErrorHandler()
    Case ERR_RESULT_RESUME
        Resume
    Case ERR_RESULT_ENDSUB
        Resume EH2_Wait
    End Select
EH2_Wait:
    ErrorTrace "Wait", ERRORTRACE_ENDSUB, ERRORHANDLER_V21
    '-------------------------------------------
End Sub



Function Bool2Check(X As Boolean) As Integer
    If X Then
        Bool2Check = vbChecked
    Else
        Bool2Check = vbUnchecked
    End If
End Function

Function Check2Bool(X As Integer) As Boolean
    If X = vbChecked Then
        Check2Bool = True
    Else
        Check2Bool = False
    End If
End Function



