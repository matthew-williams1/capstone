library IEEE;
use IEEE.std_logic_1164.all;

package data_cache_array_pkg is
    type data_cache_array is array (15 downto 0) of std_logic_vector(7 downto 0);
end package;
