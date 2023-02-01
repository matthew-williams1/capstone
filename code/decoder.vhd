library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity decoder is
	port(
		data_in : in std_logic_vector(15 downto 0);
		opcode : out std_logic_vector(3 downto 0);
		func : out std_logic;
		rd : out std_logic_vector(2 downto 0);
		rs1 : out std_logic_vector(2 downto 0);
		rs2 : out std_logic_vector(2 downto 0);
		imm : out std_logic_vector(7 downto 0)
	);
end decoder;
	
architecture decoder_arch of decoder is

	-- signals

	signal func_bit : std_logic;
	signal instruction : std_logic_vector (3 downto 0);
	signal imm_extended: std_logic_vector (7 downto 0);
--	signal imm_padded_with_0s, imm_sign_extended: std_logic_vector (7 downto 0);
--    signal imm_5bits : std_logic_vector (4 downto 0);

begin
	func_bit <= data_in(4);
	instruction <= data_in(3 downto 0);

--	imm_sign_extended(4 downto 0) <= imm_5bits;
--	imm_sign_extended(7 downto 5) <= (others => imm_5bits(4));
--	imm_padded_with_0s(4 downto 0) <= imm_5bits;
--	imm_padded_with_0s(7 downto 5) <= (others => '0');

	opcode <= instruction;
	func <= func_bit;

	process(data_in, instruction, func_bit)
	begin
		case(instruction) is
			-- ADD | SUB | MUL | XOR | AND | OR
			when "0000" | "0001" | "0010" | "0011" | "0100" | "0101" =>
				if func_bit = '0' then
					rd <= data_in(7 downto 5);
					rs1 <= data_in(10 downto 8);
					rs2 <= data_in(13 downto 11);
					imm <= (others => '0');
				else
					rd <= data_in(7 downto 5);
					rs1 <= data_in(10 downto 8);
					rs2 <= (others => '0');
					
					if (instruction = "0000" or instruction = "0001" or instruction = "0010") then
					    -- sign extended imm from 5 bits to 8 bits
						imm <= std_logic_vector(resize(signed(data_in(15 downto 11)), imm'length));
					else
					    -- leading zero-padding imm from 5 bits to 8 bits
						imm <= std_logic_vector(resize(unsigned(data_in(15 downto 11)), imm'length));
					end if;	
				end if;

			-- ST | MV
			when "0110" | "0111" =>
				if func_bit = '0' then
					rs1 <= data_in(7 downto 5);
					rs2 <= data_in(10 downto 8);
					rd <= (others => '0');
					imm <= (others => '0');
				else
					rs1 <= data_in(7 downto 5);
                    imm <= data_in(15 downto 8);
					rd <= (others => '0');
					rs2 <= (others => '0');
				end if;

			-- BEQ | BLT | BGE | BNE
			when "1000" | "1001" | "1010" | "1011" =>
				rs1 <= data_in(7 downto 5);
				rs2 <= data_in(10 downto 8);
				rd <= (others => '0');
			    -- sign extend imm from 5 bits to 8 bits
                imm <= std_logic_vector(resize(signed(data_in(15 downto 11)), imm'length));				

			-- LD
			when "1100" =>
				if func_bit = '0' then
					rd <= data_in(7 downto 5);
					rs2 <= data_in(10 downto 8);
					rs1 <= (others => '0');
					imm <= (others => '0');
				else
					rd <= data_in(7 downto 5);
					rs1 <= (others => '0');
					rs2 <= (others => '0');
					-- imm is absolute address
                    imm <= data_in(15 downto 8);
				end if;

			-- BAL
			when "1110" =>
				rd <= data_in(7 downto 5);
				rs1 <= (others => '0');
				rs2 <= (others => '0');
				-- imm is absolute address
                imm <= data_in(12 downto 5);
			
			when others =>
			    rd <= (others => '0');
			    rs1 <= (others => '0');
			    rs2 <= (others => '0');
			    imm <= (others => '0');
		end case ;
	end process;

end decoder_arch;