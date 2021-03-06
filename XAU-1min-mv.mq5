//+------------------------------------------------------------------+
//|                                                  XAU-1min-mv.mq5 |
//|                                                          TTSS000 |
//|                                      https://twitter.com/ttss000 |
//+------------------------------------------------------------------+
#property copyright "TTSS000"
#property link      "https://twitter.com/ttss000"
#property version   "1.00"
//--- input parameters

#import "shell32.dll"
long ShellExecuteW(long hWnd,string lpVerb,string lpFile,string lpParameters,string lpDirectory,int nCmdShow);
#import

input double   mv_percent=0.25;
input int      bars_after=5;
input double param_lots=0.01;
input int param_slip_point=100;
input int param_magic=234545072;

datetime dt_prev=0;
int h_FileOutput, filehandle;
datetime flag_dt_long;
bool flag_long=false;
datetime flag_dt_short;
bool flag_short=false;
//string record = "";
datetime rec_dt_long[10];
datetime rec_dt_short[10];
double rec_double_long[10];
double rec_double_short[10];
string data_folder_str ;
string filename;
double total=0;
double count=0;
double lots=param_lots;

MqlTradeRequest request;
MqlTradeResult  result;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//--- create timer
//EventSetTimer(60);
//ShellExecuteW(0,"","notepad.exe","","",5);
  data_folder_str = TerminalInfoString(TERMINAL_DATA_PATH);
  Print ("DataFolder="+data_folder_str);
  filename = "xauusd-mv.csv";
  ResetLastError();
  //filehandle = FileOpen(filename,FILE_WRITE|FILE_CSV);

  if(filehandle!=INVALID_HANDLE) {
    Print("File opened correctly");
  } else Print("Error in opening file "+filename+","+GetLastError());

//FileWrite(filehandle, 0, 0, 0, 0);
//FileFlush(filehandle);
  long modes = SymbolInfoInteger(Symbol(), SYMBOL_FILLING_MODE);
  if ((modes & SYMBOL_FILLING_FOK) != 0) {
      Print("SYMBOL_FILLING_FOK FOK ポリシーに対応しています");
  }
  if ((modes & SYMBOL_FILLING_IOC) != 0) {
      Print("SYMBOL_FILLING_IOC IOC ポリシーに対応しています");
  }
  
  // 成行注文時には RETURN ポリシーは無条件で指定可能とされているため、
  // RETURN ポリシーに対応しているかを調べるビットフラグは用意されていないようです。
  Print("SYMBOL_FILLING_RETURN ポリシーに対応しています（嘘かも）");
//---
  return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//--- destroy timer
  long ret_code = 0;
//EventKillTimer();
  //FileFlush(h_FileOutput);
  //FileClose(h_FileOutput);
  Print ("ODini total:"+total+" count="+count+" t/c="+(total/count));
//long ret_code =  ShellExecuteW(NULL, "explorer", data_folder_str, NULL,data_folder_str,1);
//Print ("ret_code="+ret_code);
  //ret_code =  ShellExecuteW(NULL, "open", data_folder_str+"\\MQL5\\Files", NULL,data_folder_str+"\\MQL5\\Files",1);
  //Print ("ret_code="+ret_code);
