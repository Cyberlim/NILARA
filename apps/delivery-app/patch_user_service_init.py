import re

with open("lib/services/user_service.dart", "r", encoding="utf-8") as f:
    content = f.read()

old_init = """  Future<void> init() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        final idToken = await user.getIdToken();
        token.value = idToken;
        await _syncWithBackend(idToken!);
      } else {
        currentUser.value = null;
        token.value = null;
      }
      isInitialized.value = true;
    });
  }"""

new_init = """  Future<void> init() async {
    // Wait for the first auth state event to resolve
    final user = await FirebaseAuth.instance.authStateChanges().first;
    if (user != null) {
      final idToken = await user.getIdToken();
      token.value = idToken;
      await _syncWithBackend(idToken!);
    } else {
      currentUser.value = null;
      token.value = null;
    }
    isInitialized.value = true;
    
    // Continue listening for subsequent changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        final idToken = await user.getIdToken();
        token.value = idToken;
        // Don't need to await here for UI responsiveness on subsequent changes
        _syncWithBackend(idToken!);
      } else {
        currentUser.value = null;
        token.value = null;
      }
    });
  }"""

content = content.replace(old_init, new_init)

with open("lib/services/user_service.dart", "w", encoding="utf-8") as f:
    f.write(content)
