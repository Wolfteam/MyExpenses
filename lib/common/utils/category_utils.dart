import 'dart:convert';

import 'package:flutter/material.dart';

import '../../common/enums/category_icon_type.dart';
import '../../common/presentation/custom_icons.dart';
import '../../models/category_icon.dart';

class CategoryUtils {
  //Education
  static const school = 'School';
  static const pallete = 'Pallete';

  //Electronics
  static const headset = 'Headset';
  static const radio = 'Radio';
  static const laptop = 'Laptop';
  static const pc = 'PC';
  static const gamepad = 'Gamepad';
  static const phone = 'Phone';
  static const smartphone = 'Smartphone';
  static const watch = 'Watch';
  static const tv = 'TV';
  static const printer = 'Printer';
  static const battery = 'Battery';

  //Family
  static const people = 'People';
  static const child = 'Child';
  static const childFriendly = 'Child_Friendly';
  static const hospital = 'Hospital';
  static const pharmacy = 'Pharmacy';
  static const gift = 'Gift';

  //Food icons
  static const fastFood = 'Fast Food';
  static const food = 'Food';
  static const dinning = 'Dinning';
  static const bar = 'Bar';
  static const cafe = 'Cafe';
  static const pizza = 'Pizza';
  static const restaurant = 'Restaurant';

  //Furniture
  static const seat = 'Seat';
  static const weekend = 'Weekend';
  static const archive = 'Archive';
  static const bed = 'Bed';

  //Income
  static const money = 'Money';
  static const dollar = 'Dollar';
  static const money2 = 'Money_2';
  static const gWallet = 'GWallet';
  static const bank = 'Bank';
  static const wallet = 'Wallet';
  static const atm = 'ATM';
  static const giftcard = 'GitfCard';
  static const creditcard = 'CreditCard';
  static const mastercard = 'Mastercard';
  static const stipe = 'Stipe';
  static const discover = 'Discover';
  static const amex = 'Amex';
  static const paypal = 'Paypal';

  //Life
  static const movie = 'Movie';
  static const camera = 'Camera';
  static const flight = 'Flight';
  static const web = 'Web';
  static const internet = 'Internet';
  static const email = 'Email';
  static const forum = 'Forum';
  static const sms = 'Sms';
  static const games = 'Games';
  static const bike = 'Bike';
  static const run = 'Run';
  static const movies = 'Movies';
  static const hotel = 'Hotel';
  static const map = 'Map';
  static const book = 'Book';
  static const pool = 'Pool';
  static const beach = 'Beach';
  static const music = 'Music';
  static const fitness = 'Fitness';
  static const cloudsun = 'CloudSun';
  static const sun = 'Sun';
  static const landscape = 'Landscape';
  static const picture = 'Picture';
  static const picture1 = 'Picture1';
  static const amazon = 'Amazon';
  static const facebook = 'Facebook';
  static const spotify = 'Spotify';
  static const steam = 'Steam';
  static const soundcloud = 'Soundcloud';
  static const skype = 'Skype';
  static const youtube = 'Youtube';
  static const soccerBall = 'Sports';

  //Personal
  static const home = 'Home';
  static const work = 'Work';
  static const pets = 'Pets';
  static const language = 'Langugage';
  static const build = 'Build';
  static const gas = 'Gas';
  static const tshirt = 'T_Shirt';
  static const laundry = 'Laundry';
  static const religious = 'Religious';
  static const lgihter = 'Lighter';
  static const chartArea = 'ChartArea';
  static const tools = 'Tools';
  static const healing = 'Healing';

  //Shopping
  static const shoppingCart = 'ShoppingCart';
  static const offer = 'Offer';
  static const diamond = 'Diamond';
  static const shop = 'Shop';
  static const mall = 'Mall';
  static const shoppingBag = 'ShoppingBag';
  static const shoopingBasket = 'ShoppingBasket';

  //Transportation
  static const boat = 'Boat';
  static const bus = 'Bus';
  static const car = 'Car';
  static const subway = 'Subway';
  static const airplane = 'Airplane';
  static const taxi = 'Taxi';

  //Others
  static const na = 'NA';
  static const tree = 'Tree';
  static const waterDrop = 'Water';
  static const question = 'Help';

  static final educationIcons = <CategoryIcon>[
    CategoryIcon(
      icon: Icon(Icons.school),
      name: school,
      type: CategoryIconType.education,
    ),
    CategoryIcon(
      icon: Icon(Icons.palette),
      name: pallete,
      type: CategoryIconType.education,
    ),
  ];

