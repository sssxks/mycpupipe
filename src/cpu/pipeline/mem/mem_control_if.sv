interface mem_control_if;
    logic Jump; // unconditional jump instruction
    logic Branch; // conditional jump instruction
    logic InverseBranch; // 1: invert branch condition, 0: normal branch condition
                         // only vaild when Branch=1

    modport provider(
        output Jump,
        output Branch,
        output InverseBranch
    );

    modport consumer(
        input Jump,
        input Branch,
        input InverseBranch
    );
endinterface //mem_control_if
