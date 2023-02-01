library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use WORK.register_array_pkg.all;

entity registers is
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
	registers_content: out register_array);
end registers ;

architecture arch of registers is
	signal registers: register_array;
	signal reg_clk: std_logic;

begin
	-- mux for the clk signal of the registers
	process(clk, god_mode_write, god_mode_full_stop)
	begin
		if god_mode_full_stop = '0' then
			reg_clk <= clk;
		elsif god_mode_full_stop = '1' then
			reg_clk <= god_mode_write;
		end if;
	end process;

	-- Writing to registers
	process(reset, reg_clk, god_mode_full_stop)
	begin
		if reset = '1' then
			registers <= (others => (others => '0'));
		elsif rising_edge(reg_clk) then
			if god_mode_full_stop = '0' and write_en = '1' then
				-- NOTE: data_in refers to the data coming from the CPU in normal mode
				registers(to_integer(unsigned(rd))) <= data_in;
			elsif god_mode_full_stop = '1' then
				registers(to_integer(unsigned(god_mode_address))) <= god_mode_data;
			end if;
		end if;
	end process;
	
	-- For the CPU normal functioning
	rs1_out <= registers(to_integer(unsigned(rs1)));
	rs2_out <= registers(to_integer(unsigned(rs2)));
	
	-- To output to the display-board
	registers_content <= registers;

end arch;
