# Synthesizable-CRC-block
 Design of synthesizable Cyclic Redundancy Check(CRC) Block for error detection (SOC design & verification).   
 Design completely accomplishes the goal of error detection with transposition and complementation of data by using CRC interface.   
 It generates 16 & 32 bit CRC code for error detection in the circuit corrosponding to input data coming from testbench and works on 100 MHz. Here project consists systemverilog files. you   can also make in verilog files. 
 
 Tools for simulation & synthesis:  Synopsys VCS, Synopsys Design compiler/Design Vision, GtkWave for waveform generation.  
 It is also working with other EDA tools compatible with verilog/systemverilog language.   
 Programming language: SystemVerilog/Verilog    
 Top Module/Testbench: tbcrc.sv      
 CRC interface: crcif.sv     
 CRC design module: crc.sv    
 To run simmulation, script: sv_uvm     
 Command to run simulation: ./sv_uvm tbcrc.sv          
 Simulation result file: final_result.txt     
 
 For logic synthesis,    
 Synthesis script: synthesis.script & sss  
 To do synthesis, run command: ./sss      
 Synthesis result file: synres.txt    
 
 All done with smile.... :)
 
