import 'package:flutter/material.dart';

class LocationHomeUi extends StatelessWidget {
  const LocationHomeUi({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.home, size: 20, color: Colors.black54),
        SizedBox(width: 6),
        Expanded(
          child: Text(
            "Lucknow Jankipuram Sector-H 201013",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Icon(Icons.arrow_forward_ios, size: 12, color: Colors.black54),
      ],
    );
  }
}
