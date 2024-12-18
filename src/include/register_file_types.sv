`ifndef REGISTER_FILE_TYPES_SV
`define REGISTER_FILE_TYPES_SV

typedef logic [31:0] register_t;

typedef union packed {
    struct packed {
        register_t x1;  // Return address
        register_t x2;  // Stack pointer
        register_t x3;  // Global pointer
        register_t x4;  // Thread pointer
        register_t x5;  // Temporary/alternate link register
        register_t x6;  // Temporary registers
        register_t x7;
        register_t x8;  // Saved registers
        register_t x9;
        register_t x10; // Function arguments/return values
        register_t x11;
        register_t x12;
        register_t x13;
        register_t x14;
        register_t x15;
        register_t x16; // Temporary registers
        register_t x17;
        register_t x18; // Saved registers
        register_t x19;
        register_t x20;
        register_t x21;
        register_t x22;
        register_t x23;
        register_t x24;
        register_t x25;
        register_t x26;
        register_t x27;
        register_t x28; // Temporary registers
        register_t x29;
        register_t x30;
        register_t x31;
    } reg_name; // register name

    struct packed {
        register_t ra;  // Return address
        register_t sp;  // Stack pointer
        register_t gp;  // Global pointer
        register_t tp;  // Thread pointer
        register_t t0;  // Temporary/alternate link register
        register_t t1;  // Temporary registers
        register_t t2;
        register_t s0;  // Saved registers
        register_t s1;
        register_t a0;  // Function arguments/return values
        register_t a1;
        register_t a2;
        register_t a3;
        register_t a4;
        register_t a5;
        register_t a6;  // Temporary registers
        register_t a7;
        register_t s2;  // Saved registers
        register_t s3;
        register_t s4;
        register_t s5;
        register_t s6;
        register_t s7;
        register_t s8;
        register_t s9;
        register_t s10;
        register_t s11;
        register_t t3;  // Temporary registers
        register_t t4;
        register_t t5;
        register_t t6;
    } abi; // ABI name

    register_t [1:31] id;  // addressing
} register_file_t;

`endif // REGISTER_FILE_TYPES_SV