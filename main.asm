global _start

section .text
_start:
  ; eval by default also progresses by 1. But we don't want that, we want to start on 0
  call get_instruction
  jmp rax

unsafe_exit:
  mov rax, 60
  xor rdi, rdi
  syscall

unsafe_unimpl:
  mov rax, 1 ; sys_write
  mov rdi, 1 ; stdout
  mov rsi, unimplemented_msg
  mov rdx, 14 ; len of msg
  syscall
  jmp unsafe_exit

i_mov:
  ;; Which register
  call inc_i_ptr
  call get_register
  mov rdx, rax
  ; RAX now contains the address to the register we want to move to

  ;; Value to move
  ; for now we only support 8-bit
  call inc_i_ptr
  call get_8_bits
  mov [rdx], rax
  jmp eval
i_add:
  jmp unsafe_unimpl    
i_sub:
  jmp unsafe_unimpl   
i_mul:
  jmp unsafe_unimpl   
i_div:
  jmp unsafe_unimpl   
i_print:
  ;; Which register
  call inc_i_ptr
  call get_register
  mov rdx, rax
  mov rsi, [rdx]
  ; We now have the value that was in the register in rsi

  add rsi, 48 ; ascii offset
  mov [print_buffer], rsi
  mov rsi, print_buffer

  mov rax, 1 ; sys_write
  mov rdi, 1 ; stdout
  mov rdx, 1 ; len
  syscall
  jmp eval
i_exit:
  jmp unsafe_exit

inc_i_ptr:
  mov rax, [instruction_ptr]
  inc rax
  mov [instruction_ptr], rax
  ret
  
instruction_table:
  jmp i_mov
  jmp i_add
  jmp i_sub
  jmp i_mul
  jmp i_div
  jmp i_print
  jmp i_exit

get_8_bits:
  ;; Get the current instruction opcode
  ; get instruction-pointer offset, we want byte-offset and not bit-offset
  mov rax, [instruction_ptr]
  ; add our offset with the base pointer
  add rax, source_ir
  mov rbx, rax
  xor rax, rax
  ; Get the actual instruction itself
  mov al, [rbx]
  movsx rax, al
  ret

get_instruction:
  call get_8_bits
  ; Multiply offset with table element size
  mov cl, I_TABLE_OFFSET_SIZE
  mul cl
  movsx rax, al
  ; We now have the mem offset from 0 to correct opcode in the table. 
  ; But we need to add the base mem address for our table
  add rax, instruction_table
  ret

get_register:
  ; Which ID? 
  call get_8_bits
  ; We want to offset by 64bit (since our regs are 64bit)
  mov rcx, 8
  mul rcx
  ; Add our base offset
  add rax, reg1
  ret

eval:
  call inc_i_ptr
  call get_instruction
  jmp rax
 
section .data
  source_ir: db I_MOV, REG1, 5, I_MOV, REG2, 2, I_PRINT, REG1, I_EXIT
  print_buffer: resq 0
  unimplemented_msg:  db "unimplemented", 10

section .bss
  instruction_ptr: resq 0
  reg1: resq 0
  reg2: resq 0
  reg3: resq 0
  reg4: resq 0
  
I_MOV equ 0
I_ADD equ 1
I_SUB equ 2
I_MUL equ 3
I_DIV equ 4
I_PRINT equ 5
I_EXIT equ 6
REG1 equ 0
REG2 equ 1
REG3 equ 2
REG4 equ 3
I_TABLE_OFFSET_SIZE equ 2
