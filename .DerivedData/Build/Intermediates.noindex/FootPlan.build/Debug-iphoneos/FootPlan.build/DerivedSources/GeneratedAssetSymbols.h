#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The resource bundle ID.
static NSString * const ACBundleID AC_SWIFT_PRIVATE = @"com.leo.f00tpl4n";

/// The "strssr" asset catalog color resource.
static NSString * const ACColorNameStrssr AC_SWIFT_PRIVATE = @"strssr";

/// The "Lanchscr" asset catalog image resource.
static NSString * const ACImageNameLanchscr AC_SWIFT_PRIVATE = @"Lanchscr";

#undef AC_SWIFT_PRIVATE
