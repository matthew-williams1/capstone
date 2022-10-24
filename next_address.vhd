library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_signed.all;
use IEEE.numeric_std.all;

entity next_address is
Port ( clk : in std_logic;
reset : in std_logic;
pc_sel : in std_logic;
pc_in : in std_logic_vector(7 downto 0);
rs_in : in std_logic_vector(7 downto 0);
immediate : in std_logic_vector(4 downto 0);
pc_saved_jump : out std_logic_vector(7 downto 0);
pc_out : out std_logic_vector(7 downto 0)
);
end next_address;

architecture Behavioral of next_address is

begin
process(clk, reset)
    begin  
        if (reset = '0') then
            pc_out <= (others => '0');
        
        elsif rising_edge(clk) then
            case pc_sel is
                when 00 =>
                    pc_out <= pc_in + 2;
                when 01 =>
                    pc_out <= pc_in + immediate;
                when others =>
                    pc_out <= pc_in + immediate + rs_in; 
            end case;
        end if;
    end process;

end Behavioral;
