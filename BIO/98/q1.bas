DECLARE FUNCTION RomanNumeral$ (inputNo AS INTEGER)

TYPE numeral
    num AS STRING * 1
    intval AS INTEGER
    critval AS INTEGER
END TYPE

CLS
PRINT "Roman Numeral Program (q1)"
PRINT "(C) Copyright Andrew Ferrier, Spheroid Software 1998."
PRINT "RGS, Guildford."
PRINT

DIM inputInteger AS INTEGER
DIM i AS INTEGER
DIM moreCount AS INTEGER

'moreCount = 0
'FOR i = 1 TO 3999
'    IF LEN(RTRIM$(LTRIM$(RomanNumeral$(i)))) > LEN(LTRIM$(RTRIM$(STR$(i)))) THEN
'        moreCount = moreCount + 1
'    END IF
'    LOCATE 1, 1
'    PRINT i
'NEXT
'PRINT "More Count: "; moreCount

'startAgain:
INPUT "Enter the number: ", inputInteger
IF (inputInteger < 1) OR (inputInteger > 3999) THEN
        PRINT "Invalid Input."
        END
END IF

PRINT "Roman Numeral Equivalent: ", RomanNumeral$(inputInteger)
'GOTO startAgain

FUNCTION RomanNumeral$ (inputNum AS INTEGER)

    DIM count AS INTEGER
    DIM i AS INTEGER
    DIM j AS INTEGER
    DIM returner AS STRING
    DIM addTo AS STRING
    DIM inputNo AS INTEGER

    DIM num(1 TO 7) AS numeral

    inputNo = inputNum 'BYVAL won't work

    num(1).intval = 1000
    num(1).critval = 900
    num(1).num = "M"
    num(2).intval = 500
    num(2).critval = 400
    num(2).num = "D"
    num(3).intval = 100
    num(3).critval = 90
    num(3).num = "C"
    num(4).intval = 50
    num(4).critval = 40
    num(4).num = "L"
    num(5).intval = 10
    num(5).critval = 9
    num(5).num = "X"
    num(6).intval = 5
    num(6).critval = 4
    num(6).num = "V"
    num(7).intval = 1
    num(7).critval = 10000
    num(7).num = "I"

    FOR j = 1 TO 7
        'Add the obvious ones first

        count = inputNo \ num(j).intval
        
        addTo = ""
        FOR i = 1 TO count
            addTo = addTo + num(j).num
        NEXT

        inputNo = inputNo - (count * num(j).intval)
        returner = returner + addTo

        'Next check for special cases

        IF inputNo >= num(j).critval THEN
            SELECT CASE j
                CASE 1
                    addTo = "CM"
                CASE 2
                    addTo = "CD"
                CASE 3
                    addTo = "XC"
                CASE 4
                    addTo = "XL"
                CASE 5
                    addTo = "IX"
                CASE 6
                    addTo = "IV"
                CASE ELSE
                    STOP
            END SELECT

            inputNo = inputNo - num(j).critval
            returner = returner + addTo
        END IF
    NEXT
           
    RomanNumeral$ = returner
END FUNCTION

