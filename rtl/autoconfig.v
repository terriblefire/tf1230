`timescale 1ns / 1ps
/*
    Copyright (C) 2018-2021, Stephen J. Leary
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


module autoconfig(

           input    RESET,
           input 	AS20,
           input 	RW20,
           input 	DS20,

           input [31:0] A,

           output [7:4] DOUT,

           output  ACCESS,
           output  DECODE

       );

reg config_out = 'd0;
reg configured = 'd0;
reg shutup = 'd0;
reg [7:4] data_out = 'd0;

// 0xE80000
wire Z2_ACCESS = ({A[31:16]} != {16'h00E8}) | (&config_out);
wire Z2_WRITE = (Z2_ACCESS | RW20);
wire [5:0] zaddr = {A[6:1]};

always @(posedge AS20 or negedge RESET) begin

    if (RESET == 1'b0) begin

        config_out <= 'd0;

    end else begin

        config_out <= configured | shutup;

    end

end

always @(negedge DS20 or negedge RESET) begin

    if (RESET == 1'b0) begin

        configured <= 'd0;
        shutup <= 'd0;
        data_out[7:4] <= 4'hf;

    end else begin

            if (Z2_WRITE == 1'b0) begin

                    case (zaddr)
                    'h22: begin //configure logic
                        configured <= 1'b1;
                    end
                    'h26: begin // shutup logic
                        shutup <= 1'b1;
                    end
                endcase

            end

            // autoconfig ROMs
            case (zaddr)
                'h00: data_out[7:4] <= 4'ha;
                'h01: data_out[7:4] <= 4'h2;
                'h03: data_out[7:4] <= 4'hc;
                'h04: data_out[7:4] <= 4'h4;
                'h08: data_out[7:4] <= 4'he;
                'h09: data_out[7:4] <= 4'hc;
                'h0a: data_out[7:4] <= 4'h2;
                'h0b: data_out[7:4] <= 4'h7;
                'h11: data_out[7:4] <= 4'he;
                'h12: data_out[7:4] <= 4'hb;
                'h13: data_out[7:4] <= 4'h5;
                default: data_out[7:4] <= 4'hf;
            endcase
            
    end
end

// decode the base addresses
// these are hardcoded to the address they always get assigned to.
assign DECODE = ({A[31:26]} != {6'b0100_00}) | shutup;

assign ACCESS = Z2_ACCESS;
assign DOUT = data_out;

endmodule
