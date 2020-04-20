Kinda broken right now but it's close to working.  

The binary code needs to be applied directly to the `source_ir` portion of the memory.  

 * MOV -> 0
   MOV, <REG>, <NUMBER>
 * ADD -> 1
   ADD, <REG>, <REG>
 * SUB -> 2
   MUL, <REG>, <REG>
 * MUL -> 3
   MUL, <REG>, <REG>
 * DIV -> 4
   DIV, <REG>, <REG>
 * PRINT -> 5
   PRINT, <REG>
 * EXIT -> 6

There's 4 registers
 * REG1 -> 0
 * REG2 -> 1
 * REG3 -> 2
 * REG4 -> 3
