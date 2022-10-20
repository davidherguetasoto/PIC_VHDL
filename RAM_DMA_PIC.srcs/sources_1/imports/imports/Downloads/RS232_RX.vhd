library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity RS232_RX is

generic(baudrate: integer:=115200; clk_freq: integer:=20000000; data_width: integer:=8; n_start_bit:std_logic:='1'); 

    Port ( Clk : in STD_LOGIC;
           Reset : in STD_LOGIC;
           LineRD_in : in STD_LOGIC;
           Valid_out : out STD_LOGIC;
           Code_out : out STD_LOGIC;
           Store_out : out STD_LOGIC);
end RS232_RX;

architecture Behavioral of RS232_RX is

--CONSTANTES
constant time_bit:integer:= (clk_freq / baudrate)-2;    -- ciclos por bit (tiempo de bit para la transmision)
constant halfbit:integer:=(time_bit/2)+2; --medio tiempo de bit en ciclos de reloj


type STATE is (Idle, StartBit,RcvData,StopBit); 
signal next_state : STATE;         -- Estado siguiente
signal present_state : STATE;  -- Estado actual

--CONTADORES
signal DataCount : integer;         --Contador de numero de bits recibidos 
signal HalfBitCounter : integer;    --Temporizador de medio bit 
signal BitCounter : integer;        --Temporizador de bit

--SEÑALES PARA INICIAR LA CUENTA DE LOS CONTADORES
signal start_BitCounter : std_logic;        --Lanzar temporizador de bit 
signal start_HalfBitCounter : std_logic;    --Lanzar temporizador de medio bit 
signal start_DataCount : std_logic;         --Sumar 1 bit recibido

--SEÑALES DE FIN DE CUENTA DE LOS CONTADORES
signal end_BitCounter : std_logic;          --Fin de temporizador de bit
signal end_HalfBitCounter : std_logic;      --Fin de temporizador de medio bit
signal end_DataCount : std_logic;           --Numero maximo de bits recibidos

--RESETEO DE LA CUENTA DEL NUMERO DE DATOS LEIDOS
signal reset_DataCount: std_logic;          --Resetear contador de bits recibidos

--FLAG CUENTA DE BIT
signal end_1bit: std_logic; -- flag para detectar cuando ha terminado un tiempo de bit. Se emplea para detectar dos bit de stop y dos bit de start.
begin

ACTUALIZACION_DE_ESTADO: process(Clk,Reset)
begin
    --Cuando se activa la señal de reset, se pasará al estado de reposo de forma asíncrona
    if Reset='0' then
        present_state<=Idle;
    elsif rising_edge(Clk) then
    --Con cada flanco de reloj se pasará del estado actual al estado que se haya cargado en el estado próximo            
        present_state<=next_state;          
    end if;
 end process;
 
ACTUALIZACION_CONTADOR_BIT: process(Clk,Reset)
begin
    if Reset='0' then
        BitCounter<=0;
        end_BitCounter<='0';
    elsif rising_edge(CLK) then
        if start_BitCounter='1' then
            if BitCounter<time_bit-1 then 
                BitCounter<=BitCounter+1;
                end_BitCounter<='0';
            else
                end_BitCounter<='1';
                BitCounter<=0;
            end if;
        else
            end_BitCounter<='0';
            BitCounter<=0;
    end if; 
    end if;  
end process;

ACTUALIZACION_CONTADOR_HALFBIT: process(clk,Reset)
begin
    if Reset='0' then
        HalfBitCounter<=0;
        end_HalfBitCounter<='0';
    elsif rising_edge(clk) then
    if end_BitCounter='1' then
        HalfBitCounter<=0;
        end_HalfBitCounter<='0';
    else
        if start_HalfBitCounter='1' then
            if HalfBitCounter < halfbit-1 then
                HalfBitCounter<=HalfBitCounter+1;
                end_HalfBitCounter<='0';
            else
                end_HalfBitCounter<='1';
                HalfBitCounter<=0;
            end if;
        else 
            end_HalfBitCounter<='0';
            HalfBitCounter<=0;
        end if;
    end if;
    end if;
end process;

