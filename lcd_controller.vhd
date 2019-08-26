library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity lcd_controller is
port (clk    : in std_logic;                          
      rst    : in std_logic;                          -- reset
      erase : in std_logic;                  --- clear position
      put_char : in std_logic;
      write_data : in std_logic_vector(7 downto 0) ;
      write_row : in std_logic_vector(0 downto 0);
      write_column : in std_logic_vector(3 downto 0);
      ack : out std_logic;
      lcd_rw : out std_logic;                         --read & write control
      lcd_en : out std_logic;                         --enable control
      lcd_rs : out std_logic;                         --data or command control
      lcd1  : out std_logic_vector(7 downto 0);
      b11 : out std_logic;
      b12 : out std_logic);     --data line
end lcd_controller;


architecture Behavioral of lcd_controller is 

type arr is array (0 to 4) of std_logic_vector(7 downto 0);
 constant lcd_cmd : arr := (x"38",x"01",x"0C",x"80",x"04");  -- cmd for LCD

 
signal lcd : std_logic_vector ( 7 downto 0);
signal count_next_cmd, count_cmd :integer range 0 to 5;
signal count_next_data, count_data :integer range 0 to 6;
signal count_next_data1, count_data1 :integer range 0 to 4;
signal cmd_line, cmd_line_next :integer range 0 to 10;
signal cmd_position : std_logic_vector(7 downto 0);
signal data_dis : std_logic_vector(7 downto 0);


type state_type is ( S0,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,S11 );
signal state : state_type := S0;

begin

count_next_cmd <= count_cmd + 1;
count_next_data <= count_data + 1;
count_next_data1 <= count_data1 + 1;
cmd_line_next <= cmd_line + 1;
b11 <= '1';
b12 <= '0';
lcd1 <= lcd;

process(clk)
begin
if rising_edge(clk) then
if (write_row(0) = '0') then          -- first row
   cmd_position <= x"80" + write_column ;
   elsif (write_row(0) = '1') then        -- second row
    cmd_position <= x"C0" + write_column ;
end if;
end if;
end process;


PROCESS(clk)

BEGIN

if rising_edge(clk) then

if (rst='0') then
		state <= S0;
		count_cmd <= 0;
		count_data <= 0;
		count_data1 <= 0;
		cmd_line <= 0;
		ack <= '0';
	else
	
	case state is	
	
		when S0=>		-- S0 to S2: Send LCD commands	
			if (count_cmd < 5) then		
				lcd <= lcd_cmd(count_cmd);
				lcd_rs <= '0';
				lcd_rw <= '0';
				lcd_en <= '0';
				ack <= '0';
				state <= S1;
			else 
				state <= S3;				
			end if;
							
		when S1=>	
			lcd <= lcd_cmd (count_cmd);
			lcd_rs <= '0';
			lcd_rw <= '0';
			lcd_en <= '1';
			ack <= '0';
			state <= S2;		
		
			
		when S2 =>	
			lcd <= lcd_cmd (count_cmd);
			lcd_rs <= '0';
			lcd_rw <= '0';
			lcd_en <= '0';
			ack <= '0';
			state <= S0;
			count_cmd <= count_next_cmd;
		
							
		when S3 =>	            -- S3 to S5: Send LCD command position
			lcd <= cmd_position;
			lcd_rs <= '0';
			lcd_rw <= '0';
			lcd_en <= '0';
			ack <= '0';
			state <= S4;	
			
		when S4 =>
			lcd <= cmd_position;
			lcd_rs <= '0';
			lcd_rw <= '0';
			lcd_en <= '1';
			ack <= '0';
			state <= S5;
		
							
		when S5 =>		
			lcd <= cmd_position;
			lcd_rs <= '0';
			lcd_rw <= '0';
			lcd_en <= '0';	
			ack <= '0';
			state <= S6;
			
	when S6=>                     -- S6 to S8: Send LCD data or clear
		   if (erase = '1' ) then
		      data_dis <= x"20";  -- to clear the data
			   lcd <=  data_dis;
			   lcd_rs <= '1';
			   lcd_rw <= '0';
			   lcd_en <= '0';
			   ack <= '0';
			   state <= S7;
			elsif ( put_char = '1') then
			   data_dis <= write_data;       -- lcd data
				lcd <=  data_dis;
			   lcd_rs <= '1';
			   lcd_rw <= '0';
			   lcd_en <= '0';
			   ack <= '0';
			   state <= S7;				
			elsif ( erase = '0' and put_char = '0') then
			   state <= S3;
			end if; 
			
	when S7=>
			lcd <= data_dis ;
			lcd_rs <= '1';
			lcd_rw <= '0';
			lcd_en <= '1';
			ack <= '0';
			state <= S8;
		   
			
	when S8=>		
			lcd <= data_dis  ;
			lcd_rs <= '1';
			lcd_rw <= '0';
			lcd_en <= '0';
			ack <= '1';     
			state <= S9;

	when S9 =>
		   ack <= '0';
		   state <= s3;
			
	when others =>
			state <= S0;
			count_cmd <= 0;		
							
	end case;
	end if;
   end if;
end process;

end Behavioral;
