// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settingsTitle => 'Settings';

  @override
  String get privacy => 'Privacy';

  @override
  String get anonymousMode => 'Anonymous mode';

  @override
  String get anonymousModeDescription => 'Hides your name and email from stored data on this device.';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get termsOfServiceTitle => 'Terms of Service';

  @override
  String get about => 'About';

  @override
  String get language => 'Language';

  @override
  String get systemDefault => 'System default';

  @override
  String get systemDefaultDescription => 'Follows your device\'s language.';

  @override
  String get navHome => 'Home';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navLogging => 'Logging';

  @override
  String get navInsights => 'Insights';

  @override
  String get navMagic => 'Magic';

  @override
  String get navSettings => 'Settings';

  @override
  String get navAccount => 'Account';

  @override
  String get homeWelcomeTitle => 'Welcome to Witchy';

  @override
  String get homeSetupTitle => 'Set up your cycle';

  @override
  String get homeSetupBody => 'Complete the short onboarding to unlock personalized predictions.';

  @override
  String get homeToday => 'Today';

  @override
  String homeCycleDay(int day) {
    return 'Day $day of your cycle';
  }

  @override
  String get homeNextPeriod => 'Next period';

  @override
  String homeInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'In $count days',
      one: 'In 1 day',
    );
    return '$_temp0';
  }

  @override
  String get homeFertileWindow => 'Fertile window';

  @override
  String get phaseMenstruation => 'Menstruation';

  @override
  String get phaseFollicular => 'Follicular phase';

  @override
  String get phaseOvulation => 'Ovulation';

  @override
  String get phaseLuteal => 'Luteal phase';

  @override
  String settingsModeActive(Object mode) {
    return '$mode is now active.';
  }

  @override
  String settingsComingSoon(Object feature) {
    return '$feature is coming soon.';
  }

  @override
  String get settingsAnonymousOn => 'Anonymous mode is now on.';

  @override
  String get settingsAnonymousOff => 'Anonymous mode is now off.';

  @override
  String get settingsPrivacySubtitle => 'How your data is protected.';

  @override
  String get settingsTermsSubtitle => 'Rules for using Witchy.';

  @override
  String get settingsAboutSubtitle => 'Witchy version and legal info.';

  @override
  String get settingsTrackingModeTitle => 'Tracking mode';

  @override
  String get settingsTrackingModeSubtitle => 'Choose what Witchy focuses on.';

  @override
  String get settingsLogsShared => 'Logs are shared';

  @override
  String get settingsLogsSharedSubtitle => 'Your symptom and period logs stay with you across modes.';

  @override
  String get settingsRemindersTitle => 'Reminders';

  @override
  String get settingsRemindersSubtitle => 'Period, medication, water and sleep.';

  @override
  String get settingsCouplesTitle => 'Couples mode';

  @override
  String get settingsCouplesSubtitle => 'Share a private space (coming soon).';

  @override
  String get settingsLanguageSubtitle => 'Choose how Witchy reads to you.';

  @override
  String get settingsThemeTitle => 'Theme';

  @override
  String get settingsThemeSubtitle => 'Choose how Witchy looks.';

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String get settingsClearData => 'Clear all data';

  @override
  String get settingsClearDataSubtitle => 'Erase every cycle, log, reminder and setting from this device.';

  @override
  String get settingsClearDataConfirmTitle => 'Erase all data?';

  @override
  String get settingsClearDataConfirmBody => 'This permanently deletes your profile, period and symptom logs, reminders and settings from this device. This cannot be undone.';

  @override
  String get settingsClearDataAction => 'Clear';

  @override
  String get cancel => 'Cancel';

  @override
  String get settingsAccountTitle => 'Account';

  @override
  String get settingsAccountSubtitle => 'Sign in to enable optional features. Your data stays on your device.';

  @override
  String get themeDefaultLight => 'Default (light)';

  @override
  String get trackingModeCycle => 'Cycle tracking';

  @override
  String get trackingModePregnancy => 'Pregnancy';

  @override
  String get trackingModePerimenopause => 'Perimenopause';

  @override
  String get trackingModeCycleDesc => 'Periods, fertility and cycle predictions.';

  @override
  String get trackingModePregnancyDesc => 'Track weeks, trimester and due date.';

  @override
  String get trackingModePerimenopauseDesc => 'Symptom-focused tracking for this stage.';

  @override
  String get authSignedIn => 'Signed in. Your account stays on this device.';

  @override
  String get authSignInOptional => 'Sign in (optional)';

  @override
  String get authBody => 'Witchy never needs an account. Signing in gives you a consistent identity for features like Couples mode — everything stays on your device.';

  @override
  String get authGoogleSignIn => 'Google Sign In';

  @override
  String get authAppleSignIn => 'Apple Sign In';

  @override
  String get authAnonymous => 'Anonymous';

  @override
  String get authProviderGoogle => 'Google';

  @override
  String get authProviderApple => 'Apple';

  @override
  String get authProviderAnonymous => 'Anonymous';

  @override
  String get onboardingBack => 'Back';

  @override
  String get onboardingFinish => 'Finish';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingWelcomeBody => 'Let\'\'s set up your cycle so we can show accurate predictions.';

  @override
  String get onboardingDisclaimer => 'Witchy is educational and not a diagnostic tool, and is not a method of contraception.';

  @override
  String get onboardingLastPeriod => 'Last period start';

  @override
  String get onboardingCycleLength => 'What is your average cycle length?';

  @override
  String get onboardingPeriodLength => 'How long does your period last?';

  @override
  String get onboardingDaysSuffix => ' days';

  @override
  String get onboardingAccountTitle => 'Create an account (optional)';

  @override
  String get onboardingAccountBody => 'Witchy works perfectly without an account. Signing in later enables optional features — everything stays on your device.';

  @override
  String get onboardingSkip => 'Skip for now';

  @override
  String get loggingUseCalendar => 'Use the Calendar tab to pick a day.';

  @override
  String get loggingLogPeriod => 'Log period';

  @override
  String get loggingLogPeriodSubtitle => 'Flow, symptoms, mood and notes';

  @override
  String get loggingLogFromCalendar => 'Log from calendar';

  @override
  String get loggingLogFromCalendarSubtitle => 'Pick a day to log or edit';

  @override
  String get loggingRecentLogs => 'Recent logs';

  @override
  String get loggingEmpty => 'No logs yet. Tap \"Log period\" to get started.';

  @override
  String get logFlowIntensity => 'Flow intensity';

  @override
  String get logSymptoms => 'Symptoms';

  @override
  String get logMood => 'Mood';

  @override
  String get logNotes => 'Notes (optional)';

  @override
  String get logSave => 'Save log';

  @override
  String logPeriodTitle(Object date) {
    return 'Log $date';
  }

  @override
  String logSymptomTitle(Object date) {
    return 'Symptoms · $date';
  }

  @override
  String get flowLight => 'Light';

  @override
  String get flowMedium => 'Medium';

  @override
  String get flowHeavy => 'Heavy';

  @override
  String get moodHappy => 'Happy';

  @override
  String get moodCalm => 'Calm';

  @override
  String get moodAnxious => 'Anxious';

  @override
  String get moodIrritable => 'Irritable';

  @override
  String get moodSad => 'Sad';

  @override
  String get moodEnergetic => 'Energetic';

  @override
  String get symptomCategoryPain => 'Pain & discomfort';

  @override
  String get symptomCramps => 'Cramps';

  @override
  String get symptomHeadache => 'Headache';

  @override
  String get symptomBackPain => 'Back pain';

  @override
  String get symptomCategoryDigestive => 'Digestive';

  @override
  String get symptomBloating => 'Bloating';

  @override
  String get symptomNausea => 'Nausea';

  @override
  String get symptomCategoryBreastSkin => 'Breast & skin';

  @override
  String get symptomTenderBreasts => 'Tender breasts';

  @override
  String get symptomAcne => 'Acne';

  @override
  String get symptomCategoryEnergyMood => 'Energy & mood';

  @override
  String get symptomFatigue => 'Fatigue';

  @override
  String get remindersTitle => 'Reminders';

  @override
  String get remindersNew => 'New reminder';

  @override
  String get remindersYour => 'Your reminders';

  @override
  String get remindersNotificationsOff => 'Notifications are off';

  @override
  String get remindersNotificationsOffBody => 'Enable notifications so your reminders can be delivered.';

  @override
  String get remindersEnable => 'Enable notifications';

  @override
  String get remindersHint => 'Reminders are scheduled on your device and never leave it.';

  @override
  String get remindersEmptyTitle => 'No reminders yet';

  @override
  String get remindersEmptyBody => 'Create one to get a gentle nudge at the right time.';

  @override
  String get remindersEdit => 'Edit';

  @override
  String get remindersDelete => 'Delete';

  @override
  String remindersBasedOnPrediction(Object date) {
    return 'Based on your next predicted period ($date).';
  }

  @override
  String get remindersFollowsPrediction => 'Follows your predicted period dates.';

  @override
  String remindersEveryAt(Object days, Object time) {
    return 'Every $days at $time';
  }

  @override
  String get reminderTypePeriodStart => 'Period start';

  @override
  String get reminderTypePeriodEnd => 'Period end';

  @override
  String get reminderTypeMedication => 'Medication';

  @override
  String get reminderTypeWater => 'Water';

  @override
  String get reminderTypeSleep => 'Sleep';

  @override
  String get reminderTypeCustom => 'Custom';

  @override
  String get presetPeriodComingUp => 'Period coming up';

  @override
  String get presetPeriodReminder => 'Period reminder';

  @override
  String get presetMedication => 'Medication';

  @override
  String get presetWaterBreak => 'Water break';

  @override
  String get presetWindDown => 'Wind down';

  @override
  String get presetReminder => 'Reminder';

  @override
  String get presetBodyPeriodComingUp => 'Your period is expected to start soon.';

  @override
  String get presetBodyPeriodReminder => 'Your period may be wrapping up.';

  @override
  String get presetBodyMedication => 'Take your medication now.';

  @override
  String get presetBodyWater => 'Time for some water.';

  @override
  String get presetBodySleep => 'Start winding down for the night.';

  @override
  String get presetBodyCustom => 'You set this reminder.';

  @override
  String get weekdayMon => 'Mon';

  @override
  String get weekdayTue => 'Tue';

  @override
  String get weekdayWed => 'Wed';

  @override
  String get weekdayThu => 'Thu';

  @override
  String get weekdayFri => 'Fri';

  @override
  String get weekdaySat => 'Sat';

  @override
  String get weekdaySun => 'Sun';

  @override
  String get calendarWeekdayMon => 'M';

  @override
  String get calendarWeekdayTue => 'T';

  @override
  String get calendarWeekdayWed => 'W';

  @override
  String get calendarWeekdayThu => 'T';

  @override
  String get calendarWeekdayFri => 'F';

  @override
  String get calendarWeekdaySat => 'S';

  @override
  String get calendarWeekdaySun => 'S';

  @override
  String get reminderEditorPickDay => 'Pick at least one day for this reminder.';

  @override
  String get reminderEditorDefaultTitle => 'Reminder';

  @override
  String get reminderEditorEdit => 'Edit reminder';

  @override
  String get reminderEditorType => 'Type';

  @override
  String get reminderEditorTitle => 'Title';

  @override
  String get reminderEditorMessage => 'Message';

  @override
  String get reminderEditorTime => 'Time';

  @override
  String get reminderEditorFollowsPeriod => 'This reminder follows your predicted period dates.';

  @override
  String get reminderEditorSave => 'Save reminder';

  @override
  String get timeAm => 'AM';

  @override
  String get timePm => 'PM';

  @override
  String get contentLoading => 'Loading magic…';

  @override
  String get contentSearch => 'Search articles and videos';

  @override
  String get contentAll => 'All';

  @override
  String get contentArticles => 'Articles';

  @override
  String get contentVideos => 'Videos';

  @override
  String get contentArticle => 'Article';

  @override
  String get contentVideo => 'Video';

  @override
  String get contentRemoveFavorite => 'Remove from favorites';

  @override
  String get contentAddFavorite => 'Add to favorites';

  @override
  String get contentEmptyTitle => 'Nothing matches your search.';

  @override
  String get contentEmptyBody => 'Try a different keyword or clear the filters.';

  @override
  String get contentArticleDisclaimer => 'These articles are for general education and are not medical advice. Talk to a healthcare professional about your health.';

  @override
  String get contentVideoError => 'Could not open this video.';

  @override
  String get contentWatch => 'Watch';

  @override
  String get couplesTitle => 'Couples mode';

  @override
  String couplesYourLink(Object code) {
    return 'Your link: $code';
  }

  @override
  String get couplesComingSoon => 'Coming soon';

  @override
  String get couplesBody => 'Couples mode lets two partners share a private space for their cycle. Pairing needs a secure backend, which is still in development — nothing is shared yet, and your data stays on your device.';

  @override
  String get couplesCreateLink => 'Create my share link';

  @override
  String get couplesPlaceholderLink => 'Your placeholder link';

  @override
  String get couplesLocalOnly => 'Local only — not sent anywhere.';

  @override
  String couplesCreated(Object date) {
    return 'Created $date';
  }

  @override
  String get relativeJustNow => 'just now';

  @override
  String relativeMinutes(int count) {
    return '$count min ago';
  }

  @override
  String relativeHours(int count) {
    return '$count h ago';
  }

  @override
  String relativeDays(int count) {
    return '$count d ago';
  }

  @override
  String get insightsEmpty => 'Log symptoms from the calendar to unlock personalized insights.';

  @override
  String insightsSummary(int count, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'days',
      one: 'day',
    );
    return 'Based on $count logged $_temp0 · $total symptom entries.';
  }

  @override
  String get cycleHistoryTitle => 'Cycle history';

  @override
  String get monthlyReportTitle => 'Monthly report';

  @override
  String get insightsTopSymptoms => 'Top symptoms';

  @override
  String get insightsSymptomsOverTime => 'Symptoms over time';

  @override
  String insightsWhen(Object symptom) {
    return 'When does \"$symptom\" happen?';
  }

  @override
  String get trendRising => 'Rising trend';

  @override
  String get trendFalling => 'Falling trend';

  @override
  String get trendConsistent => 'Consistent';

  @override
  String get trendInsufficient => 'Keep logging to spot a trend';

  @override
  String get insightsTypicalDay => 'Typical cycle day';

  @override
  String get insightsNoPattern => 'No pattern found yet — keep logging.';

  @override
  String insightsAverage(int average, int first, int last) {
    return 'On average around day $average of your cycle (range $first–$last).';
  }

  @override
  String insightsDay(int index) {
    return 'Day $index';
  }

  @override
  String get cycleHistoryEmpty => 'No cycles detected yet. Track a few period days and your history will appear here.';

  @override
  String get cycleLengthTrendTitle => 'Cycle length trend';

  @override
  String get nextPeriodPredicted => 'Next period predicted';

  @override
  String get cycleHistoryCycles => 'Cycles';

  @override
  String get cycleHistoryGlance => 'Your cycle at a glance';

  @override
  String get metricAverageLength => 'Average length';

  @override
  String get metricCompletedCycles => 'Completed cycles';

  @override
  String get metricRange => 'Range (short–long)';

  @override
  String get metricPredictionAccuracy => 'Prediction accuracy';

  @override
  String get cycleCurrent => 'Current cycle';

  @override
  String cycleLengthDays(int length) {
    return '$length days';
  }

  @override
  String metricAccuracyDays(int days) {
    return '±$days days';
  }

  @override
  String get reportThisMonth => 'This month';

  @override
  String get reportPeriodDays => 'Period days logged';

  @override
  String get reportDaysLogged => 'Days logged';

  @override
  String get reportCycleMetrics => 'Cycle metrics';

  @override
  String get reportAverageCycleLength => 'Average cycle length';

  @override
  String get reportMostLogged => 'Most logged this month';

  @override
  String get reportLogs => 'Logs';

  @override
  String get reportNoLogs => 'No logs for this month yet.';

  @override
  String get reportLocalOnly => 'All reports are computed locally on your device. Nothing leaves it.';

  @override
  String get reportPredictionEmpty => 'Log a couple of periods so we can predict your next one accurately.';

  @override
  String reportPrediction(Object date, Object start, Object end) {
    return 'Your next period is expected around $date. Your fertile window runs $start–$end.';
  }

  @override
  String get perimenopauseSummaryTitle => 'Your summary';

  @override
  String get perimenopauseEmpty => 'No symptom logs yet in this stage.';

  @override
  String get perimenopauseLogToday => 'Log today';

  @override
  String get perimenopauseLogTodayBody => 'Tap a symptom to log it for today.';

  @override
  String perimenopauseLogged(Object symptom) {
    return '\"$symptom\" logged for today.';
  }

  @override
  String get periCatBodyTemp => 'Body temperature';

  @override
  String get periCatSleep => 'Sleep & energy';

  @override
  String get periCatMood => 'Mood & focus';

  @override
  String get periCatCycle => 'Cycle changes';

  @override
  String get periCatOther => 'Other';

  @override
  String get periHotFlashes => 'Hot flashes';

  @override
  String get periNightSweats => 'Night sweats';

  @override
  String get periChills => 'Chills';

  @override
  String get periTroubleSleeping => 'Trouble sleeping';

  @override
  String get periFatigue => 'Fatigue';

  @override
  String get periWakingNight => 'Waking at night';

  @override
  String get periMoodSwings => 'Mood swings';

  @override
  String get periIrritability => 'Irritability';

  @override
  String get periBrainFog => 'Brain fog';

  @override
  String get periAnxiety => 'Anxiety';

  @override
  String get periIrregularPeriods => 'Irregular periods';

  @override
  String get periHeavierFlow => 'Heavier flow';

  @override
  String get periLighterFlow => 'Lighter flow';

  @override
  String get periMissedPeriods => 'Missed periods';

  @override
  String get periVaginalDryness => 'Vaginal dryness';

  @override
  String get periJointPain => 'Joint pain';

  @override
  String get periHeadaches => 'Headaches';

  @override
  String get periLowLibido => 'Low libido';

  @override
  String get pregnancyTitle => 'Pregnancy';

  @override
  String get pregnancyPickerHelp => 'First day of your last period';

  @override
  String get pregnancySetupTitle => 'Set your last period date';

  @override
  String get pregnancySetupBody => 'Weeks and due date are calculated from the first day of your last menstrual period.';

  @override
  String get pregnancyChooseDate => 'Choose date';

  @override
  String pregnancyProgress(int percent) {
    return '$percent% of 40 weeks';
  }

  @override
  String get pregnancyThisStage => 'This stage';

  @override
  String get trimesterFirst => 'First trimester';

  @override
  String get trimesterSecond => 'Second trimester';

  @override
  String get trimesterThird => 'Third trimester';

  @override
  String get stageSummaryFirst => 'Major organs and systems are forming. Fatigue and nausea are common.';

  @override
  String get stageSummarySecond => 'Growth accelerates and many people feel a boost in energy. Baby movements often begin.';

  @override
  String get stageSummaryThird => 'The baby grows rapidly and prepares for birth. Rest and planning ahead matter.';

  @override
  String get tipFirst1 => 'Take a folic acid supplement (400–800 mcg) if advised by a clinician.';

  @override
  String get tipFirst2 => 'Stay hydrated and eat small, frequent meals if nausea is an issue.';

  @override
  String get tipFirst3 => 'Avoid alcohol, tobacco and unpasteurised foods.';

  @override
  String get tipSecond1 => 'Keep up gentle, regular activity with clinician approval.';

  @override
  String get tipSecond2 => 'Monitor iron levels; iron needs rise as the baby grows.';

  @override
  String get tipSecond3 => 'Note when you first feel movements — tell your care team.';

  @override
  String get tipThird1 => 'Pack a hospital bag and plan transport ahead of the due date.';

  @override
  String get tipThird2 => 'Sleep on your side and practise pelvic floor exercises.';

  @override
  String get tipThird3 => 'Discuss a birth plan and pain-relief options with your care team.';

  @override
  String get weekHeadlineEarly => 'Early pregnancy — confirm care early.';

  @override
  String get weekHeadlineFirst => 'First trimester — organs are forming.';

  @override
  String get weekHeadlineSecond => 'Second trimester — growth and movement.';

  @override
  String get weekHeadlineThird => 'Third trimester — preparing for birth.';

  @override
  String trackerPregnantHeadline(int weeks, int days) {
    return 'You are $weeks weeks and $days days pregnant.';
  }

  @override
  String trackerDueLine(Object date, int days) {
    return 'Estimated due date: $date ($days days to go based on your dates).';
  }

  @override
  String trackerStageLine(Object trimester) {
    return 'You are in the $trimester trimester.';
  }

  @override
  String get trackerPeriEmpty => 'Log symptoms to see which ones are most frequent for you.';

  @override
  String trackerPeriSummary(int count, Object top) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return 'You have logged symptoms on $_temp0. Your most frequent symptom is \"$top\".';
  }

  @override
  String get trackerDisclaimer => 'Witchy is educational and not a diagnostic tool, and is not a method of contraception. Always consult a qualified healthcare professional about your health.';

  @override
  String get ordinalFirst => 'first';

  @override
  String get ordinalSecond => 'second';

  @override
  String get ordinalThird => 'third';

  @override
  String get chartLengthEmpty => 'Track a few full cycles to see your length trend here.';

  @override
  String chartAvg(Object value) {
    return 'avg ${value}d';
  }

  @override
  String chartDays(int days) {
    return '$days days';
  }

  @override
  String get chartSymptomsEmpty => 'Log symptoms to see patterns here.';

  @override
  String chartFrequencyTooltip(int count, Object symptom) {
    return '$count× $symptom';
  }

  @override
  String get chartPhaseEmpty => 'No phase data yet for this symptom.';

  @override
  String get chartPhaseMenstrual => 'Menstrual';

  @override
  String get chartPhaseFollicular => 'Follicular';

  @override
  String get chartPhaseOvulation => 'Ovulation';

  @override
  String get chartPhaseLuteal => 'Luteal';

  @override
  String get chartOverTimeEmpty => 'Symptom entries will appear here once you start logging.';

  @override
  String chartEntries(int count) {
    return '$count entries';
  }

  @override
  String get privacySec1Title => 'Your data stays on your device';

  @override
  String get privacySec1Body => 'Witchy is a privacy-first period tracker. All of your logs — period dates, symptoms, moods, notes, and reminders — are stored locally on your device using on-device storage. Nothing is sent to our servers, and no account is required to use the app.';

  @override
  String get privacySec2Title => 'No tracking or analytics';

  @override
  String get privacySec2Body => 'Witchy does not include third-party analytics, advertising, or tracking SDKs. We have no way to see your cycle data, and neither does anyone else: your information never leaves your device.';

  @override
  String get privacySec3Title => 'Anonymous mode';

  @override
  String get privacySec3Body => 'When anonymous mode is enabled, the app clears any stored account identifier (your name and email) and no longer displays them. You can keep using Witchy without linking an identity.';

  @override
  String get privacySec4Title => 'How your data is used';

  @override
  String get privacySec4Body => 'Your logs power the predictions, insights, and reports you see in the app. They are used only to compute those results locally and are never shared with third parties.';

  @override
  String get privacySec5Title => 'Deleting your data';

  @override
  String get privacySec5Body => 'You can clear all data at any time by removing Witchy from your device or clearing the app data. Because everything is stored locally, deletion is immediate and permanent.';

  @override
  String get privacySec6Title => 'Not medical advice';

  @override
  String get privacySec6Body => 'Witchy provides educational information and estimates only. It is not a medical device and does not diagnose, treat, or prevent any condition. Always consult a qualified healthcare professional about your health.';

  @override
  String get termsSec1Title => 'Acceptance of terms';

  @override
  String get termsSec1Body => 'By using Witchy, you agree to these terms. If you do not agree, please do not use the app.';

  @override
  String get termsSec2Title => 'Use of the app';

  @override
  String get termsSec2Body => 'Witchy is provided for personal, non-commercial use to help you understand and track your reproductive health. You agree not to misuse the app or use it to harm others.';

  @override
  String get termsSec3Title => 'No medical guarantee';

  @override
  String get termsSec3Body => 'Witchy provides estimates and educational content that may not be accurate for your body. It is not a diagnostic or contraceptive tool. You are responsible for decisions you make based on the app.';

  @override
  String get termsSec4Title => 'Your data';

  @override
  String get termsSec4Body => 'All data you enter is stored on your device. You are responsible for backing it up, and you may delete it at any time. We do not collect or process your personal data.';

  @override
  String get termsSec5Title => 'Changes to these terms';

  @override
  String get termsSec5Body => 'We may update these terms from time to time. Continued use of the app after changes are posted constitutes acceptance of the updated terms.';

  @override
  String get termsSec6Title => 'Contact';

  @override
  String get termsSec6Body => 'Questions about these terms or your privacy can be directed through the standard app support channels.';
}
