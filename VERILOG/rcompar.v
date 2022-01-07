  //Lian Attily | LAB L | November 12th | Implement a comparator
  module comparebase(a,b, Gr, Eq);
    input a,b;                           
    output Gr,Eq;                            
    assign Eq=(a&b) | (~a&~b);              
    assign Gr=a&~b;                         
  endmodule

module comparestage(GR, EQ, Gr, Eq);    //input GR, EQ, output Gr, Eq
  parameter WIDTH=2;
  output GR, EQ;                           
  input wire[WIDTH-1:0] Gr,Eq;
  wire [1:0] rGr, rEq;    
  generate            //used for loops and conditions
    if(WIDTH===2)begin 
      assign EQ= Eq[1] & Eq[0];              
      assign GR= Gr[1] | (Eq[1] & Gr[0]);   //identical to stage 2 of Lab K
    end
    else begin    //binary recursion (2 recursive calls)
      comparestage #(.WIDTH(WIDTH/2))lower(rGr[0], rEq[0], Gr[WIDTH/2-1:0],Eq[WIDTH/2-1:0]); 
      comparestage #(.WIDTH(WIDTH/2))upper(rGr[1], rEq[1], Gr[WIDTH-1:WIDTH/2],Eq[WIDTH-1:WIDTH/2]); 
      assign EQ = rEq[1] & rEq[0];               //similar to base case
      assign GR = rGr[1] | (rEq[1] & rGr[0]);  
    end
  endgenerate
endmodule


module labL;
  parameter WIDTH=4;
  integer i, j;
  reg [WIDTH-1:0]a,b;                          
  reg expectG,expectE;                
  output [WIDTH-1:0] Gr,Eq; 

  comparebase compar[WIDTH-1:0] (a,b, Gr, Eq);
  comparestage #(.WIDTH(WIDTH))mine(GR, EQ, Gr,Eq);
  //equiv: comparestage #(WIDTH) mine(GR,EQ, Gr, Eq);

  initial
  begin
      for (i = 0; i < 2**WIDTH; i = i + 1)    //2**WIDTH = 2^WIDTH (but ^ is XOR in verilog)
      begin
          for (j = 0; j < 2**WIDTH; j = j + 1)
          begin
              a = i; b = j; 
              expectG=(a>b);
              expectE=(a==b); 
              #1  //wait
              if(expectG===GR && expectE==EQ) 
                  $display("PASS a=%b b=%b -> Gr=%b, Eq=%b", a, b, GR, EQ);
              else 
                  $display("FAIL a=%b b=%b -> Gr=%b, Eq=%b", a, b, GR, EQ);
          end
      end
  #1    
  $finish;
  end
endmodule