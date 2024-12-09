library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity led_strip_controller is
    Port (
        clk       : in  STD_LOGIC;
        reset     : in  STD_LOGIC;
        start     : in  STD_LOGIC;
        data_in   : in  STD_LOGIC_VECTOR(23 downto 0);
        pulse_out : out STD_LOGIC;
        led_ready : out STD_LOGIC
    );
end led_strip_controller;

architecture Behavioral of led_strip_controller is

    -- �llapotok
    type state_type is (IDLE, INIT, CLEAR_LEDS, ANIMATE, PROCESSING, T0H_STATE, T0L_STATE, T1H_STATE, T1L_STATE, DONE);
    signal current_state, next_state : state_type := IDLE;

    -- Sz�ml�l�k �s v�ltoz�k
    signal bit_index : integer range 0 to 23 := 23; -- aktu�lis bit indexe
    signal counter : integer range 0 to 1600 := 0; -- id?z�t? sz�ml�l�
    signal current_bit : std_logic; -- aktu�lis bit �rt�ke
    signal pulse_reg : std_logic := '0'; -- pulse_out regiszter
    signal led_buffer : std_logic_vector(23 downto 0) := (others => '0'); -- LED adatok

    -- Id?z�t�si �lland�k
    constant T0H_MIN : integer := 22;  -- 220ns
    constant T0H_MAX : integer := 38;  -- 380ns
    constant T0L_MIN : integer := 58;  -- 580ns
    constant T0L_MAX : integer := 160; -- 1600ns
    constant T1H_MIN : integer := 58;  -- 580ns
    constant T1H_MAX : integer := 160; -- 1600ns
    constant T1L_MIN : integer := 22;  -- 220ns
    constant T1L_MAX : integer := 42;  -- 420ns

begin
    -- �llapotg�p regiszter
    process(clk, reset)
    begin
        if reset = '1' then
            current_state <= IDLE;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;

    -- �llapotg�p logika
    process(current_state, start, counter, bit_index, current_bit)
    begin
        -- Alap�rt�kek
        next_state <= current_state;
        pulse_reg <= '0';
        led_ready <= '0';

        case current_state is
            -- IDLE �llapot: v�rakoz�s az ind�t�sra
            when IDLE =>
                if start = '1' then
                    next_state <= INIT;
                end if;

            -- INIT �llapot: NeoLED vez�rl? inicializ�l�sa
            when INIT =>
                if start = '1' then
                    next_state <= CLEAR_LEDS;
                end if;

            -- CLEAR_LEDS �llapot: �sszes LED kikapcsol�sa
            when CLEAR_LEDS =>
                led_buffer <= (others => '0'); -- Minden LED t�rl�se
                next_state <= ANIMATE;

            -- ANIMATE �llapot: LED adatok kisz�m�t�sa
            when ANIMATE =>
                led_buffer <= std_logic_vector(to_unsigned(23, 24)); -- Dummy anim�ci� adat
                next_state <= PROCESSING;

            -- PROCESSING �llapot: bitenk�nti pulzus-gener�l�s el?k�sz�t�se
            when PROCESSING =>
                if bit_index = 0 then
                    next_state <= DONE;
                else
                    current_bit <= led_buffer(bit_index);
                    if current_bit = '1' then
                        next_state <= T1H_STATE;
                    else
                        next_state <= T0H_STATE;
                    end if;
                    bit_index <= bit_index - 1;
                    counter <= 0;
                end if;

            -- Pulzusok gener�l�sa az id?z�t�sek alapj�n
            when T0H_STATE =>
                pulse_reg <= '1';
                if counter >= T0H_MAX then
                    next_state <= T0L_STATE;
                    counter <= 0;
                else
                    counter <= counter + 1;
                end if;

            when T0L_STATE =>
                pulse_reg <= '0';
                if counter >= T0L_MAX then
                    next_state <= PROCESSING;
                    counter <= 0;
                else
                    counter <= counter + 1;
                end if;

            when T1H_STATE =>
                pulse_reg <= '1';
                if counter >= T1H_MAX then
                    next_state <= T1L_STATE;
                    counter <= 0;
                else
                    counter <= counter + 1;
                end if;

            when T1L_STATE =>
                pulse_reg <= '0';
                if counter >= T1L_MAX then
                    next_state <= PROCESSING;
                    counter <= 0;
                else
                    counter <= counter + 1;
                end if;

            -- DONE �llapot: Anim�ci� v�ge, vissza IDLE-be
            when DONE =>
                led_ready <= '1';
                next_state <= IDLE;

            when others =>
                next_state <= IDLE;
        end case;
    end process;

    pulse_out <= pulse_reg;

end Behavioral;


