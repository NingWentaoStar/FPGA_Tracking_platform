-- Created by IP Generator (Version 2020.3-Lite build 71107)
-- Instantiation Template
--
-- Insert the following codes into your VHDL file.
--   * Change the_instance_name to your own instance name.
--   * Change the net names in the port map.


COMPONENT MA_stage0
  PORT (
    a : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
    b : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
    acc_init : IN STD_LOGIC_VECTOR(95 DOWNTO 0);
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    ce : IN STD_LOGIC;
    reload : IN STD_LOGIC;
    p : OUT STD_LOGIC_VECTOR(95 DOWNTO 0)
  );
END COMPONENT;


the_instance_name : MA_stage0
  PORT MAP (
    a => a,
    b => b,
    acc_init => acc_init,
    clk => clk,
    rst => rst,
    ce => ce,
    reload => reload,
    p => p
  );
