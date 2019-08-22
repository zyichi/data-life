import 'package:data_life/models/contact.dart';
import 'package:data_life/models/location.dart';
import 'package:flutter/material.dart';

import 'package:page_transition/page_transition.dart';

import 'package:data_life/views/login_page.dart';
import 'package:data_life/views/action_page.dart';
import 'package:data_life/views/location_page.dart';
import 'package:data_life/views/contact_page.dart';

class MeView extends StatefulWidget {
  @override
  _MeViewState createState() => _MeViewState();
}

class _MeViewState extends State<MeView> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        GestureDetector(
          child: Padding(
            padding:
                const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 16),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.grey[200],
                  child: Icon(
                    Icons.person,
                    size: 48,
                    color: Colors.grey[500],
                  ),
                ),
                SizedBox(width: 20),
                Text(
                  '立即登陆',
                  style: Theme.of(context).textTheme.headline,
                ),
              ],
            ),
          ),
          onTap: () {
            Navigator.push(
                context,
                PageTransition(
                  child: LoginPage(),
                  type: PageTransitionType.rightToLeft,
                ));
          },
        ),
        _createSeparator(),
        _createGoalStats(),
        _createSeparator(),
        _createContactStats(),
        _createSeparator(),
        _createLocationStats(),
        _createSeparator(),
        _buildActionStats(),
      ],
    );
  }

  Widget _createSeparator() {
    return Container(
      color: Colors.grey[200],
      width: double.infinity,
      height: 16,
    );
  }

  Widget _createGoalStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding:
              const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 0),
          child: Text(
            '目标',
            style: Theme.of(context).textTheme.title,
          ),
        ),
        SizedBox(height: 8),
        Divider(),
        InkWell(
          child: Padding(
            padding:
                const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('正在进行'),
                Row(
                  children: <Widget>[
                    Text('7 个'),
                    Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).textTheme.caption.color,
                    ),
                  ],
                ),
              ],
            ),
          ),
          onTap: () {},
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Divider(),
        ),
        InkWell(
          child: Padding(
            padding:
                const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('已完成'),
                Row(
                  children: <Widget>[
                    Text('128 个'),
                    Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).textTheme.caption.color,
                    ),
                  ],
                ),
              ],
            ),
          ),
          onTap: () {},
        ),
        SizedBox(height: 8),
      ],
    );
  }

  Widget _createContactStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding:
              const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 0),
          child: Row(
            children: <Widget>[
              Text(
                '常在一起的人',
                style: Theme.of(context).textTheme.title,
              ),
              Text(
                '(最近半年)',
                style: Theme.of(context).textTheme.caption,
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Divider(),
        InkWell(
          child: Padding(
            padding:
            const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('丫大宝'),
                Row(
                  children: <Widget>[
                    Text('128 天'),
                    Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).textTheme.caption.color,
                    ),
                  ],
                ),
              ],
            ),
          ),
          onTap: () {},
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Divider(),
        ),
        InkWell(
          child: Padding(
            padding:
            const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('长旭'),
                Row(
                  children: <Widget>[
                    Text('11 天'),
                    Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).textTheme.caption.color,
                    ),
                  ],
                ),
              ],
            ),
          ),
          onTap: () {},
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Divider(),
        ),
        InkWell(
          child: Padding(
            padding:
            const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('芳芳'),
                Row(
                  children: <Widget>[
                    Text('3 天'),
                    Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).textTheme.caption.color,
                    ),
                  ],
                ),
              ],
            ),
          ),
          onTap: () {},
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Divider(),
        ),
        InkWell(
          child: Padding(
            padding:
            const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('妈妈'),
                Row(
                  children: <Widget>[
                    Text('33 天'),
                    Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).textTheme.caption.color,
                    ),
                  ],
                ),
              ],
            ),
          ),
          onTap: () {},
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Divider(),
        ),
        InkWell(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
            child: Text('更多人...',
              style: TextStyle(color: Theme.of(context).textTheme.caption.color),
            ),
          ),
          onTap: () {
            Navigator.push(
                context,
                PageTransition(
                  child: ContactPage(),
                  type: PageTransitionType.rightToLeft,
                ));
          },
        ),
        SizedBox(height: 8),
      ],
    );
  }

  Widget _createLocationStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding:
              const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 0),
          child: Row(
            children: <Widget>[
              Text(
                '常去的地方',
                style: Theme.of(context).textTheme.title,
              ),
              Text(
                '(最近半年)',
                style: Theme.of(context).textTheme.caption,
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Divider(),
        InkWell(
          child: Padding(
            padding:
            const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('东小口公园'),
                Row(
                  children: <Widget>[
                    Text('30 次, 128 小时 15 分钟'),
                    Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).textTheme.caption.color,
                    ),
                  ],
                ),
              ],
            ),
          ),
          onTap: () {},
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Divider(),
        ),
        InkWell(
          child: Padding(
            padding:
            const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('家'),
                Row(
                  children: <Widget>[
                    Text('179 次, 3200 小时 55 分钟'),
                    Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).textTheme.caption.color,
                    ),
                  ],
                ),
              ],
            ),
          ),
          onTap: () {},
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Divider(),
        ),
        InkWell(
          child: Padding(
            padding:
            const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('798创意咖啡屋'),
                Row(
                  children: <Widget>[
                    Text('24 次, 48 小时 8 分钟'),
                    Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).textTheme.caption.color,
                    ),
                  ],
                ),
              ],
            ),
          ),
          onTap: () {},
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Divider(),
        ),
        InkWell(
          child: Padding(
            padding:
            const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('30 次, 128 小时 15 分钟'),
                Row(
                  children: <Widget>[
                    Text('90 次， 90 天 21 分钟'),
                    Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).textTheme.caption.color,
                    ),
                  ],
                ),
              ],
            ),
          ),
          onTap: () {},
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Divider(),
        ),
        InkWell(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
            child: Text('更多地点...',
              style: TextStyle(color: Theme.of(context).textTheme.caption.color),
            ),
          ),
          onTap: () {
            Navigator.push(
                context,
                PageTransition(
                  child: LocationPage(),
                  type: PageTransitionType.rightToLeft,
                ));
          },
        ),
        SizedBox(height: 8),
      ],
    );
  }

  Widget _buildActionStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding:
          const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 0),
          child: Row(
            children: <Widget>[
              Text(
                '常做的事情',
                style: Theme.of(context).textTheme.title,
              ),
              Text(
                '(最近半年)',
                style: Theme.of(context).textTheme.caption,
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        InkWell(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
            child: Text('更多常做...',
              style: TextStyle(color: Theme.of(context).textTheme.caption.color),
            ),
          ),
          onTap: () {
            Navigator.push(
                context,
                PageTransition(
                  child: ActionPage(),
                  type: PageTransitionType.rightToLeft,
                ));
          },
        ),
        SizedBox(height: 16),
      ],
    );
  }
}
