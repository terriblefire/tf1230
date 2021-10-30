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

module main_top(

           input			RESET,
           output  			HALT,

           input            DISABLE,

           // all clock lines.
           input   			CLK14M,
           input   			CLK100M,
           output   		CLKCPU,
           output  			CLKRAM,

           input [31:0]    	A,
           inout [31:24]   	D,

           //  SDRAM Control
           output			CLKRAME,
           output [12:0]    ARAM,
           output [1:0] 	BA,
           output			CAS,
           output [3:0] 	DQM,
           output			RAMWE,
           output			RAS,
           output			RAMCS,
           output			RAMOE,

           // transfer control lines
           input [1:0] 		SIZ,
           input [2:0] 		FC,
           output[2:0] 		IPL,

           // cache control lines.
           input			CBREQ,
           output			CBACK,
           output			CIIN,

           // 68030 control lines
           input			AS30,
           input			DS30,
           input			RW30,

           output [1:0] 	DS30ACK,
           output			STERM,

           output			BGACK30,
           output			BR30,
           input			BG30,

           // CD32 / 68020 control lines
           output			AS20,
           output			DS20,
           output			RW20,

           output			BR20,
           input			BG20,

           input [1:0] 		DSACK,

           output			IOW,
           output           IOR,

           input			IDEINT,
           input			IDEWAIT,
           output [1:0] 	IDECS,
           output			PUNT,
           output			BERR,

           input            EXP_BR,
           output           EXP_BG,

           output			INT2,
           input			IDELED,
           output			ACTIVE,

           output			RXD,
           output			RXD_EXT,

           input			TXD,
           input			TXD_EXT
       );

reg HIGHZ;
reg BGACK_INT;

