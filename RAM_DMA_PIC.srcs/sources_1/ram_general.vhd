LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

USE work.PIC_pkg.all;

ENTITY ram_general IS
PORT (
   Clk      : in    std_logic;
   write_en : in    std_logic;
   oe       : in    std_logic;
   address  : in    std_logic_vector(7 downto 0);
   databus  : inout std_logic_vector(7 downto 0));   
END ram_general;

ARCHITECTURE behavior OF ram_general IS

  SIGNAL contents_ram : array8_ram(191 downto 0);

BEGIN

-------------------------------------------------------------------------
-- Memoria de propósito general
-------------------------------------------------------------------------
p_ram : process (clk)  -- no reset
begin
  if clk'event and clk = '1' then
    if write_en = '1' and unsigned(address) >= 64 and (unsigned(address) <= 255) then
      contents_ram(to_integer(unsigned(address))-64) <= databus;
    end if;
  end if;

end process;

databus <= contents_ram(to_integer(unsigned(address))) when oe = '0' and unsigned(address) >= 64 and (unsigned(address) <= 255) else (others => 'Z');

END behavior;

