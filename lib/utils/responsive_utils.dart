import 'package:flutter/material.dart';

/// Responsive breakpoints for the app
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

/// Device type enumeration
enum DeviceType { mobile, tablet, desktop }

/// Extension methods for responsive design on BuildContext
extension ResponsiveContext on BuildContext {
  /// Get screen size
  Size get screenSize => MediaQuery.of(this).size;

  /// Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Check if device is mobile
  bool get isMobile => screenWidth < Breakpoints.mobile;

  /// Check if device is tablet
  bool get isTablet =>
      screenWidth >= Breakpoints.mobile && screenWidth < Breakpoints.tablet;

  /// Check if device is desktop
  bool get isDesktop => screenWidth >= Breakpoints.tablet;

  /// Get device type
  DeviceType get deviceType {
    if (screenWidth < Breakpoints.mobile) return DeviceType.mobile;
    if (screenWidth < Breakpoints.tablet) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  /// Get responsive padding
  EdgeInsets get responsivePadding {
    if (isMobile) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
    } else if (isTablet) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 24);
    }
    return const EdgeInsets.symmetric(horizontal: 40, vertical: 40);
  }

  /// Get horizontal padding
  double get horizontalPadding {
    if (isMobile) return 16;
    if (isTablet) return 24;
    return 40;
  }

  /// Get responsive font size
  double responsiveFontSize(double baseSize) {
    if (isMobile) return baseSize * 0.85;
    if (isTablet) return baseSize * 0.95;
    return baseSize;
  }

  /// Get responsive spacing
  double get responsiveSpacing {
    if (isMobile) return 12;
    if (isTablet) return 16;
    return 20;
  }

  /// Get sidebar width
  double get sidebarWidth {
    if (isMobile) return 0; // No sidebar on mobile
    if (isTablet) return 200;
    return 250;
  }

  /// Get maximum content width for centered layouts
  double get maxContentWidth {
    if (isMobile) return screenWidth - 32;
    if (isTablet) return screenWidth - 48;
    return 1200;
  }
}

/// Responsive widget that builds different layouts based on screen size
class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    if (context.isMobile) return mobile;
    if (context.isTablet && tablet != null) return tablet!;
    return desktop;
  }
}

/// Responsive layout with sidebar that converts to drawer on mobile
class ResponsiveScaffold extends StatelessWidget {
  final Widget body;
  final Widget sidebar;
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const ResponsiveScaffold({
    super.key,
    required this.body,
    required this.sidebar,
    this.appBar,
    this.drawer,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    if (context.isMobile) {
      return Scaffold(
        key: scaffoldKey,
        appBar: appBar,
        drawer: drawer ?? sidebar,
        body: body,
        backgroundColor: backgroundColor,
        bottomNavigationBar: bottomNavigationBar,
      );
    }

    return Scaffold(
      key: scaffoldKey,
      appBar: appBar,
      body: Row(
        children: [
          sidebar,
          Expanded(child: body),
        ],
      ),
      backgroundColor: backgroundColor,
    );
  }
}

/// Responsive grid that adjusts columns based on screen size
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    int crossAxisCount;
    if (context.isMobile) {
      crossAxisCount = 1;
    } else if (context.isTablet) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 3;
    }

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: children.map((child) {
        return SizedBox(
          width: (context.screenWidth -
                  (context.horizontalPadding * 2) -
                  (spacing * (crossAxisCount - 1))) /
              crossAxisCount,
          child: child,
        );
      }).toList(),
    );
  }
}

/// Responsive card that adjusts padding and width
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? maxWidth;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? context.maxContentWidth,
        ),
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: padding ?? context.responsivePadding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Helper for responsive table display
class ResponsiveTableConfig {
  final BuildContext context;

  ResponsiveTableConfig(this.context);

  /// Get column widths based on screen size
  Map<int, TableColumnWidth> getColumnWidths(int columnCount) {
    if (context.isMobile) {
      // On mobile, use fixed width for all columns (horizontal scroll)
      return {
        for (int i = 0; i < columnCount; i++)
          i: const FixedColumnWidth(120),
      };
    }
    return {
      for (int i = 0; i < columnCount; i++)
        i: const FlexColumnWidth(),
    };
  }

  /// Whether to allow horizontal scrolling
  bool get allowHorizontalScroll => context.isMobile;

  /// Get data row height
  double get dataRowHeight => context.isMobile ? 56 : 52;

  /// Get heading row height
  double get headingRowHeight => context.isMobile ? 48 : 44;
}

/// Extension for responsive text styles
extension ResponsiveTextStyle on TextStyle {
  TextStyle responsive(BuildContext context) {
    double scale = 1.0;
    if (context.isMobile) scale = 0.85;
    else if (context.isTablet) scale = 0.95;
    
    return copyWith(
      fontSize: fontSize != null ? fontSize! * scale : null,
    );
  }
}

/// Extension for responsive container constraints
extension ResponsiveConstraints on BoxConstraints {
  static BoxConstraints maxWidthResponsive(BuildContext context, double maxWidth) {
    if (context.isMobile) {
      return BoxConstraints(maxWidth: context.screenWidth - 32);
    }
    return BoxConstraints(maxWidth: maxWidth);
  }
}
