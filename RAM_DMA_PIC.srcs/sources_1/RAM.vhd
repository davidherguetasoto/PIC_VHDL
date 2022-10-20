
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

USE work.PIC_pkg.all;

ENTITY RAM IS
PORT (
   Clk      : in    std_logic;
   Reset    : in    std_logic;
   write_en : in    std_logic;
   oe       : in    std_logic;
   address  : in    std_logic_vector(3 downto 0);
   databus  : inout std_logic_vector(7 downto 0);
   switches : out   std_logic_vector(7 downto 0);
   temp_l   : out   std_logic_vector(6 downto 0);
   temp_h   : out   std_logic_vector(6 downto 0));   
END RAM;

ARCHITECTURE behavior OF RAM IS
  
  --SIGNAL contents_ram : array8_ram(255 downto 0);
  component ram_especifica is 
    PORT (
        Clk      : in    std_logic;
        Reset    : in    std_logic;
        write_en : in    std_logic;
        oe       : in    std_logic;
        address  : in    std_logic_vector(3 downto 0);
        databus  : inout std_logic_vector(7 downto 0);
        switches : out   std_logic_vector(7 downto 0);
        temp_l   : out   std_logic_vector(6 downto 0);
        temp_h   : out   std_logic_vector(6 downto 0));
  end component;
  
  component ram_general is
    PORT (
        Clk      : in    std_logic;
        write_en : in    std_logic;
        oe       : in    std_logic;
        address  : in    std_logic_vector(7 downto 0);
        databus  : inout std_logic_vector(7 downto 0)); 
  end component;
  
BEGIN
   RAM_ESPECIFICA:ram_especifica
        port map(
            Clk => Clk,
            Reset => Reset,
            write_en => write_en,
            oe => oe, 
            address => ,
            
END behavior;

