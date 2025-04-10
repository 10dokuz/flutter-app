import 'dart:developer' as dev;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/features/ads/interstitial_ad_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/features/wallet/cubits/payment_request_cubit.dart';
import 'package:flutterquiz/features/wallet/cubits/transactions_cubit.dart';
import 'package:flutterquiz/features/wallet/models/payment_request.dart';
import 'package:flutterquiz/features/wallet/wallet_repository.dart';
import 'package:flutterquiz/ui/screens/wallet/widgets/cancel_redeem_request_dialog.dart';
import 'package:flutterquiz/ui/screens/wallet/widgets/redeem_amount_request_bottom_sheet_container.dart';
import 'package:flutterquiz/ui/styles/colors.dart';
import 'package:flutterquiz/ui/widgets/all.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:intl/intl.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  _WalletScreenState createState() => _WalletScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<PaymentRequestCubit>(
            create: (_) => PaymentRequestCubit(WalletRepository()),
          ),
          BlocProvider<TransactionsCubit>(
            create: (_) => TransactionsCubit(WalletRepository()),
          ),
        ],
        child: const WalletScreen(),
      ),
    );
  }
}

class _WalletScreenState extends State<WalletScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  TextEditingController? redeemableAmountTextEditingController;
  late final ScrollController _transactionsScrollController = ScrollController()
    ..addListener(hasMoreTransactionsScrollListener);

  void hasMoreTransactionsScrollListener() {
    if (_transactionsScrollController.position.maxScrollExtent ==
        _transactionsScrollController.offset) {
      if (context.read<TransactionsCubit>().hasMoreTransactions()) {
        fetchMoreTransactions();
      } else {
        dev.log(name: 'Payout Transactions', 'No more transactions');
      }
    }
  }

  void fetchTransactions() {
    context.read<TransactionsCubit>().getTransactions();
  }

  void fetchMoreTransactions() {
    context.read<TransactionsCubit>().getMoreTransactions();
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 1, vsync: this);
    Future.delayed(Duration.zero, () {
      fetchTransactions();
      redeemableAmountTextEditingController = TextEditingController(
        text: UiUtils.calculateAmountPerCoins(
          userCoins: double.parse(context.read<UserDetailsCubit>().getCoins()!)
              .toInt(),
          amount: context.read<SystemConfigCubit>().coinAmount,
          coins: context.read<SystemConfigCubit>().perCoin,
        ).toString(),
      );
      Future.delayed(Duration.zero, () {
        context.read<InterstitialAdCubit>().showAd(context);
      });
      setState(() {});
    });
  }

  double _minimumRedeemableAmount() {
    return UiUtils.calculateAmountPerCoins(
      userCoins: context.read<SystemConfigCubit>().minimumCoinLimit,
      amount: context.read<SystemConfigCubit>().coinAmount,
      coins: context.read<SystemConfigCubit>().perCoin,
    );
  }

  @override
  void dispose() {
    redeemableAmountTextEditingController?.dispose();
    _transactionsScrollController
      ..removeListener(hasMoreTransactionsScrollListener)
      ..dispose();
    tabController.dispose();
    super.dispose();
  }

  Widget _buildPayoutRequestNote(String note) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onTertiary,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              note,
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onTertiary
                    .withOpacity(0.4),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Expanded widget kaldırılarak, içeriğin doğru renderlanması sağlandı.
  Widget _buildRequestContainer() {
    final configCubit = context.read<SystemConfigCubit>();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    spreadRadius: 2,
                    blurRadius: 2,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Coins",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiary,
                      fontSize: 16,
                    ),
                  ),
                  BlocBuilder<UserDetailsCubit, UserDetailsState>(
                    bloc: context.read<UserDetailsCubit>(),
                    builder: (context, state) {
                      if (state is UserDetailsFetchSuccess) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              Assets.coin,
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${context.read<UserDetailsCubit>().getCoins()}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onTertiary,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                          ],
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                  SizedBox(height: 24),
                  // İletişim Bilgileri Bölümü: Hiçbir satır silinmeden, ikon eklemeleri yapıldı.
                  Text(
                    "Contact Information",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiary,
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Thank you for choosing us!",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiary,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Icon(
                        Icons.camera_alt,
                        color: Theme.of(context).colorScheme.onTertiary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Instagram: appbilio",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onTertiary,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.send,
                        color: Theme.of(context).colorScheme.onTertiary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Telegram: appbilio",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onTertiary,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.email,
                        color: Theme.of(context).colorScheme.onTertiary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Mail: chatbilio@gmail.com",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onTertiary,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            // Diğer widget ve butonlar...
          ],
        ),
      ),
    );
  }

  Container redeemCoinOptions(String coins) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onTertiary.withOpacity(0.09),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context)
                .colorScheme
                .onTertiary
                .withOpacity(0.06),
            spreadRadius: 1,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            Assets.coin,
            width: 15,
            height: 15,
          ),
          const SizedBox(width: 4),
          Text(
            coins,
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onTertiary
                  .withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionContainer({
    required PaymentRequest paymentRequest,
    required int index,
    required int totalTransactions,
    required bool hasMoreTransactionsFetchError,
    required bool hasMore,
  }) {
    if (index == totalTransactions - 1) {
      if (hasMore) {
        if (hasMoreTransactionsFetchError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: IconButton(
                onPressed: fetchMoreTransactions,
                icon: Icon(
                  Icons.error,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          );
        } else {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: CircularProgressContainer(),
            ),
          );
        }
      }
    }
    final String paymentStatus;
    final Color statusColor;
    String? paymentLogo;
    if (paymentRequest.status == '0') {
      paymentStatus = "Pending";
      statusColor = kPendingColor;
    } else if (paymentRequest.status == '1') {
      paymentStatus = "Completed";
      statusColor = kAddCoinColor;
    } else {
      paymentStatus = "Wrong Details";
      statusColor = kHurryUpTimerColor;
    }
    final payoutIndex = payoutMethods.indexWhere(
          (e) => e.type.toLowerCase() == paymentRequest.paymentType.toLowerCase(),
    );
    if (payoutIndex != -1) {
      paymentLogo = payoutMethods[payoutIndex].image;
    }
    return LayoutBuilder(
      builder: (context, constraint) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: statusColor),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    child: Text(
                      paymentStatus,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    DateFormat('yyyy-MM-dd').format(
                      DateTime.parse(paymentRequest.date),
                    ),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onTertiary
                          .withOpacity(.4),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      paymentRequest.details,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onTertiary,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: constraint.maxWidth * 0.23,
                    child: Text(
                      NumberFormat.compactCurrency(
                        symbol: context
                            .read<SystemConfigCubit>()
                            .payoutRequestCurrency,
                      ).format(double.parse(paymentRequest.paymentAmount)),
                      maxLines: 1,
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeights.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (paymentLogo != null && paymentLogo.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: QImage(
                        imageUrl: paymentLogo,
                        width: 40,
                        height: 40,
                      ),
                    )
                  else
                    Expanded(
                      child: Text(
                        "payment: ${paymentRequest.paymentType}",
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onTertiary,
                        ),
                      ),
                    ),
                  if (paymentRequest.status == '0')
                    GestureDetector(
                      onTap: () {
                        showCancelRequestDialog(
                          paymentId: paymentRequest.id,
                          context: context,
                        ).then((canceled) {
                          if (canceled != null && canceled) {
                            fetchTransactions();
                            redeemableAmountTextEditingController?.text =
                                UiUtils.calculateAmountPerCoins(
                                  userCoins: int.parse(
                                    context.read<UserDetailsCubit>().getCoins()!,
                                  ),
                                  amount: context.read<SystemConfigCubit>().coinAmount,
                                  coins: context.read<SystemConfigCubit>().perCoin,
                                ).toString();
                          }
                        });
                      },
                      child: Text(
                        "Cancel",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                          color: Theme.of(context).colorScheme.onTertiary,
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionListContainer() {
    return BlocConsumer<TransactionsCubit, TransactionsState>(
      listener: (context, state) {
        if (state is TransactionsFetchFailure) {
          if (state.errorMessage == errorCodeUnauthorizedAccess) {
            showAlreadyLoggedInDialog(context);
          }
        }
      },
      builder: (context, state) {
        if (state is TransactionsFetchInProgress ||
            state is TransactionsFetchInitial) {
          return const Center(child: CircularProgressContainer());
        }
        if (state is TransactionsFetchFailure) {
          return Center(
            child: ErrorContainer(
              errorMessage: convertErrorCodeToLanguageKey(state.errorMessage),
              onTapRetry: fetchTransactions,
              showErrorImage: true,
            ),
          );
        }
        final totalReqs =
            (state as TransactionsFetchSuccess).paymentRequests.length;
        return SingleChildScrollView(
          controller: _transactionsScrollController,
          padding: EdgeInsets.only(
            bottom: 20,
            top: context.height * 0.02,
            left: context.width * (0.05),
            right: context.width * (0.05),
          ),
          child: Column(
            children: [
              /// Total Earnings
              Container(
                alignment: Alignment.center,
                width: context.width,
                height: context.height * (0.1),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Total Earnings",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onTertiary,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${context.read<SystemConfigCubit>().payoutRequestCurrency} ${context.read<TransactionsCubit>().calculateTotalEarnings()}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onTertiary,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.height * 0.015),

              /// List of Redeem Requests
              for (var i = 0; i < totalReqs; i++) ...[
                _buildTransactionContainer(
                  paymentRequest: state.paymentRequests[i],
                  index: i,
                  totalTransactions: state.paymentRequests.length,
                  hasMoreTransactionsFetchError: state.hasMoreFetchError,
                  hasMore: state.hasMore,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QAppBar(
        title: Text("More"),
        bottom: TabBar(
          tabAlignment: TabAlignment.fill,
          controller: tabController,
          tabs: [
            Tab(
              text: "Contact", // İletişim
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          _buildRequestContainer(),
        ],
      ),
    );
  }
}
