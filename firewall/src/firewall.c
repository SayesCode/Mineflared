#include "firewall.h"
#include "rules.h"
#include "logging.h"
#include "utils.h"
#include <stdio.h>

void start_firewall() {
    // Load firewall rules from the configuration file
    load_firewall_rules("../config/firewall.conf");
    
    // Start monitoring traffic on port 7844
    printf("Firewall started. Monitoring traffic...\n");
    monitor_traffic(); // This function will run indefinitely
}
