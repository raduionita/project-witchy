import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @anonymousMode.
  ///
  /// In en, this message translates to:
  /// **'Anonymous mode'**
  String get anonymousMode;

  /// No description provided for @anonymousModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Hides your name and email from stored data on this device.'**
  String get anonymousModeDescription;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @termsOfServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfServiceTitle;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefault;

  /// No description provided for @systemDefaultDescription.
  ///
  /// In en, this message translates to:
  /// **'Follows your device\'s language.'**
  String get systemDefaultDescription;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// No description provided for @navLogging.
  ///
  /// In en, this message translates to:
  /// **'Logging'**
  String get navLogging;

  /// No description provided for @navInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get navInsights;

  /// No description provided for @navMagic.
  ///
  /// In en, this message translates to:
  /// **'Magic'**
  String get navMagic;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get navAccount;

  /// No description provided for @homeWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Witchy'**
  String get homeWelcomeTitle;

  /// No description provided for @homeSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your cycle'**
  String get homeSetupTitle;

  /// No description provided for @homeSetupBody.
  ///
  /// In en, this message translates to:
  /// **'Complete the short onboarding to unlock personalized predictions.'**
  String get homeSetupBody;

  /// No description provided for @homeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get homeToday;

  /// No description provided for @homeCycleDay.
  ///
  /// In en, this message translates to:
  /// **'Day {day} of your cycle'**
  String homeCycleDay(int day);

  /// No description provided for @homeNextPeriod.
  ///
  /// In en, this message translates to:
  /// **'Next period'**
  String get homeNextPeriod;

  /// No description provided for @homeInDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{In 1 day} other{In {count} days}}'**
  String homeInDays(int count);

  /// No description provided for @homeFertileWindow.
  ///
  /// In en, this message translates to:
  /// **'Fertile window'**
  String get homeFertileWindow;

  /// No description provided for @phaseMenstruation.
  ///
  /// In en, this message translates to:
  /// **'Menstruation'**
  String get phaseMenstruation;

  /// No description provided for @phaseFollicular.
  ///
  /// In en, this message translates to:
  /// **'Follicular phase'**
  String get phaseFollicular;

  /// No description provided for @phaseOvulation.
  ///
  /// In en, this message translates to:
  /// **'Ovulation'**
  String get phaseOvulation;

  /// No description provided for @phaseLuteal.
  ///
  /// In en, this message translates to:
  /// **'Luteal phase'**
  String get phaseLuteal;

  /// No description provided for @settingsModeActive.
  ///
  /// In en, this message translates to:
  /// **'{mode} is now active.'**
  String settingsModeActive(Object mode);

  /// No description provided for @settingsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'{feature} is coming soon.'**
  String settingsComingSoon(Object feature);

  /// No description provided for @settingsAnonymousOn.
  ///
  /// In en, this message translates to:
  /// **'Anonymous mode is now on.'**
  String get settingsAnonymousOn;

  /// No description provided for @settingsAnonymousOff.
  ///
  /// In en, this message translates to:
  /// **'Anonymous mode is now off.'**
  String get settingsAnonymousOff;

  /// No description provided for @settingsPrivacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'How your data is protected.'**
  String get settingsPrivacySubtitle;

  /// No description provided for @settingsTermsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Rules for using Witchy.'**
  String get settingsTermsSubtitle;

  /// No description provided for @settingsAboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Witchy version and legal info.'**
  String get settingsAboutSubtitle;

  /// No description provided for @settingsTrackingModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Tracking mode'**
  String get settingsTrackingModeTitle;

  /// No description provided for @settingsTrackingModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose what Witchy focuses on.'**
  String get settingsTrackingModeSubtitle;

  /// No description provided for @settingsLogsShared.
  ///
  /// In en, this message translates to:
  /// **'Logs are shared'**
  String get settingsLogsShared;

  /// No description provided for @settingsLogsSharedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your symptom and period logs stay with you across modes.'**
  String get settingsLogsSharedSubtitle;

  /// No description provided for @settingsRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get settingsRemindersTitle;

  /// No description provided for @settingsRemindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Period, medication, water and sleep.'**
  String get settingsRemindersSubtitle;

  /// No description provided for @settingsCouplesTitle.
  ///
  /// In en, this message translates to:
  /// **'Couples mode'**
  String get settingsCouplesTitle;

  /// No description provided for @settingsCouplesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share a private space (coming soon).'**
  String get settingsCouplesSubtitle;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how Witchy reads to you.'**
  String get settingsLanguageSubtitle;

  /// No description provided for @settingsThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsThemeTitle;

  /// No description provided for @settingsThemeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how Witchy looks.'**
  String get settingsThemeSubtitle;

  /// No description provided for @settingsSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get settingsSignOut;

  /// No description provided for @settingsAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccountTitle;

  /// No description provided for @settingsAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to enable optional features. Your data stays on your device.'**
  String get settingsAccountSubtitle;

  /// No description provided for @themeDefaultLight.
  ///
  /// In en, this message translates to:
  /// **'Default (light)'**
  String get themeDefaultLight;

  /// No description provided for @trackingModeCycle.
  ///
  /// In en, this message translates to:
  /// **'Cycle tracking'**
  String get trackingModeCycle;

  /// No description provided for @trackingModePregnancy.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy'**
  String get trackingModePregnancy;

  /// No description provided for @trackingModePerimenopause.
  ///
  /// In en, this message translates to:
  /// **'Perimenopause'**
  String get trackingModePerimenopause;

  /// No description provided for @trackingModeCycleDesc.
  ///
  /// In en, this message translates to:
  /// **'Periods, fertility and cycle predictions.'**
  String get trackingModeCycleDesc;

  /// No description provided for @trackingModePregnancyDesc.
  ///
  /// In en, this message translates to:
  /// **'Track weeks, trimester and due date.'**
  String get trackingModePregnancyDesc;

  /// No description provided for @trackingModePerimenopauseDesc.
  ///
  /// In en, this message translates to:
  /// **'Symptom-focused tracking for this stage.'**
  String get trackingModePerimenopauseDesc;

  /// No description provided for @authSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed in. Your account stays on this device.'**
  String get authSignedIn;

  /// No description provided for @authSignInOptional.
  ///
  /// In en, this message translates to:
  /// **'Sign in (optional)'**
  String get authSignInOptional;

  /// No description provided for @authBody.
  ///
  /// In en, this message translates to:
  /// **'Witchy never needs an account. Signing in gives you a consistent identity for features like Couples mode — everything stays on your device.'**
  String get authBody;

  /// No description provided for @authGoogleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Google Sign In'**
  String get authGoogleSignIn;

  /// No description provided for @authAppleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Apple Sign In'**
  String get authAppleSignIn;

  /// No description provided for @authAnonymous.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get authAnonymous;

  /// No description provided for @authProviderGoogle.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get authProviderGoogle;

  /// No description provided for @authProviderApple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get authProviderApple;

  /// No description provided for @authProviderAnonymous.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get authProviderAnonymous;

  /// No description provided for @onboardingBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboardingBack;

  /// No description provided for @onboardingFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get onboardingFinish;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Let\'\'s set up your cycle so we can show accurate predictions.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Witchy is educational and not a diagnostic tool, and is not a method of contraception.'**
  String get onboardingDisclaimer;

  /// No description provided for @onboardingLastPeriod.
  ///
  /// In en, this message translates to:
  /// **'Last period start'**
  String get onboardingLastPeriod;

  /// No description provided for @onboardingCycleLength.
  ///
  /// In en, this message translates to:
  /// **'What is your average cycle length?'**
  String get onboardingCycleLength;

  /// No description provided for @onboardingPeriodLength.
  ///
  /// In en, this message translates to:
  /// **'How long does your period last?'**
  String get onboardingPeriodLength;

  /// No description provided for @onboardingDaysSuffix.
  ///
  /// In en, this message translates to:
  /// **' days'**
  String get onboardingDaysSuffix;

  /// No description provided for @onboardingAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create an account (optional)'**
  String get onboardingAccountTitle;

  /// No description provided for @onboardingAccountBody.
  ///
  /// In en, this message translates to:
  /// **'Witchy works perfectly without an account. Signing in later enables optional features — everything stays on your device.'**
  String get onboardingAccountBody;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get onboardingSkip;

  /// No description provided for @loggingUseCalendar.
  ///
  /// In en, this message translates to:
  /// **'Use the Calendar tab to pick a day.'**
  String get loggingUseCalendar;

  /// No description provided for @loggingLogPeriod.
  ///
  /// In en, this message translates to:
  /// **'Log period'**
  String get loggingLogPeriod;

  /// No description provided for @loggingLogPeriodSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Flow, symptoms, mood and notes'**
  String get loggingLogPeriodSubtitle;

  /// No description provided for @loggingLogFromCalendar.
  ///
  /// In en, this message translates to:
  /// **'Log from calendar'**
  String get loggingLogFromCalendar;

  /// No description provided for @loggingLogFromCalendarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a day to log or edit'**
  String get loggingLogFromCalendarSubtitle;

  /// No description provided for @loggingRecentLogs.
  ///
  /// In en, this message translates to:
  /// **'Recent logs'**
  String get loggingRecentLogs;

  /// No description provided for @loggingEmpty.
  ///
  /// In en, this message translates to:
  /// **'No logs yet. Tap \"Log period\" to get started.'**
  String get loggingEmpty;

  /// No description provided for @logFlowIntensity.
  ///
  /// In en, this message translates to:
  /// **'Flow intensity'**
  String get logFlowIntensity;

  /// No description provided for @logSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get logSymptoms;

  /// No description provided for @logMood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get logMood;

  /// No description provided for @logNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get logNotes;

  /// No description provided for @logSave.
  ///
  /// In en, this message translates to:
  /// **'Save log'**
  String get logSave;

  /// No description provided for @logPeriodTitle.
  ///
  /// In en, this message translates to:
  /// **'Log {date}'**
  String logPeriodTitle(Object date);

  /// No description provided for @logSymptomTitle.
  ///
  /// In en, this message translates to:
  /// **'Symptoms · {date}'**
  String logSymptomTitle(Object date);

  /// No description provided for @flowLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get flowLight;

  /// No description provided for @flowMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get flowMedium;

  /// No description provided for @flowHeavy.
  ///
  /// In en, this message translates to:
  /// **'Heavy'**
  String get flowHeavy;

  /// No description provided for @moodHappy.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get moodHappy;

  /// No description provided for @moodCalm.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get moodCalm;

  /// No description provided for @moodAnxious.
  ///
  /// In en, this message translates to:
  /// **'Anxious'**
  String get moodAnxious;

  /// No description provided for @moodIrritable.
  ///
  /// In en, this message translates to:
  /// **'Irritable'**
  String get moodIrritable;

  /// No description provided for @moodSad.
  ///
  /// In en, this message translates to:
  /// **'Sad'**
  String get moodSad;

  /// No description provided for @moodEnergetic.
  ///
  /// In en, this message translates to:
  /// **'Energetic'**
  String get moodEnergetic;

  /// No description provided for @symptomCategoryPain.
  ///
  /// In en, this message translates to:
  /// **'Pain & discomfort'**
  String get symptomCategoryPain;

  /// No description provided for @symptomCramps.
  ///
  /// In en, this message translates to:
  /// **'Cramps'**
  String get symptomCramps;

  /// No description provided for @symptomHeadache.
  ///
  /// In en, this message translates to:
  /// **'Headache'**
  String get symptomHeadache;

  /// No description provided for @symptomBackPain.
  ///
  /// In en, this message translates to:
  /// **'Back pain'**
  String get symptomBackPain;

  /// No description provided for @symptomCategoryDigestive.
  ///
  /// In en, this message translates to:
  /// **'Digestive'**
  String get symptomCategoryDigestive;

  /// No description provided for @symptomBloating.
  ///
  /// In en, this message translates to:
  /// **'Bloating'**
  String get symptomBloating;

  /// No description provided for @symptomNausea.
  ///
  /// In en, this message translates to:
  /// **'Nausea'**
  String get symptomNausea;

  /// No description provided for @symptomCategoryBreastSkin.
  ///
  /// In en, this message translates to:
  /// **'Breast & skin'**
  String get symptomCategoryBreastSkin;

  /// No description provided for @symptomTenderBreasts.
  ///
  /// In en, this message translates to:
  /// **'Tender breasts'**
  String get symptomTenderBreasts;

  /// No description provided for @symptomAcne.
  ///
  /// In en, this message translates to:
  /// **'Acne'**
  String get symptomAcne;

  /// No description provided for @symptomCategoryEnergyMood.
  ///
  /// In en, this message translates to:
  /// **'Energy & mood'**
  String get symptomCategoryEnergyMood;

  /// No description provided for @symptomFatigue.
  ///
  /// In en, this message translates to:
  /// **'Fatigue'**
  String get symptomFatigue;

  /// No description provided for @remindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersTitle;

  /// No description provided for @remindersNew.
  ///
  /// In en, this message translates to:
  /// **'New reminder'**
  String get remindersNew;

  /// No description provided for @remindersYour.
  ///
  /// In en, this message translates to:
  /// **'Your reminders'**
  String get remindersYour;

  /// No description provided for @remindersNotificationsOff.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off'**
  String get remindersNotificationsOff;

  /// No description provided for @remindersNotificationsOffBody.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications so your reminders can be delivered.'**
  String get remindersNotificationsOffBody;

  /// No description provided for @remindersEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get remindersEnable;

  /// No description provided for @remindersHint.
  ///
  /// In en, this message translates to:
  /// **'Reminders are scheduled on your device and never leave it.'**
  String get remindersHint;

  /// No description provided for @remindersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No reminders yet'**
  String get remindersEmptyTitle;

  /// No description provided for @remindersEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Create one to get a gentle nudge at the right time.'**
  String get remindersEmptyBody;

  /// No description provided for @remindersEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get remindersEdit;

  /// No description provided for @remindersDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get remindersDelete;

  /// No description provided for @remindersBasedOnPrediction.
  ///
  /// In en, this message translates to:
  /// **'Based on your next predicted period ({date}).'**
  String remindersBasedOnPrediction(Object date);

  /// No description provided for @remindersFollowsPrediction.
  ///
  /// In en, this message translates to:
  /// **'Follows your predicted period dates.'**
  String get remindersFollowsPrediction;

  /// No description provided for @remindersEveryAt.
  ///
  /// In en, this message translates to:
  /// **'Every {days} at {time}'**
  String remindersEveryAt(Object days, Object time);

  /// No description provided for @reminderTypePeriodStart.
  ///
  /// In en, this message translates to:
  /// **'Period start'**
  String get reminderTypePeriodStart;

  /// No description provided for @reminderTypePeriodEnd.
  ///
  /// In en, this message translates to:
  /// **'Period end'**
  String get reminderTypePeriodEnd;

  /// No description provided for @reminderTypeMedication.
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get reminderTypeMedication;

  /// No description provided for @reminderTypeWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get reminderTypeWater;

  /// No description provided for @reminderTypeSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get reminderTypeSleep;

  /// No description provided for @reminderTypeCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get reminderTypeCustom;

  /// No description provided for @presetPeriodComingUp.
  ///
  /// In en, this message translates to:
  /// **'Period coming up'**
  String get presetPeriodComingUp;

  /// No description provided for @presetPeriodReminder.
  ///
  /// In en, this message translates to:
  /// **'Period reminder'**
  String get presetPeriodReminder;

  /// No description provided for @presetMedication.
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get presetMedication;

  /// No description provided for @presetWaterBreak.
  ///
  /// In en, this message translates to:
  /// **'Water break'**
  String get presetWaterBreak;

  /// No description provided for @presetWindDown.
  ///
  /// In en, this message translates to:
  /// **'Wind down'**
  String get presetWindDown;

  /// No description provided for @presetReminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get presetReminder;

  /// No description provided for @presetBodyPeriodComingUp.
  ///
  /// In en, this message translates to:
  /// **'Your period is expected to start soon.'**
  String get presetBodyPeriodComingUp;

  /// No description provided for @presetBodyPeriodReminder.
  ///
  /// In en, this message translates to:
  /// **'Your period may be wrapping up.'**
  String get presetBodyPeriodReminder;

  /// No description provided for @presetBodyMedication.
  ///
  /// In en, this message translates to:
  /// **'Take your medication now.'**
  String get presetBodyMedication;

  /// No description provided for @presetBodyWater.
  ///
  /// In en, this message translates to:
  /// **'Time for some water.'**
  String get presetBodyWater;

  /// No description provided for @presetBodySleep.
  ///
  /// In en, this message translates to:
  /// **'Start winding down for the night.'**
  String get presetBodySleep;

  /// No description provided for @presetBodyCustom.
  ///
  /// In en, this message translates to:
  /// **'You set this reminder.'**
  String get presetBodyCustom;

  /// No description provided for @weekdayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekdaySat;

  /// No description provided for @weekdaySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekdaySun;

  /// No description provided for @calendarWeekdayMon.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get calendarWeekdayMon;

  /// No description provided for @calendarWeekdayTue.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get calendarWeekdayTue;

  /// No description provided for @calendarWeekdayWed.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get calendarWeekdayWed;

  /// No description provided for @calendarWeekdayThu.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get calendarWeekdayThu;

  /// No description provided for @calendarWeekdayFri.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get calendarWeekdayFri;

  /// No description provided for @calendarWeekdaySat.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get calendarWeekdaySat;

  /// No description provided for @calendarWeekdaySun.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get calendarWeekdaySun;

  /// No description provided for @reminderEditorPickDay.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one day for this reminder.'**
  String get reminderEditorPickDay;

  /// No description provided for @reminderEditorDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminderEditorDefaultTitle;

  /// No description provided for @reminderEditorEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit reminder'**
  String get reminderEditorEdit;

  /// No description provided for @reminderEditorType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get reminderEditorType;

  /// No description provided for @reminderEditorTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get reminderEditorTitle;

  /// No description provided for @reminderEditorMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get reminderEditorMessage;

  /// No description provided for @reminderEditorTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get reminderEditorTime;

  /// No description provided for @reminderEditorFollowsPeriod.
  ///
  /// In en, this message translates to:
  /// **'This reminder follows your predicted period dates.'**
  String get reminderEditorFollowsPeriod;

  /// No description provided for @reminderEditorSave.
  ///
  /// In en, this message translates to:
  /// **'Save reminder'**
  String get reminderEditorSave;

  /// No description provided for @timeAm.
  ///
  /// In en, this message translates to:
  /// **'AM'**
  String get timeAm;

  /// No description provided for @timePm.
  ///
  /// In en, this message translates to:
  /// **'PM'**
  String get timePm;

  /// No description provided for @contentLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading magic…'**
  String get contentLoading;

  /// No description provided for @contentSearch.
  ///
  /// In en, this message translates to:
  /// **'Search articles and videos'**
  String get contentSearch;

  /// No description provided for @contentAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get contentAll;

  /// No description provided for @contentArticles.
  ///
  /// In en, this message translates to:
  /// **'Articles'**
  String get contentArticles;

  /// No description provided for @contentVideos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get contentVideos;

  /// No description provided for @contentArticle.
  ///
  /// In en, this message translates to:
  /// **'Article'**
  String get contentArticle;

  /// No description provided for @contentVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get contentVideo;

  /// No description provided for @contentRemoveFavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get contentRemoveFavorite;

  /// No description provided for @contentAddFavorite.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get contentAddFavorite;

  /// No description provided for @contentEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches your search.'**
  String get contentEmptyTitle;

  /// No description provided for @contentEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Try a different keyword or clear the filters.'**
  String get contentEmptyBody;

  /// No description provided for @contentArticleDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'These articles are for general education and are not medical advice. Talk to a healthcare professional about your health.'**
  String get contentArticleDisclaimer;

  /// No description provided for @contentVideoError.
  ///
  /// In en, this message translates to:
  /// **'Could not open this video.'**
  String get contentVideoError;

  /// No description provided for @contentWatch.
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get contentWatch;

  /// No description provided for @couplesTitle.
  ///
  /// In en, this message translates to:
  /// **'Couples mode'**
  String get couplesTitle;

  /// No description provided for @couplesYourLink.
  ///
  /// In en, this message translates to:
  /// **'Your link: {code}'**
  String couplesYourLink(Object code);

  /// No description provided for @couplesComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get couplesComingSoon;

  /// No description provided for @couplesBody.
  ///
  /// In en, this message translates to:
  /// **'Couples mode lets two partners share a private space for their cycle. Pairing needs a secure backend, which is still in development — nothing is shared yet, and your data stays on your device.'**
  String get couplesBody;

  /// No description provided for @couplesCreateLink.
  ///
  /// In en, this message translates to:
  /// **'Create my share link'**
  String get couplesCreateLink;

  /// No description provided for @couplesPlaceholderLink.
  ///
  /// In en, this message translates to:
  /// **'Your placeholder link'**
  String get couplesPlaceholderLink;

  /// No description provided for @couplesLocalOnly.
  ///
  /// In en, this message translates to:
  /// **'Local only — not sent anywhere.'**
  String get couplesLocalOnly;

  /// No description provided for @couplesCreated.
  ///
  /// In en, this message translates to:
  /// **'Created {date}'**
  String couplesCreated(Object date);

  /// No description provided for @relativeJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get relativeJustNow;

  /// No description provided for @relativeMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String relativeMinutes(int count);

  /// No description provided for @relativeHours.
  ///
  /// In en, this message translates to:
  /// **'{count} h ago'**
  String relativeHours(int count);

  /// No description provided for @relativeDays.
  ///
  /// In en, this message translates to:
  /// **'{count} d ago'**
  String relativeDays(int count);

  /// No description provided for @insightsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Log symptoms from the calendar to unlock personalized insights.'**
  String get insightsEmpty;

  /// No description provided for @insightsSummary.
  ///
  /// In en, this message translates to:
  /// **'Based on {count} logged {count, plural, one{day} other{days}} · {total} symptom entries.'**
  String insightsSummary(int count, int total);

  /// No description provided for @cycleHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Cycle history'**
  String get cycleHistoryTitle;

  /// No description provided for @monthlyReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly report'**
  String get monthlyReportTitle;

  /// No description provided for @insightsTopSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Top symptoms'**
  String get insightsTopSymptoms;

  /// No description provided for @insightsSymptomsOverTime.
  ///
  /// In en, this message translates to:
  /// **'Symptoms over time'**
  String get insightsSymptomsOverTime;

  /// No description provided for @insightsWhen.
  ///
  /// In en, this message translates to:
  /// **'When does \"{symptom}\" happen?'**
  String insightsWhen(Object symptom);

  /// No description provided for @trendRising.
  ///
  /// In en, this message translates to:
  /// **'Rising trend'**
  String get trendRising;

  /// No description provided for @trendFalling.
  ///
  /// In en, this message translates to:
  /// **'Falling trend'**
  String get trendFalling;

  /// No description provided for @trendConsistent.
  ///
  /// In en, this message translates to:
  /// **'Consistent'**
  String get trendConsistent;

  /// No description provided for @trendInsufficient.
  ///
  /// In en, this message translates to:
  /// **'Keep logging to spot a trend'**
  String get trendInsufficient;

  /// No description provided for @insightsTypicalDay.
  ///
  /// In en, this message translates to:
  /// **'Typical cycle day'**
  String get insightsTypicalDay;

  /// No description provided for @insightsNoPattern.
  ///
  /// In en, this message translates to:
  /// **'No pattern found yet — keep logging.'**
  String get insightsNoPattern;

  /// No description provided for @insightsAverage.
  ///
  /// In en, this message translates to:
  /// **'On average around day {average} of your cycle (range {first}–{last}).'**
  String insightsAverage(int average, int first, int last);

  /// No description provided for @insightsDay.
  ///
  /// In en, this message translates to:
  /// **'Day {index}'**
  String insightsDay(int index);

  /// No description provided for @cycleHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No cycles detected yet. Track a few period days and your history will appear here.'**
  String get cycleHistoryEmpty;

  /// No description provided for @cycleLengthTrendTitle.
  ///
  /// In en, this message translates to:
  /// **'Cycle length trend'**
  String get cycleLengthTrendTitle;

  /// No description provided for @nextPeriodPredicted.
  ///
  /// In en, this message translates to:
  /// **'Next period predicted'**
  String get nextPeriodPredicted;

  /// No description provided for @cycleHistoryCycles.
  ///
  /// In en, this message translates to:
  /// **'Cycles'**
  String get cycleHistoryCycles;

  /// No description provided for @cycleHistoryGlance.
  ///
  /// In en, this message translates to:
  /// **'Your cycle at a glance'**
  String get cycleHistoryGlance;

  /// No description provided for @metricAverageLength.
  ///
  /// In en, this message translates to:
  /// **'Average length'**
  String get metricAverageLength;

  /// No description provided for @metricCompletedCycles.
  ///
  /// In en, this message translates to:
  /// **'Completed cycles'**
  String get metricCompletedCycles;

  /// No description provided for @metricRange.
  ///
  /// In en, this message translates to:
  /// **'Range (short–long)'**
  String get metricRange;

  /// No description provided for @metricPredictionAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Prediction accuracy'**
  String get metricPredictionAccuracy;

  /// No description provided for @cycleCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current cycle'**
  String get cycleCurrent;

  /// No description provided for @cycleLengthDays.
  ///
  /// In en, this message translates to:
  /// **'{length} days'**
  String cycleLengthDays(int length);

  /// No description provided for @metricAccuracyDays.
  ///
  /// In en, this message translates to:
  /// **'±{days} days'**
  String metricAccuracyDays(int days);

  /// No description provided for @reportThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get reportThisMonth;

  /// No description provided for @reportPeriodDays.
  ///
  /// In en, this message translates to:
  /// **'Period days logged'**
  String get reportPeriodDays;

  /// No description provided for @reportDaysLogged.
  ///
  /// In en, this message translates to:
  /// **'Days logged'**
  String get reportDaysLogged;

  /// No description provided for @reportCycleMetrics.
  ///
  /// In en, this message translates to:
  /// **'Cycle metrics'**
  String get reportCycleMetrics;

  /// No description provided for @reportAverageCycleLength.
  ///
  /// In en, this message translates to:
  /// **'Average cycle length'**
  String get reportAverageCycleLength;

  /// No description provided for @reportMostLogged.
  ///
  /// In en, this message translates to:
  /// **'Most logged this month'**
  String get reportMostLogged;

  /// No description provided for @reportLogs.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get reportLogs;

  /// No description provided for @reportNoLogs.
  ///
  /// In en, this message translates to:
  /// **'No logs for this month yet.'**
  String get reportNoLogs;

  /// No description provided for @reportLocalOnly.
  ///
  /// In en, this message translates to:
  /// **'All reports are computed locally on your device. Nothing leaves it.'**
  String get reportLocalOnly;

  /// No description provided for @reportPredictionEmpty.
  ///
  /// In en, this message translates to:
  /// **'Log a couple of periods so we can predict your next one accurately.'**
  String get reportPredictionEmpty;

  /// No description provided for @reportPrediction.
  ///
  /// In en, this message translates to:
  /// **'Your next period is expected around {date}. Your fertile window runs {start}–{end}.'**
  String reportPrediction(Object date, Object start, Object end);

  /// No description provided for @perimenopauseSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Your summary'**
  String get perimenopauseSummaryTitle;

  /// No description provided for @perimenopauseEmpty.
  ///
  /// In en, this message translates to:
  /// **'No symptom logs yet in this stage.'**
  String get perimenopauseEmpty;

  /// No description provided for @perimenopauseLogToday.
  ///
  /// In en, this message translates to:
  /// **'Log today'**
  String get perimenopauseLogToday;

  /// No description provided for @perimenopauseLogTodayBody.
  ///
  /// In en, this message translates to:
  /// **'Tap a symptom to log it for today.'**
  String get perimenopauseLogTodayBody;

  /// No description provided for @perimenopauseLogged.
  ///
  /// In en, this message translates to:
  /// **'\"{symptom}\" logged for today.'**
  String perimenopauseLogged(Object symptom);

  /// No description provided for @periCatBodyTemp.
  ///
  /// In en, this message translates to:
  /// **'Body temperature'**
  String get periCatBodyTemp;

  /// No description provided for @periCatSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep & energy'**
  String get periCatSleep;

  /// No description provided for @periCatMood.
  ///
  /// In en, this message translates to:
  /// **'Mood & focus'**
  String get periCatMood;

  /// No description provided for @periCatCycle.
  ///
  /// In en, this message translates to:
  /// **'Cycle changes'**
  String get periCatCycle;

  /// No description provided for @periCatOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get periCatOther;

  /// No description provided for @periHotFlashes.
  ///
  /// In en, this message translates to:
  /// **'Hot flashes'**
  String get periHotFlashes;

  /// No description provided for @periNightSweats.
  ///
  /// In en, this message translates to:
  /// **'Night sweats'**
  String get periNightSweats;

  /// No description provided for @periChills.
  ///
  /// In en, this message translates to:
  /// **'Chills'**
  String get periChills;

  /// No description provided for @periTroubleSleeping.
  ///
  /// In en, this message translates to:
  /// **'Trouble sleeping'**
  String get periTroubleSleeping;

  /// No description provided for @periFatigue.
  ///
  /// In en, this message translates to:
  /// **'Fatigue'**
  String get periFatigue;

  /// No description provided for @periWakingNight.
  ///
  /// In en, this message translates to:
  /// **'Waking at night'**
  String get periWakingNight;

  /// No description provided for @periMoodSwings.
  ///
  /// In en, this message translates to:
  /// **'Mood swings'**
  String get periMoodSwings;

  /// No description provided for @periIrritability.
  ///
  /// In en, this message translates to:
  /// **'Irritability'**
  String get periIrritability;

  /// No description provided for @periBrainFog.
  ///
  /// In en, this message translates to:
  /// **'Brain fog'**
  String get periBrainFog;

  /// No description provided for @periAnxiety.
  ///
  /// In en, this message translates to:
  /// **'Anxiety'**
  String get periAnxiety;

  /// No description provided for @periIrregularPeriods.
  ///
  /// In en, this message translates to:
  /// **'Irregular periods'**
  String get periIrregularPeriods;

  /// No description provided for @periHeavierFlow.
  ///
  /// In en, this message translates to:
  /// **'Heavier flow'**
  String get periHeavierFlow;

  /// No description provided for @periLighterFlow.
  ///
  /// In en, this message translates to:
  /// **'Lighter flow'**
  String get periLighterFlow;

  /// No description provided for @periMissedPeriods.
  ///
  /// In en, this message translates to:
  /// **'Missed periods'**
  String get periMissedPeriods;

  /// No description provided for @periVaginalDryness.
  ///
  /// In en, this message translates to:
  /// **'Vaginal dryness'**
  String get periVaginalDryness;

  /// No description provided for @periJointPain.
  ///
  /// In en, this message translates to:
  /// **'Joint pain'**
  String get periJointPain;

  /// No description provided for @periHeadaches.
  ///
  /// In en, this message translates to:
  /// **'Headaches'**
  String get periHeadaches;

  /// No description provided for @periLowLibido.
  ///
  /// In en, this message translates to:
  /// **'Low libido'**
  String get periLowLibido;

  /// No description provided for @pregnancyTitle.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy'**
  String get pregnancyTitle;

  /// No description provided for @pregnancyPickerHelp.
  ///
  /// In en, this message translates to:
  /// **'First day of your last period'**
  String get pregnancyPickerHelp;

  /// No description provided for @pregnancySetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Set your last period date'**
  String get pregnancySetupTitle;

  /// No description provided for @pregnancySetupBody.
  ///
  /// In en, this message translates to:
  /// **'Weeks and due date are calculated from the first day of your last menstrual period.'**
  String get pregnancySetupBody;

  /// No description provided for @pregnancyChooseDate.
  ///
  /// In en, this message translates to:
  /// **'Choose date'**
  String get pregnancyChooseDate;

  /// No description provided for @pregnancyProgress.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of 40 weeks'**
  String pregnancyProgress(int percent);

  /// No description provided for @pregnancyThisStage.
  ///
  /// In en, this message translates to:
  /// **'This stage'**
  String get pregnancyThisStage;

  /// No description provided for @trimesterFirst.
  ///
  /// In en, this message translates to:
  /// **'First trimester'**
  String get trimesterFirst;

  /// No description provided for @trimesterSecond.
  ///
  /// In en, this message translates to:
  /// **'Second trimester'**
  String get trimesterSecond;

  /// No description provided for @trimesterThird.
  ///
  /// In en, this message translates to:
  /// **'Third trimester'**
  String get trimesterThird;

  /// No description provided for @stageSummaryFirst.
  ///
  /// In en, this message translates to:
  /// **'Major organs and systems are forming. Fatigue and nausea are common.'**
  String get stageSummaryFirst;

  /// No description provided for @stageSummarySecond.
  ///
  /// In en, this message translates to:
  /// **'Growth accelerates and many people feel a boost in energy. Baby movements often begin.'**
  String get stageSummarySecond;

  /// No description provided for @stageSummaryThird.
  ///
  /// In en, this message translates to:
  /// **'The baby grows rapidly and prepares for birth. Rest and planning ahead matter.'**
  String get stageSummaryThird;

  /// No description provided for @tipFirst1.
  ///
  /// In en, this message translates to:
  /// **'Take a folic acid supplement (400–800 mcg) if advised by a clinician.'**
  String get tipFirst1;

  /// No description provided for @tipFirst2.
  ///
  /// In en, this message translates to:
  /// **'Stay hydrated and eat small, frequent meals if nausea is an issue.'**
  String get tipFirst2;

  /// No description provided for @tipFirst3.
  ///
  /// In en, this message translates to:
  /// **'Avoid alcohol, tobacco and unpasteurised foods.'**
  String get tipFirst3;

  /// No description provided for @tipSecond1.
  ///
  /// In en, this message translates to:
  /// **'Keep up gentle, regular activity with clinician approval.'**
  String get tipSecond1;

  /// No description provided for @tipSecond2.
  ///
  /// In en, this message translates to:
  /// **'Monitor iron levels; iron needs rise as the baby grows.'**
  String get tipSecond2;

  /// No description provided for @tipSecond3.
  ///
  /// In en, this message translates to:
  /// **'Note when you first feel movements — tell your care team.'**
  String get tipSecond3;

  /// No description provided for @tipThird1.
  ///
  /// In en, this message translates to:
  /// **'Pack a hospital bag and plan transport ahead of the due date.'**
  String get tipThird1;

  /// No description provided for @tipThird2.
  ///
  /// In en, this message translates to:
  /// **'Sleep on your side and practise pelvic floor exercises.'**
  String get tipThird2;

  /// No description provided for @tipThird3.
  ///
  /// In en, this message translates to:
  /// **'Discuss a birth plan and pain-relief options with your care team.'**
  String get tipThird3;

  /// No description provided for @weekHeadlineEarly.
  ///
  /// In en, this message translates to:
  /// **'Early pregnancy — confirm care early.'**
  String get weekHeadlineEarly;

  /// No description provided for @weekHeadlineFirst.
  ///
  /// In en, this message translates to:
  /// **'First trimester — organs are forming.'**
  String get weekHeadlineFirst;

  /// No description provided for @weekHeadlineSecond.
  ///
  /// In en, this message translates to:
  /// **'Second trimester — growth and movement.'**
  String get weekHeadlineSecond;

  /// No description provided for @weekHeadlineThird.
  ///
  /// In en, this message translates to:
  /// **'Third trimester — preparing for birth.'**
  String get weekHeadlineThird;

  /// No description provided for @trackerPregnantHeadline.
  ///
  /// In en, this message translates to:
  /// **'You are {weeks} weeks and {days} days pregnant.'**
  String trackerPregnantHeadline(int weeks, int days);

  /// No description provided for @trackerDueLine.
  ///
  /// In en, this message translates to:
  /// **'Estimated due date: {date} ({days} days to go based on your dates).'**
  String trackerDueLine(Object date, int days);

  /// No description provided for @trackerStageLine.
  ///
  /// In en, this message translates to:
  /// **'You are in the {trimester} trimester.'**
  String trackerStageLine(Object trimester);

  /// No description provided for @trackerPeriEmpty.
  ///
  /// In en, this message translates to:
  /// **'Log symptoms to see which ones are most frequent for you.'**
  String get trackerPeriEmpty;

  /// No description provided for @trackerPeriSummary.
  ///
  /// In en, this message translates to:
  /// **'You have logged symptoms on {count, plural, one{1 day} other{{count} days}}. Your most frequent symptom is \"{top}\".'**
  String trackerPeriSummary(int count, Object top);

  /// No description provided for @trackerDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Witchy is educational and not a diagnostic tool, and is not a method of contraception. Always consult a qualified healthcare professional about your health.'**
  String get trackerDisclaimer;

  /// No description provided for @ordinalFirst.
  ///
  /// In en, this message translates to:
  /// **'first'**
  String get ordinalFirst;

  /// No description provided for @ordinalSecond.
  ///
  /// In en, this message translates to:
  /// **'second'**
  String get ordinalSecond;

  /// No description provided for @ordinalThird.
  ///
  /// In en, this message translates to:
  /// **'third'**
  String get ordinalThird;

  /// No description provided for @chartLengthEmpty.
  ///
  /// In en, this message translates to:
  /// **'Track a few full cycles to see your length trend here.'**
  String get chartLengthEmpty;

  /// No description provided for @chartAvg.
  ///
  /// In en, this message translates to:
  /// **'avg {value}d'**
  String chartAvg(Object value);

  /// No description provided for @chartDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String chartDays(int days);

  /// No description provided for @chartSymptomsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Log symptoms to see patterns here.'**
  String get chartSymptomsEmpty;

  /// No description provided for @chartFrequencyTooltip.
  ///
  /// In en, this message translates to:
  /// **'{count}× {symptom}'**
  String chartFrequencyTooltip(int count, Object symptom);

  /// No description provided for @chartPhaseEmpty.
  ///
  /// In en, this message translates to:
  /// **'No phase data yet for this symptom.'**
  String get chartPhaseEmpty;

  /// No description provided for @chartPhaseMenstrual.
  ///
  /// In en, this message translates to:
  /// **'Menstrual'**
  String get chartPhaseMenstrual;

  /// No description provided for @chartPhaseFollicular.
  ///
  /// In en, this message translates to:
  /// **'Follicular'**
  String get chartPhaseFollicular;

  /// No description provided for @chartPhaseOvulation.
  ///
  /// In en, this message translates to:
  /// **'Ovulation'**
  String get chartPhaseOvulation;

  /// No description provided for @chartPhaseLuteal.
  ///
  /// In en, this message translates to:
  /// **'Luteal'**
  String get chartPhaseLuteal;

  /// No description provided for @chartOverTimeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Symptom entries will appear here once you start logging.'**
  String get chartOverTimeEmpty;

  /// No description provided for @chartEntries.
  ///
  /// In en, this message translates to:
  /// **'{count} entries'**
  String chartEntries(int count);

  /// No description provided for @privacySec1Title.
  ///
  /// In en, this message translates to:
  /// **'Your data stays on your device'**
  String get privacySec1Title;

  /// No description provided for @privacySec1Body.
  ///
  /// In en, this message translates to:
  /// **'Witchy is a privacy-first period tracker. All of your logs — period dates, symptoms, moods, notes, and reminders — are stored locally on your device using on-device storage. Nothing is sent to our servers, and no account is required to use the app.'**
  String get privacySec1Body;

  /// No description provided for @privacySec2Title.
  ///
  /// In en, this message translates to:
  /// **'No tracking or analytics'**
  String get privacySec2Title;

  /// No description provided for @privacySec2Body.
  ///
  /// In en, this message translates to:
  /// **'Witchy does not include third-party analytics, advertising, or tracking SDKs. We have no way to see your cycle data, and neither does anyone else: your information never leaves your device.'**
  String get privacySec2Body;

  /// No description provided for @privacySec3Title.
  ///
  /// In en, this message translates to:
  /// **'Anonymous mode'**
  String get privacySec3Title;

  /// No description provided for @privacySec3Body.
  ///
  /// In en, this message translates to:
  /// **'When anonymous mode is enabled, the app clears any stored account identifier (your name and email) and no longer displays them. You can keep using Witchy without linking an identity.'**
  String get privacySec3Body;

  /// No description provided for @privacySec4Title.
  ///
  /// In en, this message translates to:
  /// **'How your data is used'**
  String get privacySec4Title;

  /// No description provided for @privacySec4Body.
  ///
  /// In en, this message translates to:
  /// **'Your logs power the predictions, insights, and reports you see in the app. They are used only to compute those results locally and are never shared with third parties.'**
  String get privacySec4Body;

  /// No description provided for @privacySec5Title.
  ///
  /// In en, this message translates to:
  /// **'Deleting your data'**
  String get privacySec5Title;

  /// No description provided for @privacySec5Body.
  ///
  /// In en, this message translates to:
  /// **'You can clear all data at any time by removing Witchy from your device or clearing the app data. Because everything is stored locally, deletion is immediate and permanent.'**
  String get privacySec5Body;

  /// No description provided for @privacySec6Title.
  ///
  /// In en, this message translates to:
  /// **'Not medical advice'**
  String get privacySec6Title;

  /// No description provided for @privacySec6Body.
  ///
  /// In en, this message translates to:
  /// **'Witchy provides educational information and estimates only. It is not a medical device and does not diagnose, treat, or prevent any condition. Always consult a qualified healthcare professional about your health.'**
  String get privacySec6Body;

  /// No description provided for @termsSec1Title.
  ///
  /// In en, this message translates to:
  /// **'Acceptance of terms'**
  String get termsSec1Title;

  /// No description provided for @termsSec1Body.
  ///
  /// In en, this message translates to:
  /// **'By using Witchy, you agree to these terms. If you do not agree, please do not use the app.'**
  String get termsSec1Body;

  /// No description provided for @termsSec2Title.
  ///
  /// In en, this message translates to:
  /// **'Use of the app'**
  String get termsSec2Title;

  /// No description provided for @termsSec2Body.
  ///
  /// In en, this message translates to:
  /// **'Witchy is provided for personal, non-commercial use to help you understand and track your reproductive health. You agree not to misuse the app or use it to harm others.'**
  String get termsSec2Body;

  /// No description provided for @termsSec3Title.
  ///
  /// In en, this message translates to:
  /// **'No medical guarantee'**
  String get termsSec3Title;

  /// No description provided for @termsSec3Body.
  ///
  /// In en, this message translates to:
  /// **'Witchy provides estimates and educational content that may not be accurate for your body. It is not a diagnostic or contraceptive tool. You are responsible for decisions you make based on the app.'**
  String get termsSec3Body;

  /// No description provided for @termsSec4Title.
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get termsSec4Title;

  /// No description provided for @termsSec4Body.
  ///
  /// In en, this message translates to:
  /// **'All data you enter is stored on your device. You are responsible for backing it up, and you may delete it at any time. We do not collect or process your personal data.'**
  String get termsSec4Body;

  /// No description provided for @termsSec5Title.
  ///
  /// In en, this message translates to:
  /// **'Changes to these terms'**
  String get termsSec5Title;

  /// No description provided for @termsSec5Body.
  ///
  /// In en, this message translates to:
  /// **'We may update these terms from time to time. Continued use of the app after changes are posted constitutes acceptance of the updated terms.'**
  String get termsSec5Body;

  /// No description provided for @termsSec6Title.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get termsSec6Title;

  /// No description provided for @termsSec6Body.
  ///
  /// In en, this message translates to:
  /// **'Questions about these terms or your privacy can be directed through the standard app support channels.'**
  String get termsSec6Body;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
