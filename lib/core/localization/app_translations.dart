class AppStrings {
  /// Simple translation selector
  static String tr(bool isSinhala, {required String en, required String si}) {
    return isSinhala ? si : en;
  }

  // Navigation
  static String navHome(bool isSi) => isSi ? 'මුල් පිටුව' : 'Home';
  static String navSounds(bool isSi) => isSi ? 'ශබ්ද' : 'Sounds';
  static String navHydration(bool isSi) => isSi ? 'ජලය' : 'Hydration';
  static String navSettings(bool isSi) => isSi ? 'සැකසුම්' : 'Settings';

  // Voice Assistant
  static String voiceTitle(bool isSi) => isSi ? 'හඬ සහායක' : 'Voice Assistant';
  static String voiceSubtitle(bool isSi) =>
      isSi ? 'ඔබට අවශ්‍ය දේ කතා කර කියන්න' : 'Speak to log water or play sounds';
  static String voiceListening(bool isSi) =>
      isSi ? 'අසමින් පවතී... දැන් කතා කරන්න' : 'Listening... Speak now';
  static String voiceTapToSpeak(bool isSi) =>
      isSi ? 'මයික්‍රෆෝනය ඔබා කතා කරන්න' : 'Tap microphone to speak';
  static String voiceProcessing(bool isSi) =>
      isSi ? 'විධානය සකසමින් පවතී...' : 'Processing command...';
  static String voiceSpeakExample(bool isSi) =>
      isSi ? '"වතුර 250ml බිව්වා" හෝ "වැසි නාදය" කියන්න' : 'Say e.g. "Log 250ml water" or "Play rain"';
  static String voiceChooseBelow(bool isSi) =>
      isSi ? 'හෝ පහත ඉක්මන් විධානයක් තෝරන්න' : 'Or choose a quick prompt below';
  static String voiceQuickPrompts(bool isSi) =>
      isSi ? 'ඉක්මන් හඬ විධාන' : 'QUICK VOICE PROMPTS';
  static String voiceTypeHint(bool isSi) =>
      isSi ? 'විධානයක් ටයිප් කරන්න හෝ කතා කරන්න...' : 'Type or speak a custom command...';
  static String voiceHeaderButton(bool isSi) => isSi ? 'හඬ' : 'Voice';
  static String voiceCardTitle(bool isSi) =>
      isSi ? 'හඬ සහායක' : 'Voice Assistant';
  static String voiceCardSubtitle(bool isSi) =>
      isSi ? 'ටැප් කර කතා කරන්න: "වතුර 250ml බිව්වා" හෝ "වැසි නාදය"' : 'Tap to speak: "Log 250ml water" or "Play rain"';

  // Home Screen
  static String greetingMorning(bool isSi) => isSi ? 'සුබ උදෑසනක්' : 'Good Morning';
  static String greetingAfternoon(bool isSi) => isSi ? 'සුබ දහවලක්' : 'Good Afternoon';
  static String greetingEvening(bool isSi) => isSi ? 'සුබ සැන්දෑවක්' : 'Good Evening';
  static String greetingNight(bool isSi) => isSi ? 'සුබ රාත්‍රියක්' : 'Good Night';
  static String homeSubtitle(bool isSi) =>
      isSi ? 'ඔබේ සුව නින්ද සහ ජල ප්‍රමාණයේ සගයා' : 'Your hydration & restful sleep companion';
  static String lastPlayed(bool isSi) => isSi ? 'අවසන් වරට වාදනය වූ' : 'LAST PLAYED';
  static String autoOff(bool isSi) => isSi ? 'ස්වයංක්‍රීයව නතර වේ' : 'Auto-off';
  static String dailyHydration(bool isSi) => isSi ? 'දෛනික ජල ප්‍රමාණය' : 'DAILY HYDRATION';
  static String ofTarget(bool isSi) => isSi ? 'න්' : 'of';
  static String logWater(bool isSi) => isSi ? 'වතුර එකතු කරන්න' : 'Log Water';
  static String browseSoundscapes(bool isSi) =>
      isSi ? 'සියලු ශබ්ද ගවේෂණය' : 'Browse All Soundscapes';

  // Settings Screen
  static String settingsTitle(bool isSi) => isSi ? 'සැකසුම්' : 'Settings';
  static String languageSection(bool isSi) => isSi ? 'භාෂාව' : 'Language';
  static String languageSelectTitle(bool isSi) =>
      isSi ? 'යෙදුමේ භාෂාව තෝරන්න' : 'App Language';
  static String english(bool isSi) => isSi ? 'English (ඉංග්‍රීසි)' : 'English';
  static String sinhala(bool isSi) => isSi ? 'සිංහල (Sinhala)' : 'සිංහල (Sinhala)';
  static String appearanceSection(bool isSi) =>
      isSi ? 'පෙනුම සහ තේමාව' : 'Appearance & Bedtime Theme';
  static String bedtimeDarkMode(bool isSi) =>
      isSi ? 'අඳුරු තේමාව (Dark Mode)' : 'Bedtime Dark Mode';
  static String textSize(bool isSi) => isSi ? 'අකුරු ප්‍රමාණය' : 'Text Size';
  static String profileSection(bool isSi) => isSi ? 'ගිණුම' : 'Profile';
  static String accountDetails(bool isSi) => isSi ? 'ගිණුමේ විස්තර' : 'Account Details';
  static String personalInfo(bool isSi) => isSi ? 'පුද්ගලික තොරතුරු' : 'Personal Information';
  static String notificationsSection(bool isSi) => isSi ? 'දැනුම්දීම්' : 'Notifications';
  static String hydrationReminders(bool isSi) => isSi ? 'ජල සිහිකැඳවීම්' : 'Hydration Reminders';
  static String quietHours(bool isSi) => isSi ? 'නිහඬ වේලාවන්' : 'Quiet Hours';
  static String caregiverSection(bool isSi) => isSi ? 'භාරකරු සම්බන්ධතාවය' : 'Caregiver Connection';
  static String enableCaregiverSharing(bool isSi) => isSi ? 'හවුල් කිරීම සක්‍රිය කරන්න' : 'Enable Sharing';
  static String manageCaregivers(bool isSi) => isSi ? 'භාරකරුවන් කළමනාකරණය' : 'Manage Caregivers';
  static String signOut(bool isSi) => isSi ? 'පිටවීම' : 'Sign Out';
}
