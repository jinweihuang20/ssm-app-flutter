// ignore_for_file: file_names, avoid_print

import 'package:flutter/material.dart';
import 'package:ssmflutter/Networks/WifiHelper.dart';
import 'package:ssmflutter/Pages/FeaturesPage.dart';
import 'package:ssmflutter/Pages/HomePage.dart';
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

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String title = "HOME";
  HomePage homePage = HomePage();
  FeaturesPage featuresPage = FeaturesPage();
  double bottomNaveIconSize = 30;
  Widget appBarRightWidget = const Text('');
  List<PageState> pageStates = [];
  bool isSSMConnected = false;
  final _pageController = PageController(initialPage: 0);
  final Color bottomNavSelectedIconColor = const Color.fromARGB(255, 65, 128, 211);
  var appBarBackgroundColor = Colors.blue;
  Color bottomNavNotSelectedIconColor = Colors.white;
  bool _homePagePauseFlag = false;
  get _homePageControlWidget {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: [
        IconButton(onPressed: () => {homePage.state.saveAccDataToMachine()}, icon: Icon(Icons.save)),
        IconButton(padding: EdgeInsets.all(1), onPressed: _homePagePauseFlag ? null : _homePagePause, icon: const Icon(Icons.pause_circle_outline)),
        IconButton(onPressed: !_homePagePauseFlag ? null : _homePageResume, icon: const Icon(Icons.play_arrow))
      ],
    );
  }

  ///要新增頁面的話就從這邊下手
  List<PageState> getPageStates() {
    List<PageState> ls = [];

    var homePageState = PageState(
        badgeState: MyBadgeState(showBadge: false),
        pageWidget: homePage,
        title: '時/頻圖',
        icon: const Icon(Icons.data_thresholding_sharp),
        iconColor: bottomNavNotSelectedIconColor);

    homePageState.appBarWidget = _homePageControlWidget;
    ls.add(homePageState);

    var featurePageState = PageState(
        pageWidget: featuresPage,
        title: '特徵值',
        icon: const Icon(Icons.featured_play_list),
        iconColor: bottomNavNotSelectedIconColor,
        badgeState: MyBadgeState(showBadge: false));

    ls.add(featurePageState);

    var deviceConnPageState = PageState(
        badgeState: MyBadgeState(showBadge: !isSSMConnected),
        pageWidget: DeviceConnectPage(
          ssmModuleOnConnect: connectedFromDeviceConnecPage,
          connected: isSSMConnected,
        ),
        title: '連線',
        icon: const Icon(Icons.settings_ethernet),
        iconColor: bottomNavNotSelectedIconColor);
    deviceConnPageState.appBarWidget = IconButton(onPressed: opQRCodeSacnner, icon: const Icon(Icons.qr_code_scanner_sharp));
    ls.add(deviceConnPageState);

    var quertPage = PageState(
        badgeState: MyBadgeState(showBadge: false),
        pageWidget: QueryPage(),
        title: '資料查詢',
        icon: const Icon(Icons.query_stats_outlined),
        iconColor: bottomNavNotSelectedIconColor);
    quertPage.appBarWidget = IconButton(
        onPressed: () {
          (quertPage.pageWidget as QueryPage).state.refresh();
        },
        icon: const Icon(Icons.refresh));
    ls.add(quertPage);
    ls.add(PageState(
        badgeState: MyBadgeState(showBadge: false),
        pageWidget: const SettingPage(),
        title: '系統設定',
        icon: const Icon(Icons.settings),
        iconColor: bottomNavNotSelectedIconColor));
    return ls;
  }

  ///創建底部導航按鈕組
  List<Widget> _getBottomNavBar() {
    List<Widget> ls = [];
    List.generate(pageStates.length, (index) {
      var state = pageStates[index];
      String title = state.title;
      Icon icon = state.icon;
      Color iconColor = state.iconColor;
      MyBadgeState badgeState = state.badgeState;
      Widget widget = Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Badge(
            showBadge: badgeState.showBadge,
            child: IconButton(
                onPressed: () {
                  _pageController.jumpToPage(index);
                  setState(() {
                    title = state.title;
                    _renderUI(index);
                  });
                },
                icon: icon,
                color: iconColor,
                iconSize: bottomNaveIconSize),
          ),
          Text(
            title,
            style: TextStyle(color: iconColor, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2),
          )
        ],
      );

      ls.add(widget);
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
      appBarRightWidget = pageState.appBarWidget;
      title = pageState.title;

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

  @override
  void initState() {
    super.initState();
    emulator.start('127.0.0.1', 5000);
    User.loadSetting().then((value) async {
      await tryConnectToSSM(value);
      setState(() {
        bottomNavNotSelectedIconColor = User.setting.appTheme == 'dark' ? Colors.white : Colors.black54;

        pageStates = getPageStates();
        _renderUI(0);
        getSSID().then((value) => print(value));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [appBarRightWidget],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(title)],
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
    });
    print('ssm init connect :$isSSMConnected');
  }

  connectedFromDeviceConnecPage(SSMConnectState state) {
    try {
      ssmModule.close();
    } catch (e) {}
    setState(() {
      isSSMConnected = state.connected;
      pageStates = getPageStates();
      _renderUI(2);
      if (state.connected) {
        featuresPage.state.ssmModule = state.ssmModule;
        homePage.state.ssmModule = state.ssmModule;
      }
    });
  }

  void _homePagePause() {
    setState(() {
      _homePagePauseFlag = true;
      (pageStates[0].pageWidget as HomePage).state.pause();
      _updateAppBarOfHomePage();
    });
  }

  void _homePageResume() {
    setState(() {
      _homePagePauseFlag = false;
      (pageStates[0].pageWidget as HomePage).state.resume();
      _updateAppBarOfHomePage();
    });
  }

  void _updateAppBarOfHomePage() {
    appBarRightWidget = _homePageControlWidget;
  }

  void opQRCodeSacnner() {
    (pageStates[1].pageWidget as DeviceConnectPage).state.openQRCodeScanner();
  }
}
