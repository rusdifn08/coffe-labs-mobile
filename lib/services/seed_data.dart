// SEED DATA AGGREGATOR
import '../data/seeds/seeds_part_1.dart';
import '../data/seeds/seeds_part_2.dart';
import '../data/seeds/seeds_part_3.dart';
import '../data/seeds/seeds_part_4.dart';
import '../data/seeds/seeds_part_5.dart';
import '../data/seeds/seeds_part_6.dart';
import '../data/seeds/seeds_part_7.dart';
import '../data/seeds/seeds_part_8.dart';
import '../data/seeds/seeds_part_9.dart';
import '../data/seeds/seeds_part_10.dart';
import '../data/seeds/seeds_part_11.dart';
import '../data/seeds/seeds_part_12.dart';
import '../data/seeds/seeds_part_13.dart';
import '../data/seeds/seeds_part_14.dart';
import '../data/seeds/seeds_part_15.dart';
import '../data/seeds/seeds_part_16.dart';
import '../data/seeds/seeds_part_17.dart';
import '../data/seeds/seeds_part_18.dart';
import '../data/seeds/seeds_part_19.dart';
import '../data/seeds/seeds_part_20.dart';
import '../data/seeds/seeds_part_21.dart';
import '../data/seeds/seeds_part_22.dart';
import '../data/seeds/seeds_part_23.dart';
import '../data/seeds/seeds_part_24.dart';
import '../data/seeds/seeds_part_25.dart';
import '../data/seeds/seeds_part_26.dart';
import '../data/seeds/seeds_part_27.dart';
import '../data/seeds/seeds_part_28.dart';
import '../data/seeds/seeds_part_29.dart';
import '../data/seeds/seeds_part_30.dart';
import '../data/seeds/seeds_part_31.dart';
import '../data/seeds/seeds_part_32.dart';
import '../data/seeds/seeds_part_33.dart';
import '../data/seeds/seeds_part_34.dart';
import '../data/seeds/seeds_part_35.dart';
import '../data/seeds/seeds_part_36.dart';
import '../data/seeds/seeds_part_37.dart';
import '../data/seeds/seeds_part_38.dart';
import '../data/seeds/seeds_part_39.dart';
import '../data/seeds/seeds_part_40.dart';
import '../data/seeds/seeds_part_41.dart';

class SeedData {
  static List<Map<String, dynamic>> getDefaultRecipes() {
    final now = DateTime.now().toIso8601String();
    return [
      ...getSeedsPart1(now),
      ...getSeedsPart2(now),
      ...getSeedsPart3(now),
      ...getSeedsPart4(now),
      ...getSeedsPart5(now),
      ...getSeedsPart6(now),
      ...getSeedsPart7(now),
      ...getSeedsPart8(now),
      ...getSeedsPart9(now),
      ...getSeedsPart10(now),
      ...getSeedsPart11(now),
      ...getSeedsPart12(now),
      ...getSeedsPart13(now),
      ...getSeedsPart14(now),
      ...getSeedsPart15(now),
      ...getSeedsPart16(now),
      ...getSeedsPart17(now),
      ...getSeedsPart18(now),
      ...getSeedsPart19(now),
      ...getSeedsPart20(now),
      ...getSeedsPart21(now),
      ...getSeedsPart22(now),
      ...getSeedsPart23(now),
      ...getSeedsPart24(now),
      ...getSeedsPart25(now),
      ...getSeedsPart26(now),
      ...getSeedsPart27(now),
      ...getSeedsPart28(now),
      ...getSeedsPart29(now),
      ...getSeedsPart30(now),
      ...getSeedsPart31(now),
      ...getSeedsPart32(now),
      ...getSeedsPart33(now),
      ...getSeedsPart34(now),
      ...getSeedsPart35(now),
      ...getSeedsPart36(now),
      ...getSeedsPart37(now),
      ...getSeedsPart38(now),
      ...getSeedsPart39(now),
      ...getSeedsPart40(now),
      ...getSeedsPart41(now),
    ];
  }
}
