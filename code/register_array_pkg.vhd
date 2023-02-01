library IEEE;
use IEEE.std_logic_1164.all;

package register_array_pkg is
    type register_array is array (7 downto 0) of std_logic_vector(7 downto 0);
end package;
