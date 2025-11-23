c";
#pragma pack(push, 1)
typedef struct t_SHProductInfo_HDB{
   uint8_t ISIN[12];
   uint8_t UpdateTime[8];
   uint8_t Symbol[32];
   uint8_t EnglishName[10];
   uint8_t UnderlyingSecurityID[6];
   uint8_t MarketType[4];
   uint8_t SecurityType[6];
   uint8_t SecuritySubType[3];
   uint8_t Currency[3];
   uint64_t ParValue;
   uint64_t UnlistedFloatShareQuantity;
   uint32_t LastTradeDate;
   uint32_t ListDate;
   uint32_t SETNo;
   uint64_t BuyQtyUnit;
   uint64_t SellQtyUnit;
   uint64_t QtyLowerLimit;
   uint64_t QtyUpperLimit;
   uint64_t PrevClosePx;
   uint64_t PriceTick;
   uint8_t LimitType;
   uint64_t LimitUpAbsolute;
   uint64_t LimitDownAbsolute;
   uint64_t XR;
   uint64_t XD;
   uint8_t CrdBuyUnderlying;
   uint8_t CrdSellUnderlying;
   uint8_t Status[20];
   uint64_t MarketQtyLowerLimit;
   uint64_t MarketQtyUpperLimit;
   uint8_t ChineseName[128];
   uint8_t MEMO[400];
}SHProductInfo_HDB;

typedef struct t_SHOptionInfo_HDB{
   uint8_t RFStreamID[5];
   uint8_t ContractID[41];
   uint8_t ContractSymbol[80];
   uint8_t UnderlyingSecurityID[6];
   uint8_t UnderlyingSecuritySymbol[32];
   uint8_t UnderlyingType[3];
   uint8_t OptionType;
   uint8_t CallOrPut;
   uint64_t ContractMultiplierUnit;
   uint64_t ExercisePrice;
   uint32_t StartDate;
   uint32_t EndDate;
   uint32_t ExerciseDate;
   uint32_t DeliveryDate;
   uint32_t ExpireDate;
   uint8_t UpdateVersion;
   uint64_t TotalLongPosition;
   uint64_t SecurityClosePx;
   uint64_t SettlPrice;
   uint64_t UnderlyingPreClosePx;
   uint8_t PriceLimitType;
   uint64_t DailyPriceUpLimit;
   uint64_t DailyPriceDownLimit;
   uint64_t MarginUnit;
   uint64_t MarginRatioParam1;
   uint64_t MarginRatioParam2;
   uint64_t RoundLot;
   uint64_t LmtOrdMinFloor;
   uint64_t LmtOrdMaxFloor;
   uint64_t MktOrdMinFloor;
   uint64_t MktOrdMaxFloor;
   uint64_t TickSize;
   uint8_t SecurityStatusFlag[8];
   uint32_t AutoSplitDate;
   uint8_t UnderlyingSymbolEx[40];
}SHOptionInfo_HDB;

typedef struct t_SZPStock_HDB{
   uint8_t SecurityIDSource[4];
   uint8_t Symbol[160];
   uint8_t SymbolEx[160];
   uint8_t EnglishName[40];
   uint8_t ISIN[12];
   uint8_t UnderlyingSecurityID[8];
   uint8_t UnderlyingSecurityIDSource[4];
   uint64_t ListDate;
   uint32_t SecurityType;
   uint8_t Currency[4];
   uint64_t QtyUnit;
   uint8_t DayTrading;
   uint64_t PrevClosePx;
   uint32_t SecurityStatus[13];
   uint64_t OutstandingShare;
   uint64_t PublicFloatShareQuantity;
   uint64_t ParValue;
   uint8_t GageFlag;
   uint64_t GageRatio;
   uint8_t CrdBuyUnderlying;
   uint8_t CrdSellUnderlying;
   int32_t PriceCheckMode;
   uint8_t PledgeFlag;
   uint64_t ContractMultiplier;
   uint8_t RegularShare[8];
   uint8_t QualificationFalg;
   uint32_t QualificationClass;
   uint64_t Interest;
   uint8_t OfferingFlag;
}SZPStock_HDB;

