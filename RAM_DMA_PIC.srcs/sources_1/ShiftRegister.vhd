
library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;
   
entity ShiftRegister is
    generic(data_width:integer:=8);
  port (
    Reset     : in  std_logic;   -- Low-level asynchronous reset
    Clk       : in  std_logic;   -- System clock (20MHz), rising edge 
    Enable    : in  std_logic;   -- Shifts when Enable = '1' 
    D         : in  std_logic;   -- Input Serial Bit (left input)
    Q         : out std_logic_vector(data_width-1 downto 0) );    -- Output parallel data 
      
end ShiftRegister;

architecture RTL of ShiftRegister is

  signal s_Q   : std_logic_vector(data_width-1 downto 0);

begin  -- RTL

  Storage : process (Clk, Reset)
  begin
    if Reset = '0' then  -- asynchronous reset (active low)
      s_Q   <= (others => '0');
    elsif rising_edge(Clk) then  -- rising edge of the clock
      if Enable = '1' then
        s_Q <= D & s_Q (data_width-1 downto 1); 
      end if;
    end if;
  end process;

  Q <= s_Q;
end RTL;

