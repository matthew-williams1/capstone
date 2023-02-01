library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use WORK.instruction_cache_array_pkg.all;

entity instruction_cache is
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
	instruction_cache_content: out instruction_cache_array);
end instruction_cache ;

architecture arch of instruction_cache is
	signal instruction_cache: instruction_cache_array;

begin

	process(reset, instruction_cache, god_mode_data, god_mode_address, god_mode_write)
	begin
		if (reset = '1') then
			instruction_cache <= (others=>(others => '0'));
		elsif rising_edge(god_mode_write) then
            instruction_cache(to_integer(unsigned(god_mode_address))) <= god_mode_data;
		end if;
	end process;
	
	-- read
	d_out <= instruction_cache(to_integer(unsigned(address)));
	
	-- For display-board	
	instruction_cache_content <= instruction_cache;

end arch;
