library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity alu is
port(input1, input2 : in std_logic_vector(7 downto 0);
	--Operation selection
    add_sub : in std_logic;
	func : in std_logic_vector(1 downto 0);
    logic : in std_logic_vector(1 downto 0);
	-- Outputs
	output : out std_logic_vector(7 downto 0) ;
	sign_bit_flag, overflow_flag, zero_flag : out std_logic);
end alu ;

architecture arch of alu is
	signal result : std_logic_vector(7 downto 0);
begin

	process (input1, input2, func, add_sub, logic)
	begin
		if func = "00" then
			result <= input2;
		elsif func = "01" then
            if add_sub = '0' then
				result <= input1 + input2;
            else
				result <= input1 - input2;
            end if;
		else
			if logic = "00" then
                result <= input1 AND input2;
			elsif logic = "01" then
				result <= input1 OR input2;
			else
				result <= input1 XOR input2;
            end if;
		end if;
  	end process;

	-- Zero flag
	process (result)
	begin
		if (result = "00000000") then
			zero_flag <= '1';
		else
			zero_flag <= '0';
		end if;
	end process;

	-- overflow flag
	process (func, input1, input2, add_sub, result)
	begin
		if (func = "01") then
			-- add two very large positive numbers
			-- (including via subtraction of a large negative number)
			if ((input1(7) = '0') AND ((input2(7) XOR add_sub) = '0')
				AND (result(7) = '1')) then
				overflow_flag <= '1';

			-- add two large negative numbers
			-- (including via subtraction of a large positive number)
			elsif ((input1(7) = '1') AND ((input2(7) XOR add_sub) = '1')
				AND (result(7) = '0')) then
				overflow_flag <= '1';

			else
				overflow_flag <= '0';
			end if;
		else
		      overflow_flag <= '0';
		end if;	
	end process;
	
	--Sign bit flag
	sign_bit_flag <= result(7);

	--Output
	output <= result;

end arch;
