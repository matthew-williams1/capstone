library IEEE;
use IEEE.std_logic_1164.all;

entity pc is
port(
	clk, reset: in std_logic;
	d_in: in std_logic_vector(3 downto 0);
	god_mode_full_stop : in std_logic;
	q_out: out std_logic_vector(3 downto 0));
end pc;

architecture arch of pc is
begin
	process(reset, clk, god_mode_full_stop)
	begin
		if reset = '1' then
			q_out <= (others => '0');
		elsif rising_edge(clk) and god_mode_full_stop = '0' then
			q_out <= d_in;
		end if;
	end process;
end arch;
