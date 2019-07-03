import 'package:flutter/material.dart';

import 'package:data_life/views/hero_name.dart';

enum SearchType {
  all,
  event,
  goal,
  people,
  place,
}

class _SearchHistory {
  final SearchType type;
  final String keyword;

  const _SearchHistory({
    @required this.type,
    @required this.keyword,
  })  : assert(type != null),
        assert(keyword != null);
}

const _SearchHistories = <_SearchHistory>[
  _SearchHistory(
    type: SearchType.people,
    keyword: '丫宝',
  ),
  _SearchHistory(
    type: SearchType.people,
    keyword: '一驰',
  ),
  _SearchHistory(
    type: SearchType.people,
    keyword: '爸爸',
  ),
  _SearchHistory(
    type: SearchType.people,
    keyword: '妈妈',
  ),
  _SearchHistory(
    type: SearchType.people,
    keyword: '二哥',
  ),
  _SearchHistory(
    type: SearchType.people,
    keyword: '大哥',
  ),
  _SearchHistory(
    type: SearchType.people,
    keyword: '卫平',
  ),
  _SearchHistory(
    type: SearchType.people,
    keyword: '卫新',
  ),
  _SearchHistory(
    type: SearchType.people,
    keyword: '张镜',
  ),
  _SearchHistory(
    type: SearchType.place,
    keyword: '溪城家园',
  ),
  _SearchHistory(
    type: SearchType.event,
    keyword: '自驾游',
  ),
  _SearchHistory(
    type: SearchType.all,
    keyword: '骑行',
  ),
  _SearchHistory(
    type: SearchType.goal,
    keyword: '100万',
  ),
  _SearchHistory(
    type: SearchType.goal,
    keyword: '200万',
  ),
  _SearchHistory(
    type: SearchType.goal,
    keyword: '400万',
  ),
  _SearchHistory(
    type: SearchType.goal,
    keyword: '800万',
  ),
  _SearchHistory(
    type: SearchType.goal,
    keyword: '1600万',
  ),
];

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Hero(
                tag: HeroName.searchLife,
                child: _SearchBar(),
              ),
              Divider(
                height: 2.0,
              ),
              Container(
                padding: EdgeInsets.only(left: 16.0, top: 32.0, bottom: 16.0),
                child: Text('Types'.toUpperCase()),
              ),
              Wrap(
                alignment: WrapAlignment.start,
                spacing: 8.0,
                runSpacing: 8.0,
                children: <Widget>[
                  Container(
                    width: 80.0,
                    height: 80.0,
                    child: Stack(
                      alignment: Alignment(0, 0),
                      children: <Widget>[
                        Icon(
                          Icons.event,
                        ),
                        Positioned(
                          child: Text('Event'),
                          bottom: 8.0,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 80.0,
                    height: 80.0,
                    child: Stack(
                      alignment: Alignment(0, 0),
                      children: <Widget>[
                        Icon(
                          Icons.outlined_flag,
                        ),
                        Positioned(
                          child: Text('Goal'),
                          bottom: 8.0,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 80.0,
                    height: 80.0,
                    child: Stack(
                      alignment: Alignment(0, 0),
                      children: <Widget>[
                        Icon(
                          Icons.people_outline,
                        ),
                        Positioned(
                          child: Text('People'),
                          bottom: 8.0,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 80.0,
                    height: 80.0,
                    child: Stack(
                      children: <Widget>[
                        Align(
                          child: Icon(
                            Icons.place,
                          ),
                          alignment: Alignment.center,
                        ),
                        Align(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text('Place'),
                          ),
                          alignment: Alignment.bottomCenter,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.only(left: 16.0, top: 32.0, bottom: 16.0),
                child: Text('History'.toUpperCase()),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _SearchHistories.length,
                  itemBuilder: (context, i) {
                    _SearchHistory history = _SearchHistories[i];
                    return InkWell(
                      onTap: () {
                        print('History tapped');
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 32.0, top: 0.0, bottom: 0.0, right: 32.0),
                        child: Row(
                          children: <Widget>[
                            Text(
                              history.keyword,
                              style: TextStyle(),
                            ),
                            Expanded(
                              child: SizedBox(),
                            ),
                            InkWell(
                              onTap: () {
                                print('Remove tapped');
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Remove',
                                  style: TextStyle(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        height: 56.0,
        width: double.infinity,
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            Expanded(
              child: TextField(
                style: Theme.of(context).textTheme.title.copyWith(
                      fontWeight: FontWeight.normal,
                    ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search life',
                ),
                autofocus: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
