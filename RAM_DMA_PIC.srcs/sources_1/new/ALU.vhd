library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.PIC_pkg.all;

entity ALU is
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
end ALU;

architecture Behavioral of ALU is

--------------------------------------------------------
--REGISTROS
signal REG_A : std_logic_vector(7 downto 0);
signal REG_B : std_logic_vector(7 downto 0);
signal REG_ACC : std_logic_vector(7 downto 0);
--------------------------------------------------------

begin

process(Reset, Clk)

begin
    if Reset = '0' then 
        REG_A <= (others=>'0');
        REG_B <= (others=>'0');
        REG_ACC <= (others=>'0');
        Index_Reg <= (others=>'0');
        
        FlagZ <= '0';
        FlagC <= '0';
        FlagN <= '0';
        FlagE <= '0';
    elsif clk'event and clk='1' then    
    --DEFINICIÓN DE INSTRUCCIONES DE LA ALU
        case u_instruction is 
        --Carga de datos en el regitro A            
            when op_lda =>
                REG_A <= Databus;
                
                REG_B <= REG_B;
                REG_ACC <= REG_ACC;
                Index_Reg <= Index_Reg;
                FlagZ <= '0';
                FlagC <= '0';
                FlagN <= '0';
                FlagE <= '0';
        --Carga de datos en el acumulador B    
            when op_ldb => 
                REG_B <= Databus;
        
                REG_A <= REG_A;
                REG_ACC <= REG_ACC;
                Index_Reg <= Index_Reg;
                FlagZ <= '0';
                FlagC <= '0';
                FlagN <= '0';
                FlagE <= '0';
        --Carga de datos en el registro acumulador        
            when op_ldacc => 
                REG_ACC <= Databus;
        
                REG_B <= REG_B;
                REG_A <= REG_A;
                Index_Reg <= Index_Reg;
                FlagZ <= '0';
                FlagC <= '0';
                FlagN <= '0';
                FlagE <= '0';
        --Carga de datos en el registro indexado        
            when op_ldid => 
                Index_Reg <= Databus; 
        
                REG_B <= REG_B;
                REG_ACC <= REG_ACC;
                REG_A <= REG_A;
                FlagZ <= '0';
                FlagC <= '0';
                FlagN <= '0';
                FlagE <= '0';
        --Mover datos del acumulador al registro indexado      
            when op_mvacc2id => 
                Index_Reg <= REG_ACC;
        
                REG_B <= REG_B;
                REG_ACC <= REG_ACC;
                REG_A <= REG_A;
                FlagZ <= '0';
                FlagC <= '0';
                FlagN <= '0';
                FlagE <= '0';
        --Mover datos del acumulador al registro A 
            when op_mvacc2a => 
                REG_A <= REG_ACC;
                
                REG_B <= REG_B;
                REG_ACC <= REG_ACC;
                Index_Reg <= Index_Reg;
                FlagZ <= '0';
                FlagC <= '0';
                FlagN <= '0';
                FlagE <= '0';
        --Mover datos del acumulador al registro B 
            when op_mvacc2b => 
                REG_B <= REG_ACC; 
                
                REG_A <= REG_A;
                REG_ACC <= REG_ACC;
                Index_Reg <= Index_Reg;
                FlagZ <= '0';
                FlagC <= '0';
                FlagN <= '0';
                FlagE <= '0';
        --SUMA 
            when op_add => 
                REG_ACC <= std_logic_vector(unsigned(REG_A) + unsigned(REG_B));
                if REG_ACC = X"00" then
                    FlagZ <= '1';
                else 
                    FlagZ <= '0';
                end if;
                
                REG_A <= REG_A;
                REG_B <= REG_B;
                Index_Reg <= Index_Reg;
                FlagE <= '0';
                              
        --RESTA 
            when op_sub => 
               REG_ACC <= std_logic_vector(unsigned(REG_A)- unsigned(REG_B));
               if REG_ACC = X"00" then
                    FlagZ <= '1';
                else 
                    FlagZ <= '0';
                end if;
                
                
               REG_A <= REG_A;
               REG_B <= REG_B;
               Index_Reg <= Index_Reg;
               FlagE <= '0';
               
        --Desplazamiento hacia la izquierda
            when op_shiftl =>  
                for i in REG_ACC'right to REG_ACC'left-1 loop 
                    REG_ACC(REG_ACC'left-i) <= REG_ACC(REG_ACC'left-1-i);
                end loop;
                REG_ACC(0) <= '0';
                
               REG_A <= REG_A;
               REG_B <= REG_B;
               Index_Reg <= Index_Reg;
               FlagE <= '0';
               FlagZ <= '0';
               FlagC <= '0';
               FlagN <= '0';

        --Desplazamiento hacia la derecha 
            when op_shiftr => 
                for i in REG_ACC'right+1 to REG_ACC'left loop 
                    REG_ACC(i-1)<= REG_ACC(i);
                end loop; 
                REG_ACC(REG_ACC'left) <= '0';
                
                REG_A <= REG_A;
                REG_B <= REG_B;
                Index_Reg <= Index_Reg;
                FlagE <= '0';
                FlagZ <= '0';
                FlagC <= '0';
                FlagN <= '0';
               
        --AND
            when op_and => 
               for i in REG_ACC'right to REG_ACC'left loop 
                    REG_ACC(i) <= REG_A(i) and REG_B(i);
                end loop;  
                if REG_ACC = X"00" then 
                    FlagZ <= '1';
                else 
                    FlagZ <= '0';
                end if;
                
                REG_A <= REG_A;
                REG_B <= REG_B;
                Index_Reg <= Index_Reg;
                FlagE <= '0';
                FlagC <= '0';
                FlagN <= '0';
       
        --OR 
            when op_or => 
                for i in REG_ACC'right to REG_ACC'left loop 
                    REG_ACC(i) <= REG_A(i) or REG_B(i);
                end loop;  
                if REG_ACC = X"00" then 
                    FlagZ <= '1';
                else 
                    FlagZ <= '0';
                end if;
                
                REG_A <= REG_A;
                REG_B <= REG_B;
                Index_Reg <= Index_Reg;
                FlagE <= '0';
                FlagC <= '0';
                FlagN <= '0';
                
        --XOR
            when op_xor => 
               for i in REG_ACC'right to REG_ACC'left loop 
                    REG_ACC(i) <= REG_A(i) xor REG_B(i);
                end loop;  
                if REG_ACC = X"00" then 
                    FlagZ <= '1';
                else 
                    FlagZ <= '0';
                end if; 
                
                REG_A <= REG_A;
                REG_B <= REG_B;
                Index_Reg <= Index_Reg;
                FlagE <= '0';
                FlagC <= '0';
                FlagN <= '0'; 
                
       --A=B 
             when op_cmpe => 
                if REG_A = REG_B then 
                    FlagZ <= '1';
                else 
                    FlagZ <= '0';
                end if;
                
                REG_ACC <= REG_ACC;
                REG_A <= REG_A;
                REG_B <= REG_B;
                Index_Reg <= Index_Reg;
                FlagE <= '0';
                FlagC <= '0';
                FlagN <= '0';
      
       --A>B
            when op_cmpg =>    
                if REG_A > REG_B then 
                    FlagZ <= '1';
                else 
                    FlagZ <= '0';
                end if;
                
                REG_ACC <= REG_ACC;
                REG_A <= REG_A;
                REG_B <= REG_B;
                Index_Reg <= Index_Reg;
                FlagE <= '0';
                FlagC <= '0';
                FlagN <= '0';
                
      --A<B 
            when op_cmpl => 
                if REG_A < REG_B then 
                    FlagZ <= '1';
                else 
                    FlagZ <= '0';
                end if; 
                
                REG_ACC <= REG_ACC;
                REG_A <= REG_A;
                REG_B <= REG_B;
                Index_Reg <= Index_Reg;
                FlagE <= '0';
                FlagC <= '0';
                FlagN <= '0'; 
                
      --ASCII a Binario 
           when op_ascii2bin => 
                
           
      --Binario a ASCII 
           when op_bin2ascii => 
           
           
      --Output Enable 
           when op_oeacc => 
           
           
           when others => 
               REG_ACC <= REG_ACC;
               REG_A <= REG_A;
               REG_B <= REG_B;
               Index_Reg <= Index_Reg;
               FlagE <= '0';
               FlagC <= '0';
               FlagN <= '0';
               FlagZ <= '0';
           
      end case;
   end if;              
end process;

end Behavioral;
