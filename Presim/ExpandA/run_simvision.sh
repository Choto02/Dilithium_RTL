rm -rf INCA_libs/
source setup_sim
ncverilog  +nctimescale+1ns/10ps +define+KECCEK_ALL_OUT +define+PRESIM -f run_presim.f
