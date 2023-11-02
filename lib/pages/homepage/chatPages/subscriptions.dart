import 'package:flutter/material.dart';
import 'package:hopewyse/pages/homepage/chatPages/constant.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../chat_page.dart';
import 'store_config.dart';

// initialize RevenueCat SDK and check if the user has a valid entitlement (subscription)
class RevenueCatManager {
  static Future<bool> checkEntitlement() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      print('customer info: $customerInfo');
      // return customerInfo.entitlements.active.containsKey(entitlementKey);
      // Check if the customer has any active entitlement
      return customerInfo.entitlements.active.isNotEmpty;
    } catch (e) {
      print('no customer info');
      return false;
    }
  }

  // check if the user has a valid entitlemen
  static Future<void> initializeRevenueCat() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      // enable debugging for revenue cat
      // await Purchases.setLogLevel(LogLevel.debug);

      PurchasesConfiguration configuration;
      if (StoreConfig.isForAppleStore()) {
        configuration = PurchasesConfiguration(appleApiKey);
      } else if (StoreConfig.isForGooglePlay()) {
        configuration = PurchasesConfiguration(googleApiKey);
      } else if (StoreConfig.isForAmazonAppstore()) {
        configuration = AmazonConfiguration(amazonApiKey);
      } else {
        print('No store configuration');
        return;
      }

      // Fetch the logged-in user's email from Firebase
      final user = FirebaseAuth.instance.currentUser;
      print('user is $user');
      if (user != null) {
        configuration.appUserID = user.email;
      } else {
        print('User is not logged in.'); // Handle this case appropriately
      }

      await Purchases.configure(configuration);
      await Purchases.enableAdServicesAttributionTokenCollection();
    } catch (e) {
      print('No purchase configuration');
    }
  }
}

// displays available packages for purchase and handles purchase logic.
class UpsellScreen extends StatefulWidget {
  final Function onPurchaseSuccess;
  const UpsellScreen({super.key, required this.onPurchaseSuccess});

  @override
  State<UpsellScreen> createState() => _UpsellScreenState();
}

class _UpsellScreenState extends State<UpsellScreen> {
  Offerings? _offerings;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final offerings = await Purchases.getOfferings();
      setState(() {
        _offerings = offerings;
      });
    } catch (e) {
      print('No offerings');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_offerings != null) {
      final offering = _offerings!.current;
      if (offering != null) {
        final purchaseButtons =
            _buildPurchaseButtons(offering.availablePackages);
        return Scaffold(
          body: Container(
            color: Colors.blueGrey[600],
            child: Center(
              child: SizedBox(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  // children: purchaseButtons,
                  children: <Widget>[
                    const Flexible(
                      // padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Upgrade Your Plan',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // const Divider(),
                    const Flexible(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            'Upgrade to a new plan to enjoy more benefits',
                            style: TextStyle(
                              color: Colors.white, // White text color
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    ...purchaseButtons,
                    // Flexible(
                    //   // Use Expanded to take up remaining space
                    //   child: Column(
                    //     children: purchaseButtons,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    }

    return Scaffold(
      body: Container(
        color: Colors.blueGrey[600],
        child: const Column(
          children: [
            Flexible(
              child: Text(
                'Upgrade Your Plan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white24,
                ),
              ),
            ),
            Divider(),
            SizedBox(
              child: Center(
                child: Text(
                  'Error upgrading plan. Please try again later.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPurchaseButtons(List<Package> packages) {
    return packages.expand((package) => _buildPackageButtons(package)).toList();
  }

  List<Widget> _buildPackageButtons(Package package) {
    final optionButtons = package.storeProduct.subscriptionOptions
        ?.map((option) => _buildSubscriptionOptionButton(option))
        .toList();

    final buttons = optionButtons ?? [];

    return buttons;
  }

// button widgets for purchasing different types of packages,
  Widget _buildSubscriptionOptionButton(SubscriptionOption option) {
    print('_buildSubscriptionOptionButton code');
    return ElevatedButton(
      onPressed: () => _purchaseSubscriptionOption(option),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.orange),
      ),
      child: Column(
        children: [
          Text(
            'Upgrade: ${option.id}',
            style: const TextStyle(
              color: Colors.black, // Black text color
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            '${option.pricingPhases.map((e) {
              return '${e.price.formatted} for ${e.billingPeriod?.value} ${e.billingPeriod?.unit}';
            }).join(' -> ')}',
            style: const TextStyle(
              color: Colors.black, // Black text color
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _purchaseSubscriptionOption(SubscriptionOption option) async {
    try {
      final customerInfo = await Purchases.purchaseSubscriptionOption(option);
      // Check if the customer has any active entitlement
      final isPro = customerInfo.entitlements.active.isNotEmpty;
      if (isPro) {
        print('purchase was successful');
        // Call the callback function on successful purchase
        widget.onPurchaseSuccess();
        Navigator.of(context).pop(); // Close the upsell screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ChatPage()),
        );
      } else {
        widget.onPurchaseSuccess();
      }
    } catch (e) {
      print('_purchaseSubscriptionOption error: $e');
    }
  }
}
