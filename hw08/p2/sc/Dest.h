/*
 * Data Destination and Checker for NVLabs Matchlib
 * (c) 2022-11-06 by W. Rhett Davis (rhett_davis@ncsu.edu)
 * 
 * Modified from the Dest module in the testbench.cpp file
 * for the Adder example packaged with Matchlib.
 * 
 * This module reads data from its input port using the (blocking) Pop()
 * method.  A maximum of one value per cycle can be read.  The frequency
 * of reads can be reduced by passing a Pacer object to the constructor.
 * If an optional input file is specified, then values are read from the
 * file and compared to the received values to check for errors.
 * 
 * Input file format:
 *   The first line of the input file is a comment.
 *   Each additional line contains one time specifier and one value per line.
 *   The time specifier uses the format "time_mode time_val time_unit":
 *     time_mode  - either + or @
 *     time_val   - the time given as a floating point decimal
 *     time_unit  - can be fs, ps, ns, us, ms, or s
 *   If the time mode is +, then the module will wait for the specified 
 *   amount of additional simulation time to pass before receiving the next value.
 *   If the time mode is @, then the module will wait until the exact
 *   simulation time specified until receiving the next vaule. 
 *   Note that every line must contain a time and value to avoid an error.
 * 
 * Template arguments:
 *   typename T   -  Data-type for the input port
 *   typename cfg -  Configuration
 * 
 * Example Configuration:
 * 
 *   struct SourceConfig {
 *     enum {
 *       verbose = 1,         // Set to 1 to print out messages 
 *                            //    to stdout before and after each Push() 
 *                            //    or 0 to execute silently
 *       haltOnError = 1,     // Set to 1 to halt the simulation when the first
 *                            //    incorrect value is received,
 *                            //    or 0 to ignore all errors.
 *                            //    This value has no effect if filename is NULL
 *       exitWhenDone = 0,    // Set to 1 to exit the simulation when the
 *                            //    end of the file is reached
 *                            //    or 0 to allow the simulation to continue
 *     };
 *   };
 *  
 *  Constructor
 *  Dest(sc_module_name name_, const Pacer& pacer_, const char *filename_ = NULL)
 *    arguments:
 *      name_        Instance name of the module
 *      pacer_       A Matchlib Pacer object used to throttle the behavior
 *      filename_    The name of a file with data to check (set to NULL to read
 *                     the input without comparing values)
 *  
 */


#ifndef __DEST_H__
#define __DEST_H__

#include <string>
#include <fstream>

#include <testbench/Pacer.h>

template <typename T,typename cfg>
SC_MODULE (Dest) {
    Connections::In<T> z_in;

    sc_in <bool> clk;
    sc_in <bool> rst;

    Pacer pacer;
    const char *filename;

    void run() {
        z_in.Reset();
        pacer.reset();
        char time_mode;
        double time_val;
        std::string time_unit;
        sc_core::sc_time start_time;
        T z, expected;
        bool passed=true;

	    std::ifstream f;
        std::string buf;
        if (filename) {
	        f.open(filename,ios::in);
            // Skip the first line, assume it is a comment
            if (f.good())
                std::getline(f,buf);
        }

        // Wait for initial reset.
        wait(20.0, SC_NS);

        wait();

        while(f.good()) {
            if (filename) {
                f >> time_mode >> time_val >> time_unit >> expected >> std::ws;
                // std::cout << time_mode << ' ' << time_val << ' ' << time_unit << ' ' << x << std::endl;

                // Parse the time from the transaction file, store in start_time
                if (time_unit=="fs")
                { start_time=sc_core::sc_time(time_val,sc_core::SC_FS);  }
                else if (time_unit=="ps")
                { start_time=sc_core::sc_time(time_val,sc_core::SC_PS);  }
                else if (time_unit=="ns")
                { start_time=sc_core::sc_time(time_val,sc_core::SC_NS);  }
                else if (time_unit=="us")
                { start_time=sc_core::sc_time(time_val,sc_core::SC_US);  }
                else if (time_unit=="ms")
                { start_time=sc_core::sc_time(time_val,sc_core::SC_MS);  }
                else
                { start_time=sc_core::sc_time(time_val,sc_core::SC_SEC); }

                // If time_mode is '+', increment start_time by current time
                if (time_mode=='+')
                { start_time+=sc_core::sc_time_stamp(); }

                // Wait until the transaction start-time is reached
                if (sc_core::sc_time_stamp() < start_time)
                wait( start_time-sc_core::sc_time_stamp() );
            }

            if (cfg::verbose) std::cout << "@" << sc_time_stamp() << "\t" << name() << " POP" << std::endl ;
            z = z_in.Pop();  
            if (cfg::verbose || (filename && (z != expected) && cfg::haltOnError)) 
                std::cout << "@" << sc_time_stamp() << "\t" << name() << " RECEIVED " << z << std::endl;
            if (filename) {
                if (z != expected) {
                    if (cfg::verbose || cfg::haltOnError) std::cout << "@" << sc_time_stamp() << "\t" << name() << " EXPECTED " << expected << " FAIL" << std::endl;
                    passed=false;
                }
                else if (cfg::verbose) std::cout << "@" << sc_time_stamp() << "\t" << name() << " EXPECTED " << expected << " PASS" << std::endl;
            }
            if (cfg::haltOnError && filename) assert (z == expected); 

            wait();

            while (pacer.tic()) { 
                if (cfg::verbose) std::cout << "@" << sc_time_stamp() << "\t" << name() << " STALL" << std::endl ;
                wait(); 
            }
        }
        if (cfg::verbose) std::cout << "@" << sc_time_stamp() << "\t" << name() << " COMPLETED" << std::endl ;
        if (filename) {
          if (passed) std::cout << sc_time_stamp() << " Simulation PASSED" << std::endl ;
          else std::cout << sc_time_stamp() << " Simulation FAILED" << std::endl ;
        }
        if (cfg::exitWhenDone) sc_stop();
    }

    SC_HAS_PROCESS(Dest);
    Dest(sc_module_name name_, const Pacer& pacer_, const char *filename_ = NULL) : sc_module(name_),
    z_in("sum_in"),
    clk("clk"),
    rst("rst"),
    pacer(pacer_),
    filename(filename_)
    {
        SC_THREAD(run);
        sensitive << clk.pos();
        NVHLS_NEG_RESET_SIGNAL_IS(rst);
    }
};


#endif
