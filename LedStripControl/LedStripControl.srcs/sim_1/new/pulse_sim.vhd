library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity led_strip_controller_tb is
    -- Tesztmodulnak nincs portja.
end led_strip_controller_tb;

architecture Behavioral of led_strip_controller_tb is

    -- Komponens deklarációja
    component led_strip_controller
        Port (
            clk       : in  STD_LOGIC;
            reset     : in  STD_LOGIC;
            start     : in  STD_LOGIC;
            data_in   : in  STD_LOGIC_VECTOR(23 downto 0);
            pulse_out : out STD_LOGIC;
            led_ready : out STD_LOGIC
        );
    end component;

    -- Teszthez szükséges jelek
    signal clk       : STD_LOGIC := '0';
    signal reset     : STD_LOGIC := '0';
    signal start     : STD_LOGIC := '0';
    signal data_in   : STD_LOGIC_VECTOR(23 downto 0) := (others => '0');
    signal pulse_out : STD_LOGIC;
    signal led_ready : STD_LOGIC;

    -- Órajel periódus
    constant clk_period : time := 10 ns;

begin

    -- Órajel generálása
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period;
        clk <= '1';
        wait for clk_period;
    end process;

    -- LED szalag vezérl? példányosítása
    uut: led_strip_controller
        Port map (
            clk       => clk,
            reset     => reset,
            start     => start,
            data_in   => data_in,
            pulse_out => pulse_out,
            led_ready => led_ready
        );

    -- Tesztelési folyamat
    stim_proc: process
    begin
        -- Reset állapot
        reset <= '1';
        wait for clk_period;
        reset <= '0';

        -- Adat küldése és start jel generálása
        wait for clk_period;
        data_in <= "101010101010101010101010";
        wait for clk_period;
        start <= '1';
        wait for clk_period * 5;
        start <= '0';

        -- Várakozás a folyamat befejezésére
        wait for clk_period * 100;
        wait;
    end process;

end Behavioral;
