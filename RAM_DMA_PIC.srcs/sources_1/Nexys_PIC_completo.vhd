------------------------------------------------------
-- Autor: Juan Antonio López Martín
-- Departamento de Ingeniería Electrónica 
------------------------------------------------------ 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity nexys_PIC_completo is
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
end nexys_PIC_completo;

architecture behavior of nexys_PIC_completo is

-- declaración de componentes 
    component clk_wiz_0
        port (          
          clk_in1   : in  std_logic;
          clk_out1  : out  std_logic;
          locked    : out std_logic);
    end component;

component PICtop_completo is
 port (
    Reset    : in  std_logic;                         -- Asynchronous, active low
    Clk      : in  std_logic;                         -- System clock, 20 MHz, rising_edge    
    RS232_RX    : in  std_logic;                      -- RS232 RX line
    RS232_TX    : out std_logic;                      -- RS232 TX line
    switches    : out std_logic_vector(7 downto 0);   -- Switch status bargraph
    Temp_L      : out std_logic_vector(6 downto 0);   -- Display value for TL
    Temp_H      : out std_logic_vector(6 downto 0));  -- Display value for TH 
end component;

-- declaración de señales 
    --signal reset, reset_p : std_logic;
    signal reset : std_logic;
    signal clk : std_logic;
    signal contador : UNSIGNED(31 downto 0); 
    --signal flag : std_logic;

-- signals for UUT (PICtop) 
    signal switches  : std_logic_vector(7 downto 0); 
    signal RD, TD  : std_logic;  
    signal Temp_H, Temp_L     : std_logic_vector(6 downto 0);
    

begin

-- 1.Botones
     reset <= not(BTNU);      -- Button UP     => Reset (active low)

-- 2.Datos de entrada y salida

     

-- 3a.Realimentación lineas TD => RD  (necesita un cable entre los pines 1 y 2 del pmodJA)
     JA(1) <= TD;   -- OUTPUT PORT     
     JA(2) <= 'Z';   -- OUTPUT PORT
     RD <= JA(2);   -- INPUT PORT

-- 3b.conexión de las lineas TD y RD PC mediante el puerto microUSB (puerto serie RS232)
--    UART_RXD_OUT <= TD;
--    RD <= UART_TXD_IN;

-- 4.Displays: Muestra el valor de la temperatura en los dos displays inferiores, y anula los otros 6. 
    CA <= not(temp_H(0)) when contador(16)='1' else not(temp_L(0));
    CB <= not(temp_H(1)) when contador(16)='1' else not(temp_L(1));
    CC <= not(temp_H(2)) when contador(16)='1' else not(temp_L(2));
    CD <= not(temp_H(3)) when contador(16)='1' else not(temp_L(3));
    CE <= not(temp_H(4)) when contador(16)='1' else not(temp_L(4));
    CF <= not(temp_H(5)) when contador(16)='1' else not(temp_L(5));
    CG <= not(temp_H(6)) when contador(16)='1' else not(temp_L(6));
    DP <= '1' when contador(16)='1' else '0';
    AN <= "111111" & not(contador(16)) & (contador(16));


-- 5.Instanciación de los componentes 
  --reset_p <= not reset;
    clk_20MHz : clk_wiz_0 PORT MAP(
        clk_in1 => CLK100MHz,
        clk_out1 => clk,
        locked => open);

    UUT : PICtop_completo PORT MAP(
        Reset      => reset, 
        Clk        => clk,
        RS232_RX   => RD,
        RS232_TX   => TD,
        switches   => switches,
        Temp_L     => Temp_L,
        Temp_H     => Temp_H );

     LED(7 downto 0) <= switches;
     LED(15 downto 8)<=(others => '0');
-- 6.Procesos adicionales 
    -- Contador para hacer el barrido de los datos en los displays
    process(reset, clk)
    begin
      if reset='0' then
        contador <= (others => '0');
        --flag <= '0';
      elsif clk'event and clk='1' then
          contador <= contador + 1;
          if contador >= 100000000 then
            contador <= (others => '0');
            --flag <= not flag;
          end if; 
      end if;
    end process;      
             
			  
--7.Otros procesos
end behavior;
