/*
 * Testbench for Reverser Example Module
 * (c) 2022-11-04 by W. Rhett Davis (rhett_davis@ncsu.edu)
 * 
 * This example shows a module that includes a Single-Port 
 * SRAM memory macro.
 */

#include "nvhls_pch.h"
#include "Source.h"
#include "Dest.h"
#include "Reverser.h"

#define NVHLS_VERIFY_BLOCKS (Reverser)
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
        verbose = 0,
        haltOnError = 0,
        exitWhenDone = 1,
    };
};

SC_MODULE (testbench) {
    NVHLS_DESIGN(Reverser) dut;

    Source<sc_int<16>,SourceConfig> srca;
    Dest<sc_int<16>,DestConfig> dest;

    Connections::Combinational<sc_int<16>> a,z;
    
    sc_clock clk;
    sc_signal<bool> rst;

    SC_CTOR(testbench) :
        dut("dut"),
        srca("srca", Pacer(0.3, 0.7),"srca.dat"),
        dest("dest", Pacer(0.2, 0.5),"dest.dat"),
        a("a"),
        z("z"),
        clk("clk", 1, SC_NS, 0.5,0,SC_NS,true),
        rst("rst")
    {

        srca.clk(clk);
        dest.clk(clk);
        dut.clk(clk);

        srca.rst(rst);
        dest.rst(rst);
        dut.rst(rst);

        srca.x_out(a);

        dut.in_p(a);
        dut.out_p(z);

        dest.z_in(z);

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

