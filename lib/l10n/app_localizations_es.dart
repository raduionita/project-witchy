// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get privacy => 'Privacidad';

  @override
  String get anonymousMode => 'Modo anónimo';

  @override
  String get anonymousModeDescription => 'Oculta tu nombre y correo de los datos guardados en este dispositivo.';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get termsOfService => 'Términos del servicio';

  @override
  String get privacyPolicyTitle => 'Política de privacidad';

  @override
  String get termsOfServiceTitle => 'Términos del servicio';

  @override
  String get about => 'Acerca de';

  @override
  String get language => 'Idioma';

  @override
  String get systemDefault => 'Predeterminado del sistema';

  @override
  String get systemDefaultDescription => 'Sigue el idioma de tu dispositivo.';

  @override
  String get navHome => 'Inicio';

  @override
  String get navCalendar => 'Calendario';

  @override
  String get navLogging => 'Registro';

  @override
  String get navInsights => 'Análisis';

  @override
  String get navLibrary => 'Biblioteca';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get homeWelcomeTitle => 'Bienvenida a Witchy';

  @override
  String get homeSetupTitle => 'Configura tu ciclo';

  @override
  String get homeSetupBody => 'Completa la breve configuración para desbloquear predicciones personalizadas.';

  @override
  String get homeToday => 'Hoy';

  @override
  String homeCycleDay(int day) {
    return 'Día $day de tu ciclo';
  }

  @override
  String get homeNextPeriod => 'Próxima regla';

  @override
  String homeInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'En $count días',
      one: 'En 1 día',
    );
    return '$_temp0';
  }

  @override
  String get homeFertileWindow => 'Ventana fértil';

  @override
  String get phaseMenstruation => 'Menstruación';

  @override
  String get phaseFollicular => 'Fase folicular';

  @override
  String get phaseOvulation => 'Ovulación';

  @override
  String get phaseLuteal => 'Fase lútea';

  @override
  String settingsModeActive(Object mode) {
    return '$mode está ahora activo.';
  }

  @override
  String settingsComingSoon(Object feature) {
    return '$feature llegará pronto.';
  }

  @override
  String get settingsAnonymousOn => 'El modo anónimo ahora está activado.';

  @override
  String get settingsAnonymousOff => 'El modo anónimo ahora está desactivado.';

  @override
  String get settingsPrivacySubtitle => 'Cómo se protegen tus datos.';

  @override
  String get settingsTermsSubtitle => 'Reglas para usar Witchy.';

  @override
  String get settingsAboutSubtitle => 'Versión de Witchy e información legal.';

  @override
  String get settingsTrackingModeTitle => 'Modo de seguimiento';

  @override
  String get settingsTrackingModeSubtitle => 'Elige en qué se enfoca Witchy.';

  @override
  String get settingsLogsShared => 'Los registros se comparten';

  @override
  String get settingsLogsSharedSubtitle => 'Tus registros de síntomas y regla permanecen contigo en todos los modos.';

  @override
  String get settingsRemindersTitle => 'Recordatorios';

  @override
  String get settingsRemindersSubtitle => 'Regla, medicación, agua y sueño.';

  @override
  String get settingsCouplesTitle => 'Modo pareja';

  @override
  String get settingsCouplesSubtitle => 'Comparte un espacio privado (próximamente).';

  @override
  String get settingsLanguageSubtitle => 'Elige cómo te lee Witchy.';

  @override
  String get settingsThemeTitle => 'Tema';

  @override
  String get settingsThemeSubtitle => 'Elige cómo se ve Witchy.';

  @override
  String get settingsSignOut => 'Cerrar sesión';

  @override
  String get settingsAccountTitle => 'Cuenta';

  @override
  String get settingsAccountSubtitle => 'Inicia sesión para activar funciones opcionales. Tus datos permanecen en tu dispositivo.';

  @override
  String get themeDefaultLight => 'Claro (por defecto)';

  @override
  String get trackingModeCycle => 'Seguimiento del ciclo';

  @override
  String get trackingModePregnancy => 'Embarazo';

  @override
  String get trackingModePerimenopause => 'Perimenopausia';

  @override
  String get trackingModeCycleDesc => 'Regla, fertilidad y predicciones del ciclo.';

  @override
  String get trackingModePregnancyDesc => 'Seguimiento de semanas, trimestre y fecha prevista.';

  @override
  String get trackingModePerimenopauseDesc => 'Seguimiento centrado en síntomas para esta etapa.';

  @override
  String get authSignedIn => 'Sesión iniciada. Tu cuenta permanece en este dispositivo.';

  @override
  String get authSignInOptional => 'Iniciar sesión (opcional)';

  @override
  String get authBody => 'Witchy nunca necesita una cuenta. Iniciar sesión te da una identidad constante para funciones como el modo pareja: todo permanece en tu dispositivo.';

  @override
  String get authGoogleSignIn => 'Iniciar sesión con Google';

  @override
  String get authAppleSignIn => 'Iniciar sesión con Apple';

  @override
  String get authAnonymousDebug => 'Iniciar sesión anónima (debug)';

  @override
  String get authProviderGoogle => 'Google';

  @override
  String get authProviderApple => 'Apple';

  @override
  String get authProviderAnonymous => 'Anónimo';

  @override
  String get onboardingBack => 'Atrás';

  @override
  String get onboardingFinish => 'Finalizar';

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get onboardingWelcomeBody => 'Vamos a configurar tu ciclo para mostrar predicciones precisas.';

  @override
  String get onboardingDisclaimer => 'Witchy es educativo y no es una herramienta de diagnóstico ni un método anticonceptivo.';

  @override
  String get onboardingLastPeriod => 'Inicio de la última regla';

  @override
  String get onboardingCycleLength => '¿Cuál es tu duración promedio del ciclo?';

  @override
  String get onboardingPeriodLength => '¿Cuánto dura tu regla?';

  @override
  String get onboardingDaysSuffix => ' días';

  @override
  String get onboardingAccountTitle => 'Crear una cuenta (opcional)';

  @override
  String get onboardingAccountBody => 'Witchy funciona perfectamente sin una cuenta. Iniciar sesión más adelante activa funciones opcionales: todo permanece en tu dispositivo.';

  @override
  String get onboardingSkip => 'Omitir por ahora';

  @override
  String get loggingUseCalendar => 'Usa la pestaña Calendario para elegir un día.';

  @override
  String get loggingLogPeriod => 'Registrar regla';

  @override
  String get loggingLogPeriodSubtitle => 'Flujo, síntomas, ánimo y notas';

  @override
  String get loggingLogFromCalendar => 'Registrar desde el calendario';

  @override
  String get loggingLogFromCalendarSubtitle => 'Elige un día para registrar o editar';

  @override
  String get loggingRecentLogs => 'Registros recientes';

  @override
  String get loggingEmpty => 'Aún no hay registros. Toca \"Registrar regla\" para empezar.';

  @override
  String get logFlowIntensity => 'Intensidad del flujo';

  @override
  String get logSymptoms => 'Síntomas';

  @override
  String get logMood => 'Ánimo';

  @override
  String get logNotes => 'Notas (opcional)';

  @override
  String get logSave => 'Guardar registro';

  @override
  String logPeriodTitle(Object date) {
    return 'Registrar $date';
  }

  @override
  String logSymptomTitle(Object date) {
    return 'Síntomas · $date';
  }

  @override
  String get flowLight => 'Ligero';

  @override
  String get flowMedium => 'Moderado';

  @override
  String get flowHeavy => 'Abundante';

  @override
  String get moodHappy => 'Feliz';

  @override
  String get moodCalm => 'Tranquila';

  @override
  String get moodAnxious => 'Ansiosa';

  @override
  String get moodIrritable => 'Irritable';

  @override
  String get moodSad => 'Triste';

  @override
  String get moodEnergetic => 'Enérgica';

  @override
  String get symptomCategoryPain => 'Dolor y molestias';

  @override
  String get symptomCramps => 'Calambres';

  @override
  String get symptomHeadache => 'Dolor de cabeza';

  @override
  String get symptomBackPain => 'Dolor de espalda';

  @override
  String get symptomCategoryDigestive => 'Digestivo';

  @override
  String get symptomBloating => 'Hinchazón';

  @override
  String get symptomNausea => 'Náuseas';

  @override
  String get symptomCategoryBreastSkin => 'Pecho y piel';

  @override
  String get symptomTenderBreasts => 'Pechos sensibles';

  @override
  String get symptomAcne => 'Acné';

  @override
  String get symptomCategoryEnergyMood => 'Energía y ánimo';

  @override
  String get symptomFatigue => 'Fatiga';

  @override
  String get remindersTitle => 'Recordatorios';

  @override
  String get remindersNew => 'Nuevo recordatorio';

  @override
  String get remindersYour => 'Tus recordatorios';

  @override
  String get remindersNotificationsOff => 'Las notificaciones están desactivadas';

  @override
  String get remindersNotificationsOffBody => 'Activa las notificaciones para que se puedan enviar tus recordatorios.';

  @override
  String get remindersEnable => 'Activar notificaciones';

  @override
  String get remindersHint => 'Los recordatorios se programan en tu dispositivo y nunca lo abandonan.';

  @override
  String get remindersEmptyTitle => 'Aún no hay recordatorios';

  @override
  String get remindersEmptyBody => 'Crea uno para recibir un aviso suave en el momento adecuado.';

  @override
  String get remindersEdit => 'Editar';

  @override
  String get remindersDelete => 'Eliminar';

  @override
  String remindersBasedOnPrediction(Object date) {
    return 'Basado en tu próxima regla prevista ($date).';
  }

  @override
  String get remindersFollowsPrediction => 'Sigue las fechas previstas de tu regla.';

  @override
  String remindersEveryAt(Object days, Object time) {
    return 'Cada $days a las $time';
  }

  @override
  String get reminderTypePeriodStart => 'Inicio de la regla';

  @override
  String get reminderTypePeriodEnd => 'Fin de la regla';

  @override
  String get reminderTypeMedication => 'Medicación';

  @override
  String get reminderTypeWater => 'Agua';

  @override
  String get reminderTypeSleep => 'Sueño';

  @override
  String get reminderTypeCustom => 'Personalizado';

  @override
  String get presetPeriodComingUp => 'Regla próxima';

  @override
  String get presetPeriodReminder => 'Recordatorio de regla';

  @override
  String get presetMedication => 'Medicación';

  @override
  String get presetWaterBreak => 'Pausa para el agua';

  @override
  String get presetWindDown => 'Relajarse';

  @override
  String get presetReminder => 'Recordatorio';

  @override
  String get presetBodyPeriodComingUp => 'Se espera que tu regla comience pronto.';

  @override
  String get presetBodyPeriodReminder => 'Tu regla puede estar terminando.';

  @override
  String get presetBodyMedication => 'Toma tu medicación ahora.';

  @override
  String get presetBodyWater => 'Hora de beber un poco de agua.';

  @override
  String get presetBodySleep => 'Empieza a relajarte para la noche.';

  @override
  String get presetBodyCustom => 'Tú configuraste este recordatorio.';

  @override
  String get weekdayMon => 'Lun';

  @override
  String get weekdayTue => 'Mar';

  @override
  String get weekdayWed => 'Mié';

  @override
  String get weekdayThu => 'Jue';

  @override
  String get weekdayFri => 'Vie';

  @override
  String get weekdaySat => 'Sáb';

  @override
  String get weekdaySun => 'Dom';

  @override
  String get calendarWeekdayMon => 'L';

  @override
  String get calendarWeekdayTue => 'M';

  @override
  String get calendarWeekdayWed => 'X';

  @override
  String get calendarWeekdayThu => 'J';

  @override
  String get calendarWeekdayFri => 'V';

  @override
  String get calendarWeekdaySat => 'S';

  @override
  String get calendarWeekdaySun => 'D';

  @override
  String get reminderEditorPickDay => 'Elige al menos un día para este recordatorio.';

  @override
  String get reminderEditorDefaultTitle => 'Recordatorio';

  @override
  String get reminderEditorEdit => 'Editar recordatorio';

  @override
  String get reminderEditorType => 'Tipo';

  @override
  String get reminderEditorTitle => 'Título';

  @override
  String get reminderEditorMessage => 'Mensaje';

  @override
  String get reminderEditorTime => 'Hora';

  @override
  String get reminderEditorFollowsPeriod => 'Este recordatorio sigue las fechas previstas de tu regla.';

  @override
  String get reminderEditorSave => 'Guardar recordatorio';

  @override
  String get timeAm => 'a. m.';

  @override
  String get timePm => 'p. m.';

  @override
  String get contentLoading => 'Cargando biblioteca…';

  @override
  String get contentSearch => 'Buscar artículos y videos';

  @override
  String get contentAll => 'Todo';

  @override
  String get contentArticles => 'Artículos';

  @override
  String get contentVideos => 'Videos';

  @override
  String get contentArticle => 'Artículo';

  @override
  String get contentVideo => 'Video';

  @override
  String get contentRemoveFavorite => 'Quitar de favoritos';

  @override
  String get contentAddFavorite => 'Añadir a favoritos';

  @override
  String get contentEmptyTitle => 'Nada coincide con tu búsqueda.';

  @override
  String get contentEmptyBody => 'Prueba con otra palabra clave o limpia los filtros.';

  @override
  String get contentArticleDisclaimer => 'Estos artículos son para educación general y no constituyen consejo médico. Habla con un profesional de la salud sobre tu bienestar.';

  @override
  String get contentVideoError => 'No se pudo abrir este video.';

  @override
  String get contentWatch => 'Ver';

  @override
  String get couplesTitle => 'Modo pareja';

  @override
  String couplesYourLink(Object code) {
    return 'Tu enlace: $code';
  }

  @override
  String get couplesComingSoon => 'Próximamente';

  @override
  String get couplesBody => 'El modo pareja permite que dos personas compartan un espacio privado para su ciclo. La vinculación necesita un backend seguro que aún está en desarrollo: nada se comparte todavía y tus datos permanecen en tu dispositivo.';

  @override
  String get couplesCreateLink => 'Crear mi enlace de compartir';

  @override
  String get couplesPlaceholderLink => 'Tu enlace provisional';

  @override
  String get couplesLocalOnly => 'Solo local: no se envía a ningún sitio.';

  @override
  String couplesCreated(Object date) {
    return 'Creado $date';
  }

  @override
  String get relativeJustNow => 'ahora mismo';

  @override
  String relativeMinutes(int count) {
    return 'hace $count min';
  }

  @override
  String relativeHours(int count) {
    return 'hace $count h';
  }

  @override
  String relativeDays(int count) {
    return 'hace $count d';
  }

  @override
  String get insightsEmpty => 'Registra síntomas desde el calendario para desbloquear análisis personalizados.';

  @override
  String insightsSummary(int count, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'días registrados',
      one: 'día registrado',
    );
    return 'Basado en $count $_temp0 · $total entradas de síntomas.';
  }

  @override
  String get cycleHistoryTitle => 'Historial del ciclo';

  @override
  String get monthlyReportTitle => 'Informe mensual';

  @override
  String get insightsTopSymptoms => 'Síntomas principales';

  @override
  String get insightsSymptomsOverTime => 'Síntomas a lo largo del tiempo';

  @override
  String insightsWhen(Object symptom) {
    return '¿Cuándo ocurre \"$symptom\"?';
  }

  @override
  String get trendRising => 'Tendencia al alza';

  @override
  String get trendFalling => 'Tendencia a la baja';

  @override
  String get trendConsistent => 'Constante';

  @override
  String get trendInsufficient => 'Sigue registrando para detectar una tendencia';

  @override
  String get insightsTypicalDay => 'Día típico del ciclo';

  @override
  String get insightsNoPattern => 'Aún no se encuentra un patrón: sigue registrando.';

  @override
  String insightsAverage(int average, int first, int last) {
    return 'En promedio, alrededor del día $average de tu ciclo (rango $first–$last).';
  }

  @override
  String insightsDay(int index) {
    return 'Día $index';
  }

  @override
  String get cycleHistoryEmpty => 'Aún no se detectan ciclos. Registra algunos días de regla y aquí aparecerá tu historial.';

  @override
  String get cycleLengthTrendTitle => 'Tendencia de la duración del ciclo';

  @override
  String get nextPeriodPredicted => 'Próxima regla prevista';

  @override
  String get cycleHistoryCycles => 'Ciclos';

  @override
  String get cycleHistoryGlance => 'Tu ciclo de un vistazo';

  @override
  String get metricAverageLength => 'Duración promedio';

  @override
  String get metricCompletedCycles => 'Ciclos completados';

  @override
  String get metricRange => 'Rango (corto–largo)';

  @override
  String get metricPredictionAccuracy => 'Precisión de la predicción';

  @override
  String get cycleCurrent => 'Ciclo actual';

  @override
  String cycleLengthDays(int length) {
    return '$length días';
  }

  @override
  String metricAccuracyDays(int days) {
    return '±$days días';
  }

  @override
  String get reportThisMonth => 'Este mes';

  @override
  String get reportPeriodDays => 'Días de regla registrados';

  @override
  String get reportDaysLogged => 'Días registrados';

  @override
  String get reportCycleMetrics => 'Métricas del ciclo';

  @override
  String get reportAverageCycleLength => 'Duración promedio del ciclo';

  @override
  String get reportMostLogged => 'Lo más registrado este mes';

  @override
  String get reportLogs => 'Registros';

  @override
  String get reportNoLogs => 'Aún no hay registros este mes.';

  @override
  String get reportLocalOnly => 'Todos los informes se calculan localmente en tu dispositivo. Nada los abandona.';

  @override
  String get reportPredictionEmpty => 'Registra un par de reglas para poder predecir la próxima con precisión.';

  @override
  String reportPrediction(Object date, Object start, Object end) {
    return 'Se espera tu próxima regla alrededor del $date. Tu ventana fértil va del $start al $end.';
  }

  @override
  String get perimenopauseSummaryTitle => 'Tu resumen';

  @override
  String get perimenopauseEmpty => 'Aún no hay registros de síntomas en esta etapa.';

  @override
  String get perimenopauseLogToday => 'Registrar hoy';

  @override
  String get perimenopauseLogTodayBody => 'Toca un síntoma para registrarlo hoy.';

  @override
  String perimenopauseLogged(Object symptom) {
    return '\"$symptom\" registrado para hoy.';
  }

  @override
  String get periCatBodyTemp => 'Temperatura corporal';

  @override
  String get periCatSleep => 'Sueño y energía';

  @override
  String get periCatMood => 'Ánimo y concentración';

  @override
  String get periCatCycle => 'Cambios en el ciclo';

  @override
  String get periCatOther => 'Otros';

  @override
  String get periHotFlashes => 'Sofocos';

  @override
  String get periNightSweats => 'Sudores nocturnos';

  @override
  String get periChills => 'Escalofríos';

  @override
  String get periTroubleSleeping => 'Problemas para dormir';

  @override
  String get periFatigue => 'Fatiga';

  @override
  String get periWakingNight => 'Despertarse por la noche';

  @override
  String get periMoodSwings => 'Cambios de ánimo';

  @override
  String get periIrritability => 'Irritabilidad';

  @override
  String get periBrainFog => 'Niebla mental';

  @override
  String get periAnxiety => 'Ansiedad';

  @override
  String get periIrregularPeriods => 'Reglas irregulares';

  @override
  String get periHeavierFlow => 'Flujo más abundante';

  @override
  String get periLighterFlow => 'Flujo más ligero';

  @override
  String get periMissedPeriods => 'Reglas perdidas';

  @override
  String get periVaginalDryness => 'Sequedad vaginal';

  @override
  String get periJointPain => 'Dolor articular';

  @override
  String get periHeadaches => 'Dolores de cabeza';

  @override
  String get periLowLibido => 'Poca libido';

  @override
  String get pregnancyTitle => 'Embarazo';

  @override
  String get pregnancyPickerHelp => 'Primer día de tu última regla';

  @override
  String get pregnancySetupTitle => 'Define la fecha de tu última regla';

  @override
  String get pregnancySetupBody => 'Las semanas y la fecha prevista se calculan desde el primer día de tu última regla.';

  @override
  String get pregnancyChooseDate => 'Elegir fecha';

  @override
  String pregnancyProgress(int percent) {
    return '$percent% de 40 semanas';
  }

  @override
  String get pregnancyThisStage => 'Esta etapa';

  @override
  String get trimesterFirst => 'Primer trimestre';

  @override
  String get trimesterSecond => 'Segundo trimestre';

  @override
  String get trimesterThird => 'Tercer trimestre';

  @override
  String get stageSummaryFirst => 'Se están formando los órganos y sistemas principales. Son comunes la fatiga y las náuseas.';

  @override
  String get stageSummarySecond => 'El crecimiento se acelera y muchas personas sienten un aumento de energía. A menudo comienzan los movimientos del bebé.';

  @override
  String get stageSummaryThird => 'El bebé crece rápidamente y se prepara para el nacimiento. Importan el descanso y planificar con antelación.';

  @override
  String get tipFirst1 => 'Toma un suplemento de ácido fólico (400–800 mcg) si un profesional lo recomienda.';

  @override
  String get tipFirst2 => 'Mantente hidratada y come porciones pequeñas y frecuentes si las náuseas son un problema.';

  @override
  String get tipFirst3 => 'Evita el alcohol, el tabaco y los alimentos sin pasteurizar.';

  @override
  String get tipSecond1 => 'Mantén una actividad suave y regular con la aprobación de tu profesional de la salud.';

  @override
  String get tipSecond2 => 'Vigila tus niveles de hierro; las necesidades aumentan a medida que el bebé crece.';

  @override
  String get tipSecond3 => 'Anota la primera vez que sientas movimientos: avísale a tu equipo de cuidado.';

  @override
  String get tipThird1 => 'Prepara la maleta del hospital y planifica el transporte antes de la fecha prevista.';

  @override
  String get tipThird2 => 'Duerme de lado y practica ejercicios de suelo pélvico.';

  @override
  String get tipThird3 => 'Conversa un plan de parto y las opciones de alivio del dolor con tu equipo de cuidado.';

  @override
  String get weekHeadlineEarly => 'Embarazo temprano: confirma tu cuidado temprano.';

  @override
  String get weekHeadlineFirst => 'Primer trimestre: se están formando los órganos.';

  @override
  String get weekHeadlineSecond => 'Segundo trimestre: crecimiento y movimiento.';

  @override
  String get weekHeadlineThird => 'Tercer trimestre: preparación para el nacimiento.';

  @override
  String trackerPregnantHeadline(int weeks, int days) {
    return 'Tienes $weeks semanas y $days días de embarazo.';
  }

  @override
  String trackerDueLine(Object date, int days) {
    return 'Fecha prevista de parto: $date (faltan $days días según tus fechas).';
  }

  @override
  String trackerStageLine(Object trimester) {
    return 'Estás en el $trimester trimestre.';
  }

  @override
  String get trackerPeriEmpty => 'Registra síntomas para ver cuáles son los más frecuentes para ti.';

  @override
  String trackerPeriSummary(int count, Object top) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return 'Has registrado síntomas en $_temp0. Tu síntoma más frecuente es \"$top\".';
  }

  @override
  String get trackerDisclaimer => 'Witchy es educativo y no es una herramienta de diagnóstico ni un método anticonceptivo. Consulta siempre a un profesional de la salud cualificado sobre tu bienestar.';

  @override
  String get ordinalFirst => 'primer';

  @override
  String get ordinalSecond => 'segundo';

  @override
  String get ordinalThird => 'tercer';

  @override
  String get chartLengthEmpty => 'Registra algunos ciclos completos para ver aquí tu tendencia de duración.';

  @override
  String chartAvg(Object value) {
    return 'prom ${value}d';
  }

  @override
  String chartDays(int days) {
    return '$days días';
  }

  @override
  String get chartSymptomsEmpty => 'Registra síntomas para ver patrones aquí.';

  @override
  String chartFrequencyTooltip(int count, Object symptom) {
    return '$count× $symptom';
  }

  @override
  String get chartPhaseEmpty => 'Aún no hay datos de fase para este síntoma.';

  @override
  String get chartPhaseMenstrual => 'Menstrual';

  @override
  String get chartPhaseFollicular => 'Folicular';

  @override
  String get chartPhaseOvulation => 'Ovulación';

  @override
  String get chartPhaseLuteal => 'Lútea';

  @override
  String get chartOverTimeEmpty => 'Las entradas de síntomas aparecerán aquí cuando empieces a registrar.';

  @override
  String chartEntries(int count) {
    return '$count entradas';
  }

  @override
  String get privacySec1Title => 'Tus datos permanecen en tu dispositivo';

  @override
  String get privacySec1Body => 'Witchy es un registrador de regla centrado en la privacidad. Todos tus registros — fechas de regla, síntomas, ánimos, notas y recordatorios — se guardan localmente en tu dispositivo mediante almacenamiento en el dispositivo. Nada se envía a nuestros servidores y no se requiere una cuenta para usar la app.';

  @override
  String get privacySec2Title => 'Sin rastreo ni analíticas';

  @override
  String get privacySec2Body => 'Witchy no incluye analíticas de terceros, publicidad ni SDK de rastreo. No tenemos forma de ver tus datos del ciclo, y tampoco nadie más: tu información nunca abandona tu dispositivo.';

  @override
  String get privacySec3Title => 'Modo anónimo';

  @override
  String get privacySec3Body => 'Cuando el modo anónimo está activado, la app borra cualquier identificador de cuenta guardado (tu nombre y correo) y deja de mostrarlos. Puedes seguir usando Witchy sin vincular una identidad.';

  @override
  String get privacySec4Title => 'Cómo se usan tus datos';

  @override
  String get privacySec4Body => 'Tus registros alimentan las predicciones, análisis e informes que ves en la app. Solo se usan para calcular esos resultados localmente y nunca se comparten con terceros.';

  @override
  String get privacySec5Title => 'Eliminar tus datos';

  @override
  String get privacySec5Body => 'Puedes borrar todos los datos en cualquier momento eliminando Witchy de tu dispositivo o borrando los datos de la app. Como todo se guarda localmente, la eliminación es inmediata y permanente.';

  @override
  String get privacySec6Title => 'No es consejo médico';

  @override
  String get privacySec6Body => 'Witchy ofrece solo información educativa y estimaciones. No es un dispositivo médico ni diagnostica, trata o previene ninguna afección. Consulta siempre a un profesional de la salud cualificado sobre tu bienestar.';

  @override
  String get termsSec1Title => 'Aceptación de los términos';

  @override
  String get termsSec1Body => 'Al usar Witchy aceptas estos términos. Si no estás de acuerdo, no uses la app.';

  @override
  String get termsSec2Title => 'Uso de la app';

  @override
  String get termsSec2Body => 'Witchy se ofrece para un uso personal y no comercial con el fin de ayudarte a comprender y seguir tu salud reproductiva. Aceptas no hacer un mal uso de la app ni usarla para dañar a otros.';

  @override
  String get termsSec3Title => 'Sin garantía médica';

  @override
  String get termsSec3Body => 'Witchy ofrece estimaciones y contenido educativo que pueden no ser precisos para tu cuerpo. No es una herramienta de diagnóstico ni anticonceptiva. Eres responsable de las decisiones que tomes basándote en la app.';

  @override
  String get termsSec4Title => 'Tus datos';

  @override
  String get termsSec4Body => 'Todos los datos que ingresas se guardan en tu dispositivo. Eres responsable de respaldarlos y puedes eliminarlos en cualquier momento. No recopilamos ni procesamos tus datos personales.';

  @override
  String get termsSec5Title => 'Cambios en estos términos';

  @override
  String get termsSec5Body => 'Podemos actualizar estos términos de vez en cuando. El uso continuado de la app después de publicar los cambios constituye la aceptación de los términos actualizados.';

  @override
  String get termsSec6Title => 'Contacto';

  @override
  String get termsSec6Body => 'Las preguntas sobre estos términos o tu privacidad pueden dirigirse a través de los canales estándar de soporte de la app.';
}
