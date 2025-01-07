/*
 * Reverser Example Module
 * (c) 2022-11-04 by W. Rhett Davis (rhett_davis@ncsu.edu)
 * 
 * This example shows a module that includes a Single-Port 
 * SRAM memory macro.
 */
#ifndef __REVERSER_H__
#define __REVERSER_H__

#include "nvhls_pch.h"

// Define the length of the buffer.
// It would be better to define this using a Config enum,
// but that would require wrapping this module with another
// module for synthesis, as with the AxiSlaveToRegTop example.
// A simple #define statement is therefore used for simplicity.
#define BUFLEN 32

SC_MODULE(Reverser)
{
    public:
        sc_in_clk     clk;
        sc_in<bool>   rst;

        Connections::In<sc_int<16>> in_p;
        Connections::Out<sc_int<16>> out_p;

        SC_HAS_PROCESS(Reverser);
        Reverser(sc_module_name name_) : sc_module(name_),
	    in_p("in"), out_p("out")
        {
            SC_THREAD (run); 
            sensitive << clk.pos(); 
            NVHLS_NEG_RESET_SIGNAL_IS(rst);
        }

        void run()
        {
            in_p.Reset();
            out_p.Reset();

	    sc_int<16>* int_buf;
	    sc_int<16>* out_buf;

            sc_int<16> buf[BUFLEN];
            sc_int<16> buf2[BUFLEN];
	    
	    int_buf = buf;
	    out_buf = buf2;
	    int i;

	    wait();
            
	    while (1)
            {
                for (i=0; i<BUFLEN; i++){         
//
			int_buf[i] = in_p.Pop();
            	}
	    	
	    	sc_int<16>* temp_ptr = int_buf;
		int_buf = out_buf;
		out_buf = temp_ptr;

	    	for(i=BUFLEN-1; i>=0; i--){
			out_p.Push(out_buf[i]);
		}
	}
        }
};

#endif
