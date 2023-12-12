`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/03/2023 01:04:12 PM
// Design Name: 
// Module Name: text
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module text(
    input clk,
    input [1:0] ball,
    input [3:0] p1_dig0, p1_dig1, p2_dig0, p2_dig1,
    input [9:0] x, y,
    input [1:0] goal,
    output [2:0] text_on,
    output reg [11:0] text_rgb
    );
    
    // signal declaration
    wire [10:0] rom_addr;
    reg [6:0] char_addr, char_addr_s, char_addr_r, char_addr_g;
    reg [3:0] row_addr;
    wire [3:0] row_addr_s, row_addr_r, row_addr_g;
    reg [2:0] bit_addr;
    wire [2:0] bit_addr_s,  bit_addr_r, bit_addr_g;
    wire [7:0] ascii_word;
    wire ascii_bit, score_on, rule_on, goal_on;
    wire [7:0] rule_rom_addr;

    ascii_rom ascii_unit(.clk(clk), .addr(rom_addr), .data(ascii_word));
   

//---------------- score display ------------------------
    assign score_on = (y >= 32) && (y < 64) && (x[9:4] < 64);
    
    assign row_addr_s = y[4:1];
    assign bit_addr_s = x[3:1];
    
    always @*
    case(x[9:4])
        // Player 1 score
        6'h01 : char_addr_s = 7'h50;     // P
        6'h02 : char_addr_s = 7'h31;     // 1
        6'h03 : char_addr_s = 7'h3A;     // :
        6'h04 : char_addr_s = {3'b011, p1_dig1};    // Player 1 tens digit
        6'h05 : char_addr_s = {3'b011, p1_dig0};    // Player 1 ones digit
        6'h11 : char_addr_s = 7'h53;     // S
        6'h12 : char_addr_s = 7'h43;     // C
        6'h13 : char_addr_s = 7'h4F;     // O
        6'h14 : char_addr_s = 7'h52;     // R
        6'h15 : char_addr_s = 7'h45;     // E
        6'h22 : char_addr_s = 7'h50;     // P
        6'h23 : char_addr_s = 7'h32;     // 2
        6'h24 : char_addr_s = 7'h3A;     // :
        6'h25 : char_addr_s = {3'b011, p2_dig1};    // Player 2 tens digit
        6'h26 : char_addr_s = {3'b011, p2_dig0};   // Player 2 ones digit
        default : char_addr_s = 7'h20;
    endcase

    
    //------------------------- how to play display -------------------------

    assign rule_on = (x[9:7] == 2) && (y[9:6] == 2);
    assign row_addr_r = y[3:0];
    assign bit_addr_r = x[2:0];
    assign rule_rom_addr = {y[5:4], x[6:3]};
    always @*
        case(rule_rom_addr)
            6'h00 : char_addr_r = 7'h52;    // R
            6'h01 : char_addr_r = 7'h55;    // U
            6'h02 : char_addr_r = 7'h4c;    // L
            6'h03 : char_addr_r = 7'h45;    // E
            6'h04 : char_addr_r = 7'h3A;    // :
            6'h05 : char_addr_r = 7'h00;    //
            6'h06 : char_addr_r = 7'h00;    //
            6'h07 : char_addr_r = 7'h00;    //
            6'h08 : char_addr_r = 7'h00;    //
            6'h09 : char_addr_r = 7'h00;    //
            6'h0A : char_addr_r = 7'h00;    //
            6'h0B : char_addr_r = 7'h00;    //
            6'h0C : char_addr_r = 7'h00;    //
            6'h0D : char_addr_r = 7'h00;    //
            6'h0E : char_addr_r = 7'h00;    //
            6'h0F : char_addr_r = 7'h00;    //

            6'h10 : char_addr_r = 7'h50;    // P
            6'h11 : char_addr_r = 7'h31;    // 1
            6'h12 : char_addr_r = 7'h20;    // 
            6'h13 : char_addr_r = 7'h50;    // P
            6'h14 : char_addr_r = 7'h52;    // R
            6'h15 : char_addr_r = 7'h45;    // E
            6'h16 : char_addr_r = 7'h53;    // S
            6'h17 : char_addr_r = 7'h53;    // S
            6'h18 : char_addr_r = 7'h20;    // 
            6'h19 : char_addr_r = 7'h41;    // A
            6'h1A : char_addr_r = 7'h20;    // 
            6'h1B : char_addr_r = 7'h41;    // A
            6'h1C : char_addr_r = 7'h4E;    // N
            6'h1D : char_addr_r = 7'h44;    // D
            6'h1E : char_addr_r = 7'h20;    // 
            6'h1F : char_addr_r = 7'h44;    // D

            6'h20 : char_addr_r = 7'h50;    // P
            6'h21 : char_addr_r = 7'h32;    // 1
            6'h22 : char_addr_r = 7'h20;    // 
            6'h23 : char_addr_r = 7'h50;    // P
            6'h24 : char_addr_r = 7'h52;    // R
            6'h25 : char_addr_r = 7'h45;    // E
            6'h26 : char_addr_r = 7'h53;    // S
            6'h27 : char_addr_r = 7'h53;    // S
            6'h28 : char_addr_r = 7'h20;    // 
            6'h29 : char_addr_r = 7'h4A;    // J
            6'h2A : char_addr_r = 7'h20;    // 
            6'h2B : char_addr_r = 7'h41;    // A
            6'h2C : char_addr_r = 7'h4E;    // N
            6'h2D : char_addr_r = 7'h44;    // D
            6'h2E : char_addr_r = 7'h20;    // 
            6'h2F : char_addr_r = 7'h4C;    // L

            6'h30 : char_addr_r = 7'h54;    // T
            6'h31 : char_addr_r = 7'h4F;    // O
            6'h32 : char_addr_r = 7'h00;    // 
            6'h33 : char_addr_r = 7'h4D;    // M
            6'h34 : char_addr_r = 7'h4F;    // O
            6'h35 : char_addr_r = 7'h56;    // V
            6'h36 : char_addr_r = 7'h45;    // E
            6'h37 : char_addr_r = 7'h00;    // 
            6'h38 : char_addr_r = 7'h55;    // U
            6'h39 : char_addr_r = 7'h50;    // P
            6'h3A : char_addr_r = 7'h2c;    // ,
            6'h3B : char_addr_r = 7'h20;    // 
            6'h3C : char_addr_r = 7'h44;    // D
            6'h3D : char_addr_r = 7'h4F;    // O
            6'h3E : char_addr_r = 7'h57;    // W
            6'h3F : char_addr_r = 7'h4E;    // N
        endcase
        
    // ------------------ goal display ----------------------------
    
    assign goal_on = (y[9:6] == 3) && (6 <= x[9:5]) && (x[9:5] <= 13);
    assign row_addr_g = y[5:2];
    assign bit_addr_g = x[4:2];
    always @*
        case(x[8:5])
            4'h6 : char_addr_g = 7'h50;     // P
            4'h7 : begin
                if(goal == 2'b01)
                    char_addr_g = 7'h31; // 1 Win
                else
                    char_addr_g = 7'h32; // 2 Win
            end
            4'h8 : char_addr_g = 7'h20;     // space
            4'h9 : char_addr_g = 7'h47;     // G
            4'hA : char_addr_g = 7'h4F;     // O
            4'hB : char_addr_g = 7'h41;     // A
            4'hC : char_addr_g = 7'h4C;     // L
            4'hD : char_addr_g = 7'h21;     // !
        endcase
    // mux for ascii ROM addresses and rgb
    always @* begin
        text_rgb = 12'h0;     
        
        if(score_on) begin
            char_addr = char_addr_s;
            row_addr = row_addr_s;
            bit_addr = bit_addr_s;
            if(ascii_bit)
                text_rgb = 12'hFF0; 
        end
        
        else if(rule_on) begin
            char_addr = char_addr_r;
            row_addr = row_addr_r;
            bit_addr = bit_addr_r;
            if(ascii_bit)
                text_rgb = 12'hFFF; 
        end
        
        else begin // goal
            char_addr = char_addr_g;
            row_addr = row_addr_g;
            bit_addr = bit_addr_g;
            if(ascii_bit)
                text_rgb = 12'hFFF; 
        end        
    end
    
    assign text_on = {score_on, rule_on, goal_on};
    
    // ascii ROM interface
    assign rom_addr = {char_addr, row_addr};
    assign ascii_bit = ascii_word[~bit_addr];
      
endmodule
