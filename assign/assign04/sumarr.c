#include <stdio.h>

unsigned sumarr_unsigned(unsigned *arr, unsigned len) {
  unsigned sum = 0;
  for (unsigned i = 0; i < len; i++) {
    sum += arr[i];
  }
  return sum;
}

float sumarr_float(float *arr, unsigned len) {
  float sum = 0.0f;
  for (unsigned i = 0; i < len; i++) {
    sum += arr[i];
  }
  return sum;
}

int main(int argc, char **argv) {
  unsigned a[] = { 1, 2, 3 };
  float b[] = { 4.0, 5.0, 6.0 };
  printf("%u\n", sumarr_unsigned(a, 3));
  printf("%f\n", sumarr_float(b, 3));
  return 0;
}
