/// Centralized utility for converting raw backend, LLM, and network errors
/// into clear, user-friendly messages without exposing technical stack traces or backend internals.
class ErrorSanitizer {
  ErrorSanitizer._();

  /// Sanitizes an error message or exception for end users.
  static String sanitize(dynamic error) {
    if (error == null) {
      return 'Something went wrong. Please try again.';
    }

    // Handle Map payloads e.g. {"detail": "..."} or {"message": "..."}
    if (error is Map) {
      if (error.containsKey('detail')) {
        return sanitize(error['detail']);
      }
      if (error.containsKey('message')) {
        return sanitize(error['message']);
      }
      return 'Please check your input details and try again.';
    }

    // Handle List payloads e.g. Pydantic validation errors [{'loc': ..., 'msg': ...}]
    if (error is List) {
      final msgs = <String>[];
      for (final item in error) {
        if (item is Map && item.containsKey('msg')) {
          msgs.add(item['msg'].toString());
        } else if (item != null) {
          msgs.add(item.toString());
        }
      }
      return sanitize(msgs.join(', '));
    }

    String msg = error.toString().replaceAll('Exception: ', '').trim();
    if (msg.isEmpty) {
      return 'Something went wrong. Please try again.';
    }

    // Strips out JSON wrapper if the backend sent {"detail": "..."} as a string
    if (msg.startsWith('{') && msg.contains('"detail"')) {
      final detailMatch = RegExp(r'"detail"\s*:\s*"([^"]+)"').firstMatch(msg);
      if (detailMatch != null) {
        return sanitize(detailMatch.group(1));
      }
    }

    final lower = msg.toLowerCase();

    // Technical body / validation / serialization / pydantic / 422 errors
    if (lower.contains('request body') ||
        lower.contains('unprocessable') ||
        lower.contains('validation error') ||
        lower.contains('field required') ||
        lower.contains('value_error') ||
        lower.contains('json decode') ||
        lower.contains('jsondecode') ||
        lower.contains('formatexception') ||
        lower.contains('payload') ||
        lower.contains('missing required') ||
        lower.contains('422') ||
        lower.contains('invalid request')) {
      if (lower.contains('email') && lower.contains('password')) {
        return 'Please enter a valid email address and password.';
      }
      if (lower.contains('email')) {
        return 'Please enter a valid email address.';
      }
      if (lower.contains('password')) {
        return 'Please enter a valid password.';
      }
      return 'Please check your input details and try again.';
    }

    // Gemini / LLM generation failures
    if (lower.contains('gemini_error') ||
        lower.contains('gemini') ||
        lower.contains('resource_exhausted') ||
        lower.contains('quota') ||
        lower.contains('rate_limit') ||
        lower.contains('overloaded') ||
        lower.contains('finish_reason') ||
        lower.contains('safety_rating') ||
        lower.contains('candidate') ||
        lower.contains('prompt_token')) {
      return 'Unable to generate paper content right now. Please try again in a moment.';
    }

    // Network / connectivity issues
    if (lower.contains('socketexception') ||
        lower.contains('failed host lookup') ||
        lower.contains('connection refused') ||
        lower.contains('network is unreachable') ||
        lower.contains('clientexception') ||
        lower.contains('connection closed') ||
        lower.contains('handshake failed') ||
        lower.contains('cert_verify_failed') ||
        lower.contains('failed to connect')) {
      return 'Unable to reach the server. Please check your internet connection.';
    }

    // Timeouts
    if (lower.contains('timeout') || lower.contains('timed out')) {
      return 'The request took too long to complete. Please try again.';
    }

    // Internal Server Error / 500 / 502 / 503 / 504 / DB / SQL
    if (lower.contains('500') ||
        lower.contains('internal server error') ||
        lower.contains('bad gateway') ||
        lower.contains('502') ||
        lower.contains('503') ||
        lower.contains('504') ||
        lower.contains('sql') ||
        lower.contains('database') ||
        lower.contains('traceback') ||
        lower.contains('syntaxerror') ||
        lower.contains('keyerror') ||
        lower.contains('typeerror')) {
      return 'A server error occurred. Please try again shortly.';
    }

    // Unauthorized / 401
    if (lower.contains('401') ||
        lower.contains('unauthorized') ||
        lower.contains('token expired') ||
        lower.contains('not authenticated')) {
      return 'Invalid email or password. Please try again.';
    }

    // Forbidden / 403
    if (lower.contains('403') || lower.contains('forbidden')) {
      return 'You do not have permission to perform this action.';
    }

    // Not found / 404
    if (lower.contains('404') || lower.contains('not found')) {
      return 'The requested resource was not found.';
    }

    return msg;
  }
}
