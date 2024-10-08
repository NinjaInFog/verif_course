module kernel_filter #(
    parameter KERNEL_SIZE = 3,
    // parameter DATA_SIZE_X = 8,
    // parameter DATA_SIZE_Y = 256,
    parameter DATA_SIZE   = 8
) 
(
    input  logic [KERNEL_SEL-1:0 ]      i_config_select,
    input  logic                        i_clk,
    input  logic                        i_nrst,

    input  logic                        i_valid,
    input  logic [DATA_SIZE-1:0]        i_data [KERNEL_SIZE-1:0] [KERNEL_SIZE-1:0],
    output logic                        o_ready,

    output logic [DATA_SIZE-1:0]        o_data
);

localparam KERNEL_SIZE = 3;
// localparam DATA_SIZE_MAX = $clog2((DATA_SIZE_Y > DATA_SIZE_X) ? DATA_SIZE_Y : DATA_SIZE_X);
// localparam DATA_SIZE_MIN = $clog2((DATA_SIZE_Y > DATA_SIZE_X) ? DATA_SIZE_X : DATA_SIZE_Y);
localparam KERNEL_BITS = (i_config_select == 3) ? 2 : (i_config_select == 2) ? 3 : (i_config_select == 1) ? 2 : 0;

logic signed [DATA_SIZE-1:0]     w_window [KERNEL_SIZE-1:0][KERNEL_SIZE-1:0];
logic signed [DATA_SIZE_MIN+3-1:0] sum_temp [(KERNEL_SIZE**2)-1:0];

logic mult_done;

// logic fall_edge_det;
// logic r_valid;
logic r_data;


logic signed [DATA_SIZE+1-1:0] temp_logic [KERNEL_SIZE-1:0][KERNEL_SIZE-1:0];
logic signed [DATA_SIZE+1-1:0] window_1 [KERNEL_SIZE-1:0][KERNEL_SIZE-1:0] = '{'{0, -1, 0},'{-1, 4, -1},'{0, -1, 0}};
logic signed [DATA_SIZE+1-1:0] window_2 [KERNEL_SIZE-1:0][KERNEL_SIZE-1:0] = '{'{-1, -1, -1},'{-1, 8, -1},'{-1, -1, -1}};
logic signed [DATA_SIZE+1-1:0] window_3 [KERNEL_SIZE-1:0][KERNEL_SIZE-1:0] = '{'{1, 2, 1},'{2, 4, 2},'{1, 2, 1}};
logic signed [DATA_SIZE+1-1:0] window_4 [KERNEL_SIZE-1:0][KERNEL_SIZE-1:0] = '{'{1, 1, 1},'{1, 1, 1},'{1, 1, 1}};


assign w_window      = (i_config_select == 3) ? window_1 : (i_config_select == 2) ? window_2 : (i_config_select == 1) ? window_3 : window_4;
// assign fall_edge_det = (!(i_valid) && r_valid);

always_ff @(posedge i_clk or negedge i_nrst) begin 
     if(!i_nrst) begin
        o_data    <= '0;
        mult_done <= 1'b0;
     end else if(i_valid) begin
        sum_temp[0] <= i_data[0][0] * w_window[0][0];
        sum_temp[1] <= i_data[0][1] * w_window[0][1];
        sum_temp[2] <= i_data[0][2] * w_window[0][2];
        sum_temp[3] <= i_data[1][0] * w_window[1][0];
        sum_temp[4] <= i_data[1][1] * w_window[1][1];
        sum_temp[5] <= i_data[1][2] * w_window[1][2];
        sum_temp[6] <= i_data[2][0] * w_window[2][0];
        sum_temp[7] <= i_data[2][1] * w_window[2][1];
        sum_temp[8] <= i_data[2][2] * w_window[2][2];
        mult_done   <= 1'b1;
     end else begin
        mult_done   <= 1'b0;
        sum_temp    <=   '0;
     end
end


// always_ff @(posedge i_clk or negedge i_nrst) begin 
//     if(!i_nrst) begin
//         r_valid <= 1'b0;
//     end else begin
//         r_valid <= i_valid;
//     end
// end


always_ff @(posedge i_clk or negedge i_nrst) begin
         if(!i_nrst) begin
            r_data  <= '0;
            o_ready <= 1'b0;
         end else if(mult_done) begin
            r_data    <= ((sum_temp[0] + sum_temp[1] + sum_temp[2] + sum_temp[3] + sum_temp[4] + sum_temp[5] + sum_temp[6] + sum_temp[7] + sum_temp[8]) >> KERNEL_BITS);
            o_ready <= 1'b1;
         end else begin
            r_data <= '0;
            o_ready <= 1'b0;
         end
            
end

assign o_data = r_data[7:0];

endmodule


