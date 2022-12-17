Option Explicit

Function CheckSum (FileName As String) As Long
    Dim ffn As Integer
    Dim Total As Long
    Dim Total2 As Long
    Dim Tot2 As String
    Dim I As Long

    ffn = FreeFile
    Open FileName For Binary As #ffn
    Total = 0
    Get #ffn, I, Tot2
    Randomize Asc(Tot2)
    For I = 1 To LOF(ffn)
        Tot2 = " "
        Get #ffn, I, Tot2
        Total = Total + (Asc(Tot2) * I)
        Total2 = Total2 + (Asc(Tot2) * Rnd)
    Next
    Total = Total Mod Total2
    Total = Total + Total2
    Total = Total + 278
    Close #ffn
    CheckSum = Total
End Function

