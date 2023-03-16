
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isoja_application/global/color.dart';

AppBar DashboardAppbar() {
  return AppBar(
    toolbarHeight: 80,
    backgroundColor: Colors.transparent,
    elevation: 0,
    title: Text(
        'ISOJA',
        style: bold24Prim()
      ),
    
  );
}

TextStyle bold24Prim() {
  return GoogleFonts.chakraPetch(
      color: bgColor, fontSize: 36, fontWeight: FontWeight.bold);
}