import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:server_iot/main_page_provider.dart';

class MainPage extends StatelessWidget {
  const MainPage._({
    Key? key,
  }) : super(key: key);

  static Widget create() {
    return ChangeNotifierProvider(
      create: (c) {
        final provider = MainPageProvider();
        provider.run();
        return provider;
      },
      child: const MainPage._(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<MainPageProvider>();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SafeArea(
        child: Column(
          children: [
            _getLabels(p),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                return _getImages(p, constraints.maxWidth);
              },
            ),
          ],
        ),
      ),
    );
  }

  Row _getImages(MainPageProvider p, double maxWidth) {
    double widgetWidth = (maxWidth / 3) - 10;
    double widgetHeight = widgetWidth * 1.2;
    return Row(
      children: [
        SizedBox(
          width: widgetWidth,
          height: widgetHeight,
          child: SvgPicture.asset('assets/fan.svg'),
        ),
        AnimatedOpacity(
          opacity: p.isFanOn ? 1 : 0,
          duration: const Duration(seconds: 2),
          child: SizedBox(
            width: widgetWidth,
            height: widgetHeight,
            child: SvgPicture.asset('assets/wind.svg'),
          ),
        ),
        SizedBox(
          width: widgetWidth,
          height: widgetHeight,
          child: SvgPicture.asset('assets/aquarium.svg'),
        ),
      ],
    );
  }

  Widget _getLabels(MainPageProvider p) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              FittedBox(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Temperatura: ${p.temp.toStringAsFixed(2)}º',
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Ambiente: ${p.envTemp.toStringAsFixed(2)}º',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              FittedBox(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Mínima ventilador: ${p.minTemp.toStringAsFixed(2)}º',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        SizedBox(
          width: 120,
          child: Column(
            children: [
              _getIpLabel(p),
              _getPortLabel(p),
            ],
          ),
        ),
      ],
    );
  }

  Widget _getIpLabel(MainPageProvider p) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FutureBuilder(
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            return Text('IP: ${snapshot.data}');
          } else if (snapshot.hasError) {
            return Text('Erro: ${snapshot.error}');
          } else {
            return const LinearProgressIndicator();
          }
        }),
        future: p.ip,
      ),
    );
  }

  Widget _getPortLabel(MainPageProvider p) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text('Porta: ${p.port}'),
    );
  }
}
