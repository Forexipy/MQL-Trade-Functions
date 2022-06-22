//+------------------------------------------------------------------+
//|                                                 TrailingStop.mqh |
//|                                        Copyright 2022, Forexipy. |
//|                                      https://github.com/Forexipy |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Forexipy."
#property link      "https://github.com/Forexipy"
#property version   "1.0"
#property strict

input int  MagicNumber   = 111;  //Magic Number
input bool UseTrailing   = true; //Use Trailing Stop
input int  TrailingStart = 10;   //Trailing Start in pips
input int  TrailingStep  = 5;    //Trailing Step in pips
input int  Offsset       = 1;    //BreakEven Offsset in pips

double Pip;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
 //---
 
 Pip = _Point;
 
 if(_Digits%2==1) Pip = _Point*10;
 
 //---
 return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
 //---
 //---
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
 //---
 
 if(UseTrailing) DoTrailing();
 
 //---   
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
 //---
 //---  
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DoTrailing()
{
 ResetLastError();
 
 for(int i=OrdersTotal()-1; i>=0; i--)
 {
  if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
  
  if(OrderSymbol()!=_Symbol) continue;
  
  if(MagicNumber>0 && OrderMagicNumber()!=MagicNumber) continue;
  
  int type = OrderType();
  
  if(type>OP_SELL) continue;
  
  double op = OrderOpenPrice();
  
  double sl = OrderStopLoss();
  
  int StopLevel = (int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
  
  if(type==OP_BUY)
  {
   if(sl<op+(Offsset*Pip))
   {
    double newSl = op+(Offsset*Pip);
    
    if(Bid>=op+(TrailingStart*Pip) && Bid-newSl>=(StopLevel*_Point))
    {
     if(!OrderModify(OrderTicket(),OrderOpenPrice(),newSl,OrderTakeProfit(),0,clrBlue))
     {
      Print("Buy Order: ",OrderTicket()," Modify Trail Start Error. ",GetLastError());
     }
    }
   }
   else
   {
    double newSl = Bid-(TrailingStep*Pip);
    
    if(Bid>=sl+(TrailingStep*Pip) && Bid-newSl>=(StopLevel*_Point))
    {
     if(!OrderModify(OrderTicket(),OrderOpenPrice(),newSl,OrderTakeProfit(),0,clrBlue))
     {
      Print("Buy Order: ",OrderTicket()," Modify Trail Step Error. ",GetLastError());
     }
    }
   }
  }
  else if(type==OP_SELL)
  {
   if(sl>op-(Offsset*Pip))
   {
    double newSl = op-(Offsset*Pip);
    
    if(Ask<=op-(TrailingStart*Pip) && newSl-Ask>=(StopLevel*_Point))
    {
     if(!OrderModify(OrderTicket(),OrderOpenPrice(),newSl,OrderTakeProfit(),0,clrRed))
     {
      Print("Sell Order: ",OrderTicket()," Modify Trail Start Error. ",GetLastError());
     }
    }
   }
   else
   {
    double newSl = Ask-(TrailingStep*Pip);
    
    if(Ask<=sl-(TrailingStep*Pip) && newSl-Ask>=(StopLevel*_Point))
    {
     if(!OrderModify(OrderTicket(),OrderOpenPrice(),newSl,OrderTakeProfit(),0,clrRed))
     {
      Print("Sell Order: ",OrderTicket()," Modify Trail Step Error. ",GetLastError());
     }
    }
   }
  }
 }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

