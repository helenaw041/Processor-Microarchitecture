// PROGRAM 1B
// Recursive vector reduction (recursive version of PROGRAM 1)
// Use R2 for sum; use R1 for idx; use R8 for remaining count
0: instruction = 32'h15080008; // ADDI R8, R8, 8; 
4: instruction = 32'h2fe00002; // JAL FUNC: 2
8: instruction = 32'h28000000; // HALT
12: instruction = 32'h00000000; // NOP

16: instruction = 32'h25000004; // BNEZ R8, 4  FUNC: 
20: instruction = 32'h33E00000;  // RET

24: instruction = 32'h1BDFFFFF; // SD R31, -1(R30)  RECURSE: 
28: instruction = 32'h17DEFFFF; // ADDI R30, R30, -1
32: instruction = 32'h1BC1FFFF; // SD R1, -1(R30)  
36: instruction = 32'h17DEFFFF; // ADDI R30, R30, -1

40: instruction = 32'h14210001; // ADDI R1, R1, 1
44: instruction = 32'h1508FFFF; // ADDI R8, R8, -1

48: instruction = 32'h2ffFFFF7; // JAL FUNC: -9

52: instruction = 32'h13C10000; // LD R1, 0(R30)
56: instruction = 32'h17DE0001; // ADDI R30, R30, 1
60: instruction = 32'h13DF0000; // LD R31, 0(R30)
64: instruction = 32'h17DE0001; // ADDI R30, R30, 1

68: instruction = 32'h10200000; // LD R0, 0(R1)
72: instruction = 32'h04401000; // ADD R2, R2, R0
76: instruction = 32'h33E00000; // RET