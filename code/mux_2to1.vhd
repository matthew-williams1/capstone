library IEEE;
use IEEE.std_logic_1164.all;

entity mux_2to1 is
port(
	input1, input2: in std_logic_vector(7 downto 0);
	selector: in std_logic;
	selected: out std_logic_vector(7 downto 0));
end mux_2to1;

architecture arch of mux_2to1 is
begin
	process (input1, input2, selector)
	begin
	case (selector) is
		when '0' =>
        		selected <= input1;
		when '1' =>
			selected <= input2;
		when others => null;
	end case;
	end process;
end arch;
