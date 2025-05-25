import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CryptoIconCacheManager {
  static const key = 'cryptoIconCache';
  
  static CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 7), // Icons are cached for 7 days
      maxNrOfCacheObjects: 200, // Maximum 200 cached icons
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );
  
  // Clear cache method for manual cache management
  static Future<void> clearCache() async {
    await instance.emptyCache();
  }
} 