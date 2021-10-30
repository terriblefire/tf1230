/*
    Copyright (C) 2013-2021, Stephen J. Leary
    All rights reserved.
    
    This file is part of  TF330/TF120 (Terrible Fire 030 Accelerator).
 
	Attribution-NoDerivs 3.0 Unported

		CREATIVE COMMONS CORPORATION IS NOT A LAW FIRM AND DOES NOT PROVIDE
		LEGAL SERVICES. DISTRIBUTION OF THIS LICENSE DOES NOT CREATE AN
		ATTORNEY-CLIENT RELATIONSHIP. CREATIVE COMMONS PROVIDES THIS
		INFORMATION ON AN "AS-IS" BASIS. CREATIVE COMMONS MAKES NO WARRANTIES
		REGARDING THE INFORMATION PROVIDED, AND DISCLAIMS LIABILITY FOR
		DAMAGES RESULTING FROM ITS USE.

*/

localparam RASCAS_DELAY   = 3'd2;   // tRCD=20ns -> 2 cycles@100MHz
localparam BURST_LENGTH   = 3'b000; // 000=1, 001=2, 010=4, 011=8, 111 = continuous.
localparam ACCESS_TYPE    = 1'b0;   // 0=sequential, 1=interleaved
localparam CAS_LATENCY    = 3'd2;   // 2/3 allowed
localparam OP_MODE        = 2'b00;  // only 00 (standard operation) allowed
localparam NO_WRITE_BURST = 1'b1;   // 0= write burst enabled, 1=only single access write
localparam WRITE_BURST 	  = 1'b0;   // 0= write burst enabled, 1=only single access write
localparam RFC_DELAY      = 4'd6;   // tRFC=66ns -> 6 cycles@100MHz
localparam RP_DELAY 	  = 'd4;

// all possible commands
localparam CMD_INHIBIT         = 4'b1111;
localparam CMD_NOP             = 4'b0111;
localparam CMD_ACTIVE          = 4'b0011;
localparam CMD_READ            = 4'b0101;
localparam CMD_WRITE           = 4'b0100;
localparam CMD_BURST_TERMINATE = 4'b0110;
localparam CMD_PRECHARGE       = 4'b0010;
localparam CMD_AUTO_REFRESH    = 4'b0001;
localparam CMD_LOAD_MODE       = 4'b0000;

// ========================================================
// Convert cmd into ascii name
// ========================================================
function [(12*8)-1:0]  cmd_name;
input [3:0] cmd;
begin
   cmd_name = 
   		   cmd ==  CMD_INHIBIT 			? "CMD_INHIBIT " :
		   cmd ==  CMD_NOP 				? "CMD_NOP     " : 
		   cmd ==  CMD_ACTIVE 			? "CMD_ACTIVE  " : 
		   cmd ==  CMD_READ 			? "CMD_READ    " : 
		   cmd ==  CMD_WRITE 			? "CMD_WRITE   " : 
		   cmd ==  CMD_BURST_TERMINATE 	? "CMD_BRSTTERM" :
		   cmd ==  CMD_PRECHARGE 		? "CMD_PRECHRGE" :
		   cmd ==  CMD_AUTO_REFRESH 	? "CMD_AREFRESH" :
		   cmd ==  CMD_LOAD_MODE        ? "CMD_LOAD_MDE" :
                                          "UNKNOWN     ";
end
endfunction
