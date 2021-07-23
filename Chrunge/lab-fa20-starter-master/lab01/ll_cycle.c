#include <stddef.h>
#include "ll_cycle.h"

int ll_has_cycle(node *head) {
    /* your code here */
    /*head->next == (*head).next */
    node *tortoies;
    node *hare;

    if (NULL != head && NULL != head->next) {
        tortoies = head->next; 
        hare = head->next->next;
    }

    while (NULL != hare) {
        if (hare == tortoies) {
            return 1;
        }
        hare = hare->next;
        if (NULL == hare) {
            return 0;
        }
        hare = hare->next;
        tortoies = tortoies->next;
    }
    return 0;
}