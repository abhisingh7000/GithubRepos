import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GitHub Repositories',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> repositories = [];

  @override
  void initState() {
    super.initState();
    fetchRepositories();
  }

  Future<void> fetchRepositories() async {
    final response = await http
        .get(Uri.parse('https://api.github.com/users/freeCodeCamp/repos'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      setState(() {
        repositories =
            data.map((repo) => repo as Map<String, dynamic>).toList();
      });

      fetchLastCommits();
    } else {
      throw Exception('Failed to load repositories');
    }
  }

  Future<void> fetchLastCommits() async {
    for (final repo in repositories) {
      final response = await http.get((Uri.parse(
          'https://api.github.com/repos/${repo['full_name']}/commits')));

      if (response.statusCode == 200) {
        final List<dynamic> commitsData = json.decode(response.body);

        final lastCommitData =
            commitsData.isNotEmpty ? commitsData.first : null;

        setState(() {
          repo['last_commit'] = lastCommitData;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GitHub Repositories'),
      ),
      body: repositories.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: repositories.length,
              itemBuilder: (BuildContext context, int index) {
                final repo = repositories[index];
                final lastCommit = repo['last_commit'];

                return ListTile(
                  title: Text(repo['name']),
                  subtitle: lastCommit != null
                      ? Text(lastCommit['commit']['message'])
                      : Text('Loading...'),
                );
              },
            ),
    );
  }
}
