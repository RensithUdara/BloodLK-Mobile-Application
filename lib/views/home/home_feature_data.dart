import 'package:flutter/material.dart';

class DonorHomeFeature {
  const DonorHomeFeature({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.description,
    required this.items,
    this.faqs = const [],
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String description;
  final List<String> items;
  final List<DonorFaqItem> faqs;
}

class DonorFaqItem {
  const DonorFaqItem({required this.question, required this.answer});

  final String question;
  final String answer;
}

const donorHomeFeatures = [
  DonorHomeFeature(
    title: 'My Profile',
    subtitle: 'View and edit your\npersonal information',
    icon: Icons.person_rounded,
    description:
        'Keep your donor details accurate so requesters can contact you quickly.',
    items: [
      'Update name, phone number, city, and blood group.',
      'Review NIC and account details.',
      'Keep your last donation date current.',
    ],
  ),
  DonorHomeFeature(
    title: 'Donation Centers',
    subtitle: 'Find nearby hospitals\nand blood banks',
    icon: Icons.local_hospital_rounded,
    description:
        'Discover suitable blood donation locations near Badulla and nearby areas.',
    items: [
      'Badulla General Hospital Blood Bank',
      'Provincial Blood Center - Uva',
      'Nearby hospital donation units',
      'Call before visiting to confirm availability.',
    ],
  ),
  DonorHomeFeature(
    title: 'Past Donations',
    subtitle: 'View and manage your\ndonation history',
    icon: Icons.bloodtype_rounded,
    description:
        'Track your past blood donations and maintain a clear donation timeline.',
    items: [
      'Add donation dates after every donation.',
      'View donation history by month and year.',
      'Use history to calculate next eligible date.',
    ],
  ),
  DonorHomeFeature(
    title: 'Next Eligibility',
    subtitle: 'Check when you can\ndonate again',
    icon: Icons.calendar_month_rounded,
    description:
        'Know when you are ready to donate again based on your last donation.',
    items: [
      'BloodLK uses a five-month donor recovery window.',
      'See your eligibility countdown.',
      'Get reminders when you become eligible.',
    ],
  ),
  DonorHomeFeature(
    title: 'Emergency Requests',
    subtitle: 'View urgent blood\nrequests',
    icon: Icons.emergency_share_rounded,
    description: 'Quickly review urgent blood requests that match donor needs.',
    items: [
      'Browse urgent requests by blood group.',
      'Check request location before responding.',
      'Contact the hospital or requester directly.',
    ],
  ),
  DonorHomeFeature(
    title: 'Notifications',
    subtitle: 'Manage your alert\npreferences',
    icon: Icons.notifications_rounded,
    description: 'Control the alerts you receive from BloodLK.',
    items: [
      'Enable urgent blood request alerts.',
      'Receive donation eligibility reminders.',
      'Choose city-based or blood-group-based alerts.',
    ],
  ),
  DonorHomeFeature(
    title: 'Settings',
    subtitle: 'App preferences\nand account',
    icon: Icons.settings_rounded,
    description:
        'Manage app behavior, account preferences, and privacy options.',
    items: [
      'Manage notification permissions.',
      'Change language and display preferences.',
      'Sign out or review privacy options.',
    ],
  ),
  DonorHomeFeature(
    title: 'FAQ',
    subtitle: 'Common questions\nabout donation',
    icon: Icons.question_mark_rounded,
    description: 'Learn the basics of safe blood donation.',
    items: const [],
    faqs: [
      DonorFaqItem(
        question: 'Who can donate blood?',
        answer:
            'Most donors must be in good health, feel well on the donation day, meet the required age and weight rules, and pass the donor screening at the center. Bring a valid ID and tell staff about recent illness, travel, medicines, tattoos, or medical conditions.',
      ),
      DonorFaqItem(
        question: 'How often can I donate?',
        answer:
            'Whole blood donation rules can differ by country and center. Many blood services allow whole blood donation around every 56 days, while this app uses a safer five-month eligibility window for donor reminders and searches. Always follow the advice of your local blood bank or hospital.',
      ),
      DonorFaqItem(
        question: 'What should I eat before donation?',
        answer:
            'Eat a proper healthy meal before donating. Choose iron-rich foods such as lean meat, fish, eggs, beans, lentils, spinach, or iron-fortified cereal. Drink extra water or another non-alcoholic drink, and avoid very fatty foods before donation.',
      ),
      DonorFaqItem(
        question: 'What should I do after donation?',
        answer:
            'Rest for a short time, drink fluids, and eat the snack provided by the center. Keep the bandage on as advised, avoid heavy exercise for the rest of the day, and eat iron-rich foods with vitamin C to help recovery. If you feel dizzy, sit or lie down and tell medical staff.',
      ),
      DonorFaqItem(
        question: 'Can I donate if I feel sick?',
        answer:
            'No. If you have fever, flu symptoms, infection, unusual tiredness, or you do not feel well, wait until you recover and ask the donation center when it is safe to donate.',
      ),
      DonorFaqItem(
        question: 'What should I bring to donate?',
        answer:
            'Bring a valid photo ID or donor card if you have one. Wear comfortable clothing with sleeves that can be rolled above the elbow, and bring any information the center may need about medicines or recent medical care.',
      ),
    ],
  ),
  DonorHomeFeature(
    title: 'Donation Tips',
    subtitle: 'Tips before and after\ndonation',
    icon: Icons.lightbulb_rounded,
    description: 'Prepare well and recover comfortably after donating blood.',
    items: [
      'Drink enough water before donating.',
      'Eat a healthy meal before your appointment.',
      'Rest after donation and avoid heavy exercise.',
    ],
  ),
  DonorHomeFeature(
    title: 'Availability Status',
    subtitle: 'Set your availability\nto help others',
    icon: Icons.how_to_reg_rounded,
    description: 'Let requesters know whether you can currently help.',
    items: [
      'Available: ready to be contacted.',
      'Busy: temporarily unavailable.',
      'Resting: recently donated or recovering.',
    ],
  ),
  DonorHomeFeature(
    title: 'Achievements',
    subtitle: 'View your badges\nand milestones',
    icon: Icons.emoji_events_rounded,
    description: 'Celebrate the positive impact of your donations.',
    items: [
      'First Donation badge',
      'Life Saver badge',
      'Emergency Hero badge',
      'Regular Donor milestone',
    ],
  ),
  DonorHomeFeature(
    title: 'Help Center',
    subtitle: 'Get support and\ncontact us',
    icon: Icons.headset_mic_rounded,
    description: 'Find support when you need help using BloodLK.',
    items: [
      'Report incorrect donor details.',
      'Ask for help with notifications.',
      'Contact admins for urgent issues.',
    ],
  ),
];
