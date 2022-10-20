
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

USE work.PIC_pkg.all;

ENTITY ram IS
PORT (
   Clk      : in    std_logic;
   Reset    : in    std_logic;
   write_en : in    std_logic;
   oe       : in    std_logic;
   address  : in    std_logic_vector(3 downto 0);
   databus  : inout std_logic_vector(7 downto 0));
END ram;

ARCHITECTURE behavior OF ram IS

  SIGNAL contents_ram : array8_ram(15 downto 0);

BEGIN

-------------------------------------------------------------------------
-- Memoria de propósito general
-------------------------------------------------------------------------
p_ram : process (clk)  -- no reset
begin
  
  if clk'event and clk = '1' then
    if write_en = '1' then
      contents_ram(to_integer(unsigned(address))) <= databus;
    end if;
  end if;

end process;

databus <= contents_ram(to_integer(unsigned(address))) when oe = '0' else (others => 'Z');
-------------------------------------------------------------------------

-------------------------------------------------------------------------
-- Decodificador de BCD a 7 segmentos
-------------------------------------------------------------------------
--with contents_ram()(7 downto 4) select
--Temp_H <=
--    "0111111" when "0000";  -- 0
--    "0000110" when "0001",  -- 1
--    "1011011" when "0010",  -- 2
--    "1001111" when "0011",  -- 3
--    "1100110" when "0100",  -- 4
--    "1101101" when "0101",  -- 5
--    "1111101" when "0110",  -- 6
--    "0000111" when "0111",  -- 7
--    "1111111" when "1000",  -- 8
--    "1101111" when "1001",  -- 9
--    "1111001" when others;  -- E (error)
-------------------------------------------------------------------------

END behavior;

