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

module ata (
           input         CLK,
           input         AS,
           input         RW,
           input [31:0]  A,
           input         WAIT,

           output [1:0] IDECS,
           output        IOR,
           output        IOW,
           output        DTACK,
           output        ACCESS
       );

/* Timing Diagram
                 S0 S1 S2 S3 S4 S5  W  W S6 S7
     __    __    __    __    __    __    __    __    __    __    __    __   
CLK |  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__
     _________________                         _____________________________
AS                    \\\_____________________/
    _______________                            _____________________________
CS                 \__________________________/
    ______________________                     _____________________________
IOR                       \___________________/
    _____________________________        ___________________________________
IOW                              \______/
    _____________________________        ___________________________________
DTACK                            \______/     
    _________________________       ________________________________________
WAIT                         \_____/
        
*/

`ifndef A1200
wire GAYLE_IDE = ({A[31:15]} != {16'h00DA,1'b0});
`else
wire GAYLE_IDE = ({A[31:14]} != {16'h00DA,2'b01});
`endif

reg [7:0] ASDLY = 8'hff;
reg DTACK_INT = 1'b1;

reg IOR_INT = 1'b1;
reg IOW_INT = 1'b1;

always @(posedge CLK or posedge AS) begin

    if (AS == 1'b1) begin

        ASDLY <= 8'hff;

    end else begin

        ASDLY <= {ASDLY[6:0], AS | (GAYLE_IDE)};

    end

end

always @(negedge CLK or posedge AS) begin

    if (AS == 1'b1) begin

        IOR_INT <= 1'b1;
        IOW_INT <= 1'b1;
        DTACK_INT <= 1'b1;

    end else begin

        IOR_INT <= ~RW | ASDLY[0];
        IOW_INT <=  RW | ASDLY[1];
        DTACK_INT <=  ASDLY[1] | ~WAIT;

    end

end

reg [1:0] IDECS_INT;
reg RTC_CS_INT;
reg SPARE_CS_INT;

always @(posedge CLK) begin 

    IDECS_INT <= A[12] ? {GAYLE_IDE, 1'b1} : {1'b1, GAYLE_IDE};

end 

assign IOR = IOR_INT;
assign IOW = IOW_INT;
assign DTACK = DTACK_INT;
assign IDECS = IDECS_INT;
assign ACCESS = GAYLE_IDE;

endmodule
