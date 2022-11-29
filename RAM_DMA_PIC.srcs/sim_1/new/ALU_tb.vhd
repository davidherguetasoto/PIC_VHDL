library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.PIC_pkg.all;

entity ALU_tb is
end ALU_tb;

architecture testbench of ALU_tb is

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

----------------------------------------------------
--SEÑALES DE RELOJ Y RESET
constant clk_freq: integer := 20000000;

signal reset : STD_LOGIC;
signal clk   : STD_LOGIC;
constant clk_period: time := 1 sec / clk_freq; 
----------------------------------------------------

----------------------------------------------------  
--SEÑALES DE LA ALU 
signal u_instruction : alu_op;
signal Databus : std_logic_vector(7 downto 0);
signal FlagZ : std_logic;
signal FlagN : std_logic;
signal FlagC : std_logic;
signal FlagE : std_logic;
signal Index_Reg : std_logic_vector(7 downto 0);
----------------------------------------------------
   
begin
    -- Generation of the reset
    reset <= '1','0' after 200 ns, '1' after 350 ns; 

    -- Generation of the clock
    process
    begin
        clk <= '1';
        wait for clk_period/2;
        clk <= '0';
        wait for clk_period/2;
    end process;  

    -- Unit Under Test (UUT)
    UUT: ALU port map(
        reset => reset,
        clk => clk, 
        u_instruction => u_instruction,
        FlagZ => FlagZ,
        FlagN => FlagN,
        FlagE => FlagE,
        FlagC => FlagC,
        Index_Reg => Index_Reg,
        Databus => Databus);
    
    -- Generation of the inpust 
    process
    begin
        wait until reset = '1';
        wait until reset = '0';        
        wait for 4*clk_period;
        
        Databus <= (others => 'Z');
        
        wait for 4*clk_period;
        -- Cargar datos en A 
        Databus <= "01101110";
        u_instruction <= op_lda;
        wait for clk_period;
        
        -- Cargar datos en B 
        Databus <= "10011011";
        u_instruction <= op_ldb; 
        wait for clk_period; 
        
        -- Cargar datos en el registro acumulador 
        Databus <= "10000000";
        u_instruction <= op_ldacc;
        wait for clk_period;
        
        -- Cargar datos en el registro indexado 
        Databus <= "00000001";
        u_instruction <= op_ldid;
        wait for clk_period;
        
        -- Mover datos del acumulador al registro indexado 
        Databus <= (others => 'Z');
        u_instruction <= op_mvacc2id;
        wait for clk_period;
        
        -- Suma con desbordamiento 
        u_instruction <= op_add;
        wait for clk_period;
        
        -- Carga en B del registro acumulador 
        u_instruction <= op_mvacc2b;
        wait for 2*clk_period;
        
        -- Suma sin desbordamiento 
        u_instruction <= op_add;
        wait for clk_period;
        
        -- Mover del registro acumulador a A 
        u_instruction <= op_mvacc2a;
        wait for clk_period;
        
        -- Resta sin desbordamiento
        u_instruction <= op_sub;
        wait for clk_period;
        
        -- Carga en el acumulador B 
        Databus <= "11111111";
        u_instruction <= op_ldb;
        wait for clk_period;
        
        -- Resta con desbordamiento 
        Databus <= (others => 'Z');
        u_instruction <= op_sub;
        wait for clk_period;
        
        -- Desplazamiento hacia la derecha (2 ciclos)
        u_instruction <= op_shiftr;
        wait for 2*clk_period;
        
        -- Desplazamiento hacia la izquierda (2 ciclos)
        u_instruction <= op_shiftl;
        wait for 2*clk_period;
        
        -- Carga en A
        Databus <= "01011010";
        u_instruction <= op_lda;
        wait for clk_period;
        
        -- Carga en B 
        Databus <= "11011011";
        u_instruction <= op_ldb;
        wait for clk_period;
        
        -- AND
        Databus <= (others => 'Z');
        u_instruction <= op_and;
        wait for clk_period;
        
        -- OR 
        u_instruction <= op_or;
        wait for clk_period;
        
        -- XOR 
        u_instruction <= op_xor;
        wait for clk_period;
        
        -- Cargar al databus 
        u_instruction <= op_oeacc;
        wait for clk_period;
        
        -- A < B
        u_instruction <= op_cmpl;
        wait for clk_period; 
        
        -- A = B 
        u_instruction <= op_cmpe;
        wait for clk_period;
        
        Databus <= "11111111";
        u_instruction <= op_lda;
        wait for clk_period;       
        u_instruction <= op_ldb;
        wait for clk_period;
        Databus <= (others => 'Z');
        u_instruction <= op_cmpe;
        wait for clk_period;
        
        -- Resta que resulta 0 
        u_instruction <= op_sub;
        wait for clk_period;
        
        
        -- A > B 
        u_instruction <= op_cmpg;
        wait for clk_period;
        Databus <= "11001100";
        u_instruction <= op_lda;
        wait for clk_period;
        Databus <= "00110011";
        u_instruction <= op_ldb;
        wait for clk_period;
        Databus <= (others => 'Z');
        u_instruction <= op_cmpg;
        wait for clk_period;
        
        -- Suma que da 0 
        Databus <= "00000000";
        u_instruction <= op_lda;
        wait for clk_period;
        Databus <= "00000000";
        u_instruction <= op_ldb;
        wait for clk_period;
        Databus <= (others => 'Z');
        u_instruction <= op_add;
        wait for clk_period;
        
        -- OR, AND y XOR de cero
        u_instruction <= op_and;
        wait for clk_period;
         
        u_instruction <= op_or;
        wait for clk_period;
        
        u_instruction <= op_xor;
        wait for clk_period;
        
        -- Cargar en el databus
        u_instruction <= op_oeacc;
        wait for clk_period;
        u_instruction <= nop;
        wait for clk_period;
        
        -- Bin2Ascii
        Databus <= X"04";
        u_instruction <= op_lda;
        wait for clk_period;
        Databus <= (others => 'Z');
        u_instruction <= op_bin2ascii;
        wait for clk_period;
        
        -- Ascii2bin
        u_instruction <= op_ascii2bin;
        wait for clk_period;
        
        -- Bin2Ascii
        Databus <= X"10";
        u_instruction <= op_lda;
        wait for clk_period;
        Databus <= (others => 'Z');
        u_instruction <= op_bin2ascii;
        wait for clk_period;
        
        -- Ascii2bin
        u_instruction <= op_ascii2bin;
        wait for clk_period;
        
        -- Carga en B dos valores seguidos
        Databus <= "11011011";
        u_instruction <= op_ldb;
        wait for clk_period;
        Databus <= "00110110";
        u_instruction <= op_ldb;
        wait for clk_period;
        
        -- Carga en A dos valores seguidos
        Databus <= "11011011";
        u_instruction <= op_lda;
        wait for clk_period;
        Databus <= "00110110";
        u_instruction <= op_lda;
        wait for clk_period;
        
        u_instruction <= nop;        
        wait;
    end process;       
end testbench;