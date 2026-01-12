import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../data/character_data.dart';
import '../services/database_service.dart';
import '../providers/theme_provider.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({Key? key}) : super(key: key);

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  List<String> purchasedCharacters = [];
  String selectedCharacter = 'قطة';
  int totalPoints = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final profile = DatabaseService.getChildProfile();
    if (profile != null) {
      setState(() {
        purchasedCharacters = profile.purchasedCharacters;
        selectedCharacter = profile.selectedCharacter;
        totalPoints = profile.totalPoints;
      });
    }
  }

  Future<void> _purchaseCharacter(AnimalCharacter character) async {
    final success =
        await DatabaseService.purchaseCharacter(character.id, character.price);

    if (success) {
      setState(() {
        purchasedCharacters.add(character.id);
        totalPoints -= character.price;
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            title: Row(
              children: [
                Icon(Icons.check_circle,
                    color: AppTheme.successGreen, size: 30),
                SizedBox(width: 10),
                Text('تم الشراء!',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text('تم شراء ${character.name} بنجاح! 🎉'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _selectCharacter(character);
                },
                child: Text('اختر الآن', style: TextStyle(fontSize: 16)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('حسناً', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        );
      }
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            title: Row(
              children: [
                Icon(Icons.error, color: AppTheme.warningOrange, size: 30),
                SizedBox(width: 10),
                Text('نقاط غير كافية',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content:
                Text('تحتاج إلى ${character.price - totalPoints} نقطة إضافية!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('حسناً', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _selectCharacter(AnimalCharacter character) async {
    await DatabaseService.selectCharacter(character.id);
    setState(() {
      selectedCharacter = character.id;
    });

    // تطبيق الثيم الجديد
    if (mounted) {
      Provider.of<ThemeProvider>(context, listen: false)
          .updateTheme(character.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم اختيار ${character.name}! 🎨',
              style: TextStyle(fontSize: 16)),
          backgroundColor: AppTheme.successGreen,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          body: Column(
            children: [
              // الشريط العلوي الثابت - سطر واحد
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      themeProvider.primaryColor,
                      themeProvider.secondaryColor
                    ],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                    child: Row(
                      children: [
                        // زر الخروج
                        IconButton(
                          icon: Icon(Icons.arrow_back,
                              color: Colors.white, size: 28),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                        SizedBox(width: 15),
                        // العنوان
                        Text(
                          'المتجر',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Spacer(),
                        // النقاط
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.monetization_on,
                                  color: Colors.amber, size: 20),
                              SizedBox(width: 6),
                              Text(
                                '$totalPoints',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        // أيقونة المتجر
                        Icon(Icons.store, color: Colors.white, size: 26),
                      ],
                    ),
                  ),
                ),
              ),

              // المحتوى القابل للتمرير
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        themeProvider.secondaryColor.withOpacity(0.3),
                        Colors.white,
                      ],
                    ),
                  ),
                  child: CustomScrollView(
                    slivers: [
                      // حيوانات رخيصة
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                          child: Text(
                            '🐾 حيوانات رخيصة (10-30 نقطة)',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primarySkyBlue,
                            ),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.85,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildCharacterCard(
                                CharactersData.cheap[index]),
                            childCount: CharactersData.cheap.length,
                          ),
                        ),
                      ),

                      // حيوانات متوسطة
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
                          child: Text(
                            '🦊 حيوانات متوسطة (40-80 نقطة)',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primarySkyBlue,
                            ),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.85,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildCharacterCard(
                                CharactersData.medium[index]),
                            childCount: CharactersData.medium.length,
                          ),
                        ),
                      ),

                      // حيوانات غالية
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
                          child: Text(
                            '🦁 حيوانات غالية (90-150 نقطة)',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primarySkyBlue,
                            ),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.85,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildCharacterCard(
                                CharactersData.expensive[index]),
                            childCount: CharactersData.expensive.length,
                          ),
                        ),
                      ),

                      // حيوانات نادرة
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
                          child: Text(
                            '🐬 حيوانات نادرة (160-200 نقطة)',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primarySkyBlue,
                            ),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.85,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) =>
                                _buildCharacterCard(CharactersData.rare[index]),
                            childCount: CharactersData.rare.length,
                          ),
                        ),
                      ),

                      // مسافة في النهاية
                      SliverToBoxAdapter(child: SizedBox(height: 30)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPointsBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primarySkyBlue, AppTheme.lightSkyBlue],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primarySkyBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.monetization_on, color: Colors.white, size: 28),
          SizedBox(width: 10),
          Text(
            'نقاطك: $totalPoints',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterCard(AnimalCharacter character) {
    final isPurchased = purchasedCharacters.contains(character.id);
    final isSelected = selectedCharacter == character.id;
    final canAfford = totalPoints >= character.price;

    return GestureDetector(
      onTap: () {
        if (isPurchased) {
          _selectCharacter(character);
        } else if (canAfford) {
          _purchaseCharacter(character);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: AppTheme.successGreen, width: 3)
              : null,
          boxShadow: [
            BoxShadow(
              color: character.primaryColor.withOpacity(0.3),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // الصورة
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.asset(
                      'assets/images/animals/${character.id}.jpg',
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        print('❌ خطأ في تحميل صورة: ${character.id}');
                        return Container(
                          color: character.primaryColor.withOpacity(0.2),
                          child: Icon(Icons.pets,
                              size: 40, color: character.primaryColor),
                        );
                      },
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      top: 5,
                      right: 5,
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: AppTheme.successGreen,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.check, color: Colors.white, size: 20),
                      ),
                    ),
                  if (!isPurchased && !canAfford)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        child: Icon(Icons.lock, color: Colors.white, size: 40),
                      ),
                    ),
                ],
              ),
            ),

            // المعلومات
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      character.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: character.primaryColor,
                      ),
                    ),
                    if (character.price > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.monetization_on,
                              color:
                                  canAfford ? AppTheme.starYellow : Colors.grey,
                              size: 20),
                          SizedBox(width: 5),
                          Text(
                            '${character.price}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color:
                                  canAfford ? AppTheme.textDark : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    if (isPurchased)
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.successGreen
                              : character.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isSelected ? 'مختار' : 'اختر',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    else
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              canAfford ? AppTheme.primarySkyBlue : Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          canAfford ? 'شراء' : 'مقفل',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
