-- HSPG.vhd (hobby servo pulse generator)
-- This starting point generates a pulse between 100 us and something much longer than 2.5 ms.

library IEEE;
library lpm;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
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

	 CONSTANT half_freq   : INTEGER := 45000;
	 signal count_360Hz   : INTEGER RANGE 0 TO half_freq/360;
	 signal clock_360Hz_int : STD_LOGIC; 
	 
    signal command : std_logic_vector(7 downto 0);  -- command sent from SCOMP
	 signal speed	 : std_logic_vector(7 downto 0);  -- command sent from SCOMP
	 signal safeCommand : std_logic_vector(7 downto 0);
    signal count   : std_logic_vector(11 downto 0);  -- internal counter
	 signal mode	 : std_logic;
	 signal upDown  : std_logic := '0';

begin

    -- Latch data on rising edge of CS
    process (RESETN, CS) begin
        if RESETN = '0' then
            command <= x"00";
        elsif IO_WRITE = '1' and rising_edge(CS) then
				mode <= IO_DATA(0);
				if mode = '0' then
					command <= IO_DATA(8 downto 1);
				else 
					speed <= IO_DATA(8 downto 1);
				end if;
        end if;
    end process;

    -- This is a VERY SIMPLE way to generate a pulse.  This is not particularly
    -- flexible and it has some issues.  It works, but you should probably consider ways
    -- to improve this.
    process (RESETN, CLOCK)
    begin
        if (RESETN = '0') then
            count <= x"000";
        elsif rising_edge(CLOCK) then
            count <= count + 1;
				
				IF count_360Hz < (half_freq/360-1) THEN
				count_360Hz <= count_360Hz + 1;
				ELSE
				count_360Hz <= 0;
				clock_360Hz_int <= NOT(clock_360Hz_int);
				END IF;
				
				
            if (count = x"708") then  -- 20 ms has elapsed
                -- Reset the counter and set the output high.
                count <= x"000";
                PULSE <= '1';
            elsif count >= (x"0" & safeCommand) then
                -- Once the count reaches the command value, set the output low.
                -- This will make larger command values produce longer pulses.
                PULSE <= '0';
            end if;
        end if;
    end process;
	 
	 safeCommand <= x"e1" WHEN command > x"b4" else
						 command + x"2d";
						 
	process (mode, RESETN, clock_360Hz_int)
   begin
	if mode = '1' then
        if (RESETN = '0') then
            command <= x"00";
        elsif rising_edge(clock_360Hz_int) then
				if updown = '1' then
            command <= command + 1;
					if command > x"b4" then
					updown <= '0';
					end if;
				else
				command <= command - 1;
					if command < x"00" then
					updown <= '1';
					end if;
        end if;
		  end if;
		end if;
    end process;
end a;
