
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
  signal address_RAM_ESPECIFICA:std_logic_vector(7 downto 0);
  signal address_RAM_GENERAL:std_logic_vector(7 downto 0);
  signal OE_RAM_GENERAL:std_logic;
  signal OE_RAM_ESPECIFICA:std_logic;
  signal WRITE_RAM_GENERAL:std_logic;
  signal WRITE_RAM_ESPECIFICA:std_logic;

  attribute keep:boolean;
  attribute keep of oe:signal is true;
  attribute keep of write_en:signal is true;
  attribute keep of address:signal is true;
  attribute keep of address_RAM_ESPECIFICA:signal is true;
  attribute keep of address_RAM_GENERAL:signal is true;
  attribute keep of OE_RAM_ESPECIFICA:signal is true;
  attribute keep of OE_RAM_GENERAL:signal is true;
  attribute keep of WRITE_RAM_ESPECIFICA:signal is true;
  attribute keep of WRITE_RAM_GENERAL:signal is true;
  
  component ram_especifica is 
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

selector_RAM:process(address,oe,write_en)
begin
    if unsigned(address) < to_unsigned(64,address'length) then
        address_RAM_ESPECIFICA<=address;
        OE_RAM_ESPECIFICA<=oe;
        WRITE_RAM_ESPECIFICA<=write_en;
        address_RAM_GENERAL<=(others=>'Z');
        OE_RAM_GENERAL<='1';
        WRITE_RAM_GENERAL<='0';
    elsif unsigned(address) >= to_unsigned(64,address'length) and unsigned(address) < to_unsigned(320,address'length) then 
        address_RAM_GENERAL<= std_logic_vector(unsigned(address)-to_unsigned(64,address'length)); --address-64
        OE_RAM_GENERAL<=oe;
        WRITE_RAM_GENERAL<=write_en;
        address_RAM_ESPECIFICA<=(others=>'Z');
        OE_RAM_ESPECIFICA<='1';
        WRITE_RAM_ESPECIFICA<='0';       
    else
        address_RAM_GENERAL<=(others=>'Z');
        OE_RAM_GENERAL<='1';
        WRITE_RAM_GENERAL<='0';
        address_RAM_ESPECIFICA<=(others=>'Z');
        OE_RAM_ESPECIFICA<='1';
        WRITE_RAM_ESPECIFICA<='0';  
    end if;       
end process;

   INST_RAM_ESPECIFICA:ram_especifica
        port map(
            Clk => Clk,
            Reset => Reset,
            write_en => WRITE_RAM_ESPECIFICA,
            oe => OE_RAM_ESPECIFICA, 
            address => address_RAM_ESPECIFICA,            
            databus => databus,
            switches => switches,
            temp_l => temp_l,
            temp_h => temp_h);
            
  INST_RAM_GENERAL:ram_general
        port map(
            Clk => Clk,
            write_en => WRITE_RAM_GENERAL,
            oe => OE_RAM_GENERAL,
            address => address_RAM_GENERAL,      
            databus => databus);       
  
END behavior;

