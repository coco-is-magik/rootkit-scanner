section .data
    exit_cmd db 'exit', 0xA    ; Command to exit the console
    exit_len equ $ - exit_cmd  ; Length of the exit command

section .bss
    input resb 80              ; Reserve 80 bytes for the input buffer

section .text
global _start

_start:
    ; Read input from the user
read_input:
    mov rax, 0                ; syscall number for sys_read (0 in 64-bit)
    mov rdi, 0                ; file descriptor 0 (stdin)
    mov rsi, input            ; pointer to buffer
    mov rdx, 80               ; number of bytes to read
    syscall                   ; call kernel

    ; Compare input with 'exit'
    mov rax, 1                ; syscall number for sys_write (for debugging)
    mov rdi, 1                ; file descriptor 1 (stdout)
    mov rsi, input            ; buffer to write
    mov rdx, 80               ; length of buffer
    syscall                   ; call kernel

    ; Check if input is 'exit'
    xor rax, rax              ; reset rax to 0
    xor rcx, rcx              ; counter for loop
compare_loop:
    mov al, [exit_cmd + rcx]
    cmp al, [input + rcx]
    jne read_input            ; jump to read_input if not equal
    inc rcx
    cmp rcx, exit_len - 1     ; -1 because we don't compare newline character
    jl compare_loop

    ; Exit the program
    mov rax, 60               ; syscall number for sys_exit (60 in 64-bit)
    xor rdi, rdi              ; return 0 status
    syscall                   ; call kernel
