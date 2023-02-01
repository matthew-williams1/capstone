library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use WORK.alu;
use WORK.branching_logic;
use WORK.controller;
use WORK.data_cache;
use WORK.decoder;
use WORK.instruction_cache;
use WORK.mux_2to1;
use WORK.mux_3to1;
use WORK.next_address;
use WORK.pc;
use WORK.registers;
use WORK.data_cache_array_pkg.all;
use WORK.instruction_cache_array_pkg.all;
use WORK.register_array_pkg.all;

entity cpu is
port(
	-- inputs
	clk: in std_logic;
	reset: in std_logic;
	god_mode_data_for_instruction_cache: in std_logic_vector(15 downto 0);
	god_mode_data_for_data_cache: in std_logic_vector(7 downto 0);
	god_mode_data_for_registers: in std_logic_vector(7 downto 0);
	god_mode_address_instruction_cache: in std_logic_vector(3 downto 0);
	god_mode_address_data_cache: in std_logic_vector(3 downto 0);
	god_mode_address_register: in std_logic_vector(2 downto 0);
	god_mode_write_instruction_cache: in std_logic;
	god_mode_write_data_cache: in std_logic;
	god_mode_write_register: in std_logic;
	god_mode_full_stop : in std_logic;

	--outputs
	pc_content: out std_logic_vector(3 downto 0);
	instruction_cache_content: out instruction_cache_array;
	data_cache_content: out data_cache_array;
	registers_content: out register_array;
	alu_input1, alu_input2, alu_output: out std_logic_vector(7 downto 0);
	alu_overflow_flag, alu_sign_bit_flag, alu_zero_flag: out std_logic
	--alu_operation (use opcode)
	--other muxes and control_unit signals
	);

end cpu;

