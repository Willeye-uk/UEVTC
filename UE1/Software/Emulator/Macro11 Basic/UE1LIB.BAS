
DECLARE FUNCTION find% (nam AS STRING)
DECLARE FUNCTION parse% (inpc AS STRING, lineno AS INTEGER)
DECLARE SUB bin (c AS INTEGER, r AS INTEGER, n AS INTEGER)

' Opcode table
opcodes:
DATA NOP0, 0
DATA LD, 16
DATA ADD, 32
DATA SUB, 48
DATA ONE, 64
DATA NAND, 80
DATA OR, 96
DATA XOR, 112
DATA STO, 128
DATA STOC, 144
DATA IEN, 160
DATA OEN, 176
DATA IOC, 192
DATA RTN, 208
DATA SKZ, 224
DATA NOPF, 240
DATA "", -1

' Memory table
memory:
DATA SR0, 0
DATA SR1, 1
DATA SR2, 2
DATA SR3, 3
DATA SR4, 4
DATA SR5, 5
DATA SR6, 6
DATA SR7, 7
DATA OR0, 8
DATA RR, 8
DATA OR1, 9
DATA IR1, 9      
DATA OR2, 10
DATA IR2, 10
DATA OR3, 11
DATA IR3, 11
DATA OR4, 12
DATA IR4, 12
DATA OR5, 13
DATA IR5, 13
DATA OR6, 14
DATA IR6, 14
DATA OR7, 15
DATA IR7, 15
DATA "", -1

' Subroutine to print an integer as binary at specified screen position
SUB bin (c AS INTEGER, r AS INTEGER, n AS INTEGER)
    LOCATE r, c, 0

    i% = 128
  
    DO
        PRINT CHR$((n AND i%) \ i% + 48);       ' 48 is '0'
        i% = i% \ 2
    LOOP WHILE i% > 0
END SUB

' Function to find data
' Input is code as string
' Output is value as integer. -1 indicates not found
' Caller has to restore data correctly before call
FUNCTION find% (nam AS STRING)
    DIM dat AS STRING
    DIM num AS INTEGER

    DO
        READ dat, num
    LOOP UNTIL dat = nam OR num = -1

    find = num
END FUNCTION

'
' Subrotine to parse an assembler statement and return opcode and mem
FUNCTION parse% (inpc AS STRING, lineno AS INTEGER)
    DIM postn AS INTEGER
    DIM opcos AS STRING
    DIM memas AS STRING
    DIM opco AS INTEGER
    DIM mema AS INTEGER

    ' Input can have a mixture of space and tab chars as white space
    ' So make any control char to a space so get removed with trim
    l% = LEN(inpc)
    FOR i% = 1 TO l%
        IF ASC(MID$(inpc, i%, 1)) < 32 THEN MID$(inpc, i%, 1) = " "
    NEXT i%

    postn = INSTR(inpc, ";")                              ' Find position of comment if any
    IF postn > 0 THEN inpc = LEFT$(inpc, postn - 1)       ' Remove any comments
    inpc = LTRIM$(RTRIM$(inpc))                           ' Remove leading and trailing spaces
 
    IF LEN(inpc) = 0 THEN
        parse% = -1
        EXIT FUNCTION
    END IF

    ' Ignore if no source
    postn = INSTR(inpc, " ")                              ' Find first space past opcode
 
    IF postn = 0 THEN
        PRINT "Invalid syntax at line "; lineno
        parse% = -1
        EXIT FUNCTION
    END IF

    opcos = LEFT$(inpc, postn - 1)                         ' Get opcode
    memas = LTRIM$(MID$(inpc, postn))                      ' Get memory

    ' Can only use ORn with STO or STOC ??
    IF (opcos <> "STO" AND opcos <> "STOC") AND LEFT$(memas, 2) = "OR" THEN
        PRINT "Invalid memory at line "; lineno
        parse% = -1
        EXIT FUNCTION
    END IF

    ' Try to find opcode
    RESTORE opcodes             ' Set data pointer to opcode data
    opco = find%(opcos)
 
    IF value = -1 THEN
        PRINT "Invalid opcode at line "; lineno
        parse% = -1
        EXIT FUNCTION
    END IF

    'writ = value

    ' Try to find memory
    RESTORE memory              ' Set data pointer to memory data
    mema = find%(memas)
 
    IF mema = -1 THEN
        PRINT "Invalid memory at line "; lineno
        parse% = -1
        EXIT FUNCTION
    END IF

    'writ = writ + value
    parse% = opco + mema
    EXIT FUNCTION

END FUNCTION

