library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
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

    constant MAX_TX_DATA:integer:=2;    --N� de bytes a enviar desde RAM a RS232
    constant MAX_RX_DATA:integer:=3;    --N� de bytes a recibir desde RS232 a RAM
    
    type state is (Idle, Carga_TX, Envio_TX,DevolverDataBus_TX,EsperarCPU_TX, SolicitudCarga_RX, Carga_RX, FinCarga_RX, FinBus_RX); --tipo estados
    signal CurrentState, NextState: state; --estados  
    
    --Contador de bytes
    signal byte_count : integer;
    signal start_ByteCount : STD_LOGIC;
    signal end_ByteCount : STD_LOGIC;
    signal ByteEndOfCount : integer;    --Dependiendo del estado en el que se encuentre, la maquina le cargara un valor de fin u otro
    
    signal TX_RDY_aux : std_logic; -- Se�al auxiliar para detectar flancos de bajada de TX_RDY 
begin
    FFs : process(clk, reset)
    begin 
        if reset = '0' then 
            CurrentState <= Idle; 
        elsif clk'event and clk = '1' then
            CurrentState <= NextState; 
        end if; 
    end process; 
    
    next_state : process(CurrentState, Send_comm, RX_Empty, DMA_ACK, RX_Full, TX_RDY, end_ByteCount, RCVD_Data, byte_count, Databus)
    begin 
    
        --valores por defecto        
        READY <= '1';
        DMA_RQ <= '0';
        Data_Read <= '0';
        Valid_D <= '1';
        Write_en <= '0';
        OE <= '1';
        databus <= (others => 'Z');
        Address <= (others => 'Z');
        TX_Data <= (others => '0');
        ByteEndOfCount <= 0;
        start_ByteCount <='0';  
        
        case CurrentState is
            when Idle =>                   
                if Send_comm = '1' then
                    READY <= '0';
                    NextState <= Carga_TX;
                elsif RX_Empty = '0' then                    
                    NextState <= SolicitudCarga_RX;
                else                    
                    NextState <= Idle;                
                end if;  
                  
            --Recepci�n
            when SolicitudCarga_RX =>
                address <= X"00";
                write_en <= '0';
                DMA_RQ <= '1';
                ByteEndOfCount <= MAX_RX_DATA;
                if DMA_ACK = '1' then
                    NextState <= Carga_RX;
                else
                    NextState <= SolicitudCarga_RX;
                end if;
            
            when Carga_RX =>
                databus <= RCVD_Data;
                address <= std_logic_vector(to_unsigned(byte_count, 8));
                ByteEndOfCount <= MAX_RX_DATA;
                start_ByteCount <= '1';
                write_en <= '1';
                oe <= '1';  
                Data_Read <= '1'; 
                DMA_RQ <= '1';
                if end_ByteCount = '1' then
                    NextState <= FinCarga_RX;
                else
                   NextState <= Carga_RX;  
                end if;  
                
            when FinCarga_RX =>
                databus <= X"FF";
                address <= NEW_INST;
                ByteEndOfCount <= MAX_RX_DATA;
                write_en <= '1';
                oe <= '1';
                Data_Read <= '1'; 
                DMA_RQ <= '1';
                if RX_Empty = '1' then
                    NextState <= FinBus_RX;
                else
                    NextState <= FinCarga_RX;
                end if;     
                
            when FinBus_RX =>
                ByteEndOfCount <= MAX_RX_DATA;
                if DMA_ACK = '0' then
                    NextState <= Idle;
                else
                    NextState <= FinBus_RX;
                end if;         
                            
            --Transmisi�n      
            when Carga_TX =>                
                READY <= '0';
                DMA_RQ <= '1';
                ByteEndOfCount <= MAX_TX_DATA;
                --if DMA_ACK = '1' and TX_RDY = '1' then             
                if TX_RDY = '1' then
                    NextState <= Envio_TX;
                else
                    NextState <= Carga_TX;
                end if;
                
            when Envio_TX =>
                READY <= '0';
                DMA_RQ <= '1';
                TX_Data <= Databus;
                Write_en <= '0';
                OE <= '0';
                ByteEndOfCount <= MAX_TX_DATA;
                start_ByteCount <='1';
                Address <= std_logic_vector(unsigned(DMA_TX_BUFFER_MSB) + to_unsigned(byte_count,Address'length));                                  
                Valid_D <= '0';
                if TX_RDY = '1' and end_ByteCount = '1' then
                    NextState <= DevolverDataBus_TX;
                else
                    NextState <= Envio_TX;
                end if; 
                
            when DevolverDataBus_TX =>
                READY <= '0';
                ByteEndOfCount <= MAX_TX_DATA;
                if DMA_ACK = '0' then 
                    NextState <= EsperarCPU_TX;
                else
                    NextState <= DevolverDataBus_TX;
                end if;
                
            when EsperarCPU_TX =>
                ByteEndOfCount <= MAX_TX_DATA;
                if Send_comm = '0' then 
                    NextState <= Idle;
                else 
                    NextState <= EsperarCPU_TX;
                end if;                                    
        end case;
    end process;
    
word_counter : process(clk, reset) 
  begin 
    if reset = '0' then
        byte_count <= 0;
        end_ByteCount <= '0';       
    elsif rising_edge(clk) then
        if start_ByteCount = '1' then
             if (CurrentState = Carga_RX and RX_Empty = '0') then
                if byte_count < ByteEndOfCount-1 then                     
                    byte_count <= byte_count + 1; 
                    end_ByteCount <= '0'; 
                else
                    end_ByteCount <= '1';                                          
                end if;
             elsif  (CurrentState = Envio_TX and TX_RDY = '1' and TX_RDY_aux ='1') then
                if byte_count < ByteEndOfCount - 1 then                     
                    byte_count <= byte_count + 1; 
                    end_ByteCount <= '0'; 
                else
                    end_ByteCount <= '1';                                          
                end if;
             end if;         
        end if;         
        if end_ByteCount = '1' then 
            byte_count <= 0; 
            end_ByteCount <= '0'; 
        end if;           
    end if;               
 end process;
 
TX_RDY_AUX_reg: process(clk, reset)
    begin
        if reset = '0' then 
            TX_RDY_aux <= '0';
        elsif rising_edge(clk) then 
            if TX_RDY = '0' then 
                TX_RDY_aux <= '1';
            else 
                TX_RDY_aux <= '0';
            end if;
        end if;
    end process;
    
end Behavioral;