//ret_code =  ShellExecuteW(NULL, "", data_folder_str, NULL,data_folder_str,1);
//Print ("ret_code="+ret_code);
  long modes = SymbolInfoInteger(Symbol(), SYMBOL_FILLING_MODE);
  if ((modes & SYMBOL_FILLING_FOK) != 0) {
      Print("FOK ポリシーに対応しています");
  }
  if ((modes & SYMBOL_FILLING_IOC) != 0) {
      Print("IOC ポリシーに対応しています");
  }
  
  // 成行注文時には RETURN ポリシーは無条件で指定可能とされているため、
  // RETURN ポリシーに対応しているかを調べるビットフラグは用意されていないようです。
  Print("RETURN ポリシーに対応しています（嘘かも）");

}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
  if(NewBar()) {
    double diff_close_prices = iClose(NULL, PERIOD_M1,1) - iClose(NULL, PERIOD_M1,2);
    if( mv_percent < 100*MathAbs( diff_close_prices ) /  iClose(NULL, PERIOD_M1,1)  ) {
      if(0<diff_close_prices) {
        Print("L diff_close_price="+diff_close_prices);
        if(flag_long==false) {
          flag_dt_long = iTime(NULL, PERIOD_CURRENT, 1);
          flag_long=true;
          rec_dt_long[0] = iTime(NULL, PERIOD_CURRENT, 1);
          rec_double_long[0] = iClose(NULL, PERIOD_M1,1);
          rec_double_long[1] = 100* ( iClose(NULL, PERIOD_M1,1) - iClose(NULL, PERIOD_M1,2)  ) /  iClose(NULL, PERIOD_M1,1);
          PlaceShortMarketOrder();
          //PlaceLongMarketOrder();
        }
      }else if(diff_close_prices<0) {
        Print("S diff_close_price="+diff_close_prices);
        if(flag_short==false) {
          flag_dt_short = iTime(NULL, PERIOD_CURRENT, 1);
          flag_short=true;
          rec_dt_short[0] = iTime(NULL, PERIOD_CURRENT, 1);
          rec_double_short[0] = iClose(NULL, PERIOD_M1,1);
          rec_double_short[1] = 100* ( iClose(NULL, PERIOD_M1,1) - iClose(NULL, PERIOD_M1,2)  ) /  iClose(NULL, PERIOD_M1,1);
          //PlaceShortMarketOrder();
          PlaceLongMarketOrder();
        }
      }
    }

    if(bars_after == iBarShift(NULL, PERIOD_M1, flag_dt_long, true)) {
      //FileWrite(filehandle, rec_dt[0], rec_double[0], rec_double[1],
      //          iTime(NULL, PERIOD_CURRENT, 1), iClose(NULL, PERIOD_M1,1),100* ( iClose(NULL, PERIOD_M1,1) - rec_double[0]  ) /  iClose(NULL, PERIOD_M1,1) );
      //FileFlush(filehandle);
      CloseShortPosition();
      //CloseLongPosition();

      flag_long=false;
      rec_dt_long[0] = 0;
      rec_double_long[0] = 0;
      rec_double_long[1] = 0;
    }
    if(bars_after == iBarShift(NULL, PERIOD_M1, flag_dt_short, true)) {
      //FileWrite(filehandle, rec_dt[0], rec_double[0], rec_double[1],
      //          iTime(NULL, PERIOD_CURRENT, 1), iClose(NULL, PERIOD_M1,1),100* ( iClose(NULL, PERIOD_M1,1) - rec_double[0]  ) /  iClose(NULL, PERIOD_M1,1) );
      //FileFlush(filehandle);
      //CloseShortPosition();
      CloseLongPosition();

      flag_short=false;
      rec_dt_short[0] = 0;
      rec_double_short[0] = 0;
      rec_double_short[1] = 0;
    }
  }

//  MqlTick last_tick;
//  if(SymbolInfoTick(Symbol(),last_tick)) {
//    //Print(last_tick.time,": Bid = ",last_tick.bid,
//    //      " Ask = ",last_tick.ask,"  Volume = ",last_tick.volume);
//
//    FileWrite(filehandle,last_tick.bid,last_tick.ask);
//    FileFlush(filehandle);
//
//  } else Print("SymbolInfoTick() failed, error = ",GetLastError());

