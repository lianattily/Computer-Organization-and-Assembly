module rff(q, d, clk, enable, reset);
    // an edge-triggered flip-flop //
    output q;
    input d, clk, enable, reset;
    reg q;

    always @(posedge reset) //reset every flip-flop to 0 (fixed starting stage)
        q<=1'b0;        //used only to start up, not used after beginning
    
    always @(posedge clk)
        if(enable) q<=d;
endmodule

module rregister(q, d, clk, enable, reset);
    //an edge-trigerred register //
    output q;
    input d, clk, enable, reset;

endmodule