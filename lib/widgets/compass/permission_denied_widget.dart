import 'package:flutter/material.dart';
import 'package:islamic_app/widgets/app_them.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionDeniedWidget extends StatelessWidget {
  final bool isEnglish;

  const PermissionDeniedWidget({
    super.key,
    required this.isEnglish,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 80, color: primaryColor.withOpacity(0.8)),
            const SizedBox(height: 20),
            Text(
              isEnglish ? 'Location Permission Required' : 'مطلوب إذن الموقع',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Text(
              isEnglish
                  ? 'To determine the Qibla direction, we need access to your location.'
                  : 'لتحديد اتجاه القبلة، نحتاج إلى إذن الوصول إلى موقعك.',
              style: TextStyle(fontSize: 16, color: primaryColor.withOpacity(0.8)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Container(
              alignment: Alignment.center,
              height: MediaQuery.of(context).size.height * 0.09,
              width: MediaQuery.of(context).size.width * 0.78,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.9),  
                borderRadius: BorderRadius.circular(13),
                ),
              child: Text(
                
                textAlign: TextAlign.center,
                isEnglish 
  ? 'Please allow location access, then close and reopen the app.' 
  : 'يرجى منح التطبيق إذن الوصول إلى الموقع ، ثم إغلاق التطبيق وفتحه مجددًا',

                style: const TextStyle(wordSpacing: 5,color: Colors.white, fontSize: 16 , fontFamily: 'Tajawal'),
              ),
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: openAppSettings,
              child: Text(
                isEnglish ? 'Open Settings' : 'فتح الإعدادات',
                style: TextStyle(color: primaryColor.withOpacity(0.8), fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
