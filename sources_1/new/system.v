`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/03/2023 01:05:01 PM
// Design Name: 
// Module Name: system
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


module system(
    input clk,              // 100MHz
    input reset,            // btnR
    input [1:0] btn,        // btnD, btnU
    input wire RsRx, //uart
    output hsync,           // to VGA Connector
    output vsync,           // to VGA Connector
    output [11:0] rgb,       // to DAC, to VGA Connector
    output wire RsTx, //uart
    output [7:0] led
    ); 
    
    wire [3:0] allbtn;

    //game state
    parameter newgame = 2'b00;
    parameter play    = 2'b01;
    parameter newball = 2'b10;
        
    reg [1:0] state_reg, state_next;
    wire [9:0] w_x, w_y;
    wire w_vid_on, w_p_tick, graph_on, miss_1, miss_2;
    wire [2:0] text_on;
    wire [11:0] graph_rgb, text_rgb;
    reg [11:0] rgb_reg, rgb_next;
    wire [3:0] p1_dig0, p1_dig1, p2_dig0, p2_dig1;
    reg game, get_score_1, clr_1, get_score_2, clr_2, timer_start;
    wire timer_tick, timer_up;
    reg [1:0] ball_reg, ball_next;
    reg [1:0] goal;
    wire dataout;
    
    // Module Instantiations
    vga vga(
        .clk_100MHz(clk),
        .reset(reset),
        .video_on(w_vid_on),
        .hsync(hsync),
        .vsync(vsync),
        .p_tick(w_p_tick),
        .x(w_x),
        .y(w_y));
    
    text display_text(
        .clk(clk),
        .x(w_x),
        .y(w_y),
        .p1_dig0(p1_dig0),
        .p1_dig1(p1_dig1),
        .p2_dig0(p2_dig0),
        .p2_dig1(p2_dig1),
        .ball(ball_reg),
        .text_on(text_on),
        .text_rgb(text_rgb),
        .goal(goal));
        
    component display_game(
        .clk(clk),
        .reset(reset),
        .btn(allbtn),
        .game(game),
        .video_on(w_vid_on),
        .x(w_x),
        .y(w_y),
        .miss_1(miss_1),
        .miss_2(miss_2),
        .graph_on(graph_on),
        .graph_rgb(graph_rgb));
    
    // 60 Hz tick when screen is refreshed
    assign timer_tick = (w_x == 0) && (w_y == 0);
    timer timer(
        .clk(clk),
        .reset(reset),
        .timer_tick(timer_tick),
        .timer_start(timer_start),
        .timer_up(timer_up));
    
    score_counter score_p1(
        .clk(clk),
        .reset(reset),
        .up(get_score_1),
        .clr(clr_1),
        .dig0(p1_dig0),
        .dig1(p1_dig1));
    
    score_counter score_p2(
        .clk(clk),
        .reset(reset),
        .up(get_score_2),
        .clr(clr_2),
        .dig0(p2_dig0),
        .dig1(p2_dig1));
        
    uart uart(.clk(clk), .RsRx(RsRx),
        .x(w_x), .y(w_y),
        .RsTx(RsTx),
        .dataout(dataout),
        .led(led),
        .Abtn(allbtn[3]),
        .Dbtn(allbtn[2]),
        .Jbtn(allbtn[1]),
        .Lbtn(allbtn[0]));

    // state register
    always @(posedge clk or posedge reset)
        if(reset) begin
            state_reg <= newgame;
            ball_reg <= 0;
            rgb_reg <= 0;
        end
    
        else begin
            state_reg <= state_next;
            ball_reg <= ball_next;
            if(w_p_tick)
                rgb_reg <= rgb_next;
        end

    // next state
    always @* begin
        game = 1'b1;
        timer_start = 1'b0;
        get_score_1 = 1'b0;
        clr_1 = 1'b0;
        get_score_2 = 1'b0;
        clr_2 = 1'b0;
        state_next = state_reg;
        ball_next = ball_reg;
        
        case(state_reg)
            newgame: begin
                ball_next = 2'b01;      
                clr_1 = 1'b1;               
                clr_2 = 1'b1;
                
                if(allbtn != 4'b0000) begin      // button pressed
                    state_next = play;
                    ball_next = ball_reg - 1;    
                end
            end
            
            play: begin
                game = 1'b0;  // screen still on
                
                if(miss_2) begin // P2 get score (P1 miss)
                    goal = 2'b10;
                    state_next = newball;
                    
                    timer_start = 1'b1;     // 2 sec 
                    ball_next = ball_reg - 1;
                    get_score_2 = 1'b1;
                end
                
                else if(miss_1) begin // P1 get score (P2 miss)
                    goal = 2'b01;
                    state_next = newball;
                    
                    timer_start = 1'b1;     // 2 sec 
                    ball_next = ball_reg - 1;
                    get_score_1 = 1'b1;
                end
            end
            
            newball: // wait for 2 sec and until button pressed
                if(timer_up && (allbtn != 4'b0000))
                    state_next = play;

        endcase           
    end
    
    // rgb display
    always @*
        if(~w_vid_on)
            rgb_next = 12'h000; 
        
        else
            if(text_on[2] || ((state_reg == newgame) && text_on[1]) || ((state_reg == newball) && text_on[0]))
                rgb_next = text_rgb;    //text
            
            else if(graph_on)
                rgb_next = graph_rgb;   //component
                
            else
                rgb_next = 12'h000;     //background
    
    assign rgb = rgb_reg;

   
    
endmodule

