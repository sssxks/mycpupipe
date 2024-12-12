if [ ! -d "build" ]; then
    mkdir build
fi
cd build
cmd.exe /mnt/c/Xilinx/Vivado/2024.1/bin/vivado.bat -mode batch -source ../scripts/simulate.tcl