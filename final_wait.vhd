library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
 
entity final_wait is
   port (
     --cout   :out std_logic_vector (9 downto 0); -- Output of the counter
	  led_off_signal : out std_logic ;  --led signal to go to off state
	  --game_over: out std_logic ; -- game over signal
     --data   :in  std_logic_vector (9 downto 0); -- Parallel load for the counter
     --load   :in  std_logic;                     -- Parallel load enable
     enable :in  std_logic;                     -- Enable counting
     react :in  std_logic;                     -- Enable counting
     clk    :in  std_logic;                     -- Input clock
     reset  :in  std_logic                      -- Input reset
   );
 end entity;
 
 architecture rtl of final_wait is
     signal count :std_logic_vector (10 downto 0);
	  signal led_state : std_logic ;
 begin
     --led_state <= '0' ;
     process (clk, reset, react) begin
         if (reset = '1') then
             count <= (others=>'0');
				 led_state <= '0';
				 
         elsif (rising_edge(clk)) then
             if(enable = '1') then
           if (count < 2000) then
                 count <= count + 1;
					  if (react = '1' ) then 
				   led_state <= '1' ;   ----off the LED
              else led_state <= '0';
				   end if ;
				end if;
             
				 
             elsif (count = 2000) then
				 count <= (others=>'0') ;
               -- game_over <= '1';   change 10 by 2000
					led_state <= '1' ; 
					--else led_state <= '0';
				 end if ;
          end if;
			 
--			 if (count < 2000 ) then
--				   if (react = '1' ) then 
--				   led_state <= '1' ;   ----off the LED
--               else led_state <= '0';
--				   end if ;
--				 end if;
--			 
--			 if (led_state = '0' ) then
--			  if (react = '1' ) then  ---- Two simultaneous reacts
--			   game_over <= '1' ;
--			  end if;
--			 end if;
     led_off_signal <= led_state ;
	 end process;
	 
	 -- cout <= count ;
end architecture;
