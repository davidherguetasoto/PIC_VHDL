
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

USE work.PIC_pkg.all;

entity PICtop is
  port (
    Reset    : in  std_logic;           -- Asynchronous, active low
    Clk      : in  std_logic;           -- System clock, 20 MHz, rising_edge
    RS232_RX : in  std_logic;           -- RS232 RX line
    RS232_TX : out std_logic;           -- RS232 TX line
    switches : out std_logic_vector(7 downto 0);   -- Switch status bargraph
    Temp     : out std_logic_vector(7 downto 0);   -- Display value for T_STAT
    Disp     : out std_logic_vector(1 downto 0));  -- Display activation for T_STAT
end PICtop;

architecture behavior of PICtop is

  constant baudrate: integer:=115200;           --Baudrate RS232 
  constant clk_freq_RS232: integer:=20000000;   --Frecuencia del reloj del puerto RS232
  constant data_width: integer:=8;              --Ancho de palabra del dato enviado por el puerto RS232
  constant n_start_bit:std_logic:='0';          --Nº de bits de Start y Stop en el RS232. Si '1' dos bits, si '0' 1 bit.
  
  component RS232top
    generic(baudrate: integer; clk_freq_RS232: integer; data_width: integer; n_start_bit:std_logic);
    port (
      Reset     : in  std_logic;
      Clk       : in  std_logic;
      Data_in   : in  std_logic_vector(data_width-1 downto 0);
      Valid_D   : in  std_logic;
      Ack_in    : out std_logic;
      TX_RDY    : out std_logic;
      TD        : out std_logic;
      RD        : in  std_logic;
      Data_out  : out std_logic_vector(data_width-1 downto 0);
      Data_read : in  std_logic;
      Full      : out std_logic;
      Empty     : out std_logic);
  end component;

begin  -- behavior

  RS232_PHY: RS232top
    generic map(
        baudrate => baudrate,
        data_width => data_width,
        clk_freq_RS232 => clk_freq_RS232,
        n_start_bit => n_start_bit)
    port map (
        Reset     => Reset,
        Clk       => Clk,
        Data_in   => TX_Data,
        Valid_D   => Valid_D,
        Ack_in    => Ack_out,
        TX_RDY    => TX_RDY,
        TD        => RS232_TX,
        RD        => RS232_RX,
        Data_out  => RCVD_Data,
        Data_read => Data_read,
        Full      => RX_Full,
        Empty     => RX_Empty);

end behavior;

