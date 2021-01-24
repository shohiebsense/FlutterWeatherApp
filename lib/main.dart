
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

void main() {
  runApp(WeatherApp());
}

class WeatherApp extends StatefulWidget {
  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  double temperature;
  int woeid = 1047378;
  var weatherData = "clear";
  String location = "Jakarta";
  String baseUrl = 'https://www.metaweather.com/';
  String endPoint = 'api/location/search/?query=';
  String detailEndPoint = 'api/location/';
  String imgUrl = 'static/img/weather/png/64/';
  String abbreviation = 'lr';
  String errorMsg = "";

  @override
  void initState() {
    super.initState();
    onTextFieldSubmitted(location);
  }

  void onTextFieldSubmitted(String text){
    getCity(text);
    fetchDetail();
  }

  void getCity(String city) async {
    try {
      var getWeatherUrl = await http.get(baseUrl+endPoint+city);
      print('weatheruRl $baseUrl$endPoint$city');

      var result = convert.json.decode(getWeatherUrl.body)[0];

      setState(() {
        print('result  ->  $result');
        location = result["title"];
        woeid = result["woeid"];
        errorMsg = '';
      });
    }  catch (e) {
      print("error $e");
      setState(() {
        errorMsg = "error, try another city";
      });
    }
  }

  void fetchDetail() async {
    var locationResult = await http.get(baseUrl + detailEndPoint + woeid.toString());
    var result = convert.json.decode(locationResult.body);
    var consolidatedWeather = result["consolidated_weather"];
    var data = consolidatedWeather[0];

    setState(() {
      temperature = data["the_temp"];
      abbreviation = data["weather_state_abbr"];
      weatherData = data["weather_state_name"].replaceAll(' ','').toLowerCase();
    });

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/${weatherData}.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: temperature == null ? Center(
            child: CircularProgressIndicator(),
          ) :  Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Center(
                    child: Image.network(baseUrl+imgUrl+abbreviation+'.png'),
                  ),
                  Center(
                    child: Text(
                      temperature.toString() + 'c',
                      style: TextStyle(color: Colors.white, fontSize: 55),
                    ),
                  ),
                  Center(
                    child: Text(
                      location,
                      style: TextStyle(color: Colors.white, fontSize: 45),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    width: 300,
                    child: TextField(
                      style: TextStyle(color: Colors.white, fontSize: 25),
                      decoration: InputDecoration(
                        hintText: 'Search City',
                        hintStyle: TextStyle(color: Colors.white, fontSize: 25),
                        prefixIcon: Icon(Icons.search, color: Colors.white,),
                      ),
                      onSubmitted: (String input){
                        onTextFieldSubmitted(input);
                      },
                    ),
                  ),
                  Text(
                    errorMsg,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 23,
                    ),
                  )
                ],
              )





























            ],
          ),
        ),
      ),
    );
  }
}
