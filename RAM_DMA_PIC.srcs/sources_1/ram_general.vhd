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

  SIGNAL contents_ram : array8_ram(255 downto 0);
  attribute keep:boolean;
  attribute keep of contents_ram:signal is true;

BEGIN

-------------------------------------------------------------------------
-- Memoria de prop�sito general
-------------------------------------------------------------------------
p_ram : process (clk)  -- no reset
begin
  if clk'event and clk = '1' then
    if write_en = '1' and unsigned(address) >= 64 and (unsigned(address) <= 319) then
      contents_ram(to_integer(unsigned(address))-64) <= databus;
    end if;
  end if;

end process;

databus <= contents_ram(to_integer(unsigned(address))-64) when oe = '0' and unsigned(address) >= 64 and (unsigned(address) <= 319) else (others => 'Z');

END behavior;

