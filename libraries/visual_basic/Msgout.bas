Attribute VB_Name = "MSGOUT"
' Module: MsgFrm
' (C) Andrew Ferrier, Spheroid Software 1998.
'
' format of messages file is
' NNN message text
' the NNN is there for your benefit and is ignored
' the message text must start in col 4
'
' Version History:
' 1.0.2     Mousepointer mods.
' 1.0.1     Access Identifiers on funcs. (10/4/98)
' 1.0       Version History started (10/4/98)
' 0.5       Updated - AJF from hereon (21/12/97)
' 0.4       MLF versions (?)

Option Explicit

Private msgout_message_filename As String
Private msgout_message_ptrs() As Integer
Private msgout_message_msgs() As String
Private msgout_message_maxmsgs As Integer
Private Function char_convert(istring As String, cconvert As String, cto As String) As String

'Last Updated 21/12/97

'this function scans an input string for a character sequence
'and replaces all occurences with another string
'the return is the new string

'istring the input string
'cconvert the string to be replaced
'cto the string to replace with

Dim off As Integer
Dim leftx As String
Dim rightx As String
Dim work As String
Dim worklen As Integer
Dim convlen As Integer

work = istring
off = InStr(work, cconvert)
Do While off > 0
    leftx = ""
    rightx = ""
    worklen = Len(work)
    convlen = Len(cconvert)
    If off > 1 Then
        leftx = Mid$(work, 1, off - 1)
    End If
    If off + convlen - 1 < worklen Then
        rightx = Mid$(work, off + convlen, worklen - off - convlen + 1)
    End If
    work = leftx + cto + rightx
    ' re-search entire string
    off = InStr(work, cconvert)
Loop

end_char_convert:
char_convert = work
End Function

Public Function msgout_message(msgnum As Integer, flags As Integer, p1 As String, p2 As String, p3 As String) As Integer

Dim xx As String
Dim MsgTxt As String

Wait
MsgTxt = msgout_get(msgnum)

xx = char_convert(MsgTxt, "%1", p1)
xx = char_convert(xx, "%2", p2)
xx = char_convert(xx, "%3", p3)
StopWait
msgout_message = MsgBox(xx, flags, MSGBOX_TITLE)
StopWait

End Function

Public Function msgout_get(msgnum As Integer) As String

Dim filenum As Integer
Dim work As String

work = ""
Wait
If msgnum > 0 And msgnum <= msgout_message_maxmsgs Then
    If msgout_message_msgs(msgnum) > "*" Then
        work = msgout_message_msgs(msgnum)
    Else
        filenum = FreeFile
        Open msgout_message_filename For Binary As filenum
        work = String$(msgout_message_ptrs(2, msgnum), " ")
        Get #filenum, msgout_message_ptrs(1, msgnum), work
        If msgout_message_msgs(msgnum) = "*" Then
            msgout_message_msgs(msgnum) = work
        End If
        Close filenum
    End If
Else
    work = ""
End If

quit_msgout_get:
msgout_get = Trim$(work)
StopWait

End Function

Public Function msgout_get_subin(msgnum As Integer, p1 As String, p2 As String, p3 As String) As String
    Dim xx As String
    Dim MsgTxt As String
        
    Wait
    MsgTxt = msgout_get(msgnum)
    
    xx = char_convert(MsgTxt, "%1", p1)
    xx = char_convert(xx, "%2", p2)
    xx = char_convert(xx, "%3", p3)
    StopWait
    msgout_get_subin = xx
End Function

Public Function msgout_init(Path As String, Filename As String) As Integer



Dim filenum As Integer
Dim currentsize As Integer
Dim offset As Integer
Dim msgnum As Integer
Dim work As String

Wait

ReDim msgout_message_ptrs(2, 32) As Integer
ReDim msgout_message_msgs(32) As String
currentsize = 32
filenum = FreeFile
msgout_message_filename = RTrim$(Path) + RTrim$(Filename)
Open msgout_message_filename For Input As filenum
offset = 1
Do While Not EOF(filenum)
    Line Input #filenum, work
    If Len(work) > 4 Then
        If Left$(work, 1) <> "*" Then
            msgnum = Val(Left$(work, 3))
            If msgnum > currentsize Then
                currentsize = currentsize + 32
                ReDim Preserve msgout_message_ptrs(2, currentsize) As Integer
                ReDim Preserve msgout_message_msgs(currentsize) As String
            End If
            If msgnum > msgout_message_maxmsgs Then
                msgout_message_maxmsgs = msgnum
            End If
            msgout_message_msgs(msgnum) = Mid$(work, 4, 1)
            If Mid$(work, 4, 1) = "#" Then
                msgout_message_msgs(msgnum) = Trim$(Right$(work, Len(work) - 4))
            End If
            msgout_message_ptrs(1, msgnum) = offset + 4
            msgout_message_ptrs(2, msgnum) = Len(work) - 4
        End If
    End If
    offset = offset + Len(work) + 2
Loop
Close filenum
StopWait

End Function

