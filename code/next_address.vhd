library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_signed.all;
use IEEE.numeric_std.all;

entity next_address is
Port(
	clk: in std_logic;
	reset: in std_logic;
	branching_flag: in std_logic;
	pc_in: in std_logic_vector(3 downto 0);
	offset: in std_logic_vector(7 downto 0);
	god_mode_full_stop : in std_logic;
	pc_out: out std_logic_vector(3 downto 0)
);
end next_address;

architecture Behavioral of next_address is

begin
process(clk, reset, god_mode_full_stop)
    begin  
        if (reset = '1') then
            pc_out <= (others => '0');
        
        elsif rising_edge(clk) and god_mode_full_stop = '0' then
            case branching_flag is
                when '1' =>
                    pc_out <= pc_in + offset(3 downto 0);
                when others =>
                    pc_out <= pc_in + 1;
            end case;
        end if;
    end process;
end Behavioral;
