#include "utils.h"
#include "logging.h"
#include "rules.h"
#include <stdio.h>
#include <unistd.h> // for sleep()

void monitor_traffic() {
    while (1) {
        // Simulate packet monitoring
        unsigned char packet[1024];
        int src_port = 7844;
        int dest_port = 80;  // Example: HTTP connection
        size_t packet_size = sizeof(packet);

        // Check if the connection between ports is allowed
        if (is_allowed(src_port, dest_port)) {
            // Log packets that follow the rules
            log_packet_info(src_port, dest_port, packet_size);
        } else {
            // Connection not allowed, alert
            printf("Connection blocked: %d -> %d\n", src_port, dest_port);
        }

        // Check for port 25565
        dest_port = 25565;
        if (is_allowed(src_port, dest_port)) {
            log_packet_info(src_port, dest_port, packet_size);
        } else {
            printf("Connection blocked: %d -> %d\n", src_port, dest_port);
        }

        // Add a delay to avoid overloading the system
        sleep(1);  // Sleep for 1 second before checking again
    }
}
