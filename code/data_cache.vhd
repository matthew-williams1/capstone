library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use WORK.data_cache_array_pkg.all;

entity data_cache is
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
	data_cache_content: out data_cache_array);
end data_cache ;

architecture arch of data_cache is
	signal data_cache: data_cache_array;
	signal reg_clk: std_logic;

begin
	-- mux for the clk signal of the data_cache_registers
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
			data_cache <= (others => (others => '0'));
		elsif rising_edge(reg_clk) then
			if god_mode_full_stop = '0' and write_en = '1' then
				-- NOTE: data_in refers to the data coming from the CPU in normal mode
				data_cache(to_integer(unsigned(address))) <= d_in;
			elsif god_mode_full_stop = '1' then
				data_cache(to_integer(unsigned(god_mode_address))) <= god_mode_data;
			end if;
		end if;
	end process;
	
	-- For the CPU normal functioning
	d_out <= data_cache(to_integer(unsigned(address)));

	-- To output to the display-board
	data_cache_content <= data_cache;

end arch;
