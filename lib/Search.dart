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
  static List<Articles> ps2 = [];
  static List<Articles> gba = [];
  static List<Articles> nds = [];

  @override
  void initState() {
    super.initState();

    getWebDataPs2();
  }

  Future getAllData() async {
    articles = [...ps2, ...gba, ...nds].toSet().toList();
    update_list('');
  }

  Future getWebDataNds() async {
    final url = Uri.parse(
        'https://myrient.erista.me/files/No-Intro/Nintendo%20-%20Nintendo%20DS%20(Decrypted)/');
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

    final size = html
        .querySelectorAll('tbody > tr> td:nth-child(1)')
        .map((element) => element.innerHtml.trim())
        .toList();

    print('Count NDS: ${titles.length}, ${urls.length}');
    setState(() {
      nds = List.generate(
        titles.length,
        (index) => Articles(
          titles: titles[index],
          url:
              'https://myrient.erista.me/files/No-Intro/Nintendo%20-%20Nintendo%20DS%20(Decrypted)/' +
                  urls[index].toString(),
          type: 'NDS',
          size: size[index],
        ),
      );
    });
    getAllData();
  }

  Future getWebDataGba() async {
    final urlGba = Uri.parse(
        'https://ia804602.us.archive.org/view_archive.php?archive=/12/items/htgdb-gamepacks/%40GBA%20-%20EverDrive%20GBA%202022-08-08.zip');
    final responseGba = await http.get(urlGba);
    dom.Document html = dom.Document.html(responseGba.body);

    final titles = html
        .querySelectorAll('div > table > tbody > tr > td > a')
        .map((element) => element.innerHtml.trim())
        .toList();

    final urls = html
        .querySelectorAll('div > table > tbody > tr > td > a')
        .map((element) => element.attributes['href'])
        .toList();

    print('Count Gba: ${titles.length}, ${urls.length}');
    setState(() {
      gba = List.generate(
        titles.length,
        (index) => Articles(
          titles: titles[index],
          url:
              'https://ia804602.us.archive.org/view_archive.php?archive=/12/items/htgdb-gamepacks/%40GBA%20-%20EverDrive%20GBA%202022-08-08.zip' +
                  urls[index].toString(),
          type: 'GBA',
          size: 'N',
        ),
      );
    });
    getWebDataNds();
  }

  Future getWebDataPs2() async {
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

    final size = html
        .querySelectorAll('tbody > tr > td:nth-child(1)')
        .map((element) => element.innerHtml.trim())
        .toList();

    print('Count Ps2: ${titles.length}, ${urls.length}');

    setState(() {
      ps2 = List.generate(
        titles.length,
        (index) => Articles(
          titles: titles[index],
          url:
              'https://myrient.erista.me/files/Redump/Sony%20-%20PlayStation%202/' +
                  urls[index].toString(),
          type: 'PS2',
          size: size[index],
        ),
      );
    });
    getWebDataGba();
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
                  subtitle: Text(article.type + ", " + article.size),
                  onTap: () => _launchUrl(Uri.parse(article.url)),
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
  final String type;
  final String size;

  const Articles({
    required this.titles,
    required this.url,
    required this.type,
    required this.size,
  });
}
