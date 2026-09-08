import re

with open("apps/delivery-app/lib/screens/vehicle_information_screen.dart", "r", encoding="utf-8") as f:
    content = f.read()

import_str = "import 'package:google_fonts/google_fonts.dart';\nimport '../services/user_service.dart';"
content = content.replace("import 'package:google_fonts/google_fonts.dart';", import_str)

old_controllers = """  final TextEditingController _vehicleTypeController = TextEditingController(text: "Electric Scooter (EV)");
  final TextEditingController _modelController = TextEditingController(text: "TVS iQube Electric");
  final TextEditingController _regNumberController = TextEditingController(text: "TS 09 EA 4321");
  final TextEditingController _ownershipController = TextEditingController(text: "Self Owned");
  final TextEditingController _batteryCapacityController = TextEditingController(text: "3.04 kWh (100 km range)");"""

new_controllers = """  late TextEditingController _vehicleTypeController;
  late TextEditingController _modelController;
  late TextEditingController _regNumberController;
  late TextEditingController _ownershipController;
  late TextEditingController _batteryCapacityController;
  
  @override
  void initState() {
    super.initState();
    final details = UserService().currentUser.value?.deliveryDetails;
    final vehicleType = details?['vehicleType'] ?? "N/A";
    final vehicleNumber = details?['vehicleNumber'] ?? "N/A";
    
    _vehicleTypeController = TextEditingController(text: vehicleType);
    _modelController = TextEditingController(text: vehicleType);
    _regNumberController = TextEditingController(text: vehicleNumber);
    _ownershipController = TextEditingController(text: "Self Owned");
    _batteryCapacityController = TextEditingController(text: "N/A");
  }"""

content = content.replace(old_controllers, new_controllers)

# Update the header UI texts
content = re.sub(r'Text\(\n\s*"TVS iQube Electric",', 'Text(\n                        _modelController.text,', content)
content = re.sub(r'Text\(\n\s*"TS 09 EA 4321",', 'Text(\n                        _regNumberController.text,', content)

with open("apps/delivery-app/lib/screens/vehicle_information_screen.dart", "w", encoding="utf-8") as f:
    f.write(content)
