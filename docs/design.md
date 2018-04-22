
The trade's status goes through these stages:
1) unconfirmed
2) unmatched
3) partially matched
4) matched


during step 1 the trade is owned by the unconfirmed gen_server.

during steps 2 and 3 the trade is owned by the order_book gen_server.

During step 4 the trade is owned by the trade history gen_server.

Additionally, we have a gen_server for knowing which stage the trade is in so we know where to look it up.