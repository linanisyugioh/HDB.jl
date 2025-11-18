c";
#pragma pack(push, 1)
typedef struct t_ZZZSIndexTick{
   uint16_t record_type;
   int32_t time;
   uint8_t stand_by[5];
   uint8_t index_code[7];
   uint8_t index_referred[21];
   uint16_t market_code;
   uint64_t realtime_index;
   uint64_t open_value_of_today;
   uint64_t maximum_of_day;
   uint64_t minimum_of_day;
   uint64_t close_value_of_today;
   uint64_t close_value_of_yesterday;
   int64_t rise_and_fall;
   int64_t rise_and_fall_range;
   uint64_t match_volume;
   uint64_t match_amount;
   uint64_t exchange_rate;
   uint16_t money_type;
   uint32_t index_serial;
   uint64_t close_value_of_today2;
   uint64_t close_value_of_today3;
}ZZZSIndexTick;

typedef struct t_ZZZSEtfIopv{
   uint16_t record_type;
   int32_t time;
   uint8_t stand_by[5];
   uint8_t stock_code[9];
   uint8_t stock_name[9];
   uint16_t market_code;
   int64_t iopv;
}ZZZSEtfIopv;

typedef struct t_IndexCodeInfo{
   uint16_t record_type;
   int32_t time;
   uint8_t stand_by[5];
   uint8_t stock_code[9];
   uint8_t stock_name[9];
   uint16_t market_code;
   int64_t iopv;
}IndexCodeInfo;

#pragma pack(pop)"
ZZZSIndexTick = c"struct t_ZZZSIndexTick"
ZZZSEtfIopv = c"struct t_ZZZSEtfIopv"
IndexCodeInfo = c"struct t_IndexCodeInfo"
zzzsdata = (ZZZSIndexTick, ZZZSEtfIopv, IndexCodeInfo, )
