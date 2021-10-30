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

module fastata (
           input         CLK,
           input         RESET,
           input         TS,
           input         RW,
           input [31:0]  A,
           input         IDEWAIT,

           output [1:0]  IDECS,
           output        IOR,
           output        IOW,
           output        TA,
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

parameter IDE_DOUBLER = 0; 

`ifndef A1200
wire IDE_ACCESS = ({A[31:15]} != {16'h00DA,1'b0});
`else
wire IDE_ACCESS = ({A[31:14]} != {16'h00DA,2'b01});
`endif

parameter PIO_MODE0_T1   =  2;             // 70ns
parameter PIO_MODE0_T2   =  5;             // 290ns
parameter PIO_MODE0_T4   =  1;             // 30ns
parameter PIO_MODE0_Teoc =  1;             // 240ns

reg [7:0] T = 0;

localparam T0 = 'd0;
localparam T1 = PIO_MODE0_T1;
localparam T2 = PIO_MODE0_T1 + PIO_MODE0_T2;
localparam T4 = PIO_MODE0_T1 + PIO_MODE0_T2 + PIO_MODE0_T4;
localparam TEOC = PIO_MODE0_T1 + PIO_MODE0_T2 + PIO_MODE0_T4 + PIO_MODE0_Teoc;

reg TS_HOLD = 1'b1;
reg IOR_INT = 1'b1;
reg IOW_INT = 1'b1;
reg TA_INT  = 1'b1;

wire START = TS | IDE_ACCESS;

reg t1_done;
reg t2_done;
reg t4_done;
reg te_done;

always @(posedge CLK or negedge RESET) begin

    if (RESET == 1'b0) begin 
        
        T <= 0;
        TS_HOLD <= 1'b1;

        t1_done <= 1'b1;
        t2_done <= 1'b1;
        t4_done <= 1'b1;
        te_done <= 1'b1;

    end else begin 

        if (|T) begin
            T <= T + 'd1;
            if ((START|t4_done) == 1'b0) begin 
                TS_HOLD <= 1'b0;
            end
        end
        
        // current cycle or last cycle is in progress. 
        case (T)

            T0: begin // 

                if ((START & TS_HOLD) == 1'b0) begin 
                    T <= 'd1;
                    TS_HOLD <= 1'b1;
                    t1_done <= 1'b1;
                    t2_done <= 1'b1;
                    t4_done <= 1'b1;
                    te_done <= 1'b1;
                end 

            end

            T1: t1_done <= 1'b0;
            T2: t2_done <= 1'b0;
            T4: t4_done <= 1'b0;
            TEOC: begin 
                te_done <= 1'b0;
                T <= T0;
            end

        endcase

    end

end


reg [1:0] IDECS_INT;
reg t4_done_d;
reg t4_done_d2;

always @(posedge CLK or negedge RESET) begin 

     if (RESET == 1'b0) begin 

        IDECS_INT <= 2'b11;
        IOR_INT <= 1'b1;
        IOW_INT <= 1'b1;
        TA_INT  <= 1'b1;
        t4_done_d <= 1'b1;
        t4_done_d2 <= 1'b1;
        
    end else begin 

        IDECS_INT <= A[12] ? {IDE_ACCESS, 1'b1} : {1'b1, IDE_ACCESS};
        IOR_INT <= (~RW | t1_done | ~t2_done);
        IOW_INT <= ( RW | t1_done | ~t2_done);
        TA_INT <= t4_done | ~t4_done_d2;
        t4_done_d <= t4_done;
        t4_done_d2 <= t4_done_d;

    end

end 

assign TA  = TA_INT;
assign IOR = IOR_INT;
assign IOW = IOW_INT;
assign IDECS = IDECS_INT;
assign ACCESS = IDE_ACCESS;

endmodule
