`timescale 1ns/1ps

module with_alarm(
				input clk,rst,pause,alarm,                 								// clock, reset and pause switches //
				input in_hour,in_minute,in_second,de_hour,de_minute,de_second,      	// increment and decrement switches //
				input [1:0] mode,                     									// mode select switches //
				output reg ring,led,                     								// ring => alarm bell output , led => circuit error output //
				output reg[7:0] hour,minute,second);          							// clock hands output //
    
    reg[7:0] alarm_hour,alarm_minute;       		// for storing alarm time //
    
    always@(posedge clk,negedge rst,negedge mode) begin
		// Circuit is initialized when reset is OFF and mode is 0 //  
        if(!rst && mode == 2'b0) begin                     
            hour <= 8'b0;
            minute <= 8'b0;
            second <= 8'b0;
            ring <= 1'b0;
            alarm_hour <= 8'b0;
            alarm_minute <= 8'b0;
			led <= 1'b0;
        end
		// End of circuit initialization //

		
		// Clock setting mode ------- clock hands are set when reset is OFF and mode value is 1 or 2 or 3 //
        else if(!rst && (mode == 2'b01 || mode == 2'b10 || mode == 2'b11)) begin 
			ring <= 1'b0;	// useful when timer ends //
			led <= 1'b0;	// no error in circuit operation //
			
			//normal clock setting without storing alarm time //
			if(!alarm)begin 												
				if(in_second == 1'b1 && de_second == 1'b0 && second < 8'b0011_1011)          // incrementing second hand upto maximum 59 // 
				second <= second+1;
            
				else if(in_minute == 1'b1 && de_minute == 1'b0 && minute < 8'b0011_1011)     // incrementing minute hand upto maximum 59 //
				minute <= minute+1;
            
				else if(in_hour == 1'b1 && de_hour == 1'b0 && hour < 8'b0001_0111)        	 // incrementing hour hand upto maximum 23 //
				hour <= hour+1;
            
				else if(de_second == 1'b1 && in_second == 1'b0 && second > 8'b0)      		 // decrementing second hand //
				second <= second-1;
            
				else if(de_minute == 1'b1 && in_minute == 1'b0 && minute > 8'b0)      		 // decrementing minute hand //
				minute <= minute-1;
            
				else if(de_hour == 1'b1 && in_hour == 1'b0 && hour > 8'b0)         			 // decrementing hour hand //
				hour <= hour-1;
				
				// else clock hands will retain their previous value //
				else begin
					second = second;										
					minute = minute;
					hour = hour;
				end
            
			end
  
			// setting of alarm as well as clock when alarm switch is ON //
			// In case of alarm, only minute and hour hand will be set //
			else begin
				if(in_second == 1'b1 && de_second == 1'b0 && second < 8'b0011_1011)begin       
					second <= second+1;
				end
				
				else if(in_minute == 1'b1 && de_minute == 1'b0 && minute < 8'b0011_1011)begin       
					minute <= minute+1;
					alarm_minute <= alarm_minute+1;
				end
				
				else if(in_hour == 1'b1 && de_hour == 1'b0 && hour < 8'b0001_0111)begin        
					hour <= hour+1;
					alarm_hour <= alarm_hour+1;
				end
				
				else if(de_second == 1'b1 && in_second == 1'b0 && second > 8'b0)begin      
					second <= second-1;
				end
				
				else if(de_minute == 1'b1 && in_minute == 1'b0 && minute > 8'b0)begin      
					minute <= minute-1;
					alarm_minute <= alarm_minute-1;
				end
				
				else if(de_hour == 1'b1 && in_hour == 1'b0 && hour > 8'b0)begin         
					hour <= hour-1;
					alarm_hour <= alarm_hour-1;
				end
				
				// else alarm and clock hands will retain their previous value //	
				else begin
					second = second;											
					minute = minute;
					alarm_minute = alarm_minute;
					hour = hour;
					alarm_hour = alarm_hour;
				end
            
			end  
        end
		// end of clock setting mode //
		
        
		// clock mode----------rst is ON and mode is 0 or 1 //     
        else if(rst == 1'b1 && (mode == 2'b01)) begin
            led = 1'b0;
            if(alarm == 1'b1 && (minute == alarm_minute && hour == alarm_hour))			// checking condition for alarm //
                ring <= 1'b1;
			else
                ring <= 1'b0;
				
            // code for normal clock //    																															//check here
            if(second == 8'b0011_1011) begin	      
                second <= 8'b0;               		//when second hand reaches 59 --- clock == 00:00:59 then it is reinitializd to 0 and
                minute <= minute+1;           		//minute hand increments by 1 --- clock == 00:01:00
                
				if(minute == 8'b0011_1011)begin      
                    minute <= 8'b0;           		//when minute hand reaches 59 --- clock == 00:59:59 then it is reinitializd to 0 and
                    hour <= hour+1;           		//hour hand increments by 1 ----------- clock == 01:00:00
                    
					if(hour == 8'b0001_0111)begin   // example clock --- 23:59:59
                        hour <= 8'b0;         		// example clock --- 00:00:00
                    end
					else begin
						hour = hour;				// else hour will retain its previous value //
					end	
                end
				else begin
					minute = minute;				// else minute will retain its previous value //
				end
            end
            
			else begin
                second <= second+1;           		//second hand gets incremented untill it reaches 59 //
            end 
        end
		// end of normal clock mode //        
        
		
		// stopwatch mode----------when reset is ON and mode is 2 //
        else if(rst == 1'b1 && mode == 2'b10) begin
            led = 1'b0;
            ring = 1'b0;
			
            // if pause switch is OFF then normal clock runs //
            if(!pause) begin            
                if(second == 8'b0011_1011)begin
                    second <= 8'b0;
                    minute <= minute+1;
                    
					if(minute == 8'b0011_1011)begin
                        minute <= 8'b0;
                        hour <= hour+1;
                    
						if(hour == 8'b1111_1111)			// hour hand will reach its maximum value 255 //
                            hour <= 8'b0;
                        else
							hour = hour;
							
                    end
					else begin
						minute = minute;
					end	
				end	
				
				else begin
					second <= second+1;
				end	
			end

			// when pause switch is ON, clock output is paused //
            else begin     					
                second = second;
                minute = minute;
                hour = hour;
            end
        end
		// end of stopwatch mode //

		
		// timer mode------------when reset is ON and mode is 3
        else if(rst == 1'b1 && mode == 2'b11) begin
            led = 1'b0;
			
			// when hour hand is non-zero //
            if(hour > 8'b0)begin            						
                if(second == 8'b0 && minute > 8'b0)begin            // example clock --- 01:20:00  
                    second <= 8'b0011_1011;
                    minute <= minute-1;								// new clock --- 01:19:59
                end
                
                else if(second == 8'b0 && minute == 8'b0)begin      // example clock --- 01:00:00   
                    hour <= hour-1;
                    minute <= 8'b0011_1011;
                    second <= 8'b0011_1011;							// new clock --- 00:59:59
                end
				
				else												// example clock --- 01:20:35  or  01:00:35
					second <= second-1;
				
            end
            
			// when hour hand is 0 //   
            else begin      										
                if(second == 8'b0 && minute > 8'b0)begin            // example clock --- 00:30:00   
                    second <= 8'b0011_1011;
                    minute <= minute-1;
                end
                
				else if(second == 8'b0 && minute == 8'b0)
                    ring <= 1'b1;                                  	// alarm bell rings when timer ends, ring stops when reset is made 0 //

				else
					second <= second-1;
					
            end
        end
		// end of timer mode //
        
		
		// in case any unusual condition occurs then led glows and bell rings //
		else begin
			led = 1'b1;												// this refers to error in circuit operation //
		    ring = 1'b1;
		    second = second;
		    minute = minute;
            alarm_minute = alarm_minute;
            hour = hour;
            alarm_hour = alarm_hour;  
		end
		
    end   
	// end of always block //   
    
endmodule