c";
#pragma pack(push, 1)
typedef struct t_SecurityKdata{
   uint32_t date;
   int32_t time;
   int64_t pre_close;
   int64_t open;
   int64_t high;
   int64_t low;
   int64_t close;
   int64_t volume;
   int64_t turnover;
   int64_t open_interest;
   int64_t pre_settle_price;
   int64_t settle_price;
}SecurityKdata;

#pragma pack(pop)"
SecurityKdata = c"struct t_SecurityKdata"
bar = (SecurityKdata, )
