LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

USE work.RS232_test.all;
USE work.PIC_pkg.all;

entity PICtopCompleta_tb is
end PICtopCompleta_tb;

architecture TestBench of PICtopCompleta_tb is

  component PICtop_completo
     port (
    Reset    : in  std_logic;                         -- Asynchronous, active low
    Clk      : in  std_logic;                         -- System clock, 20 MHz, rising_edge    
    RS232_RX    : in  std_logic;                      -- RS232 RX line
    RS232_TX    : out std_logic;                      -- RS232 TX line
    switches    : out std_logic_vector(7 downto 0);   -- Switch status bargraph
    Temp_L      : out std_logic_vector(6 downto 0);   -- Display value for TL
    Temp_H      : out std_logic_vector(6 downto 0));  -- Display value for TH 
  end component;

-----------------------------------------------------------------------------
-- Internal signals
-----------------------------------------------------------------------------

  signal Reset    : std_logic;
  signal Clk      : std_logic;
  signal RS232_RX : std_logic;
  signal RS232_TX : std_logic;
  signal switches : std_logic_vector(7 downto 0);
  signal Temp_L   : std_logic_vector(6 downto 0);   -- Display value for TL
  signal Temp_H   : std_logic_vector(6 downto 0);  -- Display value for TH 
  
begin  -- TestBench

  UUT: PICtop_completo
    port map (
        Reset    => Reset,
        Clk      => Clk,
        RS232_RX => RS232_RX,
        RS232_TX => RS232_TX,
        switches => switches,
        Temp_L     => Temp_L,
        Temp_H     => Temp_H);

-----------------------------------------------------------------------------
-- Reset & clock generator
-----------------------------------------------------------------------------

  Reset <= '0', '1' after 75 ns;

  p_clk : PROCESS
  BEGIN
     clk <= '1', '0' after 25 ns;
     wait for 50 ns;
  END PROCESS;

-------------------------------------------------------------------------------
-- Sending some stuff through RS232 port
-------------------------------------------------------------------------------

  SEND_STUFF : process
  begin
-- Encender interruptor 4 (I 4 1)
     RS232_RX <= '1';
     wait for 40 us;
     Transmit(RS232_RX, X"49");
     wait for 40 us;
     Transmit(RS232_RX, X"34");
     wait for 40 us;
     Transmit(RS232_RX, X"31");
     wait for 80 us;
-- Encender interruptor 2 (I 2 1)
     Transmit(RS232_RX, X"49");
     wait for 40 us;
     Transmit(RS232_RX, X"32");
     wait for 40 us;
     Transmit(RS232_RX, X"31");
     wait for 80 us;
-- Apagar interruptor 4 (I 4 0)
     Transmit(RS232_RX, X"49");
     wait for 40 us;
     Transmit(RS232_RX, X"34");
     wait for 40 us;
     Transmit(RS232_RX, X"30");
     wait;
  end process SEND_STUFF;
   
end TestBench;

