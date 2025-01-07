#define TAPS 16
#define TSTEP1 32
#define TSTEP2 48

// short coef[TAPS*2] = {
// #include "coef.inc"
// };

// short input[TSTEP1+TSTEP2] = {
// #include "input.inc"
// };


#include "expected.inc"

// CLOBBER is a compiler barrier
// Some resources on compiler barriers:  
//   https://youtu.be/nXaxk27zwlk  (original source, as far as I can tell)
//   https://stackoverflow.com/questions/37786547/enforcing-statement-order-in-c
//   https://preshing.com/20120625/memory-ordering-at-compile-time/
static void clobber() {
  asm volatile ("" : : : "memory");
}



int main( int argc, char* argv[] )
{

  int n,m;

  //dma:
  volatile long long *dma_st     = (volatile long long*)  0x70000000;
  volatile long long **dma_sr    = (volatile long long**) 0x70000010;
  volatile long long **dma_dr    = (volatile long long**) 0x70000018;
  volatile long long *dma_len    = (volatile long long*)  0x70000020;
  
  //accelerator:
  volatile long long *accel_st   = (volatile long long*)  0x70010000;
  volatile long long *accel_ctrl = (volatile long long*)  0x70010008;
  volatile long long *accel_w    = (volatile long long*)  0x70010010;
  volatile long long *accel_x    = (volatile long long*)  0x70010030;
  volatile long long *accel_z    = (volatile long long*)  0x70010050;

  volatile short *coef=(short *)0x60004000;
  volatile short *input=(short *)0x60002000;
  // Uncomment the next line to avoid memory controller accesses
  // short output[TSTEP1+TSTEP2];
  volatile short *output=(short *)0x60001000;


  short error,total_error, cal_output;


  ////////////////////////////////////////
  //
  //
  //Software Implmenetation:
  //
  ////////////////////////////////////////

/*  
  // First FIR filter operation
  for (n=0; n<TSTEP1; n++) {
    output[n]=0;
    for (m=0; m<TAPS; m++) {
      if (n+m-TAPS+1 >= 0) {
        output[n]+=coef[m]*input[n+m-TAPS+1];
        // Uncomment the next line for detailed calculation
        // printf("cpu main n: %d coef[%d]: %d input[%d]: %d sum: %d\n",n,m,coef[m],n+m-TAPS+1,input[n+m-TAPS+1],output[n]);
      }
    }
  }
    // Second FIR filter operation
  for (n=0; n<TSTEP2; n++) {
    output[TSTEP1+n]=0;
    for (m=0; m<TAPS; m++) {
      if (n+m-TAPS+1 >= 0) {
        output[TSTEP1+n]+=coef[TAPS+m]*input[TSTEP1+n+m-TAPS+1];
        // Uncomment the next line for detailed calculation
        // printf("cpu main n: %d coef[%d]: %d input[%d]: %d sum: %d\n",n,m,coef[TAPS+m],n+m-TAPS+1,input[TSTEP1+n+m-TAPS+1],output[TSTEP1+n]);
      }
    }
  }


  // Error check for both FIR filter operations
  total_error=0;
  for (n=0; n<(TSTEP1+TSTEP2); n++) {
    error=expected[n]-output[n];              // Error for this time-step
    total_error+=(error<0)?(-error):(error);  // Absolute value
    // Uncomment the next line for a detailed error check
//    printf("cpu main k: %d output: %x expected %x\n",n,output[n],expected[n]);
  }

//  printf("cpu main FIR total error: %d\n",total_error);


*/
 
  //////////////////////////
  //
  // FIR accelerator:
  //
  //////////////////////////
 
  //
  // First FIR on accelerator
  //
  *accel_ctrl = 1;
  *dma_sr=(volatile long long*)((long)coef & 0x1fffffff);; // memctl coeff address
  *dma_dr=(volatile long long*)((long)accel_w & 0x1fffffff); // fir coeff address
  *dma_len=32; // starts transfer
  clobber();

  *accel_ctrl = 2;
  *dma_sr=(volatile long long*)((long)input & 0x1fffffff);
  *dma_dr=(volatile long long*)((long)accel_x & 0x1fffffff);
  *dma_len=32; // starts transfer
  clobber();

  *dma_sr=(volatile long long*)((long)accel_z & 0x1fffffff);
  *dma_dr=(volatile long long*)((long)output & 0x1fffffff);
  *dma_len=32; // starts transfer
  clobber();

  *dma_sr=(volatile long long*)((long)input+0x20 & 0x1fffffff);
  *dma_dr=(volatile long long*)((long)accel_x & 0x1fffffff);
  *dma_len=32; // starts transfer
  clobber();

  *dma_sr=(volatile long long*)((long)accel_z & 0x1fffffff);
  *dma_dr=(volatile long long*)((long)output+0x20 & 0x1fffffff);
  *dma_len=32; // starts transfer
  clobber();

  // Second FIR on accelerator
  *accel_ctrl = 0xFF; // reset internal variables to start new operation
  // while(*accel_st!=0xFF);
  *accel_ctrl = 1;
  *dma_sr=(volatile long long*)((long)coef+0x20 & 0x1fffffff);; // memctl coeff address
  *dma_dr=(volatile long long*)((long)accel_w & 0x1fffffff); // fir coeff address
  *dma_len=32; // starts transfer
  clobber();
  *accel_ctrl = 2;
  // 32 bytes input and output
  *dma_sr=(volatile long long*)((long)input+0x40 & 0x1fffffff);
  *dma_dr=(volatile long long*)((long)accel_x & 0x1fffffff);
  *dma_len=32; // starts transfer
  clobber();

  *dma_sr=(volatile long long*)((long)accel_z & 0x1fffffff);
  *dma_dr=(volatile long long*)((long)output+0x40 & 0x1fffffff);
  *dma_len=32; // starts transfer
  clobber();
  // 32 bytes input and output
  *dma_sr=(volatile long long*)((long)input+0x60 & 0x1fffffff);
  *dma_dr=(volatile long long*)((long)accel_x & 0x1fffffff);
  *dma_len=32; // starts transfer
  clobber();

  *dma_sr=(volatile long long*)((long)accel_z & 0x1fffffff);
  *dma_dr=(volatile long long*)((long)output+0x60 & 0x1fffffff);
  *dma_len=32; // starts transfer
  clobber();
  // 32 bytes input and output
  *dma_sr=(volatile long long*)((long)input+0x80 & 0x1fffffff);
  *dma_dr=(volatile long long*)((long)accel_x & 0x1fffffff);
  *dma_len=32; // starts transfer
  clobber();

  *dma_sr=(volatile long long*)((long)accel_z & 0x1fffffff);
  *dma_dr=(volatile long long*)((long)output+0x80 & 0x1fffffff);
  *dma_len=32; // starts transfer
  clobber();
  




  // Error check for both FIR filter operations
  total_error=0;
  for (n=0; n<(TSTEP1+TSTEP2); n++) {
    // for (n=0; n<(TSTEP1); n++) {
//    printf("expected[%d]=%x, output[%d]=%x\n",n,expected[n],n,output[n]);
    error=expected[n]-output[n];              // Error for this time-step
    total_error+=(error<0)?(-error):(error);  // Absolute value
    // Uncomment the next line for a detailed error check
    // printf("cpu main k: %d output: %d expected %d\n",n,output[n],expected[n]);
  }

//  printf("cpu main FIR total error: %d\n",total_error);

      	*accel_ctrl=(volatile long long)0x0f;       // Exit
}
