import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

final bd = Firestore.instance;
String cuenta = "";
String alumnoNombre = "";
String imei = "";
String sim = "";
Color fondoAlumno=Colors.redAccent;

void main() => runApp(Escaner());

class Escaner extends StatefulWidget {
  @override
  createState() => Estado();
}

class Estado extends State<Escaner> {
  String lecturaEscaner = '';


  TextEditingController numeroCuentaControlador;

  @override
  void initState() {
    super.initState();
  }

// -------------------- CÓDIGO DE BARRAS
  Future<void> escanerCodigoBarras(String tipo) async {
    String lecturaCodigoBarras;

    try {
      lecturaCodigoBarras = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666",
          "Cancelar",
          true,
          ScanMode.BARCODE);
    }
    on PlatformException {
      lecturaCodigoBarras = 'Falló al obtener la versión de la plataforma';
    }

    if (!mounted) return;

    setState(() {
      if (tipo == "cuenta")
        cuenta = lecturaCodigoBarras;
      else if (tipo == "sim")
        sim = lecturaCodigoBarras;
      else
        imei = lecturaCodigoBarras;
    });
  }


  @override
  Widget build(BuildContext context) =>
      MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
              appBar: AppBar(title: Text('Entrega de tabletas')),
              body:

              Padding(
                padding: const EdgeInsets.all(12.0),
                child: ListView(
                    children: [

                      ListTile(
                          title: Text("No. de cuenta: $cuenta"),
                          subtitle: Text("Alumno: $alumnoNombre"),
                          selectedTileColor: fondoAlumno,
                      ),

                      RaisedButton(
                        color: Colors.white30,
                      child: Text("Escanear cuenta"),
                      onPressed: () {
                        escanerCodigoBarras("cuenta");
                      }
                  ),

                    RaisedButton(
                      child: Text('Buscar alumno'),
                      onPressed: () {
                        consultar(cuenta);
                        setState(() {});
                      },
                    ),


                      ListTile(
                        title: Text("Sim: $sim"),
                        subtitle: Text("IMEI: $imei"),
                      ),

                      RaisedButton(
                          child: Text("Escanear SIM"),
                          onPressed: (){
                            escanerCodigoBarras("sim");
                          }
                      ),

                      RaisedButton(
                          child: Text("Escanear IMEI"),
                          onPressed: (){
                            escanerCodigoBarras("imei");
                          }
                      ),

                      Text(""),
                      Text(""),
                      Visibility(visible: true,
                        child: RaisedButton(
                            color: Colors.green,
                            child: Text("Asignar tableta"),
                            onPressed: (){
                              actualizar(cuenta, imei, sim);
                                setState(() {
                                  cuenta="";
                                  alumnoNombre = "";
                                  imei="";
                                  sim="";
                                });
                            }
                        ),
                      ),


            ],
          ),
              )


        /*
          Builder(builder: (BuildContext context) {
            return Container(
                alignment: Alignment.topCenter,
                child: Flex(
                    direction: Axis.vertical,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[

                      TextField(
                        controller: numeroCuentaControlador,
                        decoration: InputDecoration(
                          hintText: "Numero de cuenta",
                        ),
                      ),


                      //-------------------- MUESTRA Y BUSCA CUENTA

                      Row(
                        children: [
                          RaisedButton(
                              child: Text("Escanear cuenta"),
                              onPressed: (){
                                  escanerCodigoBarras("cuenta");
                                }
                              ),
                          RaisedButton(
                            child: Text('Buscar'),
                            onPressed: (){
                              consultar(cuenta);
                              setState(() {
                              });
                            },
                          ),
                        ],
                      ),


                      Text("Alumno: $alumnoNombre"),
                      Divider(),


                      Text("Sim $sim"),
                      RaisedButton(
                          child: Text("Escanear SIM"),
                          onPressed: (){
                            escanerCodigoBarras("sim");
                          }
                      ),
                      Divider(),

                      Text("IMEI $imei"),
                      RaisedButton(
                          child: Text("Escanear IMEI"),
                          onPressed: (){
                            escanerCodigoBarras("imei");
                          }
                      ),

                      Divider(),

                      RaisedButton(
                          child: Text("Asignar tableta"),
                          onPressed: (){
                            actualizar(imei, sim);
                          }
                      ),

                    ]));
          })

          */


      )

  );
}


