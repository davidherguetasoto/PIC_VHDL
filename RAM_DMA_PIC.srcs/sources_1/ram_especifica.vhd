
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

USE work.PIC_pkg.all;

ENTITY ram_especifica IS
PORT (
   Clk      : in    std_logic;
   Reset    : in    std_logic;
   write_en : in    std_logic;
   oe       : in    std_logic;
   address  : in    std_logic_vector(7 downto 0);   
   databus  : inout std_logic_vector(7 downto 0);
   switches : out   std_logic_vector(7 downto 0);
   temp_l   : out   std_logic_vector(6 downto 0);
   temp_h   : out   std_logic_vector(6 downto 0));   
END ram_especifica;

ARCHITECTURE behavior OF ram_especifica IS

  SIGNAL contents_ram : array8_ram(63 downto 0);
  attribute keep:boolean;
  attribute keep of contents_ram:signal is true;
  attribute keep of oe:signal is true;
  attribute keep of write_en:signal is true;
  attribute keep of address:signal is true;
  
  signal content_ram_temp : STD_LOGIC_VECTOR(7 downto 0);
  
BEGIN
p_ram : process (clk, reset)
begin
  if Reset = '0' then
    reset_all : for i in 0 to 63 loop
        contents_ram(i) <= (others => '0');               
    end loop;    
    contents_ram(to_integer(unsigned(T_STAT))) <= "00010000"; 
  elsif clk'event and clk = '1' then
    if write_en = '1' and oe='1' then
      contents_ram(to_integer(unsigned(address))) <= databus;
    end if;
  end if;
end process;

databus <= contents_ram(to_integer(unsigned(address))) when oe = '0' and write_en='0' else (others => 'Z');

gen_switches : for i in 0 to 7 generate
   switches(i) <= contents_ram(to_integer(unsigned(SWITCH_BASE) + to_unsigned(i,SWITCH_BASE'length)))(0);
end generate;       
        
-------------------------------------------------------------------------
-- Decodificador de BCD a 7 segmentos
-------------------------------------------------------------------------

with contents_ram(to_integer(unsigned(T_STAT)))(7 downto 4) select
content_ram_temp <=
    "11111111" when "0000", -- error   
    contents_ram(to_integer(unsigned(T_STAT)))(7 downto 0) when others;  
    
with content_ram_temp(7 downto 4) select
Temp_H <=
    "0000110" when "0001",  -- 1
    "1011011" when "0010",  -- 2
    "1111001" when others;  -- E (error)

with content_ram_temp(3 downto 0) select
Temp_L <=   
    "0111111" when "0000",  -- 0
    "0000110" when "0001",  -- 1
    "1011011" when "0010",  -- 2
    "1001111" when "0011",  -- 3
    "1100110" when "0100",  -- 4
    "1101101" when "0101",  -- 5
    "1111101" when "0110",  -- 6
    "0000111" when "0111",  -- 7
    "1111111" when "1000",  -- 8
    "1101111" when "1001",  -- 9    
    "1010000" when others;    -- r (error)  

END behavior;