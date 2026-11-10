import 'package:flutter/material.dart';
import 'package:linkflutter/core/constants/app_constants.dart';
import 'package:linkflutter/core/network/network_status.dart';
import 'package:provider/provider.dart';

/// Message affiché tant que l’application ne joint pas Internet.
class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !mounted) return;
    final network = context.read<NetworkStatus>();
    if (network.isOffline) {
      network.recheck();
    }
  }

  @override
  Widget build(BuildContext context) {
    final network = context.watch<NetworkStatus>();
    if (!network.isOffline) return const SizedBox.shrink();

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Dismissible(
            key: const ValueKey('offline-banner'),
            direction: DismissDirection.horizontal,
            onDismissed: (_) => network.reportOnline(),
            child: Material(
              color: AppColors.textPrimary,
              borderRadius: BorderRadius.circular(16),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.wifi_off_rounded,
                      color: AppColors.onPrimary,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        NetworkStatus.offlineMessage,
                        style: TextStyle(
                          color: AppColors.onPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: network.isChecking
                          ? null
                          : () => network.recheck(),
                      child: Text(
                        network.isChecking ? '…' : 'Réessayer',
                        style: const TextStyle(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
