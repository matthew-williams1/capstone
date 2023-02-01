library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity controller is
    port(
	-- Inputs
	opcode : in std_logic_vector(3 downto 0);
	func : in std_logic;
	-- OUTPUT CONTROL SIGNALS
	mux2_selector : out std_logic;
	-- ALU
	add_sub : out std_logic;
	logic, alu_func : out std_logic_vector(1 downto 0);
	-- Reg file
	reg_file_write_en : out std_logic;
	reg_file_data_src : out std_logic_vector(1 downto 0);
	-- Data Cache
	data_cache_write_en : out std_logic;
	-- Next Addr
	branch_type : out std_logic_vector(2 downto 0)	
    );
end controller;

architecture arch of controller is



begin
    process(opcode, func)
    begin
    -- Default output assignement to counter inferred latches
    mux2_selector <= '0';
    add_sub <= '0';
    logic <= "00";
    alu_func <= "00";
    reg_file_write_en <= '0';
    reg_file_data_src <= "00";
    data_cache_write_en <= '0';
    branch_type <= "000";
    
		case(opcode) is
		    -- ADD
			when "0000" =>
				add_sub <= '0';
				alu_func <= "01";
				reg_file_write_en <= '1';
				reg_file_data_src <= "00";
				if func = '0' then
					mux2_selector <= '0';
				else
					mux2_selector <= '1';
				end if;
							
			-- SUB
			when "0001" =>
				add_sub <= '1';
				alu_func <= "01";
				reg_file_write_en <= '1';
				reg_file_data_src <= "00";
				if func = '0' then
					mux2_selector <= '0';
				else
					mux2_selector <= '1';
				end if;
				
			-- MUL
--			when "0010" =>
--				reg_file_data_src <= "01";

			-- XOR
			when "0011" =>
				logic <= "10";
				alu_func <= "10";
                reg_file_write_en <= '1';
                reg_file_data_src <= "00";
				if func = '0' then
                    mux2_selector <= '0';
				else
                    mux2_selector <= '1';
				end if;
							
			-- AND
			when "0100" =>
				logic <= "00";
				alu_func <= "10";
                reg_file_write_en <= '1';
                reg_file_data_src <= "00";
				if func = '0' then
                    mux2_selector <= '0';
				else
                    mux2_selector <= '1';
				end if;
							
			-- OR
			when "0101" =>
				logic <= "01";
				alu_func <= "10";
                reg_file_write_en <= '1';
                reg_file_data_src <= "00";
				if func = '0' then
                    mux2_selector <= '0';
				else
                    mux2_selector <= '1';
				end if;

			-- BEQ
			when "1000" =>
				add_sub <= '1';
				alu_func <= "01";
				branch_type <= "000";
                reg_file_write_en <= '0';
                mux2_selector <= '0';
				data_cache_write_en <= '0';			
					
			-- BLT
			when "1001" =>
			    add_sub <= '1';
			    alu_func <= "01";
			    branch_type <= "001";
                reg_file_write_en <= '0';
                mux2_selector <= '0';
				data_cache_write_en <= '0';
				
			-- BGE
			when "1010" =>
			    add_sub <= '1';
                alu_func <= "01";
                branch_type <= "010";
                reg_file_write_en <= '0';
                mux2_selector <= '0';
				data_cache_write_en <= '0';
				
			-- BNE
			when "1011" =>
			    add_sub <= '1';
                alu_func <= "01";
                branch_type <= "011";
                reg_file_write_en <= '0';
                mux2_selector <= '0';
				data_cache_write_en <= '0';
				
			-- LD
			when "1100" =>
				reg_file_write_en <= '1';
                reg_file_data_src <= "10";
				if func = '0' then
					mux2_selector <= '0';
				else
                    mux2_selector <= '1';
				end if;

			-- ST
			when "0110" =>
                data_cache_write_en <= '1';
			    if func = '0' then
                    mux2_selector <= '0';
                else
                    mux2_selector <= '1';
                end if;

			-- MV
			when "0111" =>
                alu_func <= "00";
                reg_file_write_en <= '1';
                reg_file_data_src <= "00";
			    if func = '0' then
                    mux2_selector <= '0';
                else
                    mux2_selector <= '1';
                end if;

			-- BAL
			when others =>
                branch_type <= "100";

		end case;
	end process;
end arch;