typedef struct t_SZStock_HDB{
   uint8_t SecurityIDSource[4];
   uint8_t Symbol[160];
   uint8_t SymbolEx[160];
   uint8_t EnglishName[40];
   uint8_t ISIN[12];
   uint8_t UnderlyingSecurityID[8];
   uint8_t UnderlyingSecurityIDSource[4];
   uint64_t ListDate;
   uint32_t SecurityType;
   uint8_t Currency[4];
   uint64_t QtyUnit;
   uint8_t DayTrading;
   uint64_t PrevClosePx;
   uint32_t SecurityStatus[13];
   uint64_t OutstandingShare;
   uint64_t PublicFloatShareQuantity;
   uint64_t ParValue;
   uint8_t GageFlag;
   uint64_t GageRatio;
   uint8_t CrdBuyUnderlying;
   uint8_t CrdSellUnderlying;
   int32_t PriceCheckMode;
   uint8_t PledgeFlag;
   uint64_t ContractMultiplier;
   uint8_t RegularShare[8];
   uint8_t QualificationFalg;
   uint32_t QualificationClass;
   uint8_t IndustryClassification[4];
   uint64_t PreviousYearProfitPerShare;
   uint64_t CurrentYearProfitPerShare;
   uint8_t OfferingFlag;
   int32_t Attribute;
   uint8_t NoProfit;
   uint8_t WeightedVotingRights;
   uint8_t IsRegistration;
   uint8_t IsVIE;
}SZStock_HDB;

typedef struct t_SZFund_HDB{
   uint8_t SecurityIDSource[4];
   uint8_t Symbol[160];
   uint8_t SymbolEx[160];
   uint8_t EnglishName[40];
   uint8_t ISIN[12];
   uint8_t UnderlyingSecurityID[8];
   uint8_t UnderlyingSecurityIDSource[4];
   uint64_t ListDate;
   uint32_t SecurityType;
   uint8_t Currency[4];
   uint64_t QtyUnit;
   uint8_t DayTrading;
   uint64_t PrevClosePx;
   uint32_t SecurityStatus[13];
   uint64_t OutstandingShare;
   uint64_t PublicFloatShareQuantity;
   uint64_t ParValue;
   uint8_t GageFlag;
   uint64_t GageRatio;
   uint8_t CrdBuyUnderlying;
   uint8_t CrdSellUnderlying;
   int32_t PriceCheckMode;
   uint8_t PledgeFlag;
   uint64_t ContractMultiplier;
   uint8_t RegularShare[8];
   uint8_t QualificationFalg;
   uint32_t QualificationClass;
   uint64_t NAV;
}SZFund_HDB;

typedef struct t_SZBond_HDB{
   uint8_t SecurityIDSource[4];
   uint8_t Symbol[160];
   uint8_t SymbolEx[160];
   uint8_t EnglishName[40];
   uint8_t ISIN[12];
   uint8_t UnderlyingSecurityID[8];
   uint8_t UnderlyingSecurityIDSource[4];
   uint64_t ListDate;
   uint32_t SecurityType;
   uint8_t Currency[4];
   uint64_t QtyUnit;
   uint8_t DayTrading;
   uint64_t PrevClosePx;
   uint32_t SecurityStatus[13];
   uint64_t OutstandingShare;
   uint64_t PublicFloatShareQuantity;
   uint64_t ParValue;
   uint8_t GageFlag;
   uint64_t GageRatio;
   uint8_t CrdBuyUnderlying;
   uint8_t CrdSellUnderlying;
   int32_t PriceCheckMode;
   uint8_t PledgeFlag;
   uint64_t ContractMultiplier;
   uint8_t RegularShare[8];
   uint8_t QualificationFalg;
   uint32_t QualificationClass;
   uint64_t CouponRate;
   uint64_t IssuePrice;
   uint64_t Interest;
   uint32_t InterestAccrualDate;
   uint32_t MaturityDate;
   uint8_t OfferingFlag;
   uint8_t SwapFlag;
   uint8_t PutbackFlag;
   uint8_t PutbackCancelFlag;
}SZBond_HDB;

