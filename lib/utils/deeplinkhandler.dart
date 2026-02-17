import 'package:app_links/app_links.dart';
import 'package:diamondnib/pages/audiobookdetails.dart';
import 'package:diamondnib/utils/constant.dart';
import 'package:diamondnib/main.dart';
import 'package:flutter/material.dart';

// Helper function to print logs
void _printLog(String message) {
  debugPrint(message);
}

class DeepLinkHandler {
  static AppLinks? _appLinks;
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    
    _appLinks = AppLinks();
    
    // Handle initial link when app is cold started
    try {
      final initialLink = await _appLinks!.getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(initialLink);
      }
    } catch (e) {
      _printLog('DeepLinkHandler: Error getting initial link: $e');
    }
    
    // Handle links when app is already running (warm start)
    _appLinks!.uriLinkStream.listen((Uri uri) {
      _handleDeepLink(uri);
    }, onError: (err) {
      _printLog('DeepLinkHandler: Error listening to deep links: $err');
    });
  }

  static void _handleDeepLink(Uri uri) {
    _printLog('DeepLinkHandler: Deep link received: $uri');
    _printLog('DeepLinkHandler: Scheme: ${uri.scheme}, Host: ${uri.host}');
    _printLog('DeepLinkHandler: Path: ${uri.path}');
    _printLog('DeepLinkHandler: PathSegments: ${uri.pathSegments}');
    _printLog('DeepLinkHandler: Query: ${uri.queryParameters}');
    
    try {
      // Handle diamondnib://audiobook/123?type=1
      // OR diamondnib://audiobook?contentId=123&type=1
      if (uri.scheme == 'diamondnib') {
        int? contentId;
        int contentType = 1;
        
        // Check if host is "audiobook" - meaning format is diamondnib://audiobook/123
        if (uri.host == 'audiobook') {
          // Content ID from path: /123
          if (uri.pathSegments.isNotEmpty) {
            contentId = int.tryParse(uri.pathSegments[0]);
          } else if (uri.path.isNotEmpty && uri.path != '/') {
            contentId = int.tryParse(uri.path.replaceAll('/', ''));
          }
        } 
        // Check if host is content ID directly - diamondnib://123?type=1
        else {
          contentId = int.tryParse(uri.host);
        }
        
        // Get type from query parameters
        if (uri.queryParameters.containsKey('type')) {
          contentType = int.tryParse(uri.queryParameters['type'] ?? '1') ?? 1;
        }
        
        // Also check for contentId in query params as fallback
        if (contentId == null && uri.queryParameters.containsKey('contentId')) {
          contentId = int.tryParse(uri.queryParameters['contentId'] ?? '');
        }
        
        _printLog('DeepLinkHandler: Parsed contentId: $contentId, contentType: $contentType');
        
        if (contentId != null && contentId > 0) {
          // Store for later use if app hasn't loaded yet
          Constant.deepLinkContentId = contentId;
          Constant.deepLinkContentType = contentType;
          Constant.shouldOpenAudioDetails = true;
          
          // Navigate immediately if navigator is available
          _navigateToAudioBook(contentId, contentType);
        } else {
          _printLog('DeepLinkHandler: Invalid contentId: $contentId');
        }
      }
    } catch (e) {
      _printLog('DeepLinkHandler: Error handling deep link: $e');
    }
  }

  static void _navigateToAudioBook(int contentId, int contentType) {
    // Try to navigate using the global navigator key
    if (navigatorKey.currentState != null && navigatorKey.currentContext != null) {
      _printLog('DeepLinkHandler: Navigating to AudioBookDetails($contentId, $contentType)');
      
      // Use pushAndRemoveUntil to avoid stacking same pages
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => AudioBookDetails(contentId, contentType),
        ),
      );
      
      // Clear the flag after navigation
      Constant.shouldOpenAudioDetails = false;
      Constant.deepLinkContentId = null;
      Constant.deepLinkContentType = null;
    } else {
      _printLog('DeepLinkHandler: Navigator not ready, will navigate later');
    }
  }

  /// Call this from your home page or splash screen to handle pending deep links
  static void checkPendingDeepLink(BuildContext context) {
    if (Constant.shouldOpenAudioDetails && 
        Constant.deepLinkContentId != null && 
        Constant.deepLinkContentType != null) {
      
      _printLog('DeepLinkHandler: Processing pending deep link');
      
      final contentId = Constant.deepLinkContentId!;
      final contentType = Constant.deepLinkContentType!;
      
      // Clear flags first
      Constant.shouldOpenAudioDetails = false;
      Constant.deepLinkContentId = null;
      Constant.deepLinkContentType = null;
      
      // Navigate
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AudioBookDetails(contentId, contentType),
        ),
      );
    }
  }
}