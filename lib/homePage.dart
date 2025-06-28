import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  bool textScanning = false;

  XFile? imageFile;

  String scannedText = "";

  void getImage() async {
    try {
      final pickedimage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedimage != null) {
        setState(() {
          textScanning = true;
          imageFile = pickedimage;
          scannedText = "";
        });

        recognisedImage(pickedimage);

        setState(() {
          textScanning = false;
        });
      }
    } catch (e) {
      setState(() {
        textScanning = false;
        imageFile = null;
        scannedText = "Error occurred while scanning";
      });
    }
  }

  void getCameraImage() async {
    final permissionStatus = await Permission.camera.request();

    if (permissionStatus.isGranted) {
      try {
        final pickedImage = await ImagePicker().pickImage(
          source: ImageSource.camera,
        );
        if (pickedImage != null) {
          setState(() {
            textScanning = true;
            imageFile = pickedImage;
            scannedText = "";
          });

          recognisedImage(pickedImage);

          setState(() {
            textScanning = false;
          });
        }
      } catch (e) {
        setState(() {
          textScanning = false;
          imageFile = null;
          scannedText = "Error occurred while scanning";
        });
      }
    } else {
      setState(() {
        scannedText = "Camera permission denied";
      });
    }
  }




  void recognisedImage(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    String resultText = "";
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        resultText += line.text + "\n";
      }
    }

    await textRecognizer.close();

    setState(() {
      scannedText = resultText;
    });
  }


  Widget build(BuildContext context) {
    return Container( decoration: BoxDecoration(
      gradient: LinearGradient(
          colors: [
            const Color(0xFF001707),
            const Color(0xFF004520),
            const Color(0xFF005A25),
            const Color(0xFF006E31),
          ],
          begin: const FractionalOffset(0.0, 0.0),
          end: const FractionalOffset(1.0, 0.0),
          stops: [0.0, 1.0, 2.0, 3.0],
          tileMode: TileMode.clamp),
    ),
      child: Scaffold( backgroundColor: Colors.transparent,

        appBar: AppBar(backgroundColor: Colors.black, title: Center(child: Text("Text and face recogniser", style: GoogleFonts.juliusSansOne(color: Colors.white),))),
        body:

        SingleChildScrollView(scrollDirection: Axis.vertical,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [SizedBox(height: 20,),
                if (!textScanning && imageFile == null)
                  Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(5),
                      color: const Color.fromARGB(215, 0, 0, 0),
                    ),
                  ),

                if (imageFile != null)
                  SizedBox(
                    width: 400,
                    height: 400,
                    child: Image.file(File(imageFile!.path), fit: BoxFit.cover),
                  ),

                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        getImage();
                      },
                      child: Container(
                        decoration: BoxDecoration(border: Border.all(width: 2,color: Color.fromARGB(
                            255, 0, 170, 67)),
                          borderRadius: BorderRadius.circular(30),
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                        width: 150,
                        height: 50,
                        child: Center(
                          child: Text(
                            "Gallery",
                            style: GoogleFonts.juliusSansOne(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    InkWell(
                      onTap: getCameraImage,
                      child: Container(
                        decoration: BoxDecoration(border: Border.all(width: 2,color: Color.fromARGB(
                            255, 0, 204, 89)),
                          borderRadius: BorderRadius.circular(30),
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                        width: 150,
                        height: 50,
                        child: Center(
                          child: Text(
                            "Camera",
                            style: GoogleFonts.juliusSansOne(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (scannedText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      scannedText,
                      style: GoogleFonts.juliusSansOne(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  )

              ],
            ),
          ),
        ),
      ),
    );
  }
}



