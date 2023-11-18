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
	 signal old_command : std_logic_vector(7 downto 0);  -- command sent from SCOMP
	 signal degreeCommand : std_logic_vector(7 downto 0);  -- command sent from SCOMP
    signal count   : std_logic_vector(11 downto 0);  -- internal counter
	 signal mode : std_logic;
	 CONSTANT half_freq   : INTEGER := 90000/2;
	 signal speed_clock : std_logic;
	 SIGNAL count_speed_clock        : INTEGER RANGE 0 TO half_freq/360; 
	 signal updown : std_logic;

begin

    -- Latch data on rising edge of CS
    process (RESETN, CS) begin
        if RESETN = '0' then
            command <= x"00";
        elsif IO_WRITE = '1' and rising_edge(CS) then
            command <= IO_DATA(8 downto 1);
				mode <= IO_DATA(0);
        end if;
		  if falling_edge(CS) then
		  old_command <= command;
		  end if;
    end process;
	 
	 
	PROCESS(CLOCk, command, old_command)
	BEGIN
	IF (old_command /= command) then
	count_speed_clock <= 0;
	else 
	if RISING_EDGE(CLOCK) then
	IF count_speed_clock < (half_freq/ to_integer(IEEE.numeric_std.unsigned(command - 1))) THEN
			count_speed_clock <= count_speed_clock + 1;
		ELSE
			count_speed_clock <= 0;
			speed_clock <= NOT(speed_clock);
		END IF;
	end if;
	end if;
	end process;
	
	
	
	 process (speed_clock)
	 begin
	 case mode is
		when '0' => degreeCommand <= command;
		when '1' => 
		if rising_edge(speed_clock) then
		
			if (updown = '1') then
			degreeCommand <= degreeCommand + 1;
			if degreeCommand = x"b4" then
			updown <= '0';
			end if;
			else 
			degreeCommand <= degreeCommand - 1;
			if degreeCommand = x"00" then
			updown <= '1';
			end if;
			end if;
			end if;
		end case;
	end process;
	 
	 
	 
	 DegreeControl: work.DegreeControl
			port map(
			CLOCK => CLOCK,
			COMMAND => degreeCommand,
			RESETN => RESETN,
			PULSE => PULSE);

end a;
