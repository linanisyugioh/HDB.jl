c";
#pragma pack(push, 1)
typedef struct t_SecurityTick_HDB{
   int32_t time;
   int32_t status;
   uint32_t pre_close;
   uint32_t open;
   uint32_t high;
   uint32_t low;
   uint32_t match;
   uint32_t ask_price[10];
   uint32_t ask_vol[10];
   uint32_t bid_price[10];
   uint32_t bid_vol[10];
   uint32_t num_trades;
   int64_t volume;
   int64_t turnover;
   int64_t total_bid_vol;
   int64_t total_ask_vol;
   uint32_t weighted_avg_bid_price;
   uint32_t weighted_avg_ask_price;
   int32_t iopv;
   int32_t yield_to_maturity;
   uint32_t high_limited;
   uint32_t low_limited;
   uint8_t prefix[4];
   int32_t syl1;
   int32_t syl2;
   int32_t sd2;
   uint8_t trading_phase_code[8];
   int32_t pre_iopv;
}SecurityTick_HDB;

typedef struct t_IndexTick_HDB{
   int32_t time;
   int32_t open;
   int32_t high;
   int32_t low;
   int32_t match;
   int64_t volume;
   int64_t turnover;
   uint32_t pre_close;
}IndexTick_HDB;

typedef struct t_FuturesTick_HDB{
   int32_t time;
   int32_t status;
   int64_t pre_open_interest;
   int64_t pre_close;
   int64_t pre_settle_price;
   int64_t open;
   int64_t high;
   int64_t low;
   int64_t match;
   int64_t volume;
   int64_t turnover;
   int64_t open_interest;
   int64_t close;
   int64_t settle_price;
   int64_t high_limited;
   int64_t low_limited;
   int32_t pre_delta;
   int32_t curr_delta;
   int64_t ask_price[5];
   uint32_t ask_vol[5];
   int64_t bid_price[5];
   uint32_t bid_vol[5];
   uint8_t trading_status;
}FuturesTick_HDB;

typedef struct t_OptionsTick_HDB{
   int32_t data_timestamp;
   int64_t pre_settle_price;
   int64_t settle_price;
   int64_t open;
   int64_t high;
   int64_t low;
   int64_t match;
   int64_t auction_price;
   int64_t auction_qty;
   int64_t total_long_position;
   int64_t bid_vol[5];
   int64_t bid_price[5];
   int64_t ask_vol[5];
   int64_t ask_price[5];
   int64_t volume;
   int64_t turnover;
   uint8_t trading_phase_code[8];
   uint8_t transact_time_only[12];
}OptionsTick_HDB;

typedef struct t_SHStepTrade_HDB{
   int32_t trade_index;
   int32_t trade_channel;
   int32_t trade_time;
   int32_t trade_price;
   int64_t trade_qty;
   int64_t trade_money;
   int64_t trade_buy_no;
   int64_t trade_sell_no;
   uint8_t bs_flag;
   uint8_t res[3];
   int64_t biz_index;
}SHStepTrade_HDB;

typedef struct t_SZStepTrade_HDB{
   uint16_t channel_no;
   int64_t appl_seq_num;
   uint8_t md_stream_id[3];
   int64_t bid_appl_seq_num;
   int64_t offer_appl_seq_num;
   uint8_t security_id[8];
   uint8_t security_id_source[4];
   int64_t last_px;
   int64_t last_qty;
   uint8_t exec_type;
   int64_t transact_time;
}SZStepTrade_HDB;

typedef struct t_SZStepOrder_HDB{
   uint16_t channel_no;
   int64_t appl_seq_num;
   uint8_t md_stream_id[3];
   uint8_t security_id[8];
   uint8_t security_id_source[4];
   int64_t price;
   int64_t order_qty;
   uint8_t side;
   int64_t transact_time;
   uint8_t ord_type;
}SZStepOrder_HDB;

typedef struct t_OrderQueueItem_HDB{
   int32_t time;
   int32_t side;
   int32_t price;
   int32_t order_num;
   int32_t item_num;
   int32_t volume[200];
}OrderQueueItem_HDB;

typedef struct t_SZOptionsTick_HDB{
   int32_t time;
   uint16_t channel_no;
   uint8_t md_stream_id[3];
   uint8_t security_id[8];
   uint8_t security_id_source[4];
   uint8_t trading_phase_code[8];
   int64_t prev_close_px;
   int64_t num_trades;
   int64_t total_volume_trade;
   int64_t total_value_trade;
   int64_t last_price;
   int64_t open_price;
   int64_t high_price;
   int64_t low_price;
   int64_t buy_avg_price;
   int64_t buy_volume_trade;
   int64_t sell_avg_price;
   int64_t sell_volume_trade;
   int64_t offer_price[10];
   int64_t offer_qty[10];
   int64_t bid_price[10];
   int64_t bid_qty[10];
   int64_t price_upper_limit;
   int64_t price_lower_limit;
   int64_t contract_position;
}SZOptionsTick_HDB;

typedef struct t_SHStepOrder_HDB{
   int32_t order_index;
   int32_t order_channel;
   int32_t order_time;
   uint8_t order_type;
   uint8_t res1[3];
   int64_t order_no;
   int32_t order_price;
   int64_t balance;
   uint8_t order_bs_flag;
   uint8_t res2[3];
   int64_t biz_index;
}SHStepOrder_HDB;

typedef struct t_FPSHStepTrade_HDB{
   int32_t trade_index;
   int32_t trade_channel;
   int32_t trade_time;
   int32_t trade_price;
   int64_t trade_qty;
   int64_t trade_money;
   int64_t trade_buy_no;
   int64_t trade_sell_no;
   uint8_t bs_flag;
   uint8_t res[3];
   int64_t biz_index;
}FPSHStepTrade_HDB;

typedef struct t_CodeInfo_HDB{
   int32_t sec_type;
   uint8_t sec_name[24];
   int32_t date;
   uint32_t high_limited;
   uint32_t low_limited;
   int32_t multiplier;
   int32_t margin_ratio;
   int32_t price_tick;
   int64_t capital;
   uint32_t cap_change_date;
   uint32_t trade_date_in;
   uint32_t trade_date_out;
   uint8_t is_halt;
   uint32_t margin_unit;
   int32_t margin_ratio_param1;
   int32_t margin_ratio_param2;
   uint8_t sec_name_ext[61];
}CodeInfo_HDB;

#pragma pack(pop)"
SecurityTick = c"struct t_SecurityTick_HDB"
IndexTick = c"struct t_IndexTick_HDB"
FuturesTick = c"struct t_FuturesTick_HDB"
OptionsTick = c"struct t_OptionsTick_HDB"
SHStepTrade = c"struct t_SHStepTrade_HDB"
SZStepTrade = c"struct t_SZStepTrade_HDB"
SZStepOrder = c"struct t_SZStepOrder_HDB"
OrderQueueItem = c"struct t_OrderQueueItem_HDB"
SZOptionsTick = c"struct t_SZOptionsTick_HDB"
SHStepOrder = c"struct t_SHStepOrder_HDB"
FPSHStepTrade = c"struct t_FPSHStepTrade_HDB"
CodeInfo = c"struct t_CodeInfo_HDB"
marketdata = (SecurityTick, IndexTick, FuturesTick, OptionsTick, SHStepTrade, SZStepTrade, SZStepOrder, OrderQueueItem, SZOptionsTick, SHStepOrder, FPSHStepTrade, CodeInfo, )
