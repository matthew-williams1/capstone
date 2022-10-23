-- 8 x 8 register file
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity registers is
port ( clk : in std_logic;
reset : in std_logic;
read_a : in std_logic_vector(2 downto 0);
read_b : in std_logic_vector(2 downto 0);
rd : std_logic_vector(2 downto 0);
data_in : std_logic_vector(7 downto 0);
write_en : in std_logic;
pc_jump_state : in std_logic_vector(7 downto 0);
jump_flag : in std_logic;
out_a : out std_logic_vector(7 downto 0); 
out_b : out std_logic_vector(7 downto 0)
);
end registers;

architecture Behaviroral of registers is
type reg_array is array(0 to 7) of std_logic_vector(7 downto 0);
signal register_arr : reg_array;

begin

--process for outputting read_a and read_b values
process(read_a, read_b)
    begin
        out_a <= register_arr(to_integer(unsigned(read_a)));
        out_b <= register_arr(to_integer(unsigned(read_b)));
end process;

--process for writing the result of ALU
process (clk, reset, write_en)
    begin
        if reset = '1' then
            for i in 0 to 7 loop
                register_arr(i) <= (others=>'0');
            end loop;

        elsif rising_edge(clk) and write_en = '1' then
            register_arr(to_integer(unsigned(rd))) <= data_in;

        end if;

end process;

--process for saving the state of the PC before a JAL(R)
process (clk, reset, write_en, jump_flag)
    begin
        if reset = '1' then
            for i in 0 to 7 loop
                register_arr(i) <= (others=>'0');
            end loop;

        elsif rising_edge(clk) and write_en = '1' and jump_flag = '1' then
            register_arr(to_integer(unsigned(rd))) <= pc_jump_state; --consider MUXing din with pc_jump_state, will prevent the need of the jal_flag control signal

        end if;

end process;

end Behaviroral;
