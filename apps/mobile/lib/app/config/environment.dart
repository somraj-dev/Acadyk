enum Environment {
  development,
  staging,
  production;

  static Environment fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'prod':
      case 'production':
        return Environment.production;
      case 'stage':
      case 'staging':
        return Environment.staging;
      case 'dev':
      case 'development':
      default:
        return Environment.development;
    }
  }
}
