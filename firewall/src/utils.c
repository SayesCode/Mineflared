#include "utils.h"
#include "logging.h"
#include "rules.h"
#include <stdio.h>

void monitor_traffic() {
    // Simulate packet monitoring
    unsigned char packet[1024];
    int src_port = 7844;
    int dest_port1 = 80;      // Example: HTTP connection
    int dest_port2 = 25565;   // Example: Minecraft server connection
    size_t packet_size = sizeof(packet);

    // Check if the connection from port 7844 to port 80 is allowed
    if (is_allowed(src_port, dest_port1)) {
        // Log packets that follow the rules
        log_packet_info(src_port, dest_port1, packet_size);
    } else {
        // Connection not allowed, alert
        printf("Connection blocked: %d -> %d\n", src_port, dest_port1);
    }

    // Check if the connection from port 7844 to port 25565 is allowed
    if (is_allowed(src_port, dest_port2)) {
        // Log packets that follow the rules
        log_packet_info(src_port, dest_port2, packet_size);
    } else {
        // Connection not allowed, alert
        printf("Connection blocked: %d -> %d\n", src_port, dest_port2);
    }
}
