import re

with open("lib/screens/add_edit_address_screen.dart", "r", encoding="utf-8") as f:
    content = f.read()

old_constructor = """class AddEditAddressScreen extends StatefulWidget {
  final Address? existingAddress;
  final bool isOrderingForSomeoneElse;

  const AddEditAddressScreen({
    Key? key, 
    this.existingAddress,
    this.isOrderingForSomeoneElse = false,
  }) : super(key: key);"""

new_constructor = """class AddEditAddressScreen extends StatefulWidget {
  final Address? existingAddress;
  final bool isOrderingForSomeoneElse;
  final bool autoFetchLocation;

  const AddEditAddressScreen({
    Key? key, 
    this.existingAddress,
    this.isOrderingForSomeoneElse = false,
    this.autoFetchLocation = false,
  }) : super(key: key);"""
content = content.replace(old_constructor, new_constructor)

old_initstate = """  void initState() {
    super.initState();
    final userProfile = UserService().profile.value;"""

new_initstate = """  void initState() {
    super.initState();
    final userProfile = UserService().profile.value;
    if (widget.autoFetchLocation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _getCurrentLocation();
      });
    }"""
content = content.replace(old_initstate, new_initstate)

with open("lib/screens/add_edit_address_screen.dart", "w", encoding="utf-8") as f:
    f.write(content)
