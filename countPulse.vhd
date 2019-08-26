library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity countPulse is port (
      clk, reset: in std_logic;
      A: in std_logic;         -- A is the input bit stream
      doneFlag: out std_logic);    -- doneFlag is high if the number of pulses exceeds 8 count
end countPulse;

architecture a1 of countPulse is

type stateType is (allOnes, between, inPulse, doneState);
signal state: stateType;
signal countReg: std_logic_vector(3 downto 0);  	 -- count is the number of pulses detected

begin
      process(clk) begin
       if rising_edge(clk) then
        if reset = '1' then
         countReg <= (others => '0');
           state <= allOnes;
      else 
      case state is
       when allOnes =>
         if A = '0' then
         state <= between;
         end if;
			
      when between =>
       if A = '1' then
        state <= inPulse;
         end if;

			when inPulse =>
        if A = '0' and
          countReg /= "1000" then 
           countReg <= countReg + "1";
            state <= between;
             elsif A = '0' and
            countReg = "1000" then
             state <= doneState;
          end if;
         when others => 

          end case;
           end if;
          end if;
 end process;
 doneFlag <= '1' when state = doneState else '0';
end a1; 