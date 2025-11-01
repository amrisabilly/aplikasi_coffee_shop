import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class JanjianPage extends StatefulWidget {
  const JanjianPage({super.key});

  @override
  State<JanjianPage> createState() => _JanjianPageState();
}

class _JanjianPageState extends State<JanjianPage> {
  // Lokasi user (otomatis)
  String myCity = 'Mendeteksi...';
  String myCountry = '';
  String myTimezone = '';
  int myUtcOffset = 7;
  RangeValues myRange = const RangeValues(19, 23);

  // Lokasi teman (dari maps)
  String friendCity = '';
  String friendCountry = '';
  String friendTimezone = '';
  int friendUtcOffset = 1;
  RangeValues friendRange = const RangeValues(18, 22);

  // Hasil blend
  String blendResult = '';
  String blendDesc = '';
  bool blendFound = false;

  // Marker teman
  LatLng? friendLatLng;

  Future<void> detectMyLocation() async {
    setState(() {
      myCity = 'Mendeteksi...';
      myCountry = '';
      myTimezone = '';
      myUtcOffset = 7;
    });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          myCity = 'Lokasi tidak aktif';
        });
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            myCity = 'Izin lokasi ditolak';
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          myCity = 'Izin lokasi permanen ditolak';
        });
        return;
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        myCity =
            place.locality ?? place.subAdministrativeArea ?? 'Tidak diketahui';
        myCountry = place.country ?? '';
      }
      // Ambil offset zona waktu lokal
      final now = DateTime.now();
      final offset = now.timeZoneOffset.inHours;
      myUtcOffset = offset;
      // Nama zona waktu lokal
      myTimezone = '${now.timeZoneName} - UTC${offset >= 0 ? '+' : ''}$offset';
      setState(() {});
    } catch (e) {
      setState(() {
        myCity = 'Gagal deteksi lokasi';
      });
    }
  }

  void blendSchedule() {
    // Konversi jam ke UTC (bisa negatif, normalisasi nanti)
    int myStartUtc = myRange.start.toInt() - myUtcOffset;
    int myEndUtc = myRange.end.toInt() - myUtcOffset;
    int friendStartUtc = friendRange.start.toInt() - friendUtcOffset;
    int friendEndUtc = friendRange.end.toInt() - friendUtcOffset;

    // Cari irisan waktu UTC
    int blendStartUtc = [
      myStartUtc,
      friendStartUtc,
    ].reduce((a, b) => a > b ? a : b);
    int blendEndUtc = [myEndUtc, friendEndUtc].reduce((a, b) => a < b ? a : b);

    // Fungsi normalisasi jam agar selalu 0-23
    int norm(int h) => ((h % 24) + 24) % 24;

    if (blendStartUtc < blendEndUtc) {
      // Ada irisan waktu
      int myBlendStart = norm(blendStartUtc + myUtcOffset);
      int myBlendEnd = norm(blendEndUtc + myUtcOffset);
      int friendBlendStart = norm(blendStartUtc + friendUtcOffset);
      int friendBlendEnd = norm(blendEndUtc + friendUtcOffset);
      setState(() {
        blendFound = true;
        blendResult =
            "The Perfect Blend!\nKalian berdua punya ${(blendEndUtc - blendStartUtc)} jam waktu ngopi yang ideal.";
        blendDesc =
            "Jadwal Anda (${myTimezone}):\n${_formatTime(myBlendStart)} - ${_formatTime(myBlendEnd)}\n" +
            (friendTimezone.isNotEmpty
                ? "Jadwal Teman (${friendTimezone}):\n${_formatTime(friendBlendStart)} - ${_formatTime(friendBlendEnd)}"
                : "Jadwal Teman: Silakan pilih lokasi teman di peta.");
      });
    } else {
      // Tidak ada irisan waktu
      int myStartAtFriend = norm(
        myRange.start.toInt() - myUtcOffset + friendUtcOffset,
      );
      int friendStartAtMe = norm(
        friendRange.start.toInt() - friendUtcOffset + myUtcOffset,
      );
      setState(() {
        blendFound = false;
        blendResult = "Jadwal Belum Pas";
        blendDesc =
            "Waktu luang Anda (mulai ${_formatTime(myRange.start.toInt())} ${myTimezone}) adalah jam ${_formatTime(myStartAtFriend)} di ${friendCity}.\n"
            "${friendTimezone.isNotEmpty ? "Waktu luang teman Anda (mulai ${_formatTime(friendRange.start.toInt())} ${friendTimezone}) baru akan mulai jam ${_formatTime(friendStartAtMe)} di lokasi Anda." : "Waktu luang teman Anda: Silakan pilih lokasi teman di peta."}\n\n"
            "Tips: Coba ajak teman Anda untuk ngopi lebih sore di waktunya.";
      });
    }
  }

  String _formatTime(int hour) {
    final h = hour % 24;
    return "${h.toString().padLeft(2, '0')}:00";
  }

  @override
  void initState() {
    super.initState();
    detectMyLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Color(0xFFF9F9F9),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.go('/explore'),
        ),
        title: Text(
          "Coffee Sync",
          style: GoogleFonts.sora(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kartu Lokasi Anda
            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.coffee, color: Color(0xFFC67C4E)),
                        SizedBox(width: 8),
                        Text(
                          "KOPI ANDA ☕",
                          style: GoogleFonts.sora(fontWeight: FontWeight.bold),
                        ),
                        Spacer(),
                        // Tombol trigger deteksi lokasi
                        IconButton(
                          icon: Icon(
                            Icons.my_location,
                            color: Color(0xFFC67C4E),
                          ),
                          tooltip: "Deteksi Lokasi Saat Ini",
                          onPressed: detectMyLocation,
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_pin, color: Color(0xFFC67C4E)),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            myCity == 'Mendeteksi...'
                                ? myCity
                                : "$myCity, $myCountry (${myTimezone.isNotEmpty ? myTimezone : 'UTC+7'})",
                            style: GoogleFonts.sora(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Jam luang Anda hari ini:",
                      style: GoogleFonts.sora(fontSize: 13),
                    ),
                    RangeSlider(
                      values: myRange,
                      min: 0,
                      max: 23,
                      divisions: 23,
                      activeColor: Color(0xFFC67C4E),
                      labels: RangeLabels(
                        _formatTime(myRange.start.toInt()),
                        _formatTime(myRange.end.toInt()),
                      ),
                      onChanged: (v) => setState(() => myRange = v),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatTime(myRange.start.toInt())),
                        Text(_formatTime(myRange.end.toInt())),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            // Kartu Lokasi Teman
            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.coffee_outlined, color: Color(0xFFC67C4E)),
                        SizedBox(width: 8),
                        Text(
                          "KOPI TEMAN ANDA ☕",
                          style: GoogleFonts.sora(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    // Maps untuk memilih lokasi teman
                    SizedBox(
                      height: 200,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter:
                              friendLatLng ??
                              LatLng(-6.2, 106.8), // Default ke Jakarta
                          initialZoom: 4.5,
                          onTap: (tapPosition, point) async {
                            setState(() {
                              friendLatLng = point;
                            });
                            // Reverse geocoding
                            List<Placemark> placemarks =
                                await placemarkFromCoordinates(
                                  point.latitude,
                                  point.longitude,
                                );
                            if (placemarks.isNotEmpty) {
                              final place = placemarks.first;
                              String city =
                                  place.locality ??
                                  place.subAdministrativeArea ??
                                  '';
                              String country = place.country ?? '';
                              // Mapping zona waktu manual (Indonesia/London)
                              int offset = 0;
                              String timezone = '';
                              if (country == 'Indonesia') {
                                if (point.longitude >= 128) {
                                  timezone = 'WIT - UTC+9';
                                  offset = 9;
                                } else if (point.longitude >= 115) {
                                  timezone = 'WITA - UTC+8';
                                  offset = 8;
                                } else {
                                  timezone = 'WIB - UTC+7';
                                  offset = 7;
                                }
                              } else if (city.toLowerCase().contains(
                                'london',
                              )) {
                                timezone = 'GMT - UTC+0';
                                offset = 0;
                              } else {
                                timezone = 'Zona waktu tidak dikenali';
                                offset = 0;
                              }
                              setState(() {
                                friendCity = city;
                                friendCountry = country;
                                friendTimezone = timezone;
                                friendUtcOffset = offset;
                              });
                            }
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                            subdomains: ['a', 'b', 'c'],
                          ),
                          if (friendLatLng != null)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: friendLatLng!,
                                  width: 40,
                                  height: 40,
                                  child: Icon(
                                    Icons.location_pin,
                                    color: Color(0xFFC67C4E),
                                    size: 40,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    if (friendCity.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 8, top: 8),
                        child: Text(
                          "$friendCity, $friendCountry ($friendTimezone)",
                          style: GoogleFonts.sora(
                            fontSize: 13,
                            color: Color(0xFFC67C4E),
                          ),
                        ),
                      ),
                    SizedBox(height: 12),
                    Text(
                      "Jam luang teman Anda:",
                      style: GoogleFonts.sora(fontSize: 13),
                    ),
                    RangeSlider(
                      values: friendRange,
                      min: 0,
                      max: 23,
                      divisions: 23,
                      activeColor: Color(0xFFC67C4E),
                      labels: RangeLabels(
                        _formatTime(friendRange.start.toInt()),
                        _formatTime(friendRange.end.toInt()),
                      ),
                      onChanged: (v) => setState(() => friendRange = v),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatTime(friendRange.start.toInt())),
                        Text(_formatTime(friendRange.end.toInt())),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32),
            // Tombol Blend
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.blender, color: Colors.white),
                label: Text(
                  "BLEND JADWALNYA!",
                  style: GoogleFonts.sora(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFC67C4E),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: blendSchedule,
              ),
            ),
            SizedBox(height: 32),
            // Hasil Blend
            if (blendResult.isNotEmpty)
              Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        blendFound ? Icons.coffee : Icons.coffee_maker_outlined,
                        color: Color(0xFFC67C4E),
                        size: 40,
                      ),
                      SizedBox(height: 12),
                      Text(
                        blendResult,
                        style: GoogleFonts.sora(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFFC67C4E),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12),
                      Text(
                        blendDesc,
                        style: GoogleFonts.sora(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
