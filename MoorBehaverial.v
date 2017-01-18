module Moore_mdl (CLK , R , B , A , A_Traffic,B_Traffic,second ,A_Light,B_Light);
  input CLK;
  output [6:0] second;
  reg [6:0] endC = 7'b1011010;
  input A_Traffic,B_Traffic,A,B,R;
  output reg A_Light = 1'b1 ; 
  output reg B_Light = 1'b0;
  reg load = 1'b0 ; 
  reg enable = 1'b1 ; 
  wire FlagA , FlagB ; 
  trafficSet tr(  A_Traffic   ,   B_Traffic   , FlagA , FlagB , CLK , A_Light , B_Light);
  counter coun (7'b0000000,second,CLK,load, enable ,endC);
  parameter S0 = 3'b000, S1 = 3'b001, S2 = 3'b010, S3 = 3'b011, S4 = 3'b100, S5 = 3'b101;
  reg [2:0] state = S0 ;   
  always @ (posedge CLK)begin 
    load = 1'b0 ;
  #2 if(R==1'b1)begin 
      state = S0;  
      A_Light=1'b1 ;
      B_Light=1'b0 ;
      load = 1'b1 ; 
      endC = 7'b1011010 ; 
      enable = 1'b1  ;  
    end
    else begin 
      if(A==1'b1)begin
        state=S3;
        A_Light=1'b1;
        B_Light=1'b0;
        load =1'b1 ;
        enable = 1'b0 ;
      end 
      else begin 
        if(B==1'b1)begin
          state=S4;
          A_Light=1'b0;
          B_Light=1'b1;
          load =1'b1 ; 
          enable =1'b0 ; 
        end
        else begin 
          case (state)
            S0: if ((second == 7'b1011010 )|(FlagA == 1'b1))begin 
                  endC = 7'b0000101 ;
                  enable = 1'b1  ; 
                  state = S1;
                  load =1'b1 ;
                  A_Light=1'b0;
                  B_Light=1'b0;  
                end
            S1: if (second == 7'b0000101)  begin
                  endC = 7'b0011110 ;
                  enable = 1'b1  ;  
                  state = S2;
                  load =1'b1 ;
                  A_Light=1'b0;
                  B_Light=1'b1;  
                end  
            S2: if (second == 7'b0011110 | FlagB ==1'b1) begin 
                  state = S5;
                  endC = 7'b0000101 ;
                  enable = 1'b1  ; 
                  load =1'b1 ;
                  A_Light=1'b0;
                  B_Light=1'b0;
                end
            S5: if (second == 7'b0000101) begin
                  state = S0;
                  endC = 7'b1011010 ;
                  enable = 1'b1  ; 
                  load =1'b1 ;
                  A_Light=1'b1;
                  B_Light=1'b0; 
                end
          endcase
       end 
     end 
    end
  end
endmodule
module trafficSet (  A_Traffic   ,   B_Traffic   , FlagA , FlagB , clk , A_Light , B_Light); 
 input   A_Traffic   ,  B_Traffic , clk  , A_Light , B_Light; 
 output  FlagA , FlagB  ; 
 trafficCounter t1(A_Traffic , FlagA , clk , A_Light) ;
 trafficCounter t2 (B_Traffic , FlagB , clk , B_Light) ;
 
endmodule 
 
module trafficCounter (Traffic   , Flag , clk , Light ) ; 
 input   Traffic   , clk  , Light; 
 output reg Flag;
 reg [3:0]F = 3'b000 ;  
 always @(posedge clk) begin 
#2 if( (Traffic == 1'b0)&& (Light == 1'b1) )begin
    F = F + 1'b1 ; 
  end
  else 
    F = 3'b000 ; 
  if(F == 3'b101 ) begin
    Flag = 1'b1 ; 
    F= 3'b000 ;
  end 
  else 
    Flag = 1'b0 ; 
end
     
endmodule
module counter(I,second,clk,load,enable,endC);
  input [6:0] I ; 
  input [6:0] endC;
  input clk ,enable;
  input  load ; 
  output [6:0] second;
  reg [6:0] second;
  reg funcLoad = 1'b1 ;  
  reg firstRun = 1'b1  ; 
  always @(posedge clk) begin 
#4 if( enable == 1'b1) begin
  
    if( (endC==second)|(load== 1'b1) )
      assign funcLoad= 1'b1;
    else
      assign funcLoad= 1'b0;
    if(firstRun == 1'b1 ) begin
      assign firstRun = 1'b0 ;
      assign funcLoad =1'b1 ; 
      end
    if ((load== 1'b1) | (funcLoad == 1'b1))
      assign second=I;
    else 
      assign second= second+1'b1 ;
  end 
  end 
endmodule   

module binaryToBcd ( binary , tens , ones , clk ) ;
  
  input [7:0] binary ; 
  input clk;
  output [3:0] ones ; 
  output  [3 :0  ] tens ;
  reg [3:0] ones ;
  reg [3:0] tens;
  
  integer i ;
  
  always @(posedge clk or binary)
  begin 
    if  (  binary == 8'b11111111)
      begin
	  ones = 4'b1111;
	  tens = 4'b1111;
	  end
	  else 
	  begin
			ones = 4'd0;
			tens = 4'd0;
    
			for ( i = 7 ; i>=0; i = i-1)
    
			begin
      
			if( tens >= 5)
        
				tens = tens + 3;
				if ( ones >= 5)

				ones = ones + 3; 
          
				tens = tens << 1;
				tens[0] = ones[3];
				ones = ones << 1;
				ones [0] = binary[i];
			end
		end
	end
endmodule
    
      
module testproject ; 
  reg CLK;
  wire [6:0] second ; 
  reg A = 1'b0; 
  reg B= 1'b0; 
  reg R = 1'b0 ; 
  reg A_Traffic =1'b0 ; 
  reg B_Traffic =1'b0 ; 
  wire  A_Light,B_Light ; 
  
  wire [3:0] tens ;
  wire [3:0] ones ; 
  binaryToBcd BTB( {1'b0 , second} , tens , ones , CLK ) ;
  Moore_mdl moortest(CLK , R , B , A , A_Traffic,B_Traffic,second ,A_Light,B_Light);
  initial 
    begin
     A_Traffic = 1'b1 ; B_Traffic = 1'b1 ; A  =1'b0 ; B =1'b0 ; R=1'b0  ; 
   end
  initial
    begin
      #90 B=~B;
    end
    
  initial
    begin
      #190 A=~A;B=~B;
    end 
  initial
    begin
      #230 A=~A;R=~R;
    end
  initial
    begin
      #240 R=~R;
    end
  initial
    begin
      #630 A=~A;B=~B;
    end
  initial
    begin
      #730 R=~R;
    end
  initial
    begin
      #740 A=~A;B=~B;R=~R;
    end
    
  initial 
    begin 
      #4000 A_Traffic = 1'b0 ;
      #500 A_Traffic = 1'b1 ; 
      #100 B_Traffic = 1'b0 ;
      #500 B_Traffic = 1'b1 ; 
    end  
  initial 
    begin 
      CLK = 1'b0 ; 
      repeat(9000)begin  
      #10 CLK = ~CLK ; 

    end
    end
  initial 
  begin 
    #16 $display("second : %d , A_Light : %b  , B_Light  : %b  , CLK : %b , tens : %d, ones : %d" , second , A_Light , B_Light , CLK , tens , ones) ; 
    repeat (9000)
      #20 $display("second : %d , A_Light : %b  , B_Light  : %b  , CLK : %b , tens : %d , ones : %d , A_traffic : %b , B_traffic : %b , A : %b , B : %b , R : %b" , second , A_Light , B_Light , CLK , tens , ones , A_Traffic, B_Traffic,A,B,R) ; 

  end
endmodule  