ACTUALIZACION_CUENTA_DATOS_RCV: process(clk,reset)
begin
    if Reset='0' then
        DataCount<=0;
        end_DataCount<='0';
    elsif rising_edge(clk) then
        if reset_DataCount='1' then 
            DataCount<=0;
            end_DataCount<='0';
        else   
            if start_DataCount='1' then             
                if DataCount < data_width then    
                    DataCount<=DataCount+1;
                    end_DataCount<='0';
                else
                    end_DataCount<='1';
                end if;
            else
            if DataCount < data_width then
                end_DataCount<='0';
            else 
                end_DataCount<='1';
            end if;
            end if;
        end if;
    end if;
end process;

ACTUALIZACION_END1BIT:process(clk,reset)
begin
    if Reset='0' then
        end_1bit<='0';
    elsif rising_edge(clk) then
        if present_state=Idle or present_state=RcvData then
            end_1bit<='0'; 
        else
            if end_BitCounter='1' and end_1bit<='0' then
                end_1bit<='1';
            elsif end_1bit<='1' and end_BitCounter='1' then
                end_1bit<='0';
            else
                end_1bit<=end_1bit;
            end if;
        end if;
    end if;          
end process;

CAMBIO_DE_ESTADO: process(LineRD_in,present_state, end_BitCounter, end_DataCount, end_HalfBitCounter, end_1bit)
begin
    case present_state is
        when Idle=>
            if LineRD_in='0' then
                next_state<=StartBit;
            else
                next_state<=Idle;
            end if; 
                  
        when StartBit=>
            if end_HalfBitCounter='1' and LineRD_in='1' then
                    next_state<=Idle;
            else
                if n_start_bit='1' then --2 StartBits 
                    if end_BitCounter='1' and LineRD_in='0' and end_1bit='1' then
                        next_state<=RcvData;
                    else
                        next_state<=StartBit;
                    end if;
                else --1 StartBit
                    if end_BitCounter='1' and LineRD_in='0' then
                        next_state<=RcvData;
                    else
                        next_state<=StartBit;
                    end if;
               end if;
           end if;      
                       
        when RcvData=> 
            if end_DataCount='1' then 
                next_state<=StopBit;
            else
                next_state<=RcvData;
            end if;
      
        when StopBit=> 
            if n_start_bit='1' then --2 StopBits
                if end_BitCounter='1' and end_1bit='1' then 
                    next_state<=Idle;
                else
                    next_state<=StopBit;
                end if;
            else --1 StopBit   
                if end_BitCounter='1' then 
                    next_state<=Idle;
                else
                    next_state<=StopBit;
                end if; 
            end if;  
    end case;                                    
end process;

GESTION_SALIDAS: process(present_state, LineRD_in, end_BitCounter, end_DataCount, end_HalfBitCounter, end_1bit)
begin 
    Code_out<=LineRD_in;
    
    case present_state is 
   
    when RcvData=> 
        start_BitCounter<='1';
        start_HalfBitCounter<='1';
        if end_BitCounter='1' then
            start_DataCount<='1';
        else
            start_DataCount<='0';
        end if;
        reset_DataCount<='0';
        Store_out<='0';
        if end_HalfBitCounter='1' and end_BitCounter='0' then 
            Valid_out<='1';
        else
            Valid_out<='0';
        end if; 
              
    when StopBit=>
       start_BitCounter<='1';
       start_HalfBitCounter<='1';
       start_DataCount<='0';
        reset_DataCount<='0';    
        Valid_out<='0';
        if n_start_bit='1' then --2 BitsStop 
            if end_HalfBitCounter='1' and LineRD_in='1' and end_1bit='1' then
                Store_out<='1';
            else
            Store_out<='0';
            end if;
        else --1 BitStop
            if end_HalfBitCounter='1' and LineRD_in='1' then
                Store_out<='1';
            else
                Store_out<='0';
            end if;
        end if;
        
    when StartBit=>
        start_BitCounter<='1';
        start_HalfBitCounter<='1';
        start_DataCount<='0';
        reset_DataCount<='0';     
        Valid_out<='0';     
        Store_out<='0';
    
    when Idle=> 
        start_BitCounter<='0';
        start_HalfBitCounter<='0';
        start_DataCount<='0';
        reset_DataCount<='1';
            
        Valid_out<='0';     
        Store_out<='0';
        
    when others=> 
        start_BitCounter<='0';
        start_DataCount<='0';
        start_HalfBitCounter<='0';
        reset_DataCount<='0';
        Valid_out<='0';     
        Store_out<='0';
    end case;                  
end process;
end Behavioral;
