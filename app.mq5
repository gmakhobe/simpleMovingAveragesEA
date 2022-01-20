//+------------------------------------------------------------------+
//|                                                          app.mq5 |
//|                                                  Given Makhobela |
//|                                      https://github.com/gmakhobe |
//+------------------------------------------------------------------+
#property copyright "Given Makhobela"
#property link      "https://github.com/gmakhobe"
#property version   "1.00"

#include "./mylib.mqh"

MqlParam mqlParams[];
int bearishEmaHandler;
int bullishEmaHandler;
int bullishEmaPeriod = 20;
int bearishEmaPeriod = 50;
int emaShift = 0;
double bearishMa = 0;
double bullishMa = 0;
double stoplossOnEntry = 10;
double tradeStopTrailer = 30;
double tradePipsToMove = 10;
double tradeLotSize = 0.15;
bool maParamsInit = true;


int OnInit()
{
   // Initialize EMA
   simpleMovingAverageIndicatorInit(mqlParams, Symbol(),bullishEmaHandler, bullishEmaPeriod, emaShift);
   simpleMovingAverageIndicatorInit(mqlParams, Symbol(),bearishEmaHandler, bearishEmaPeriod, emaShift);

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   
}

void OnTick()
{
   double emaBullishValue[];
   double emaBearishValue[];
   int numberOfOpenedPositions = PositionsTotal();
   
   simpleMovingAverageIndicatorData(bullishEmaHandler, emaBullishValue, 1);
   simpleMovingAverageIndicatorData(bearishEmaHandler, emaBearishValue, 1);
   
   if (numberOfOpenedPositions < 4){
      maTrader(emaBearishValue[0], emaBullishValue[0]);
   } 
   
   for(int i = 0; i < numberOfOpenedPositions; i++)
   {
      positionManager(Symbol(), i, 30, 5);
   }   
}

void maTrader(double bearishValue, double bullishValue)
{
   // Set main Params
   if (maParamsInit)
   {
      bearishMa = bearishValue;
      bullishMa = bullishValue;
      maParamsInit = false;
   }
   
   if (!maParamsInit && bearishValue > bullishValue && bearishMa < bullishMa)
   {
      bearishMa = bearishValue;
      bullishMa = bullishValue;
      maParamsInit = true;
      openSellOrder(Symbol(), tradeLotSize, stoplossOnEntry, NULL);
      Print("Sell Trade Opened!");
   }
   
   if (!maParamsInit && bearishValue < bullishValue && bearishMa > bullishMa)
   {
      bearishMa = bearishValue;
      bullishMa = bullishValue;
      maParamsInit = true;
      openBuyOrder(Symbol(), tradeLotSize, stoplossOnEntry, NULL);
      Print("Buy Trade Opened!");
   }
}

/*
void maTradeManager(double bearishValue, double bullishValue)
{
   if (PositionSelect(Symbol()))
   {
      if (PositionGetInteger(POSITION_TYPE) == ORDER_TYPE_BUY)
      {
         buyPositionManager(tradeStopTrailer, tradePipsToMove);
         Print("Manage Buy Position");
      }
   
      if (PositionGetInteger(POSITION_TYPE) == ORDER_TYPE_SELL)
      {
         sellPositionManager(tradeStopTrailer, tradePipsToMove);
         Print("Manage Sell Position");
      }
   }
}*/
