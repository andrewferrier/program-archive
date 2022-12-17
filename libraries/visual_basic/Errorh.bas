Attribute VB_Name = "ErrorH"
' Module: ErrorH
' (C) Andrew Ferrier, Spheroid Software 1998.
'
' Future:
' Make into general ErrorH for all programs.
'
' Version History:
' 2.0.1     Instructions for use placed in skeleton (8/7/1999)
' 2.0       Large-scale modifications to entire ErrorH module (12/4/98)
' 1.0.1     Minor modifications (11/4/98)
' 1.0       Version History started (10/4/98)

Option Explicit

'Private Declare Function FindWindow Lib "user32" Alias "FindWindowA" (ByVal lpClassName As String, ByVal lpWindowName As String) As Long
'Private Declare Function GetWindowWord Lib "user32" (ByVal hwnd As Long, ByVal nIndex As Long) As Integer

' Used by ErrorTrace
Public CurrentSub As String

' These constants are used in AA_Skeleton
Public Const ERR_RESULT_RESUME = 1
Public Const ERR_RESULT_ENDSUB = 2
Public Const ERR_RESULT_RESTARTSUB = 3

Public Const ERRORTRACE_STARTSUB = 0
Public Const ERRORTRACE_ENDSUB = 1
Private Const ERRORTRACE_ERROROCCURED = 2

'**** OLD VERSIONS

Public CheckErrHandler As Integer
Public Const ERRORHANDLER_V25 = 25
Public Const ERRORHANDLER_V24 = 24
Public Const ERRORHANDLER_V22 = 22
Public Const ERRORHANDLER_V21 = 21
Private Sub AA_Skeleton()
    ' Notes for use of skeleton:
    '
    ' - Paste the below sections around each subroutine or function,
    '   with the 1st section above all the code, and the 2nd section
    '   below all the code.
    ' - Replace all instances of the phrase "Skeleton" with the
    '   exact name of the procedure or subroutine.

    '-------------------------------------------
    'Error Handler v25 - 1st Section
    On Error GoTo EH_Skeleton: ErrorTrace "Skeleton", ERRORTRACE_STARTSUB
EHR_Skeleton:
    '-------------------------------------------

    '-------------------------------------------
    'Error Handler v25 - 2nd Section
    GoTo EH2_Skeleton
EH_Skeleton:
    Select Case ErrorHandler()
        Case ERR_RESULT_RESUME
            Resume
        Case ERR_RESULT_ENDSUB
            Resume EH2_Skeleton
        Case ERR_RESULT_RESTARTSUB
            Resume EHR_Skeleton
    End Select
EH2_Skeleton:
    ErrorTrace "Skeleton", ERRORTRACE_ENDSUB
    '-------------------------------------------
End Sub

Sub CreateInternalError(ErrorNum As Long, Optional ErrorInfo As String)
    'This is used to create an internal error in the
    'program

    ErrorTrace "CreateInternalError", ERRORTRACE_ERROROCCURED
    QuitError ErrorNum + 50000, ErrorInfo
End Sub

