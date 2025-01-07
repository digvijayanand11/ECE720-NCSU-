/*
 * Testbench for Simple Adder Example Module
 * (c) 2022-11-04 by W. Rhett Davis (rhett_davis@ncsu.edu)
 * 
 * This example shows a basic design working with NVLabs Matchlib
 * Modified slightly from the Adder.h example packaged with Matchlib
 */

#include "nvhls_pch.h"
#include "Source.h"
#include "Dest.h"
#include "LFSR.h"

#define NVHLS_VERIFY_BLOCKS (LFSR)
#include <nvhls_verify.h>
#include <testbench/nvhls_rand.h>
#include <testbench/Pacer.h>

struct SourceConfig {
    enum {
        verbose = 0,
        exitWhenDone = 0,
    };
};

struct DestConfig {
    enum {
        verbose = 1,
        haltOnError = 1,
        exitWhenDone = 1,
    };
};

SC_MODULE (testbench) {
    NVHLS_DESIGN(LFSR) dut;

    Source<sc_uint<8>,SourceConfig> count_src;
    Source<sc_uint<12>,SourceConfig> seed_src;
    Dest<sc_uint<48>,DestConfig> lfsr4_dest;

    Connections::Combinational<sc_uint<8>> count;
    Connections::Combinational<sc_uint<12>> seed;
    Connections::Combinational<sc_uint<48>> lfsr4;

    
    sc_clock clk;
    sc_signal<bool> rst;

    SC_CTOR(testbench) :
        dut("dut"),
        count_src("count_src", Pacer(0, 1),"count.dat"),
        seed_src("seed_src", Pacer(0, 1),"seed.dat"),
        lfsr4_dest("lfsr4_dest", Pacer(0, 1),"lfsr4.dat"),
        count("count"),
        seed("seed"),
        lfsr4("lfsr4"),
        clk("clk", 1, SC_NS, 0.5,0,SC_NS,true),
        rst("rst")
    {

        count_src.clk(clk);
        seed_src.clk(clk);
        lfsr4_dest.clk(clk);
        dut.clk(clk);

        count_src.rst(rst);
        seed_src.rst(rst);
        lfsr4_dest.rst(rst);
        dut.rst(rst);

        count_src.x_out(count);
        seed_src.x_out(seed);

        dut.count_in(count);
        dut.seed_in(seed);
        dut.lfsr4_out(lfsr4);

        lfsr4_dest.z_in(lfsr4);

        SC_THREAD(run);
    }

    void run() {
        //reset
        rst = 1;
        wait(10.5, SC_NS);
        rst = 0;
        //std::cout << "@" << sc_time_stamp() << " Asserting Reset " << std::endl ;
        wait(1, SC_NS);
        //std::cout << "@" << sc_time_stamp() << " Deasserting Reset " << std::endl ;
        rst = 1;
    }
};

int sc_main(int argc, char *argv[])
{
    nvhls::set_random_seed();
    testbench my_testbench("my_testbench");
    sc_start();
    return 0;
};

