library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
 
entity down_counter is
   port ( 
	  led_on_signal :out std_logic ;                --turns ON the LED
     --cout   :out std_logic_vector (9 downto 0); -- Output of the counter
     data : in  std_logic_vector(10 downto 0); -- Parallel load for the counter
     load   :in  std_logic;                     -- Parallel load enable
     --enable :in  std_logic;                     -- Enable counting
     clk    :in  std_logic;                     -- Input clock
     reset  :in  std_logic                      -- Input reset
   );
 end entity;
 
 architecture rtl of down_counter is
     signal count :std_logic_vector (10 downto 0);
 signal led_s : std_logic ;
 begin
     process (clk, reset, led_s) begin
         if (reset = '1') then
             count <= "11111010000";
				 --count <= "0000000101" ;   used for rtl testing
         elsif (rising_edge(clk)) then
             if (load = '1') then
                 count <=1000+ data;
					  --count <=5+ data;     
             elsif (led_s = '0') then
                 count <= count - 1;    --It goes to state 1024 after 0 ?
             end if;
         end if;
			
	     if (count = "00000000000") then 
	      led_s <= '1' ;
              else led_s <= '0' ;
	       end if ;

			
     end process;
	led_on_signal <= led_s ;  
     --cout <= count;
end architecture;
