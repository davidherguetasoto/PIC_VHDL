LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

USE work.RS232_test.all;
USE work.PIC_pkg.all;

entity tb_Nexys_completo is
end tb_Nexys_completo;

architecture TestBench of tb_Nexys_completo is

  component nexys_PIC_completo is
  port (
    
	-- Puertos PMOD de usuario (x4)
	JA 				: inout STD_LOGIC_VECTOR(2 downto 1);    
	
    --Interfaz USB-RS232
--    UART_TXD_IN     : in  STD_LOGIC;
--    UART_RXD_OUT    : out  STD_LOGIC;
--    UART_CTS        : in  STD_LOGIC;
--    UART_RTS        : in  STD_LOGIC;

---------------------------------------------------------------------------------------
	-- Displays 7 segmentos (x8)
    CA                 : out  STD_LOGIC;    
    CB                 : out  STD_LOGIC;    
    CC                 : out  STD_LOGIC;    
    CD                 : out  STD_LOGIC;    
    CE                 : out  STD_LOGIC;    
    CF                 : out  STD_LOGIC;    
    CG                 : out  STD_LOGIC;    
    DP                 : out  STD_LOGIC;    
    AN                 : out  STD_LOGIC_VECTOR(7 downto 0);    

-- Botones de usuario (x5)
  --  BTNC             : in  STD_LOGIC;    
    BTNU             : in  STD_LOGIC;    
  --  BTNL             : in  STD_LOGIC;    
  --  BTNR             : in  STD_LOGIC;    
--    BTND             : in  STD_LOGIC;    

-- Interruptores (x16) y LEDs
 --   SW                 : in   STD_LOGIC_VECTOR(15 downto 0);    
    LED                : out  STD_LOGIC_VECTOR(15 downto 0);   

-- Reloj de la FPGA
    CLK100MHZ        : in   STD_LOGIC

	 );  
end component;

-----------------------------------------------------------------------------
-- Internal signals
-----------------------------------------------------------------------------

  
-- Board signals used in the design 
    signal Clk100MHz : std_logic;
    signal Clk, reset : std_logic;
    signal SW, LED : std_logic_vector(15 downto 0);
    signal CA, CB, CC, CD, CE, CF, CG, DP : std_logic;
    signal AN : std_logic_vector(7 downto 0);
    signal BTNC, BTNU, BTNL, BTNR : std_logic;
    signal JA : std_logic_vector(2 downto 1);

-- Serial signals
--    signal TD        : std_logic;   -- RS232 Transmission line
--    signal RD        : std_logic;   -- RS232 Reception line
    

-- Time constants
  constant Tclk: time := 10 ns;   -- Clock Period (100 MHz)  
  constant Tclk2: time := 50 ns;  -- Clock Period (20 MHz)
  
begin  -- TestBench

  -- Instantiation of "Unit Under Test" 
  Unit_nexys_PIC :  nexys_PIC_completo
    port map (
	JA => JA,

    CA => CA,
    CB => CB,
    CC => CC,
    CD => CD,
    CE => CE,
    CF => CF,
    CG => CG,
    DP => DP,
    AN => AN,
   
    BTNU => BTNU,  

    LED => LED,
    CLK100MHZ => CLK100MHZ );
-----------------------------------------------------------------------------
-- Reset & clock generator
-----------------------------------------------------------------------------

 -- Reset <= '0', '1' after 75 ns;

-- Clock generation (100 MHz)
  CLK100MHz <= Clk;

  p_clk : PROCESS
  BEGIN
     Clk <= '1';
     wait for Tclk/2;
     Clk <= '0';
     wait for Tclk/2;
  END PROCESS;

