
library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;
   
entity RS232top is
generic(baudrate: integer:=115200; clk_freq_RS232: integer:=20000000; data_width: integer:=8; n_start_bit:std_logic:='0');
  port (
    Reset     : in  std_logic;   -- Low-level asynchronous reset
    Clk       : in  std_logic;   -- System clock (20MHz), rising edge 
	
    Data_in   : in  std_logic_vector(data_width-1 downto 0);  -- Parallel TX byte 
    Valid_D   : in  std_logic;   -- Handshake signal from guest, active low 
    Ack_in    : out std_logic;   -- Data ack, low when it has been stored
    TX_RDY    : out std_logic;   -- System ready to transmit
    TD        : out std_logic;   -- RS232 Transmission line
	
    RD        : in  std_logic;   -- RS232 Reception line
    Data_out  : out std_logic_vector(data_width-1 downto 0);  -- Parallel RX byte
    Data_read : in  std_logic;   -- Send RX data to guest 
    Full      : out std_logic;   -- Internal RX memory full 
    Empty     : out std_logic);  -- Internal RX memory empty

end RS232top;

architecture RTL of RS232top is
 
  ------------------------------------------------------------------------
  -- Components for Transmitter Block
  ------------------------------------------------------------------------

  component RS232_TX
    generic (
        baudrate: integer;
        clk_freq: integer; 
        data_width: integer;
        double_Bit_SS: STD_LOGIC);
    port (
      Clk   : in  std_logic;
      Reset : in  std_logic;
      Start : in  std_logic;
      Data  : in  std_logic_vector(data_width-1 downto 0);
      EOT   : out std_logic;
      TX    : out std_logic);
  end component;

  ------------------------------------------------------------------------
  -- Components for Receiver Block
  ------------------------------------------------------------------------

  component ShiftRegister
    generic(data_width: integer);
    port (
      Reset  : in  std_logic;
      Clk    : in  std_logic;
      Enable : in  std_logic;
      D      : in  std_logic;
      Q      : out std_logic_vector(data_width-1 downto 0));
  end component;

  component RS232_RX
  generic(baudrate: integer; clk_freq: integer; data_width: integer; n_start_bit:std_logic);
    port (
      Clk       : in  std_logic;
      Reset     : in  std_logic;
      LineRD_in : in  std_logic;
      Valid_out : out std_logic;
      Code_out  : out std_logic;
      Store_out : out std_logic);
  end component;

  component fifo
    port (
      clk   : IN  std_logic;
      srst  : IN  std_logic;
      din   : IN  std_logic_VECTOR(7 downto 0);
      wr_en : IN  std_logic;
      rd_en : IN  std_logic;
      dout  : OUT std_logic_VECTOR(7 downto 0);
      full  : OUT std_logic;
      empty : OUT std_logic);
  end component;

  ------------------------------------------------------------------------
  -- Internal Signals
  ------------------------------------------------------------------------

  signal Data_FF    : std_logic_vector(data_width-1 downto 0);
  signal StartTX    : std_logic;  -- start signal for transmitter
  signal LineRD_in  : std_logic;  -- internal RX line
  signal Valid_out  : std_logic;  -- valid bit at the receiver
  signal Code_out   : std_logic;  -- bit at the receiver output
  signal sinit      : std_logic;  -- fifo reset
  signal Fifo_in    : std_logic_vector(7 downto 0);
  signal Fifo_write : std_logic;
  signal TX_RDY_i   : std_logic;
  signal Q          : std_logic_vector(data_width-1 downto 0); -- Intermediate register. Out of shiftReg.
  signal data_out_fifo: std_logic_vector(7 downto 0);          -- Intermediate register. Out of FIFO
begin  -- RTL

  Transmitter: RS232_TX
    generic map(
      baudrate => baudrate,
      clk_freq => clk_freq_RS232, 
      data_width => data_width,
      double_Bit_SS => n_start_bit)
    port map (
      Clk   => Clk,
      Reset => Reset,
      Start => StartTX,
      Data  => Data_FF,
      EOT   => TX_RDY_i,
      TX    => TD);

  Receiver: RS232_RX
    generic map(
     baudrate => baudrate,
     clk_freq => clk_freq_RS232, 
     data_width => data_width,
     n_start_bit => n_start_bit)
     
    port map (
      Clk       => Clk,
      Reset     => Reset,
      LineRD_in => LineRD_in,
      Valid_out => Valid_out,
      Code_out  => Code_out,
      Store_out => Fifo_write);

  Shift: ShiftRegister
    generic map(data_width => data_width)
    port map (
      Reset  => Reset,
      Clk    => Clk,
      Enable => Valid_Out,
      D      => Code_Out,
      Q      => Q);

  sinit <= not reset;
  
  Internal_memory: fifo
    port map (
      clk   => clk,
      srst  => sinit,
      din   => Fifo_in,
      wr_en => Fifo_write,
      rd_en => Data_read,
      dout  => data_out_fifo,
      full  => Full,
      empty => Empty);

  -- purpose: Clocking process for input protocol
  Clocking : process (Clk, Reset)
  begin
    if Reset = '0' then  -- asynchronous reset (active low)
      Data_FF   <= (others => '0');
      LineRD_in <= '1';
      Ack_in    <= '1';
    elsif rising_edge(Clk) then  -- rising edge of the clock
      LineRD_in <= RD;
      if Valid_D = '0' and TX_RDY_i = '1' then
        Data_FF <= Data_in;
        Ack_in  <= '0';
        StartTX <= '1';
      else
        Ack_in  <= '1';
        StartTX <= '0';
      end if;
    end if;
  end process Clocking;

  TX_RDY <= TX_RDY_i;
  
  Data_out<=data_out_fifo(data_width-1 downto 0);  --Adapt FIFO output to system output
  
 -- Fifo_in<= std_logic_vector(to_unsigned(to_integer(unsigned(Q)),8)); -- Adapt ShiftReg output to FIFO input
    Fifo_in <= std_logic_vector(resize(unsigned(Q),8));
end RTL;

