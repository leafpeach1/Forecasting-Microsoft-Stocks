
ods graphics on / discretemax= 1600;
data project;
infile '/home/u63652615/sasuser.v94/Microsoft_Stock 1(in).csv' dlm=',' firstobs=2;
input Date $ Open High Low Close Volume;
date_num = input(Date, mmddyy10.);
format date_num mmddyy10.;
ObsNum = _N_;
run;

proc means data = project;
var Open High Low Close;
title "Means Procedure for All Variables except Volume and Date";
run;

proc corr data = project;
var Open High Low Close;
title "Autocorrelation Procedure for All Variables except Volume and Date";
run;

proc univariate data = project;
var Open High Low Close;
title "Univariate Procedure for All Variables except Volume and Date";
run;

data stockWithMa;
set project;
MA_10_ForHighVariable = mean(High, 10);
title "Moving Average of 10 for the High Price Variable";
run;
proc print data=stockWithMa(obs=20);
run;

data stockWithMa2;
set project;
MA_10_ForLowVariable = mean(Low, 10);
title "Moving Average of 10 for the Low Price Variable";

run;
proc print data = stockWithMa2(obs=20);
run;



proc sgplot data=project;
heatmap x=Open y=High;
title "Heat Map of The Open Price Compared to the High Price";
run;

proc sgplot data=project;
heatmap x=Close y=Low;
title "Heat Map of The Close Price Compared to the Low Price";

run;


proc sgplot data=project;
  histogram High;
  title "Histogram of High Prices";
run;

proc sgplot data=project;
  histogram Low;
  title "Histogram of Low Prices";
run;

proc reg data=project outest=betas;
    model High = Open;
    output out=predictions predicted=PredClose;
    title "Linear Regression with the High Price being the Dependent Variable and the Open Price being Independent";
run;

proc reg data=project outest=betas;
    model Low = Close;
    output out=predictions predicted=PredClose;
    title "Linear Regression with the Low Price being the Dependent Variable and the Close Price being Independent";
run;

proc arima data=project;
	identify var=High(1);
	estimate p=1 q=1;
	forecast lead=365 interval=day out=forecast_output;
	title "Autoregressive Interval Moving Average Procedure of the High Price";
run;

proc arima data=project;
	identify var=Low(1);
	estimate p=1 q=1;
	forecast lead=365 interval=day out=forecast_output;
	title "Autoregressive Interval Moving Average Procedure of the High Price";
run;

data forecast_output2;
    set forecast_output;
    ObsNum = _N_;
run;


/* Create a line plot of forecasted values and actual Close prices */
proc sgplot data=forecast_output2;
    scatter x=ObsNum y=Forecast / markerattrs=(symbol=circlefilled size=7 color=red) legendlabel="Forecasted";
    xaxis type=time;
    yaxis label="Forecast";
    keylegend / location=inside position=topright across=1;
    title "Forecasted High Prices";
run;



proc sgplot data=project;
scatter x=date_num y=High;
title "Actual High Prices";
run;


