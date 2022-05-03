// ignore_for_file: file_names, avoid_print

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ssmflutter/Networks/WifiHelper.dart';
import 'package:ssmflutter/Pages/FeaturesPage.dart';
import 'package:ssmflutter/Pages/HomePage.dart';
import 'package:ssmflutter/Pages/WidgetTestPage.dart';
import 'package:ssmflutter/Router/Routers.dart';
import 'package:badges/badges.dart';
import 'package:ssmflutter/SSMModule/module.dart';
import 'DeviceConnectPage.dart';
import '../SysSetting.dart';
import 'QueryPage.dart';
import 'SettingPage.dart';
import '../SSMModule/emulator.dart' as emulator;

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);
  static final pageController = PageController(initialPage: 0);
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String title = "";
  HomePage homePage = HomePage();
  FeaturesPage featuresPage = FeaturesPage();
  double bottomNaveIconSize = 30;
  Widget appBarRightWidget = const Text('');
  List<PageState> pageStates = [];
  bool isSSMConnected = false;
  bool autoStartProcessDone = false;
  var bottomNavSelectedIconColor = Colors.blue;
  var appBarBackgroundColor = Colors.blue;
  Color bottomNavNotSelectedIconColor = Colors.white;
  var currentIndexOfBottomNav = 0;
  List<BottomNavigationBarItem> bottomNaviga = [];

  @override
  void initState() {
    super.initState();
    pageStates = getPageStates();
    bottomNaviga = _getBottomNavBar();
    emulator.start('127.0.0.1', 5000);

    User.loadSetting().then((value) async {
      await tryConnectToSSM(value);
      setState(() {
        bottomNavNotSelectedIconColor = User.setting.appTheme == 'dark' ? Colors.white : Colors.black54;

        _renderUI(0);
        getDeviceWifiInfo().then((value) => print(value?.toJson()));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    PageView pageView = PageView(
      controller: MainPage.pageController,
      children: _getPageWidgets(),
      onPageChanged: _renderUI,
    );

    Widget loadingView = Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(),
          Padding(
            padding: EdgeInsets.only(left: 18.0),
            child: Text(
              'Loading...',
              style: TextStyle(fontSize: 24, letterSpacing: 5),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: pageView,
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: true,
        showUnselectedLabels: true,
        unselectedItemColor: Colors.white,
        unselectedFontSize: 12,
        iconSize: 9,
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndexOfBottomNav,
        onTap: (index) {
          action(index, title);
          setState(() {
            currentIndexOfBottomNav = index;
          });
        },
        items: bottomNaviga,
      ),
      // persistentFooterButtons: _getBottomNavBar(),
    );
  }

  Module ssmModule = Module(ip: '192.168.0.68', port: 5000);
  Future<void> tryConnectToSSM(SysSetting settings) async {
    ///
    ssmModule = Module(ip: settings.ssmIp, port: settings.ssmPort);
    bool connect = await ssmModule.connect();
    print('ssm init connect :$connect');
    setState(() {
      isSSMConnected = connect;
      if (connect) {
        homePage.state.ssmModule = ssmModule;
        featuresPage.state.ssmModule = ssmModule;
      }
      autoStartProcessDone = true;
    });
    print('ssm init connect :$isSSMConnected');
  }

  connectedFromDeviceConnecPage(SSMConnectState state) {
    try {
      ssmModule.close();
    } catch (e) {}
    setState(() {
      isSSMConnected = state.connected;
      if (state.connected) {
        featuresPage.state.ssmModule = state.ssmModule;
        homePage.state.ssmModule = state.ssmModule;
      }
      if (state.isIPChange) {
        featuresPage.state.clearData();
      }
    });
  }

  void action(int index, String title) {
    MainPage.pageController.jumpToPage(index);
    setState(() {
      title = title;
      _renderUI(index);
    });
  }

  ///要新增頁面的話就從這邊下手
  List<PageState> getPageStates() {
    double iconSize = 30;
    List<PageState> ls = [];
    var homePageState = PageState(
        badgeState: MyBadgeState(showBadge: false),
        pageWidget: homePage,
        title: 'HOME',
        icon: Icon(
          Icons.home,
          size: iconSize,
        ),
        iconColor: bottomNavNotSelectedIconColor);
    ls.add(homePageState);
    var featurePageState = PageState(
        pageWidget: featuresPage,
        title: '特徵值',
        // icon: ImageIcon(AssetImage('assets/icon/icon.png')),
        icon: Icon(
          Icons.featured_play_list,
          size: iconSize,
        ),
        iconColor: bottomNavNotSelectedIconColor,
        badgeState: MyBadgeState(showBadge: false));
    ls.add(featurePageState);
    var deviceConnPageState = PageState(
        badgeState: MyBadgeState(showBadge: !isSSMConnected),
        pageWidget: DeviceConnectPage(
          ssmModuleOnConnect: connectedFromDeviceConnecPage,
          connected: isSSMConnected,
        ),
        title: '模組連線/設定',
        icon: Icon(Icons.settings_ethernet, size: iconSize),
        iconColor: bottomNavNotSelectedIconColor);
    ls.add(deviceConnPageState);
    var quertPage = PageState(
        badgeState: MyBadgeState(showBadge: false),
        pageWidget: QueryPage(),
        title: '資料查詢',
        icon: Icon(Icons.query_stats_outlined, size: iconSize),
        iconColor: bottomNavNotSelectedIconColor);
    ls.add(quertPage);
    ls.add(PageState(
        badgeState: MyBadgeState(showBadge: false),
        pageWidget: const SettingPage(),
        title: '系統設定',
        icon: Icon(Icons.settings, size: iconSize),
        iconColor: bottomNavNotSelectedIconColor));

    // if (kDebugMode) {
    //   ls.add(PageState(
    //       pageWidget: const WidgetTestPage(),
    //       title: 'Widget test',
    //       icon: Icon(Icons.widgets, size: iconSize),
    //       iconColor: bottomNavSelectedIconColor,
    //       badgeState: MyBadgeState(showBadge: false)));
    // }

    return ls;
  }

  ///創建底部導航按鈕組
  List<BottomNavigationBarItem> _getBottomNavBar() {
    List<BottomNavigationBarItem> ls = [];
    List.generate(pageStates.length, (index) {
      var state = pageStates[index];
      dynamic icon = state.icon;
      ls.add(BottomNavigationBarItem(icon: icon, label: state.title));
    });
    return ls;
  }

  ///頁面變更時變更底部導航按鈕ICON的顏色與APP BAR TITLE
  void _renderUI(int activeIndex) {
    setState(() {
      // for (var element in pageStates) {
      //   element.iconColor = bottomNavNotSelectedIconColor;
      // }
      // PageState pageState = pageStates[activeIndex];
      // pageState.iconColor = bottomNavSelectedIconColor;
      // appBarRightWidget = pageState.appBarWidget;
      // title = pageState.title;
      currentIndexOfBottomNav = activeIndex;

      ///
      if (activeIndex == 2) {
        appBarBackgroundColor = isSSMConnected ? Colors.blue : Colors.red;
      } else {
        appBarBackgroundColor = Colors.blue;
      }
    });
  }

  ///取得要餵給 PageView的 Widget列表
  List<Widget> _getPageWidgets() {
    List<Widget> ls = [];
    List.generate(pageStates.length, (index) => {ls.add(pageStates[index].pageWidget)});
    return ls;
  }
}
