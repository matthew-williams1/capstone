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
		case(opcode) is
		    -- ADD
			when "0000" =>
				add_sub <= '0';
				alu_func <= "01";
				logic <= "XX";
				reg_file_write_en <= '1';
				reg_file_data_src <= "00";
				if func = '0' then
					mux2_selector <= '0';
				elsif func = '1' then
					mux2_selector <= '1';
				end if;
				branch_type <= "XXX";
				data_cache_write_en <= 'X';				
			-- SUB
			when "0001" =>
				add_sub <= '1';
				alu_func <= "01";
				logic <= "XX";
				reg_file_write_en <= '1';
				reg_file_data_src <= "00";
				if func = '0' then
					mux2_selector <= '0';
				elsif func = '1' then
					mux2_selector <= '1';
				end if;
				branch_type <= "XXX";
				data_cache_write_en <= 'X';
			-- MUL
--			when "0010" =>
--				reg_file_data_src <= "01";
			-- XOR
			when "0011" =>
				logic <= "10";
				alu_func <= "10";
				add_sub <= 'X';
                reg_file_write_en <= '1';
                reg_file_data_src <= "00";
				if func = '0' then
                    mux2_selector <= '0';
				elsif func = '1' then
                    mux2_selector <= '1';
				end if;
				branch_type <= "XXX";
				data_cache_write_en <= 'X';								
			-- AND
			when "0100" =>
				logic <= "00";
				alu_func <= "10";
				add_sub <= 'X';
                reg_file_write_en <= '1';
                reg_file_data_src <= "00";
				if func = '0' then
                    mux2_selector <= '0';
				elsif func = '1' then
                    mux2_selector <= '1';
				end if;
				branch_type <= "XXX";
				data_cache_write_en <= 'X';				
			-- OR
			when "0101" =>
				logic <= "01";
				alu_func <= "10";
				add_sub <= 'X';
                reg_file_write_en <= '1';
                reg_file_data_src <= "00";
				if func = '0' then
                    mux2_selector <= '0';
				elsif func = '1' then
                    mux2_selector <= '1';
				end if;
				branch_type <= "XXX";
				data_cache_write_en <= 'X';
			-- BEQ
			when "1000" =>
				add_sub <= '1';
				alu_func <= "01";
				branch_type <= "000";
				logic <= "XX";
                reg_file_write_en <= '0';
                reg_file_data_src <= "XX";
                mux2_selector <= '0';
				data_cache_write_en <= '0';				
			-- BLT
			when "1001" =>
			    add_sub <= '1';
			    alu_func <= "01";
			    branch_type <= "001";
				logic <= "XX";
                reg_file_write_en <= '0';
                reg_file_data_src <= "XX";
                mux2_selector <= '0';
				data_cache_write_en <= '0';
			-- BGE
			when "1010" =>
			    add_sub <= '1';
                alu_func <= "01";
                branch_type <= "010";
				logic <= "XX";
                reg_file_write_en <= '0';
                reg_file_data_src <= "XX";
                mux2_selector <= '0';
				data_cache_write_en <= '0';
			-- BNE
			when "1011" =>
			    add_sub <= '1';
                alu_func <= "01";
                branch_type <= "011";
				logic <= "XX";
                reg_file_write_en <= '0';
                reg_file_data_src <= "XX";
                mux2_selector <= '0';
				data_cache_write_en <= '0';
			-- LD
			when "1100" =>
				reg_file_write_en <= '1';
                reg_file_data_src <= "10";
				if func = '0' then
					mux2_selector <= '0';
				elsif func = '1' then
                    mux2_selector <= '1';
				end if;
			    add_sub <= 'X';
                alu_func <= "XX";
                branch_type <= "XXX";
				logic <= "XX";
				data_cache_write_en <= 'X';
			-- ST
			when "0110" =>
                data_cache_write_en <= '1';
			    if func = '0' then
                    mux2_selector <= '0';
                elsif func = '1' then
                    mux2_selector <= '1';
                end if;
				reg_file_write_en <= 'X';
                reg_file_data_src <= "XX";
			    add_sub <= 'X';
                alu_func <= "XX";
                branch_type <= "XXX";
				logic <= "XX";
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
                branch_type <= "XXX";
				logic <= "XX";
				add_sub <= 'X';
				data_cache_write_en <= 'X';
			-- BAL
			when others =>
                branch_type <= "100";
                mux2_selector <= 'X';
                add_sub <= 'X';
		        logic <= "XX";
		        alu_func <= "XX";
		        reg_file_write_en <= 'X';
                reg_file_data_src <= "XX";
                data_cache_write_en <= 'X';
		end case;
	end process;
end arch;
