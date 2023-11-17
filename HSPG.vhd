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

    signal command : std_logic_vector(7 downto 0);  -- command sent from SCOMP
	 signal degreeCommand : std_logic_vector(7 downto 0);  -- command sent from SCOMP
    signal count   : std_logic_vector(11 downto 0);  -- internal counter
	 signal mode : std_logic;

begin

    -- Latch data on rising edge of CS
    process (RESETN, CS) begin
        if RESETN = '0' then
            command <= x"00";
        elsif IO_WRITE = '1' and rising_edge(CS) then
            command <= IO_DATA(8 downto 1);
				mode <= IO_DATA(0);
        end if;
    end process;
	 
	 process (CLOCK)
	 begin
	 case mode is
		when '0' => degreeCommand <= command;
		when '1' => 
		if rising_edge(Clock) then
			degreeCommand <= degreeCommand + 1;
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
