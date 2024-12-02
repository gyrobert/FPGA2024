library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_pulse_fsm is
-- Tesztbencsnek nincs portja
end tb_pulse_fsm;

architecture Behavioral of tb_pulse_fsm is

    -- Komponens deklar�l�sa
    component pulse_fsm
        Port (
            clk       : in  STD_LOGIC;
            reset     : in  STD_LOGIC;
            start     : in  STD_LOGIC;
            data_in   : in  STD_LOGIC_VECTOR(23 downto 0);
            pulse_out : out STD_LOGIC
        );
    end component;

    -- Teszt jelek deklar�l�sa
    signal clk       : STD_LOGIC := '0';
    signal reset     : STD_LOGIC := '0';
    signal start     : STD_LOGIC := '0';
    signal data_in   : STD_LOGIC_VECTOR(23 downto 0) := (others => '0');
    signal pulse_out : STD_LOGIC;

    -- �rajel peri�dusa
    constant CLK_PERIOD : time := 10 ns;

begin
    -- �rajel gener�l�sa
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- Az FSM p�ld�nyos�t�sa
    uut: pulse_fsm
        Port map (
            clk       => clk,
            reset     => reset,
            start     => start,
            data_in   => data_in,
            pulse_out => pulse_out
        );

    -- Tesztjelek �s id?z�t�s
    stimulus : process
    begin
        -- 1. Reset akt�v
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        wait for 20 ns;

        -- 2. Els? adat (24 bites) bead�sa, start jel aktiv�l�sa
        data_in <= "110100110011001100110011"; -- Bemeneti adat
        start <= '1';
        wait for 10 ns;
        start <= '0';

        -- 3. V�rakoz�s az impulzussorozat befejez�s�re
        wait for 50 us; -- El�g id? az FSM lefut�s�ra

        -- 4. M�sodik adat bead�sa
        data_in <= "001101100110110110110110"; -- M�sodik tesztadat
        start <= '1';
        wait for 10 ns;
        start <= '0';

        -- �jabb v�rakoz�s
        wait for 50 us;

        -- Szimul�ci� v�ge
        wait;
    end process;

end Behavioral;
