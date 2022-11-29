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
signal REG_A : std_logic_vector(Databus'high downto 0);
signal REG_B : std_logic_vector(Databus'high downto 0);
signal REG_ACC : std_logic_vector(Databus'high+1 downto 0);
--------------------------------------------------------

begin

process(Reset, Clk)
begin
    if Reset = '0' then 
        REG_A <= (others=>'0');
        REG_B <= (others=>'0');
        REG_ACC <= (others=>'0');
        Index_Reg <= (others=>'0');
    elsif clk'event and clk='1' then    
    --DEFINICIÓN DE INSTRUCCIONES DE LA ALU
        case u_instruction is 
        --Carga de datos en el regitro A            
            when op_lda =>
                REG_A <= Databus;               
                REG_B <= REG_B;
                REG_ACC <= REG_ACC;
                
        --Carga de datos en el acumulador B    
            when op_ldb => 
                REG_B <= Databus;        
                REG_A <= REG_A;
                REG_ACC <= REG_ACC;
                
        --Carga de datos en el registro acumulador        
            when op_ldacc => 
                REG_ACC(REG_ACC'high-1 downto 0) <= Databus;       
                REG_B <= REG_B;
                REG_A <= REG_A;
                
        --Carga de datos en el registro indexado        
            when op_ldid => 
                Index_Reg <= Databus;        
                REG_B <= REG_B;
                REG_ACC <= REG_ACC;
                REG_A <= REG_A;
                
        --Mover datos del acumulador al registro indexado      
            when op_mvacc2id => 
                Index_Reg <= REG_ACC(REG_ACC'high-1 downto 0);
                REG_B <= REG_B;
                REG_ACC <= REG_ACC;
                REG_A <= REG_A;
                
        --Mover datos del acumulador al registro A 
            when op_mvacc2a => 
                REG_A <= REG_ACC(REG_ACC'high-1 downto 0);               
                REG_B <= REG_B;
                REG_ACC <= REG_ACC;
                
        --Mover datos del acumulador al registro B 
            when op_mvacc2b => 
                REG_B <= REG_ACC(REG_ACC'high-1 downto 0);                 
                REG_A <= REG_A;
                REG_ACC <= REG_ACC;
                
        --SUMA 
            when op_add => 
                REG_ACC <= std_logic_vector(unsigned('0'&REG_A) + unsigned('0'&REG_B));
                REG_A <= REG_A;
                REG_B <= REG_B;
                              
        --RESTA 
            when op_sub => 
               REG_ACC <= std_logic_vector(signed('0'&REG_A)- signed('0'&REG_B));             
               REG_A <= REG_A;
               REG_B <= REG_B;
               
        --Desplazamiento hacia la izquierda
            when op_shiftl =>  
               for i in REG_ACC'right to REG_ACC'left-2 loop 
                    REG_ACC(REG_ACC'left-i-1) <= REG_ACC(REG_ACC'left-2-i);
               end loop;
               REG_ACC(0) <= '0';               
               REG_A <= REG_A;
               REG_B <= REG_B;

        --Desplazamiento hacia la derecha 
            when op_shiftr => 
                for i in REG_ACC'right+1 to REG_ACC'left-1 loop 
                    REG_ACC(i-1)<= REG_ACC(i);
                end loop; 
                REG_ACC(REG_ACC'left-1) <= '0';                
                REG_A <= REG_A;
                REG_B <= REG_B;
               
        --AND
            when op_and => 
               for i in REG_ACC'right to REG_ACC'left-1 loop 
                    REG_ACC(i) <= REG_A(i) and REG_B(i);
                end loop;                
                REG_A <= REG_A;
                REG_B <= REG_B;
       
        --OR 
            when op_or => 
                for i in REG_ACC'right to REG_ACC'left-1 loop 
                    REG_ACC(i) <= REG_A(i) or REG_B(i);
                end loop;                 
                REG_A <= REG_A;
                REG_B <= REG_B;
                
        --XOR
            when op_xor => 
               for i in REG_ACC'right to REG_ACC'left-1 loop 
                    REG_ACC(i) <= REG_A(i) xor REG_B(i);
                end loop;                  
                REG_A <= REG_A;
                REG_B <= REG_B;
                
      --ASCII a Binario 
           when op_ascii2bin => 
               if REG_A >= std_logic_vector(to_unsigned(48,REG_A'length)) and REG_A <= std_logic_vector(to_unsigned(57,REG_A'length)) then
                   REG_A <= std_logic_vector(unsigned(REG_A)-to_unsigned(48,REG_A'length));
               else 
                REG_A <= REG_A;
               end if;
               REG_ACC <= REG_ACC;
               REG_B <= REG_B;
           
      --Binario a ASCII 
           when op_bin2ascii => 
              if REG_A >= std_logic_vector(to_unsigned(0,REG_A'length)) and REG_A <= std_logic_vector(to_unsigned(9,REG_A'length)) then
                  REG_A <= std_logic_vector(unsigned(REG_A)+to_unsigned(48,REG_A'length));
              else
                  REG_A <= REG_A;
              end if;
              REG_ACC <= REG_ACC;
              REG_B <= REG_B;
              
           when others => 
               REG_ACC <= REG_ACC;
               REG_A <= REG_A;
               REG_B <= REG_B;
           
      end case;
   end if;              
end process;

---------------------------------------------------------------------------------------------------
-- GESTIÓN DE FLAGS
FlagC <= '0' when Reset = '0' else
         REG_ACC(REG_ACC'high) when u_instruction = op_add or u_instruction = op_sub else
         '0';
         
FlagZ <= '0' when Reset = '0' else 
         '1' when (REG_ACC(REG_ACC'high downto 0) = std_logic_vector(to_unsigned(0,REG_ACC'length))) and (u_instruction = op_add or u_instruction = op_sub or u_instruction = op_and or u_instruction = op_or or u_instruction = op_xor) else
         '1' when (REG_A = REG_B) and (u_instruction = op_cmpe) else 
         '1' when (REG_A > REG_B) and (u_instruction = op_cmpg) else 
         '1' when (REG_A < REG_B) and (u_instruction = op_cmpl) else 
         '0';
         
FlagE <= '0' when Reset = '0' else 
         '1' when (REG_A < std_logic_vector(to_unsigned(48,REG_A'length)) or REG_A > std_logic_vector(to_unsigned(57,REG_A'length))) and (u_instruction = op_ascii2bin) else
         '1' when (REG_A > std_logic_vector(to_unsigned(9,REG_A'length))) and (u_instruction = op_bin2ascii) else 
         '0';
         
FlagN <= '0'; 

---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- Escritura en databus        
Databus <= REG_ACC(REG_ACC'left-1 downto 0) when u_instruction = op_oeacc else (others => 'Z');
---------------------------------------------------------------------------------------------------
end Behavioral;
