library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_pulse_fsm is
-- Tesztbencsnek nincs portja
end tb_pulse_fsm;

architecture Behavioral of tb_pulse_fsm is

    -- Komponens deklarálása
    component pulse_fsm
        Port (
            clk       : in  STD_LOGIC;
            reset     : in  STD_LOGIC;
            start     : in  STD_LOGIC;
            data_in   : in  STD_LOGIC_VECTOR(23 downto 0);
            pulse_out : out STD_LOGIC
        );
    end component;

    -- Teszt jelek deklarálása
    signal clk       : STD_LOGIC := '0';
    signal reset     : STD_LOGIC := '0';
    signal start     : STD_LOGIC := '0';
    signal data_in   : STD_LOGIC_VECTOR(23 downto 0) := (others => '0');
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
    end process;

    -- Az FSM példányosítása
    uut: pulse_fsm
        Port map (
            clk       => clk,
            reset     => reset,
            start     => start,
            data_in   => data_in,
            pulse_out => pulse_out
        );

    -- Tesztjelek és id?zítés
    stimulus : process
    begin
        -- 1. Reset aktív
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        wait for 20 ns;

        -- 2. Els? adat (24 bites) beadása, start jel aktiválása
        data_in <= "110100110011001100110011"; -- Bemeneti adat
        start <= '1';
        wait for 10 ns;
        start <= '0';

        -- 3. Várakozás az impulzussorozat befejezésére
        wait for 50 us; -- Elég id? az FSM lefutására

        -- 4. Második adat beadása
        data_in <= "001101100110110110110110"; -- Második tesztadat
        start <= '1';
        wait for 10 ns;
        start <= '0';

        -- Újabb várakozás
        wait for 50 us;

        -- Szimuláció vége
        wait;
    end process;

end Behavioral;
