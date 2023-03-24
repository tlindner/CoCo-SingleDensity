	org	$8000
start
* patch DSKINI for SD

* Change the loop constructs in DSKINI to end at sector 9 instead of 18.

	lda	#$09
	sta	$d5c5
	sta	$d5c9
	sta	$d5d2
	sta	$d67b
	sta	$d6bc

* Change track start from 32 bytes of 0x4E to 32 bytes of 0xFF

	lda	#$ff
	sta	$d696

* Change track end from 200 bytes of 0x4E to 200 bytes of 0xFF

	sta	$d6c1

* New track table ends with 8 blocks not 9.

	lda	#$08
	sta	$d6b5

* Insert the address of the new track table into DSKINI.

	ldd	#nt
	std	$d6a4

* Change program to jump to our new DSKINI write routine.

	lda	#$7e
	sta	$d646
	ldd	#write
	std	$d647

* Now we patch DSKCON.

* OR in single density (instead of double density) mode

* patch DSKCON for SD
	lda	#$0
	sta	$d775

* Don’t turn on halt mode

	lda	#$00
	sta	$d840
* Set DRGRAM and DSKREG to single density
	sta $0986
	sta $ff40

* Patch DSKCON to jump to new write and read loops

	lda	#$7e
	sta	$d86b
	sta	$d881
	ldd	#wdsk
	std	$d86c
	ldd	#rdsk
	std	$d882

* patch out dskini verify
*	lda #$7e
*	sta $d662
*	ldd #$d2cd
*	std $d688

	rts
	
* New writing routine for DSKINI
    org $fe20

write	anda	#$4f
	sta	$ff40	Turn off halting, double density and NMI
    sta $0986   copy to DRGRAM
w0	ldb	,x+	Read byte from track buffer
w1	lda	$ff48	Get FDC status
	rora		Roll busy bit into carry flag
	bcc	w3	If not busy, then branch out of loop
	rora		Roll data request bit into carry flag
	bcs	w2	If ready for data, branch to write instruction
	bra	w1	Branch back to test status again.
w2	stb	,y	Write data to FDC
	bra	w0	Branch back to get new byte
w3	jmp	$d64f done, jmp back to DSKINI

* New writing routine for DSKCON

wdsk	ldb	,x+	Load byte from transfer buffer
	stb	$ff4b	Write it to FDC
wd1	lda	,u	Get status
	rora		Roll busy bit into carry flag
	lbcc	$d88b	If not busy, branch to end loop
	rora		Roll data request bit into carry flag
	bcs	wdsk	If data requested, get new byte from transfer buffer
	bra	wd1 Brach to check status again

* New reading routine for DSKCON

rdsk	ldb	$ff4b	Load byte from FDC
	stb	,x+	Store byte to transfer buffer
rd1	lda	,u	Get status
	rora		Roll busy bit into carry flag
	lbcc	$d88b	If not busy, branch to end loop
	rora		Roll data request bit into carry flag
	bcs	rdsk	If data requested, get new byte from transfer buffer
	bra	rd1	Brach to check status again

* New disk format table

nt	fcb 3,$0	Sync field
	fcb 3,$0
	fcb 1,$FE	ID Address Mark
* Track, side and sector numbers are inserted here
	fcb 1,1	Sector Size (256 byte sectors)
	fcb 1,$f7	CRC Request
	fcb 11,$ff	GAP II (Post-ID Gap)
	fcb 6,$0	Sync Field
	fcb 1,$fb	Data Address Mark (AM2)
	fcb 0,$ff	Data Field (256 bytes)
	fcb 1,$f7	CRC Request
	fcb 27,$ff	Gap III (Post Gap Data)
	end start
