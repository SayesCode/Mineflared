#include "rules.h"
#include <assert.h>
#include <stdio.h>

int main() {
    load_firewall_rules("../config/firewall.conf");
    
    assert(is_allowed(7844, 80) == 1);        // Port 7844 to 80 should be allowed
    assert(is_allowed(7844, 25565) == 1);     // Port 7844 to 25565 should be allowed
    assert(is_allowed(7844, 22) == 0);        // Port 7844 to 22 should be blocked
    
    printf("All rule tests passed.\n");
    return 0;
}
