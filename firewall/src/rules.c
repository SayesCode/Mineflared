#include "rules.h"
#include <stdio.h>
#include <string.h>

#define MAX_RULES 10
int allowed_ports[MAX_RULES][2]; // Stores pairs of allowed ports
int rule_count = 0;

void load_firewall_rules(const char *config_file) {
    // Example of simple rule parsing from a configuration file
    allowed_ports[0][0] = 7844; allowed_ports[0][1] = 80;
    allowed_ports[1][0] = 7844; allowed_ports[1][1] = 25565;
    rule_count = 2; // Total number of rules
}

int is_allowed(int src_port, int dest_port) {
    for (int i = 0; i < rule_count; i++) {
        if (allowed_ports[i][0] == src_port && allowed_ports[i][1] == dest_port) {
            return 1;
        }
    }
    return 0;
}
