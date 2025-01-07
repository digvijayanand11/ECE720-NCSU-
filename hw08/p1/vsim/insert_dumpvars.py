import sys

TOP_NAME=sys.argv[1]

f=open(f'../hls/Catapult/{TOP_NAME}.v1/concat_sim_rtl.v')

lines=[]

for line in f:
    lines.append(line)
f.close()

# Find last non-empty line
for i in range(len(lines),0,-1):
    if lines[i-1].strip()!='':
        break
lastline=i

if lines[lastline-1].strip() != 'endmodule':
    raise Exception(f'Last line of concat_sim_rtl.v is "{lines[lastline-1].strip()}", but "endmodule" was expected')
      


f=open(f'../hls/Catapult/{TOP_NAME}.v1/concat_sim_rtl_dumpvars.v','w')
for line in lines[:lastline-1]:
    f.write(line)



f.write('''  initial begin
     $display("Dumping all signals to waves.vcd.\\n");
     $dumpfile("waves.vcd"); // waveforms in this file.. 
     $dumpvars; // saves all waveforms
  end
''')
f.write(lines[lastline-1])
f.close()

