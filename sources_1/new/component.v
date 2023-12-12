`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/03/2023 01:03:06 PM
// Design Name: 
// Module Name: component
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


module component(
    input clk,  
    input reset,    
    input [3:0] btn,        // btn[0] = up, btn[1] = down
    input game,        // game on
    input video_on,
    input [9:0] x,
    input [9:0] y,
    output graph_on,
    output reg miss_1,  miss_2,   // ball miss
    output reg [11:0] graph_rgb
    );
    
    // maximum x, y values in display area
    parameter X_MAX = 639;
    parameter Y_MAX = 479;
    
    // 60Hz refresh tick
    wire refresh_tick;
    assign refresh_tick = ((y == 481) && (x == 0)) ? 1 : 0; // start of vsync(vertical retrace)

    
    
    // WALLS
    // TOP wall boundaries
    parameter TOP_WALL_T = 64;    
    parameter TOP_WALL_B = 71;    // 8 pixels wide
    // BOTTOM wall boundaries
    parameter BOTTOM_WALL_T = 472;    
    parameter BOTTOM_WALL_B = 479;    // 8 pixels wide
    // MIDDLE LINE
    parameter MID_LINE_T = 316;    
    parameter MID_LINE_B = 327;    // 12 pixels wide
    
    
    // PADDLE
    // paddle horizontal boundaries
    parameter X_PAD_L_1 = 600;
    parameter X_PAD_R_1 = 607;    // 8 pixels wide
    parameter X_PAD_L_2 = 32;
    parameter X_PAD_R_2 = 39;
    
    // paddle vertical boundary signals
    wire [9:0] y_pad_t_1, y_pad_b_1;
    wire [9:0] y_pad_t_2, y_pad_b_2;
    parameter PAD_HEIGHT = 96;  // 96 pixels high
    
    // register to track top boundary and buffer
    reg [9:0] y_pad_reg_1 = 204;      // Paddle starting position
    reg [9:0] y_pad_next_1;
    reg [9:0] y_pad_reg_2 = 204;      // Paddle starting position
    reg [9:0] y_pad_next_2;
    
    // paddle speed
    parameter PAD_SPEED = 3;
    
    
    // BALL
    // square rom boundaries
    parameter BALL_SIZE = 8;
    // ball horizontal boundary signals
    wire [9:0] x_ball_l, x_ball_r;
    // ball vertical boundary signals
    wire [9:0] y_ball_t, y_ball_b;
    // register to track top left position
    reg [9:0] y_ball_reg, x_ball_reg;
    // signals for register buffer
    wire [9:0] y_ball_next, x_ball_next;
    // registers to track ball speed and buffers
    reg [9:0] x_delta_reg, x_delta_next;
    reg [9:0] y_delta_reg, y_delta_next;
    // positive or negative ball SPEED
    parameter BALL_SPEED_POS = 2;    // ball speed positive pixel direction(down, right)
    parameter BALL_SPEED_NEG = -2;   // ball speed negative pixel direction(up, left)
    // round ball from square image
    wire [2:0] rom_addr, rom_col;   // 3-bit rom address and rom column
    reg [7:0] rom_data;             // data at current rom address
    wire rom_bit;                   // signify when rom data is 1 or 0 for ball rgb control
    
    
    // Register Control
    always @(posedge clk or posedge reset)
        if(reset) begin
            y_pad_reg_1 <= 204;
            y_pad_reg_2 <= 204;
            x_ball_reg <= 0;
            y_ball_reg <= 0;
            x_delta_reg <= 10'h002;
            y_delta_reg <= 10'h002;
        end
        else begin
            y_pad_reg_1 <= y_pad_next_1;
            y_pad_reg_2 <= y_pad_next_2;
            x_ball_reg <= x_ball_next;
            y_ball_reg <= y_ball_next;
            x_delta_reg <= x_delta_next;
            y_delta_reg <= y_delta_next;
        end
    
    
    // ball
    always @*
        case(rom_addr)
            3'b000 :    rom_data = 8'b00111100; //   ****  
            3'b001 :    rom_data = 8'b01111110; //  ******
            3'b010 :    rom_data = 8'b11111111; // ********
            3'b011 :    rom_data = 8'b11111111; // ********
            3'b100 :    rom_data = 8'b11111111; // ********
            3'b101 :    rom_data = 8'b11111111; // ********
            3'b110 :    rom_data = 8'b01111110; //  ******
            3'b111 :    rom_data = 8'b00111100; //   ****
        endcase
    
    
    // OBJECT STATUS SIGNALS
    wire t_wall_on, b_wall_on, pad_on, pad_on_2, sq_ball_on, ball_on;
    wire [11:0] wall_rgb, pad_rgb, pad_rgb_2, ball_rgb, bg_rgb;
    wire t_wall_on, b_wall_on, m_line_on, pad_on, pad_on_2, sq_ball_on, ball_on;
    
    // pixel within wall boundaries

    assign t_wall_on = ((TOP_WALL_T <= y) && (y <= TOP_WALL_B)) ? 1 : 0;
    assign b_wall_on = ((BOTTOM_WALL_T <= y) && (y <= BOTTOM_WALL_B)) ? 1 : 0;
    
    assign m_line_on = ((MID_LINE_T <= x) && (x <= MID_LINE_B)) ? 1 : 0;
    assign wall_rgb   = 12'hFFF;    // white walls
    assign pad_rgb    = 12'hFFF;    // blue paddle
    assign pad_rgb_2  = 12'hFFF;  // red paddle
    assign ball_rgb   = 12'hFF0;    // white ball
    assign bg_rgb     = 12'h000;    // black background
    
    
    // paddle 
    assign y_pad_t_1 = y_pad_reg_1;                             // paddle top position
    assign y_pad_b_1 = y_pad_t_1 + PAD_HEIGHT - 1;              // paddle bottom position
    assign y_pad_t_2 = y_pad_reg_2;                             // paddle top position
    assign y_pad_b_2 = y_pad_t_2 + PAD_HEIGHT - 1;              // paddle bottom position
    assign pad_on = (X_PAD_L_1 <= x) && (x <= X_PAD_R_1) &&     // pixel within paddle boundaries
                    (y_pad_t_1 <= y) && (y <= y_pad_b_1);
    assign pad_on_2 = (X_PAD_L_2 <= x) && (x <= X_PAD_R_2) &&     // pixel within paddle boundaries
                    (y_pad_t_2 <= y) && (y <= y_pad_b_2);
       
                    
    // Paddle Control
    always @* begin
        y_pad_next_1 = y_pad_reg_1;     // no move
        y_pad_next_2 = y_pad_reg_2;
        if(refresh_tick)
            if(btn[0] & (y_pad_b_1 < (BOTTOM_WALL_T - 1 - PAD_SPEED)))
            begin
                y_pad_next_1 = y_pad_reg_1 + PAD_SPEED;  // move down L
            end
            else if(btn[1] & (y_pad_t_1 > (TOP_WALL_B - 1 - PAD_SPEED)))
            begin
                y_pad_next_1 = y_pad_reg_1 - PAD_SPEED;  // move up  J
            end
            else if(btn[2] & (y_pad_b_2 < (BOTTOM_WALL_T - 1 - PAD_SPEED)))
            begin
                y_pad_next_2 = y_pad_reg_2 + PAD_SPEED;  // move down D
            end
            else if(btn[3] & (y_pad_t_2 > (TOP_WALL_B - 1 - PAD_SPEED)))
            begin
                y_pad_next_2 = y_pad_reg_2 - PAD_SPEED;  // move up A
            end
    end
    
    
    // rom data square boundaries
    assign x_ball_l = x_ball_reg;
    assign y_ball_t = y_ball_reg;
    assign x_ball_r = x_ball_l + BALL_SIZE - 1;
    assign y_ball_b = y_ball_t + BALL_SIZE - 1;
    // pixel within rom square boundaries
    assign sq_ball_on = (x_ball_l <= x) && (x <= x_ball_r) &&
                        (y_ball_t <= y) && (y <= y_ball_b);
    // map current pixel location to rom addr/col
    assign rom_addr = y[2:0] - y_ball_t[2:0];   // 3-bit address
    assign rom_col = x[2:0] - x_ball_l[2:0];    // 3-bit column index
    assign rom_bit = rom_data[rom_col];         // 1-bit signal rom data by column
    // pixel within round ball
    assign ball_on = sq_ball_on & rom_bit;      // within square boundaries AND rom data bit == 1
 
  
    // new ball position
    assign x_ball_next = (game) ? X_MAX / 2 :
                         (refresh_tick) ? x_ball_reg + x_delta_reg : x_ball_reg;
    assign y_ball_next = (game) ? Y_MAX / 2 :
                         (refresh_tick) ? y_ball_reg + y_delta_reg : y_ball_reg;
    
    // change ball direction after collision
    always @* begin
        miss_1 = 1'b0;
        miss_2 = 1'b0;
        x_delta_next = x_delta_reg;
        y_delta_next = y_delta_reg;
        
        if(game) begin
            x_delta_next = BALL_SPEED_NEG;
            y_delta_next = BALL_SPEED_POS;
        end
        
        else if(y_ball_t < TOP_WALL_B)             // reach top
            y_delta_next = BALL_SPEED_POS;   // move down
        
        else if(y_ball_b > (BOTTOM_WALL_T))         // reach bottom wall
            y_delta_next = BALL_SPEED_NEG;  // move up

        
        else if((X_PAD_L_1 <= x_ball_r) && (x_ball_r <= X_PAD_R_1) &&
                (y_pad_t_1 <= y_ball_b) && (y_ball_t <= y_pad_b_1)) 
                    x_delta_next = BALL_SPEED_NEG;

        else if((X_PAD_R_2 >= x_ball_l) && (x_ball_l >= X_PAD_L_2) &&
                (y_pad_t_2 <= y_ball_b) && (y_ball_t <= y_pad_b_2)) 
                    x_delta_next = BALL_SPEED_POS;

        else if(x_ball_r > X_MAX)  // P1 get score (P2 miss)
            miss_1 = 1'b1;
        else if(x_ball_l < 10) // P2 get score (P1 miss)
            miss_2 = 1'b1;
    end                    
    
    // output status signal for graphics 
    assign graph_on = t_wall_on | b_wall_on | m_line_on | pad_on | pad_on_2 | ball_on;
    
    
    // rgb multiplexing circuit
    always @*
        if(~video_on)
            graph_rgb = 12'h000;      // no value, blank
        else
            if(t_wall_on | b_wall_on | m_line_on)
                graph_rgb = wall_rgb;     // wall color
            else if(pad_on)
                graph_rgb = pad_rgb;      // paddle color
            else if(pad_on_2)
                graph_rgb = pad_rgb_2;      // paddle color
            else if(ball_on)
                graph_rgb = ball_rgb;     // ball color
            else
                graph_rgb = bg_rgb;       // background
       
endmodule
