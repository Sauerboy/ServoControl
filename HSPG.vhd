-- HSPG.vhd (hobby servo pulse generator)
-- This starting point generates a pulse between 100 us and something much longer than 2.5 ms.

library IEEE;
library lpm;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use IEEE.numeric_std.all;
use lpm.lpm_components.all;

entity HSPG is
    port(
        CS          : in  std_logic;
        IO_WRITE    : in  std_logic;
        IO_DATA     : in  std_logic_vector(15 downto 0);
        CLOCK       : in  std_logic;
        RESETN      : in  std_logic;
        PULSE       : out std_logic
    );
end HSPG;

architecture a of HSPG is

    signal command : std_logic_vector(7 downto 0);  -- command sent from SCOMP
	 signal degree_command : std_logic_vector(7 downto 0);  -- command sent from SCOMP
    signal count   : std_logic_vector(11 downto 0);  -- internal counter
	 signal mode : std_logic; -- 0 is degree mode, 1 is speed mode
	 CONSTANT half_freq   : INTEGER := 90000/2;
	 signal speed_clock : std_logic; -- variable speed clock used in speed control
	 SIGNAL count_speed_clock        : INTEGER RANGE 0 TO half_freq; -- used to generate speed clock. 
	 signal up_down : std_logic; -- controls whether angle of servo is incremented or decremented when in speed mode.

begin

    -- Latch data on rising edge of CS
    process (RESETN, CS) begin
        if RESETN = '0' then
            command <= x"00";
        elsif IO_WRITE = '1' and rising_edge(CS) then
            command <= IO_DATA(8 downto 1);
				mode <= IO_DATA(0); -- Assign LSB of IO_DATA to mode
        end if;
    end process;
	 
	 
	process(CLOCK, command)
	begin
	if rising_edge(CLOCK) then
	if count_speed_clock < (half_freq/ (to_integer(IEEE.numeric_std.unsigned(command + x"01")))) then
			count_speed_clock <= count_speed_clock + 1;
		else
			count_speed_clock <= 0;
			speed_clock <= NOT(speed_clock);
		end if;
	end if;
	end process;
	
	
	
	 process (speed_clock)
	 begin
	 case mode is 
		when '0' => if command > x"b4" then -- when in degree mode, assign the degree_command to command
														--  as long as it's in a safe range
						degree_command <= x"b4";
						else degree_command <= command;
						end if;
		when '1' => -- increment/decrement degree_command every clock cycle depending on up_down
						-- when a max/min is hit, invert up_down
		if rising_edge(speed_clock) then
			if (up_down = '1') then
			degree_command <= degree_command + x"01";
			if (degree_command = x"b4") then 
			up_down <= '0';
			end if;
			elsif (up_down = '0' and degree_command > 0) then
			degree_command <= degree_command - x"01";
			if (degree_command <= x"01") then
			up_down <= '1';
			end if;
			end if;
			end if;
		end case;
	end process;
	 
	 
	 -- map to degree_control VHDL
	 DegreeControl: work.DegreeControl
			port map(
			CLOCK => CLOCK,
			COMMAND => degree_command,
			RESETN => RESETN,
			PULSE => PULSE);

end a;
