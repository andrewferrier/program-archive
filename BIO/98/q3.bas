CLS
PRINT "Alphametics Program (q3)"
PRINT "(C) Copyright Andrew Ferrier, Spheroid Software 1998."
PRINT "RGS, Guildford."
PRINT

DIM numLines AS INTEGER, i AS INTEGER, j AS INTEGER

INPUT "", numLines

DIM lines(1 TO numLines) AS STRING
DIM letter(1 TO 9) AS STRING * 1

FOR i = 1 TO 9
    letter(i) = " "
NEXT

FOR i = 1 TO numLines
    INPUT "", lines(i)
    lines(i) = UCASE$(lines(i))
NEXT

FOR i = 1 TO numLines
    FOR j = 1 TO LEN(lines(i))
        FOR k = 1 TO 9
            IF MID$(lines(i), j, 1) = letter(k) THEN

            END IF
        NEXT
    NEXT
NEXT


