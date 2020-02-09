import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:my_expenses/common/presentation/custom_icons.dart';
import 'package:my_expenses/common/utils/category_utils.dart';

import '../common/enums/category_icon_type.dart';
import '../models/category_icon.dart';

class CategoryIconsPage extends StatelessWidget {
  final educationIcons = <CategoryIcon>[
    CategoryIcon(
      icon: Icon(Icons.school),
      name: "School",
      type: CategoryIconType.Education,
    ),
    CategoryIcon(
      icon: Icon(Icons.palette),
      name: "Pallete",
      type: CategoryIconType.Education,
    ),
  ];

  final electronicIcons = <CategoryIcon>[
    CategoryIcon(
      icon: Icon(Icons.headset),
      name: "Headset",
      type: CategoryIconType.Electronics,
    ),
    CategoryIcon(
      icon: Icon(Icons.radio),
      name: "Radio",
      type: CategoryIconType.Electronics,
    ),
    CategoryIcon(
      icon: Icon(Icons.computer),
      name: "Laptop",
      type: CategoryIconType.Electronics,
    ),
    CategoryIcon(
      icon: Icon(Icons.desktop_windows),
      name: "PC",
      type: CategoryIconType.Electronics,
    ),
    CategoryIcon(
      icon: Icon(Icons.gamepad),
      name: "Gamepad",
      type: CategoryIconType.Electronics,
    ),
    CategoryIcon(
      icon: Icon(Icons.phone),
      name: "Phone",
      type: CategoryIconType.Electronics,
    ),
    CategoryIcon(
      icon: Icon(Icons.phone_android),
      name: "Smartphone",
      type: CategoryIconType.Electronics,
    ),
    CategoryIcon(
      icon: Icon(Icons.watch),
      name: "Watch",
      type: CategoryIconType.Electronics,
    ),
    CategoryIcon(
      icon: Icon(Icons.print),
      name: "Printer",
      type: CategoryIconType.Electronics,
    ),
  ];

