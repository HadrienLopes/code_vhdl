library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity serializer is
    generic (
        -- Largeur des data
        DATA_WIDTH : integer := 8
    );
    port (
        clk    : in  std_logic;
        rst_n  : in  std_logic;
        valid  : in std_logic;
        data   : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        ack    : out  std_logic;
        tx     : out  std_logic
    );
end serializer;

architecture state_machine of serializer is
    type serializer_state IS (idle, load_data, transmit_bit, complete);
    signal state  : serializer_state := idle;
    signal buff   : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal count  : natural range 0 to DATA_WIDTH := 0;
    signal valid_sync : std_logic := '0';

begin
    -- Synchr de valid
    process(clk, rst_n)
    begin
        if rst_n = '1' then
            valid_sync <= '0';
        elsif rising_edge(clk) then
            valid_sync <= valid;
        end if;
    end process;

    process(clk, rst_n)
    begin
        if rst_n = '1' then
            state <= idle;
            buff <= (others => '0');
            count <= 0;
            ack <= '0';
            tx <= '0';
        else
            if rising_edge(clk) then
                case state is
                    when idle =>
                        ack <= '1';
                        tx <= '0';
                        if valid_sync = '1' then
                            state <= load_data;
                        end if;

                    when load_data =>
                        buff <= data;
                        ack <= '0';
                        count <= 0;
                        state <= transmit_bit;

                    when transmit_bit =>
                        if count < DATA_WIDTH then
                            tx <= buff(count);
                            count <= count + 1;
                        else
                            state <= complete;
                        end if;

                    when complete =>
                        ack <= '1';
                        state <= idle;

                    when others =>
                        state <= idle;
                end case; -- state
            end if; -- clock
        end if; -- reset
    end process;

end state_machine;

