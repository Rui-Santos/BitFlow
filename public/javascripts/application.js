// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var chart_buttons = [{
  type: 'hour',
  count: 1,
  text: '2h'
}, {
  type: 'hour',
  count: 12,
  text: '12h'
}, {
  type: 'day',
  count: 1,
  text: '1d'
}, {
  type: 'week',
  count: 1,
  text: '1w'
}, {
  type: 'month',
  count: 1,
  text: '1m'
}, {
  type: 'month',
  count: 6,
  text: '6m'
}, {
  type: 'year',
  count: 1,
  text: '1y'
}, {
  type: 'all',
  text: 'All'
}];

var createPriceChart = function(usd_btc, volume) {
  return new Highcharts.StockChart({
    chart: {
      renderTo: 'btc_pricing_graph'
    },
    rangeSelector: {
      buttons: chart_buttons,
      selected: 1
    },
    title: {
      text: 'USD to BTC exchange rate'
    },
    xAxis: {
      type: 'datetime',
      maxZoom: 12 * 3600 * 1000 // 12 hours
    },
    yAxis: [{
      title: {
        text: 'Exchange rate'
      },
      height: 250,
      lineWidth: 2
    }, {
      title: {
        text: 'Volume'
      },
      top: 320,
      height: 50,
      offset: 0,
      lineWidth: 3
    }],
    series: [{
      name: 'USD to BTC',
      data: usd_btc,
      marker: {
        enabled: true,
        radius: 2
      }
    }, {
      type: 'column',
      name: 'Volume',
      data: volume,
      yAxis: 1
    }]
  });
};
var loadPriceChart = function() {
  $.get('/trades/price_graph.js', function(usd_btc_data, state, xhr) {
    var trade_prices = eval(usd_btc_data);
    var usd_btc = [];
    var volume = [];
    $.each(trade_prices, function(index) {
      var trade = trade_prices[index].trade;
      var date = new Date(trade.updated_at);
      var utc_date = Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate(), date.getUTCHours(), date.getUTCMinutes());
      usd_btc.push([utc_date, parseFloat(trade.market_price)]);
      volume.push([utc_date, parseFloat(trade.amount)]);
    });
    var chart_object = createPriceChart(usd_btc, volume);
  });
};