  final familyIcons = <CategoryIcon>[
    CategoryIcon(
      icon: Icon(Icons.people),
      name: "People",
      type: CategoryIconType.Family,
    ),
    CategoryIcon(
      icon: Icon(Icons.child_care),
      name: "Child",
      type: CategoryIconType.Family,
    ),
    CategoryIcon(
      icon: Icon(Icons.child_friendly),
      name: "Child_Friendly",
      type: CategoryIconType.Family,
    ),
    CategoryIcon(
      icon: Icon(Icons.local_hospital),
      name: "Hospital",
      type: CategoryIconType.Family,
    ),
    CategoryIcon(
      icon: Icon(Icons.local_pharmacy),
      name: "Pharmacy",
      type: CategoryIconType.Family,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.gift),
      name: "Gift",
      type: CategoryIconType.Family,
    ),
  ];

  final foodIcons = <CategoryIcon>[
    CategoryIcon(
      icon: Icon(Icons.fastfood),
      name: "Fast Food",
      type: CategoryIconType.Food,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.food),
      name: "Food",
      type: CategoryIconType.Food,
    ),
    CategoryIcon(
      icon: Icon(Icons.local_dining),
      name: "Dinning",
      type: CategoryIconType.Food,
    ),
    CategoryIcon(
      icon: Icon(Icons.local_bar),
      name: "Bar",
      type: CategoryIconType.Food,
    ),
    CategoryIcon(
      icon: Icon(Icons.local_cafe),
      name: "Dinning",
      type: CategoryIconType.Food,
    ),
    CategoryIcon(
      icon: Icon(Icons.local_pizza),
      name: "Pizza",
      type: CategoryIconType.Food,
    ),
    CategoryIcon(
      icon: Icon(Icons.restaurant),
      name: "Restaurant",
      type: CategoryIconType.Food,
    ),
  ];

  final furnitureIcons = <CategoryIcon>[
    CategoryIcon(
      icon: Icon(Icons.event_seat),
      name: "Seat",
      type: CategoryIconType.Furniture,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.weekend),
      name: "Weekend",
      type: CategoryIconType.Furniture,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.archive),
      name: "Archive",
      type: CategoryIconType.Furniture,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.hotel),
      name: "Bed",
      type: CategoryIconType.Furniture,
    ),
  ];

  final incomeIcons = <CategoryIcon>[
    CategoryIcon(
      icon: Icon(CustomIcons.money),
      name: "Money_2",
      type: CategoryIconType.Income,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.dollar),
      name: "Dollar",
      type: CategoryIconType.Income,
    ),
    CategoryIcon(
      icon: Icon(Icons.attach_money),
      name: "Money",
      type: CategoryIconType.Income,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.gwallet),
      name: "GWallet",
      type: CategoryIconType.Income,
    ),
    CategoryIcon(
      icon: Icon(Icons.account_balance),
      name: "Bank",
      type: CategoryIconType.Income,
    ),
    CategoryIcon(
      icon: Icon(Icons.account_balance_wallet),
      name: "Wallet",
      type: CategoryIconType.Income,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.local_atm),
      name: "ATM",
      type: CategoryIconType.Income,
    ),
    CategoryIcon(
      icon: Icon(Icons.card_giftcard),
      name: "GitfCard",
      type: CategoryIconType.Income,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.credit_card),
      name: "CreditCard",
      type: CategoryIconType.Income,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.cc_mastercard),
      name: "Mastercard",
      type: CategoryIconType.Income,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.cc_stripe),
      name: "Stipe",
      type: CategoryIconType.Income,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.cc_discover),
      name: "Discover",
      type: CategoryIconType.Income,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.cc_amex),
      name: "Amex",
      type: CategoryIconType.Income,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.cc_paypal),
      name: "Paypal",
      type: CategoryIconType.Income,
    ),
  ];

  final lifeIcons = <CategoryIcon>[
    CategoryIcon(
      icon: Icon(Icons.movie),
      name: "Movie",
      type: CategoryIconType.Life,
    ),
    CategoryIcon(
      icon: Icon(Icons.camera_enhance),
      name: "Camera",
      type: CategoryIconType.Life,
    ),
    CategoryIcon(
      icon: Icon(Icons.flight_takeoff),
      name: "Flight",
      type: CategoryIconType.Life,
    ),
    CategoryIcon(
      icon: Icon(Icons.web),
      name: "Web",
      type: CategoryIconType.Life,
    ),
    CategoryIcon(
      icon: Icon(Icons.email),
      name: "Email",
      type: CategoryIconType.Life,
    ),
    CategoryIcon(
      icon: Icon(Icons.forum),
      name: "Forum",
      type: CategoryIconType.Life,
    ),
    CategoryIcon(
      icon: Icon(Icons.textsms),
      name: "Sms",
      type: CategoryIconType.Life,
    ),
    CategoryIcon(
      icon: Icon(Icons.videogame_asset),
      name: "Games",
      type: CategoryIconType.Life,
    ),
    CategoryIcon(
      icon: Icon(Icons.directions_bike),
      name: "Bike",
      type: CategoryIconType.Life,
    ),
    CategoryIcon(
      icon: Icon(Icons.directions_run),
      name: "Run",
      type: CategoryIconType.Life,
    ),
    CategoryIcon(
      icon: Icon(Icons.local_movies),
      name: "Movies",
      type: CategoryIconType.Life,
    ),
    CategoryIcon(
      icon: Icon(Icons.local_hotel),
      name: "Hotel",
      type: CategoryIconType.Life,
    ),
    CategoryIcon(
      icon: Icon(Icons.map),
      name: "Map",
      type: CategoryIconType.Life,
    ),
    CategoryIcon(
      icon: Icon(Icons.book),
      name: "Book",
      type: CategoryIconType.Life,
    ),
    CategoryIcon(
      icon: Icon(Icons.pool),
      name: "Pool",
      type: CategoryIconType.Life,
    ),
    CategoryIcon(
      icon: Icon(Icons.beach_access),
      name: "Beach",
      type: CategoryIconType.Life,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.music_note),
      name: "Music",
      type: CategoryIconType.Life,
    ),
    CategoryIcon(
      icon: Icon(Icons.fitness_center),
      name: "Fitness",
      type: CategoryIconType.Life,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.cloud_sun),
      name: "CloudSun",
      type: CategoryIconType.Life,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.sun_filled),
      name: "Sun",
      type: CategoryIconType.Life,
    ),
    CategoryIcon(
      icon: Icon(Icons.landscape),
      name: "Landscape",
      type: CategoryIconType.Life,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.picture),
      name: "Picture",
      type: CategoryIconType.Life,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.picture_1),
      name: "Picture_1",
      type: CategoryIconType.Life,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.amazon),
      name: "Amazon",
      type: CategoryIconType.Life,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.facebook_official),
      name: "Facebook",
      type: CategoryIconType.Life,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.spotify),
      name: "Spotify",
      type: CategoryIconType.Life,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.steam_squared),
      name: "Steam",
      type: CategoryIconType.Life,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.soundcloud),
      name: "Soundcloud",
      type: CategoryIconType.Life,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.skype),
      name: "Skype",
      type: CategoryIconType.Life,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.youtube_play),
      name: "Youtube",
      type: CategoryIconType.Life,
    ),
  ];

  final personalIcons = <CategoryIcon>[
    CategoryIcon(
      icon: Icon(Icons.home),
      name: "Home",
      type: CategoryIconType.Personal,
    ),
    CategoryIcon(
      icon: Icon(Icons.work),
      name: "Work",
      type: CategoryIconType.Personal,
    ),
    CategoryIcon(
      icon: Icon(Icons.pets),
      name: "Pets",
      type: CategoryIconType.Personal,
    ),
    CategoryIcon(
      icon: Icon(Icons.language),
      name: "Langugage",
      type: CategoryIconType.Personal,
    ),
    CategoryIcon(
      icon: Icon(Icons.build),
      name: "Build",
      type: CategoryIconType.Personal,
    ),
    CategoryIcon(
      icon: Icon(Icons.local_gas_station),
      name: "Gas",
      type: CategoryIconType.Personal,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.t_shirt),
      name: "T_Shirt",
      type: CategoryIconType.Personal,
    ),
    CategoryIcon(
      icon: Icon(Icons.local_laundry_service),
      name: "Laundry",
      type: CategoryIconType.Personal,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.religious_christian),
      name: "Religious",
      type: CategoryIconType.Personal,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.lighter),
      name: "Lighter",
      type: CategoryIconType.Personal,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.chart_area),
      name: "ChartArea",
      type: CategoryIconType.Personal,
    ),
  ];

  final shoppingIcons = <CategoryIcon>[
    CategoryIcon(
      icon: Icon(Icons.add_shopping_cart),
      name: "Shop",
      type: CategoryIconType.Shopping,
    ),
    CategoryIcon(
      icon: Icon(Icons.local_offer),
      name: "Offer",
      type: CategoryIconType.Shopping,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.diamond),
      name: "Diamond",
      type: CategoryIconType.Shopping,
    ),
    CategoryIcon(
      icon: Icon(Icons.local_mall),
      name: "Shop",
      type: CategoryIconType.Shopping,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.shop),
      name: "Shop",
      type: CategoryIconType.Shopping,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.shopping_bag),
      name: "ShoppingBag",
      type: CategoryIconType.Shopping,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.shopping_basket),
      name: "ShoppingBasket",
      type: CategoryIconType.Shopping,
    ),
  ];

  final transportationIcon = <CategoryIcon>[
    CategoryIcon(
      icon: Icon(Icons.directions_boat),
      name: "Boat",
      type: CategoryIconType.Transportation,
    ),
    CategoryIcon(
      icon: Icon(Icons.directions_bus),
      name: "Bus",
      type: CategoryIconType.Transportation,
    ),
    CategoryIcon(
      icon: Icon(Icons.directions_car),
      name: "Car",
      type: CategoryIconType.Transportation,
    ),
    CategoryIcon(
      icon: Icon(Icons.directions_subway),
      name: "Subway",
      type: CategoryIconType.Transportation,
    ),
    CategoryIcon(
      icon: Icon(Icons.airplanemode_active),
      name: "Airplane",
      type: CategoryIconType.Transportation,
    ),
    CategoryIcon(
      icon: Icon(Icons.local_taxi),
      name: "Taxi",
      type: CategoryIconType.Transportation,
    ),
  ];

  final otherIcons = <CategoryIcon>[
    CategoryIcon(
      icon: Icon(CustomIcons.na),
      name: "NA",
      type: CategoryIconType.Others,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.tree_1),
      name: "Tree",
      type: CategoryIconType.Others,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.drop),
      name: "Drop",
      type: CategoryIconType.Others,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.help_circled),
      name: "Help",
      type: CategoryIconType.Others,
      isSelected: true,
    ),
  ];

  final _controller = ScrollController();

  final _selectedKey = new GlobalKey();

  List<Widget> _buildCategoryIconsPerType(
    BuildContext context,
    String categoryType,
    List<CategoryIcon> icons,
  ) {
    var textTheme = Theme.of(context).textTheme;
    var orientation = MediaQuery.of(context).orientation;
    var grid = GridView.count(
      childAspectRatio: orientation == Orientation.portrait ? 1.5 : 2,
      crossAxisCount: 4,
      padding: EdgeInsets.all(0),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: List.generate(
        icons.length,
        (index) {
          return IconButton(
            key: icons[index].isSelected ? _selectedKey : null,
            iconSize: 30,
            color: icons[index].isSelected ? Colors.redAccent : Colors.black87,
            icon: icons[index].icon,
            onPressed: () {},
          );
        },
      ),
    );
    var widgets = [
      Container(
        margin: EdgeInsets.only(top: 10),
        child: Text(
          categoryType,
          style: textTheme.subhead,
          textAlign: TextAlign.center,
        ),
      ),
      grid
    ];

    return widgets;
  }

  List<Widget> _buildCategoryIcons(BuildContext context) {
    var categoryIcons = List<Widget>();
    var icons = educationIcons +
        electronicIcons +
        familyIcons +
        foodIcons +
        furnitureIcons +
        incomeIcons +
        lifeIcons +
        personalIcons +
        shoppingIcons +
        transportationIcon +
        otherIcons;
    for (CategoryIconType type in CategoryIconType.values) {
      var filteredIcons = icons.where((i) => i.type == type).toList();
      if (filteredIcons.length <= 0) {
        print("Couldnt find categories icon for type = $type");
        continue;
      }

      String categoryType = CategoryUtils.getCategoryIconTypeName(type);
      var widgets = _buildCategoryIconsPerType(
        context,
        categoryType,
        filteredIcons,
      );
      categoryIcons.addAll(widgets);
    }

    return categoryIcons;
  }

  _animateToIndex() => Scrollable.ensureVisible(
        _selectedKey.currentContext,
        duration: Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) => _animateToIndex());

    return Scaffold(
      appBar: AppBar(
        title: Text("Pick an icon"),
        leading: BackButton(),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _animateToIndex,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buildCategoryIcons(context),
        ),
      ),
    );
  }
}