void consultar(String cuenta) async {
  try {

    /*
    Firestore.instance.collection('tabletas').where('cuenta', isEqualTo: cuenta)
        .snapshots().listen((data) {
          if(data.documents.length>0)
            alumnoNombre = data.documents[0]['nombre'];
          else
            alumnoNombre="NO EXISTE";

          print('Nombre: $alumnoNombre');
        }
    );
*/

    bd.collection('tabletas').document(cuenta).get().then(
            (value) {
          if (value.exists) {
            alumnoNombre = value.data['nombre'];
            imei = value.data['imei'];
            sim = value.data['sim'];
          }
          else {
            alumnoNombre = "NO EXISTE";
            imei = "";
            sim = "";
          }
        }
    );
  }
  catch (error) {
    //print(error);
    alumnoNombre = "NO EXISTE";
  }
}


void actualizar(String cuenta, String sim, String imei) async {
  try {
    await bd.collection('tabletas')
        .document(cuenta)
        .updateData({
      'sim': sim,
      'imei': imei
    });
  }
  catch (error) {
    print(error);
  }
}


/*
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

final bd = Firestore.instance;
String alumnoNombre="";
String imei="";
String sim="";

void main() => runApp(Escaner());

class Escaner extends StatefulWidget {
  @override
  createState() => Estado();
}

class Estado extends State<Escaner> {
  String lecturaEscaner = '';
  String cuenta="";

  TextEditingController numeroCuentaControlador;

  @override
  void initState() {
    super.initState();
  }

// -------------------- CÓDIGO DE BARRAS
  Future<void> escanerCodigoBarras(String tipo) async {
    String lecturaCodigoBarras;

    try {
      lecturaCodigoBarras = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666",
          "Cancelar",
          true,
          ScanMode.BARCODE);
    }
    on PlatformException {
      lecturaCodigoBarras = 'Falló al obtener la versión de la plataforma';
    }

    if (!mounted) return;

    setState(() {
      if(tipo=="cuenta")
        cuenta=lecturaCodigoBarras;
      else if(tipo=="sim")
        sim=lecturaCodigoBarras;
      else
        imei=lecturaCodigoBarras;
    });
  }


  @override
  Widget build(BuildContext context) => MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: AppBar(title: Text('Lector de códigos $lecturaEscaner')),
          body: Builder(builder: (BuildContext context) {
            return Container(
                alignment: Alignment.topCenter,
                child: Flex(
                    direction: Axis.vertical,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[

                      TextField(
                        controller: numeroCuentaControlador,
                        decoration: InputDecoration(
                          hintText: "Numero de cuenta",
                        ),
                      ),



                      //-------------------- MUESTRA Y BUSCA CUENTA
                      Text("No. de cuenta: $cuenta"),
                      Row(
                        children: [
                          RaisedButton(
                              child: Text("Escanear cuenta"),
                              onPressed: (){
                                  escanerCodigoBarras("cuenta");
                                }
                              ),
                          RaisedButton(
                            child: Text('Buscar'),
                            onPressed: (){
                              consultar(cuenta);
                              setState(() {
                              });
                            },
                          ),
                        ],
                      ),




                      Text("Alumno: $alumnoNombre"),
                      Divider(),


                      Text("Sim $sim"),
                      RaisedButton(
                          child: Text("Escanear SIM"),
                          onPressed: (){
                            escanerCodigoBarras("sim");
                          }
                      ),
                      Divider(),

                      Text("IMEI $imei"),
                      RaisedButton(
                          child: Text("Escanear IMEI"),
                          onPressed: (){
                            escanerCodigoBarras("imei");
                          }
                      ),

                      Divider(),

                      RaisedButton(
                          child: Text("Asignar tableta"),
                          onPressed: (){
                            actualizar(imei, sim);
                          }
                      ),



                    ]));
          })
      )
  );
}


void consultar(String cuenta)async{
  try {

    /*
    Firestore.instance.collection('tabletas').where('cuenta', isEqualTo: cuenta)
        .snapshots().listen((data) {
          if(data.documents.length>0)
            alumnoNombre = data.documents[0]['nombre'];
          else
            alumnoNombre="NO EXISTE";

          print('Nombre: $alumnoNombre');
        }
    );
*/

          bd.collection('tabletas').document(cuenta).get().then(
            (value) {
              if(value.exists) {
                alumnoNombre = value.data['nombre'];
                imei=value.data['imei'];
                sim=value.data['sim'];
              }
              else {
                alumnoNombre = "NO EXISTE";
                imei="";
                sim="";
              }
            }
    );
  }
  catch(error){
    //print(error);
    alumnoNombre="NO EXISTE";
  }
}


void actualizar(String sim, String imei) async{
  try {
    await bd.collection('tabletas')
        .document('KcJUNtjypfSP66YNMUOr')
        .updateData({
          'sim': sim,
          'imei': imei
        });
  }
  catch(error){
    print(error);
  }
}




 */