-------------------------------------------------------------------------------
-- Sending some stuff through RS232 port
-------------------------------------------------------------------------------

  SEND_STUFF : process
  variable data:std_logic_vector(9 downto 0);
  begin

    BTNU <= '1';
    JA(2)<='1';
    wait for 40 us;
    BTNU <= '0';
    wait for 40 us;
  
  -- I41 (HAY QUE AÑADIR 1 AL FINAL (BIT DE FIN) Y 0 AL PRINCIPIO (BIT START))  
    data := "1010010010";
    for i in 0 to 9 loop 
        JA(2)<=data(i);
        wait for 8680 ns;
    end loop;
    wait for 40 us;
    
    data := "1001101000";
    for i in 0 to 9 loop 
        JA(2)<=data(i);
        wait for 8680 ns;
    end loop;
    wait for 40 us;
    
    data := "1001100010";
    for i in 0 to 9 loop 
        JA(2)<=data(i);
        wait for 8680 ns;
    end loop;
    wait for 40 us;
    
    -- T15
        data := "1010101000";
    for i in 0 to 9 loop 
        JA(2)<=data(i);
        wait for 8680 ns;
    end loop;
    wait for 40 us;
    
    data := "1001100010";
    for i in 0 to 9 loop 
        JA(2)<=data(i);
        wait for 8680 ns;
    end loop;
    wait for 40 us;
    
    data := "1001101010";
    for i in 0 to 9 loop 
        JA(2)<=data(i);
        wait for 8680 ns;
    end loop;
    wait for 40 us;
    
    -- T 2 2 
         data := "1010101000";
    for i in 0 to 9 loop 
        JA(2)<=data(i);
        wait for 8680 ns;
    end loop;
    wait for 40 us;
    
    data := "1001100100";
    for i in 0 to 9 loop 
        JA(2)<=data(i);
        wait for 8680 ns;
    end loop;
    wait for 40 us;
    
    data := "1001100100";
    for i in 0 to 9 loop 
        JA(2)<=data(i);
        wait for 8680 ns;
    end loop;
        wait for 40 us;
 -- A 5 7   
    data := "1010000010";
    for i in 0 to 9 loop 
        JA(2)<=data(i);
        wait for 8680 ns;
    end loop;    wait for 40 us;
    
    data := "1001101010";
    for i in 0 to 9 loop 
        JA(2)<=data(i);
        wait for 8680 ns;
    end loop;    wait for 40 us;
    
    data := "1001101110";
    for i in 0 to 9 loop 
        JA(2)<=data(i);
        wait for 8680 ns;
    end loop;
        wait for 40 us;
  -- S A 5  
    data := "1010100110";
    for i in 0 to 9 loop 
        JA(2)<=data(i);
        wait for 8680 ns;
    end loop;    wait for 40 us;
    
    data := "1010000010";
    for i in 0 to 9 loop 
        JA(2)<=data(i);
        wait for 8680 ns;
    end loop;    wait for 40 us;
    
    data := "1001101010";
    for i in 0 to 9 loop 
        JA(2)<=data(i);
        wait for 8680 ns;
    end loop;
    wait;
    
  
-- -- Encender interruptor 4 (I 4 1) 
--     Transmit(JA(2), X"49");
--     wait for 40 us;
--     Transmit(JA(2), X"34");
--     wait for 40 us;
--     Transmit(JA(2), X"31");
--     wait for 80 us;
---- Encender interruptor 2 (I 2 1)
--     Transmit(JA(2), X"49");
--     wait for 40 us;
--     Transmit(JA(2), X"32");
--     wait for 40 us;
--     Transmit(JA(2), X"31");
--     wait for 80 us;
---- Apagar interruptor 4 (I 4 0)
--     Transmit(JA(2), X"49");
--     wait for 40 us;
--     Transmit(JA(2), X"34");
--     wait for 40 us;
--     Transmit(JA(2), X"30");
--          wait for 80 us;
---- Poner temperatura (T 1 4)
--     Transmit(JA(2), X"54");
--     wait for 40 us;
--     Transmit(JA(2), X"31");
--     wait for 40 us;
--     Transmit(JA(2), X"34");
--          wait for 80 us;
---- Poner temperatura (T 2 1)
--     Transmit(JA(2), X"54");
--     wait for 40 us;
--     Transmit(JA(2), X"32");
--     wait for 40 us;
--     Transmit(JA(2), X"31");
--     wait;
  end process SEND_STUFF;
   
end TestBench;

