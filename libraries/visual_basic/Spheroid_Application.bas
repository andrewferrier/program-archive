Attribute VB_Name = "Spheroid_Application"
Option Explicit

Private Const SPHEROID_PROGRAMS_LOG = "c:\spheroid_programs.log"

Dim filenumber As Integer


Sub CloseLog()
    PrintToLog "Spheroid Application log about to be closed."
    Close filenumber
End Sub

Sub EndSpheroidApplication()
    CloseLog
End Sub

Sub OpenLog()
    Open SPHEROID_PROGRAMS_LOG For Append As filenumber
    PrintToLog "Spheroid Application log now open."
End Sub

Sub PrintToLog(LogMessage As String)
    Print #filenumber, LogMessage
End Sub

Sub StartSpheroidApplication()
    filenumber = FreeFile
    
    OpenLog
    Print #filenumber, ""
    Print #filenumber, "******* " & Date & " " & Time & " *********"
    Print #filenumber, "Visual Basic"
    Print #filenumber, "Application Title: " & APPNAME & " version " & APP_VERSION
    #If DebugVersion Then
        Print #filenumber, "Running in debug mode."
    #Else
        Print #filenumber, "Running in release mode."
    #End If
End Sub



