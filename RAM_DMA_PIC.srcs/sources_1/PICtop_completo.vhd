
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

USE work.PIC_pkg.all;

entity PICtop_completo is
 port (
    Reset    : in  std_logic;                         -- Asynchronous, active low
    Clk      : in  std_logic;                         -- System clock, 20 MHz, rising_edge    
    RS232_RX    : in  std_logic;                      -- RS232 RX line
    RS232_TX    : out std_logic;                      -- RS232 TX line
    switches    : out std_logic_vector(7 downto 0);   -- Switch status bargraph
    Temp_L      : out std_logic_vector(6 downto 0);   -- Display value for TL
    Temp_H      : out std_logic_vector(6 downto 0));  -- Display value for TH 
end PICtop_completo;

architecture behavior of PICtop_completo is

---------------------------------------------------------------------
--CONSTANTES DEL PUERTO SERIE RS232
  constant baudrate: integer:=115200;              --Baudrate RS232 
  constant clk_freq_RS232: integer:=20000000;      --Frecuencia del reloj del puerto RS232
  constant data_width: integer:=8;                 --Ancho de palabra del dato enviado por el puerto RS232
  constant n_start_bit:std_logic:='0';             --Nº de bits de Start y Stop en el RS232. Si '1' dos bits, si '0' 1 bit.
----------------------------------------------------------------------

-----------------------------------------------------------------------------
-- RS232
  component RS232top
    generic(baudrate: integer; clk_freq_RS232: integer; data_width: integer; n_start_bit:std_logic);
    port (
      Reset     : in  std_logic;
      Clk       : in  std_logic;
      Data_in   : in  std_logic_vector(7 downto 0);
      Valid_D   : in  std_logic;
      Ack_in    : out std_logic;
      TX_RDY    : out std_logic;
      TD        : out std_logic;
      RD        : in  std_logic;
      Data_out  : out std_logic_vector(7 downto 0);
      Data_read : in  std_logic;
      Full      : out std_logic;
      Empty     : out std_logic);
  end component;
  
-----------------------------------------------------------------------------

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
--  CPU
------------------------------------------------------------------------
 
 component CPU is
    port ( Reset : in  STD_LOGIC;
           Clk : in  STD_LOGIC;
           ROM_Data : in  STD_LOGIC_VECTOR (11 downto 0);
           ROM_Addr : out  STD_LOGIC_VECTOR (11 downto 0);
           RAM_Addr : out  STD_LOGIC_VECTOR (7 downto 0);
           RAM_Write : out  STD_LOGIC;
           RAM_OE : out  STD_LOGIC;
           Databus : inout  STD_LOGIC_VECTOR (7 downto 0);
           DMA_RQ : in  STD_LOGIC;
           DMA_ACK : out  STD_LOGIC;
           SEND_comm : out  STD_LOGIC;
           DMA_READY : in  STD_LOGIC;
           Alu_op : out  alu_op;
           Index_Reg : in  STD_LOGIC_VECTOR (7 downto 0);
           FlagZ : in  STD_LOGIC;
           FlagC : in  STD_LOGIC;
           FlagN : in  STD_LOGIC;
           FlagE : in  STD_LOGIC);
end component;

------------------------------------------------------------------------
-- ROM
------------------------------------------------------------------------

component ROM is
  port (
    Instruction     : out std_logic_vector(11 downto 0);  -- Instruction bus
    Program_counter : in  std_logic_vector(11 downto 0));
end component;

------------------------------------------------------------------------
-- ALU
------------------------------------------------------------------------

component ALU is
port (
    Reset : in std_logic; -- asynnchronous, active low
    Clk : in std_logic; -- Sys clock, 20MHz, rising_edge
    u_instruction : in alu_op; -- u-instructions from CPU
    FlagZ : out std_logic; -- Zero flag
    FlagC : out std_logic; -- Carry flag
    FlagN : out std_logic; -- Nibble carry bit
    FlagE : out std_logic; -- Error flag
    Index_Reg : out std_logic_vector(7 downto 0); -- Index register
    Databus : inout std_logic_vector(7 downto 0) -- System Data bus
);
end component;

------------------------------------------------------------------------
-- Internal Signals
------------------------------------------------------------------------

 signal TX_Data      : STD_LOGIC_VECTOR (7 downto 0);
 signal RCVD_Data    : STD_LOGIC_VECTOR (7 downto 0);
 signal address      : STD_LOGIC_VECTOR (7 downto 0);
 signal databus      : STD_LOGIC_VECTOR (7 downto 0);
 signal Valid_D      : STD_LOGIC;
 signal Ack_out      : STD_LOGIC;
 signal TX_RDY       : STD_LOGIC;
 signal Data_Read    : STD_LOGIC;
 signal Full         : STD_LOGIC;
 signal Empty        : STD_LOGIC;
 signal DMA_RQ       : STD_LOGIC;
 signal DMA_ACK      : STD_LOGIC;
 signal Send_comm    : STD_LOGIC;
 signal DMA_READY    : STD_LOGIC;
 signal ROM_Data     : STD_LOGIC_VECTOR (11 downto 0);
 signal ROM_Addr     : STD_LOGIC_VECTOR (11 downto 0);
 signal RAM_Addr     : STD_LOGIC_VECTOR (7 downto 0);
 signal RAM_Write    : STD_LOGIC;
 signal RAM_OE       : STD_LOGIC;
 signal ALU_op       : alu_op;
 signal Index_REG    : STD_LOGIC_VECTOR (7 downto 0);
 signal FlagZ        : STD_LOGIC;
 signal FlagC        : STD_LOGIC;
 signal FlagN        : STD_LOGIC;
 signal FlagE        : STD_LOGIC;
 


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
        write_en => RAM_Write,
        oe       => RAM_OE,
        address  => RAM_Addr,
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
        Write_en  => RAM_Write,
        OE        => RAM_OE,
        DMA_RQ    => DMA_RQ,
        DMA_ACK   => DMA_ACK,
        Send_comm => Send_comm,
        READY     => DMA_READY );
        
 CPU_PHY: CPU 
    port map(
        Clk => Clk,
        Reset => Reset,
        ROM_Data => ROM_Data,
        ROM_Addr => ROM_Addr,
        RAM_Addr => RAM_Addr,
        RAM_Write => RAM_Write,
        RAM_OE => RAM_OE,
        Databus => databus,
        DMA_RQ => DMA_RQ,
        DMA_ACK => DMA_ACK,
        Send_comm => Send_comm,
        DMA_READY => DMA_READY,
        ALU_op => ALU_op, 
        Index_REG => Index_REG,
        FlagZ => FlagZ,
        FlagC => FlagC,
        FlagE => FlagE,
        FlagN => FlagN);
        
 ROM_PHY: ROM 
    port map(
        Instruction => ROM_Data,
        Program_counter => ROM_Addr);
        
 ALU_PHY: ALU 
    port map(
        Reset => Reset,
        Clk => Clk,
        u_instruction => ALU_op,
        FlagZ => FlagZ,
        FlagC => FlagC,
        FlagN => FlagN,
        FlagE => FlagE,
        Index_REG => Index_REG,
        Databus => Databus);
       
        
end behavior;
