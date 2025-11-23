c";
#pragma pack(push, 1)
typedef struct t_QxData_HDB{
   int32_t date;
   int32_t bonus_ratio;
   int32_t dividend;
   int32_t allot_ratio;
   int32_t allot_price;
   int32_t add_ratio;
   int32_t add_price;
   int32_t factor;
}QxData_HDB;

#pragma pack(pop)"
QxData = c"struct t_QxData_HDB"
fundmentals = (QxData, )
