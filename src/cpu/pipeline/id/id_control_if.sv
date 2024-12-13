interface id_control_if;
    logic [2:0] ImmSel; // select signal to immgen. i-type / s-type / sb-type / uj-type
    modport provider (
        output ImmSel
    );

    modport consumer (
        input ImmSel
    );
endinterface //id_control_if