reg ram_access;
reg PUNT_INT;
wire CPUSPACE = &FC;
wire FPUOP = CPUSPACE & ({A[19:16]} == {4'b0010});
wire IACK = CPUSPACE & ({A[19:16]} == {4'b1111});
wire ram_decode  = ({A[31:27]} != {5'b0000_1}) & ({A[31:27]} != {5'b0001_0}) ; 

wire GAYLE_IDE;
wire DTACK_IDE;

reg SPEED_D;

clocks CLOCKS(
    .CLK100M ( CLK100M ),
    .CLK14M  ( CLK14M  ),
    .SPEED   ( SPEED_D ),
    .CLKCPU  ( CLKCPU  )
);


arb ARB (
    
    .CLK	    ( CLKCPU    ),
    .CLK100M    ( CLK100M   ),
    .DISABLE    ( DISABLE   ),

    .AS30       ( AS30      ),

    .BR20       ( BR20      ),
    .BG20       ( BG20      ),

    .BG30       ( BG30      ),
    .BR30       ( BR30      ),
    .BGACK30    ( BGACK30   ),

    .EXP_BG     ( EXP_BG    ),
    .EXP_BR     ( EXP_BR    )
    
);


// module to control IDE timings. 
ata ATA (

	.CLK	( CLKCPU	), 
	.AS	    ( AS30      ),
	.RW	    ( RW30	    ),
	.A		( A		    ),
	// IDEWait not connected on TF328.
	.WAIT   ( IDEWAIT   ),  
	
	.IDECS  ( IDECS	    ),
	.IOR	( IOR		),
	.IOW	( IOW		),
	.DTACK  ( DTACK_IDE	),
    .ACCESS ( GAYLE_IDE )
	
);


// produce an internal data strobe
wire GAYLE_INT2;
wire GAYLE_ACCESS;

wire gayle_dout;
   
reg   GAYLE_DS;

gayle GAYLE(

    .CLKCPU ( CLKCPU        ),
    .RESET  ( RESET         ),

    .AS20   ( AS30          ),
    .DS20   ( GAYLE_DS      ),
    .RW     ( RW30          ),

    .A      ( A             ),

    .IDE_INT( IDEINT        ),
    .INT2   ( GAYLE_INT2    ),
    .DIN    ( D[31]         ),

    .DOUT   ( gayle_dout    ),
    .ACCESS ( GAYLE_ACCESS  )

);


wire [7:4] zii_dout;
wire zii_decode = 1'b1;

wire WAIT;


sdram SDRAM (

    .RESET(RESET),

    .CLKCPU (CLKCPU),
    .CLK    (~CLKRAM),
    .CLKRAME(CLKRAME),

    .ACCESS(ram_access),

    .A(A),
    .SIZ(SIZ),

    .AS30(AS30),
    .RW30(RW30),
    .DS30(DS30),

    .CBACK(CBACK),
    .CIIN(CIIN), 
    .CBREQ(CBREQ),

    .STERM(STERM),

    .ARAM(ARAM),
    .BA(BA),

    .CAS(CAS),
    .RAS(RAS),

    .DQM(DQM),

    .RAMWE(RAMWE),

    .WAIT   ( WAIT      ),
    .RAMCS(RAMCS)
    //.RAMOE(RAMOE)
);


reg intcycle_dout = 1'b0;
reg fastcycle_int;
reg FASTCYCLE;

always @(negedge CLKCPU or posedge AS30) begin	

    if (AS30 == 1'b1) begin 
        
        intcycle_dout <= 1'b0;
        fastcycle_int <= 1'b1;
        FASTCYCLE <= 1'b1;

    end else begin 

        intcycle_dout <= ~(GAYLE_ACCESS & zii_decode) & RW30; 
        fastcycle_int <= GAYLE_ACCESS & zii_decode;
        FASTCYCLE <= fastcycle_int;

    end
end

reg AS20_D;
reg DS20_D;

always @(negedge CLK100M or posedge AS30) begin	

    if (AS30 == 1'b1) begin 

        AS20_D <= 1'b1;
        DS20_D <= 1'b1;
        ram_access <= 1'b1;

    end else begin 

        ram_access <= AS30 | ram_decode;
        AS20_D <= AS30 | ~SPEED_D;
        DS20_D <= DS30 | ~SPEED_D;
        GAYLE_DS <= DS30 | GAYLE_ACCESS | AS30;
    
    end 

end

wire PUNT_COMB = GAYLE_ACCESS & ram_access & GAYLE_IDE & zii_decode;

always @(posedge CLK100M) begin 

    BGACK_INT <= (BG30 | ~AS30) & (BGACK_INT | EXP_BR) | EXP_BR;
    HIGHZ <= PUNT_INT & BGACK30;
    PUNT_INT <= PUNT_COMB;
    SPEED_D <= ~AS30 & ram_decode & GAYLE_IDE & GAYLE_ACCESS | ~RESET;

end 

assign PUNT = PUNT_INT ? 1'bz : 1'b0;
assign INT2 = GAYLE_INT2 ? 1'bz : 1'b0;

wire [7:0] data_out;
assign data_out = GAYLE_ACCESS ? 8'bzzzz_zzzz : {gayle_dout,7'b000_0000};
assign data_out = zii_decode ? 8'bzzzz_zzzz : {zii_dout, zii_dout};

assign D[31:24] = (intcycle_dout) ? data_out : 8'bzzzzzzzz;   

assign CLKRAM = CLK100M;
assign DS30ACK = {FASTCYCLE  & DTACK_IDE, 1'b1} & (DSACK) | {2{IACK}};

assign AS20 = HIGHZ ? AS20_D : 1'bz;
assign DS20 = HIGHZ ? DS20_D : 1'bz;
assign RW20 = HIGHZ ? RW30 : 1'bz;

assign HALT = 1'b1;
assign BERR = 1'bz;

// setup the serial port pass through
assign RXD_EXT = TXD;
assign RXD = TXD_EXT ? 1'bz : 1'b0;

assign D[31:24] = 8'bzzzzzzzz;
assign IPL = 3'bzzz;

assign RAMOE = 1'b0;
assign ACTIVE = IDELED ? 1'bz : 1'b0;

endmodule
