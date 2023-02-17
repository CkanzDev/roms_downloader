import 'dart:async';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  static List<Articles> articles = [];

  @override
  void initState() {
    super.initState();

    getWebData();
  }

  Future getWebData() async {
    final url = Uri.parse(
        'https://myrient.erista.me/files/Redump/Sony%20-%20PlayStation%202/');
    final response = await http.get(url);
    dom.Document html = dom.Document.html(response.body);

    final titles = html
        .querySelectorAll('tbody > tr > td > a')
        .map((element) => element.innerHtml.trim())
        .toList();

    final urls = html
        .querySelectorAll('tbody > tr > td > a')
        .map((element) => element.attributes['href'])
        .toList();

    print('Count: ${titles.length}, ${urls.length}');

    setState(() {
      articles = List.generate(
        titles.length,
        (index) => Articles(
          titles: titles[index],
          url: urls[index] ?? 'default',
        ),
      );
    });
    update_list('');
  }

  Future<void> _launchUrl(Uri _url) async {
    if (!await launchUrl(
      _url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $_url');
    }
  }

  List<Articles> display_list = List.from(articles);
  void update_list(String value) {
    setState(() {
      display_list = articles
          .where((element) =>
              element.titles.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            onChanged: (value) => update_list(value),
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade800,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                hintText: "eg: God Hands",
                prefixIcon: Icon(Icons.search),
                prefixIconColor: Colors.white),
          ),
          SizedBox(
            height: 20.0,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: display_list.length,
              itemBuilder: (context, index) {
                final article = display_list[index];

                return ListTile(
                  title: Text(article.titles),
                  onTap: () => _launchUrl(Uri.parse(
                      'https://myrient.erista.me/files/Redump/Sony%20-%20PlayStation%202/' +
                          article.url)),
                );
              },
            ),
          )
        ],
      ),
    ));
  }
}

class Articles {
  final String titles;
  final String url;

  const Articles({
    required this.titles,
    required this.url,
  });
}
