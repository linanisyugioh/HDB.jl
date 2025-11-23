c";
#pragma pack(push, 1)
typedef struct t_Component_HDB{
   uint8_t underlying_symbol[20];
   uint8_t underlying_symbol_source[4];
   uint8_t security_name[64];
   uint8_t substitute_flag;
   int64_t component_qty;
   int32_t premium_ratio;
   int32_t discount_ratio;
   int64_t creation_cash_substitute;
   int64_t redemption_cash_substitute;
   int64_t substitution_cash_amount;
   uint8_t bs_open;
   uint8_t reserved[30];
}Component_HDB;

typedef struct t_ETFInfo_HDB{
   uint8_t version[8];
   uint8_t etf_name[64];
   uint8_t fund_management_company[64];
   uint8_t underlying_index[12];
   int32_t creation_redemption_unit;
   int64_t estimate_cash_component;
   int32_t max_cash_ratio;
   uint8_t publish;
   uint8_t creation;
   uint8_t redemption;
   int32_t sz_record_num;
   int32_t total_record_num;
   int32_t trading_day;
   int32_t pre_trading_day;
   int64_t cash_component;
   int64_t nav_per_cu;
   int32_t nav;
   int64_t dividend_per_cu;
   int64_t creation_limit;
   int64_t redemption_limit;
   int64_t creation_limit_peruser;
   int64_t redemption_Limit_peruser;
   int64_t net_creation_limit;
   int64_t net_redemption_limit;
   int64_t net_creation_limit_peruser;
   int64_t net_redemption_limit_peruser;
   uint8_t all_cash_flag;
   int64_t all_cash_amount;
   int32_t all_cash_premium_rate;
   int32_t all_cash_discount_rate;
   uint8_t rtgs_flag;
   uint8_t reserved[30];
}ETFInfo_HDB;

#pragma pack(pop)"
Component = c"struct t_Component_HDB"
ETFInfo = c"struct t_ETFInfo_HDB"
staticinfo = (Component, ETFInfo, )
