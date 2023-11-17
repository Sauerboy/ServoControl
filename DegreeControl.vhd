-- HSPG.vhd (hobby servo pulse generator)
-- This starting point generates a pulse between 100 us and something much longer than 2.5 ms.

library IEEE;
library lpm;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use lpm.lpm_components.all;

entity DegreeControl is
    port(
		  COMMAND 	  : in  std_logic_vector(7 downto 0);  -- command sent from SCOMP
        CLOCK       : in  std_logic;
        RESETN      : in  std_logic;
        PULSE       : out std_logic
    );
end DegreeControl;

architecture a of DegreeControl is
	 signal safeCommand : std_logic_vector(7 downto 0);
    signal count   : std_logic_vector(11 downto 0);  -- internal counter

begin

    -- This is a VERY SIMPLE way to generate a pulse.  This is not particularly
    -- flexible and it has some issues.  It works, but you should probably consider ways
    -- to improve this.
    process (RESETN, CLOCK)
    begin
        if (RESETN = '0') then
            count <= x"000";
				PULSE <= '0';
        elsif rising_edge(CLOCK) then
            count <= count + 1;
            if (count >= x"708") then  -- 20 ms has elapsed
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
	 safeCommand <= x"e1" WHEN COMMAND > x"b4" else
						 COMMAND + x"2d";

end a;
