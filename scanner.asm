section .data
    exit_cmd db 'exit', 0xA                 ; Command to exit the console
    exit_len equ $ - exit_cmd               ; Length of the exit command
    info_cmd db 'info', 0xA                 ; Command to print system information
    info_len equ $ - info_cmd               ; Length of the info command
    buffer_size equ 80                      ; Define buffer size as a variable
    prompt db '>> ', 0                      ; Shell prompt string
    sys_info db 'System: x86_64 Linux', 0xA ; Example system information string
    sys_info_len equ $ - sys_info           ; Length of the system information string
    uname_syscall equ 63                    ; Syscall number for uname in Linux
    newline db 10

section .bss
    input resb buffer_size                  ; Reserve 80 bytes for the input buffer
    uname_buffer resb 65                    ; Reserve 65 bytes for storing the kernel version

section .text
global _start

_start:
    call clear_buffer                       ; Clear the buffer
    call display_prompt                     ; Display shell prompt
    call read_input                         ; Read user input

    ; Check for commands
    call check_exit                         ; Check if the exit command was given
not_exit:
    call check_info                         ; Check if the info command was given
not_info:
    call no_command
good_cmd:
    jmp _start                              ; Loop back to start

; Functions below this point

; Clear data from the buffer
clear_buffer:
    mov rcx, buffer_size                    ; Set the counter to the buffer size
    mov rdi, input                          ; Destination is the input buffer
clear_buffer_loop:                          ; Loop Label
    mov byte [rdi + rcx - 1], 0             ; Set each byte in the buffer to 0
    loop clear_buffer_loop                  ; Decrement rcx and repeat until rcx is 0
    ret

; Display the shell prompt
display_prompt:
    mov rax, 1                              ; Syscall number for sys_write
    mov rdi, 1                              ; File descriptor 1 (stdout)
    mov rsi, prompt                         ; Pointer to the prompt string
    mov rdx, 4                              ; Length of the prompt string (3 characters + null terminator)
    syscall                                 ; Call kernel
    ret

; Read input from the user
read_input:
    mov rax, 0                              ; Syscall number for sys_read (0 in 64-bit)
    mov rdi, 0                              ; File descriptor 0 (stdin)
    mov rsi, input                          ; Pointer to buffer
    mov rdx, buffer_size                    ; Number of bytes to read
    syscall                                 ; Call kernel
    ret

print_newline:
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall
    ret

; Echo the input back to the console
no_command:
    mov rax, 1                              ; Syscall number for sys_write (for debugging)
    mov rdi, 1                              ; File descriptor 1 (stdout)
    mov rsi, input                          ; Buffer to write
    mov rdx, buffer_size                    ; Length of buffer
    syscall                                 ; Call kernel
    ret

; Get kernel version using uname syscall
get_kernel_version:
    mov rax, uname_syscall                  ; Syscall number for uname
    mov rdi, uname_buffer                   ; Pointer to the buffer for storing uname output
    syscall                                 ; Call kernel
    ret                                     ; Return to caller

; Check if input is 'exit'
check_exit:
    xor rax, rax                            ; Reset rax to 0
    xor rcx, rcx                            ; Counter for loop
compare_loop:
    mov al, [exit_cmd + rcx]                ; Load the next byte of the exit command into al
    cmp al, [input + rcx]                   ; Compare this byte with the corresponding byte in input
    jne not_exit                            ; Jump to read_input if not equal
    inc rcx                                 ; Increment the counter rcx to move to the next byte
    cmp rcx, exit_len - 1                   ; -1 because we don't compare newline character
    jl compare_loop

    ; Exit the program
    mov rax, 60                             ; Syscall number for sys_exit (60 in 64-bit)
    xor rdi, rdi                            ; Return 0 status
    syscall                                 ; Call kernel

; Check if input is 'info'
check_info:
    xor rax, rax                            ; Reset rax to 0
    xor rcx, rcx                            ; Counter for loop
compare_info_loop:
    mov al, [info_cmd + rcx]                ; Load the next byte of the info command into al
    cmp al, [input + rcx]                   ; Compare this byte with the corresponding byte in input
    jne not_info                            ; Jump to no_command if not equal
    inc rcx                                 ; Increment the counter rcx to move to the next byte
    cmp rcx, info_len                       ; Compare with info_len, including newline
    jl compare_info_loop

    ; Display system information
    call get_kernel_version                 ; Get the kernel version (replaces sys_info for dynamic info)
    mov rax, 1                              ; Syscall number for sys_write
    mov rdi, 1                              ; File descriptor 1 (stdout)
    mov rsi, uname_buffer                   ; Pointer to the buffer containing the kernel version
    mov rdx, 65                             ; Length of the buffer (assumed maximum)
    syscall                                 ; Call kernel

    call print_newline
    
    jmp good_cmd                            ; Return to main loop