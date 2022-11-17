----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.11.2022 16:06:25
-- Design Name: 
-- Module Name: dma_tb - Behavioral
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

entity dma_tb is
--  Port ( );
end dma_tb;

architecture Testbench of dma_tb is
    component dma is
        PORT (
            Reset : in STD_LOGIC;
            CLK : in STD_LOGIC;
            --RX
            RCVD_Data : in STD_LOGIC_VECTOR(7 downto 0);
            RX_Full : in STD_LOGIC;
            RX_Empty : in STD_LOGIC;
            Data_Read : out STD_LOGIC;
            ACK_out : in STD_LOGIC;
            --TX
            TX_RDY : in STD_LOGIC;
            Valid_D : out STD_LOGIC;
            TX_Data : out STD_LOGIC_VECTOR(7 downto 0);
            --RAM
            Address : out STD_LOGIC_VECTOR(7 downto 0);
            Databus : inout STD_LOGIC_VECTOR(7 downto 0);
            Write_en : out STD_LOGIC;
            OE : out STD_LOGIC;
            DMA_RQ : out STD_LOGIC;
            DMA_ACK : in STD_LOGIC;
            Send_comm : in STD_LOGIC;
            READY : out STD_LOGIC);
    end component;
    
    constant clk_freq: integer := 20000000;

    signal reset : STD_LOGIC;
    signal clk   : STD_LOGIC;
    constant clk_period: time := 1 sec / clk_freq; 
    
    --RX
    signal RCVD_Data : STD_LOGIC_VECTOR(7 downto 0);
    signal RX_Full :  STD_LOGIC;
    signal RX_Empty : STD_LOGIC;
    signal Data_Read : STD_LOGIC;
    signal ACK_out : STD_LOGIC;   
    
    --TX
    signal TX_RDY : STD_LOGIC;
    signal Valid_D : STD_LOGIC;
    signal TX_Data : STD_LOGIC_VECTOR(7 downto 0);
    
    --RAM
    signal Address : STD_LOGIC_VECTOR(7 downto 0);
    signal Databus : STD_LOGIC_VECTOR(7 downto 0);
    signal Write_en :STD_LOGIC;
    signal OE : STD_LOGIC;
    signal DMA_RQ : STD_LOGIC;
    signal DMA_ACK : STD_LOGIC;
    signal Send_comm : STD_LOGIC;
    signal READY : STD_LOGIC;

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
    DUT: dma 
        port map(
            Reset => Reset,
            CLK => CLK,
            --RX
            RCVD_Data => RCVD_Data,
            RX_Full  => RX_Full,
            RX_Empty => RX_Empty,
            Data_Read => Data_Read,
            ACK_out => ACK_out,
            --TX
            TX_RDY => TX_RDY,
            Valid_D => Valid_D,
            TX_Data => TX_Data,
            --RAM
            Address => Address,
            Databus => Databus,
            Write_en => Write_en,
            OE => OE,
            DMA_RQ => DMA_RQ,
            DMA_ACK => DMA_ACK,
            Send_comm => Send_comm,
            READY => READY);
            
    ---- Generation of the inputs 
    process
    begin
               
        wait until reset = '1';
        wait until reset = '0';        
        wait for 4*clk_period;   
        
        RX_Empty <= '1';    
        wait for 4*clk_period;
        RCVD_Data <= "10100101";
        RX_Empty <= '0';
        wait for 5*clk_period;
        DMA_ACK <= '1';
        wait for clk_period;
        RX_Empty <= '1';
               
        wait for 100*clk_period;
        
        RX_Empty <= '0';
        RCVD_Data <= "11101101";
        wait for clk_period;
        RX_Empty <= '1';
        
        wait for 100*clk_period;
        
        RX_Empty <= '0';
        RCVD_Data <= "00110100";
        wait for clk_period;
        RX_Empty <= '1';
        
        wait for 100*clk_period;
        
        RX_Empty <= '0';
        wait for clk_period;
        RX_Empty <= '1';
        
        wait for 100*clk_period;
        
        RX_Empty <= '0';
        wait for clk_period;
        RX_Empty <= '1';
              
        wait for 10*clk_period;        
        DMA_ACK <= '0';       
        wait;    
    
    end process;
    
end Testbench;
