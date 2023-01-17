
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RAM_tb is
end RAM_tb;

architecture Testbench of RAM_tb is
    COMPONENT RAM IS
    PORT (
      Clk       : in    std_logic;
      Reset     : in    std_logic;
      write_en  : in    std_logic;
      oe        : in    std_logic;
      address   : in    std_logic_vector(7 downto 0);
      databus   : inout std_logic_vector(7 downto 0);
      switches  : out   std_logic_vector(7 downto 0);
      temp_l    : out   std_logic_vector(6 downto 0);
      temp_h    : out   std_logic_vector(6 downto 0));   
    END COMPONENT;

    constant clk_freq: integer := 20000000;

    signal reset : STD_LOGIC;
    signal clk   : STD_LOGIC;
    constant clk_period: time := 1 sec / clk_freq;    
    
    signal write_en : STD_LOGIC;
    signal oe : STD_LOGIC;
    signal address : STD_LOGIC_VECTOR(7 downto 0);
    signal databus : STD_LOGIC_VECTOR(7 downto 0);    
    
    signal switches : STD_LOGIC_VECTOR(7 downto 0);
    signal temp_l : STD_LOGIC_VECTOR(6 downto 0);
    signal temp_h : STD_LOGIC_VECTOR(6 downto 0);

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

    -- Design under test (DUT)
    DUT: RAM 
        port map(
            -- Inputs 
            reset => reset,
            clk   => clk,
            write_en => write_en,
            oe   => oe,
            address => address,
            --Inout
            databus => databus,
            -- Outputs
            switches => switches,
            temp_l  => temp_l,
            temp_h => temp_h);
            
    ---- Generation of the inputs 
    process
    begin
               
        wait until reset = '1';
        wait until reset = '0';
        wait for 4*clk_period;    
        wait for 4*clk_period;
        
        --PREPARACIÓN PARA ESCRITURA           
        write_en <= '1';
        oe <= '1';
        wait for 4*clk_period;    
        
        --ESCRITURA DE DATOS EN RAM ESPECIFICA
        address <= X"04";
        databus <= "00010011"; --13º  
        wait for 20*clk_period;
        
        --ESCRITURA DE DATOS EN RAM GENERL           
        address <= X"50"; --SW4
        databus <= "01000001"; --VALOR ALTO
        wait for 20*clk_period;

        --PREPARACIÓN PARA LECTURA
        write_en <= '0';
        oe <= '0';
        databus <= (others => 'Z');
        wait for 4*clk_period;
        
        --LECTURA DE LOS DATOS ESCRITOS
        address <= X"04";  
        wait for 4*clk_period;
        address <= X"50";            
        wait;    
    
    end process;
end Testbench;
