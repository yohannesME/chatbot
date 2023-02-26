import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:chatbot/model/Message.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'app_libs.dart';
import 'chatmessage.dart';
import 'threedots.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  List<Message> _messages = [];

  late OpenAI? chatGPT;
  bool _isImageSearch = false;
  bool _isSearching = false;
  bool _isTyping = false;

  @override
  void initState() {
    chatGPT = OpenAI.instance.build(
      token: "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",
      baseOption: HttpSetup(receiveTimeout: 60000),
    );

    super.initState();
  }

  void searchMessage(String msg) {
    String searchKey = _searchController.text.toLowerCase();
    if (searchKey.isEmpty) {
      setState(() {
        //return the old value from database
      });
      return;
    }

    setState(() {
      _messages = _messages
          .where((element) => element.text.toLowerCase().contains(searchKey))
          .toList();
    });
  }

  void _toggleSearchBar() {
    setState(() {
      _isSearching = !_isSearching;
    });
    // if (!_isSearching) {}
  }

  void uploadMessage(Message msg) {
    DBHelper.insert('messages', {
      'id': DateTime.now().toIso8601String(),
      'text': msg.text,
      'isBot': msg.isBot,
      'isImage': msg.isImage
    });
  }

  void _clearDatabase() async {
    setState(() {
      _messages = [];
    });
    await DBHelper.clear();
  }

  Future<void> fetchAndSetPlaces() async {
    final dataList = await DBHelper.getData('messages');
    _messages = dataList
        .map(
          (item) => Message(
            text: item['text'],
            isBot: item['isBot'],
            isImage: item['isImage'],
          ),
        )
        .toList();
    _messages = List.from(_messages.reversed);
  }

  @override
  void dispose() {
    chatGPT?.close();
    chatGPT?.genImgClose();
    appTheme.removeListener(() {});

    super.dispose();
  }

  // Link for api - https://beta.openai.com/account/api-keys

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;
    Message message = Message(
      text: _controller.text,
      isBot: false,
      isImage: false,
    );

    setState(() {
      _messages.insert(0, message);
      _isTyping = true;
      uploadMessage(message);
    });

    _controller.clear();

    if (_isImageSearch) {
      final request = GenerateImage(message.text, 1, size: "256x256");

      final response = await chatGPT!.generateImage(request);
      // Vx.log(response!.data!.last!.url!);
      insertNewData(response!.data!.last!.url!, isImage: true);
    } else {
      final request = CompleteText(
          prompt: message.text, model: kTranslateModelV3, maxTokens: 3000);

      final response = await chatGPT!.onCompleteText(request: request);
      // Vx.log(response!.choices[0].text);
      insertNewData(response!.choices[0].text, isImage: false);
    }
  }

  void insertNewData(String response, {bool isImage = false}) {
    Message botMessage = Message(
      text: response,
      isBot: true,
      isImage: isImage,
    );

    setState(() {
      _isTyping = false;
      _messages.insert(0, botMessage);
      uploadMessage(botMessage);
    });
  }

  Widget _buildTextComposer() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            onSubmitted: (value) => _sendMessage(),
            decoration: const InputDecoration.collapsed(
              hintText: "Question/description",
            ),
          ),
        ),
        ButtonBar(
          children: [
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                _isImageSearch = false;
                _sendMessage();
              },
            ),
            IconButton(
              onPressed: () {
                _isImageSearch = true;
                _sendMessage();
              },
              icon: const Icon(Icons.image),
            )
          ],
        ),
      ],
    ).px16();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: _isSearching
              ? Expanded(
                  child: Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: TextField(
                    controller: _searchController,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(hintText: 'Search'),
                    onSubmitted: (value) {
                      searchMessage(value);
                    },
                  ),
                ))
              : const Text("AI ChatBot"),
          actions: [
            IconButton(
              onPressed: _toggleSearchBar,
              icon: _isSearching
                  ? const Icon(Icons.search_off)
                  : const Icon(Icons.search),
            ),
            IconButton(
              onPressed: _clearDatabase,
              icon: const Icon(Icons.cleaning_services_outlined),
            ),
            IconButton(
              icon: const Icon(Icons.light_mode),
              onPressed: appTheme.switchingTheme,
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Flexible(
                child: FutureBuilder(
                  future: fetchAndSetPlaces(),
                  builder: (ctx, snapshot) =>
                      snapshot.connectionState == ConnectionState.waiting
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : _messages.isEmpty
                              ? const Center(
                                  child: Text('No Request History Yet!'),
                                )
                              : ListView.builder(
                                  reverse: true,
                                  padding: Vx.m8,
                                  itemCount: _messages.length,
                                  itemBuilder: (context, index) {
                                    return ChatMessage(
                                      sender: _messages[index].isBot
                                          ? 'bot'
                                          : 'user',
                                      text: _messages[index].text,
                                      isImage: _messages[index].isImage,
                                    );
                                  },
                                ),
                ),
              ),
              if (_isTyping) const ThreeDots(),
              const Divider(
                height: 1.0,
              ),
              Container(
                child: _buildTextComposer(),
              )
            ],
          ),
        ));
  }
}
