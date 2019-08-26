library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_int is
	port (clk,reset: in std_logic;
			--LED : out std_logic;
			timeout : out std_logic_vector(13 downto 0) ;
			rs,rw,en : out std_logic;
			data : out std_logic_vector(7 downto 0);
			b11,b12 : out std_logic
			--gameover : out std_logic
--			bintime : out std_logic_vector(12 downto 0)
			);
end entity;
architecture struct of control_int is

component lcd_controller is
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
      b11 : out std_ulogic;
      b12 : out std_ulogic);     --data line
end component;


signal sclk,led_sig,newrst,done_sig : std_logic;
signal randsig : std_logic_vector(10 downto 0);
signal React : std_logic;
signal timeoutsig : std_logic_vector(13 downto 0);
signal oversig : std_logic := '0';
signal rstcount_sig : std_logic_vector(3 downto 0);
signal reactcount,ledcount : std_logic_vector(3 downto 0);
signal debreact : std_logic;

signal erase : std_logic := '0';
signal put_char : std_logic := '1';
signal write_data : std_logic_vector(7 downto 0);
signal write_row : std_logic_vector(0 downto 0);
signal write_column : std_logic_vector(3 downto 0);
signal ack : std_logic;

begin
--	React <= not nreact;
--	Reset <= not nreset;
--	LED <= led_sig and not (oversig);
--
--	gameover <= oversig;
--
--	s0 : debouncer port map (x=>React , clk=>CLK, reset=>Reset, output=>debreact);
--	s1 : slowclk port map (inclk=>CLK, outclk=>sclk);
--	s2 : randgen port map (clk=>CLK, stop=>React, output=>randsig);
--	s3 : ledctrl port map (sclk=>sclk, react=>React, rst=>newrst, random=>randsig, toled=>led_sig);
--	s4 : timer port map (led=>led_sig, Reset=>Reset, sclk=>sclk, tottime=>timeout);
--	s5 : looper port map(React=>React, Reset=>Reset, sclk=>sclk, newrst=>newrst, done=>done_sig, rstcount=>rstcount_sig);
--	s6 : over port map (React=>debreact, Reset=>Reset, led=>led_sig, reactcount=>reactcount, ledcount=>ledcount);
	s7 : lcd_controller port map (clk=>clk, rst=>reset, erase=>erase, put_char=>put_char,
											write_data=>write_data, write_row=>write_row, write_column=>write_column,
											ack=>ack, lcd_rw=>rw, lcd_en=>en, lcd_rs=>rs, lcd1=>data, b11=>b11, b12=>b12);

	process(clk,reset,ack)
	constant wrdata : unsigned(7 downto 0) := to_unsigned(48,8);
	variable d, nextd : integer := -1;
	variable timeint,digit : integer := 0;
--	variable p : std_logic;
	variable putdata : std_logic_vector(7 downto 0);

	begin
		if(rising_edge(clk)) then

			if (reset = '1') then
				erase <= '1';
				write_row <= "0";
				write_column <= "0000";
				put_char <= '1';
				d:=3;
			--	oversig <= '0';
			end if;

--			if (reactcount > ledcount) then
--				oversig <= '1';
--			end if;
--			
			if (ack = '1') then
				
				erase <= '0';
				
				if d=-1 then
					timeint := to_integer(unsigned(timeoutsig));
					nextd:=-2;
					putdata:=std_logic_vector(wrdata + unsigned(reactcount));
					d:=3;
				end if;
				
				if d=-2 then
					nextd:=3;
					putdata:=std_logic_vector(wrdata + unsigned(ledcount));
					d:=3;

				end if;
					
				
				if d=3 then
					if (timeint - 1000 >= 0) then
						timeint := timeint - 1000;
						digit := digit + 1;
					else
						putdata:=std_logic_vector(wrdata + digit);
						nextd := 2;
						digit := 0;
					end if;
				end if;

				if d=2 then
					if (timeint - 100 >= 0) then
						timeint := timeint - 100;
						digit := digit + 1;
					else
						putdata:=std_logic_vector(wrdata + digit);
						nextd := 1;
						digit := 0;
					end if;
				end if;
				
				if d=1 then
					if (timeint - 10 >= 0) then
						timeint := timeint - 10;
						digit := digit + 1;
					else						
						putdata:=std_logic_vector(wrdata + digit);
						nextd := 0;
						digit := 0;
					end if;
				end if;
				
				if d=0 then
						digit := timeint;
						putdata:=std_logic_vector(wrdata + digit);
						nextd := -1;
						digit := 0;
				end if;
				
				if (oversig = '1') then
					putdata := std_logic_vector(wrdata);
				end if;
				
				if(done_sig = '1') then
					put_char<='0';
				else
					put_char<='1';
				end if;
				
				
				write_data<=putdata;		
				write_row<=std_logic_vector(to_unsigned(1,1));
				write_column<=std_logic_vector(to_unsigned(15-d,4));
														
				d := nextd;			
			end if;
		end if;
	end process;
end struct;