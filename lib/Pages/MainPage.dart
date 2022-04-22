// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:ssmflutter/Router/Routers.dart';

import '../DeviceConnectPage.dart';
import 'QueryPage.dart';
import 'SettingPage.dart';

import '../APPBarFactory.dart' as APPBarFactory;
import '../main.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String title = "HOME";
  double bottomNaveIconSize = 30;
  Widget appBarRightWidget = const Text('');
  List<PageState> pageStates = [];

  final _pageController = PageController(initialPage: 0);
  final Color bottomNavSelectedIconColor = const Color.fromARGB(255, 65, 128, 211);
  final Color bottomNavNotSelectedIconColor = Colors.white;

  ///要新增頁面的話就從這邊下手
  List<PageState> getPageStates() {
    List<PageState> ls = [];
    ls.add(PageState(pageWidget: SubPage1(), title: 'HOME', icon: const Icon(Icons.home), iconColor: bottomNavNotSelectedIconColor));
    ls.add(PageState(pageWidget: const DeviceConnectPage(), title: '連線', icon: const Icon(Icons.settings_ethernet), iconColor: bottomNavNotSelectedIconColor));
    ls.add(PageState(pageWidget: QueryPage(), title: '資料查詢', icon: const Icon(Icons.query_stats_outlined), iconColor: bottomNavNotSelectedIconColor));
    ls.add(PageState(pageWidget: const SettingPage(), title: '系統設定', icon: const Icon(Icons.settings), iconColor: bottomNavNotSelectedIconColor));
    return ls;
  }

  ///創建底部導航按鈕組
  List<Widget> _getBottomNavBar() {
    List<Widget> ls = [];
    List.generate(pageStates.length, (index) {
      var state = pageStates[index];
      Icon icon = state.icon;
      Color iconColor = state.iconColor;
      ls.add(IconButton(
          onPressed: () {
            _pageController.jumpToPage(index);
            setState(() {
              title = state.title;
              _renderUI(index);
            });
          },
          icon: icon,
          color: iconColor,
          iconSize: bottomNaveIconSize));
    });

    return <Widget>[
      Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ls,
          ))
    ];
  }

  ///頁面變更時變更底部導航按鈕ICON的顏色與APP BAR TITLE
  void _renderUI(int activeIndex) {
    setState(() {
      for (var element in pageStates) {
        element.iconColor = bottomNavNotSelectedIconColor;
      }
      PageState pageState = pageStates[activeIndex];
      pageState.iconColor = bottomNavSelectedIconColor;
      title = pageState.title;
    });
  }

  ///取得要餵給 PageView的 Widget列表
  List<Widget> _getPageWidgets() {
    List<Widget> ls = [];
    List.generate(pageStates.length, (index) => {ls.add(pageStates[index].pageWidget)});
    return ls;
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      pageStates = getPageStates();
      _renderUI(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(title), appBarRightWidget],
        ),
        automaticallyImplyLeading: false, //隱藏返回按鈕
      ),
      body: PageView(
        controller: _pageController,
        children: _getPageWidgets(),
        onPageChanged: _renderUI,
      ),
      persistentFooterButtons: _getBottomNavBar(),
    );
  }
}

///
class SubPage1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Page1'),
    );
  }
}
