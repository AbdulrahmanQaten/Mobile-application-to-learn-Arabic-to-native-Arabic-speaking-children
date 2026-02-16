import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/database_service.dart';
import '../providers/theme_provider.dart';
import 'welcome_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String childName = '';
  int childAge = 5;
  bool soundEffectsEnabled = true;
  bool learningNotificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final profile = DatabaseService.getChildProfile();
    if (profile != null) {
      setState(() {
        childName = profile.name;
        childAge = profile.age;
        soundEffectsEnabled = profile.soundEffectsEnabled;
        learningNotificationsEnabled = false;
      });
    }
  }

  Future<void> _editName(Color primaryColor) async {
    final controller = TextEditingController(text: childName);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('تعديل الاسم'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'الاسم',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
          ),
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: Text('حفظ'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final profile = DatabaseService.getChildProfile();
      if (profile != null) {
        profile.name = result;
        await DatabaseService.saveChildProfile(profile);
        setState(() {
          childName = result;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم تحديث الاسم بنجاح! 🎉')),
          );
        }
      }
    }
  }

  Future<void> _editAge(Color primaryColor) async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('تعديل العمر'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: 4,
            itemBuilder: (context, index) {
              final age = index + 5;
              return ListTile(
                title: Text('$age سنوات', textAlign: TextAlign.center),
                onTap: () => Navigator.pop(context, age),
              );
            },
          ),
        ),
      ),
    );

    if (result != null) {
      final profile = DatabaseService.getChildProfile();
      if (profile != null) {
        profile.age = result;
        await DatabaseService.saveChildProfile(profile);
        setState(() {
          childAge = result;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم تحديث العمر بنجاح! 🎉')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  themeProvider.primaryColor,
                  themeProvider.secondaryColor,
                  Colors.white,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // الشريط العلوي
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back,
                              color: Colors.white, size: 28),
                          onPressed: () => Navigator.pop(context),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'الإعدادات',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.settings, color: Colors.white, size: 32),
                      ],
                    ),
                  ),

                  // المحتوى
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.all(20),
                      children: [
                        // معلومات الطفل
                        _buildSectionTitle('معلومات الطفل'),
                        _buildSettingCard(
                          icon: Icons.person,
                          title: 'الاسم',
                          subtitle: childName,
                          onTap: () => _editName(themeProvider.primaryColor),
                          primaryColor: themeProvider.primaryColor,
                        ),
                        SizedBox(height: 12),
                        _buildSettingCard(
                          icon: Icons.cake,
                          title: 'العمر',
                          subtitle: '$childAge سنوات',
                          onTap: () => _editAge(themeProvider.primaryColor),
                          primaryColor: themeProvider.primaryColor,
                        ),

                        SizedBox(height: 30),

                        // الإعدادات العامة
                        _buildSectionTitle('الإعدادات العامة'),
                        _buildSwitchCard(
                          icon: Icons.volume_up,
                          title: 'المؤثرات الصوتية',
                          subtitle: 'أصوات التشجيع والتفاعل',
                          value: soundEffectsEnabled,
                          primaryColor: themeProvider.primaryColor,
                          onChanged: (value) async {
                            setState(() {
                              soundEffectsEnabled = value;
                            });
                            // حفظ في قاعدة البيانات
                            final profile = DatabaseService.getChildProfile();
                            if (profile != null) {
                              profile.soundEffectsEnabled = value;
                              await DatabaseService.saveChildProfile(profile);
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(value
                                    ? 'تم تفعيل المؤثرات الصوتية! 🔊'
                                    : 'تم تعطيل المؤثرات الصوتية 🔇'),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 12),
                        _buildSwitchCard(
                          icon: Icons.notifications_active,
                          title: 'إشعارات التعلم',
                          subtitle: 'تذكيرات يومية للتعلم',
                          value: learningNotificationsEnabled,
                          primaryColor: themeProvider.primaryColor,
                          onChanged: (value) {
                            setState(() {
                              learningNotificationsEnabled = value;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(value
                                    ? 'تم تفعيل إشعارات التعلم! 🔔'
                                    : 'تم تعطيل إشعارات التعلم'),
                              ),
                            );
                          },
                        ),

                        SizedBox(height: 30),

                        // إعادة تعيين
                        _buildSectionTitle('إعادة التعيين'),
                        InkWell(
                          onTap: () => _showResetConfirmation(themeProvider.primaryColor),
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.red.withOpacity(0.3)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.restart_alt, color: Colors.red, size: 24),
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'إعادة تعيين التطبيق',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'حذف جميع البيانات والبدء من جديد',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.warning_amber, size: 20, color: Colors.red),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 30),

                        // معلومات التطبيق
                        _buildSectionTitle('حول التطبيق'),
                        _buildSettingCard(
                          icon: Icons.info,
                          title: 'الإصدار',
                          subtitle: '1.0.0',
                          onTap: null,
                          primaryColor: themeProvider.primaryColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showResetConfirmation(Color primaryColor) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Text('تأكيد إعادة التعيين', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Text(
          'سيتم حذف جميع بياناتك (التقدم، النجوم، الذهب، الشخصيات) والبدء من جديد.\n\nهل أنت متأكد؟',
          style: TextStyle(fontSize: 15, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء', style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('إعادة تعيين', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await DatabaseService.deleteProfile();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => WelcomeScreen()),
          (route) => false,
        );
      }
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12, right: 5),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.textDark,
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color primaryColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: primaryColor, size: 24),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Color primaryColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: primaryColor, size: 24),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: primaryColor,
          ),
        ],
      ),
    );
  }
}
