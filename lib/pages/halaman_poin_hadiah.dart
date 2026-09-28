import 'package:flutter/material.dart';
import 'package:test23/core/app_colors.dart';
import 'package:test23/data/user_account_data.dart';

class HalamanPoinHadiah extends StatefulWidget {
  const HalamanPoinHadiah({super.key});

  @override
  State<HalamanPoinHadiah> createState() => _HalamanPoinHadiahState();
}

class _HalamanPoinHadiahState extends State<HalamanPoinHadiah> {
  int _points = UserAccountData.userPoints;

  void _redeemReward(HadiahRewardModel reward) {
    if (_points < reward.poinDibutuhkan) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('Poin Tidak Cukup', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
          content: Text('Anda membutuhkan ${reward.poinDibutuhkan} Pts untuk menukarkan hadiah ini. Saat ini poin Anda adalah $_points Pts.'),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkGreen),
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Konfirmasi Penukaran', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
        content: Text('Tukarkan ${reward.poinDibutuhkan} Pts untuk "${reward.judul}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkGreen),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _points -= reward.poinDibutuhkan;
                UserAccountData.userPoints = _points;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Selamat! Penukaran "${reward.judul}" berhasil!'),
                  backgroundColor: AppColors.darkGreen,
                ),
              );
            },
            child: const Text('Tukarkan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rewards = UserAccountData.listHadiah;

    return Scaffold(
      backgroundColor: AppColors.bgScreen,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Center(
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6F3DD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_rounded, color: AppColors.darkGreen, size: 20),
              ),
            ),
          ),
        ),
        title: const Text(
          'Poin & Hadiah',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkGreen),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 14),

            // ── EcoPoints Hero Banner ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.darkGreen,
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D4330), Color(0xFF072C1E)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkGreen.withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'TOTAL ECOPOINTS ANDA',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.limeAccent,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Eco Guardian Tier 2',
                            style: TextStyle(fontSize: 10, color: AppColors.limeAccent, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          '$_points',
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Pts',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.limeAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Expanded(
                          child: Text(
                            'Target Tier Berikutnya (Eco Hero)',
                            style: TextStyle(fontSize: 10, color: Colors.white60),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '250 Pts lagi',
                          style: TextStyle(fontSize: 10, color: AppColors.limeAccent, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: 0.67,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.limeAccent),
                        minHeight: 5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Section Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: const [
                  Text(
                    'Katalog Hadiah Sirkular',
                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.darkGreen),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Reward Items List
            ...rewards.map((rew) => _buildRewardCard(rew)),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardCard(HadiahRewardModel reward) {
    final bool canRedeem = _points >= reward.poinDibutuhkan;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cardBorder, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6F3DD),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    reward.badge,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkGreen,
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.stars_rounded, size: 16, color: Color(0xFFF9A825)),
                    const SizedBox(width: 4),
                    Text(
                      '${reward.poinDibutuhkan} Pts',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              reward.judul,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.darkGreen),
            ),
            const SizedBox(height: 4),
            Text(
              reward.deskripsi,
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF4C6656), height: 1.3),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 38,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: canRedeem ? AppColors.darkGreen : Colors.grey.shade300,
                  foregroundColor: canRedeem ? Colors.white : Colors.grey.shade600,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _redeemReward(reward),
                child: Text(
                  canRedeem ? 'Tukarkan Sekarang' : 'Poin Kurang (${reward.poinDibutuhkan - _points} Pts lagi)',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
