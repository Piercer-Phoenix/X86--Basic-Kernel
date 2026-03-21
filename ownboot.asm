bits 16
org 0x7c00

_start:

    ;Job number 1: reading the kernel into memory using BIOS.

    mov ah, 0x02    ;Bios function specification. 
    mov al, 20      ;How many sectors are to be read, in this case, 20 sectors are enough for a small kernel
    mov ch, 0       
    mov cl, 2       ;From which sector to begin reading. 
    mov dh, 0
;dl argument tells BIOS which device we want to boot from, since we are using the 
;boot device itself for the sake of simplicity, the dl will stay the same as BIOS loads it with the drive number
    mov bx, 0x1000  ;This function loads the file we specified at ES:BX which will, in our case be 0x10000
    mov es, bx      ; ES = 0x1000
    xor bx, bx      ; BX = 0x0000, ES:BX = 0x10000
    int 0x13

    ;Job number 2: Enable protected mode.
    ; Before changing protection enable bit in cr0 to 1, we have to load a GDT. 
    
    cli             ;Stop interrupts when changing CPU state. 
    lgdt [gdt_desc] ;load the GDT

    ;enabling the pe bit in cr0
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    
    ;Set CS using a far jump statement and load EIP with the protected_setup label
    jmp 0x08 : protected_setup 

    ;since we are using flat memory models, we musth set up the segment registers(except CS)
    ;with the data segment selector and forget them. 


    protected_setup:
    ;job number 3: Finish protected mod setup, and then jump to kernel and give it access. 
    bits 32
    ;set up segment registers
    mov eax, 0x10
    mov ds, eax
    mov es, eax
    mov fs, eax
    mov gs, eax
    mov ss, eax
    mov esp, 0x7bff
    
    ;Jump to the kernel and start executing the instructions at 0x10000
    jmp 0x08 : 0x10000 


    ;The actual definition of the GDT, It is a grey box for me. 

    gdt_start:  
        dd 0, 0             ; Null descriptor (required)
    
    gdt_code:
        dw 0xFFFF           ; Limit low (bits 0-15)
        dw 0                ; Base low (bits 0-15)
        db 0                ; Base middle (bits 16-23)
        db 10011010b        ; Access byte: Present, Ring0, Code, Executable, Readable
        db 11001111b        ; Flags + Limit high: 32-bit, 4KB granularity, Limit 16-19
        db 0                ; Base high (bits 24-31)
        
    gdt_data:
        dw 0xFFFF           ; Limit low
        dw 0                ; Base low
        db 0                ; Base middle
        db 10010010b        ; Access byte: Present, Ring0, Data, Writable
        db 11001111b        ; Same flags
        db 0                ; Base high
        
    gdt_end:

    gdt_desc:
        dw gdt_end - gdt_start - 1  ; GDT size minus 1
        dd gdt_start                 ; GDT base address    


;Padding to 510 bytes for BIOS requirements
times 510 - ($-$$) db 0
;The magic number for letting BIOS know. 
dw 0xaa55