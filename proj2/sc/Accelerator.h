/*
 * 
 */
#pragma once
#include "nvhls_pch.h"

SC_MODULE(Accelerator)
{
    public:
        sc_in_clk     clk;
        sc_in<bool>   rst;

        sc_out<sc_uint<8>> st_out;
        Connections::In<sc_uint<8>> ctrl_in;
        Connections::In<sc_uint<64>> w_in;
        Connections::In<sc_uint<64>> x_in;
        Connections::Out<sc_uint<64>> z_out;

        SC_HAS_PROCESS(Accelerator);
        Accelerator(sc_module_name name_) : sc_module(name_),
        st_out("st_out"), ctrl_in("ctrl_in"), w_in("w_in"), x_in("x_in"), z_out("z_out")
        {
            SC_THREAD (run); 
            sensitive << clk.pos(); 
            NVHLS_NEG_RESET_SIGNAL_IS(rst);
        }
        void run()
        {
            ctrl_in.Reset();
            w_in.Reset();
            x_in.Reset();
            z_out.Reset();

        sc_uint<64> data[4] = {0};
	    sc_uint<64> data2 = 0;
	    sc_uint<8> ctrl=0;
		
	    // try burst::
	    //
		sc_uint<4> output_ready = 0;

		sc_uint<16> burst_buf [4] = {0};
	    sc_uint<16> data_burst16[16] = {0};
	    sc_uint<16> data_burst16_2[16] = {0};
	    
		sc_uint<16> output[4] = {0};

	    sc_uint<8> status = 0; 				
	    int i = 0;
		    
	    st_out.write(0);

	    sc_uint<64> x_in64 = 0;	  
    
	    int temp_indB = 0; /// coeff pointer
            wait();                  // wait separates reset from operational behavior

        while (1){
            if (!ctrl_in.Empty()) {
                ctrl=ctrl_in.Pop();
//				std::cout<<"\n\n\t\tctrl = "<< ctrl << "\t" << std::endl;	    
				// st_out.write(ctrl);
			}
		if(ctrl==0xFF){		// indicates new operation about to start; reset all internal structure
			// coefficient
			temp_indB = 0;
			output_ready=0;
			data2=0;
			x_in64=0;
			for (i=0; i<16; i++) {
				data_burst16[i] = 0;
				data_burst16_2[i] = 0;
			}
			for (i=0; i<4;i++) {
				burst_buf[i] = 0;
				output[i] = 0;
			}

			// st_out.write(0xFF);
			
		}
		if (ctrl==0x01) {
            if(!w_in.Empty()){
                data2 = w_in.Pop();
//				std::cout << "&&&&&&&&&&& data2 " << std::hex << data2 << std::endl;
				data_burst16_2[temp_indB + 0] = data2.range(15,0) & 0xFFFF;
				data_burst16_2[temp_indB + 1] = data2.range(31,16) & 0xFFFF;
				data_burst16_2[temp_indB + 2] = data2.range(47,32) & 0xFFFF;
				data_burst16_2[temp_indB + 3] = data2.range(63,48) & 0xFFFF;
				temp_indB +=4; 
//				for (i = 0; i < 16; i++) {
//					std::cout << "&&&&&&&&&&& data_burst16_2[" << i << "] = " << std::hex << data_burst16_2[i] << std::endl;
//				}
            }


		}
		if (ctrl==0x02) {
				int idx = 0;
				if(!x_in.Empty()){
                    x_in64 = x_in.Pop();
//					std::cout << "x_in64 " << std::hex << x_in64 << std::endl;

					/////////////////////////////////////////////			
					//
					// FIR Operation:
					//
					/////////////////////////////////////////////

					for (i = 3; i >= 0; i--) {
						burst_buf[i] = data_burst16[15 - (3 - i)];
					}
					wait();  
					for (i = 15; i >= 4; i--) {
						data_burst16[i] = data_burst16[i-4];
					}
					wait();  
					data_burst16[3] = x_in64.range(15,0);
					data_burst16[2] = x_in64.range(31,16);
					data_burst16[1] = x_in64.range(47,32);
					data_burst16[0] = x_in64.range(63,48);

	//				for (i = 0; i < 16; i++) {
	//					std::cout << "data_burst[" << i << "] = " << std::hex << data_burst16[i] << std::endl;
	//				}

					for (i = 3; i >=0; i--) {
						for (int j = 0; j<16 ; j++) {
							if (i + j < 16) {
								output[3-i] += data_burst16[i+j] * data_burst16_2[15-j];
							}
							else {
								output[3-i] += burst_buf[(i+j)%16] * data_burst16_2[15-j];
							}
							wait();  
						}
						output_ready = output_ready << 1 | 1;
					}
	//				for (i = 0; i < 4; i++) {
	//					std::cout << ";;;;;;;;;;;;; output[" << i << "] = " << std::hex << output[i] << std::endl;
	//				}					
				}
				if (!z_out.Full() && output_ready == 0xF) {
	//				std::cout << "push output  = " << std::hex << ((output[3] << 48) | (output[2] << 32) | (output[1] << 16) | (output[0])) << std::endl;
					z_out.Push(
						(output[3] << 48) | (output[2] << 32) | (output[1] << 16) | (output[0])
					);
				}
				output_ready = 0;
				for (i=0; i < 4 ; i++) {
					output[i] = 0;
				}
			}                               
			wait();   	
		}
	}
};
