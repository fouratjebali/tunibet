import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'car_model.dart';

class PlaceBetPage extends StatefulWidget {
  final Car car;
  final bool isDealer;

  const PlaceBetPage({Key? key, required this.car, this.isDealer = false}) : super(key: key);

  @override
  State<PlaceBetPage> createState() => _PlaceBetPageState();
}

class _PlaceBetPageState extends State<PlaceBetPage> {
  final TextEditingController _betAmountController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _lastBets = [];

  @override
  void initState() {
    super.initState();
    _betAmountController.text = widget.car.price.toStringAsFixed(0);
    _fetchLastBets();
  }

Future<void> _fetchLastBets() async {
  try {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:5000/api/bets/last-bets?car_id=${widget.car.id}'),
    );

    if (response.statusCode == 200) {
      final bets = List<Map<String, dynamic>>.from(json.decode(response.body));
      setState(() {
        _lastBets = bets;

        // Update the text field with the price of the last bet if available
        if (_lastBets.isNotEmpty) {
          _betAmountController.text = _lastBets.first['amount'].toString();
        }
      });
    } else {
      print('Failed to fetch last bets');
    }
  } catch (e) {
    print('Error fetching last bets: $e');
  }
}
Future<void> _acceptLastBet() async {
  if (_lastBets.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No bets to accept')),
    );
    return;
  }

  final lastBet = _lastBets.first;

  try {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:5000/api/bets/accept-bet'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'car_id': widget.car.id,
        'bet_number': lastBet['bet_number'],
        'user_id': lastBet['user_id'],
        'amount': lastBet['amount'],
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bet accepted successfully!')),
      );
      Navigator.pop(context); // Go back to the dealer's home page
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to accept bet')),
      );
    }
  } catch (e) {
    print('Error accepting bet: $e');
  }
}

  Future<void> _placeBet() async {
    final betAmount = double.tryParse(_betAmountController.text);
    if (betAmount == null || betAmount <= widget.car.price) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount greater than the current price.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/bets/place-bet'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'car_id': widget.car.id,
          'user_id': 1, // Replace with the actual user ID
          'amount': betAmount,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bet placed successfully!')),
        );
        _fetchLastBets(); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to place bet.')),
        );
      }
    } catch (e) {
      print('Error placing bet: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        '${widget.car.make} ${widget.car.model}',
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Editable Price Field
          TextField(
            controller: _betAmountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Your Bet Amount',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // Last Bets Table
          const Text(
            'Last 5 Bets',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _lastBets.isEmpty
              ? const Center(child: Text('No bets available.'))
              : Table(
                  border: TableBorder.all(color: Colors.grey),
                  columnWidths: const {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(2),
                  },
                  children: [
                    const TableRow(
                      decoration: BoxDecoration(color: Colors.grey),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Bet #', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Created At', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    ..._lastBets.map((bet) {
                      return TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(bet['bet_number'].toString()),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('${bet['amount']} DT'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(bet['created_at']),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
          const Spacer(),
        ],
      ),
    ),
    bottomNavigationBar: SizedBox(
      width: double.infinity,
      height: 50,
      child: widget.isDealer
          ? ElevatedButton(
              onPressed: _acceptLastBet,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF56021F),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Accept Last Bet',
                style: TextStyle(color: Colors.white, 
                fontSize: 16, 
                fontWeight: FontWeight.bold),
              ),
            )
          : ElevatedButton(
              onPressed: _placeBet,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF56021F),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Confirm your bet',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
    ),
  );
}
}