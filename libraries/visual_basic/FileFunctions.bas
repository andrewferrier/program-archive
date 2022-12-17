Attribute VB_Name = "FileFunctions"
Option Explicit

Public Function GetFileAsString(Filename As String) As String
    Dim Filenumber As Integer
    Dim ImportedData As String
    Dim ImportedData2 As String

    Filenumber = FreeFile
    Open Filename For Input As Filenumber
    ImportedData = ""
    Do Until EOF(Filenumber)
        Line Input #Filenumber, ImportedData2
        ImportedData = ImportedData & ImportedData2 & Chr$(13) & Chr$(10)
    Loop
    Close Filenumber
    
    GetFileAsString = ImportedData
End Function


