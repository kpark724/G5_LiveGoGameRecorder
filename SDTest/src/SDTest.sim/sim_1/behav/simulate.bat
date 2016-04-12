@echo off
set xv_path=C:\\Xilinx\\Vivado\\2015.4\\bin
call %xv_path%/xsim sd_tb_behav -key {Behavioral:sim_1:Functional:sd_tb} -tclbatch sd_tb.tcl -view C:/Users/Jesse/XilinxProjects/SDTest/sd_tb_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
