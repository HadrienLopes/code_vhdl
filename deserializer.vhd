library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity deserializer is
    generic (
        --Largeur des data
        DATA_WIDTH : integer := 8
    );
    port (
        clk    : in  std_logic;
        rst_n  : in  std_logic;
        rx     : in  std_logic;
        ack    : in  std_logic;
        valid  : out std_logic;
        data   : out std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
end deserializer;

architecture state_machine of deserializer is
    type deserializer_state IS (idle, wait_for_start, receive_bits, finalize);
    signal state  : deserializer_state := idle;
    signal buff   : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal count  : natural range 0 to DATA_WIDTH := 0;
    signal rx_sync : std_logic := '0';

begin
    -- Synchro dw rx
    process(clk, rst_n)
    begin
        if rst_n = '1' then
            rx_sync <= '0';
        elsif rising_edge(clk) then
            rx_sync <= rx;
        end if;
    end process;

    process(clk, rst_n)
    begin
        if rst_n = '1' then
            state <= idle;
            buff <= (others => '0');
            count <= 0;
            valid <= '0';
            data <= (others => '0');
        else
            if rising_edge(clk) then
                case state is
                    when idle =>
                        valid <= '0';
                        if rx_sync = '1' then
                            state <= wait_for_start;
                            count <= 0;
                        end if;

                    when wait_for_start =>
                        -- Pause d'horloge avant de start data reading phase
                        state <= receive_bits;

                    when receive_bits =>
                        if count < DATA_WIDTH then
                            buff(count) <= rx_sync;
                            count <= count + 1;
                        else
                            state <= finalize;
                        end if;

                    when finalize =>
                        valid <= '1';
                        data <= buff;
                        if ack = '1' then
                            valid <= '0';
                            state <= idle;
                        end if;

                    when others =>
                        state <= idle;
                end case; -- state
            end if; -- clock
        end if; -- reset
    end process;

end state_machine;
