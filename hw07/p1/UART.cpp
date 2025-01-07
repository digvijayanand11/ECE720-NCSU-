// UART:

# include <systemc.h>
# include "read_master_if.h"
# include "CPU.h"
# include <list>

using namespace std;

class UART : public sc_module, read_master_if<char>
{
public:
  
  // define ports:
  sc_export<read_master_if<char> > out;
  sc_event read_event, write_event;
  
  // initialize variables:
  list <char> fifo;  
  char buffer;

  SC_HAS_PROCESS(UART);

  UART(sc_module_name name) : sc_module(name) {
    SC_THREAD(main);
    out.bind(*this); // change this?
  }

  bool nb_read(){return true;}
  const sc_event &data_write_event() const {return write_event; }

  void read(int addr, char &data){
	if(addr == 0){
		if(!fifo.size())
			data = 0;
		else 
			data = 1;
	}
	else{
		data = fifo.front();
		fifo.pop_front();
	}
	read_event.notify(SC_ZERO_TIME);
  }

  void main () {
    const char *str = "Hello, World!\n";
    const char *p = str;

    while (true) {
        cout << sc_time_stamp().to_string();
        cout << "\tUART writing " << *p << " to buffer\n";
        fifo.push_back(*p++);
        cout << sc_time_stamp().to_string();
        cout << "\tUART wrote to buffer\n";
        wait(100, SC_NS);
    }
  }
};

class top : public sc_module
{
public:
  UART uart_inst;
  CPU cpu_inst;

  top(sc_module_name name) : 
    sc_module(name),
    uart_inst("UART1"),
    cpu_inst("CPU1")
  {

    cpu_inst.master(uart_inst.out);
  }
};

int sc_main (int argc, char *argv[])
{
  top top1("Top1");
  sc_start(1300, SC_NS);
  cout << endl <<endl;
  return 0;
}