typedef struct t_SZWarrant_HDB{
   uint8_t SecurityIDSource[4];
   uint8_t Symbol[160];
   uint8_t SymbolEx[160];
   uint8_t EnglishName[40];
   uint8_t ISIN[12];
   uint8_t UnderlyingSecurityID[8];
   uint8_t UnderlyingSecurityIDSource[4];
   uint64_t ListDate;
   uint32_t SecurityType;
   uint8_t Currency[4];
   uint64_t QtyUnit;
   uint8_t DayTrading;
   uint64_t PrevClosePx;
   uint32_t SecurityStatus[13];
   uint64_t OutstandingShare;
   uint64_t PublicFloatShareQuantity;
   uint64_t ParValue;
   uint8_t GageFlag;
   uint64_t GageRatio;
   uint8_t CrdBuyUnderlying;
   uint8_t CrdSellUnderlying;
   int32_t PriceCheckMode;
   uint8_t PledgeFlag;
   uint64_t ContractMultiplier;
   uint8_t RegularShare[8];
   uint8_t QualificationFalg;
   uint32_t QualificationClass;
   uint64_t ExercisePrice;
   uint64_t ExerciseRatio;
   uint32_t ExerciesBeginDate;
   uint32_t ExerciesEndDate;
   uint8_t CallOrPut;
   uint8_t DeliveryType;
   uint64_t ClearingPrice;
   uint8_t ExerciseType;
   uint32_t LastTradeDay;
}SZWarrant_HDB;

typedef struct t_SZRepo_HDB{
   uint8_t SecurityIDSource[4];
   uint8_t Symbol[160];
   uint8_t SymbolEx[160];
   uint8_t EnglishName[40];
   uint8_t ISIN[12];
   uint8_t UnderlyingSecurityID[8];
   uint8_t UnderlyingSecurityIDSource[4];
   uint64_t ListDate;
   uint32_t SecurityType;
   uint8_t Currency[4];
   uint64_t QtyUnit;
   uint8_t DayTrading;
   uint64_t PrevClosePx;
   uint32_t SecurityStatus[13];
   uint64_t OutstandingShare;
   uint64_t PublicFloatShareQuantity;
   uint64_t ParValue;
   uint8_t GageFlag;
   uint64_t GageRatio;
   uint8_t CrdBuyUnderlying;
   uint8_t CrdSellUnderlying;
   int32_t PriceCheckMode;
   uint8_t PledgeFlag;
   uint64_t ContractMultiplier;
   uint8_t RegularShare[8];
   uint8_t QualificationFalg;
   uint32_t QualificationClass;
   uint32_t ExpirationDays;
}SZRepo_HDB;

typedef struct t_SZOption_HDB{
   uint8_t SecurityIDSource[4];
   uint8_t Symbol[160];
   uint8_t SymbolEx[160];
   uint8_t EnglishName[40];
   uint8_t ISIN[12];
   uint8_t UnderlyingSecurityID[8];
   uint8_t UnderlyingSecurityIDSource[4];
   uint64_t ListDate;
   uint32_t SecurityType;
   uint8_t Currency[4];
   uint64_t QtyUnit;
   uint8_t DayTrading;
   uint64_t PrevClosePx;
   uint32_t SecurityStatus[13];
   uint64_t OutstandingShare;
   uint64_t PublicFloatShareQuantity;
   uint64_t ParValue;
   uint8_t GageFlag;
   uint64_t GageRatio;
   uint8_t CrdBuyUnderlying;
   uint8_t CrdSellUnderlying;
   int32_t PriceCheckMode;
   uint8_t PledgeFlag;
   uint64_t ContractMultiplier;
   uint8_t RegularShare[8];
   uint8_t QualificationFalg;
   uint32_t QualificationClass;
   uint8_t CallOrPut;
   uint32_t ListType;
   uint32_t DeliveryDay;
   uint32_t DeliveryMonth;
   uint8_t DeliveryType;
   uint32_t ExerciesBeginDate;
   uint32_t ExerciesEndDate;
   uint64_t ExercisePrice;
   uint8_t ExerciseType;
   uint32_t LastTradeDay;
   uint32_t AdjustTimes;
   uint64_t ContractUnit;
   uint64_t PrevClearingPrice;
   uint64_t ContractPosition;
}SZOption_HDB;

