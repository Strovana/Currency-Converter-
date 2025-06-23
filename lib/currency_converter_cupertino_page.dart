import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CurrencyConverterCupertinoPage extends StatefulWidget {
  const CurrencyConverterCupertinoPage({super.key});

  @override
  State<CurrencyConverterCupertinoPage> createState() => _CurrencyConverterCupertinoPageState();
}

class _CurrencyConverterCupertinoPageState extends State<CurrencyConverterCupertinoPage> {
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

  void showPicker({required bool isFrom}) {
    final List<String> keys = currencies.keys.toList();
    final selectedIndex = keys.indexOf(isFrom ? fromCurrency! : toCurrency!);

    showCupertinoModalPopup(
      context: context,
      builder:
          (_) => Container(
            height: 250,
            color: CupertinoColors.black,
            child: Column(
              children: [
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                      initialItem: selectedIndex,
                    ),
                    itemExtent: 32,
                    backgroundColor: CupertinoColors.black,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        if (isFrom) {
                          fromCurrency = keys[index];
                        } else {
                          toCurrency = keys[index];
                        }
                      });
                    },
                    children:
                        keys
                            .map(
                              (k) => Text(
                                "$k — ${currencies[k]}",
                                style: const TextStyle(
                                  color: CupertinoColors.white,
                                  fontFamily: 'EdoSZ',
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
                CupertinoButton(
                  child: const Text("Done"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
    );
  }
  
  Widget buildPickerButton(String label, bool isFrom) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: "EdoSZ",
              fontSize: 20,
              color: CupertinoColors.white,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => showPicker(isFrom: isFrom),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: CupertinoColors.black,
              border: Border.all(color: CupertinoColors.white, width: 2),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isFrom ? fromCurrency! : toCurrency!,
                  style: const TextStyle(
                    fontFamily: "EdoSZ",
                    fontSize: 16,
                    color: CupertinoColors.white,
                  ),
                ),
                const Icon(
                  CupertinoIcons.chevron_down,
                  color: CupertinoColors.white,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text(
          "Currency Converter",
          style: TextStyle(fontWeight: FontWeight.w500, fontFamily: "EdoSZ"),
          selectionColor: CupertinoColors.black
        ),
        

        backgroundColor: CupertinoColors.white,
      ),
      backgroundColor: CupertinoColors.systemOrange,
      
        child:
            currencies.isEmpty
                ? const Center(child: CupertinoActivityIndicator(),)
                :SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [Text(
                      "${toCurrency ?? ''} ${result.toStringAsFixed(2)}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontFamily: "EdoSZ", fontSize: 30, color: CupertinoColors.white),
                    ),
                
                  
                    
                      
                    const SizedBox(height: 20),
                    buildPickerButton("From", true),
                    const SizedBox(height: 20),
                    buildPickerButton("To", false),
                    const SizedBox(height: 20),
                    Text(
                      "Enter the Price in $fromCurrency",
                      style: const TextStyle(fontFamily: "EdoSZ", fontSize: 20, color: CupertinoColors.white),
                    ),
                    const SizedBox(height: 10),
                    CupertinoTextField(
                      controller: textEditingController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      placeholder: "Amount in $fromCurrency",
                      placeholderStyle: const TextStyle(color: CupertinoColors.white),
                      style: const TextStyle(color: CupertinoColors.white, fontFamily: "EdoSZ"),
                      prefix: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(CupertinoIcons.money_dollar, color: CupertinoColors.white),
                      ),
                      decoration: BoxDecoration(
                        color: CupertinoColors.black,
                        border: Border.all(color: CupertinoColors.white, width: 2),
                        borderRadius: BorderRadius.circular(60),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    ),
                    const SizedBox(height: 25),
                    CupertinoButton.filled(
                      onPressed: convertCurrency,
                      child: const Text("Convert", style: TextStyle(fontFamily: "EdoSZ", fontSize: 20)),
                    )])),));
      
  }
}
