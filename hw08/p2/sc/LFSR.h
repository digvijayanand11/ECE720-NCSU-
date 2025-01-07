#ifndef __LFSR_H__
#define __LFSR_H__

#pragma once

#include "nvhls_pch.h"
#include <ac_int.h>
#include <iostream>
#define LFSR_Len 12


SC_MODULE(LFSR){

	public:
		sc_in_clk 	clk;
		sc_in<bool>	rst;

	Connections::In 	<sc_uint<8>> count_in;
	Connections::In 	<sc_uint<12>> seed_in;
	Connections::Out	<sc_uint<48>> lfsr4_out;

	SC_HAS_PROCESS(LFSR);

	LFSR(sc_module_name name_) : sc_module(name_),
		count_in("count_in"), seed_in("seed_in"), lfsr4_out("lfsr4_out"){
			SC_THREAD(run);
			sensitive << clk.pos();
			NVHLS_NEG_RESET_SIGNAL_IS(rst);
		}

	void run(){

		// reset:
		count_in.Reset();
		seed_in.Reset();
		lfsr4_out.Reset();

		// initialization:
		sc_uint <12> lfsr_buf = 0;
		sc_uint <48> lfsr_pp = 0;
		sc_uint <48> lfsr_pp_out = 0;
		int i;


		sc_uint<8> cnt;
		wait();
		
		// functionality:
		while(1){

			cnt = count_in.Pop();
			lfsr_buf = seed_in.Pop();

			for(i=0; i<cnt; i++){
				bool feedback = lfsr_buf[11]^lfsr_buf[10]^lfsr_buf[9]^lfsr_buf[3];
				lfsr_buf = (lfsr_buf << 1) | feedback;
//				cout << i << ".feedback = \t" << feedback << "\t\tlfsr_buf\t" << lfsr_buf << "\t" << endl;
				int curr_itr = i%4;
				lfsr_pp.range(((curr_itr+1)*12-1), (curr_itr*12)) = (lfsr_buf);

				if((i+1)%4==0){
					lfsr4_out.Push(lfsr_pp);
					lfsr_pp = 0; 
				;
				}

				
			}
			// for residual bits:
			if(cnt%4!=0){
				lfsr4_out.Push(lfsr_pp);
				lfsr_pp=0;
			}

			wait();			
		}
	}
};

#endif
