
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
   address  : in    std_logic_vector(7 downto 0);
   databus  : inout std_logic_vector(7 downto 0);
   switches : out   std_logic_vector(7 downto 0);
   temp_l   : out   std_logic_vector(6 downto 0);
   temp_h   : out   std_logic_vector(6 downto 0));   
END RAM;

ARCHITECTURE behavior OF RAM IS
  
  --SIGNAL contents_ram : array8_ram(255 downto 0);
  signal CS_ram_general, CS_ram_especifica:std_logic;
  component ram_especifica is 
    PORT (
        Clk      : in    std_logic;
        Reset    : in    std_logic;
        write_en : in    std_logic;
        oe       : in    std_logic;
        address  : in    std_logic_vector(7 downto 0);
        CS       : in    std_logic;
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
        databus  : inout std_logic_vector(7 downto 0);
        CS       : in    std_logic); 
  end component;
  
BEGIN
   INST_RAM_ESPECIFICA:ram_especifica
        port map(
            Clk => Clk,
            Reset => Reset,
            write_en => write_en,
            oe => oe, 
            address => address,
            CS =>  CS_ram_especifica,
            databus => databus,
            switches => switches,
            temp_l => temp_l,
            temp_h => temp_h);
            
  INST_RAM_GENERAL:ram_general
        port map(
            Clk => Clk,
            write_en => write_en,
            oe => oe,
            address => address,
            CS => CS_ram_general,
            databus => databus);
            
  CS_ram_especifica<= '1' when (unsigned(address) < X"40") else '0';
  CS_ram_general<= '1' when (unsigned(address) >= X"40") else '0';
END behavior;

