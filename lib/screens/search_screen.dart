import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<String> productos = ["Nike Air", "Adidas Superstar"];
  List<String> resultados = [];

  void _buscar(String query) {
    setState(() {
      resultados = productos
          .where((p) => p.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Buscar Producto")),
      body: Column(
        children: [
          TextField(onChanged: _buscar),
          Expanded(
            child: ListView.builder(
              itemCount: resultados.length,
              itemBuilder: (context, index) =>
                  ListTile(title: Text(resultados[index])),
            ),
          ),
        ],
      ),
    );
  }
}
