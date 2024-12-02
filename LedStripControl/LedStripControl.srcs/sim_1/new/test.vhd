library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_pulse_generator is
end tb_pulse_generator;

architecture sim of tb_pulse_generator is
    -- Komponens be�gyaz�sa, amit tesztel�nk
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
    end process clk_process;

    -- Az egys�g be�gyaz�sa, amelyet tesztel�nk
    uut: pulse_generator
        Port map (
            clk       => clk,
            reset     => reset,
            data_in   => data_in,
            start     => start,
            pulse_out => pulse_out
        );

    -- Szimul�ci�s folyamat
    stimulus : process
    begin
        -- 1. Reset jel be�ll�t�sa
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        wait for 20 ns;

        -- 2. Els? adat bemenet �s start jel aktiv�l�sa
        data_in <= "110100110011001100110011"; -- teszt adat 24 biten
        start <= '1';
        wait for 10 ns;
        start <= '0';

        -- V�rakoz�s a jelsorozat gener�l�s�ra
        wait for 50 us;  -- elegend? id?t biztos�tunk az impulzussorozat v�gigfut�s�hoz

        -- 3. M�sodik adat bemenet �s start jel aktiv�l�sa
        data_in <= "001101100110110110110110"; -- �jabb teszt adat
        start <= '1';
        wait for 10 ns;
        start <= '0';

        -- �jabb v�rakoz�s az impulzussorozat befejez�s�re
        wait for 50 us;

        -- Szimul�ci� le�ll�t�sa
        wait;
    end process stimulus;

end sim;
