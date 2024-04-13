// import 'dart:developer';
// import 'dart:io';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:lets_chat/API/apis.dart';
// import 'package:lets_chat/helper/dialogs.dart';
// import 'package:lets_chat/models/chat_user.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:flutter/material.dart';
//
// class PdfOptionsScreen extends StatefulWidget {
//   final ChatUser user;
//   const PdfOptionsScreen({Key? key, required this.user}) : super(key: key);
//
//   @override
//   State<PdfOptionsScreen> createState() => _PdfOptionsScreenState();
// }
//
// class _PdfOptionsScreenState extends State<PdfOptionsScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('PDF Converter'),
//       ),
//       body: GridView.count(
//         crossAxisCount: 2,
//         children: [
//           GestureDetector(
//             onTap: () {
//               PdfCreator.createPdf(context, widget.user); // Pass user here
//             },
//             child: Card(
//               color: Colors.blueAccent,
//               child: Center(
//                 child: Text(
//                   'Create PDF',
//                   style: TextStyle(color: Colors.white, fontSize: 18),
//                 ),
//               ),
//             ),
//           ),
//           GestureDetector(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => PdfListScreen(user: widget.user),
//                 ),
//               );
//             },
//             child: Card(
//               color: Colors.blueAccent,
//               child: Center(
//                 child: Text(
//                   'View PDF',
//                   style: TextStyle(color: Colors.white, fontSize: 18),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class PdfCreator {
//   static Future<void> createPdf(BuildContext context, ChatUser user) async {
//     try {
//       // Select multiple images from the gallery
//       final List<XFile> images =
//       await ImagePicker().pickMultiImage(imageQuality: 50);
//
//       if (images == null || images.isEmpty) {
//         // No images selected
//         return;
//       }
//
//       // Create a PDF document
//       final pdf = pw.Document();
//
//       // Add images to the PDF document
//       for (final image in images) {
//         final imageData = await image.readAsBytes();
//         final pdfImage = pw.MemoryImage(
//           imageData,
//         );
//         pdf.addPage(
//           pw.Page(
//             build: (pw.Context context) {
//               return pw.Center(
//                 child: pw.Image(pdfImage),
//               );
//             },
//           ),
//         );
//       }
//
//       // Save the PDF document to a temporary file
//       final tempDir = await getTemporaryDirectory();
//       final tempPath = tempDir.path;
//       final tempFile = File('$tempPath/example.pdf');
//       await tempFile.writeAsBytes(await pdf.save());
//
//       // Pass user to uploadPdfToFirebaseStorage
//       // ignore: use_build_context_synchronously
//       await uploadPdfToFirebaseStorage(context, user, tempFile);
//     } catch (e) {
//       // Handle errors
//       log('Error creating PDF: $e');
//       // ignore: use_build_context_synchronously
//       Dialogs.showSnackbar(context, "Error creating PDF: $e");
//     }
//   }
//
//   static Future<void> uploadPdfToFirebaseStorage(
//       BuildContext context, ChatUser user, File file) async {
//     try {
//       final String fileName = '${DateTime.now()}.pdf';
//       // Upload the PDF file to Firebase Storage
//       final Reference storageRef =
//       FirebaseStorage.instance.ref().child('pdfs/$fileName');
//       final UploadTask uploadTask = storageRef.putFile(file);
//       final TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
//
//       // Get the download URL of the uploaded PDF
//       final String downloadUrl = await snapshot.ref.getDownloadURL();
//
//       // Call the sendMessageWithPDF function from APIs.dart
//       await APIs.sendMessageWithPDF(user, file);
//
//       // You can now use the downloadUrl as needed (e.g., save it to Firestore)
//       log('PDF uploaded to: $downloadUrl');
//       Dialogs.showSnackbar(context, 'PDF uploaded to: $downloadUrl');
//       Navigator.pop(context);
//     } catch (e) {
//       // Handle errors
//       log('Error uploading PDF: $e');
//       Dialogs.showSnackbar(context, 'Error uploading PDF: $e');
//     }
//   }
// }
// class PdfListScreen extends StatefulWidget {
//   final ChatUser user;
//   const PdfListScreen({Key? key, required this.user}) : super(key: key);
//
//   @override
//   State<PdfListScreen> createState() => _PdfListScreenState();
// }
//
// class _PdfListScreenState extends State<PdfListScreen> {
//   List<String> pdfUrls = [];
//
//   @override
//   void initState() {
//     super.initState();
//     // Fetch PDF URLs from Firebase Storage
//     fetchPdfUrls();
//   }
//
//   Future<void> fetchPdfUrls() async {
//     try {
//       final ListResult result = await FirebaseStorage.instance
//           .ref()
//           .child('pdfs')
//           .listAll();
//
//       setState(() {
//         pdfUrls = result.items.map((item) => item.fullPath).toList();
//       });
//     } catch (e) {
//       log('Error fetching PDF URLs: $e');
//       Dialogs.showSnackbar(context, 'Error fetching PDF URLs: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('PDF List'),
//       ),
//       body: ListView.builder(
//         itemCount: pdfUrls.length,
//         itemBuilder: (context, index) {
//           return ListTile(
//             title: Text('PDF ${index + 1}'),
//             onTap: () {
//               Navigator.pop(context);
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) =>
//                       PdfViewScreen(pdfUrl: pdfUrls[index]),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
// class PdfViewScreen extends StatefulWidget {
//   final String pdfUrl;
//
//   const PdfViewScreen({Key? key, required this.pdfUrl}) : super(key: key);
//
//   @override
//   _PdfViewScreenState createState() => _PdfViewScreenState();
// }
//
// class _PdfViewScreenState extends State<PdfViewScreen> {
//   PDFDocument? document;
//
//   @override
//   void initState() {
//     super.initState();
//     loadDocument();
//   }
//
//   Future<void> loadDocument() async {
//     document = await PDFDocument.fromURL(widget.pdfUrl);
//     setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("PDF Viewer"),
//       ),
//       body: Center(
//         child: document != null
//             ? PDFViewer(document: document!)
//             : const CircularProgressIndicator(),
//       ),
//     );
//   }
// }
