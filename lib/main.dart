import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import 'package:cached_network_image/cached_network_image.dart';
//import 'package:transparent_image/transparent_image.dart';
//import 'package:catcher/catcher_plugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.indigo,
      ),
      home: MyHomePage(title: 'Criptomonedas'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var datosGrafico;
  var datosMonedas;

  DateTime _dateTime = DateTime.now();
  String d1 = '2019-01-01';
  String d2 = '2019-12-31';
  double priceCurrency;
  double priceDolar;
  double priceEuro;

  @override
  void initState() {
    super.initState();

    buscarDatosWeb(d1, d2);
    buscaPrecios();
  }

  buscaPrecios() async {
    priceDolar = await getPriceCurrency("USD", "MXN");
    priceEuro = await getPriceCurrency("EUR", "MXN");
  }

  getData(String dateStart, String dateEnd) async {
    final dateS = dateStart.substring(0, 10);
    final dateF = dateEnd.substring(0, 10);
    final url =
        'https://api.coindesk.com/v1/bpi/historical/close.json?start=$dateS&end=$dateF';
    List<double> datos;
    await http.get(url).then((res) {
      datos = jsonDecode(res.body)['bpi'].values.toList().cast<double>();
    });
    return datos;
  }

  Future<double> getPriceCurrency(String source, String target) async {
    String url =
        'https://api.cambio.today/v1/quotes/$source/$target/json?quantity=1&key=2380|^Rc0uqBMrcPSMcowjqTP7PJxEu*~UFdU';
    final res = await http.get(url);
    final _dato = jsonDecode(res.body);
    return _dato['result']['value'] as double;
  }

  getCoinPrices() async {
    var _body;
    final url =
        'https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest';
    await http.get(url, headers: {
      'X-CMC_PRO_API_KEY': '71357ff9-6340-4d3e-98be-9fde07fea604'
    }).then((res) {
      _body = jsonDecode(res.body)['data'];
    });
    return datosMonedas = _body;
  }

  buscarDatosWeb(String dateStart, String dateEnd) {
    setState(() {
      datosGrafico = getData(dateStart, dateEnd);
    });
  }

  buscarIconCurrency(String symbol) async {
    final res = await http.get('https://cryptoicons.org/api/icon/$symbol/100');
    if (res.statusCode == 200) {
      return Image.network(
        'https://cryptoicons.org/api/icon/$symbol/100',
      );
    } else {
      return Icon(
        Icons.error,
        size: 60,
      );
    }
  }

  String roundDouble(double num, int dec) => num.toStringAsFixed(dec);

  Widget PreciosMonedas(String symbol) => ListView.builder(
        itemCount: datosMonedas == null ? 0 : 20, //datosMonedas.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            margin: EdgeInsets.only(top: 0, bottom: 15),
            height: 60,
            width: 60,
            child: ListTile(
              leading: FutureBuilder(
                future: buscarIconCurrency(
                    datosMonedas[index]['symbol'].toString().toLowerCase()),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasError) print(snapshot.error);
                  return snapshot.hasData
                      ? snapshot.data
                      : new CircularProgressIndicator();
                },
              ),
              title: Text(
                datosMonedas[index]['name'],
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: Colors.indigo,
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                roundDouble(datosMonedas[index]['quote']['USD']['price'], 3)
                    .toString(),
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
              trailing: Text(
                  "MXN: ${roundDouble(priceDolar * datosMonedas[index]['quote']['USD']['price'], 3)} \n VOL 24h: ${roundDouble(datosMonedas[index]['quote']['USD']['volume_24h'], 0)} \n Chg 24h: ${roundDouble(datosMonedas[index]['quote']['USD']['percent_change_24h'], 2)}",
                  textAlign: TextAlign.right,
                  ),
              //enabled: true,
            ),
          );
        },
      );

  var data1 = [0.0, 2.0, 3.5, -2.0, 0.5, 0.7, 0.8, 1.0, 2.0, 3.0, 3.2];

  List<CircularStackEntry> circularData = <CircularStackEntry>[
    new CircularStackEntry(
      <CircularSegmentEntry>[
        new CircularSegmentEntry(1000.0, Color(0xff4285F4), rankKey: 'Q1'),
        new CircularSegmentEntry(1000.0, Color(0xfff3af00), rankKey: 'Q2'),
        new CircularSegmentEntry(1000.0, Color(0xffec3337), rankKey: 'Q3'),
        new CircularSegmentEntry(1000.0, Color(0xff40b24b), rankKey: 'Q4'),
      ],
      rankKey: 'Quarterly Profits',
    ),
  ];

  Material myTextItems(String title, String subtitle) {
    return Material(
      color: Colors.white,
      elevation: 14.0,
      borderRadius: BorderRadius.circular(24.0),
      shadowColor: Color(0x802196F3),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 30.0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Material myCircularItems(String title, String subtitle) {
    return Material(
      color: Colors.white,
      elevation: 14.0,
      borderRadius: BorderRadius.circular(25.0),
      shadowColor: Color(0x802196F3),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 30.0,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: AnimatedCircularChart(
                      size: const Size(100.0, 100.0),
                      initialChartData: circularData,
                      chartType: CircularChartType.Pie,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Material mychart1Items(String title, String priceVal, String subtitle) {
    return Material(
      color: Colors.white,
      elevation: 14.0,
      borderRadius: BorderRadius.circular(24.0),
      shadowColor: Color(0x802196F3),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(1.0),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(1.0),
                    child: Text(
                      priceVal,
                      style: TextStyle(
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(1.0),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.all(1.0),
                      child: FutureBuilder(
                        future: datosGrafico,
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.hasError) print(snapshot.error);
                          return snapshot.hasData
                              ? Sparkline(
                                  data: snapshot.data,
                                  lineColor: Color(0xffff6101),
                                  pointsMode: PointsMode.all,
                                  pointSize: 8.0,
                                )
                              : new CircularProgressIndicator();
                        },
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Material mychart2Items(String title, String priceVal, String subtitle) {
    return Material(
      color: Colors.white,
      elevation: 14.0,
      borderRadius: BorderRadius.circular(24.0),
      shadowColor: Color(0x802196F3),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(1.0),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(1.0),
                    child: Text(
                      priceVal,
                      style: TextStyle(
                        fontSize: 30.0,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(1.0),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(1.0),
                    child: new Sparkline(
                      data: data1,
                      fillMode: FillMode.below,
                      fillGradient: new LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.amber[800], Colors.amber[200]],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              buscarDatosWeb('2019-09-01', '2019-09-30');
            }),
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(FontAwesomeIcons.chartLine),
            onPressed: () {
              showDatePicker(
                      context: context,
                      initialDate:
                          _dateTime == null ? DateTime.now() : _dateTime,
                      firstDate: DateTime(2001),
                      lastDate: DateTime(2021))
                  .then((date) {
                setState(() {
                  _dateTime = date;
                  buscarDatosWeb('2019-08-01', _dateTime.toString());
                });
              });
            },
          ),
        ],
      ),
      body: Container(
        color: Color(0xffE5E5E5),
        child: GestureDetector(
            onTap: () {
              print('presiono tap = ${DateTime.now()}');
            },
            onPanDown: (DragDownDetails details) {
              print("parent PanDown = ${DateTime.now()}");
            },
            onVerticalDragEnd: (DragEndDetails details) {
              print("parent VerticalDragEnd = ${DateTime.now()}");
            },
            onVerticalDragDown: (DragDownDetails details) {
              print("parent VerticalDragDown = ${DateTime.now()}");
            },
            onDoubleTap: () {
              print('Doble Tap');
              buscarDatosWeb(d1, d2);
            },
            onTapUp: (TapUpDetails details) {
              print("parent tapup = ${DateTime.now()}");
            },
            onTapDown: (TapDownDetails details) {
              print("parent tapdown = ${DateTime.now()}");
            },
            child: StaggeredGridView.count(
              crossAxisCount: 4,
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Material(
                      color: Colors.white,
                      elevation: 14.0,
                      borderRadius: BorderRadius.circular(24.0),
                      shadowColor: Color(0x802196F3),
                      child: Stack(
                        children: <Widget>[
                          Container(
                            color: Colors.indigo[900],
                            child: ListTile(
                              leading: Icon(
                                FontAwesomeIcons.chartLine,
                                color: Colors.white,
                                size: 50,
                              ),
                              title: Text(
                                "Cryptos",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20),
                                textAlign: TextAlign.right,
                              ),
                              subtitle: Text(
                                "Price in USD",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 18),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ),

                          Container(
                            margin: EdgeInsets.only(top: 70),
                            child: FutureBuilder(
                              future: getCoinPrices(),
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                if (snapshot.hasError) print(snapshot.error);
                                return snapshot.hasData
                                    ? PreciosMonedas('btc')
                                    : new CircularProgressIndicator();
                              },
                            ),
                          ), //myCircularItems("Ethereum", "68.7M"),
                        ],
                      ),
                    )),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: mychart1Items(
                      "Bitcoin history chart",
                      _dateTime == null
                          ? 'Nothing has been picked yet'
                          : _dateTime.toString(),
                      "+12.9% of target"),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: mychart2Items("Conversion", "0.9M", "+19% of target"),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FutureBuilder(
                    future: getPriceCurrency("USD", "MXN"),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasError) print(snapshot.error);
                      return snapshot.hasData
                          ? myTextItems(
                              "USD/MXN Price", snapshot.data.toString())
                          : new CircularProgressIndicator();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FutureBuilder(
                    future: getPriceCurrency("EUR", "MXN"),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasError) print(snapshot.error);
                      return snapshot.hasData
                          ? myTextItems(
                              "EUR/MXN Price", snapshot.data.toString())
                          : new CircularProgressIndicator();
                    },
                  ),
                ),
              ],
              staggeredTiles: [
                StaggeredTile.extent(4, 400.0),
                StaggeredTile.extent(4, 250.0),
                StaggeredTile.extent(4, 250.0),
                StaggeredTile.extent(4, 120.0),
                StaggeredTile.extent(4, 120.0),
              ],
            )),
      ),
    );
  }
}
