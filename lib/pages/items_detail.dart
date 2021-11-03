import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:grimm_scanner/assets/constants.dart';
import 'package:grimm_scanner/models/grimm_item.dart';
import 'package:grimm_scanner/utils/qrutils.dart';

// printing libs
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ItemDetail extends StatefulWidget {
  static const routeName = "/items/detail";

  const ItemDetail({Key? key}) : super(key: key);

  @override
  _ItemDetailState createState() => _ItemDetailState();
}

class _ItemDetailState extends State<ItemDetail> {
  late String qrcode;
  late GrimmItem grimmItem;

  @override
  Widget build(BuildContext context) {
    qrcode = ModalRoute.of(context)!.settings.arguments == null
        ? "NULL"
        : ModalRoute.of(context)!.settings.arguments as String;

    // on s'assure que "qrcode" vaut quelque chose, car sinon plus loin ça va péter
    // s'il vaut "NULL", on force le retour au home screen
    if (qrcode == "NULL") {
      Future.microtask(() => Navigator.pushNamedAndRemoveUntil(
          context, "/", (Route<dynamic> route) => false));
    }

    grimmItem = GrimmItem(
        id: qrcode.replaceAll(Constants.grimmQrCodeStartsWith, ""),
        description: "description",
        location: "location",
        idCategory: "idCategory",
        available: true,
        remark: "remark");

    print("ItemDetail - GrimmItem - " + grimmItem.toString());

    return Scaffold(
        appBar: AppBar(
          title: const Text("Détail de l'objet"),
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: handleAction,
              itemBuilder: (BuildContext context) {
                return Constants.actions.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        body: Center(
            // enlever le Center pour ne plus centrer verticalement
            child: SingleChildScrollView(
                child: Container(
                    child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                QRUtils.generateQrWidgetFromString(grimmItem.getIdForQrCode()),
                const SizedBox(height: 20.0),
                Container(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('items')
                        .doc(grimmItem.id)
                        .snapshots(),
                    builder: buildItemDetails,
                  ),
                ),
                const SizedBox(height: 60.0),
              ],
            ),
          ],
        )))));
  }

  Widget buildItemDetails(
      BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
    /*late CollectionReference _items;

  _items = FirebaseFirestore.instance.collection("items");

  Future<void> updateItem(GrimmItem i) async {
    _items.doc(i.id).update(i.toJson());
  }*/

    // si on a des données
    if (snapshot.hasData) {
      // snapshot.hasData renvoie true même si le doc n'existe pas, il faut tester
      // encore plus loin pour être sûr
      // si on a des données et que le doc existe
      if (snapshot.data!.data() != null) {
        grimmItem = GrimmItem.fromJson(snapshot.data);

        var availability;
        if (grimmItem.available == true) {
          availability = "Disponible";
        } else {
          availability = "Emprunté";
        }

        return Container(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              Text("Objet : " + grimmItem.description,
                  style: TextStyle(color: Colors.black, fontSize: 14)),
              const SizedBox(height: 20.0),
              Text("Emplacement : " + grimmItem.location,
                  style: TextStyle(color: Colors.black, fontSize: 14)),
              const SizedBox(height: 20.0),
              /*Text("Catégorie : " + item.idCategory,
                style: TextStyle(color: Colors.black, fontSize: 14)),*/
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('category')
                    .doc(grimmItem.idCategory)
                    .snapshots(),
                builder: buildItemCategory,
              ),
              const SizedBox(height: 20.0),
              Text("Statut : " + availability,
                  style: TextStyle(color: Colors.black, fontSize: 14)),
              const SizedBox(height: 50.0),
              //if (item.available)
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor,
                    textStyle: TextStyle(
                        fontFamily: "Raleway-Regular", fontSize: 14.0),
                    side: const BorderSide(width: 1.0, color: Colors.black),
                    padding: EdgeInsets.all(10.0),
                  ),
                  onPressed: () async {
                    //if (item.available) {
                    grimmItem.available = !grimmItem.available;
                    //updateItem(item);
                    grimmItem.saveToFirestore();
                    //} else {
                    //  //TODO: définir l'action
                    //}
                  },
                  child: Text(grimmItem.available ? "EMPRUNTER" : "RETOURNER")),
              //const SizedBox(height: 15.0),
              /*if (!item.available)
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor,
                    textStyle: TextStyle(
                        fontFamily: "Raleway-Regular", fontSize: 14.0),
                    side: const BorderSide(width: 1.0, color: Colors.black),
                    padding: EdgeInsets.all(10.0),
                  ),
                  onPressed: () async {
                    if (!item.available) {
                      item.available = true;
                      //updateItem(item);
                      item.saveToFirestore();
                    } else {
                      //TODO: définir l'action
                    }
                  },
                  child: Text("RETOURNER")),*/
              const SizedBox(height: 20.0),
            ]));
      } else {
        return Text("Pas d'object trouvé, scannez à nouveau");
      }
    } else {
      return Text("No item details yet :(");
    }
  }

  Widget buildItemCategory(BuildContext context,
      AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
    // si on a des données
    if (snapshot.hasData) {
      // snapshot.hasData renvoie true même si le doc n'existe pas, il faut tester
      // encore plus loin pour être sûr
      // si on a des données et que le doc existe
      if (snapshot.data!.data() != null) {
        var grimmCategory = snapshot.data;
        return Text("Catégorie : " + grimmCategory!.data()!["name"]);
      }
    }
    return const Text("");
  }

  Future<void> handleAction(String value) async {
    if (value == Constants.actionPrintQr) {
      print("ItemDetail - handleAction - print QR");
      final doc = pw.Document();
      doc.addPage(pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) => <pw.Widget>[
                pw.Center(
                  child: pw.Paragraph(
                      text: grimmItem.description, style: const pw.TextStyle(fontSize: 20,),),
                ),
                pw.Center(
                  child: pw.BarcodeWidget(
                      data: qrcode,
                      width: 150,
                      height: 150,
                      barcode: pw.Barcode.qrCode()),
                ),
                pw.Padding(padding: const pw.EdgeInsets.all(10)),
              ]));
      //build: (pw.Context context) => <pw.Widget>[
      //    pw.Center(child: pw.Paragraph(text: grimmItem.description, style: pw.TextStyle(fontSize: 18))),
      //  ]));
      /*pw.Center(
                child: pw.BarcodeWidget(
                    data: qrcode,
                    width: 300,
                    height: 300,
                    barcode: pw.Barcode.qrCode()),
              )
            ];
          ));*/

      await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => doc.save(), name: "qrgrimm_"+grimmItem.getDescriptionForPdfFilename()+"");
      //await Printing.sharePdf(bytes: await doc.save(), filename: "qrgrimm_"+grimmItem.getDescriptionForPdfFilename()+".pdf");
    }
  }
}
