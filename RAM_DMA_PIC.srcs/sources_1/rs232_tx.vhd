----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.09.2022 13:07:00
-- Design Name: 
-- Module Name: RS232_TX - Behavioral
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

entity RS232_TX is
    generic ( baudrate: integer := 115200; 
              clk_freq: integer := 20000000; 
              data_width: integer := 8;
              double_Bit_SS: STD_LOGIC := '1');
    
    port ( reset : in STD_LOGIC;
           clk : in STD_LOGIC;
           start : in STD_LOGIC;
           data : in STD_LOGIC_VECTOR (data_width - 1 downto 0);
           eot : out STD_LOGIC;
           tx : out STD_LOGIC);
end RS232_TX;

architecture Behavioral of RS232_TX is
type state is (Idle, StartBit, SendData, StopBit); --tipo estados
    signal CurrentState, NextState: state; --estados  
    
    --contador de pulsos
    signal pulse_width : integer; --valor del contador de pulsos        
    signal start_PulseCounter : STD_LOGIC; --activación del contador de pulsos
    signal end_PulseCounter : STD_LOGIC; --fin del contador de pulsos
    signal end2_PulseCounter : STD_LOGIC; --fin del contador de pulsos (flanco anterior)
    constant PulseEndOfCount : positive := clk_freq / baudrate; --valor final del contador de pulsos         
    
    --contador de datos
    signal start_DataCounter : STD_LOGIC; --valor del contador de datos
    signal end_DataCounter : STD_LOGIC; --activación del contador de datos
    signal data_count : integer; --fin del contador de datos 
    constant DataEndOfCount : positive := data_width; --valor final del contador de datos
    
    --doble bit start/stop
    signal start_doubleBit : STD_LOGIC; --activación del contador doble bit
    constant double_Bit : STD_LOGIC := double_Bit_SS; --activación de doble bit (1 -> activado, 0 -> desactivado)
    signal end_2Bit : STD_LOGIC; --fin de 2 bits 
    signal end_1Bit : STD_LOGIC; --fin de 1 bit

begin
    FFs : process(clk, reset)
    begin 
        if reset = '0' then 
            CurrentState <= Idle; 
        elsif clk'event and clk = '1' then
            CurrentState <= NextState; 
        end if; 
    end process; 
    
    next_state : process(CurrentState, start, data_count, end_PulseCounter, end_DataCounter, data, end_2Bit)
    begin 
        case CurrentState is
            when Idle =>   
                tx <= '1'; --transmisión de 1 por defecto 
                eot <= '1'; --fin de transmisión
                start_PulseCounter <= '0'; --desactivación del contador de pulsos
                start_DataCounter <= '0';  
                start_DoubleBit <= '0';                                                 
                if start = '1' then
                    start_PulseCounter <= '1'; --activación del contador de pulsos           
                    NextState <= StartBit;     
                else                                       
                    NextState <= Idle;                                                        
                end if;
    
            when StartBit =>
                tx <= '0'; --transmisión del bit de comienzo
                eot <= '0';   
                start_PulseCounter <= '1'; --activación del contador de pulsos  
                start_DataCounter <= '0'; 
                start_DoubleBit <= '1'; --activación del contador doble bit                                       
                if end_PulseCounter = '1' then --fin del contador de pulsos y fin de bit
                    if double_Bit = '1' then                        
                        if end_2Bit = '1' then                   
                            NextState <= SendData;
                        else
                            NextState <= StartBit;
                        end if;
                    else
                        NextState <= SendData;
                     end if;
                else
                    NextState <= StartBit;                      
                end if;
    
            when SendData =>
                tx <= data(data_count); --transmisión de los bits del dato
                eot <= '0';  
                start_PulseCounter <= '1';              
                start_DataCounter <= '1'; --activación del contador de datos  
                start_DoubleBit <= '0'; --deactivación del contador doble bit        
                if end_DataCounter = '1' then --fin del contador de datos
                    NextState <= StopBit;    
                else                    
                    NextState <= SendData;
                end if;            
                
            when StopBit =>
                tx <= '1'; --transmisión del bit de fin 
                eot <= '0';
                start_PulseCounter <= '1';
                start_DataCounter <= '0'; --desactivación del contador de datos
                start_DoubleBit <= '1'; --activación del contador doble bit  
                if end_PulseCounter = '1' then --fin del contador de pulsos
                    if double_Bit = '1' then
                        if end_2Bit = '1' then
                            start_PulseCounter <= '0'; --desactivación del contador de pulsos
                            NextState <= Idle;
                        else
                            NextState <= StopBit;
                        end if;
                    else
                        start_PulseCounter <= '0'; --desactivación del contador de pulsos                    
                        NextState <= Idle;
                    end if;     
                else                                
                    NextState <= StopBit;                                   
                end if;               
        end case;
    end process;

    pulse_counter : process(clk, reset) 
    begin
        if reset = '0' then
            pulse_width <= 0;
            end_PulseCounter <= '0';
            end2_PulseCounter <= '0';
        elsif rising_edge(clk) then
            if start_PulseCounter = '1' then --activación del contador de pulsos
                if pulse_width < PulseEndOfCount - 1 then --valor del contador de pulsos menor del valor final
         	      pulse_width <= pulse_width + 1; --incremento del contador de pulsos
         	      end_PulseCounter <= '0';
         	    else    
         	      end_PulseCounter <= '1'; --fin del contador de pulsos      	      
         	      pulse_width <= 0; --reinicio del valor del contador de pulsos
         	    end if;
         	    if pulse_width = PulseEndOfCount - 2 then --valor del contador de pulsos a 1 pulso de reloj del valor final
         	      end2_PulseCounter <= '1'; --fin del contador de pulsos (flanco anterior)
         	    else
         	      end2_PulseCounter <= '0'; --reinicio del fin del contador de pulsos (flanco anterior)
         	    end if;
            else
                end_PulseCounter <= '0';    
            end if;
        end if;        
     end process;
     
     data_counter : process(clk, reset) 
      begin 
        if reset = '0' then
            data_count <= 0;
            end_DataCounter <= '0';       
        elsif rising_edge(clk) then
            if start_DataCounter = '1' then --activación del contador de datos
                if data_count < DataEndOfCount - 1 then --valor del contador de datos menor del valor final
                    if end_PulseCounter = '1' then
                        data_count <= data_count + 1; --incremento del contador de datos 
                        end_DataCounter <= '0';
                    end if;
                elsif end2_PulseCounter = '1' then --fin del contador de pulsos (flanco anterior)
                    end_DataCounter <= '1'; --fin del contador de datos                
                end if;
            end if;         
            if end_DataCounter = '1' then --fin del contador de datos
                data_count <= 0; --reinicio del valor del contador de datos 
                end_DataCounter <= '0'; --reinicio del fin del contador de datos
            end if;           
        end if;               
     end process;
     
     double_bit_start_stop : process(clk, reset)
     begin
        if reset = '0' then
            end_2Bit <= '0';
            end_1Bit <= '0';
        elsif rising_edge(clk) then  
            if double_Bit = '1' and start_DoubleBit = '1' then           
                if end_PulseCounter = '1' and end_1Bit = '0' then                   
                    end_1Bit <= '1';                   
                elsif end2_PulseCounter = '1' and end_1Bit = '1' then                    
                    end_2Bit <= '1';
                end if;
                if end_2Bit = '1' then
                    end_1Bit <= '0';
                    end_2Bit <= '0';
                end if;
            end if;                           
        end if;
     end process;

end Behavioral;