'Bio '97 - Part 1
'Written by and Copyright Andrew J Ferrier, Spheroid Software 1997.

DIM hours AS INTEGER, minutes AS INTEGER
DIM hoursArray(1 TO 12) AS STRING
DIM minutesArray(1 TO 29) AS STRING
DIM calcResult AS STRING

hoursArray(1) = "One"
hoursArray(2) = "Two"
hoursArray(3) = "Three"
hoursArray(4) = "Four"
hoursArray(5) = "Five"
hoursArray(6) = "Six"
hoursArray(7) = "Seven"
hoursArray(8) = "Eight"
hoursArray(9) = "Nine"
hoursArray(10) = "Ten"
hoursArray(11) = "Eleven"
hoursArray(12) = "Twelve"

minutesArray(13) = "Thirteen"
minutesArray(14) = "Fourteen"
minutesArray(16) = "Sixteen"
minutesArray(17) = "Seventeen"
minutesArray(18) = "Eighteen"
minutesArray(19) = "Nineteen"
minutesArray(20) = "Twenty"
FOR minutes = 1 TO 9
    minutesArray(20 + minutes) = "Twenty-" + LCASE$(minutesArray(minutes))
NEXT
FOR minutes = 1 TO 12
    minutesArray(minutes) = hoursArray(minutes)
NEXT

start:
CLS
PRINT "Time Program"
INPUT "Hours: ", hours
INPUT "Minutes: ", minutes

IF hours < 1 OR hours > 12 OR minutes < 0 OR minutes > 59 THEN
    PRINT "Invalid input.": END
END IF

SELECT CASE minutes
        CASE 0
                calcResult = hoursArray(hours) + " o'clock"
        CASE 1
                calcResult = "One minute past " + hoursArray(hours)
        CASE 2 TO 14
                calcResult = minutesArray(minutes) + " minutes past " + hoursArray(hours)
        CASE 15
                calcResult = "Quarter past " + hoursArray(hours)
        CASE 16 TO 29
                calcResult = minutesArray(minutes) + " minutes past " + hoursArray(hours)
        CASE 30
                calcResult = "Half past " + hoursArray(hours)
        CASE 31 TO 44
                GOSUB hoursAdjust
                calcResult = minutesArray(60 - minutes) + " minutes to " + hoursArray(hours)
        CASE 45
                GOSUB hoursAdjust
                calcResult = "Quarter to " + hoursArray(hours)
        CASE 45 TO 58
                GOSUB hoursAdjust
                calcResult = minutesArray(60 - minutes) + " minutes to " + hoursArray(hours)
        CASE 59
                GOSUB hoursAdjust
                calcResult = "One minute to " + hoursArray(hours)
        CASE ELSE
                calcResult = "Invalid input."
                END
END SELECT

PRINT calcResult
DO: LOOP WHILE INKEY$ = ""
GOTO start

hoursAdjust:
hours = hours + 1
IF hours = 13 THEN hours = 1
RETURN

SUB hoursAdjust (hours AS INTEGER)
        hours = hours + 1
        IF hours = 13 THEN hours = 1
END SUB

