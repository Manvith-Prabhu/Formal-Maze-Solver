module Maze_solver (
    input logic clk,
    input logic rst,
    output logic [2:0] direction  // 3-bit output to represent direction 
    output logic [3:0] x_pos,
    output logic [3:0] y_pos,
    output logic found
);

    // Maze representation: 1 = path, 0 = wall
    logic [0:9][0:9] maze = '{
        '{1, 0, 0, 0, 0, 0, 0, 0, 0, 1},
        '{1, 0, 1, 1, 1, 1, 1, 0, 1, 0},
        '{1, 1, 1, 0, 0, 0, 1, 0, 0, 1},
        '{0, 0, 1, 1, 0, 1, 1, 1, 0, 1},
        '{1, 0, 0, 1, 0, 0, 1, 0, 1, 0},
        '{1, 0, 1, 1, 1, 1, 1, 1, 1, 0},
        '{1, 0, 1, 0, 0, 0, 0, 0, 1, 1},
        '{0, 0, 1, 0, 0, 0, 0, 1, 0, 1},
        '{0, 0, 1, 0, 0, 1, 1, 1, 0, 1},
        '{0, 1, 1, 1, 1, 1, 0, 1, 1, 1}
    };

    // Position registers
    logic [3:0] x, y;
    logic [7:0] cur_pos; // Current position in the maze

    //Output assignments
    assign x_pos = x;
    assign y_pos = y;
    assign found = ((x == 4'd9) && (y == 4'd9));
    assign cur_pos = {x, y};

    logic [9:0][9:0] visited; // Track visited positions
    always_ff @( posedge clk ) begin 
        if (rst || found) begin
            visited <= '0;
        end else if (!found) begin
            visited[x_pos][y_pos] <= 1'b1; // Mark current position as visited
        end        
    end

    // Direction 
    always_ff @( posedge clk) begin
        if (rst) begin
            x <= 4'd0;
            y <= 4'd0;
        end else if (!found) begin
            case (direction)
                3'b000: if (y>0 && maze[x][y-1] && ~visited[x][y-1]) y <= y - 1; // Up
                3'b001: if (y<9 && maze[x][y+1] && ~visited[x][y+1]) y <= y + 1; // Down
                3'b010: if (x>0 && maze[x-1][y] && ~visited[x-1][y]) x <= x - 1; // Left
                3'b011: if (x<9 && maze[x+1][y] && ~visited[x+1][y]) x <= x + 1; // Right
                default: begin x<=x; y<=y; end // No movement
            endcase
        end
    end
    
endmodule