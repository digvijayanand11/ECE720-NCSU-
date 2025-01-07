/** Neuron Network Size **/

`define proxal_synapse_count_para   16'd40
`define synapse_count_region_para   16'd64
`define distal_synapse_count_para   16'd16


`define column_per_row_para         16'd32
`define col_per_lane_para           16'd04  /** Col number in one row mapped to each lane **/
`define cell_per_column_para        16'd32
`define block_per_element_para      16'd04
`define segment_per_cell_para       16'd15
`define synapse_per_lane_para       16'd02


`define col_bondary_para            8'd32 
`define row_bondary_para            8'd64	
`define col_initial_para            8'd00		  
`define row_initial_para            8'd00	  
`define col_per_col_para            8'd00   /** Col offset of frist column in each element **/
`define row_per_col_para            8'd08   /** Row offset of frist column in each element **/


`define packet_count_desired_para   16'd40
`define learned_threshold_para      16'd15
`define actived_threshold_para      16'd15
`define predict_threshold_para      16'd15

`define perm_threshold_pro_para     16'd80
`define perm_max_val_pro_para       16'd200
`define perm_min_val_pro_para       16'd050
`define perm_rate_pro_para          16'd005

`define perm_threshold_dis_para     16'd80
`define perm_rate_dis_para          16'd005
`define permanence_max_dis_para     16'd150
`define permanence_min_dis_para     16'd000	

`define perm_init_pro_para          32'd120  /** initial of proximal synapse **/	  
`define perm_init_dis_para          16'd120  /** initial of distal synapse **/
`define constant_update_para        16'd200

`define boost_initial_para          32'd01000		  
`define boost_max_val_para          32'd10000
`define boost_min_val_para          32'd00850
`define boost_rate_para             32'd00005
`define boost_cont_para             32'd00500
`define overlap_minimun_para        8'h02

/** Hardware Structure size  **/

`define cores_count_para            2
`define lane_size_para              8
`define lemt_size_para              8
`define tree_size_para              3  /** sort tree in proc **/

`define word_size_para              32
`define long_size_para              64
`define addr_size_para              32
`define sram_size_para              24
`define addr_size_lemt              16
`define addr_size_proc              8


`define buff_size_proc              12
`define buff_size_lane              8
`define buff_size_lemt              16
`define buff_size_port              6
`define buff_size_tree              4


/** memory address of spatial pooling **/
`define memory_addr_init_pro_para 32'h00000000 
`define memory_addr_init_map_para 32'h00000000 /** Mapping flag in spatial lane memory **/
`define memory_addr_init_vld_para 32'h00000040 /** Per valid flag in spatial lane memory **/
`define memory_addr_init_flg_para 32'h00000080 /** Syn valid flag in spatial lane memory **/
`define memory_addr_init_bst_para 32'h000000c0 /** Boost value in spatial lane memory **/
`define memory_addr_init_act_para 32'h000000e0 /** Active Cycle in spatial lane memory **/
`define memory_addr_init_ovr_para 32'h00000100 /** Overlap cycle in spatial lane memory **/

`define memory_addr_init_val_para 32'h10000000 /** Permenance value in spatial lane memory **/
`define memory_addr_init_tmp_para 32'h20000000 /** Synapse index temp store in lane memory **/


/** memory address of temporal pooling **/
`define memory_addr_init_per_para  32'h30000000 /** Permanence in temporal lane memory **/
`define memory_addr_init_syn_para  32'h40000000 /** Synapse index in temporal lane memory **/   
`define memory_size_packet         8'h29 //32'h00000031 /** packet_count_desired_para * cores_count_ring + 1 **/
`define memory_lemt_packet         16'h0029 

/** memory address of element, 2 chunck + 1 chunk + blocks **/
`define memory_size_lemt_para      `memory_lemt_packet * 3 /** 32'd075 **/
`define memory_chunk_0_lemt        `memory_lemt_packet * 0 /** 32'd000 **/
`define memory_chunk_1_lemt        `memory_lemt_packet * 1 /** 32'd025 **/
`define memory_addr_init_ind_para  `memory_lemt_packet * 2 /** 32'h00000032, place used to store learn packet in element **/
`define memory_addr_init_blk_para  16'h8000


/** Working Memory For Processor and Element **/
/** 4 chunck + 1 chunk **/     
`define memory_size_proc_para      `memory_size_packet * 5 /** 32'd125 **/ 
`define memory_chunk_0_proc        `memory_size_packet * 0 /** 32'd000 **/
`define memory_chunk_1_proc        `memory_size_packet * 1 /** 32'd025 **/
`define memory_chunk_2_proc        `memory_size_packet * 2 /** 32'd050 **/
`define memory_chunk_3_proc        `memory_size_packet * 3 /** 32'd075 **/
`define memory_addr_init_buf_para  `memory_size_packet * 4 /** 32'h00000064, place used to store learn packet in Processor **/



// `include "../param.vh"

module bank_proc ( clk, rst,
                   memory_chunk_update, /** Change the initial of address **/
                   /** Memory Control from Dist **/
                   memory_addr_proc_0,
                   memory_wt_data_0,
                   memory_rd_enable_0,
                   memory_wt_enable_0,
                   /** Memory Contorl from Inht **/
                   memory_addr_proc_1,
                   memory_wt_data_1,
                   memory_rd_enable_1,
                   memory_wt_enable_1,
                   /** Memory Contorl from Cndt **/
                   memory_addr_proc_2,
                   memory_wt_data_2,
                   memory_rd_enable_2,
                   memory_wt_enable_2,
                   /** Output Signal **/
                   memory_device_enable,
                   memory_addr_proc,
                   memory_wt_data,
                   memory_wt_enable,
                   memory_rd_enable,
                   memory_data_ready,
                   /** For memory orgnization **/
                   memory_addr_init_pi0, /** Initial addr for index **/
                   memory_addr_init_pv0, /** Initial addr for value **/
                   memory_addr_init_pi1, /** Initial addr for index **/
                   memory_addr_init_pv1, /** Initial addr for value **/
                   memory_addr_init_ind  /** Initial addr for final index **/
                 );

parameter addr_size = `addr_size_proc,
          word_size = `word_size_para;


parameter memory_chunk_0 = `memory_chunk_0_proc,
		  memory_chunk_1 = `memory_chunk_1_proc,
		  memory_chunk_2 = `memory_chunk_2_proc,
		  memory_chunk_3 = `memory_chunk_3_proc;


input wire  clk, rst;
input wire  memory_chunk_update;
/** Memory Control from Inht **/
input wire memory_rd_enable_2, memory_wt_enable_2;
input wire [addr_size - 1 : 0] memory_addr_proc_2;
input wire [word_size - 1 : 0] memory_wt_data_2;
/** Memory Control from Dist **/
input wire memory_rd_enable_1, memory_wt_enable_1;
input wire [addr_size - 1 : 0] memory_addr_proc_1;
input wire [word_size - 1 : 0] memory_wt_data_1;
/** Memory Control from Inht **/
input wire memory_rd_enable_0,memory_wt_enable_0 ;
input wire [addr_size - 1 : 0] memory_addr_proc_0;
input wire [word_size - 1 : 0] memory_wt_data_0;


/** Output Signal **/
output reg [addr_size - 1 : 0] memory_addr_proc;
output reg [word_size - 1 : 0] memory_wt_data;
output reg memory_wt_enable, memory_rd_enable;
output reg memory_data_ready;
output reg memory_device_enable;
/** For memory orgnization **/
output reg  [addr_size - 1 : 0] memory_addr_init_pi0; /** Initial addr for index **/
output reg  [addr_size - 1 : 0] memory_addr_init_pv0; /** Initial addr for value **/
output reg  [addr_size - 1 : 0] memory_addr_init_pi1; /** Initial addr for index **/
output reg  [addr_size - 1 : 0] memory_addr_init_pv1; /** Initial addr for value **/
output reg  [addr_size - 1 : 0] memory_addr_init_ind; /** Initial addr for final index **/


reg memory_device_occupy_0, memory_device_occupy_1;
reg memory_device_occupy_2;


always @(*)
begin
  memory_device_occupy_0 = memory_rd_enable_0||memory_wt_enable_0;
  memory_device_occupy_1 = memory_rd_enable_1||memory_wt_enable_1;
  memory_device_occupy_2 = memory_rd_enable_2||memory_wt_enable_2;
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_device_enable <= 1'b0;
  end
  else begin
    case(1'b1)
      memory_device_occupy_0: memory_device_enable <= 1'b1;
      memory_device_occupy_1: memory_device_enable <= 1'b1;
      memory_device_occupy_2: memory_device_enable <= 1'b1;
	  default               : memory_device_enable <= 1'b0;
	endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
   memory_wt_enable <= 1'b0;
  end
  else begin
    case(1'b1)
      memory_wt_enable_0: memory_wt_enable <= memory_wt_enable_0;
      memory_wt_enable_1: memory_wt_enable <= memory_wt_enable_1;
      memory_wt_enable_2: memory_wt_enable <= memory_wt_enable_2;
	  default           : memory_wt_enable <= 1'b0;
	endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
   memory_rd_enable <= 1'b0;
  end
  else begin
    case(1'b1)
      memory_rd_enable_0: memory_rd_enable <= memory_rd_enable_0;
      memory_rd_enable_1: memory_rd_enable <= memory_rd_enable_1;
      memory_rd_enable_2: memory_rd_enable <= memory_rd_enable_2;
	  default           : memory_rd_enable <= 1'b0;
	endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_wt_data <= {word_size{1'b0}};
  end
  else begin
    case(1'b1)
      memory_wt_enable_0: memory_wt_data <= memory_wt_data_0;
      memory_wt_enable_1: memory_wt_data <= memory_wt_data_1;
      memory_wt_enable_2: memory_wt_data <= memory_wt_data_2;
	  default           : memory_wt_data <= {word_size{1'b0}};
	endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_proc <= {addr_size{1'b0}};
  end
  else begin
    case(1'b1)
      memory_device_occupy_0: memory_addr_proc <= memory_addr_proc_0;
      memory_device_occupy_1: memory_addr_proc <= memory_addr_proc_1;
      memory_device_occupy_2: memory_addr_proc <= memory_addr_proc_2;
      default               : memory_addr_proc <= {addr_size{1'b0}};
    endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_data_ready <= 1'b0;
  end
  else begin
    memory_data_ready <= (memory_rd_enable == 1'b1);
  end
end


/** For memory space orgnization **/


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_init_pv0 <= {addr_size{1'b0}};
  end
  else if(memory_chunk_update == 1'b1) begin
    memory_addr_init_pv0 <= {memory_chunk_0};
  end
  else begin
    memory_addr_init_pv0 <= {memory_chunk_2};
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_init_pi0 <= {addr_size{1'b0}};
  end
  else if(memory_chunk_update == 1'b1) begin
    memory_addr_init_pi0 <= {memory_chunk_1};
  end
  else begin
    memory_addr_init_pi0 <= {memory_chunk_3};
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_init_pv1 <= {addr_size{1'b0}};
  end
  else if(memory_chunk_update == 1'b1) begin
    memory_addr_init_pv1 <= {memory_chunk_2};
  end
  else begin
    memory_addr_init_pv1 <= {memory_chunk_0};
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_init_pi1 <= {addr_size{1'b0}};
  end
  else if(memory_chunk_update == 1'b1) begin
    memory_addr_init_pi1 <= {memory_chunk_3};
  end
  else begin
    memory_addr_init_pi1 <= {memory_chunk_1};
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_init_ind <= {addr_size{1'b0}};
  end
  else begin
    memory_addr_init_ind <= {memory_chunk_update ? memory_chunk_3 : memory_chunk_1};
  end
end


endmodule


/** logic unit in processor used to decide acitve cell and learn cell **/
/** among candidates from all elements **/
// `include "../param.vh"

module buld_proc ( clk, rst,
                   process_enable_buld,
                   buffer_input_0,
                   buffer_input_1,
                   buffer_input_2,
                   buffer_input_3,
                   buffer_input_4,
                   buffer_input_5,
                   buffer_input_6,
                   buffer_input_7,
                   buffer_empty_rcvd,
                   process_done_flag,
                   packet_instr_proc,
                   memory_addr_init_ind,
                   process_learn_enable,
                   /** Output Signal **/
                   memory_addr_proc,
                   memory_wt_enable,
                   memory_rd_enable,
                   memory_wt_data,
                   buffer_read_port,
                   process_done_buld
                 );

parameter  word_size = `word_size_para,
           addr_size = `addr_size_proc,
           lemt_size = `lemt_size_para,
           lane_size = `lane_size_para;

parameter  memory_addr_init_buf = `memory_addr_init_buf_para,
           cell_per_column = `cell_per_column_para,
           block_per_element = `block_per_element_para;


input wire clk, rst;
input wire process_enable_buld, process_learn_enable;
input wire process_done_flag;
input wire [word_size - 1 : 0] buffer_input_0, buffer_input_1;
input wire [word_size - 1 : 0] buffer_input_2, buffer_input_3;
input wire [word_size - 1 : 0] buffer_input_4, buffer_input_5;
input wire [word_size - 1 : 0] buffer_input_6, buffer_input_7;
input wire [lemt_size - 1 : 0] buffer_empty_rcvd;
input wire [addr_size - 1 : 0] memory_addr_init_ind;
input wire [3 : 0] packet_instr_proc;


output reg [addr_size - 1 : 0] memory_addr_proc;
output reg [word_size - 1 : 0] memory_wt_data;
output reg memory_wt_enable, memory_rd_enable;
output reg [lemt_size - 1 : 0] buffer_read_port;
output reg process_done_buld;


reg [7 : 0] index_act_cell, index_lrn_cell;
reg [7 : 0] index_col_proc, index_row_proc;
reg [3 : 0] state_buld, next_state_buld;
reg [2 : 0] index_elemnt;
reg index_lemt_count, index_lemt_reset;
reg [2 : 0] buffer_index_max, buffer_index_min;
reg [7 : 0] buffer_count_act [lemt_size - 1 : 0];
reg [7 : 0] buffer_count_seg [lemt_size - 1 : 0];


reg [3 : 0] index_segment_found, index_segment_minim;
reg [3 : 0] index_block_found, index_block_minim;
reg [3 : 0] block_used_elemnt;
reg [3 : 0] index_elemnt_found, index_elemnt_least;
reg buffer_max_found, buffer_min_found;
reg [7 : 0] buffer_value_max, buffer_value_min;


reg [7 : 0] index_cells_learn, index_cells_found;
reg [lemt_size - 1 : 0] actived_cell_elemnt;
reg [lemt_size - 1 : 0] learned_cell_elemnt;
reg [word_size - 1 : 0] packet_data_found;
reg [lemt_size - 1 : 0] buffer_count_flag;
reg [addr_size - 1 : 0] memory_addr_offt;
reg [addr_size - 1 : 0] memory_addr_init;
reg [3 : 0] logic_timer_buld;
reg logic_timer_count, logic_timer_reset;
reg blank_cell_found;
reg least_elemnt_found;

reg learned_cell_found, actived_cell_found;
reg packet_dirty_found, packet_ready_buld;
reg process_done_item;
reg [3 : 0] workload_buffer [lemt_size - 1 : 0];
reg [word_size - 1 : 0] packet_data_rcvd [lemt_size - 1 : 0];

reg [3 : 0] work_load_elemnt, work_load_minium;
reg [word_size - 1 : 0] packet_data_maxn, packet_data_minn;
reg [3 : 0] packet_data_flag;
reg memory_addr_offt_updt;
reg packet_valid_flag;


genvar index_lemt;

integer index;


always @(posedge clk)
begin
  if(~rst) begin
    memory_rd_enable <= 1'b0;
  end
  else begin
    memory_rd_enable <= memory_rd_enable;
  end
end


always @(*)
begin
  packet_data_rcvd[0] = buffer_input_0;
  packet_data_rcvd[1] = buffer_input_1;
  packet_data_rcvd[2] = buffer_input_2;
  packet_data_rcvd[3] = buffer_input_3;
  packet_data_rcvd[4] = buffer_input_4;
  packet_data_rcvd[5] = buffer_input_5;
  packet_data_rcvd[6] = buffer_input_6;
  packet_data_rcvd[7] = buffer_input_7;
end


/*** FSM logic for distributing learning cells among processing elements ***/


always @(posedge clk)
begin
  if(~rst) begin
    state_buld <= 4'b0000;
  end
  else begin
    state_buld <= next_state_buld;
  end
end


always @(*)
begin
  case(state_buld)
    4'b0000: begin
	           if(process_enable_buld == 1'b1) begin
                 next_state_buld = 4'b0001;
			   end
			   else begin
                 next_state_buld = 4'b0000;
			   end
	         end
    4'b0001: begin  /** check if any learn and active cell is found from the elements **/
			   if(logic_timer_buld == 4'b0010) begin
                 next_state_buld = packet_dirty_found ? 4'b0010 : 4'b0100;
			   end
			   else begin
                 next_state_buld = 4'b0001;
			   end
	         end
    4'b0010: begin  /** check segment activity/count to find matching segment **/
			   if(logic_timer_buld == 4'b1000) begin
                 next_state_buld = blank_cell_found ? 4'b0011 : 4'b0100;
			   end
			   else begin
                 next_state_buld = 4'b0010;
			   end
	         end
    4'b0011: begin  /** If min segment count is zero, compute the learn index **/
			   if(logic_timer_buld == 4'b1000) begin
                 next_state_buld = 4'b0100;
			   end
			   else begin
                 next_state_buld = 4'b0011;
			   end
	         end
    4'b0100: begin  /** Write the index of both learn and active cell into SRAM **/
			   if(process_learn_enable == 1'b0) begin
                 next_state_buld = 4'b0111;
			   end
			   else begin
                 next_state_buld = blank_cell_found ? 4'b0110 : 4'b0101;
			   end
	         end
    4'b0101: begin  /** Write learning package from max segment active **/
			   if(logic_timer_buld == 4'b0001) begin
                 next_state_buld = 4'b0111;
			   end
			   else begin
                 next_state_buld = 4'b0101;
			   end
	         end
    4'b0110: begin  /** Write learning package from min segment number **/
			   if(logic_timer_buld == 4'b0001) begin
                 next_state_buld = 4'b0111;
			   end
			   else begin
                 next_state_buld = 4'b0110;
			   end
	         end
    4'b0111: begin /** Wait for the next column received from the processing element **/
               if(process_done_flag == 1'b1) begin
				 next_state_buld = 4'b1000;
			   end
			   else begin /** instr == buld && buffer_empty == 1'b0 **/
                 next_state_buld = packet_ready_buld ? 4'b0001 : 4'b0111;
               end
             end
    4'b1000: begin /** Write the complete flag(ffff) of learning packet into the memory **/
               if(logic_timer_buld == 4'b0000) begin
                 next_state_buld = 4'b0000;
               end
               else begin
                 next_state_buld = 4'b1000;
               end
             end
	default: begin
	           next_state_buld = 4'b0000;
			 end
  endcase
end


always @(posedge clk)
begin
  if(~rst) begin
    process_done_buld <= 1'b0;
  end
  else begin
    process_done_buld <= (next_state_buld == 4'b0000)&&(state_buld != 4'b0000);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    process_done_item <= 1'b0;
  end
  else begin
    process_done_item <= (next_state_buld != 4'b0111)&&(state_buld == 4'b0111);
  end
end


always @(*)
begin
  if((packet_instr_proc == 4'b0100)&&(buffer_empty_rcvd == {lemt_size{1'b0}})) begin
    packet_ready_buld = 1'b1;
  end
  else begin
    packet_ready_buld = 1'b0;
  end
end


/** state == 3'b001, check if any learn and active cell is found from the elements **/


generate

  for(index_lemt = 0; index_lemt < lemt_size; index_lemt = index_lemt + 1)
  begin : element_cell

	always @(*)
	begin
	  actived_cell_elemnt[index_lemt] = (packet_data_rcvd[index_lemt][word_size - 17 : word_size - 24] == cell_per_column);
	  learned_cell_elemnt[index_lemt] = (packet_data_rcvd[index_lemt][word_size - 25 : word_size - 32] == cell_per_column);
	end

  end


endgenerate


always @(posedge clk)
begin /** set to 1, if not found **/
  if((~rst)||(process_done_item == 1'b1)) begin
    learned_cell_found <= 1'b0;
  end
  else if(learned_cell_elemnt == {lane_size{1'b1}}) begin
    learned_cell_found <= 1'b1;
  end
  else begin
    learned_cell_found <= learned_cell_found;
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_done_item == 1'b1)) begin
    actived_cell_found <= 1'b0;
  end
  else if(actived_cell_elemnt == {lane_size{1'b0}}) begin
    actived_cell_found <= 1'b1;
  end
  else begin
    actived_cell_found <= actived_cell_found;
  end
end


always @(*)
begin
  if((learned_cell_found == 1'b1)&&(process_learn_enable == 1'b1)) begin
    packet_dirty_found = 1'b1;
  end
  else begin
    packet_dirty_found = 1'b0;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    packet_data_found <= {word_size{1'b0}};
  end
  else begin
    case(1'b0)
	  actived_cell_elemnt[0]: packet_data_found <= packet_data_rcvd[0];
	  actived_cell_elemnt[1]: packet_data_found <= packet_data_rcvd[1];
	  actived_cell_elemnt[2]: packet_data_found <= packet_data_rcvd[2];
	  actived_cell_elemnt[3]: packet_data_found <= packet_data_rcvd[3];
	  actived_cell_elemnt[4]: packet_data_found <= packet_data_rcvd[4];
	  actived_cell_elemnt[5]: packet_data_found <= packet_data_rcvd[5];
	  actived_cell_elemnt[6]: packet_data_found <= packet_data_rcvd[6];
	  actived_cell_elemnt[7]: packet_data_found <= packet_data_rcvd[7];
	  default: packet_data_found <=  packet_data_rcvd[0];
	endcase
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_enable_buld == 1'b1)) begin
    index_lrn_cell <= cell_per_column;
  end
  else begin
    case(state_buld)
	  4'b0001: index_lrn_cell <= packet_data_found[word_size - 25 : word_size - 32];
	  4'b0010: index_lrn_cell <= index_cells_found;
	  4'b0011: index_lrn_cell <= index_cells_learn;
      default: index_lrn_cell <= index_lrn_cell;
	endcase
  end
end


always @(posedge clk)
begin /** all neural cells are active **/
  if((~rst)||(process_enable_buld == 1'b1)) begin
    index_act_cell <= cell_per_column;
  end
  else if(state_buld == 4'b0001) begin
    index_act_cell <= packet_data_found[word_size - 17 : word_size - 24];
  end
  else begin
    index_act_cell <= index_act_cell;
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_enable_buld == 1'b1)) begin
    index_row_proc <= 8'b00000000;
  end
  else if(state_buld == 4'b0001) begin
    index_row_proc <= packet_data_found[word_size - 01 : word_size - 08];
  end
  else begin
    index_row_proc <= index_row_proc;
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_enable_buld == 1'b1)) begin
    index_col_proc <= 8'b00000000;
  end
  else if(state_buld == 4'b0001) begin
    index_col_proc <= packet_data_found[word_size - 09 : word_size - 16];
  end
  else begin
    index_col_proc <= index_col_proc;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_read_port <= {lemt_size{1'b0}};
  end
  else begin
    case(state_buld)
      4'b0001: buffer_read_port <= {lemt_size{(logic_timer_buld == 4'b0001)}};
      4'b0101: buffer_read_port <= {lemt_size{(logic_timer_buld == 4'b0000)}};
      4'b0110: buffer_read_port <= {lemt_size{(logic_timer_buld == 4'b0000)}};
      default: buffer_read_port <= 1'b0;
    endcase
  end
end


/** state == 3'b010, check segment activity/count to find matching segment **/


always @(posedge clk)
begin
  if((~rst)||(index_lemt_reset == 1'b1)) begin
    index_elemnt <= 3'b000;
  end
  else if(index_lemt_count == 1'b1) begin
    index_elemnt <= index_elemnt + 1'b1;
  end
  else begin
    index_elemnt <= index_elemnt;
  end
end


always @(*)
begin
  case(state_buld)
    4'b0010 : index_lemt_count = 1'b1;
	4'b0011 : index_lemt_count = 1'b1;
    default: index_lemt_count = 1'b0;
  endcase
end


always @(*)
begin
  case(state_buld)
    4'b0010 : index_lemt_reset = (next_state_buld == 4'b0011);
	4'b0011 : index_lemt_reset = (next_state_buld == 4'b0100);
    default: index_lemt_reset = 1'b0;
  endcase
end


generate

  for(index_lemt = 0; index_lemt < lemt_size; index_lemt = index_lemt + 1)
  begin : element_flag

	always @(*)
	begin
	  buffer_count_flag[index_lemt] = packet_data_rcvd[index_lemt][0];
	  buffer_count_act[index_lemt] = buffer_count_flag[index_lemt] ? packet_data_rcvd[index_lemt][word_size - 01 : word_size - 08] : 8'h00; /** segment active **/
	  buffer_count_seg[index_lemt] = buffer_count_flag[index_lemt] ? 8'hff : packet_data_rcvd[index_lemt][word_size - 01 : word_size - 08]; /** segment number **/
	end

  end


endgenerate


always @(*)
begin
  packet_valid_flag = (buffer_count_flag == {lemt_size{1'b0}}); /** flag == 1, min segment_count **/
end


always @(*)
begin
  buffer_max_found = (buffer_value_max <= buffer_count_act[index_elemnt])&&(state_buld == 4'b0010);
  buffer_min_found = (buffer_value_min >= buffer_count_seg[index_elemnt])&&(state_buld == 4'b0010);
end


always @(posedge clk)
begin
  if((~rst)||(process_done_item == 1'b1)) begin
    buffer_value_max <= 8'b00000000;
  end
  else if(buffer_max_found == 1'b1) begin
    buffer_value_max <= buffer_count_act[index_elemnt];
  end
  else begin
    buffer_value_max <= buffer_value_max;
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_done_item == 1'b1)) begin
    buffer_index_max <= 3'b000;
  end
  else if(buffer_max_found == 1'b1) begin
    buffer_index_max <= index_elemnt;
  end
  else begin
    buffer_index_max <= buffer_index_max;
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_done_item == 1'b1)) begin
    buffer_value_min <= 8'b11111111;
  end
  else if(buffer_min_found == 1'b1) begin
    buffer_value_min <= buffer_count_seg[index_elemnt];
  end
  else begin
    buffer_value_min <= buffer_value_min;
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_done_item == 1'b1)) begin
    buffer_index_min <= 3'b000;
  end
  else if(buffer_min_found == 1'b1) begin
    buffer_index_min <= index_elemnt;
  end
  else begin
    buffer_index_min <= buffer_index_min;
  end
end


always @(*)
begin
  index_elemnt_found = packet_valid_flag ? buffer_index_min : buffer_index_max;
  index_cells_found = packet_data_rcvd[index_elemnt_found][word_size - 21 : word_size - 28];
  index_block_found = packet_data_rcvd[index_elemnt_found][word_size - 17 : word_size - 20];
end


always @(*)
begin
  index_segment_found = packet_data_rcvd[buffer_index_max][word_size - 09 : word_size - 12];
  index_segment_minim = packet_data_rcvd[buffer_index_min][word_size - 01 : word_size - 04];
end


always @(*)
begin
  blank_cell_found = (index_segment_minim == 4'b0000)&&(packet_valid_flag == 1'b1);
end


/** state == 3'b011, If min segment count is zero, compute the learn index, workload and target element **/
/** Element with avaliable block and least work load is selected as target element **/


always @(*)
begin
  block_used_elemnt = packet_data_rcvd[index_elemnt][word_size - 5 : word_size - 8];
  work_load_elemnt = workload_buffer[index_elemnt];
end


always @(posedge clk)
begin
  if((~rst)||(process_done_item == 1'b1)) begin
    index_cells_learn <= (cell_per_column - 1);
  end
  else if((state_buld == 4'b0011)&&(next_state_buld == 4'b0011)) begin
    index_cells_learn <= index_cells_learn - block_used_elemnt;
  end
  else begin
    index_cells_learn <= index_cells_learn;
  end
end


always @(*)
begin
  if((work_load_minium > work_load_elemnt)&&(state_buld == 4'b0011)&&(next_state_buld == 4'b0011)&&(block_used_elemnt < block_per_element)) begin
    least_elemnt_found = 1'b1;
  end
  else begin
    least_elemnt_found = 1'b0;
  end
end


always @(posedge clk)
begin /** Element with least work load and dirty block is selected **/
  if((~rst)||(process_done_item == 1'b1)) begin
    index_elemnt_least <= 4'b0000;
  end
  else if(least_elemnt_found == 1'b1) begin
    index_elemnt_least <= index_elemnt;
  end
  else begin
    index_elemnt_least <= index_elemnt_least;
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_done_item == 1'b1))  begin
    work_load_minium <= 4'b1111;
  end
  else if(least_elemnt_found == 1'b1) begin
    work_load_minium <= work_load_elemnt;
  end
  else begin
    work_load_minium <= work_load_minium;
  end
end


always @(posedge clk)
begin /** Block occupied account for elment with least work load **/
  if((~rst)||(process_done_item == 1'b1))  begin
    index_block_minim <= 4'b0000;
  end
  else if(least_elemnt_found == 1'b1) begin
    index_block_minim <= block_used_elemnt;
  end
  else begin
    index_block_minim <= index_block_minim;
  end
end


/** state == 3'b101, write learning package from max segment activity **/
/** state == 3'b110, write learning package from min segment account **/


always @(posedge clk)
begin
  if(~rst) begin
    memory_wt_enable <= 1'b0;
  end
  begin
    case(state_buld)
	  4'b0100: memory_wt_enable <= (logic_timer_buld == 4'b0000);
      4'b0101: memory_wt_enable <= (logic_timer_buld == 4'b0000);
      4'b0110: memory_wt_enable <= (logic_timer_buld == 4'b0000);
      4'b1000: memory_wt_enable <= (logic_timer_buld == 4'b0000);
      default: memory_wt_enable <= 1'b0;
    endcase
  end
end

/**
Packet_One_Index = {index_row_proc, index_col_proc, index_act_found, Index_Lrn_Found}
Packet_Two_Build = {Max_Counter_Pnt, Segment_Index_Pnt, 4'h0, Block_Index_Pnt, Cell_ID_Block, 4'b0001}
Packet_Two_Exist = {Min_Counter_Seg, Block_Count_Used, 8'h00, Block_Index_Seg, Cell_ID_Block, 4'b0010}
**/

always @(posedge clk)
begin
  if(~rst) begin
    memory_wt_data <= {word_size{1'b0}};
  end
  else begin
    case(state_buld)
      4'b0100: memory_wt_data <= {index_row_proc, index_col_proc, index_act_cell, index_lrn_cell};
      4'b0101: memory_wt_data <= {packet_data_maxn};
      4'b0110: memory_wt_data <= {packet_data_minn};
      //4'b1000: memory_wt_data <= {word_size{1'b0}};
      4'b1000: memory_wt_data <= {word_size{1'b1}}; /** for test ring only **/
      default: memory_wt_data <= {word_size{1'b0}};          /** 8 bit **/                        /** 8 bit **/
    endcase
  end
end


always @(*)
begin
  packet_data_flag = {packet_dirty_found ? 4'b0001 : 4'b0000}; /** if a valid packet **/
  packet_data_maxn = {index_row_proc, index_col_proc, index_block_found, index_segment_found, index_elemnt_found, packet_data_flag};
  packet_data_minn = {index_row_proc, index_col_proc, index_block_minim, index_segment_minim, index_elemnt_least, packet_data_flag};
end


always @(*)
begin
  case(state_buld)
    4'b0100: memory_addr_init = memory_addr_init_ind;
    4'b0101: memory_addr_init = memory_addr_init_buf;
    4'b0110: memory_addr_init = memory_addr_init_buf;
    4'b1000: memory_addr_init = memory_addr_init_buf;
    default: memory_addr_init = {addr_size{1'b0}};
  endcase
end


always @(posedge clk)
begin
  if((~rst)||(process_done_buld == 1'b1)) begin
    memory_addr_offt <= {addr_size{1'b0}};
  end
  else if(memory_addr_offt_updt == 1'b1) begin
    memory_addr_offt <= memory_addr_offt + 16'h0001;
  end
  else begin
    memory_addr_offt <= memory_addr_offt;
  end
end


always @(*)
begin
  case(next_state_buld)
    4'b0001: memory_addr_offt_updt = (state_buld == 4'b0111);
    4'b1000: memory_addr_offt_updt = (state_buld == 4'b0111);
    default: memory_addr_offt_updt = (1'b0);
  endcase
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_proc <= {addr_size{1'b0}};
  end
  else begin
    memory_addr_proc <= {memory_addr_init + memory_addr_offt};
  end
end


/** logic used to control and record package number in central processor **/


always @(posedge clk)
begin
  if((~rst)||(process_done_buld == 1'b1)) begin
    for(index = 0; index < lemt_size; index = index + 1)
	  workload_buffer[index] <= 4'b0000;
  end
  else if((state_buld == 4'b0101)&&(logic_timer_buld == 4'b0001)) begin
    workload_buffer[index_elemnt_found] <= workload_buffer[index_elemnt_found] + 1'b1;
  end
  else if((state_buld == 4'b0110)&&(logic_timer_buld == 4'b0001)) begin
    workload_buffer[index_elemnt_least] <= workload_buffer[index_elemnt_least] + 1'b1;
  end
  else begin
    for(index = 0; index < lemt_size; index = index + 1)
	  workload_buffer[index] <= workload_buffer[index];
  end
end


always @(posedge clk)
begin
  if((~rst)||(logic_timer_reset == 1'b1)) begin
    logic_timer_buld <= 4'b0000;
  end
  else if(logic_timer_count == 1'b1) begin
    logic_timer_buld <= logic_timer_buld + 1'b1;
  end
  else begin
    logic_timer_buld <= logic_timer_buld;
  end
end


always @(*)
begin
  case(state_buld)
    4'b0000: logic_timer_count = 1'b0;
    4'b0111: logic_timer_count = 1'b0;
    4'b1000: logic_timer_count = 1'b0;
	default: logic_timer_count = 1'b1;
  endcase
end


always @(*)
begin
  case(state_buld)
    4'b0000: logic_timer_reset = 1'b0;
    4'b0111: logic_timer_reset = 1'b0;
    4'b1000: logic_timer_reset = 1'b0;
	default: logic_timer_reset = (next_state_buld != state_buld);
  endcase
end


endmodule


// `include "../param.vh"

module ctrl_proc ( clk, rst,
                   process_flows_enable,
                   process_done_init,
                   process_done_sort,
                   process_done_find,
                   process_done_buld,
                   process_done_dist,
                   packet_enable_init,
                   packet_enable_dist,
                   packet_inst_init,
                   packet_data_init,
                   packet_inst_dist,
                   packet_data_dist,
				   packet_inst_rcvd_0,
				   packet_inst_rcvd_1,
				   packet_inst_rcvd_2,
				   packet_inst_rcvd_3,
				   packet_inst_rcvd_4,
				   packet_inst_rcvd_5,
				   packet_inst_rcvd_6,
				   packet_inst_rcvd_7,
                   /**output signal**/
				   process_done_flow,
				   buffer_inst_reset,
                   buffer_fifo_reset,
                   process_enable_init,
                   process_enable_sort,
                   process_enable_find,
                   process_enable_buld,
                   process_enable_dist,
				   packet_enable_send,
				   packet_inst_send,
				   packet_data_send,
                   process_code_flag,
				   process_done_flag,
                   packet_instr_proc,
                   memory_data_need,
                   memory_chunk_update
				 );

parameter lemt_size = `lemt_size_para,
		  word_size = `word_size_para;


input wire clk, rst;
input wire process_flows_enable;
input wire process_done_sort, process_done_find;
input wire process_done_buld, process_done_dist;
input wire process_done_init;
input wire [lemt_size - 1 : 0] packet_enable_dist;
input wire [lemt_size - 1 : 0] packet_enable_init;
input wire [word_size - 1 : 0] packet_inst_init;
input wire [word_size - 1 : 0] packet_data_init;
input wire [word_size - 1 : 0] packet_inst_dist;
input wire [word_size - 1 : 0] packet_data_dist;
input wire [word_size - 1 : 0] packet_inst_rcvd_0;
input wire [word_size - 1 : 0] packet_inst_rcvd_1;
input wire [word_size - 1 : 0] packet_inst_rcvd_2;
input wire [word_size - 1 : 0] packet_inst_rcvd_3;
input wire [word_size - 1 : 0] packet_inst_rcvd_4;
input wire [word_size - 1 : 0] packet_inst_rcvd_5;
input wire [word_size - 1 : 0] packet_inst_rcvd_6;
input wire [word_size - 1 : 0] packet_inst_rcvd_7;


output reg process_enable_init, process_enable_sort;
output reg process_enable_find, process_enable_buld;
output reg process_enable_dist;
output reg memory_chunk_update;
output reg [lemt_size - 1 : 0] packet_enable_send;
output reg [word_size - 1 : 0] packet_inst_send;
output reg [word_size - 1 : 0] packet_data_send;
output reg process_code_flag, process_done_flag;
output reg [3 : 0] packet_instr_proc;
output reg memory_data_need;
output reg process_done_flow;
output reg buffer_inst_reset;
output reg buffer_fifo_reset;


reg [word_size - 1 : 0] packet_inst_rcvd [lemt_size - 1 : 0];
reg [lemt_size - 1 : 0] packet_sort_ready, packet_find_ready;
reg [lemt_size - 1 : 0] packet_buld_ready, packet_send_ready;
reg [lemt_size - 1 : 0] packet_item_ready;
reg [3 : 0] state_ctrl, next_state_ctrl, states;
reg memory_addr_update;
reg [lemt_size - 1 : 0] packet_done_ready, packet_code_ready;
reg process_done_wait;
reg memory_data_reset;
reg process_done_rcvd, process_done_buff, process_done_comu;



genvar index;


always @(*)
begin
  packet_inst_rcvd[0] = packet_inst_rcvd_0;
  packet_inst_rcvd[1] = packet_inst_rcvd_1;
  packet_inst_rcvd[2] = packet_inst_rcvd_2;
  packet_inst_rcvd[3] = packet_inst_rcvd_3;
  packet_inst_rcvd[4] = packet_inst_rcvd_4;
  packet_inst_rcvd[5] = packet_inst_rcvd_5;
  packet_inst_rcvd[6] = packet_inst_rcvd_6;
  packet_inst_rcvd[7] = packet_inst_rcvd_7;
end


always @(posedge clk)
begin
  if(~rst) begin
    state_ctrl <= 4'b0000;
  end
  else begin
    state_ctrl <= next_state_ctrl;
  end
end


always @(*)
begin
  case(state_ctrl)
    3'b000 : next_state_ctrl = process_flows_enable ? 3'b001 : 3'b000;
	3'b001 : next_state_ctrl = process_done_init ? 3'b110 : 3'b001;
	3'b010 : next_state_ctrl = process_done_sort ? 3'b101 : 3'b010; /** sort the sorted array **/
	3'b011 : next_state_ctrl = process_done_find ? 3'b101 : 3'b011; /** find the max/min data **/
	3'b100 : next_state_ctrl = process_done_buld ? 3'b111 : 3'b100;	/** generate new segments for learning cell **/
	3'b111 : next_state_ctrl = 3'b101; /** store and forward data using noc **/
	3'b101 : next_state_ctrl = process_done_dist ? 3'b110 : 3'b101;
    3'b110 : next_state_ctrl = process_done_wait ? states : 3'b110;
    default: next_state_ctrl = 3'b000;
  endcase
end


always @(posedge clk)
begin
  if(~rst) begin
    states <= 3'b000;
  end
  else if(process_done_dist == 1'b1) begin
    states <= 3'b110;
  end
  else begin
    case(packet_instr_proc[3 : 0])
      4'b0010: states <= 3'b010;
      4'b0011: states <= 3'b011;
	  4'b0100: states <= 3'b100;
	  4'b0101: states <= 3'b101;         /** send instr indicates intial in all elements is done **/
	  default: states <= 3'b110;
	endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    process_done_buff <= 1'b0;
	process_done_flow <= 1'b0; /** indicate the current image is done **/
  end
  else begin
    process_done_buff <= (packet_item_ready == {lemt_size{1'b1}});
	process_done_flow <= (process_done_rcvd == 1'b1)&&(process_done_buff == 1'b0);
  end
end


always @(*)
begin
  process_done_rcvd = (packet_item_ready == {lemt_size{1'b1}});
  buffer_inst_reset = (process_done_dist == 1'b1);
  memory_data_reset = (process_done_sort == 1'b1)&&(process_done_flag == 1'b1);
end


always @(posedge clk)
begin
  if(~rst) begin
    process_done_wait <= 1'b0;
  end
  else begin
    process_done_wait <= (packet_instr_proc != 4'b0000);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_fifo_reset <= 1'b0;
  end
  else begin
    buffer_fifo_reset <= (process_done_sort == 1'b1)||(process_done_dist == 1'b1);
  end
end


always @(posedge clk)
begin
  if((~rst)||(memory_data_reset == 1'b1)) begin
    memory_data_need <= 1'b0;
  end
  else if(process_done_sort == 1'b1) begin
    memory_data_need <= 1'b1;
  end
  else begin
    memory_data_need <= memory_data_need;
  end
end


/** state_ctrl == 3'b001, trigger the initial process for each element **/


always @(posedge clk)
begin
  if(~rst) begin
    process_enable_init <= 1'b0;
  end
  else begin
    process_enable_init <= (state_ctrl != 3'b001)&&(next_state_ctrl == 3'b001);
  end
end


/** state_ctrl == 3'b010, trigger the sorting process for data received **/


always @(posedge clk)
begin
  if(~rst) begin
    process_enable_sort <= 1'b0;
  end
  else begin
    process_enable_sort <= (state_ctrl != 3'b010)&&(next_state_ctrl == 3'b010);
  end
end


/** state_ctrl == 3'b011, send the information back to the processing elements **/


always @(posedge clk)
begin
  if(~rst) begin
    process_enable_find <= 1'b0;
  end
  else begin
    process_enable_find <= (state_ctrl != 3'b011)&&(next_state_ctrl == 3'b011);
  end
end


/** state_ctrl == 3'b100, trigger the process for generate new segment **/


always @(posedge clk)
begin
  if(~rst) begin
    process_enable_buld <= 1'b0;
  end
  else begin
    process_enable_buld <= (state_ctrl != 3'b100)&&(next_state_ctrl == 3'b100);
  end
end


/** state_ctrl == 3'b101, send the information back to the processing elements **/


always @(posedge clk)
begin
  if(~rst) begin
    process_enable_dist <= 1'b0;
  end
  else begin
    process_enable_dist <= (state_ctrl != 3'b101)&&(next_state_ctrl == 3'b101);
  end
end


always @(*)
begin
  case(state_ctrl)
    3'b001 : packet_inst_send = {packet_inst_init};
	3'b101 : packet_inst_send = {packet_inst_dist};
	default: packet_inst_send = {word_size{1'b0}};
  endcase
end


always @(*)
begin
  case(state_ctrl)
    3'b001 : packet_data_send = packet_data_init;
	3'b101 : packet_data_send = packet_data_dist;
	default: packet_data_send = {word_size{1'b0}};
  endcase
end


always @(*)
begin
  case(state_ctrl)
    3'b001 : packet_enable_send = packet_enable_init;
	3'b101 : packet_enable_send = packet_enable_dist;
	default: packet_enable_send = {lemt_size{1'b0}};
  endcase
end


always @(*)
begin
  memory_addr_update = (packet_instr_proc == 4'b0010)&&(process_done_sort == 1'b1)&&(process_done_flag == 1'b0);
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_chunk_update <= 1'b0;
  end
  else begin
    memory_chunk_update <= memory_chunk_update + memory_addr_update;
  end
end


/** packet_inst_rcvd = {8'h00, instr{8'h00}, type{8'h00}, done{8'h00}} **/
/** instr = find{0010}, sort{0001}, buld{0100} **/
/** control logic used to decode the instruction received from elements **/

generate


  for(index = 0; index < lemt_size; index = index + 1)
  begin: inst_rcvd

    always @(*)
	begin
	  packet_send_ready[index] = packet_inst_rcvd[index][11];
	  packet_buld_ready[index] = packet_inst_rcvd[index][10];
	  packet_find_ready[index] = packet_inst_rcvd[index][09];
	  packet_sort_ready[index] = packet_inst_rcvd[index][08];
	  packet_item_ready[index] = packet_inst_rcvd[index][28];
	end

    always @(*)
	begin
	  packet_done_ready[index] = packet_inst_rcvd[index][00];
	  packet_code_ready[index] = packet_inst_rcvd[index][01];
	end


  end


endgenerate



always @(posedge clk)
begin
  if((~rst)||(process_done_dist == 1'b1)) begin
    packet_instr_proc <= 4'b0000;
  end
  else begin
    case({lemt_size{1'b1}})
      packet_buld_ready: packet_instr_proc <= 4'b0100;
      packet_sort_ready: packet_instr_proc <= 4'b0010;
      packet_find_ready: packet_instr_proc <= 4'b0011;
      packet_send_ready: packet_instr_proc <= 4'b0101;
      default          : packet_instr_proc <= 4'b0000;
    endcase
  end
end


always @(posedge clk)
begin /** indicate if last round of an operation **/
  if((~rst)||(process_done_dist == 1'b1)) begin
    process_done_flag <= 1'b0;
  end
  else if(packet_done_ready == {lemt_size{1'b1}}) begin
    process_done_flag <= 1'b1;
  end
  else begin
    process_done_flag <= process_done_flag;
  end
end


always @(posedge clk)
begin /** indicate if look for max or min value **/
  if((~rst)||(process_done_dist == 1'b1)) begin
    process_code_flag <= 1'b0;
  end
  else if(packet_code_ready == {lemt_size{1'b1}}) begin
    process_code_flag <= 1'b1;
  end
  else begin
    process_code_flag <= process_code_flag;
  end
end


endmodule


/** logic module used to send data back to processing element **/
// `include "../param.vh"

module dist_proc ( clk, rst,
                   process_enable_dist,
                   process_learn_enable,
				   buffer_rd_data,
                   packet_data_find,
                   packet_instr_proc,
                   process_done_flag,
                   process_code_flag,
				   memory_addr_init_ind,
                   /**output signal**/
                   process_done_dist,
				   memory_addr_proc,
                   memory_rd_enable,
                   memory_wt_enable,
                   memory_wt_data,
				   buffer_rd_enable,
				   packet_inst_send,
				   packet_data_send,
				   packet_enable_send
				 );

parameter  word_size = `word_size_para,
           lemt_size = `lemt_size_para,
           addr_size = `addr_size_proc,
           memory_packet_count = `memory_size_packet, /** total packet count in proc memory(includ received from other cores) **/
           memory_addr_init_buf = `memory_addr_init_buf_para;


input wire clk, rst;
input wire process_enable_dist;
input wire process_learn_enable;
input wire [word_size - 1 : 0] packet_data_find; /** result from find logic **/
input wire [word_size - 1 : 0] buffer_rd_data;
input wire [3 : 0] packet_instr_proc;
input wire [addr_size - 1 : 0] memory_addr_init_ind;
input wire process_done_flag, process_code_flag;


output reg process_done_dist;
output reg [addr_size - 1 : 0] memory_addr_proc;
output reg memory_rd_enable, buffer_rd_enable;
output reg memory_wt_enable;
output reg [word_size - 1 : 0] memory_wt_data;
output reg [lemt_size - 1 : 0] packet_enable_send;
output reg [word_size - 1 : 0] packet_inst_send;
output reg [word_size - 1 : 0] packet_data_send;



reg [addr_size - 1 : 0] memory_addr_init;
reg [addr_size - 1 : 0] memory_addr_offt;
reg [word_size - 1 : 0] packet_data_read;
reg [word_size - 1 : 0] buffer_data_read;
reg [2 : 0] state_dist, next_state_dist;
reg [2 : 0] states;
reg [3 : 0] logic_timer_dist;
reg [7 : 0] index_element;
reg index_element_count, index_element_reset;
reg logic_timer_count, logic_timer_reset;
reg memory_data_source, buffer_data_source;
reg instrn_data_source, packet_data_source;
reg packet_loop_done;
reg memory_addr_count, memory_mask_source;
reg memory_read_done;


always @(posedge clk)
begin
  if(~rst) begin
    memory_wt_enable <= 1'b0;
    memory_wt_data <= {word_size{1'b0}};
  end
  else begin
    memory_wt_enable <= memory_wt_enable;
    memory_wt_data <= memory_wt_data;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    state_dist <= 3'b000;
  end
  else begin
    state_dist <= next_state_dist;
  end
end


always @(*)
begin
  case(state_dist)
    3'b000 : begin
	           if(process_enable_dist == 1'b1) begin
			     next_state_dist = states;
			   end
			   else begin
			     next_state_dist = 3'b000;
			   end
			 end
	3'b001 : begin /** read column index from memory to send **/
	           if(logic_timer_dist == 4'b0011) begin
			     next_state_dist = 3'b010;
			   end
			   else begin
			     next_state_dist = 3'b001;
			   end
			 end
    3'b010 : begin /** send inst back to the elements **/
	           if(instrn_data_source == 1'b1) begin
			     next_state_dist = 3'b000;
			   end
			   else begin
			     next_state_dist = buffer_data_source ? 4'b011 : 3'b100;
			   end
			 end
    3'b011 : begin /** send buffer data back to the elements **/
	           if(logic_timer_dist == 4'b0000) begin
			     next_state_dist = 3'b000;
			   end
			   else begin
			     next_state_dist = 3'b011;
			   end
			 end
    3'b100 : begin /** send column data back to the elements **/
	           if(packet_loop_done == 1'b1) begin
			     next_state_dist = packet_data_source ? 3'b101 : 3'b000;
			   end
			   else begin
			     next_state_dist = 3'b100;
			   end
			 end
	3'b101 : begin /** read packet data from memory to send **/
	           if(logic_timer_dist == 4'b0011) begin
			     next_state_dist = 3'b110;
			   end
			   else begin
			     next_state_dist = 3'b101;
			   end
			 end
    3'b110 : begin /** send inst back to the elements **/
	           if(logic_timer_dist == 4'b0000) begin
			     next_state_dist = 3'b111;
			   end
			   else begin
			     next_state_dist = 3'b110;
			   end
			 end
    3'b111 : begin /** send packet data back to the elements **/
	           if(packet_loop_done == 1'b1) begin
			     next_state_dist = 3'b000;
			   end
			   else begin
			     next_state_dist = 3'b111;
			   end
			 end
	default: begin
			   next_state_dist = 3'b000;
			 end
  endcase
end


/** reset instr buffer each time the send operation is done **/

/**
3'b001 : states <= 4'b0001; sort
3'b001 : states <= 4'b0010; find
3'b001 : states <= 4'b0100; bult
3'b010 : states <= 4'b1000; send
**/


always @(posedge clk)
begin
  if(~rst) begin
    states <= 3'b000;
  end
  else begin
    case(1'b1)
	  memory_data_source: states <= 3'b001;
	  buffer_data_source: states <= 3'b010;
      instrn_data_source: states <= 3'b010;
	  default           : states <= 3'b000;
    endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_data_source <= 1'b0;
  end
  else begin
    memory_data_source <= ((packet_instr_proc == 4'b0010)&&(process_done_flag == 1'b1))||
                          ((packet_instr_proc == 4'b0100)&&(process_done_flag == 1'b1));
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    instrn_data_source <= 1'b0;
  end
  else begin
    instrn_data_source <= ((packet_instr_proc == 4'b0010)&&(process_done_flag == 1'b0))||
	                      ((packet_instr_proc == 4'b0101)&&(process_done_flag == 1'b1));
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_data_source <= 1'b0;
  end
  else begin
    buffer_data_source <= (packet_instr_proc == 4'b0011)&&(process_done_flag == 1'b1);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    packet_data_source <= 1'b0;
  end
  else begin
    packet_data_source <= (packet_instr_proc == 4'b0100)&&(process_learn_enable == 1'b1);
  end
end


always @(posedge clk)
begin /** each element sort part of the index **/
  if(~rst) begin
    memory_mask_source <= 1'b0;
  end
  else begin
    memory_mask_source <= (packet_instr_proc == 4'b0010)&&(process_code_flag == 1'b1);
  end
end


always @(*)
begin
  packet_loop_done = (buffer_rd_data == {word_size{1'b1}});
end


always @(posedge clk)
begin
  if(~rst) begin
    process_done_dist <= 1'b0;
  end
  else begin
    process_done_dist <= (next_state_dist == 3'b000)&&(state_dist != 3'b000);
  end
end


/** state_dist == 3'b001, read column data from memory to send **/
/** state_dist == 3'b101, read packet data from memory to send **/


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_proc <= {addr_size{1'b0}};
  end
  else begin
    memory_addr_proc <= memory_addr_init + memory_addr_offt;
  end
end


always @(*)
begin
  case(state_dist)
    3'b001 : memory_addr_init = memory_addr_init_ind;
	3'b100 : memory_addr_init = memory_addr_init_ind;
	3'b101 : memory_addr_init = memory_addr_init_buf;
	3'b111 : memory_addr_init = memory_addr_init_buf;
    default: memory_addr_init = {addr_size{1'b0}};
  endcase
end


always @(posedge clk)
begin
  if((~rst)||(packet_loop_done == 1'b1)) begin
    memory_addr_offt <= {addr_size{1'b0}};
  end
  else if(memory_addr_count == 1'b1) begin
    memory_addr_offt <= memory_addr_offt + 1'b1;
  end
  else begin
    memory_addr_offt <= memory_addr_offt;
  end
end


always @(*)
begin
  memory_read_done = (memory_addr_offt == memory_packet_count);
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_rd_enable <= 1'b0;
  end
  else begin
    case(state_dist)
      3'b001 : memory_rd_enable <= (memory_read_done == 1'b0);
	  3'b100 : memory_rd_enable <= (memory_read_done == 1'b0);
	  3'b101 : memory_rd_enable <= (memory_read_done == 1'b0);
	  3'b111 : memory_rd_enable <= (memory_read_done == 1'b0);
      default: memory_rd_enable <= 1'b0;
    endcase
  end
end


always @(*)
begin
  case(state_dist)
    3'b001 : memory_addr_count = (memory_read_done == 1'b0);
    3'b100 : memory_addr_count = (memory_read_done == 1'b0);
    3'b101 : memory_addr_count = (memory_read_done == 1'b0);
    3'b111 : memory_addr_count = (memory_read_done == 1'b0);
    default: memory_addr_count = 1'b0;
  endcase
end


always @(posedge clk)
begin
  if(~rst) begin
    packet_inst_send <= {word_size{1'b0}};
  end
  else begin
    case(state_dist)
	  3'b010 : packet_inst_send <= {word_size{1'b1}};
	  3'b110 : packet_inst_send <= {word_size{1'b1}};
	  default: packet_inst_send <= {word_size{1'b0}};
	endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    packet_data_send <= {word_size{1'b0}};
  end
  else begin
    case(state_dist)
	  3'b100 : packet_data_send <= {packet_data_read};
          3'b011 : packet_data_send <= {packet_data_find};
	  3'b111 : packet_data_send <= {packet_data_read};
	  default: packet_data_send <= {word_size{1'b0}};
	endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    packet_enable_send <= {lemt_size{1'b0}};
  end
  else begin
    case(state_dist)
	  3'b000 : packet_enable_send <= {lemt_size{1'b0}};
          3'b001 : packet_enable_send <= {lemt_size{1'b0}};
	  3'b101 : packet_enable_send <= {lemt_size{1'b0}};
	  default: packet_enable_send <= {lemt_size{1'b1}};
	endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_rd_enable <= 1'b0;
  end
  else begin
    case(next_state_dist)
	  3'b100 : buffer_rd_enable <= 1'b1;
	  3'b111 : buffer_rd_enable <= 1'b1;
	  default: buffer_rd_enable <= 1'b0;
	endcase
  end
end


always @(*)
begin
  buffer_data_read = {buffer_rd_data[word_size - 1 : word_size - 24], index_element};
  packet_data_read = memory_mask_source ? buffer_data_read : buffer_rd_data;
  index_element_reset = (process_done_dist == 1'b1)||(index_element == 8'h07);
  index_element_count = (memory_mask_source == 1'b1)&&(state_dist == 3'b100);
end


always @(posedge clk)
begin
  if((~rst)||(index_element_reset == 1'b1)) begin
    index_element <= 8'b00000000;
  end
  else if(index_element_count == 1'b1) begin
    index_element <= index_element + 1'b1;
  end
  else begin
    index_element <= index_element;
  end
end


always @(posedge clk)
begin
  if((~rst)||(logic_timer_reset == 1'b1)) begin
    logic_timer_dist <= 4'b0000;
  end
  else if(logic_timer_count == 1'b1) begin
    logic_timer_dist <= logic_timer_dist + 1'b1;
  end
  else begin
    logic_timer_dist <= logic_timer_dist;
  end
end


always @(*)
begin
  case(state_dist)
    3'b001 : logic_timer_count = 1'b1;
    3'b101 : logic_timer_count = 1'b1;
    default: logic_timer_count = 1'b0;
  endcase
end


always @(*)
begin
  case(state_dist)
    3'b001 : logic_timer_reset = (next_state_dist != 3'b001);
    3'b101 : logic_timer_reset = (next_state_dist != 3'b101);
    default: logic_timer_reset = 1'b0;
  endcase
end



endmodule


// `include "../param.vh"

module fifo_proc ( clk, rst,
                   buffer_wt_enable,
                   buffer_rd_enable,
                   buffer_wt_data,
                   buffer_data_reset,
                   /** Output Signal **/
                   buffer_rd_data,
                   buffer_data_count
                 );

parameter  buff_size = `buff_size_proc;
parameter  word_size = `word_size_para;


input wire clk, rst;
input wire [0 : 0] buffer_wt_enable;
input wire [6 : 0] buffer_rd_enable;
input wire buffer_data_reset;
input wire [word_size - 1 : 0] buffer_wt_data;

output reg [word_size - 1 : 0] buffer_rd_data;
output reg [4 : 0] buffer_data_count;


reg [word_size - 1 : 0] buffer_data_fifo [buff_size - 1 : 0];
reg [word_size - 1 : 0] buffer_data_next [buff_size - 1 : 0];
reg [3 : 0] buffer_rd_index, buffer_wt_index;
reg buffer_rd_reset, buffer_wt_reset;
reg buffer_data_read, buffer_data_wten;


integer index;


always @(*)
begin
  buffer_data_read = (buffer_rd_enable != 7'b0000000);
  buffer_data_wten = (buffer_wt_enable == 1'b1);
end


always @(posedge clk )
begin
  if((~rst)||(buffer_data_reset == 1'b1)) begin
    for(index = 0; index < buff_size; index = index + 1)
      buffer_data_fifo[index] <= {word_size{1'b0}};
  end
  else begin
    for(index = 0; index < buff_size; index = index + 1)
      buffer_data_fifo[index] <= buffer_data_next[index];
  end
end


always @(*)
begin
  if(buffer_data_wten == 1'b1) begin
    for(index = 0; index < buff_size; index = index + 1)
      buffer_data_next[index] = buffer_data_fifo[index];
      buffer_data_next[buffer_wt_index] = buffer_wt_data;
  end
  else begin
    for(index = 0; index < buff_size; index = index + 1)
      buffer_data_next[index] = buffer_data_fifo[index];
  end
end


always @(*)
begin
  buffer_rd_reset = ((buffer_rd_index == (buff_size - 1))&&(buffer_data_read == 1'b1))||(buffer_data_reset == 1'b1);
  buffer_wt_reset = ((buffer_wt_index == (buff_size - 1))&&(buffer_data_wten == 1'b1))||(buffer_data_reset == 1'b1);
end


always @(posedge clk)
begin
  if((~rst)||(buffer_rd_reset == 1'b1)) begin
    buffer_rd_index <= 3'b000;
  end
  else if(buffer_data_read == 1'b1) begin
    buffer_rd_index <= buffer_rd_index + 1'b1;
  end
  else begin
    buffer_rd_index <= buffer_rd_index;
  end
end


always @(posedge clk)
begin
  if((~rst)||(buffer_wt_reset == 1'b1)) begin
    buffer_wt_index <= 3'b000;
  end
  else if(buffer_data_wten == 1'b1) begin
    buffer_wt_index <= buffer_wt_index + 1'b1;
  end
  else begin
    buffer_wt_index <= buffer_wt_index;
  end
end


always @(posedge clk)
begin
  if((~rst)||(buffer_data_reset == 1'b1)) begin
    buffer_data_count <= 5'b0000;
  end
  else if((buffer_data_wten == 1'b1)&&(buffer_data_read == 1'b0)) begin
    buffer_data_count <= buffer_data_count + 1'b1;
  end
  else if((buffer_data_wten == 1'b0)&&(buffer_data_read == 1'b1)) begin
    buffer_data_count <= buffer_data_count - 1'b1;
  end
  else begin
    buffer_data_count <= buffer_data_count;
  end
end


always @(*)
begin
  buffer_rd_data = buffer_data_fifo[buffer_rd_index];
end


endmodule


/** logic unit used to find min/max value using pipeline **/
// `include "../param.vh"

module find_proc ( clk, rst,
                   process_enable_find,
                   buffer_input_0,
                   buffer_input_1,
                   buffer_input_2,
                   buffer_input_3,
                   buffer_input_4,
                   buffer_input_5,
                   buffer_input_6,
                   buffer_input_7,
                   buffer_empty_rcvd,
                   device_find_code,
                   /** ouput signal **/
                   buffer_read_port,
                   process_done_find,
                   buffer_output_index,
                   buffer_output_data
                 );


parameter word_size = `word_size_para,
          lemt_size = `lemt_size_para;

input wire clk, rst;
input wire process_enable_find;
input wire [word_size - 1 : 0] buffer_input_0, buffer_input_1;
input wire [word_size - 1 : 0] buffer_input_2, buffer_input_3;
input wire [word_size - 1 : 0] buffer_input_4, buffer_input_5;
input wire [word_size - 1 : 0] buffer_input_6, buffer_input_7;
input wire [lemt_size - 1 : 0] buffer_empty_rcvd;
input wire device_find_code;

output reg [word_size - 1 : 0] buffer_output_data;
output reg [lemt_size - 1 : 0] buffer_read_port;
output reg [2 : 0] buffer_output_index;
output reg process_done_find;


reg [word_size - 1 : 0] buffer_temp_value_0 [3 : 0];
reg [word_size - 1 : 0] buffer_temp_value_1 [1 : 0];
reg [word_size - 1 : 0] buffer_final_value  [1 : 0];

reg [2 : 0] buffer_temp_index_0 [3 : 0];
reg [2 : 0] buffer_temp_index_1 [1 : 0];
reg [2 : 0] buffer_final_index  [1 : 0];


reg [3 : 0] buffer_temper_find_0;
reg [1 : 0] buffer_temper_find_1;
reg [1 : 0] buffer_final_find;
reg [2 : 0] state_find, next_state_find;
reg buffer_final_enable;
reg buffer_data_flag, buffer_data_done;
reg [2 : 0] buffer_find_enable;



always @(posedge clk)
begin
  if(~rst) begin
    state_find <= 3'b000;
  end
  else begin
    state_find <= next_state_find;
  end
end


always @(*)
begin
  case(state_find)
    3'b000 : next_state_find = process_enable_find ? 3'b001 : 3'b000;
	3'b001 : next_state_find = 3'b010; /** trigger 1st level **/
	3'b010 : next_state_find = 3'b011; /** trigger 2nd level **/
	3'b011 : next_state_find = 3'b100; /** trigger 3nd level **/
	3'b100 : next_state_find = buffer_find_enable[2] ? 3'b100 : 3'b000;
	default: next_state_find = 3'b000;
  endcase
end


always @(posedge clk)
begin
  if(~rst) begin
    process_done_find <= 1'b0;
  end
  else begin
    process_done_find <= (next_state_find == 3'b000)&&(state_find != 3'b000);
  end
end


always @(*)
begin
  buffer_data_done = (buffer_empty_rcvd == {lemt_size{1'b1}});
end



always @(posedge clk)
begin
  if((~rst)||(buffer_data_done== 1'b1)) begin
    buffer_read_port <= {lemt_size{1'b0}};
  end
  else if(next_state_find == 3'b001) begin
    buffer_read_port <= {lemt_size{1'b1}};
  end
  else begin
    buffer_read_port <= buffer_read_port;
  end
end


/** The initial level of compare tree **/


always @(posedge clk)
begin
  if((~rst)||(buffer_data_done == 1'b1)) begin
    buffer_find_enable[0] <= 1'b0;
  end
  else if(next_state_find == 3'b001) begin
    buffer_find_enable[0] <= 1'b1;
  end
  else begin
    buffer_find_enable[0] <= buffer_find_enable[0];
  end
end


always @(posedge clk)
begin
  if(~rst) begin
	buffer_temp_value_0[0] <= {word_size{1'b0}};
    buffer_temp_index_0[0] <= {3'b000};
  end
  else if((buffer_temper_find_0[0] == 1'b1)&&(buffer_find_enable[0] == 1'b1)) begin
	buffer_temp_value_0[0] <= buffer_input_0;
    buffer_temp_index_0[0] <= 3'b000;
  end
  else if((buffer_temper_find_0[0] == 1'b0)&&(buffer_find_enable[0] == 1'b1)) begin
	buffer_temp_value_0[0] <= buffer_input_1;
    buffer_temp_index_0[0] <= 3'b001;
  end
  else begin
	buffer_temp_value_0[0] <= buffer_temp_value_0[0];
    buffer_temp_index_0[0] <= buffer_temp_index_0[0];
  end
end


always @(posedge clk)
begin
  if(~rst) begin
	buffer_temp_value_0[1] <= {word_size{1'b0}};
    buffer_temp_index_0[1] <= 3'b000;
  end
  else if((buffer_temper_find_0[1] == 1'b1)&&(buffer_find_enable[0] == 1'b1)) begin
	buffer_temp_value_0[1] <= buffer_input_2;
    buffer_temp_index_0[1] <= 3'b010;
  end
  else if((buffer_temper_find_0[1] == 1'b0)&&(buffer_find_enable[0] == 1'b1)) begin
	buffer_temp_value_0[1] <= buffer_input_3;
    buffer_temp_index_0[1] <= 3'b011;
  end
  else begin
	buffer_temp_value_0[1] <= buffer_temp_value_0[1];
    buffer_temp_index_0[1] <= buffer_temp_index_0[1];
  end
end


always @(posedge clk)
begin
  if(~rst) begin
	buffer_temp_value_0[2] <= {word_size{1'b0}};
    buffer_temp_index_0[2] <= 3'b000;
  end
  else if((buffer_temper_find_0[2] == 1'b1)&&(buffer_find_enable[0] == 1'b1)) begin
	buffer_temp_value_0[2] <= buffer_input_4;
    buffer_temp_index_0[2] <= 3'b100;
  end
  else if((buffer_temper_find_0[2] == 1'b0)&&(buffer_find_enable[0] == 1'b1)) begin
	buffer_temp_value_0[2] <= buffer_input_5;
    buffer_temp_index_0[2] <= 3'b101;
  end
  else begin
	buffer_temp_value_0[2] <= buffer_temp_value_0[2];
    buffer_temp_index_0[2] <= buffer_temp_index_0[2];
  end
end


always @(posedge clk)
begin
  if(~rst) begin
	buffer_temp_value_0[3] <= {word_size{1'b0}};
    buffer_temp_index_0[3] <= 3'b000;
  end
  else if((buffer_temper_find_0[3] == 1'b1)&&(buffer_find_enable[0] == 1'b1)) begin
	buffer_temp_value_0[3] <= buffer_input_6;
    buffer_temp_index_0[3] <= 3'b110;
  end
  else if((buffer_temper_find_0[3] == 1'b0)&&(buffer_find_enable[0] == 1'b1)) begin
	buffer_temp_value_0[3] <= buffer_input_7;
    buffer_temp_index_0[3] <= 3'b111;
  end
  else begin
	buffer_temp_value_0[3] <= buffer_temp_value_0[3];
    buffer_temp_index_0[3] <= buffer_temp_index_0[3];
  end
end


always @(*)
begin
  case(device_find_code)
    1'b1 : buffer_temper_find_0[0] = (buffer_input_0 >= buffer_input_1); /** looking for the max **/
	1'b0 : buffer_temper_find_0[0] = (buffer_input_0 <= buffer_input_1);
  endcase
end


always @(*)
begin
  case(device_find_code)
    1'b1 : buffer_temper_find_0[1] = (buffer_input_2 >= buffer_input_3); /** looking for the max **/
	1'b0 : buffer_temper_find_0[1] = (buffer_input_2 <= buffer_input_3);
  endcase
end


always @(*)
begin
  case(device_find_code)
    1'b1 : buffer_temper_find_0[2] = (buffer_input_4 >= buffer_input_5); /** looking for the max **/
	1'b0 : buffer_temper_find_0[2] = (buffer_input_4 <= buffer_input_5);
  endcase
end


always @(*)
begin
  case(device_find_code)
    1'b1 : buffer_temper_find_0[3] = (buffer_input_6 >= buffer_input_7); /** looking for the max **/
	1'b0 : buffer_temper_find_0[3] = (buffer_input_6 <= buffer_input_7);
  endcase
end


/** The second level of compare tree **/


always @(posedge clk)
begin
  if(~rst) begin
    buffer_find_enable[1] <= 1'b0;
  end
  else begin
    buffer_find_enable[1] <= buffer_find_enable[0];
  end
end


always @(posedge clk)
begin
  if(~rst) begin
	buffer_temp_value_1[0] <= {word_size{1'b0}};
    buffer_temp_index_1[0] <= 3'b000;
  end
  else if((buffer_temper_find_1[0] == 1'b1)&&(buffer_find_enable[1] == 1'b1)) begin
	buffer_temp_value_1[0] <= buffer_temp_value_0[0];
    buffer_temp_index_1[0] <= buffer_temp_index_0[0];
  end
  else if((buffer_temper_find_1[0] == 1'b0)&&(buffer_find_enable[1] == 1'b1)) begin
	buffer_temp_value_1[0] <= buffer_temp_value_0[1];
    buffer_temp_index_1[0] <= buffer_temp_index_0[1];
  end
  else begin
	buffer_temp_value_1[0] <= buffer_temp_value_1[0];
    buffer_temp_index_1[0] <= buffer_temp_index_1[0];
  end
end


always @(posedge clk)
begin
  if(~rst) begin
	buffer_temp_value_1[1] <= {word_size{1'b0}};
    buffer_temp_index_1[1] <= 3'b000;
  end
  else if((buffer_temper_find_1[1] == 1'b1)&&(buffer_find_enable[1] == 1'b1)) begin
	buffer_temp_value_1[1] <= buffer_temp_value_0[2];
    buffer_temp_index_1[1] <= buffer_temp_index_0[2];
  end
  else if((buffer_temper_find_1[1] == 1'b0)&&(buffer_find_enable[1] == 1'b1)) begin
	buffer_temp_value_1[1] <= buffer_temp_value_0[3];
    buffer_temp_index_1[1] <= buffer_temp_index_0[3];
  end
  else begin
	buffer_temp_value_1[1] <= buffer_temp_value_1[1];
    buffer_temp_index_1[1] <= buffer_temp_index_1[1];
  end
end


always @(*)
begin
  case(device_find_code)
    1'b1 : buffer_temper_find_1[0] = (buffer_temp_value_0[0] >= buffer_temp_value_0[1]); /** looking for the max **/
	1'b0 : buffer_temper_find_1[0] = (buffer_temp_value_0[0] <= buffer_temp_value_0[1]);
  endcase
end


always @(*)
begin
  case(device_find_code)
    1'b1 : buffer_temper_find_1[1] = (buffer_temp_value_0[2] >= buffer_temp_value_0[3]); /** looking for the max **/
	1'b0 : buffer_temper_find_1[1] = (buffer_temp_value_0[2] <= buffer_temp_value_0[3]);
  endcase
end


/** The third level of compare tree **/


always @(posedge clk)
begin
  if(~rst) begin
    buffer_find_enable[2] <= 1'b0;
  end
  else begin
    buffer_find_enable[2] <= buffer_find_enable[1];
  end
end


always @(posedge clk)
begin
  if(~rst) begin
	buffer_final_value[0] <= {word_size{1'b0}};
	buffer_final_index[0] <= 3'b000;
  end
  else if((buffer_final_find[0] == 1'b1)&&(buffer_find_enable[2] == 1'b1)) begin
	buffer_final_value[0] <= buffer_temp_value_1[0];
	buffer_final_index[0] <= buffer_temp_index_1[0];
  end
  else if((buffer_final_find[0] == 1'b0)&&(buffer_find_enable[2] == 1'b1)) begin
	buffer_final_value[0] <= buffer_temp_value_1[1];
	buffer_final_index[0] <= buffer_temp_index_1[1];
  end
  else begin
	buffer_final_value[0] <= buffer_final_value[0];
	buffer_final_index[0] <= buffer_final_index[0];
  end
end


always @(*)
begin
  case(device_find_code)
    1'b1 : buffer_final_find[0] = (buffer_temp_value_1[0] >= buffer_temp_value_1[1]); /** looking for the max **/
	1'b0 : buffer_final_find[0] = (buffer_temp_value_1[0] <= buffer_temp_value_1[1]);
  endcase
end


always @(posedge clk)
begin /** store the result of first round into buffer **/
  if((~rst)||(process_done_find == 1'b1)) begin
    buffer_data_flag <= 1'b0;
  end
  else if(state_find == 3'b100) begin
    buffer_data_flag <= 1'b1;
  end
  else begin
    buffer_data_flag <= buffer_data_flag;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_final_enable <= 1'b0;
  end
  else begin
    buffer_final_enable <= buffer_find_enable[2];
  end
end


/** may need to fix this bug **/
always @(posedge clk)
begin
  if((~rst)||(process_enable_find == 1'b1)) begin
	buffer_final_value[1] <= {word_size{1'b0}};
	buffer_final_index[1] <= 3'b000;
  end
  else if((buffer_final_find[1] == 1'b1)&&(buffer_final_enable == 1'b1)) begin
	buffer_final_value[1] <= buffer_final_value[0];
	buffer_final_index[1] <= buffer_final_index[0];
  end
  else begin
	buffer_final_value[1] <= buffer_final_value[1];
	buffer_final_index[1] <= buffer_final_index[1];
  end
end


always @(*)
begin
  case({device_find_code, buffer_data_flag})
    2'b11  : buffer_final_find[1] = (buffer_final_value[0] >= buffer_final_value[1]); /** looking for the max **/
	2'b01  : buffer_final_find[1] = (buffer_final_value[0] <= buffer_final_value[1]);
	default: buffer_final_find[1] = (1'b1);
  endcase
end


always @(*)
begin
   buffer_output_data  = buffer_final_value[1];
   buffer_output_index = buffer_final_index[1];
end



endmodule


// `include "../param.vh"

module init_proc ( clk, rst,
                   process_enable_init,
                   packet_grant_send,
                   /** Output Signal **/
                   process_done_init,
                   packet_data_send,
                   packet_inst_send,
                   packet_enable_send
			     );

parameter lane_size = `lane_size_para,
          word_size = `word_size_para,
          lemt_size = `lemt_size_para,
          col_bondary = `col_bondary_para,
          row_bondary = `row_bondary_para,
          col_initial = `col_initial_para,
          row_initial = `row_initial_para,
          col_per_col = `col_per_col_para,  /** Col offset of frist column in each element **/
          row_per_col = `row_per_col_para;  /** Row offset of frist column in each element **/



input wire clk, rst;
input wire process_enable_init;
input wire [lemt_size - 1 : 0] packet_grant_send;


output reg process_done_init;
output reg [word_size - 1 : 0] packet_data_send;
output reg [word_size - 1 : 0] packet_inst_send;
output reg [lemt_size - 1 : 0] packet_enable_send;


reg [7 : 0] row_init_elmt, col_init_elmt;
reg [7 : 0] row_bond_elmt, col_bond_elmt;
reg [2 : 0] state_init, next_state_init;
reg lanes_loop_done;
reg [7 : 0] index_element;
reg receiver_valid;


always @(posedge clk)
begin
  if(~rst) begin
    state_init <= 3'b000;
  end
  else begin
    state_init <= next_state_init;
  end
end


always @(*)
begin
  case(state_init)
    3'b000 : next_state_init = process_enable_init ? 3'b001 : 3'b000;
    3'b001 : next_state_init = receiver_valid ? 3'b010 : 3'b001; /** Send the inital instr **/
    3'b010 : next_state_init = receiver_valid ? 3'b011 : 3'b010; /** Send the row init **/
    3'b011 : next_state_init = receiver_valid ? 3'b100 : 3'b011; /** Send the col init **/
    3'b100 : next_state_init = receiver_valid ? 3'b101 : 3'b100; /** Send the row bond **/
    3'b101 : next_state_init = receiver_valid ? 3'b110 : 3'b101; /** Send the col bond **/
    3'b110 : next_state_init = lanes_loop_done ? 3'b000 : 3'b001; /** Send the element index **/
    default: next_state_init = 3'b000;
  endcase
end


always @(posedge clk)
begin
  if(~rst) begin
     packet_enable_send <= {lane_size{1'b0}};
  end
  else begin
    case(state_init)
      3'b000 : packet_enable_send <= {lane_size{1'b0}};
      3'b111 : packet_enable_send <= {lane_size{1'b0}};
      default: packet_enable_send <= {8'h01 << index_element};
    endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    packet_inst_send <= {word_size{1'b0}};
  end
  else begin
    packet_inst_send <= {word_size{1'b1}};
  end
end


always @(posedge clk)
begin
  if(~rst) begin
     packet_data_send <= {word_size{1'b0}};
  end
  else begin
    case(state_init)
       3'b010 : packet_data_send <= {24'h000000, row_init_elmt}; /** Send the row init **/
       3'b011 : packet_data_send <= {24'h000000, col_init_elmt}; /** Send the col init **/
       3'b100 : packet_data_send <= {24'h000000, row_bond_elmt}; /** Send the row bond **/
       3'b101 : packet_data_send <= {24'h000000, col_bond_elmt}; /** Send the col bond **/
       3'b110 : packet_data_send <= {24'h000000, index_element}; /** Send the element index **/
       default: packet_data_send <= {word_size{1'b0}};
    endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    process_done_init <= 1'b0;
  end
  else begin
    process_done_init <= (state_init != 3'b000)&&(next_state_init == 3'b000);
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_enable_init == 1'b1)) begin
    row_init_elmt <= row_initial;
  end
  else if(state_init == 3'b110) begin
    row_init_elmt <= row_init_elmt + row_per_col;
  end
  else begin
    row_init_elmt <= row_init_elmt;
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_enable_init == 1'b1)) begin
    col_init_elmt <= col_initial;
  end
  else if(state_init == 3'b110) begin
    col_init_elmt <= col_init_elmt + col_per_col;
  end
  else begin
    col_init_elmt <= col_init_elmt;
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_enable_init == 1'b1)) begin
    row_bond_elmt <= (row_per_col - 1);
  end
  else if(state_init == 3'b110) begin
    row_bond_elmt <= row_bond_elmt + row_per_col;
  end
  else begin
    row_bond_elmt <= row_bond_elmt;
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_enable_init == 1'b1)) begin
    col_bond_elmt <= col_bondary;
  end
  else if(state_init == 3'b110) begin
    col_bond_elmt <= col_bond_elmt + col_per_col;
  end
  else begin
    col_bond_elmt <= col_bond_elmt;
  end
end


always @(posedge clk)
begin
  if((packet_enable_send == 8'b10000000)&&(receiver_valid == 1'b1)) begin
    lanes_loop_done = 1'b1;
  end
  else begin
    lanes_loop_done = 1'b0;
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_enable_init == 1'b1)) begin
    index_element <= 8'b00000000;
  end
  else if((state_init == 3'b110)&&(next_state_init != 3'b110)) begin
    index_element <= index_element + 1'b1;
  end
  else begin
    index_element <= index_element;
  end
end


always @(*)
begin
  if(packet_grant_send[index_element] == 1'b1) begin
    receiver_valid = 1'b1;
  end
  else begin
    receiver_valid = 1'b0;
  end
end



endmodule


// `include "../param.vh"

module proc_unit ( clk, rst,
                   process_learn_enable,
                   process_flows_enable,
                   packet_grant_send,
                   packet_ready_rcvd,
                   packet_data_proc_0,
                   packet_data_proc_1,
                   packet_data_proc_2,
                   packet_data_proc_3,
                   packet_data_proc_4,
                   packet_data_proc_5,
                   packet_data_proc_6,
                   packet_data_proc_7,
                   /** output signal **/
                   memory_check_ready,
                   process_done_flow,
				   buffer_data_index,
                   packet_ready_send,
                   packet_grant_rcvd,
                   packet_data_lemt_0,
                   packet_data_lemt_1,
                   packet_data_lemt_2,
                   packet_data_lemt_3,
                   packet_data_lemt_4,
                   packet_data_lemt_5,
                   packet_data_lemt_6,
                   packet_data_lemt_7
                 );



parameter word_size = `word_size_para,
          lemt_size = `lemt_size_para,
          addr_size = `addr_size_proc;


input  wire clk, rst;
input  wire process_learn_enable;
input  wire process_flows_enable;
input  wire [lemt_size - 1 : 0] packet_grant_send;
input  wire [lemt_size - 1 : 0] packet_ready_rcvd;
input  wire [word_size - 1 : 0] packet_data_proc_0;
input  wire [word_size - 1 : 0] packet_data_proc_1;
input  wire [word_size - 1 : 0] packet_data_proc_2;
input  wire [word_size - 1 : 0] packet_data_proc_3;
input  wire [word_size - 1 : 0] packet_data_proc_4;
input  wire [word_size - 1 : 0] packet_data_proc_5;
input  wire [word_size - 1 : 0] packet_data_proc_6;
input  wire [word_size - 1 : 0] packet_data_proc_7;


output wire memory_check_ready;
output wire process_done_flow;
output wire [word_size - 1 : 0] buffer_data_index;
output wire [lemt_size - 1 : 0] packet_ready_send;
output wire [lemt_size - 1 : 0] packet_grant_rcvd;
output wire [word_size - 1 : 0] packet_data_lemt_0;
output wire [word_size - 1 : 0] packet_data_lemt_1;
output wire [word_size - 1 : 0] packet_data_lemt_2;
output wire [word_size - 1 : 0] packet_data_lemt_3;
output wire [word_size - 1 : 0] packet_data_lemt_4;
output wire [word_size - 1 : 0] packet_data_lemt_5;
output wire [word_size - 1 : 0] packet_data_lemt_6;
output wire [word_size - 1 : 0] packet_data_lemt_7;


wire process_done_init, process_done_sort;
wire process_done_find, process_done_buld;
wire process_done_dist;
wire [3 : 0] packet_instr_proc;
wire process_code_flag, process_done_flag;
wire [lemt_size - 1 : 0] packet_enable_init;
wire [lemt_size - 1 : 0] packet_enable_dist;
wire [word_size - 1 : 0] packet_inst_init;
wire [word_size - 1 : 0] packet_inst_dist;
wire [word_size - 1 : 0] packet_data_init;
wire [word_size - 1 : 0] packet_data_dist;


wire process_enable_init, process_enable_sort;
wire process_enable_find, process_enable_buld;
wire process_enable_dist;
wire [lemt_size - 1 : 0] packet_enable_send;
wire [word_size - 1 : 0] packet_inst_send;
wire [word_size - 1 : 0] packet_data_send;
wire memory_chunk_update;


wire [word_size - 1 : 0] packet_inst_rcvd [lemt_size - 1 : 0];
wire [word_size - 1 : 0] packet_data_rcvd [lemt_size - 1 : 0];
wire [4 : 0] buffer_data_count;
wire [word_size - 1 : 0] buffer_rd_data;
wire [addr_size - 1 : 0] memory_addr_init_pv1, memory_addr_init_pv0;
wire [addr_size - 1 : 0] memory_addr_init_pi1, memory_addr_init_pi0;
wire [addr_size - 1 : 0] memory_addr_init_ind;


wire [lemt_size - 1 : 0] buffer_full_sort;
wire [lemt_size - 1 : 0] buffer_find_sort;
wire [1 : 0] buffer_read_fifo;
wire [lemt_size - 1 : 0] buffer_read_port [2 : 0];
wire [2 : 0] packet_read_port [lemt_size - 1 : 0];


wire [addr_size - 1 : 0] memory_addr_proc_0;
wire [addr_size - 1 : 0] memory_addr_proc_1;
wire [addr_size - 1 : 0] memory_addr_proc_2;
wire [word_size - 1 : 0] memory_wt_data_0;
wire [word_size - 1 : 0] memory_wt_data_1;
wire [word_size - 1 : 0] memory_wt_data_2;
wire memory_wt_enable_0, memory_wt_enable_1;
wire memory_wt_enable_2;
wire memory_rd_enable_0, memory_rd_enable_1;
wire memory_rd_enable_2;


wire [word_size - 1 : 0] memory_rd_data;
wire memory_data_ready;
wire [addr_size - 1 : 0] memory_addr_proc;
wire [word_size - 1 : 0] memory_wt_data;
wire memory_wt_enable, memory_rd_enable;


wire [lemt_size - 1 : 0] buffer_empty_rcvd;
wire [2 : 0] buffer_output_index;
wire [word_size - 1 : 0] buffer_output_data;
wire [6 : 0] buffer_rd_enable = {5'b00000, buffer_read_fifo};
wire buffer_inst_reset, buffer_fifo_reset;
wire [word_size - 1 : 0] packet_data_proc [lemt_size - 1 : 0];
wire [word_size - 1 : 0] packet_data_lemt [lemt_size - 1 : 0];
wire memory_data_need;



assign packet_read_port[0] = {buffer_read_port[0][0], buffer_read_port[1][0], buffer_read_port[2][0]};
assign packet_read_port[1] = {buffer_read_port[0][1], buffer_read_port[1][1], buffer_read_port[2][1]};
assign packet_read_port[2] = {buffer_read_port[0][2], buffer_read_port[1][2], buffer_read_port[2][2]};
assign packet_read_port[3] = {buffer_read_port[0][3], buffer_read_port[1][3], buffer_read_port[2][3]};
assign packet_read_port[4] = {buffer_read_port[0][4], buffer_read_port[1][4], buffer_read_port[2][4]};
assign packet_read_port[5] = {buffer_read_port[0][5], buffer_read_port[1][5], buffer_read_port[2][5]};
assign packet_read_port[6] = {buffer_read_port[0][6], buffer_read_port[1][6], buffer_read_port[2][6]};
assign packet_read_port[7] = {buffer_read_port[0][7], buffer_read_port[1][7], buffer_read_port[2][7]};


assign packet_data_proc[0] = packet_data_proc_0;
assign packet_data_proc[1] = packet_data_proc_1;
assign packet_data_proc[2] = packet_data_proc_2;
assign packet_data_proc[3] = packet_data_proc_3;
assign packet_data_proc[4] = packet_data_proc_4;
assign packet_data_proc[5] = packet_data_proc_5;
assign packet_data_proc[6] = packet_data_proc_6;
assign packet_data_proc[7] = packet_data_proc_7;
assign packet_data_lemt_0  = packet_data_lemt[0];
assign packet_data_lemt_1  = packet_data_lemt[1];
assign packet_data_lemt_2  = packet_data_lemt[2];
assign packet_data_lemt_3  = packet_data_lemt[3];
assign packet_data_lemt_4  = packet_data_lemt[4];
assign packet_data_lemt_5  = packet_data_lemt[5];
assign packet_data_lemt_6  = packet_data_lemt[6];
assign packet_data_lemt_7  = packet_data_lemt[7];


genvar index_lemt;


ctrl_proc x0 ( .clk(clk), .rst(rst),
               .process_flows_enable(process_flows_enable),
               .process_done_init(process_done_init),
               .process_done_sort(process_done_sort),
               .process_done_find(process_done_find),
               .process_done_buld(process_done_buld),
               .process_done_dist(process_done_dist),
               .packet_enable_init(packet_enable_init),
               .packet_enable_dist(packet_enable_dist),
               .packet_inst_init(packet_inst_init),
               .packet_data_init(packet_data_init),
               .packet_inst_dist(packet_inst_dist),
               .packet_data_dist(packet_data_dist),
               .packet_inst_rcvd_0(packet_inst_rcvd[0]),
               .packet_inst_rcvd_1(packet_inst_rcvd[1]),
               .packet_inst_rcvd_2(packet_inst_rcvd[2]),
               .packet_inst_rcvd_3(packet_inst_rcvd[3]),
               .packet_inst_rcvd_4(packet_inst_rcvd[4]),
               .packet_inst_rcvd_5(packet_inst_rcvd[5]),
               .packet_inst_rcvd_6(packet_inst_rcvd[6]),
               .packet_inst_rcvd_7(packet_inst_rcvd[7]),
               /**output signal**/
               .process_done_flow(process_done_flow),
               .buffer_inst_reset(buffer_inst_reset),
               .buffer_fifo_reset(buffer_fifo_reset),
               .process_enable_init(process_enable_init),
               .process_enable_sort(process_enable_sort),
               .process_enable_find(process_enable_find),
               .process_enable_buld(process_enable_buld),
               .process_enable_dist(process_enable_dist),
               .packet_enable_send(packet_enable_send),
               .packet_inst_send(packet_inst_send),
               .packet_data_send(packet_data_send),
               .process_code_flag(process_code_flag),
               .packet_instr_proc(packet_instr_proc),
               .process_done_flag(process_done_flag),
               .memory_data_need(memory_data_need),
               .memory_chunk_update(memory_chunk_update)
             );


init_proc x1 ( .clk(clk), .rst(rst),
               .process_enable_init(process_enable_init),
               .packet_grant_send(packet_grant_send),
               /**output signal**/
               .process_done_init(process_done_init),
               .packet_data_send(packet_data_init),
               .packet_inst_send(packet_inst_init),
               .packet_enable_send(packet_enable_init)
             );


sort_proc x2 ( .clk(clk), .rst(rst),
               .process_enable_sort(process_enable_sort),
               .device_sort_code(process_code_flag),
               .buffer_input_0(packet_data_rcvd[0]),
               .buffer_input_1(packet_data_rcvd[1]),
               .buffer_input_2(packet_data_rcvd[2]),
               .buffer_input_3(packet_data_rcvd[3]),
               .buffer_input_4(packet_data_rcvd[4]),
               .buffer_input_5(packet_data_rcvd[5]),
               .buffer_input_6(packet_data_rcvd[6]),
               .buffer_input_7(packet_data_rcvd[7]),
               .buffer_data_count(buffer_data_count),
               .buffer_data_memory(buffer_rd_data),
               .memory_data_need(memory_data_need),
               .memory_addr_init_pv1(memory_addr_init_pv1),
               .memory_addr_init_pv0(memory_addr_init_pv0),
               .memory_addr_init_pi1(memory_addr_init_pi1),
               .memory_addr_init_pi0(memory_addr_init_pi0),
                /** output signal **/
               .process_done_sort(process_done_sort),
               .memory_wt_enable(memory_wt_enable_0),
               .memory_rd_enable(memory_rd_enable_0),
               .memory_addr_proc(memory_addr_proc_0),
               .memory_wt_data(memory_wt_data_0),
               .buffer_read_port(buffer_read_port[0]),
               .buffer_read_fifo(buffer_read_fifo[0])
             );


find_proc x3 ( .clk(clk), .rst(rst),
               .process_enable_find(process_enable_find),
               .buffer_input_0(packet_data_rcvd[0]),
               .buffer_input_1(packet_data_rcvd[1]),
               .buffer_input_2(packet_data_rcvd[2]),
               .buffer_input_3(packet_data_rcvd[3]),
               .buffer_input_4(packet_data_rcvd[4]),
               .buffer_input_5(packet_data_rcvd[5]),
               .buffer_input_6(packet_data_rcvd[6]),
               .buffer_input_7(packet_data_rcvd[7]),
               .buffer_empty_rcvd(buffer_empty_rcvd),
               .device_find_code(process_code_flag),
                /** ouput signal **/
               .process_done_find(process_done_find),
               .buffer_read_port(buffer_read_port[1]),
               .buffer_output_index(buffer_output_index),
               .buffer_output_data(buffer_output_data)
             );


dist_proc x4 ( .clk(clk), .rst(rst),
               .process_enable_dist(process_enable_dist),
               .buffer_rd_data(buffer_rd_data),
               .packet_data_find(buffer_output_data),
               .packet_instr_proc(packet_instr_proc),
               .process_done_flag(process_done_flag),
               .process_code_flag(process_code_flag),
               .memory_addr_init_ind(memory_addr_init_ind),
               .process_learn_enable(process_learn_enable),
                /**output signal**/
               .process_done_dist(process_done_dist),
               .memory_addr_proc(memory_addr_proc_1),
               .memory_rd_enable(memory_rd_enable_1),
               .memory_wt_enable(memory_wt_enable_1),
               .memory_wt_data(memory_wt_data_1),
               .buffer_rd_enable(buffer_read_fifo[1]),
               .packet_inst_send(packet_inst_dist),
               .packet_data_send(packet_data_dist),
               .packet_enable_send(packet_enable_dist)
             );


buld_proc x5 ( .clk(clk), .rst(rst),
               .process_enable_buld(process_enable_buld),
               .process_learn_enable(process_learn_enable),
               .buffer_input_0(packet_data_rcvd[0]),
               .buffer_input_1(packet_data_rcvd[1]),
               .buffer_input_2(packet_data_rcvd[2]),
               .buffer_input_3(packet_data_rcvd[3]),
               .buffer_input_4(packet_data_rcvd[4]),
               .buffer_input_5(packet_data_rcvd[5]),
               .buffer_input_6(packet_data_rcvd[6]),
               .buffer_input_7(packet_data_rcvd[7]),
               .buffer_empty_rcvd(buffer_empty_rcvd),
               .process_done_flag(process_done_flag),
               .packet_instr_proc(packet_instr_proc),
               .memory_addr_init_ind(memory_addr_init_ind),
                /** output signal **/
               .memory_addr_proc(memory_addr_proc_2),
               .memory_wt_enable(memory_wt_enable_2),
               .memory_rd_enable(memory_rd_enable_2),
               .memory_wt_data(memory_wt_data_2),
               .buffer_read_port(buffer_read_port[2]),
               .process_done_buld(process_done_buld)
             );


fifo_proc x6 ( .clk(clk), .rst(rst),
               .buffer_wt_enable(memory_data_ready),
               .buffer_rd_enable(buffer_rd_enable),
               .buffer_wt_data(memory_rd_data),
               .buffer_data_reset(buffer_fifo_reset),
               /** Output Signal **/
               .buffer_rd_data(buffer_rd_data),
               .buffer_data_count(buffer_data_count)
             );


generate

   for(index_lemt = 0; index_lemt < lemt_size; index_lemt = index_lemt + 1)
   begin : Interface

    send_proc x7 ( .clk(clk), .rst(rst),
                   .packet_enable_send(packet_enable_send[index_lemt]),
                   .packet_grant_send(packet_grant_send[index_lemt]),  /** The receiver is able to accept package **/
                   .packet_inst_send(packet_inst_send),
                   .packet_data_send(packet_data_send),
                   /** Output Signal **/
                   .packet_data_lemt(packet_data_lemt[index_lemt]),
                   .packet_ready_send(packet_ready_send[index_lemt])  /** Packet is required to sent to processor **/
                 );


    rcvd_proc x8 ( .clk(clk), .rst(rst),
                   .packet_ready_rcvd(packet_ready_rcvd[index_lemt]),
                   .packet_data_proc(packet_data_proc[index_lemt]),
                   .packet_read_port(packet_read_port[index_lemt]),
                   .buffer_rcvd_reset(buffer_inst_reset),
                   /*** Output Signal ***/
                   .packet_inst_rcvd(packet_inst_rcvd[index_lemt]),
                   .packet_data_rcvd(packet_data_rcvd[index_lemt]),
                   .buffer_empty_rcvd(buffer_empty_rcvd[index_lemt]),
                   .packet_grant_rcvd(packet_grant_rcvd[index_lemt])
				 );

   end

endgenerate


bank_proc x9 ( .clk(clk), .rst(rst),
               .memory_chunk_update(memory_chunk_update), /** Change the initial of address **/
               /** Memory Control from Dist **/
               .memory_addr_proc_0(memory_addr_proc_0),
               .memory_wt_data_0(memory_wt_data_0),
               .memory_rd_enable_0(memory_rd_enable_0),
               .memory_wt_enable_0(memory_wt_enable_0),
               /** Memory Contorl from Inht **/
               .memory_addr_proc_1(memory_addr_proc_1),
               .memory_wt_data_1(memory_wt_data_1),
               .memory_rd_enable_1(memory_rd_enable_1),
               .memory_wt_enable_1(memory_wt_enable_1),
               /** Memory Contorl from Cndt **/
               .memory_addr_proc_2(memory_addr_proc_2),
               .memory_wt_data_2(memory_wt_data_2),
               .memory_rd_enable_2(memory_rd_enable_2),
               .memory_wt_enable_2(memory_wt_enable_2),
               /** Output Signal **/
               .memory_addr_proc(memory_addr_proc),
               .memory_wt_data(memory_wt_data),
               .memory_wt_enable(memory_wt_enable),
               .memory_rd_enable(memory_rd_enable),
               .memory_data_ready(memory_data_ready),
               .memory_device_enable(memory_device_enable),
               /** For memory orgnization **/
               .memory_addr_init_pi0(memory_addr_init_pi0), /** Initial addr for index **/
               .memory_addr_init_pv0(memory_addr_init_pv0), /** Initial addr for value **/
               .memory_addr_init_pi1(memory_addr_init_pi1), /** Initial addr for index **/
               .memory_addr_init_pv1(memory_addr_init_pv1), /** Initial addr for value **/
               .memory_addr_init_ind(memory_addr_init_ind)  /** Initial addr for final index **/
             );


/** The behavior module of SRAM is required for debug purpose **/

sram_proc x10( .clk(clk), .rst(rst),
               .memory_addr_init_ind(memory_addr_init_ind),
               .memory_device_enable(memory_device_enable),
               .memory_addr_proc(memory_addr_proc),
	       .process_done_flow(process_done_flow),
               .memory_wt_data(memory_wt_data),
               .memory_wt_enable(memory_wt_enable),
               .memory_rd_enable(memory_rd_enable),
                /** output signal **/
	       .memory_check_ready(memory_check_ready),
               .memory_rd_data(memory_rd_data),
               .buffer_data_index(buffer_data_index)
             );

endmodule


// `include "../param.vh"

module rcvd_proc ( clk, rst,
                   packet_ready_rcvd,
				   packet_data_proc,
				   packet_read_port,
                   buffer_rcvd_reset,
				   /*** Output Signal ***/
                   packet_inst_rcvd,
				   packet_data_rcvd,
                   buffer_empty_rcvd,
				   packet_grant_rcvd
				 );

parameter  word_size = `word_size_para,
           buff_size = `buff_size_port;


input wire clk, rst;
input wire [word_size - 1 : 0] packet_data_proc;
input wire packet_ready_rcvd;  /** The package is coming into buffer **/
input wire buffer_rcvd_reset;
input wire [2 : 0] packet_read_port;


output reg packet_grant_rcvd;  /** The receiver is able to receiver **/
output reg buffer_empty_rcvd;
output reg [word_size - 1 : 0] packet_inst_rcvd;
output reg [word_size - 1 : 0] packet_data_rcvd;


reg [word_size - 1 : 0] buffer_data_rcvd [buff_size - 1 : 0];
reg header_ready_read, packet_ready_mask;
reg buffer_full_init, buffer_full_loop;
reg buffer_done_init, buffer_done_loop;
reg buffer_rd_enable, buffer_wt_enable;
reg [2 : 0] buffer_rd_index, buffer_wt_index;
reg [2 : 0] buffer_data_count;
reg index_read_reset, index_wten_reset;
reg buffer_data_reset;



integer index;


/** For each transaction, the first package is always the instruction **/


always @(posedge clk)
begin
  if(~rst) begin
    packet_ready_mask <= 1'b0;
  end
  else begin
    packet_ready_mask <= packet_ready_rcvd;
  end
end


always @(*)
begin /** the instruction is ready to read **/
  if((packet_ready_mask == 1'b0)&&(packet_ready_rcvd == 1'b1)) begin
    header_ready_read = 1'b1;
  end
  else begin
    header_ready_read = 1'b0;
  end
end


always @(posedge clk)
begin
  if((~rst)||(buffer_rcvd_reset == 1'b1)) begin
    packet_inst_rcvd <= {word_size{1'b0}};
  end
  else if(header_ready_read == 1'b1) begin
    packet_inst_rcvd <= packet_data_proc;
  end
  else begin
    packet_inst_rcvd <= packet_inst_rcvd;
  end
end


always @(*)
begin
  buffer_data_reset = (header_ready_read == 1'b1)&&(packet_data_proc[word_size - 1] == 1'b0);
end

/** Write the received package into the receiver buffer except the instruction **/


always @(*)
begin
  if((packet_ready_rcvd == 1'b1)&&(header_ready_read == 1'b0)&&(packet_grant_rcvd == 1'b1)) begin
    buffer_wt_enable = 1'b1;
  end
  else begin
    buffer_wt_enable = 1'b0;
  end
end


always @(posedge clk)
begin
  if((~rst)||(buffer_data_reset == 1'b1)) begin
    for(index = 0; index < buff_size; index = index + 1)
      buffer_data_rcvd[index] <= {word_size{1'b0}};
  end
  else if(buffer_wt_enable == 1'b1) begin
    buffer_data_rcvd[buffer_wt_index] <= packet_data_proc;
  end
  else begin
    for(index = 0; index < buff_size; index = index + 1)
      buffer_data_rcvd[index] <= buffer_data_rcvd[index];
  end
end


always @(posedge clk)
begin
  if((~rst)||(buffer_data_reset == 1'b1)) begin
    buffer_data_count <= {1'b0, {buff_size{1'b0}}};
  end
  else if((buffer_wt_enable == 1'b1)&&(buffer_rd_enable == 1'b0)) begin
    buffer_data_count <= buffer_data_count + 1'b1;
  end
  else if((buffer_wt_enable == 1'b0)&&(buffer_rd_enable == 1'b1)) begin
    buffer_data_count <= buffer_data_count - 1'b1;
  end
  else begin
    buffer_data_count <= buffer_data_count;
  end
end


always @(*)
begin
  buffer_rd_enable = (packet_read_port != 3'b000);
end


always @(posedge clk)
begin
  if((~rst)||(index_read_reset == 1'b1)) begin
    buffer_rd_index <= {buff_size{1'b0}};
  end
  else if(buffer_rd_enable == 1'b1) begin /** The value is found for next tree level **/
    buffer_rd_index <= buffer_rd_index + 1'b1;
  end
  else begin
    buffer_rd_index <= buffer_rd_index;
  end
end


always @(posedge clk)
begin
  if((~rst)||(index_wten_reset == 1'b1)) begin
    buffer_wt_index <= {buff_size{1'b0}};
  end
  else if(buffer_wt_enable == 1'b1) begin /** The value is found for next tree level **/
    buffer_wt_index <= buffer_wt_index + 1'b1;
  end
  else begin
    buffer_wt_index <= buffer_wt_index;
  end
end


always @(*)
begin
  index_read_reset  = ((buffer_rd_index == (buff_size - 1))&&(buffer_rd_enable == 1'b1))||(buffer_rcvd_reset == 1'b1);
  index_wten_reset  = ((buffer_wt_index == (buff_size - 1))&&(buffer_wt_enable == 1'b1))||(buffer_rcvd_reset == 1'b1);
end


always @(posedge clk)
begin
  if(~rst) begin
    packet_grant_rcvd <= 1'b0;
  end
  else begin
    packet_grant_rcvd <= (buffer_full_init == 1'b0)&&(buffer_full_loop == 1'b0);
  end
end


always @(*)
begin
  if((buffer_data_count == (buff_size - 1))&&(buffer_wt_enable == 1'b1)&&(buffer_rd_enable == 1'b0)) begin
    buffer_full_init = 1'b1;
  end
  else begin
    buffer_full_init = 1'b0;
  end
end


always @(*)
begin
  if((buffer_data_count == buff_size)&&(buffer_rd_enable == 1'b0)) begin
    buffer_full_loop = 1'b1;
  end
  else begin
    buffer_full_loop = 1'b0;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_empty_rcvd <= 1'b0;
  end
  else begin
    buffer_empty_rcvd <= (buffer_done_init == 1'b1)||(buffer_done_loop == 1'b1);
  end
end


always @(*)
begin
  if((buffer_data_count == 4'b0001)&&(buffer_wt_enable == 1'b0)&&(buffer_rd_enable == 1'b1)) begin
    buffer_done_init = 1'b1;
  end
  else begin
    buffer_done_init = 1'b0;
  end
end


always @(*)
begin
  if((buffer_data_count == 4'b0000)&&(buffer_wt_enable == 1'b0)) begin
    buffer_done_loop = 1'b1;
  end
  else begin
    buffer_done_loop = 1'b0;
  end
end


always @(*)
begin
  packet_data_rcvd = buffer_data_rcvd[buffer_rd_index];
end




endmodule


// `include "../param.vh"

module send_proc ( clk, rst,
                   packet_enable_send,
                   packet_grant_send,  /** The receiver is able to accept package **/
                   packet_inst_send,
                   packet_data_send,
                   /** Output Signal **/
                   packet_ready_send,  /** Packet is required to sent to processor **/
                   packet_data_lemt
                 );

parameter word_size = `word_size_para;


input wire clk, rst;
input wire packet_enable_send;
input wire packet_grant_send;  /** The receiver is able to accept package **/
input wire [word_size - 1 : 0] packet_inst_send;
input wire [word_size - 1 : 0] packet_data_send;

output reg packet_ready_send;  /** Packet is required to sent to processor **/
output reg [word_size - 1 : 0] packet_data_lemt;


reg [1 : 0] state_send, next_state_send;


always @(posedge clk)
begin
  if(~rst) begin /** This is down when all packets is sent **/
    packet_ready_send <= 1'b0;
  end
  else begin
    packet_ready_send <= packet_enable_send;
  end
end


/** Inst is required for each time the transaction is interrupted **/


always @(posedge clk)
begin
  if(~rst) begin
    state_send <= 2'b00;
  end
  else begin
    state_send <= next_state_send;
  end
end


always @(*)
begin /** If the receiver is full, stall in current phase **/
  case(state_send)
    2'b00  : begin
               if(packet_enable_send == 1'b1) begin
                 next_state_send = 2'b01;
               end
               else begin
                 next_state_send = 2'b00;
               end
             end
    2'b01  : begin
               if(packet_enable_send == 1'b1) begin
                 next_state_send = packet_grant_send ? 2'b10 : 2'b01;
               end
               else begin
                 next_state_send = 2'b00;
               end
             end
    2'b10  : begin
               if(packet_enable_send == 1'b1) begin
                 next_state_send = 2'b10;
               end
               else begin
                 next_state_send = 2'b00;
               end
             end
    default: begin
               next_state_send = 2'b00;
             end
  endcase
end


always @(posedge clk)
begin
  if(~rst) begin
    packet_data_lemt <= {word_size{1'b0}};
  end
  else if(next_state_send == 2'b01) begin
    packet_data_lemt <= packet_inst_send;
  end
  else begin
    packet_data_lemt <= packet_data_send;
  end
end


endmodule


/** logic unit used to merge the sorted array received from elements **/
// `include "../param.vh"

module sort_proc ( clk, rst,
                   process_enable_sort,
                   device_sort_code,
                   buffer_input_0,
                   buffer_input_1,
                   buffer_input_2,
                   buffer_input_3,
                   buffer_input_4,
                   buffer_input_5,
                   buffer_input_6,
                   buffer_input_7,
                   buffer_data_memory,
                   buffer_data_count,
                   memory_data_need,
                   memory_addr_init_pv1,
                   memory_addr_init_pv0,
                   memory_addr_init_pi1,
                   memory_addr_init_pi0,
                   /** output signal **/
                   process_done_sort,
                   memory_wt_enable,
                   memory_rd_enable,
                   memory_addr_proc,
                   memory_wt_data,
				   buffer_read_fifo,
                   buffer_read_port
                 );

parameter  word_size = `word_size_para,
           lemt_size = `lemt_size_para,
           addr_size = `addr_size_proc;

input  wire clk, rst;
input  wire process_enable_sort;
input  wire [word_size - 1 : 0] buffer_input_0, buffer_input_1;
input  wire [word_size - 1 : 0] buffer_input_2, buffer_input_3;
input  wire [word_size - 1 : 0] buffer_input_4, buffer_input_5;
input  wire [word_size - 1 : 0] buffer_input_6, buffer_input_7;
input  wire device_sort_code, memory_data_need;
input  wire [word_size - 1 : 0] buffer_data_memory;
input  wire [4 : 0] buffer_data_count;
input  wire [addr_size - 1 : 0] memory_addr_init_pv1;
input  wire [addr_size - 1 : 0] memory_addr_init_pv0;
input  wire [addr_size - 1 : 0] memory_addr_init_pi1;
input  wire [addr_size - 1 : 0] memory_addr_init_pi0;


output wire process_done_sort;
output wire memory_wt_enable , memory_rd_enable;
output wire buffer_read_fifo;
output wire [lemt_size - 1 : 0] buffer_read_port;
output wire [addr_size - 1 : 0] memory_addr_proc;
output wire [word_size - 1 : 0] memory_wt_data;


wire [word_size - 1 : 0] buffer_temper_1_0, buffer_temper_1_1;
wire [word_size - 1 : 0] buffer_temper_0_0, buffer_temper_0_1;
wire [word_size - 1 : 0] buffer_temper_0_2, buffer_temper_0_3;
wire [word_size - 1 : 0] buffer_output_data;
wire [2 : 0] process_enable_tree;
wire [3 : 0] buffer_full_1, buffer_find_1;
wire [1 : 0] buffer_full_2, buffer_find_2;
wire buffer_input_find;
wire [lemt_size - 1 : 0] buffer_full_sort; /** used to indicate whether read from lower buffer **/
wire [lemt_size - 1 : 0] buffer_find_sort;



tree_unit x1_1 ( .clk(clk), .rst(rst),
                 .process_enable_tree(process_enable_tree[0]),
                 .buffer_input_find(buffer_find_1[0]),
				 .buffer_input_full(buffer_full_1[0]),
                 .buffer_input_0(buffer_input_0),
				 .buffer_input_1(buffer_input_1),
				 .buffer_enable_reset(buffer_enable_reset),
				 .device_sort_code(device_sort_code),
                  /** Output Signal **/
				 .buffer_output_full(buffer_full_sort[1 : 0]),
                 .buffer_output_data(buffer_temper_0_0),
                 .buffer_output_find(buffer_find_sort[1 : 0])
               );



tree_unit x1_2 ( .clk(clk), .rst(rst),
                 .process_enable_tree(process_enable_tree[0]),
                 .buffer_input_find(buffer_find_1[1]),
				 .buffer_input_full(buffer_full_1[1]),
                 .buffer_input_0(buffer_input_2),
				 .buffer_input_1(buffer_input_3),
                 .buffer_enable_reset(buffer_enable_reset),
				 .device_sort_code(device_sort_code),
                  /** Output Signal **/
				 .buffer_output_full(buffer_full_sort[3 : 2]),
                 .buffer_output_data(buffer_temper_0_1),
                 .buffer_output_find(buffer_find_sort[3 : 2])
               );



tree_unit x1_3 ( .clk(clk), .rst(rst),
                 .process_enable_tree(process_enable_tree[0]),
                 .buffer_input_find(buffer_find_1[2]),
				 .buffer_input_full(buffer_full_1[2]),
                 .buffer_input_0(buffer_input_4),
				 .buffer_input_1(buffer_input_5),
				 .buffer_enable_reset(buffer_enable_reset),
				 .device_sort_code(device_sort_code),
                  /** Output Signal **/
				 .buffer_output_full(buffer_full_sort[5 : 4]),
                 .buffer_output_data(buffer_temper_0_2),
                 .buffer_output_find(buffer_find_sort[5 : 4])
               );


tree_unit x1_4 ( .clk(clk), .rst(rst),
                 .process_enable_tree(process_enable_tree[0]),
                 .buffer_input_find(buffer_find_1[3]),
				 .buffer_input_full(buffer_full_1[3]),
                 .buffer_input_0(buffer_input_6),
				 .buffer_input_1(buffer_input_7),
				 .buffer_enable_reset(buffer_enable_reset),
				 .device_sort_code(device_sort_code),
                  /** Output Signal **/
				 .buffer_output_full(buffer_full_sort[7 : 6]),
                 .buffer_output_data(buffer_temper_0_3),
                 .buffer_output_find(buffer_find_sort[7 : 6])
               );


/** The second level of maxer in the tree structure **/


tree_unit x2_1 ( .clk(clk), .rst(rst),
                 .process_enable_tree(process_enable_tree[1]),
                 .buffer_input_find(buffer_find_2[0]),
				 .buffer_input_full(buffer_full_2[0]),
                 .buffer_input_0(buffer_temper_0_0),
				 .buffer_input_1(buffer_temper_0_1),
				 .buffer_enable_reset(buffer_enable_reset),
				 .device_sort_code(device_sort_code),
                  /** Output Signal **/
				 .buffer_output_full(buffer_full_1[1 : 0]),
                 .buffer_output_data(buffer_temper_1_0),
                 .buffer_output_find(buffer_find_1[1 : 0])
                );

tree_unit x2_2 ( .clk(clk), .rst(rst),
                 .process_enable_tree(process_enable_tree[1]),
                 .buffer_input_find(buffer_find_2[1]),
				 .buffer_input_full(buffer_full_2[1]),
                 .buffer_input_0(buffer_temper_0_2),
				 .buffer_input_1(buffer_temper_0_3),
				 .buffer_enable_reset(buffer_enable_reset),
				 .device_sort_code(device_sort_code),
                  /** Output Signal **/
				 .buffer_output_full(buffer_full_1[3 : 2]),
                 .buffer_output_data(buffer_temper_1_1),
                 .buffer_output_find(buffer_find_1[3 : 2])
                );

/** The final level of maxer in the tree structure **/


tree_unit x3_1 ( .clk(clk), .rst(rst),
                 .process_enable_tree(process_enable_tree[2]),
                 .buffer_input_find(buffer_input_find),
                 .buffer_input_full(1'b0),
                 .buffer_input_0(buffer_temper_1_0),
                 .buffer_input_1(buffer_temper_1_1),
				 .buffer_enable_reset(buffer_enable_reset),
				 .device_sort_code(device_sort_code),
                  /** Output Signal **/
                 .buffer_output_full(buffer_full_2),
                 .buffer_output_data(buffer_output_data),
                 .buffer_output_find(buffer_find_2)
                );


tree_ctrl ctrl ( .clk(clk), .rst(rst),
                 .process_enable_sort(process_enable_sort),
				 .device_sort_code(device_sort_code),
				 .buffer_data_count(buffer_data_count),
				 .buffer_data_memory(buffer_data_memory),
				 .buffer_data_output(buffer_output_data),
				 .memory_data_need(memory_data_need),
				 .memory_addr_init_pv1(memory_addr_init_pv1),
				 .memory_addr_init_pv0(memory_addr_init_pv0),
				 .memory_addr_init_pi1(memory_addr_init_pi1),
				 .memory_addr_init_pi0(memory_addr_init_pi0),
				 .buffer_full_sort(buffer_full_sort),
				 .buffer_find_sort(buffer_find_sort),
				  /** output signal **/
				 .process_enable_tree(process_enable_tree),
				 .memory_wt_enable(memory_wt_enable),
				 .memory_rd_enable(memory_rd_enable),
				 .memory_addr_proc(memory_addr_proc),
				 .memory_wt_data(memory_wt_data),
				 .buffer_read_fifo(buffer_read_fifo),
				 .buffer_read_port(buffer_read_port),
                 .process_done_sort(process_done_sort),
				 .buffer_output_find(buffer_input_find),
				 .buffer_enable_reset(buffer_enable_reset)
				);



endmodule


// `include "../param.vh"

module sram_proc ( clk, rst,
                   memory_addr_init_ind,
                   memory_device_enable,
		   process_done_flow,
                   memory_addr_proc,
                   memory_wt_data,
                   memory_wt_enable,
                   memory_rd_enable,
				   /** output signal **/
		   memory_check_ready,
                   memory_rd_data,
				   buffer_data_index
                 );


parameter addr_size = `addr_size_proc,
	  word_size = `word_size_para,
	      bank_size =  `memory_size_proc_para,
		  pckt_size = `memory_size_packet;


input wire clk, rst;
input wire [addr_size - 1 : 0] memory_addr_init_ind;
input wire [addr_size - 1 : 0] memory_addr_proc; // Change as you change size of SRAM
input wire memory_device_enable;
input wire process_done_flow;
input wire [31 : 0] memory_wt_data;
input wire memory_wt_enable, memory_rd_enable;

output reg [31 : 0] memory_rd_data;
output reg [31 : 0] buffer_data_index;
output reg memory_check_ready;


reg [31 : 0] register_proc [bank_size - 1 : 0];   /** Active Column and Learn Packet **/ /** Index = 4'b0000 **/
reg [addr_size - 1 : 0] memory_data_count;
reg [addr_size - 1 : 0] memory_index_check;
reg memory_check_done;


integer index;


always @(posedge clk)
begin
  if(~rst) begin
	memory_rd_data <= {word_size{1'b0}};
  end
  else if((memory_device_enable == 1'b1)&&(memory_rd_enable == 1'b1)) begin
	memory_rd_data <= {register_proc[memory_addr_proc]};
  end
  else begin
	memory_rd_data <= {memory_rd_data};
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    for(index = 0; index < bank_size; index = index + 1)
      register_proc[index] <= {word_size{1'b0}};
  end
  else if((memory_device_enable == 1'b1)&&(memory_wt_enable == 1'b1)) begin
    for(index = 0; index < bank_size; index = index + 1)
      register_proc[index] <= register_proc[index];
      register_proc[memory_addr_proc] <= {memory_wt_data};
  end
  else begin
    for(index = 0; index < bank_size; index = index + 1)
      register_proc[index] <= register_proc[index];
  end
end


always @(*)
begin
  memory_check_done = (memory_data_count == (pckt_size - 1));
end


always @(posedge clk)
begin
  if(~rst) begin
	buffer_data_index <= {word_size{1'b0}};
  end
  else begin
	buffer_data_index <= {register_proc[memory_index_check]};
  end
end


always @(posedge clk)
begin
  if(~rst) begin
	memory_index_check <= {addr_size{1'b0}};
  end
  else if(process_done_flow == 1'b1) begin
	memory_index_check <= {memory_addr_init_ind};
  end
  else if(memory_check_ready == 1'b1) begin
	memory_index_check <= {memory_index_check + 1'b1};
  end
  else begin
	memory_index_check <= {memory_index_check};
  end
end


always @(posedge clk)
begin
  if((~rst)||(memory_check_done == 1'b1)) begin
	memory_check_ready <= {1'b0};
  end
  else if(process_done_flow == 1'b1) begin
	memory_check_ready <= {1'b1};
  end
  else begin
	memory_check_ready <= {memory_check_ready};
  end
end


always @(posedge clk)
begin
  if((~rst)||(memory_check_done == 1'b1)) begin
	memory_data_count <= {addr_size{1'b0}};
  end
  else if(memory_check_ready == 1'b1) begin
	memory_data_count <= {memory_data_count + 1'b1};
  end
  else begin
	memory_data_count <= {memory_data_count};
  end
end



endmodule


/** The control unit of the tree structure **/
// `include "../param.vh"

module tree_ctrl( clk, rst,
                  process_enable_sort,
				  device_sort_code,
				  memory_data_need,
				  buffer_data_output,
				  buffer_data_count,
                  buffer_data_memory,
				  buffer_full_sort,
				  buffer_find_sort,
				  memory_addr_init_pv1,
				  memory_addr_init_pv0,
				  memory_addr_init_pi1,
				  memory_addr_init_pi0,
				  /** output signal **/
				  process_enable_tree,
				  memory_wt_enable,
				  memory_rd_enable,
				  memory_addr_proc,
				  memory_wt_data,
				  buffer_read_fifo,
				  buffer_read_port,
                  process_done_sort,
				  buffer_output_find,
				  buffer_enable_reset
				);

parameter  word_size = `word_size_para,
           tree_size = `tree_size_para,
           lemt_size = `lemt_size_para,
           addr_size = `addr_size_proc,
           buff_size = `buff_size_tree,
           packet_count_desire = `packet_count_desired_para;


input wire clk, rst;
input wire process_enable_sort, device_sort_code;
input wire memory_data_need;
input wire [word_size - 1 : 0] buffer_data_output;
input wire [word_size - 1 : 0] buffer_data_memory;
input wire [addr_size - 1 : 0] memory_addr_init_pv1;
input wire [addr_size - 1 : 0] memory_addr_init_pv0;
input wire [addr_size - 1 : 0] memory_addr_init_pi1;
input wire [addr_size - 1 : 0] memory_addr_init_pi0;
input wire [4 : 0] buffer_data_count;
input wire [lemt_size - 1 : 0] buffer_full_sort;
input wire [lemt_size - 1 : 0] buffer_find_sort;


output reg [2 : 0] process_enable_tree;
output reg process_done_sort;
output reg [addr_size - 1 : 0] memory_addr_proc;
output reg [word_size - 1 : 0] memory_wt_data;
output reg memory_wt_enable, memory_rd_enable;
output reg buffer_output_find, buffer_read_fifo;
output reg [lemt_size - 1 : 0] buffer_read_port;
output reg buffer_enable_reset;


reg [addr_size - 1 : 0] memory_addr_read, memory_addr_wten;
reg [addr_size - 1 : 0] memory_init_read, memory_init_wten;
reg [addr_size - 1 : 0] memory_offt_read, memory_offt_wten;
reg [word_size - 1 : 0] memory_wt_buffer;
reg buffer_data_fully, buffer_data_empty;
reg [2 : 0] state_sort, next_state_sort;
reg [3 : 0] logic_timer_tree;
reg logic_timer_count, logic_timer_reset;
reg [7 : 0] packet_count_find;
reg [word_size - 1 : 0] buffer_memory_topper, buffer_output_topper;
reg topper_value_flag, topper_equal_flag, buffer_value_flag;
reg memory_wten_done, memory_wten_source;
reg maximum_data_found, minimum_data_found;
reg process_done_wait, packet_count_done;
reg memory_updt_read, memory_read_reset;
reg buffer_data_mask;


genvar index;


generate

   always @(posedge clk)
   begin
     if((~rst)||(process_done_sort == 1'b1)) begin
	   process_enable_tree[0] <= 1'b0;
	 end
	 else if(process_enable_sort == 1'b1) begin
	   process_enable_tree[0] <= 1'b1;
     end
	 else begin
	   process_enable_tree[0] <= process_enable_tree[0];
	 end
   end


   for(index = 1; index < tree_size; index = index + 1)
   begin : Execution_Lane

	   always @(posedge clk)
	   begin
	     if((~rst)||(process_done_sort == 1'b1)) begin
		   process_enable_tree[index] <= 1'b0;
	     end
		 else begin
		   process_enable_tree[index] <= process_enable_tree[index - 1];
		 end
	   end

   end


endgenerate



generate


   for(index = 0; index < lemt_size; index = index + 1)
   begin : read_port

	 always @(*)
	 begin
        buffer_read_port[index] = (buffer_full_sort[index] == 1'b0)&&(buffer_find_sort[index] == 1'b1);
	 end

   end


endgenerate



always @(posedge clk)
begin
  if(~rst) begin
    buffer_enable_reset <= 1'b0;
  end
  else begin
    buffer_enable_reset <= (process_done_sort == 1'b1);
  end
end



always @(posedge clk)
begin
  if(~rst) begin
    process_done_wait <= 1'b0;
  end
  else begin
    process_done_wait <= (state_sort == 3'b010)&&(logic_timer_tree == 4'b0011);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    process_done_sort <= 1'b0;
  end
  else begin
    process_done_sort <= (state_sort != 3'b000)&&(next_state_sort == 3'b000);
  end
end


/** The logic unit used to merge data received from elements and ones in sram **/


always @(posedge clk)
begin
  if(~rst) begin
    state_sort <= 3'b000;
  end
  else begin
    state_sort <= next_state_sort;
  end
end


always @(*)
begin
  case(state_sort)
    3'b000 : begin
	           if(process_enable_sort == 1'b1) begin
			     next_state_sort = memory_data_need ? 3'b001 : 3'b010;
			   end
			   else begin
			     next_state_sort = 3'b000;
			   end
			 end
	3'b001 : begin /** read data from sram round into buffer for next phase **/
	           if(buffer_data_fully == 1'b1) begin
			     next_state_sort = buffer_data_mask ? 3'b011 : 3'b010;
			   end
			   else begin
			     next_state_sort = 3'b001;
			   end
			 end
	3'b010 : begin /** read data from both source into topper to compare **/
	           if(process_done_wait == 1'b1) begin
			     next_state_sort = 3'b011;
			   end
			   else begin
			     next_state_sort = 3'b010;
			   end
			 end
	3'b011 : begin /** compare data from both source for max value and write **/
	           if(packet_count_done == 1'b1) begin
			     next_state_sort = 3'b110;
			   end
			   else begin
			     next_state_sort = 3'b100;
			   end
			 end
	3'b100 : begin /** write the final result of sort back to processor memory  **/
	           if(memory_wten_done == 1'b1) begin
			      next_state_sort = buffer_data_empty ? 3'b101 : 3'b011;
			   end
			   else begin
			      next_state_sort = 3'b100;
			   end
			 end
	3'b101 : begin /** Wait until the last write to memory is done before read **/
	           if(logic_timer_tree == 4'b0000) begin
			      next_state_sort = 3'b001;
			   end
			   else begin
			      next_state_sort = 3'b101;
			   end
			 end
        3'b110 : begin /** Write the done flag into both value and index sections **/
	           if(memory_wten_done == 1'b1) begin
			      next_state_sort = 3'b000;
			   end
			   else begin
			      next_state_sort = 3'b110;
			   end
			 end
	default: next_state_sort = 3'b000;
  endcase
end


always @(posedge clk)
begin /** don't need to trigger the tree again **/
  if((~rst)||(process_enable_sort == 1'b1)) begin
    buffer_data_mask <= 1'b0;
  end
  else if(state_sort == 3'b100) begin
    buffer_data_mask <= 1'b1;
  end
  else begin
    buffer_data_mask <= buffer_data_mask;
  end
end


/** state_sort == 3'b001, read data from memroy sram into the buffer unitl full **/


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_read <= {addr_size{1'b0}};
  end
  else begin
    memory_addr_read <= {memory_init_read + memory_offt_read};
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_done_sort == 1'b1)) begin
    memory_offt_read <= {addr_size{1'b0}};
  end
  else if((state_sort == 3'b001)&&(memory_updt_read == 1'b1)) begin
    memory_offt_read <= memory_offt_read + 1;
  end
  else begin
    memory_offt_read <= memory_offt_read;
  end
end


always @(*)
begin
  if((memory_updt_read == 1'b0)&&(device_sort_code == 1'b1)) begin
    memory_init_read = memory_addr_init_pv0;
  end
  else begin
    memory_init_read = memory_addr_init_pi0;
  end
end


always @(posedge clk)
begin
  if((~rst)||(memory_read_reset == 1'b1)) begin
    memory_updt_read <= 1'b0;
  end
  else if((next_state_sort == 3'b001)&&(device_sort_code == 1'b1)) begin
    memory_updt_read <= ~memory_updt_read;
  end
  else if((next_state_sort == 3'b001)&&(device_sort_code == 1'b0)) begin
    memory_updt_read <= 1'b1;
  end
  else begin
    memory_updt_read <= memory_updt_read;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_rd_enable <= 1'b0;
  end
  else begin
    memory_rd_enable <= (next_state_sort == 3'b001);
  end
end


always @(*)
begin
  memory_read_reset = (state_sort == 3'b001)&&(next_state_sort != 3'b001);
  buffer_data_fully = (logic_timer_tree == (buff_size - 1));
end


/** state_sort == 3'b010, read data from both source into topper buffer to compare **/
/** state_sort == 3'b011, compare the data from both source to decide written data **/

always @(*)
begin
  topper_equal_flag = (buffer_output_topper == buffer_memory_topper);
  topper_value_flag = (buffer_output_topper >= buffer_memory_topper);
  buffer_value_flag = (buffer_data_output <= buffer_data_memory);
end


always @(*)
begin /** 1 = output buffer, 0 = memory buffer **/
  maximum_data_found = (topper_equal_flag ? buffer_value_flag : topper_value_flag);
  minimum_data_found = (topper_value_flag == 1'b0);
end


always @(posedge clk)
begin
  if((~rst)||(process_done_sort == 1'b1)) begin
    memory_wten_source <= 1'b0;
  end
  else if(memory_data_need == 1'b0) begin /** first round of merge **/
    memory_wten_source <= 1'b1;
  end
  else if(state_sort == 3'b011) begin
    memory_wten_source <= device_sort_code ? maximum_data_found : minimum_data_found;
  end
  else begin
    memory_wten_source <= memory_wten_source;
  end
end


always @(*)
begin
  case(state_sort)
    3'b010 : buffer_read_fifo = (process_done_wait == 1'b1);
    3'b100 : buffer_read_fifo = (memory_wten_source == 1'b0);
	default: buffer_read_fifo = 1'b0;
  endcase
end


always @(*)
begin
  case(state_sort)
    3'b010 : buffer_output_find = (process_done_wait == 1'b1);
    3'b100 : buffer_output_find = (memory_wten_source == 1'b1);
	default: buffer_output_find = 1'b0;
  endcase
end


always @(posedge clk)
begin
  if((~rst)||(process_done_sort == 1'b1)) begin
    buffer_memory_topper <= {word_size{1'b0}};
  end
  else if(buffer_read_fifo == 1'b1) begin
    buffer_memory_topper <= buffer_data_memory;
  end
  else begin
    buffer_memory_topper <= buffer_memory_topper;
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_done_sort == 1'b1)) begin
    buffer_output_topper <= {word_size{1'b0}};
  end
  else if(buffer_output_find == 1'b1) begin
    buffer_output_topper <= buffer_data_output;
  end
  else begin
    buffer_output_topper <= buffer_output_topper;
  end
end


/** state_sort == 3'b100, write the final result of sort back to processor memory **/


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_wten <= {addr_size{1'b0}};
  end
  else begin
    memory_addr_wten <= memory_init_wten + memory_offt_wten;
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_done_sort == 1'b1)) begin
    memory_offt_wten <= {addr_size{1'b0}};
  end
  else if((state_sort == 3'b100)&&(memory_wten_done == 1'b1)) begin
    memory_offt_wten <= memory_offt_wten + 1;
  end
  else begin
    memory_offt_wten <= memory_offt_wten;
  end
end


always @(*)
begin
  if((logic_timer_tree == 4'b0000)&&(device_sort_code == 1'b1)) begin
    memory_init_wten = memory_addr_init_pv1;
  end
  else begin
    memory_init_wten = memory_addr_init_pi1;
  end
end


always @(*)
begin
  memory_wten_done = device_sort_code ? (logic_timer_tree == 4'b0001) : (logic_timer_tree == 4'b0000);
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_wt_enable <= 1'b0;
  end
  else begin
    memory_wt_enable <= (state_sort == 3'b100)||(state_sort == 3'b110);
  end
end


always @(*)
begin
  buffer_data_empty = (buffer_data_count == {3'b000, 2'b10})&&(memory_data_need == 1'b1);
end


always @(*)
begin
  case(state_sort)
    3'b100 : memory_wt_buffer = {memory_wten_source ? buffer_output_topper : buffer_memory_topper};
    3'b110 : memory_wt_buffer = {word_size{1'b1}};
    default: memory_wt_buffer = {word_size{1'b0}};
  endcase
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_wt_data <= {word_size{1'b0}};
  end
  else begin
    memory_wt_data <= memory_wt_buffer;
  end
end


/** calculat the number of package has beed written into the sram **/


always @(posedge clk)
begin
  if((~rst)||(process_done_sort == 1'b1)) begin
    packet_count_find <= 8'b00000000;
  end
  else if((memory_wten_done == 1'b1)&&(state_sort == 3'b100)) begin
    packet_count_find <= packet_count_find + 1'b1;
  end
  else begin
    packet_count_find <= packet_count_find;
  end
end


always @(*)
begin
  packet_count_done = (packet_count_find == packet_count_desire);
end


always @(*)
begin
  case(state_sort)
    3'b001 : memory_addr_proc = {memory_addr_read};
    default: memory_addr_proc = {memory_addr_wten};
  endcase
end


always @(posedge clk)
begin
  if((~rst)||(logic_timer_reset == 1'b1)) begin
    logic_timer_tree <= 4'b0000;
  end
  else if(logic_timer_count == 1'b1) begin
    logic_timer_tree <= logic_timer_tree + 1'b1;
  end
  else begin
    logic_timer_tree <= logic_timer_tree;
  end
end


always @(*)
begin
  case(state_sort)
	3'b001 : logic_timer_count = 1'b1;
	3'b010 : logic_timer_count = 1'b1;
	3'b100 : logic_timer_count = 1'b1;
	3'b110 : logic_timer_count = 1'b1;
	default: logic_timer_count = 1'b0;
  endcase
end


always @(*)
begin
  case(state_sort)
	3'b001 : logic_timer_reset = (next_state_sort != 3'b001);
	3'b010 : logic_timer_reset = (next_state_sort != 3'b010);
	3'b100 : logic_timer_reset = (next_state_sort != 3'b100);
	3'b110 : logic_timer_reset = (next_state_sort != 3'b110);
	default: logic_timer_reset = 1'b0;
  endcase
end


endmodule


/** logic unit used to find the max one among data received from element units **/
// `include "../param.vh"

module tree_unit( clk, rst,
                  process_enable_tree,
                  buffer_input_find,
				  buffer_input_full,
                  buffer_input_0,
				  buffer_input_1,
				  buffer_enable_reset,
				  device_sort_code,
                  /** Output Signal **/
				  buffer_output_full,
                  buffer_output_data,
                  buffer_output_find
                );

parameter word_size = `word_size_para,
          buff_size = `buff_size_tree;

input wire clk, rst;
input wire process_enable_tree;
input wire buffer_input_find;
input wire buffer_input_full;
input wire [word_size - 1 : 0] buffer_input_0;
input wire [word_size - 1 : 0] buffer_input_1;
input wire device_sort_code;
input wire buffer_enable_reset;


output reg [word_size - 1 : 0] buffer_output_data;
output reg [1 : 0] buffer_output_full;
output reg [1 : 0] buffer_output_find;


reg [word_size - 1 : 0] buffer_data_mxtr [buff_size - 1 : 0];
reg [1 : 0] buffer_rd_index, buffer_wt_index;
reg [2 : 0] buffer_data_count;
reg buffer_wt_enable, buffer_rd_enable;
reg buffer_data_full, buffer_init_full, buffer_loop_full;
reg index_wt_reset, index_rd_reset;
reg buffer_temper_find, buffer_buffed_find;
reg [1 : 0] state_unit, next_state_unit;
reg buffer_data_done;
reg input_zeros_0, input_zeros_1;
reg none_zero_find, true_zero_find;


integer index;



always @(posedge clk)
begin
  if(~rst) begin
    state_unit <= 2'b00;
  end
  else begin
    state_unit <= next_state_unit;
  end
end


always @(*)
begin
  case(state_unit)
    2'b00  : begin
               if(process_enable_tree == 1'b1) begin
                 next_state_unit = 2'b01;
               end
               else begin
                 next_state_unit = 2'b00;
               end
             end
    2'b01  : begin /**  write the value into buffer  **/
               if(process_enable_tree == 1'b0) begin
                 next_state_unit = 2'b00;
               end
               else begin
                 next_state_unit = buffer_data_done ? 2'b10 : 2'b01;
               end
             end
    2'b10  : begin /** write the index into buffer **/
               if(process_enable_tree == 1'b0) begin
                 next_state_unit = 2'b00;
               end
               else begin
                 next_state_unit = buffer_data_full ? 2'b10 : 2'b01;
               end
             end
    default: next_state_unit = 2'b00;
  endcase
end


always @(*)
begin
  buffer_data_done = (buffer_data_full == 1'b0)&&(device_sort_code == 1'b1);
end



always @(*)
begin
  case(state_unit)
    2'b01  : buffer_output_find = buffer_temper_find ? 2'b01 : 2'b10;
    2'b10  : buffer_output_find = buffer_buffed_find ? 2'b01 : 2'b10;
    default: buffer_output_find = 2'b00;
  endcase
end


always @(*)
begin
  input_zeros_0 = (buffer_input_0 == {word_size{1'b0}});
  input_zeros_1 = (buffer_input_1 == {word_size{1'b0}});
end


always @(*)
begin
  none_zero_find = (buffer_input_0 <= buffer_input_1)&&(input_zeros_0 == 1'b0);
  true_zero_find = (buffer_input_0 >= buffer_input_1)&&(input_zeros_1 == 1'b1);
end


always @(*)
begin
  case(device_sort_code)
    1'b1 : buffer_temper_find = (buffer_input_0 >= buffer_input_1); /** looking for the max **/
	1'b0 : buffer_temper_find = (none_zero_find == 1'b1)||(true_zero_find == 1'b1);
  endcase
end


always @(posedge clk)
begin
  if((~rst)||(buffer_enable_reset == 1'b1)) begin
    buffer_buffed_find <= 1'b0;
  end
  else if(state_unit == 2'b01) begin
    buffer_buffed_find <= buffer_temper_find;
  end
  else begin
    buffer_buffed_find <= buffer_buffed_find;
  end
end


always @(*)
begin
  case(state_unit)
    2'b01  : buffer_wt_enable = (buffer_data_full == 1'b0);
    2'b10  : buffer_wt_enable = (buffer_data_full == 1'b0);
    default: buffer_wt_enable = (1'b0);
  endcase
end


always @(*)
begin
  if((buffer_input_full == 1'b0)&&(buffer_input_find == 1'b1)) begin
    buffer_rd_enable = 1'b1;
  end
  else begin
    buffer_rd_enable = 1'b0;
  end
end


always @(posedge clk)
begin
  if((~rst)||(buffer_enable_reset == 1'b1)) begin
    for(index = 0; index < buff_size; index = index + 1)
      buffer_data_mxtr[index] <= {word_size{1'b0}};
  end
  else if((buffer_wt_enable == 1'b1)&&(buffer_output_find == 2'b01)) begin
    buffer_data_mxtr[buffer_wt_index] <= buffer_input_0;
  end
  else if((buffer_wt_enable == 1'b1)&&(buffer_output_find == 2'b10)) begin
    buffer_data_mxtr[buffer_wt_index] <= buffer_input_1;
  end
  else begin
    for(index = 0; index < buff_size; index = index + 1)
      buffer_data_mxtr[index] <= buffer_data_mxtr[index];
  end
end


always @(posedge clk)
begin
  if((~rst)||(index_wt_reset == 1'b1)) begin
    buffer_wt_index <= {buff_size{1'b0}};
  end
  else if(buffer_wt_enable == 1'b1) begin
    buffer_wt_index <= buffer_wt_index + 1'b1;
  end
  else begin
    buffer_wt_index <= buffer_wt_index;
  end
end


always @(posedge clk)
begin
  if((~rst)||(index_rd_reset == 1'b1)) begin
    buffer_rd_index <= {buff_size{1'b0}};
  end
  else if(buffer_rd_enable == 1'b1) begin /** The value is found for next tree level **/
    buffer_rd_index <= buffer_rd_index + 1'b1;
  end
  else begin
    buffer_rd_index <= buffer_rd_index;
  end
end


always @(*)
begin
  index_rd_reset = (buffer_enable_reset == 1'b1)||((buffer_rd_index == (buff_size - 1))&&(buffer_rd_enable == 1'b1));
  index_wt_reset = (buffer_enable_reset == 1'b1)||((buffer_wt_index == (buff_size - 1))&&(buffer_wt_enable == 1'b1));
end


always @(posedge clk)
begin
  if((~rst)||(buffer_enable_reset == 1'b1)) begin
    buffer_data_count <= {1'b0, {buff_size{1'b0}}};
  end
  else if((buffer_wt_enable == 1'b1)&&(buffer_rd_enable == 1'b0)) begin
    buffer_data_count <= buffer_data_count + 1'b1;
  end
  else if((buffer_wt_enable == 1'b0)&&(buffer_rd_enable == 1'b1)) begin
    buffer_data_count <= buffer_data_count - 1'b1;
  end
  else begin
    buffer_data_count <= buffer_data_count;
  end
end


always @(*)
begin
  buffer_output_full = {buffer_data_full, buffer_data_full};
  buffer_init_full = (buffer_data_count == (buff_size - 1))&&(buffer_wt_enable == 1'b1)&&(buffer_rd_enable == 1'b0);
  buffer_loop_full = (buffer_data_count == buff_size)&&(buffer_rd_enable == 1'b0);
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_data_full <= 1'b0;
  end
  else begin
    buffer_data_full <= (buffer_loop_full == 1'b1)||(buffer_init_full == 1'b1);
  end
end


always @(*)
begin
  buffer_output_data = buffer_data_mxtr[buffer_rd_index];
end


endmodule


/** This logic is used to find the best candidate of learning and active cell **/
/** Each iteration of active logic is for one active column at t **/
// `include "../param.vh"

module actc_ctrl ( clk, rst,
                   process_learn_enable,
                   process_enable_actc,
                   memory_addr_computed,
                   memory_addr_init_prt,
                   memory_addr_init_prv,
                   compute_addr_done,
                   memory_data_ready,
                   buffer_data_fifo,
                   buffer_send_epty,
                   process_done_find,
				   buffer_counter_find_0,
				   buffer_counter_find_1,
				   buffer_counter_find_2,
				   buffer_counter_find_3,
				   buffer_counter_find_4,
				   buffer_counter_find_5,
				   buffer_counter_find_6,
				   buffer_counter_find_7,
                   /** Output Signal **/
                   memory_addr_load_rcvd,
                   process_enable_find,
                   process_done_actc,
                   buffer_read_fifo,
                   packet_enable_send,
                   packet_data_send,
                   packet_inst_send,
				   memory_addr_lemt,
                   memory_wt_data,
                   memory_wt_enable,
                   memory_rd_enable,
                   compute_addr_enable,
                   compute_addr_packet,
                   compute_addr_length
				 );


parameter  addr_size = `addr_size_lemt,
           lane_size = `lane_size_para,
           word_size = `word_size_para;


parameter  actived_threshold = `actived_threshold_para,
           learned_threshold = `learned_threshold_para,
           cell_per_column = `cell_per_column_para,
           block_per_element = `block_per_element_para,
           memory_packet_count = `memory_size_packet, /** total packet count in proc memory(includ received from other cores) **/
           memory_addr_init_blk = `memory_addr_init_blk_para;


input wire clk, rst;
input wire process_enable_actc, process_learn_enable;
input wire [addr_size - 1 : 0] memory_addr_computed;
input wire [addr_size - 1 : 0] memory_addr_init_prt;
input wire [addr_size - 1 : 0] memory_addr_init_prv;
input wire [word_size - 1 : 0] buffer_data_fifo;
input wire buffer_send_epty;
input wire [23 : 0] buffer_counter_find_0, buffer_counter_find_1;
input wire [23 : 0] buffer_counter_find_2, buffer_counter_find_3;
input wire [23 : 0] buffer_counter_find_4, buffer_counter_find_5;
input wire [23 : 0] buffer_counter_find_6, buffer_counter_find_7;
input wire [lane_size - 1 : 0] process_done_find;
input wire compute_addr_done, memory_data_ready;


output reg [lane_size - 1 : 0] process_enable_find;
output reg [addr_size - 1 : 0] memory_addr_lemt;
output reg memory_rd_enable, memory_wt_enable;
output reg [word_size - 1 : 0] memory_wt_data;
output reg process_done_actc;
output reg compute_addr_enable;
output reg [word_size - 1 : 0] compute_addr_packet;
output reg [3 : 0] compute_addr_length;
output reg packet_enable_send;
output reg [word_size - 1 : 0] packet_data_send;
output reg [word_size - 1 : 0] packet_inst_send;
output reg buffer_read_fifo;
output reg memory_addr_load_rcvd;



reg [addr_size - 1 : 0] memory_addr_offt_prt;
reg [addr_size - 1 : 0] memory_addr_offt_blk;
reg [addr_size - 1 : 0] memory_addr_offt_prv;
reg [addr_size - 1 : 0] memory_addr_init, memory_addr_offt;
reg [word_size - 1 : 0] packet_data_learn;
reg [lane_size - 1 : 0] lanes_find_flag;
reg [word_size - 1 : 0] buffer_data_actc;


reg [7  : 0] index_learned_cell, index_actived_cell;
reg [7  : 0] max_counter_act, max_counter_lrn, max_counter_pnt;
reg [3  : 0] min_counter_seg;
reg [7  : 0] cell_id_block;
reg [7  : 0] index_col_fifo, index_row_fifo, index_blk_fifo;
reg [7  : 0] index_col_buff, index_row_buff, index_blk_buff;
reg [3  : 0] block_loop_count, block_count_used;
reg [3  : 0] segment_count_loop, segment_count;
reg [3  : 0] state_actc, next_state_actc;
reg [3  : 0] block_index_pnt, block_index_seg;
reg [3  : 0] segment_index_pnt;
reg [23 : 0] buffer_counter_find[lane_size - 1 : 0];
reg [7  : 0] buffer_counter_act;
reg [7  : 0] buffer_counter_pnt;
reg [7  : 0] buffer_counter_lrn;
reg [7  : 0] find_counter_act [lane_size - 1 : 0];
reg [7  : 0] find_counter_pnt [lane_size - 1 : 0];
reg [7  : 0] find_counter_lrn [lane_size - 1 : 0];

reg segment_loop_done, segment_loop_rset;
reg dirty_block_found, block_loop_done;
reg learned_cell_state, actived_cell_state, predict_cell_state;
reg buffer_counter_reset;
reg [2 : 0] index_buffer_find;
reg [7 : 0] cell_index_pnt, cell_index_seg;
reg process_done_item;
reg buffer_data_reset, proper_cell_find;
reg packet_loop_done, packet_send_init, packet_send_done;
reg lanes_find_done, lanes_loop_done, memory_read_done;
reg block_data_ready, segment_data_ready;
reg memory_addr_updt_prt, memory_addr_rset_prv;
reg memory_addr_updt_blk, memory_addr_load_blk;
reg memory_read_init, memory_buff_ready, buffer_data_done;



genvar index;


generate

   for(index = 0; index < lane_size; index = index + 1)
   begin: lanes

     always @(*)
     begin
       find_counter_act[index] = buffer_counter_find[index][23 : 16];
       find_counter_lrn[index] = buffer_counter_find[index][15 : 08];
       find_counter_pnt[index] = buffer_counter_find[index][07 : 00];
     end

   end

endgenerate


always @(*)
begin
  buffer_counter_find[0] = buffer_counter_find_0;
  buffer_counter_find[1] = buffer_counter_find_1;
  buffer_counter_find[2] = buffer_counter_find_2;
  buffer_counter_find[3] = buffer_counter_find_3;
  buffer_counter_find[4] = buffer_counter_find_4;
  buffer_counter_find[5] = buffer_counter_find_5;
  buffer_counter_find[6] = buffer_counter_find_6;
  buffer_counter_find[7] = buffer_counter_find_7;
end


always @(posedge clk)
begin
  if(~rst) begin
    state_actc <= 4'b0000;
  end
  else begin
    state_actc <= next_state_actc;
  end
end


always @(*)
begin
  case(state_actc)
    4'b0000: begin
	           if(process_enable_actc == 1'b1) begin
			     next_state_actc = 4'b0001;
			   end
			   else begin
			     next_state_actc = 4'b0000;
			   end
	         end
	4'b0001: begin  /** Read out one active column at t to find cell candidate **/
	           if(memory_buff_ready == 1'b1) begin
				 next_state_actc = packet_loop_done ? 4'b1011 : 4'b0010;
			   end
			   else begin
				 next_state_actc = 4'b0001;
			   end
	         end
    4'b0010: begin  /** Calculate the initial address of block for each column **/
	           if(compute_addr_done == 1'b1) begin
			     next_state_actc = 4'b0011;
			   end
			   else begin
	             next_state_actc = 4'b0010;
			   end
	         end
	4'b0011: begin  /** Read the block information from memory and check for dirty **/
               if(memory_data_ready == 1'b1) begin
			     next_state_actc = 4'b0100;
			   end
			   else begin
			     next_state_actc = 4'b0011;
			   end
             end
    4'b0100: begin /** Check if any dirty block is found in current active column **/
	           if(dirty_block_found == 1'b1) begin
			     next_state_actc = 4'b0101;
			   end
			   else begin
			     next_state_actc = 4'b1011;
			   end
	         end
    4'b0101: begin /** Calculate the address of synapse for the lane memory **/
               if(compute_addr_done == 1'b1) begin
			     next_state_actc = 4'b0110;
	           end
			   else begin
			     next_state_actc = 4'b0101;
			   end
			 end
    4'b0110: begin /** Trigger the find unit to figure out active state **/
	           if(lanes_find_done == 1'b1) begin
			     next_state_actc = 4'b0111;
			   end
			   else begin
			     next_state_actc = 4'b0110;
			   end
	         end
    4'b0111: begin /** Synpases in one segment is looped, move to next segment **/
	           if(lanes_loop_done == 1'b1) begin
			     next_state_actc = 4'b1000;
			   end
			   else begin
			     next_state_actc = 4'b0111;
			   end
	         end
    4'b1000: begin /** Update the info for each segment check if proper cell found **/
               if(buffer_data_done == 1'b1) begin
			     next_state_actc = 4'b1001;
	           end
			   else begin
			     next_state_actc = 4'b1000;
			   end
			 end
    4'b1001: begin /** Check and update info for learn cell if learn enable **/
               if(packet_send_init == 1'b1) begin
			     next_state_actc = 4'b1011;
	           end
			   else begin
			     next_state_actc = segment_loop_done ? 4'b0011 : 4'b0110;
			   end
			 end
    4'b1010: begin /** Send the info of current colum back to the central processor **/
               if(packet_send_done == 1'b1) begin
			     next_state_actc = packet_loop_done ? 4'b0000 : 4'b0001;
	           end
			   else begin
			     next_state_actc = 4'b1010;
			   end
			 end
    4'b1011: begin
               if(buffer_send_epty == 1'b1) begin
                 next_state_actc = 4'b1010;
               end
               else begin
                 next_state_actc = 4'b1011;
               end
             end
	default: begin
	           next_state_actc = 4'b0000;
	         end
  endcase
end


always @(posedge clk)
begin
  if(~rst) begin
    process_done_actc <= 1'b0;
  end
  else begin
    process_done_actc <= (next_state_actc == 4'b0000)&&(state_actc != 4'b0000);
  end
end


always @(posedge clk)
begin /** blocks of one column is done **/
  if(~rst) begin
    process_done_item <= 1'b0;
  end
  else begin
    case(next_state_actc)
      4'b0001: process_done_item <= (state_actc == 4'b1010);
      4'b0000: process_done_item <= (state_actc == 4'b1010);
      default: process_done_item <= (1'b0);
    endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_lemt <= {addr_size{1'b0}};
  end
  else begin
    memory_addr_lemt <= {memory_addr_init + memory_addr_offt};
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_read_fifo <= 1'b0;
  end
  else begin
    case(next_state_actc)
	  4'b0011: buffer_read_fifo <= (state_actc == 4'b0010)||(state_actc == 4'b1001);
	  4'b0001: buffer_read_fifo <= (state_actc == 4'b1010);
	  4'b0000: buffer_read_fifo <= (state_actc == 4'b1010);
	  default: buffer_read_fifo <= (1'b0);
	endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_buff_ready <= (1'b0);
  end
  else begin
    memory_buff_ready <= (memory_data_ready == 1'b1);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_read_init <= 1'b0;
  end
  else begin
    case(state_actc)
	  4'b0001: memory_read_init <= 1'b1;
	  4'b0011: memory_read_init <= 1'b1;
      default: memory_read_init <= 1'b0;
	endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_data_done <= (1'b0);
  end
  else begin
    case(state_actc)
	  4'b1000: buffer_data_done <= 1'b1;
	  4'b1010: buffer_data_done <= 1'b1;
      default: buffer_data_done <= 1'b0;
	endcase
  end
end


/** state_actc == 4'b0001, read out one active column at t to find cell candidate **/


always @(*)
begin
  index_row_fifo = {buffer_data_fifo[word_size - 1 : word_size - 08]};
  index_col_fifo = {buffer_data_fifo[word_size - 9 : word_size - 16]};
  index_blk_fifo = {4'b0000, block_loop_count};
end


always @(*)
begin
  memory_addr_updt_prt = (state_actc == 4'b0001)&&(memory_data_ready == 1'b1);
  packet_loop_done = (buffer_data_fifo == {word_size{1'b1}});
end


always @(posedge clk)
begin
  if((~rst)||(process_done_actc == 1'b1)) begin
    memory_addr_offt_prt <= {addr_size{1'b0}};
  end
  else if(memory_addr_updt_prt == 1'b1) begin
    memory_addr_offt_prt <= memory_addr_offt_prt + 1'b1;
  end
  else begin
    memory_addr_offt_prt <= memory_addr_offt_prt;
  end
end


/** state_actc == 4'b0010, calculate the address for the block of current active column **/
/** state_actc == 4'b0101, calculate the address of synapse for the lane memory **/


always @(*)
begin
  index_row_buff = {buffer_data_actc[word_size - 1 : word_size - 08]};
  index_col_buff = {buffer_data_actc[word_size - 9 : word_size - 16]};
  index_blk_buff = {4'b0000, block_loop_count};
end


always @(posedge clk)
begin
  if(~rst) begin
    compute_addr_enable <= 1'b0;
  end
  else begin
    case(next_state_actc)
	  4'b0010: compute_addr_enable <= (state_actc == 4'b0001);
	  4'b0101: compute_addr_enable <= (state_actc == 4'b0100);
	  default: compute_addr_enable <= 1'b0;
	endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    compute_addr_packet <= {word_size{1'b0}};
  end
  else begin
    case(next_state_actc)
      4'b0010: compute_addr_packet <= {8'h00, index_blk_fifo, index_col_fifo, index_row_fifo};
	  4'b0101: compute_addr_packet <= {8'h00, index_blk_buff, index_col_buff, index_row_buff};
      default: compute_addr_packet <= {word_size{1'b0}};
    endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    compute_addr_length <= 4'b0000;
  end
  else begin
    case(next_state_actc)
      4'b0010: compute_addr_length <= 4'b0010;
      4'b0101: compute_addr_length <= 4'b0100;
      default: compute_addr_length <= 4'b0000;
    endcase
  end
end


/** state_actc == 4'b0011, read the block information from memory and check for dirty  **/


always @(posedge clk)
begin
  if(~rst) begin
    memory_rd_enable <= 1'b0;
  end
  else begin
    case(state_actc)
	  4'b0001: memory_rd_enable <= (memory_read_init == 1'b0);
	  4'b0011: memory_rd_enable <= (memory_read_init == 1'b0);
	  4'b0110: memory_rd_enable <= (memory_read_done == 1'b1);
      default: memory_rd_enable <= (1'b0);
	endcase
  end
end


always @(*)
begin
  case(state_actc)
    4'b0001: memory_addr_init = {memory_addr_init_prt}; /** The initial address of active columns at t **/
	4'b0011: memory_addr_init = {memory_addr_init_blk}; /** The initial address blocks belong to active column **/
	4'b0110: memory_addr_init = (memory_addr_init_prv); /** The initial address blocks belong to active column **/
	default: memory_addr_init = {addr_size{1'b0}};
  endcase
end


always @(*)
begin
  case(state_actc)
    4'b0001: memory_addr_offt = {memory_addr_offt_prt}; /** The initial address of active columns at t **/
	4'b0011: memory_addr_offt = {memory_addr_offt_blk}; /** The initial address blocks belong to active column **/
	4'b0110: memory_addr_offt = (memory_addr_offt_prv); /** The initial address blocks belong to active column **/
    default: memory_addr_offt = {addr_size{1'b0}};
  endcase
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_offt_blk <= {addr_size{1'b0}};
  end
  else if(memory_addr_load_blk == 1'b1) begin
    memory_addr_offt_blk <= memory_addr_computed;
  end
  else if(memory_addr_updt_blk == 1'b1) begin
    memory_addr_offt_blk <= memory_addr_offt_blk + 1'b1;
  end
  else begin
    memory_addr_offt_blk <= memory_addr_offt_blk;
  end
end


always @(*)
begin
  memory_read_done = (memory_addr_offt_prv < memory_packet_count);
  memory_addr_updt_blk = (segment_loop_done == 1'b1)&&(state_actc == 4'b1001);
  memory_addr_load_blk = (compute_addr_done == 1'b1)&&(state_actc == 4'b0010);
end


/** state_actc == 4'b0100, check if any dirty block is found in current active column **/


always @(posedge clk)
begin
  if(~rst) begin
    buffer_data_actc <= {word_size{1'b0}};
  end
  else if((state_actc == 4'b0010)&&(next_state_actc == 4'b0011)) begin
    buffer_data_actc <= buffer_data_fifo;
  end
  else begin
    buffer_data_actc <= buffer_data_actc;
  end
end



always @(*)
begin  /** The block info of active column is stored in the buffer **/
  cell_id_block = buffer_data_fifo[word_size -  1 : word_size -  8]; /** The cell id in this block **/
  segment_count = buffer_data_fifo[word_size -  9 : word_size - 12];
  predict_cell_state = buffer_data_fifo[word_size - 14];
end


always @(*)
begin
  dirty_block_found = (segment_count != 4'b0000);
  block_data_ready = (state_actc == 4'b0100);
end


always @(posedge clk)
begin
  if((~rst)||(process_done_item == 1'b1)) begin
    min_counter_seg <= 4'b1111;
  end
  else if((block_data_ready == 1'b1)&&(min_counter_seg >= segment_count)) begin
    min_counter_seg <= segment_count;
  end
  else begin
    min_counter_seg <= min_counter_seg;
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_done_item == 1'b1)) begin
    block_index_seg <= 4'b0000;
  end
  else if((block_data_ready == 1'b1)&&(min_counter_seg >= segment_count)) begin
    block_index_seg <= block_loop_count;
  end
  else begin
    block_index_seg <= block_index_seg;
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_done_item == 1'b1)) begin
    cell_index_seg <= 8'b00000000;
  end
  else if((block_data_ready == 1'b1)&&(min_counter_seg >= segment_count)) begin
    cell_index_seg <= cell_id_block;
  end
  else begin
    cell_index_seg <= cell_index_seg;
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_done_item == 1'b1)) begin
    block_count_used <= 4'b0000;
  end
  else if((dirty_block_found == 1'b1)&&(state_actc == 4'b0100)) begin
    block_count_used <= block_count_used + 1'b1;
  end
  else begin
    block_count_used <= block_count_used;
  end
end


/** state_actc == 4'b0110, trigger the find unit to figure out active state **/


always @(posedge clk)
begin
  if(~rst) begin
    process_enable_find <= {lane_size{1'b0}};
  end
  else begin
    process_enable_find <= {lane_size{(state_actc != 4'b0110)&&(next_state_actc == 4'b0110)}};
  end
end


always @(*)
begin
  memory_addr_rset_prv = (state_actc == 4'b0110)&&(next_state_actc == 4'b0111);
end


always @(posedge clk)
begin
  if((~rst)||(memory_addr_rset_prv == 1'b1)) begin
    memory_addr_offt_prv <= {addr_size{1'b0}};
  end
  else if(state_actc == 4'b0110) begin
    memory_addr_offt_prv <= memory_addr_offt_prv + 1'b1;
  end
  else begin
    memory_addr_offt_prv <= memory_addr_offt_prv;
  end
end


always @(*)
begin
  lanes_find_done = (lanes_find_flag == {lane_size{1'b1}});
end


generate

   for(index = 0; index < lane_size; index = index + 1)
   begin: flags

	  always @(posedge clk)
	  begin
	    if((~rst)||(lanes_find_done == 1'b1)) begin
		  lanes_find_flag[index] <= 1'b0;
		end
		else if(process_done_find[index] == 1'b1) begin
		  lanes_find_flag[index] <= 1'b1;
		end
		else begin
		  lanes_find_flag[index] <= lanes_find_flag[index];
        end
      end

   end

endgenerate


always @(*)
begin
  if((state_actc == 4'b0101)&&(compute_addr_done == 1'b1)) begin
    memory_addr_load_rcvd = 1'b1;
  end
  else begin
    memory_addr_load_rcvd = 1'b0;
  end
end


/** state_actc == 4'b0111, synpases in one segment is looped, move to the next segment **/


always @(*)
begin
  buffer_counter_reset = (buffer_data_done == 1'b1)&&(state_actc == 4'b1000);
end


always @(posedge clk)
begin /** active synapse **/
  if((~rst)||(buffer_counter_reset == 1'b1)) begin
    buffer_counter_act <= 8'h00;
  end
  else if(state_actc == 4'b0111) begin
    buffer_counter_act <= buffer_counter_act + find_counter_act[index_buffer_find];
  end
  else begin
    buffer_counter_act <= buffer_counter_act;
  end
end


always @(posedge clk)
begin /** potential synapse **/
  if((~rst)||(buffer_counter_reset == 1'b1)) begin
    buffer_counter_pnt <= 8'h00;
  end
  else if(state_actc == 4'b0111) begin
    buffer_counter_pnt <= buffer_counter_pnt + find_counter_pnt[index_buffer_find];
  end
  else begin
    buffer_counter_pnt <= buffer_counter_pnt;
  end
end


always @(posedge clk)
begin /** learning synapse **/
  if((~rst)||(buffer_counter_reset == 1'b1)) begin
    buffer_counter_lrn <= 8'h00;
  end
  else if(state_actc == 4'b0111) begin
    buffer_counter_lrn <= buffer_counter_lrn + find_counter_lrn[index_buffer_find];
  end
  else begin
    buffer_counter_lrn <= buffer_counter_lrn;
  end
end


always @(posedge clk)
begin
  if((~rst)||(buffer_counter_reset == 1'b1)) begin
    index_buffer_find <= 3'b000;
  end
  else if(state_actc == 4'b0111) begin
    index_buffer_find <= index_buffer_find + 1'b1;
  end
  else begin
    index_buffer_find <= index_buffer_find;
  end
end


always @(*)
begin
  if((index_buffer_find == (lane_size - 1))&&(state_actc == 4'b0111)) begin
    lanes_loop_done = 1'b1;
  end
  else begin
    lanes_loop_done = 1'b0;
  end
end


/** state_actc == 4'b1000, update the info for each segment check if learn found **/
/** Decide the cell state based on the segment active **/
/** If none active cell is found, the Cell_Index_Active is set to the cell count **/


always @(*)
begin
  if((state_actc == 4'b1000)&&(buffer_data_done == 1'b0)) begin
    segment_data_ready = 1'b1;
  end
  else begin
    segment_data_ready = 1'b0;
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_done_item == 1'b1)) begin
    max_counter_act <= 8'b00000000;
  end
  else if((segment_data_ready == 1'b1)&&(buffer_counter_act >= max_counter_act)) begin
    max_counter_act <= buffer_counter_act;
  end
  else begin
    max_counter_act <= max_counter_act;
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_done_item == 1'b1)) begin
    max_counter_lrn <= 8'b00000000;
  end
  else if((segment_data_ready == 1'b1)&&(buffer_counter_lrn >= max_counter_lrn)) begin
    max_counter_lrn <= buffer_counter_lrn;
  end
  else begin
    max_counter_lrn <= max_counter_lrn;
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_done_item == 1'b1)) begin
    max_counter_pnt <= 8'b00000000;
  end
  else if((segment_data_ready == 1'b1)&&(buffer_counter_pnt >= max_counter_pnt)) begin
    max_counter_pnt <= buffer_counter_pnt;
  end
  else begin
    max_counter_pnt <= max_counter_pnt;
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_done_item == 1'b1)) begin
    cell_index_pnt <= 8'b00000000;
  end
  else if((segment_data_ready == 1'b1)&&(buffer_counter_pnt >= max_counter_pnt)) begin
    cell_index_pnt <= cell_id_block;
  end
  else begin
    cell_index_pnt <= cell_index_pnt;
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_done_item == 1'b1)) begin
    segment_index_pnt <= 4'b0000;
  end
  else if((segment_data_ready == 1'b1)&&(buffer_counter_pnt >= max_counter_pnt)) begin
    segment_index_pnt <= segment_count_loop;
  end
  else begin
    segment_index_pnt <= segment_index_pnt;
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_done_item == 1'b1)) begin
    block_index_pnt <= 4'b0000;
  end
  else if((segment_data_ready == 1'b1)&&(buffer_counter_pnt >= max_counter_pnt)) begin
    block_index_pnt <= block_loop_count;
  end
  else begin
    block_index_pnt <= block_index_pnt;
  end
end


always @(*)
begin
  if((max_counter_act >= actived_threshold)&&(predict_cell_state == 1'b1)) begin
    actived_cell_state = 1'b1;
  end
  else begin
    actived_cell_state = 1'b0;
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_done_item == 1'b1)) begin
    index_actived_cell <= cell_per_column;
  end
  else if((state_actc == 4'b1000)&&(actived_cell_state == 1'b1)) begin
    index_actived_cell <= cell_id_block;
  end
  else begin
    index_actived_cell <= index_actived_cell;
  end
end


always @(*)
begin
  if((max_counter_lrn >= learned_threshold)&&(actived_cell_state == 1'b1)) begin
    learned_cell_state = 1'b1;
  end
  else begin
    learned_cell_state = 1'b0;
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_done_item == 1'b1))begin
    index_learned_cell <= cell_per_column;
  end
  else if((state_actc == 4'b1000)&&(learned_cell_state == 1'b1)) begin
    index_learned_cell <= cell_id_block;
  end
  else begin
    index_learned_cell <= index_learned_cell;
  end
end


always @(*)
begin
  proper_cell_find = process_learn_enable ? learned_cell_state : actived_cell_state;
end


always @(posedge clk)
begin
  if((~rst)||(segment_loop_rset == 1'b1)) begin
    segment_count_loop <= 4'b0000;
  end
  else if(segment_data_ready == 1'b1) begin
    segment_count_loop <= segment_count_loop + 1'b1;
  end
  else begin
    segment_count_loop <= segment_count_loop;
  end
end


always @(*)
begin
  segment_loop_done = (segment_count_loop == segment_count);
  segment_loop_rset = (segment_loop_done == 1'b1)&&(state_actc == 4'b1001);
  block_loop_done = (block_loop_count == (block_per_element - 1));
end


always @(posedge clk)
begin
  if((~rst)||(process_done_item == 1'b1)) begin
    block_loop_count <= 4'b0000;
  end
  else if((segment_loop_done == 1'b1)&&(state_actc == 4'b1001)) begin
    block_loop_count <= block_loop_count + 1'b1;
  end
  else begin
    block_loop_count <= block_loop_count;
  end
end


/** state_actc == 4'b1001, check and update info for learn cell if learn enable **/


always @(*)
begin /** information of current column is ready to be sent **/
  packet_send_init = (proper_cell_find == 1'b1)||(block_loop_done == 1'b1);
end


always @(posedge clk)
begin
  if(~rst) begin
    packet_send_done <= (1'b0);
  end
  else begin
    packet_send_done <= (state_actc == 4'b1010)&&(buffer_data_done == 1'b1);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_wt_enable <= 1'b0;
  end
  else begin
    case(state_actc)
      4'b1001: memory_wt_enable <= learned_cell_state;
      default: memory_wt_enable <= 1'b0;
    endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_wt_data <= {word_size{1'b0}};
  end
  else begin
    case(state_actc)            /** cell_index, segmeng_count, pred_t-0, pred_t-1, lern_t-0, lern_t-1 **/
      4'b1001: memory_wt_data <= {buffer_data_fifo[word_size - 1 : word_size - 14], 1'b1, buffer_data_fifo[word_size - 15], 16'h0000};
      default: memory_wt_data <= {word_size{1'b0}};
    endcase
  end
end


/** state_actc == 4'b1010, send the info of current colum back to the central processor **/


always @(posedge clk)
begin
  if((~rst)||(process_done_actc == 1'b1)) begin
    buffer_data_reset <= 1'b0;
  end
  else if(process_done_item == 1'b1) begin
    buffer_data_reset <= 1'b1;
  end
  else begin
    buffer_data_reset <= buffer_data_reset;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    packet_enable_send <= 1'b0;
  end
  else begin
    packet_enable_send <= (next_state_actc == 4'b1010);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    packet_inst_send <= {word_size{1'b0}};
  end
  else begin
    packet_inst_send <= {buffer_data_reset, 7'b0000000, 8'h00, 8'h04, {7'b0000000, packet_loop_done}};
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    packet_data_send <= {word_size{1'b0}};
  end
  else if((buffer_data_done == 1'b0)&&(packet_send_done == 1'b0)) begin
    packet_data_send <= {buffer_data_actc[word_size - 1 : word_size - 16], index_actived_cell, index_learned_cell};
  end
  else if((buffer_data_done == 1'b1)&&(packet_send_done == 1'b0)) begin
    packet_data_send <= {packet_data_learn};
  end
  else begin
    packet_data_send <= {word_size{1'b0}};
  end
end


always @(*)
begin
  if(max_counter_pnt >= actived_threshold) begin
    packet_data_learn = {max_counter_pnt, segment_index_pnt, 4'h0, block_index_pnt, cell_index_pnt, 4'b0001};
  end
  else begin
    packet_data_learn = {min_counter_seg, block_count_used, 8'h00, block_index_seg, cell_index_seg, 4'b0010};
  end
end



endmodule


// `include "../param.vh"

module address_calculator ( clk, rst,
                            compute_enable_actc,
						    compute_packet_actc,
						    compute_length_actc,
                            compute_enable_buld,
						    compute_packet_buld,
						    compute_length_buld,
                            /** Output Signal **/
                            memory_addr_computed,
						    compute_addr_done
						   );

parameter  addr_size = `addr_size_para,
           word_size = `word_size_para,
           memory_interval = 32'h0001;

input wire clk, rst;
input wire compute_enable_actc;
input wire [word_size - 1 : 0] compute_packet_actc;
input wire [3 : 0] compute_length_actc;
input wire compute_enable_buld;
input wire [word_size - 1 : 0] compute_packet_buld;
input wire [3 : 0] compute_length_buld;


output reg [addr_size - 1 : 0] memory_addr_computed;
output reg compute_addr_done;


parameter  column_per_row     = {8'h00, `column_per_row_para},
           block_per_element  = {8'h00, 16'h0001},
           segment_per_block  = {8'h00, 16'h0001},
           synapse_per_lane   = {8'h00, `synapse_per_lane_para};


/** compute_addr_packet = {Index_Segment, Index_Block, Index_Col, Index_Row} **/


reg compute_addr_enable;
reg [word_size - 1 : 0] compute_addr_packet;
reg [3 : 0] compute_addr_length;
reg [24: 0] opnd_mul_one, opnd_mul_two;
reg [24: 0] opnd_add_one, opnd_add_two;
reg [24: 0] add_result, mul_result;
reg [2 : 0] state_addr, next_state_addr;
reg [1 : 0] index_para, index_head, index_spot;
reg operand_load_enable;
reg add_compute_enable;
reg mul_compute_enable;
reg compute_offt_enable;
reg para_loop_done, spot_loop_done;
reg compute_phase_done;
reg [2 : 0] memory_addr_length;
reg [3 : 0] memory_addr_state;
reg memory_state_reset;

wire [24 : 0] para_tank [3 : 0];
wire [24 : 0] spot_tank [3 : 0];

assign para_tank[0] = column_per_row;
assign para_tank[1] = block_per_element;
assign para_tank[2] = segment_per_block;
assign para_tank[3] = synapse_per_lane;


assign spot_tank[0] = {16'h0000, compute_addr_packet[07 : 00]};
assign spot_tank[1] = {16'h0000, compute_addr_packet[15 : 08]};
assign spot_tank[2] = {16'h0000, compute_addr_packet[23 : 16]};
assign spot_tank[3] = {16'h0000, compute_addr_packet[31 : 24]};


always @(posedge clk)
begin
  if((~rst)||(memory_state_reset == 1'b1)) begin
    memory_addr_state <= 4'b0000;
  end
  else begin
    case(1'b1)
      compute_enable_actc: memory_addr_state <= 4'b0001;
      compute_enable_buld: memory_addr_state <= 4'b0010;
      default: memory_addr_state <= memory_addr_state;
    endcase
  end
end


always @(*)
begin
  memory_state_reset = (next_state_addr == 3'b000)&&(state_addr != 3'b000);
end


always @(*)
begin
  case(memory_addr_state)
    4'b0001: compute_addr_packet = {compute_packet_actc};
    4'b0010: compute_addr_packet = {compute_packet_buld};
    default: compute_addr_packet = {word_size{1'b0}};
  endcase
end


always @(*)
begin
  case(memory_addr_state)
    4'b0001: compute_addr_length = {compute_length_actc};
    4'b0010: compute_addr_length = {compute_length_buld};
    default: compute_addr_length = {word_size{1'b0}};
  endcase
end


always @(posedge clk)
begin
  if(~rst) begin
     compute_addr_enable <= 1'b0;
  end
  else begin
    case(1'b1)
      compute_enable_actc: compute_addr_enable <= {1'b1};
      compute_enable_buld: compute_addr_enable <= {1'b1};
      default: compute_addr_enable <= {1'b0};
    endcase
  end
end


always @(*)
begin
  memory_addr_computed = {8'h00, add_result};
  memory_addr_length = compute_addr_length[2 : 0];
  compute_offt_enable = compute_addr_length[3];
end


always @(posedge clk)
begin
  if(~rst) begin
    compute_addr_done <= 1'b0;
  end
  else begin
    compute_addr_done <= (next_state_addr == 3'b000)&&(state_addr != 3'b000);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    state_addr <= 3'b000;
  end
  else begin
    state_addr <= next_state_addr;
  end
end


always @(*)
begin
  case(state_addr)
    3'b000 : next_state_addr = (compute_addr_enable == 1'b1) ? 3'b001 : 3'b000;
	3'b001 : next_state_addr = 3'b010; /** Load the Initial info for each computaion **/
	3'b010 : next_state_addr = (para_loop_done == 1'b1) ? 3'b011 : 3'b010; /** Execute the multiplication for one index **/
	3'b011 : next_state_addr = (spot_loop_done == 1'b1) ? 3'b100 : 3'b001; /** Execute the addition for the address result **/
	3'b100 : next_state_addr = (compute_offt_enable == 1'b1) ? 3'b101 : 3'b000; /** Execute the additional for multiplication of the internval **/
	3'b101 : next_state_addr = 3'b000;    /**  Execute the additional for the offset **/
	default: next_state_addr = 3'b000;
  endcase
end


always @(*)
begin
  if((state_addr == 3'b010)&&(index_para == (memory_addr_length - 1))) begin
    para_loop_done = 1'b1;
  end
  else begin
    para_loop_done = 1'b0;
  end
end


always @(*)
begin
  if((state_addr == 3'b011)&&(index_spot == (memory_addr_length - 1))) begin
    spot_loop_done = 1'b1;
  end
  else begin
    spot_loop_done = 1'b0;
  end
end


always @(*)
begin
  operand_load_enable = (state_addr == 3'b001);
  compute_phase_done  = (state_addr == 3'b011);
  mul_compute_enable  = (state_addr == 3'b010)||(state_addr == 3'b100);
  add_compute_enable  = (state_addr == 3'b011)||(state_addr == 3'b101);
end


always @(*)
begin
  opnd_mul_one = (state_addr == 3'b010) ? mul_result[24 : 0] : add_result[24 : 0];
  opnd_mul_two = (state_addr == 3'b010) ? para_tank[index_para] : memory_interval;
end


always @(posedge clk)
begin
  if(~rst) begin
    mul_result <= {24'h000000};
  end
  else if(operand_load_enable == 1'b1) begin
    mul_result <= spot_tank[index_spot];
  end
  else if(mul_compute_enable == 1'b1)begin
    mul_result <= opnd_mul_one * opnd_mul_two;
  end
  else begin
    mul_result <= mul_result;
  end
end


always @(posedge clk)
begin
  if((~rst)||(compute_addr_done == 1'b1)) begin
    index_spot <= 3'b000;
  end
  else if((compute_phase_done == 1'b1)&&(spot_loop_done == 1'b0)) begin
    index_spot <= index_spot + 1'b1;
  end
  else begin
    index_spot <= index_spot;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    index_para <= 2'b00;
  end
  else if(operand_load_enable == 1'b1) begin
    index_para <= index_head;
  end
  else if(mul_compute_enable == 1'b1) begin
    index_para <= index_para + 1'b1;
  end
  else begin
    index_para <= index_para;
  end
end


always @(posedge clk)
begin
  if((~rst)||(compute_addr_done == 1'b1)) begin
    index_head <= 2'b00;
  end
  else if(compute_phase_done == 1'b1) begin
    index_head <= index_head + 1'b1;
  end
  else begin
    index_head <= index_head;
  end
end


always @(*)
begin
  case(state_addr)
    3'b011 : opnd_add_one = {add_result};
	3'b101 : opnd_add_one = {add_result};
	default: opnd_add_one = {24'h000000};
  endcase
end


always @(*)
begin
  case(state_addr)
    3'b011 : opnd_add_two = {mul_result};
	3'b101 : opnd_add_two = {spot_tank[memory_addr_length]};
	default: opnd_add_two = {24'h000000};
  endcase
end



always @(posedge clk)
begin
  if((~rst)||(compute_addr_enable == 1'b1)) begin
    add_result <= {24'h000000};
  end
  else if(add_compute_enable == 1'b1) begin
    add_result <= opnd_add_one + opnd_add_two;
  end
  else begin
    add_result <= add_result;
  end
end


endmodule


// `include "../param.vh"

module bank_lemt ( clk, rst,
                   memory_chunk_update,
                   memory_data_lemt,
                   memory_addr_lemt_5,
                   memory_wt_data_5,
                   memory_rd_enable_5,
                   memory_wt_enable_5,
                   /** Lane Memory Control from realer **/
                   memory_addr_lemt_4,
                   memory_wt_data_4,
                   memory_rd_enable_4,
                   memory_wt_enable_4,
                   /** Lane Memory Control from boster **/
                   memory_addr_lemt_3,
                   memory_wt_data_3,
                   memory_rd_enable_3,
                   memory_wt_enable_3,
                   /** Lane Memory Control from lapper **/
                   memory_addr_lemt_2,
                   memory_wt_data_2,
                   memory_rd_enable_2,
                   memory_wt_enable_2,
                   /** Lane Memory Control from ranker **/
                   memory_addr_lemt_1,
                   memory_wt_data_1,
                   memory_rd_enable_1,
                   memory_wt_enable_1,
                   /** Lane Memory Control from scaner **/
                   memory_addr_lemt_0,
                   memory_wt_data_0,
                   memory_rd_enable_0,
                   memory_wt_enable_0,
                   /** Output Signal **/
                   memory_data_ready,
                   memory_addr_lemt,
                   memory_wt_data,
                   memory_rd_data,
                   memory_wt_enable,
				   memory_rd_enable,
                   memory_device_enable,
                   memory_addr_init_prt,
                   memory_addr_init_prv
                 );

parameter addr_size = `addr_size_lemt,
          word_size = `word_size_para;


parameter memory_chunk_0  = `memory_chunk_0_lemt,
		  memory_chunk_1  = `memory_chunk_1_lemt;


input wire clk, rst;
input wire memory_chunk_update;
input wire [word_size - 1 : 0] memory_data_lemt;
/** Lane Memory Control from realer **/
input wire [addr_size - 1 : 0] memory_addr_lemt_5;
input wire [word_size - 1 : 0] memory_wt_data_5;
input wire memory_rd_enable_5, memory_wt_enable_5;
/** Lane Memory Control from adpter **/
input wire [addr_size - 1 : 0] memory_addr_lemt_4;
input wire [word_size - 1 : 0] memory_wt_data_4;
input wire memory_rd_enable_4, memory_wt_enable_4;
/** Lane Memory Control from boster **/
input wire [addr_size - 1 : 0] memory_addr_lemt_3;
input wire [word_size - 1 : 0] memory_wt_data_3;
input wire memory_rd_enable_3, memory_wt_enable_3;
/** Lane Memory Control from lapper **/
input wire [addr_size - 1 : 0] memory_addr_lemt_2;
input wire [word_size - 1 : 0] memory_wt_data_2;
input wire memory_rd_enable_2, memory_wt_enable_2;
/** Lane Memory Control from ranker **/
input wire [addr_size - 1 : 0] memory_addr_lemt_1;
input wire [word_size - 1 : 0] memory_wt_data_1;
input wire memory_rd_enable_1, memory_wt_enable_1;
/** Lane Memory Control from scaner **/
input wire [addr_size - 1 : 0] memory_addr_lemt_0;
input wire [word_size - 1 : 0] memory_wt_data_0;
input wire memory_rd_enable_0, memory_wt_enable_0;


/** Output Signal **/
output reg [addr_size - 1 : 0] memory_addr_init_prt; /** t - 0 column **/
output reg [addr_size - 1 : 0] memory_addr_init_prv; /** t - 1 column **/
output reg [addr_size - 1 : 0] memory_addr_lemt;
output reg [word_size - 1 : 0] memory_wt_data;
output reg memory_device_enable, memory_data_ready;
output reg memory_wt_enable, memory_rd_enable;
output reg [word_size - 1 : 0] memory_rd_data;


reg [1 : 0] memory_buff_ready;
reg memory_chunk_flipped;
reg [word_size - 1 : 0] memory_data_buffer;

reg [word_size - 1 : 0] memory_wten_data;
reg [addr_size - 1 : 0] memory_addr_bank;
reg [5 : 0] memory_device_found;
reg memory_device_valid;
reg memory_wten_temp, memory_read_temp;



always @(*)
begin
  memory_device_found[0] = memory_rd_enable_0||memory_wt_enable_0;
  memory_device_found[1] = memory_rd_enable_1||memory_wt_enable_1;
  memory_device_found[2] = memory_rd_enable_2||memory_wt_enable_2;
  memory_device_found[3] = memory_rd_enable_3||memory_wt_enable_3;
  memory_device_found[4] = memory_rd_enable_4||memory_wt_enable_4;
  memory_device_found[5] = memory_rd_enable_5||memory_wt_enable_5;
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_bank <= {addr_size{1'b0}};
  end
  else begin
    case(1'b1)
      memory_device_found[0]: memory_addr_bank <= {memory_addr_lemt_0};
      memory_device_found[1]: memory_addr_bank <= {memory_addr_lemt_1};
      memory_device_found[2]: memory_addr_bank <= {memory_addr_lemt_2};
      memory_device_found[3]: memory_addr_bank <= {memory_addr_lemt_3};
      memory_device_found[4]: memory_addr_bank <= {memory_addr_lemt_4};
      memory_device_found[5]: memory_addr_bank <= {memory_addr_lemt_5};
      default               : memory_addr_bank <= {addr_size{1'b0}};
    endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_wten_temp <= 1'b0;
  end
  else begin
    case(1'b1)
      memory_wt_enable_0: memory_wten_temp <= memory_wt_enable_0;
      memory_wt_enable_1: memory_wten_temp <= memory_wt_enable_1;
      memory_wt_enable_2: memory_wten_temp <= memory_wt_enable_2;
      memory_wt_enable_3: memory_wten_temp <= memory_wt_enable_3;
      memory_wt_enable_4: memory_wten_temp <= memory_wt_enable_4;
      memory_wt_enable_5: memory_wten_temp <= memory_wt_enable_5;
	  default           : memory_wten_temp <= 1'b0;
	endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_read_temp <= 1'b0;
  end
  else begin
    case(1'b1)
      memory_rd_enable_0: memory_read_temp <= memory_rd_enable_0;
      memory_rd_enable_1: memory_read_temp <= memory_rd_enable_1;
      memory_rd_enable_2: memory_read_temp <= memory_rd_enable_2;
      memory_rd_enable_3: memory_read_temp <= memory_rd_enable_3;
      memory_rd_enable_4: memory_read_temp <= memory_rd_enable_4;
      memory_rd_enable_5: memory_read_temp <= memory_rd_enable_5;
	  default           : memory_read_temp <= 1'b0;
	endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_wten_data <= {word_size{1'b0}};
  end
  else begin
    case(1'b1)
      memory_wt_enable_0: memory_wten_data <= {memory_wt_data_0};
      memory_wt_enable_1: memory_wten_data <= {memory_wt_data_1};
      memory_wt_enable_2: memory_wten_data <= {memory_wt_data_2};
      memory_wt_enable_3: memory_wten_data <= {memory_wt_data_3};
      memory_wt_enable_4: memory_wten_data <= {memory_wt_data_4};
      memory_wt_enable_5: memory_wten_data <= {memory_wt_data_5};
	  default           : memory_wten_data <= {word_size{1'b0}};
	endcase
  end
end


/*** Final address decode stage of memory controller **/


always @(posedge clk)
begin
  if(~rst) begin
    memory_device_valid <= (1'b0);
  end
  else begin
    memory_device_valid <= (memory_device_found != 6'b000000);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_device_enable <= (1'b0);
  end
  else begin
    memory_device_enable <= (memory_device_valid == 1'b1);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_lemt <= {addr_size{1'b0}};
  end
  else begin
    memory_addr_lemt <= {memory_addr_bank};
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_wt_enable <= 1'b0;
  end
  else begin
    memory_wt_enable <= memory_wten_temp;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_rd_enable <= 1'b0;
  end
  else begin
    memory_rd_enable <= memory_read_temp;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_wt_data <= {word_size{1'b0}};
  end
  else begin
    memory_wt_data <= {memory_wten_data};
  end
end


always @(posedge clk)
begin /** Flip each time when the image is processed done **/
  if(~rst) begin
    memory_chunk_flipped <= 1'b0;
  end
  else if(memory_chunk_update == 1'b1) begin
    memory_chunk_flipped <= memory_chunk_flipped + 1'b1;
  end
  else begin
    memory_chunk_flipped <= memory_chunk_flipped;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_init_prt <= {addr_size{1'b0}};
  end
  else if(memory_chunk_flipped == 1'b0) begin
    memory_addr_init_prt <= memory_chunk_0;
  end
  else begin
    memory_addr_init_prt <= memory_chunk_1;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_init_prv <= {addr_size{1'b0}};
  end
  else if(memory_chunk_flipped == 1'b0) begin
    memory_addr_init_prv <= memory_chunk_1;
  end
  else begin
    memory_addr_init_prv <= memory_chunk_0;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_data_ready <= (1'b0);
  end
  else begin
    memory_data_ready <= (memory_buff_ready[1] == 1'b1);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_buff_ready[1] <= (1'b0);
  end
  else begin
    memory_buff_ready[1] <= (memory_buff_ready[0] == 1'b1);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_buff_ready[0] <= (1'b0);
  end
  else begin
    memory_buff_ready[0] <= (memory_rd_enable == 1'b1);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_data_buffer <= {word_size{1'b0}};
  end
  else begin
    memory_data_buffer <= {memory_data_lemt};
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_rd_data <= {word_size{1'b0}};
  end
  else begin
    memory_rd_data <= {memory_data_buffer};
  end
end


endmodule


/*** This is used to create new segment or strength the exsiting segment ***/
// `include "../param.vh"

module buld_ctrl ( clk, rst,
				   process_learn_enable,
				   process_units_enable,
                   process_enable_buld,
                   compute_addr_done,
                   process_done_calc,
                   process_done_swap,
                   process_done_merg,
                   process_done_find,
				   process_done_sort,
                   packet_proc_done,
                   index_data_lemt,
                   memory_read_calc,
				   buffer_data_rcvd,
				   buffer_data_fifo,
                   memory_data_ready,
                   memory_addr_computed,
                   memory_addr_init_prv,
                   memory_addr_init_prt,
                   /** Output Signal **/
                   memory_addr_load_rcvd,
                   process_done_buld,
                   compute_addr_enable,
                   compute_addr_packet,
                   compute_addr_length,
                   process_enable_find,
                   process_enable_calc,
                   process_enable_swap,
                   process_enable_merg,
                   process_enable_sort,
                   round_flag_head,
				   buffer_data_buld,
                   buffer_read_fifo,
                   buffer_read_port,
                   memory_addr_lemt,
                   memory_wt_data,
                   memory_rd_enable,
                   memory_wt_enable
			     );

parameter   addr_size = `addr_size_lemt,
            word_size = `word_size_para,
            lane_size = `lane_size_para;


parameter   cell_per_column = `cell_per_column_para,
            packet_count_desired = `memory_size_packet - 1,
            memory_addr_init_blk = `memory_addr_init_blk_para,
            memory_addr_init_ind = `memory_addr_init_ind_para;


input wire clk, rst;
input wire process_learn_enable, process_units_enable;
input wire process_enable_buld;
input wire compute_addr_done, memory_read_calc;
input wire memory_data_ready;
input wire process_done_calc, process_done_swap, process_done_merg;
input wire packet_proc_done;
input wire [lane_size - 1 : 0] process_done_find;
input wire [lane_size - 1 : 0] process_done_sort;
input wire [addr_size - 1 : 0] memory_addr_computed;
input wire [word_size - 1 : 0] buffer_data_fifo;
input wire [word_size - 1 : 0] buffer_data_rcvd;
input wire [addr_size - 1 : 0] memory_addr_init_prv;
input wire [addr_size - 1 : 0] memory_addr_init_prt;
input wire [7 : 0] index_data_lemt;


output reg process_done_buld, compute_addr_enable;
output reg [word_size - 1 : 0] compute_addr_packet;
output reg [word_size - 1 : 0] buffer_data_buld;
output reg [3 : 0] compute_addr_length;
output reg [lane_size - 1 : 0] process_enable_find;
output reg [lane_size - 1 : 0] process_enable_sort;
output reg memory_addr_load_rcvd;
output reg process_enable_calc, process_enable_swap, process_enable_merg;
output reg round_flag_head;
output reg memory_rd_enable, memory_wt_enable;
output reg [word_size - 1 : 0] memory_wt_data;
output reg [addr_size - 1 : 0] memory_addr_lemt;
output reg buffer_read_fifo, buffer_read_port;


reg [addr_size - 1 : 0] memory_addr_init, memory_addr_offt;
reg [addr_size - 1 : 0] memory_addr_offt_prv;
reg [addr_size - 1 : 0] memory_addr_offt_col;
reg [lane_size - 1 : 0] lanes_done_flag, lanes_done_sort;
reg [word_size - 1 : 0] buffer_data_blks;
reg [7 : 0] packet_loop_count, cell_index_learn;
reg [7 : 0] index_seg, index_blk, index_col, index_row;
reg [3 : 0] state_buld, next_state_buld;
reg packet_loop_done, packet_dirty_find, packet_updt_done;
reg block_update_flag, memory_read_done;
reg memory_buff_ready, memory_data_done, memory_read_init;
reg memory_addr_updt_col, memory_addr_reset_col, memory_addr_reset_prv;
reg lanes_find_done, bound_pass_lane, lanes_sort_done;
reg process_buffer_calc, process_buffer_swap;
reg swap_occupied_line, calc_occupied_line, merg_occupied_line;
reg calc_occupied_done, swap_occupied_done;
reg index_ready_cell, value_ready_data;
reg pipe_enable_calc, init_enable_calc;
reg [7 : 0] block_info_update, block_data_update;
reg process_data_reset;


genvar index;


always @(posedge clk)
begin
  if(~rst) begin
    state_buld <= 4'b0000;
  end
  else begin
    state_buld <= next_state_buld;
  end
end


always @(*)
begin
  case(state_buld)
    4'b0000: begin
	           if(process_enable_buld == 1'b1) begin
			     next_state_buld = 4'b0001;
			   end
			   else begin
			     next_state_buld = 4'b0000;
			   end
	         end
	4'b0001: begin /** Wait until the packets in the processor is ready for elements **/
	           if(packet_proc_done == 1'b1) begin
			     next_state_buld = 4'b0010;
			   end
			   else begin
			     next_state_buld = 4'b0001;
	           end
	         end
	4'b0010: begin /** Write column and cell index received from processor into sram **/
	           if(packet_loop_done == 1'b1) begin
			     next_state_buld = process_learn_enable ? 4'b0011 : 4'b0000;
			   end
			   else begin
			     next_state_buld = 4'b0010;
	           end
	         end
	4'b0011: begin /** Wait until the packets in the processor is ready for elements **/
	           if(packet_proc_done == 1'b1) begin
			     next_state_buld = 4'b0100;
			   end
			   else begin
			     next_state_buld = 4'b0011;
	           end
	         end
	4'b0100: begin /** Write the learning packets received from processor into sram **/
	           if(packet_loop_done == 1'b1) begin
			     next_state_buld = process_units_enable ? 4'b0101 : 4'b0000; /** First round of temporal **/
			   end
			   else begin
			     next_state_buld = 4'b0100;
	           end
	         end
    4'b0101: begin /** Read the learning packet from sram to check the dirty **/
	           if(memory_buff_ready == 1'b0) begin
			     next_state_buld = 4'b0110;
			   end
			   else begin
			     next_state_buld = 4'b0101;
			   end
	         end
    4'b0110: begin /** Read the column index to obtain learning cell index **/
	           if(memory_buff_ready == 1'b1) begin
			     next_state_buld = 4'b0111;
			   end
			   else begin
			     next_state_buld = 4'b0110;
			   end
	         end
    4'b0111: begin /** Check if the dirty block is found in current packet **/
	           if(packet_updt_done == 1'b1) begin
				 next_state_buld = 4'b0000;
			   end
			   else begin
				 next_state_buld = packet_dirty_find ? 4'b1000 : 4'b0101;
			   end
	         end
    4'b1000: begin /** Compute the address of block in current learning packet **/
	           if(compute_addr_done == 1'b1) begin
				 next_state_buld = 4'b1001;
			   end
			   else begin
				 next_state_buld = 4'b1000;
			   end
	         end
    4'b1001: begin /** Read and update the block info of current learning packet **/
	           if(memory_buff_ready == 1'b1) begin
			     next_state_buld = 4'b1010;
			   end
			   else begin
			     next_state_buld = 4'b1001;
			   end
	         end
    4'b1010: begin /** Compute the address of learning cell in lane sram ***/
	           if(compute_addr_done == 1'b1) begin
			     next_state_buld = block_update_flag ? 4'b1100 : 4'b1011; /** block_update_flag = 1, new segment required **/
			   end
			   else begin
			     next_state_buld = 4'b1010;
			   end
	         end
    4'b1011: begin /** Enhance the strength of segment in current learning packet **/
	           if(lanes_find_done == 1'b1) begin
				 next_state_buld = 4'b0101;
			   end
			   else begin
				 next_state_buld = 4'b1011;
			   end
	         end
    4'b1100: begin /** Trigger logic to bulid new segment in current learning packet **/
	           if(lanes_sort_done == 1'b1) begin
				 next_state_buld = 4'b0101;
			   end
			   else begin
				 next_state_buld = 4'b1100;
			   end
	         end
    default: begin
	           next_state_buld = 4'b0000;
	         end
  endcase
end



always @(posedge clk)
begin
  if(~rst) begin
    process_done_buld <= 1'b0;
  end
  else begin
    process_done_buld <= (next_state_buld == 3'b000)&&(state_buld != 3'b000);
  end
end


always @(*)
begin
  case(state_buld)
    4'b1100: memory_addr_load_rcvd = (process_buffer_swap == 1'b1)&&(merg_occupied_line == 1'b0);
    4'b1010: memory_addr_load_rcvd = (compute_addr_done == 1'b1)&&(block_update_flag == 1'b0);
    default: memory_addr_load_rcvd = 1'b0;
  endcase
end


always @(*)
begin
  if(~rst) begin
    process_data_reset <= 1'b0;
  end
  else begin
    process_data_reset <= (state_buld == 4'b1100)&&(next_state_buld == 4'b0101);
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_data_reset == 1'b1)) begin
    round_flag_head <= 1'b1;
  end
  else if(process_done_merg == 1'b1) begin
    round_flag_head <= 1'b0;
  end
  else begin
    round_flag_head <= round_flag_head;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_lemt <= {addr_size{1'b0}};
  end
  else begin
    memory_addr_lemt <= {memory_addr_init + memory_addr_offt};
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_buff_ready <= (1'b0);
  end
  else begin
    memory_buff_ready <= (memory_data_ready == 1'b1);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_read_init <= 1'b0;
  end
  else begin
    case(state_buld)
      4'b0110: memory_read_init <= 1'b1;
      4'b1001: memory_read_init <= 1'b1;
      default: memory_read_init <= 1'b0;
    endcase
  end
end


/** state_buld == 4'b0010, write column and cell index received from processor into sram **/
/** state_buld == 4'b0100, write the learning packets received from processor into sram **/


always @(posedge clk)
begin
  if(~rst) begin
    buffer_read_port <= 1'b0;
  end
  else begin
    case(next_state_buld)
	  4'b0010: buffer_read_port <= (1'b1);
	  4'b0100: buffer_read_port <= (1'b1);
	  default: buffer_read_port <= (1'b0);
	endcase
  end
end


always @(*)
begin
  packet_loop_done = (buffer_data_rcvd == {word_size{1'b1}});
  packet_updt_done = (buffer_data_buld == {word_size{1'b1}});
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_wt_enable <= 1'b0;
  end
  else begin
    case(state_buld)
	  4'b1001: memory_wt_enable <= (memory_buff_ready == 1'b1);
	  4'b0010: memory_wt_enable <= (1'b1);
	  4'b0100: memory_wt_enable <= (1'b1);
	  default: memory_wt_enable <= (1'b0);
	endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_wt_data <= {word_size{1'b0}};
  end
  else begin
    case(state_buld)
	  4'b0010: memory_wt_data <= {buffer_data_rcvd};
	  4'b0100: memory_wt_data <= {buffer_data_rcvd};
	  4'b1001: memory_wt_data <= {buffer_data_blks}; /** The updated block info **/
	  default: memory_wt_data <= {word_size{1'b0}};
	endcase
  end
end


always @(posedge clk)
begin /** addr offt for both current and previous active column **/
  if((~rst)||(memory_addr_reset_col == 1'b1)) begin
    memory_addr_offt_col <= {addr_size{1'b0}};
  end
  else if(memory_addr_updt_col == 1'b1) begin
    memory_addr_offt_col <= memory_addr_offt_col + 1'b1;
  end
  else begin
    memory_addr_offt_col <= memory_addr_offt_col;
  end
end


always @(*)
begin
  case(state_buld)
    4'b0010: memory_addr_reset_col = (next_state_buld != 4'b0010);
	4'b0100: memory_addr_reset_col = (next_state_buld != 4'b0100);
	4'b0111: memory_addr_reset_col = (next_state_buld == 4'b0000);
	default: memory_addr_reset_col = 1'b0;
  endcase
end


always @(*)
begin
  case(state_buld)
    4'b0010: memory_addr_updt_col = 1'b1;
	4'b0100: memory_addr_updt_col = 1'b1;
	4'b0111: memory_addr_updt_col = 1'b1;
	default: memory_addr_updt_col = 1'b0;
  endcase
end


/** state_buld == 4'b0101, read the learning packet from sram to check the dirty **/
/** state_buld == 4'b0110, read the column index to obtain learning cell index **/


always @(posedge clk)
begin
  if(~rst) begin
    memory_rd_enable <= 1'b0;
  end
  else begin
    case(state_buld)
	  4'b0101: memory_rd_enable <= (1'b1);
	  4'b0110: memory_rd_enable <= (memory_read_init == 1'b0);
	  4'b1001: memory_rd_enable <= (memory_read_init == 1'b0);
	  4'b1011: memory_rd_enable <= (memory_read_done == 1'b1);
	  4'b1100: memory_rd_enable <= (memory_read_calc == 1'b1);
	  default: memory_rd_enable <= (1'b0);
	endcase
  end
end


always @(*)
begin
  case(state_buld)
    4'b0010: memory_addr_init = {memory_addr_init_prt};
	4'b0110: memory_addr_init = {memory_addr_init_prt};
	4'b1001: memory_addr_init = {memory_addr_init_blk};
	4'b1011: memory_addr_init = {memory_addr_init_prv};
	4'b1100: memory_addr_init = {memory_addr_init_prv};
	default: memory_addr_init = {memory_addr_init_ind};
  endcase
end


always @(*)
begin
  case(state_buld)
	4'b1001: memory_addr_offt = {memory_addr_computed};
	4'b1011: memory_addr_offt = {memory_addr_offt_prv};
	4'b1100: memory_addr_offt = {memory_addr_offt_prv};
	default: memory_addr_offt = {memory_addr_offt_col};
  endcase
end


/** state_buld == 4'b0111, check if the dirty block is found in current packet **/


always @(*)
begin
  packet_dirty_find = (buffer_data_buld[7 : 4] == index_data_lemt)&&(buffer_data_buld[0] == 1'b1);
  value_ready_data = (state_buld == 4'b0110)&&(memory_buff_ready == 1'b1); /** learning packet ready **/
  index_ready_cell = (state_buld == 4'b0111); /** cell index ready **/
  memory_data_done = (memory_data_ready == 1'b1)&&(memory_buff_ready == 1'b0);
end


always @(posedge clk)
begin
  if(~rst) begin /** learning packet **/
    buffer_data_buld <= {word_size{1'b0}};
  end
  else if(value_ready_data == 1'b1) begin
    buffer_data_buld <= buffer_data_fifo;
  end
  else begin
    buffer_data_buld <= buffer_data_buld;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_read_fifo <= 1'b0;
  end
  begin
    case(state_buld)
	  4'b0110: buffer_read_fifo <= (memory_data_done == 1'b1);
	  4'b0111: buffer_read_fifo <= (1'b1);
	  4'b1010: buffer_read_fifo <= (compute_addr_done == 1'b1);
	  default: buffer_read_fifo <= (1'b0);
	endcase
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_done_buld == 1'b1)) begin
    cell_index_learn <= cell_per_column;
  end
  else if(index_ready_cell == 1'b1) begin
    cell_index_learn <= buffer_data_fifo[7 : 0];
  end
  else begin
    cell_index_learn <= cell_index_learn;
  end
end


/** state_buld == 4'b1000, compute the address of block in current learning packet **/
/** state_buld == 4'b1010, compute the address of learning cell in lane sram ***/


always @(*)
begin
  index_seg = {4'b0000, buffer_data_buld[word_size - 21 : word_size - 24]};
  index_blk = {4'b0000, buffer_data_buld[word_size - 17 : word_size - 20]};
  index_col = {buffer_data_buld[word_size - 9 : word_size - 16]};
  index_row = {buffer_data_buld[word_size - 1 : word_size - 08]};
end


always @(posedge clk)
begin
  if(~rst) begin
    compute_addr_enable <= 1'b0;
  end
  else begin
    case(next_state_buld)
      4'b1000: compute_addr_enable <= (state_buld == 4'b0111);
      4'b1010: compute_addr_enable <= (state_buld == 4'b1001);
      default: compute_addr_enable <= 1'b0;
    endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    compute_addr_packet <= {word_size{1'b0}};
  end
  else begin
    case(next_state_buld)
      4'b1000: compute_addr_packet <= {8'h00,     index_blk, index_col, index_row};
      4'b1010: compute_addr_packet <= {index_seg, index_blk, index_col, index_row};
      default: compute_addr_packet <= {word_size{1'b0}};
    endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    compute_addr_length <= 4'b0000;
  end
  else begin
    case(next_state_buld)
      4'b1000: compute_addr_length <= 4'b1010;
      4'b1010: compute_addr_length <= 4'b0100;
      default: compute_addr_length <= 4'b0000;
    endcase
  end
end


/** state_buld == 4'b1001, read and update the block info of current learning packet **/


always @(*)
begin
  block_data_update = block_update_flag ? 8'b00010010 : 8'b00000010;
  block_info_update = buffer_data_fifo[word_size - 9 : word_size - 16] + block_data_update;
end

always @(*)
begin
  buffer_data_blks = {cell_index_learn, block_info_update, 16'h0000};
  block_update_flag = (buffer_data_fifo[word_size - 9 : word_size - 16] == buffer_data_buld[word_size -  21 : word_size - 24]);
end


/** state_buld == 4'b1011, enhance the strength of segment in current learning packet **/


always @(posedge clk)
begin
  if(~rst) begin
    process_enable_find <= {lane_size{1'b0}};
  end
  else begin
    process_enable_find <= {lane_size{(state_buld == 4'b1010)&&(next_state_buld == 4'b1011)}};
  end
end


always @(*)
begin
  memory_read_done = (memory_addr_offt_prv <= packet_count_desired);
  lanes_find_done = (lanes_done_flag == {lane_size{1'b1}});
end


generate

   for(index = 0; index < lane_size; index = index + 1)
   begin: flags

	  always @(posedge clk)
	  begin
	    if((~rst)||(lanes_find_done == 1'b1)) begin
		  lanes_done_flag[index] <= 1'b0;
		end
		else if(process_done_find[index] == 1'b1) begin
		  lanes_done_flag[index] <= 1'b1;
		end
		else begin
		  lanes_done_flag[index] <= lanes_done_flag[index];
        end
      end

   end

endgenerate


always@(*)
begin
  case(state_buld)
    4'b1011: memory_addr_reset_prv = (next_state_buld == 4'b0101);
    4'b1100: memory_addr_reset_prv = (next_state_buld == 4'b0101);
    default: memory_addr_reset_prv = 1'b0;
  endcase
end



always @(posedge clk)
begin
  if((~rst)||(memory_addr_reset_prv == 1'b1)) begin
    memory_addr_offt_prv <= {word_size{1'b0}};
  end
  else if((state_buld == 4'b1011)||(memory_read_calc == 1'b1)) begin
    memory_addr_offt_prv <= memory_addr_offt_prv + 1'b1;
  end
  else begin
    memory_addr_offt_prv <= memory_addr_offt_prv;
  end
end

reg memory_test;


always @(posedge clk)
begin
  if(~rst) begin
    memory_test <= 1'b0;
  end
  else begin
    case(state_buld)
	  4'b1100: memory_test <= (memory_read_calc == 1'b1);
	  default: memory_test <= (1'b0);
	endcase
  end
end

/**
always @(posedge clk)
begin
  if((~rst)||(lanes_find_done == 1'b1)) begin
    memory_addr_offt_prv <= {word_size{1'b0}};
  end
  else if((state_buld == 4'b1011)||(memory_read_calc == 1'b1)) begin
    memory_addr_offt_prv <= memory_addr_offt_prv + 1'b1;
  end
  else begin
    memory_addr_offt_prv <= memory_addr_offt_prv;
  end
end
**/

/** state_buld == 4'b1100, trigger logic to bulid new segment in current learning packet **/


always @(*)
begin
  pipe_enable_calc = (process_buffer_calc == 1'b1)&&(swap_occupied_line == 1'b0)&&(bound_pass_lane == 1'b0);
  init_enable_calc = (state_buld == 4'b1010)&&(next_state_buld == 4'b1100);
end


always @(posedge clk)
begin
  if((~rst)||(process_data_reset == 1'b1)) begin
    packet_loop_count <= 8'b00000000;
  end
  else if(process_enable_calc == 1'b1) begin
    packet_loop_count <= packet_loop_count + lane_size;
  end
  else begin
    packet_loop_count <= packet_loop_count;
  end
end


always @(*)
begin
  bound_pass_lane = (packet_loop_count >= packet_count_desired[7: 0]);
end


always @(posedge clk)
begin
  if(~rst) begin
	process_enable_calc <= 1'b0;
  end
  else begin
	process_enable_calc <= (pipe_enable_calc == 1'b1)||(init_enable_calc == 1'b1);
  end
end


always @(posedge clk)
begin
  if((~rst)||(calc_occupied_done == 1'b1)) begin
	process_buffer_calc <= 1'b0;
  end
  else if(process_done_calc == 1'b1) begin
	process_buffer_calc <= 1'b1;
  end
  else begin
	process_buffer_calc <= process_buffer_calc;
  end
end


always @(*)
begin
  if((process_buffer_calc == 1'b1)&&(swap_occupied_line == 1'b0)) begin
	calc_occupied_done = 1'b1;
  end
  else begin
	calc_occupied_done = 1'b0;
  end
end


always @(posedge clk)
begin
  if((~rst)||(calc_occupied_done == 1'b1)) begin
	calc_occupied_line <= 1'b0;
  end
  else if(process_enable_calc == 1'b1) begin
	calc_occupied_line <= 1'b1;
  end
  else begin
	calc_occupied_line<= calc_occupied_line;
  end
end


/** The control logic used for the rank **/

always @(posedge clk)
begin
  if(~rst) begin
	process_enable_swap <= 1'b0;
  end
  else begin
	process_enable_swap <= (process_buffer_calc == 1'b1)&&(swap_occupied_line == 1'b0);
  end
end


always @(posedge clk)
begin
  if((~rst)||(swap_occupied_done == 1'b1)) begin
	process_buffer_swap <= 1'b0;
  end
  else if(process_done_swap == 1'b1) begin
	process_buffer_swap <= 1'b1;
  end
  else begin
	process_buffer_swap <= process_buffer_swap;
  end
end


always @(*)
begin
  if((process_buffer_swap == 1'b1)&&(merg_occupied_line == 1'b0)) begin
	swap_occupied_done = 1'b1;
  end
  else begin
	swap_occupied_done = 1'b0;
  end
end


always @(posedge clk)
begin
  if((~rst)||(swap_occupied_done == 1'b1)) begin
	swap_occupied_line <= 1'b0;
  end
  else if(process_enable_swap == 1'b1) begin
	swap_occupied_line <= 1'b1;
  end
  else begin
	swap_occupied_line <= swap_occupied_line;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    process_enable_merg <= 1'b0;
  end
  else begin
    process_enable_merg <= (process_buffer_swap == 1'b1)&&(merg_occupied_line == 1'b0);
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_done_merg == 1'b1)) begin
    merg_occupied_line <= 1'b0;
  end
  else if(process_enable_merg == 1'b1) begin
    merg_occupied_line <= 1'b1;
  end
  else begin
    merg_occupied_line <= merg_occupied_line;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    process_enable_sort <= {lane_size{1'b0}};
  end
  else begin
    process_enable_sort <= {lane_size{(process_done_merg == 1'b1)&&(bound_pass_lane == 1'b1)&&(swap_occupied_line == 1'b0)}};
  end
end


always @(*)
begin
  lanes_sort_done = (lanes_done_sort == {lane_size{1'b1}});
end


generate

   for(index = 0; index < lane_size; index = index + 1)
   begin: sort_flags

	  always @(posedge clk)
	  begin
	    if((~rst)||(lanes_sort_done == 1'b1)) begin
		  lanes_done_sort[index] <= 1'b0;
		end
		else if(process_done_sort[index] == 1'b1) begin
		  lanes_done_sort[index] <= 1'b1;
		end
		else begin
		  lanes_done_sort[index] <= lanes_done_sort[index];
        end
      end

   end

endgenerate



endmodule


/*** This unit is used to calculate the range the learning candidate ***/
/*** The nearer learning column has higher priority to be connected ***/
/*** There is only on ranger per element, using three stage pipeline ***/
// `include "../param.vh"

module calc_ctrl ( clk, rst,
                   process_enable_calc,
                   buffer_data_fifo,
                   buffer_data_buld,
                   memory_data_ready,
                   /** Output Signal **/
                   process_done_calc,
                   buffer_data_0,
                   buffer_data_1,
                   buffer_data_2,
                   buffer_data_3,
                   buffer_data_4,
                   buffer_data_5,
                   buffer_data_6,
                   buffer_data_7,
				   buffer_read_fifo,
				   memory_read_calc
                 );

parameter   word_size = `word_size_para,
            addr_size = `addr_size_para,
            lane_size = `lane_size_para;

input wire clk, rst;
input wire process_enable_calc;
input wire [word_size - 1 : 0] buffer_data_buld;  /** Data from build logic unit, active column at t **/
input wire [word_size - 1 : 0] buffer_data_fifo;  /** Data from element memory, active column at t-1 **/
input wire memory_data_ready;


output reg [word_size - 1 : 0] buffer_data_0, buffer_data_1;
output reg [word_size - 1 : 0] buffer_data_2, buffer_data_3;
output reg [word_size - 1 : 0] buffer_data_4, buffer_data_5;
output reg [word_size - 1 : 0] buffer_data_6, buffer_data_7;
output reg process_done_calc;
output reg buffer_read_fifo, memory_read_calc;


reg [word_size - 1 : 0] buffer_data_calc [lane_size - 1 : 0];
reg [7 : 0] index_col_ref, index_row_ref;
reg [7 : 0] index_col_tar, index_row_tar;
reg [7 : 0] index_lrn_ref;
reg [7 : 0] distance_row, distance_col, distance_rcvd;
reg [word_size - 1 : 0] buffer_data_find;
reg [2  : 0] state_calc, next_state_calc;
reg [23 : 0] column_index;
reg [7  : 0] logic_timer_calc;
reg [2  : 0] index_buffer;
reg logic_timer_count, logic_timer_reset;
reg index_buffer_count;
reg distance_zero, distance_find;
reg buffer_read_done;
reg buffer_data_ready, buffer_data_valid;





integer index;


always @(*)
begin
  index_row_ref = buffer_data_fifo[word_size - 01 : word_size - 08];
  index_col_ref = buffer_data_fifo[word_size - 09 : word_size - 16];
  index_lrn_ref = buffer_data_fifo[word_size - 25 : word_size - 32];
end


always @(*)
begin
  index_row_tar = buffer_data_buld[word_size - 1 : word_size - 08];
  index_col_tar = buffer_data_buld[word_size - 9 : word_size - 16];
end


always @(posedge clk)
begin
  if(~rst) begin
    state_calc <= 3'b000;
  end
  else begin
    state_calc <= next_state_calc;
  end
end


always @(*)
begin
  case(state_calc)
    3'b000 : begin
	           if(process_enable_calc == 1'b1) begin
			     next_state_calc = 3'b001;
			   end
			   else begin
			     next_state_calc = 3'b000;
			   end
			 end
	3'b001 : begin /** Read the previous active columns from element sram **/
	           if(buffer_read_done == 1'b1) begin
			     next_state_calc = 3'b010;
			   end
			   else begin
			     next_state_calc = 3'b001;
			   end
	         end
	3'b010 : begin /** The data reading of current round is done compute **/
	           if(buffer_data_ready == 1'b0) begin
			     next_state_calc = 3'b011;
			   end
			   else begin
			     next_state_calc = 3'b010;
			   end
	         end
	3'b011 : begin
		   next_state_calc = 3'b000;
	         end
	default: begin
	           next_state_calc = 3'b000;
	         end
  endcase
end


always @(posedge clk)
begin
  if(~rst) begin
    process_done_calc <= 1'b0;
  end
  else begin
    process_done_calc <= (next_state_calc == 3'b000)&&(state_calc == 3'b011);
  end
end

/**
always @(*)
begin
  buffer_index_reset = (next_state_calc == 3'b000)&&(state_calc == 3'b011);
  buffer_data_ready = (state_calc == 3'b010)||(state_calc == 3'b011);
end
**/

always @(*)
begin
  buffer_read_done = (logic_timer_calc == (lane_size - 1));
  memory_read_calc = (next_state_calc == 3'b001);
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_data_ready <= 1'b0;
  end
  else begin
    buffer_data_ready <= (memory_data_ready == 1'b1);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    distance_row <= 8'b00000000;
  end
  else if((index_row_ref >= index_row_tar)&&(buffer_data_ready == 1'b1)) begin
    distance_row <= index_row_ref - index_row_tar;
  end
  else if((index_row_ref <= index_row_tar)&&(buffer_data_ready == 1'b1)) begin
    distance_row <= index_row_tar - index_row_ref;
  end
  else begin
    distance_row <= distance_row;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    distance_col <= 8'b00000000;
  end
  else if((index_col_ref >= index_col_tar)&&(buffer_data_ready == 1'b1)) begin
    distance_col <= index_col_ref - index_col_tar;
  end
  else if((index_col_ref <= index_col_tar)&&(buffer_data_ready == 1'b1)) begin
    distance_col <= index_col_tar - index_col_ref;
  end
  else begin
    distance_col <= distance_col;
  end
end


always @(*)
begin
  distance_zero = (distance_row == 8'b00000000)&&(distance_col == 8'b00000000);
  distance_find = (distance_row >= distance_col);
  distance_rcvd = (distance_zero == 1'b1) ?  8'b11111111 : (distance_find ? distance_row : distance_col);
end


always @(posedge clk)
begin
  if(~rst) begin
    column_index <= {24'h000000};
  end
  else begin
    column_index <= {index_row_ref, index_col_ref, index_lrn_ref};
  end
end


always @(posedge clk)
begin /** The 'fffff' flag is read into buffer **/
  if(~rst) begin
    buffer_data_valid <= 1'b0;
  end
  else begin
    buffer_data_valid <= (buffer_data_fifo == {word_size{1'b1}});
  end
end


always @(*)
begin
  buffer_data_find = buffer_data_valid ? {word_size{1'b1}} : {distance_rcvd, column_index};
end


always @(posedge clk)
begin
  if(~rst) begin
    index_buffer_count <= 1'b0;
  end
  else begin
    case(state_calc)
      3'b001 : index_buffer_count <= buffer_data_ready;
      3'b010 : index_buffer_count <= buffer_data_ready;
      default: index_buffer_count <= 1'b0;
    endcase
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_done_calc == 1'b1)) begin
    index_buffer <= 3'b000;
  end
  else if(index_buffer_count == 1'b1) begin
    index_buffer <= index_buffer + 1'b1;
  end
  else begin
    index_buffer <= index_buffer;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    for(index = 0; index < lane_size; index = index + 1)
      buffer_data_calc[index] <= {word_size{1'b1}};
  end
  else if(index_buffer_count == 1'b1) begin
    buffer_data_calc[index_buffer] <= buffer_data_find;
  end
  else begin
    for(index = 0; index < lane_size; index = index + 1)
      buffer_data_calc[index] <= buffer_data_calc[index];
  end
end


/**
always @(posedge clk)
begin
  if(~rst) begin
    buffer_read_fifo <= 1'b0;
  end
  else begin
    case(next_state_calc)
	  3'b010 : buffer_read_fifo <= 1'b1;
	  3'b011 : buffer_read_fifo <= 1'b1;
	  default: buffer_read_fifo <= 1'b0;
	endcase
  end
end


always @(*)
begin
  buffer_read_reset = (state_calc == 3'b011)&&(logic_timer_calc == 4'b0010);
end


always @(posedge clk)
begin
  if((~rst)||(buffer_read_reset == 1'b1)) begin
    buffer_read_fifo <= 1'b0;
  end
  else if((next_state_calc == 3'b010)&&(state_calc == 3'b001)) begin
    buffer_read_fifo <= 1'b1;
  end
  else begin
    buffer_read_fifo <= buffer_read_fifo;
  end
end
**/


always @(posedge clk)
begin
  if(~rst) begin
    buffer_read_fifo <= 1'b0;
  end
  else begin
    case(state_calc)
      3'b001 : buffer_read_fifo <= memory_data_ready;
      3'b010 : buffer_read_fifo <= memory_data_ready;
      default: buffer_read_fifo <= 1'b0;
    endcase
  end
end


always @(posedge clk)
begin
  if((~rst)||(logic_timer_reset == 1'b1)) begin
    logic_timer_calc <= 4'b0000;
  end
  else if(logic_timer_count == 1'b1) begin
    logic_timer_calc <= logic_timer_calc + 1'b1;
  end
  else begin
    logic_timer_calc <= logic_timer_calc;
  end
end


always @(*)
begin
  case(state_calc)
    3'b001 : logic_timer_count = 1'b1;
	default: logic_timer_count = 1'b0;
  endcase
end


always @(*)
begin
  case(state_calc)
    3'b001 : logic_timer_reset = (next_state_calc == 3'b010);
	default: logic_timer_reset = 1'b0;
  endcase
end


always @(*)
begin
  buffer_data_0 = buffer_data_calc[0];
  buffer_data_1 = buffer_data_calc[1];
  buffer_data_2 = buffer_data_calc[2];
  buffer_data_3 = buffer_data_calc[3];
  buffer_data_4 = buffer_data_calc[4];
  buffer_data_5 = buffer_data_calc[5];
  buffer_data_6 = buffer_data_calc[6];
  buffer_data_7 = buffer_data_calc[7];
end



endmodule


// `include "../param.vh"

module fifo_lemt ( clk, rst,
                   buffer_wt_enable,
                   buffer_rd_enable,
                   buffer_wt_data,
                   buffer_data_reset,
                   /** Output Signal **/
                   buffer_rd_data
                 );

parameter  buff_size = `buff_size_lemt;
parameter  word_size = `word_size_para;


input wire clk, rst;
input wire [0 : 0] buffer_wt_enable;
input wire [6 : 0] buffer_rd_enable;
input wire buffer_data_reset;
input wire [word_size - 1 : 0] buffer_wt_data;

output reg [word_size - 1 : 0] buffer_rd_data;


reg [word_size - 1 : 0] buffer_data_fifo [buff_size - 1 : 0];
reg [word_size - 1 : 0] buffer_data_next [buff_size - 1 : 0];
reg [3 : 0] buffer_rd_index, buffer_wt_index;
reg buffer_rd_reset, buffer_wt_reset;
reg buffer_data_read, buffer_data_wten;


integer index;


always @(*)
begin
  buffer_data_read = (buffer_rd_enable != 7'b0000000);
  buffer_data_wten = (buffer_wt_enable == 1'b1);
end


always @(posedge clk )
begin
  if((~rst)||(buffer_data_reset == 1'b1)) begin
    for(index = 0; index < buff_size; index = index + 1)
      buffer_data_fifo[index] <= {word_size{1'b0}};
  end
  else begin
    for(index = 0; index < buff_size; index = index + 1)
      buffer_data_fifo[index] <= buffer_data_next[index];
  end
end


always @(*)
begin
  if(buffer_data_wten == 1'b1) begin
    for(index = 0; index < buff_size; index = index + 1)
      buffer_data_next[index] = buffer_data_fifo[index];
      buffer_data_next[buffer_wt_index] = buffer_wt_data;
  end
  else begin
    for(index = 0; index < buff_size; index = index + 1)
      buffer_data_next[index] = buffer_data_fifo[index];
  end
end


always @(*)
begin
  buffer_rd_reset = ((buffer_rd_index == (buff_size - 1))&&(buffer_data_read == 1'b1))||(buffer_data_reset == 1'b1);
  buffer_wt_reset = ((buffer_wt_index == (buff_size - 1))&&(buffer_data_wten == 1'b1))||(buffer_data_reset == 1'b1);
end


always @(posedge clk)
begin
  if((~rst)||(buffer_rd_reset == 1'b1)) begin
    buffer_rd_index <= 3'b000;
  end
  else if(buffer_data_read == 1'b1) begin
    buffer_rd_index <= buffer_rd_index + 1'b1;
  end
  else begin
    buffer_rd_index <= buffer_rd_index;
  end
end


always @(posedge clk)
begin
  if((~rst)||(buffer_wt_reset == 1'b1)) begin
    buffer_wt_index <= 3'b000;
  end
  else if(buffer_data_wten == 1'b1) begin
    buffer_wt_index <= buffer_wt_index + 1'b1;
  end
  else begin
    buffer_wt_index <= buffer_wt_index;
  end
end


always @(*)
begin
  buffer_rd_data = buffer_data_fifo[buffer_rd_index];
end


endmodule


/** control logic used on the sort the index of active column and download from processor **/
// `include "../param.vh"

module indx_ctrl ( clk, rst,
                   process_enable_indx,
                   memory_addr_init_prt,
				   packet_data_rcvd,
                   value_sorted_0,
                   value_sorted_1,
                   value_sorted_2,
                   value_sorted_3,
                   value_sorted_4,
                   value_sorted_5,
                   value_sorted_6,
                   value_sorted_7,
                   buffer_send_full,
				   buffer_rd_data,
				   index_data_elmt,
                   packet_proc_done,
				   result_sort_ready,
				   memory_data_ready,
				   /** output signal **/
                   process_done_indx,
                   buffer_output_0,
                   buffer_output_1,
                   buffer_output_2,
                   buffer_output_3,
                   buffer_output_4,
                   buffer_output_5,
                   buffer_output_6,
                   buffer_output_7,
                   packet_sort_ready,
				   buffer_read_port,
				   buffer_read_fifo,
                   memory_addr_lemt,
				   memory_wt_data,
				   memory_wt_enable,
			       memory_rd_enable,
				   packet_inst_send,
				   packet_data_send,
                   packet_enable_send
                 );

parameter word_size = `word_size_para,
          addr_size = `addr_size_lemt,
          lane_size = `lane_size_para,
          buff_size = `buff_size_lemt,
          inst_sort = 8'h01;


input wire clk, rst;
input wire process_enable_indx, memory_data_ready;
input wire buffer_send_full;
input wire [addr_size - 1 : 0] memory_addr_init_prt;
input wire [word_size - 1 : 0] value_sorted_0;
input wire [word_size - 1 : 0] value_sorted_1;
input wire [word_size - 1 : 0] value_sorted_2;
input wire [word_size - 1 : 0] value_sorted_3;
input wire [word_size - 1 : 0] value_sorted_4;
input wire [word_size - 1 : 0] value_sorted_5;
input wire [word_size - 1 : 0] value_sorted_6;
input wire [word_size - 1 : 0] value_sorted_7;
input wire packet_proc_done, result_sort_ready;
input wire [word_size - 1 : 0] buffer_rd_data;
input wire [word_size - 1 : 0] packet_data_rcvd;
input wire [7 : 0] index_data_elmt;


output reg process_done_indx;
output reg [word_size - 1 : 0] buffer_output_0;
output reg [word_size - 1 : 0] buffer_output_1;
output reg [word_size - 1 : 0] buffer_output_2;
output reg [word_size - 1 : 0] buffer_output_3;
output reg [word_size - 1 : 0] buffer_output_4;
output reg [word_size - 1 : 0] buffer_output_5;
output reg [word_size - 1 : 0] buffer_output_6;
output reg [word_size - 1 : 0] buffer_output_7;
output reg packet_sort_ready;
output reg packet_enable_send;
output reg [word_size - 1 : 0] packet_inst_send;
output reg [word_size - 1 : 0] packet_data_send;
output reg [addr_size - 1 : 0] memory_addr_lemt;
output reg [word_size - 1 : 0] memory_wt_data;
output reg buffer_read_port, buffer_read_fifo;
output reg memory_wt_enable, memory_rd_enable;



reg process_done_item, packet_loop_done;
reg [2 : 0] state_indx, next_state_indx;
reg [2 : 0] index_buffer;
reg [7 : 0] buffer_rd_count, buffer_wt_count;
reg packet_send_done;
reg [word_size - 1 : 0] buffer_data_rcvd [lane_size - 1 : 0];
reg [word_size - 1 : 0] buffer_data_mem [lane_size - 1 : 0];
reg buffer_index_count, buffer_index_reset;
reg [addr_size - 1 : 0] memory_addr_init;
reg [addr_size - 1 : 0] memory_addr_offt;
reg memory_addr_count, memory_addr_reset;
reg packet_rcvd_done, memory_read_done;
reg dirty_data_found, buffer_data_ready;
reg [word_size - 1 : 0] packet_data_temp;
reg buffer_data_done;


integer index;


always @(*)
begin
  buffer_data_rcvd[0] = value_sorted_0;
  buffer_data_rcvd[1] = value_sorted_1;
  buffer_data_rcvd[2] = value_sorted_2;
  buffer_data_rcvd[3] = value_sorted_3;
  buffer_data_rcvd[4] = value_sorted_4;
  buffer_data_rcvd[5] = value_sorted_5;
  buffer_data_rcvd[6] = value_sorted_6;
  buffer_data_rcvd[7] = value_sorted_7;

  buffer_output_0 = buffer_data_mem[0];
  buffer_output_1 = buffer_data_mem[1];
  buffer_output_2 = buffer_data_mem[2];
  buffer_output_3 = buffer_data_mem[3];
  buffer_output_4 = buffer_data_mem[4];
  buffer_output_5 = buffer_data_mem[5];
  buffer_output_6 = buffer_data_mem[6];
  buffer_output_7 = buffer_data_mem[7];
end


always @(posedge clk)
begin
  if(~rst) begin
    state_indx <= 3'b000;
  end
  else begin
    state_indx <= next_state_indx;
  end
end


always @(*)
begin
  case(state_indx)
    3'b000 : begin
	           if(process_enable_indx == 1'b1) begin
			     next_state_indx = 3'b010;
			   end
			   else begin
			     next_state_indx = 3'b000;
			   end
			 end
    3'b001 : begin /** Wait until the sorting in processor is done **/
               if(packet_proc_done == 1'b1) begin
                 next_state_indx = packet_loop_done ? 3'b111 : 3'b011;
               end
               else begin
                 next_state_indx = 3'b001;
               end
             end
    3'b010 : begin /** Write the index of active column into sram **/
	           if(packet_rcvd_done == 1'b1) begin
			     next_state_indx = 3'b011;
			   end
			   else begin
			     next_state_indx = 3'b010;
			   end
			 end
    3'b011 : begin /** Read index of active column into buffer **/
	           if(memory_read_done == 1'b1) begin
			     next_state_indx = 3'b100;
			   end
			   else begin
			     next_state_indx = 3'b011;
			   end
			 end
    3'b100 : begin /** Wait until the data is ready in buffer **/
	         if(buffer_data_done == 1'b1) begin //if(memory_data_ready == 1'b0) begin
			     next_state_indx = 3'b101;
			   end
			   else begin
			     next_state_indx = 3'b100;
			   end
			 end
	3'b101 : begin /** Trigger the sort device for active column index **/
               if(result_sort_ready == 1'b1) begin
			     next_state_indx = 3'b110;
			   end
			   else begin
			     next_state_indx = 3'b101;
			   end
             end
    3'b110 : begin /** Send the sorted index back to processor **/
	           if(packet_proc_done == 1'b1) begin
			     next_state_indx = packet_loop_done ? 3'b111 : 3'b011;
			   end
			   else begin
			     next_state_indx = 3'b110;
			   end
             end
    3'b111 : begin /** Write the sorted active column index into memory **/
	           if(packet_rcvd_done == 1'b1) begin
			     next_state_indx = 3'b000;
			   end
			   else begin
			     next_state_indx = 3'b111;
			   end
			 end
    default :begin
	           next_state_indx = 3'b000;
			 end
  endcase
end


always @(posedge clk)
begin
  if(~rst) begin
    process_done_indx <= 1'b0;
  end
  else begin
    process_done_indx <= (next_state_indx == 3'b000)&&(state_indx != 3'b000);
  end
end


always @(*)
begin
  if((state_indx == 3'b110)&&(next_state_indx != 3'b110)) begin
    process_done_item = 1'b1;
  end
  else begin
    process_done_item = 1'b0;
  end
end


always @(*)
begin
  packet_loop_done = (buffer_rd_count == buffer_wt_count); /** memory_fifo **/
end


/** state_indx == 3'b010, write the index of active column into sram  **/


always @(posedge clk)
begin
  if(~rst) begin
    buffer_read_port <= 1'b0;
  end
  else begin
    buffer_read_port <= (next_state_indx == 3'b010)||(next_state_indx == 3'b111);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_wt_enable <= 1'b0;
  end
  else begin
    case(state_indx)
      3'b010 : memory_wt_enable <= (dirty_data_found == 1'b1);
      3'b111 : memory_wt_enable <= (1'b1);
      default: memory_wt_enable <= (1'b0);
    endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_wt_data <= {word_size{1'b0}};
  end
  else begin
    case(state_indx)
	  3'b010 : memory_wt_data <= {packet_data_rcvd};
          3'b111 : memory_wt_data <= {packet_data_rcvd};
	  default: memory_wt_data <= {word_size{1'b0}};
	endcase
  end
end


always @(*)
begin
  packet_rcvd_done = ({packet_data_rcvd[word_size - 1 : word_size - 24],8'hff} == {word_size{1'b1}});
  dirty_data_found = ({index_data_elmt} == {packet_data_rcvd[7 : 0]})&&(state_indx == 3'b010)&&(packet_rcvd_done == 1'b0);
end


always @(posedge clk)
begin
  if((~rst)||(process_done_indx == 1'b1)) begin
    buffer_wt_count <= 8'b00000000;
  end
  else if((state_indx == 3'b010)&&(dirty_data_found == 1'b1)) begin
    buffer_wt_count <= buffer_wt_count + 1'b1;
  end
  else begin
    buffer_wt_count <= buffer_wt_count;
  end
end


/** state_indx == 3'b011, read index of active column into buffer **/


always @(posedge clk)
begin
  if(~rst) begin
    memory_rd_enable <= 1'b0;
  end
  else begin
    memory_rd_enable <= (state_indx == 3'b011);
  end
end


always@(posedge clk)
begin
  if((~rst)||(process_done_indx == 1'b1)) begin
    buffer_rd_count <= 8'b00000000;
  end
  else if(next_state_indx == 3'b011) begin
    buffer_rd_count <= buffer_rd_count + 1'b1;
  end
  else begin
    buffer_rd_count <= buffer_rd_count;
  end
end


always @(*)
begin
  memory_read_done = ((buffer_rd_count == buffer_wt_count)||(buffer_rd_count == (buff_size - 1)))&&(state_indx == 3'b011);
end


always @(posedge clk)
begin
  if((~rst)||(buffer_index_reset == 1'b1)) begin
    index_buffer <= 3'b000;
  end
  else if(buffer_index_count == 1'b1) begin
    index_buffer <= index_buffer + 1'b1;  /* from memory **/
  end
  else begin
    index_buffer <= index_buffer;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_data_ready <= 1'b0;
  end
  else begin
    buffer_data_ready <= (memory_data_ready == 1'b1);
  end
end


always @(*)
begin
  buffer_data_done = (buffer_data_ready == 1'b1)&&(memory_data_ready == 1'b0);
end


always @(*)
begin
  case(state_indx)
    3'b011 : buffer_index_count = (buffer_data_ready == 1'b1);
    3'b100 : buffer_index_count = (buffer_data_ready == 1'b1);
    3'b110 : buffer_index_count = (buffer_send_full == 1'b0);
    default: buffer_index_count = 1'b0;
  endcase
end


always @(*)
begin
  case(state_indx)
    3'b101 : buffer_index_reset = (next_state_indx != 3'b101);
	3'b110 : buffer_index_reset = (next_state_indx != 3'b110);
    default: buffer_index_reset = 1'b0;
  endcase
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_read_fifo <= 1'b0;
  end
  else begin
    buffer_read_fifo <= (memory_data_ready == 1'b1)&&(state_indx != 3'b000);
  end
end


always @(posedge clk)
begin
  if((~rst)||(packet_proc_done == 1'b1)) begin
    for(index = 0; index < buff_size; index = index + 1)
      buffer_data_mem[index] <= {word_size{1'b1}};
  end
  else if((buffer_data_ready == 1'b1)&&(state_indx == 3'b100)) begin
    buffer_data_mem[index_buffer] <= buffer_rd_data;
  end
  else begin
    for(index = 0; index < buff_size; index = index + 1)
      buffer_data_mem[index] <= buffer_data_mem[index];
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_lemt <= {addr_size{1'b0}};
  end
  else begin
    memory_addr_lemt <= {memory_addr_init + memory_addr_offt};
  end
end


always @(*)
begin
  memory_addr_init = memory_addr_init_prt;
end


always @(posedge clk)
begin
  if((~rst)||(memory_addr_reset == 1'b1)) begin
    memory_addr_offt <= {addr_size{1'b0}};
  end
  else if(memory_addr_count == 1'b1) begin
    memory_addr_offt <= memory_addr_offt + 1'b1;
  end
  else begin
    memory_addr_offt <= memory_addr_offt;
  end
end


always @(*)
begin
  case(next_state_indx)
    3'b010 : memory_addr_count = (dirty_data_found == 1'b1);
	3'b011 : memory_addr_count = (1'b1);
	3'b111 : memory_addr_count = (state_indx == 3'b111);
	default: memory_addr_count = (1'b0);
  endcase
end


always @(*)
begin
  case(state_indx)
    3'b010 : memory_addr_reset = (packet_rcvd_done == 1'b1);
    3'b100 : memory_addr_reset = (packet_loop_done == 1'b1);
    3'b111 : memory_addr_reset = (packet_rcvd_done == 1'b1);
    default: memory_addr_reset = (1'b0);
  endcase
end


/** state_indx == 3'b101, trigger the sort device for active column index **/


always @(posedge clk)
begin /** need to wait memory data into buffer **/
  if(~rst) begin
    packet_sort_ready <= 1'b0;
  end
  else begin
    packet_sort_ready <= (next_state_indx == 3'b101)&&(state_indx != 3'b101);
  end
end


/** state_indx == 3'b110, send the sorted index back to processor **/


always @(posedge clk)
begin
  if(~rst) begin
    packet_enable_send <= 1'b0;
  end
  else begin
    case(next_state_indx)
	  3'b110 : packet_enable_send <= 1'b1;
	  default: packet_enable_send <= 1'b0;
	endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    packet_inst_send <= {word_size{1'b0}};
  end
  else begin
    packet_inst_send <= {16'h0000, inst_sort, {7'b0000000, packet_loop_done}}; /**indicate if last round of columns **/
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    packet_data_send <= {word_size{1'b0}};
  end
  else begin
    case(next_state_indx)
	  3'b110 : packet_data_send <= {packet_data_temp};
	  default: packet_data_send <= {word_size{1'b0}};
    endcase
  end
end


always @(*)
begin
  packet_data_temp = packet_send_done ? {word_size{1'b1}} : {buffer_data_rcvd[index_buffer]};
end


always @(posedge clk)
begin
  if((~rst)||(packet_proc_done == 1'b1)) begin
    packet_send_done <= 1'b0;
  end
  else if((buffer_data_rcvd[index_buffer] == {word_size{1'b1}})&&(state_indx == 3'b110)) begin
    packet_send_done <= 1'b1;
  end
  else begin
    packet_send_done <= packet_send_done;
  end
end



endmodule


/** The initial unit in each processing element for lanes **/
// `include "../param.vh"

module init_ctrl( clk, rst,
                  process_enable_init,
                  packet_data_rcvd,
                  /** Output Signal **/
                  process_done_init,
                  index_data_lane,
                  index_data_elmt,
                  index_lane_ready,
                  buffer_read_port
                );

parameter lane_size = `lane_size_para,
          word_size = `word_size_para;

parameter col_per_lane = `col_per_lane_para;


input wire clk, rst;
input wire process_enable_init;
input wire [word_size - 1 : 0] packet_data_rcvd;


output reg process_done_init;
output reg buffer_read_port;
output reg [lane_size - 1 : 0] index_lane_ready; /** enable lane for receiving data **/
output reg [7 : 0] index_data_lane;
output reg [7 : 0] index_data_elmt;



reg [7 : 0] index_data_init;
reg [7 : 0] index_intern;
reg [2 : 0] state_init, next_state_init;
reg buffer_index_send, buffer_index_init;
reg buffer_index_done, buffer_index_rset;


always @(posedge clk)
begin
  if(~rst) begin
    state_init <= 3'b000;
  end
  else begin
    state_init <= next_state_init;
  end
end


always @(*)
begin
  case(state_init)
    3'b000 : next_state_init = process_enable_init ? 3'b001 : 3'b000;
    3'b001 : next_state_init = buffer_index_done ? 3'b010 : 3'b001; /** Send the row init of each lane **/
    3'b010 : next_state_init = buffer_index_done ? 3'b011 : 3'b010; /** Send the col init of each lane **/
    3'b011 : next_state_init = buffer_index_done ? 3'b100 : 3'b011; /** Send the row bond of each lane **/
    3'b100 : next_state_init = buffer_index_done ? 3'b101 : 3'b100; /** Send the col bond of each lane **/
    3'b101 : next_state_init = 3'b110;                              /** Send the Elmt index of each lane**/
    3'b110 : next_state_init = buffer_index_done ? 3'b000 : 3'b110; /** Send the lane index of each lane**/
    default: next_state_init = 3'b000;
  endcase
end


always @(posedge clk)
begin
  if(~rst) begin
    process_done_init <= 1'b0;
  end
  else begin
    process_done_init <= (state_init != 3'b000)&&(next_state_init == 3'b000);
  end
end


always @(*)
begin
  buffer_index_init = (next_state_init != state_init)&&(next_state_init != 3'b000);
  buffer_index_send = (state_init != 3'b000)&&(state_init != 3'b101);
  buffer_index_done = (index_lane_ready[lane_size - 1] == 1'b1);
  buffer_index_rset = (next_state_init == 3'b101)&&(state_init == 3'b100);
end


always @(*)
begin
  case(next_state_init)
    3'b010 : index_intern = col_per_lane; /** Send the col init of each lane   **/
    3'b100 : index_intern = col_per_lane; /** Send the col bond of each lane   **/
    3'b110 : index_intern = 8'b00000001;  /** Send the lane index of each lane **/
    default: index_intern = 8'b00000000;
  endcase
end


always @(*)
begin
  case(next_state_init)
    3'b100 : index_data_init = {col_per_lane - 8'b00000001};
    3'b110 : index_data_init = {8'b00000000};
    default: index_data_init = {packet_data_rcvd[7 : 0]};
  endcase
end


always @(posedge clk)
begin
  if(~rst) begin
    index_data_lane <= 8'b00000000;
  end
  else if(buffer_index_init == 1'b1) begin
    index_data_lane <= index_data_init;
  end
  else if(buffer_index_send == 1'b1) begin
    index_data_lane <= index_data_lane + index_intern;
  end
  else begin
    index_data_lane <= index_data_lane;
  end
end


always @(posedge clk)
begin
  if((~rst)||(buffer_index_rset == 1'b1)) begin
    index_lane_ready <= {lane_size{1'b0}};
  end
  else if(buffer_index_init == 1'b1) begin
    index_lane_ready <= 8'b00000001;
  end
  else if(buffer_index_send == 1'b1) begin
    index_lane_ready <= index_lane_ready << 1'b1;
  end
  else begin
    index_lane_ready <= index_lane_ready;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_read_port <= 1'b0;
  end
  else begin
    buffer_read_port <= (next_state_init != state_init)&&(next_state_init != 3'b000);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    index_data_elmt <= 8'b00000000;
  end
  else if(state_init == 3'b101) begin
    index_data_elmt <= packet_data_rcvd[7 : 0];
  end
  else begin
    index_data_elmt <= index_data_elmt;
  end
end


endmodule


/**
always @(*)
begin
  case(next_state_init)
    3'b001 : index_intern = 8'b00000000;  Send the row init of each lane
    3'b010 : index_intern = col_per_lane; Send the col init of each lane
	3'b011 : index_intern = 8'b00000000;  Send the row bond of each lane
    3'b100 : index_intern = col_per_lane; Send the col bond of each lane
    3'b110 : index_intern = 8'b00000001;  Send the lane index of each lane
    default: index_intern = 8'b00000000;
  endcase
end


always @(*)
begin
  case(next_state_init)
    3'b001 : index_data_init = {packet_data_rcvd[7 : 0]};
	3'b010 : index_data_init = {packet_data_rcvd[7 : 0]};
	3'b011 : index_data_init = {packet_data_rcvd[7 : 0]};
    3'b100 : index_data_init = {col_per_lane - 1};
    3'b110 : index_data_init = {8'b00000000};
    default: index_data_init = {8'b00000000};
  endcase
end
**/


// `include "../param.vh"

module lemt_ctrl ( clk, rst,
                   process_learn_enable,
                   process_tmpry_enable,
                   process_done_init,
                   process_done_pipe,
                   process_done_indx,
                   process_done_splr,
				   process_done_actc,
				   process_done_buld,
                   process_done_pred,
                   process_done_tplr,
                   memory_data_ready,
                   memory_find_busy,
                   packet_inst_rcvd,
                   packet_inst_pipe,
                   packet_inst_indx,
                   packet_inst_splr,
                   packet_inst_actc,
                   packet_inst_pred,
                   packet_inst_tplr,

                   packet_data_pipe,
                   packet_data_indx,
                   packet_data_splr,
                   packet_data_actc,
                   packet_data_pred,
                   packet_data_tplr,

                   packet_enable_pipe,
                   packet_enable_indx,
                   packet_enable_splr,
                   packet_enable_actc,
                   packet_enable_pred,
                   packet_enable_tplr,
                   /** Output Signal **/

                   buffer_conf_reset,
				   buffer_data_reset,
                   device_code_find,
                   process_enable_init,
                   process_enable_pipe,
                   process_enable_indx,
                   process_enable_splr,
				   process_enable_actc,
				   process_enable_buld,
                   process_enable_pred,
                   process_enable_tplr,
                   packet_proc_done,
                   buffer_wten_lemt,
				   packet_data_send,
				   packet_inst_send,
				   packet_enable_send,
				   memory_chunk_update,
				   process_units_enable
                 );

parameter word_size = `word_size_para,
          lane_size = `lane_size_para;


input wire clk, rst;
input wire process_learn_enable, process_tmpry_enable;
input wire process_done_init, process_done_pipe;
input wire process_done_indx, process_done_splr;
input wire process_done_actc, process_done_buld;
input wire process_done_pred, process_done_tplr;
input wire memory_data_ready;
input wire [lane_size - 1 : 0] memory_find_busy;
input wire packet_enable_pipe, packet_enable_indx;
input wire packet_enable_splr, packet_enable_actc;
input wire packet_enable_pred, packet_enable_tplr;

input wire [word_size - 1 : 0] packet_inst_rcvd;
input wire [word_size - 1 : 0] packet_inst_pipe;
input wire [word_size - 1 : 0] packet_inst_indx;
input wire [word_size - 1 : 0] packet_inst_splr;
input wire [word_size - 1 : 0] packet_inst_actc;
input wire [word_size - 1 : 0] packet_inst_pred;
input wire [word_size - 1 : 0] packet_inst_tplr;

input wire [word_size - 1 : 0] packet_data_pipe;
input wire [word_size - 1 : 0] packet_data_indx;
input wire [word_size - 1 : 0] packet_data_splr;
input wire [word_size - 1 : 0] packet_data_actc;
input wire [word_size - 1 : 0] packet_data_pred;
input wire [word_size - 1 : 0] packet_data_tplr;


output reg buffer_conf_reset, buffer_data_reset;
output reg packet_proc_done;
output reg process_enable_init, process_enable_pipe;
output reg process_enable_indx, process_enable_splr;
output reg process_enable_actc, process_enable_buld;
output reg process_enable_pred, process_enable_tplr;

output reg [lane_size - 1 : 0] device_code_find;
output reg [word_size - 1 : 0] packet_data_send;
output reg [word_size - 1 : 0] packet_inst_send;
output reg packet_enable_send;
output reg memory_chunk_update;
output reg buffer_wten_lemt;
output reg process_units_enable; /** first round of temporal **/


reg [3 : 0] state_ctrl, next_state_ctrl;
reg process_done_send;


always @(posedge clk)
begin
  if(~rst) begin
    state_ctrl <= 4'b0000;
  end
  else begin
    state_ctrl <= next_state_ctrl;
  end
end


always @(*)
begin
  case(state_ctrl)
    4'b0000: begin
	           if(packet_proc_done == 1'b1) begin
			     next_state_ctrl = 4'b0001;
			   end
			   else begin
			     next_state_ctrl = 4'b0000;
			   end
			 end
    4'b0001: begin /** Trigger the inital process for each execution lane in current element **/
	           if(process_done_init == 1'b1) begin
			     next_state_ctrl = 4'b0010;
			   end
			   else begin
			     next_state_ctrl = 4'b0001;
			   end
			 end
    4'b0010: begin /** Find the active column for current input image **/
	           if(process_done_pipe == 1'b1) begin
			     next_state_ctrl = 4'b0011;
			   end
			   else begin
			     next_state_ctrl = 4'b0010;
			   end
			 end
    4'b0011: begin /** Sort and send the column index back to processor **/
	           if(process_done_indx == 1'b1) begin
			     next_state_ctrl = process_learn_enable ? 4'b0100 : 4'b0101;
			   end
			   else begin
			     next_state_ctrl = 4'b0011;
			   end
			  end
	4'b0100: begin /** Spatial learning process in processing elements **/
	           if(process_done_splr == 1'b1) begin
			     next_state_ctrl = 4'b0101;
			   end
			   else begin
			     next_state_ctrl = 4'b0100;
			   end
			 end
    4'b0101: begin /** Send the completion flag to indicate processor **/
	           if(process_done_send == 1'b1) begin
			     next_state_ctrl = 4'b0110;
			   end
			   else begin
			     next_state_ctrl = 4'b0101;
			   end
			 end
    4'b0110: begin /** Wait for the instruction from processor for next phase **/
	           if(packet_proc_done == 1'b1) begin
			     next_state_ctrl = process_tmpry_enable ? 4'b0111 : 4'b0010;
			   end
			   else begin
			     next_state_ctrl = 4'b0110;
			   end
			 end
    4'b0111: begin /** Find active and learn cells in each of active column **/
	           if(process_done_actc == 1'b1) begin
			     next_state_ctrl = 4'b1000;
			   end
			   else begin
			     next_state_ctrl = 4'b0111;
			   end
			 end
    4'b1000: begin /** Create segments in each learning cell in the element **/
	           if(process_done_buld == 1'b1) begin
			     next_state_ctrl = process_units_enable ? 4'b1001 : 4'b0010;
			   end
			   else begin
			     next_state_ctrl = 4'b1000;
			   end
			 end
    4'b1001: begin /** Find predict cells in each of all columns of this element **/
	           if(process_done_pred == 1'b1) begin
			     next_state_ctrl = 4'b1010;
			   end
			   else begin
			     next_state_ctrl = 4'b1001;
			   end
			 end
    4'b1010: begin
	           if(packet_proc_done == 1'b1) begin
			     next_state_ctrl = process_learn_enable ? 4'b1011 : 4'b0010;
			   end
			   else begin
			     next_state_ctrl = 4'b1010;
			   end
			 end
    4'b1011: begin /** Temporal learning process in processing element **/
	           if(process_done_tplr == 1'b1) begin
			     next_state_ctrl = 4'b1100;
			   end
			   else begin
			     next_state_ctrl = 4'b1011;
			   end
			 end
    4'b1100: begin
	           if(packet_proc_done == 1'b1) begin
			     next_state_ctrl = 4'b0010;
			   end
			   else begin
			     next_state_ctrl = 4'b1100;
			   end
			 end

    default: begin
	           next_state_ctrl = 4'b0000;
			 end
  endcase
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_conf_reset <= 1'b0;
  end
  else begin
    buffer_conf_reset <= (process_done_pipe == 1'b1)||(process_done_splr == 1'b1)||(process_done_init == 1'b1);
  end
end

/**
always @(posedge clk)
begin
  if(~rst) begin
    buffer_data_reset <= 1'b0;
  end
  else begin
    buffer_data_reset <= (process_done_init == 1'b1)||(process_done_indx == 1'b1)||(process_done_splr == 1'b1)||(process_done_actc == 1'b1)||(process_done_pred == 1'b1)||(process_done_tplr == 1'b1);
  end
end
**/


always @(posedge clk)
begin
  if(~rst) begin
    buffer_data_reset <= 1'b0;
  end
  else begin
    case(state_ctrl)
      4'b0001: buffer_data_reset <= (next_state_ctrl != 4'b0001);
      4'b0011: buffer_data_reset <= (next_state_ctrl != 4'b0011);
      4'b0100: buffer_data_reset <= (next_state_ctrl != 4'b0100);
      4'b0111: buffer_data_reset <= (next_state_ctrl != 4'b0111);
      4'b1010: buffer_data_reset <= (next_state_ctrl != 4'b1010);
      4'b1100: buffer_data_reset <= (next_state_ctrl != 4'b1100);
      default: buffer_data_reset <= (1'b0);
    endcase
  end
end


always @(*)
begin
  buffer_wten_lemt = (memory_data_ready == 1'b1)&&(memory_find_busy == {lane_size{1'b0}});
end


/*********************************** test purpose for current version ***********************************/

always @(posedge clk)
begin
  if(~rst) begin
    process_units_enable <= 1'b0;
  end
  else if((state_ctrl == 4'b1000)&&(next_state_ctrl == 4'b0010)) begin
    process_units_enable <= 1'b1;
  end
  else begin
    process_units_enable <= process_units_enable;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_chunk_update <= (1'b0);
  end
  else begin
    memory_chunk_update <= (next_state_ctrl == 4'b0010)&&(state_ctrl != 4'b0010);
  end
end


/**********************************************************************************************************/


always @(*)
begin
  packet_proc_done = (packet_inst_rcvd == {word_size{1'b1}});
end


always @(*)
begin
  case(state_ctrl)
    4'b0010: packet_enable_send = packet_enable_pipe;
    4'b0011: packet_enable_send = packet_enable_indx;
    4'b0100: packet_enable_send = packet_enable_splr;
    4'b0101: packet_enable_send = 1'b1;
    4'b0111: packet_enable_send = packet_enable_actc;
    4'b1001: packet_enable_send = packet_enable_pred;
    4'b1011: packet_enable_send = packet_enable_tplr;
    default: packet_enable_send = 1'b0;
  endcase
end


always @(*)
begin
  case(state_ctrl)
    4'b0010: packet_inst_send = {packet_inst_pipe};
    4'b0011: packet_inst_send = {packet_inst_indx};
    4'b0100: packet_inst_send = {packet_inst_splr};
    4'b0101: packet_inst_send = {process_tmpry_enable ? {16'h0000, 16'h0801} : {16'h1000, 16'h0801}};
    4'b0111: packet_inst_send = {packet_inst_actc};
    4'b1001: packet_inst_send = {packet_inst_pred};
    4'b1011: packet_inst_send = {packet_inst_tplr};
    default: packet_inst_send = {word_size{1'b0}};
  endcase
end


always @(*)
begin
  case(state_ctrl)
    4'b0010: packet_data_send = {packet_data_pipe};
    4'b0011: packet_data_send = {packet_data_indx};
    4'b0100: packet_data_send = {packet_data_splr};
    4'b0111: packet_data_send = {packet_data_actc};
    4'b1001: packet_data_send = {packet_data_pred};
    4'b1011: packet_data_send = {packet_data_tplr};
    default: packet_data_send = {word_size{1'b0}};
  endcase
end


always @(posedge clk)
begin
  if(~rst) begin
    device_code_find <= 1'b0;
  end
  else begin
    device_code_find <= {lane_size{(next_state_ctrl == 4'b1001)}};
  end
end


/** state_ctrl == 4'b0001, trigger the inital process for each execution lane in current element **/


always @(posedge clk)
begin
  if(~rst) begin
    process_enable_init <= 1'b0;
  end
  else begin
    process_enable_init <= (next_state_ctrl == 4'b0001)&&(state_ctrl == 4'b0000);
  end
end


/** state_ctrl == 4'b0010, find the active column for current input image **/


always @(posedge clk)
begin
  if(~rst) begin
    process_enable_pipe <= 1'b0;
  end
  else begin
    process_enable_pipe <= (next_state_ctrl == 4'b0010)&&(state_ctrl != 4'b0010);
  end
end


/** state_ctrl == 4'b0011,  sort and send the column index back to processor **/


always @(posedge clk)
begin
  if(~rst) begin
    process_enable_indx <= 1'b0;
  end
  else begin
    process_enable_indx <= (next_state_ctrl == 4'b0011)&&(state_ctrl != 4'b0011);
  end
end


/** state_ctrl == 4'b0100,  sort and send the column index back to processor **/


always @(posedge clk)
begin
  if(~rst) begin
    process_enable_splr <= 1'b0;
  end
  else begin
    process_enable_splr <= (next_state_ctrl == 4'b0100)&&(state_ctrl != 4'b0100);
  end
end


/** state_ctrl == 4'b0111, find active and learn cells in each of active column **/


always @(posedge clk)
begin
  if(~rst) begin
    process_enable_actc <= 1'b0;
  end
  else begin
    process_enable_actc <= (next_state_ctrl == 4'b0111)&&(state_ctrl != 4'b0111);
  end
end


/** state_ctrl == 4'b1000,  sort and send the column index back to processor **/


always @(posedge clk)
begin
  if(~rst) begin
    process_enable_buld <= 1'b0;
  end
  else begin
    process_enable_buld <= (next_state_ctrl == 4'b1000)&&(state_ctrl != 4'b1000);
  end
end


/** state_ctrl == 4'b0101, send the completion flag to indicate processor **/


always @(posedge clk)
begin
  if(~rst) begin
    process_done_send <= 1'b0;
  end
  else begin
    process_done_send <= (next_state_ctrl == 4'b0101)&&(state_ctrl != 4'b0101);
  end
end


/** state_ctrl == 4'b1001, send the completion flag to indicate processor **/


always @(posedge clk)
begin
  if(~rst) begin
    process_enable_pred <= 1'b0;
  end
  else begin
    process_enable_pred <= (next_state_ctrl == 4'b1001)&&(state_ctrl != 4'b1001);
  end
end


/** state_ctrl == 4'b1001, send the completion flag to indicate processor **/


always @(posedge clk)
begin
  if(~rst) begin
    process_enable_tplr <= 1'b0;
  end
  else begin
    process_enable_tplr <= (next_state_ctrl == 4'b1011)&&(state_ctrl != 4'b1011);
  end
end



endmodule


// `include "../param.vh"

module lemt_unit ( clk, rst,
                   process_learn_enable,
                   process_tmpry_enable,
                   packet_data_lemt,
                   packet_grant_send,
                   packet_ready_rcvd,
                   buffer_data_pixel,
                   /**output signal**/
                   image_read_enable,
                   packet_data_proc,
                   packet_ready_send,
                   packet_grant_rcvd
				 );

parameter  addr_size = `addr_size_lemt,
           word_size = `word_size_para,
           lane_size = `lane_size_para,
	   addr_lane = `addr_size_para;


input  wire clk, rst;
input  wire [(word_size*lane_size) - 1 : 0] buffer_data_pixel;
input  wire packet_grant_send;
input  wire packet_ready_rcvd;
input  wire [word_size - 1 : 0] packet_data_lemt;
input  wire process_learn_enable, process_tmpry_enable;


output wire [lane_size - 1 : 0] image_read_enable;
output wire [word_size - 1 : 0] packet_data_proc;
output wire packet_ready_send;
output wire packet_grant_rcvd;


wire [addr_size - 1 : 0] memory_addr_init_prv, memory_addr_init_prt;
wire [addr_size - 1 : 0] memory_addr_lemt_0, memory_addr_lemt_1;
wire [addr_size - 1 : 0] memory_addr_lemt_2, memory_addr_lemt_3;
wire [addr_size - 1 : 0] memory_addr_lemt_4, memory_addr_lemt_5;


wire [word_size - 1 : 0] memory_wt_data_lemt_0, memory_wt_data_lemt_1;
wire [word_size - 1 : 0] memory_wt_data_lemt_2, memory_wt_data_lemt_3;
wire [word_size - 1 : 0] memory_wt_data_lemt_4, memory_wt_data_lemt_5;


wire memory_read_lemt_0, memory_read_lemt_1;
wire memory_read_lemt_2, memory_read_lemt_3;
wire memory_read_lemt_4, memory_read_lemt_5;


wire memory_wten_lemt_0, memory_wten_lemt_1;
wire memory_wten_lemt_2, memory_wten_lemt_3;
wire memory_wten_lemt_4, memory_wten_lemt_5;


wire [word_size - 1 : 0] memory_wt_data_lemt;
wire [word_size - 1 : 0] memory_rd_data_lemt;
wire [addr_size - 1 : 0] memory_addr_lemt;
wire memory_ready_lemt, memory_device_lemt;
wire memory_wten_lemt, memory_read_lemt;


wire process_enable_init, process_enable_pipe;
wire process_enable_indx, process_enable_splr;
wire process_done_init, process_done_pipe;
wire process_done_indx, process_done_splr;


wire [word_size - 1 : 0] packet_inst_rcvd, packet_data_rcvd;
wire [word_size - 1 : 0] packet_inst_pipe, packet_inst_indx;
wire [word_size - 1 : 0] packet_inst_splr;
wire [word_size - 1 : 0] packet_data_pipe, packet_data_indx;
wire [word_size - 1 : 0] packet_data_splr;
wire packet_enable_pipe, packet_enable_indx, packet_enable_splr;
wire packet_proc_done;
wire buffer_conf_reset, buffer_data_reset;
wire [word_size - 1 : 0] packet_data_send, packet_inst_send;
wire packet_enable_send, memory_chunk_update;
wire buffer_send_full, buffer_send_epty;


wire [lane_size - 1 : 0] index_lane_ready;
wire [lane_size - 1 : 0] bound_pass_lane;
wire [7 : 0] index_data_lane;
wire [7 : 0] index_data_lemt;
wire [7 : 0] index_row_lane [lane_size - 1 : 0];
wire [7 : 0] index_col_lane [lane_size - 1 : 0];
wire [7 : 0] index_cfg_lane [lane_size - 1 : 0];


wire [word_size - 1 : 0] index_sorted_0, index_sorted_1;
wire [word_size - 1 : 0] index_sorted_2, index_sorted_3;
wire [word_size - 1 : 0] index_sorted_4, index_sorted_5;
wire [word_size - 1 : 0] index_sorted_6, index_sorted_7;
wire [word_size - 1 : 0] value_sorted_0, value_sorted_1;
wire [word_size - 1 : 0] value_sorted_2, value_sorted_3;
wire [word_size - 1 : 0] value_sorted_4, value_sorted_5;
wire [word_size - 1 : 0] value_sorted_6, value_sorted_7;
wire [lane_size - 1 : 0] process_enable_scan, process_done_scan;


wire [word_size - 1 : 0] buffer_max_scan [lane_size - 1 : 0];
wire [word_size - 1 : 0] buffer_data_index [lane_size - 1 : 0];
wire [word_size - 1 : 0] buffer_data_value [lane_size - 1 : 0];
wire [15 : 0] valid_bit_count [lane_size - 1 : 0];


wire [word_size - 1 : 0] buffer_data_lemt;
wire [6 : 0] buffer_read_lemt;
wire [3 : 0] buffer_read_port;
wire buffer_wten_lemt;
wire [1 : 0] buffer_read_lane [lane_size - 1 : 0];


wire [lane_size - 1 : 0] process_enable_adpt, process_enable_bost;
wire [lane_size - 1 : 0] process_enable_lapp;
wire [lane_size - 1 : 0] process_done_adpt, process_done_bost;
wire [lane_size - 1 : 0] process_done_lapp;
wire [word_size - 1 : 0] buffer_max_adpt [lane_size - 1 : 0];
wire [lane_size - 1 : 0] index_dirty_ready;


wire [lane_size - 1 : 0] packet_maxn_ready;
wire packet_minn_ready, result_minn_ready;
wire result_maxn_ready;
wire [word_size - 1 : 0] index_recved_0, index_recved_1;
wire [word_size - 1 : 0] index_recved_2, index_recved_3;
wire [word_size - 1 : 0] index_recved_4, index_recved_5;
wire [word_size - 1 : 0] index_recved_6, index_recved_7;
wire [word_size - 1 : 0] index_minned_0, index_minned_1;
wire [word_size - 1 : 0] index_minned_2, index_minned_3;
wire [word_size - 1 : 0] index_minned_4, index_minned_5;
wire [word_size - 1 : 0] index_minned_6, index_minned_7;


wire process_enable_actc, process_done_actc;
wire [addr_lane - 1 : 0] memory_addr_computed;
wire compute_addr_done;
wire [lane_size - 1 : 0] process_find_actc;
wire [lane_size - 1 : 0] process_done_find;
wire [word_size - 1 : 0] packet_data_actc;
wire [word_size - 1 : 0] packet_inst_actc;
wire packet_enable_actc;


wire process_units_enable;
wire process_enable_buld, process_done_buld;
wire [3 : 0] memory_addr_load_rcvd;
wire [23 : 0] buffer_counter_find_0, buffer_counter_find_1;
wire [23 : 0] buffer_counter_find_2, buffer_counter_find_3;
wire [23 : 0] buffer_counter_find_4, buffer_counter_find_5;
wire [23 : 0] buffer_counter_find_6, buffer_counter_find_7;
wire [23 : 0] buffer_counter_find [lane_size - 1 : 0];


wire process_enable_calc, process_enable_merg, process_enable_swap;
wire process_done_calc, process_done_merg, process_done_swap;
wire [lane_size - 1 : 0] process_enable_sort;
wire [lane_size - 1 : 0] process_done_sort;
wire [lane_size - 1 : 0] process_find_buld;
wire [word_size - 1 : 0] buffer_data_buld;
wire round_flag_head, memory_read_calc;
wire [lane_size - 1 : 0] memory_lane_read, memory_lane_wten;
wire [lane_size - 1 : 0] memory_addr_rset;
wire [lane_size - 1 : 0] memory_buff_ready;
wire [word_size - 1 : 0] memory_buff_lane [lane_size - 1 : 0];
wire [word_size - 1 : 0] memory_data_lane [lane_size - 1 : 0];


wire [word_size - 1 : 0] buffer_ct_data_0, buffer_ct_data_1;
wire [word_size - 1 : 0] buffer_ct_data_2, buffer_ct_data_3;
wire [word_size - 1 : 0] buffer_ct_data_4, buffer_ct_data_5;
wire [word_size - 1 : 0] buffer_ct_data_6, buffer_ct_data_7;


wire [word_size - 1 : 0] buffer_st_data_0, buffer_st_data_1;
wire [word_size - 1 : 0] buffer_st_data_2, buffer_st_data_3;
wire [word_size - 1 : 0] buffer_st_data_4, buffer_st_data_5;
wire [word_size - 1 : 0] buffer_st_data_6, buffer_st_data_7;


wire compute_enable_actc;
wire [word_size - 1 : 0] compute_packet_actc;
wire [3 : 0] compute_length_actc;


wire compute_enable_buld;
wire [word_size - 1 : 0] compute_packet_buld;
wire [3 : 0] compute_length_buld;


wire process_enable_pred, process_done_pred;
wire [word_size - 1 : 0] packet_data_pred;
wire [word_size - 1 : 0] packet_inst_pred;
wire packet_enable_pred;
wire [addr_lane - 1 : 0] memory_addr_buffered;
wire [lane_size - 1 : 0] memory_find_busy;
wire [lane_size - 1 : 0] device_code_find;
wire [lane_size - 1 : 0] process_find_pred;


wire process_enable_tplr, process_done_tplr;
wire [lane_size - 1 : 0] process_enable_updt;
wire [lane_size - 1 : 0] process_done_updt;
wire [3 : 0] operate_buffer;
wire [addr_lane - 1 : 0] memory_addr_received;
wire memory_addr_load_tplr;
wire [word_size - 1 : 0] packet_data_tplr;
wire [word_size - 1 : 0] packet_inst_tplr;
wire packet_enable_tplr;


wire [word_size - 1 : 0] memory_data_lemt;


assign buffer_data_index[0] = {index_row_lane[0], index_col_lane[0], index_data_lemt, index_cfg_lane[0]};
assign buffer_data_index[1] = {index_row_lane[1], index_col_lane[1], index_data_lemt, index_cfg_lane[1]};
assign buffer_data_index[2] = {index_row_lane[2], index_col_lane[2], index_data_lemt, index_cfg_lane[2]};
assign buffer_data_index[3] = {index_row_lane[3], index_col_lane[3], index_data_lemt, index_cfg_lane[3]};
assign buffer_data_index[4] = {index_row_lane[4], index_col_lane[4], index_data_lemt, index_cfg_lane[4]};
assign buffer_data_index[5] = {index_row_lane[5], index_col_lane[5], index_data_lemt, index_cfg_lane[5]};
assign buffer_data_index[6] = {index_row_lane[6], index_col_lane[6], index_data_lemt, index_cfg_lane[6]};
assign buffer_data_index[7] = {index_row_lane[7], index_col_lane[7], index_data_lemt, index_cfg_lane[7]};
assign buffer_counter_find_0 = {buffer_counter_find[0]};
assign buffer_counter_find_1 = {buffer_counter_find[1]};
assign buffer_counter_find_2 = {buffer_counter_find[2]};
assign buffer_counter_find_3 = {buffer_counter_find[3]};
assign buffer_counter_find_4 = {buffer_counter_find[4]};
assign buffer_counter_find_5 = {buffer_counter_find[5]};
assign buffer_counter_find_6 = {buffer_counter_find[6]};
assign buffer_counter_find_7 = {buffer_counter_find[7]};



genvar index_lane;


lemt_ctrl ctrl ( .clk(clk), .rst(rst),
                 .process_learn_enable(process_learn_enable),
                 .process_tmpry_enable(process_tmpry_enable),
                 .process_done_init(process_done_init),
                 .process_done_pipe(process_done_pipe),
                 .process_done_indx(process_done_indx),
                 .process_done_splr(process_done_splr),
                 .process_done_actc(process_done_actc),
                 .process_done_buld(process_done_buld),
                 .process_done_pred(process_done_pred),
                 .process_done_tplr(process_done_tplr),
                 .memory_data_ready(memory_ready_lemt),
                 .memory_find_busy(memory_find_busy),
                 .packet_inst_rcvd(packet_inst_rcvd),
                 .packet_inst_pipe(packet_inst_pipe),
                 .packet_inst_indx(packet_inst_indx),
                 .packet_inst_splr(packet_inst_splr),
                 .packet_inst_actc(packet_inst_actc),
                 .packet_inst_pred(packet_inst_pred),
                 .packet_inst_tplr(packet_inst_tplr),
                 .packet_data_pipe(packet_data_pipe),
                 .packet_data_indx(packet_data_indx),
                 .packet_data_splr(packet_data_splr),
                 .packet_data_actc(packet_data_actc),
                 .packet_data_pred(packet_data_pred),
                 .packet_data_tplr(packet_data_tplr),
                 .packet_enable_pipe(packet_enable_pipe),
                 .packet_enable_indx(packet_enable_indx),
                 .packet_enable_splr(packet_enable_splr),
                 .packet_enable_actc(packet_enable_actc),
                 .packet_enable_pred(packet_enable_pred),
                 .packet_enable_tplr(packet_enable_tplr),
                  /** Output Signal **/
                 .process_enable_init(process_enable_init),
                 .process_enable_pipe(process_enable_pipe),
                 .process_enable_indx(process_enable_indx),
                 .process_enable_splr(process_enable_splr),
                 .process_enable_actc(process_enable_actc),
                 .process_enable_buld(process_enable_buld),
                 .process_enable_pred(process_enable_pred),
                 .process_enable_tplr(process_enable_tplr),
                 .buffer_conf_reset(buffer_conf_reset),
                 .buffer_data_reset(buffer_data_reset),				 /** for both rcvd and fifo **/
                 .packet_proc_done(packet_proc_done),
                 .buffer_wten_lemt(buffer_wten_lemt),
                 .device_code_find(device_code_find),
                 .packet_data_send(packet_data_send),
                 .packet_inst_send(packet_inst_send),
                 .packet_enable_send(packet_enable_send),
                 .memory_chunk_update(memory_chunk_update),
                 .process_units_enable(process_units_enable)
                );



init_ctrl init ( .clk(clk), .rst(rst),
                 .process_enable_init(process_enable_init),
                 .packet_data_rcvd(packet_data_rcvd),
                  /** Output Signal **/
                 .process_done_init(process_done_init),
                 .index_data_lane(index_data_lane),
                 .index_data_elmt(index_data_lemt),
                 .index_lane_ready(index_lane_ready),
                 .buffer_read_port(buffer_read_port[2])
                );

/** control logic for spatial pooling **/

pipe_ctrl pipe ( .clk(clk), .rst(rst),
                 .process_enable_pipe(process_enable_pipe),
                 .bound_pass_lane(bound_pass_lane),
                 .process_done_scan(process_done_scan),
                 .buffer_send_full(buffer_send_full),
                 .value_sorted_0(value_sorted_0),
                 .value_sorted_1(value_sorted_1),
                 .value_sorted_2(value_sorted_2),
                 .value_sorted_3(value_sorted_3),
                 .value_sorted_4(value_sorted_4),
                 .value_sorted_5(value_sorted_5),
                 .value_sorted_6(value_sorted_6),
                 .value_sorted_7(value_sorted_7),
                 .index_sorted_0(index_sorted_0),
                 .index_sorted_1(index_sorted_1),
                 .index_sorted_2(index_sorted_2),
                 .index_sorted_3(index_sorted_3),
                 .index_sorted_4(index_sorted_4),
                 .index_sorted_5(index_sorted_5),
                 .index_sorted_6(index_sorted_6),
                 .index_sorted_7(index_sorted_7),
                 .packet_proc_done(packet_proc_done),
                 /** output signal **/
                 .packet_enable_send(packet_enable_pipe),
                 .packet_data_send(packet_data_pipe),
                 .packet_inst_send(packet_inst_pipe),
                 .process_done_pipe(process_done_pipe),
                 .process_enable_scan(process_enable_scan)
               );


maxr_lemt maxr ( .clk(clk), .rst(rst),
                 .packet_sort_ready(packet_maxn_ready),
                 .input_data_0({buffer_data_value[0], buffer_data_index[0]}),
                 .input_data_1({buffer_data_value[1], buffer_data_index[1]}),
                 .input_data_2({buffer_data_value[2], buffer_data_index[2]}),
                 .input_data_3({buffer_data_value[3], buffer_data_index[3]}),
                 .input_data_4({buffer_data_value[4], buffer_data_index[4]}),
                 .input_data_5({buffer_data_value[5], buffer_data_index[5]}),
                 .input_data_6({buffer_data_value[6], buffer_data_index[6]}),
                 .input_data_7({buffer_data_value[7], buffer_data_index[7]}),
                 /** Output Signal **/
                 .result_sort_ready(result_maxn_ready),
                 .output_data_0({value_sorted_0, index_sorted_0}),
                 .output_data_1({value_sorted_1, index_sorted_1}),
                 .output_data_2({value_sorted_2, index_sorted_2}),
                 .output_data_3({value_sorted_3, index_sorted_3}),
                 .output_data_4({value_sorted_4, index_sorted_4}),
                 .output_data_5({value_sorted_5, index_sorted_5}),
                 .output_data_6({value_sorted_6, index_sorted_6}),
                 .output_data_7({value_sorted_7, index_sorted_7})
               );



indx_ctrl indx ( .clk(clk), .rst(rst),
                 .process_enable_indx(process_enable_indx),
                 .memory_addr_init_prt(memory_addr_init_prt),
                 .packet_data_rcvd(packet_data_rcvd),
                 .buffer_send_full(buffer_send_full),
                 .value_sorted_0(index_minned_0),
                 .value_sorted_1(index_minned_1),
                 .value_sorted_2(index_minned_2),
                 .value_sorted_3(index_minned_3),
                 .value_sorted_4(index_minned_4),
                 .value_sorted_5(index_minned_5),
                 .value_sorted_6(index_minned_6),
                 .value_sorted_7(index_minned_7),
                 .buffer_rd_data(buffer_data_lemt),
                 .index_data_elmt(index_data_lemt),
                 .packet_proc_done(packet_proc_done),
                 .result_sort_ready(result_minn_ready),
                 .memory_data_ready(memory_ready_lemt),
                 /** output signal **/
                 .process_done_indx(process_done_indx),
                 .buffer_output_0(index_recved_0),
                 .buffer_output_1(index_recved_1),
                 .buffer_output_2(index_recved_2),
                 .buffer_output_3(index_recved_3),
                 .buffer_output_4(index_recved_4),
                 .buffer_output_5(index_recved_5),
                 .buffer_output_6(index_recved_6),
                 .buffer_output_7(index_recved_7),
                 .packet_sort_ready(packet_minn_ready),
                 .buffer_read_port(buffer_read_port[1]),
                 .buffer_read_fifo(buffer_read_lemt[1]),
                 .memory_addr_lemt(memory_addr_lemt_0),
                 .memory_wt_data(memory_wt_data_lemt_0),
                 .memory_wt_enable(memory_wten_lemt_0),
                 .memory_rd_enable(memory_read_lemt_0),
                 .packet_inst_send(packet_inst_indx),
                 .packet_data_send(packet_data_indx),
                 .packet_enable_send(packet_enable_indx)
               );


mixr_lemt minn ( .clk(clk), .rst(rst),
                 .packet_sort_ready(packet_minn_ready),
                 .input_data_0(index_recved_0),
                 .input_data_1(index_recved_1),
                 .input_data_2(index_recved_2),
                 .input_data_3(index_recved_3),
                 .input_data_4(index_recved_4),
                 .input_data_5(index_recved_5),
                 .input_data_6(index_recved_6),
                 .input_data_7(index_recved_7),
                  /** Output Signal **/
                 .result_sort_ready(result_minn_ready),
                 .output_data_0(index_minned_0),
                 .output_data_1(index_minned_1),
                 .output_data_2(index_minned_2),
                 .output_data_3(index_minned_3),
                 .output_data_4(index_minned_4),
                 .output_data_5(index_minned_5),
                 .output_data_6(index_minned_6),
                 .output_data_7(index_minned_7)
               );



splr_ctrl splr ( .clk(clk), .rst(rst),
                 .process_enable_splr(process_enable_splr),
                 .buffer_send_full(buffer_send_full),
                 .packet_proc_done(packet_proc_done),
                 .process_done_adpt(process_done_adpt),
                 .process_done_bost(process_done_bost),
                 .process_done_lapp(process_done_lapp),
                 .buffer_rd_data(buffer_data_lemt),
                 .index_data_lemt(index_data_lemt),
                 .index_dirty_ready(index_dirty_ready),
                 .memory_data_ready(memory_ready_lemt),
                 .index_data_lane_0({index_row_lane[0], index_col_lane[0]}),
                 .index_data_lane_1({index_row_lane[1], index_col_lane[1]}),
                 .index_data_lane_2({index_row_lane[2], index_col_lane[2]}),
                 .index_data_lane_3({index_row_lane[3], index_col_lane[3]}),
                 .index_data_lane_4({index_row_lane[4], index_col_lane[4]}),
                 .index_data_lane_5({index_row_lane[5], index_col_lane[5]}),
                 .index_data_lane_6({index_row_lane[6], index_col_lane[6]}),
                 .index_data_lane_7({index_row_lane[7], index_col_lane[7]}),
                 .buffer_max_adpt_0(buffer_max_adpt[0]),
                 .buffer_max_adpt_1(buffer_max_adpt[1]),
                 .buffer_max_adpt_2(buffer_max_adpt[2]),
                 .buffer_max_adpt_3(buffer_max_adpt[3]),
                 .buffer_max_adpt_4(buffer_max_adpt[4]),
                 .buffer_max_adpt_5(buffer_max_adpt[5]),
                 .buffer_max_adpt_6(buffer_max_adpt[6]),
                 .buffer_max_adpt_7(buffer_max_adpt[7]),
                 .buffer_max_rank_0(buffer_max_scan[0]),
                 .buffer_max_rank_1(buffer_max_scan[1]),
                 .buffer_max_rank_2(buffer_max_scan[2]),
                 .buffer_max_rank_3(buffer_max_scan[3]),
                 .buffer_max_rank_4(buffer_max_scan[4]),
                 .buffer_max_rank_5(buffer_max_scan[5]),
                 .buffer_max_rank_6(buffer_max_scan[6]),
                 .buffer_max_rank_7(buffer_max_scan[7]),
                 .memory_addr_init_prt(memory_addr_init_prt),
                  /** output signal **/
                 .process_done_splr(process_done_splr),
                 .buffer_read_fifo(buffer_read_lemt[0]),
                 .buffer_read_port(buffer_read_port[0]),
                 .memory_addr_lemt(memory_addr_lemt_1),
                 .memory_rd_enable(memory_read_lemt_1),
                 .process_enable_adpt(process_enable_adpt),
                 .process_enable_bost(process_enable_bost),
                 .process_enable_lapp(process_enable_lapp),
                 .packet_data_send(packet_data_splr),
                 .packet_inst_send(packet_inst_splr),
                 .packet_enable_send(packet_enable_splr)
               );


actc_ctrl actc ( .clk(clk), .rst(rst),
                 .process_learn_enable(process_learn_enable),
                 .process_enable_actc(process_enable_actc),
                 .memory_addr_computed(memory_addr_computed[15 : 0]),
                 .memory_addr_init_prt(memory_addr_init_prt),
                 .memory_addr_init_prv(memory_addr_init_prv),
                 .compute_addr_done(compute_addr_done),
                 .memory_data_ready(memory_ready_lemt),
                 .buffer_data_fifo(buffer_data_lemt),
                 .buffer_send_epty(buffer_send_epty),
                 .process_done_find(process_done_find),
                 .buffer_counter_find_0(buffer_counter_find_0),
                 .buffer_counter_find_1(buffer_counter_find_1),
                 .buffer_counter_find_2(buffer_counter_find_2),
                 .buffer_counter_find_3(buffer_counter_find_3),
                 .buffer_counter_find_4(buffer_counter_find_4),
                 .buffer_counter_find_5(buffer_counter_find_5),
                 .buffer_counter_find_6(buffer_counter_find_6),
                 .buffer_counter_find_7(buffer_counter_find_7),
                   /** Output Signal **/
                 .memory_addr_load_rcvd(memory_addr_load_rcvd[0]),
                 .process_enable_find(process_find_actc),
                 .process_done_actc(process_done_actc),
                 .buffer_read_fifo(buffer_read_lemt[2]),
                 .packet_enable_send(packet_enable_actc),
                 .packet_data_send(packet_data_actc),
                 .packet_inst_send(packet_inst_actc),
                 .memory_addr_lemt(memory_addr_lemt_2),
                 .memory_wt_data(memory_wt_data_lemt_2),
                 .memory_wt_enable(memory_wten_lemt_2),
                 .memory_rd_enable(memory_read_lemt_2),
                 .compute_addr_enable(compute_enable_actc),
                 .compute_addr_packet(compute_packet_actc),
                 .compute_addr_length(compute_length_actc)
               );


buld_ctrl buld ( .clk(clk), .rst(rst),
                 .process_learn_enable(process_learn_enable),
                 .process_units_enable(process_units_enable),
                 .process_enable_buld(process_enable_buld),
                 .compute_addr_done(compute_addr_done),
                 .process_done_calc(process_done_calc),
                 .process_done_swap(process_done_swap),
                 .process_done_merg(process_done_merg),
                 .process_done_find(process_done_find),
                 .process_done_sort(process_done_sort),
                 .packet_proc_done(packet_proc_done),
                 .index_data_lemt(index_data_lemt),
                 .buffer_data_rcvd(packet_data_rcvd),
                 .buffer_data_fifo(buffer_data_lemt),
                 .memory_read_calc(memory_read_calc),
                 .memory_data_ready(memory_ready_lemt),
                 .memory_addr_computed(memory_addr_computed[15 : 0]),
                 .memory_addr_init_prv(memory_addr_init_prv),
                 .memory_addr_init_prt(memory_addr_init_prt),
                   /** Output Signal **/
                 .memory_addr_load_rcvd(memory_addr_load_rcvd[1]),
                 .process_done_buld(process_done_buld),
                 .compute_addr_enable(compute_enable_buld),
                 .compute_addr_packet(compute_packet_buld),
                 .compute_addr_length(compute_length_buld),
                 .process_enable_find(process_find_buld),
                 .process_enable_calc(process_enable_calc),
                 .process_enable_swap(process_enable_swap),
                 .process_enable_merg(process_enable_merg),
                 .process_enable_sort(process_enable_sort),
                 .round_flag_head(round_flag_head),
                 .buffer_data_buld(buffer_data_buld),
                 .buffer_read_fifo(buffer_read_lemt[3]),
                 .buffer_read_port(buffer_read_port[3]),
                 .memory_addr_lemt(memory_addr_lemt_3),
                 .memory_rd_enable(memory_read_lemt_3),
                 .memory_wt_enable(memory_wten_lemt_3),
                 .memory_wt_data(memory_wt_data_lemt_3)
               );


calc_ctrl calc ( .clk(clk), .rst(rst),
                 .process_enable_calc(process_enable_calc),
                 .buffer_data_fifo(buffer_data_lemt),
                 .buffer_data_buld(buffer_data_buld),
                 .memory_data_ready(memory_ready_lemt),
                   /** Output Signal **/
                 .process_done_calc(process_done_calc),
                 .buffer_data_0(buffer_ct_data_0),
                 .buffer_data_1(buffer_ct_data_1),
                 .buffer_data_2(buffer_ct_data_2),
                 .buffer_data_3(buffer_ct_data_3),
                 .buffer_data_4(buffer_ct_data_4),
                 .buffer_data_5(buffer_ct_data_5),
                 .buffer_data_6(buffer_ct_data_6),
                 .buffer_data_7(buffer_ct_data_7),
                 .memory_read_calc(memory_read_calc),
                 .buffer_read_fifo(buffer_read_lemt[4])
               );


mixr_lemt minx ( .clk(clk), .rst(rst),
                 .packet_sort_ready(process_enable_swap),
                 .input_data_0(buffer_ct_data_0),
                 .input_data_1(buffer_ct_data_1),
                 .input_data_2(buffer_ct_data_2),
                 .input_data_3(buffer_ct_data_3),
                 .input_data_4(buffer_ct_data_4),
                 .input_data_5(buffer_ct_data_5),
                 .input_data_6(buffer_ct_data_6),
                 .input_data_7(buffer_ct_data_7),
                  /** Output Signal **/
                 .result_sort_ready(process_done_swap),
                 .output_data_0(buffer_st_data_0),
                 .output_data_1(buffer_st_data_1),
                 .output_data_2(buffer_st_data_2),
                 .output_data_3(buffer_st_data_3),
                 .output_data_4(buffer_st_data_4),
                 .output_data_5(buffer_st_data_5),
                 .output_data_6(buffer_st_data_6),
                 .output_data_7(buffer_st_data_7)
               );


merg_ctrl merg ( .clk(clk), .rst(rst),
                 .process_enable_merg(process_enable_merg),
                 .memory_data_ready(memory_buff_ready),
                 .round_flag_head(round_flag_head),
                 .buffer_st_data_0(buffer_st_data_0),
                 .buffer_st_data_1(buffer_st_data_1),
                 .buffer_st_data_2(buffer_st_data_2),
                 .buffer_st_data_3(buffer_st_data_3),
                 .buffer_st_data_4(buffer_st_data_4),
                 .buffer_st_data_5(buffer_st_data_5),
                 .buffer_st_data_6(buffer_st_data_6),
                 .buffer_st_data_7(buffer_st_data_7),
                 .memory_rd_data_0(memory_buff_lane[0]),
                 .memory_rd_data_1(memory_buff_lane[1]),
                 .memory_rd_data_2(memory_buff_lane[2]),
                 .memory_rd_data_3(memory_buff_lane[3]),
                 .memory_rd_data_4(memory_buff_lane[4]),
                 .memory_rd_data_5(memory_buff_lane[5]),
                 .memory_rd_data_6(memory_buff_lane[6]),
                 .memory_rd_data_7(memory_buff_lane[7]),
                   /** output signal **/
                 .process_done_merg(process_done_merg),
                 .memory_lane_wten(memory_lane_wten),
                 .memory_lane_read(memory_lane_read),
                 .memory_addr_rset(memory_addr_rset),
                 .memory_data_lane_0(memory_data_lane[0]),
                 .memory_data_lane_1(memory_data_lane[1]),
                 .memory_data_lane_2(memory_data_lane[2]),
                 .memory_data_lane_3(memory_data_lane[3]),
                 .memory_data_lane_4(memory_data_lane[4]),
                 .memory_data_lane_5(memory_data_lane[5]),
                 .memory_data_lane_6(memory_data_lane[6]),
                 .memory_data_lane_7(memory_data_lane[7])
               );


pred_ctrl pred ( .clk(clk), .rst(rst),
                 .process_enable_pred(process_enable_pred),
                 .memory_addr_init_prt(memory_addr_init_prt),
                 .buffer_data_fifo(buffer_data_lemt),
                 .memory_data_ready(memory_ready_lemt),
                 .process_done_find(process_done_find),
                 .buffer_counter_find_0(buffer_counter_find_0),
                 .buffer_counter_find_1(buffer_counter_find_1),
                 .buffer_counter_find_2(buffer_counter_find_2),
                 .buffer_counter_find_3(buffer_counter_find_3),
                 .buffer_counter_find_4(buffer_counter_find_4),
                 .buffer_counter_find_5(buffer_counter_find_5),
                 .buffer_counter_find_6(buffer_counter_find_6),
                 .buffer_counter_find_7(buffer_counter_find_7),
                 .process_learn_enable(process_learn_enable),
                   /** Output Signal **/
                 .process_enable_find(process_find_pred),
                 .process_done_pred(process_done_pred),
                 .memory_addr_lemt(memory_addr_lemt_4),
                 .memory_wt_data(memory_wt_data_lemt_4),
                 .memory_rd_enable(memory_read_lemt_4),
                 .memory_wt_enable(memory_wten_lemt_4),
                 .buffer_read_fifo(buffer_read_lemt[5]),
                 .packet_enable_send(packet_enable_pred),
                 .packet_inst_send(packet_inst_pred),
                 .packet_data_send(packet_data_pred),
                 .memory_addr_buffered(memory_addr_buffered),
                 .memory_addr_load_rcvd(memory_addr_load_rcvd[2])
               );


tplr_ctrl tplr ( .clk(clk), .rst(rst),
                 .process_enable_tplr(process_enable_tplr),
                 .buffer_data_fifo(buffer_data_lemt),
                 .process_done_updt(process_done_updt),
                 .memory_data_ready(memory_ready_lemt),
                   /** output signal **/
                 .process_enable_updt(process_enable_updt),
                 .process_done_tplr(process_done_tplr),
                 .buffer_read_fifo(buffer_read_lemt[6]),
                 .memory_addr_lemt(memory_addr_lemt_5),
                 .memory_wt_data(memory_wt_data_lemt_5),
                 .memory_rd_enable(memory_read_lemt_5),
                 .memory_wt_enable(memory_wten_lemt_5),
                 .operate_buffer(operate_buffer),
                 .packet_enable_send(packet_enable_tplr),
                 .packet_inst_send(packet_inst_tplr),
                 .packet_data_send(packet_data_tplr),
                 .memory_addr_buffered(memory_addr_received),
                 .memory_addr_load_rcvd(memory_addr_load_rcvd[3])
               );


rcvd_lemt rcvd ( .clk(clk), .rst(rst),
                 .packet_ready_rcvd(packet_ready_rcvd),
                 .packet_data_elmt(packet_data_lemt),
                 .buffer_read_port(buffer_read_port),
                 .buffer_rcvd_reset(buffer_data_reset),
                  /*** Output Signal ***/
                 .packet_inst_rcvd(packet_inst_rcvd),
                 .packet_data_rcvd(packet_data_rcvd),
                 .packet_grant_rcvd(packet_grant_rcvd)
			   );


send_lemt send ( .clk(clk), .rst(rst),
                 .packet_enable_send(packet_enable_send),
                 .packet_grant_send(packet_grant_send),  /** The receiver is able to accept package **/
                 .packet_inst_send(packet_inst_send),
                 .packet_data_send(packet_data_send),
                 .packet_proc_done(packet_proc_done),
                   /** Output Signal **/
                 .packet_ready_send(packet_ready_send),  /** Packet is required to sent to processor **/
                 .packet_data_proc(packet_data_proc),
                 .buffer_data_full(buffer_send_full),
                 .buffer_data_epty(buffer_send_epty)
			   );



fifo_lemt fifo ( .clk(clk), .rst(rst),
                 .buffer_data_reset(buffer_data_reset),
                 .buffer_wt_enable(buffer_wten_lemt),
                 .buffer_rd_enable(buffer_read_lemt),
                 .buffer_wt_data(memory_rd_data_lemt),
                   /** Output Signal **/
                 .buffer_rd_data(buffer_data_lemt)
               );



bank_lemt lemt ( .clk(clk), .rst(rst),
                 .memory_chunk_update(memory_chunk_update),
                 .memory_data_lemt(memory_data_lemt),
                 .memory_addr_lemt_5(memory_addr_lemt_5),
                 .memory_wt_data_5(memory_wt_data_lemt_5),
                 .memory_rd_enable_5(memory_read_lemt_5),
                 .memory_wt_enable_5(memory_wten_lemt_5),
                 .memory_addr_lemt_4(memory_addr_lemt_4),
                 .memory_wt_data_4(memory_wt_data_lemt_4),
                 .memory_rd_enable_4(memory_read_lemt_4),
                 .memory_wt_enable_4(memory_wten_lemt_4),
                 .memory_addr_lemt_3(memory_addr_lemt_3),
                 .memory_wt_data_3(memory_wt_data_lemt_3),
                 .memory_rd_enable_3(memory_read_lemt_3),
                 .memory_wt_enable_3(memory_wten_lemt_3),
                 .memory_addr_lemt_2(memory_addr_lemt_2),
                 .memory_wt_data_2(memory_wt_data_lemt_2),
                 .memory_rd_enable_2(memory_read_lemt_2),
                 .memory_wt_enable_2(memory_wten_lemt_2),
                 .memory_addr_lemt_1(memory_addr_lemt_1),
                 .memory_wt_data_1({word_size{1'b0}}),
                 .memory_rd_enable_1(memory_read_lemt_1),
                 .memory_wt_enable_1(1'b0),
                 .memory_addr_lemt_0(memory_addr_lemt_0),
                 .memory_wt_data_0(memory_wt_data_lemt_0),
                 .memory_rd_enable_0(memory_read_lemt_0),
                 .memory_wt_enable_0(memory_wten_lemt_0),
                 /** output signal **/
                 .memory_data_ready(memory_ready_lemt),
                 .memory_addr_lemt(memory_addr_lemt),
                 .memory_wt_data(memory_wt_data_lemt),
                 .memory_rd_data(memory_rd_data_lemt),
                 .memory_wt_enable(memory_wten_lemt),
                 .memory_rd_enable(memory_read_lemt),
                 .memory_device_enable(memory_device_lemt),
                 .memory_addr_init_prt(memory_addr_init_prt),
                 .memory_addr_init_prv(memory_addr_init_prv)
               );


sram_lemt sram ( .clk(clk), .rst(rst),
                 .memory_device_enable(memory_device_lemt),
                 .memory_addr_lemt(memory_addr_lemt),
                 .memory_wt_data(memory_wt_data_lemt),
                 .memory_wt_enable(memory_wten_lemt),
                 .memory_rd_enable(memory_read_lemt),
				  /** output signal **/
                 .memory_rd_data(memory_data_lemt)
                );




address_calculator addr ( .clk(clk), .rst(rst),
                          .compute_enable_actc(compute_enable_actc),
                          .compute_packet_actc(compute_packet_actc),
                          .compute_length_actc(compute_length_actc),
                          .compute_enable_buld(compute_enable_buld),
                          .compute_packet_buld(compute_packet_buld),
                          .compute_length_buld(compute_length_buld),
                            /** Output Signal **/
                          .memory_addr_computed(memory_addr_computed),
                          .compute_addr_done(compute_addr_done)
				 		);

generate

    for(index_lane = 0; index_lane < lane_size; index_lane = index_lane + 1)
    begin : lanes


        lane_unit lane ( .clk(clk), .rst(rst),
                         .image_pixel_buffer(buffer_data_pixel[(index_lane+1)*word_size - 1 : index_lane*word_size]),
                         .process_enable_scan(process_enable_scan[index_lane]),
                         .process_enable_lapp(process_enable_lapp[index_lane]),
                         .process_enable_adpt(process_enable_adpt[index_lane]),
                         .process_enable_bost(process_enable_bost[index_lane]),
                         .process_enable_sort(process_enable_sort[index_lane]),
                         .process_enable_updt(process_enable_updt[index_lane]),
                         .process_learn_enable(process_learn_enable),
                         .index_lane_ready(index_lane_ready[index_lane]),
                         .memory_data_lemt(memory_rd_data_lemt),
                         .index_data_lane(index_data_lane),
                         .index_dirty_ready(index_dirty_ready[index_lane]),
                         .buffer_conf_reset(buffer_conf_reset),
                         .result_maxn_ready(result_maxn_ready),
                         .packet_data_rcvd(packet_data_rcvd),
                         .buffer_data_lemt(buffer_data_lemt),
                         .memory_ready_lemt(memory_ready_lemt),
                         .memory_addr_computed(memory_addr_computed),
                         .memory_addr_received(memory_addr_received),
                         .memory_addr_buffered(memory_addr_buffered),
                         .device_code_find(device_code_find[index_lane]),
                         .operate_buffer(operate_buffer),
                         .process_find_actc(process_find_actc[index_lane]),
                         .process_find_buld(process_find_buld[index_lane]),
                         .process_find_pred(process_find_pred[index_lane]),
                         .memory_addr_load_rcvd(memory_addr_load_rcvd),
                         .memory_lane_wten(memory_lane_wten[index_lane]),
                         .memory_lane_read(memory_lane_read[index_lane]),
                         .memory_addr_rset(memory_addr_rset[index_lane]),
			 .memory_data_merg(memory_data_lane[index_lane]),
                         /** output signal **/
			 .memory_buff_ready(memory_buff_ready[index_lane]),
                         .memory_data_sort(memory_buff_lane[index_lane]),
                         .index_row_lane(index_row_lane[index_lane]),
                         .index_col_lane(index_col_lane[index_lane]),
                         .index_cfg_lane(index_cfg_lane[index_lane]),
                         .process_done_scan(process_done_scan[index_lane]),
                         .process_done_lapp(process_done_lapp[index_lane]),
                         .process_done_adpt(process_done_adpt[index_lane]),
                         .process_done_bost(process_done_bost[index_lane]),
                         .process_done_sort(process_done_sort[index_lane]),
                         .process_done_updt(process_done_updt[index_lane]),
                         .process_done_find(process_done_find[index_lane]),
                         .image_read_enable(image_read_enable[index_lane]),
                         .bound_pass_lane(bound_pass_lane[index_lane]),
                         .buffer_max_scan(buffer_max_scan[index_lane]),
                         .buffer_max_adpt(buffer_max_adpt[index_lane]),
                         .memory_find_busy(memory_find_busy[index_lane]),
                         .packet_maxn_ready(packet_maxn_ready[index_lane]),
                         .buffer_data_value(buffer_data_value[index_lane]),
                         .buffer_counter_find(buffer_counter_find[index_lane])
                       );
    end

endgenerate



endmodule


// `include "../param.vh"

module maxr_lemt ( clk, rst,
                   packet_sort_ready,
                   input_data_0,
                   input_data_1,
                   input_data_2,
                   input_data_3,
                   input_data_4,
                   input_data_5,
                   input_data_6,
                   input_data_7,
                   /** Output Signal **/
                   result_sort_ready,
                   output_data_0,
                   output_data_1,
                   output_data_2,
                   output_data_3,
                   output_data_4,
                   output_data_5,
                   output_data_6,
                   output_data_7
                 );

parameter lane_size = `lane_size_para,
          long_size = `long_size_para,
          word_size = `word_size_para;

input wire clk, rst;
input wire [lane_size - 1 : 0] packet_sort_ready;
input wire [long_size - 1 : 0] input_data_0, input_data_1;
input wire [long_size - 1 : 0] input_data_2, input_data_3;
input wire [long_size - 1 : 0] input_data_4, input_data_5;
input wire [long_size - 1 : 0] input_data_6, input_data_7;

output reg result_sort_ready;
output reg [long_size - 1 : 0] output_data_0,  output_data_1;
output reg [long_size - 1 : 0] output_data_2,  output_data_3;
output reg [long_size - 1 : 0] output_data_4,  output_data_5;
output reg [long_size - 1 : 0] output_data_6,  output_data_7;



reg [long_size - 1 : 0] buffer_data_maxr [lane_size - 1 : 0];
reg [long_size - 1 : 0] buffer_data_muxr [lane_size - 1 : 0];
reg [long_size - 1 : 0] sorts_data_0, sorts_data_1;
reg [long_size - 1 : 0] sorts_data_2, sorts_data_3;
reg [long_size - 1 : 0] sorts_data_4, sorts_data_5;
reg [long_size - 1 : 0] sorts_data_6, sorts_data_7;
reg [long_size - 1 : 0] swaped_data_0, swaped_data_1;
reg [long_size - 1 : 0] swaped_data_2, swaped_data_3;
reg [long_size - 1 : 0] swaped_data_4, swaped_data_5;
reg [long_size - 1 : 0] swaped_data_6, swaped_data_7;
reg [long_size - 1 : 0] buffer_data_0, buffer_data_1;
reg [long_size - 1 : 0] buffer_data_2, buffer_data_3;
reg [long_size - 1 : 0] buffer_data_4, buffer_data_5;
reg [long_size - 1 : 0] buffer_data_6, buffer_data_7;
reg [2 : 0] phase, phase_timer_maxr;
reg [3 : 0] stage, logic_timer_maxr;
reg device_maxr_enable, packet_data_ready, sorter_data_ready;
reg buffer_flag_0, buffer_flag_1;
reg buffer_flag_2, buffer_flag_3;


always @(posedge clk)
begin
  if((~rst)||(result_sort_ready == 1'b1)) begin
    device_maxr_enable <= 1'b0;
  end
  else if(packet_data_ready == 1'b1) begin
    device_maxr_enable <= 1'b1;
  end
  else begin
    device_maxr_enable <= device_maxr_enable;
  end
end


always @(posedge clk)
begin
  if((~rst)||(result_sort_ready == 1'b1)) begin
	phase_timer_maxr <= 3'b000;
  end
  else if(sorter_data_ready == 1'b1) begin
    phase_timer_maxr <= phase_timer_maxr + 1'b1;
  end
  else begin
    phase_timer_maxr <= phase_timer_maxr;
  end
end


always @(posedge clk)
begin
  if((~rst)||(sorter_data_ready == 1'b1)) begin
    logic_timer_maxr <= 4'b0000;
  end
  else if(device_maxr_enable == 1'b1) begin
    logic_timer_maxr <= logic_timer_maxr + 1'b1;
  end
  else begin
    logic_timer_maxr <= logic_timer_maxr;
  end
end


always @(*)
begin
  case(phase_timer_maxr)
    3'b000 : stage = 4'b1010;
    3'b001 : stage = 4'b1100;
    3'b010 : stage = 4'b1100;
	default: stage = 4'b0000;
  endcase
end


always @(*)
begin
  case(phase_timer_maxr)
    3'b001 : phase = 3'b001;
    3'b011 : phase = 3'b010;
    3'b100 : phase = 3'b001;
	default: phase = 3'b000;
  endcase
end


always @(posedge clk)
begin
  if(~rst) begin
    result_sort_ready <= (1'b0);
  end
  else begin
    result_sort_ready <= (phase_timer_maxr == 3'b101)&&(logic_timer_maxr == 4'b0010);
  end
end


always @(*)
begin
  sorter_data_ready = (logic_timer_maxr == 4'b0011)&&(device_maxr_enable == 1'b1);
  packet_data_ready = (packet_sort_ready == {lane_size{1'b1}});
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_data_maxr[0] <= {long_size{1'b0}};
    buffer_data_maxr[1] <= {long_size{1'b0}};
    buffer_data_maxr[2] <= {long_size{1'b0}};
    buffer_data_maxr[3] <= {long_size{1'b0}};
    buffer_data_maxr[4] <= {long_size{1'b0}};
    buffer_data_maxr[5] <= {long_size{1'b0}};
    buffer_data_maxr[6] <= {long_size{1'b0}};
    buffer_data_maxr[7] <= {long_size{1'b0}};
  end
  else if(packet_data_ready == 1'b1) begin
    buffer_data_maxr[0] <= input_data_0;
    buffer_data_maxr[1] <= input_data_1;
    buffer_data_maxr[2] <= input_data_2;
    buffer_data_maxr[3] <= input_data_3;
    buffer_data_maxr[4] <= input_data_4;
    buffer_data_maxr[5] <= input_data_5;
    buffer_data_maxr[6] <= input_data_6;
    buffer_data_maxr[7] <= input_data_7;
  end
  else if(sorter_data_ready == 1'b1) begin
    buffer_data_maxr[0] <= sorts_data_0;
    buffer_data_maxr[1] <= sorts_data_1;
    buffer_data_maxr[2] <= sorts_data_2;
    buffer_data_maxr[3] <= sorts_data_3;
    buffer_data_maxr[4] <= sorts_data_4;
    buffer_data_maxr[5] <= sorts_data_5;
    buffer_data_maxr[6] <= sorts_data_6;
    buffer_data_maxr[7] <= sorts_data_7;
  end
  else begin
    buffer_data_maxr[0] <= buffer_data_maxr[0];
    buffer_data_maxr[1] <= buffer_data_maxr[1];
    buffer_data_maxr[2] <= buffer_data_maxr[2];
    buffer_data_maxr[3] <= buffer_data_maxr[3];
    buffer_data_maxr[4] <= buffer_data_maxr[4];
    buffer_data_maxr[5] <= buffer_data_maxr[5];
    buffer_data_maxr[6] <= buffer_data_maxr[6];
    buffer_data_maxr[7] <= buffer_data_maxr[7];
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_data_muxr[0] <= {long_size{1'b0}};
    buffer_data_muxr[1] <= {long_size{1'b0}};
    buffer_data_muxr[2] <= {long_size{1'b0}};
    buffer_data_muxr[3] <= {long_size{1'b0}};
    buffer_data_muxr[4] <= {long_size{1'b0}};
    buffer_data_muxr[5] <= {long_size{1'b0}};
    buffer_data_muxr[6] <= {long_size{1'b0}};
    buffer_data_muxr[7] <= {long_size{1'b0}};
  end
  else if(phase == 3'b001) begin
    buffer_data_muxr[0] <= {buffer_data_maxr[0]};
    buffer_data_muxr[1] <= {buffer_data_maxr[2]};
    buffer_data_muxr[2] <= {buffer_data_maxr[1]};
    buffer_data_muxr[3] <= {buffer_data_maxr[3]};
    buffer_data_muxr[4] <= {buffer_data_maxr[4]};
    buffer_data_muxr[5] <= {buffer_data_maxr[6]};
    buffer_data_muxr[6] <= {buffer_data_maxr[5]};
    buffer_data_muxr[7] <= {buffer_data_maxr[7]};
  end
  else if(phase == 3'b010) begin
    buffer_data_muxr[0] <= {buffer_data_maxr[0]};
    buffer_data_muxr[1] <= {buffer_data_maxr[4]};
    buffer_data_muxr[2] <= {buffer_data_maxr[1]};
    buffer_data_muxr[3] <= {buffer_data_maxr[5]};
    buffer_data_muxr[4] <= {buffer_data_maxr[2]};
    buffer_data_muxr[5] <= {buffer_data_maxr[6]};
    buffer_data_muxr[6] <= {buffer_data_maxr[3]};
    buffer_data_muxr[7] <= {buffer_data_maxr[7]};
  end
  else begin
    buffer_data_muxr[0] <= {buffer_data_maxr[0]};
    buffer_data_muxr[1] <= {buffer_data_maxr[1]};
    buffer_data_muxr[2] <= {buffer_data_maxr[2]};
    buffer_data_muxr[3] <= {buffer_data_maxr[3]};
    buffer_data_muxr[4] <= {buffer_data_maxr[4]};
    buffer_data_muxr[5] <= {buffer_data_maxr[5]};
    buffer_data_muxr[6] <= {buffer_data_maxr[6]};
    buffer_data_muxr[7] <= {buffer_data_maxr[7]};
  end
end


always @(*)
begin
  swaped_data_0 = {buffer_data_muxr[0][long_size - 1 : word_size], {~buffer_data_muxr[0][word_size - 1 : word_size - 32]}};
  swaped_data_1 = {buffer_data_muxr[1][long_size - 1 : word_size], {~buffer_data_muxr[1][word_size - 1 : word_size - 32]}};
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_flag_0 <= (1'b0);
  end
  else begin
    buffer_flag_0 <= (swaped_data_0 > swaped_data_1);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_data_0 <= {long_size{1'b0}};
  end
  else begin
    case(stage[0])
      1'b1  : buffer_data_0 <= (buffer_flag_0 == 1'b1) ? buffer_data_muxr[1] : buffer_data_muxr[0];
      1'b0  : buffer_data_0 <= (buffer_flag_0 == 1'b0) ? buffer_data_muxr[1] : buffer_data_muxr[0];
    endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_data_1 <= {long_size{1'b0}};
  end
  else begin
    case(stage[0])
      1'b1  : buffer_data_1 <= (buffer_flag_0 == 1'b1) ? buffer_data_muxr[0] : buffer_data_muxr[1];
      1'b0  : buffer_data_1 <= (buffer_flag_0 == 1'b0) ? buffer_data_muxr[0] : buffer_data_muxr[1];
    endcase
  end
end


always @(*)
begin
  swaped_data_2 = {buffer_data_muxr[2][long_size - 1 : word_size], {~buffer_data_muxr[2][word_size - 1 : word_size - 32]}};
  swaped_data_3 = {buffer_data_muxr[3][long_size - 1 : word_size], {~buffer_data_muxr[3][word_size - 1 : word_size - 32]}};
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_flag_1 <= (1'b0);
  end
  else begin
    buffer_flag_1 <= (swaped_data_2 > swaped_data_3);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_data_2 <= {long_size{1'b0}};
  end
  else begin
    case(stage[1])
      1'b1  : buffer_data_2 <= (buffer_flag_1 == 1'b1) ? buffer_data_muxr[3] : buffer_data_muxr[2];
      1'b0  : buffer_data_2 <= (buffer_flag_1 == 1'b0) ? buffer_data_muxr[3] : buffer_data_muxr[2];
    endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_data_3 <= {long_size{1'b0}};
  end
  else begin
    case(stage[1])
      1'b1  : buffer_data_3 <= (buffer_flag_1 == 1'b1) ? buffer_data_muxr[2] : buffer_data_muxr[3];
      1'b0  : buffer_data_3 <= (buffer_flag_1 == 1'b0) ? buffer_data_muxr[2] : buffer_data_muxr[3];
    endcase
  end
end


always @(*)
begin
  swaped_data_4 = {buffer_data_muxr[4][long_size - 1 : word_size], {~buffer_data_muxr[4][word_size - 1 : word_size - 32]}};
  swaped_data_5 = {buffer_data_muxr[5][long_size - 1 : word_size], {~buffer_data_muxr[5][word_size - 1 : word_size - 32]}};
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_flag_2 <= (1'b0);
  end
  else begin
    buffer_flag_2 <= (swaped_data_4 > swaped_data_5);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_data_4 <= {long_size{1'b0}};
  end
  else begin
    case(stage[2])
      1'b1  : buffer_data_4 <= (buffer_flag_2 == 1'b1) ? buffer_data_muxr[5] : buffer_data_muxr[4];
      1'b0  : buffer_data_4 <= (buffer_flag_2 == 1'b0) ? buffer_data_muxr[5] : buffer_data_muxr[4];
    endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_data_5 <= {long_size{1'b0}};
  end
  else begin
    case(stage[2])
      1'b1  : buffer_data_5 <= (buffer_flag_2 == 1'b1) ? buffer_data_muxr[4] : buffer_data_muxr[5];
      1'b0  : buffer_data_5 <= (buffer_flag_2 == 1'b0) ? buffer_data_muxr[4] : buffer_data_muxr[5];
    endcase
  end
end


always @(*)
begin
  swaped_data_6 = {buffer_data_muxr[6][long_size - 1 : word_size], {~buffer_data_muxr[6][word_size - 1 : word_size - 32]}};
  swaped_data_7 = {buffer_data_muxr[7][long_size - 1 : word_size], {~buffer_data_muxr[7][word_size - 1 : word_size - 32]}};
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_flag_3 <= (1'b0);
  end
  else begin
    buffer_flag_3 <= (swaped_data_6 > swaped_data_7);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_data_6 <= {long_size{1'b0}};
  end
  else begin
    case(stage[3])
      1'b1  : buffer_data_6 <= (buffer_flag_3 == 1'b1) ? buffer_data_muxr[7] : buffer_data_muxr[6];
      1'b0  : buffer_data_6 <= (buffer_flag_3 == 1'b0) ? buffer_data_muxr[7] : buffer_data_muxr[6];
    endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_data_7 <= {long_size{1'b0}};
  end
  else begin
    case(stage[3])
      1'b1  : buffer_data_7 <= (buffer_flag_3 == 1'b1) ? buffer_data_muxr[6] : buffer_data_muxr[7];
      1'b0  : buffer_data_7 <= (buffer_flag_3 == 1'b0) ? buffer_data_muxr[6] : buffer_data_muxr[7];
    endcase
  end
end


always @(*)
begin
  case(phase)
    3'b001: begin
              sorts_data_0 = buffer_data_0;
              sorts_data_1 = buffer_data_2;
              sorts_data_2 = buffer_data_1;
              sorts_data_3 = buffer_data_3;
              sorts_data_4 = buffer_data_4;
              sorts_data_5 = buffer_data_6;
              sorts_data_6 = buffer_data_5;
              sorts_data_7 = buffer_data_7;
	        end
    3'b010: begin
              sorts_data_0 = buffer_data_0;
              sorts_data_1 = buffer_data_2;
              sorts_data_2 = buffer_data_4;
              sorts_data_3 = buffer_data_6;
              sorts_data_4 = buffer_data_1;
              sorts_data_5 = buffer_data_3;
              sorts_data_6 = buffer_data_5;
              sorts_data_7 = buffer_data_7;
	        end
	default:begin
              sorts_data_0 = buffer_data_0;
              sorts_data_1 = buffer_data_1;
              sorts_data_2 = buffer_data_2;
              sorts_data_3 = buffer_data_3;
              sorts_data_4 = buffer_data_4;
              sorts_data_5 = buffer_data_5;
              sorts_data_6 = buffer_data_6;
              sorts_data_7 = buffer_data_7;
	        end
  endcase
end


always @(*)
begin
  output_data_0 = buffer_data_maxr[0];
  output_data_1 = buffer_data_maxr[1];
  output_data_2 = buffer_data_maxr[2];
  output_data_3 = buffer_data_maxr[3];
  output_data_4 = buffer_data_maxr[4];
  output_data_5 = buffer_data_maxr[5];
  output_data_6 = buffer_data_maxr[6];
  output_data_7 = buffer_data_maxr[7];
end


endmodule


/** Assuming the count of active column is always larger than the synapse count per segment **/
// `include "../param.vh"

module merg_ctrl ( clk, rst,
                   process_enable_merg,
				   memory_data_ready,
				   round_flag_head,
                   buffer_st_data_0,
                   buffer_st_data_1,
                   buffer_st_data_2,
                   buffer_st_data_3,
                   buffer_st_data_4,
                   buffer_st_data_5,
                   buffer_st_data_6,
                   buffer_st_data_7,
                   memory_rd_data_0,
                   memory_rd_data_1,
                   memory_rd_data_2,
                   memory_rd_data_3,
                   memory_rd_data_4,
                   memory_rd_data_5,
                   memory_rd_data_6,
                   memory_rd_data_7,
                   /** output signal **/
                   process_done_merg,
                   memory_lane_wten,
                   memory_lane_read,
 		   memory_addr_rset,
                   memory_data_lane_0,
                   memory_data_lane_1,
                   memory_data_lane_2,
                   memory_data_lane_3,
                   memory_data_lane_4,
                   memory_data_lane_5,
                   memory_data_lane_6,
                   memory_data_lane_7
		   	     );

parameter word_size = `word_size_para,
          lane_size = `lane_size_para,
          addr_size = `addr_size_para,
          distal_synapse_count = `distal_synapse_count_para,
          memory_addr_init_per = `memory_addr_init_per_para,
          memory_addr_init_tmp = `memory_addr_init_tmp_para, /** address for temp store synapse per lane **/
          permanence_initial = `perm_init_dis_para;


input wire clk, rst;
input wire process_enable_merg, round_flag_head;
input wire [lane_size - 1 : 0] memory_data_ready;
input wire [word_size - 1 : 0] buffer_st_data_0, buffer_st_data_1;
input wire [word_size - 1 : 0] buffer_st_data_2, buffer_st_data_3;
input wire [word_size - 1 : 0] buffer_st_data_4, buffer_st_data_5;
input wire [word_size - 1 : 0] buffer_st_data_6, buffer_st_data_7;
input wire [word_size - 1 : 0] memory_rd_data_0, memory_rd_data_1;
input wire [word_size - 1 : 0] memory_rd_data_2, memory_rd_data_3;
input wire [word_size - 1 : 0] memory_rd_data_4, memory_rd_data_5;
input wire [word_size - 1 : 0] memory_rd_data_6, memory_rd_data_7;


output reg [word_size - 1 : 0] memory_data_lane_0, memory_data_lane_1;
output reg [word_size - 1 : 0] memory_data_lane_2, memory_data_lane_3;
output reg [word_size - 1 : 0] memory_data_lane_4, memory_data_lane_5;
output reg [word_size - 1 : 0] memory_data_lane_6, memory_data_lane_7;
output reg process_done_merg;
output reg [lane_size - 1 : 0] memory_lane_read, memory_lane_wten;
output reg [lane_size - 1 : 0] memory_addr_rset;


reg [word_size - 1 : 0] buffer_data_lane [lane_size - 1 : 0];
reg [word_size - 1 : 0] buffer_data_sort [lane_size - 1 : 0];
reg [word_size - 1 : 0] buffer_data_wten [lane_size - 1 : 0];
reg [word_size - 1 : 0] buffer_data_cont [lane_size - 1 : 0];
reg [word_size - 1 : 0] buffer_data_temp;

reg [2 : 0] index_buffer_sort, index_buffer_lane, index_buffer_wten;
reg [2 : 0] state_merg, next_state_merg;
reg [7 : 0] synapse_loop_count;
reg synapse_loop_done, memory_lane_ready;
reg index_lane_count, index_sort_count;
reg memory_buffer_done, writen_buffer_done;
reg writen_buffer_full, sorter_buffer_done;
reg sorter_data_ready, buffer_data_ready;
reg buffer_data_found, sorter_buff_ready;
reg buffer_data_flag, index_wten_reset;
reg memory_data_empty, memory_buffer_read;



integer index;



always @(posedge clk)
begin
  if(~rst) begin
    state_merg <= 3'b000;
  end
  else begin
    state_merg <= next_state_merg;
  end
end


always @(*)
begin
  case(state_merg)
    3'b000 : begin
	           if(process_enable_merg == 1'b1) begin
	             next_state_merg = round_flag_head ? 3'b101 : 3'b010;
	           end
	           else begin
	             next_state_merg = 3'b000;
	           end
	         end
    3'b001 : begin /** Merge the data from source into target register **/
	           if(writen_buffer_done == 1'b1) begin
	             next_state_merg = 3'b011;
	           end
	           else begin
	             next_state_merg = memory_buffer_done ? 3'b010 : 3'b001;
	           end
	         end
    3'b010 : begin /** Read data from lane sram into memory register **/
	           if(memory_lane_ready == 1'b1) begin
	             next_state_merg = 3'b001;
	           end
	           else begin
	             next_state_merg = 3'b010;
	           end
	         end
    3'b011 : begin /** Write the synapse information into lane memory **/
	           if(synapse_loop_done == 1'b1) begin
	             next_state_merg = 3'b000;
	           end
	           else begin
	             next_state_merg = memory_buffer_read ? 3'b010 : 3'b001;
	           end
	         end
    3'b100 : begin /** Write the permanence value into lane memory **/
	           if(synapse_loop_done == 1'b1) begin
	             next_state_merg = 3'b000;
	           end
	           else begin
	             next_state_merg = 3'b001;
	           end
	         end
    3'b101 : begin /** Write the sorter data into buffer for first round **/
	           next_state_merg = 3'b000;
             end
    default: begin
	           next_state_merg = 3'b000;
	         end
  endcase
end


always @(posedge clk)
begin
  if(~rst) begin
    process_done_merg <= 1'b0;
  end
  else begin
    process_done_merg <= (state_merg != 3'b000)&&(next_state_merg == 3'b000);
  end
end


always @(posedge clk)
begin /** Store data received from sort logic **/
  if(~rst) begin
    buffer_data_sort[0] <= {word_size{1'b0}};
    buffer_data_sort[1] <= {word_size{1'b0}};
    buffer_data_sort[2] <= {word_size{1'b0}};
    buffer_data_sort[3] <= {word_size{1'b0}};
    buffer_data_sort[4] <= {word_size{1'b0}};
    buffer_data_sort[5] <= {word_size{1'b0}};
    buffer_data_sort[6] <= {word_size{1'b0}};
    buffer_data_sort[7] <= {word_size{1'b0}};
  end
  else if(sorter_buff_ready == 1'b1) begin
    buffer_data_sort[0] <= buffer_st_data_0;
    buffer_data_sort[1] <= buffer_st_data_1;
    buffer_data_sort[2] <= buffer_st_data_2;
    buffer_data_sort[3] <= buffer_st_data_3;
    buffer_data_sort[4] <= buffer_st_data_4;
    buffer_data_sort[5] <= buffer_st_data_5;
    buffer_data_sort[6] <= buffer_st_data_6;
    buffer_data_sort[7] <= buffer_st_data_7;
  end
  else begin
    buffer_data_sort[0] <= buffer_data_sort[0];
    buffer_data_sort[1] <= buffer_data_sort[1];
    buffer_data_sort[2] <= buffer_data_sort[2];
    buffer_data_sort[3] <= buffer_data_sort[3];
    buffer_data_sort[4] <= buffer_data_sort[4];
    buffer_data_sort[5] <= buffer_data_sort[5];
    buffer_data_sort[6] <= buffer_data_sort[6];
    buffer_data_sort[7] <= buffer_data_sort[7];
  end
end


always @(*)
begin
  synapse_loop_done = (synapse_loop_count >= (distal_synapse_count - 1));
  sorter_buff_ready = (process_enable_merg == 1'b1)&&(round_flag_head == 1'b0); /** second time **/
  memory_lane_ready = (memory_data_ready == {lane_size{1'b1}});
end


/** state_merg == 3'b001, merge the data from source into target register **/


always @(posedge clk)
begin
  if((~rst)||(process_done_merg == 1'b1)) begin
    synapse_loop_count <= 8'b00000000;
  end
  else if(state_merg == 3'b001) begin
    synapse_loop_count <= synapse_loop_count + 1'b1;
  end
  else begin
    synapse_loop_count <= synapse_loop_count;
  end
end


always @(*)
begin
  if(buffer_data_sort[index_buffer_sort] >= buffer_data_lane[index_buffer_lane]) begin
    buffer_data_found = 1'b1;
  end
  else begin
    buffer_data_found = 1'b0;
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_done_merg == 1'b1)) begin
    buffer_data_flag <= 1'b0;
  end
  else if(sorter_buffer_done == 1'b1) begin
    buffer_data_flag <= 1'b1;
  end
  else begin
    buffer_data_flag <= buffer_data_flag;
  end
end


always @(*)
begin
  if((buffer_data_flag == 1'b0)&&(buffer_data_found == 1'b0)) begin
    buffer_data_temp = buffer_data_sort[index_buffer_sort];
    index_sort_count = 1'b1;
    index_lane_count = 1'b0;
  end
  else begin
    buffer_data_temp = buffer_data_lane[index_buffer_lane];
    index_sort_count = 1'b0;
    index_lane_count = 1'b1;
  end
end


always @(posedge clk)
begin
  if((~rst)||(index_wten_reset == 1'b1)) begin
    index_buffer_wten <= 3'b000;
  end
  else if(state_merg == 3'b001) begin
    index_buffer_wten <= index_buffer_wten + 1'b1;
  end
  else begin
    index_buffer_wten <= index_buffer_wten;
  end
end


always @(posedge clk)
begin
  if((~rst)||(index_wten_reset == 1'b1)) begin
    for(index = 0; index < lane_size; index = index + 1)
      buffer_data_wten[index] <= {word_size{1'b0}};
  end
  else if(state_merg == 3'b001) begin
    buffer_data_wten[index_buffer_wten] <= buffer_data_temp;
  end
  else begin
    for(index = 0; index < lane_size; index = index + 1)
      buffer_data_wten[index] <= buffer_data_wten[index];
  end
end


always @(*)
begin
  index_wten_reset = (state_merg == 3'b011);
end


always @(posedge clk)
begin
  if((~rst)||(process_done_merg == 1'b1)) begin
    index_buffer_sort <= 3'b000;
  end
  else if((index_sort_count == 1'b1)&&(state_merg == 3'b001))  begin
    index_buffer_sort <= index_buffer_sort + 1'b1;
  end
  else begin
    index_buffer_sort <= index_buffer_sort;
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_done_merg == 1'b1)) begin
    index_buffer_lane <= 3'b000;
  end
  else if((index_lane_count == 1'b1)&&(state_merg == 3'b001)) begin
    index_buffer_lane <= index_buffer_lane + 1'b1;
  end
  else begin
    index_buffer_lane <= index_buffer_lane;
  end
end


always @(*)
begin
  sorter_buffer_done = (index_buffer_sort == (lane_size - 1))&&(buffer_data_found == 1'b0);
  memory_buffer_done = (index_buffer_lane == (lane_size - 1))&&(buffer_data_found == 1'b1);
  writen_buffer_full = (index_buffer_wten == (lane_size - 1));
  writen_buffer_done = (writen_buffer_full == 1'b1)||(synapse_loop_done == 1'b1);
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_buffer_read <= 1'b0;
  end
  else begin
    memory_buffer_read <= (memory_buffer_done == 1'b1);
  end
end


/** state_merg == 3'b010, read data from lane sram into memory register **/


always @ (posedge clk)
begin
  if(~rst) begin
    memory_lane_read <= {lane_size{1'b0}};
  end
  else begin
    memory_lane_read <= {lane_size{(next_state_merg == 3'b010)&&(state_merg != 3'b010)}};
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_rset <= {lane_size{1'b0}};
  end
  else begin
    memory_addr_rset <= {lane_size{(state_merg != 3'b000)&&(next_state_merg == 3'b000)}};
  end
end


always @(posedge clk)
begin /** none data written into lane memory yet **/
  if((~rst)||(round_flag_head == 1'b1)) begin
    memory_data_empty <= 1'b0;
  end
  else if(state_merg == 3'b011) begin
    memory_data_empty <= 1'b1;
  end
  else begin
    memory_data_empty <= memory_data_empty;
  end
end


always @(*)
begin
  sorter_data_ready = (process_enable_merg == 1'b1)&&(round_flag_head == 1'b1);
  buffer_data_ready = (memory_lane_ready == 1'b1)&&(state_merg == 3'b010)&&(memory_data_empty == 1'b1);
end


always @(posedge clk)
begin /** Store data received from lane logic **/
  if(~rst) begin
    buffer_data_lane[0] <= {word_size{1'b0}};
    buffer_data_lane[1] <= {word_size{1'b0}};
    buffer_data_lane[2] <= {word_size{1'b0}};
    buffer_data_lane[3] <= {word_size{1'b0}};
    buffer_data_lane[4] <= {word_size{1'b0}};
    buffer_data_lane[5] <= {word_size{1'b0}};
    buffer_data_lane[6] <= {word_size{1'b0}};
    buffer_data_lane[7] <= {word_size{1'b0}};
  end
  else if(buffer_data_ready == 1'b1) begin
    buffer_data_lane[0] <= memory_rd_data_0;
    buffer_data_lane[1] <= memory_rd_data_1;
    buffer_data_lane[2] <= memory_rd_data_2;
    buffer_data_lane[3] <= memory_rd_data_3;
    buffer_data_lane[4] <= memory_rd_data_4;
    buffer_data_lane[5] <= memory_rd_data_5;
    buffer_data_lane[6] <= memory_rd_data_6;
    buffer_data_lane[7] <= memory_rd_data_7;
  end
  else if(sorter_data_ready == 1'b1) begin
    buffer_data_lane[0] <= buffer_st_data_0;
    buffer_data_lane[1] <= buffer_st_data_1;
    buffer_data_lane[2] <= buffer_st_data_2;
    buffer_data_lane[3] <= buffer_st_data_3;
    buffer_data_lane[4] <= buffer_st_data_4;
    buffer_data_lane[5] <= buffer_st_data_5;
    buffer_data_lane[6] <= buffer_st_data_6;
    buffer_data_lane[7] <= buffer_st_data_7;
  end
  else begin
    buffer_data_lane[0] <= buffer_data_lane[0];
    buffer_data_lane[1] <= buffer_data_lane[1];
    buffer_data_lane[2] <= buffer_data_lane[2];
    buffer_data_lane[3] <= buffer_data_lane[3];
    buffer_data_lane[4] <= buffer_data_lane[4];
    buffer_data_lane[5] <= buffer_data_lane[5];
    buffer_data_lane[6] <= buffer_data_lane[6];
    buffer_data_lane[7] <= buffer_data_lane[7];
  end
end


/** state_merg == 3'b011, write the synapse information into lane memory **/
/** state_merg == 3'b100, write the permanence value into lane memory **/


always @(posedge clk)
begin
  if(~rst) begin
    memory_lane_wten <= {lane_size{1'b0}};
  end
  else begin
    memory_lane_wten <= {lane_size{(next_state_merg == 3'b011)}};
  end
end



always @(*)
begin
  memory_data_lane_0 = buffer_data_wten[0];
  memory_data_lane_1 = buffer_data_wten[1];
  memory_data_lane_2 = buffer_data_wten[2];
  memory_data_lane_3 = buffer_data_wten[3];
  memory_data_lane_4 = buffer_data_wten[4];
  memory_data_lane_5 = buffer_data_wten[5];
  memory_data_lane_6 = buffer_data_wten[6];
  memory_data_lane_7 = buffer_data_wten[7];
end


endmodule


// `include "../param.vh"

module mixr_lemt ( clk, rst,
                   packet_sort_ready,
                   input_data_0,
                   input_data_1,
                   input_data_2,
                   input_data_3,
                   input_data_4,
                   input_data_5,
                   input_data_6,
                   input_data_7,
                   /** Output Signal **/
                   result_sort_ready,
                   output_data_0,
                   output_data_1,
                   output_data_2,
                   output_data_3,
                   output_data_4,
                   output_data_5,
                   output_data_6,
                   output_data_7
                 );

parameter lane_size = `lane_size_para,
          word_size = `word_size_para;

input wire clk, rst;
input wire packet_sort_ready;
input wire [word_size - 1 : 0] input_data_0, input_data_1;
input wire [word_size - 1 : 0] input_data_2, input_data_3;
input wire [word_size - 1 : 0] input_data_4, input_data_5;
input wire [word_size - 1 : 0] input_data_6, input_data_7;

output reg result_sort_ready;
output reg [word_size - 1 : 0] output_data_0,  output_data_1;
output reg [word_size - 1 : 0] output_data_2,  output_data_3;
output reg [word_size - 1 : 0] output_data_4,  output_data_5;
output reg [word_size - 1 : 0] output_data_6,  output_data_7;



reg [word_size - 1 : 0] buffer_data_mixr [lane_size - 1 : 0];
reg [word_size - 1 : 0] buffer_data_muxr [lane_size - 1 : 0];
reg [word_size - 1 : 0] sorts_data_0, sorts_data_1;
reg [word_size - 1 : 0] sorts_data_2, sorts_data_3;
reg [word_size - 1 : 0] sorts_data_4, sorts_data_5;
reg [word_size - 1 : 0] sorts_data_6, sorts_data_7;
reg [word_size - 1 : 0] buffer_data_0, buffer_data_1;
reg [word_size - 1 : 0] buffer_data_2, buffer_data_3;
reg [word_size - 1 : 0] buffer_data_4, buffer_data_5;
reg [word_size - 1 : 0] buffer_data_6, buffer_data_7;
reg [2 : 0] phase, phase_timer_mixr;
reg [3 : 0] stage, logic_timer_mixr;
reg device_mixr_enable, packet_data_ready, sorter_data_ready;
reg buffer_flag_0, buffer_flag_1;
reg buffer_flag_2, buffer_flag_3;


always @(posedge clk)
begin
  if((~rst)||(result_sort_ready == 1'b1)) begin
    device_mixr_enable <= 1'b0;
  end
  else if(packet_data_ready == 1'b1) begin
    device_mixr_enable <= 1'b1;
  end
  else begin
    device_mixr_enable <= device_mixr_enable;
  end
end


always @(posedge clk)
begin
  if((~rst)||(result_sort_ready == 1'b1)) begin
	phase_timer_mixr <= 3'b000;
  end
  else if(sorter_data_ready == 1'b1) begin
    phase_timer_mixr <= phase_timer_mixr + 1'b1;
  end
  else begin
    phase_timer_mixr <= phase_timer_mixr;
  end
end


always @(posedge clk)
begin
  if((~rst)||(sorter_data_ready == 1'b1)) begin
    logic_timer_mixr <= 4'b0000;
  end
  else if(device_mixr_enable == 1'b1) begin
    logic_timer_mixr <= logic_timer_mixr + 1'b1;
  end
  else begin
    logic_timer_mixr <= logic_timer_mixr;
  end
end


always @(*)
begin
  case(phase_timer_mixr)
    3'b000 : stage = 4'b1010;
    3'b001 : stage = 4'b1100;
    3'b010 : stage = 4'b1100;
	default: stage = 4'b0000;
  endcase
end


always @(*)
begin
  case(phase_timer_mixr)
    3'b001 : phase = 3'b001;
    3'b011 : phase = 3'b010;
    3'b100 : phase = 3'b001;
	default: phase = 3'b000;
  endcase
end


always @(posedge clk)
begin
  if(~rst) begin
    result_sort_ready <= (1'b0);
  end
  else begin
    result_sort_ready <= (phase_timer_mixr == 3'b101)&&(logic_timer_mixr == 4'b0010);
  end
end


always @(*)
begin
  sorter_data_ready = (logic_timer_mixr == 4'b0011)&&(device_mixr_enable == 1'b1);
  packet_data_ready = (packet_sort_ready == 1'b1);
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_data_mixr[0] <= {word_size{1'b0}};
    buffer_data_mixr[1] <= {word_size{1'b0}};
    buffer_data_mixr[2] <= {word_size{1'b0}};
    buffer_data_mixr[3] <= {word_size{1'b0}};
    buffer_data_mixr[4] <= {word_size{1'b0}};
    buffer_data_mixr[5] <= {word_size{1'b0}};
    buffer_data_mixr[6] <= {word_size{1'b0}};
    buffer_data_mixr[7] <= {word_size{1'b0}};
  end
  else if(packet_data_ready == 1'b1) begin
    buffer_data_mixr[0] <= input_data_0;
    buffer_data_mixr[1] <= input_data_1;
    buffer_data_mixr[2] <= input_data_2;
    buffer_data_mixr[3] <= input_data_3;
    buffer_data_mixr[4] <= input_data_4;
    buffer_data_mixr[5] <= input_data_5;
    buffer_data_mixr[6] <= input_data_6;
    buffer_data_mixr[7] <= input_data_7;
  end
  else if(sorter_data_ready == 1'b1) begin
    buffer_data_mixr[0] <= sorts_data_0;
    buffer_data_mixr[1] <= sorts_data_1;
    buffer_data_mixr[2] <= sorts_data_2;
    buffer_data_mixr[3] <= sorts_data_3;
    buffer_data_mixr[4] <= sorts_data_4;
    buffer_data_mixr[5] <= sorts_data_5;
    buffer_data_mixr[6] <= sorts_data_6;
    buffer_data_mixr[7] <= sorts_data_7;
  end
  else begin
    buffer_data_mixr[0] <= buffer_data_mixr[0];
    buffer_data_mixr[1] <= buffer_data_mixr[1];
    buffer_data_mixr[2] <= buffer_data_mixr[2];
    buffer_data_mixr[3] <= buffer_data_mixr[3];
    buffer_data_mixr[4] <= buffer_data_mixr[4];
    buffer_data_mixr[5] <= buffer_data_mixr[5];
    buffer_data_mixr[6] <= buffer_data_mixr[6];
    buffer_data_mixr[7] <= buffer_data_mixr[7];
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_data_muxr[0] <= {word_size{1'b0}};
    buffer_data_muxr[1] <= {word_size{1'b0}};
    buffer_data_muxr[2] <= {word_size{1'b0}};
    buffer_data_muxr[3] <= {word_size{1'b0}};
    buffer_data_muxr[4] <= {word_size{1'b0}};
    buffer_data_muxr[5] <= {word_size{1'b0}};
    buffer_data_muxr[6] <= {word_size{1'b0}};
    buffer_data_muxr[7] <= {word_size{1'b0}};
  end
  else if(phase == 3'b001) begin
    buffer_data_muxr[0] <= {buffer_data_mixr[0]};
    buffer_data_muxr[1] <= {buffer_data_mixr[2]};
    buffer_data_muxr[2] <= {buffer_data_mixr[1]};
    buffer_data_muxr[3] <= {buffer_data_mixr[3]};
    buffer_data_muxr[4] <= {buffer_data_mixr[4]};
    buffer_data_muxr[5] <= {buffer_data_mixr[6]};
    buffer_data_muxr[6] <= {buffer_data_mixr[5]};
    buffer_data_muxr[7] <= {buffer_data_mixr[7]};
  end
  else if(phase == 3'b010) begin
    buffer_data_muxr[0] <= {buffer_data_mixr[0]};
    buffer_data_muxr[1] <= {buffer_data_mixr[4]};
    buffer_data_muxr[2] <= {buffer_data_mixr[1]};
    buffer_data_muxr[3] <= {buffer_data_mixr[5]};
    buffer_data_muxr[4] <= {buffer_data_mixr[2]};
    buffer_data_muxr[5] <= {buffer_data_mixr[6]};
    buffer_data_muxr[6] <= {buffer_data_mixr[3]};
    buffer_data_muxr[7] <= {buffer_data_mixr[7]};
  end
  else begin
    buffer_data_muxr[0] <= {buffer_data_mixr[0]};
    buffer_data_muxr[1] <= {buffer_data_mixr[1]};
    buffer_data_muxr[2] <= {buffer_data_mixr[2]};
    buffer_data_muxr[3] <= {buffer_data_mixr[3]};
    buffer_data_muxr[4] <= {buffer_data_mixr[4]};
    buffer_data_muxr[5] <= {buffer_data_mixr[5]};
    buffer_data_muxr[6] <= {buffer_data_mixr[6]};
    buffer_data_muxr[7] <= {buffer_data_mixr[7]};
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_flag_0 <= (1'b0);
  end
  else begin
    buffer_flag_0 <= (buffer_data_muxr[0] < buffer_data_muxr[1]);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_data_0 <= {word_size{1'b0}};
  end
  else begin
    case(stage[0])
      1'b1  : buffer_data_0 <= (buffer_flag_0 == 1'b1) ? buffer_data_muxr[1] : buffer_data_muxr[0];
      1'b0  : buffer_data_0 <= (buffer_flag_0 == 1'b0) ? buffer_data_muxr[1] : buffer_data_muxr[0];
    endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_data_1 <= {word_size{1'b0}};
  end
  else begin
    case(stage[0])
      1'b1  : buffer_data_1 <= (buffer_flag_0 == 1'b1) ? buffer_data_muxr[0] : buffer_data_muxr[1];
      1'b0  : buffer_data_1 <= (buffer_flag_0 == 1'b0) ? buffer_data_muxr[0] : buffer_data_muxr[1];
    endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_flag_1 <= (1'b0);
  end
  else begin
    buffer_flag_1 <= (buffer_data_muxr[2] < buffer_data_muxr[3]);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_data_2 <= {word_size{1'b0}};
  end
  else begin
    case(stage[1])
      1'b1  : buffer_data_2 <= (buffer_flag_1 == 1'b1) ? buffer_data_muxr[3] : buffer_data_muxr[2];
      1'b0  : buffer_data_2 <= (buffer_flag_1 == 1'b0) ? buffer_data_muxr[3] : buffer_data_muxr[2];
    endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_data_3 <= {word_size{1'b0}};
  end
  else begin
    case(stage[1])
      1'b1  : buffer_data_3 <= (buffer_flag_1 == 1'b1) ? buffer_data_muxr[2] : buffer_data_muxr[3];
      1'b0  : buffer_data_3 <= (buffer_flag_1 == 1'b0) ? buffer_data_muxr[2] : buffer_data_muxr[3];
    endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_flag_2 <= (1'b0);
  end
  else begin
    buffer_flag_2 <= (buffer_data_muxr[4] < buffer_data_muxr[5]);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_data_4 <= {word_size{1'b0}};
  end
  else begin
    case(stage[2])
      1'b1  : buffer_data_4 <= (buffer_flag_2 == 1'b1) ? buffer_data_muxr[5] : buffer_data_muxr[4];
      1'b0  : buffer_data_4 <= (buffer_flag_2 == 1'b0) ? buffer_data_muxr[5] : buffer_data_muxr[4];
    endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_data_5 <= {word_size{1'b0}};
  end
  else begin
    case(stage[2])
      1'b1  : buffer_data_5 <= (buffer_flag_2 == 1'b1) ? buffer_data_muxr[4] : buffer_data_muxr[5];
      1'b0  : buffer_data_5 <= (buffer_flag_2 == 1'b0) ? buffer_data_muxr[4] : buffer_data_muxr[5];
    endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_flag_3 <= (1'b0);
  end
  else begin
    buffer_flag_3 <= (buffer_data_muxr[6] < buffer_data_muxr[7]);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_data_6 <= {word_size{1'b0}};
  end
  else begin
    case(stage[3])
      1'b1  : buffer_data_6 <= (buffer_flag_3 == 1'b1) ? buffer_data_muxr[7] : buffer_data_muxr[6];
      1'b0  : buffer_data_6 <= (buffer_flag_3 == 1'b0) ? buffer_data_muxr[7] : buffer_data_muxr[6];
    endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_data_7 <= {word_size{1'b0}};
  end
  else begin
    case(stage[3])
      1'b1  : buffer_data_7 <= (buffer_flag_3 == 1'b1) ? buffer_data_muxr[6] : buffer_data_muxr[7];
      1'b0  : buffer_data_7 <= (buffer_flag_3 == 1'b0) ? buffer_data_muxr[6] : buffer_data_muxr[7];
    endcase
  end
end


always @(*)
begin
  case(phase)
    3'b001: begin
              sorts_data_0 = buffer_data_0;
              sorts_data_1 = buffer_data_2;
              sorts_data_2 = buffer_data_1;
              sorts_data_3 = buffer_data_3;
              sorts_data_4 = buffer_data_4;
              sorts_data_5 = buffer_data_6;
              sorts_data_6 = buffer_data_5;
              sorts_data_7 = buffer_data_7;
	        end
    3'b010: begin
              sorts_data_0 = buffer_data_0;
              sorts_data_1 = buffer_data_2;
              sorts_data_2 = buffer_data_4;
              sorts_data_3 = buffer_data_6;
              sorts_data_4 = buffer_data_1;
              sorts_data_5 = buffer_data_3;
              sorts_data_6 = buffer_data_5;
              sorts_data_7 = buffer_data_7;
	        end
	default:begin
              sorts_data_0 = buffer_data_0;
              sorts_data_1 = buffer_data_1;
              sorts_data_2 = buffer_data_2;
              sorts_data_3 = buffer_data_3;
              sorts_data_4 = buffer_data_4;
              sorts_data_5 = buffer_data_5;
              sorts_data_6 = buffer_data_6;
              sorts_data_7 = buffer_data_7;
	        end
  endcase
end


always @(*)
begin
  output_data_0 = buffer_data_mixr[0];
  output_data_1 = buffer_data_mixr[1];
  output_data_2 = buffer_data_mixr[2];
  output_data_3 = buffer_data_mixr[3];
  output_data_4 = buffer_data_mixr[4];
  output_data_5 = buffer_data_mixr[5];
  output_data_6 = buffer_data_mixr[6];
  output_data_7 = buffer_data_mixr[7];
end


endmodule


/** logic unit used to control the pipeline in sparse pooling **/
// `include "../param.vh"

module pipe_ctrl( clk, rst,
                  process_enable_pipe,
				  bound_pass_lane,
				  process_done_scan,
                  buffer_send_full,
                  value_sorted_0,
                  value_sorted_1,
                  value_sorted_2,
                  value_sorted_3,
                  value_sorted_4,
                  value_sorted_5,
                  value_sorted_6,
                  value_sorted_7,
                  index_sorted_0,
                  index_sorted_1,
                  index_sorted_2,
                  index_sorted_3,
                  index_sorted_4,
                  index_sorted_5,
                  index_sorted_6,
                  index_sorted_7,
                  packet_proc_done,
				  /** output signal **/
                  packet_enable_send,
                  packet_data_send,
                  packet_inst_send,
				  process_done_pipe,
				  process_enable_scan
                );

parameter lane_size = `lane_size_para,
	  word_size = `word_size_para,
          inst_sort = 8'h01;


input wire clk, rst;
input wire process_enable_pipe;
input wire packet_proc_done;
input wire buffer_send_full; /** fifo in sender is full **/
input wire [lane_size - 1 : 0] process_done_scan;
input wire [lane_size - 1 : 0] bound_pass_lane;
input wire [word_size - 1 : 0] value_sorted_0, value_sorted_1;
input wire [word_size - 1 : 0] value_sorted_2, value_sorted_3;
input wire [word_size - 1 : 0] value_sorted_4, value_sorted_5;
input wire [word_size - 1 : 0] value_sorted_6, value_sorted_7;
input wire [word_size - 1 : 0] index_sorted_0, index_sorted_1;
input wire [word_size - 1 : 0] index_sorted_2, index_sorted_3;
input wire [word_size - 1 : 0] index_sorted_4, index_sorted_5;
input wire [word_size - 1 : 0] index_sorted_6, index_sorted_7;


output reg packet_enable_send;
output reg process_done_pipe;
output reg [word_size - 1 : 0] packet_data_send;
output reg [word_size - 1 : 0] packet_inst_send;
output reg [lane_size - 1 : 0] process_enable_scan;


reg process_enable_inht, process_done_inht;
reg inht_occupied_line;
reg [lane_size - 1 : 0] pipeline_enable_scan;
reg [lane_size - 1 : 0] scan_occupied_done;
reg [lane_size - 1 : 0] scan_occupied_line;
reg [2 : 0] state_inht, next_state_inht;
reg [2 : 0] index_buffer;
reg packet_copy_done, packet_send_done, packet_inst_done;
reg [word_size - 1 : 0] buffer_data_index [lane_size - 1 : 0];
reg [word_size - 1 : 0] buffer_data_value [lane_size - 1 : 0];
reg buffer_index_count;
reg [lane_size - 1 : 0] process_buffer_scan;
reg last_round_inht;
reg [lane_size - 1 : 0] last_round_scan;


always @(posedge clk)
begin
  if(~rst) begin
    process_done_pipe <= 1'b0;
  end
  else begin
    process_done_pipe <= (process_done_inht == 1'b1)&&(last_round_inht == 1'b1);
  end
end


always @(posedge clk)
begin /** set to 1, if it is last round of inht triggered **/
  if((~rst)||(process_done_pipe == 1'b1)) begin
    last_round_inht <= 1'b0;
  end
  else if((last_round_scan == {lane_size{1'b1}})&&(process_enable_inht == 1'b1)) begin
    last_round_inht <= 1'b1;
  end
  else begin
    last_round_inht <= last_round_inht;
  end
end


genvar index_lane;


generate

   for(index_lane = 0 ; index_lane < lane_size ; index_lane = index_lane + 1)
   begin: lane_ctrl


      always @(posedge clk)
      begin
        if((~rst)||(process_done_pipe == 1'b1)) begin
           last_round_scan[index_lane] <= 1'b0;
        end
        else if((bound_pass_lane[index_lane] == 1'b1)&&(process_done_scan[index_lane] == 1'b1)) begin
           last_round_scan[index_lane] <= 1'b1;
        end
        else begin
           last_round_scan[index_lane] <= last_round_scan[index_lane];
        end
      end


      always @(posedge clk)
      begin
	    if(~rst) begin
		  process_enable_scan[index_lane] <= 1'b0;
		end
	    else begin
		  process_enable_scan[index_lane] <= (process_enable_pipe == 1'b1)||(pipeline_enable_scan[index_lane] == 1'b1);
	    end
	  end


      always @(*)
      begin
	    if((process_buffer_scan[index_lane] == 1'b1)&&(inht_occupied_line == 1'b0)&&(last_round_scan[index_lane] == 1'b0)) begin
		  pipeline_enable_scan[index_lane] = 1'b1;
	    end
	    else begin
		  pipeline_enable_scan[index_lane] = 1'b0;
	    end
      end


      always @(posedge clk)
      begin
	    if((~rst)||(scan_occupied_done[index_lane] == 1'b1)) begin
		  process_buffer_scan[index_lane] <= 1'b0;
	    end
	    else if(process_done_scan[index_lane] == 1'b1) begin
		  process_buffer_scan[index_lane] <= 1'b1;
	    end
	    else begin
		  process_buffer_scan[index_lane] <= process_buffer_scan[index_lane];
	    end
      end


      always @(*)
      begin
	    if((process_buffer_scan[index_lane] == 1'b1)&&(inht_occupied_line == 1'b0)) begin
		  scan_occupied_done[index_lane] = 1'b1;
	    end
	    else begin
		  scan_occupied_done[index_lane] = 1'b0;
	    end
      end


      always @(posedge clk)
      begin
	    if((~rst)||(scan_occupied_done[index_lane] == 1'b1)) begin
		  scan_occupied_line[index_lane] <= 1'b0;
	    end
	    else if(process_enable_scan[index_lane] == 1'b1) begin
		  scan_occupied_line[index_lane] <= 1'b1;
	    end
	    else begin
		  scan_occupied_line[index_lane] <= scan_occupied_line[index_lane];
	    end
      end

   end

endgenerate


/** The control logic used for the inht **/


always @(posedge clk)
begin
  if(~rst) begin
    process_enable_inht <= 1'b0;
  end
  else begin
    process_enable_inht <= (process_buffer_scan == {lane_size{1'b1}})&&(inht_occupied_line == 1'b0);
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_done_inht == 1'b1)) begin
    inht_occupied_line <= 1'b0;
  end
  else if(process_enable_inht == 1'b1) begin
    inht_occupied_line <= 1'b1;
  end
  else begin
    inht_occupied_line <= inht_occupied_line;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    state_inht <= 3'b000;
  end
  else begin
    state_inht <= next_state_inht;
  end
end


always @(*)
begin
  case(state_inht)
    3'b000 : begin
	           if(process_enable_inht == 1'b1) begin
			     next_state_inht = 3'b001;
			   end
    		   else begin
                 next_state_inht = 3'b000;
               end
             end
    3'b001 : begin /** Copy previous data and send instruction packet **/
               if(packet_copy_done == 1'b1) begin
                 next_state_inht = 3'b010;
               end
               else begin
                 next_state_inht = 3'b001;
               end
             end
    3'b010 : begin /** Send the instruction into the processor **/
               if(packet_inst_done == 1'b1) begin
                 next_state_inht = 3'b011;
               end
               else begin
                 next_state_inht = 3'b010;
               end
             end
    3'b011 : begin /** Send the overlap value into processor **/
	           if(packet_proc_done == 1'b1) begin
			     next_state_inht = 3'b000;
			   end
    		   else begin
                 next_state_inht = buffer_send_full ? 3'b011 : 3'b100;
               end
             end
    3'b100 : begin /** Send the index information into processor **/
	           if(packet_proc_done == 1'b1) begin
			     next_state_inht = 3'b000;
			   end
    		   else begin
                 next_state_inht = buffer_send_full ? 3'b100 : 3'b011;
               end
             end
    default: begin
	           next_state_inht = 3'b000;
			 end
  endcase
end


always @(posedge clk)
begin
  if(~rst) begin
    process_done_inht <= 1'b0;
  end
  else begin
    process_done_inht <= (next_state_inht == 3'b000)&&(state_inht != 3'b000);
  end
end


/** state_inht == 3'b001, copy the data from the previous phase **/


always @(*)
begin
  packet_copy_done = (state_inht == 3'b001);
  packet_inst_done = (state_inht == 3'b010);
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_data_value[0] <= {word_size{1'b0}};
    buffer_data_value[1] <= {word_size{1'b0}};
    buffer_data_value[2] <= {word_size{1'b0}};
    buffer_data_value[3] <= {word_size{1'b0}};
    buffer_data_value[4] <= {word_size{1'b0}};
    buffer_data_value[5] <= {word_size{1'b0}};
    buffer_data_value[6] <= {word_size{1'b0}};
    buffer_data_value[7] <= {word_size{1'b0}};
  end
  else if(packet_copy_done == 1'b1) begin
    buffer_data_value[0] <= value_sorted_0;
    buffer_data_value[1] <= value_sorted_1;
    buffer_data_value[2] <= value_sorted_2;
    buffer_data_value[3] <= value_sorted_3;
    buffer_data_value[4] <= value_sorted_4;
    buffer_data_value[5] <= value_sorted_5;
    buffer_data_value[6] <= value_sorted_6;
    buffer_data_value[7] <= value_sorted_7;
  end
  else begin
    buffer_data_value[0] <= buffer_data_value[0];
    buffer_data_value[1] <= buffer_data_value[1];
    buffer_data_value[2] <= buffer_data_value[2];
    buffer_data_value[3] <= buffer_data_value[3];
    buffer_data_value[4] <= buffer_data_value[4];
    buffer_data_value[5] <= buffer_data_value[5];
    buffer_data_value[6] <= buffer_data_value[6];
    buffer_data_value[7] <= buffer_data_value[7];
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_data_index[0] <= {word_size{1'b0}};
    buffer_data_index[1] <= {word_size{1'b0}};
    buffer_data_index[2] <= {word_size{1'b0}};
    buffer_data_index[3] <= {word_size{1'b0}};
    buffer_data_index[4] <= {word_size{1'b0}};
    buffer_data_index[5] <= {word_size{1'b0}};
    buffer_data_index[6] <= {word_size{1'b0}};
    buffer_data_index[7] <= {word_size{1'b0}};
  end
  else if(packet_copy_done == 1'b1) begin
    buffer_data_index[0] <= index_sorted_0;
    buffer_data_index[1] <= index_sorted_1;
    buffer_data_index[2] <= index_sorted_2;
    buffer_data_index[3] <= index_sorted_3;
    buffer_data_index[4] <= index_sorted_4;
    buffer_data_index[5] <= index_sorted_5;
    buffer_data_index[6] <= index_sorted_6;
    buffer_data_index[7] <= index_sorted_7;
  end
  else begin
    buffer_data_index[0] <= buffer_data_index[0];
    buffer_data_index[1] <= buffer_data_index[1];
    buffer_data_index[2] <= buffer_data_index[2];
    buffer_data_index[3] <= buffer_data_index[3];
    buffer_data_index[4] <= buffer_data_index[4];
    buffer_data_index[5] <= buffer_data_index[5];
    buffer_data_index[6] <= buffer_data_index[6];
    buffer_data_index[7] <= buffer_data_index[7];
  end
end


/** state_inht == 3'b010, wait for the send of inst packet send **/


always @(posedge clk)
begin
  if(~rst) begin
    packet_enable_send <= 1'b0;
  end
  else begin
    packet_enable_send <= (next_state_inht == 3'b010)||(next_state_inht == 3'b011)||(next_state_inht == 3'b100);
  end
end


/** state_inht == 3'b011, send the overlap value into processor **/
/** state_inht == 3'b100, send the index into processor **/


always @(*)
begin
  if((buffer_send_full == 1'b0)&&(next_state_inht == 3'b100)&&(packet_send_done == 1'b0)) begin
    buffer_index_count = 1'b1;
  end
  else begin
    buffer_index_count = 1'b0;
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_enable_inht == 1'b1)) begin
    index_buffer <= 3'b000;
  end
  else if(buffer_index_count == 1'b1) begin
    index_buffer <= index_buffer + 1'b1;
  end
  else begin
    index_buffer <= index_buffer;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    packet_inst_send <= {word_size{1'b0}};
  end
  else begin
    packet_inst_send <= {16'h0000, inst_sort, 6'b000000, 1'b1, last_round_inht}; /**indicate if last round of columns **/
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    packet_data_send <= {word_size{1'b0}};
  end
  else begin
    case(next_state_inht)
      3'b011 : packet_data_send <= packet_send_done ? {word_size{1'b0}} : {buffer_data_value[index_buffer]};
	  3'b100 : packet_data_send <= packet_send_done ? {word_size{1'b0}} : {buffer_data_index[index_buffer]};
	  default: packet_data_send <= {word_size{1'b0}};
    endcase
  end
end


always @(posedge clk)
begin /** tell processor all data are send **/
  if((~rst)||(process_enable_inht == 1'b1)) begin
    packet_send_done <= 1'b0;
  end
  else if((index_buffer == (lane_size - 1))&&(buffer_index_count == 1'b1)) begin
    packet_send_done <= 1'b1;
  end
  else begin
    packet_send_done <= packet_send_done;
  end
end


endmodule


/** This module is used to compute the predict state of each block in the element **/
// `include "../param.vh"

module pred_ctrl ( clk, rst,
                   process_enable_pred,
                   memory_addr_init_prt,
                   buffer_data_fifo,
                   memory_data_ready,
                   process_done_find,
				   buffer_counter_find_0,
				   buffer_counter_find_1,
				   buffer_counter_find_2,
				   buffer_counter_find_3,
				   buffer_counter_find_4,
				   buffer_counter_find_5,
				   buffer_counter_find_6,
				   buffer_counter_find_7,
                   process_learn_enable,
                   /** Output Signal **/
                   process_enable_find,
                   process_done_pred,
				   memory_addr_lemt,
                   memory_wt_data,
                   memory_rd_enable,
                   memory_wt_enable,
                   buffer_read_fifo,
				   packet_enable_send,
				   packet_inst_send,
				   packet_data_send,
                   memory_addr_buffered,
                   memory_addr_load_rcvd
                 );


parameter  word_size = `word_size_para,
           addr_size = `addr_size_lemt,
           lane_size = `lane_size_para,
	   addr_lane = `addr_size_para,
           block_per_element = `block_per_element_para,
           mem_inter_seg = `segment_per_cell_para * `synapse_per_lane_para;

parameter  active_threshold = `predict_threshold_para,
           memory_packet_count = `memory_size_packet, /** total packet count in proc memory(includ received from other cores) **/
           memory_addr_init_blk = `memory_addr_init_blk_para;

input wire clk, rst;
input wire process_enable_pred, process_learn_enable, memory_data_ready;
input wire [addr_size - 1 : 0] memory_addr_init_prt;
input wire [word_size - 1 : 0] buffer_data_fifo;
input wire [lane_size - 1 : 0] process_done_find;
input wire [23 : 0] buffer_counter_find_0, buffer_counter_find_1;
input wire [23 : 0] buffer_counter_find_2, buffer_counter_find_3;
input wire [23 : 0] buffer_counter_find_4, buffer_counter_find_5;
input wire [23 : 0] buffer_counter_find_6, buffer_counter_find_7;


output reg process_done_pred, buffer_read_fifo;
output reg memory_addr_load_rcvd;
output reg [addr_size - 1 : 0] memory_addr_lemt;
output reg [word_size - 1 : 0] memory_wt_data;
output reg memory_rd_enable, memory_wt_enable;
output reg [addr_lane - 1 : 0] memory_addr_buffered;
output reg [lane_size - 1 : 0] process_enable_find;
output reg packet_enable_send;
output reg [word_size - 1 : 0] packet_inst_send;
output reg [word_size - 1 : 0] packet_data_send;



reg [word_size - 1 : 0] buffer_counter_act [lane_size - 1 : 0];
reg [word_size - 1 : 0] buffer_data_dirty;
reg [addr_size - 1 : 0] memory_addr_init, memory_addr_offt;
reg [addr_size - 1 : 0] memory_addr_read_blk;
reg [addr_size - 1 : 0] memory_addr_wten_blk;
reg [addr_size - 1 : 0] memory_addr_offt_prt;
reg [lane_size - 1 : 0] lanes_find_flag;
reg [3 : 0] segment_count_loop;
reg [3 : 0] segment_count_blks;
reg [3 : 0] index_dirty_pred, index_buffer_find;
reg [2 : 0] state_pred, next_state_pred;
reg [7 : 0] buffer_data_count;
reg dirty_block_find, block_loop_done;
reg segment_loop_done;
reg lanes_find_done, lanes_loop_done;
reg predict_cell_find;
reg memory_read_update, memory_wten_update, memory_buff_update;
reg buffer_counter_reset;
reg [3 : 0] index_dirty_block;
reg dirty_block_done, index_loop_done;
reg dirty_last_block, dirty_last_rset;
reg memory_read_done;
reg process_done_flag; /** indicate the image process is done **/


genvar index;


always @(*)
begin
  buffer_counter_act[0] = buffer_counter_find_0[23 : 16];
  buffer_counter_act[1] = buffer_counter_find_1[23 : 16];
  buffer_counter_act[2] = buffer_counter_find_2[23 : 16];
  buffer_counter_act[3] = buffer_counter_find_3[23 : 16];
  buffer_counter_act[4] = buffer_counter_find_4[23 : 16];
  buffer_counter_act[5] = buffer_counter_find_5[23 : 16];
  buffer_counter_act[6] = buffer_counter_find_6[23 : 16];
  buffer_counter_act[7] = buffer_counter_find_7[23 : 16];
end


always @(posedge clk)
begin
  if(~rst) begin
    state_pred <= 3'b000;
  end
  else begin
    state_pred <= next_state_pred;
  end
end


always @(*)
begin
  case(state_pred)
    3'b000 : begin
	           if(process_enable_pred == 1'b1) begin
			     next_state_pred = 3'b001;
			   end
			   else begin
			     next_state_pred = 3'b000;
			   end
             end
    3'b001 : begin /** Read block info into fifo buffer to avoid memory latency **/
			   if(memory_data_ready == 1'b1) begin
				 next_state_pred = 3'b010;
			   end
			   else begin
				 next_state_pred = 3'b001;
			   end
             end
    3'b010 : begin /** Check the segment count if any dirty block is found **/
	           if(block_loop_done == 1'b1) begin
			     next_state_pred = 3'b111;
			   end
			   else begin
			     next_state_pred = dirty_block_find ? 3'b011 : 3'b010;
			   end
             end
    3'b011 : begin /** Trigger find logic to loop synapse in one segment **/
	           if(lanes_find_done == 1'b1) begin
			     next_state_pred = 3'b100;
			   end
			   else begin
			     next_state_pred = 3'b011;
			   end
             end
    3'b100 : begin /** Decide the predict state of current dirty cell **/
	           if(lanes_loop_done == 1'b1) begin
			     next_state_pred = 3'b101;
			   end
			   else begin
			     next_state_pred = 3'b100;
			   end
             end
	3'b101 : begin  /** Update the cell state based on the matching result **/
			   next_state_pred = 3'b110;
             end
	3'b110 : begin  /** If predict cell is found, then update target segment **/
               if(predict_cell_find == 1'b1) begin
			     next_state_pred = 3'b010;
			   end
			   else begin
	             next_state_pred = segment_loop_done ? 3'b010 : 3'b011;
	           end
             end
    3'b111 : begin  /** Indicate the processor that the pred process is done here **/
			   next_state_pred = 3'b000;
             end
    default: begin
               next_state_pred = 3'b000;
             end
  endcase
end


always @(posedge clk)
begin
  if(~rst) begin
    process_done_pred <= 1'b0;
  end
  else begin
    process_done_pred <= (state_pred != 3'b000)&&(next_state_pred == 3'b000);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_read_fifo <= 1'b0;
  end
  else begin
    buffer_read_fifo <= (next_state_pred == 3'b010);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_lemt <= {addr_size{1'b0}};
  end
  else begin
    memory_addr_lemt <= {memory_addr_init + memory_addr_offt};
  end
end


/** state_pred == 3'b001, read block info into fifo buffer to avoid memory latency **/



always @(posedge clk)
begin
  if(~rst) begin
    memory_rd_enable <= 1'b0;
  end
  else begin
    case(state_pred)
      3'b001 : memory_rd_enable <= (1'b1);
      3'b010 : memory_rd_enable <= (1'b1);
      3'b011 : memory_rd_enable <= (memory_read_done == 1'b1);
      default: memory_rd_enable <= (1'b0);
    endcase
  end
end


always @(*)
begin
  case(state_pred)
    3'b001 : memory_addr_init = {memory_addr_init_blk}; /** The initial address of active columns at t **/
	3'b010 : memory_addr_init = {memory_addr_init_blk}; /** The initial address blocks belong to active column **/
	3'b011 : memory_addr_init = {memory_addr_init_prt};
	3'b110 : memory_addr_init = {memory_addr_init_blk};
	default: memory_addr_init = {addr_size{1'b0}};
  endcase
end


always @(*)
begin
  case(state_pred)
    3'b001 : memory_addr_offt = {memory_addr_read_blk}; /** The initial address of active columns at t **/
	3'b010 : memory_addr_offt = {memory_addr_read_blk};
	3'b011 : memory_addr_offt = {memory_addr_offt_prt}; /** The initial address blocks belong to active column **/
	3'b110 : memory_addr_offt = {memory_addr_wten_blk};
    default: memory_addr_offt = {addr_size{1'b0}};
  endcase
end


always @(*)
begin
  case(state_pred)
    3'b001 : memory_read_update = 1'b1;
    3'b010 : memory_read_update = 1'b1;
    default: memory_read_update = 1'b0;
  endcase
end


always @(posedge clk)
begin
  if((~rst)||(process_done_pred == 1'b1)) begin
    memory_addr_read_blk <= {addr_size{1'b0}};
  end
  else if(memory_read_update == 1'b1) begin
    memory_addr_read_blk <= memory_addr_read_blk + 1'b1;
  end
  else begin
    memory_addr_read_blk <= memory_addr_read_blk;
  end
end


/** state_pred == 3'b010, check if any dirty block is found in this column **/


always @(*)
begin
  segment_count_blks = buffer_data_fifo[word_size - 09 : word_size - 12];
  block_loop_done = (buffer_data_fifo == {word_size{1'b1}});
  dirty_block_find = (segment_count_blks != 4'b0000)&&(state_pred == 3'b010)&&(dirty_block_done == 1'b0);
end


always @(posedge clk)
begin
  if((~rst)||(index_loop_done == 1'b1)) begin
    index_dirty_block <= 4'b0000;
  end
  else if(state_pred == 3'b010) begin
    index_dirty_block <= index_dirty_block + 1'b1;
  end
  else begin
    index_dirty_block <= index_dirty_block;
  end
end


always @(posedge clk)
begin /** set to 1 if the last block of current column need to be check **/
  if((~rst)||(dirty_last_rset == 1'b1)) begin
    dirty_last_block <= 1'b0;
  end
  else if((index_loop_done == 1'b1)&&(segment_count_blks != 4'b0000))begin
    dirty_last_block <= 1'b1;
  end
  else begin
    dirty_last_block <= dirty_last_block;
  end
end


always @(posedge clk)
begin /** If predict cell is found, the rest blocks of current column doesn't need to check **/
  if((~rst)||(index_loop_done == 1'b1)) begin
    dirty_block_done <= 1'b0;
  end
  else if((state_pred == 3'b110)&&(predict_cell_find == 1'b1)&&(dirty_last_block == 1'b0)) begin /** if last block is predict, no need to set flag **/
    dirty_block_done <= 1'b1;
  end
  else begin
    dirty_block_done <= dirty_block_done;
  end
end


always @(*)
begin
  dirty_last_rset = (state_pred == 3'b110)&&(next_state_pred != 3'b110);
  index_loop_done = (index_dirty_block == (block_per_element - 1))&&(state_pred == 3'b010);
end



always @(posedge clk)
begin /** used to store dirty block from fifo **/
  if(~rst) begin
    buffer_data_dirty <= {word_size{1'b0}};
  end
  else if(dirty_block_find == 1'b1) begin
    buffer_data_dirty <= buffer_data_fifo;
  end
  else begin
    buffer_data_dirty <= buffer_data_dirty;
  end
end


always @(posedge clk)
begin /** Block address store offset of the corresponding synapse info **/
  if((~rst)||(process_done_pred == 1'b1)) begin
    memory_addr_buffered <= {addr_lane{1'b0}};
  end
  else if(memory_buff_update == 1'b1) begin
    memory_addr_buffered <= memory_addr_buffered + mem_inter_seg;
  end
  else begin
    memory_addr_buffered <= memory_addr_buffered;
  end
end


always @(*)
begin
  case(state_pred)
    3'b010 : memory_buff_update = (dirty_block_find == 1'b0);
    3'b110 : memory_buff_update = (1'b1);
    default: memory_buff_update = (1'b0);
  endcase
end


always @(*)
begin /** Load the lane address only once for each block **/
  if((state_pred == 3'b010)&&(dirty_block_find == 1'b1)) begin
    memory_addr_load_rcvd = 1'b1;
  end
  else begin
    memory_addr_load_rcvd = 1'b0;
  end
end


/** state_pred == 3'b011, trigger find logic to loop synapse in one segment **/


always @(posedge clk)
begin
  if(~rst) begin
    process_enable_find <= {lane_size{1'b0}};
  end
  else begin
    process_enable_find <= {lane_size{(state_pred != 3'b011)&&(next_state_pred == 3'b011)}};
  end
end


always @(posedge clk)
begin
  if((~rst)||(lanes_find_done == 1'b1)) begin
    memory_addr_offt_prt <= {addr_size{1'b0}};
  end
  else if(state_pred == 3'b011) begin
    memory_addr_offt_prt <= memory_addr_offt_prt + 1'b1;
  end
  else begin
    memory_addr_offt_prt <= memory_addr_offt_prt;
  end
end


always @(*)
begin
  lanes_find_done = (lanes_find_flag == {lane_size{1'b1}});
end


generate

   for(index = 0; index < lane_size; index = index + 1)
   begin: flags

	  always @(posedge clk)
	  begin
	    if((~rst)||(lanes_find_done == 1'b1)) begin
		  lanes_find_flag[index] <= 1'b0;
		end
		else if(process_done_find[index] == 1'b1) begin
		  lanes_find_flag[index] <= 1'b1;
		end
		else begin
		  lanes_find_flag[index] <= lanes_find_flag[index];
        end
      end

   end

endgenerate


always @(*)
begin
  memory_read_done = (memory_addr_offt_prt < memory_packet_count);
end

/** state_pred == 3'b100, decide the predict state of current dirty cell **/


always @(*)
begin
  buffer_counter_reset = (state_pred == 3'b110);
end


always @(posedge clk)
begin /** active synapse **/
  if((~rst)||(buffer_counter_reset == 1'b1)) begin
    buffer_data_count <= 8'b00000000;
  end
  else if(state_pred == 3'b100) begin
    buffer_data_count <= buffer_data_count + buffer_counter_act[index_buffer_find];
  end
  else begin
    buffer_data_count <= buffer_data_count;
  end
end


always @(posedge clk)
begin
  if((~rst)||(buffer_counter_reset == 1'b1)) begin
    index_buffer_find <= 3'b000;
  end
  else if(state_pred == 3'b100) begin
    index_buffer_find <= index_buffer_find + 1'b1;
  end
  else begin
    index_buffer_find <= index_buffer_find;
  end
end


always @(*)
begin
  if((index_buffer_find == (lane_size - 1))&&(state_pred == 3'b100)) begin
    lanes_loop_done = 1'b1;
  end
  else begin
    lanes_loop_done = 1'b0;
  end
end


/** state_pred == 3'b101, check if predict cell is found, then update target segment **/


always @(*)
begin
  segment_loop_done = (segment_count_loop == buffer_data_dirty[word_size - 09 : word_size - 12])&&(state_pred == 3'b110);
end


always @(posedge clk)
begin
  if((~rst)||(segment_loop_done == 1'b1)) begin
    segment_count_loop <= 4'b0000;
  end
  else if(state_pred == 3'b101) begin
    segment_count_loop <= segment_count_loop + 1'b1;
  end
  else begin
    segment_count_loop <= segment_count_loop;
  end
end


always @(*)
begin
  case(state_pred)
    3'b101 : predict_cell_find = (buffer_data_count >= active_threshold);
    3'b110 : predict_cell_find = (buffer_data_count >= active_threshold);
    default: predict_cell_find = (1'b0);
  endcase
end


/** state_pred == 3'b110, update the block state in element sram and trigger for synapse **/


always @(posedge clk)
begin /** index of segment which has been update for prediction **/
  if((~rst)||(dirty_block_find == 1'b1)) begin
    index_dirty_pred <= 4'b0000;
  end
  else if(state_pred == 3'b110) begin
    index_dirty_pred <= index_dirty_pred + 1'b1;
  end
  else begin
    index_dirty_pred <= index_dirty_pred;
  end
end


always @(*)
begin
  case(state_pred)
    3'b010 : memory_wten_update = (next_state_pred == 3'b010);
    3'b110 : memory_wten_update = (next_state_pred == 3'b010);
    default: memory_wten_update = 1'b0;
  endcase
end


always @(posedge clk)
begin
  if((~rst)||(process_done_pred == 1'b1)) begin
    memory_addr_wten_blk <= {addr_size{1'b0}};
  end
  else if(memory_wten_update == 1'b1) begin
    memory_addr_wten_blk <= memory_addr_wten_blk + 1'b1;
  end
  else begin
    memory_addr_wten_blk <= memory_addr_wten_blk;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_wt_enable <= 1'b0;
  end
  else begin
    case(state_pred)
      3'b110 : memory_wt_enable <= (next_state_pred == 3'b010);
      default: memory_wt_enable <= (1'b0);
    endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_wt_data <= {word_size{1'b0}};
  end
  else begin
    case(state_pred)
	  3'b110 : memory_wt_data <= {buffer_data_dirty[word_size - 01 : word_size - 12], predict_cell_find,
	                              buffer_data_dirty[word_size - 13], buffer_data_dirty[word_size - 15],
	                              buffer_data_dirty[word_size - 16], index_dirty_pred, 12'h000};
	  default: memory_wt_data <= {word_size{1'b0}};
	endcase
  end
end


/** state_pred == 3'b111, indicate the processor that the pred process is done here  **/


always @(posedge clk)
begin
  if(~rst) begin
    packet_enable_send <= 1'b0;
  end
  else begin
    packet_enable_send <= (next_state_pred == 3'b111);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    packet_inst_send <= {word_size{1'b0}};
  end
  else begin
    packet_inst_send <= {3'b000, process_done_flag, 12'h000, 16'h0801};
  end
end


always @(*)
begin
  process_done_flag = (process_learn_enable == 1'b0);
end

always @(posedge clk)
begin
  if(~rst) begin
    packet_data_send <= {word_size{1'b0}};
  end
  else begin
    packet_data_send <= {packet_data_send};
  end
end


endmodule


// `include "../param.vh"

module rcvd_lemt ( clk, rst,
                   packet_ready_rcvd,
				   packet_data_elmt,
				   buffer_read_port,
                   buffer_rcvd_reset,
				   /*** Output Signal ***/
                   packet_inst_rcvd,
				   packet_data_rcvd,
				   packet_grant_rcvd
				 );

parameter  word_size = `word_size_para,
           buff_size = `buff_size_port;


input wire clk, rst;
input wire [word_size - 1 : 0] packet_data_elmt;
input wire packet_ready_rcvd;  /** The package is coming into buffer **/
input wire buffer_rcvd_reset;
input wire [3 : 0] buffer_read_port;


output reg packet_grant_rcvd;  /** The receiver is able to receiver **/
output reg [word_size - 1 : 0] packet_inst_rcvd;
output reg [word_size - 1 : 0] packet_data_rcvd;


reg [word_size - 1 : 0] buffer_data_rcvd [buff_size - 1 : 0];
reg header_ready_read, packet_ready_mask;
reg buffer_full_init, buffer_full_loop;
reg buffer_done_init, buffer_done_loop;
reg buffer_rd_enable, buffer_wt_enable;
reg buffer_inst_reset;
reg [2 : 0] buffer_rd_index, buffer_wt_index;
reg [2 : 0] buffer_data_count;
reg index_read_reset, index_wten_reset;


integer index;


/** For each transaction, the first package is always the instruction **/


always @(posedge clk)
begin
  if(~rst) begin
    packet_ready_mask <= 1'b0;
  end
  else begin
    packet_ready_mask <= packet_ready_rcvd;
  end
end


always @(*)
begin /** the instruction is ready to read **/
  if((packet_ready_mask == 1'b0)&&(packet_ready_rcvd == 1'b1)) begin
    header_ready_read = 1'b1;
  end
  else begin
    header_ready_read = 1'b0;
  end
end


always @(*)
begin
  if((packet_ready_mask == 1'b1)&&(packet_ready_rcvd == 1'b0)) begin
    buffer_inst_reset = 1'b1;
  end
  else begin
    buffer_inst_reset = 1'b0;
  end
end


always @(posedge clk)
begin
  if((~rst)||(buffer_inst_reset == 1'b1)) begin
    packet_inst_rcvd <= {word_size{1'b0}};
  end
  else if(header_ready_read == 1'b1) begin
    packet_inst_rcvd <= packet_data_elmt;
  end
  else begin
    packet_inst_rcvd <= packet_inst_rcvd;
  end
end


/** Write the received package into the receiver buffer except the instruction **/


always @(*)
begin
  if((packet_ready_rcvd == 1'b1)&&(header_ready_read == 1'b0)&&(packet_grant_rcvd == 1'b1)) begin
    buffer_wt_enable = 1'b1;
  end
  else begin
    buffer_wt_enable = 1'b0;
  end
end


always @(posedge clk)
begin
  if((~rst)||(buffer_rcvd_reset == 1'b1)) begin
    for(index = 0; index < buff_size; index = index + 1)
      buffer_data_rcvd[index] <= {word_size{1'b0}};
  end
  else if(buffer_wt_enable == 1'b1) begin
    buffer_data_rcvd[buffer_wt_index] <= packet_data_elmt;
  end
  else begin
    for(index = 0; index < buff_size; index = index + 1)
      buffer_data_rcvd[index] <= buffer_data_rcvd[index];
  end
end


always @(posedge clk)
begin
  if((~rst)||(buffer_rcvd_reset == 1'b1)) begin
    buffer_data_count <= {1'b0, {buff_size{1'b0}}};
  end
  else if((buffer_wt_enable == 1'b1)&&(buffer_rd_enable == 1'b0)) begin
    buffer_data_count <= buffer_data_count + 1'b1;
  end
  else if((buffer_wt_enable == 1'b0)&&(buffer_rd_enable == 1'b1)) begin
    buffer_data_count <= buffer_data_count - 1'b1;
  end
  else begin
    buffer_data_count <= buffer_data_count;
  end
end


always @(*)
begin
  buffer_rd_enable = ~(buffer_read_port == 4'b0000);
end


always @(posedge clk)
begin
  if((~rst)||(index_read_reset == 1'b1)) begin
    buffer_rd_index <= {buff_size{1'b0}};
  end
  else if(buffer_rd_enable == 1'b1) begin /** The value is found for next tree level **/
    buffer_rd_index <= buffer_rd_index + 1'b1;
  end
  else begin
    buffer_rd_index <= buffer_rd_index;
  end
end


always @(posedge clk)
begin
  if((~rst)||(index_wten_reset == 1'b1)) begin
    buffer_wt_index <= {buff_size{1'b0}};
  end
  else if(buffer_wt_enable == 1'b1) begin /** The value is found for next tree level **/
    buffer_wt_index <= buffer_wt_index + 1'b1;
  end
  else begin
    buffer_wt_index <= buffer_wt_index;
  end
end


always @(*)
begin
  index_read_reset  = ((buffer_rd_index == (buff_size - 1))&&(buffer_rd_enable == 1'b1))||(buffer_rcvd_reset == 1'b1);
  index_wten_reset  = ((buffer_wt_index == (buff_size - 1))&&(buffer_wt_enable == 1'b1))||(buffer_rcvd_reset == 1'b1);
end


always @(posedge clk)
begin
  if(~rst) begin
    packet_grant_rcvd <= 1'b0;
  end
  else begin
    packet_grant_rcvd <= (buffer_full_init == 1'b0)&&(buffer_full_loop == 1'b0);
  end
end


always @(*)
begin
  if((buffer_data_count == (buff_size - 1))&&(buffer_wt_enable == 1'b1)&&(buffer_rd_enable == 1'b0)) begin
    buffer_full_init = 1'b1;
  end
  else begin
    buffer_full_init = 1'b0;
  end
end


always @(*)
begin
  if((buffer_data_count == buff_size)&&(buffer_rd_enable == 1'b0)) begin
    buffer_full_loop = 1'b1;
  end
  else begin
    buffer_full_loop = 1'b0;
  end
end


always @(*)
begin
  if((buffer_data_count == 4'b0001)&&(buffer_wt_enable == 1'b0)&&(buffer_rd_enable == 1'b1)) begin
    buffer_done_init = 1'b1;
  end
  else begin
    buffer_done_init = 1'b0;
  end
end


always @(*)
begin
  if((buffer_data_count == 4'b0000)&&(buffer_wt_enable == 1'b0)) begin
    buffer_done_loop = 1'b1;
  end
  else begin
    buffer_done_loop = 1'b0;
  end
end


always @(*)
begin
  packet_data_rcvd = buffer_data_rcvd[buffer_rd_index];
end




endmodule


// `include "../param.vh"

module send_lemt ( clk, rst,
                   packet_enable_send,
                   packet_grant_send,  /** The receiver is able to accept package **/
                   packet_inst_send,
                   packet_data_send,
                   packet_proc_done,
                   /** Output Signal **/
                   packet_ready_send,  /** Packet is required to sent to processor **/
                   packet_data_proc,
                   buffer_data_full,
                   buffer_data_epty
                 );

parameter word_size = `word_size_para,
          buff_size = `buff_size_port;


input wire clk, rst;
input wire packet_enable_send;
input wire packet_grant_send, packet_proc_done;  /** The receiver is able to accept package **/
input wire [word_size - 1 : 0] packet_inst_send;
input wire [word_size - 1 : 0] packet_data_send;


output reg packet_ready_send;  /** Packet is required to sent to processor **/
output reg [word_size - 1 : 0] packet_data_proc;
output reg buffer_data_full, buffer_data_epty;


reg [word_size - 1 : 0] buffer_data_rcvd [buff_size - 1 : 0];
reg [1 : 0] state_send, next_state_send;
reg buffer_full_init, buffer_full_loop;
reg buffer_rd_enable, buffer_wt_enable;
reg [2 : 0] buffer_rd_index, buffer_wt_index;
reg [2 : 0] buffer_data_count;
reg index_read_reset, index_wten_reset;
reg [word_size - 1 : 0] packet_data_temp;
reg buffer_data_reset;
reg packet_data_done, buffer_data_done;


integer index;

/**
always @(posedge clk)
begin
  if(~rst) begin
    packet_ready_send <= 1'b0;
  end
  else begin
    packet_ready_send <= packet_enable_send;
  end
end
**/


always @(posedge clk)
begin /** set to 0 when all packets is sent **/
  if((~rst)||(packet_data_done == 1'b1)) begin
    packet_ready_send <= 1'b0;
  end
  else if(packet_enable_send == 1'b1)begin
    packet_ready_send <= 1'b1;
  end
  else begin
    packet_ready_send <= packet_ready_send;
  end
end


always @(*)
begin
  buffer_data_done = (buffer_data_count == 3'b001)&&(buffer_rd_enable == 1'b1)&&(buffer_wt_enable == 1'b0);
  packet_data_done = (packet_proc_done == 1'b1)||(buffer_data_done == 1'b1);
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_data_epty <= 1'b0;
  end
  else begin
    buffer_data_epty <= (buffer_data_count == 3'b000);
  end
end


/** Inst is required for each time the transaction is interrupted **/


always @(posedge clk)
begin
  if(~rst) begin
    state_send <= 2'b00;
  end
  else begin
    state_send <= next_state_send;
  end
end


always @(*)
begin /** If the receiver is full, stall in current phase **/
  case(state_send)
    2'b00  : begin
               if(packet_enable_send == 1'b1) begin
                 next_state_send = 2'b01;
               end
               else begin
                 next_state_send = 2'b00;
               end
             end
    2'b01  : begin
               if(packet_ready_send == 1'b1) begin
                 next_state_send = 2'b10;
               end
               else begin
                 next_state_send = 2'b00;
               end
             end
    2'b10  : begin
               if(packet_data_done == 1'b1) begin
                 next_state_send = 2'b00;
               end
               else begin
                 next_state_send = 2'b10;
               end
             end
    default: begin
               next_state_send = 2'b00;
             end
  endcase
end



always @(*)
begin
  buffer_data_reset = (packet_ready_send == 1'b1)&&(packet_enable_send == 1'b0); /** reset buffer once send is done **/
  packet_data_proc = buffer_data_rcvd[buffer_rd_index];
end



always @(*)
begin
  case(next_state_send)
    2'b01  : packet_data_temp = {packet_inst_send};
    2'b10  : packet_data_temp = {packet_data_send};
    default: packet_data_temp = {word_size{1'b0}};
  endcase
end


always @(*)
begin
  if((packet_enable_send == 1'b1)&&(buffer_data_full == 1'b0)) begin
    buffer_wt_enable = 1'b1;
  end
  else begin
    buffer_wt_enable = 1'b0;
  end
end


always @(*)
begin
  case(state_send)
    2'b01  : buffer_rd_enable = 1'b1;
    2'b10  : buffer_rd_enable = (packet_grant_send == 1'b1);
    default: buffer_rd_enable = 1'b0;
  endcase
end


always @(posedge clk)
begin
  if((~rst)||(packet_data_done == 1'b1)) begin
    for(index = 0; index < buff_size; index = index + 1)
      buffer_data_rcvd[index] <= {word_size{1'b0}};
  end
  else if(buffer_wt_enable == 1'b1) begin
    buffer_data_rcvd[buffer_wt_index] <= packet_data_temp;
  end
  else begin
    for(index = 0; index < buff_size; index = index + 1)
      buffer_data_rcvd[index] <= buffer_data_rcvd[index];
  end
end


always @(posedge clk)
begin
  if((~rst)||(packet_data_done == 1'b1)) begin
    buffer_data_count <= 3'b000;
  end
  else if((buffer_wt_enable == 1'b1)&&(buffer_rd_enable == 1'b0)) begin
    buffer_data_count <= buffer_data_count + 1'b1;
  end
  else if((buffer_wt_enable == 1'b0)&&(buffer_rd_enable == 1'b1)) begin
    buffer_data_count <= buffer_data_count - 1'b1;
  end
  else begin
    buffer_data_count <= buffer_data_count;
  end
end


always @(posedge clk)
begin
  if((~rst)||(index_read_reset == 1'b1)) begin
    buffer_rd_index <= {buff_size{1'b0}};
  end
  else if(buffer_rd_enable == 1'b1) begin /** The value is found for next tree level **/
    buffer_rd_index <= buffer_rd_index + 1'b1;
  end
  else begin
    buffer_rd_index <= buffer_rd_index;
  end
end


always @(posedge clk)
begin
  if((~rst)||(index_wten_reset == 1'b1)) begin
    buffer_wt_index <= {buff_size{1'b0}};
  end
  else if(buffer_wt_enable == 1'b1) begin /** The value is found for next tree level **/
    buffer_wt_index <= buffer_wt_index + 1'b1;
  end
  else begin
    buffer_wt_index <= buffer_wt_index;
  end
end


always @(*)
begin
  index_read_reset  = ((buffer_rd_index == (buff_size - 1))&&(buffer_rd_enable == 1'b1))||(packet_data_done == 1'b1);
  index_wten_reset  = ((buffer_wt_index == (buff_size - 1))&&(buffer_wt_enable == 1'b1))||(packet_data_done == 1'b1);
end


always @(*)
begin
  if((buffer_data_count == (buff_size - 1))&&(buffer_wt_enable == 1'b1)&&(buffer_rd_enable == 1'b0)) begin
    buffer_full_init = 1'b1;
  end
  else begin
    buffer_full_init = 1'b0;
  end
end


always @(*)
begin
  if((buffer_data_count == buff_size)&&(buffer_rd_enable == 1'b0)) begin
    buffer_full_loop = 1'b1;
  end
  else begin
    buffer_full_loop = 1'b0;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_data_full <= 1'b0;
  end
  else begin
    buffer_data_full <= (buffer_full_loop == 1'b1)||(buffer_full_init == 1'b1);
  end
end


endmodule


/** control logic for spatial learning process **/
// `include "../param.vh"

module splr_ctrl ( clk, rst,
                   process_enable_splr,
                   buffer_send_full,
                   packet_proc_done,
                   process_done_adpt,
                   process_done_bost,
                   process_done_lapp,
                   buffer_rd_data,
                   index_data_lemt,
                   index_dirty_ready,
                   buffer_max_adpt_0,
                   buffer_max_adpt_1,
                   buffer_max_adpt_2,
                   buffer_max_adpt_3,
                   buffer_max_adpt_4,
                   buffer_max_adpt_5,
                   buffer_max_adpt_6,
                   buffer_max_adpt_7,
                   buffer_max_rank_0,
                   buffer_max_rank_1,
                   buffer_max_rank_2,
                   buffer_max_rank_3,
                   buffer_max_rank_4,
                   buffer_max_rank_5,
                   buffer_max_rank_6,
                   buffer_max_rank_7,
                   memory_data_ready,
                   index_data_lane_0,
                   index_data_lane_1,
                   index_data_lane_2,
                   index_data_lane_3,
                   index_data_lane_4,
                   index_data_lane_5,
                   index_data_lane_6,
                   index_data_lane_7,
                   memory_addr_init_prt,
                   /** output signal **/
                   process_done_splr,
                   memory_rd_enable,
                   buffer_read_fifo,
                   buffer_read_port,
                   memory_addr_lemt,
                   packet_data_send,
                   packet_inst_send,
                   packet_enable_send,
                   process_enable_adpt,
                   process_enable_bost,
                   process_enable_lapp
				  );

parameter word_size = `word_size_para,
          lane_size = `lane_size_para,
          addr_size = `addr_size_lemt,
          buff_size = `buff_size_lemt,
          inst_find = 8'h02,
          packet_count_desired = `packet_count_desired_para;


input wire clk, rst;
input wire process_enable_splr;
input wire buffer_send_full, packet_proc_done, memory_data_ready;
input wire [lane_size - 1 : 0] process_done_adpt;
input wire [lane_size - 1 : 0] process_done_bost;
input wire [lane_size - 1 : 0] process_done_lapp;
input wire [word_size - 1 : 0] buffer_rd_data;
input wire [7 : 0] index_data_lemt;
input wire [word_size - 1 : 0] buffer_max_adpt_0, buffer_max_adpt_1; /** Max active cycle **/
input wire [word_size - 1 : 0] buffer_max_adpt_2, buffer_max_adpt_3;
input wire [word_size - 1 : 0] buffer_max_adpt_4, buffer_max_adpt_5;
input wire [word_size - 1 : 0] buffer_max_adpt_6, buffer_max_adpt_7;
input wire [word_size - 1 : 0] buffer_max_rank_0, buffer_max_rank_1; /** Max overlap cycle **/
input wire [word_size - 1 : 0] buffer_max_rank_2, buffer_max_rank_3;
input wire [word_size - 1 : 0] buffer_max_rank_4, buffer_max_rank_5;
input wire [word_size - 1 : 0] buffer_max_rank_6, buffer_max_rank_7;
input wire [15 : 0] index_data_lane_0, index_data_lane_1;
input wire [15 : 0] index_data_lane_2, index_data_lane_3;
input wire [15 : 0] index_data_lane_4, index_data_lane_5;
input wire [15 : 0] index_data_lane_6, index_data_lane_7;
input wire [lane_size - 1 : 0] index_dirty_ready;
input wire [addr_size - 1 : 0] memory_addr_init_prt;


output reg packet_enable_send , process_done_splr;
output reg buffer_read_port, buffer_read_fifo;
output reg memory_rd_enable;
output reg [addr_size - 1 : 0] memory_addr_lemt; /** For element sram **/
output reg [word_size - 1 : 0] packet_data_send;
output reg [word_size - 1 : 0] packet_inst_send;
output reg [lane_size - 1 : 0] process_enable_adpt;
output reg [lane_size - 1 : 0] process_enable_bost;
output reg [lane_size - 1 : 0] process_enable_lapp;


reg [lane_size - 1 : 0] lanes_done_lapp, lanes_done_adpt, lanes_done_bost;
reg [lane_size - 1 : 0] index_dirty_find;
reg [addr_size - 1 : 0] memory_addr_init, memory_addr_offt;
reg [2 : 0] state_splr, next_state_splr;
reg packet_send_done;
reg [word_size - 1 : 0] buffer_max_rank [lane_size - 1 : 0];
reg [word_size - 1 : 0] buffer_max_adpt [lane_size - 1 : 0];
reg [7 : 0] packet_data_count;
reg [2 : 0] index_buffer;
reg index_buffer_count, memory_offt_count;
reg buffer_data_ready, memory_buff_ready;
reg buffer_data_full, packet_data_done;
reg index_dirty_lemt, index_bound_lemt;
reg index_dirty_lane, index_ready_data;
reg [7 : 0] buffer_data_count;
reg buffer_add_count, buffer_dec_count;


genvar index;


always @(posedge clk)
begin
  if(~rst) begin
    state_splr <= 3'b000;
  end
  else begin
    state_splr <= next_state_splr;
  end
end


always @(*)
begin
  case(state_splr)
    3'b000 : begin
	           if(process_enable_splr == 1'b1) begin
			     next_state_splr = 3'b001;
			   end
			   else begin
			     next_state_splr = 3'b000;
			   end
			 end
    3'b001 : begin /** Send the max overlap cycle of each lane to the processor for global **/
	           if(packet_send_done == 1'b1) begin
			     next_state_splr = 3'b010;
			   end
			   else begin
			     next_state_splr = 3'b001;
			   end
			 end
	3'b010 : begin /** Wait for the instr from processor to move forward **/
	           if(packet_proc_done == 1'b1) begin
			     next_state_splr = 3'b011;
			   end
			   else begin
			     next_state_splr = 3'b010;
			   end
	         end
    3'b011 : begin /** Trigger the device lapper to update permanence based on overlap cycle **/
	           if(lanes_done_lapp == {lane_size{1'b1}}) begin
			     next_state_splr = 3'b100;
			   end
			   else begin
			     next_state_splr = 3'b011;
			   end
			 end
    3'b100 : begin /** Trigger the device adpt to update active cycle and permanence **/
	           if(lanes_done_adpt == {lane_size{1'b1}}) begin
			     next_state_splr = 3'b101;
			   end
			   else begin
			     next_state_splr = 3'b100;
			   end
			 end
    3'b101 : begin /** Send the max active cycle of each lane to the processor for global **/
	           if(packet_send_done == 1'b1) begin
			     next_state_splr = 3'b110;
			   end
			   else begin
			     next_state_splr = 3'b101;
			   end
			 end
	3'b110 : begin /** Wait for the instr from processor to move forward **/
	           if(packet_proc_done == 1'b1) begin
			     next_state_splr = 3'b111;
			   end
			   else begin
			     next_state_splr = 3'b110;
			   end
	         end
    3'b111 : begin /** Trigger the device boster to update boost value based on active cycle **/
	           if(lanes_done_bost == {lane_size{1'b1}}) begin
			     next_state_splr = 3'b000;
			   end
			   else begin
			     next_state_splr = 3'b111;
			   end
			 end
    default: begin
	           next_state_splr = 3'b000;
			 end
  endcase
end


always @(posedge clk)
begin
  if(~rst) begin
    process_done_splr <= 1'b0;
  end
  else begin
    process_done_splr <= (state_splr == 3'b111)&&(next_state_splr == 3'b000);
  end
end


always @(*)
begin
  buffer_max_rank[0] = buffer_max_rank_0;
  buffer_max_rank[1] = buffer_max_rank_1;
  buffer_max_rank[2] = buffer_max_rank_2;
  buffer_max_rank[3] = buffer_max_rank_3;
  buffer_max_rank[4] = buffer_max_rank_4;
  buffer_max_rank[5] = buffer_max_rank_5;
  buffer_max_rank[6] = buffer_max_rank_6;
  buffer_max_rank[7] = buffer_max_rank_7;
end


always @(*)
begin
  buffer_max_adpt[0] = buffer_max_adpt_0;
  buffer_max_adpt[1] = buffer_max_adpt_1;
  buffer_max_adpt[2] = buffer_max_adpt_2;
  buffer_max_adpt[3] = buffer_max_adpt_3;
  buffer_max_adpt[4] = buffer_max_adpt_4;
  buffer_max_adpt[5] = buffer_max_adpt_5;
  buffer_max_adpt[6] = buffer_max_adpt_6;
  buffer_max_adpt[7] = buffer_max_adpt_7;
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_read_port <= 1'b0;
  end
  else begin
    case(state_splr)
      3'b011 : buffer_read_port <= (next_state_splr == 3'b100);
      3'b111 : buffer_read_port <= (next_state_splr == 3'b100);
      default: buffer_read_port <= (1'b0);
    endcase
  end
end


/** state_splr == 3'b001, send the max overlap cycle of each lane to the processor for global **/
/** state_splr == 3'b101, send the max acitve cycle of each lane to the processor for global **/


always @(posedge clk)
begin
  if(~rst) begin
    packet_enable_send <= 1'b0;
  end
  else begin
    packet_enable_send <= (next_state_splr == 3'b001)||(next_state_splr == 3'b101);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    packet_inst_send <= {word_size{1'b0}};
  end
  else begin
    packet_inst_send <= {16'h0000, inst_find, 8'b00000011};
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    packet_data_send <= {word_size{1'b0}};
  end
  else begin
    case(next_state_splr)
      3'b001 : packet_data_send <= {buffer_max_rank[index_buffer]};
	  3'b101 : packet_data_send <= {buffer_max_adpt[index_buffer]};
	  default: packet_data_send <= {word_size{1'b0}};
    endcase
  end
end


always @(posedge clk)
begin
  if((~rst)||(packet_send_done == 1'b1)) begin
    index_buffer <= 3'b000;
  end
  else if(index_buffer_count == 1'b1) begin
    index_buffer <= index_buffer + 1'b1;
  end
  else begin
    index_buffer <= index_buffer;
  end
end


always @(*)
begin
  case(state_splr)
    3'b001 : index_buffer_count = (buffer_send_full == 1'b0);
    3'b101 : index_buffer_count = (buffer_send_full == 1'b0);
    default: index_buffer_count = (1'b0);
  endcase
end


always @(posedge clk)
begin
  if(~rst) begin
    packet_send_done <= 1'b0;
  end
  else begin
    packet_send_done <= (index_buffer == (lane_size - 1))&&(index_buffer_count == 1'b1);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    process_enable_lapp <= {lane_size{1'b0}};
  end
  else begin
    process_enable_lapp <= {lane_size{(next_state_splr == 3'b011)&&(state_splr != 3'b011)}};
  end
end


generate

   for(index = 0; index < lane_size; index = index + 1)
   begin : lapp_flag

     always @(posedge clk)
     begin
       if((~rst)||(process_done_splr == 1'b1)) begin
	     lanes_done_lapp[index] <= 1'b0;
	   end
	   else if(process_done_lapp[index] == 1'b1) begin
	     lanes_done_lapp[index] <= 1'b1;
	   end
	   else begin
	     lanes_done_lapp[index] <= lanes_done_lapp[index];
	   end
     end

   end

endgenerate


/** state_splr == 3'b100, trigger the process adpt to update active cycle and permanence **/


always @(posedge clk)
begin
  if(~rst) begin
    process_enable_adpt <= {lane_size{1'b0}};
  end
  else begin
    process_enable_adpt <= {lane_size{(buffer_data_ready == 1'b1)}};
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_done_splr == 1'b1)) begin
    memory_buff_ready <= 1'b0;
  end
  else if((memory_data_ready == 1'b1)&&(state_splr == 3'b100))begin
    memory_buff_ready <= 1'b1;
  end
  else begin
    memory_buff_ready <= memory_buff_ready;
  end
end


always @(*)
begin
  if((memory_buff_ready == 1'b0)&&(memory_data_ready == 1'b1)&&(state_splr == 3'b100)) begin
    buffer_data_ready = 1'b1;
  end
  else begin
    buffer_data_ready = 1'b0;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_rd_enable <= (1'b0);
  end
  else begin
    memory_rd_enable <= (buffer_data_full == 1'b0)&&(packet_data_done == 1'b0)&&(next_state_splr == 3'b100);
  end
end


always @(*)
begin
  packet_data_done = (packet_data_count >= (packet_count_desired + 1'b1));
  buffer_data_full = (buffer_data_count >= (buff_size - 1));
end


always @(posedge clk)
begin
  if((~rst)||(process_done_splr == 1'b1)) begin
    packet_data_count <= 8'b0000000;
  end
  else if((memory_rd_enable == 1'b1)&&(state_splr == 3'b100)) begin
    packet_data_count <= packet_data_count + 1'b1;
  end
  else begin
    packet_data_count <= packet_data_count;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_lemt <= {addr_size{1'b0}};
  end
  else begin
    memory_addr_lemt <= {memory_addr_init + memory_addr_offt};
  end
end


always @(*)
begin
  case(next_state_splr)
    3'b100 : memory_addr_init = {memory_addr_init_prt};
	default: memory_addr_init = {addr_size{1'b0}};
  endcase
end


always @(*)
begin
  memory_offt_count = (buffer_data_full == 1'b0)&&(packet_data_done == 1'b0)&&(next_state_splr == 3'b100);
end


always @(posedge clk)
begin /** Buffer used to store the address of active column **/
  if((~rst)||(process_done_splr == 1'b1)) begin
    memory_addr_offt <= {addr_size{1'b0}};
  end
  else if(memory_offt_count == 1'b1) begin
    memory_addr_offt <= {memory_addr_offt + 1'b1};
  end
  else begin
    memory_addr_offt <= {memory_addr_offt};
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_done_splr == 1'b1)) begin
    buffer_data_count <= 8'b000000;
  end
  else if((buffer_add_count == 1'b1)&&(buffer_dec_count == 1'b0)) begin
    buffer_data_count <= buffer_data_count + 1'b1;
  end
  else if((buffer_add_count == 1'b0)&&(buffer_dec_count == 1'b1)) begin
    buffer_data_count <= buffer_data_count - 1'b1;
  end
  else begin
    buffer_data_count <= buffer_data_count;
  end
end


always @(*)
begin
  buffer_add_count = (buffer_data_full == 1'b0)&&(packet_data_done == 1'b0)&&(next_state_splr == 3'b100);
  buffer_dec_count = (index_dirty_lane == 1'b1)&&(index_ready_data == 1'b1)&&(buffer_read_fifo == 1'b0);
end


always @(posedge clk)
begin
  if((~rst)||(next_state_splr == 3'b101)) begin
    index_ready_data <= 1'b0;
  end
  else if(process_enable_adpt == {lane_size{1'b1}}) begin
    index_ready_data <= 1'b1;
  end
  else begin
    index_ready_data <= index_ready_data;
  end
end


always @(*)
begin
  index_dirty_find[0] = (index_data_lane_0 == buffer_rd_data[word_size - 1 : word_size - 16])&&(index_dirty_ready[0] == 1'b1);
  index_dirty_find[1] = (index_data_lane_1 == buffer_rd_data[word_size - 1 : word_size - 16])&&(index_dirty_ready[1] == 1'b1);
  index_dirty_find[2] = (index_data_lane_2 == buffer_rd_data[word_size - 1 : word_size - 16])&&(index_dirty_ready[2] == 1'b1);
  index_dirty_find[3] = (index_data_lane_3 == buffer_rd_data[word_size - 1 : word_size - 16])&&(index_dirty_ready[3] == 1'b1);
  index_dirty_find[4] = (index_data_lane_4 == buffer_rd_data[word_size - 1 : word_size - 16])&&(index_dirty_ready[4] == 1'b1);
  index_dirty_find[5] = (index_data_lane_5 == buffer_rd_data[word_size - 1 : word_size - 16])&&(index_dirty_ready[5] == 1'b1);
  index_dirty_find[6] = (index_data_lane_6 == buffer_rd_data[word_size - 1 : word_size - 16])&&(index_dirty_ready[6] == 1'b1);
  index_dirty_find[7] = (index_data_lane_7 == buffer_rd_data[word_size - 1 : word_size - 16])&&(index_dirty_ready[7] == 1'b1);
end


always @(*)
begin
  index_dirty_lemt = (index_dirty_find == {lane_size{1'b0}});
  index_bound_lemt = (buffer_rd_data[word_size - 17 : word_size - 24] == index_data_lemt)||(buffer_rd_data == {word_size{1'b1}});
  index_dirty_lane = (index_bound_lemt == 1'b0)||(index_dirty_lemt == 1'b0);
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_read_fifo <= 1'b0;
  end
  else begin
    buffer_read_fifo <= (index_dirty_lane == 1'b1)&&(index_ready_data == 1'b1)&&(buffer_read_fifo == 1'b0);
  end
end


generate

   for(index = 0; index < lane_size; index = index + 1)
   begin : adpt_flag

     always @(posedge clk)
     begin
       if((~rst)||(process_done_splr == 1'b1)) begin
	     lanes_done_adpt[index] <= 1'b0;
	   end
	   else if(process_done_adpt[index] == 1'b1) begin
	     lanes_done_adpt[index] <= 1'b1;
	   end
	   else begin
	     lanes_done_adpt[index] <= lanes_done_adpt[index];
	   end
     end

   end

endgenerate


/** state_splr == 3'b111, trigger the device boster to update boost value based on active cycle **/


always @(posedge clk)
begin
  if(~rst) begin
    process_enable_bost <= {lane_size{1'b0}};
  end
  else begin
    process_enable_bost <= {lane_size{(next_state_splr == 3'b111)&&(state_splr != 3'b111)}};
  end
end


generate

   for(index = 0; index < lane_size; index = index + 1)
   begin : bost_flap

     always @(posedge clk)
     begin
       if((~rst)||(process_done_splr == 1'b1)) begin
	     lanes_done_bost[index] <= 1'b0;
	   end
	   else if(process_done_bost[index] == 1'b1) begin
	     lanes_done_bost[index] <= 1'b1;
	   end
	   else begin
	     lanes_done_bost[index] <= lanes_done_bost[index];
	   end
     end

   end

endgenerate



endmodule


/*module************************************
*
* NAME:  sram_2R
*
* DESCRIPTION:
*	Memory for Graph: 8K*128bits, 2 read ports
*
* REVISION HISTORY
*   Date     Programmer    Description
*   2/4/13   Wenxu Zhao    Version 1.0
*
*M
/** For 4 * 4 columns, 2 blocks each column **/ /** 32 blocks, [4 : 0] **/
// `include "../param.vh"

module sram_lemt( clk, rst,
                  memory_device_enable,
                  memory_addr_lemt,
                  memory_wt_data,
                  memory_wt_enable,
                  memory_rd_enable,
				  /** output signal **/
                  memory_rd_data
                );


parameter addr_size = `addr_size_lemt,
          word_size = `word_size_para,
		  bank_size = 128;

input wire clk, rst;
input wire [addr_size - 1 : 0] memory_addr_lemt; // Change as you change size of SRAM
input wire memory_device_enable;
input wire [31 : 0] memory_wt_data;
input wire memory_wt_enable, memory_rd_enable;

output reg [31: 0] memory_rd_data;



reg [31 : 0] register_lemt [bank_size - 1 : 0];   /** Active Column and Learn Packet **/
reg [31 : 0] register_blks [bank_size - 1 : 0];
reg memory_addr_init;
reg [6 : 0] memory_valid_lemt;
reg [6 : 0] memory_valid_blks;
reg memory_lemt_enable, memory_blks_enable;
reg memory_done_enable;


integer index;


always @(*)
begin
  memory_valid_blks = memory_addr_lemt[10 : 4];
  memory_valid_lemt = memory_addr_lemt[6  : 0];
  memory_addr_init = memory_addr_lemt[15];
  memory_lemt_enable = (memory_device_enable == 1'b1)&&(memory_addr_init == 1'b0);
  memory_blks_enable = (memory_device_enable == 1'b1)&&(memory_addr_init == 1'b1);
  memory_done_enable = (memory_device_enable == 1'b1)&&(memory_addr_lemt == 16'ha001); /** block infor is looped done **/
end


always @(posedge clk)
begin
  if(~rst) begin
	memory_rd_data <= {word_size{1'b0}};
  end
  else if((memory_done_enable == 1'b1)&&(memory_rd_enable == 1'b1)) begin
	memory_rd_data <= {word_size{1'b1}};
  end
  else if((memory_lemt_enable == 1'b1)&&(memory_rd_enable == 1'b1)) begin
	memory_rd_data <= {register_lemt[memory_valid_lemt]};
  end
  else if((memory_blks_enable == 1'b1)&&(memory_rd_enable == 1'b1)) begin
	memory_rd_data <= {register_blks[memory_valid_blks]};
  end
  else begin
	memory_rd_data <= {memory_rd_data};
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    for(index = 0; index < bank_size; index = index + 1)
      register_lemt[index] <= {word_size{1'b0}};
  end
  else if((memory_lemt_enable == 1'b1)&&(memory_wt_enable == 1'b1)) begin
    for(index = 0; index < bank_size; index = index + 1)
      register_lemt[index] <= register_lemt[index];
      register_lemt[memory_valid_lemt] <= {memory_wt_data};
  end
  else begin
    for(index = 0; index < bank_size; index = index + 1)
      register_lemt[index] <= register_lemt[index];
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    for(index = 0; index < bank_size; index = index + 1)
      register_blks[index] <= {word_size{1'b0}};
  end
  else if((memory_blks_enable == 1'b1)&&(memory_wt_enable == 1'b1)) begin
    for(index = 0; index < bank_size; index = index + 1)
      register_blks[index] <= register_blks[index];
      register_blks[memory_valid_blks] <= {memory_wt_data};
  end
  else begin
    for(index = 0; index < bank_size; index = index + 1)
      register_blks[index] <= register_blks[index];
  end
end



endmodule


/** The temporal learning process **/
// `include "../param.vh"

module tplr_ctrl ( clk, rst,
                   process_enable_tplr,
                   buffer_data_fifo,
                   process_done_updt,
                   memory_data_ready,
                   /** output signal **/
                   process_enable_updt,
                   process_done_tplr,
                   buffer_read_fifo,
                   memory_addr_lemt,
                   memory_wt_data,
                   memory_rd_enable,
                   memory_wt_enable,
				   operate_buffer,
				   packet_enable_send,
				   packet_inst_send,
				   packet_data_send,
                   memory_addr_buffered,
                   memory_addr_load_rcvd
                 );

parameter  lane_size = `lane_size_para,
           word_size = `word_size_para,
           addr_size = `addr_size_lemt,
	   addr_lane = `addr_size_para,
           mem_inter_syn = `segment_per_cell_para * `synapse_per_lane_para,
           memory_addr_init_blk = `memory_addr_init_blk_para;


input wire clk, rst;
input wire process_enable_tplr, memory_data_ready;
input wire [lane_size - 1 : 0] process_done_updt;
input wire [word_size - 1 : 0] buffer_data_fifo;


output reg memory_addr_load_rcvd;
output reg [lane_size - 1 : 0] process_enable_updt;
output reg [addr_lane - 1 : 0] memory_addr_buffered;
output reg [addr_size - 1 : 0] memory_addr_lemt;
output reg memory_rd_enable, memory_wt_enable;
output reg [word_size - 1 : 0] memory_wt_data;
output reg buffer_read_fifo, process_done_tplr;
output reg packet_enable_send;
output reg [word_size - 1 : 0] packet_data_send;
output reg [word_size - 1 : 0] packet_inst_send;
output reg [3 : 0] operate_buffer;


reg [addr_size - 1 : 0] memory_addr_read_blk;
reg [addr_size - 1 : 0] memory_addr_wten_blk;
reg [addr_size - 1 : 0] memory_addr_init, memory_addr_offt;
reg [word_size - 1 : 0] buffer_data_dirty;
reg [2 : 0] state_tplr, next_state_tplr;
reg [lane_size - 1 : 0] lanes_updt_flag;
reg lanes_update_done;
reg memory_buff_update, memory_wten_update, memory_read_update;
reg dirty_block_find, block_loop_done;
reg dirty_block_learned, dirty_block_predict, dirty_block_updated;
reg [3 : 0] segment_count_blks, segment_count_loop;
reg segment_loop_done, dirty_segment_find;
reg positive_update, negative_update, synapses_update, permance_update;


genvar index;


always @(posedge clk)
begin
  if(~rst) begin
    state_tplr <= 3'b000;
  end
  else begin
    state_tplr <= next_state_tplr;
  end
end


always @(*)
begin
  case(state_tplr)
    3'b000 : begin
	           if(process_enable_tplr == 1'b1) begin
			     next_state_tplr = 3'b001;
			   end
			   else begin
			     next_state_tplr = 3'b000;
			   end
             end
    3'b001 : begin  /** Read the block info and write it into the fifo buffer **/
			   if(memory_data_ready == 1'b1) begin
				 next_state_tplr = 3'b010;
			   end
			   else begin
				 next_state_tplr = 3'b001;
			   end
             end
    3'b010 : begin /** Check the state if any dirty block is found **/
	           if(block_loop_done == 1'b1) begin
			     next_state_tplr = 3'b110;
			   end
			   else begin
			     next_state_tplr = dirty_block_find ? 3'b011 : 3'b010;
			   end
             end
    3'b011 : begin /** Use the updt loigc used to update the synapse info **/
	           if(lanes_update_done == 1'b1) begin
			     next_state_tplr = 3'b100;
			   end
			   else begin
			     next_state_tplr = 3'b011;
			   end
             end
	3'b100 : begin /** Check if all the segments in current cell are done **/
	           if(segment_loop_done == 1'b1) begin
			     next_state_tplr = 3'b101;
			   end
			   else begin
			     next_state_tplr = 3'b011;
			   end
             end
    3'b101 : begin /** Write the updated state of dirty block in element sram **/
			   next_state_tplr = 3'b010;
             end
	3'b110 : begin /** Indicate the processor that learning phase is done here **/
			   next_state_tplr = 3'b000;
	         end
    default: begin
               next_state_tplr = 3'b000;
             end
  endcase
end


always @(posedge clk)
begin
  if(~rst) begin
    process_done_tplr <= 1'b0;
  end
  else begin
    process_done_tplr <= (state_tplr != 3'b000)&&(next_state_tplr == 3'b000);
  end
end


always @(*)
begin
  if(buffer_data_fifo == {word_size{1'b1}}) begin
    block_loop_done = 1'b1;
  end
  else begin
    block_loop_done = 1'b0;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_lemt <= {addr_size{1'b0}};
  end
  else begin
    memory_addr_lemt <= {memory_addr_init + memory_addr_offt};
  end
end


/** state_tplr == 3'b001, read the block info and write it into the fifo buffer **/


always @(posedge clk)
begin
  if(~rst) begin
    memory_rd_enable <= 1'b0;
  end
  else begin
    case(next_state_tplr)
      3'b001 : memory_rd_enable <= 1'b1;
	  3'b010 : memory_rd_enable <= 1'b1;
      default: memory_rd_enable <= 1'b0;
    endcase
  end
end


always @(*)
begin
  case(next_state_tplr)
    3'b001 : memory_addr_init = {memory_addr_init_blk}; /** The initial address of active columns at t **/
	3'b010 : memory_addr_init = {memory_addr_init_blk}; /** The initial address blocks belong to active column **/
	3'b101 : memory_addr_init = {memory_addr_init_blk};
	default: memory_addr_init = {addr_size{1'b0}};
  endcase
end


always @(*)
begin
  case(next_state_tplr)
    3'b001 : memory_addr_offt = {memory_addr_read_blk}; /** The initial address of active columns at t **/
	3'b010 : memory_addr_offt = {memory_addr_read_blk};
	3'b101 : memory_addr_offt = {memory_addr_wten_blk}; /** The initial address blocks belong to active column **/
    default: memory_addr_offt = {addr_size{1'b0}};
  endcase
end


always @(*)
begin
  memory_read_update = (next_state_tplr == 3'b001)||(next_state_tplr == 3'b010);
end


always @(posedge clk)
begin
  if((~rst)||(process_done_tplr == 1'b1)) begin
    memory_addr_read_blk <= {addr_size{1'b0}};
  end
  else if(memory_read_update == 1'b1) begin
    memory_addr_read_blk <= memory_addr_read_blk + 1'b1;
  end
  else begin
    memory_addr_read_blk <= memory_addr_read_blk;
  end
end


/** state_tplr == 3'b010, check if any dirty block is found in this column **/
/** [19] predict at t, [18] predict at t-1, [17] active at t, [16] active at t-1 **/


always @(posedge clk)
begin
  if(~rst) begin
    buffer_read_fifo <= 1'b0;
  end
  else begin
    buffer_read_fifo <= (next_state_tplr == 3'b010);
  end
end


always @(*)
begin
  dirty_block_learned = (buffer_data_fifo[17]);
  dirty_block_predict = (buffer_data_fifo[19]);
  dirty_block_updated = (buffer_data_fifo[19] == 1'b0)&&(buffer_data_fifo[18] == 1'b1);
  dirty_block_find = (dirty_block_learned == 1'b1)||(dirty_block_predict == 1'b1)||(dirty_block_updated == 1'b1);
end


always @(posedge clk)
begin /** used to store dirty block from fifo **/
  if(~rst) begin
    buffer_data_dirty <= {word_size{1'b0}};
  end
  else if((dirty_block_find == 1'b1)&&(state_tplr == 3'b010)) begin
    buffer_data_dirty <= buffer_data_fifo;
  end
  else begin
    buffer_data_dirty <= buffer_data_dirty;
  end
end


always @(posedge clk)
begin /** Block address store offset of the corresponding synapse info **/
  if((~rst)||(process_done_tplr == 1'b1)) begin
    memory_addr_buffered <= {addr_lane{1'b0}};
  end
  else if(memory_buff_update == 1'b1) begin
    memory_addr_buffered <= memory_addr_buffered + mem_inter_syn;
  end
  else begin
    memory_addr_buffered <= memory_addr_buffered;
  end
end


always @(*)
begin
  case(state_tplr)
    3'b010 : memory_buff_update = (dirty_block_find == 1'b0);
	3'b101 : memory_buff_update = (1'b1);
	default: memory_buff_update = (1'b0);
  endcase
end


/** state_tplr = 3'b011, use the updt loigc used to update the synapse info **/


always @(posedge clk)
begin
  if(~rst) begin
    process_enable_updt <= {lane_size{1'b0}};
  end
  else begin
    process_enable_updt <= {lane_size{(state_tplr != 3'b011)&&(next_state_tplr == 3'b011)}};
  end
end


always @(*)
begin
  lanes_update_done = (lanes_updt_flag == {lane_size{1'b1}});
end


generate

   for(index = 0; index < lane_size; index = index + 1)
   begin: flags

	  always @(posedge clk)
	  begin
	    if((~rst)||(lanes_update_done == 1'b1)) begin
		  lanes_updt_flag[index] <= 1'b0;
		end
		else if(process_done_updt[index] == 1'b1) begin
		  lanes_updt_flag[index] <= 1'b1;
		end
		else begin
		  lanes_updt_flag[index] <= lanes_updt_flag[index];
        end
      end

   end

endgenerate


always @(*)
begin
  if((state_tplr == 3'b010)&&(dirty_block_find == 1'b1)) begin
    memory_addr_load_rcvd = 1'b1;
  end
  else begin
    memory_addr_load_rcvd = 1'b0;
  end
end


always @(*)
begin
  dirty_segment_find = (segment_count_loop == buffer_data_dirty[word_size - 17 : word_size - 20]);
  synapses_update = (buffer_data_dirty[19] == 1'b1)&&(dirty_segment_find == 1'b1); /** update predict counter only **/
  positive_update = (buffer_data_dirty[17] == 1'b1);
  negative_update = (buffer_data_dirty[19] == 1'b0)&&(buffer_data_dirty[18] == 1'b1);
  permance_update = (positive_update == 1'b1)||(negative_update == 1'b1);
  operate_buffer = {synapses_update, permance_update, positive_update, negative_update};
end


/** state_tplr == 3'b100, check if all the segments in current cell are done **/


always @(*)
begin
  segment_count_blks = buffer_data_dirty[word_size - 9 : word_size - 12];
  segment_loop_done = (segment_count_blks == segment_count_loop);
end


always @(posedge clk)
begin
  if((~rst)||(segment_loop_done == 1'b1)) begin
    segment_count_loop <= 4'b0000;
  end
  else if(lanes_update_done == 1'b1) begin
    segment_count_loop <= segment_count_loop + 1'b1;
  end
  else begin
    segment_count_loop <= segment_count_loop;
  end
end


/** state_tplr == 3'b101, Write the updated state of dirty block in element sram **/


always @(posedge clk)
begin
  if(~rst) begin
    memory_wt_enable <= 1'b0;
  end
  else begin
    case(next_state_tplr)
      3'b101 : memory_wt_enable <= 1'b1;
      default: memory_wt_enable <= 1'b0;
    endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_wt_data <= {word_size{1'b0}};
  end
  else begin
    case(next_state_tplr)
      3'b101 : memory_wt_data <= {buffer_data_dirty[word_size - 1 : word_size - 12], 1'b0, buffer_data_dirty[word_size - 13],
                                  1'b0, buffer_data_dirty[word_size - 15], 16'h0000};
      default: memory_wt_data <= {word_size{1'b0}};
    endcase
  end
end


always @(*)
begin
  case(state_tplr)
    3'b010 : memory_wten_update = (next_state_tplr == 3'b010);
	3'b101 : memory_wten_update = (next_state_tplr == 3'b010);
	default: memory_wten_update = 1'b0;
  endcase
end


always @(posedge clk)
begin
  if((~rst)||(process_done_tplr == 1'b1)) begin
    memory_addr_wten_blk <= {addr_size{1'b0}};
  end
  else if(memory_wten_update == 1'b1) begin
    memory_addr_wten_blk <= memory_addr_wten_blk + 1'b1;
  end
  else begin
    memory_addr_wten_blk <= memory_addr_wten_blk;
  end
end


/** state_tplr = 3'b101, Indicate the processor that learning is done here **/


always @(posedge clk)
begin
  if(~rst) begin
    packet_enable_send <= 1'b0;
  end
  else begin
    packet_enable_send <= (next_state_tplr == 3'b110);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    packet_inst_send <= {word_size{1'b0}};
  end
  else begin
    packet_inst_send <= {16'h1000, 16'h0801};
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    packet_data_send <= {word_size{1'b0}};
  end
  else begin
    packet_data_send <= packet_data_send;
  end
end



endmodule


/** logic unit used to update the active cycle and permanence value of active column **/
// `include "../param.vh"

module adpt_unit( clk, rst,
                  process_enable_adpt,
				  index_row_lane,
				  index_col_lane,
				  memory_data_ready,
				  memory_rd_data,
				  buffer_rd_data,
				  bound_pass_lane,
				  /** output signal **/
				  process_done_adpt,
				  memory_addr_lane,
				  memory_wt_data,
				  memory_wt_enable,
				  memory_rd_enable,
				  index_dirty_ready,
				  index_done_lane,
				  buffer_max_count,
				  index_dirty_find
				);

parameter memory_addr_init_map = `memory_addr_init_map_para,
          memory_addr_init_act = `memory_addr_init_act_para,
          memory_addr_init_per = `memory_addr_init_vld_para,
          memory_addr_init_flg = `memory_addr_init_flg_para,
          memory_addr_init_val = `memory_addr_init_val_para;


parameter word_size = `word_size_para,
          addr_size = `addr_size_para,
          synapse_count_region = `synapse_count_region_para,
          permanence_max_val = `perm_max_val_pro_para,
          permanence_min_val = `perm_min_val_pro_para,
          permanence_rate = `perm_rate_pro_para,
          permanence_threshold = `perm_threshold_pro_para;


input wire clk, rst;
input wire process_enable_adpt;
input wire [word_size - 1 : 0] memory_rd_data;
input wire [word_size - 1 : 0] buffer_rd_data;
input wire [7 : 0] index_row_lane;
input wire [7 : 0] index_col_lane;
input wire memory_data_ready, bound_pass_lane;


output reg process_done_adpt;
output reg index_done_lane, index_dirty_find;
output reg index_dirty_ready;
output reg [addr_size - 1 : 0] memory_addr_lane;
output reg [word_size - 1 : 0] memory_wt_data;
output reg memory_wt_enable, memory_rd_enable;
output reg [word_size - 1 : 0] buffer_max_count;


reg [word_size - 1 : 0] memory_data_buffer, memory_updt_buffer, memory_perm_buffer;
reg [word_size - 1 : 0] memory_pipe_buffer_0;
reg [word_size - 1 : 0] memory_pipe_buffer_1;
reg [addr_size - 1 : 0] memory_addr_head_map;
reg [addr_size - 1 : 0] memory_addr_head_per;
reg [addr_size - 1 : 0] memory_addr_head_flg;
reg [addr_size - 1 : 0] memory_addr_head_val;
reg [addr_size - 1 : 0] memory_addr_offt_act;
reg [addr_size - 1 : 0] memory_addr_offt_flg;
reg [addr_size - 1 : 0] memory_addr_offt_val;
reg [addr_size - 1 : 0] memory_addr_init, memory_addr_offt;
reg [word_size - 1 : 0] buffer_perm_postive, buffer_perm_negtive;

reg [3 : 0] state_adpt, next_state_adpt;
reg [2 : 0] state_addr;
reg [4 : 0] index_flag_buffer;
reg [word_size - 1 : 0] synaps_data_update;
reg [word_size - 1 : 0] buffer_flag_update;
reg [word_size - 1 : 0] buffer_data_update;
reg [7 : 0] synaps_loop_count;
reg [7 : 0] index_row_rcvd, index_col_rcvd;
reg dirty_bit_found, dirty_packet_found;
reg [3 : 0] logic_timer_adpt;
reg logic_timer_count, logic_timer_reset;
reg buffer_loop_done, synaps_loop_done;
reg process_done_item;
reg index_row_found, index_col_found;
reg memory_offt_val_updt, memory_offt_flg_updt;
reg synaps_vld_flag, per_max_flag, per_min_flag, synaps_act_flag;
reg buffer_max_find;
reg bound_dirty_find, bound_pass_done;
reg index_buffer_reset, index_buffer_count;
reg memory_addr_head_count, memory_addr_offt_count;
reg memory_buff_ready, memory_flag_ready, buffer_data_ready;



genvar index;


always @(posedge clk)
begin
  if(~rst) begin
    state_adpt <= 4'b0000;
  end
  else begin
    state_adpt <= next_state_adpt;
  end
end


always @(*)
begin
  case(state_adpt)
    4'b0000: begin
	           if(process_enable_adpt == 1'b1) begin
			     next_state_adpt = 4'b0001;
			   end
			   else begin
			     next_state_adpt = 4'b0000;
			   end
			 end
    4'b0001: begin /** Read the active cycle for each column and check matching **/
	           if(dirty_packet_found == 1'b1) begin
			     next_state_adpt = 4'b0011;
			   end
			   else begin
			     next_state_adpt = bound_pass_lane ? 4'b0010 : 4'b0001;
			   end
			 end
    4'b0010: begin /** Update the active cycle for the last column index **/
	           if(logic_timer_adpt == 4'b0110) begin
			     next_state_adpt = 4'b0000;
			   end
			   else begin
			     next_state_adpt = 4'b0010;
			   end
			 end
    4'b0011: begin /** Update the active cycle for matching column index **/
	           if(logic_timer_adpt == 4'b0111) begin
			     next_state_adpt = 4'b0100;
			   end
			   else begin
			     next_state_adpt = 4'b0011;
			   end
			 end
    4'b0100: begin /** Read mapping flag of active column into buffer **/
	           if(logic_timer_adpt == 4'b0000) begin
			     next_state_adpt = 4'b0101;
			   end
			   else begin
			     next_state_adpt = 4'b0100;
			   end
			 end
    4'b0101: begin /** Read actived flag of active column into buffer **/
	           if(logic_timer_adpt == 4'b0000)  begin
			     next_state_adpt = 4'b0110;
			   end
			   else begin
			     next_state_adpt = 4'b0101;
			   end
			 end
    4'b0110: begin /** Wait until all the flag are written into buffer **/
	           if(logic_timer_adpt == 4'b0111)  begin
			     next_state_adpt = 4'b0111;
			   end
			   else begin
			     next_state_adpt = 4'b0110;
			   end
             end
    4'b0111: begin /** Check each bit of the mapping buffer to find dirty **/
	           if(dirty_bit_found == 1'b1) begin
			     next_state_adpt = 4'b1000;
			   end
			   else begin
			     next_state_adpt = buffer_loop_done ? 4'b1001 : 4'b0111;
			   end
			 end
    4'b1000: begin /** Update the permanece value and write it back to memory **/
	           if(logic_timer_adpt == 4'b1000) begin
			     next_state_adpt = buffer_loop_done ? 4'b1001 : 4'b0111;
			   end
			   else begin
			     next_state_adpt = 4'b1000;
			   end
			 end
	4'b1001: begin /** Write the updated permanence valid flag back to sram **/
               if(synaps_loop_done == 1'b1) begin
			     next_state_adpt = bound_dirty_find ? 4'b0000 : 4'b0001;
               end
               else begin
                 next_state_adpt = 4'b0100;
               end
             end
    default: begin
               next_state_adpt = 4'b0000;
             end
  endcase
end


always @(posedge clk)
begin
  if(~rst) begin
    process_done_adpt <= 1'b0;
  end
  else begin
    process_done_adpt <= (next_state_adpt == 4'b0000)&&(state_adpt != 4'b0000);
  end
end


always @(posedge clk)
begin /** update of active column is done **/
  if(~rst) begin
    process_done_item <= 1'b0;
  end
  else begin
    process_done_item <= (state_adpt == 4'b1001)&&(synaps_loop_done == 1'b1);
  end
end


always @(posedge clk)
begin /** indicate if last column in the lane is dirty **/
  if((~rst)||(process_done_adpt == 1'b1))begin
    bound_dirty_find <= 1'b0;
  end
  else if((dirty_packet_found == 1'b1)&&(bound_pass_lane == 1'b1)) begin
    bound_dirty_find <= 1'b1;
  end
  else begin
    bound_dirty_find<= bound_dirty_find;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_flag_ready <= 1'b0;
  end
  else begin
    memory_flag_ready <= (memory_data_ready == 1'b1)&&(state_adpt != 4'b0000);
  end
end


always @(*)
begin
  case(state_adpt)
    //4'b0010: memory_buff_ready = (logic_timer_adpt == 4'b0110);
    4'b0011: memory_buff_ready = (logic_timer_adpt == 4'b0110);
    4'b1000: memory_buff_ready = (logic_timer_adpt == 4'b0110);
    default: memory_buff_ready = (1'b0);
  endcase
end



always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_lane <= {addr_size{1'b0}};
  end
  else begin
    memory_addr_lane <= {memory_addr_init + memory_addr_offt};
  end
end


/** state_adpt == 3'b001, read the active cycle for each column and check matching **/


always @(posedge clk)
begin
  if(~rst) begin
    memory_rd_enable <= 1'b0;
  end
  else begin
    case(state_adpt)
      4'b0001: memory_rd_enable <= (bound_pass_done == 1'b1);
      4'b0100: memory_rd_enable <= (1'b1); /** read mapping **/
      4'b0101: memory_rd_enable <= (1'b1); /** read actived **/
      4'b0111: memory_rd_enable <= (dirty_bit_found == 1'b1);
      default: memory_rd_enable <= (1'b0);
    endcase
  end
end


always @(*)
begin
  case(state_adpt)
    4'b0001: memory_addr_offt_count = (bound_pass_done == 1'b1)&&(dirty_packet_found == 1'b0);
    4'b0011: memory_addr_offt_count = (logic_timer_adpt == 4'b0111);
    default: memory_addr_offt_count = (1'b0);
  endcase
end


always @(posedge clk)
begin
  if((~rst)||(process_done_adpt == 1'b1)) begin
    memory_addr_offt_act <= {addr_size{1'b0}};
  end
  else if(memory_addr_offt_count == 1'b1) begin
    memory_addr_offt_act <= memory_addr_offt_act + 1'b1;
  end
  else begin
    memory_addr_offt_act <= memory_addr_offt_act;
  end
end


always @(*)
begin
  index_row_rcvd = buffer_rd_data[word_size - 1 : word_size - 08];
  index_col_rcvd = buffer_rd_data[word_size - 9 : word_size - 16];
  bound_pass_done = ({index_row_lane, index_col_lane} <= {index_row_rcvd, index_col_rcvd});
  index_done_lane = (bound_pass_done == 1'b1)&&(state_adpt == 4'b0001);
end


always @(posedge clk)
begin
  if(~rst) begin
    index_dirty_ready <= (1'b0);
  end
  else begin
    index_dirty_ready <= (next_state_adpt == 4'b0001);
  end
end


always @(*)
begin
  index_row_found = (index_row_lane == index_row_rcvd);
  index_col_found = (index_col_lane == index_col_rcvd);
end


always @(*)
begin
  if((index_row_found == 1'b1)&&(index_col_found == 1'b1)&&(state_adpt == 4'b0001)) begin
    dirty_packet_found = 1'b1;
  end
  else begin
    dirty_packet_found = 1'b0;
  end
end


/** state_adpt == 3'b010, update the active cycle for the last column index **/
/** state_adpt == 3'b011, Update the active cycle for matching column index **/


always @(*)
begin
  case(state_adpt)
    4'b0001: buffer_data_ready = memory_data_ready;
    4'b0010: buffer_data_ready = memory_data_ready;
    4'b0011: buffer_data_ready = memory_data_ready;
    default: buffer_data_ready = 1'b0;
  endcase
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_data_buffer <= {word_size{1'b0}};
  end
  else if(buffer_data_ready == 1'b1) begin
    memory_data_buffer <= memory_rd_data;
  end
  else begin
    memory_data_buffer <= memory_data_buffer;
  end
end


always @(posedge clk)
begin
  if(~rst) begin /** active cycle of active column is added by 1 **/
    buffer_data_update <= {word_size{1'b0}};
  end
  else if((state_adpt == 3'b011)&&(memory_buff_ready == 1'b1)) begin
    buffer_data_update <= memory_data_buffer + 1'b1;
  end
  else begin
    buffer_data_update <= memory_data_buffer;
  end
end


always @(*)
begin
  case(state_adpt)
	4'b0001: buffer_max_find = (buffer_data_update >= buffer_max_count);
	4'b0010: buffer_max_find = (buffer_data_update >= buffer_max_count);
	4'b0011: buffer_max_find = (buffer_data_update >= buffer_max_count);
	default: buffer_max_find = (1'b0);
  endcase
end


always @(posedge clk)
begin
  if((~rst)||(process_enable_adpt == 1'b1)) begin
     buffer_max_count <= {word_size{1'b0}};
  end
  else if(buffer_max_find == 1'b1) begin
     buffer_max_count <= buffer_data_update;
  end
  else begin
     buffer_max_count <= buffer_max_count;
  end
end


/** state_adpt == 4'b0100, read mapping flag of active column into buffer **/
/** state_adpt == 4'b0101, read synpase flag of active column into buffer **/


always @(posedge clk)
begin
  if(~rst) begin
    state_addr <= 3'b000;
  end
  else begin
    case(next_state_adpt)
      4'b0001: state_addr <= 3'b001;  /** Act cycle flag **/
      4'b0011: state_addr <= 3'b011;  /** Act cycle flag **/
      4'b0100: state_addr <= 3'b100;  /** Map valid flag **/
      4'b0101: state_addr <= 3'b101;  /** Act valid flag **/
      4'b0111: state_addr <= 3'b111;  /** Per value flag **/
      4'b1000: state_addr <= 3'b000;  /** Per value flag **/
      4'b1001: state_addr <= 3'b010;  /** Per valid flag **/
    endcase
  end
end


always @(*)
begin
  case(state_addr)
    3'b001: memory_addr_init = {memory_addr_init_act};  /** Act cycle flag **/
    3'b011: memory_addr_init = {memory_addr_init_act};  /** Act cycle flag **/
    3'b100: memory_addr_init = {memory_addr_head_map};  /** Map valid flag **/
    3'b101: memory_addr_init = {memory_addr_head_flg};  /** Act valid flag **/
    3'b111: memory_addr_init = {memory_addr_head_val};  /** Per value flag **/
    3'b000: memory_addr_init = {memory_addr_head_val};  /** Per value flag **/
    3'b010: memory_addr_init = {memory_addr_head_per};  /** Per valid flag **/
  endcase
end


always @(*)
begin
  case(state_addr)
    3'b001: memory_addr_offt = {memory_addr_offt_act};
    3'b011: memory_addr_offt = {memory_addr_offt_act};
    3'b100: memory_addr_offt = {memory_addr_offt_flg};  /** offset for flag data **/
    3'b101: memory_addr_offt = {memory_addr_offt_flg};
    3'b111: memory_addr_offt = {memory_addr_offt_val};  /** Per value flag **/
    3'b000: memory_addr_offt = {memory_addr_offt_val};  /** Per value flag **/
    3'b010: memory_addr_offt = {memory_addr_offt_flg};  /** Per valid flag **/
  endcase
end


always @(posedge clk)
begin
  if(~rst) begin /** synapse act valid flag **/
    memory_pipe_buffer_0 <= {word_size{1'b0}};
  end
  else if((memory_data_ready == 1'b1)&&(state_adpt == 4'b0110)) begin
    memory_pipe_buffer_0 <= memory_rd_data;
  end
  else begin
    memory_pipe_buffer_0 <= memory_pipe_buffer_0;
  end
end


always @(posedge clk)
begin
  if(~rst) begin /** synapse per valid flag **/
    memory_pipe_buffer_1 <= {word_size{1'b0}};
  end
  else if((memory_data_ready == 1'b1)&&(state_adpt == 4'b0110)) begin
    memory_pipe_buffer_1 <= memory_pipe_buffer_0;
  end
  else begin
    memory_pipe_buffer_1 <= memory_pipe_buffer_1;
  end
end


/** state_adpt == 4'b0111, check each bit of the mapping buffer to find dirty **/


always @(posedge clk)
begin
  if((~rst)||(index_buffer_reset == 1'b1)) begin
    index_flag_buffer <= 5'b00000;
  end
  else if(index_buffer_count == 1'b1) begin
    index_flag_buffer <= index_flag_buffer + 1'b1;
  end
  else begin
    index_flag_buffer <= index_flag_buffer;
  end
end


always @(*)
begin
  case(state_adpt)
    4'b1000: index_buffer_count = (logic_timer_adpt == 4'b1000);
    4'b0111: index_buffer_count = (dirty_bit_found == 1'b0);
    default: index_buffer_count = (1'b0);
  endcase
end


always @(*)
begin
  index_buffer_reset = (next_state_adpt == 4'b0101); /** The flag buffer is written back **/
  dirty_bit_found = (memory_pipe_buffer_1[index_flag_buffer] == 1'b1);
  synaps_loop_done = (synaps_loop_count == synapse_count_region);
end


always @(*)
begin
  buffer_loop_done = (index_flag_buffer == 5'b11111)||(synaps_loop_done == 1'b1);
end


always @(posedge clk)
begin
  if((~rst)||(process_done_item == 1'b1)) begin
    synaps_loop_count <= 8'b00000000;
  end
  else if(state_adpt == 4'b0111) begin
    synaps_loop_count <= synaps_loop_count + 1'b1;
  end
  else begin
    synaps_loop_count <= synaps_loop_count;
  end
end


/** state_adpt == 4'b1000, update the permanece value and write it back to memory **/


always @(posedge clk)
begin
  if(~rst) begin
    memory_perm_buffer <= {word_size{1'b0}};
  end
  else if((state_adpt == 4'b1000)&&(memory_data_ready == 1'b1)) begin
    memory_perm_buffer <= memory_rd_data;
  end
  else begin
    memory_perm_buffer <= memory_perm_buffer;
  end
end



always @(*)
begin
  synaps_vld_flag = memory_pipe_buffer_0[index_flag_buffer];
  per_max_flag = (memory_updt_buffer >= permanence_max_val);
  per_min_flag = (memory_updt_buffer <= permanence_min_val);
  synaps_act_flag = (synaps_data_update >= permanence_threshold);
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_perm_postive <= {word_size{1'b0}};
  end
  else if((memory_buff_ready == 1'b1)&&(state_adpt == 4'b1000)) begin
    buffer_perm_postive <= {memory_perm_buffer + permanence_rate};
  end
  else begin
    buffer_perm_postive <= {buffer_perm_postive};
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_perm_negtive <= {word_size{1'b0}};
  end
  else if((memory_buff_ready == 1'b1)&&(state_adpt == 4'b1000)) begin
    buffer_perm_negtive <= {memory_perm_buffer - permanence_rate};
  end
  else begin
    buffer_perm_negtive <= {buffer_perm_negtive};
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_updt_buffer <= {word_size{1'b0}};
  end
  else begin
    memory_updt_buffer <= {synaps_vld_flag ? buffer_perm_postive : buffer_perm_negtive};
  end
end


always @(*)
begin
  case({per_max_flag, per_min_flag})
    2'b10  : synaps_data_update = permanence_max_val;
    2'b01  : synaps_data_update = permanence_min_val;
    default: synaps_data_update = memory_updt_buffer;
  endcase
end


always @(posedge clk)
begin
  if((~rst)||(index_buffer_reset == 1'b1)) begin
    buffer_flag_update <= {word_size{1'b0}};
  end
  else if((logic_timer_adpt == 4'b1000)&&(state_adpt == 4'b1000)) begin
    buffer_flag_update[index_flag_buffer] <= synaps_act_flag;
  end
  else begin
    buffer_flag_update <= buffer_flag_update;
  end
end


/** state_adpt == 4'b1001, write the updated permanence valid flag back to sram **/


always @(posedge clk)
begin
  if(~rst) begin
    memory_wt_enable <= 1'b0;
  end
  else begin
    case(state_adpt)
      4'b0011: memory_wt_enable <= (logic_timer_adpt == 4'b0111);
      4'b1000: memory_wt_enable <= (logic_timer_adpt == 4'b1000);
      4'b1001: memory_wt_enable <= (logic_timer_adpt == 4'b0000);
      default: memory_wt_enable <= (1'b0);
    endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_wt_data <= {word_size{1'b0}};
  end
  else begin
    case(state_adpt)
      4'b0011: memory_wt_data <= {buffer_data_update};
      4'b1000: memory_wt_data <= {synaps_data_update};
      4'b1001: memory_wt_data <= {buffer_flag_update};
      default: memory_wt_data <= {word_size{1'b0}};
    endcase
  end
end


/** memory address for different data stored in lane memory **/


always @(posedge clk)
begin
  if((~rst)||(process_done_adpt == 1'b1)) begin
    memory_addr_head_map <= memory_addr_init_map;
  end
  else if(memory_addr_head_count == 1'b1) begin
    memory_addr_head_map <= memory_addr_head_map + 16'h0002;
  end
  else begin
    memory_addr_head_map <= memory_addr_head_map;
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_done_adpt == 1'b1)) begin
    memory_addr_head_per <= memory_addr_init_per;
  end
  else if(memory_addr_head_count == 1'b1) begin
    memory_addr_head_per <= memory_addr_head_per + 16'h0002;
  end
  else begin
    memory_addr_head_per <= memory_addr_head_per;
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_done_adpt == 1'b1)) begin
    memory_addr_head_flg <= memory_addr_init_flg;
  end
  else if(memory_addr_head_count == 1'b1) begin
    memory_addr_head_flg <= memory_addr_head_flg + 16'h0002;
  end
  else begin
    memory_addr_head_flg <= memory_addr_head_flg;
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_done_adpt == 1'b1)) begin
    memory_addr_head_val <= memory_addr_init_val;
  end
  else if(memory_addr_head_count == 1'b1) begin
    memory_addr_head_val <= memory_addr_head_val + 16'h0028;
  end
  else begin
    memory_addr_head_val <= memory_addr_head_val;
  end
end


always @(*)
begin
  case(state_adpt)
    4'b0001: memory_addr_head_count = ({index_row_lane, index_col_lane} < {index_row_rcvd, index_col_rcvd});
    4'b1001: memory_addr_head_count = (synaps_loop_done == 1'b1);
    default: memory_addr_head_count = (1'b0);
  endcase
end



/** The address offest for each data chunck **/


always @(*)
begin
  memory_offt_val_updt = (state_adpt == 4'b1000)&&(logic_timer_adpt == 4'b1000);
  memory_offt_flg_updt = (state_adpt == 4'b1001)&&(synaps_loop_done == 1'b0);
end


always @(posedge clk)
begin
  if((~rst)||(process_done_item == 1'b1)) begin
    memory_addr_offt_flg <= {word_size{1'b0}};
  end
  else if(memory_offt_flg_updt == 1'b1) begin
    memory_addr_offt_flg <= memory_addr_offt_flg + 1'b1;
  end
  else begin
    memory_addr_offt_flg <= memory_addr_offt_flg;
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_done_item == 1'b1)) begin
    memory_addr_offt_val <= {word_size{1'b0}};
  end
  else if(memory_offt_val_updt == 1'b1) begin
    memory_addr_offt_val <= memory_addr_offt_val + 1'b1;
  end
  else begin
    memory_addr_offt_val <= memory_addr_offt_val;
  end
end



always @(posedge clk)
begin
  if((~rst)||(logic_timer_reset == 1'b1)) begin
    logic_timer_adpt <= 4'b0000;
  end
  else if(logic_timer_count == 1'b1) begin
    logic_timer_adpt <= logic_timer_adpt + 1'b1;
  end
  else begin
    logic_timer_adpt <= logic_timer_adpt;
  end
end


always @(*)
begin
  case(state_adpt)
	4'b0010: logic_timer_count = (1'b1);
	4'b0011: logic_timer_count = (1'b1);
	4'b0110: logic_timer_count = (1'b1);
	4'b1000: logic_timer_count = (1'b1);
	default: logic_timer_count = (1'b0);
  endcase
end


always @(*)
begin
  case(state_adpt)
	4'b0010: logic_timer_reset = (next_state_adpt != 4'b0010);
	4'b0011: logic_timer_reset = (next_state_adpt != 4'b0011);
	4'b0110: logic_timer_reset = (next_state_adpt != 4'b0110);
	4'b1000: logic_timer_reset = (next_state_adpt != 4'b1000);
	default: logic_timer_reset = 1'b0;
  endcase
end

endmodule


// `include "../param.vh"

module bank_ctrl ( clk, rst,
                   memory_rd_data_prox,
                   memory_rd_data_dist,
                   memory_rd_data_perm,
                   memory_ready_prox,
                   memory_ready_dist,
                   memory_ready_perm,
                   /** Output Signal **/
                   memory_data_lane,
                   memory_data_ready
                 );

parameter word_size = `word_size_para;


input wire clk, rst;
input wire [word_size - 1 : 0] memory_rd_data_prox;
input wire [word_size - 1 : 0] memory_rd_data_dist;
input wire [word_size - 1 : 0] memory_rd_data_perm;
input wire memory_ready_prox;
input wire memory_ready_dist;
input wire memory_ready_perm;

output reg [word_size - 1 : 0] memory_data_lane;
output reg memory_data_ready;


always @(posedge clk)
begin
  if(~rst) begin
    memory_data_ready <= 1'b0;
  end
  else begin
    case(1'b1)
      memory_ready_prox: memory_data_ready <= 1'b1;
      memory_ready_perm: memory_data_ready <= 1'b1;
      memory_ready_dist: memory_data_ready <= 1'b1;
      default          : memory_data_ready <= 1'b0;
    endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_data_lane <= {word_size{1'b0}};
  end
  else begin
    case(1'b1)
      memory_ready_prox: memory_data_lane <= {memory_rd_data_prox};
      memory_ready_perm: memory_data_lane <= {memory_rd_data_perm};
      memory_ready_dist: memory_data_lane <= {memory_rd_data_dist};
      default          : memory_data_lane <= {word_size{1'b0}};
    endcase
  end
end


endmodule


// `include "../param.vh"

module bank_perm ( clk, rst,
                   /** Lane memory control from sort **/
                   memory_addr_lane_6,
                   memory_wt_data_6,
                   memory_rd_enable_6,
                   memory_wt_enable_6,
                   /** Lane memory control from find **/
                   memory_addr_lane_5,
                   memory_wt_data_5,
                   memory_rd_enable_5,
                   memory_wt_enable_5,
                   /** Lane memory control from updt **/
                   memory_addr_lane_4,
                   memory_wt_data_4,
                   memory_rd_enable_4,
                   memory_wt_enable_4,
                   /** Lane Memory Data recevied **/
                   memory_rd_data_0,
                   /** Output Signal **/
                   memory_addr_lane,
                   memory_wt_data,
                   memory_rd_data,
                   memory_wt_enable,
				   memory_rd_enable,
                   memory_data_ready,
                   memory_device_enable
                 );

parameter addr_size = `addr_size_para,
          word_size = `word_size_para,
          sram_size = 24, /** word size in sram **/
          memory_addr_init_per = `memory_addr_init_per_para;


input wire  clk, rst;
/** Lane Memory Control from cnnter **/
input wire  [addr_size - 1 : 0] memory_addr_lane_6;
input wire  [word_size - 1 : 0] memory_wt_data_6;
input wire  memory_rd_enable_6, memory_wt_enable_6;

/** Lane Memory Control from matcher **/
input wire  [addr_size - 1 : 0] memory_addr_lane_5;
input wire  [word_size - 1 : 0] memory_wt_data_5;
input wire  memory_rd_enable_5, memory_wt_enable_5;

/** Lane Memory Control from adpter **/
input wire  [addr_size - 1 : 0] memory_addr_lane_4;
input wire  [word_size - 1 : 0] memory_wt_data_4;
input wire  memory_rd_enable_4, memory_wt_enable_4;

/** Lane Memory Data recevied **/
input wire  [sram_size - 1 : 0] memory_rd_data_0;


/** output signal **/
output reg  [addr_size - 1 : 0] memory_addr_lane;
output reg  [sram_size - 1 : 0] memory_wt_data;
output reg  [word_size - 1 : 0] memory_rd_data;
output reg  memory_wt_enable, memory_rd_enable;
output reg  memory_device_enable, memory_data_ready;


reg [word_size - 1 : 0] memory_wten_data;
reg [addr_size - 1 : 0] memory_addr_bank;
reg [6 : 4] memory_device_found;
reg memory_device_valid, memory_buff_ready;
reg memory_wten_temp, memory_read_temp;


always @(*)
begin
  memory_device_found[4] = memory_rd_enable_4||memory_wt_enable_4;
  memory_device_found[5] = memory_rd_enable_5||memory_wt_enable_5;
  memory_device_found[6] = memory_rd_enable_6||memory_wt_enable_6;
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_bank <= {addr_size{1'b0}};
  end
  else begin
    case(1'b1)
      memory_device_found[4]: memory_addr_bank <= {memory_addr_lane_4};
      memory_device_found[5]: memory_addr_bank <= {memory_addr_lane_5};
      memory_device_found[6]: memory_addr_bank <= {memory_addr_lane_6};
      default               : memory_addr_bank <= {addr_size{1'b0}};
    endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_wten_temp <= 1'b0;
  end
  else begin
    case(1'b1)
      memory_wt_enable_4: memory_wten_temp <= memory_wt_enable_4;
      memory_wt_enable_5: memory_wten_temp <= memory_wt_enable_5;
      memory_wt_enable_6: memory_wten_temp <= memory_wt_enable_6;
	  default           : memory_wten_temp <= 1'b0;
	endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_wten_data <= {word_size{1'b0}};
  end
  else begin
    case(1'b1)
      memory_wt_enable_4: memory_wten_data <= {memory_wt_data_4};
      memory_wt_enable_5: memory_wten_data <= {memory_wt_data_5};
      memory_wt_enable_6: memory_wten_data <= {memory_wt_data_6};
	  default           : memory_wten_data <= {word_size{1'b0}};
	endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_read_temp <= 1'b0;
  end
  else begin
    case(1'b1)
      memory_rd_enable_4: memory_read_temp <= memory_rd_enable_4;
      memory_rd_enable_5: memory_read_temp <= memory_rd_enable_5;
      memory_rd_enable_6: memory_read_temp <= memory_rd_enable_6;
	  default           : memory_read_temp <= 1'b0;
	endcase
  end
end


/*** Final address decode stage of memory controller **/


always @(posedge clk)
begin
  if(~rst) begin
    memory_device_valid <= (1'b0);
  end
  else begin
    memory_device_valid <= (memory_device_found != 3'b000);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_device_enable <= 1'b0;
  end
  else begin
    memory_device_enable <= (memory_device_valid == 1'b1)&&(memory_addr_bank[31 : 24] == 8'h32);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_lane <= {addr_size{1'b0}};
  end
  else begin
    memory_addr_lane <= {(memory_device_valid == 1'b1)&&(memory_addr_bank[31 : 24] == 8'h32)} ? {memory_addr_bank} : {addr_size{1'b0}};
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_rd_enable <= 1'b0;
  end
  else begin
    memory_rd_enable <= (memory_device_valid == 1'b1)&&(memory_addr_bank[31 : 24] == 8'h32) ? memory_read_temp : 1'b0;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_wt_enable <= 1'b0;
  end
  else begin
    memory_wt_enable <= (memory_device_valid == 1'b1)&&(memory_addr_bank[31 : 24] == 8'h32) ? memory_wten_temp : 1'b0;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_wt_data <= {sram_size{1'b0}};
  end
  else begin
    memory_wt_data <= {(memory_device_valid == 1'b1)&&(memory_addr_bank[31 : 24] == 8'h32)} ? {memory_wten_data[23: 0]} : {sram_size{1'b0}};
  end
end


/*** Final decode stage of memory read data in controller **/


always @(posedge clk)
begin
  if(~rst) begin
    memory_buff_ready <= (1'b0);
  end
  else begin
    memory_buff_ready <= (memory_rd_enable == 1'b1);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_data_ready <= (1'b0);
  end
  else begin
    memory_data_ready <= (memory_buff_ready == 1'b1);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_rd_data <= {word_size{1'b0}};
  end
  else begin
    memory_rd_data <= {8'h00, memory_rd_data_0};
  end
end


endmodule


// `include "../param.vh"

module bank_prox ( clk, rst,
                   /** Lane Memory Control from adpter **/
                   memory_addr_lane_4,
                   memory_wt_data_4,
                   memory_rd_enable_4,
                   memory_wt_enable_4,
                   /** Lane Memory Control from boster **/
                   memory_addr_lane_3,
                   memory_wt_data_3,
                   memory_rd_enable_3,
                   memory_wt_enable_3,
                   /** Lane Memory Control from lapper **/
                   memory_addr_lane_2,
                   memory_wt_data_2,
                   memory_rd_enable_2,
                   memory_wt_enable_2,
                   /** Lane Memory Control from ranker **/
                   memory_addr_lane_1,
                   memory_wt_data_1,
                   memory_rd_enable_1,
                   memory_wt_enable_1,
                   /** Lane Memory Control from scaner **/
                   memory_addr_lane_0,
                   memory_wt_data_0,
                   memory_rd_enable_0,
                   memory_wt_enable_0,
                   /** Lane Memory Data recevied **/
                   memory_data_prox,
                   /** Output Signal **/
                   memory_addr_lane,
                   memory_wt_data,
                   memory_rd_data,
                   memory_wt_enable,
				   memory_rd_enable,
                   memory_data_ready,
                   memory_device_enable
                 );

parameter addr_size = `addr_size_para,
          word_size = `word_size_para;


input wire  clk, rst;
/** Lane Memory Control from adpter **/
input wire  [addr_size - 1 : 0] memory_addr_lane_4;
input wire  [word_size - 1 : 0] memory_wt_data_4;
input wire  memory_rd_enable_4, memory_wt_enable_4;

/** Lane Memory Control from boster **/
input wire  [addr_size - 1 : 0] memory_addr_lane_3;
input wire  [word_size - 1 : 0] memory_wt_data_3;
input wire  memory_rd_enable_3, memory_wt_enable_3;

/** Lane Memory Control from lapper **/
input wire  [addr_size - 1 : 0] memory_addr_lane_2;
input wire  [word_size - 1 : 0] memory_wt_data_2;
input wire  memory_rd_enable_2, memory_wt_enable_2;

/** Lane Memory Control from ranker **/
input wire  [addr_size - 1 : 0] memory_addr_lane_1;
input wire  [word_size - 1 : 0] memory_wt_data_1;
input wire  memory_rd_enable_1, memory_wt_enable_1;

/** Lane Memory Control from scaner **/
input wire  [addr_size - 1 : 0] memory_addr_lane_0;
input wire  [word_size - 1 : 0] memory_wt_data_0;
input wire  memory_rd_enable_0, memory_wt_enable_0;

/** Lane Memory Data recevied **/
input wire  [word_size - 1 : 0] memory_data_prox;

/** output signal **/
output reg  [addr_size - 1 : 0] memory_addr_lane;
output reg  [word_size - 1 : 0] memory_wt_data;
output reg  [word_size - 1 : 0] memory_rd_data;
output reg  memory_device_enable, memory_data_ready;
output reg  memory_wt_enable, memory_rd_enable;


reg [word_size - 1 : 0] memory_wten_data;
reg [addr_size - 1 : 0] memory_addr_bank;

reg [4 : 0] memory_device_found;
reg memory_device_valid, memory_buff_ready;
reg memory_wten_temp, memory_read_temp;


always @(*)
begin
  memory_device_found[0] = memory_rd_enable_0||memory_wt_enable_0;
  memory_device_found[1] = memory_rd_enable_1||memory_wt_enable_1;
  memory_device_found[2] = memory_rd_enable_2||memory_wt_enable_2;
  memory_device_found[3] = memory_rd_enable_3||memory_wt_enable_3;
  memory_device_found[4] = memory_rd_enable_4||memory_wt_enable_4;
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_bank <= {addr_size{1'b0}};
  end
  else begin
    case(1'b1)
      memory_device_found[0]: memory_addr_bank <= {memory_addr_lane_0};
      memory_device_found[1]: memory_addr_bank <= {memory_addr_lane_1};
      memory_device_found[2]: memory_addr_bank <= {memory_addr_lane_2};
      memory_device_found[3]: memory_addr_bank <= {memory_addr_lane_3};
      memory_device_found[4]: memory_addr_bank <= {memory_addr_lane_4};
      default               : memory_addr_bank <= {addr_size{1'b0}};
    endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_wten_temp <= 1'b0;
  end
  else begin
    case(1'b1)
      memory_wt_enable_0: memory_wten_temp <= memory_wt_enable_0;
      memory_wt_enable_1: memory_wten_temp <= memory_wt_enable_1;
      memory_wt_enable_2: memory_wten_temp <= memory_wt_enable_2;
      memory_wt_enable_3: memory_wten_temp <= memory_wt_enable_3;
      memory_wt_enable_4: memory_wten_temp <= memory_wt_enable_4;
	  default           : memory_wten_temp <= 1'b0;
	endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_read_temp <= 1'b0;
  end
  else begin
    case(1'b1)
      memory_rd_enable_0: memory_read_temp <= memory_rd_enable_0;
      memory_rd_enable_1: memory_read_temp <= memory_rd_enable_1;
      memory_rd_enable_2: memory_read_temp <= memory_rd_enable_2;
      memory_rd_enable_3: memory_read_temp <= memory_rd_enable_3;
      memory_rd_enable_4: memory_read_temp <= memory_rd_enable_4;
	  default           : memory_read_temp <= 1'b0;
	endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_wten_data <= {word_size{1'b0}};
  end
  else begin
    case(1'b1)
      memory_wt_enable_0: memory_wten_data <= {memory_wt_data_0};
      memory_wt_enable_1: memory_wten_data <= {memory_wt_data_1};
      memory_wt_enable_2: memory_wten_data <= {memory_wt_data_2};
      memory_wt_enable_3: memory_wten_data <= {memory_wt_data_3};
      memory_wt_enable_4: memory_wten_data <= {memory_wt_data_4};
	  default           : memory_wten_data <= {word_size{1'b0}};
	endcase
  end
end


/*** Final address decode stage of memory controller **/


always @(posedge clk)
begin
  if(~rst) begin
    memory_device_valid <= (1'b0);
  end
  else begin
    memory_device_valid <= (memory_device_found != 5'b00000);
  end
end



always @(posedge clk)
begin
  if(~rst) begin
    memory_device_enable <= 1'b0;
  end
  else begin
    memory_device_enable <= (memory_device_valid == 1'b1)&&(memory_addr_bank[27 : 23] == 4'b0000);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_lane <= {addr_size{1'b0}};
  end
  else begin
    memory_addr_lane <= {(memory_device_valid == 1'b1)&&(memory_addr_bank[27 : 23] == 4'b0000)} ? {memory_addr_bank} : {addr_size{1'b0}};
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_wt_enable <= 1'b0;
  end
  else begin
    memory_wt_enable <= (memory_device_valid == 1'b1)&&(memory_addr_bank[27 : 23] == 4'b0000) ? memory_wten_temp : 1'b0;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_rd_enable <= 1'b0;
  end
  else begin
    memory_rd_enable <= (memory_device_valid == 1'b1)&&(memory_addr_bank[27 : 23] == 4'b0000) ? memory_read_temp : 1'b0;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_wt_data <= {word_size{1'b0}};
  end
  else begin
    memory_wt_data <= {(memory_device_valid == 1'b1)&&(memory_addr_bank[27 : 23] == 4'b0000)} ? {memory_wten_data} : {word_size{1'b0}};
  end
end


/*** Final decode stage of memory read data in controller **/


always @(posedge clk)
begin
  if(~rst) begin
    memory_buff_ready <= (1'b0);
  end
  else begin
    memory_buff_ready <= (memory_rd_enable == 1'b1);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_data_ready <= (1'b0);
  end
  else begin
    memory_data_ready <= (memory_buff_ready == 1'b1);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_rd_data <= {word_size{1'b0}};
  end
  else begin
    memory_rd_data <= (memory_data_prox);
  end
end




endmodule


// `include "../param.vh"

module bank_syns ( clk, rst,
                   /** Lane memory control from sort **/
                   memory_addr_lane_6,
                   memory_wt_data_6,
                   memory_rd_enable_6,
                   memory_wt_enable_6,
                   /** Lane memory control from find **/
                   memory_addr_lane_5,
                   memory_wt_data_5,
                   memory_rd_enable_5,
                   memory_wt_enable_5,
                   /** Lane memory control from updt **/
                   memory_addr_lane_4,
                   memory_wt_data_4,
                   memory_rd_enable_4,
                   memory_wt_enable_4,
                   /** Lane Memory Data recevied **/
                   memory_rd_data_0,
                   /** Output Signal **/
                   memory_addr_lane,
                   memory_wt_data,
                   memory_rd_data,
                   memory_wt_enable,
				   memory_rd_enable,
                   memory_data_ready,
                   memory_device_enable
                 );

parameter addr_size = `addr_size_para,
          word_size = `word_size_para,
          sram_size = 24, /** word size in sram **/
          memory_addr_init_per = `memory_addr_init_per_para;


input wire  clk, rst;
/** Lane Memory Control from cnnter **/
input wire  [addr_size - 1 : 0] memory_addr_lane_6;
input wire  [word_size - 1 : 0] memory_wt_data_6;
input wire  memory_rd_enable_6, memory_wt_enable_6;

/** Lane Memory Control from matcher **/
input wire  [addr_size - 1 : 0] memory_addr_lane_5;
input wire  [word_size - 1 : 0] memory_wt_data_5;
input wire  memory_rd_enable_5, memory_wt_enable_5;

/** Lane Memory Control from adpter **/
input wire  [addr_size - 1 : 0] memory_addr_lane_4;
input wire  [word_size - 1 : 0] memory_wt_data_4;
input wire  memory_rd_enable_4, memory_wt_enable_4;

/** Lane Memory Data recevied **/
input wire  [sram_size - 1 : 0] memory_rd_data_0;


/** output signal **/
output reg  [addr_size - 1 : 0] memory_addr_lane;
output reg  [sram_size - 1 : 0] memory_wt_data;
output reg  [word_size - 1 : 0] memory_rd_data;
output reg  memory_wt_enable, memory_rd_enable;
output reg  memory_device_enable, memory_data_ready;


reg [word_size - 1 : 0] memory_wten_data;
reg [addr_size - 1 : 0] memory_addr_bank;
reg [6 : 4] memory_device_found;
reg memory_device_valid, memory_buff_ready;
reg memory_wten_temp, memory_read_temp;


always @(*)
begin
  memory_device_found[4] = memory_rd_enable_4||memory_wt_enable_4;
  memory_device_found[5] = memory_rd_enable_5||memory_wt_enable_5;
  memory_device_found[6] = memory_rd_enable_6||memory_wt_enable_6;
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_bank <= {addr_size{1'b0}};
  end
  else begin
    case(1'b1)
      memory_device_found[4]: memory_addr_bank <= {memory_addr_lane_4};
      memory_device_found[5]: memory_addr_bank <= {memory_addr_lane_5};
      memory_device_found[6]: memory_addr_bank <= {memory_addr_lane_6};
      default               : memory_addr_bank <= {addr_size{1'b0}};
    endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_wten_temp <= 1'b0;
  end
  else begin
    case(1'b1)
      memory_wt_enable_4: memory_wten_temp <= memory_wt_enable_4;
      memory_wt_enable_5: memory_wten_temp <= memory_wt_enable_5;
      memory_wt_enable_6: memory_wten_temp <= memory_wt_enable_6;
	  default           : memory_wten_temp <= 1'b0;
	endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_wten_data <= {word_size{1'b0}};
  end
  else begin
    case(1'b1)
      memory_wt_enable_4: memory_wten_data <= {memory_wt_data_4};
      memory_wt_enable_5: memory_wten_data <= {memory_wt_data_5};
      memory_wt_enable_6: memory_wten_data <= {memory_wt_data_6};
	  default           : memory_wten_data <= {word_size{1'b0}};
	endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_read_temp <= 1'b0;
  end
  else begin
    case(1'b1)
      memory_rd_enable_4: memory_read_temp <= memory_rd_enable_4;
      memory_rd_enable_5: memory_read_temp <= memory_rd_enable_5;
      memory_rd_enable_6: memory_read_temp <= memory_rd_enable_6;
	  default           : memory_read_temp <= 1'b0;
	endcase
  end
end


/*** Final address decode stage of memory controller **/


always @(posedge clk)
begin
  if(~rst) begin
    memory_device_valid <= (1'b0);
  end
  else begin
    memory_device_valid <= (memory_device_found != 3'b000);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_device_enable <= 1'b0;
  end
  else begin
    memory_device_enable <= (memory_device_valid == 1'b1)&&(memory_addr_bank[31 : 24] == 8'h42);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_lane <= {addr_size{1'b0}};
  end
  else begin
    memory_addr_lane <= {(memory_device_valid == 1'b1)&&(memory_addr_bank[31 : 24] == 8'h42)} ? {memory_addr_bank} : {addr_size{1'b0}};
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_rd_enable <= 1'b0;
  end
  else begin
    memory_rd_enable <= (memory_device_valid == 1'b1)&&(memory_addr_bank[31 : 24] == 8'h42) ? memory_read_temp : 1'b0;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_wt_enable <= 1'b0;
  end
  else begin
    memory_wt_enable <= (memory_device_valid == 1'b1)&&(memory_addr_bank[31 : 24] == 8'h42) ? memory_wten_temp : 1'b0;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_wt_data <= {sram_size{1'b0}};
  end
  else begin
    memory_wt_data <= {(memory_device_valid == 1'b1)&&(memory_addr_bank[31 : 24] == 8'h42)} ? {memory_wten_data[31:8]} : {sram_size{1'b0}};
  end
end


/*** Final decode stage of memory read data in controller **/


always @(posedge clk)
begin
  if(~rst) begin
    memory_buff_ready <= (1'b0);
  end
  else begin
    memory_buff_ready <= (memory_rd_enable == 1'b1);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_data_ready <= (1'b0);
  end
  else begin
    memory_data_ready <= (memory_buff_ready == 1'b1);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_rd_data <= {word_size{1'b0}};
  end
  else begin
    memory_rd_data <= {memory_rd_data_0, 8'h00};
  end
end


endmodule


/** logic unit used to update boost value based on active cycle **/
// `include "../param.vh"

module bost_unit ( clk, rst,
                   process_enable_bost,
                   memory_rd_data,
                   packet_data_rcvd,
                   memory_data_ready,
                   /** Output Signal **/
                   process_done_bost,
                   memory_addr_lane,
                   memory_wt_data,
                   memory_wt_enable,
                   memory_rd_enable
			     );


parameter word_size = 32,
          addr_size = 32,
          boost_initial = `boost_initial_para,
          boost_max_val = `boost_max_val_para,
          boost_min_val = `boost_min_val_para,
          boost_rate = `boost_rate_para,
          boost_cont = `boost_cont_para;

parameter memory_addr_init_act = `memory_addr_init_act_para,
          memory_addr_init_bst = `memory_addr_init_bst_para;

input wire clk, rst;
input wire process_enable_bost;
input wire [word_size - 1 : 0] packet_data_rcvd;
input wire [word_size - 1 : 0] memory_rd_data;
input wire memory_data_ready;


output reg memory_wt_enable, memory_rd_enable;
output reg [addr_size - 1 : 0] memory_addr_lane;
output reg [word_size - 1 : 0] memory_wt_data;
output reg process_done_bost;


reg [word_size - 1 : 0] memory_data_buffer, memory_updt_buffer;
reg [word_size - 1 : 0] buffer_update_data, buffer_final_data;
reg [addr_size - 1 : 0] memory_addr_init, memory_addr_offt;
reg [2 : 0] state_bost, next_state_bost;
reg [3 : 0] logic_timer_bost;
reg logic_timer_count, logic_timer_reset;
reg packet_update_code, packet_loop_done;
reg [15 : 0] buffer_oprand_mult;
reg buffer_operate_enable;


always @(posedge clk)
begin
  if(~rst) begin
    state_bost <= 3'b000;
  end
  else begin
    state_bost <= next_state_bost;
  end
end


always @(*)
begin
  case(state_bost)
   3'b000 : begin
              if(process_enable_bost == 1'b1) begin
			    next_state_bost = 3'b001;
			  end
			  else begin
			    next_state_bost = 3'b000;
			  end
			end
   3'b001 : begin /** Read active cycle for each column into memory buffer **/
              if(memory_data_ready == 1'b1) begin
			    next_state_bost = 3'b010;
			  end
			  else begin
			    next_state_bost = 3'b001;
			  end
			end
   3'b010 : begin /** Wait until the data is written into the buffer **/
              if(packet_loop_done == 1'b1) begin
			    next_state_bost = 3'b000;
			  end
			  else begin
			    next_state_bost = 3'b011;
			  end
			end
   3'b011 : begin /** Update the boost value based on active cycle **/
              if(logic_timer_bost == 4'b0100) begin
			    next_state_bost = 3'b100;
			  end
			  else begin
			    next_state_bost = 3'b011;
			  end
			end
   3'b100 : begin /** Write the updated boost value back to the lane sram **/
              if(logic_timer_bost == 4'b0000) begin
			    next_state_bost = 3'b001;
			  end
			  else begin
			    next_state_bost = 3'b100;
			  end
			end
   default: begin
              next_state_bost = 3'b000;
			end
  endcase
end


always @(posedge clk)
begin
  if(~rst) begin
    process_done_bost <= 1'b0;
  end
  else begin
    process_done_bost <= (state_bost != 3'b000)&&(next_state_bost == 3'b000);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
	packet_loop_done <= (1'b0);
  end
  else begin
	packet_loop_done <= (memory_addr_offt == 32'h00000020);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_lane <= {addr_size{1'b0}};
  end
  else begin
    memory_addr_lane <= {memory_addr_init + memory_addr_offt};
  end
end


/** state_bost == 3'b001, read active cycle and wait till the first data ready **/
/** state_bost == 3'b010, wait until the data is written into the buffer **/


always @(posedge clk)
begin
  if(~rst) begin
    memory_rd_enable <= 1'b0;
  end
  else begin
    case(state_bost)
      3'b001 : memory_rd_enable <= (logic_timer_bost == 4'b0000);
      default: memory_rd_enable <= (1'b0);
    endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin /** Per value buffer */
    memory_data_buffer <= {word_size{1'b0}};
  end
  else if(memory_data_ready == 1'b1) begin
    memory_data_buffer <= memory_rd_data;
  end
  else begin
    memory_data_buffer <= memory_data_buffer;
  end
end


/** state_bost == 3'b011, update the boost value based on active cycle **/


always @(posedge clk)
begin
  if(~rst) begin
    buffer_oprand_mult <= 16'h0000;
  end
  else if((logic_timer_bost == 4'b0000)&&(state_bost == 3'b011)) begin
    buffer_oprand_mult <= boost_cont;
  end
  else if((logic_timer_bost == 4'b0001)&&(state_bost == 3'b011)) begin
    buffer_oprand_mult <= boost_rate;
  end
  else begin
    buffer_oprand_mult <= buffer_oprand_mult;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_operate_enable <= (1'b0);
  end
  else begin
    buffer_operate_enable <= (state_bost == 3'b011)&&((logic_timer_bost == 4'b0000)||(logic_timer_bost == 4'b0001));
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_updt_buffer <= {word_size{1'b0}};
  end
  else if(buffer_operate_enable == 1'b1) begin
    memory_updt_buffer <= memory_data_buffer[15 : 0] * buffer_oprand_mult;
  end
  else begin
    memory_updt_buffer <= memory_updt_buffer;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    packet_update_code <= 1'b0;
  end
  else if((logic_timer_bost == 4'b0010)&&(state_bost == 3'b011)) begin
    packet_update_code <= (memory_updt_buffer >= packet_data_rcvd);
  end
  else begin
    packet_update_code <= packet_update_code;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_update_data <= {word_size{1'b0}};
  end
  else if((logic_timer_bost == 4'b0011)&&(state_bost == 3'b011)) begin
    buffer_update_data <= boost_max_val - memory_updt_buffer;
  end
  else if(buffer_update_data <= boost_min_val) begin
    buffer_update_data <= boost_min_val;
  end
  else begin
    buffer_update_data <= buffer_update_data;
  end
end


always @(*)
begin
  buffer_final_data = packet_update_code ? boost_initial : buffer_update_data;
end


/** state_bost == 3'b100, write the updated boost value back to the lane sram **/


always @(posedge clk)
begin
  if(~rst) begin
    memory_wt_data <= {word_size{1'b0}};
  end
  else begin
    case(state_bost)
	  3'b100 : memory_wt_data <= {buffer_final_data};
	  default: memory_wt_data <= {word_size{1'b0}};
	endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_wt_enable <= 1'b0;
  end
  else begin
    case(state_bost)
	  3'b100 : memory_wt_enable <= 1'b1;
	  default: memory_wt_enable <= 1'b0;
	endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_init <= {addr_size{1'b0}};
  end
  else begin
    case(next_state_bost)
      3'b001 : memory_addr_init <= {memory_addr_init_act};
      3'b100 : memory_addr_init <= {memory_addr_init_bst};
      default: memory_addr_init <= {addr_size{1'b0}};
    endcase
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_done_bost == 1'b1)) begin
    memory_addr_offt <= {addr_size{1'b0}};
  end
  else if(state_bost == 3'b100) begin
    memory_addr_offt <= memory_addr_offt + 1'b1;
  end
  else begin
    memory_addr_offt <= memory_addr_offt;
  end
end


always @(posedge clk)
begin
  if((~rst)||(logic_timer_reset == 1'b1)) begin
    logic_timer_bost <= 4'b0000;
  end
  else if(logic_timer_count == 1'b1) begin
    logic_timer_bost <= logic_timer_bost + 1'b1;
  end
  else begin
    logic_timer_bost <= logic_timer_bost;
  end
end


always @(*)
begin
  case(state_bost)
    3'b001 : logic_timer_count = 1'b1;
    3'b011 : logic_timer_count = 1'b1;
    default: logic_timer_count = 1'b0;
  endcase
end


always @(*)
begin
  case(state_bost)
    3'b001 : logic_timer_reset = (next_state_bost == 3'b010);
    3'b011 : logic_timer_reset = (next_state_bost == 3'b100);
    default: logic_timer_reset = (1'b0);
  endcase
end


endmodule


/** logic unit used to store index information of columns **/
// `include "../param.vh"

module conf_unit( clk, rst,
                  index_lane_ready,
                  index_data_lane,
                  index_info_rset,
                  index_done_rank,
                  index_done_adpt,
                  process_done_lapp,
                  process_done_find,
                  /** Output Signal **/
                  index_row_lane,
                  index_col_lane,
                  index_cfg_lane,
                  bound_pass_lane,
	          bound_pass_done,
                  buffer_lane_reset
                );

parameter word_size = `word_size_para,
	      lane_size = `lane_size_para;

input wire clk, rst;
input wire [7 : 0] index_data_lane;
input wire index_lane_ready;  /** enable signal from initial process **/
input wire index_info_rset;  /** reset the column index for new image **/
input wire index_done_rank;  /** process of the current column is done **/
input wire index_done_adpt;
input wire process_done_find;
input wire process_done_lapp;


output reg [7 : 0] index_row_lane, index_col_lane;
output reg [7 : 0] index_cfg_lane;
output reg bound_pass_lane, bound_pass_done;
output reg buffer_lane_reset;


reg [7 : 0] bound_row_lane, bound_col_lane;
reg [7 : 0] initl_row_lane, initl_col_lane;
reg bound_col_pass, index_done_lane;
reg index_item_init;


always @(*)
begin
  index_done_lane = (index_done_rank == 1'b1)||(index_done_adpt == 1'b1);
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_lane_reset <= 1'b0;
  end
  else begin
    buffer_lane_reset <= (process_done_find == 1'b1)||(process_done_lapp == 1'b1);
  end
end


/** Index information received from the processor **/


always @(posedge clk)
begin
  if(~rst) begin
    index_cfg_lane <= 8'b00000000;
  end
  else if(index_lane_ready == 1'b1) begin
    index_cfg_lane <= index_data_lane;
  end
  else begin
    index_cfg_lane <= index_cfg_lane;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    bound_col_lane <= 8'b00000000;
  end
  else if(index_lane_ready == 1'b1) begin
    bound_col_lane <= index_cfg_lane;
  end
  else begin
    bound_col_lane <= bound_col_lane;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    bound_row_lane <= 8'b00000000;
  end
  else if(index_lane_ready == 1'b1) begin
    bound_row_lane <= bound_col_lane;
  end
  else begin
    bound_row_lane <= bound_row_lane;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    initl_col_lane <= 8'b00000000;
  end
  else if(index_lane_ready == 1'b1) begin
    initl_col_lane <= bound_row_lane;
  end
  else begin
    initl_col_lane <= initl_col_lane;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    initl_row_lane <= 8'b00000000;
  end
  else if(index_lane_ready == 1'b1) begin
    initl_row_lane <= initl_col_lane;
  end
  else begin
    initl_row_lane <= initl_row_lane;
  end
end


/** Column index information is computed within each execution lane **/


always @(posedge clk)
begin
  if(~rst) begin
    index_row_lane <= 8'b00000000;
  end
  else if(index_info_rset == 1'b1) begin
    index_row_lane <= initl_row_lane;
  end
  else if(bound_col_pass == 1'b1) begin
    index_row_lane <= index_row_lane + 1'b1;
  end
  else begin
    index_row_lane <= index_row_lane;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    index_col_lane <= 8'b00000000;
  end
  else if(index_item_init == 1'b1) begin
    index_col_lane <= initl_col_lane;
  end
  else if(index_done_lane == 1'b1) begin
    index_col_lane <= index_col_lane + 1'b1;
  end
  else begin
    index_col_lane <= index_col_lane;
  end
end


always @(*)
begin
  if((index_row_lane >= bound_row_lane)&&(index_col_lane >= bound_col_lane)) begin
    bound_pass_done = 1'b1;
  end
  else begin
    bound_pass_done = 1'b0;
  end
end



always @(posedge clk)
begin
  if(~rst) begin
    bound_pass_lane <= (1'b0);
  end
  else begin
    bound_pass_lane <= (index_row_lane >= bound_row_lane)&&(index_col_lane >= bound_col_lane);
  end
end


always @(*)
begin
  if((index_col_lane >= bound_col_lane)&&(index_done_lane == 1'b1)) begin
    bound_col_pass = 1'b1;
  end
  else begin
    bound_col_pass = 1'b0;
  end
end


always @(*)
begin
  if((index_info_rset == 1'b1)||(bound_col_pass == 1'b1)) begin
    index_item_init = 1'b1;
  end
  else begin
    index_item_init = 1'b0;
  end
end


endmodule


// `include "../param.vh"

module fifo_lane ( clk, rst,
                   buffer_wt_enable,
                   buffer_rd_enable,
                   buffer_wt_data,
                   buffer_data_reset,
                   /** Output Signal **/
                   buffer_rd_data
                 );

parameter  buff_size = `buff_size_lane;
parameter  word_size = `word_size_para;


input wire clk, rst;
input wire [1 : 0] buffer_wt_enable;
input wire [1 : 0] buffer_rd_enable;
input wire buffer_data_reset;
input wire [word_size - 1 : 0] buffer_wt_data;

output reg [word_size - 1 : 0] buffer_rd_data;


reg [word_size - 1 : 0] buffer_data_fifo [buff_size - 1 : 0];
reg [word_size - 1 : 0] buffer_data_next [buff_size - 1 : 0];
reg [3 : 0] buffer_rd_index, buffer_wt_index;
reg buffer_rd_reset, buffer_wt_reset;
reg buffer_data_read, buffer_data_wten;


integer index;


always @(*)
begin
  buffer_data_read = (buffer_rd_enable != 2'b00);
  buffer_data_wten = (buffer_wt_enable != 2'b00);
end


always @(posedge clk )
begin
  if((~rst)||(buffer_data_reset == 1'b1)) begin
    for(index = 0; index < buff_size; index = index + 1)
      buffer_data_fifo[index] <= {word_size{1'b0}};
  end
  else begin
    for(index = 0; index < buff_size; index = index + 1)
      buffer_data_fifo[index] <= buffer_data_next[index];
  end
end


always @(*)
begin
  if(buffer_data_wten == 1'b1) begin
    for(index = 0; index < buff_size; index = index + 1)
      buffer_data_next[index] = buffer_data_fifo[index];
      buffer_data_next[buffer_wt_index] = buffer_wt_data;
  end
  else begin
    for(index = 0; index < buff_size; index = index + 1)
      buffer_data_next[index] = buffer_data_fifo[index];
  end
end


always @(*)
begin
  buffer_rd_reset = ((buffer_rd_index == (buff_size - 1))&&(buffer_data_read == 1'b1))||(buffer_data_reset == 1'b1);
  buffer_wt_reset = ((buffer_wt_index == (buff_size - 1))&&(buffer_data_wten == 1'b1))||(buffer_data_reset == 1'b1);
end


always @(posedge clk)
begin
  if((~rst)||(buffer_rd_reset == 1'b1)) begin
    buffer_rd_index <= 3'b000;
  end
  else if(buffer_data_read == 1'b1) begin
    buffer_rd_index <= buffer_rd_index + 1'b1;
  end
  else begin
    buffer_rd_index <= buffer_rd_index;
  end
end


always @(posedge clk)
begin
  if((~rst)||(buffer_wt_reset == 1'b1)) begin
    buffer_wt_index <= 3'b000;
  end
  else if(buffer_data_wten == 1'b1) begin
    buffer_wt_index <= buffer_wt_index + 1'b1;
  end
  else begin
    buffer_wt_index <= buffer_wt_index;
  end
end


always @(*)
begin
  buffer_rd_data = buffer_data_fifo[buffer_rd_index];
end


endmodule


/** The logic used to find matching for each segment **/
// `include "../param.vh"

module find_unit ( clk, rst,
                   process_learn_enable,
                   process_find_actc,
                   process_find_buld,
                   process_find_pred,
                   memory_ready_lemt,
                   memory_ready_lane,
                   memory_ready_syns,
                   memory_data_lemt,
                   buffer_data_lane,
                   device_code_find,
                   memory_addr_buffered,
                   memory_addr_computed,
                   memory_addr_load_rcvd,
                   /*** output signal ***/
                   process_done_find,
                   memory_rd_enable,
                   memory_wt_enable,
                   memory_wt_data,
                   memory_addr_lane,
                   memory_find_busy,
                   buffer_read_fifo,
                   buffer_wten_fifo,
                   buffer_counter_find
                 );


parameter word_size = `word_size_para,
          lane_size = `lane_size_para,
          addr_size = `addr_size_para,
          buff_size = `buff_size_lane;


parameter memory_addr_init_per = `memory_addr_init_per_para,
          memory_addr_init_syn = `memory_addr_init_syn_para,
          distal_synapse_count = `distal_synapse_count_para,
          cell_per_column = `cell_per_column_para,
          synapse_per_lane = `synapse_per_lane_para,
          permanence_threshold = `perm_threshold_dis_para;


input wire clk, rst;
input wire process_learn_enable, device_code_find;
input wire process_find_actc, process_find_buld, process_find_pred;
input wire [addr_size - 1 : 0] memory_addr_buffered;
input wire [addr_size - 1 : 0] memory_addr_computed;
input wire [word_size - 1 : 0] buffer_data_lane, memory_data_lemt;
input wire [2 : 0] memory_addr_load_rcvd;
input wire memory_ready_lemt, memory_ready_lane, memory_ready_syns;


output reg [addr_size - 1 : 0] memory_addr_lane;
output reg [word_size - 1 : 0] memory_wt_data;
output reg memory_wt_enable, memory_rd_enable;
output reg process_done_find;
output reg memory_find_busy;  /** memory is occupied by find logic, none fifo used **/
output reg [23 : 0] buffer_counter_find;
output reg buffer_read_fifo, buffer_wten_fifo;


reg [word_size - 1 : 0] buffer_data_lemt;
reg [word_size - 1 : 0] buffer_data_pass;
reg [word_size - 1 : 0] memory_data_temp;
reg [addr_size - 1 : 0] memory_addr_offt;
reg [addr_size - 1 : 0] memory_addr_init;
reg [addr_size - 1 : 0] memory_addr_offt_syn;
reg [addr_size - 1 : 0] memory_addr_offt_per;
reg [2 : 0] state_find, next_state_find;
reg cells_match_find, cells_match_done;
reg synaps_vld_flag, synaps_tmp_flag;
reg [15 : 0] synaps_per_data;
reg column_match_find, column_match_rcvd, column_match_pass;
reg actived_match_rcvd, actived_match_pass;
reg learned_match_rcvd, learned_match_pass;
reg actived_match_cell, learned_match_cell;
reg actived_match_find, learned_match_find;
reg [15 : 0] index_col_lane, index_col_rcvd, index_col_pass;
reg [7  : 0] index_act_rcvd, index_lrn_rcvd;
reg [7  : 0] index_act_pass, index_lrn_pass;
reg [7  : 0] index_cel_lane;
reg [7  : 0] buffer_counter_act, buffer_counter_lrn;
reg [7  : 0] buffer_counter_pnt;
reg match_find_act, match_find_pnt, match_find_lrn;
reg dirty_match_find, index_match_find;
reg packet_read_done, packet_loop_done;
reg index_loop_done, flags_loop_done;
reg [7 : 0] match_flag_act, match_flag_lrn;
reg index_flag_reset, index_flag_count;
reg [2 : 0] index_match_flag;
reg [7 : 0] packet_read_count;
reg memory_addr_updt_per, memory_addr_updt_syn;
reg [addr_size - 1 : 0] memory_addr_received;
reg memory_addr_offt_load, process_enable_find;



always @(*)
begin
  case(1'b1)
    memory_addr_load_rcvd[0]: memory_addr_offt_load = 1'b1;
    memory_addr_load_rcvd[1]: memory_addr_offt_load = 1'b1;
    memory_addr_load_rcvd[2]: memory_addr_offt_load = 1'b1;
    default: memory_addr_offt_load = 1'b0;
  endcase
end


always @(*)
begin
  case(1'b1)
    memory_addr_load_rcvd[0]: memory_addr_received = memory_addr_computed;
    memory_addr_load_rcvd[1]: memory_addr_received = memory_addr_computed;
    memory_addr_load_rcvd[2]: memory_addr_received = memory_addr_buffered;
    default: memory_addr_received = {addr_size{1'b0}};
  endcase
end


always @(*)
begin
  case(1'b1)
    process_find_actc: process_enable_find = 1'b1;
    process_find_buld: process_enable_find = 1'b1;
    process_find_pred: process_enable_find = 1'b1;
    default: process_enable_find = 1'b0;
  endcase
end


always @(posedge clk)
begin
  if(~rst) begin
    state_find <= 3'b000;
  end
  else begin
    state_find <= next_state_find;
  end
end


always @(*)
begin
  case(state_find)
    3'b000 : begin
	           if(process_enable_find == 1'b1) begin
				 next_state_find = 3'b001;
	           end
	           else begin
				 next_state_find = 3'b000;
	           end
	         end
	3'b001 : begin /** Read synapse information from sram lane and ready to match **/
	           if(memory_ready_lane == 1'b1) begin
				 next_state_find = 3'b010;
	           end
	           else begin
				 next_state_find = 3'b001;
	           end
	         end
	3'b010 : begin /** Read synapse information and matching with active columns **/
	           if(packet_loop_done == 1'b1) begin
				 next_state_find = 3'b011;
	           end
	           else begin
				 next_state_find = 3'b010;
	           end
	         end
    3'b011 : begin /** Check the matching condition and update counter **/
	           if(dirty_match_find == 1'b1) begin
				 next_state_find = 3'b100;
	           end
	           else begin
				 next_state_find = flags_loop_done ? 3'b000 : 3'b011;
	           end
	         end
    3'b100 : begin /** Read permance value for matching synapses only **/
	           if(memory_ready_lane == 1'b1) begin
				 next_state_find = 3'b101;
	           end
	           else begin
				 next_state_find = 3'b100;
	           end
	         end
    3'b101 : begin /** Update the counter based on matching condition **/
	           if(process_learn_enable == 1'b1) begin
				 next_state_find = 3'b110;
	           end
	           else begin
				 next_state_find = 3'b011;
	           end
	         end
    3'b110 : begin /** Write the updated synapes bits back to sram if learn enable **/
	           if(flags_loop_done == 1'b1) begin
				 next_state_find = 3'b000;
			   end
	           else begin
				 next_state_find = 3'b011;
	           end
	         end
	default: begin
	           next_state_find = 3'b000;
	         end
  endcase
end


always @(posedge clk)
begin
  if(~rst) begin
    process_done_find <= 1'b0;
  end
  else begin
    process_done_find <= (state_find != 3'b000)&&(next_state_find == 3'b000);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_lane <= {addr_size{1'b0}};
  end
  else begin
    memory_addr_lane <= {memory_addr_init + memory_addr_offt};
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_done_find == 1'b1)) begin
    buffer_data_lemt <= {word_size{1'b0}};
  end
  else if((memory_ready_lemt == 1'b1)&&(state_find != 3'b000)) begin
    buffer_data_lemt <= memory_data_lemt;
  end
  else begin
    buffer_data_lemt <= buffer_data_lemt;
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_done_find == 1'b1)) begin
    memory_find_busy <= 1'b0;
  end
  else if(memory_ready_syns == 1'b1) begin
    memory_find_busy <= 1'b1;
  end
  else begin
    memory_find_busy <= memory_find_busy;
  end
end


always @(*)
begin
  buffer_read_fifo = ((cells_match_done == 1'b1)&&(index_loop_done == 1'b0))||
                     ((cells_match_find == 1'b1)&&(index_loop_done == 1'b0))||
                     ((state_find == 3'b100)&&(next_state_find == 3'b101));
  buffer_wten_fifo = (memory_ready_lane == 1'b1)&&(state_find != 3'b000);
end


always @(*)
begin
  buffer_counter_find = {buffer_counter_act, buffer_counter_lrn, buffer_counter_pnt};
  packet_loop_done = (buffer_data_lemt == {word_size{1'b1}});
end


/** state == 3'b001,  read synapse information from sram lane and ready to match **/


always @(posedge clk)
begin
  if(~rst) begin
    memory_rd_enable <= 1'b0;
  end
  else begin
    case(next_state_find) /** For the lane memory **/
      3'b001 : memory_rd_enable <= (packet_read_done == 1'b0);
	  3'b010 : memory_rd_enable <= (packet_read_done == 1'b0);
      3'b100 : memory_rd_enable <= (state_find == 3'b011);
      default: memory_rd_enable <= (1'b0);
    endcase
  end
end


always @(*)
begin
  case(next_state_find) /** For the lane memory **/
    3'b001 : memory_addr_init = {memory_addr_init_syn}; /** Read synapse info **/
    3'b010 : memory_addr_init = {memory_addr_init_syn}; /** Read synapse info **/
    3'b100 : memory_addr_init = {memory_addr_init_per};
    3'b110 : memory_addr_init = {memory_addr_init_per};
	default: memory_addr_init = {addr_size{1'b0}};
  endcase
end


always @(*)
begin
  case(next_state_find) /** For the lane memory **/
    3'b001 : memory_addr_offt = {memory_addr_offt_syn}; /** Read synapse info **/
    3'b010 : memory_addr_offt = {memory_addr_offt_syn}; /** Read synapse info **/
    3'b100 : memory_addr_offt = {memory_addr_offt_per};
    3'b110 : memory_addr_offt = {memory_addr_offt_per};
	default: memory_addr_offt = {addr_size{1'b0}};
  endcase
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_offt_syn <= {addr_size{1'b0}};
  end
  else if(memory_addr_offt_load == 1'b1) begin
    memory_addr_offt_syn <= memory_addr_received;          /** Computed address or buffered address **/
  end
  else if(memory_addr_updt_syn == 1'b1) begin
    memory_addr_offt_syn <= memory_addr_offt_syn + 1'b1;
  end
  else begin
    memory_addr_offt_syn <= memory_addr_offt_syn;
  end
end


always @(*)
begin
  packet_read_done = (packet_read_count == synapse_per_lane);
end


always @(posedge clk)
begin
  if((~rst)||(process_done_find == 1'b1)) begin
    packet_read_count <= 8'b00000000;
  end
  else if(memory_addr_updt_syn == 1'b1) begin
	packet_read_count <= packet_read_count + 1'b1;
  end
  else begin
    packet_read_count <= packet_read_count;
  end
end


always @(*)
begin
  case(next_state_find)
    3'b001 : memory_addr_updt_syn = (packet_read_done == 1'b0);
	3'b010 : memory_addr_updt_syn = (packet_read_done == 1'b0);
	default: memory_addr_updt_syn = (1'b0);
  endcase
end


/** state == 3'b010,  read synapse information and matching with active columns **/


always @(*)
begin
  index_col_rcvd = buffer_data_lemt[word_size - 01 : word_size - 16];
  index_act_rcvd = buffer_data_lemt[word_size - 17 : word_size - 24];
  index_lrn_rcvd = buffer_data_lemt[word_size - 25 : word_size - 32];
end


always @(*)
begin
  index_col_lane = buffer_data_lane[word_size - 01 : word_size - 16];
  index_cel_lane = buffer_data_lane[word_size - 17 : word_size - 24];
end


always @(*)
begin
  index_col_pass = buffer_data_pass[word_size - 01 : word_size - 16];
  index_act_pass = buffer_data_pass[word_size - 17 : word_size - 24];
  index_lrn_pass = buffer_data_pass[word_size - 25 : word_size - 32];
end


always @(*)
begin
  column_match_rcvd = (index_col_rcvd == index_col_lane)&&(state_find == 3'b010);
  column_match_pass = (index_col_pass == index_col_lane)&&(state_find == 3'b010); /** The column passed need to match with new synapse **/
  column_match_find = (column_match_rcvd == 1'b1)||(column_match_pass == 1'b1);
end


always @(*)
begin
  actived_match_rcvd = (index_act_rcvd == index_cel_lane)||(index_act_rcvd == cell_per_column);
  actived_match_pass = (index_act_pass == index_cel_lane)||(index_act_pass == cell_per_column);
  actived_match_cell = (actived_match_rcvd == 1'b1)||(actived_match_pass == 1'b1);
end


always @(*)
begin
  learned_match_rcvd = (index_lrn_rcvd == index_cel_lane)||(index_lrn_rcvd == cell_per_column);
  learned_match_pass = (index_lrn_pass == index_cel_lane)||(index_lrn_pass == cell_per_column);
  learned_match_cell = (learned_match_rcvd == 1'b1)||(learned_match_pass == 1'b1);
end


always @(*)
begin
  actived_match_find = (actived_match_cell == 1'b1)&&(column_match_find == 1'b1);
  learned_match_find = (learned_match_cell == 1'b1)&&(column_match_find == 1'b1);
end


always @(*)
begin
  cells_match_done = (index_col_rcvd >= index_col_lane)&&(state_find == 3'b010);
  cells_match_find = (learned_match_find == 1'b1)||(actived_match_find == 1'b1);
end


always @(posedge clk)
begin
  if((~rst)||(process_done_find == 1'b1)) begin
    buffer_data_pass <= {word_size{1'b0}};
  end
  else if(cells_match_done == 1'b1) begin
    buffer_data_pass <= buffer_data_lemt;
  end
  else begin
    buffer_data_pass <= buffer_data_pass;
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_done_find == 1'b1)) begin
    match_flag_act <= 8'b00000000;
  end
  else if(actived_match_find == 1'b1) begin
    match_flag_act[index_match_flag] <= 1'b1;
  end
  else begin
    match_flag_act <= match_flag_act;
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_done_find == 1'b1)) begin
    match_flag_lrn <= 8'b00000000;
  end
  else if(learned_match_find == 1'b1) begin
    match_flag_lrn[index_match_flag] <= 1'b1;
  end
  else begin
    match_flag_lrn <= match_flag_lrn;
  end
end


always @(posedge clk)
begin
  if((~rst)||(index_flag_reset == 1'b1)) begin
    index_match_flag <= 3'b000;
  end
  else if(index_flag_count == 1'b1) begin
    index_match_flag <= index_match_flag + 1'b1;
  end
  else begin
    index_match_flag <= index_match_flag;
  end
end


always @(*)
begin
  case(state_find)
    3'b011 : index_flag_count = (dirty_match_find == 1'b0);
    3'b110 : index_flag_count = (dirty_match_find == 1'b1);
    default: index_flag_count = (index_match_find == 1'b1);
  endcase
end


always @(*)
begin
  case(state_find)
    3'b010 : index_flag_reset = (next_state_find == 3'b011);
    3'b011 : index_flag_reset = (next_state_find == 3'b000);
    3'b110 : index_flag_reset = (next_state_find == 3'b000);
    default: index_flag_reset = (1'b0);
  endcase
end


always @(*)
begin
  index_loop_done = (index_match_flag == (synapse_per_lane - 1));
  index_match_find = ((cells_match_done == 1'b1)||(cells_match_find == 1'b1))&&(index_loop_done == 1'b0);
end


/** state == 3'b011, check the matching condition and update counter **/


always @(*)
begin
  dirty_match_find = match_flag_lrn[index_match_flag]||match_flag_act[index_match_flag];
  flags_loop_done = (index_match_flag == (synapse_per_lane - 1));
end


/** state == 3'b100, read permance value for matching synapses only **/


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_offt_per <= {addr_size{1'b0}};
  end
  else if(memory_addr_offt_load == 1'b1) begin
    memory_addr_offt_per <= memory_addr_received;          /** Computed address or buffered address **/
  end
  else if(memory_addr_updt_per == 1'b1) begin
    memory_addr_offt_per <= memory_addr_offt_per + 1'b1;
  end
  else begin
    memory_addr_offt_per <= memory_addr_offt_per;
  end
end


always @(*)
begin
  case(state_find)
    3'b011 : memory_addr_updt_per = (dirty_match_find == 1'b0);
    3'b110 : memory_addr_updt_per = (1'b1);
    default: memory_addr_updt_per = (1'b0);
  endcase
end


/** state == 3'b101, update the counter based on matching condition **/


always @(*)
begin
  synaps_vld_flag = buffer_data_lane[word_size - 32];  /** If a valid synapse **/
  synaps_tmp_flag = buffer_data_lane[word_size - 31];  /** If a new created synapse **/
  synaps_per_data = buffer_data_lane[word_size - 09 : word_size - 24]; /** permanence value **/
end


always @(*)
begin
  match_find_act = (match_flag_act[index_match_flag] == 1'b1)&&(synaps_tmp_flag == 1'b0)&&
                   (synaps_vld_flag == 1'b1)&&(synaps_per_data >= permanence_threshold);

  match_find_pnt = (match_flag_act[index_match_flag] == 1'b1)&&(synaps_tmp_flag == 1'b0)&&
                   (synaps_vld_flag == 1'b1);

  match_find_lrn = (match_flag_lrn[index_match_flag] == 1'b1)&&(synaps_tmp_flag == 1'b0)&&
                   (synaps_vld_flag == 1'b1)&&(synaps_per_data >= permanence_threshold);
end


always @(posedge clk)
begin
  if((~rst)||(process_enable_find == 1'b1)) begin
    buffer_counter_act <= 8'b00000000;
  end
  else if((state_find == 3'b101)&&(match_find_act == 1'b1)) begin
    buffer_counter_act <= buffer_counter_act + 1'b1;
  end
  else begin
    buffer_counter_act <= buffer_counter_act;
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_enable_find == 1'b1)) begin
    buffer_counter_lrn <= 8'b00000000;
  end
  else if((state_find == 3'b101)&&(match_find_lrn == 1'b1)) begin
    buffer_counter_lrn <= buffer_counter_lrn + 1'b1;
  end
  else begin
    buffer_counter_lrn <= buffer_counter_lrn;
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_enable_find == 1'b1)) begin
    buffer_counter_pnt <= 8'b00000000;
  end
  else if((state_find == 3'b101)&&(match_find_pnt == 1'b1)) begin
    buffer_counter_pnt <= buffer_counter_pnt + 1'b1;
  end
  else begin
    buffer_counter_pnt <= buffer_counter_pnt;
  end
end


/** state == 3'b110, write the updated synapes flag back to sram if learn enable **/


always @(posedge clk)
begin
  if(~rst) begin
    memory_wt_enable <= 1'b0;
  end
  else begin
    case(next_state_find) /** for lane sram **/
      3'b110 : memory_wt_enable <= 1'b1;
      default: memory_wt_enable <= 1'b0;
    endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_wt_data <= {word_size{1'b0}};
  end
  else begin
    case(next_state_find) /** for lane sram **/
      3'b110 : memory_wt_data <= {memory_data_temp};
      default: memory_wt_data <= {word_size{1'b0}};
    endcase
  end
end


always @(*)
begin                                        /** synapse is active due to predict **/
  memory_data_temp = device_code_find ? {buffer_data_lane[word_size - 1 : word_size - 29], match_find_act, buffer_data_lane[word_size - 31 : word_size - 32]}
                                      : {buffer_data_lane[word_size - 1 : word_size - 28], match_find_act, buffer_data_lane[word_size - 30 : word_size - 32]};
end


endmodule


// `include "../param.vh"

module lane_unit( clk, rst,
                  process_enable_scan,
                  process_enable_lapp,
                  process_enable_adpt,
                  process_enable_bost,
                  process_enable_sort,
                  process_enable_updt,
                  process_learn_enable,
                  image_pixel_buffer,
                  index_lane_ready,
                  memory_data_lemt,
                  index_data_lane,
                  buffer_conf_reset,
                  result_maxn_ready,
                  packet_data_rcvd,
                  buffer_data_lemt,
                  memory_addr_computed,
                  memory_addr_received,
                  memory_addr_buffered,
                  device_code_find,
                  operate_buffer,
                  process_find_actc,
                  process_find_buld,
                  process_find_pred,
                  memory_lane_wten,
                  memory_lane_read,
                  memory_addr_rset,
                  memory_data_merg,
                  memory_ready_lemt,
                  memory_addr_load_rcvd,
                  /** output signal **/
                  process_done_scan,
                  process_done_lapp,
                  process_done_adpt,
                  process_done_bost,
                  process_done_sort,
                  process_done_updt,
                  process_done_find,
                  index_row_lane,
                  index_col_lane,
                  index_cfg_lane,
                  image_read_enable,
                  memory_find_busy,
                  bound_pass_lane,
                  index_dirty_ready,
                  buffer_max_scan,
                  buffer_max_adpt,
                  memory_buff_ready,
                  memory_data_sort,
                  packet_maxn_ready,
                  buffer_data_value,
                  buffer_counter_find
				);

parameter word_size = `word_size_para,
          addr_size = `addr_size_para,
          sram_size = `sram_size_para;


input  wire clk, rst;
input  wire process_enable_scan, process_enable_lapp;
input  wire process_enable_adpt, process_enable_bost;
input  wire process_enable_sort, process_enable_updt;
input  wire process_learn_enable;
input  wire index_lane_ready;
input  wire [word_size - 1 : 0] image_pixel_buffer;
input  wire [word_size - 1 : 0] memory_data_lemt;
input  wire buffer_conf_reset , result_maxn_ready;
input  wire [word_size - 1 : 0] packet_data_rcvd;
input  wire [word_size - 1 : 0] buffer_data_lemt;
input  wire [addr_size - 1 : 0] memory_addr_computed;
input  wire [addr_size - 1 : 0] memory_addr_received; /**tplr**/
input  wire [addr_size - 1 : 0] memory_addr_buffered;
input  wire memory_ready_lemt, device_code_find;
input  wire [7 : 0] index_data_lane;
input  wire [3 : 0] operate_buffer;
input  wire [3 : 0] memory_addr_load_rcvd; /** {memory_addr_load_tplr, memory_addr_load_find } **/
input  wire process_find_actc, process_find_buld, process_find_pred;
input  wire memory_lane_wten, memory_lane_read;
input  wire memory_addr_rset;
input  wire [word_size - 1 : 0] memory_data_merg;


output wire process_done_lapp, process_done_scan;
output wire process_done_adpt, process_done_bost;
output wire process_done_sort, process_done_updt;
output wire process_done_find;
output wire image_read_enable;
output wire index_dirty_ready;
output wire [23 : 0] buffer_counter_find;
output wire [7 : 0] index_row_lane, index_col_lane;
output wire [7 : 0] index_cfg_lane;
output wire bound_pass_lane, packet_maxn_ready;
output wire [word_size - 1 : 0] buffer_data_value;
output wire [word_size - 1 : 0] buffer_max_scan;
output wire [word_size - 1 : 0] buffer_max_adpt;
output wire memory_find_busy, memory_buff_ready;
output wire [word_size - 1 : 0] memory_data_sort;


wire [word_size - 1 : 0] buffer_data_lane;
wire index_done_scan, index_done_adpt;
wire buffer_lane_reset, bound_pass_done;
wire [1 : 0] buffer_read_lane;
wire [1 : 0] buffer_wten_lane;
wire [addr_size - 1 : 0] memory_addr_lane_0;
wire [addr_size - 1 : 0] memory_addr_lane_1;
wire [addr_size - 1 : 0] memory_addr_lane_2;
wire [addr_size - 1 : 0] memory_addr_lane_3;
wire [addr_size - 1 : 0] memory_addr_lane_4;
wire [addr_size - 1 : 0] memory_addr_lane_5;
wire [addr_size - 1 : 0] memory_addr_lane_6;


wire [word_size - 1 : 0] memory_wt_data_lane_0;
wire [word_size - 1 : 0] memory_wt_data_lane_1;
wire [word_size - 1 : 0] memory_wt_data_lane_2;
wire [word_size - 1 : 0] memory_wt_data_lane_3;
wire [word_size - 1 : 0] memory_wt_data_lane_4;
wire [word_size - 1 : 0] memory_wt_data_lane_5;
wire [word_size - 1 : 0] memory_wt_data_lane_6;

wire memory_wten_lane_0, memory_read_lane_0;
wire memory_wten_lane_1, memory_read_lane_1;
wire memory_wten_lane_2, memory_read_lane_2;
wire memory_wten_lane_3, memory_read_lane_3;
wire memory_wten_lane_4, memory_read_lane_4;
wire memory_wten_lane_5, memory_read_lane_5;
wire memory_wten_lane_6, memory_read_lane_6;


wire [word_size - 1 : 0] memory_rd_data_lane;
wire memory_ready_lane;


wire memory_wt_enable_prox, memory_device_prox;
wire memory_rd_enable_prox;
wire [addr_size - 1 : 0] memory_addr_lane_prox;
wire [word_size - 1 : 0] memory_wt_data_prox;
wire [word_size - 1 : 0] memory_rd_data_prox;
wire [word_size - 1 : 0] memory_data_prox;
wire memory_ready_prox;


wire [addr_size - 1 : 0] memory_addr_lane_syns;
wire [sram_size - 1 : 0] memory_wt_data_syns;
wire [word_size - 1 : 0] memory_rd_data_syns;
wire [sram_size - 1 : 0] memory_rd_data_0;
wire memory_wt_enable_syns, memory_rd_enable_syns;
wire memory_device_syns, memory_ready_syns;


wire [addr_size - 1 : 0] memory_addr_lane_perm;
wire [sram_size - 1 : 0] memory_wt_data_perm;
wire [word_size - 1 : 0] memory_rd_data_perm;
wire [sram_size - 1 : 0] memory_rd_data_1;
wire memory_wt_enable_perm, memory_rd_enable_perm;
wire memory_device_perm, memory_ready_perm;


assign index_done_scan = process_done_scan;

conf_unit conf ( .clk(clk), .rst(rst),
                 .process_done_lapp(process_done_lapp),
                 .process_done_find(process_done_find),
                 .index_lane_ready(index_lane_ready),
                 .index_data_lane(index_data_lane),
                 .index_info_rset(buffer_conf_reset),
                 .index_done_rank(index_done_scan),
                 .index_done_adpt(index_done_adpt),
                 /** output signal **/
                 .index_row_lane(index_row_lane),
                 .index_col_lane(index_col_lane),
                 .index_cfg_lane(index_cfg_lane),
                 .buffer_lane_reset(buffer_lane_reset),
                 .bound_pass_lane(bound_pass_lane),
                 .bound_pass_done(bound_pass_done)
               );


scan_unit scan ( .clk(clk), .rst(rst),
                 .process_enable_scan(process_enable_scan),
                 .buffer_conf_reset(buffer_conf_reset),
                 .image_pixel_buffer(image_pixel_buffer),
                 .process_learn_enable(process_learn_enable),
                 .memory_rd_data(memory_rd_data_lane),
                 .memory_data_ready(memory_ready_lane),
                 .result_sort_ready(result_maxn_ready),
                 /** output signal **/
                 .process_done_scan(process_done_scan),
                 .buffer_max_count(buffer_max_scan),
                 .packet_sort_ready(packet_maxn_ready),
                 .buffer_data_value(buffer_data_value),
                 .image_read_enable(image_read_enable),
                 .memory_addr_lane(memory_addr_lane_0),
                 .memory_wt_enable(memory_wten_lane_0),
                 .memory_rd_enable(memory_read_lane_0),
                 .memory_wt_data(memory_wt_data_lane_0)
               );


lapp_unit lapp ( .clk(clk), .rst(rst),
                 .process_enable_lapp(process_enable_lapp),
                 .packet_data_rcvd(packet_data_rcvd), /** From interface buffer **/
                 .buffer_data_fifo(buffer_data_lane),
                 .memory_data_ready(memory_ready_lane),
                 /** output signal **/
                 .process_done_lapp(process_done_lapp),
                 .buffer_read_fifo(buffer_read_lane[0]),
                 .buffer_wten_fifo(buffer_wten_lane[0]),
                 .memory_addr_lane(memory_addr_lane_1),
                 .memory_wt_enable(memory_wten_lane_1),
                 .memory_rd_enable(memory_read_lane_1),
                 .memory_wt_data(memory_wt_data_lane_1)
               );


adpt_unit adpt ( .clk(clk), .rst(rst),
                 .process_enable_adpt(process_enable_adpt),
                 .memory_data_ready(memory_ready_lane),
                 .index_row_lane(index_row_lane),
                 .index_col_lane(index_col_lane),
                 .bound_pass_lane(bound_pass_done),
                 .buffer_rd_data(buffer_data_lemt),
                 .memory_rd_data(memory_rd_data_lane),
                 /** output signal **/
                 .process_done_adpt(process_done_adpt),
                 .index_dirty_find(index_dirty_find),
                 .index_done_lane(index_done_adpt),
                 .buffer_max_count(buffer_max_adpt),
                 .index_dirty_ready(index_dirty_ready),
                 .memory_addr_lane(memory_addr_lane_2),
                 .memory_wt_enable(memory_wten_lane_2),
                 .memory_rd_enable(memory_read_lane_2),
                 .memory_wt_data(memory_wt_data_lane_2)
               );


bost_unit bost ( .clk(clk), .rst(rst),
                 .process_enable_bost(process_enable_bost),
                 .packet_data_rcvd(packet_data_rcvd),
                 .memory_rd_data(memory_rd_data_lane),
                 .memory_data_ready(memory_ready_lane),
                 /** output signal **/
                 .process_done_bost(process_done_bost),
                 .memory_addr_lane(memory_addr_lane_3),
                 .memory_wt_enable(memory_wten_lane_3),
                 .memory_rd_enable(memory_read_lane_3),
                 .memory_wt_data(memory_wt_data_lane_3)
               );


sort_unit sort ( .clk(clk), .rst(rst),
                 .process_enable_sort(process_enable_sort),
                 .memory_data_ready(memory_ready_lane),
                 .memory_addr_computed(memory_addr_computed),
                 .memory_rd_data(memory_rd_data_lane),
                 .memory_data_lane(memory_data_merg),
                 .memory_lane_read(memory_lane_read),
                 .memory_lane_wten(memory_lane_wten),
                 .memory_addr_rset(memory_addr_rset),
                 /** output signal **/
                 .process_done_sort(process_done_sort),
                 .memory_data_buffer(memory_data_sort),
                 .memory_lane_ready(memory_buff_ready),
                 .memory_addr_lane(memory_addr_lane_4),
                 .memory_wt_enable(memory_wten_lane_4),
                 .memory_rd_enable(memory_read_lane_4),
                 .memory_wt_data(memory_wt_data_lane_4)
               );


find_unit find ( .clk(clk), .rst(rst),
                 .memory_addr_load_rcvd(memory_addr_load_rcvd[2 : 0]),
                 .process_find_actc(process_find_actc),
                 .process_find_buld(process_find_buld),
                 .process_find_pred(process_find_pred),
                 .memory_ready_lane(memory_ready_lane),
                 .memory_ready_lemt(memory_ready_lemt),
                 .memory_ready_syns(memory_ready_syns),
                 .memory_data_lemt(memory_data_lemt),
                 .buffer_data_lane(buffer_data_lane),
                 .process_learn_enable(process_learn_enable),
                 .device_code_find(device_code_find),
                 .memory_addr_buffered(memory_addr_buffered),
                 .memory_addr_computed(memory_addr_computed),
                 /*** output signal ***/
                 .process_done_find(process_done_find),
                 .memory_addr_lane(memory_addr_lane_5),
                 .memory_wt_data(memory_wt_data_lane_5),
                 .memory_wt_enable(memory_wten_lane_5),
                 .memory_rd_enable(memory_read_lane_5),
                 .memory_find_busy(memory_find_busy),
                 .buffer_read_fifo(buffer_read_lane[1]),
                 .buffer_wten_fifo(buffer_wten_lane[1]),
                 .buffer_counter_find(buffer_counter_find)
               );


updt_unit updt ( .clk(clk), .rst(rst),
                 .memory_addr_load_rcvd(memory_addr_load_rcvd[3]),
                 .process_enable_updt(process_enable_updt),
                 .memory_addr_received(memory_addr_received),
                 .operate_buffer(operate_buffer),
                 .memory_rd_data(memory_rd_data_lane),
                 .memory_data_ready(memory_ready_lane),
                 /*** output signal **/
                 .process_done_updt(process_done_updt),
                 .memory_addr_lane(memory_addr_lane_6),
                 .memory_wt_enable(memory_wten_lane_6),
                 .memory_rd_enable(memory_read_lane_6),
                 .memory_wt_data(memory_wt_data_lane_6)
               );



bank_prox prox ( .clk(clk), .rst(rst),
                 .memory_addr_lane_4(memory_addr_lane_4),
                 .memory_rd_enable_4(memory_read_lane_4),
                 .memory_wt_enable_4(memory_wten_lane_4),
                 .memory_wt_data_4(memory_wt_data_lane_4),
                 .memory_addr_lane_3(memory_addr_lane_3),
                 .memory_rd_enable_3(memory_read_lane_3),
                 .memory_wt_enable_3(memory_wten_lane_3),
                 .memory_wt_data_3(memory_wt_data_lane_3),
                 .memory_addr_lane_2(memory_addr_lane_2),
                 .memory_rd_enable_2(memory_read_lane_2),
                 .memory_wt_enable_2(memory_wten_lane_2),
                 .memory_wt_data_2(memory_wt_data_lane_2),
                 .memory_addr_lane_1(memory_addr_lane_1),
                 .memory_rd_enable_1(memory_read_lane_1),
                 .memory_wt_enable_1(memory_wten_lane_1),
                 .memory_wt_data_1(memory_wt_data_lane_1),
                 .memory_addr_lane_0(memory_addr_lane_0),
                 .memory_rd_enable_0(memory_read_lane_0),
                 .memory_wt_enable_0(memory_wten_lane_0),
                 .memory_wt_data_0(memory_wt_data_lane_0),

                 .memory_data_prox(memory_data_prox),
                 /** Output Signal **/
                 .memory_addr_lane(memory_addr_lane_prox),
                 .memory_wt_enable(memory_wt_enable_prox),
				 .memory_rd_enable(memory_rd_enable_prox),
                 .memory_rd_data(memory_rd_data_prox),
                 .memory_wt_data(memory_wt_data_prox),
                 .memory_data_ready(memory_ready_prox),
                 .memory_device_enable(memory_device_prox)

               );

sram_prox prox_mems ( .clk(clk), .rst(rst),
                      .memory_device_enable(memory_device_prox),
                      .memory_addr_prox(memory_addr_lane_prox),
                      .memory_wt_data(memory_wt_data_prox),
                      .memory_wt_enable(memory_wt_enable_prox),
                      .memory_rd_enable(memory_rd_enable_prox),
                      /** output signal **/
                      .memory_rd_data(memory_data_prox)
                     );


bank_perm perm ( .clk(clk), .rst(rst),
                 .memory_wt_data_6(memory_wt_data_lane_6),
                 .memory_addr_lane_6(memory_addr_lane_6),
                 .memory_rd_enable_6(memory_read_lane_6),
                 .memory_wt_enable_6(memory_wten_lane_6),
                 .memory_wt_data_5(memory_wt_data_lane_5),
                 .memory_addr_lane_5(memory_addr_lane_5),
                 .memory_rd_enable_5(memory_read_lane_5),
                 .memory_wt_enable_5(memory_wten_lane_5),
                 .memory_wt_data_4(memory_wt_data_lane_4),
                 .memory_addr_lane_4(memory_addr_lane_4),
                 .memory_rd_enable_4(memory_read_lane_4),
                 .memory_wt_enable_4(memory_wten_lane_4),
				 .memory_rd_data_0(memory_rd_data_0),
                   /** Lane Memory Data recevied **/
                   /** Output Signal **/
                 .memory_addr_lane(memory_addr_lane_perm),
                 .memory_wt_enable(memory_wt_enable_perm),
                 .memory_rd_enable(memory_rd_enable_perm),
                 .memory_wt_data(memory_wt_data_perm),
				 .memory_rd_data(memory_rd_data_perm),
                 .memory_data_ready(memory_ready_perm),
                 .memory_device_enable(memory_device_perm)
               );


sram_dist perm_mems ( .clk(clk), .rst(rst),
                      .memory_device_enable(memory_device_perm),
                      .memory_addr_dist(memory_addr_lane_perm),
                      .memory_wt_data(memory_wt_data_perm),
                      .memory_wt_enable(memory_wt_enable_perm),
                      .memory_rd_enable(memory_rd_enable_perm),
                      /** output signal **/
                      .memory_rd_data(memory_rd_data_0)
                     );


bank_syns syns ( .clk(clk), .rst(rst),
                 .memory_wt_data_6(memory_wt_data_lane_6),
                 .memory_addr_lane_6(memory_addr_lane_6),
                 .memory_rd_enable_6(memory_read_lane_6),
                 .memory_wt_enable_6(memory_wten_lane_6),
                 .memory_wt_data_5(memory_wt_data_lane_5),
                 .memory_addr_lane_5(memory_addr_lane_5),
                 .memory_rd_enable_5(memory_read_lane_5),
                 .memory_wt_enable_5(memory_wten_lane_5),
                 .memory_wt_data_4(memory_wt_data_lane_4),
                 .memory_addr_lane_4(memory_addr_lane_4),
                 .memory_rd_enable_4(memory_read_lane_4),
                 .memory_wt_enable_4(memory_wten_lane_4),
				 .memory_rd_data_0(memory_rd_data_1),
                   /** Lane Memory Data recevied **/
                   /** Output Signal **/
                 .memory_addr_lane(memory_addr_lane_syns),
                 .memory_wt_enable(memory_wt_enable_syns),
                 .memory_rd_enable(memory_rd_enable_syns),
                 .memory_wt_data(memory_wt_data_syns),
				 .memory_rd_data(memory_rd_data_syns),
                 .memory_data_ready(memory_ready_syns),
                 .memory_device_enable(memory_device_syns)
               );


sram_dist syns_mems ( .clk(clk), .rst(rst),
                      .memory_device_enable(memory_device_syns),
                      .memory_addr_dist(memory_addr_lane_syns),
                      .memory_wt_data(memory_wt_data_syns),
                      .memory_wt_enable(memory_wt_enable_syns),
                      .memory_rd_enable(memory_rd_enable_syns),
                      /** output signal **/
                      .memory_rd_data(memory_rd_data_1)
                     );



bank_ctrl bank ( .clk(clk), .rst(rst),
                 .memory_rd_data_prox(memory_rd_data_prox),
                 .memory_rd_data_dist(memory_rd_data_syns),
                 .memory_rd_data_perm(memory_rd_data_perm),
                 .memory_ready_prox(memory_ready_prox),
                 .memory_ready_dist(memory_ready_syns),
                 .memory_ready_perm(memory_ready_perm),
                 /** Output Signal **/
                 .memory_data_lane(memory_rd_data_lane),
                 .memory_data_ready(memory_ready_lane)
               );



fifo_lane fifo ( .clk(clk), .rst(rst),
                 .buffer_wt_enable(buffer_wten_lane),
                 .buffer_rd_enable(buffer_read_lane),
                 .buffer_wt_data(memory_rd_data_lane),
                 .buffer_data_reset(buffer_lane_reset),
                 /** Output Signal **/
                 .buffer_rd_data(buffer_data_lane)
               );



endmodule


/** Lane logic used to update permanence value based on overlap cycle **/
// `include "../param.vh"

module lapp_unit ( clk, rst,
                   process_enable_lapp,
                   packet_data_rcvd, /** From interface buffer **/
                   buffer_data_fifo,
                   memory_data_ready,
                   /** Output Signal **/
                   process_done_lapp,
				   buffer_read_fifo,
				   buffer_wten_fifo,
                   memory_addr_lane,
                   memory_wt_data,
                   memory_rd_enable,
                   memory_wt_enable
		     	 );

parameter word_size = `word_size_para,
          addr_size = `addr_size_para,
          permanence_init = `perm_init_pro_para,
          constant_update = `constant_update_para;

parameter memory_addr_init_per = `memory_addr_init_vld_para,
          memory_addr_init_ovr = `memory_addr_init_ovr_para,
          memory_addr_init_val = `memory_addr_init_val_para,
          proxal_synapse_count = `proxal_synapse_count_para;


input wire clk, rst;
input wire process_enable_lapp;
input wire [word_size - 1 : 0] packet_data_rcvd; /** From interface buffer **/
input wire memory_data_ready;
input wire [word_size - 1 : 0] buffer_data_fifo;


output reg process_done_lapp;
output reg [addr_size - 1 : 0] memory_addr_lane;
output reg [word_size - 1 : 0] memory_wt_data;
output reg memory_rd_enable, memory_wt_enable;
output reg buffer_read_fifo, buffer_wten_fifo;


reg [word_size - 1 : 0] memory_updt_buffer;
reg [addr_size - 1 : 0] memory_addr_init, memory_addr_offt;
reg [addr_size - 1 : 0] memory_addr_offt_ovr;
reg [addr_size - 1 : 0] memory_addr_head_val;
reg [addr_size - 1 : 0] memory_addr_offt_val;
reg [addr_size - 1 : 0] memory_addr_head_per;
reg [addr_size - 1 : 0] memory_addr_offt_per;
reg [2 : 0] state_lapp, next_state_lapp;
reg [7 : 0] logic_timer_lapp;
reg logic_timer_count, logic_timer_reset;
reg packet_update_done, packet_loop_done;
reg dirty_packet_found;
reg memory_offt_val_rset, memory_offt_per_rset;
reg memory_addr_head_updt, memory_offt_over_updt;
reg buffer_data_ready;
reg [word_size - 1 : 0] packet_data_buffer;


always @(posedge clk)
begin
  if(~rst) begin
    state_lapp <= 3'b000;
  end
  else begin
    state_lapp <= next_state_lapp;
  end
end


always @(*)
begin
  case(state_lapp)
    3'b000 : begin
               if(process_enable_lapp == 1'b1) begin
				 next_state_lapp = 3'b001;
	           end
			   else begin
				 next_state_lapp = 3'b000;
			   end
			 end
    3'b001 : begin  /** Read overlap cycle and wait till the first data ready **/
               if(buffer_data_ready == 1'b1) begin
				 next_state_lapp = 3'b010;
	           end
			   else begin
				 next_state_lapp = 3'b001;
			   end
			 end
    3'b010 : begin  /** Compare overlap cycle and find column needed update **/
               if(dirty_packet_found == 1'b1) begin
				 next_state_lapp = 3'b011;
	           end
			   else begin
				 next_state_lapp = packet_loop_done ? 3'b000 : 3'b010;
			   end
			 end
	3'b011 : begin /** Write inital permanence value into lane memory **/
	           if(packet_update_done == 1'b1) begin
			     next_state_lapp = 3'b100;
			   end
			   else begin
			     next_state_lapp = 3'b011;
			   end
	         end
	3'b100 : begin /** Write updated permanece flag (reset to active) **/
	           if(packet_update_done == 1'b1) begin
			     next_state_lapp = packet_loop_done ? 3'b000 : 3'b010;
			   end
			   else begin
			     next_state_lapp = 3'b100;
			   end
	         end
	default: begin
	           next_state_lapp = 3'b000;
			 end
  endcase
end


always @(posedge clk)
begin
  if(~rst) begin
    process_done_lapp <= 1'b0;
  end
  else begin
    process_done_lapp <= (next_state_lapp == 3'b000)&&(state_lapp != 3'b000);
  end
end


always @(*)
begin
  packet_loop_done = (buffer_data_fifo == {word_size{1'b1}});
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_data_ready <= 1'b0;
  end
  else begin
    buffer_data_ready <= (memory_data_ready == 1'b1);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    packet_data_buffer <= {word_size{1'b0}};
  end
  else begin
    packet_data_buffer <= {packet_data_rcvd};
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_lane <= {addr_size{1'b0}};
  end
  else begin
    memory_addr_lane <= {memory_addr_init + memory_addr_offt};
  end
end


/** state_lapp == 3'b001, read overlap cycle and wait till the first data ready **/
/** state_lapp == 3'b010, read overlap cycle and find column needed update **/


always @(posedge clk)
begin
  if(~rst) begin
    memory_rd_enable <= 1'b0;
  end
  else begin
    case(state_lapp)
      3'b001 : memory_rd_enable <= 1'b1;
      3'b010 : memory_rd_enable <= 1'b1;
      default: memory_rd_enable <= 1'b0;
    endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_updt_buffer <= {word_size{1'b0}};
  end
  else if(next_state_lapp == 3'b010) begin
    memory_updt_buffer <= buffer_data_fifo[15 : 0] * constant_update;
  end
  else begin
    memory_updt_buffer <= memory_updt_buffer;
  end
end


always @(*)
begin
  dirty_packet_found = (memory_updt_buffer <= packet_data_buffer);
  buffer_read_fifo = (next_state_lapp == 3'b010);
  buffer_wten_fifo = (memory_data_ready == 1'b1)&&(state_lapp != 3'b000);
end


/** state_lapp == 3'b011, write initial permanence value into lane memory **/
/** state_lapp == 3'b100, write updated permanece flag (reset to active) **/


always @(posedge clk)
begin
  if(~rst) begin
    memory_wt_enable <= 1'b0;
  end
  else begin
    case(state_lapp)
      3'b011 : memory_wt_enable <= 1'b1;
      3'b100 : memory_wt_enable <= 1'b1;
      default: memory_wt_enable <= 1'b0;
    endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_wt_data <= {word_size{1'b0}};
  end
  else begin
    case(state_lapp)
      3'b011 : memory_wt_data <= {permanence_init};
      3'b100 : memory_wt_data <= {word_size{1'b1}};
      default: memory_wt_data <= {word_size{1'b0}};
    endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_init <= {addr_size{1'b0}};
  end
  else begin
    case(next_state_lapp)
	  3'b011 : memory_addr_init <= {memory_addr_head_val}; /** Read permanence value **/
	  3'b100 : memory_addr_init <= {memory_addr_head_per}; /** Permanence valid flag **/
	  default: memory_addr_init <= {memory_addr_init_ovr}; /** Read overlap cycle **/
    endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_offt <= {addr_size{1'b0}};
  end
  else begin
    case(next_state_lapp)
	  3'b011 : memory_addr_offt <= {memory_addr_offt_val};
	  3'b100 : memory_addr_offt <= {memory_addr_offt_per};
	  default: memory_addr_offt <= {memory_addr_offt_ovr};
    endcase
  end
end


always @(*)
begin
  memory_offt_over_updt = (next_state_lapp == 3'b010)||(next_state_lapp == 3'b001);
end


always @(posedge clk)
begin
  if((~rst)||(process_done_lapp == 1'b1)) begin   /** Should be reloaded for each image **/
    memory_addr_offt_ovr <= {addr_size{1'b0}};
  end
  else if(memory_offt_over_updt == 1'b1) begin
    memory_addr_offt_ovr <= memory_addr_offt_ovr + 16'h0001;
  end
  else begin
    memory_addr_offt_ovr <= memory_addr_offt_ovr;
  end
end


always @(*)
begin
  case(state_lapp)
    3'b010 : memory_addr_head_updt = (dirty_packet_found == 1'b0);
    3'b100 : memory_addr_head_updt = (packet_update_done == 1'b1);
    default: memory_addr_head_updt = (1'b0);
  endcase
end


always @(*)
begin
  memory_offt_val_rset = (packet_update_done == 1'b1)&&(state_lapp == 3'b011);
  memory_offt_per_rset = (packet_update_done == 1'b1)&&(state_lapp == 3'b100);
end


always @(posedge clk)
begin
  if((~rst)||(process_done_lapp == 1'b1)) begin
    memory_addr_head_val <= memory_addr_init_val;
  end
  else if(memory_addr_head_updt == 1'b1) begin
    memory_addr_head_val <= memory_addr_head_val + 16'h0028;
  end
  else begin
    memory_addr_head_val <= memory_addr_head_val;
  end
end


always @(posedge clk)
begin
  if((~rst)||(memory_offt_val_rset == 1'b1)) begin
    memory_addr_offt_val <= {addr_size{1'b0}};
  end
  else if(next_state_lapp == 3'b011) begin
    memory_addr_offt_val <= memory_addr_offt_val + 16'h0001;
  end
  else begin
    memory_addr_offt_val <= memory_addr_offt_val;
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_done_lapp == 1'b1)) begin
    memory_addr_head_per <= memory_addr_init_per;
  end
  else if(memory_addr_head_updt == 1'b1) begin
    memory_addr_head_per <= memory_addr_head_per + 16'h0002;
  end
  else begin
    memory_addr_head_per <= memory_addr_head_per;
  end
end


always @(posedge clk)
begin
  if((~rst)||(memory_offt_per_rset == 1'b1)) begin
    memory_addr_offt_per <= {addr_size{1'b0}};
  end
  else if(next_state_lapp == 3'b100) begin
    memory_addr_offt_per <= memory_addr_offt_per + 16'h0001;
  end
  else begin
    memory_addr_offt_per <= memory_addr_offt_per;
  end
end


always @(*)
begin
  case(state_lapp)
    3'b011 : packet_update_done = (logic_timer_lapp == (proxal_synapse_count - 1));
	3'b100 : packet_update_done = (logic_timer_lapp == 8'b00000001);
	default: packet_update_done = 1'b0;
  endcase
end


/** Memory control logic and logic timer in the overlap procesing **/


always @(posedge clk)
begin
  if((~rst)||(logic_timer_reset == 1'b1)) begin
    logic_timer_lapp <= 8'b00000000;
  end
  else if(logic_timer_count == 1'b1) begin
    logic_timer_lapp <= logic_timer_lapp + 1'b1;
  end
  else begin
    logic_timer_lapp <= logic_timer_lapp;
  end
end


always @(*)
begin
  case(state_lapp)
	3'b011 : logic_timer_count = 1'b1;
	3'b100 : logic_timer_count = 1'b1;
    default: logic_timer_count = 1'b0;
  endcase
end


always @(*)
begin
  case(state_lapp)
	3'b011 : logic_timer_reset = (next_state_lapp != 3'b011);
	3'b100 : logic_timer_reset = (next_state_lapp != 3'b100);
    default: logic_timer_reset = 1'b0;
  endcase
end


endmodule


/** logic unit to calculate overlap of each column, sort them within element, and update overlap cycle **/
// `include "../param.vh"


module scan_unit ( clk, rst,
                   process_enable_scan,
                   buffer_conf_reset,
				   image_pixel_buffer,
                   memory_rd_data,
                   memory_data_ready,
                   result_sort_ready,
                   process_learn_enable,
                   /** Output Signal **/
                   process_done_scan,
                   memory_rd_enable,
                   memory_wt_enable,
                   memory_wt_data,
                   memory_addr_lane,
                   packet_sort_ready,
                   buffer_max_count,
                   buffer_data_value,
	           image_read_enable
                 );


parameter  word_size = `word_size_para,
           lane_size = `lane_size_para,
           addr_size = `addr_size_para;

parameter  memory_addr_init_map = `memory_addr_init_map_para, /** Initial of mapping **/
           memory_addr_init_per = `memory_addr_init_vld_para, /** Initial of per valid **/
           memory_addr_init_flg = `memory_addr_init_flg_para, /** Initial of syn valid **/
           synapse_count_region = `synapse_count_region_para,
           memory_addr_init_bst = `memory_addr_init_bst_para,
           memory_addr_init_ovr = `memory_addr_init_ovr_para,
           overlap_minimun = `overlap_minimun_para;


input wire clk, rst;
input wire process_enable_scan, process_learn_enable;
input wire buffer_conf_reset;
input wire [word_size - 1 : 0] image_pixel_buffer;
input wire [word_size - 1 : 0] memory_rd_data;
input wire memory_data_ready, result_sort_ready;


output reg [addr_size - 1 : 0] memory_addr_lane;
output reg [word_size - 1 : 0] memory_wt_data;
output reg packet_sort_ready;
output reg memory_rd_enable, memory_wt_enable;
output reg process_done_scan;
output reg [word_size - 1 : 0] buffer_max_count;
output reg [word_size - 1 : 0] buffer_data_value;
output reg image_read_enable;


reg [word_size - 1 : 0] memory_data_buffer, memory_pipe_buffer;
reg [addr_size - 1 : 0] memory_addr_init, memory_addr_offt;
reg [addr_size - 1 : 0] memory_addr_offt_col;
reg [addr_size - 1 : 0] memory_addr_offt_flg;
reg [word_size - 1 : 0] memory_wt_buffer;

reg [3  : 0] state_scan, next_state_scan;
reg [15 : 0] loops_bit_count;
reg [7  : 0] valid_bits_count;
reg [4  : 0] index_buffer;
reg memory_read_ready;
reg iterate_done_scan, iterate_done_loop;
reg memory_addr_updt_flg, memory_addr_updt_col;
reg valid_bit;
reg memory_buff_ready, buffer_data_ready;
reg [word_size - 1 : 0] valid_value_offest;
reg [15 : 0] valid_value_buffer;


always @(posedge clk)
begin
  if(~rst) begin
    state_scan <= 4'b0000;
  end
  else begin
    state_scan <= next_state_scan;
  end
end


always @(*)
begin
  case(state_scan)
    4'b0000: begin
	           if(process_enable_scan == 1'b1) begin
			     next_state_scan = 4'b0001;
			   end
			   else begin
			     next_state_scan = 4'b0000;
			   end
			 end
    4'b0001: begin /** Read the mapping information of each column in element **/
			   next_state_scan = 4'b0010;
			 end
    4'b0010: begin /** Read the permanence flags of each column in element **/
	           if(buffer_data_ready == 1'b1) begin
			     next_state_scan = 4'b0011;
			   end
			   else begin
			     next_state_scan = 4'b0010;
			   end
			 end
    4'b0011: begin /** Trigger to scan input pixel and accumulate activity **/
	           if(iterate_done_scan == 1'b1) begin
			     next_state_scan = 4'b0100;
			   end
			   else begin
			     next_state_scan = 4'b0011;
			   end
			 end
	4'b0100: begin /** Write the active synapse flags of each column back **/
               if(iterate_done_loop == 1'b1) begin
			     next_state_scan = 4'b0101;
			   end
			   else begin
			     next_state_scan = 4'b0001;
			   end
             end
    4'b0101: begin /** Read the boost value of each column in the element**/
	           if(memory_data_ready == 1'b1) begin
	             next_state_scan = 4'b0110;
			   end
			   else begin
			     next_state_scan = 4'b0101;
			   end
	         end
    4'b0110: begin /** Compute the overlap value of each column in element **/
			   if(process_learn_enable ==1'b1) begin
	             next_state_scan = 4'b0111;
               end
               else begin
                 next_state_scan = 4'b1001;
               end
			 end
    4'b0111: begin /** Read the overlap cycle of each column in the element **/
	           if(buffer_data_ready == 1'b1) begin
	             next_state_scan = 4'b1000;
               end
			   else begin
 	             next_state_scan = 4'b0111;
               end
			 end
    4'b1000: begin /** Update and write the overlap cycle of each column back **/
	           if(buffer_data_ready == 1'b0) begin
	             next_state_scan = 4'b1001;
               end
               else begin
                 next_state_scan = 4'b1000;
               end
			 end
    4'b1001: begin /** Sort the overlap value received from all execution lanes **/
	           if(result_sort_ready == 1'b1) begin
	             next_state_scan = 4'b0000;
               end
			   else begin
 	             next_state_scan = 4'b1001;
               end
			 end
    default: begin
	           next_state_scan = 4'b0000;
			 end
  endcase
end


always @(posedge clk)
begin
  if(~rst) begin /** used to indicate column done, image read done and scan proc done **/
    process_done_scan <= 1'b0;
  end
  else begin
    process_done_scan <= (next_state_scan == 4'b0000)&&(state_scan != 4'b0000);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_lane <= {addr_size{1'b0}};
  end
  else begin
    memory_addr_lane <= {memory_addr_init + memory_addr_offt};
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_buff_ready <= 1'b0;
  end
  else begin
    memory_buff_ready <= (memory_data_ready == 1'b1)&&(state_scan != 4'b0000);
  end
end


always @(*)
begin
  buffer_data_ready = (memory_data_ready == 1'b0)&&(memory_buff_ready == 1'b1);
end


always @(posedge clk)
begin
  if(~rst) begin
    image_read_enable <= 1'b0;
  end
  else begin
    image_read_enable <= (next_state_scan == 4'b0001);
  end
end


/** state_scan == 4'b0001, read the mapping information of each column in element **/
/** state_scan == 4'b0010, read the permanence flags of each column in element **/
/** state_scan == 4'b0101, read the boost value of each column in the element**/
/** state_scan == 4'b0111, read the overlap cycle of each column in the element **/


always @(posedge clk)
begin
  if(~rst) begin
    memory_rd_enable <= 1'b0;
  end
  else begin
    case(state_scan)
      4'b0001: memory_rd_enable <= (memory_read_ready == 1'b1);
      4'b0010: memory_rd_enable <= (memory_read_ready == 1'b1);
      4'b0101: memory_rd_enable <= (memory_read_ready == 1'b1);
      4'b0111: memory_rd_enable <= (memory_read_ready == 1'b1);
      default: memory_rd_enable <= (1'b0);
    endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_read_ready <= 1'b0;
  end
  else begin
    case(state_scan)
      4'b0000: memory_read_ready <= (next_state_scan != 4'b0000);
      4'b0001: memory_read_ready <= (next_state_scan != 4'b0001);
      4'b0100: memory_read_ready <= (next_state_scan != 4'b0100);
      4'b0110: memory_read_ready <= (next_state_scan != 4'b0110);
      default: memory_read_ready <= (1'b0);
    endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_init <= {addr_size{1'b0}};
  end
  else begin
    case(next_state_scan) /** For the lane memory **/
      4'b0001: memory_addr_init <= {memory_addr_init_map}; /** initial address of mapping information **/
      4'b0010: memory_addr_init <= {memory_addr_init_per}; /** initial address of permanence flag **/
      4'b0100: memory_addr_init <= {memory_addr_init_flg}; /** initial address of active synapse flag **/
      4'b0101: memory_addr_init <= {memory_addr_init_bst}; /** initial address of boost value **/
      default: memory_addr_init <= {memory_addr_init_ovr}; /** initial address of overlap cycle **/
    endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_offt <= {addr_size{1'b0}};
  end
  else begin
    case(next_state_scan) /** For the lane memory **/
      4'b0001: memory_addr_offt <= {memory_addr_offt_flg};
      4'b0010: memory_addr_offt <= {memory_addr_offt_flg};
      4'b0100: memory_addr_offt <= {memory_addr_offt_flg};
      default: memory_addr_offt <= {memory_addr_offt_col};
    endcase
  end
end


always @(posedge clk)
begin
  if((~rst)||(buffer_conf_reset == 1'b1)) begin
    memory_addr_offt_flg <= {addr_size{1'b0}};
  end
  else if(memory_addr_updt_flg == 1'b1) begin
    memory_addr_offt_flg <= memory_addr_offt_flg + 32'h0001;
  end
  else begin
    memory_addr_offt_flg <= memory_addr_offt_flg;
  end
end


always @(posedge clk)
begin
  if((~rst)||(buffer_conf_reset == 1'b1)) begin
    memory_addr_offt_col <= {addr_size{1'b0}};
  end
  else if(memory_addr_updt_col == 1'b1) begin
    memory_addr_offt_col <= memory_addr_offt_col + 32'h0001;
  end
  else begin
    memory_addr_offt_col <= memory_addr_offt_col;
  end
end


always @(*)
begin
  memory_addr_updt_flg = (next_state_scan == 4'b0100);
  memory_addr_updt_col = (state_scan == 4'b1001)&&(next_state_scan == 4'b0000);
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_data_buffer <= {word_size{1'b0}};
  end
  else if((memory_data_ready == 1'b1)&&(state_scan != 4'b0000)) begin
    memory_data_buffer <= memory_rd_data;
  end
  else begin
    memory_data_buffer <= memory_data_buffer;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_pipe_buffer <= {word_size{1'b0}};
  end
  else if((memory_data_ready == 1'b1)&&(state_scan != 4'b0000)) begin
    memory_pipe_buffer <= memory_data_buffer;
  end
  else begin
    memory_pipe_buffer <= memory_pipe_buffer;
  end
end


/** state_scan == 4'b0011, trigger to scan input pixel and accumulate activity**/


always @(posedge clk)
begin
  if((~rst)||(iterate_done_scan == 1'b1)) begin
    index_buffer <= 5'b00000;
  end
  else if(state_scan == 4'b0011) begin
    index_buffer <= index_buffer + 1'b1;
  end
  else begin
    index_buffer <= index_buffer;
  end
end


always @(*)
begin
  valid_bit = image_pixel_buffer[index_buffer]&&
              memory_data_buffer[index_buffer]&&
              memory_pipe_buffer[index_buffer];
end


always @(posedge clk)
begin
  if((~rst)||(process_enable_scan == 1'b1)) begin
    valid_bits_count <= 8'h00;
  end
  else if((state_scan == 4'b0011)&&(valid_bit == 1'b1)) begin
    valid_bits_count <= valid_bits_count + 1'b1;
  end
  else begin
    valid_bits_count <= valid_bits_count;
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_done_scan == 1'b1)) begin
    loops_bit_count <= 16'h0000;
  end
  else if(next_state_scan == 4'b0011) begin
    loops_bit_count <= loops_bit_count + 1'b1;
  end
  else begin
    loops_bit_count <= loops_bit_count;
  end
end


always @(*)
begin
  if(loops_bit_count == synapse_count_region) begin
    iterate_done_loop = 1'b1;
  end
  else begin
    iterate_done_loop = 1'b0;
  end
end


always @(*)
begin /** The current buffer is looped, need to be re-refreshed **/
  if((iterate_done_loop == 1'b1)||(index_buffer == 5'b11111)) begin
    iterate_done_scan = 1'b1;
  end
  else begin
    iterate_done_scan = 1'b0;
  end
end


/** state_scan == 4'b0100: write the active synapse flags of each column back **/
/** state_scan == 4'b1000: update and write the overlap cycle of each column back **/


always @(posedge clk)
begin
  if(~rst) begin
    memory_wt_enable <= 1'b0;
  end
  else begin
    case(state_scan)
	  4'b0100: memory_wt_enable <= (next_state_scan != 4'b0100);
	  4'b1000: memory_wt_enable <= (next_state_scan != 4'b1000);
	  default: memory_wt_enable <= 1'b0;
	endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_wt_data <= {word_size{1'b0}};
  end
  else begin
    case(state_scan)
      4'b0100: memory_wt_data <= {memory_wt_buffer};
      4'b1000: memory_wt_data <= {memory_wt_buffer};
      default: memory_wt_data <= {word_size{1'b0}};
    endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_wt_buffer <= {word_size{1'b0}};
  end
  else begin
    case(next_state_scan)
      4'b0100: memory_wt_buffer <= {memory_pipe_buffer & image_pixel_buffer};
      4'b1000: memory_wt_buffer <= {memory_data_buffer + valid_value_offest};
      default: memory_wt_buffer <= {word_size{1'b0}};
    endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_max_count <= {word_size{1'b0}};
  end
  else if((state_scan == 4'b1000)&&(memory_wt_buffer > buffer_max_count)) begin
    buffer_max_count <= memory_wt_buffer;
  end
  else begin
    buffer_max_count <= buffer_max_count;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    valid_value_offest <= 32'h00000000;
    valid_value_buffer <= 16'h0000;
  end
  else begin
    valid_value_buffer <= (valid_bits_count >= overlap_minimun) ? {8'h00, valid_bits_count} : {16'h0000};
    valid_value_offest <= (valid_bits_count >= overlap_minimun) ? {32'h00000001} :  {32'h00000000};
  end
end


/** state_scan == 4'b0110, compute the overlap value of each column in element **/


always @(posedge clk)
begin
  if(~rst) begin /** The overlap value for each column **/
    buffer_data_value <= 32'h00000000;
  end
  else if(state_scan == 4'b0110) begin
    buffer_data_value <= valid_value_buffer * memory_data_buffer[15 : 0];
  end
  else begin
    buffer_data_value <= buffer_data_value;
  end
end


/** state_scan == 4'b1001, sort the overlap value received from all execution lanes **/


always @(posedge clk)
begin
  if(~rst) begin
    packet_sort_ready <= 1'b0;
  end
  else begin
    packet_sort_ready <= (next_state_scan == 4'b1001)&&(state_scan != 4'b1001);
  end
end




endmodule


/** logic unit used sort the index of synapse in each lane, smaller goes firt **/
// `include "../param.vh"

module sort_unit ( clk, rst,
                   process_enable_sort,
                   memory_data_ready,
                   memory_addr_computed,
                   memory_rd_data,
                   memory_data_lane,
                   memory_lane_read,
                   memory_lane_wten,
                   memory_addr_rset,
                   /** output signal **/
                   process_done_sort,
                   memory_addr_lane,
                   memory_wt_data,
                   memory_wt_enable,
                   memory_rd_enable,
                   memory_data_buffer,
                   memory_lane_ready
		   	     );

parameter word_size = `word_size_para,
          lane_size = `lane_size_para,
          addr_size = `addr_size_para,
          synapse_per_lane = `synapse_per_lane_para,
          memory_addr_init_per = `memory_addr_init_per_para,
          memory_addr_init_tmp = `memory_addr_init_tmp_para,
          memory_addr_init_syn = `memory_addr_init_syn_para,
          permanence_initial = `perm_init_dis_para;


input wire clk, rst;
input wire process_enable_sort;
input wire [addr_size - 1 : 0] memory_addr_computed;
input wire [word_size - 1 : 0] memory_rd_data;
input wire [word_size - 1 : 0] memory_data_lane;
input wire memory_data_ready;
input wire memory_lane_read, memory_lane_wten;
input wire memory_addr_rset;


output reg process_done_sort;
output reg [addr_size - 1 : 0] memory_addr_lane;
output reg [word_size - 1 : 0] memory_wt_data;
output reg memory_rd_enable, memory_wt_enable;
output reg [word_size - 1 : 0] memory_data_buffer;
output reg memory_lane_ready;


reg [addr_size - 1 : 0] memory_addr_init, memory_addr_offt;
reg [addr_size - 1 : 0] memory_addr_offt_read;
reg [addr_size - 1 : 0] memory_addr_offt_wten;
reg [addr_size - 1 : 0] memory_addr_offt_temp;
//reg [word_size - 1 : 0] memory_data_buffer;
reg [word_size - 1 : 0] buffer_data_bonder, buffer_data_update;
reg [2 : 0] state_sort, next_state_sort;
reg buffer_data_ready, bonder_data_ready;
reg [3 : 0] logic_timer_sort;
reg logic_timer_count, logic_timer_reset;
reg memory_read_done, bonder_data_found, memory_read_buff;
reg memory_addr_read_updt, memory_addr_read_rset;
reg memory_addr_wten_updt, memory_addr_wten_rset;
reg [3 : 0] synapse_loop_count;
reg synapse_loop_done, synapse_init_done;
reg synapse_updt_done, synapse_valid_flag;
reg process_done_item, memory_buff_ready;
reg memory_addr_updt_temp, memory_addr_temp_rset;


always @(posedge clk)
begin
  if(~rst) begin
    state_sort <= 3'b000;
  end
  else begin
    state_sort <= next_state_sort;
  end
end


always @(*)
begin
  case(state_sort)
    3'b000 : begin
	           if(process_enable_sort == 1'b1) begin
	             next_state_sort = 3'b001;
	           end
	           else begin
	             next_state_sort = 3'b000;
	           end
	         end
    3'b001 : begin /** Read the synapse index from buffer address for sorting **/
	           if(memory_read_done == 1'b1) begin
	             next_state_sort = 3'b010;
	           end
	           else begin
	             next_state_sort = 3'b001;
	           end
	         end
    3'b010 : begin /** Wait until all the synapse in this lane is looped **/
	           if(memory_buff_ready == 1'b1) begin
	             next_state_sort = 3'b011;
	           end
	           else begin
	             next_state_sort = 3'b010;
	           end
	         end
    3'b011 : begin /** Update the result buffer based on the loop result **/
	           if(logic_timer_sort == 4'b0001) begin
	             next_state_sort = 3'b100;
	           end
	           else begin
	             next_state_sort = 3'b011;
	           end
	         end
    3'b100 : begin /** Write the sorted index back to the address in the lane **/
	           if(logic_timer_sort == 4'b0000) begin
	             next_state_sort = 3'b101;
	           end
	           else begin
	             next_state_sort = 3'b100;
	           end
	         end
    3'b101 : begin /** Write the permanence back to the address in the lane **/
	           if(synapse_loop_done == 1'b1) begin
	             next_state_sort = 3'b110;
	           end
	           else begin
	             next_state_sort = 3'b001;
	           end
	         end
    3'b110 : begin /** Write the initial packet back to the temporal address **/
	           if(synapse_init_done == 1'b1) begin
	             next_state_sort = 3'b000;
	           end
	           else begin
	             next_state_sort = 3'b110;
	           end
	         end
    default: begin
	           next_state_sort = 3'b000;
	         end
  endcase
end


always @(posedge clk)
begin
  if(~rst) begin
    process_done_sort <= 1'b0;
  end
  else begin
    process_done_sort <= (state_sort == 3'b110)&&(next_state_sort == 3'b000);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_lane <= {lane_size{1'b0}};
  end
  else begin
    memory_addr_lane <= {memory_addr_init + memory_addr_offt};
  end
end


always @(*)
begin
  memory_buff_ready = (memory_data_ready == 1'b0)&&(buffer_data_ready == 1'b1);
  process_done_item = (state_sort == 3'b101)&&(next_state_sort != 3'b101);
end


/** state_sort == 3'b001, read the synapse index from buffer address for sorting **/
/** state_sort == 3'b010, wait until all the synapse in this lane is looped **/


always @(posedge clk)
begin
  if(~rst) begin
     memory_read_buff <= (1'b0);
  end
  else begin
     memory_read_buff <= (memory_lane_read == 1'b1);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_init <= {addr_size{1'b0}};
  end
  else begin
    case(next_state_sort)
      3'b000 : memory_addr_init <= {memory_addr_init_tmp};
      3'b001 : memory_addr_init <= {memory_addr_init_tmp};
      3'b100 : memory_addr_init <= {memory_addr_init_syn};
      3'b101 : memory_addr_init <= {memory_addr_init_per};
      3'b110 : memory_addr_init <= {memory_addr_init_tmp};
      default: memory_addr_init <= {addr_size{1'b0}};
    endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_offt <= {addr_size{1'b0}};
  end
  else begin
    case(next_state_sort)
      3'b000 : memory_addr_offt <= {memory_addr_offt_temp};
      3'b001 : memory_addr_offt <= {memory_addr_offt_read};
      3'b100 : memory_addr_offt <= {memory_addr_offt_wten};
      3'b101 : memory_addr_offt <= {memory_addr_offt_wten};
      3'b110 : memory_addr_offt <= {memory_addr_offt_temp};
      default: memory_addr_offt <= {addr_size{1'b0}};
    endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_rd_enable <= 1'b0;
  end
  else begin
    case(state_sort)
      3'b000 : memory_rd_enable <= memory_read_buff; //memory_lane_read;
      3'b001 : memory_rd_enable <= 1'b1;
      default: memory_rd_enable <= 1'b0;
    endcase
  end
end


always @(posedge clk)
begin
  if((~rst)||(memory_addr_read_rset == 1'b1)) begin
    memory_addr_offt_read <= {addr_size{1'b0}};
  end
  else if(memory_addr_read_updt == 1'b1) begin
    memory_addr_offt_read <= memory_addr_offt_read + 1'b1;
  end
  else begin
    memory_addr_offt_read <= memory_addr_offt_read;
  end
end


always @(*)
begin
  memory_read_done = (logic_timer_sort == (synapse_per_lane - 1));
  memory_addr_read_updt = (next_state_sort == 3'b001);
  memory_addr_read_rset = (next_state_sort == 3'b101);
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_data_buffer <= {word_size{1'b0}};
  end
  else if(memory_data_ready == 1'b1) begin
    memory_data_buffer <= memory_rd_data;
  end
  else begin
    memory_data_buffer <= memory_data_buffer;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    buffer_data_ready <= 1'b0;
  end
  else begin
    buffer_data_ready <= (memory_data_ready == 1'b1)&&(state_sort != 3'b000);
  end
end


always @(posedge clk)
begin
  if((~rst)||(process_done_item == 1'b1)) begin
    buffer_data_update <= {word_size{1'b1}};
  end
  else if(bonder_data_found == 1'b1) begin
    buffer_data_update <= {memory_data_buffer[word_size - 9 : 0],8'h00};
  end
  else begin
    buffer_data_update <= {buffer_data_update};
  end
end


always @(*)
begin
  bonder_data_found = (buffer_data_update > {memory_data_buffer[word_size - 9 : 0], 8'h00})&&(buffer_data_ready == 1'b1)&&
                      (buffer_data_bonder < {memory_data_buffer[word_size - 9 : 0], 8'h00})&&(memory_data_buffer != {word_size{1'b1}});
end


always @(posedge clk)
begin /** indicate if valid data is found during this round **/
  if((~rst)||(process_done_item == 1'b1)) begin
    synapse_valid_flag <= 1'b0;
  end
  else if(bonder_data_found == 1'b1) begin
    synapse_valid_flag <= 1'b1;
  end
  else begin
    synapse_valid_flag <= synapse_valid_flag;
  end
end


/** state_sort == 3'b011, update the result buffer based on the loop result **/


always @(posedge clk)
begin
  if((~rst)||(process_done_sort == 1'b1)) begin
    buffer_data_bonder <= {word_size{1'b0}};
  end
  else if(bonder_data_ready == 1'b1) begin
    buffer_data_bonder <= buffer_data_update;
  end
  else begin
    buffer_data_bonder <= buffer_data_bonder;
  end
end


always @(*)
begin
  bonder_data_ready = (state_sort == 3'b011)&&(logic_timer_sort == 4'b0000);
end


always @(posedge clk)
begin
  if((~rst)||(process_done_sort == 1'b1)) begin
    synapse_loop_count <= 4'b0000;
  end
  else if(synapse_updt_done == 1'b1) begin
    synapse_loop_count <= synapse_loop_count + 1'b1;
  end
  else begin
    synapse_loop_count <= synapse_loop_count;
  end
end


always @(*)
begin
  synapse_updt_done = (state_sort == 3'b011)&&(logic_timer_sort == 4'b0001);
  synapse_loop_done = (synapse_loop_count == synapse_per_lane);
end


/** state_sort == 3'b100, write the sorted index back to the address in the lane **/


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_offt_wten <= {addr_size{1'b0}};
  end
  else if(memory_addr_wten_rset == 1'b1) begin
    memory_addr_offt_wten <= memory_addr_computed;
  end
  else if(memory_addr_wten_updt == 1'b1) begin
    memory_addr_offt_wten <= memory_addr_offt_wten + 1'b1;
  end
  else begin
    memory_addr_offt_wten <= memory_addr_offt_wten;
  end
end


always @(*)
begin
  memory_addr_wten_rset = (next_state_sort == 3'b001)&&(state_sort == 3'b000);
  memory_addr_wten_updt = (next_state_sort == 3'b101);
end


/** state_sort == 3'b110, write the initial packet back to the temporal address **/


always @(*)
begin
  synapse_init_done = (logic_timer_sort == (synapse_per_lane - 1));
end


always @(posedge clk)
begin
  if((~rst)||(memory_addr_temp_rset == 1'b1)) begin
     memory_addr_offt_temp <= {addr_size{1'b0}};
  end
  else if(memory_addr_updt_temp == 1'b1) begin
     memory_addr_offt_temp <= memory_addr_offt_temp + 1'b1;
  end
  else begin
     memory_addr_offt_temp <= memory_addr_offt_temp;
  end
end


always @(*)
begin
  case(next_state_sort)
    3'b000 : memory_addr_updt_temp = memory_lane_wten;
    3'b110 : memory_addr_updt_temp = 1'b1;
    default: memory_addr_updt_temp = 1'b0;
  endcase
end


always @(*)
begin
  case(state_sort)
    3'b110 : memory_addr_temp_rset = (next_state_sort == 3'b000);
    3'b000 : memory_addr_temp_rset = (memory_addr_rset == 1'b1);
    default: memory_addr_temp_rset = 1'b0;
  endcase
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_wt_enable <= 1'b0;
  end
  else begin
    case(state_sort)
          3'b000 : memory_wt_enable <= memory_lane_wten;
	  3'b100 : memory_wt_enable <= 1'b1;
	  3'b101 : memory_wt_enable <= 1'b1;
          3'b110 : memory_wt_enable <= 1'b1;
	  default: memory_wt_enable <= 1'b0;
	endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_wt_data <= {word_size{1'b0}};
  end
  else begin
    case(state_sort)
      3'b000 : memory_wt_data <= {memory_data_lane};
      3'b100 : memory_wt_data <= {synapse_valid_flag ? buffer_data_update : {word_size{1'b0}}};
      3'b101 : memory_wt_data <= {8'h00, permanence_initial, 7'b0000001, synapse_valid_flag};
      3'b110 : memory_wt_data <= {32'hffffffff};
      default: memory_wt_data <= {word_size{1'b0}};
	endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_lane_ready <= (1'b0);
  end
  else begin
    memory_lane_ready <= (memory_data_ready == 1'b1);
  end
end


always @(posedge clk)
begin
  if((~rst)||(logic_timer_reset == 1'b1)) begin
    logic_timer_sort <= 4'b0000;
  end
  else if(logic_timer_count == 1'b1) begin
    logic_timer_sort <= logic_timer_sort + 1'b1;
  end
  else begin
    logic_timer_sort <= logic_timer_sort;
  end
end


always @(*)
begin
  case(state_sort)
    3'b001 : logic_timer_reset = (next_state_sort != 3'b001);
    3'b011 : logic_timer_reset = (next_state_sort != 3'b011);
    3'b110 : logic_timer_reset = (next_state_sort != 3'b110);
	default: logic_timer_reset = 1'b0;
  endcase
end


always @(*)
begin
  case(state_sort)
    3'b001 : logic_timer_count = 1'b1;
    3'b011 : logic_timer_count = 1'b1;
    3'b110 : logic_timer_count = 1'b1;
	default: logic_timer_count = 1'b0;
  endcase
end


endmodule


// `include "../param.vh"

module sram_dist ( clk, rst,
                   memory_device_enable,
                   memory_addr_dist,
                   memory_wt_data,
                   memory_wt_enable,
                   memory_rd_enable,
				   /** output signal **/
                   memory_rd_data
                 );


parameter addr_size = 32,
		  word_size = 24,
		  bank_size = 16;


input wire clk, rst;
input wire [addr_size - 1 : 0] memory_addr_dist; // Change as you change size of SRAM
input wire memory_device_enable;
input wire [word_size - 1 : 0] memory_wt_data;
input wire memory_wt_enable, memory_rd_enable;

output reg [word_size - 1 : 0] memory_rd_data;


reg [word_size - 1 : 0] register_dist [bank_size - 1 : 0];

reg [3 : 0] memory_addr_valid;


integer index;


always @(*)
begin
  memory_addr_valid = (memory_addr_dist[4 : 0]);
end


always @(posedge clk)
begin
  if(~rst) begin
	memory_rd_data <= {word_size{1'b0}};
  end
  else if((memory_device_enable == 1'b1)&&(memory_rd_enable == 1'b1)) begin
	memory_rd_data <= {register_dist[memory_addr_valid]};
  end
  else begin
	memory_rd_data <= {memory_rd_data};
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    for(index = 0; index < bank_size; index = index + 1)
      register_dist[index] <= {word_size{1'b0}};
  end
  else if((memory_device_enable == 1'b1)&&(memory_wt_enable == 1'b1)) begin
    for(index = 0; index < bank_size; index = index + 1)
      register_dist[index] <= register_dist[index];
	  register_dist[memory_addr_valid] <= {memory_wt_data};
  end
  else begin
    for(index = 0; index < bank_size; index = index + 1)
      register_dist[index] <= register_dist[index];
  end
end



endmodule


// `include "../param.vh"

module sram_prox ( clk, rst,
                   memory_device_enable,
                   memory_addr_prox,
                   memory_wt_data,
                   memory_wt_enable,
                   memory_rd_enable,
				   /** output signal **/
                   memory_rd_data
                 );


parameter addr_size = 32,
		  word_size = 32,
		  bank_size = 16;


input wire clk, rst;
input wire [addr_size - 1 : 0] memory_addr_prox; // Change as you change size of SRAM
input wire memory_device_enable;
input wire [word_size - 1 : 0] memory_wt_data;
input wire memory_wt_enable, memory_rd_enable;

output reg [word_size - 1 : 0] memory_rd_data;


reg [31 : 0] register_prox [15 : 0];   /** 0~8, 9~13, 14~15 **/



reg [7 : 0] memory_addr_init;
reg [3 : 0] memory_addr_valid;
reg memory_addr_spec;


integer index;


always @(*)
begin
  memory_addr_init = (memory_addr_prox[31 : 23]);
  memory_addr_spec = (memory_rd_enable == 1'b1)&&(memory_addr_prox == 32'h00000120); /** special case for overlap cycle **/
end


always @(*)
begin
  case(memory_addr_init)
	8'h00  : memory_addr_valid = memory_addr_prox[8  : 5];
	8'h10  : memory_addr_valid = memory_addr_prox[11 : 8] + 4'b1001;
	8'h20  : memory_addr_valid = memory_addr_prox[3  : 0] + 4'b1110;
	default: memory_addr_valid = 4'b0000;
  endcase
end


always @(posedge clk)
begin
  if(~rst) begin
	memory_rd_data <= {word_size{1'b0}};
  end
  else if((memory_device_enable == 1'b1)&&(memory_addr_spec == 1'b1)) begin
	memory_rd_data <= {word_size{1'b1}};
  end
  else if((memory_device_enable == 1'b1)&&(memory_rd_enable == 1'b1)) begin
	memory_rd_data <= {register_prox[memory_addr_valid]};
  end
  else begin
	memory_rd_data <= {memory_rd_data};
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    register_prox[0]  <= {32'hffffffff};
    register_prox[1]  <= {32'hffffffff};
    register_prox[2]  <= {32'hffffffff};
    register_prox[3]  <= {32'hffffffff};
    register_prox[4]  <= {32'hffffffff};
    register_prox[5]  <= {32'hffffffff};
    register_prox[6]  <= {32'h000003E8};
	register_prox[7]  <= {32'h00000000};
	register_prox[8]  <= {32'h00000000};
	register_prox[9]  <= {32'h00000078};
	register_prox[10] <= {32'h00000078};
	register_prox[11] <= {32'h00000078};
	register_prox[12] <= {32'h00000078};
	register_prox[13] <= {32'h00000078};
    register_prox[14] <= {32'hffffffff};
    register_prox[15] <= {32'hffffffff};
  end
  else if((memory_device_enable == 1'b1)&&(memory_wt_enable == 1'b1)) begin
    for(index = 0; index < bank_size; index = index + 1)
      register_prox[index] <= register_prox[index];
	  register_prox[memory_addr_valid] <= {memory_wt_data};
  end
  else begin
    for(index = 0; index < bank_size; index = index + 1)
      register_prox[index] <= register_prox[index];
  end
end



endmodule


/** updtize the modification of distal synapses in learning mode **/
/** The logic is designed for one segment each time **/
// `include "../param.vh"

module updt_unit ( clk, rst,
                   memory_addr_load_rcvd,
                   process_enable_updt,
                   memory_addr_received,
                   operate_buffer,
                   memory_rd_data,
				   memory_data_ready,
                   /** Output Signal **/
                   process_done_updt,
                   memory_addr_lane,
                   memory_wt_data,
                   memory_wt_enable,
                   memory_rd_enable
                 );


parameter  word_size = `word_size_para,
           addr_size = `addr_size_para,
           permanence_rate_distal = `perm_rate_dis_para,
           permanence_init_distal = `perm_init_dis_para,
           permanence_max_distal = `permanence_max_dis_para,
           permanence_min_distal = `permanence_min_dis_para;

parameter  distal_synapse_count = `distal_synapse_count_para,
           memory_addr_init_per = `memory_addr_init_per_para,
           memory_addr_init_syn = `memory_addr_init_syn_para,
           synapse_per_lane = `synapse_per_lane_para;


input wire clk, rst;
input wire process_enable_updt;
input wire memory_data_ready;
input wire [addr_size - 1 : 0] memory_addr_received;
input wire memory_addr_load_rcvd;
input wire [word_size - 1 : 0] memory_rd_data;
input wire [3 : 0] operate_buffer;


output reg process_done_updt;
output reg [addr_size - 1 : 0] memory_addr_lane;
output reg [word_size - 1 : 0] memory_wt_data;
output reg memory_wt_enable, memory_rd_enable;


reg [addr_size - 1 : 0] memory_addr_init, memory_addr_offt;
reg [word_size - 1 : 0] memory_data_buffer; /** Used to store per value **/
reg [15 : 0] memory_updt_buffer;
reg [15 : 0] memory_bond_buffer;
reg [word_size - 1 : 0] memory_data_temp, memory_data_updt;
reg [15 : 0] permanence_rate_combol;
reg [2  : 0] state_updt, next_state_updt;
reg [3  : 0] logic_timer_updt;
reg [7  : 0] synapse_loop_count;
reg [3  : 0] predict_updt_count, predict_updt_flags;
reg packet_update_flag;
reg synapse_loop_done;
reg permanence_update, valid_synaps_flag;
reg memory_addr_offt_updt;
reg logic_timer_count, logic_timer_reset;
reg positive_update, negative_update;
reg synaps_inc_flag, synaps_dec_flag;



always @(posedge clk)
begin
  if(~rst) begin
    state_updt <= 3'b000;
  end
  else begin
    state_updt <= next_state_updt;
  end
end


always @(*)
begin
  case(state_updt)
    3'b000 : begin
	           if(process_enable_updt == 1'b1) begin
			     next_state_updt = 3'b001;
			   end
			   else begin
			     next_state_updt = 3'b000;
			   end
             end
	3'b001 : begin /** Read the permanence from lane memory to update value **/
	           if(memory_data_ready == 1'b1) begin
			     next_state_updt = 3'b010;
			   end
			   else begin
			     next_state_updt = 3'b001;
			   end
            end
	3'b010 : begin /** Check if this segment is predicted in this round **/
	           if(packet_update_flag == 1'b1)  begin
			     next_state_updt = 3'b011;
			   end
			   else begin
			     next_state_updt = 3'b100;
			   end
             end
	3'b011 : begin /** Upate the permanence based on the flags in memory **/
	           if(logic_timer_updt == 4'b0001) begin
			     next_state_updt = 3'b100;
			   end
			   else begin
			     next_state_updt = 3'b011;
			   end
             end
    3'b100 : begin /** Write the updated permanence value back into lane sram **/
	           if(synapse_loop_done == 1'b1) begin
			     next_state_updt = 3'b000;
			   end
			   else begin
			     next_state_updt = 3'b001;
			   end
	         end
	default: begin
	           next_state_updt = 3'b000;
			 end
  endcase
end


always @(posedge clk)
begin
  if(~rst) begin
    process_done_updt <= 1'b0;
  end
  else begin
    process_done_updt <= (state_updt == 3'b100)&&(next_state_updt == 3'b000);
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_lane <= {addr_size{1'b0}};
  end
  else begin
    memory_addr_lane <= {memory_addr_init + memory_addr_offt};
  end
end


/** state_updt == 3'b001, read the permanence from lane memory to update value  **/


always @(posedge clk)
begin
  if(~rst) begin
    memory_rd_enable <= 1'b0;
  end
  else begin
    case(state_updt)
      3'b001 : memory_rd_enable <= (logic_timer_updt == 4'b0000);  /** Read permanence value **/
      default: memory_rd_enable <= (1'b0);
    endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_init <= {addr_size{1'b0}};
  end
  else begin
    memory_addr_init <= {memory_addr_init_per};
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_addr_offt <= {addr_size{1'b0}};
  end
  else if(memory_addr_load_rcvd == 1'b1) begin     /** Should be reloaded for each block **/
    memory_addr_offt <= memory_addr_received; /** Computed address or buffered address **/
  end
  else if(memory_addr_offt_updt == 1'b1) begin
    memory_addr_offt <= memory_addr_offt + 1'b1;
  end
  else begin
    memory_addr_offt <= memory_addr_offt;
  end
end


always @(*)
begin
  case(state_updt)
	3'b100 : memory_addr_offt_updt = 1'b1;
	default: memory_addr_offt_updt = 1'b0;
  endcase
end


/** state_updt == 3'b010, check if this segment is predicted in this round **/
/** blk_info = cell_index, segmeng_count, pred_t-0, pred_t-1, lern_t-0, lern_t-1 **/


always @(posedge clk)
begin
  if(~rst) begin /**  permanence value and flags **/
    memory_data_buffer <= {word_size{1'b0}};
  end
  else if((memory_data_ready == 1'b1)&&(state_updt == 3'b001)) begin
    memory_data_buffer <= memory_rd_data;
  end
  else begin
    memory_data_buffer <= memory_data_buffer;
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    predict_updt_count <= 4'b0000;
  end
  else if(state_updt == 3'b010) begin
    predict_updt_count <= memory_data_buffer[7 : 4] + predict_updt_flags;
  end
  else begin
    predict_updt_count <= predict_updt_count;
  end
end


always @(*)
begin
  predict_updt_flags = {3'b000, (operate_buffer[3] == 1'b1)&&(memory_data_buffer[2] == 1'b1)};
  packet_update_flag = {operate_buffer[2]};
end


/** state_updt == 3'b011, update the permanence based on the flags in memory **/
/** blk_info = cell_index, segmeng_count, pred_t-0, pred_t-1, lern_t-0, lern_t-1 **/


always @(*)
begin
  positive_update = (operate_buffer[1] == 1'b1);
  negative_update = (operate_buffer[0] == 1'b1);
  valid_synaps_flag = (memory_data_buffer[0] == 1'b1)&&(memory_data_buffer[1] == 1'b0);
end


always @(*)
begin
  synaps_inc_flag = (valid_synaps_flag == 1'b1)&&(memory_data_buffer[3] == 1'b1)&&(positive_update == 1'b1);
  synaps_dec_flag = (valid_synaps_flag == 1'b1)&&(memory_data_buffer[3] == 1'b0)&&(positive_update == 1'b1);
  permanence_update = (state_updt == 3'b011)&&(logic_timer_updt == 4'b0001);
end


always @(posedge clk)
begin
  if(~rst) begin
    permanence_rate_combol <= {16'h0000};
  end
  else if((state_updt == 3'b011)&&(logic_timer_updt == 4'b0000)) begin
    permanence_rate_combol <= {12'h000, predict_updt_count} * permanence_rate_distal;
  end
  else begin
    permanence_rate_combol <= {permanence_rate_combol};
  end
end


always @(posedge clk)
begin /** Updated permanence value **/
  if(~rst) begin
    memory_updt_buffer <= 16'h0000;
  end
  else if((synaps_inc_flag == 1'b1)&&(permanence_update == 1'b1)) begin
    memory_updt_buffer <= memory_data_buffer + permanence_rate_distal;
  end
  else if((synaps_dec_flag == 1'b1)&&(permanence_update == 1'b1)) begin
    memory_updt_buffer <= memory_data_buffer - permanence_rate_distal;
  end
  else if((negative_update == 1'b1)&&(permanence_update == 1'b1)) begin
    memory_updt_buffer <= memory_data_buffer - permanence_rate_combol;
  end
  else begin
    memory_updt_buffer <= permanence_init_distal;
  end
end


always @(*)
begin
  if(memory_updt_buffer <= permanence_min_distal) begin
    memory_bond_buffer = permanence_min_distal;
  end
  else if(memory_updt_buffer >= permanence_max_distal) begin
    memory_bond_buffer = permanence_max_distal;
  end
  else begin
    memory_bond_buffer = memory_updt_buffer;
  end
end


/** state_updt == 3'b100, write the updated permanence value back into lane sram  **/


always @(*)
begin
  memory_data_updt = {memory_data_buffer[word_size - 01 : word_size - 24], predict_updt_count, 4'b0001};
  memory_data_temp = {packet_update_flag ? {8'h00, memory_bond_buffer, 8'h01} : memory_data_updt};
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_wt_enable <= 1'b0;
  end
  else begin
    case(state_updt)
      3'b100 : memory_wt_enable <= 1'b1;  /** Write synpase information **/
      default: memory_wt_enable <= 1'b0;
    endcase
  end
end


always @(posedge clk)
begin
  if(~rst) begin
    memory_wt_data <= {word_size{1'b0}};
  end
  else begin
    case(state_updt)
      3'b100 : memory_wt_data <= {memory_data_temp};  /** Write permanence value **/
      default: memory_wt_data <= {word_size{1'b0}};
    endcase
  end
end


/** Loop control logic and logic timer for modification updtize process **/


always @(posedge clk)
begin
  if((~rst)||(process_done_updt == 1'b1)) begin
    synapse_loop_count <= 8'b00000000;
  end
  else if(next_state_updt == 3'b100) begin
    synapse_loop_count <= synapse_loop_count + 1'b1;
  end
  else begin
    synapse_loop_count <= synapse_loop_count;
  end
end


always @(*)
begin
  synapse_loop_done = (synapse_loop_count == synapse_per_lane);
end


always @(*)
begin
  case(state_updt)
    3'b001 : logic_timer_count = 1'b1;
    3'b011 : logic_timer_count = 1'b1;
	default: logic_timer_count = 1'b0;
  endcase
end


always @(*)
begin
  case(state_updt)
    3'b001 : logic_timer_reset = (next_state_updt != 3'b001);
    3'b011 : logic_timer_reset = (next_state_updt != 3'b011);
	default: logic_timer_reset = 1'b0;
  endcase
end


always @(posedge clk)
begin
  if((~rst)||(logic_timer_reset == 1'b1)) begin
    logic_timer_updt <= 4'b0000;
  end
  else if(logic_timer_count == 1'b1) begin
    logic_timer_updt <= logic_timer_updt + 1'b1;
  end
  else begin
    logic_timer_updt <= logic_timer_updt;
  end
end



endmodule


`timescale 1 ns / 1 ns


module core_unit ( clk, rst,
                   process_learn_enable,
                   process_flows_enable,
				   process_tmpry_enable,
				   buffer_data_pixel_0,
				   buffer_data_pixel_1,
				   buffer_data_pixel_2,
				   buffer_data_pixel_3,
				   buffer_data_pixel_4,
				   buffer_data_pixel_5,
				   buffer_data_pixel_6,
				   buffer_data_pixel_7,
                   /** output signal **/
                   memory_check_ready,
		                   process_done_flow,
				   buffer_data_index
                 );

parameter word_size = `word_size_para,
          lemt_size = `lemt_size_para,
          addr_size = `addr_size_para,
	  lane_size = `lane_size_para;

input  wire clk, rst;
input  wire process_learn_enable;
input  wire process_tmpry_enable;
input  wire process_flows_enable;
input  wire [word_size - 1 : 0] buffer_data_pixel_0;
input  wire [word_size - 1 : 0] buffer_data_pixel_1;
input  wire [word_size - 1 : 0] buffer_data_pixel_2;
input  wire [word_size - 1 : 0] buffer_data_pixel_3;
input  wire [word_size - 1 : 0] buffer_data_pixel_4;
input  wire [word_size - 1 : 0] buffer_data_pixel_5;
input  wire [word_size - 1 : 0] buffer_data_pixel_6;
input  wire [word_size - 1 : 0] buffer_data_pixel_7;


output wire [word_size - 1 : 0] buffer_data_index;
output wire process_done_flow;
output wire memory_check_ready;


wire [lemt_size - 1 : 0] packet_grant_send_proc;
wire [lemt_size - 1 : 0] packet_grant_rcvd_proc;
wire [lemt_size - 1 : 0] packet_ready_send_proc;
wire [lemt_size - 1 : 0] packet_ready_rcvd_proc;
wire [word_size - 1 : 0] packet_data_lemt  [lemt_size - 1 : 0];
wire [word_size - 1 : 0] packet_data_proc  [lemt_size - 1 : 0];
wire [lane_size - 1 : 0] image_read_enable [lemt_size - 1 : 0];



genvar i;


proc_unit  x0 ( .clk(clk), .rst(rst),
                .process_learn_enable(process_learn_enable),
                .process_flows_enable(process_flows_enable),
                .packet_data_proc_0(packet_data_proc[0]),
                .packet_data_proc_1(packet_data_proc[1]),
                .packet_data_proc_2(packet_data_proc[2]),
                .packet_data_proc_3(packet_data_proc[3]),
                .packet_data_proc_4(packet_data_proc[4]),
                .packet_data_proc_5(packet_data_proc[5]),
                .packet_data_proc_6(packet_data_proc[6]),
                .packet_data_proc_7(packet_data_proc[7]),
                .packet_grant_send(packet_grant_send_proc),
                .packet_ready_rcvd(packet_ready_rcvd_proc),
                 /** output signal**/
				.memory_check_ready(memory_check_ready),
		.process_done_flow(process_done_flow),
		.buffer_data_index(buffer_data_index),
                .packet_data_lemt_0(packet_data_lemt[0]),
                .packet_data_lemt_1(packet_data_lemt[1]),
                .packet_data_lemt_2(packet_data_lemt[2]),
                .packet_data_lemt_3(packet_data_lemt[3]),
                .packet_data_lemt_4(packet_data_lemt[4]),
                .packet_data_lemt_5(packet_data_lemt[5]),
                .packet_data_lemt_6(packet_data_lemt[6]),
                .packet_data_lemt_7(packet_data_lemt[7]),
                .packet_ready_send(packet_ready_send_proc),
                .packet_grant_rcvd(packet_grant_rcvd_proc)
	      );


generate

    for (i = 0; i < lemt_size; i = i + 1)
    begin : elements

	    lemt_unit x1 ( .clk(clk), .rst(rst),
                       .process_learn_enable(process_learn_enable),
                       .process_tmpry_enable(process_tmpry_enable),
                       .buffer_data_pixel({buffer_data_pixel_7, buffer_data_pixel_6, buffer_data_pixel_5, buffer_data_pixel_4,
										   buffer_data_pixel_3, buffer_data_pixel_2, buffer_data_pixel_1, buffer_data_pixel_0}),
                       .packet_data_lemt(packet_data_lemt[i]),
                       .packet_grant_send(packet_grant_rcvd_proc[i]),
                       .packet_ready_rcvd(packet_ready_send_proc[i]),
                       /** output signal **/
                       .image_read_enable(image_read_enable[i]),
                       .packet_data_proc(packet_data_proc[i]),
                       .packet_ready_send(packet_ready_rcvd_proc[i]),
                       .packet_grant_rcvd(packet_grant_send_proc[i])
			         );

	end

endgenerate



endmodule


