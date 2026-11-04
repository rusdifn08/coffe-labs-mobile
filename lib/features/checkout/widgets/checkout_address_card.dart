import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class CheckoutAddressCard extends StatelessWidget {
  final bool isEn;
  final String recipientName;
  final String phoneNumber;
  final String shippingAddress;
  final Function(String name, String phone, String address) onAddressUpdated;

  const CheckoutAddressCard({
    super.key,
    required this.isEn,
    required this.recipientName,
    required this.phoneNumber,
    required this.shippingAddress,
    required this.onAddressUpdated,
  });

  void _showEditAddressDialog(BuildContext context) {
    final nameCtrl = TextEditingController(text: recipientName);
    final phoneCtrl = TextEditingController(text: phoneNumber);
    final addrCtrl = TextEditingController(text: shippingAddress);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(isEn ? 'Edit Shipping Address' : 'Ubah Alamat Pengiriman'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: isEn ? 'Recipient Name' : 'Nama Penerima',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: phoneCtrl,
                  decoration: InputDecoration(
                    labelText: isEn ? 'Phone Number' : 'Nomor Telepon',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: addrCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: isEn ? 'Full Street Address' : 'Alamat Lengkap',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(isEn ? 'Cancel' : 'Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                onAddressUpdated(
                  nameCtrl.text.trim(),
                  phoneCtrl.text.trim(),
                  addrCtrl.text.trim(),
                );
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBrown),
              child: Text(isEn ? 'Save' : 'Simpan', style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(CupertinoIcons.location_solid, size: 16, color: AppTheme.primaryBrown),
                  const SizedBox(width: 6),
                  Text(
                    isEn ? 'Shipping Address' : 'Alamat Pengiriman',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
              InkWell(
                onTap: () => _showEditAddressDialog(context),
                child: Text(
                  isEn ? 'Edit' : 'Ubah',
                  style: const TextStyle(
                    color: AppTheme.primaryBrown,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$recipientName ($phoneNumber)',
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.textDark),
          ),
          const SizedBox(height: 2),
          Text(
            shippingAddress,
            style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted, height: 1.3),
          ),
        ],
      ),
    );
  }
}
