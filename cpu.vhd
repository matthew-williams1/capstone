library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;
use IEEE.numeric_std.all;

entity cpu is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           led : out STD_LOGIC;
           AN0 : out std_logic;
           AN1 : out std_logic;
           AN2 : out std_logic;
           AN3 : out std_logic;
           AN4 : out std_logic;
           AN5 : out std_logic;
           AN6 : out std_logic;
           AN7 : out std_logic;
           CA : out std_logic;
           CB : out std_logic;
           CC : out std_logic;
           CD : out std_logic;
           CE : out std_logic;
           CF : out std_logic;
           CG : out std_logic;
           DP : out std_logic;
           SW0 : in std_logic;
           SW1 : in std_logic;
           SW2 : in std_logic;
           SW3 : in std_logic;
           SW4 : in std_logic;
           SW5 : in std_logic;
           SW6 : in std_logic;
           SW7 : in std_logic;
           SW8 : in std_logic;
           SW9 : in std_logic;
           SW10 : in std_logic;
           SW11 : in std_logic;
           SW12 : in std_logic;
           SW13 : in std_logic;
           SW14 : in std_logic;
           SW15 : in std_logic);

end cpu;

architecture Behavioral of cpu is
type reg_array is array(0 to 7) of std_logic_vector(15 downto 0);
signal i_cache : reg_array;

component registers
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
end component;


component next_address is
Port ( clk : in std_logic;
reset : in std_logic;
pc_sel : in std_logic;
pc_in : in std_logic_vector(7 downto 0);
rs_in : in std_logic_vector(7 downto 0);
immediate : in std_logic_vector(4 downto 0);
pc_saved_jump : out std_logic_vector(7 downto 0);
pc_out : out std_logic_vector(7 downto 0)
);
end component;

signal read_a, read_b, rd : std_logic_vector(2 downto 0);
signal immediate : std_logic_vector(4 downto 0);
signal data_in, pc_jump_state, out_a, out_b, pc_in, rs_in, pc_saved_jump, pc_out : std_logic_vector(7 downto 0);
signal write_en, jump_flag, pc_sel : std_logic;
signal insn : std_logic_vector(15 downto 0);





begin
NAU: next_address port map (clk, reset, pc_sel, pc_in, rs_in, immediate, pc_saved_jump, pc_out);
RFILE: registers port map (clk, reset, read_a, read_b, rd, data_in, write_en, pc_jump_state, jump_flag, out_a, out_b);

process(clk, pc_out)

begin            
    i_cache(0)(15) <= SW15;
    i_cache(0)(14) <= SW14;
    i_cache(0)(13) <= SW13;
    i_cache(0)(12) <= SW12;
    i_cache(0)(11) <= SW11;
    i_cache(0)(10) <= SW10;
    i_cache(0)(9) <= SW9;
    i_cache(0)(8) <= SW8;
    i_cache(0)(7) <= SW7;
    i_cache(0)(6) <= SW6;
    i_cache(0)(5) <= SW5;
    i_cache(0)(4) <= SW4;
    i_cache(0)(3) <= SW3;
    i_cache(0)(2) <= SW2;
    i_cache(0)(1) <= SW1;
    i_cache(0)(0) <= SW0; 
    
    if reset = '1' then
        for i in 0 to 7 loop
            i_cache(i) <= (others=>'0');
        end loop;
        
    elsif rising_edge(clk) then
    insn <= i_cache(pc_out);
    end if;
            
            
            
end process;


end Behavioral;
