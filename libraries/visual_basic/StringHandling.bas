Attribute VB_Name = "StringHandling"
Option Explicit

Function GetFileNamePortion(ByVal Filename As String, Optional JustExtension As Boolean = False) As String
    '-------------------------------------------
    'Error Handler V24
    If Not InDesign() Then On Error GoTo EH_GetFileNamePortion Else On Error GoTo 0
    ErrorTrace "GetFileNamePortion", ERRORTRACE_STARTSUB, ERRORHANDLER_V24
EHR_GetFileNamePortion:
    '-------------------------------------------

    'If JustExtension = false, returns
    'xxxxx.yyy, else yyy

    Dim SearchFor As String * 1
    Dim LastPos As Long

    If JustExtension Then
        SearchFor = "."
    Else
        SearchFor = "\"
    End If

    LastPos = InstrBackwards(Len(Filename), Filename, SearchFor)
    If LastPos <= 0 Then
        GetFileNamePortion = ""
    Else
        GetFileNamePortion = Right$(Filename, Len(Filename) - LastPos)
    End If

    '-------------------------------------------
    'Error Handler V24
    GoTo EH2_GetFileNamePortion
EH_GetFileNamePortion:
    Select Case ErrorHandler()
    Case ERR_RESULT_RESUME
        Resume
    Case ERR_RESULT_ENDSUB
        Resume EH2_GetFileNamePortion
    Case ERR_RESULT_RESTARTSUB
        Resume EHR_GetFileNamePortion
    End Select
EH2_GetFileNamePortion:
    ErrorTrace "GetFileNamePortion", ERRORTRACE_ENDSUB, ERRORHANDLER_V24
    '-------------------------------------------
End Function


Function InstrBackwards(ByVal StartPos As Long, ByVal MainString As String, ByVal SubString As String) As Long
    Dim i As Long

    If StartPos > (Len(MainString) - Len(SubString) + 1) Then
        InstrBackwards = 0
        Exit Function
    End If

    For i = StartPos To 1 Step -1
        If Mid$(MainString, i, Len(SubString)) = SubString Then
            'Found
            InstrBackwards = i
            Exit Function
        End If
    Next
    
    InstrBackwards = 0
End Function

Public Function ParseIntoSubstrings(ToParse As String, SubString As String) As Collection
    Dim Results As New Collection
    Dim Location As Long, NewLocation As Long

    Location = 1

    Do
        NewLocation = InStr(Location, ToParse, SubString, 0)

        If NewLocation > 1 Then
            'Found substring
            Results.Add Mid$(ToParse, Location, NewLocation - Location)
            Location = NewLocation + Len(SubString)
        Else
            'not found
            Results.Add Right$(ToParse, Len(ToParse) - Location + 1)
            Exit Do
        End If
    Loop
    
    Set ParseIntoSubstrings = Results
End Function


Function RemoveSubSection(ByVal MainString As String, ByVal Section1 As Long, ByVal Section2 As Long) As String
    If Section2 < Section1 Then
        Dim Temp As Long
        
        Temp = Section1
        Section1 = Section2
        Section2 = Temp
    End If
    
    RemoveSubSection = Left$(MainString, Section1 - 1) & Right$(MainString, Len(MainString) - Section2)
End Function


Function RemoveSubStrings(ByVal MainString As String, ByVal SubString As String) As String
    Dim Located As Long
    
    Do
        Located = InStr(1, MainString, SubString, 0)
        If Located > 0 Then
            MainString = RemoveSubSection(MainString, Located, Located + Len(SubString) - 1)
        Else
            Exit Do
        End If
    Loop
    
    RemoveSubStrings = MainString
End Function

