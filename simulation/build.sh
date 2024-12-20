#!/bin/bash

# If "clean" is passed as an argument, perform cleanup
if [ "$1" == "clean" ]; then
    rm -f *.o *.elf *_dump.s *.bin *.hex *.coe
    exit 0
fi

# Define the list of source files
SRC_FILES=("Hazard_NOP.S" "noHazard.S")

for SRC in "${SRC_FILES[@]}"; do
    OBJ="${SRC%.S}.o"
    ELF="${SRC%.S}.elf"
    DUMP="${SRC%.S}_dump.s"
    BIN="${SRC%.S}.bin"
    HEX="${SRC%.S}.hex"
    COE="${SRC%.S}.coe"
    HEX_REV="${SRC%.S}_rev.hex" # 用于存储转为大端序的十六进制文件

    # Assemble the source file
    if ! riscv32-unknown-elf-as -o "$OBJ" "$SRC"; then
        echo "Assembly failed for $SRC"
        exit 1
    fi

    # Link the object file
    if ! riscv32-unknown-elf-ld -T linker.ld -o "$ELF" "$OBJ"; then
        echo "Linking failed for $OBJ"
        exit 1
    fi

    # Generate disassembly (optional)
    if ! riscv32-unknown-elf-objdump -S "$ELF" > "$DUMP"; then
        echo "Objdump failed for $ELF"
        exit 1
    fi

    # Generate binary file from ELF
    if ! riscv32-unknown-elf-objcopy -O binary "$ELF" "$BIN"; then
        echo "Binary extraction failed for $ELF"
        exit 1
    fi

    # Convert binary to hexadecimal format, 4 bytes per line
    if ! xxd -p -c 4 "$BIN" > "$HEX"; then
        echo "Hexadecimal conversion failed for $BIN"
        exit 1
    fi

    # Adjust the byte order (convert little-endian to big-endian)
    # Take each 32-bit line, split into bytes, reverse the order, and reassemble
    if ! awk '
    {
        line = $0;
        first = substr(line, 7, 2);  # Byte 4
        second = substr(line, 5, 2); # Byte 3
        third = substr(line, 3, 2);  # Byte 2
        fourth = substr(line, 1, 2); # Byte 1
        printf("%s%s%s%s\n", first, second, third, fourth);
    }' "$HEX" > "$HEX_REV"; then
        echo "Byte order adjustment failed for $HEX"
        exit 1
    fi

    # Format the hexadecimal data as Vivado COE file
    echo "memory_initialization_radix=16;" > "$COE"
    echo "memory_initialization_vector=" >> "$COE"
    sed 's/$/,/' "$HEX_REV" | sed '$ s/,$/;/' >> "$COE"

    echo "Generated $COE from $SRC"
done
