import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

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
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 59, 59, 59),
      appBar: AppBar(title: Center(child: Text("Text and face recogniser"))),
      body: SingleChildScrollView(scrollDirection: Axis.vertical,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!textScanning && imageFile == null)
                Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                ),

              if (imageFile != null)
                SizedBox(
                  width: 400,
                  height: 400,
                  child: Image.file(File(imageFile!.path), fit: BoxFit.cover),
                ),

              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      getImage();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color.fromARGB(255, 0, 0, 0),
                      ),
                      child: Center(
                        child: Text(
                          "Gallery",
                          style: GoogleFonts.juliusSansOne(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      width: 100,
                      height: 100,
                    ),
                  ),
                  SizedBox(width: 5),
                  InkWell(
                    onTap: () {},
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color.fromARGB(255, 0, 0, 0),
                      ),
                      child: Center(
                        child: Text(
                          "Camera",
                          style: GoogleFonts.juliusSansOne(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      width: 100,
                      height: 100,
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
    );
  }
}