  static final electronicIcons = <CategoryIcon>[
    CategoryIcon(
      icon: Icon(Icons.headset),
      name: headset,
      type: CategoryIconType.electronics,
    ),
    CategoryIcon(
      icon: Icon(Icons.radio),
      name: radio,
      type: CategoryIconType.electronics,
    ),
    CategoryIcon(
      icon: Icon(Icons.computer),
      name: laptop,
      type: CategoryIconType.electronics,
    ),
    CategoryIcon(
      icon: Icon(Icons.desktop_windows),
      name: pc,
      type: CategoryIconType.electronics,
    ),
    CategoryIcon(
      icon: Icon(Icons.gamepad),
      name: gamepad,
      type: CategoryIconType.electronics,
    ),
    CategoryIcon(
      icon: Icon(Icons.phone),
      name: phone,
      type: CategoryIconType.electronics,
    ),
    CategoryIcon(
      icon: Icon(Icons.phone_android),
      name: smartphone,
      type: CategoryIconType.electronics,
    ),
    CategoryIcon(
      icon: Icon(Icons.watch),
      name: watch,
      type: CategoryIconType.electronics,
    ),
    CategoryIcon(
      icon: Icon(Icons.live_tv),
      name: tv,
      type: CategoryIconType.electronics,
    ),
    CategoryIcon(
      icon: Icon(Icons.print),
      name: printer,
      type: CategoryIconType.electronics,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.battery),
      name: battery,
      type: CategoryIconType.electronics,
    ),
  ];

  static final familyIcons = <CategoryIcon>[
    CategoryIcon(
      icon: Icon(Icons.people),
      name: people,
      type: CategoryIconType.family,
    ),
    CategoryIcon(
      icon: Icon(Icons.child_care),
      name: child,
      type: CategoryIconType.family,
    ),
    CategoryIcon(
      icon: Icon(Icons.child_friendly),
      name: childFriendly,
      type: CategoryIconType.family,
    ),
    CategoryIcon(
      icon: Icon(Icons.local_hospital),
      name: hospital,
      type: CategoryIconType.family,
    ),
    CategoryIcon(
      icon: Icon(Icons.local_pharmacy),
      name: pharmacy,
      type: CategoryIconType.family,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.gift),
      name: gift,
      type: CategoryIconType.family,
    ),
  ];

  static final foodIcons = <CategoryIcon>[
    CategoryIcon(
      icon: Icon(Icons.fastfood),
      name: fastFood,
      type: CategoryIconType.food,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.food),
      name: food,
      type: CategoryIconType.food,
    ),
    CategoryIcon(
      icon: Icon(Icons.local_dining),
      name: dinning,
      type: CategoryIconType.food,
    ),
    CategoryIcon(
      icon: Icon(Icons.local_bar),
      name: bar,
      type: CategoryIconType.food,
    ),
    CategoryIcon(
      icon: Icon(Icons.local_cafe),
      name: cafe,
      type: CategoryIconType.food,
    ),
    CategoryIcon(
      icon: Icon(Icons.local_pizza),
      name: pizza,
      type: CategoryIconType.food,
    ),
    CategoryIcon(
      icon: Icon(Icons.restaurant),
      name: restaurant,
      type: CategoryIconType.food,
    ),
  ];

  static final furnitureIcons = <CategoryIcon>[
    CategoryIcon(
      icon: Icon(Icons.event_seat),
      name: seat,
      type: CategoryIconType.furniture,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.weekend),
      name: weekend,
      type: CategoryIconType.furniture,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.archive),
      name: archive,
      type: CategoryIconType.furniture,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.hotel),
      name: bed,
      type: CategoryIconType.furniture,
    ),
  ];

  static final incomeIcons = <CategoryIcon>[
    CategoryIcon(
      icon: Icon(CustomIcons.money),
      name: money2,
      type: CategoryIconType.income,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.dollar),
      name: dollar,
      type: CategoryIconType.income,
    ),
    CategoryIcon(
      icon: Icon(Icons.attach_money),
      name: money,
      type: CategoryIconType.income,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.gwallet),
      name: gWallet,
      type: CategoryIconType.income,
    ),
    CategoryIcon(
      icon: Icon(Icons.account_balance),
      name: bank,
      type: CategoryIconType.income,
    ),
    CategoryIcon(
      icon: Icon(Icons.account_balance_wallet),
      name: wallet,
      type: CategoryIconType.income,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.local_atm),
      name: atm,
      type: CategoryIconType.income,
    ),
    CategoryIcon(
      icon: Icon(Icons.card_giftcard),
      name: giftcard,
      type: CategoryIconType.income,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.credit_card),
      name: creditcard,
      type: CategoryIconType.income,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.cc_mastercard),
      name: mastercard,
      type: CategoryIconType.income,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.cc_stripe),
      name: stipe,
      type: CategoryIconType.income,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.cc_discover),
      name: discover,
      type: CategoryIconType.income,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.cc_amex),
      name: amex,
      type: CategoryIconType.income,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.cc_paypal),
      name: paypal,
      type: CategoryIconType.income,
    ),
  ];

  static final lifeIcons = <CategoryIcon>[
    CategoryIcon(
      icon: Icon(Icons.movie),
      name: movie,
      type: CategoryIconType.life,
    ),
    CategoryIcon(
      icon: Icon(Icons.camera_enhance),
      name: camera,
      type: CategoryIconType.life,
    ),
    CategoryIcon(
      icon: Icon(Icons.flight_takeoff),
      name: flight,
      type: CategoryIconType.life,
    ),
    CategoryIcon(
      icon: Icon(Icons.web),
      name: web,
      type: CategoryIconType.life,
    ),
    CategoryIcon(
      icon: Icon(Icons.email),
      name: email,
      type: CategoryIconType.life,
    ),
    CategoryIcon(
      icon: Icon(Icons.forum),
      name: forum,
      type: CategoryIconType.life,
    ),
    CategoryIcon(
      icon: Icon(Icons.textsms),
      name: sms,
      type: CategoryIconType.life,
    ),
    CategoryIcon(
      icon: Icon(Icons.videogame_asset),
      name: games,
      type: CategoryIconType.life,
    ),
    CategoryIcon(
      icon: Icon(Icons.directions_bike),
      name: bike,
      type: CategoryIconType.life,
    ),
    CategoryIcon(
      icon: Icon(Icons.directions_run),
      name: run,
      type: CategoryIconType.life,
    ),
    CategoryIcon(
      icon: Icon(Icons.local_movies),
      name: movies,
      type: CategoryIconType.life,
    ),
    CategoryIcon(
      icon: Icon(Icons.local_hotel),
      name: hotel,
      type: CategoryIconType.life,
    ),
    CategoryIcon(
      icon: Icon(Icons.map),
      name: map,
      type: CategoryIconType.life,
    ),
    CategoryIcon(
      icon: Icon(Icons.book),
      name: book,
      type: CategoryIconType.life,
    ),
    CategoryIcon(
      icon: Icon(Icons.pool),
      name: pool,
      type: CategoryIconType.life,
    ),
    CategoryIcon(
      icon: Icon(Icons.beach_access),
      name: beach,
      type: CategoryIconType.life,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.music_note),
      name: music,
      type: CategoryIconType.life,
    ),
    CategoryIcon(
      icon: Icon(Icons.fitness_center),
      name: fitness,
      type: CategoryIconType.life,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.cloud_sun),
      name: cloudsun,
      type: CategoryIconType.life,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.sun_filled),
      name: sun,
      type: CategoryIconType.life,
    ),
    CategoryIcon(
      icon: Icon(Icons.landscape),
      name: landscape,
      type: CategoryIconType.life,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.picture),
      name: picture,
      type: CategoryIconType.life,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.picture_1),
      name: picture1,
      type: CategoryIconType.life,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.amazon),
      name: amazon,
      type: CategoryIconType.life,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.facebook_official),
      name: facebook,
      type: CategoryIconType.life,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.spotify),
      name: spotify,
      type: CategoryIconType.life,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.steam_squared),
      name: steam,
      type: CategoryIconType.life,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.soundcloud),
      name: soundcloud,
      type: CategoryIconType.life,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.skype),
      name: skype,
      type: CategoryIconType.life,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.youtube_play),
      name: youtube,
      type: CategoryIconType.life,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.soccer_ball),
      name: soccerBall,
      type: CategoryIconType.life,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.internet_explorer),
      name: internet,
      type: CategoryIconType.life,
    ),
  ];

  static final personalIcons = <CategoryIcon>[
    CategoryIcon(
      icon: Icon(Icons.home),
      name: home,
      type: CategoryIconType.personal,
    ),
    CategoryIcon(
      icon: Icon(Icons.work),
      name: work,
      type: CategoryIconType.personal,
    ),
    CategoryIcon(
      icon: Icon(Icons.pets),
      name: pets,
      type: CategoryIconType.personal,
    ),
    CategoryIcon(
      icon: Icon(Icons.language),
      name: language,
      type: CategoryIconType.personal,
    ),
    CategoryIcon(
      icon: Icon(Icons.build),
      name: build,
      type: CategoryIconType.personal,
    ),
    CategoryIcon(
      icon: Icon(Icons.local_gas_station),
      name: gas,
      type: CategoryIconType.personal,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.t_shirt),
      name: tshirt,
      type: CategoryIconType.personal,
    ),
    CategoryIcon(
      icon: Icon(Icons.local_laundry_service),
      name: laundry,
      type: CategoryIconType.personal,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.religious_christian),
      name: religious,
      type: CategoryIconType.personal,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.lighter),
      name: lgihter,
      type: CategoryIconType.personal,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.chart_area),
      name: chartArea,
      type: CategoryIconType.personal,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.tools),
      name: tools,
      type: CategoryIconType.personal,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.healing),
      name: healing,
      type: CategoryIconType.personal,
    ),
  ];

  static final shoppingIcons = <CategoryIcon>[
    CategoryIcon(
      icon: Icon(Icons.add_shopping_cart),
      name: shoppingCart,
      type: CategoryIconType.shopping,
    ),
    CategoryIcon(
      icon: Icon(Icons.local_offer),
      name: offer,
      type: CategoryIconType.shopping,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.diamond),
      name: diamond,
      type: CategoryIconType.shopping,
    ),
    CategoryIcon(
      icon: Icon(Icons.local_mall),
      name: mall,
      type: CategoryIconType.shopping,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.shop),
      name: shop,
      type: CategoryIconType.shopping,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.shopping_bag),
      name: shoppingBag,
      type: CategoryIconType.shopping,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.shopping_basket),
      name: shoopingBasket,
      type: CategoryIconType.shopping,
    ),
  ];

  static final transportationIcon = <CategoryIcon>[
    CategoryIcon(
      icon: Icon(Icons.directions_boat),
      name: boat,
      type: CategoryIconType.transportation,
    ),
    CategoryIcon(
      icon: Icon(Icons.directions_bus),
      name: bus,
      type: CategoryIconType.transportation,
    ),
    CategoryIcon(
      icon: Icon(Icons.directions_car),
      name: car,
      type: CategoryIconType.transportation,
    ),
    CategoryIcon(
      icon: Icon(Icons.directions_subway),
      name: subway,
      type: CategoryIconType.transportation,
    ),
    CategoryIcon(
      icon: Icon(Icons.airplanemode_active),
      name: airplane,
      type: CategoryIconType.transportation,
    ),
    CategoryIcon(
      icon: Icon(Icons.local_taxi),
      name: taxi,
      type: CategoryIconType.transportation,
    ),
  ];

  static final otherIcons = <CategoryIcon>[
    CategoryIcon(
      icon: Icon(CustomIcons.na),
      name: na,
      type: CategoryIconType.others,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.tree_1),
      name: tree,
      type: CategoryIconType.others,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.drop),
      name: waterDrop,
      type: CategoryIconType.others,
    ),
    CategoryIcon(
      icon: Icon(CustomIcons.help_circled),
      name: question,
      type: CategoryIconType.others,
    ),
  ];

  static List<CategoryIcon> getAllCategoryIcons() {
    final icons = educationIcons +
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
    return icons;
  }

  static CategoryIcon getByName(String name) =>
      getAllCategoryIcons().firstWhere((c) => c.name == name);

  static CategoryIcon getByNameAndType(String name, CategoryIconType type) =>
      getAllCategoryIcons()
          .where((i) => i.type == type)
          .firstWhere((c) => c.name == name);

  static CategoryIcon getByIconData(IconData iconData) =>
      getAllCategoryIcons().firstWhere((c) => c.icon.icon == iconData);

  static String toJSONString(IconData data) {
    final map = <String, dynamic>{};
    map['codePoint'] = data.codePoint;
    map['fontFamily'] = data.fontFamily;
    map['fontPackage'] = data.fontPackage;
    map['matchTextDirection'] = data.matchTextDirection;
    return jsonEncode(map);
  }

  static IconData fromJSONString(String jsonString) {
    final map = jsonDecode(jsonString);
    return IconData(
      map['codePoint'] as int,
      fontFamily: map['fontFamily'] as String,
      fontPackage: map['fontPackage'] as String,
      matchTextDirection: map['matchTextDirection'] as bool,
    );
  }
}
