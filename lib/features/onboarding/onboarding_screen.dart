import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/core/utils/navigation_options.dart';
import 'package:opennutritracker/features/onboarding/domain/entity/user_activity_selection_entity.dart';
import 'package:opennutritracker/features/onboarding/domain/entity/user_gender_selection_entity.dart';
import 'package:opennutritracker/features/onboarding/domain/entity/user_goal_selection_entity.dart';
import 'package:opennutritracker/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:opennutritracker/features/onboarding/presentation/onboarding_intro_page_body.dart';
import 'package:opennutritracker/features/onboarding/presentation/widgets/onboarding_fourth_page_body.dart';
import 'package:opennutritracker/features/onboarding/presentation/widgets/onboarding_goal_details_page_body.dart';
import 'package:opennutritracker/features/onboarding/presentation/widgets/onboarding_overview_page_body.dart';
import 'package:opennutritracker/features/onboarding/presentation/widgets/onboarding_third_page_body.dart';
import 'package:opennutritracker/features/onboarding/presentation/widgets/highlight_button.dart';
import 'package:opennutritracker/features/onboarding/presentation/widgets/onboarding_first_page_body.dart';
import 'package:opennutritracker/features/onboarding/presentation/widgets/onboarding_second_page_body.dart';
import 'package:opennutritracker/generated/l10n.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late OnboardingBloc _onboardingBloc;
  final _introKey = GlobalKey<IntroductionScreenState>();

  final _pageDecoration = const PageDecoration(
      safeArea: 0, bodyAlignment: Alignment.topCenter, bodyFlex: 6);

  final _defaultImageWidget = null;

  bool _introPageButtonActive = false;
  bool _firstPageButtonActive = false;
  bool _secondPageButtonActive = false;
  bool _thirdPageButtonActive = false;
  bool _fourthPageButtonActive = false;
  bool _goalDetailsPageButtonActive = false;
  bool _overviewPageButtonActive = false;

  bool _needsGoalDetails = false;

  @override
  void initState() {
    _onboardingBloc = locator<OnboardingBloc>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<OnboardingBloc, OnboardingState>(
          bloc: _onboardingBloc,
          builder: (context, state) {
            if (state is OnboardingInitialState) {
              _onboardingBloc.add(LoadOnboardingEvent());
              return _getLoadingContent();
            } else if (state is OnboardingLoadingState) {
              return _getLoadingContent();
            } else if (state is OnboardingLoadedState) {
              return _getLoadedContent(context);
            }
            return _getLoadingContent();
          },
        ),
      ),
    );
  }

  Widget _getLoadingContent() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _getLoadedContent(BuildContext context) {
    return IntroductionScreen(
        key: _introKey,
        scrollPhysics: const NeverScrollableScrollPhysics(),
        back: const Icon(Icons.arrow_back_outlined),
        showBackButton: true,
        showNextButton: false,
        showDoneButton: false,
        isProgressTap: false,
        dotsFlex: 0,
        dotsDecorator: DotsDecorator(
          size: const Size(10.0, 10.0),
          activeColor: Theme.of(context).colorScheme.primary,
          activeSize: const Size(22.0, 10.0),
          activeShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
        ),
        onChange: onPageChanged,
        pages: _getPageViewModels());
  }

  int get _overviewPageIndex => _needsGoalDetails ? 6 : 5;

  List<PageViewModel> _getPageViewModels() {
    final pages = <PageViewModel>[
      // Page 0: Intro
      PageViewModel(
          title: S.of(context).onboardingWelcomeLabel,
          decoration: _pageDecoration,
          image: _defaultImageWidget,
          bodyWidget: OnboardingIntroPageBody(
            setPageContent: _setIntroPageData,
            initialAcceptedPolicy: _introPageButtonActive,
            initialAcceptedDataCollection:
                _onboardingBloc.userSelection.acceptDataCollection,
          ),
          footer: HighlightButton(
            buttonLabel: S.of(context).buttonStartLabel,
            onButtonPressed: () => _scrollToPage(1),
            buttonActive: _introPageButtonActive,
          )),
      // Page 1: Gender & Age
      PageViewModel(
          titleWidget: const SizedBox(),
          decoration: _pageDecoration,
          image: _defaultImageWidget,
          bodyWidget: OnboardingFirstPageBody(
            setPageContent: _setFirstPageData,
            initialGender: _onboardingBloc.userSelection.gender,
            initialBirthday: _onboardingBloc.userSelection.birthday,
          ),
          footer: HighlightButton(
            buttonLabel: S.of(context).buttonNextLabel,
            onButtonPressed: () => _scrollToPage(2),
            buttonActive: _firstPageButtonActive,
          )),
      // Page 2: Height & Weight
      PageViewModel(
          titleWidget: const SizedBox(),
          decoration: _pageDecoration,
          image: _defaultImageWidget,
          bodyWidget: OnboardingSecondPageBody(
            setButtonContent: _setSecondPageData,
            initialHeightCm: _onboardingBloc.userSelection.height,
            initialWeightKg: _onboardingBloc.userSelection.weight,
            initialUsesImperialUnits:
                _onboardingBloc.userSelection.usesImperialUnits,
          ),
          footer: HighlightButton(
            buttonLabel: S.of(context).buttonNextLabel,
            onButtonPressed: () => _scrollToPage(3),
            buttonActive: _secondPageButtonActive,
          )),
      // Page 3: Activity Level
      PageViewModel(
          titleWidget: const SizedBox(),
          decoration: _pageDecoration,
          image: _defaultImageWidget,
          bodyWidget: OnboardingThirdPageBody(
            setButtonContent: _setThirdPageButton,
            initialActivity: _onboardingBloc.userSelection.activity,
          ),
          footer: HighlightButton(
            buttonLabel: S.of(context).buttonNextLabel,
            onButtonPressed: () => _scrollToPage(4),
            buttonActive: _thirdPageButtonActive,
          )),
      // Page 4: Goal Selection
      PageViewModel(
          titleWidget: const SizedBox(),
          decoration: _pageDecoration,
          image: _defaultImageWidget,
          bodyWidget: OnboardingFourthPageBody(
            setButtonContent: _setFourthPageButton,
            initialGoal: _onboardingBloc.userSelection.goal,
          ),
          footer: HighlightButton(
            buttonLabel: S.of(context).buttonNextLabel,
            onButtonPressed: () => _scrollToPage(5),
            buttonActive: _fourthPageButtonActive,
          )),
    ];

    // Page 5 (conditional): Goal Details
    if (_needsGoalDetails) {
      pages.add(PageViewModel(
          titleWidget: const SizedBox(),
          decoration: _pageDecoration,
          image: _defaultImageWidget,
          bodyWidget: OnboardingGoalDetailsPageBody(
            goal: _onboardingBloc.userSelection.goal ??
                UserGoalSelectionEntity.loseWeight,
            currentWeightKG: _onboardingBloc.userSelection.weight ?? 70,
            usesImperialUnits: _onboardingBloc.userSelection.usesImperialUnits,
            initialTargetWeightKG: _onboardingBloc.userSelection.targetWeight,
            initialWeightChangeRateKgPerWeek:
                _onboardingBloc.userSelection.weightChangeRateKgPerWeek,
            setButtonContent: _setGoalDetailsPageData,
          ),
          footer: HighlightButton(
            buttonLabel: S.of(context).buttonNextLabel,
            onButtonPressed: () => _scrollToPage(_overviewPageIndex),
            buttonActive: _goalDetailsPageButtonActive,
          )));
    }

    // Overview page (last)
    pages.add(PageViewModel(
        titleWidget: const SizedBox(),
        decoration: _pageDecoration,
        image: _defaultImageWidget,
        bodyWidget: OnboardingOverviewPageBody(
          calorieGoalDayString: _onboardingBloc
                  .getOverviewCalorieGoal()
                  ?.toInt()
                  .toString() ??
              "?",
          carbsGoalString:
              _onboardingBloc.getOverviewCarbsGoal()?.toInt().toString() ?? "?",
          fatGoalString:
              _onboardingBloc.getOverviewFatGoal()?.toInt().toString() ?? "?",
          proteinGoalString:
              _onboardingBloc.getOverviewProteinGoal()?.toInt().toString() ??
                  "?",
          setButtonActive: _setOverviewPageContent,
        ),
        footer: HighlightButton(
          buttonLabel: S.of(context).buttonStartLabel,
          onButtonPressed: () {
            _onOverviewStartButtonPressed(context);
          },
          buttonActive: _overviewPageButtonActive,
        )));

    return pages;
  }

  void _scrollToPage(int page) {
    FocusScope.of(context).requestFocus(FocusNode());
    _introKey.currentState?.animateScroll(page);
  }

  void _setIntroPageData(bool active, bool acceptedDataCollection) {
    setState(() {
      _onboardingBloc.userSelection.acceptDataCollection =
          acceptedDataCollection;
      _introPageButtonActive = active;
    });
  }

  void _setFirstPageData(bool active, UserGenderSelectionEntity? selectedGender,
      DateTime? selectedBirthday) {
    setState(() {
      _onboardingBloc.userSelection.gender = selectedGender;
      _onboardingBloc.userSelection.birthday = selectedBirthday;
      _firstPageButtonActive = active;
    });
  }

  void _setSecondPageData(bool active, double? selectedHeight,
      double? selectedWeight, bool usesImperial) {
    setState(() {
      _onboardingBloc.userSelection.height = selectedHeight;
      _onboardingBloc.userSelection.weight = selectedWeight;
      _onboardingBloc.userSelection.usesImperialUnits = usesImperial;
      _secondPageButtonActive = active;
    });
  }

  void _setThirdPageButton(
      bool active, UserActivitySelectionEntity? selectedActivity) {
    setState(() {
      _onboardingBloc.userSelection.activity = selectedActivity;
      _thirdPageButtonActive = active;
    });
  }

  void _setFourthPageButton(
      bool active, UserGoalSelectionEntity? selectedGoal) {
    setState(() {
      _onboardingBloc.userSelection.goal = selectedGoal;
      _fourthPageButtonActive = active;

      final needsDetails =
          selectedGoal == UserGoalSelectionEntity.loseWeight ||
              selectedGoal == UserGoalSelectionEntity.gainWeigh;

      if (needsDetails != _needsGoalDetails) {
        _needsGoalDetails = needsDetails;
        if (!needsDetails) {
          _onboardingBloc.userSelection.targetWeight = null;
          _onboardingBloc.userSelection.weightChangeRateKgPerWeek = null;
          _goalDetailsPageButtonActive = false;
        }
      }
    });
  }

  void _setGoalDetailsPageData(
      bool active, double? targetWeight, double? weightChangeRateKgPerWeek) {
    setState(() {
      _onboardingBloc.userSelection.targetWeight = targetWeight;
      _onboardingBloc.userSelection.weightChangeRateKgPerWeek =
          weightChangeRateKgPerWeek;
      _goalDetailsPageButtonActive = active;
    });
  }

  void onPageChanged(int page) {
    checkUserDataProvided();
  }

  void checkUserDataProvided() {
    _onboardingBloc.userSelection.checkDataProvided()
        ? _setOverviewPageContent(true)
        : _setOverviewPageContent(false);
  }

  void _setOverviewPageContent(bool active) {
    setState(() {
      _overviewPageButtonActive = active;
    });
  }

  void _onOverviewStartButtonPressed(BuildContext context) {
    final userEntity = _onboardingBloc.userSelection.toUserEntity();
    final hasAcceptedDataCollection =
        _onboardingBloc.userSelection.acceptDataCollection;
    final usesImperialUnits = _onboardingBloc.userSelection.usesImperialUnits;
    if (userEntity != null) {
      _onboardingBloc.saveOnboardingData(
          context, userEntity, hasAcceptedDataCollection, usesImperialUnits);
      Navigator.pushReplacementNamed(context, NavigationOptions.mainRoute);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).onboardingSaveUserError)));
      _scrollToPage(1);
    }
  }
}
