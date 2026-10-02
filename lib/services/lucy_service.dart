class LucyService {
  LucyService({this.baseUrl});

  final String? baseUrl;

  Future<void> sendTask(String prompt) async {
    // Backend integration will be added here.
    // Keep the mobile UI independent from the transport implementation.
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }
}
