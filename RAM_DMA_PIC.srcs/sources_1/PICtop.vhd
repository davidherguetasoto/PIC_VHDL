
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

USE work.PIC_pkg.all;

entity terna_top is
  port (
    Reset    : in  std_logic;                      -- Asynchronous, active low
    Clk      : in  std_logic;                      -- System clock, 20 MHz, rising_edge
    i_write_en    : in  std_logic;                            -- Signals needed to access directly to the RAM (read/write)
    i_oe          : in  std_logic;                            -- Signals needed to access directly to the RAM (read/write)
    i_address     : in std_logic_vector(7 downto 0);          -- Signals needed to access directly to the RAM (read/write)
    databus     : inout std_logic_vector(7 downto 0);     -- Signals needed to access directly to the RAM (read/write)
    i_send        : in  std_logic;                            -- Indicates the DMA to send the RAM positions 4 y 5 (CPU response)
    --i_req         : in std_logic; --DUDA 
     
    RS232_RX    : in  std_logic;           -- RS232 RX line
    RS232_TX    : out std_logic;           -- RS232 TX line
    switches    : out std_logic_vector(7 downto 0);   -- Switch status bargraph
    Temp_L      : out std_logic_vector(6 downto 0);   -- Display value for TL
    Temp_H      : out std_logic_vector(6 downto 0));  -- Display value for TH 
    end terna_top;

architecture behavior of terna_top is

---------------------------------------------------------------------
--CONSTANTES DEL PUERTO SERIE RS232
  constant baudrate: integer:=115200;              --Baudrate RS232 
  constant clk_freq_RS232: integer:=20000000;      --Frecuencia del reloj del puerto RS232
  constant data_width: integer:=8;                 --Ancho de palabra del dato enviado por el puerto RS232
  constant n_start_bit:std_logic:='0';             --Nº de bits de Start y Stop en el RS232. Si '1' dos bits, si '0' 1 bit.
----------------------------------------------------------------------
   
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
  
   ------------------------------------------------------------------------
  -- RAM
  ------------------------------------------------------------------------
  
   component RAM
    port (
      Clk      : in    std_logic;
      Reset    : in    std_logic;
      write_en : in    std_logic;
      oe       : in    std_logic;
      address  : in    std_logic_vector(7 downto 0);
      databus  : inout std_logic_vector(7 downto 0);
      Switches : out std_logic_vector(7 downto 0);
      Temp_L   : out std_logic_vector(6 downto 0);
      Temp_H   : out std_logic_vector(6 downto 0));
  end component;
  
  ------------------------------------------------------------------------
  --  DMA
  ------------------------------------------------------------------------
  
   component DMA
    port ( Reset 		: in STD_LOGIC;
           Clk 	 		: in STD_LOGIC;
           RCVD_Data 	: in STD_LOGIC_VECTOR (7 downto 0);
           RX_Full 		: in STD_LOGIC;
           RX_Empty     : in STD_LOGIC;
           Data_Read 	: out STD_LOGIC;
           ACK_out 		: in STD_LOGIC;
           TX_RDY 		: in STD_LOGIC;
           Valid_D 		: out STD_LOGIC;
           TX_Data 		: out STD_LOGIC_VECTOR (7 downto 0);
           Address 		: out STD_LOGIC_VECTOR (7 downto 0);
           Databus 		: inout STD_LOGIC_VECTOR (7 downto 0);
           Write_en 	: out STD_LOGIC;
           OE 			: out STD_LOGIC;
           DMA_RQ 		: out STD_LOGIC;
           DMA_ACK 		: in STD_LOGIC;
           Send_comm 	: in STD_LOGIC;
           READY 		: out STD_LOGIC	);
  end component;
  
  ------------------------------------------------------------------------
  -- Internal Signals
  ------------------------------------------------------------------------

 signal TX_Data      : STD_LOGIC_VECTOR (7 downto 0);
 signal RCVD_Data    : STD_LOGIC_VECTOR (7 downto 0);
 signal address      : STD_LOGIC_VECTOR (7 downto 0);
 --signal databus      : STD_LOGIC_VECTOR (7 downto 0);
 signal Valid_D      : STD_LOGIC;
 signal Ack_out      : STD_LOGIC;
 signal TX_RDY       : STD_LOGIC;
 signal Data_Read    : STD_LOGIC;
 signal Full         : STD_LOGIC;
 signal Empty        : STD_LOGIC;
 signal Write_en     : STD_LOGIC;
 signal OE           : STD_LOGIC;
 signal DMA_RQ       : STD_LOGIC;
 signal DMA_ACK      : STD_LOGIC;
 signal Send_comm    : STD_LOGIC;
 signal READY        : STD_LOGIC;

 signal write_en_mem, oe_mem, i_address_req  : STD_LOGIC;
 signal address_mem  : STD_LOGIC_VECTOR(7 downto 0);
    
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
        Full      => Full,
        Empty     => Empty);

 RAM_PHY: RAM
    port map (
        Clk      => Clk,
        Reset    => Reset,
        write_en => write_en_mem,
        oe       => oe_mem,
        address  => address_mem,
        databus  => databus,
        Switches => switches,
        Temp_L   => Temp_L,
        Temp_H   => Temp_H );
        
 DMA_PHY: DMA
    port map (
        Clk       => Clk,
        Reset     => Reset,
        RCVD_Data => RCVD_Data,
        RX_Full   => Full,
        RX_Empty  => Empty,
        Data_Read => Data_Read,
        ACK_out   => ACK_out,
        TX_RDY    => TX_RDY,
        Valid_D   => Valid_D,
        TX_Data   => TX_Data,
        Address   => address,
        Databus   => databus,
        Write_en  => Write_en,
        OE        => OE,
        DMA_RQ    => DMA_RQ,
        DMA_ACK   => DMA_ACK,
        Send_comm => Send_comm,
        READY     => READY );


------ (1) SIGNALS USED TO GIVE CONTROL OF THE DATABUS TO THE DMA WHEN NEEDED 
    process(reset, clk)
    begin
      if reset='0' then
        DMA_ACK <= '0';
        Send_comm <= '0';
      elsif clk'event and clk='1' then
        DMA_ACK <= DMA_RQ;
        Send_comm <= i_send and (READY);
      end if;
    end process;  

------ (2) ADDITIONAL MULTIPLEXERS TO READ/WRITE DIRECTLY IN RAM
   i_address_req <= i_write_en or not(i_oe);
   address_mem <= i_address when (i_address_req = '1') else address;
   write_en_mem <= i_write_en when write_en = 'Z' else i_write_en or write_en;
   oe_mem <= write_en_mem when oe = 'Z' else ( (i_oe and oe) or (write_en_mem) );   -- oe is active low (expression has been simplified)
         --oe_mem <= not( (not(i_oe) or not(oe)) and not(write_en_mem) );
   --databus <= i_databus;     -- bidirectional access
   --i_databus <= databus;
    
end behavior;

