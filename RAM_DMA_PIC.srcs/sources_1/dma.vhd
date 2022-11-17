----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.10.2022 17:55:56
-- Design Name: 
-- Module Name: dma - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

USE work.PIC_pkg.all;

entity dma is
  Port (
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
end dma;

architecture Behavioral of dma is

    type state is (Idle, Carga_TX, Envio_TX, SolicitudCarga_RX, Carga_RX, FinCarga_RX, FinBus_RX); --tipo estados
    signal CurrentState, NextState: state; --estados  
    
    --Contador de bytes de RX
    signal byte_count_rx : integer;
    signal start_ByteCount_rx : STD_LOGIC;
    signal end_ByteCount_rx : STD_LOGIC;
    signal ByteEndOfCount_rx : integer := 3; 
    
    --Contador de bytes de TX
    signal byte_count_tx : integer;
    signal start_ByteCount_tx : STD_LOGIC;
    signal end_ByteCount_tx : STD_LOGIC;
    signal ByteEndOfCount_tx : integer;       

begin
    FFs : process(clk, reset)
    begin 
        if reset = '0' then 
            CurrentState <= Idle; 
        elsif clk'event and clk = '1' then
            CurrentState <= NextState; 
        end if; 
    end process; 
    
    next_state : process(CurrentState, Send_comm, RX_Empty, DMA_ACK, RX_Full, end_ByteCount_rx, TX_RDY, ACK_out)
    begin 
        case CurrentState is
            when Idle =>   
                if Send_comm = '1' then
                    NextState <= Carga_TX;
                elsif RX_Empty = '0' then
                    NextState <= SolicitudCarga_RX;
                else
                    NextState <= Idle;                
                end if;  
                  
            --Recepción
            when SolicitudCarga_RX =>
                if DMA_ACK = '1' then
                    NextState <= Carga_RX;
                else
                    NextState <= SolicitudCarga_RX;
                end if;
            
            when Carga_RX =>
                if end_ByteCount_rx = '1' then
                    NextState <= FinCarga_RX;
                else
                   NextState <= Carga_RX;  
                end if;  
                
            when FinCarga_RX =>
                if RX_Empty = '0' then
                    NextState <= FinBus_RX;
                else
                    NextState <= FinCarga_RX;
                end if;     
                
            when FinBus_RX =>
                if DMA_ACK = '0' then
                    NextState <= Idle;
                else
                    NextState <= FinBus_RX;
                end if;         
                            
            --Transmisión      
            when Carga_TX =>                
                if ACK_out = '1' and TX_RDY = '1' then
                    NextState <= Envio_TX;
                else
                    NextState <= Carga_TX;
                end if;
                
            when Envio_TX =>
                NextState <= Envio_TX; 
                                    
        end case;
    end process;
    
GESTION_SALIDAS: process(CurrentState, RCVD_Data, byte_count_rx)
begin    
    
    case CurrentState is    
        when Idle =>       
            databus <= (others => 'Z');
            address <= X"00";
            write_en <= '0';
            oe <= '0';
            Data_Read <= '0';
            DMA_RQ <= '0';
            
        when SolicitudCarga_RX =>
            databus <= (others => 'Z');
            address <= X"00";
            write_en <= '0';
            oe <= '0';
            Data_Read <= '0';  
            DMA_RQ <= '1';           
        
        when Carga_RX =>
            databus <= RCVD_Data;
            address <= std_logic_vector(to_unsigned(byte_count_rx, 8));
            start_ByteCount_rx <= '1';
            write_en <= '1';
            oe <= '1';  
            Data_Read <= '1'; 
            DMA_RQ <= '1';
       
       when FinCarga_RX =>
            databus <= X"FF";
            address <= NEW_INST;
            start_ByteCount_rx <= '0';
            write_en <= '1';
            oe <= '1';
            Data_Read <= '1'; 
            DMA_RQ <= '1';
        
        when FinBus_RX =>
            databus <= (others => 'Z');
            address <= X"00";
            write_en <= '0';
            oe <= '0';
            Data_Read <= '0';  
            DMA_RQ <= '0';   
              
        when Carga_TX =>
            databus <= (others => 'Z');
      
        when Envio_TX =>
            databus <= (others => 'Z');                                  
              
        when others => 
             databus <= (others => 'Z');
             address <= X"00";
             write_en <= '0';
             oe <= '0';
             Data_Read <= '0';    
             DMA_RQ <= '0';    
    end case;                  
end process;
    
word_counter_rx : process(clk, reset) 
  begin 
    if reset = '0' then
        byte_count_rx <= 0;
        end_ByteCount_rx <= '0';       
    elsif rising_edge(clk) then
        if start_ByteCount_rx = '1' then
            if RX_Empty = '0' then
                if byte_count_rx < ByteEndOfCount_rx - 1 then                     
                    byte_count_rx <= byte_count_rx + 1; 
                    end_ByteCount_rx <= '0'; 
                else
                    end_ByteCount_rx <= '1';                                          
                end if;           
            end if;
        end if;         
        if end_ByteCount_rx = '1' then 
            byte_count_rx <= 0; 
            end_ByteCount_rx <= '0'; 
        end if;           
    end if;               
 end process;
 
word_counter_tx : process(clk, reset) 
begin 
if reset = '0' then
    byte_count_tx <= 0;
    end_ByteCount_tx <= '0';       
elsif rising_edge(clk) then
    if start_ByteCount_tx = '1' then 
        if byte_count_tx < ByteEndOfCount_tx - 1 then
            if end_ByteCount_tx = '1' then
                byte_count_tx <= byte_count_tx + 1; 
                end_ByteCount_tx <= '0';
            end if;                 
        end if;
    end if;         
    if end_ByteCount_tx = '1' then 
        byte_count_tx <= 0; 
        end_ByteCount_tx <= '0';
    end if;           
end if;               
end process;

end Behavioral;
