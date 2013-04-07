#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <assert.h>

#include "network.cuh"

#define N_NUT 27

void test_nutrients(Network *n) {
  char name[23], line[LINE_MAX];
  int energy[N_NUT], protein[N_NUT], fat[N_NUT], calcium[N_NUT];
  float iron[N_NUT];
  Neuron *neu;
  int *rate, i;

  for (i=0; i<N_NUT; i++) {
    fgets(line, LINE_MAX, stdin);
    sscanf(line, "23C%d%d%d%d%f", &name[i], &energy[i], &protein[i],
        &fat[i], &calcium[i], &iron[i]);
  }

  for (i=0; i<N_NUT; i++) {
    // Reset inputs 
    neu = n->neurons(true);
    neu[0].input = 0;
    neu[1].input = 0;
    neu[2].input = 0;
    neu[3].input = 0;
    neu[4].input = 0;
   
    for (int i=0; i<1000; i++) {
      if (i == 100) {
        // Allow time for network to stabilize
        neu = n->neurons(true);
        neu[0].input = energy[i] * 1.0;
        neu[1].input = protein[i] * 1.0;
        neu[2].input = fat[i]* 1.0;
        neu[3].input = calcium[i] * 0.01;
        neu[4].input = iron[i];

        n->neurons(neu, true);
      }
      
      n->time_step();
      n->find_firing_neurons();
      n->update_current();
      n->update_potential();
    }

    rate = n->spiking_rate(true);
    neu = n->neurons(true);
    printf("%d, %d\n", rate[11], rate[12]);
  };
}

int main() {
  Network *n = new Network(13, 42);
  n->randomize_weights();
  n->build_connections(5,6,2);

  test_nutrients(n);
}
