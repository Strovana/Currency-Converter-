import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CurrencyConverterMaterialPage extends StatefulWidget {
  const CurrencyConverterMaterialPage({super.key});

  @override
  State<CurrencyConverterMaterialPage> createState() =>
      _CurrencyConverterMaterialPageState();
}

class _CurrencyConverterMaterialPageState
    extends State<CurrencyConverterMaterialPage> {
  double result = 0.0;
  final TextEditingController textEditingController = TextEditingController();

  Map<String, String> currencies = {};
  String? fromCurrency;
  String? toCurrency;
  final String accessKey = '31b5ac4701d19131424178146436c7b2';

  @override
  void initState() {
    super.initState();
    fetchCurrencies();
  }

  Future<void> fetchCurrencies() async {
    final url = Uri.parse(
      'https://api.exchangerate.host/list?access_key=$accessKey',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] != true || data['currencies'] == null) {
        debugPrint('Failed to load currencies: ${data['error'] ?? 'unknown'}');
        return;
      }

      setState(() {
        currencies = Map<String, String>.from(data['currencies']);
        fromCurrency = currencies.keys.first;
        toCurrency = currencies.keys.first;
      });
    } else {
      debugPrint('HTTP error: ${response.statusCode}');
    }
  }

  Future<void> convertCurrency() async {
    final from = fromCurrency;
    final to = toCurrency;
    final input = textEditingController.text;
    final amount = double.tryParse(input);
    if (from == null || to == null || amount == null) return;

    final url = Uri.parse(
      'https://api.exchangerate.host/live'
      '?access_key=$accessKey'
      '&source=$from'
      '&currencies=$to&format=1',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] != true || data['quotes'] == null) {
        debugPrint('Convert failed: ${data['error'] ?? 'unknown'}');
        return;
      }

      final rate = (data['quotes']['$from$to'] as num).toDouble();
      setState(() => result = amount * rate);

      if (kDebugMode) debugPrint('Rate $from→$to = $rate');
    } else {
      debugPrint('HTTP error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.black, width: 2),
      borderRadius: BorderRadius.circular(60),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Currency Converter",
          style: TextStyle(fontWeight: FontWeight.w500, fontFamily: "EdoSZ"),
        ),
        elevation: 0,

        backgroundColor: Colors.blueGrey,
      ),
      backgroundColor: Colors.blueGrey,
      body: Center(
        child:
            currencies.isEmpty
                ? const CircularProgressIndicator()
                : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${toCurrency ?? ''} ${result.toStringAsFixed(2)}",
                        style: const TextStyle(fontFamily: "EdoSZ",fontSize: 30),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left:16,right:16),
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Text("From",
                          
                          style:TextStyle(
                            fontFamily: "EdoSZ",
                            fontSize: 20,
                            color: Colors.white,
                          )),
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        itemHeight: null,
                        dropdownColor: Colors.black,
                        style: const TextStyle(
                          fontFamily: "EdoSZ",
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        value: fromCurrency,
                        items:
                            currencies.keys
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text("$c — ${currencies[c]}"),
                                    
                                  ),
                                )
                                .toList(),
                        decoration: InputDecoration(
                          
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          hintStyle: TextStyle(
                            fontFamily: "EdoSZ",
                            fontSize: 13,
                            color: Colors.white,
                          ),
                          prefixIcon: Icon(Icons.attach_money),
                          prefixIconColor: Colors.white,

                          enabledBorder: border,
                          focusedBorder: border,
                          fillColor: Colors.black,
                          filled: true,
                        ),
                        onChanged: (v) => setState(() => fromCurrency = v),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left:16,right:16),
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "To",

                            style: TextStyle(
                              fontFamily: "EdoSZ",
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        itemHeight: null,
                        dropdownColor: Colors.black,
                        style: const TextStyle(
                          fontFamily: "EdoSZ",
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        value: toCurrency,
                        items:
                            currencies.keys
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text("$c — ${currencies[c]}"),
                                  ),
                                )
                                .toList(),
                        decoration: InputDecoration(
                         /* floatingLabelBehavior: FloatingLabelBehavior.auto,
                          hintText:
                              " $fromCurrency",
                          labelText: "To",
                          labelStyle: const TextStyle(
                            fontFamily: "EdoSZ",
                            color: Colors.white,
                          ),*/
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          hintStyle: TextStyle(
                            fontFamily: "EdoSZ",
                            fontSize: 13,
                            color: Colors.white,
                          ),
                          prefixIcon: Icon(Icons.attach_money),
                          prefixIconColor: Colors.white,

                          enabledBorder: border,
                          focusedBorder: border,
                          fillColor: Colors.black,
                          filled: true,
                        ),
                        onChanged: (v) => setState(() => toCurrency = v),
                      ),
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Enter the Amount to Convert $fromCurrency",

                            style: TextStyle(
                              fontFamily: "EdoSZ",
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      TextField(
                        controller: textEditingController,
                        decoration: InputDecoration(
                          hintText: "Amount in $fromCurrency",
                          hintStyle: const TextStyle(
                            fontFamily: "EdoSZ",
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          enabledBorder: border,
                          focusedBorder: border,
                          fillColor: Colors.black,
                          filled: true,
                          prefixIcon: const Icon(Icons.attach_money),
                          prefixIconColor: Colors.white,
                          prefixStyle: TextStyle(
                            fontFamily: "EdoSZ",
                            color: Colors.white,
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 25),
                      ElevatedButton(
                        onPressed: convertCurrency,
                        style: ElevatedButton.styleFrom(
                          textStyle: TextStyle(
                            fontFamily: "EdoSZ",
                            fontSize: 20,
                            color: Colors.white,
                        ),
                          backgroundColor: Colors.black,
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: const Text("Convert",
                          style: TextStyle(
                            fontFamily: "EdoSZ",
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        
                      ),
                  )],
                  ),
                ),
      ),
    );
  }
}
