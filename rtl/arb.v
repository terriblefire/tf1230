`timescale 1ns / 1ps
/*
    Copyright (C) 2019, Stephen J. Leary
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

module arb(

    input           CLK,
    input           CLK100M, 
    input           DISABLE, 

    input           AS30,

    // 020 ARB
    output			BR20,
    input			BG20,

    // 030 ARB
    output	reg		BR30,
    output	reg		BGACK30,
    input			BG30,

    // AKIKO ARB
    input           EXP_BR,
    output          EXP_BG

);

reg BGACK_INT;

always @(posedge CLK) begin 

    BGACK_INT <= ((BG30 | ~AS30) & (BGACK_INT | EXP_BR) | EXP_BR) & ~DISABLE;

end

always @(posedge CLK100M) begin 

    BR30 <= EXP_BR & ~DISABLE;
    BGACK30 <= BGACK_INT;

end

assign BR20     = DISABLE;
assign EXP_BG   = DISABLE ? 1'bz : BGACK_INT;

endmodule