architecture arch of cpu is

	-- internal signals (wires)
	signal pc_out_to_fork_icache_next_address: std_logic_vector(3 downto 0);
	signal next_address_to_pc: std_logic_vector(3 downto 0);
	signal icache_to_decoder: std_logic_vector(15 downto 0);
	signal decoder_opcode_to_control_unit: std_logic_vector(3 downto 0);
	signal decoder_func_to_control_unit: std_logic;
	signal decoder_rs1_to_registers: std_logic_vector(2 downto 0);
	signal decoder_rs2_to_registers: std_logic_vector(2 downto 0);
	signal decoder_rd_to_registers: std_logic_vector(2 downto 0);
	signal decoder_imm_to_mux_and_next_address: std_logic_vector(7 downto 0);
	signal control_unit_to_alu_add_sub: std_logic;
	signal control_unit_to_alu_func: std_logic_vector(1 downto 0);
	signal control_unit_to_alu_logic_func: std_logic_vector(1 downto 0);
	signal control_unit_to_dcache_write_en: std_logic;
	signal control_unit_to_registers_write_en: std_logic;
	signal control_unit_to_branching_unit: std_logic_vector(2 downto 0);
	signal control_unit_to_mux2to1: std_logic;
	signal control_unit_to_mux3to1: std_logic_vector(1 downto 0);
	signal branching_unit_to_next_address: std_logic;
	signal register_rs1_out_to_fork_alu_input1_ext_board_dcache_d_in: std_logic_vector(7 downto 0);
	signal register_rs2_out_to_mux: std_logic_vector(7 downto 0);
	signal mux_to_fork_alu_input2_ext_board_dcache_address: std_logic_vector(7 downto 0);
	signal alu_overflow_flag_to_branching_logic_unit: std_logic;
	signal alu_zero_flag_to_branching_logic_unit: std_logic;
	signal alu_sign_bit_flag_to_branching_logic_unit: std_logic;
	signal alu_output_to_mux_for_reg_d_in: std_logic_vector(7 downto 0);
	signal dcache_out_to_mux_for_reg_d_in: std_logic_vector(7 downto 0);
	signal external_board_to_mux_for_reg_d_in: std_logic_vector(7 downto 0); -- ** TO DO set a driver for this signal **
	signal mux_to_reg_d_in: std_logic_vector(7 downto 0);


	-- components
	component pc is
		port(
			clk, reset: in std_logic;
			d_in: in std_logic_vector(3 downto 0);
			god_mode_full_stop : in std_logic;
			q_out: out std_logic_vector(3 downto 0)
		);
	end component;

	component next_address is
		port(
			clk: in std_logic;
			reset: in std_logic;
			branching_flag: in std_logic;
			pc_in: in std_logic_vector(3 downto 0);
			offset: in std_logic_vector(7 downto 0);
			god_mode_full_stop : in std_logic;
			pc_out: out std_logic_vector(3 downto 0)
		);
	end component;
	
	component controller is
		port(
			-- Inputs
			opcode: in std_logic_vector(3 downto 0);
			func: in std_logic;
			-- OUTPUT CONTROL SIGNALS
			mux2_selector : out std_logic;
			--ALU
			add_sub : out std_logic;
			logic, alu_func : out std_logic_vector(1 downto 0);
			-- Reg file
			reg_file_write_en : out std_logic;
			reg_file_data_src : out std_logic_vector(1 downto 0);
			-- Data Cache
			data_cache_write_en : out std_logic;
			-- Next Addr
			branch_type : out std_logic_vector(2 downto 0)
		);
	end component;

	component branching_logic is
		port(
        	branching_type : in std_logic_vector(2 downto 0);
        	sign, zero, overflow : in std_logic;
        	branching_flag : out std_logic
		);
	end component;
	
	component instruction_cache is
		port(
			-- normal stuff
			reset: in std_logic;
			address: in std_logic_vector(3 downto 0);
			d_out: out std_logic_vector(15 downto 0);
			
			-- god mode
			god_mode_data: in std_logic_vector(15 downto 0);
			god_mode_address: in std_logic_vector(3 downto 0);
			god_mode_write: in std_logic;
			-- for seven segment displays
			instruction_cache_content: out instruction_cache_array
		);
	end component;
	
	component decoder is
		port(
			data_in : in std_logic_vector(15 downto 0);
			opcode : out std_logic_vector(3 downto 0);
			func : out std_logic;
			rd : out std_logic_vector(2 downto 0);
			rs1 : out std_logic_vector(2 downto 0);
			rs2 : out std_logic_vector(2 downto 0);
			imm : out std_logic_vector(7 downto 0)
		);
	end component;
	
	component registers is
		port(
			-- normal stuff
			clk, reset : in std_logic;
			data_in : in std_logic_vector(7 downto 0);
			write_en : in std_logic;
			rs1 : in std_logic_vector(2 downto 0);
			rs2 : in std_logic_vector(2 downto 0);
			rd : in std_logic_vector(2 downto 0);
			rs1_out : out std_logic_vector(7 downto 0);
			rs2_out : out std_logic_vector(7 downto 0);

			-- god mode
			god_mode_data: in std_logic_vector(7 downto 0);
			god_mode_address: in std_logic_vector(2 downto 0);
			god_mode_write: in std_logic;
			god_mode_full_stop : in std_logic;
			-- for seven segment displays
			registers_content: out register_array
		);
	end component;
	
	component ALU is
		port(
			input1, input2: in std_logic_vector(7 downto 0);
			add_sub: in std_logic;
			logic: in std_logic_vector(1 downto 0);
			func: in std_logic_vector(1 downto 0);
			output: out std_logic_vector(7 downto 0);
			overflow_flag, zero_flag, sign_bit_flag: out std_logic
		);	
	end component;
	
	component data_cache is
		port(
			-- normal stuff
			d_in: in std_logic_vector(7 downto 0);
			reset: in std_logic;
			clk: in std_logic;
			write_en: in std_logic;
			address: in std_logic_vector(3 downto 0);
			d_out: out std_logic_vector(7 downto 0);
			
			-- god mode
			god_mode_data: in std_logic_vector(7 downto 0);
			god_mode_address: in std_logic_vector(3 downto 0);
			god_mode_write: in std_logic;
			god_mode_full_stop : in std_logic;
			-- for seven segment displays
			data_cache_content: out data_cache_array
		);
	end component;

	component mux_2to1 is
		port(
			input1, input2: in std_logic_vector(7 downto 0);
			selector: in std_logic;
			selected: out std_logic_vector(7 downto 0));
	end component;

	component mux_3to1 is
		port(
			input1, input2, input3: in std_logic_vector(7 downto 0);
			selector: in std_logic_vector(1 downto 0);
			selected: out std_logic_vector(7 downto 0)
		);
	end component;


