library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity led_fsm is
   port (
     led_on :  in std_logic;
	  led_off : in std_logic;
	  led_final : out std_logic;
	  clk    :in  std_logic; 
	  reset : in std_logic ;
	  game_over : out std_logic 
   );
 end entity;

architecture rtl of led_fsm is
    type state_type is (L_on, L_off);
    signal state, next_state : state_type;
 begin
SYNC_PROC : process (clk)
    begin
	   if rising_edge(clk) then
       if (reset = '1') then
       state <= L_off;
         else               --LED on after reset and turns off after one clock cycle 
        state <= next_state;
         --\led_final <= '0';
         end if;
			end if;
        end process;
NEXT_STATE_DECODE : process (state, led_on,led_off)
begin
   case (state) is
   when L_on =>
	    game_over <= '0' ;
	   -- led_final <= '1';
      if (led_on = '1') then      --LED is in on state also at redundant states '0 0 ' and '0 1 ' which wont come !
			if (led_off = '1') then
         led_final <= '0';
          next_state <= L_off;
         else
			led_final <= '1';
         next_state <= L_on;
         end if;
			end if ;
			
    when L_off =>
     led_final <= '0';
	  game_over <= '0' ;
	if (led_on = '1') then
	next_state <= L_on;
	end if ;
	
	if (led_off = '1') then
	      game_over <= '1';
	      next_state <= L_off;
	    else game_over <= '0' ; 
	  end if ;
	 	 
   when others =>
   next_state <= L_off;
	
    end case;
end process;
end architecture;