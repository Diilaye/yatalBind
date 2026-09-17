import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'fr': {
          // AppBar
          'app_title': 'Concours National de Calligraphie du Saint Coran',
          'app_search': 'Rechercher...',
          // Home Screen
          'previous_events': 'Événements Précédents',
          'see_all': 'VOIR TOUT',
          'yaatal_mbinde_contest': 'Concours C3S YAATAL MBINDUM ALXURAN',

          // Langue
          'language': 'Langue',
          'french': 'Français',
          'arabic': 'العربية',

          // Autres textes courants
          'notifications': 'Notifications',
          'search': 'Rechercher...',
          'categories': 'Catégories',
          'welcome': 'Bienvenue',
          'loading': 'Chargement...',
          'error': 'Erreur',
          'retry': 'Réessayer',
          'cancel': 'Annuler',
          'confirm': 'Confirmer',
          'save': 'Enregistrer',
          'delete': 'Supprimer',
          'edit': 'Modifier',
          'add': 'Ajouter',
          'close': 'Fermer',

          // ParticipateScreen
          'participate': 'Participer',
          'registration_form': 'Formulaire d\'inscription',
          'submit_application': 'Vous pouvez déposer votre candidature ici',
          'first_name': 'Prénom',
          'last_name': 'Nom',
          'phone': 'Téléphone',
          'birth_date': 'Date de Naissance',
          'exact_address': 'Adresse Exacte',
          'school': 'École',
          'professor': 'Professeur',
          'take_photo': 'Prendre une photo',
          'select_file': 'Sélectionner un fichier',
          'file_selected': 'Fichier sélectionné.',
          'validate': 'Valider',
          'please_enter': 'Veuillez entrer',
          'invalid_phone': 'Numéro de téléphone invalide.',
          'age_limit': 'L\'âge ne doit pas dépasser 34 ans.',
          'file_size_limit': 'Le fichier ne doit pas dépasser 1 Mo.',
          'form_submitted': 'Formulaire soumis avec succès !',

          // ContactScreen
          'contact_us': 'Contactez-nous',
          'name': 'Nom',
          'surname': 'Prénom',
          'email': 'Email',
          'message': 'Message',
          'send': 'Envoyer',
          'yaatal_info': 'Informations du groupe Yaatal Mbinde',
          'address': 'Adresse: Dakar, Sénégal',
          'phone_contact': 'Téléphone: +221 33 123 45 67',
          'email_contact': 'Email: contact@yaatal.com',
          'our_locations': 'Nos Localisations',
          'message_sent': 'Message envoyé avec succès!',
          'send_error': 'Erreur lors de l\'envoi du message',
          'enter_valid_email': 'Veuillez entrer un email valide',

          // EventsScreen
          'your_channel': 'Votre Chaîne',
          'videos_list': 'LISTES DES VIDÉOS',
          'videos_count': 'Videos',

          // GalleryScreen
          'gallery': 'Galérie',
          'yaatal_mbindoum': 'Yaatal Mbindoum Al Xurane',
          'photos_count': 'photos',
          'all_events': 'Tous les événements',
          'view_photos': 'VOIR LES PHOTOS',
          'refresh': 'Actualiser',
          'all_years': 'Toutes les années',
          'years': 'Années',
          'all': 'Tous',
          'photos': 'Photos',

          // ConcoursScreen
          'information': 'Informations',
          'concours': 'Concours',
          'why_yaatal_mbinde':
              'Pourquoi participer au concours Yaatal Mbinde ?',
          'learn_more': 'En savoir plus',
          'contest_details': 'Détails du concours',
          'download_rules': 'Télécharger le règlement',
          'contest_rules': 'Règlement du concours',
          'download_prizes': 'Télécharger la liste des prix',
          'prizes_list': 'Liste des prix',
          'girls': 'Filles',
          'boys': 'Garçons',
          'regions': 'Régions',
          'participation_rate': 'Taux de participation',
        },
        'ar': {
          // AppBar
          'app_title': 'مسابقة  الوطنية في رسم القرآن الكريم والخط المحلي',
          'app_search': 'بحث...',
          // Home Screen
          'previous_events': 'الأحداث السابقة',
          'see_all': 'عرض الكل',
          'yaatal_mbinde_contest': 'مسابقة C3S YAATAL MBINDUM ALXURAN',

          // Langue
          'language': 'اللغة',
          'french': 'Français',
          'arabic': 'العربية',

          // Autres textes courants
          'notifications': 'الإشعارات',
          'search': 'بحث...',
          'categories': 'الفئات',
          'welcome': 'مرحبا',
          'loading': 'جار التحميل...',
          'error': 'خطأ',
          'retry': 'إعادة المحاولة',
          'cancel': 'إلغاء',
          'confirm': 'تأكيد',
          'save': 'حفظ',
          'delete': 'حذف',
          'edit': 'تعديل',
          'add': 'إضافة',
          'close': 'إغلاق',

          // ParticipateScreen
          'participate': 'يشارك',
          'registration_form': 'نموذج التسجيل',
          'submit_application': 'يمكنك تقديم طلبك هنا',
          'first_name': 'الاسم الأول',
          'last_name': 'اسم',
          'phone': 'هاتف',
          'birth_date': 'تاريخ الميلاد',
          'exact_address': 'العنوان الدقيق',
          'school': 'مدرسة',
          'professor': 'مدرس',
          'take_photo': 'التقط صورة',
          'select_file': 'حدد ملف',
          'file_selected': 'تم تحديد الملف.',
          'validate': 'للتحقق من صحة',
          'please_enter': 'الرجاء الدخول',
          'invalid_phone': 'رقم الهاتف غير صالح',
          'age_limit': '- لا يجب أن يتجاوز العمر 34 سنة.',
          'file_size_limit': 'لا يجب أن يتجاوز حجم الملف 1 ميجا بايت.',
          'form_submitted': 'تم إرسال النموذج بنجاح!',

          //ConcoursScreen
          'information': 'معلومات',
          'contact_us': 'اتصل بنا',
          'contest_details': 'تفاصيل المسابقة',
          'download_rules': 'تحميل القواعد',
          'contest_rules': 'قواعد المسابقة',
          'download_prizes': 'تحميل قائمة الجوائز',
          'prizes_list': 'قائمة الجوائز',
          'contest_results': 'نتائج المسابقة',
          'why_yaatal_mbinde': 'لماذا تشارك في مسابقة Yaatal Mbinde؟',
          'girls': 'فتيات',
          'boys': 'أولاد',
          'regions': 'مناطق',
          'participation_rate': 'معدل المشاركة',

          //GalleryScreen
          'years': 'سنوات',
          'all_categories': 'جميع الفئات',
          'all': 'الكل',
          'all_years': 'جميع السنوات',
          'gallery': 'معرض',
          'photos_count': 'صور',
        },
      };
}