typedef struct t_SZReits_HDB{
   uint8_t SecurityIDSource[4];
   uint8_t Symbol[160];
   uint8_t SymbolEx[160];
   uint8_t EnglishName[40];
   uint8_t ISIN[12];
   uint8_t UnderlyingSecurityID[8];
   uint8_t UnderlyingSecurityIDSource[4];
   uint64_t ListDate;
   uint32_t SecurityType;
   uint8_t Currency[4];
   uint64_t QtyUnit;
   uint8_t DayTrading;
   uint64_t PrevClosePx;
   uint32_t SecurityStatus[13];
   uint64_t OutstandingShare;
   uint64_t PublicFloatShareQuantity;
   uint64_t ParValue;
   uint8_t GageFlag;
   uint64_t GageRatio;
   uint8_t CrdBuyUnderlying;
   uint8_t CrdSellUnderlying;
   int32_t PriceCheckMode;
   uint8_t PledgeFlag;
   uint64_t ContractMultiplier;
   uint8_t RegularShare[8];
   uint8_t QualificationFalg;
   uint32_t QualificationClass;
   uint32_t MaturityDate;
}SZReits_HDB;

typedef struct t_SZTenderer_HDB{
   uint8_t TendererID[6];
   uint8_t TendererName[200];
   uint64_t OfferingPrice;
   uint32_t BeginDate;
   uint32_t EndDate;
}SZTenderer_HDB;

typedef struct t_RightsIssue_HDB{
   uint8_t SecurityIDSource[4];
   uint8_t Symbol[160];
   uint8_t SymbolEx[160];
   uint8_t EnglishName[40];
   uint8_t UnderlyingSecurityID[8];
   uint8_t UnderlyingSecurityIDSource[4];
   uint64_t Price;
   uint64_t Unit;
}RightsIssue_HDB;

typedef struct t_DerivativeAuction_HDB{
   uint8_t SecurityIDSource[4];
   uint64_t BuyQtyUpperLimit;
   uint64_t SellQtyUpperLimit;
   uint64_t MarketBuyQtyUpperLimit;
   uint64_t MarketSellQtyUpperLimit;
   uint64_t QuoteBuyQtyUpperLimit;
   uint64_t QuoteSellQtyUpperLimit;
   uint64_t BuyQtyUnit;
   uint64_t SellQtyUnit;
   uint64_t PriceTick;
   uint64_t PriceUpperLimit;
   uint64_t PriceLowerLimit;
   uint64_t LastSellMargin;
   uint64_t SellMargin;
   uint64_t MarginRatioParam1;
   uint64_t MarginRatioParam2;
   uint8_t MarketMakerFlag;
}DerivativeAuction_HDB;

typedef struct t_CashAuction_HDB{
   uint8_t SecurityIDSource[4];
   uint64_t BuyQtyUpperLimit;
   uint64_t SellQtyUpperLimit;
   uint64_t BuyQtyUnit;
   uint64_t SellQtyUnit;
   uint64_t MarketBuyQtyUpperLimit;
   uint64_t MarketSellQtyUpperLimit;
   uint64_t MarketBuyQtyUnit;
   uint64_t MarketSellQtyUnit;
   uint64_t PriceTick;
   uint8_t MarketMakerFlag;
}CashAuction_HDB;

typedef struct t_PriceLimitSetting_HDB{
   uint8_t Type;
   uint8_t HasPriceLimit;
   uint8_t ReferPriceType;
   uint8_t LimitType;
   uint64_t LimitUpRate;
   uint64_t LimitDownRate;
   uint64_t LimitUpAbsolute;
   uint64_t LimitDownAbsolute;
   uint8_t HasAuctionLimit;
   uint8_t AuctionLimitType;
   uint8_t AuctionReferPriceType;
   uint64_t AuctionUpDownRate;
   uint64_t AuctionUpDownAbsolute;
}PriceLimitSetting_HDB;

typedef struct t_SZCombinationStrategy_HDB{
   uint8_t StrategyID[8];
   uint32_t AutoSplitDay;
}SZCombinationStrategy_HDB;

typedef struct t_TInstrument_HDB{
   uint8_t InstrumentName[40];
   uint64_t UpLimitPrice;
   uint64_t LowLimitPrice;
   int64_t VolumeMultiple;
   int64_t PriceTick;
   uint32_t OpenDate;
   uint32_t ExpireDate;
   uint8_t ExchangeID[9];
   int64_t LongMarginRatio;
   int64_t ShortMarginRatio;
}TInstrument_HDB;