begin
	--port maps

	pc_unit: pc
		port map(
			clk => clk,
			reset => reset,
			god_mode_full_stop => god_mode_full_stop,
			d_in => next_address_to_pc,
			q_out => pc_out_to_fork_icache_next_address
		);

	
	next_add: next_address
		port map(
			clk => clk,
			reset => reset,
			branching_flag => branching_unit_to_next_address,
			pc_in => pc_out_to_fork_icache_next_address,
			god_mode_full_stop => god_mode_full_stop,
			offset => decoder_imm_to_mux_and_next_address,
			pc_out => next_address_to_pc
		);

	branching_unit: branching_logic
		port map(
			branching_type => control_unit_to_branching_unit,
        	sign => alu_sign_bit_flag_to_branching_logic_unit,
			zero => alu_zero_flag_to_branching_logic_unit,
			overflow => alu_overflow_flag_to_branching_logic_unit,
        	branching_flag => branching_unit_to_next_address
		);

	i_cache: instruction_cache
		port map(
			reset => reset,
			address => pc_out_to_fork_icache_next_address,
			d_out => icache_to_decoder,			
			-- god mode
			god_mode_data => god_mode_data_for_instruction_cache,
			god_mode_address => god_mode_address_instruction_cache,
			god_mode_write => god_mode_write_instruction_cache,
			-- for seven segment displays
			instruction_cache_content => instruction_cache_content
		);

	decoder_unit: decoder
		port map(
			data_in => icache_to_decoder,
			opcode => decoder_opcode_to_control_unit,
			func => decoder_func_to_control_unit,
			rd => decoder_rd_to_registers,
			rs1 => decoder_rs1_to_registers,
			rs2 => decoder_rs2_to_registers,
			imm => decoder_imm_to_mux_and_next_address
		);
		
    controller_unit: controller
        port map(
            opcode => decoder_opcode_to_control_unit, 
            func => decoder_func_to_control_unit,
            mux2_selector => control_unit_to_mux2to1,   
            add_sub => control_unit_to_alu_add_sub,
            logic => control_unit_to_alu_logic_func,
            alu_func => control_unit_to_alu_func,    
            reg_file_write_en => control_unit_to_registers_write_en,
            reg_file_data_src => control_unit_to_mux3to1,      
            data_cache_write_en => control_unit_to_dcache_write_en,
            branch_type => control_unit_to_branching_unit
        );

	reg: registers
		port map(
			-- normal stuff
			data_in => mux_to_reg_d_in,
			reset => reset,
			clk => clk,
			write_en => control_unit_to_registers_write_en,
			rs1 => decoder_rs1_to_registers,
			rs2 => decoder_rs2_to_registers,
			rd => decoder_rd_to_registers,
			rs1_out => register_rs1_out_to_fork_alu_input1_ext_board_dcache_d_in,
			rs2_out => register_rs2_out_to_mux,
			
			-- god mode
			god_mode_data => god_mode_data_for_registers,
			god_mode_address => god_mode_address_register,
			god_mode_full_stop => god_mode_full_stop,
			god_mode_write => god_mode_write_register,
			-- for seven segment displays
			registers_content => registers_content
		);

	ALU_unit: ALU
		port map(
			input1 => register_rs1_out_to_fork_alu_input1_ext_board_dcache_d_in,
			input2 => mux_to_fork_alu_input2_ext_board_dcache_address,
			add_sub => control_unit_to_alu_add_sub,
			logic => control_unit_to_alu_logic_func,
			func => control_unit_to_alu_func,
			output => alu_output_to_mux_for_reg_d_in,
			overflow_flag => alu_overflow_flag_to_branching_logic_unit,
			zero_flag => alu_zero_flag_to_branching_logic_unit,
			sign_bit_flag => alu_sign_bit_flag_to_branching_logic_unit
		);
	
	d_cache: data_cache
		port map(
			-- normal stuff
			d_in => register_rs1_out_to_fork_alu_input1_ext_board_dcache_d_in,
			reset => reset,
			clk => clk,
			write_en => control_unit_to_dcache_write_en,
			address => mux_to_fork_alu_input2_ext_board_dcache_address(3 downto 0),
			d_out => dcache_out_to_mux_for_reg_d_in,
			
			-- god mode
			god_mode_data => god_mode_data_for_data_cache,
			god_mode_address => god_mode_address_data_cache,
			god_mode_write => god_mode_write_data_cache,
			god_mode_full_stop => god_mode_full_stop,
			-- for seven segment displays
			data_cache_content => data_cache_content
		);

	mux_data_select: mux_2to1
		port map(
			input1 => register_rs2_out_to_mux,
			input2 => decoder_imm_to_mux_and_next_address,
			selector => control_unit_to_mux2to1,
			selected => mux_to_fork_alu_input2_ext_board_dcache_address
		);
	
	mux_reg_d_in: mux_3to1
		port map(
			input1 => alu_output_to_mux_for_reg_d_in,
			input2 => external_board_to_mux_for_reg_d_in,
			input3 => dcache_out_to_mux_for_reg_d_in,
			selector => control_unit_to_mux3to1,
			selected => mux_to_reg_d_in
		);


	-- signals to outputs
	pc_content <= pc_out_to_fork_icache_next_address;
	alu_input1 <= register_rs1_out_to_fork_alu_input1_ext_board_dcache_d_in;
	alu_input2 <= mux_to_fork_alu_input2_ext_board_dcache_address;
	alu_output <= alu_output_to_mux_for_reg_d_in;
	alu_overflow_flag <= alu_overflow_flag_to_branching_logic_unit;
	alu_sign_bit_flag <= alu_sign_bit_flag_to_branching_logic_unit;
	alu_zero_flag <= alu_zero_flag_to_branching_logic_unit;

end arch;
