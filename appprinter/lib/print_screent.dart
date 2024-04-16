import 'package:appprinter/image_utils.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart' as esc;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';

class MyWidget extends StatelessWidget {
  MyWidget({super.key});
  Widget build(BuildContext context) {
    return StreamBuilder<dynamic>(
        stream: FlutterBluetoothPrinter.discovery,
        builder: (context, snapshot) {
          final list = snapshot.data ?? <BluetoothDevice>[];
          return ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                final device = list.elementAt(index);
                return ListTile(
                    title: Text(device.name ?? 'No Name'),
                    subtitle: Text(device.address),
                    onTap: () async {
                      await print(device);
                    });
              });
        });
  }

  Future<void> print(BluetoothDevice divice) async {
    final ByteData data = await rootBundle.load('assets/images/image.png');
    var imagePrint = ImageUtils.splitImage(Uint8List.view(data.buffer));
    if (imagePrint != null) {
      esc.CapabilityProfile profile = await esc.CapabilityProfile.load();
      esc.Generator generator = esc.Generator(esc.PaperSize.mm58, profile);
      List<int> bytes = [];
      int space = 12;
      if (imagePrint.length > space) {
        double count = imagePrint.length / space;
        if (count - count.toInt() > 0) {
          count = count + 1;
        }
        int index = 0;
        while (index < count.toInt()) {
          List<int> byte = [];
          for (int i = index * space;
              i <
                  (index == count.toInt() - 1
                      ? imagePrint.length
                      : (index + 1) * space);
              i++) {
            byte += generator.imageRaster(imagePrint[i]);
          }
          await FlutterBluetoothPrinter.printBytes(
            address: divice.address,
            keepConnected: true,
            data: Uint8List.fromList(byte),
          );
          index++;
        }
        bytes = [];
      } else {
        for (var element in imagePrint) {
          bytes += generator.imageRaster(element);
        }
      }
      bytes += generator.feed(3);
      bytes += generator.cut();
      await FlutterBluetoothPrinter.printBytes(
        address: divice.address,
        keepConnected: true,
        data: Uint8List.fromList(bytes),
      );
    }
  }
}