Function ErrorHandler() As Integer
    Const EXTRA_ERROR = 50000
    
    Dim ErrorNumber As Long
    Dim rc As Integer
    Dim ErrorResult As Integer
    Dim WinErr As Integer

    WinErr = Err.Number
    ErrorNumber = WinErr + EXTRA_ERROR
            
    Err.Number = 0
    ErrorTrace "ErrorHandler", ERRORTRACE_ERROROCCURED
        
    Select Case WinErr
        Case 7, 28, 3035, 3178, 20478
            'Out of Memory or Stack Space
            MsgBox "Warning: " & APPNAME & " is very low on memory. To try and ensure data safety, " & APPNAME & " will now close all the item windows and the Database. Before continuing your use of " & APPNAME & ", you should close all unnecessary windows in both " & APPNAME & " and other programs, to save on memory.", vbExclamation, MSGBOX_TITLE
            CloseDB
            ErrorResult = ERR_RESULT_ENDSUB
        Case 55, 3006, 3008, 3009, 3050, 3052
            'Share Error or Exclusive locking on DB/Table
            MsgBox "The file or database you are trying to open is already in use by " & APPNAME & " or another program. Please close this file before trying to open it here. If this error keeps occuring and you are sure that it is not due to the file being currently open in another program, you may need to load SHARE.EXE or increase it's number of locks. See your DOS manual for more information.", vbExclamation, MSGBOX_TITLE
            ErrorResult = ERR_RESULT_ENDSUB
        Case 61, 3026
            rc = MsgBox("The disk you are trying to save to is full. Please make sure that the disk has ample free space. Then press Retry. Alternatively, just press Cancel to stop the attempt to save (you may lose data).", vbExclamation & vbRetryCancel, MSGBOX_TITLE)
            If rc = vbRetry Then
                ErrorResult = ERR_RESULT_RESUME
            ElseIf rc = vbCancel Then
                ErrorResult = ERR_RESULT_ENDSUB
            End If
        Case 71
            'Disk Not Ready
            rc = MsgBox("The disk is not ready. Please make sure that the disk is in the drive and that the drive door is shut. Then press Retry. Alternatively, just press Cancel to stop what you are currently doing.", vbExclamation & vbRetryCancel, MSGBOX_TITLE)
            If rc = vbRetry Then
                ErrorResult = ERR_RESULT_RESUME
            ElseIf rc = vbCancel Then
                ErrorResult = ERR_RESULT_ENDSUB
            End If
        Case 363
            'Custom Control No Load
            MsgBox "One of " & APPNAME & "'s components is missing. It is necessary to re-install " & APPNAME & " to run it.", vbCritical, MSGBOX_TITLE
            CloseDB
            End
        Case 365
            CreateInternalError 0, "Unload Error"
            QuitError
        Case 482
            'Printer Error
            rc = MsgBox("An Error has occured when using your printer: Please make sure that it is connected to your computer, full of paper, switched on and online. Then press Retry. If you cannot get it to work, see your printer manual.", vbExclamation + vbRetryCancel, MSGBOX_TITLE)
            If rc = vbRetry Then
                ErrorResult = ERR_RESULT_RESUME
            Else
                ErrorResult = ERR_RESULT_ENDSUB
            End If
        Case 3024
            'Couldn't find file 'item'
            rc = MsgBox("Couldn't find the file you were trying to open. Sorry. Please try again. Make sure that any database you specified on the command line exists.", vbExclamation + vbOK, MSGBOX_TITLE)
            ErrorResult = ERR_RESULT_ENDSUB
        Case cdlCancel, 3059
            'Canceled a common dialog
            ErrorResult = ERR_RESULT_ENDSUB
        Case 3056
            'Couldn't repair database
            MsgBox "The database you are trying to repair cannot be repaired. It is recommended that you contact us (Spheroid Software) to see if we can solve the problem.", vbExclamation, MSGBOX_TITLE
            ErrorResult = ERR_RESULT_ENDSUB
        Case 3204
            'Database already exists
            MsgBox "The database you are trying to create or use already exists. Please use a different filename.", vbExclamation, MSGBOX_TITLE
            ErrorResult = ERR_RESULT_RESTARTSUB
        Case 3049, 3041, 3182
            'Database is corrupt or Invalid File Format.
            MsgBox "The database currently in use is corrupt. It will be closed immediately, and then you should repair it - see the help file for more information on repairing.", vbCritical, MSGBOX_TITLE
            CloseDB
            ErrorResult = ERR_RESULT_ENDSUB
        Case 3183
            'No enough space on temporary disk
            rc = MsgBox("There is not enough space on your temporary disk to continue. You need to free up some space. The press 'Retry' to continue. Or, press 'Cancel' to end " & APPNAME & ". See your DOS manual for more information on temporary disks.", vbCritical + vbRetryCancel, MSGBOX_TITLE)
            If rc = vbCancel Then
                QuitError
            Else
                ErrorResult = ERR_RESULT_RESUME
            End If
        Case 28663 To 28664
            'No Printer device drivers
            MsgBox "No Printer Device Drivers were found. You must install one using Windows Control Panel before you can print using " & APPNAME & ". See your Windows manual for more information.", vbExclamation, MSGBOX_TITLE
            ErrorResult = ERR_RESULT_ENDSUB
        Case Else
            'Unrecognized error.
            CreateInternalError 11, Str$(ErrorNumber)
    End Select

    If ErrorResult = ERR_RESULT_ENDSUB Or ErrorResult = ERR_RESULT_RESTARTSUB Then
        SetStatus ""
        StopWaitAll
    End If

    ErrorHandler = ErrorResult
End Function

Sub ErrorTrace(SubName As String, ErrorTraceType As Integer, Optional ErrorVersion As Integer)
    'This subroutine must be kept small in terms
    'of speed, because it is executed every time
    'a sub is entered or exited.

    'ErrorVersion is the version number of the error handler
    'It is an out-of-date concept: ignore it.
    
    Select Case ErrorTraceType
        Case ERRORTRACE_STARTSUB
            CurrentSub = SubName
        Case ERRORTRACE_ENDSUB
            'May not get intercepted if they use exit sub
        Case ERRORTRACE_ERROROCCURED
        Case Else
            CreateInternalError 19, Str$(ErrorTraceType)
    End Select
End Sub

Function InDesign() As Integer
    'InDesign no longer required because VB5 allows break on
    'all errors - so allow errors to be trapped.

    InDesign = False
End Function

Private Sub QuitError(Optional ErrorNum As Long = 0, Optional ErrorInfo As String = "")
    ' The following line is used instead of StopWaitAll from the UserInterface
    ' module because it ensures that CurrentSub is not corrupted.
    Screen.MousePointer = vbDefault
    
    ErrorInfo = Trim$(ErrorInfo)
    MsgBox "An internal error in " & APPNAME & " has occured: Please inform " & COMPANY & " of the error. Below are some bits of information that may help us fix the problem. Please note all this information down exactly. Thank you. Then " & APPNAME & " will end, attempting to save all information in the process. Error information is: " & Chr$(13) & Chr$(13) & APP_VERSION & "/" & Trim$(Str$(ErrorNum)) & "/" & ErrorInfo & "/" & CurrentSub, vbCritical, MSGBOX_TITLE
    If IsDatabaseOpen Then
        MainTable.Close
        LinksTable.Close
        DatabaseInUse.Close
    End If
    Stop
End Sub
