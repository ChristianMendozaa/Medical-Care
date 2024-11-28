import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DiagnosticChatAssistant extends StatefulWidget {
  final Map<String, dynamic> diagnostic;

  const DiagnosticChatAssistant({Key? key, required this.diagnostic})
      : super(key: key);

  @override
  _DiagnosticChatAssistantState createState() =>
      _DiagnosticChatAssistantState();
}

class _DiagnosticChatAssistantState extends State<DiagnosticChatAssistant> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final String _apiKey = "8cd6995d-a404-4f2c-bbb0-0eec439d82d3";
  final String _apiUrl = "https://api.sambanova.ai/v1/chat/completions";

  @override
  void initState() {
    super.initState();
    _startConversation();
  }

  void _startConversation() {
    final introMessage = """
Hola, soy tu asistente especializado en diagnósticos. Aquí están los detalles del diagnóstico que me proporcionaste:
- **Diagnóstico**: ${widget.diagnostic['diagnosticName']}
- **Paciente**: ${widget.diagnostic['patientName']}
- **Tipo de Diagnóstico**: ${widget.diagnostic['diagnosticType']}
- **Predicción Seleccionada**: ${widget.diagnostic['selectedPrediction']}
- **Observaciones**: ${widget.diagnostic['observations'] ?? "No especificadas"}

¿Cómo puedo ayudarte hoy?
""";

    setState(() {
      _messages.add({"role": "assistant", "content": introMessage});
    });
  }

  Future<void> _sendMessage(String message) async {
    if (message.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "content": message});
    });

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "Meta-Llama-3.1-8B-Instruct",
          "messages": [
            {
              "role": "system",
              "content": _messages.first["content"]!,
            },
            ..._messages.sublist(1),
          ],
          "temperature": 0.7,
          "top_p": 0.9,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final assistantMessage = data['choices'][0]['message']['content'];

        setState(() {
          _messages.add({"role": "assistant", "content": assistantMessage});
        });
      } else {
        throw Exception("Error al obtener respuesta de la API");
      }
    } catch (e) {
      setState(() {
        _messages.add({"role": "assistant", "content": "Error: $e"});
      });
    }
  }

  Widget _buildMessageBubble(Map<String, String> message) {
    final isUser = message["role"] == "user";
    return Container(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
      decoration: BoxDecoration(
        color: isUser ? Colors.blueAccent : Colors.teal[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: isUser
          ? Text(
              message["content"] ?? "",
              style: TextStyle(color: Colors.black87, fontSize: 16),
            )
          : _buildFormattedText(message["content"] ?? ""),
    );
  }

  Widget _buildFormattedText(String text) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.+?)\*\*'); // Detectar texto entre **

    text.splitMapJoin(
      regex,
      onMatch: (match) {
        spans.add(TextSpan(
          text: match.group(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ));
        return '';
      },
      onNonMatch: (nonMatch) {
        spans.add(TextSpan(text: nonMatch));
        return '';
      },
    );

    return RichText(
      text: TextSpan(
        style: TextStyle(color: Colors.black87, fontSize: 16),
        children: spans,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Asistente de Diagnóstico"),
        backgroundColor: Colors.blueAccent, // Color suave
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Escribe un mensaje...",
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    final message = _controller.text;
                    _controller.clear();
                    _sendMessage(message);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent, // Color del botón
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Icon(Icons.send, size: 28),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
