#ifndef RULES_H
#define RULES_H

// Checks if the connection is allowed based on the configured rules
int is_allowed(int src_port, int dest_port);

// Loads firewall rules from the configuration file
void load_firewall_rules(const char *config_file);

#endif
