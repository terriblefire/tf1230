`timescale 1ns / 1ps
/*
    Copyright (C) 2016-2017, Stephen J. Leary
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


module clocks(
              input      CLK100M,
              input      CLK14M,
              input      SPEED, 
              output     CLKCPU
);

localparam CLOCK_SMOOTHING = 2;
localparam CLOCK_SMOOTH = 10;

reg CLK50MI;
reg [4:0] CLK14M_D;
reg [CLOCK_SMOOTH:0] SPEED_D;

wire can_change = (&CLK14M_D[CLOCK_SMOOTHING:0] == 1'b1) || (|CLK14M_D[CLOCK_SMOOTHING:0] == 1'b0);

always @(posedge CLK100M) begin 

        SPEED_D <= {SPEED_D[CLOCK_SMOOTH-1:0], SPEED};

        if (can_change == 1) begin
            CLK14M_D <= {CLK14M_D[3:0], ~CLK14M};
        end else begin
            CLK14M_D <= {CLK14M_D[3:0], CLK14M_D[0]};
        end

        if (SPEED) begin
            CLK50MI <=  CLK14M_D[2] & (&SPEED_D);
        end else begin 
            CLK50MI <= ~CLK50MI;
        end 

end 

assign CLKCPU = CLK50MI;

endmodule
