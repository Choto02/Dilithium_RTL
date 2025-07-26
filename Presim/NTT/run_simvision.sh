rm -rf INCA_libs/
source setup_sim
xmverilog +access+r +xmtimescale+1ns/1ps +define+KECCEK_ALL_OUT +define+PRESIM -f run_presim.f