//---
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
//---

}
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
{
//---

}
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
{
//---

}
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
{
//---
  double ret=0.0;
//---

//---
  return(ret);
}
//+------------------------------------------------------------------+
//| TesterInit function                                              |
//+------------------------------------------------------------------+
void OnTesterInit()
{
//---

}
//+------------------------------------------------------------------+
//| TesterPass function                                              |
//+------------------------------------------------------------------+
void OnTesterPass()
{
//---

}
//+------------------------------------------------------------------+
//| TesterDeinit function                                            |
//+------------------------------------------------------------------+
void OnTesterDeinit()
{
//---
  //FileFlush(h_FileOutput);
  //FileClose(h_FileOutput);
  Print ("OTD total:"+total+" count="+count+" t/c="+(total/count));
  long ret_code =  ShellExecuteW(NULL, "explorer", data_folder_str, NULL,data_folder_str,1);
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

}
//+------------------------------------------------------------------+
//| BookEvent function                                               |
//+------------------------------------------------------------------+
void OnBookEvent(const string &symbol)
{
//---

}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
bool NewBar()
{
  static datetime dt = 0;
  if(dt != iTime(NULL, PERIOD_CURRENT, 0)) {
    dt = iTime(NULL, PERIOD_CURRENT, 0);
    //Sleep(100); // wait for tick
    return(true);
  }
  return(false);
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void PlaceLongMarketOrder(void)
{
  double Bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
  double Ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);

  ZeroMemory(request);
  ZeroMemory(result);
//--- setting the operation parameters
  request.action  =TRADE_ACTION_DEAL; // type of trade operation
//request.position=in_ticket_no;   // ticket of the position
  request.symbol=_Symbol;     // symbol
  request.volume=lots;
  request.price=Ask;
  request.stoplimit=param_slip_point;
  request.sl      =0;
  request.tp      =0;
  request.magic=param_magic;         // MagicNumber of the position
  request.type_filling=ORDER_FILLING_RETURN ;
  request.type_filling=ORDER_FILLING_IOC ;
  request.type=ORDER_TYPE_BUY;


  if(!OrderSend(request,result)) {
    Print("Buy OrderError");
  }
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void PlaceShortMarketOrder(void)
{
  double Bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
  double Ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);

  ZeroMemory(request);
  ZeroMemory(result);
//--- setting the operation parameters
  request.action  =TRADE_ACTION_DEAL; // type of trade operation
//request.position=in_ticket_no;   // ticket of the position
  request.symbol=_Symbol;     // symbol
  request.volume=lots;
  request.price=Bid;
  request.stoplimit=param_slip_point;
  request.sl      =0;
  request.tp      =0;
  request.magic=param_magic;         // MagicNumber of the position
  request.type_filling=ORDER_FILLING_RETURN ;
  request.type_filling=ORDER_FILLING_IOC ;
  request.type=ORDER_TYPE_SELL;

  if(!OrderSend(request,result)) {
    Print("Sell OrderError");
  }
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void Close_Position()
{
  int pos_total=PositionsTotal(); // number of open positions
//--- iterate over all open positions
  for(int i=pos_total-1; 0 <= i; i--) {
    //--- parameters of the order
    ulong  position_ticket=PositionGetTicket(i);// ticket of the position
    PositionSelectByTicket(position_ticket);

    string position_symbol=PositionGetString(POSITION_SYMBOL); // symbol
    int    digits=(int)SymbolInfoInteger(position_symbol,SYMBOL_DIGITS); // number of decimal places
    ulong  magic=PositionGetInteger(POSITION_MAGIC); // MagicNumber of the position
    double volume=PositionGetDouble(POSITION_VOLUME);    // volume of the position
    double sl=PositionGetDouble(POSITION_SL);  // Stop Loss of the position
    double tp=PositionGetDouble(POSITION_TP);  // Take Profit of the position
    ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);    // type of the position

    if(position_symbol != Symbol() || magic != param_magic) {
      continue;
    }
    ZeroMemory(request);
    ZeroMemory(result);
    request.action   =TRADE_ACTION_DEAL;        // type of trade operation
    request.position =position_ticket;          // ticket of the position
    request.symbol   =position_symbol;          // symbol
    request.volume   =volume;                   // volume of the position
    request.deviation=param_slip_point;
    request.magic    =param_magic;             // MagicNumber of the position
    request.type_filling=ORDER_FILLING_RETURN ;
    request.type_filling=ORDER_FILLING_IOC ;
    //--- set the price and order type depending on the position type
    if(type==POSITION_TYPE_BUY)     {
      request.price=SymbolInfoDouble(position_symbol,SYMBOL_BID);
      request.type =ORDER_TYPE_SELL;
    }    else     {
      request.price=SymbolInfoDouble(position_symbol,SYMBOL_ASK);
      request.type =ORDER_TYPE_BUY;
    }
    OrderSend(request,result);
  }
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void CloseLongPosition()
{
  int pos_total=PositionsTotal(); // number of open positions
//--- iterate over all open positions
  for(int i=pos_total-1; 0 <= i; i--) {
    //--- parameters of the order
    ulong  position_ticket=PositionGetTicket(i);// ticket of the position
    PositionSelectByTicket(position_ticket);

    string position_symbol=PositionGetString(POSITION_SYMBOL); // symbol
    int    digits=(int)SymbolInfoInteger(position_symbol,SYMBOL_DIGITS); // number of decimal places
    ulong  magic=PositionGetInteger(POSITION_MAGIC); // MagicNumber of the position
    double volume=PositionGetDouble(POSITION_VOLUME);    // volume of the position
    double sl=PositionGetDouble(POSITION_SL);  // Stop Loss of the position
    double tp=PositionGetDouble(POSITION_TP);  // Take Profit of the position
    ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);    // type of the position

    if(position_symbol != Symbol() || magic != param_magic) {
      continue;
    }
    if(type == POSITION_TYPE_BUY){
      ZeroMemory(request);
      ZeroMemory(result);
      request.action   =TRADE_ACTION_DEAL;        // type of trade operation
      request.position =position_ticket;          // ticket of the position
      request.symbol   =position_symbol;          // symbol
      request.volume   =volume;                   // volume of the position
      request.deviation=param_slip_point;
      request.magic    =param_magic;             // MagicNumber of the position
      request.type_filling=ORDER_FILLING_RETURN ;
      request.type_filling=ORDER_FILLING_IOC ;
      //--- set the price and order type depending on the position type
      request.price=SymbolInfoDouble(position_symbol,SYMBOL_BID);
      request.type =ORDER_TYPE_SELL;
      OrderSend(request,result);
    }

  }
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void CloseShortPosition()
{
  int pos_total=PositionsTotal(); // number of open positions
//--- iterate over all open positions
  for(int i=pos_total-1; 0 <= i; i--) {
    //--- parameters of the order
    ulong  position_ticket=PositionGetTicket(i);// ticket of the position
    PositionSelectByTicket(position_ticket);

    string position_symbol=PositionGetString(POSITION_SYMBOL); // symbol
    int    digits=(int)SymbolInfoInteger(position_symbol,SYMBOL_DIGITS); // number of decimal places
    ulong  magic=PositionGetInteger(POSITION_MAGIC); // MagicNumber of the position
    double volume=PositionGetDouble(POSITION_VOLUME);    // volume of the position
    double sl=PositionGetDouble(POSITION_SL);  // Stop Loss of the position
    double tp=PositionGetDouble(POSITION_TP);  // Take Profit of the position
    ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);    // type of the position

    if(position_symbol != Symbol() || magic != param_magic) {
      continue;
    }
    if(type == POSITION_TYPE_SELL){
      ZeroMemory(request);
      ZeroMemory(result);
      request.action   =TRADE_ACTION_DEAL;        // type of trade operation
      request.position =position_ticket;          // ticket of the position
      request.symbol   =position_symbol;          // symbol
      request.volume   =volume;                   // volume of the position
      request.deviation=param_slip_point;
      request.magic    =param_magic;             // MagicNumber of the position
      request.type_filling=ORDER_FILLING_RETURN ;
      request.type_filling=ORDER_FILLING_IOC ;
      //--- set the price and order type depending on the position type
      request.price=SymbolInfoDouble(position_symbol,SYMBOL_ASK);
      request.type =ORDER_TYPE_BUY;
      OrderSend(request,result);
    }

  }
}
//+------------------------------------------------------------------+
