library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity branching_logic is
    port(
        branching_type : in std_logic_vector(2 downto 0);
        sign, zero, overflow : in std_logic;
        branching_flag : out std_logic);
end branching_logic;

architecture branching_logic_arch of branching_logic is

begin
    process (branching_type, sign, zero, overflow)
    begin
        case (branching_type) is
            -- BEQ
            when "000" =>
                branching_flag <= zero;
            -- BLT
            when "001" =>
                branching_flag <= overflow XOR sign;
            -- BGE
            when "010" =>
                branching_flag <= overflow XNOR sign;
            -- BNE
            when "011" =>
                branching_flag <= NOT(zero);
            when "100" =>
                branching_flag <= '1';              
            when others => branching_flag <= '0';
        end case;
    end process;
end branching_logic_arch;
