`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2023 09:48:17 AM
// Design Name: 
// Module Name: uart
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


module uart(
    input clk,
    input RsRx,
    input [9:0] x,
    input [9:0] y,
    output RsTx,
    output data_out,
    output reg [7:0] led,
    output reg Abtn,
    output reg Dbtn,
    output reg Jbtn,
    output reg Lbtn
    );

    reg en, last_rec;
    reg [7:0] data_out;
    wire [7:0] data_out;
    wire sent, received, baud;
    wire refresh_tick;
    assign refresh_tick = ((y == 481) && (x == 0)) ? 1 : 0; // start of vsync(vertical retrace)
    parameter TIMEOUT_THRESHOLD = 10000000;
    integer key_timeout_count;  // Counter to track the time elapsed since last 'a' key press
    
    baudrate_gen baudrate_gen(clk, baud);
    uart_rx receiver(baud,x,y, RsRx, received, data_out);
    uart_tx transmitter(baud,x,y, data_out, en, sent, RsTx);
    
    always @(posedge baud) begin
        if (en) en = 0;
        if (~last_rec & received) begin
            data_out = data_out;
            if (data_out <= 8'h7A && data_out >= 8'h41) begin
                en = 1;
            end
        end
        else begin
            data_out = 8'h00;
        end
        last_rec = received;

    end
    always @(posedge clk)begin
        if(data_out == 8'h61 || data_out == 8'h41) begin
              key_timeout_count <= 0;
              Abtn = 1;// a , A
              Dbtn = 0;
              Jbtn = 0;
              Lbtn = 0;
        end
        else if (data_out == 8'h64 || data_out == 8'h44) begin
              key_timeout_count <= 0;
              Abtn = 0;
              Dbtn = 1; // d , D
              Jbtn = 0;
              Lbtn = 0;
        end
        else if(data_out == 8'h6A || data_out == 8'h4A) begin
              Abtn = 0;
              Dbtn = 0;
              Jbtn = 1;// j , J
              Lbtn = 0;
        end
        else if (data_out == 8'h6C || data_out == 8'h4C) begin
              Abtn = 0;
              Dbtn = 0;
              Jbtn = 0;
              Lbtn = 1;  // l , L
        end
        else begin
            if (key_timeout_count < TIMEOUT_THRESHOLD) begin
                        key_timeout_count <= key_timeout_count + 1;
                        if (key_timeout_count >= TIMEOUT_THRESHOLD) begin
                            Abtn = 0;  // Set btn 0 if timeout duration is exceeded
                            Dbtn = 0;
                            Jbtn = 0;
                            Lbtn = 0;
                            key_timeout_count <= 0;
                        
                        end
             end
             else begin
                            Abtn = 0;  // Set btn 0 if timeout duration is exceeded
                            Dbtn = 0;
                            Jbtn = 0;
                            Lbtn = 0;
                            key_timeout_count <= 0;
            end
        end
            
    end
endmodule
