import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';

class CardMetodePembayaran extends StatelessWidget {
  final String selectedMethod;
  final String selectedBank;
  final ValueChanged<String> onMethodChanged;
  final ValueChanged<String> onBankChanged;

  const CardMetodePembayaran({
    super.key,
    required this.selectedMethod,
    required this.selectedBank,
    required this.onMethodChanged,
    required this.onBankChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cardBorder, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.payment_rounded,
                  size: 16,
                  color: AppColors.darkGreen,
                ),
                SizedBox(width: 6),
                Text(
                  'Metode Pembayaran',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Bungkus kedua pilihan dengan RadioGroup
            RadioGroup<String>(
              groupValue: selectedMethod,
              onChanged: (val) {
                if (val != null) {
                  onMethodChanged(val);
                }
              },
              child: Column(
                children: [
                  // Opsi 1: QRIS
                  InkWell(
                    onTap: () => onMethodChanged('qris'),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: selectedMethod == 'qris'
                            ? const Color(0xFFE8F6EE)
                            : AppColors.bgScreen,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selectedMethod == 'qris'
                              ? AppColors.darkGreen
                              : AppColors.cardBorder,
                          width: selectedMethod == 'qris' ? 1.5 : 1,
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.qr_code_2_rounded,
                            color: AppColors.darkGreen,
                            size: 22,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'QRIS (Instant)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.darkGreen,
                                  ),
                                ),
                                Text(
                                  'GoPay, ShopeePay, Dana, & Semua M-Banking',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Radio<String>(
                            value: 'qris',
                            activeColor: AppColors.darkGreen,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Opsi 2: Bank Transfer VA
                  InkWell(
                    onTap: () => onMethodChanged('bank_transfer'),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: selectedMethod == 'bank_transfer'
                            ? const Color(0xFFE8F6EE)
                            : AppColors.bgScreen,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selectedMethod == 'bank_transfer'
                              ? AppColors.darkGreen
                              : AppColors.cardBorder,
                          width: selectedMethod == 'bank_transfer' ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.account_balance_rounded,
                                color: AppColors.darkGreen,
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Transfer Virtual Account',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.darkGreen,
                                      ),
                                    ),
                                    Text(
                                      'BCA, BNI, BRI, Mandiri',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Radio<String>(
                                value: 'bank_transfer',
                                activeColor: AppColors.darkGreen,
                              ),
                            ],
                          ),

                          // Jika bank_transfer dipilih, tampilkan opsi pilihan bank
                          if (selectedMethod == 'bank_transfer') ...[
                            const Divider(height: 16, color: Color(0xFFC7E2D1)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: ['bca', 'bni', 'bri', 'mandiri'].map((
                                bank,
                              ) {
                                final isBankActive = selectedBank == bank;
                                return InkWell(
                                  onTap: () => onBankChanged(bank),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isBankActive
                                          ? AppColors.darkGreen
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.darkGreen,
                                      ),
                                    ),
                                    child: Text(
                                      bank.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isBankActive
                                            ? Colors.white
                                            : AppColors.darkGreen,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}