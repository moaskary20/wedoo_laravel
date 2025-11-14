import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_fr.dart';

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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('fr'),
  ];

  /// The application title
  ///
  /// In ar, this message translates to:
  /// **'Wedoo'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get home;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @myOrders.
  ///
  /// In ar, this message translates to:
  /// **'طلباتي'**
  String get myOrders;

  /// No description provided for @appExplanation.
  ///
  /// In ar, this message translates to:
  /// **'شرح التطبيق'**
  String get appExplanation;

  /// No description provided for @changeLanguage.
  ///
  /// In ar, this message translates to:
  /// **'تغيير اللغة'**
  String get changeLanguage;

  /// No description provided for @selectLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اختر اللغة'**
  String get selectLanguage;

  /// No description provided for @arabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @french.
  ///
  /// In ar, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @editProfile.
  ///
  /// In ar, this message translates to:
  /// **'تعديل بياناتي'**
  String get editProfile;

  /// No description provided for @notifications.
  ///
  /// In ar, this message translates to:
  /// **'الاشعارات'**
  String get notifications;

  /// No description provided for @conversations.
  ///
  /// In ar, this message translates to:
  /// **'المحادثات'**
  String get conversations;

  /// No description provided for @promoCode.
  ///
  /// In ar, this message translates to:
  /// **'البرومو كود'**
  String get promoCode;

  /// No description provided for @termsOfUse.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الإستخدام'**
  String get termsOfUse;

  /// No description provided for @shareApp.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة التطبيق'**
  String get shareApp;

  /// No description provided for @contactUs.
  ///
  /// In ar, this message translates to:
  /// **'اتصل بنا'**
  String get contactUs;

  /// No description provided for @deleteAccount.
  ///
  /// In ar, this message translates to:
  /// **'حذف الحساب'**
  String get deleteAccount;

  /// No description provided for @logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من أنك تريد تسجيل الخروج؟'**
  String get logoutConfirm;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @logoutSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل الخروج بنجاح'**
  String get logoutSuccess;

  /// No description provided for @logoutError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء تسجيل الخروج'**
  String get logoutError;

  /// No description provided for @loading.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل...'**
  String get loading;

  /// No description provided for @membershipCode.
  ///
  /// In ar, this message translates to:
  /// **'كود العضوية'**
  String get membershipCode;

  /// No description provided for @followUs.
  ///
  /// In ar, this message translates to:
  /// **'تابعنا على'**
  String get followUs;

  /// No description provided for @help.
  ///
  /// In ar, this message translates to:
  /// **'مساعدة'**
  String get help;

  /// No description provided for @handymanWedoo.
  ///
  /// In ar, this message translates to:
  /// **'صنايعي وي دو'**
  String get handymanWedoo;

  /// No description provided for @shopsExhibitions.
  ///
  /// In ar, this message translates to:
  /// **'محلات و بوتيكات'**
  String get shopsExhibitions;

  /// No description provided for @phoneNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get phoneNumber;

  /// No description provided for @password.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get password;

  /// No description provided for @login.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get login;

  /// No description provided for @register.
  ///
  /// In ar, this message translates to:
  /// **'التسجيل'**
  String get register;

  /// No description provided for @forgotPassword.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get forgotPassword;

  /// No description provided for @location.
  ///
  /// In ar, this message translates to:
  /// **'الموقع'**
  String get location;

  /// No description provided for @selectLocation.
  ///
  /// In ar, this message translates to:
  /// **'اختيار الموقع'**
  String get selectLocation;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @submit.
  ///
  /// In ar, this message translates to:
  /// **'إرسال'**
  String get submit;

  /// No description provided for @back.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get back;

  /// No description provided for @next.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In ar, this message translates to:
  /// **'السابق'**
  String get previous;

  /// No description provided for @urgent.
  ///
  /// In ar, this message translates to:
  /// **'عاجل'**
  String get urgent;

  /// No description provided for @normal.
  ///
  /// In ar, this message translates to:
  /// **'عادي'**
  String get normal;

  /// No description provided for @notUrgent.
  ///
  /// In ar, this message translates to:
  /// **'غير عاجل'**
  String get notUrgent;

  /// No description provided for @taskDescription.
  ///
  /// In ar, this message translates to:
  /// **'وصف المهمة'**
  String get taskDescription;

  /// No description provided for @budget.
  ///
  /// In ar, this message translates to:
  /// **'الميزانية'**
  String get budget;

  /// No description provided for @selectImages.
  ///
  /// In ar, this message translates to:
  /// **'اختر الصور'**
  String get selectImages;

  /// No description provided for @user.
  ///
  /// In ar, this message translates to:
  /// **'مستخدم'**
  String get user;

  /// No description provided for @languageChanged.
  ///
  /// In ar, this message translates to:
  /// **'تم تغيير اللغة إلى {language}'**
  String languageChanged(String language);

  /// No description provided for @selectServiceType.
  ///
  /// In ar, this message translates to:
  /// **'اختر نوع الخدمة'**
  String get selectServiceType;

  /// No description provided for @craftsman.
  ///
  /// In ar, this message translates to:
  /// **'صنايعي'**
  String get craftsman;

  /// No description provided for @shop.
  ///
  /// In ar, this message translates to:
  /// **'محل'**
  String get shop;

  /// No description provided for @createServiceRequest.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء طلب خدمة'**
  String get createServiceRequest;

  /// No description provided for @createRequest.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء طلب'**
  String get createRequest;

  /// No description provided for @taskType.
  ///
  /// In ar, this message translates to:
  /// **'نوع المهمة'**
  String get taskType;

  /// No description provided for @selectTaskType.
  ///
  /// In ar, this message translates to:
  /// **'اختر نوع المهمة'**
  String get selectTaskType;

  /// No description provided for @taskSpecifications.
  ///
  /// In ar, this message translates to:
  /// **'مواصفات المهمة'**
  String get taskSpecifications;

  /// No description provided for @selectUrgency.
  ///
  /// In ar, this message translates to:
  /// **'اختر الأولوية'**
  String get selectUrgency;

  /// No description provided for @useSavedLocation.
  ///
  /// In ar, this message translates to:
  /// **'استخدام الموقع المحفوظ'**
  String get useSavedLocation;

  /// No description provided for @selectNewLocation.
  ///
  /// In ar, this message translates to:
  /// **'اختر موقع جديد'**
  String get selectNewLocation;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// No description provided for @name.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get name;

  /// No description provided for @email.
  ///
  /// In ar, this message translates to:
  /// **'البريد الالكتروني'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In ar, this message translates to:
  /// **'الهاتف'**
  String get phone;

  /// No description provided for @governorate.
  ///
  /// In ar, this message translates to:
  /// **'الولاية'**
  String get governorate;

  /// No description provided for @city.
  ///
  /// In ar, this message translates to:
  /// **'المدينة'**
  String get city;

  /// No description provided for @area.
  ///
  /// In ar, this message translates to:
  /// **'المنطقة'**
  String get area;

  /// No description provided for @updateProfile.
  ///
  /// In ar, this message translates to:
  /// **'تحديث الملف الشخصي'**
  String get updateProfile;

  /// No description provided for @profileUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث الملف الشخصي بنجاح'**
  String get profileUpdated;

  /// No description provided for @searchOrders.
  ///
  /// In ar, this message translates to:
  /// **'البحث في الطلبات'**
  String get searchOrders;

  /// No description provided for @noOrders.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات'**
  String get noOrders;

  /// No description provided for @orderStatus.
  ///
  /// In ar, this message translates to:
  /// **'حالة الطلب'**
  String get orderStatus;

  /// No description provided for @orderDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الطلب'**
  String get orderDate;

  /// No description provided for @howToCreateRequest.
  ///
  /// In ar, this message translates to:
  /// **'طريقة انشاء طلب'**
  String get howToCreateRequest;

  /// No description provided for @learnHowToCreate.
  ///
  /// In ar, this message translates to:
  /// **'تعلم كيفية إنشاء طلب خدمة بسهولة'**
  String get learnHowToCreate;

  /// No description provided for @howToChooseCraftsman.
  ///
  /// In ar, this message translates to:
  /// **'كيف تختار الصنايعي المناسب'**
  String get howToChooseCraftsman;

  /// No description provided for @tipsForChoosing.
  ///
  /// In ar, this message translates to:
  /// **'نصائح لاختيار أفضل حرفي لخدمتك'**
  String get tipsForChoosing;

  /// No description provided for @howToCommunicate.
  ///
  /// In ar, this message translates to:
  /// **'كيفية التواصل مع الحرفي'**
  String get howToCommunicate;

  /// No description provided for @communicationMethods.
  ///
  /// In ar, this message translates to:
  /// **'طرق التواصل والتفاوض على الأسعار'**
  String get communicationMethods;

  /// No description provided for @rateService.
  ///
  /// In ar, this message translates to:
  /// **'تقييم الخدمة'**
  String get rateService;

  /// No description provided for @howToRate.
  ///
  /// In ar, this message translates to:
  /// **'كيفية تقييم جودة الخدمة المقدمة'**
  String get howToRate;

  /// No description provided for @services.
  ///
  /// In ar, this message translates to:
  /// **'الخدمات'**
  String get services;

  /// No description provided for @selectCategory.
  ///
  /// In ar, this message translates to:
  /// **'اختر الفئة'**
  String get selectCategory;

  /// No description provided for @orderDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الطلب'**
  String get orderDetails;

  /// No description provided for @promoCodeScreen.
  ///
  /// In ar, this message translates to:
  /// **'شاشة البرومو كود'**
  String get promoCodeScreen;

  /// No description provided for @searchInOrders.
  ///
  /// In ar, this message translates to:
  /// **'بحث في الطلبات'**
  String get searchInOrders;

  /// No description provided for @close.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get close;

  /// No description provided for @service.
  ///
  /// In ar, this message translates to:
  /// **'الخدمة'**
  String get service;

  /// No description provided for @description.
  ///
  /// In ar, this message translates to:
  /// **'الوصف'**
  String get description;

  /// No description provided for @time.
  ///
  /// In ar, this message translates to:
  /// **'الوقت'**
  String get time;

  /// No description provided for @progress.
  ///
  /// In ar, this message translates to:
  /// **'التقدم'**
  String get progress;

  /// No description provided for @status.
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get status;

  /// No description provided for @pending.
  ///
  /// In ar, this message translates to:
  /// **'قيد الانتظار'**
  String get pending;

  /// No description provided for @pleaseEnterPromoCode.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال كود البرومو'**
  String get pleaseEnterPromoCode;

  /// No description provided for @codeConfirmed.
  ///
  /// In ar, this message translates to:
  /// **'تم تأكيد الكود'**
  String get codeConfirmed;

  /// No description provided for @invalidPromoCode.
  ///
  /// In ar, this message translates to:
  /// **'كود البرومو غير صحيح'**
  String get invalidPromoCode;

  /// No description provided for @errorConfirmingPromoCode.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في تأكيد كود البرومو'**
  String get errorConfirmingPromoCode;

  /// No description provided for @codeAccepted.
  ///
  /// In ar, this message translates to:
  /// **'تم قبول الكود'**
  String get codeAccepted;

  /// No description provided for @codeNotFound.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد هذا الكود'**
  String get codeNotFound;

  /// No description provided for @membershipCodeCopied.
  ///
  /// In ar, this message translates to:
  /// **'تم نسخ كود العضوية'**
  String get membershipCodeCopied;

  /// No description provided for @errorCopyingMembershipCode.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في نسخ كود العضوية'**
  String get errorCopyingMembershipCode;

  /// No description provided for @doYouHavePromoCode.
  ///
  /// In ar, this message translates to:
  /// **'هل لديك برومو كود ؟'**
  String get doYouHavePromoCode;

  /// No description provided for @enterPromoCode.
  ///
  /// In ar, this message translates to:
  /// **'أدخل البرومو كود'**
  String get enterPromoCode;

  /// No description provided for @yourMembershipCode.
  ///
  /// In ar, this message translates to:
  /// **'كود العضوية الخاص بك هو'**
  String get yourMembershipCode;

  /// No description provided for @shareWithFriends.
  ///
  /// In ar, this message translates to:
  /// **'شاركه مع الاصدقاء لتستفيدوا جميعاً بهدايا وي دو'**
  String get shareWithFriends;

  /// No description provided for @affiliatedFriends.
  ///
  /// In ar, this message translates to:
  /// **'الاصدقاء المنتسبين لي'**
  String get affiliatedFriends;

  /// No description provided for @connectionError.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في الاتصال'**
  String get connectionError;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم الهاتف'**
  String get enterPhoneNumber;

  /// No description provided for @enterPassword.
  ///
  /// In ar, this message translates to:
  /// **'أدخل كلمة المرور'**
  String get enterPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك حساب؟'**
  String get dontHaveAccount;

  /// No description provided for @createAccount.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get createAccount;

  /// No description provided for @craftsmanCount.
  ///
  /// In ar, this message translates to:
  /// **'يتواجد في هذه المهمة'**
  String get craftsmanCount;

  /// No description provided for @createServiceRequestButton.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء طلب خدمة'**
  String get createServiceRequestButton;

  /// No description provided for @tips.
  ///
  /// In ar, this message translates to:
  /// **'نصائح'**
  String get tips;

  /// No description provided for @craftSecrets.
  ///
  /// In ar, this message translates to:
  /// **'أسرار الصنايعية'**
  String get craftSecrets;

  /// No description provided for @message.
  ///
  /// In ar, this message translates to:
  /// **'الرسالة'**
  String get message;

  /// No description provided for @writeYourMessage.
  ///
  /// In ar, this message translates to:
  /// **'اكتب رسالتك...'**
  String get writeYourMessage;

  /// No description provided for @pleaseWriteMessage.
  ///
  /// In ar, this message translates to:
  /// **'يرجى كتابة رسالتك'**
  String get pleaseWriteMessage;

  /// No description provided for @messageSentSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال رسالتك بنجاح'**
  String get messageSentSuccess;

  /// No description provided for @errorSendingMessage.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في إرسال الرسالة'**
  String get errorSendingMessage;

  /// No description provided for @customerService.
  ///
  /// In ar, this message translates to:
  /// **'خدمة العملاء'**
  String get customerService;

  /// No description provided for @clickHere.
  ///
  /// In ar, this message translates to:
  /// **'اضغط هنا'**
  String get clickHere;

  /// No description provided for @cannotOpenWhatsApp.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن فتح واتساب'**
  String get cannotOpenWhatsApp;

  /// No description provided for @locationNotSet.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم تحديد الموقع'**
  String get locationNotSet;

  /// No description provided for @newPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الجديدة'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get confirmPassword;

  /// No description provided for @leavePasswordEmpty.
  ///
  /// In ar, this message translates to:
  /// **'اترك كلمتا المرور فارغتين إن لم ترد تغييرها'**
  String get leavePasswordEmpty;

  /// No description provided for @residentialArea.
  ///
  /// In ar, this message translates to:
  /// **'منطقة سكنك'**
  String get residentialArea;

  /// No description provided for @termsTitle.
  ///
  /// In ar, this message translates to:
  /// **'شروط وأحكام استخدام التطبيق'**
  String get termsTitle;

  /// No description provided for @lastUpdate.
  ///
  /// In ar, this message translates to:
  /// **'آخر تحديث: ديسمبر 2024'**
  String get lastUpdate;

  /// No description provided for @acceptTerms.
  ///
  /// In ar, this message translates to:
  /// **'1. قبول الشروط'**
  String get acceptTerms;

  /// No description provided for @acceptTermsContent.
  ///
  /// In ar, this message translates to:
  /// **'باستخدامك لهذا التطبيق، فإنك توافق على الالتزام بشروط وأحكام الاستخدام هذه. إذا كنت لا توافق على هذه الشروط، يرجى عدم استخدام التطبيق.'**
  String get acceptTermsContent;

  /// No description provided for @serviceDescription.
  ///
  /// In ar, this message translates to:
  /// **'2. وصف الخدمة'**
  String get serviceDescription;

  /// No description provided for @serviceDescriptionContent.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق \"الصنايع\" هو منصة رقمية تربط بين العملاء والصنايعية المهرة لتقديم خدمات الصيانة والإصلاح. نهدف إلى تسهيل عملية العثور على الصنايعية المناسبين وتقديم خدمات عالية الجودة.'**
  String get serviceDescriptionContent;

  /// No description provided for @registrationAccount.
  ///
  /// In ar, this message translates to:
  /// **'3. التسجيل والحساب'**
  String get registrationAccount;

  /// No description provided for @registrationAccountContent.
  ///
  /// In ar, this message translates to:
  /// **'• يجب أن تكون 18 عاماً أو أكثر لاستخدام التطبيق\n• يجب تقديم معلومات صحيحة ودقيقة عند التسجيل\n• أنت مسؤول عن الحفاظ على سرية حسابك وكلمة المرور\n• يجب إبلاغنا فوراً عن أي استخدام غير مصرح به لحسابك'**
  String get registrationAccountContent;

  /// No description provided for @appUsage.
  ///
  /// In ar, this message translates to:
  /// **'4. استخدام التطبيق'**
  String get appUsage;

  /// No description provided for @appUsageContent.
  ///
  /// In ar, this message translates to:
  /// **'• يمكنك استخدام التطبيق للأغراض القانونية فقط\n• لا يجوز استخدام التطبيق لأي نشاط غير قانوني أو ضار\n• يجب احترام حقوق الملكية الفكرية\n• لا يجوز محاولة اختراق أو تعطيل التطبيق'**
  String get appUsageContent;

  /// No description provided for @servicesPayments.
  ///
  /// In ar, this message translates to:
  /// **'5. الخدمات والمدفوعات'**
  String get servicesPayments;

  /// No description provided for @servicesPaymentsContent.
  ///
  /// In ar, this message translates to:
  /// **'• الأسعار المعروضة في التطبيق قد تتغير دون إشعار مسبق\n• المدفوعات تتم عبر طرق آمنة ومعتمدة\n• يمكن إلغاء الطلبات وفقاً للشروط المحددة\n• نحتفظ بالحق في رفض أو إلغاء أي طلب'**
  String get servicesPaymentsContent;

  /// No description provided for @dataPrivacy.
  ///
  /// In ar, this message translates to:
  /// **'6. خصوصية البيانات'**
  String get dataPrivacy;

  /// No description provided for @dataPrivacyContent.
  ///
  /// In ar, this message translates to:
  /// **'• نحن نلتزم بحماية خصوصيتك وبياناتك الشخصية\n• يتم جمع البيانات الضرورية فقط لتقديم الخدمة\n• لا نشارك بياناتك الشخصية مع أطراف ثالثة دون موافقتك\n• يمكنك مراجعة سياسة الخصوصية للحصول على تفاصيل أكثر'**
  String get dataPrivacyContent;

  /// No description provided for @userResponsibility.
  ///
  /// In ar, this message translates to:
  /// **'7. مسؤولية المستخدم'**
  String get userResponsibility;

  /// No description provided for @userResponsibilityContent.
  ///
  /// In ar, this message translates to:
  /// **'• أنت مسؤول عن دقة المعلومات المقدمة\n• يجب التعامل مع الصنايعية باحترام ومهنية\n• لا يجوز إساءة استخدام النظام أو التلاعب به\n• يجب الإبلاغ عن أي مشاكل أو انتهاكات'**
  String get userResponsibilityContent;

  /// No description provided for @appResponsibility.
  ///
  /// In ar, this message translates to:
  /// **'8. مسؤولية التطبيق'**
  String get appResponsibility;

  /// No description provided for @appResponsibilityContent.
  ///
  /// In ar, this message translates to:
  /// **'• نحن نسعى لتقديم أفضل الخدمات الممكنة\n• لا نتحمل مسؤولية الأضرار الناتجة عن استخدام التطبيق\n• نحتفظ بالحق في تعديل أو إيقاف الخدمة\n• نعمل على حل النزاعات بطريقة عادلة'**
  String get appResponsibilityContent;

  /// No description provided for @modifyTerms.
  ///
  /// In ar, this message translates to:
  /// **'9. تعديل الشروط'**
  String get modifyTerms;

  /// No description provided for @modifyTermsContent.
  ///
  /// In ar, this message translates to:
  /// **'نحتفظ بالحق في تعديل هذه الشروط في أي وقت. سيتم إشعار المستخدمين بأي تغييرات مهمة. استمرار استخدام التطبيق بعد التعديلات يعني الموافقة على الشروط الجديدة.'**
  String get modifyTermsContent;

  /// No description provided for @terminateService.
  ///
  /// In ar, this message translates to:
  /// **'10. إنهاء الخدمة'**
  String get terminateService;

  /// No description provided for @terminateServiceContent.
  ///
  /// In ar, this message translates to:
  /// **'يمكن لأي من الطرفين إنهاء هذه الاتفاقية في أي وقت. نحتفظ بالحق في تعليق أو إنهاء حسابك في حالة انتهاك هذه الشروط.'**
  String get terminateServiceContent;

  /// No description provided for @applicableLaw.
  ///
  /// In ar, this message translates to:
  /// **'11. القانون المطبق'**
  String get applicableLaw;

  /// No description provided for @applicableLawContent.
  ///
  /// In ar, this message translates to:
  /// **'تخضع هذه الشروط للقوانين المحلية. أي نزاعات ستتم تسويتها من خلال المحاكم المختصة.'**
  String get applicableLawContent;

  /// No description provided for @contactUsSection.
  ///
  /// In ar, this message translates to:
  /// **'12. التواصل معنا'**
  String get contactUsSection;

  /// No description provided for @contactUsSectionContent.
  ///
  /// In ar, this message translates to:
  /// **'لأي استفسارات أو شكاوى، يمكنك التواصل معنا عبر:\n• البريد الإلكتروني: support@handyman.com\n• الهاتف: 01234567890\n• العنوان: القاهرة، مصر'**
  String get contactUsSectionContent;

  /// No description provided for @termsAgreement.
  ///
  /// In ar, this message translates to:
  /// **'باستخدامك لهذا التطبيق، فإنك تؤكد أنك قد قرأت وفهمت هذه الشروط والأحكام ووافقت عليها.'**
  String get termsAgreement;

  /// No description provided for @step1ChooseService.
  ///
  /// In ar, this message translates to:
  /// **'اختر نوع الخدمة المطلوبة من القائمة'**
  String get step1ChooseService;

  /// No description provided for @step2FillDetails.
  ///
  /// In ar, this message translates to:
  /// **'املأ تفاصيل الطلب والموقع'**
  String get step2FillDetails;

  /// No description provided for @step3SetBudget.
  ///
  /// In ar, this message translates to:
  /// **'حدد الميزانية المتوقعة'**
  String get step3SetBudget;

  /// No description provided for @step4AttachPhotos.
  ///
  /// In ar, this message translates to:
  /// **'أرفق الصور إذا لزم الأمر'**
  String get step4AttachPhotos;

  /// No description provided for @step5SendRequest.
  ///
  /// In ar, this message translates to:
  /// **'اضغط على \"إرسال الطلب\"'**
  String get step5SendRequest;

  /// No description provided for @step6WaitResponse.
  ///
  /// In ar, this message translates to:
  /// **'انتظر رد الصنايعية على طلبك'**
  String get step6WaitResponse;

  /// No description provided for @step1ReviewRatings.
  ///
  /// In ar, this message translates to:
  /// **'راجع تقييمات الصنايعية السابقة'**
  String get step1ReviewRatings;

  /// No description provided for @step2ComparePrices.
  ///
  /// In ar, this message translates to:
  /// **'قارن الأسعار المقدمة'**
  String get step2ComparePrices;

  /// No description provided for @step3CheckExperience.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من خبرة الحرفي في المجال'**
  String get step3CheckExperience;

  /// No description provided for @step4ReadComments.
  ///
  /// In ar, this message translates to:
  /// **'اقرأ التعليقات والمراجعات'**
  String get step4ReadComments;

  /// No description provided for @step5CheckAvailability.
  ///
  /// In ar, this message translates to:
  /// **'تأكد من توفر الحرفي في الوقت المطلوب'**
  String get step5CheckAvailability;

  /// No description provided for @step6CommunicateBefore.
  ///
  /// In ar, this message translates to:
  /// **'تواصل مع الحرفي قبل التعاقد'**
  String get step6CommunicateBefore;

  /// No description provided for @step1UseMessaging.
  ///
  /// In ar, this message translates to:
  /// **'استخدم نظام الرسائل في التطبيق'**
  String get step1UseMessaging;

  /// No description provided for @step2SetAppointment.
  ///
  /// In ar, this message translates to:
  /// **'حدد موعد مناسب للزيارة'**
  String get step2SetAppointment;

  /// No description provided for @step3DiscussDetails.
  ///
  /// In ar, this message translates to:
  /// **'ناقش تفاصيل العمل والأسعار'**
  String get step3DiscussDetails;

  /// No description provided for @step4CheckWarranty.
  ///
  /// In ar, this message translates to:
  /// **'تأكد من شروط الضمان'**
  String get step4CheckWarranty;

  /// No description provided for @step5KeepRecords.
  ///
  /// In ar, this message translates to:
  /// **'احتفظ بسجل المحادثات'**
  String get step5KeepRecords;

  /// No description provided for @step6RateAfterWork.
  ///
  /// In ar, this message translates to:
  /// **'استخدم التقييم بعد انتهاء العمل'**
  String get step6RateAfterWork;

  /// No description provided for @step1RateQuality.
  ///
  /// In ar, this message translates to:
  /// **'قيم جودة العمل المنجز'**
  String get step1RateQuality;

  /// No description provided for @step2RatePunctuality.
  ///
  /// In ar, this message translates to:
  /// **'قيم التزام الحرفي بالمواعيد'**
  String get step2RatePunctuality;

  /// No description provided for @step3RateProfessionalism.
  ///
  /// In ar, this message translates to:
  /// **'قيم التعامل والاحترافية'**
  String get step3RateProfessionalism;

  /// No description provided for @step4WriteComment.
  ///
  /// In ar, this message translates to:
  /// **'اكتب تعليق مفصل عن التجربة'**
  String get step4WriteComment;

  /// No description provided for @step5AttachWorkPhotos.
  ///
  /// In ar, this message translates to:
  /// **'ارفق صور للعمل المنجز'**
  String get step5AttachWorkPhotos;

  /// No description provided for @step6HelpOthers.
  ///
  /// In ar, this message translates to:
  /// **'ساعد الآخرين بمراجعتك'**
  String get step6HelpOthers;

  /// No description provided for @homeMaintenance.
  ///
  /// In ar, this message translates to:
  /// **'خدمات صيانة المنازل'**
  String get homeMaintenance;

  /// No description provided for @cleaningServices.
  ///
  /// In ar, this message translates to:
  /// **'خدمات التنظيف'**
  String get cleaningServices;

  /// No description provided for @transportation.
  ///
  /// In ar, this message translates to:
  /// **'النقل والخدمات اللوجستية'**
  String get transportation;

  /// No description provided for @carServices.
  ///
  /// In ar, this message translates to:
  /// **'خدمات السيارات'**
  String get carServices;

  /// No description provided for @emergencyServices.
  ///
  /// In ar, this message translates to:
  /// **'خدمات طارئة (عاجلة)'**
  String get emergencyServices;

  /// No description provided for @familyServices.
  ///
  /// In ar, this message translates to:
  /// **'خدمات الأسر والعائلات'**
  String get familyServices;

  /// No description provided for @technicalServices.
  ///
  /// In ar, this message translates to:
  /// **'خدمات تقنية'**
  String get technicalServices;

  /// No description provided for @gardenServices.
  ///
  /// In ar, this message translates to:
  /// **'خدمات الحديقة'**
  String get gardenServices;

  /// No description provided for @variousCrafts.
  ///
  /// In ar, this message translates to:
  /// **'حرف وخدمات متنوعة'**
  String get variousCrafts;

  /// No description provided for @elevatorsSolar.
  ///
  /// In ar, this message translates to:
  /// **'المصاعد والألواح الشمسية'**
  String get elevatorsSolar;

  /// No description provided for @educationServices.
  ///
  /// In ar, this message translates to:
  /// **'خدمات التعليم والدروس الخصوصية'**
  String get educationServices;

  /// No description provided for @eventsCelebrations.
  ///
  /// In ar, this message translates to:
  /// **'خدمات المناسبات والإحتفالات'**
  String get eventsCelebrations;

  /// No description provided for @travelTourism.
  ///
  /// In ar, this message translates to:
  /// **'خدمات السفر والسياحة'**
  String get travelTourism;

  /// No description provided for @officeServices.
  ///
  /// In ar, this message translates to:
  /// **'خدمات المكاتب والمستندات'**
  String get officeServices;

  /// No description provided for @shoppingServices.
  ///
  /// In ar, this message translates to:
  /// **'خدمات التسوق'**
  String get shoppingServices;

  /// No description provided for @corporateServices.
  ///
  /// In ar, this message translates to:
  /// **'خدمات للمؤسسات والشركات'**
  String get corporateServices;

  /// No description provided for @specialNeeds.
  ///
  /// In ar, this message translates to:
  /// **'خدمات ذوي الإحتياجات الخاصة'**
  String get specialNeeds;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In ar, this message translates to:
  /// **'يرجى ملء جميع الحقول'**
  String get pleaseFillAllFields;

  /// No description provided for @pleaseEnterValidPhone.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال رقم هاتف صحيح'**
  String get pleaseEnterValidPhone;

  /// No description provided for @loginSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل الدخول بنجاح'**
  String get loginSuccess;

  /// No description provided for @invalidPhoneOrPassword.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف أو كلمة المرور غير صحيحة'**
  String get invalidPhoneOrPassword;

  /// No description provided for @serverConnectionError.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في الاتصال بالخادم'**
  String get serverConnectionError;

  /// No description provided for @connectionTimeout.
  ///
  /// In ar, this message translates to:
  /// **'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى'**
  String get connectionTimeout;

  /// No description provided for @checkInternetConnection.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في الاتصال بالخادم. يرجى التحقق من الإنترنت'**
  String get checkInternetConnection;

  /// No description provided for @connectionErrorRetry.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في الاتصال. يرجى المحاولة مرة أخرى'**
  String get connectionErrorRetry;

  /// No description provided for @taskDescriptionLabel.
  ///
  /// In ar, this message translates to:
  /// **'وصف المهمة'**
  String get taskDescriptionLabel;

  /// No description provided for @writeDetailedDescription.
  ///
  /// In ar, this message translates to:
  /// **'اكتب وصفاً مفصلاً للمهمة المطلوبة...'**
  String get writeDetailedDescription;

  /// No description provided for @priorityLevel.
  ///
  /// In ar, this message translates to:
  /// **'مستوى الأولوية'**
  String get priorityLevel;

  /// No description provided for @expectedBudget.
  ///
  /// In ar, this message translates to:
  /// **'الميزانية المتوقعة (اختياري)'**
  String get expectedBudget;

  /// No description provided for @budgetExample.
  ///
  /// In ar, this message translates to:
  /// **'مثال: 500 دينار تونسي'**
  String get budgetExample;

  /// No description provided for @taskLocation.
  ///
  /// In ar, this message translates to:
  /// **'مكان المهمة'**
  String get taskLocation;

  /// No description provided for @editLocation.
  ///
  /// In ar, this message translates to:
  /// **'تعديل المكان'**
  String get editLocation;

  /// No description provided for @addPhotos.
  ///
  /// In ar, this message translates to:
  /// **'أضف صور (اختياري)'**
  String get addPhotos;

  /// No description provided for @clickMapToMoveMarker.
  ///
  /// In ar, this message translates to:
  /// **'اضغط على الخريطة لتحريك العلامة أو اسحب العلامة الحمراء'**
  String get clickMapToMoveMarker;

  /// No description provided for @pleaseWriteTaskDescription.
  ///
  /// In ar, this message translates to:
  /// **'يرجى كتابة وصف المهمة'**
  String get pleaseWriteTaskDescription;

  /// No description provided for @pleaseWriteMoreDetailed.
  ///
  /// In ar, this message translates to:
  /// **'يرجى كتابة وصف أكثر تفصيلاً (10 أحرف على الأقل)'**
  String get pleaseWriteMoreDetailed;

  /// No description provided for @pleaseSelectLocation.
  ///
  /// In ar, this message translates to:
  /// **'يرجى اختيار موقع للمهمة'**
  String get pleaseSelectLocation;

  /// No description provided for @pleaseSelectTaskType.
  ///
  /// In ar, this message translates to:
  /// **'يرجى اختيار نوع المهمة'**
  String get pleaseSelectTaskType;

  /// No description provided for @noTasksAvailable.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مهام متاحة لهذه الفئة'**
  String get noTasksAvailable;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// No description provided for @price.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get price;

  /// No description provided for @duration.
  ///
  /// In ar, this message translates to:
  /// **'المدة'**
  String get duration;

  /// No description provided for @errorLoadingTaskTypes.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في تحميل أنواع المهام'**
  String get errorLoadingTaskTypes;

  /// No description provided for @serverConnectionErrorCheckInternet.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في الاتصال بالخادم. تحقق من اتصال الإنترنت'**
  String get serverConnectionErrorCheckInternet;

  /// No description provided for @connectionTimeoutTryAgain.
  ///
  /// In ar, this message translates to:
  /// **'انتهت مهلة الاتصال. حاول مرة أخرى'**
  String get connectionTimeoutTryAgain;

  /// No description provided for @cannotReachServer.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن الوصول إلى الخادم. تحقق من اتصال الإنترنت'**
  String get cannotReachServer;

  /// No description provided for @tryAgain.
  ///
  /// In ar, this message translates to:
  /// **'حاول مرة أخرى'**
  String get tryAgain;

  /// No description provided for @errorSendingRequest.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في إرسال الطلب'**
  String get errorSendingRequest;

  /// No description provided for @errorSendingRequestRetry.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في إرسال الطلب. يرجى المحاولة مرة أخرى'**
  String get errorSendingRequestRetry;

  /// No description provided for @imageAddedSuccessfully.
  ///
  /// In ar, this message translates to:
  /// **'تم إضافة الصورة بنجاح'**
  String get imageAddedSuccessfully;

  /// No description provided for @errorAddingImage.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في إضافة الصورة'**
  String get errorAddingImage;

  /// No description provided for @selectImageSource.
  ///
  /// In ar, this message translates to:
  /// **'اختر مصدر الصورة'**
  String get selectImageSource;

  /// No description provided for @camera.
  ///
  /// In ar, this message translates to:
  /// **'الكاميرا'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In ar, this message translates to:
  /// **'المعرض'**
  String get gallery;

  /// No description provided for @confirmLocation.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الموقع'**
  String get confirmLocation;

  /// No description provided for @locationSelected.
  ///
  /// In ar, this message translates to:
  /// **'تم اختيار الموقع'**
  String get locationSelected;

  /// No description provided for @mapLocation.
  ///
  /// In ar, this message translates to:
  /// **'خريطة الموقع'**
  String get mapLocation;

  /// No description provided for @clickToSelectLocation.
  ///
  /// In ar, this message translates to:
  /// **'اضغط لاختيار الموقع'**
  String get clickToSelectLocation;

  /// No description provided for @customLocation.
  ///
  /// In ar, this message translates to:
  /// **'موقع مخصص'**
  String get customLocation;

  /// No description provided for @drill.
  ///
  /// In ar, this message translates to:
  /// **'مثقاب'**
  String get drill;

  /// No description provided for @meter.
  ///
  /// In ar, this message translates to:
  /// **'متر'**
  String get meter;

  /// No description provided for @hammer.
  ///
  /// In ar, this message translates to:
  /// **'مطرقة'**
  String get hammer;

  /// No description provided for @faucet.
  ///
  /// In ar, this message translates to:
  /// **'صنبور'**
  String get faucet;

  /// No description provided for @wires.
  ///
  /// In ar, this message translates to:
  /// **'أسلاك'**
  String get wires;

  /// No description provided for @paint.
  ///
  /// In ar, this message translates to:
  /// **'دهان'**
  String get paint;

  /// No description provided for @pipes.
  ///
  /// In ar, this message translates to:
  /// **'مواسير'**
  String get pipes;

  /// No description provided for @tools.
  ///
  /// In ar, this message translates to:
  /// **'أدوات'**
  String get tools;

  /// No description provided for @messageSentAndSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال الرسالة وحفظها في الـ admin panel'**
  String get messageSentAndSaved;

  /// No description provided for @conversationDeleted.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف المحادثة'**
  String get conversationDeleted;

  /// No description provided for @conversationDeletedFromAdmin.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف المحادثة من الـ admin panel'**
  String get conversationDeletedFromAdmin;

  /// No description provided for @errorDeletingConversation.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في حذف المحادثة'**
  String get errorDeletingConversation;

  /// No description provided for @thankYouWillReplySoon.
  ///
  /// In ar, this message translates to:
  /// **'شكراً لك! سأقوم بالرد عليك قريباً.'**
  String get thankYouWillReplySoon;

  /// No description provided for @helloIWant.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً، أريد'**
  String get helloIWant;

  /// No description provided for @helloAvailableTomorrow.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً، سأكون متاحاً غداً في الساعة 10 صباحاً'**
  String get helloAvailableTomorrow;

  /// No description provided for @excellentWhatPrice.
  ///
  /// In ar, this message translates to:
  /// **'ممتاز، ما هو السعر المتوقع؟'**
  String get excellentWhatPrice;

  /// No description provided for @priceRange50to100.
  ///
  /// In ar, this message translates to:
  /// **'السعر يتراوح بين 50-100 دينار حسب المشكلة'**
  String get priceRange50to100;

  /// No description provided for @kilometers.
  ///
  /// In ar, this message translates to:
  /// **'كم'**
  String get kilometers;

  /// No description provided for @today.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get today;

  /// No description provided for @step1.
  ///
  /// In ar, this message translates to:
  /// **'قدم 1'**
  String get step1;

  /// No description provided for @pendingStatus.
  ///
  /// In ar, this message translates to:
  /// **'قيد الانتظار'**
  String get pendingStatus;

  /// No description provided for @craftsmenInThisTask.
  ///
  /// In ar, this message translates to:
  /// **'يتواجد في هذه المهمة'**
  String get craftsmenInThisTask;

  /// No description provided for @yourServicesOnUs.
  ///
  /// In ar, this message translates to:
  /// **'خدماتك علينا'**
  String get yourServicesOnUs;

  /// No description provided for @contactInfo.
  ///
  /// In ar, this message translates to:
  /// **'بيانات الإتصال'**
  String get contactInfo;

  /// No description provided for @selectNewImage.
  ///
  /// In ar, this message translates to:
  /// **'اختر صورة جديدة'**
  String get selectNewImage;

  /// No description provided for @takePhoto.
  ///
  /// In ar, this message translates to:
  /// **'التقاط صورة'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In ar, this message translates to:
  /// **'اختيار من المعرض'**
  String get chooseFromGallery;

  /// No description provided for @deleteImage.
  ///
  /// In ar, this message translates to:
  /// **'حذف الصورة'**
  String get deleteImage;

  /// No description provided for @imageSelectedSuccessfully.
  ///
  /// In ar, this message translates to:
  /// **'تم اختيار الصورة بنجاح'**
  String get imageSelectedSuccessfully;

  /// No description provided for @errorSelectingImage.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في اختيار الصورة'**
  String get errorSelectingImage;

  /// No description provided for @imageDeleted.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف الصورة'**
  String get imageDeleted;

  /// No description provided for @pleaseEnterName.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال الاسم'**
  String get pleaseEnterName;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال البريد الإلكتروني'**
  String get pleaseEnterEmail;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الجديدة غير متطابقة'**
  String get passwordsDoNotMatch;

  /// No description provided for @dataSavedSuccessfully.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ البيانات بنجاح'**
  String get dataSavedSuccessfully;

  /// No description provided for @dataSavedToAdmin.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ البيانات بنجاح في الـ admin panel'**
  String get dataSavedToAdmin;

  /// No description provided for @connectionErrorCheckInternet.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في الاتصال. يرجى التحقق من الإنترنت'**
  String get connectionErrorCheckInternet;

  /// No description provided for @cannotOpenFacebook.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن فتح فيسبوك'**
  String get cannotOpenFacebook;

  /// No description provided for @errorSharingOnFacebook.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في مشاركة التطبيق على فيسبوك'**
  String get errorSharingOnFacebook;

  /// No description provided for @errorSharingOnWhatsApp.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في مشاركة التطبيق على واتساب'**
  String get errorSharingOnWhatsApp;

  /// No description provided for @shareAppMessage.
  ///
  /// In ar, this message translates to:
  /// **'قم بتنزيل تطبيق Wedoo للحصول على أفضل خدمات الصنايعي والصنايعية!'**
  String get shareAppMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
