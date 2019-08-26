library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Reaction_game is
   port (
     Reset_bar :  in std_logic;
	  LED : out std_logic ;                      --LED Output
	  React_bar : in std_logic;
	  rs,rw,en : out std_logic;
	  data : out std_logic_vector(7 downto 0);
	  b11,b12 : out std_logic;
	  CLK    :in  std_logic
	  --LCD_out : out std_logic_vector (13 downto 0) -- Sum of Response time in binary  
   ) ;
 end entity;
 
architecture struct of Reaction_game is

component Clock_Divider is
     port ( clk,reset: in std_logic;
            clock_out: out std_logic
				);
end component;


component rand_num is
   port (
     cout :out std_logic_vector (10 downto 0); -- Output of the counter
     react :in  std_logic;                     --loads present random state
     clk    :in  std_logic;                     -- Input clock
     reset  :in  std_logic                      -- Input reset
   );
 end component;
 
 component down_counter is
   port ( 
	  led_on_signal :out std_logic ;                --turns ON the LED
     data : in  std_logic_vector(10 downto 0); -- Parallel load for the counter
     load   :in  std_logic;                     -- Parallel load enable
     clk    :in  std_logic;                     -- Input clock
     reset  :in  std_logic                      -- Input reset
   );
 end component;
 
component final_wait is
   port (
	  led_off_signal : out std_logic ;  --led signal to go to off state
     enable :in  std_logic;                     -- Enable counting
     react :in  std_logic;                     -- Enable counting
     clk    :in  std_logic;                     -- Input clock
     reset  :in  std_logic                      -- Input reset
   );
 end component;
 
component led_fsm is
   port (
     led_on :  in std_logic;
	  led_off : in std_logic;
	  led_final : out std_logic;
	  clk    :in  std_logic; 
	  reset : in std_logic ;
	  game_over : out std_logic 
   );
 end component;
 
component measure_counter is
   port (
     cout   :out std_logic_vector (13 downto 0); -- Output of the counter bits to be displayed on LCD
     enable :in  std_logic;                     -- Enable counting when led is on
     clk    :in  std_logic;                     -- Input clock 
     reset  :in  std_logic                      -- Input reset
   );
 end component;
 
component countPulse is port (
      clk, reset: in std_logic;
      A: in std_logic;         -- A is the input bit stream
      doneFlag: out std_logic);    -- doneFlag is high if the number of pulses exceeds 8 count
end component;

component control_int is
	port (clk,reset: in std_logic;
			--LED : out std_logic;
			timeout : out std_logic_vector(13 downto 0) ;
			rs,rw,en : out std_logic;
			data : out std_logic_vector(7 downto 0);
			b11,b12 : out std_logic
			--gameover : out std_logic
--			bintime : out std_logic_vector(12 downto 0)
			);
end component;
 
signal randum_number : std_logic_vector (10 downto 0);  --LCD display will have three inputs i.e. 'LCD_out' total response time shifted by 3 bits and 'over_sig' to  
signal LCD_out : std_logic_vector (13 downto 0) ;       -- show game over and 'lcd_display_sig' to display final average reponse time in decimal.
signal Reset, React, down_cntr_sig, wait_state_sig,LED_sig , over_sig, lcd_display_sig , clk_1k: std_logic ;
--signal LED_sig : std_logic_vector (7 downto 0) ;
begin

Reset <= (not Reset_bar) ;
React <= (not React_bar) ;

Clock_Divider_1KHZ : Clock_Divider port map (reset => Reset, clk => CLK, clock_out => clk_1k);
 
Random_Number_generation : rand_num port map (reset => Reset, react => React, clk => clk_1k, cout => randum_number);

Down_counting_of_Randum : down_counter port map (reset => Reset, clk => clk_1k, load => React, data => randum_number, led_on_signal => down_cntr_sig);

Wait_state_2s: final_wait port map (reset => Reset, react => React, clk => clk_1k, enable => down_cntr_sig, led_off_signal => wait_state_sig);

LED_control_state: led_fsm port map (reset => Reset, clk => CLK, led_on => down_cntr_sig, led_off => wait_state_sig, led_final => LED_sig , game_over => over_sig);

measure_time : measure_counter port map (reset => Reset, clk => clk_1k, enable => LED_sig, cout => LCD_out) ;

done_eight_times : countPulse port map (reset => Reset, clk => clk_1k , A => LED_sig, doneFlag => lcd_display_sig ) ;

lcd_interface : control_int port map ( clk => CLK_1k,reset => Reset,timeout =>LCD_out,  rs => rs,rw => rw,en => en, b11 =>b11,b12 => b12 , data => data  ) ;

LED <= LED_sig ;
 

end struct;
