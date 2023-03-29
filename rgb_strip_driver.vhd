library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity rbg_led_driver is
port(
	 clk, switch : in std_logic;
	 din : out std_logic
	 );
end rbg_led_driver;

architecture Behavioral of rbg_led_driver is
signal data : std_logic_vector(0 to 23);
signal d_counter : integer range 0 to 24 := 0;
signal led_iterator : integer range 0 to 14 := 0;
constant num_leds : integer := 14; -- The strip doesn't set exactly this number of leds, so 
								   -- just set num_leds >> the actual number of leds on your strip
signal cycle_counter : integer := 0;
signal red : std_logic_vector(0 to 7) := (others => '0');
signal green : std_logic_vector(0 to 7) := (others => '0');
signal blue : std_logic_vector(0 to 7) := (others => '0');
begin
process (clk)
	begin
		if rising_edge(clk) then
		cycle_counter <= cycle_counter + 10;
		if switch = '1' then  -- all blue
		  red <= (others => '0');
          green <= (others => '0');
          blue <= (others => '1');
		else
		  red <= (others => '1');
          green <= (others => '0');
          blue <= (others => '0');
		end if;
			if led_iterator < num_leds then
				if d_counter < 24 then 
					if data(d_counter) = '1' then
						if cycle_counter < 800 then
							din <= '1';
						elsif cycle_counter >= 800 and cycle_counter < 1250 then
							din <= '0';
						else
							cycle_counter <= 0;
							d_counter <= d_counter + 1;
						end if;	-- if cycle_counter < 800		
					else --if data(d_counter) = '0'
						if cycle_counter < 400 then
							din <= '1';
						elsif cycle_counter >= 400 and cycle_counter < 1250 then
							din <= '0';
						else
							cycle_counter <= 0;
							d_counter <= d_counter + 1;
						end if;	--if cycle_counter < 400
					end if; --data(d_counter) = 1/0
				else --if d_counter < 24
					cycle_counter <= 0;
					d_counter <= 0;
					led_iterator <= led_iterator + 1;
				end if; --if d_counter < 24
			else --if led_iterator < num_leds
				if cycle_counter > 60000 then
					cycle_counter <= 0;
					led_iterator <= 0;
					d_counter <= 0; 
				end if; 
			end if;-- if led_iterator < num_leds
			
		end if;--rising_edge
end process;


data <= green & red & blue;

end Behavioral;
