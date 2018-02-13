// test bench for multifunctional circuit
`timescale 1ns / 1ps

module tb_with_alarm;

reg 	 	clk,rst,pause,alarm;
reg 	 	in_hour,in_minute,in_second,de_hour,de_minute,de_second;
reg[1:0] 	mode;

wire 		ring,led;
wire[7:0] 	hour,minute,second;

with_alarm dut(.clk(clk),
               .rst(rst),
               .pause(pause),
               .alarm(alarm),
               .in_hour(in_hour),
               .in_minute(in_minute),
               .in_second(in_second),
               .de_hour(de_hour),
               .de_minute(de_minute),
               .de_second(de_second),
               .mode(mode),
               .ring(ring),
               .led(led),
               .hour(hour),
               .minute(minute),
               .second(second)
			  );
               
initial clk=0;
always #5 clk = ~clk;

initial fork
	rst=0;
	pause=0;
	alarm=0;
	mode=2'b00;
	in_hour=0;
	in_minute=0;
	in_second=0;
	de_hour=0;
	de_minute=0;
	de_second=0;
	
	
	
	// for this testbench, verify one mode at a time //
	// delays should be changed while verifying multiple cases at once //	
	
    // stimulus for timer --- change times
	#40 mode=2'd3;         
	 
	#60 in_hour=1;             
	#80 in_hour=0;	       
	
	#100 de_hour=1;	
	#110 de_hour=0;	           
	
	#200 in_minute=1;	
	#280 in_minute=0;      
	
	#300 de_minute=1;
	#330 de_minute=0;      
	
    #350 rst=1;
   
   // stimulus for stopwatch ---- change times
   #40 mode=2'd2;
   #60 rst=1;    
    
   #5000 pause=1;
   
    // stimulus for normal clock mode //
    #30 mode=2'b01;
    
    #60 in_hour=1;             
    #180 in_hour=0;           
        
    #200 de_hour=1;    
    #220 de_hour=0;               
        
    #250 in_minute=1;    
    #550 in_minute=0;      
        
    #600 de_minute=1;
    #750 de_minute=0;    
  
    #800 rst=1;
    
join
endmodule
