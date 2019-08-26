library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
 
entity measure_counter is
   port (
     cout   :out std_logic_vector (13 downto 0); -- Output of the counter bits
     enable :in  std_logic;                     -- Enable counting when led is on
     clk    :in  std_logic;                     -- Input clock 
     reset  :in  std_logic                      -- Input reset
   );
 end entity;
 
 architecture rtl of measure_counter is
     signal count :std_logic_vector (13 downto 0);
 begin
     process (clk, reset) begin
         if (reset = '1') then
             count <= (others=>'0');
         elsif (rising_edge(clk)) then
             --if (load = '1') then
               --  count <= 1000 + data;
             if (enable = '1') then
                 count <= count + 1;
             end if;
         end if;
     end process;
     cout <= count;
end architecture;
