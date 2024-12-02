library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_pulse_generator is
end tb_pulse_generator;

architecture sim of tb_pulse_generator is
    -- Komponens beágyazása, amit tesztelünk
    component pulse_generator
        Port (
            clk       : in  STD_LOGIC;
            reset     : in  STD_LOGIC;
            data_in   : in  STD_LOGIC_VECTOR(23 downto 0);
            start     : in  STD_LOGIC;
            pulse_out : out STD_LOGIC
        );
    end component;

    -- Bels? jelek
    signal clk       : STD_LOGIC := '0';
    signal reset     : STD_LOGIC := '0';
    signal data_in   : STD_LOGIC_VECTOR(23 downto 0);
    signal start     : STD_LOGIC := '0';
    signal pulse_out : STD_LOGIC;

    -- Órajel periódusa
    constant CLK_PERIOD : time := 10 ns;

begin
    -- Órajel generálása
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process clk_process;

    -- Az egység beágyazása, amelyet tesztelünk
    uut: pulse_generator
        Port map (
            clk       => clk,
            reset     => reset,
            data_in   => data_in,
            start     => start,
            pulse_out => pulse_out
        );

    -- Szimulációs folyamat
    stimulus : process
    begin
        -- 1. Reset jel beállítása
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        wait for 20 ns;

        -- 2. Els? adat bemenet és start jel aktiválása
        data_in <= "110100110011001100110011"; -- teszt adat 24 biten
        start <= '1';
        wait for 10 ns;
        start <= '0';

        -- Várakozás a jelsorozat generálására
        wait for 50 us;  -- elegend? id?t biztosítunk az impulzussorozat végigfutásához

        -- 3. Második adat bemenet és start jel aktiválása
        data_in <= "001101100110110110110110"; -- újabb teszt adat
        start <= '1';
        wait for 10 ns;
        start <= '0';

        -- Újabb várakozás az impulzussorozat befejezésére
        wait for 50 us;

        -- Szimuláció leállítása
        wait;
    end process stimulus;

end sim;
