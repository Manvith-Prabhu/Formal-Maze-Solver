module fvm_Maze_Solver (
    input logic clk,
    input logic rst,
    output logic [2:0] direction,  // 3-bit output to represent direction 
    output logic [3:0] x_pos,
    output logic [3:0] y_pos,
    output logic found
)

    localparam int P = 5; //number of paths
    localparam int M = 50; //maximum steps per path

//region -------------- Num Paths -----------------------------------------
    logic [6:0] m; // 7 bits is enough to represent a path lenth of 100
    logic [0:P-1] is_loop;
    logic duplicate_path = 0;
    integer n, r;
    logic [5:0] p; // path id

    typedef struct {
        logic [7:0] steps [M-1:0]; // each step is 8 bits (4 bits for x and 4 bits for y)
    } path_t;

    path_t all_paths [0:P-1];

    wire [3:0] x_new =  (direction == 3'b010 && Maze_solver.maze[x_pos-1][y_pos] && ~Maze_solver.visited[x_pos-1][y_pos] && x_pos > 0) ? (x_pos - 1) :
                        (direction == 3'b011 && Maze_solver.maze[x_pos+1][y_pos] && ~Maze_solver.visited[x_pos+1][y_pos] && x_pos < 9) ? (x_pos + 1) :
                        x_pos;
    
    wire [3:0] y_new =  (direction == 3'b000 && Maze_solver.maze[x_pos][y_pos-1] && ~Maze_solver.visited[x_pos][y_pos-1] && y_pos > 0) ? (y_pos - 1) :
                        (direction == 3'b001 && Maze_solver.maze[x_pos][y_pos+1] && ~Maze_solver.visited[x_pos][y_pos+1] && y_pos < 9) ? (y_pos + 1) :
                        y_pos;

    wire found_M1 = (x_new == 4'd9) && (y_new == 4'd9);

    logic equal;
    always_comb begin 
        equal = 0;
        duplicate_path = 0;
        if (p> 0) begin
            for (n = 0; n < P; n = n + 1) begin
                if (n < p) begin
                    equal = 1;
                    for (r = 0; r < M; r = r + 1) begin
                        if (r<m && all_paths[p].steps[r] != all_paths[n].steps[r]) begin
                            equal = 0;
                        end
                    end
                end

                if (found_M1 && equal) begin
                    duplicate_path = 1;
                end
            end
        end
    end

    no_duplicate_path: assume property (
        @(posedge clk) disable iff (rst) 
        ~duplicate_path || direction == 3'b110
    );

    always_ff @(posedge clk) begin
        if (rst) begin
            for (n = 0; n < P; n = n + 1) begin
                for (r = 0; r < M; r = r + 1) begin
                    all_paths[n].steps[r] <= 8'd0;
                end
            end
            m <= 0;
            p <= 0;
        end else if (!found) begin
            if (m < M && (x_new != x_pos || y_new != y_pos)) begin
                all_paths[p].steps[m] <= Maze_solver.cur_pos;
                m <= m + 1;
            end
        end else if (found_M1) begin
            all_paths[p].steps[m] <= Maze_solver.cur_pos;
            p <= p + 1;
            m <= 0;
        end
    end

//endregion ---------------------------------------------------------------


//region ----------------- Best Path --------------------------------------

    find_best_path: cover property (
        @(posedge clk) disable iff (rst) 
        x_pos == 4'd9 && y_pos == 4'd9 
    );

//endregion ---------------------------------------------------------------

endmodule

bind Maze_Solver fvm_Maze_Solver fvm_Maze_Solver(.*);