.section .data
p1:  .asciz "Enter first string: "
p2:  .asciz "Enter second string: "
p3:  .asciz "Hamming distance = "
nl:  .asciz "\n"

.section .bss
.lcomm s1, 256
.lcomm s2, 256
.lcomm outbuf, 32

.section .text
.globl _start

_start:
    mov $1, %rax
    mov $1, %rdi
    lea p1(%rip), %rsi
    mov $20, %rdx
    syscall

    mov $0, %rax
    mov $0, %rdi
    lea s1(%rip), %rsi
    mov $255, %rdx
    syscall
    mov %rax, %r8

    lea s1(%rip), %r12
    cmp $0, %r8
    je read_second
    mov %r8, %rcx
    dec %rcx
    movzbq (%r12,%rcx,1), %rbx
    cmp $10, %bl
    jne read_second
    movb $0, (%r12,%rcx,1)
    dec %r8

read_second:
    mov $1, %rax
    mov $1, %rdi
    lea p2(%rip), %rsi
    mov $21, %rdx
    syscall

    mov $0, %rax
    mov $0, %rdi
    lea s2(%rip), %rsi
    mov $255, %rdx
    syscall
    mov %rax, %r9

    lea s2(%rip), %r13
    cmp $0, %r9
    je set_min
    mov %r9, %rcx
    dec %rcx
    movzbq (%r13,%rcx,1), %rbx
    cmp $10, %bl
    jne set_min
    movb $0, (%r13,%rcx,1)
    dec %r9

set_min:
    mov %r8, %r10
    cmp %r9, %r10
    jbe start_compare
    mov %r9, %r10

start_compare:
    xor %r11, %r11
    xor %r14, %r14

compare_chars:
    cmp %r10, %r11
    je print_answer

    mov (%r12,%r11,1), %al
    xor (%r13,%r11,1), %al

    mov $8, %cl
count_bits:
    shr $1, %al
    jnc bit_zero
    inc %r14
bit_zero:
    dec %cl
    jnz count_bits

    inc %r11
    jmp compare_chars

print_answer:
    mov $1, %rax
    mov $1, %rdi
    lea p3(%rip), %rsi
    mov $19, %rdx
    syscall

    lea outbuf(%rip), %rsi
    add $31, %rsi
    movb $0, (%rsi)

    mov %r14, %rax
    cmp $0, %rax
    jne make_digits
    dec %rsi
    movb $'0', (%rsi)
    jmp write_digits

make_digits:
    mov $10, %rbx
digit_loop:
    xor %rdx, %rdx
    div %rbx
    add $'0', %dl
    dec %rsi
    mov %dl, (%rsi)
    cmp $0, %rax
    jne digit_loop

write_digits:
    lea outbuf(%rip), %rcx
    add $31, %rcx
    sub %rsi, %rcx

    mov $1, %rax
    mov $1, %rdi
    mov %rsi, %rsi
    mov %rcx, %rdx
    syscall

    mov $1, %rax
    mov $1, %rdi
    lea nl(%rip), %rsi
    mov $1, %rdx
    syscall

    mov $60, %rax
    xor %rdi, %rdi
    syscall
