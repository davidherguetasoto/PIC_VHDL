----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.10.2022 15:28:59
-- Design Name: 
-- Module Name: ram_especifica_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ram_especifica_tb is
--  Port ( );
end ram_especifica_tb;

architecture Testbench of ram_especifica_tb is
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
    DUT: ram_especifica 
        port map(
            -- Inputs 
            reset => reset,
            clk   => clk,
            write_en => write_en,
            oe   => oe,
            address => address,
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
        
        --ESCRITURA DE TEMPERATURA EN EL DATABUS
        address <= X"31";
        databus <= "00010011";  
        wait for 2*clk_period;
        write_en <= '1';
        wait for 10*clk_period;
        oe <= '1'; 
        wait for 10*clk_period;
        write_en <= '0'; 
        wait for 10*clk_period;
        
        --ESCRITURA DE SWITCH 1 EN EL DATABUS   
        oe <= '1';
        address <= X"11";
        databus <= "00000000";
        wait for 10*clk_period;
        write_en <= '1';
        wait for 10*clk_period;
        oe <= '0'; 
        wait for 10*clk_period;
        write_en <= '0';
        wait for 10*clk_period;
        
        --LECTURA DE TEMPERATURA DESDE EL DATABUS
        address <= X"31";
        databus <= (others => 'Z');
        wait for 10*clk_period;
        oe <= '0';
        write_en <= '0';    
                    
        wait;    
    
    end process;
end Testbench;