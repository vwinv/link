import 'package:flutter/material.dart';
import 'package:linkflutter/features/app_update/services/app_update_service.dart';
import 'package:provider/provider.dart';

/// Lance le contrôle de version une fois l’arbre prêt.
class AppUpdateGate extends StatefulWidget {
  const AppUpdateGate({super.key, required this.child});

  final Widget child;

  @override
  State<AppUpdateGate> createState() => _AppUpdateGateState();
}

class _AppUpdateGateState extends State<AppUpdateGate> {
  var _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    // Laisser le router / auth se stabiliser avant le check.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        context.read<AppUpdateService>().check();
      });
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
