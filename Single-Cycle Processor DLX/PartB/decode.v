`timescale 1ns/1ns
     
`define NOP    6'd0
`define ADD    6'd1
`define ADDI   6'd5 
`define LOAD   6'd4 
`define STORE  6'd6  
`define BNEZ   6'd9  
`define HALT   6'd10 
`define JAL    6'd11 // NEW
`define RET    6'd12  // NEW

module decode(
 input wire [31:0]  instr_pi,
 output wire [5:0]  opCode_po,
 output wire [4:0]  rs_po,
 output wire [4:0]  rt_po,
 output wire [31:0] offset_po,
 output wire [6:0]  control_po, // NEW
 output wire [4:0]  destReg_po,
 output wire 	    writeEnable_po,
 output wire 	    isHalt_po
 );

wire ALU2op, ALU1op, Load, Store, Branch, Jump, Return;
wire [4:0] rd;
   

   assign opCode_po = instr_pi[31:26];  
   assign rs_po = instr_pi[25:21];  
   assign rt_po = instr_pi[20:16];
   assign rd = instr_pi[15:11];

   
   assign ALU2op = (opCode_po == `ADD);
   assign ALU1op = (opCode_po == `ADDI);
   assign Load =  (opCode_po == `LOAD);
   assign Store = (opCode_po == `STORE);
   assign Branch  =  (opCode_po == `BNEZ);
   assign isHalt_po = (opCode_po == `HALT);
   assign Jump = (opCode_po == `JAL); // added
   assign Return = (opCode_po == `RET); // added

   assign control_po = {Return, Jump, Branch, Store, Load, ALU1op, ALU2op};  // modifyied
   assign offset_po = control_po[5] ?  {{10{instr_pi[19]}}, instr_pi[19:0], 2'b00} : // EXT and << 2bits
                              {{16{instr_pi[15]}}, instr_pi[15:0]}; // EXT
   assign destReg_po = control_po[5] ? rs_po : (control_po[0] ? rd : rt_po); // modifyied
   assign writeEnable_po = control_po[5] | (|control_po[2:0]);

endmodule