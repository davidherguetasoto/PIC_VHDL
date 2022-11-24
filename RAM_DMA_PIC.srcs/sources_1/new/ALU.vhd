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

--------------------------------------------------------
--REGISTROS
signal REG_A : std_logic_vector(7 downto 0);
signal REG_B : std_logic_vector(7 downto 0);
signal REG_ACC : std_logic_vector(7 downto 0);
signal REG_INDEX : std_logic_vector(7 downto 0);
--------------------------------------------------------

--INTERNAL DATABUS 
signal ALU_Databus : std_logic_vector(7 downto 0);

begin

process(Reset, Clk)

begin
    if Reset = '0' then 
        REG_A <= X"00";
        REG_B <= X"00";
        REG_ACC <= X"00";
        REG_INDEX <= X"00";
        
        Index_Reg <= X"00";
        FlagZ <= '0';
        FlagC <= '0';
        FlagN <= '0';
        FlagE <= '0';
        
end process;

end Behavioral;
