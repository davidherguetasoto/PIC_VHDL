library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.PIC_pkg.all;

entity ALU is
port (
Reset : in std_logic; -- asynnchronous, active low
Clk : in std_logic; -- Sys clock, 20MHz, rising_edge
u_instruction : in alu_op; -- u-instructions from CPU
FlagZ : out std_logic; -- Zero flag
FlagC : out std_logic; -- Carry flag
FlagN : out std_logic; -- Nibble carry bit
FlagE : out std_logic; -- Error flag
Index_Reg : out std_logic_vector(7 downto 0); -- Index register
Databus : inout std_logic_vector(7 downto 0) -- System Data bus
);
end ALU;

architecture Behavioral of ALU is

begin


end Behavioral;
