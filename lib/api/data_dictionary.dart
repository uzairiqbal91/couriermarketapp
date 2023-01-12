import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const JOB_TYPE = {
  'same-day': 'Same Day',
  'multi-drop': 'Multi Drop',
};

const VEHICLE_LOAD = {
  'outward': 'Outward Load',
  'backload': 'Backload',
};

const VEHICLE_TYPE = {
  'motorcycle': 'Motorcycle',
  'small-van': 'Small van',
  'swb': 'SWB up to 2.4m',
  'mwb': 'MWB up to 3m',
  'lwb': 'LWB up to 4m',
  'xlwb': 'XLWB 4m+',
  'luton': 'Luton',
  't7.5': '7.5T',
  't12': '12T',
  't18': '18T',
  't26': '26T',
  '13.6m': '13.6M',
  'skellie-1x20ft': 'Skellie 1x20ft',
  'skellie-2x20ft': 'Skellie 2x20ft',
  'skellie-1x40ft': 'Skellie 1x40ft',
  'skellie-1x44ft': 'Skellie 1x44ft',
  'tractor-4a': '4 Axle Tractor',
  'tractor-6a': '6 Axle Tractor',
};

const VEHICLE_BODY = {
  'na': 'N/A',
  'box': 'Box',
  'curtain-side': 'Curtain Side',
  'tail-lift': 'Tail Lift',
  'double-deck': 'Double Deck',
  'dropside': 'Dropside',
  'flatbed': 'Flatbed',
  'high-roof': 'High Roof',
  'low-loader': 'Low Loader',
  'panel': 'Panel',
  'refrigerated': 'Refrigerated',
  'tanker': 'Tanker',
  'temperature-controlled': 'Temperature Controlled',
  'tilt': 'Tilt',
  'tipper': 'Tipper',
  'trailer': 'Trailer',
  'vehicle-transporter': 'Vehicle Transporter',
};

const VEHICLE_FREIGHT = {
  'na': 'N/A',
  'ambient': 'Ambient',
  'adr': 'ADR',
  'aviation-ab': 'Level A/B Aviation',
  'aviation-d': 'Level D Aviation',
  'chilled': 'Refrigerated/chilled',
  'container': 'Container',
  'fragile': 'Fragile',
  'dangerous': 'DGSA Qualified',
  'hanging-garments': 'Hanging Garments',
  'install-swapout': 'Installation & Swapout',
  'livestock': 'Livestock',
  'loose': 'Loose',
  'removals': 'Removals',
  'secure-high': 'High Security',
  'frozen': 'Frozen',
  'waste': 'Waste',
  'weee': 'WEEE'
};

List<DropdownMenuItem<String>> assembleDropdown(Map<String, String> items) => items.entries
    .map((MapEntry<String, String> e) => DropdownMenuItem<String>(value: e.key, child: Text(e.value)))
    .toList();
