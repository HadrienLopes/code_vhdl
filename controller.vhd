library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity controller is
    generic (
        -- Largeur des data
        DATA_WIDTH : integer := 8
    );
    port (
        clk      : in  std_logic;
        rst_n    : in  std_logic;

        rx_data  : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        rx_valid : in std_logic;
        rx_ack   : out std_logic;

        tx_ack   : in std_logic;
        tx_valid : out std_logic;
        tx_data  : out std_logic_vector(DATA_WIDTH - 1 downto 0);
        
        empty    : in  std_logic;
        full     : in  std_logic;
        din      : in  std_logic_vector(DATA_WIDTH - 1 downto 0);

        push     : out std_logic;
        pop      : out std_logic;
        dout     : out  std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
end controller;

architecture behavior of controller is
  
    signal command      : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal flag_push    : std_logic := '0';
    signal flag_pop     : std_logic := '0';
    signal fifo_full    : std_logic := '0';
    signal fifo_empty   : std_logic := '1';
    
    signal status       : std_logic_vector(DATA_WIDTH - 1 downto 0);
    
    constant CMD_PUSH   : std_logic_vector(DATA_WIDTH - 1 downto 0) := "00000001"; -- "00000001";
    constant CMD_POP    : std_logic_vector(DATA_WIDTH - 1 downto 0) := "00000010";
    constant CMD_STATUS : std_logic_vector(DATA_WIDTH - 1 downto 0) := "00000100";
    
begin
    process(clk, rst_n)
    begin
        if rst_n = '1' then
            command <= (others => '0');
            flag_push <= '0';
            flag_pop <= '0';
            fifo_full <= '0';
            fifo_empty <= '1';
            push <= '0';
            pop <= '0';
            dout <= (others => '0');
            rx_ack <= '0';
            tx_valid <= '0';
            tx_data <= (others => '0');
            status <= (others => '0');
            
        elsif rising_edge(clk) then
            -- Gestions des trames sur Tx/Rx
            if rx_valid = '1' then
                command <= rx_data;
                rx_ack <= '1';
            else
                rx_ack <= '0';
            end if;
            if flag_push = '1' then
                dout <= rx_data;
                flag_push <= '0';
            end if;
            
            if tx_ack = '1' then
                tx_valid <= '0';
            end if;
            if flag_pop = '1' then
                tx_data <= din;
                tx_valid <= '1';
                flag_pop <= '0';
            end if;

            -- Comparaison des commandes
            if command = CMD_PUSH then
                flag_push <= '1';
                if fifo_full = '0' then
                    push <= '1';
                else
                    push <= '0';
                end if;
            elsif command = CMD_POP then
                flag_pop <= '1';
                if fifo_empty = '0' then
                    pop <= '1';
                else
                    pop <= '0';
                end if;
            elsif command = CMD_STATUS then
                status <= "000" & fifo_full & "000" & fifo_empty;
                flag_pop <= '1';
            else
                push <= '0';
                pop <= '0';
            end if;
            
        end if;
    end process;
end behavior;

