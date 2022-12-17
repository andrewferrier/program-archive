'Bio '97 - Part 2
'Written by and Copyright Andrew Ferrier 1997.

DIM board(1 TO 8, 1 TO 8) AS STRING
DIM i AS INTEGER, j AS INTEGER, x AS INTEGER, y AS INTEGER
DIM inputChar AS STRING, currentPlayer AS STRING
DIM inputValue AS INTEGER
DIM xcord AS INTEGER, ycord AS INTEGER
DIM totalChanged AS INTEGER, occupied AS INTEGER
DIM foundyet AS INTEGER

TYPE maxCh
    max AS INTEGER
    x AS INTEGER
    y AS INTEGER
END TYPE

DIM maxChanged AS maxCh

CONST EMPTY = "."
CONST BLACK = "*"
CONST WHITE = "0"

CLS
PRINT "BIO'97 - Part Two by Andrew Ferrier"
PRINT

FOR i = 1 TO 8
    FOR j = 1 TO 8
        board(i, j) = EMPTY
    NEXT
NEXT

FOR i = 1 TO 4
    FOR j = 1 TO 4
        DO
            inputChar = INKEY$
        LOOP WHILE inputChar = ""
        SELECT CASE inputChar
            CASE "*": board(i + 2, j + 2) = BLACK
            CASE "0": board(i + 2, j + 2) = WHITE
            CASE ".": board(i + 2, j + 2) = EMPTY
            CASE ELSE
                PRINT "Invalid input."
                END
        END SELECT
        PRINT inputChar;
    NEXT
    PRINT
NEXT

PRINT
PRINT "Strategy One"
GOSUB printBoard
currentPlayer = BLACK

DO
    INPUT "Input:", inputValue

    SELECT CASE inputValue
        CASE -1
            END
        CASE IS > 0
            FOR i = 1 TO inputValue
                GOSUB playRound
            NEXT
            GOSUB printBoard
        CASE 0
            INPUT "X: ", xcord
            INPUT "Y: ", ycord
            board(xcord, ycord) = currentPlayer
            GOSUB incrementPlayer
            GOSUB printBoard
    END SELECT
LOOP

playRound:
FOR i = 1 TO 8
    FOR j = 1 TO 8
        totalChanged = 0
        maxChanged.max = 0
        maxChanged.x = 1
        maxChanged.y = 1

        IF board(i, j) = EMPTY THEN
            'Can place here
            occupied = 0
            IF i > 1 THEN
                IF board(i - 1, j) <> EMPTY THEN occupied = 1
            END IF
            IF i < 8 THEN
                IF board(i + 1, j) <> EMPTY THEN occupied = 1
            END IF
            IF j > 1 THEN
                IF board(i, j - 1) <> EMPTY THEN occupied = 1
            END IF
            IF j < 8 THEN
                IF board(i, j + 1) <> EMPTY THEN occupied = 1
            END IF
            IF i > 1 AND j > 1 THEN
                IF board(i - 1, j - 1) <> EMPTY THEN occupied = 1
            END IF
            IF i < 8 AND j < 8 THEN
                IF board(i + 1, j + 1) <> EMPTY THEN occupied = 1
            END IF
            IF i > 1 AND j < 8 THEN
                IF board(i - 1, j + 1) <> EMPTY THEN occupied = 1
            END IF
            IF i < 8 AND j > 1 THEN
                IF board(i + 1, j - 1) <> EMPTY THEN occupied = 1
            END IF
        END IF

        IF (occupied = 1) THEN
            'One square occupied - can continue
            'Now we have to fill in all the gaps
            'and count up the no. of counters
            'Unfinished
        END IF

        IF maxChanged.max < totalChanged THEN
            maxChanged.x = i
            maxChanged.y = j
            maxChanged.max = totalChanged
        END IF
    NEXT
NEXT
board(maxChanged.x, maxChanged.y) = currentPlayer
GOSUB incrementPlayer
RETURN

printBoard:
FOR i = 1 TO 8
    FOR j = 1 TO 8
        PRINT board(i, j);
    NEXT
    PRINT
NEXT
RETURN

incrementPlayer:
IF currentPlayer = WHITE THEN currentPlayer = BLACK
IF currentPlayer = BLACK THEN currentPlayer = WHITE
RETURN





