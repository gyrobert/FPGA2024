library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity led_strip_controller is
    Port (
        clk       : in  STD_LOGIC;
        reset     : in  STD_LOGIC;
        start     : in  STD_LOGIC;
        data_in   : in  STD_LOGIC_VECTOR(23 downto 0);
        pulse_out : out STD_LOGIC
    );
end led_strip_controller;

architecture Behavioral of led_strip_controller is

    -- Állapotok
    type state_type is (IDLE,INIT, PROCESSING, T0H_STATE,T0H_DONE, T0L_STATE, T0L_DONE, T1H_STATE, T1H_DONE, T1L_STATE,T1L_DONE, BIT_CHECK_STATE, DONE);
    signal current_state, next_state : state_type;
    signal counter, counter_next : integer range 0 to 1600; 
    -- Számlálók és változók
    signal bit_index,bit_index_next : integer range 0 to 23; 
    signal current_bit : std_logic;
    signal led_buffer : std_logic_vector(23 downto 0) := (others => '0'); 
    signal led_out, led_out_next: std_logic;
                          
    constant T0H_MIN : integer := 22;  -- 220ns
    constant T0H_MAX : integer := 38;  -- 380ns
    constant T0L_MIN : integer := 58;  -- 580ns
    constant T0L_MAX : integer := 160; -- 1600ns
    constant T1H_MIN : integer := 58;  -- 580ns
    constant T1H_MAX : integer := 160; -- 1600ns
    constant T1L_MIN : integer := 22;  -- 220ns
    constant T1L_MAX : integer := 42;  -- 420ns
    
begin
   
    reset_state:process(clk, reset)
    begin
        if reset = '1' then
            current_state <= IDLE;
            counter <= 0;
            pulse_out <= '0';
        elsif(clk'event and clk='1') then
            current_state <= next_state;
            counter <= counter_next;
            led_out <= led_out_next;
            current_bit <= led_buffer(bit_index);
        end if;
    end process reset_state;

    
   case_log:process(current_state, start, counter, bit_index, current_bit)
    begin
        case current_state is
            -- IDLE 
            when IDLE =>
                if start = '1' then
                 next_state <= INIT;
                else
                    next_state <= IDLE;
                end if;

            --INIT
            when INIT =>
                bit_index <= 23;
                led_buffer <= data_in;
                next_state <= PROCESSING;

            -- feldolgozas 
            when PROCESSING =>
                    if current_bit = '1' then
                        next_state <= T1H_STATE;
                    elsif current_bit = '0' then
                        next_state <= T0H_STATE;
                    end if;
                   

            --Pulse generalas
            when T0H_STATE =>
                if counter < T0H_MAX then
                    next_state <= T0H_STATE;
                else
                    next_state <= T0L_STATE;
                end if;

            when T0L_STATE =>
                if counter < T0L_MAX then
                    next_state <= T0L_STATE;
                else
                    next_state <= BIT_CHECK_STATE;
                end if;
                
          
            when T1H_STATE =>
                if counter = T1H_MAX then
                    next_state <= T1H_STATE;
                else
                    next_state <= T1H_DONE;
                end if;
            
            when T1H_DONE =>
                next_state <= T1L_STATE;
            
            when T1L_STATE =>
                if counter = T1L_MAX then
                    next_state <= T1L_STATE;
                else
                    next_state <= T1L_DONE;
                end if;          
             
             when T1L_DONE =>
                next_state <= BIT_CHECK_STATE;
                   
             when BIT_CHECK_STATE =>
                if bit_index <= 0 then
                    next_state <= DONE;
                else
                    next_state <= PROCESSING;
                end if;
                  
            -- DONE 
            when DONE =>
                next_state <= IDLE;

            when others =>
                next_state <= IDLE;
        end case;
    end process case_log;
    
    with current_state select
        bit_index_next <= bit_index-1 when BIT_CHECK_STATE,
                          bit_index when others;
              
                       
    with current_state select
        counter_next <= 0 when IDLE,
                        1 when PROCESSING,
                        0 when T0H_DONE,
                        0 when T0L_DONE,
                        0 when T1H_DONE,
                        0 when T1L_DONE,
                        counter+1 when others;
                        
    with current_state select
        led_out_next <= '0' when IDLE,
                        '1' when T0H_STATE,
                        '1' when T1H_STATE,
                        '0' when T0L_STATE,
                        '0' when T1L_STATE,
                        led_out when others;
                      
                            
        
    pulse_out <= led_out;

end Behavioral;




