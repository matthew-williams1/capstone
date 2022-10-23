library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.std_logic_unsigned.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity seven_segment_real_test is
    Port ( clk : in STD_LOGIC;
           rst_n : in STD_LOGIC;
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

end seven_segment_real_test;

architecture Behavioral of seven_segment_real_test is
signal counter: std_logic_vector (17 downto 0);
signal led_high : std_logic;
signal dec_num : integer;
signal d0 : integer;
signal d1 : integer;
signal d2 : integer;
signal d0_arr : std_logic_vector (6 downto 0);
signal d1_arr : std_logic_vector (6 downto 0);
signal d2_arr : std_logic_vector (6 downto 0);
signal bin_num : std_ulogic_vector (7 downto 0);
begin

dec_to_digi : process(dec_num)
    begin
    dec_num <= to_integer(unsigned(bin_num));
        if rising_edge(clk) then
            d0 <= dec_num mod 10;
            d1 <= (dec_num mod 100)/10;
            d2 <= dec_num /100;
        end if;
end process dec_to_digi;

ss_out_dec: process(clk, d0, d1, d2)
    begin
        if rising_edge(clk) then
            case d0 is
                when 0 =>
                    d0_arr <= "0000001";
                when 1 =>
                    d0_arr <= "1001111";
                when 2 =>
                    d0_arr <= "0010010";
                when 3 =>
                    d0_arr <= "0000110";
                when 4 =>
                    d0_arr <= "1001100";
                when 5 =>
                    d0_arr <= "0100100";
                when 6 =>
                    d0_arr <= "0100000"; 
                when 7 =>
                    d0_arr <= "0001111";
                when 8 =>
                    d0_arr <= "0000000";
                when others =>
                    d0_arr <= "0000100";             
            end case;
            
            case d1 is
                when 0 =>
                    d1_arr <= "0000001";
                when 1 =>
                    d1_arr <= "1001111";
                when 2 =>
                    d1_arr <= "0010010";
                when 3 =>
                    d1_arr <= "0000110";
                when 4 =>
                    d1_arr <= "1001100";
                when 5 =>
                    d1_arr <= "0100100";
                when 6 =>
                    d1_arr <= "0100000"; 
                when 7 =>
                    d1_arr <= "0001111";
                when 8 =>
                    d1_arr <= "0000000";
                when others =>
                    d1_arr <= "0000100";             
            end case; 
        
            case d2 is
                when 0 =>
                    d2_arr <= "0000001";
                when 1 =>
                    d2_arr <= "1001111";
                when 2 =>
                    d2_arr <= "0010010";
                when 3 =>
                    d2_arr <= "0000110";
                when 4 =>
                    d2_arr <= "1001100";
                when 5 =>
                    d2_arr <= "0100100";
                when 6 =>
                    d2_arr <= "0100000"; 
                when 7 =>
                    d2_arr <= "0001111";
                when 8 =>
                    d2_arr <= "0000000";
                when others =>
                    d2_arr <= "0000100";             
            end case; 
                   
        end if;
end process ss_out_dec;

seg_out:process(clk, d0, d1, d2)
begin
    if rising_edge(clk) then
        
            if counter = "1" then
                AN0<= '0';
                AN1<= '1';
                AN2<= '1';                  
                CA <= d0_arr(6);
                CB <= d0_arr(5);
                CC <= d0_arr(4);
                CD <= d0_arr(3);
                CE <= d0_arr(2);
                CF <= d0_arr(1);
                CG <= d0_arr(0);
                end if;
            if counter = "010101010101010101" then
                AN0<= '1';
                AN1<= '0';
                AN2<= '1';                  
                CA <= d1_arr(6);
                CB <= d1_arr(5);
                CC <= d1_arr(4);
                CD <= d1_arr(3);
                CE <= d1_arr(2);
                CF <= d1_arr(1);
                CG <= d1_arr(0);
            end if;
            if counter = "0101010101010101010" then
                AN0<= '1';
                AN1<= '1';
                AN2<= '0';
                CA <= d2_arr(6);
                CB <= d2_arr(5);
                CC <= d2_arr(4);
                CD <= d2_arr(3);
                CE <= d2_arr(2);
                CF <= d2_arr(1);
                CG <= d2_arr(0);            
            end if;
            
            if counter = "1000000000000000000" then
            counter <= (others => '0');
            end if;
            
            counter <= counter + 1;
            AN3 <= '1';
            AN4 <= '1';
            AN5 <= '1';
            AN6 <= '1';
            AN7 <= '1';
            
    end if;
end process seg_out;

switches: process(clk)
    begin
        if rising_edge(clk) then
            bin_num(7) <= SW7;
            bin_num(6) <= SW6;
            bin_num(5) <= SW5;
            bin_num(4) <= SW4;
            bin_num(3) <= SW3;
            bin_num(2) <= SW2;
            bin_num(1) <= SW1;
            bin_num(0) <= SW0;   
        end if;
end process switches;

led <= led_high;
end Behavioral;
