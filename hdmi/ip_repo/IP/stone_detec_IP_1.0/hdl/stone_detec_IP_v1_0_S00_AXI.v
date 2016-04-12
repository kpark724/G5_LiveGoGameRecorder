
`timescale 1 ns / 1 ps


    
	module stone_detec_IP_v1_0_S00_AXI #
	(
		// Users to add parameters here

        parameter integer I_VDMA_HIGH = 10, 
        parameter integer J_VDMA_HIGH = 9, 
        parameter integer I_VDMA_MAX_POSSIBLE = 2047,
        parameter integer J_VDMA_MAX_POSSIBLE = 1023,


        parameter WHITE_STONE = 1,
        parameter BLACK_STONE = 2,
        parameter NO_STONE = 0,

        parameter integer BUSY = 1,
        parameter integer IDLE = 2,
        parameter integer OUTPUTTING = 3,
		// User parameters ends
		// Do not modify the parameters beyond this line

		// Width of S_AXI data bus
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		// Width of S_AXI address bus
		parameter integer C_S_AXI_ADDR_WIDTH	= 6
	)
	(
		// Users to add ports here
                // valid bit from the VDMA
        input v_vdma,
        // Give to VDMA (Ready signal)
        output reg r_vdma,
        // Data from the VDMA for the pixel
        input [23:0] d_vdma,
		// User ports ends
		// Do not modify the ports beyond this line

		// Global Clock Signal
		input wire  S_AXI_ACLK,
		// Global Reset Signal. This Signal is Active LOW
		input wire  S_AXI_ARESETN,
		// Write address (issued by master, acceped by Slave)
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
		// Write channel Protection type. This signal indicates the
    		// privilege and security level of the transaction, and whether
    		// the transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_AWPROT,
		// Write address valid. This signal indicates that the master signaling
    		// valid write address and control information.
		input wire  S_AXI_AWVALID,
		// Write address ready. This signal indicates that the slave is ready
    		// to accept an address and associated control signals.
		output wire  S_AXI_AWREADY,
		// Write data (issued by master, acceped by Slave) 
		input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
		// Write strobes. This signal indicates which byte lanes hold
    		// valid data. There is one write strobe bit for each eight
    		// bits of the write data bus.    
		input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
		// Write valid. This signal indicates that valid write
    		// data and strobes are available.
		input wire  S_AXI_WVALID,
		// Write ready. This signal indicates that the slave
    		// can accept the write data.
		output wire  S_AXI_WREADY,
		// Write response. This signal indicates the status
    		// of the write transaction.
		output wire [1 : 0] S_AXI_BRESP,
		// Write response valid. This signal indicates that the channel
    		// is signaling a valid write response.
		output wire  S_AXI_BVALID,
		// Response ready. This signal indicates that the master
    		// can accept a write response.
		input wire  S_AXI_BREADY,
		// Read address (issued by master, acceped by Slave)
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
		// Protection type. This signal indicates the privilege
    		// and security level of the transaction, and whether the
    		// transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_ARPROT,
		// Read address valid. This signal indicates that the channel
    		// is signaling valid read address and control information.
		input wire  S_AXI_ARVALID,
		// Read address ready. This signal indicates that the slave is
    		// ready to accept an address and associated control signals.
		output wire  S_AXI_ARREADY,
		// Read data (issued by slave)
		output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
		// Read response. This signal indicates the status of the
    		// read transfer.
		output wire [1 : 0] S_AXI_RRESP,
		// Read valid. This signal indicates that the channel is
    		// signaling the required read data.
		output wire  S_AXI_RVALID,
		// Read ready. This signal indicates that the master can
    		// accept the read data and response information.
		input wire  S_AXI_RREADY
	);

	// AXI4LITE signals
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  	axi_awready;
	reg  	axi_wready;
	reg [1 : 0] 	axi_bresp;
	reg  	axi_bvalid;
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	reg  	axi_arready;
	reg [C_S_AXI_DATA_WIDTH-1 : 0] 	axi_rdata;
	reg [1 : 0] 	axi_rresp;
	reg  	axi_rvalid;

	// Example-specific design signals
	// local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	// ADDR_LSB is used for addressing 32/64 bit registers/memories
	// ADDR_LSB = 2 for 32 bits (n downto 2)
	// ADDR_LSB = 3 for 64 bits (n downto 3)
	localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
	localparam integer OPT_MEM_ADDR_BITS = 3;
	//----------------------------------------------
	//-- Signals for user logic register space example
	//------------------------------------------------
	//-- Number of Slave Registers 16
	// I don't handle cases if somebody violates permissions. Anything can happen, so don't violate them.

	// SD also will contain parameters common to both
	/* reset (R/W) */
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg0;
	/* start (R/W)*/
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg1;
	/* status (R)*/
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg2;
	/*  output	*/
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg3;
	/* SD: FRAME WIDTH (MSB 16 bits), FRAME HEIGHT (LSB 16 bits)*/
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg4;
	/*  SD: W_SUB and H_SUB (MSB and LSB 16 bits respectively)
	    HD: (left, right)*/
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg5;
	/*  SD: I0, J0 - (16 bits MSB, 16 bits LSB respectively)
        HD: (top, bottom)*/
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg6;
	/*  SD: (incl_iA, incl_jA)
        */
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg7;
	/*  SD: (incl_iB, incl_jB)
        HD: (av_param_LR, av_param_TB)*/
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg8;
	/*  SD: (incl_iC, incl_jC)
        HD: (dd_in_LR, dd_out_LR)*/
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg9;
	/*  SD: (incl_iD, incl_jD)
        HD: (dd_in_LR, dd_out_LR) */
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg10;
	/*  SD: (thres_frac_num_w,thres_frac_denom_w, thres_frac_num_b,thres_frac_denom_b) */
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg11;
	
	
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg12;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg13;
	
	
	/* DUMP CONFIG: when set to 1 - will dump config into the stone
        detec registers. When set to 2 - will dump into the hand detec
        registers. Automatically set to 0 when configuration is complete.
        MB can use this to know when the IP is ready to start the detection */
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg14; 
	
	/*Debugging register (R/W)*/
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg15; 
	
	
	wire	 slv_reg_rden;
	wire	 slv_reg_wren;
	reg [C_S_AXI_DATA_WIDTH-1:0]	 reg_data_out;
	integer	 byte_index;
    
    
    // CONFIGURATION
    
    // stone detec config reg declaration
    reg [I_VDMA_HIGH:0] i_vdma_max;
    reg [J_VDMA_HIGH:0] j_vdma_max;    
    reg [I_VDMA_HIGH:0] w_sub;
    reg [J_VDMA_HIGH:0] h_sub;
    reg [I_VDMA_HIGH:0] i0, i1;
    reg [J_VDMA_HIGH:0] j0, j1;
    reg [I_VDMA_HIGH:0] incl_iA, incl_iB, incl_iC, incl_iD;
    reg [J_VDMA_HIGH:0] incl_jA, incl_jB, incl_jC, incl_jD;
    reg [7:0] thres_frac_denom_w, thres_frac_denom_b;
    reg [7:0] thres_frac_num_w, thres_frac_num_b;
    
    // hand detec config reg declaration
    reg [I_VDMA_HIGH:0] left, right;
    reg [J_VDMA_HIGH:0] top, bottom;
    //reg [7:0] thres_hand_L, thres_hand_R, thres_hand_T, thres_hand_B;
    reg [J_VDMA_HIGH:0] av_param_LR;
    reg [I_VDMA_HIGH:0] av_param_TB;
    reg [J_VDMA_HIGH:0] dd_out_LR;
    reg [J_VDMA_HIGH:0] dd_in_LR;
    reg [I_VDMA_HIGH:0] dd_out_TB;
    reg [I_VDMA_HIGH:0] dd_in_TB;
                              
     
    
    // dump
    always @ (posedge S_AXI_ACLK)
        begin
            if (slv_reg14 == 1)// if was told to dump the stone detection configuration
                begin
                    w_sub <= slv_reg5[I_VDMA_HIGH+16:16];
                    h_sub <= slv_reg5[J_VDMA_HIGH:0];
                
                    i_vdma_max <= slv_reg4[I_VDMA_HIGH+16:16] - 1 ;
                    j_vdma_max <= slv_reg4[J_VDMA_HIGH:0] - 1 ;
                
                    i0 <= slv_reg6[I_VDMA_HIGH+16:16];
                    j0 <= slv_reg6[J_VDMA_HIGH:0];
                    i1 <= slv_reg6[I_VDMA_HIGH+16:16] + 19*slv_reg5[I_VDMA_HIGH+16:16]-1;
                    j1 <= slv_reg6[J_VDMA_HIGH:0] + 19*slv_reg5[J_VDMA_HIGH:0]-1;   
           
                    incl_iA <= slv_reg7[I_VDMA_HIGH+16:16];
                    incl_iB <= slv_reg8[I_VDMA_HIGH+16:16];
                    incl_iC <= slv_reg9[I_VDMA_HIGH+16:16];
                    incl_iD <= slv_reg10[I_VDMA_HIGH+16:16];
                
                    incl_jA <= slv_reg7[J_VDMA_HIGH:0];
                    incl_jB <= slv_reg8[J_VDMA_HIGH:0];
                    incl_jC <= slv_reg9[J_VDMA_HIGH:0];
                    incl_jD <= slv_reg10[J_VDMA_HIGH:0];
                    thres_frac_num_w <= slv_reg11[31:24];
                    thres_frac_denom_w <= slv_reg11[23:16];
                    thres_frac_num_b <= slv_reg11[15:8];
                    thres_frac_denom_b <= slv_reg11[7:0];
                end
            if (slv_reg14 == 2) // dump hand detection config regs
                begin
     
                
                    left <= slv_reg5[I_VDMA_HIGH+16:16];
                    right <= slv_reg5[I_VDMA_HIGH:0];
                    top <= slv_reg6[J_VDMA_HIGH+16:16];
                    bottom <= slv_reg6[J_VDMA_HIGH:0];
            
                    //thres_hand_L <= slv_reg7[31:24];
                    //thres_hand_R <= slv_reg7[23:16];
                    //thres_hand_T <= slv_reg7[15:8];
                    //thres_hand_B <= slv_reg7[7:0];
               
                    av_param_LR <= slv_reg8[J_VDMA_HIGH+16:16];
                    av_param_TB <= slv_reg8[I_VDMA_HIGH:0];
                
                    dd_in_LR <= slv_reg9[J_VDMA_HIGH+16:16];
                    dd_out_LR <= slv_reg9[J_VDMA_HIGH:0];
                
                    dd_in_TB <= slv_reg10[I_VDMA_HIGH+16:16];
                    dd_out_TB <= slv_reg10[I_VDMA_HIGH:0];
                
                end
        end
        
    
    
    // pointers of a pixel within the frame: in sync with data
    reg [I_VDMA_HIGH:0] i_vdma; 
    reg [J_VDMA_HIGH:0] j_vdma;
    // intersection pointers (absolute go from 0 to 360, i,j go from 0 to 18)
    reg [4:0] inters_i;
    reg [4:0] inters_j;
    reg [8:0] inters_index;// make internal
    // pixel pointers with respect to the current intersection
    reg [I_VDMA_HIGH:0] i_within_inters;// CL
    reg [J_VDMA_HIGH:0] j_within_inters;// CL
    // maximum eval value seen so far in the entire frame
    reg [7:0] max_white_overall;
    // minimum eval value seen so far in the entire frame
    reg [7:0] max_black_overall;
    
    // will be used to know when to perform the data readout by the MB
    reg data_input_in_progress;// can set this value to 0 as soon as you see you are processing your last data point
    reg eval_is_valid;
    
    // evaluation matrix for determining what stone if any the intersection has
    reg [7:0] white_eval [0:360];// CL, lags the data by 1 clock cycle
    reg [7:0] black_eval [0:360];// CL, lags the data by 1 clock cycle
    reg [8:0] k_in_config; // pointer in the 19*19-sized 1D array
    reg [3:0] k_in_hd;// note 1 to 8!!!!!!!!!!!!!!!!!
    
    reg [1:0] stone_decision;// combinational logic
    reg [1:0] stone_decision_next;

    wire resetn;
    
    wire [7:0] min_brightness;
    wire [7:0] max_brightness;
    
    
    wire [7:0] mid_white; 
    wire [7:0] mid_black;
    
    
    wire [7:0] max_white_dev;
    wire [7:0] max_black_dev;
    
    // overkill but okay
    wire [31:0] white_eval_x_denom;
    wire [31:0] black_eval_x_denom;
    
    wire [31:0] white_eval_x_denom_next;
        wire [31:0] black_eval_x_denom_next;
    
    wire [31:0] mid_white_x_denom;
    wire [31:0] mid_black_x_denom;
    
     wire [31:0] max_white_dev_x_num;
     wire [31:0] max_black_dev_x_num;

    reg [7:0] brightness; // combinational logic ouput - not actually a register 
    wire [8:0] brightness_pre;
    		reg all_complete;// not done yet :(


	// I/O Connections assignments

	assign S_AXI_AWREADY	= axi_awready;
	assign S_AXI_WREADY	= axi_wready;
	assign S_AXI_BRESP	= axi_bresp;
	assign S_AXI_BVALID	= axi_bvalid;
	assign S_AXI_ARREADY	= axi_arready;
	assign S_AXI_RDATA	= axi_rdata;
	assign S_AXI_RRESP	= axi_rresp;
	assign S_AXI_RVALID	= axi_rvalid;
	// Implement axi_awready generation
	// axi_awready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
	// de-asserted when reset is low.






	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awready <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID)
	        begin
	          // slave is ready to accept write address when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
	          axi_awready <= 1'b1;
	        end
	      else           
	        begin
	          axi_awready <= 1'b0;
	        end
	    end 
	end       

	// Implement axi_awaddr latching
	// This process is used to latch the address when both 
	// S_AXI_AWVALID and S_AXI_WVALID are valid. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awaddr <= 0;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID)
	        begin
	          // Write Address latching 
	          axi_awaddr <= S_AXI_AWADDR;
	        end
	    end 
	end       

	// Implement axi_wready generation
	// axi_wready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
	// de-asserted when reset is low. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_wready <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID)
	        begin
	          // slave is ready to accept write data when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
	          axi_wready <= 1'b1;
	        end
	      else
	        begin
	          axi_wready <= 1'b0;
	        end
	    end 
	end       

	// Implement memory mapped register select and write logic generation
	// The write data is accepted and written to memory mapped registers when
	// axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
	// select byte enables of slave registers while writing.
	// These registers are cleared when reset (active low) is applied.
	// Slave register write enable is asserted when valid address and data are available
	// and the slave is ready to accept the write address and write data.
	assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

	always @( posedge S_AXI_ACLK )
	begin
	  if ( resetn == 1'b0 )
	    begin
	      slv_reg0 <= 0;
	      slv_reg1 <= 0;
	      slv_reg2 <= 0;
          
          
          slv_reg14 <= 0;// config dump
          
	    end 
	  else begin
	    if (slv_reg_wren)
	      begin
	        case ( axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	          4'h0:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 0
	                slv_reg0[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          4'h1:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 1
	                slv_reg1[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          4'h2:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 2
	                slv_reg2[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          4'h3:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 3
	                //slv_reg3[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          4'h4:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 4
	                slv_reg4[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          4'h5:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 5
	                slv_reg5[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          4'h6:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 6
	                slv_reg6[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          4'h7:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 7
	                slv_reg7[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          4'h8:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 8
	                slv_reg8[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          4'h9:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 9
	                slv_reg9[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          4'hA:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 10
	                slv_reg10[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          4'hB:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 11
	                slv_reg11[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          4'hC:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 12
	                slv_reg12[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          4'hD:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 13
	                slv_reg13[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          4'hE:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 14
	                slv_reg14[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          4'hF:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 15
	                slv_reg15[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          default : begin
	                      slv_reg0 <= slv_reg0;
	                      slv_reg1 <= slv_reg1;
	                      slv_reg2 <= slv_reg2;
	                      //slv_reg3 <= slv_reg3;
	                      slv_reg4 <= slv_reg4;
	                      slv_reg5 <= slv_reg5;
	                      slv_reg6 <= slv_reg6;
	                      slv_reg7 <= slv_reg7;
	                      slv_reg8 <= slv_reg8;
	                      slv_reg9 <= slv_reg9;
	                      slv_reg10 <= slv_reg10;
	                      slv_reg11 <= slv_reg11;
	                      slv_reg12 <= slv_reg12;
	                      slv_reg13 <= slv_reg13;
	                      slv_reg14 <= slv_reg14;
	                      slv_reg15 <= slv_reg15;
	                    end
	        endcase
	      end
	    else
	       begin
	       
	           // if was told to dump config
	           if (slv_reg14 == 1)
                  begin
                      slv_reg14 <= 0;
                  end
               else
                  if (slv_reg14 == 2)
                      begin
                          slv_reg14 <= 0;
                      end

	           // if was told to begin
	           if (slv_reg1 == 1)
	               begin
        	           slv_reg1 <= 0;
        	           slv_reg2 <= BUSY;
        	       end
        	   
        	   else
        	       if (eval_is_valid) 
            	       begin   
                	      slv_reg2 <= OUTPUTTING;
        	           end
        	       
	       end
	  end
	end    
    // helper vars
    
    
    

    
    assign max_brightness = max_white_overall;
    assign min_brightness = 255 - max_black_overall;
    

    assign mid_white = (max_brightness>>1) + (min_brightness>>1);
    
    assign mid_black = 255 - mid_white;
        
    
    assign max_white_dev = max_white_overall - mid_white;
    assign max_black_dev = max_black_overall - mid_black;
    
    assign white_eval_x_denom = white_eval[k_in_config] * thres_frac_denom_w;
    assign black_eval_x_denom = black_eval[k_in_config] * thres_frac_denom_b;
    
    reg [8:0] k_in_config_plus_1_chop_at_360;
    always @ (*)
        begin
            if (k_in_config == 360)
                k_in_config_plus_1_chop_at_360 <= k_in_config;
            else
                k_in_config_plus_1_chop_at_360 <= k_in_config + 1;
        end
    assign white_eval_x_denom_next = white_eval[k_in_config_plus_1_chop_at_360] * thres_frac_denom_w;
    assign black_eval_x_denom_next = black_eval[k_in_config_plus_1_chop_at_360] * thres_frac_denom_b;
    
    
    assign mid_white_x_denom = mid_white * thres_frac_denom_w;
    assign mid_black_x_denom = mid_black * thres_frac_denom_b;

   
    assign max_white_dev_x_num = max_white_dev * thres_frac_num_w;
    assign max_black_dev_x_num = max_black_dev * thres_frac_num_b;
    
    always @ (*)
        begin
            
            if (white_eval_x_denom > mid_white_x_denom + max_white_dev_x_num)
                stone_decision <= WHITE_STONE;
            else
                if (black_eval_x_denom > mid_black_x_denom + max_black_dev_x_num)
                    stone_decision <= BLACK_STONE;
                else
                    stone_decision <= NO_STONE;
            

            if (white_eval_x_denom_next > mid_white_x_denom + max_white_dev_x_num)
                stone_decision_next <= WHITE_STONE;
            else
                if (black_eval_x_denom_next > mid_black_x_denom + max_black_dev_x_num)
                    stone_decision_next <= BLACK_STONE;
                else
                    stone_decision_next <= NO_STONE;


         

            
            //if (white_eval(I,J) > mid_white + max_dev_white*thres_fraction_w)
               // config(I,J) = 1;
                //continue
            //end
            //if (black_eval(I,J) > mid_black + max_dev_black*thres_fraction_b)
               // config(I,J) = -1;
               // continue
           // end
           // config(I,J) = 0;
            
        end
        
   
 	always @( posedge S_AXI_ACLK )
	   begin
	       if ( resetn == 1'b0 )
	           begin
	               k_in_hd <= 0;
	               k_in_config <= 0;
	               slv_reg3 <= 0;
	           end 
	       else
	           begin    
                   if (eval_is_valid)
                      begin
                            if (slv_reg_rden && axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] == 3)
                                begin
                                    if (k_in_config < 360)
                                        begin
                                          slv_reg3 <= stone_decision_next;
                                          k_in_config <= k_in_config + 1;
                                        end
                                    else
                                        begin
                                          if (k_in_hd < 9 )
                                             begin

                                               case (k_in_hd)
                                                    0: slv_reg3 <= hd_dumped_value_min_L;
                                                    1: slv_reg3 <= hd_dumped_value_min_R;
                                                    2: slv_reg3 <= hd_dumped_value_min_T;
                                                    3: slv_reg3 <= hd_dumped_value_min_B;
                                                    4: slv_reg3 <= hd_dumped_value_max_L;
                                                    5: slv_reg3 <= hd_dumped_value_max_R;
                                                    6: slv_reg3 <= hd_dumped_value_max_T;
                                                    7: slv_reg3 <= hd_dumped_value_max_B;
                                                    8: slv_reg3 <= 0;
                                                    default:  slv_reg3 <= 0;
                                               endcase

                                               k_in_hd <= k_in_hd + 1;
                                             end
                                        end
                                end
                             else
                                begin
                                    case (k_in_hd)
                                         0: slv_reg3 <= stone_decision;
                                         1: slv_reg3 <= hd_dumped_value_min_L;
                                         2: slv_reg3 <= hd_dumped_value_min_R;
                                         3: slv_reg3 <= hd_dumped_value_min_T;
                                         4: slv_reg3 <= hd_dumped_value_min_B;
                                         5: slv_reg3 <= hd_dumped_value_max_L;
                                         6: slv_reg3 <= hd_dumped_value_max_R;
                                         7: slv_reg3 <= hd_dumped_value_max_T;
                                         8: slv_reg3 <= hd_dumped_value_max_B;
                                         9: slv_reg3 <= 0;
                                        default:  slv_reg3 <= 0;
                                    endcase
                                end                
                      end          
	           end
	   end 

	always @ (posedge S_AXI_ACLK)
	   begin
    	   all_complete <= eval_is_valid && k_in_config == 360 && k_in_hd == 9;
	   end	
      
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_bvalid  <= 0;
	      axi_bresp   <= 2'b0;
	    end 
	  else
	    begin    
	      if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID)
	        begin
	          // indicates a valid write response is available
	          axi_bvalid <= 1'b1;
	          axi_bresp  <= 2'b0; // 'OKAY' response 
	        end                   // work error responses in future
	      else
	        begin
	          if (S_AXI_BREADY && axi_bvalid) 
	            //check if bready is asserted while bvalid is high) 
	            //(there is a possibility that bready is always asserted high)   
	            begin
	              axi_bvalid <= 1'b0; 
	            end  
	        end
	    end
	end   

	// Implement axi_arready generation
	// axi_arready is asserted for one S_AXI_ACLK clock cycle when
	// S_AXI_ARVALID is asserted. axi_awready is 
	// de-asserted when reset (active low) is asserted. 
	// The read address is also latched when S_AXI_ARVALID is 
	// asserted. axi_araddr is reset to zero on reset assertion.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_arready <= 1'b0;
	      axi_araddr  <= 32'b0;
	    end 
	  else
	    begin    
	      if (~axi_arready && S_AXI_ARVALID)
	        begin
	          // indicates that the slave has acceped the valid read address
	          axi_arready <= 1'b1;
	          // Read address latching
	          axi_araddr  <= S_AXI_ARADDR;
	        end
	      else
	        begin
	          axi_arready <= 1'b0;
	        end
	    end 
	end       

	// Implement axi_arvalid generation
	// axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
	// S_AXI_ARVALID and axi_arready are asserted. The slave registers 
	// data are available on the axi_rdata bus at this instance. The 
	// assertion of axi_rvalid marks the validity of read data on the 
	// bus and axi_rresp indicates the status of read transaction.axi_rvalid 
	// is deasserted on reset (active low). axi_rresp and axi_rdata are 
	// cleared to zero on reset (active low).  
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rvalid <= 0;
	      axi_rresp  <= 0;
	    end 
	  else
	    begin    
	      if (axi_arready && S_AXI_ARVALID && ~axi_rvalid)
	        begin
	          // Valid read data is available at the read data bus
	          axi_rvalid <= 1'b1;
	          axi_rresp  <= 2'b0; // 'OKAY' response
	        end   
	      else if (axi_rvalid && S_AXI_RREADY)
	        begin
	          // Read data is accepted by the master
	          axi_rvalid <= 1'b0;
	        end                
	    end
	end    

	// Implement memory mapped register select and read logic generation
	// Slave register read enable is asserted when valid address is available
	// and the slave is ready to accept the read address.
	assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;
	always @(*)
	begin
	      // Address decoding for reading registers
	      case ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	        4'h0   : reg_data_out <= slv_reg0;
	        4'h1   : reg_data_out <= slv_reg1;
	        4'h2   : reg_data_out <= slv_reg2;
	        4'h3   : reg_data_out <= slv_reg3;	                   
	        4'h4   : reg_data_out <= slv_reg4;
	        4'h5   : reg_data_out <= slv_reg5;
	        4'h6   : reg_data_out <= slv_reg6;
	        4'h7   : reg_data_out <= slv_reg7;
	        4'h8   : reg_data_out <= slv_reg8;
	        4'h9   : reg_data_out <= slv_reg9;
	        4'hA   : reg_data_out <= slv_reg10;
	        4'hB   : reg_data_out <= slv_reg11;
	        4'hC   : reg_data_out <= slv_reg12;
	        4'hD   : reg_data_out <= slv_reg13;
	        4'hE   : reg_data_out <= slv_reg14;
	        4'hF   : reg_data_out <= slv_reg15;
	        default : reg_data_out <= 0;
	      endcase
	end

	// Output register or memory read data
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rdata  <= 0;
	    end 
	  else
	    begin    
	      // When there is a valid read address (S_AXI_ARVALID) with 
	      // acceptance of read address by the slave (axi_arready), 
	      // output the read dada 
	      if (slv_reg_rden)
	        begin
	          axi_rdata <= reg_data_out;     // register read data
	        end   
	    end
	end    
	
	
    assign resetn = ~((S_AXI_ARESETN == 1'b0) || (slv_reg0 == 1) || (all_complete == 1'b1));

    
	// Add user logic here--------------------------------------------------

    
    // whether to include the current pixel in max or min calculations
    wire incl; // CL
    assign incl = (i_vdma >= i0 && i_vdma <= i1 && j_vdma >= j0 && j_vdma <= j1) && ((incl_iA <= i_within_inters) && (i_within_inters <= incl_iB) || (incl_iC <= i_within_inters) && (i_within_inters <= incl_iD)) && ((incl_jA <= j_within_inters) && (j_within_inters <= incl_jB) || (incl_jC <= j_within_inters) && (j_within_inters <= incl_jD));    
    
    // intersection coordinates logic
	always @( posedge S_AXI_ACLK )
	begin
	   if ( resetn == 1'b0 )
	    begin
            i_vdma <= 0; 
            j_vdma <= 0; 
            inters_i <= 0;
            inters_j <= 0;
            inters_index <= 0;
	    end 
	  else
	    begin    
            if (v_vdma && data_input_in_progress)
                begin
                    // logic for i_vdma and j_vdma
                    if (i_vdma == i_vdma_max)
                        begin
                            i_vdma <= 0;
                            if (j_vdma == j_vdma_max)
                                j_vdma <= 0;
                            else
                                j_vdma <= j_vdma + 1;
                        end
                    else
                        i_vdma <= i_vdma + 1;
                        
                    // logic for inters_i
                    if (i_vdma >= i0-1 && i_vdma <= i1-1) 
                        begin 
                            if (i_within_inters == w_sub - 1)
                                if (inters_i < 18)
                                    inters_i <= inters_i + 1;
                                else
                                    inters_i <= 0;
                            else
                                inters_i <= inters_i;
                        end
                    else
                        inters_i <= 0;
                        
                    // logic for inters_j
                    if (j_vdma >= j0-1 && j_vdma <= j1-1) 
                        begin 
                            if (j_within_inters == h_sub - 1 && inters_i == 18 && i_within_inters == w_sub -1)
                                if (inters_j < 18)
                                    inters_j <= inters_j + 1;
                                else
                                    inters_j <= 0;
                            else
                                inters_j <= inters_j;
                        end
                    else
                        inters_j <= 0;
                                        
                end
            
	    end 
	end      
	     
	

	
    always @ (*)
        begin
            if (i_vdma >= i0 && i_vdma <= i1)
                i_within_inters = i_vdma - i0 - w_sub * inters_i;
            else
                i_within_inters <= 0;   
            if (j_vdma >= j0 && j_vdma <= j1)
                j_within_inters = j_vdma - j0 - h_sub * inters_j;    
            else
                j_within_inters <= 0; 
        end
    
    // data_input_in_progress and r_vdma
	always @( posedge S_AXI_ACLK )
	   begin
	     if ( resetn == 1'b0 )
	       begin
             data_input_in_progress <= 0;// can set this value to 0 as soon as you see you are processing your last data point (i.e. next cycle after - set to 0)
	         eval_is_valid <= 0;
	         r_vdma <= 1'b0;
	       end
	     else 
            if (slv_reg1 == 1'b1)// Start
              begin
                data_input_in_progress <= 1'b1;
                r_vdma <= 1'b1;
              end
            else
                if (i_vdma == i_vdma_max && j_vdma == j_vdma_max) 
                    begin
                        data_input_in_progress <= 1'b0;
                        r_vdma <= 1'b0;
                        eval_is_valid <= 1'b1;
                    end
       end
                  

    assign brightness_pre = d_vdma[7:0] + d_vdma[23:16];
    always @ (*)
        begin
            if ((brightness_pre >> 1) > offset_subtr[inters_i] [inters_j])
                brightness <= (brightness_pre >> 1) - offset_subtr[inters_i] [inters_j];
            else
                brightness <= 0;
        end
	
	reg [7:0] offset_subtr [0:18][0:18];
	always @(posedge S_AXI_ACLK)
	   begin
	       if (~((S_AXI_ARESETN == 1'b0) || (slv_reg0 == 1)))
	           begin
	               for (p = 0; p<=18; p=p+1)
	                   for (q = 0; q<=18; q= q+1)
	                       offset_subtr[p][q] <= 0;
	           end
	       
	   end
	
	
	always @( posedge S_AXI_ACLK )
	  begin
	   if ( resetn == 1'b0 )
	    begin
	        max_white_overall <= 0;// the min value possible
            max_black_overall <= 0;// because the values are unsigned, this will be the max value possible
	        
	    end 
	  else
	    begin
	       if (incl)
	           begin
	               if (255 - brightness > max_black_overall)
	                   max_black_overall <= 255-brightness;
	               if (brightness > max_white_overall)
	                   max_white_overall <= brightness;


	               
	           end    
	    end 
	end           

    // white_eval, black_eval: = is important!
    integer k,p,q; 
	always @( posedge S_AXI_ACLK )
      begin
       if ( resetn == 1'b0 )
        begin
            
            for (k=0; k<=360; k = k+1)
                begin
                    white_eval[k] <= 0;
                    black_eval[k] <= 0;
                end
        end 
      else
        begin
             
             if (brightness > white_eval[inters_j * 19 + inters_i] && incl)
                white_eval[inters_j * 19 + inters_i] <= brightness;
                
                            
             if (255-brightness > black_eval[inters_j * 19 + inters_i] && incl)
                black_eval[inters_j * 19 + inters_i] <= 255-brightness;
                            
        end 
    end   
    
    //=========================================================================
    // HAND DETECTION
    //-------------------------------------------------------------------------
    // subsampled derivatives (by summing)
    // it could be represented with an array, but actually it turns out that we only need to keep one value at a time
    reg signed [32:0] der_sum_L; 
    reg signed [32:0] der_sum_R;
    reg signed [32:0] der_sum_T;
    reg signed [32:0] der_sum_B;
    
    // pointers within the subsampled derivatives
    reg [J_VDMA_HIGH:0] hd_subsamp_ptr_L;
    reg [J_VDMA_HIGH:0] hd_subsamp_ptr_R;
    reg [I_VDMA_HIGH:0] hd_subsamp_ptr_T;
    reg [I_VDMA_HIGH:0] hd_subsamp_ptr_B;
    
    reg [J_VDMA_HIGH:0] hd_subsamp_counter_L;
    reg [J_VDMA_HIGH:0] hd_subsamp_counter_R;
    reg [I_VDMA_HIGH:0] hd_subsamp_counter_T;
    reg [I_VDMA_HIGH:0] hd_subsamp_counter_B;
    
    // derivatives
    reg [7:0] hd_stored_L [0:J_VDMA_MAX_POSSIBLE];
    reg [7:0] hd_stored_R [0:J_VDMA_MAX_POSSIBLE];    
    reg [7:0] hd_stored_T [0:I_VDMA_MAX_POSSIBLE];
    reg [7:0] hd_stored_B [0:I_VDMA_MAX_POSSIBLE];
    
    // dump enable
    reg hd_sum_dump_enable_L;
    reg hd_sum_dump_enable_R;
    reg hd_sum_dump_enable_T;
    reg hd_sum_dump_enable_B;
    
    
    
    wire [7:0] red; 
    assign red = d_vdma[23:16];
    
    // logic for the pointers into the subsampling arrrays and storage into the subsampling arrays
    
   
    wire signed [32:0] der_temp_L; assign der_temp_L = -{24'b0,hd_stored_L[j_vdma]} + {24'b0,red};
    wire signed [32:0] der_temp_R; assign der_temp_R = -{24'b0,hd_stored_R[j_vdma]} + {24'b0,red};
    wire signed [32:0] der_temp_T; assign der_temp_T = -{24'b0,hd_stored_T[i_vdma]} + {24'b0,red};
    wire signed [32:0] der_temp_B; assign der_temp_B = -{24'b0,hd_stored_B[i_vdma]} + {24'b0,red};
    
    // these are actually CL. Verilog is bad :(
    reg signed [32:0] abs_der_temp_L;
    reg signed [32:0] abs_der_temp_R;
    reg signed [32:0] abs_der_temp_T;
    reg signed [32:0] abs_der_temp_B;
    
    always @ (*)
        begin
            // L
            if (der_temp_L[32])
                abs_der_temp_L <= -der_temp_L;
            else
                abs_der_temp_L <= der_temp_L;


            // R
            if (der_temp_R[32])
                abs_der_temp_R <= -der_temp_R;
            else
                abs_der_temp_R <= der_temp_R;



            // T
            if (der_temp_T[32])
                abs_der_temp_T <= -der_temp_T;
            else
                abs_der_temp_T <= der_temp_T;


            // B
            if (der_temp_B[32])
                abs_der_temp_B <= -der_temp_B;
            else
                abs_der_temp_B <= der_temp_B;

        end
      
    always @ (posedge S_AXI_ACLK)
        begin
            if (resetn == 1'b0)
                begin
                     hd_subsamp_ptr_L <= 0;
                     hd_subsamp_ptr_R <= 0;
                     hd_subsamp_ptr_T <= 0;
                     hd_subsamp_ptr_B <= 0;
                            
                     hd_subsamp_counter_L <= 0;
                     hd_subsamp_counter_R <= 0;
                     hd_subsamp_counter_T <= 0;
                     hd_subsamp_counter_B <= 0;
                 end
            else
                begin
                
                    // left
                    if ( i_vdma == left - dd_out_LR )
                         begin
                            hd_stored_L[j_vdma] <= red; // note: 256 - data on the left
                         end   
                     else
                          if (( i_vdma == left + dd_in_LR ) && (j_vdma >= top && j_vdma <= bottom))
                              begin
                                        //counter
                                        if ( hd_subsamp_counter_L == av_param_LR - 1)
                                            begin
                                                hd_subsamp_counter_L <= 0;
                                                hd_subsamp_ptr_L <= hd_subsamp_ptr_L + 1;
                                            end
                                        else
                                            hd_subsamp_counter_L <= hd_subsamp_counter_L + 1;
                                        // derivative sum
                                        if ( hd_subsamp_counter_L == 0 )
                                            der_sum_L <= abs_der_temp_L;
                                        else
                                            der_sum_L <= der_sum_L + abs_der_temp_L;
                                        // hd_sum_dump_enable
                                        hd_sum_dump_enable_L <= (hd_subsamp_counter_L == av_param_LR - 1) && ~hd_sum_dump_enable_L;
                                        
                              end
                             
                              
                    // right
                    if ( i_vdma == right - dd_in_LR )
                        begin
                            hd_stored_R[j_vdma] <= red; 
                        end
                    else
                         if ( ( i_vdma == right + dd_out_LR ) && (j_vdma >= top && j_vdma <= bottom))
                            begin
                                         // counter
                                         if ( hd_subsamp_counter_R == av_param_LR - 1)
                                             begin
                                                 hd_subsamp_counter_R <= 0;
                                                 hd_subsamp_ptr_R <= hd_subsamp_ptr_R + 1;
                                             end
                                         else
                                             hd_subsamp_counter_R <= hd_subsamp_counter_R + 1;                                   
                                        // deriv sum
                                        if (hd_subsamp_counter_R == 0)
                                            der_sum_R <= abs_der_temp_R;   
                                        else
                                            der_sum_R <= der_sum_R + abs_der_temp_R;
                                        // sum dump enable
                                        hd_sum_dump_enable_R <= (hd_subsamp_counter_R == av_param_LR - 1)&& ~hd_sum_dump_enable_R;
                                            
                            end          
                        
                    // top
                    if ( j_vdma == top - dd_out_TB )
                        begin
                           hd_stored_T[i_vdma] <= red;
                        end
                    else
                        if ((j_vdma == top + dd_in_TB) && (i_vdma >= left && i_vdma <= right))
                            begin
                                // counter
                                if ( hd_subsamp_counter_T == av_param_TB - 1)
                                     begin
                                          hd_subsamp_counter_T <= 0;
                                          hd_subsamp_ptr_T <= hd_subsamp_ptr_T + 1;
                                     end
                                else
                                     hd_subsamp_counter_T <= hd_subsamp_counter_T + 1;
                                // deriv sum
                                if (hd_subsamp_counter_T == 0)
                                    der_sum_T <= abs_der_temp_T;
                                else
                                    der_sum_T <= der_sum_T + abs_der_temp_T;
                                // sum dump enable
                                hd_sum_dump_enable_T <= (hd_subsamp_counter_T == av_param_TB - 1) && ~hd_sum_dump_enable_T;
                            end
                                       
                    // bottom
                    if (j_vdma == bottom - dd_in_TB)
                        begin
                            hd_stored_B[i_vdma] <= red;
                        end
                    else
                         if ((j_vdma == bottom + dd_out_TB) && (i_vdma >= left && i_vdma <= right))
                            begin
                                if ( hd_subsamp_counter_B == av_param_TB - 1)
                                     begin
                                         hd_subsamp_counter_B <= 0;
                                         hd_subsamp_ptr_B <= hd_subsamp_ptr_B + 1;
                                     end
                                else
                                     hd_subsamp_counter_B <= hd_subsamp_counter_B + 1;
                            
                                if (hd_subsamp_counter_B == 0)
                                    der_sum_B <= abs_der_temp_B;
                                else
                                    der_sum_B <= der_sum_B + abs_der_temp_B;
                                // sum dump enable
                                hd_sum_dump_enable_B <= (hd_subsamp_counter_B == av_param_TB - 1) && ~hd_sum_dump_enable_B;
                            end
                end
                
        end
    
    // NOTE: IF THE HAND DETECTION STOPS WORKING AFTER A WHILE - TRY THE FOLLOWING: USE ABS INSTEAD OF THE NOT 
    
    // the hd_min and hd_mean logic
    reg hd_dumped_value_seen_L;
    reg hd_dumped_value_seen_R;
    reg hd_dumped_value_seen_T;
    reg hd_dumped_value_seen_B;    
    reg signed [32:0] hd_dumped_value_min_L;// actually I don't think it has to be signed, but whatever :P
    reg signed [32:0] hd_dumped_value_min_R;
    reg signed [32:0] hd_dumped_value_min_T;
    reg signed [32:0] hd_dumped_value_min_B;
    
    reg signed [32:0] hd_dumped_value_max_L;// actually I don't think it has to be signed, but whatever :P
    reg signed [32:0] hd_dumped_value_max_R;
    reg signed [32:0] hd_dumped_value_max_T;
    reg signed [32:0] hd_dumped_value_max_B;
    
    always @ (posedge S_AXI_ACLK)
        begin
            if (resetn == 1'b0)
                begin
                    hd_dumped_value_seen_L <= 0;
                    hd_dumped_value_seen_R <= 0;
                    hd_dumped_value_seen_T <= 0;
                    hd_dumped_value_seen_B <= 0;                
                end
            else
                begin
                    // left
                    if (hd_sum_dump_enable_L)
                        begin
                            hd_dumped_value_seen_L <= 1;
                            if (hd_dumped_value_seen_L)
                                begin
                                    if (der_sum_L < hd_dumped_value_min_L)
                                        hd_dumped_value_min_L <= der_sum_L;
                                    if (der_sum_L > hd_dumped_value_max_L)
                                        hd_dumped_value_max_L <= der_sum_L;
                                end
                            else
                                begin
                                    hd_dumped_value_min_L <= der_sum_L;
                                    hd_dumped_value_max_L <= der_sum_L;
                                end
                        end
                    // right
                    if (hd_sum_dump_enable_R)
                        begin
                          hd_dumped_value_seen_R <= 1;
                          if (hd_dumped_value_seen_R)
                               begin
                                   if (der_sum_R < hd_dumped_value_min_R)
                                       hd_dumped_value_min_R <= der_sum_R;
                                   if (der_sum_R > hd_dumped_value_max_R)
                                       hd_dumped_value_max_R <= der_sum_R;
                               end
                          else
                               begin
                                    hd_dumped_value_max_R <= der_sum_R;
                                    hd_dumped_value_min_R <= der_sum_R;
                               end
                        end
                    // top
                   if (hd_sum_dump_enable_T)
                        begin
                          hd_dumped_value_seen_T <= 1;
                          if (hd_dumped_value_seen_T)
                               begin
                                   if (der_sum_T < hd_dumped_value_min_T)
                                       hd_dumped_value_min_T <= der_sum_T;
                                   if (der_sum_T > hd_dumped_value_max_T)
                                       hd_dumped_value_max_T <= der_sum_T;
                               end
                          else
                               begin
                                   hd_dumped_value_min_T <= der_sum_T;
                                   hd_dumped_value_max_T <= der_sum_T;
                               end
                        end
                   // bottom
                   if (hd_sum_dump_enable_B)
                        begin
                          hd_dumped_value_seen_B <= 1;
                          if (hd_dumped_value_seen_B)
                               begin
                                   if (der_sum_B < hd_dumped_value_min_B)
                                       hd_dumped_value_min_B <= der_sum_B;
                                   if (der_sum_B > hd_dumped_value_max_B)
                                       hd_dumped_value_max_B <= der_sum_B;
                               end
                          else
                               begin
                                   hd_dumped_value_min_B <= der_sum_B;
                                   hd_dumped_value_max_B <= der_sum_B;
                               end
                        end

                end
        end    
    

	endmodule
