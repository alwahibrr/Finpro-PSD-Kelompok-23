library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Hotel_Management_System is
    Generic (
        FLOORS    : integer := 5;
        ROOMS_PER_FLOOR : integer := 10;
        DAY_COUNTER_WIDTH : integer := 3
    );
    Port (
        clk          : in  STD_LOGIC;
        reset        : in  STD_LOGIC;
        manual_clean_request : in  STD_LOGIC;
        emergency_lock_all   : in  STD_LOGIC;
        room_floor   : in  INTEGER range 0 to FLOORS-1;
        room_number  : in  INTEGER range 0 to ROOMS_PER_FLOOR-1;
        pin_input    : in  STD_LOGIC_VECTOR(15 downto 0);
        access_request : in  STD_LOGIC;
        lock_request : in  STD_LOGIC;
        unlock_request : in  STD_LOGIC;
        access_granted : out STD_LOGIC;
        current_time_of_day : out STD_LOGIC_VECTOR(1 downto 0);
        current_day    : out STD_LOGIC_VECTOR(DAY_COUNTER_WIDTH-1 downto 0);
        room_status    : out STD_LOGIC_VECTOR(7 downto 0)
    );
end Hotel_Management_System;

architecture Behavioral of Hotel_Management_System is

    constant TOTAL_ROOMS : integer := FLOORS * ROOMS_PER_FLOOR;
    
    type TIME_OF_DAY is (MORNING, NOON, AFTERNOON, NIGHT);
    signal current_time : TIME_OF_DAY := MORNING;
    
    type DAY_OF_WEEK is (SUNDAY, MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY);
    signal current_day_signal : DAY_OF_WEEK := SUNDAY;
    
    type ROOM_RECORD is record
        room_id      : STD_LOGIC_VECTOR(15 downto 0);
        is_occupied  : STD_LOGIC;
        is_locked    : STD_LOGIC;
        needs_cleaning : STD_LOGIC;
        is_being_cleaned : STD_LOGIC;
        pin_code     : STD_LOGIC_VECTOR(15 downto 0);
    end record;
    
    type ROOM_MATRIX is array (0 to FLOORS-1, 0 to ROOMS_PER_FLOOR-1) of ROOM_RECORD;
    signal hotel_rooms : ROOM_MATRIX;
    
    signal time_counter : INTEGER range 0 to 24999999 := 0; 
    signal day_counter  : INTEGER range 0 to 6 := 0;
    signal time_tick    : STD_LOGIC := '0';
    
    type SYSTEM_STATE is (IDLE, CHECK_ACCESS, LOCK_ROOM, UNLOCK_ROOM);
    signal state : SYSTEM_STATE := IDLE;
    
    signal reversed_pin  : STD_LOGIC_VECTOR(15 downto 0);
    
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                time_counter <= 0;
                time_tick <= '0';
                current_time <= MORNING;
                current_day_signal <= SUNDAY;
                day_counter <= 0;
            else
                if time_counter = 4 then 
                    time_counter <= 0;
                    time_tick <= '1';
                    
                    case current_time is
                        when MORNING => current_time <= NOON;
                        when NOON => current_time <= AFTERNOON;
                        when AFTERNOON => current_time <= NIGHT;
                        when NIGHT => 
                            current_time <= MORNING;
                            if day_counter = 6 then
                                day_counter <= 0;
                            else
                                day_counter <= day_counter + 1;
                            end if;
                    end case;
                else
                    time_counter <= time_counter + 1;
                    time_tick <= '0';
                end if;
                
                case day_counter is
                    when 0 => current_day_signal <= SUNDAY;
                    when 1 => current_day_signal <= MONDAY;
                    when 2 => current_day_signal <= TUESDAY;
                    when 3 => current_day_signal <= WEDNESDAY;
                    when 4 => current_day_signal <= THURSDAY;
                    when 5 => current_day_signal <= FRIDAY;
                    when 6 => current_day_signal <= SATURDAY;
                    when others => null;
                end case;
            end if;
        end if;
    end process;

    process(clk)
        variable room_id_base : INTEGER;
        variable room_id_vec  : STD_LOGIC_VECTOR(15 downto 0);
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state <= IDLE;
                access_granted <= '0';
                
                for i in 0 to FLOORS-1 loop
                    for j in 0 to ROOMS_PER_FLOOR-1 loop
                        room_id_base := i * 100 + j;
                        room_id_vec := STD_LOGIC_VECTOR(TO_UNSIGNED(room_id_base, 16));
                        hotel_rooms(i, j).room_id <= room_id_vec;
                        for k in 0 to 15 loop
                            hotel_rooms(i, j).pin_code(k) <= room_id_vec(15 - k);
                        end loop;
                        
                        hotel_rooms(i, j).is_occupied <= '0';
                        hotel_rooms(i, j).is_locked <= '1'; 
                        hotel_rooms(i, j).needs_cleaning <= '0';
                        hotel_rooms(i, j).is_being_cleaned <= '0';
                    end loop;
                end loop;
                
            else
                case state is
                    when IDLE =>
                        access_granted <= '0';
                        if access_request = '1' or lock_request = '1' or unlock_request = '1' then
                            state <= CHECK_ACCESS;
                            for k in 0 to 15 loop
                                reversed_pin(k) <= hotel_rooms(room_floor, room_number).room_id(15 - k);
                            end loop;
                        end if;
                        
                    when CHECK_ACCESS =>
                        if pin_input = reversed_pin then
                            if lock_request = '1' then
                                state <= LOCK_ROOM;
                            elsif unlock_request = '1' then
                                state <= UNLOCK_ROOM;
                            else
                                access_granted <= '1';
                                state <= IDLE;
                            end if;
                        else
                            access_granted <= '0';
                            state <= IDLE;
                        end if;
                        
                    when LOCK_ROOM =>
                        hotel_rooms(room_floor, room_number).is_locked <= '1';
                        state <= IDLE;
                        
                    when UNLOCK_ROOM =>
                        hotel_rooms(room_floor, room_number).is_locked <= '0';
                        state <= IDLE;
                        
                    when others =>
                        state <= IDLE;
                end case;

                if time_tick = '1' then
                    if current_time = NIGHT then
                         for i in 0 to FLOORS-1 loop
                            for j in 0 to ROOMS_PER_FLOOR-1 loop
                                hotel_rooms(i, j).is_locked <= '1';
                            end loop;
                        end loop;
                    end if;
                    
                    if (current_day_signal = WEDNESDAY or current_day_signal = SATURDAY) and current_time = MORNING then
                        for i in 0 to FLOORS-1 loop
                            for j in 0 to ROOMS_PER_FLOOR-1 loop
                                hotel_rooms(i, j).is_being_cleaned <= '1';
                                hotel_rooms(i, j).needs_cleaning <= '0';
                            end loop;
                        end loop;
                    elsif (current_day_signal = WEDNESDAY or current_day_signal = SATURDAY) and current_time = NOON then
                        for i in 0 to FLOORS-1 loop
                            for j in 0 to ROOMS_PER_FLOOR-1 loop
                                hotel_rooms(i, j).is_being_cleaned <= '0';
                            end loop;
                        end loop;
                    end if;
                    
                    if manual_clean_request = '1' then
                        for i in 0 to FLOORS-1 loop
                            for j in 0 to ROOMS_PER_FLOOR-1 loop
                                hotel_rooms(i, j).needs_cleaning <= '1';
                            end loop;
                        end loop;
                    end if;
                end if;

                if emergency_lock_all = '1' then
                    for i in 0 to FLOORS-1 loop
                        for j in 0 to ROOMS_PER_FLOOR-1 loop
                            hotel_rooms(i, j).is_locked <= '1';
                        end loop;
                    end loop;
                end if;

            end if;
        end if;
    end process;

    process(current_time, current_day_signal, hotel_rooms, room_floor, room_number)
    begin
        case current_time is
            when MORNING => current_time_of_day <= "00";
            when NOON => current_time_of_day <= "01";
            when AFTERNOON => current_time_of_day <= "10";
            when NIGHT => current_time_of_day <= "11";
        end case;
        
        case current_day_signal is
            when SUNDAY => current_day <= "000";
            when MONDAY => current_day <= "001";
            when TUESDAY => current_day <= "010";
            when WEDNESDAY => current_day <= "011";
            when THURSDAY => current_day <= "100";
            when FRIDAY => current_day <= "101";
            when SATURDAY => current_day <= "110";
        end case;
        
        room_status(0) <= hotel_rooms(room_floor, room_number).is_occupied;
        room_status(1) <= hotel_rooms(room_floor, room_number).is_locked;
        room_status(2) <= hotel_rooms(room_floor, room_number).needs_cleaning;
        room_status(3) <= hotel_rooms(room_floor, room_number).is_being_cleaned;
        room_status(7 downto 4) <= "0000";
    end process;

end Behavioral;