`timescale 1ns/1ns

/*
 * Instantiate the 7 modules in the processor:
 *   insMem, decode, regFile, execute, dataMem, branchPC, pc
 * Connect up the ports using  wires and glue logic as needed.
 */

module processor (
   input CLK_pi,
   input CPU_RESET_pi
);

   wire [31:0] pc, instruction;
   insMem myInsMem ( // returns instruction at PC address
      .pc_pi(pc),
      .instruction_po(instruction)
   );

   // wire [31:0] instr_pi;
   wire [5:0] opCode;
   wire [4:0] rs, rt;
   wire [31:0] offset;
   wire [6:0] control; // changed
   wire [4:0] destReg;
   wire writeEnable, isHalt;
   decode myDecode (
      .instr_pi(instruction),
      .opCode_po(opCode), 
      .rs_po(rs),
      .rt_po(rt),
      .offset_po(offset),
      .control_po(control),
      .destReg_po(destReg),
      .writeEnable_po(writeEnable),
      .isHalt_po(isHalt)
   );
   
   wire [31:0] op1, op2;
   wire [31:0] pc_plus_4 = pc + 4; // PC + 4 for JAL return address
   regFile myRegFile (
      .clk_pi(CLK_pi),
      .reset_pi(CPU_RESET_pi), 
      .reg1_pi(rs), 
      .reg2_pi(rt), 
      .destReg_pi(destReg), // decode module determined appropriate reg
      .we_pi(writeEnable), 
      .writeData_pi(control[5] ? pc_plus_4 : (control[2] ? loadData : aluResult)), 

      .operand1_po(op1),
      .operand2_po(op2)
   );

   wire [31:0] aluResult;
   execute myExecute (
      .op1_pi(op1), 
      .op2_pi(op2), 
      .aluFunc_pi(opCode),
      .offset_pi(offset),
      .aluResult_po(aluResult)
   );

   wire [31:0] loadData;
   dataMem myDataMem (
      .clk_pi(CLK_pi),
      .reset_pi(CPU_RESET_pi), 
      .store_pi(control[3]),  
      .address_pi(aluResult),
      .storeData_pi(op2), 
      .loadData_po(loadData)
   );

   wire isTakenBranch;
   wire [31:0] targetPC;
   branchPC myBranchPC (
      .currentPC_pi(pc), 
      .branchCondTrue_pi(((|control[6:5])) | aluResult[0]), // new: Branching must occur if we don't want  PC+4 (see pc.v)
      .isBranch_pi(|control[6:4]), // new
      .branchOffset_pi(offset),

      .isTakenBranch_po(isTakenBranch), 
      .targetPC_po(targetPC)
   );

   PC myPC (
      .clk_pi(CLK_pi),
      .reset_pi(CPU_RESET_pi),
      .halt_pi(isHalt),
      .isTakenBranch_pi(isTakenBranch), 
      .targetPC_pi(control[6] ? op1 : targetPC), // new 

      .pc_po(pc) // curr_pc becomes next_pc on rising clock edge so it's ok to wire together
   );

endmodule