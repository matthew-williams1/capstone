library IEEE;
use IEEE.std_logic_1164.all;

entity mux_3to1 is
port(
	input1, input2, input3: in std_logic_vector(7 downto 0);
	selector: in std_logic_vector(1 downto 0);
	selected: out std_logic_vector(7 downto 0));
end mux_3to1;

architecture arch of mux_3to1 is
begin
	process (input1, input2, input3, selector)
	begin
	case (selector) is
		when "00" =>
        		selected <= input1;
		when "01" =>
			selected <= input2;
		when others =>
			selected <= input3;
	end case;
	end process;
end arch;