typedef struct t_BJNQXX_HDB{
   uint8_t ShortName[16];
   uint8_t EnglishName[20];
   uint8_t BaseCode[6];
   uint8_t ISINCode[12];
   int32_t TradeUnit;
   uint8_t Industry[5];
   uint8_t Currency[2];
   int64_t ShareVal;
   int64_t Capital;
   int64_t NonRestCap;
   int64_t LastYearProfit;
   int64_t CurYearProfit;
   int64_t HandlingRate;
   int64_t StampDutyRate;
   int64_t TransferRate;
   uint32_t ListDate;
   uint32_t StartDate;
   uint32_t EndDate;
   int64_t MaxNumber;
   int32_t BuyNumber;
   int32_t SellNumber;
   int64_t MinNumber;
   int64_t PriceTick;
   int64_t FirstLimintParam;
   int64_t FollowLimitParam;
   int32_t LimitParamKind;
   int64_t HighLimitPrc;
   int64_t LowLimitPrc;
   int64_t BlockHighLimit;
   int64_t BlockLowLimit;
   uint8_t CompoFlag;
   int32_t EquiRatio;
   uint8_t TradeStatus;
   uint8_t SecLevel;
   uint8_t TradeType;
   int32_t MarketMakerNum;
   uint8_t HaltFlag;
   uint8_t QxFlag;
   uint8_t NetVoteFlag;
   uint8_t OtherBusStatus[4];
   int32_t UpdateTime;
}BJNQXX_HDB;

typedef struct t_SecurityInfo_HDB{
   uint8_t ISIN_CODE[40];
   uint8_t EXCHMARKET_CODE[40];
   uint8_t EXCHMARKET_ANN_CODE[40];
   uint8_t INFO_NAME_NATIONAL[40];
   uint8_t INFO_FULLNAME[300];
   uint8_t INFO_FULLNAME_ENG[200];
   uint32_t SECURITYCLASS;
   uint32_t SECURITYSUBCLASS;
   uint8_t SECURITYTYPE[10];
   uint8_t INFO_COUNTRYCODE[10];
   uint8_t INFO_EXCHANGE_ENG[40];
   uint8_t INFO_EXCHANGE[40];
   uint8_t INFO_CODE[10];
   uint8_t INFO_COMPCODE[10];
   uint8_t SECURITY_STATUS;
   uint8_t CRNCY_CODE[10];
   double INFO_CURPAR;
   double MIN_PRC_CHG_UNIT;
   double INFO_UNITPERLOT;
   uint8_t INFO_LISTDATE[8];
   uint8_t INFO_DELISTDATE[8];
   double INFO_LISTPRICE;
   uint32_t INFO_TYPECODE;
   uint8_t CONTRACT_ID[10];
   uint8_t INFO_LISTBOARDNAME[10];
   uint32_t TRADING_STATUS;
}SecurityInfo_HDB;

#pragma pack(pop)"
SHProductInfo = c"struct t_SHProductInfo_HDB"
SHOptionInfo = c"struct t_SHOptionInfo_HDB"
SZPStock = c"struct t_SZPStock_HDB"
SZStock = c"struct t_SZStock_HDB"
SZFund = c"struct t_SZFund_HDB"
SZBond = c"struct t_SZBond_HDB"
SZWarrant = c"struct t_SZWarrant_HDB"
SZRepo = c"struct t_SZRepo_HDB"
SZOption = c"struct t_SZOption_HDB"
SZReits = c"struct t_SZReits_HDB"
SZTenderer = c"struct t_SZTenderer_HDB"
RightsIssue = c"struct t_RightsIssue_HDB"
DerivativeAuction = c"struct t_DerivativeAuction_HDB"
CashAuction = c"struct t_CashAuction_HDB"
PriceLimitSetting = c"struct t_PriceLimitSetting_HDB"
SZCombinationStrategy = c"struct t_SZCombinationStrategy_HDB"
TInstrument = c"struct t_TInstrument_HDB"
BJNQXX = c"struct t_BJNQXX_HDB"
SecurityInfo = c"struct t_SecurityInfo_HDB"
baseinfo = (SHProductInfo, SHOptionInfo, SZPStock, SZStock, SZFund, SZBond, SZWarrant, SZRepo, SZOption, SZReits, SZTenderer, RightsIssue, DerivativeAuction, CashAuction, PriceLimitSetting, SZCombinationStrategy, TInstrument, BJNQXX, SecurityInfo, )
