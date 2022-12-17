DECLARE SUB clearBoard ()
DECLARE SUB iterate ()
DECLARE SUB drawBoard ()

CLS
PRINT "Pigs Program (q2)"
PRINT "(C) Copyright Andrew Ferrier, Spheroid Software 1998."
PRINT "RGS, Guildford."
PRINT

DIM xcord AS INTEGER, ycord AS INTEGER
DIM command AS STRING, subcommand AS STRING, subcommand2 AS STRING

CONST up = 5
CONST down = 6
CONST left = 7
CONST right = 8

CONST empty = 0
CONST tree = 1
CONST pigs = 2
CONST farmer = 3
CONST pigsfarmer = 4

TYPE square
    contents AS INTEGER
    pigsdirec AS INTEGER
    farmerdirec AS INTEGER
END TYPE

DIM SHARED pd AS INTEGER
DIM SHARED fd AS INTEGER
DIM SHARED grid(1 TO 10, 1 TO 10) AS square

pd = up
fd = up

PRINT "Enter Co-ords: "
INPUT "", xcord
LOCATE 6, 5
INPUT "", ycord

ycord = 11 - ycord

grid(xcord, ycord).contents = pigs
INPUT "", xcord
LOCATE 7, 5
INPUT "", ycord

ycord = 11 - ycord

IF (grid(xcord, ycord).contents = pigs) THEN
    grid(xcord, ycord).contents = pigsfarmer
ELSE
    grid(xcord, ycord).contents = farmer
END IF

DO
    CALL drawBoard

    INPUT "", command

    command = UCASE$(command)

    subcommand = command
    subcommand2 = ""

    FOR i = 1 TO LEN(command)
        IF MID$(command, i, 1) = " " THEN
            subcommand = MID$(command, 1, i - 1)
            subcommand2 = MID$(command, i)
        END IF
    NEXT

    SELECT CASE subcommand
        CASE "T"
            FOR i = 1 TO VAL(subcommand2)
                INPUT "", xcord
                INPUT "", ycord
                xcord = 11 - xcord
                ycord = 11 - ycord
                grid(xcord, ycord).contents = tree
            NEXT
        CASE "M"
            FOR i = 1 TO VAL(subcommand2)
                CALL iterate
            NEXT
        CASE "X"
            END
        CASE ELSE
    END SELECT
LOOP UNTIL (1 > 2)

SUB clearBoard
    FOR x = 1 TO 10
        FOR y = 1 TO 10
            IF (grid(x, y).contents <> tree) OR (grid(x, y).contents <> empty) THEN
                grid(x, y).contents = empty
            END IF
        NEXT
    NEXT
END SUB

SUB drawBoard
    DIM x AS INTEGER
    DIM y AS INTEGER

    PRINT
    FOR y = 1 TO 10
        FOR x = 1 TO 10
            SELECT CASE grid(x, y).contents
                CASE empty
                    PRINT ".";
                CASE farmer
                    PRINT "F";
                CASE pigs
                    PRINT "P";
                CASE pigsfarmer
                    PRINT "+";
                CASE tree
                    PRINT "*";
            END SELECT
        NEXT
        PRINT
    NEXT
END SUB

SUB iterate
    DIM px AS INTEGER, py AS INTEGER, fx AS INTEGER, fy AS INTEGER

    FOR x = 1 TO 10
        FOR y = 1 TO 10
            SELECT CASE grid(x, y).contents
                CASE pigs
                    px = x
                    py = y
                CASE farmer
                    fx = x
                    fy = y
                CASE pigsfarmer
                    px = x
                    py = y
                    fx = x
                    fy = y
                CASE ELSE
            END SELECT
        NEXT
    NEXT

    SELECT CASE pd
        CASE up
            IF py = 1 THEN pd = right ELSE py = py - 1
        CASE down
            IF py = 10 THEN pd = left ELSE py = py + 1
        CASE left
            IF px = 1 THEN pd = up ELSE px = px - 1
        CASE right
            IF px = 10 THEN pd = down ELSE px = px + 1
    END SELECT

    fd = pd

    SELECT CASE fd
        CASE up
            fy = fy - 1
        CASE down
            fy = fy + 1
        CASE left
            fx = fx - 1
        CASE right
           fx = fx + 1
    END SELECT

    IF (fx < 1) THEN fx = 1
    IF (fx > 10) THEN fx = 10
    IF (fy < 1) THEN fy = 1
    IF (fy > 10) THEN fy = 10

    CALL clearBoard

    IF (px = fx) AND (py = fy) THEN
        grid(px, py).contents = pigsfarmer
    ELSE
        grid(px, py).contents = pigs
        grid(fx, fy).contents = farmer
    END IF
END SUB

