


module crc(crc_if.dp m);

logic [31:0] crc_data, crc_ctrl, crc_gpoly, dhatri;
logic [31:0] crc_tot, crc_seed, crc_temp, seed_data_reg, crc_totr, crc_fxor;
logic [1:0] TOT,TOTR;
logic  FXOR,WAS,TCRC;

always @(posedge m.clk)
begin 
    if(m.rst) begin 
            crc_data = 32'hffff_ffff;
            crc_gpoly = 32'h0000_1021;
            crc_ctrl = 32'h0000_0000;
            crc_seed = 32'hffff_ffff; 
    end 
    else begin 
            if(m.RW) begin 
                case(m.addr)
                    32'h4003_2000 : crc_data = m.data_wr;
                                    
                              
                    32'h4003_2004 : crc_gpoly = m.data_wr;
                                    
                
                    32'h4003_2008 : crc_ctrl = m.data_wr;
                               
               endcase
            end 
    
     
            TOT = crc_ctrl[31:30];           
            TOTR = crc_ctrl[29:28];
            FXOR = crc_ctrl[26];
            WAS = crc_ctrl[25];
            TCRC = crc_ctrl[24]; 
        
     //... reverse logic... 
       case(TOT)
                                   
            2'b00 : crc_tot = crc_data;                 
            
            2'b01 : crc_tot = { {crc_data[24], crc_data[25], crc_data[26], crc_data[27], crc_data[28], crc_data[29],                                       crc_data[30],crc_data[31]}, {crc_data[16], crc_data[17], crc_data[18], crc_data[19], crc_data[20], crc_data[21], crc_data[22], crc_data[23]}, {crc_data[8], crc_data[9], crc_data[10], crc_data[11], crc_data[12], crc_data[13], crc_data[14], crc_data[15]}, {crc_data[0], crc_data[1], crc_data[2], crc_data[3], crc_data[4], crc_data[5], crc_data[6], crc_data[7]}};
            
            2'b10 : crc_tot = {crc_data[0], crc_data[1], crc_data[2], crc_data[3], crc_data[4], crc_data[5], crc_data[6], crc_data[7], crc_data[8], crc_data[9], crc_data[10], crc_data[11], crc_data[12], crc_data[13], crc_data[14], crc_data[15], crc_data[16], crc_data[17], crc_data[18], crc_data[19], crc_data[20], crc_data[21], crc_data[22], crc_data[23], crc_data[24], crc_data[25], crc_data[26], crc_data[27], crc_data[28], crc_data[29], crc_data[30], crc_data[31]}; 
            
            2'b11 : crc_tot = {{crc_data[7], crc_data[6], crc_data[5], crc_data[4], crc_data[3], crc_data[2], crc_data[1], crc_data[0]}, {crc_data[15], crc_data[14], crc_data[13], crc_data[12], crc_data[11], crc_data[10], crc_data[9], crc_data[8]}, {crc_data[23], crc_data[22], crc_data[21], crc_data[20], crc_data[19], crc_data[18], crc_data[17], crc_data[16]}, {crc_data[31], crc_data[30], crc_data[29], crc_data[28], crc_data[27], crc_data[26], crc_data[25], crc_data[24]}};
        endcase 
        
         
        dhatri = crc_tot;
 
          
      if(WAS == 1 && m.RW == 1 && m.addr == 32'h4003_2000 && m.Sel) begin 
                    crc_seed = crc_tot;
      end 

//... 32 bit engine.... 
      
      else if(TCRC == 1 && WAS == 0 && m.RW == 1 && m.Sel == 1 && m.addr == 32'h4003_2000) 
      begin   
        
              seed_data_reg = crc_seed;   
           
            for(int i = 0; i < 32; i = i+1) begin 
                      
                    if(seed_data_reg[31] == 0) begin 
                            seed_data_reg = seed_data_reg << 1;
                            seed_data_reg = {seed_data_reg[31:1], crc_tot[31]};
                            crc_tot = crc_tot << 1;
                    end 
                    else if(seed_data_reg[31] == 1) begin 
                            seed_data_reg = seed_data_reg << 1;
                            seed_data_reg = {seed_data_reg[31:1], crc_tot[31]};
                            seed_data_reg = seed_data_reg ^ crc_gpoly;
                            crc_tot = crc_tot << 1;
                        
                    end 
                    
                        
            end 
                    
                crc_temp = seed_data_reg;
                crc_seed = crc_temp;
                    
        end 
    
//... 16 bit engine.. 
        else if(TCRC == 0 && WAS == 0 && m.RW == 1 && m.Sel == 1 && m.addr == 32'h4003_2000)
        begin
        
               seed_data_reg = crc_seed;  
           
           for(int i = 0; i < 32; i = i+1) begin 
                      
                        if(seed_data_reg[15] == 0) begin 
                            seed_data_reg = seed_data_reg << 1;
                            seed_data_reg = {seed_data_reg[15:1], crc_tot[31]};
                            crc_tot = crc_tot << 1;
                        end 
                        else if(seed_data_reg[15] == 1) begin 
                            seed_data_reg = seed_data_reg << 1;
                            seed_data_reg[15:0] = {seed_data_reg[15:1], crc_tot[31]};
                            seed_data_reg[15:0] =  seed_data_reg[15:0] ^ crc_gpoly;
                            crc_tot = crc_tot << 1;
                        
                        end 
                    
                        
                  end 
                    
                    crc_temp = {16'b0, seed_data_reg[15:0]};
                   
                    crc_seed = crc_temp;
                    
        
         end 
    
        if(FXOR == 1) begin 
            if(TCRC == 1) begin 
                crc_fxor = crc_seed ^ 32'hffff_ffff;
            end 
            else if(TCRC == 0) begin 
                case (TOTR)
                    2'b00 : crc_fxor = crc_seed ^ 32'h0000_ffff;
                    2'b01 : crc_fxor = crc_seed ^ 32'h0000_ffff;
                    2'b10 : crc_fxor = crc_seed ^ 32'hffff_0000;
                    2'b11 : crc_fxor = crc_seed ^ 32'hffff_0000;
                endcase 
            end 
        end 
        else if(FXOR == 0) begin 
                crc_fxor = crc_seed;
        end 
        
        
     case(TOTR)
                                   
            2'b00 : crc_totr = crc_fxor;                 
            
            2'b01 : crc_totr = { {crc_fxor[24], crc_fxor[25], crc_fxor[26], crc_fxor[27], crc_fxor[28], crc_fxor[29],                                       crc_fxor[30],crc_fxor[31]}, {crc_fxor[16], crc_fxor[17], crc_fxor[18], crc_fxor[19], crc_fxor[20], crc_fxor[21], crc_fxor[22], crc_fxor[23]}, {crc_fxor[8], crc_fxor[9], crc_fxor[10], crc_fxor[11], crc_fxor[12], crc_fxor[13], crc_fxor[14], crc_fxor[15]}, {crc_fxor[0], crc_fxor[1], crc_fxor[2], crc_fxor[3], crc_fxor[4], crc_fxor[5], crc_fxor[6], crc_fxor[7]}};
            
            2'b10 : crc_totr = {crc_fxor[0], crc_fxor[1], crc_fxor[2], crc_fxor[3], crc_fxor[4], crc_fxor[5], crc_fxor[6], crc_fxor[7], crc_fxor[8], crc_fxor[9], crc_fxor[10], crc_fxor[11], crc_fxor[12], crc_fxor[13], crc_fxor[14], crc_fxor[15], crc_fxor[16], crc_fxor[17], crc_fxor[18], crc_fxor[19], crc_fxor[20], crc_fxor[21], crc_fxor[22], crc_fxor[23], crc_fxor[24], crc_fxor[25], crc_fxor[26], crc_fxor[27], crc_fxor[28], crc_fxor[29], crc_fxor[30], crc_fxor[31]}; 
            
            2'b11 : crc_totr = {{crc_fxor[7], crc_fxor[6], crc_fxor[5], crc_fxor[4], crc_fxor[3], crc_fxor[2], crc_fxor[1], crc_fxor[0]}, {crc_fxor[15], crc_fxor[14], crc_fxor[13], crc_fxor[12], crc_fxor[11], crc_fxor[10], crc_fxor[9], crc_fxor[8]}, {crc_fxor[23], crc_fxor[22], crc_fxor[21], crc_fxor[20], crc_fxor[19], crc_fxor[18], crc_fxor[17], crc_fxor[16]}, {crc_fxor[31], crc_fxor[30], crc_fxor[29], crc_fxor[28], crc_fxor[27], crc_fxor[26], crc_fxor[25], crc_fxor[24]}};
        endcase 
    end 
end

always @(*) begin 
      
        if (m.addr == 32'h4003_2000)
        begin
           m.data_rd = crc_totr;
        end
    

        else if (m.addr == 32'h4003_2004)
        begin
            m.data_rd = crc_gpoly;
        end
        else if (m.addr == 32'h4003_2008)
        begin
            m.data_rd = crc_ctrl;
        end
        else m.data_rd = 32'h12345678;
   
     
end 
       
       
    
endmodule 
                
