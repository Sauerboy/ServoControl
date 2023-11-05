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
        PULSE       : out std_logic;
		  safeCommand_out : out std_logic_vector(7 downto 0);
		  count_out   : out std_logic_vector(7 downto 0)  -- internal counter
    );
end HSPG;

architecture a of HSPG is

    signal command : std_logic_vector(7 downto 0);  -- command sent from SCOMP
	 signal safeCommand : std_logic_vector(7 downto 0);
	 signal count   : std_logic_vector(7 downto 0) := "11000110";  -- internal counter strt at c6 to get rid of empty period

begin

    -- Latch data on rising edge of CS
    process (RESETN, CS) begin
        if RESETN = '0' then
            command <= x"00";
        elsif IO_WRITE = '1' and rising_edge(CS) then
            command <= IO_DATA(7 downto 0);
        end if;
    end process;

    -- This is a VERY SIMPLE way to generate a pulse.  This is not particularly
    -- flexible and it has some issues.  It works, but you should probably consider ways
    -- to improve this.
    process (RESETN, CLOCK)
    begin
        if (RESETN = '0') then
            count <= x"c6";
				pulse <= '0';
        elsif rising_edge(CLOCK) then
            count <= count + 1;
            if (count = x"c7") then  -- 20 ms has elapsed
                -- Reset the counter and set the output high.
                count <= x"00";
					 PULSE <= '1';
            elsif count = safeCommand then
                -- Once the count reaches the command value, set the output low.
                -- This will make larger command values produce longer pulses.
                PULSE <= '0';
            end if;
        end if;
    end process;
	 safeCommand <= x"18" WHEN command > x"14" else
						 command + x"04";
	 safeCommand_out <= safeCommand;
	 count_out <= count;

end a;
