import 'package:my_expenses/common/enums/category_icon_type.dart';

class CategoryUtils {
  static String getCategoryIconTypeName(CategoryIconType type) {
    switch (type) {
      case CategoryIconType.Education:
        return "Education";
      case CategoryIconType.Electronics:
        return "Electronics";
      case CategoryIconType.Family:
        return "Family";
      case CategoryIconType.Food:
        return "Food";
      case CategoryIconType.Furniture:
        return "Furniture";
      case CategoryIconType.Income:
        return "Income";
      case CategoryIconType.Life:
        return "Life";
      case CategoryIconType.Personal:
        return "Personal";
      case CategoryIconType.Shopping:
        return "Shopping";
      case CategoryIconType.Transportation:
        return "Transportation";
      case CategoryIconType.Others:
        return "Others";
    }
  }
}
