library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
 
entity rand_num is
   port (
     cout :out std_logic_vector (10 downto 0); -- Output of the counter
     --data   :in  std_logic_vector (9 downto 0); -- Parallel load for the counter
     --load   :in  std_logic;                     -- Parallel load enable
     react :in  std_logic;                     --loads present random state
     clk    :in  std_logic;                     -- Input clock
     reset  :in  std_logic                      -- Input reset
   );
 end entity;
 
 architecture rtl of rand_num is
     signal count :std_logic_vector (10 downto 0);
	  signal random :std_logic_vector(10 downto 0) ;
 begin
     process (clk, reset, react, count) begin
         if (reset = '1') then
             count <= (others=>'0');
         elsif (rising_edge(clk)) then
             if (count < 1000) then-----change 5 to 1000
                 count <= count + 1;
				 end if;
             if (count = 1000 ) then
                count <= (others=>'0');
				 end if ;
          end if;
			 if (react = '1') then    ---why it is changing only at falling edge in simulation ?
             random <= count;
				-- else random <= (others=>'0') ;
	          end if ;
     end process;
	  cout <= random ;
	  
end architecture;