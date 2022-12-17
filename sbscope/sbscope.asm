;
;
;   CRO Program - Written by and Copyright Andrew J Ferrier 1996.
;
;   Andrew Ferrier, Spheroid Software
;
;   this program must be compiled with the SB_BASE constant defined
;   (pref. on the command line of the assembler).

        dosseg
        .MODEL tiny
        .286
        .386
        .stack 50d
        .RADIX 10

        sb_reset           equ SB_BASE + 06h
        sb_read            equ SB_BASE + 0Ah
        sb_write           equ SB_BASE + 0Ch
        sb_dataavail       equ SB_BASE + 0Eh

        screen_width       equ 320d
        screen_height      equ 200d
        screen_base        equ 0A000h

        array_base1        equ 5000h
        array_base2        equ array_base1 + screen_width

        num_pal_entries    equ 0FFh
        frame_count_digits equ 10d

        white              equ 15d

; MAIN PROGRAM ===============================================================

        .code
        even

start:

        ; Reset SB. This is probably not necessary on the new SoundBlasters
        ; (eg SB-16), but it is probably necessay for back/wd compatibility.

        mov     al, 1
        mov     dx, sb_reset
        out     dx, al
        mov     cx, 50000
slow:   loop    slow	                         ; Optimized for size
        mov     al, 0
        out     dx, al
        mov     dx, sb_dataavail
loop1:  in      al, dx
        and     al, 10000000b
        jz      loop1
        mov     dx, sb_read
loop2:  in      al, dx
        cmp     al, 0AAh
        jnz     loop2

        ; Setup Arrays

        ; FS and GS DO NOT point to segments. I am merely using them as
        ; 16-bit values, because it means that the array offsets can be
        ; exchanged and moved around quickly.

        mov     ax, array_base1                  ; FS = Old Array
        mov     fs, ax                           ; GS = New Array
        mov     ax, array_base2
        mov     gs, ax

        ; Clear out screen area

        mov     ax, cs
        mov     es, ax
        mov     di, array_base1
        mov     ecx, ((screen_width * 2) + 16) / 4
        mov     eax, 64646464h
        rep     stosd

         ; Initialize 320x200x256 video mode.

        mov     ax, 0013h
        int     10h

        ; Initialize Frame Count (kept in ebp) naughty!

	xor	ebp, ebp

        ; Set ES to point to the screen - it will not be changed throughout
        ; program. Also clear direction flag - just in case it's set (why?)

        mov     ax, screen_base
        mov     es, ax
        cld

; NEW SCREEN =================================================================

newscreen:

        ; Frame count
	
	inc	ebp

        ; Swap arrays

        mov     ax, fs
        mov     bx, gs
        mov     gs, ax
        mov     fs, bx

        ; Initialize Loop + Clear interrupts

        cli
        mov     ecx, screen_width

        ; Vert. Retrace Check - Slow it down a bit !

        mov     dx, 3DAh
l1:     in      al, dx
        and     al, 1h
        jnz     l1
l2:     in      al, dx
        and     al, 1h
        jz      l2

; NEW COLUMN =================================================================

newcolumn:

        ; Get SB Sample

        mov     dx, sb_write
loopa1: in      al, dx
        and     al, 10000000b
        jnz     loopa1
        mov     al, 20h
        out     dx, al
        mov     dx, sb_dataavail
loopa2: in      al, dx
        and     al, 10000000b
        jz      loopa2
        mov     dx, sb_read
        in      al, dx

        ; AL = Sample value from 0 to 255.
        ; Convert AL from (0 to 255) to (0 to 199)

        xor     ah, ah
        mov     bx, screen_height - 1
        mul     bx
        shr     ax, 8                            ; Div. by 255 (0xFF)

        ; Save new value

        mov     si, gs
        add     si, cx
        mov     cs:[si], al

        ; Wipe out old line

        push    ax                               ; Save new value

        mov     si, fs
        add     si, cx
	mov	ax, cs:[si]
        xor     bh, bh

        call    vline

        ; Draw new line

        pop     ax                               ; Get it back

        mov     si, gs
        add     si, cx
        mov     ah, cs:[si + 1]
        mov     bh, white

        call    vline

        ; Loop around the columns

	dec	ecx
	jnz     newcolumn

        ; Set interrupts on and check the keyboard.

        sti
        mov     ah, 01h
        int     16h
        jnz     short kyprss
        jmp     newscreen

; VERTICAL LINE ROUTINE ======================================================

        ; Register Summary:

        ; AL=X1 of line                    Destroyed
        ; AH=X2 of line                    Destroyed
        ; BH=Attribute                     Destroyed
        ; BL=Not used                      Destroyed
        ; CX=Y of line                       Preserved (ECX)
        ; DX=Not used                      Destroyed
        ; DI=Not used                      Destroyed
        ; ES=Screen base                     Preserved

vline:
        push    ecx

        cmp     ah, al
        ja      short noswap
        je      short onepoint

        xchg    ah, al                           ; AH = Bottom, AL = Top.

noswap:
        mov     di, cx
        push    ax
        xor     ah, ah

	push 	ax
	shl     ax, 8
	pop     cx
	shl	cx, 6
	add	ax, cx

        add     di, ax
        pop     ax

        sub     ah, al
        xor     cx, cx
        mov     cl, ah

vlineloop:
        mov     es:[di], bh
        add     di, screen_width
	dec	cx
	jnz     vlineloop

        pop     ecx
        ret

onepoint:
        mov     di, cx
        xor     ah, ah

	push 	ax
	shl     ax, 8
	pop     cx
	shl	cx, 6
	add	ax, cx

        add     di, ax
        mov     es:[di], bh

        pop     ecx
        ret

; KEY PRESSED ===============================================================

kyprss: ; Clear Keyboard Buffer

        mov     ah, 00h
        int     16h

        ; Set mode back to text

        mov     ax, 0003h
        int     10h
        mov     ax, 1112h
        mov     bl, 00h
        int     10h

        ; Print number of frames

        mov     ax, seg numframesstring
        mov     ds, ax
        mov     dx, offset numframesstring
        mov     ah, 09h
        int     21h

        mov     ecx, frame_count_digits
        mov     ah, 02h
blanks: mov     dl, 32d
        int     21h
        loop    blanks                           ; Optimized for size

        mov     ecx, frame_count_digits

lpprnt: mov     eax, ebp
        mov     ebx, 10d
        cdq
        div     ebx
        mul     ebx
        mov     edx, ebp
        sub     edx, eax

        ; eax is digit

        mov     ah, 02h
        add     dl, 48d
        int     21h
        mov     dl, 08h
        int     21h
        int     21h

        mov     eax, ebp
        mov     ebx, 10d
        cdq
        div     ebx
        mov     ebp, eax

        loop    lpprnt			         ; Optimized for size

        ; Print text on screen

        mov     ax, seg endstring
        mov     ds, ax
        mov     dx, offset endString
        mov     ah, 09h
        int     21h

        mov     ax, 4C00h
        int     21h

; DATA =======================================================================

        .data

        numframesstring db "Total no. of frames:$"
        include \SPHEROID\SBSCOPE\SBSCOPE.MSG

; END ASSEMBLY ===============================================================

end start
