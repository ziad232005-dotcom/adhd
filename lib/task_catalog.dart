/// A ready-made daily task the parent can add with one tap.
class CatalogTask {
  const CatalogTask(this.category, this.title, this.subtitle, this.points,
      {this.minutes});

  final String category;
  final String title;
  final String subtitle;
  final int points;
  final int? minutes;
}

/// The categories, in the order they are shown.
const List<String> taskCategories = [
  'Morning',
  'School',
  'Home',
  'Hygiene',
  'Food',
  'Sleep',
  'Play & Activity',
  'Social & Skills',
];

/// A fixed list of daily tasks, so a parent rarely has to write one.
const List<CatalogTask> taskCatalog = [
  // Morning
  CatalogTask('Morning', 'Wake up on time', 'Get out of bed when the alarm rings.', 3),
  CatalogTask('Morning', 'Make my bed', 'Straighten the sheet and the pillow.', 3, minutes: 5),
  CatalogTask('Morning', 'Get dressed', 'Put on today’s clothes by myself.', 3, minutes: 10),
  CatalogTask('Morning', 'Eat breakfast', 'Sit down and finish my breakfast.', 3, minutes: 15),
  CatalogTask('Morning', 'Put on my shoes', 'Shoes on and ready to go.', 2, minutes: 5),
  CatalogTask('Morning', 'Check my morning list', 'Look at what is planned for today.', 2, minutes: 5),

  // School
  CatalogTask('School', 'Pack my school bag', 'Books, notebooks and pencil case.', 5, minutes: 10),
  CatalogTask('School', 'Do my homework', 'Finish today’s homework.', 8, minutes: 30),
  CatalogTask('School', 'Read for 10 minutes', 'Read a book or a story.', 5, minutes: 10),
  CatalogTask('School', 'Review today’s lessons', 'Look at what I learned today.', 5, minutes: 15),
  CatalogTask('School', 'Prepare tomorrow’s bag', 'Get everything ready tonight.', 4, minutes: 10),
  CatalogTask('School', 'Write in my notebook', 'Write a few neat lines.', 4, minutes: 10),
  CatalogTask('School', 'Practice math', 'Solve a few small problems.', 5, minutes: 15),
  CatalogTask('School', 'Tidy my study desk', 'Clear the desk before and after studying.', 3, minutes: 5),

  // Home
  CatalogTask('Home', 'Tidy my room', 'Put toys and clothes in their places.', 5, minutes: 10),
  CatalogTask('Home', 'Put dirty clothes in the basket', 'Clothes go in the laundry basket.', 2),
  CatalogTask('Home', 'Set the table', 'Help set plates and cups for the meal.', 3, minutes: 5),
  CatalogTask('Home', 'Clear my plate', 'Take my plate to the kitchen.', 2),
  CatalogTask('Home', 'Help in the kitchen', 'Help a grown-up with a small job.', 4, minutes: 10),
  CatalogTask('Home', 'Water the plants', 'Give the plants a little water.', 3, minutes: 5),
  CatalogTask('Home', 'Put the toys away', 'Every toy back in its box.', 3, minutes: 10),
  CatalogTask('Home', 'Take out the small trash', 'Carry the small bin to the big one.', 3, minutes: 5),

  // Hygiene
  CatalogTask('Hygiene', 'Brush my teeth (morning)', 'Brush for two minutes.', 3, minutes: 2),
  CatalogTask('Hygiene', 'Brush my teeth (night)', 'Brush for two minutes before bed.', 3, minutes: 2),
  CatalogTask('Hygiene', 'Wash my face', 'Wash my face with water and soap.', 2, minutes: 2),
  CatalogTask('Hygiene', 'Wash my hands before eating', 'Soap, water and a good scrub.', 2, minutes: 2),
  CatalogTask('Hygiene', 'Take a bath', 'Wash and dry myself well.', 4, minutes: 15),
  CatalogTask('Hygiene', 'Comb my hair', 'Brush my hair neatly.', 2, minutes: 3),
  CatalogTask('Hygiene', 'Wash my hands after the toilet', 'Always with soap.', 2, minutes: 2),

  // Food
  CatalogTask('Food', 'Drink water', 'Drink a glass of water.', 2),
  CatalogTask('Food', 'Eat my vegetables', 'Try my vegetables at lunch.', 4, minutes: 15),
  CatalogTask('Food', 'Eat a piece of fruit', 'A fruit as a healthy snack.', 3),
  CatalogTask('Food', 'Finish my lunch', 'Sit and eat my lunch calmly.', 4, minutes: 20),
  CatalogTask('Food', 'Eat dinner at the table', 'Sit with the family for dinner.', 4, minutes: 20),
  CatalogTask('Food', 'Take my vitamin', 'Only the one my parent gives me.', 2),

  // Sleep
  CatalogTask('Sleep', 'Get ready for bed', 'Pajamas on and lights low.', 3, minutes: 10),
  CatalogTask('Sleep', 'Switch off screens', 'No screens before bedtime.', 4),
  CatalogTask('Sleep', 'Read a bedtime story', 'A calm story before sleep.', 3, minutes: 10),
  CatalogTask('Sleep', 'Go to bed on time', 'In bed at the agreed time.', 5),
  CatalogTask('Sleep', 'Lay out tomorrow’s clothes', 'Choose clothes for the morning.', 2, minutes: 5),
  CatalogTask('Sleep', 'Take a quiet breathing break', 'Slow breaths to relax.', 3, minutes: 3),

  // Play & Activity
  CatalogTask('Play & Activity', 'Play outside', 'Fresh air and running around.', 5, minutes: 30),
  CatalogTask('Play & Activity', 'Do some exercise', 'Jump, stretch or dance.', 5, minutes: 15),
  CatalogTask('Play & Activity', 'Screen-free play', 'Blocks, puzzles or drawing.', 4, minutes: 20),
  CatalogTask('Play & Activity', 'Draw or colour', 'Make something with colours.', 4, minutes: 15),
  CatalogTask('Play & Activity', 'Ride a bike or scooter', 'Wear the helmet first.', 5, minutes: 20),
  CatalogTask('Play & Activity', 'Build with blocks', 'Build something and tell us about it.', 4, minutes: 15),
  CatalogTask('Play & Activity', 'Play a board game', 'A turn-taking game with the family.', 4, minutes: 20),
  CatalogTask('Play & Activity', 'Listen to calm music', 'Sit quietly and listen.', 3, minutes: 10),

  // Social & Skills
  CatalogTask('Social & Skills', 'Say please and thank you', 'Use kind words today.', 3),
  CatalogTask('Social & Skills', 'Wait for my turn', 'Wait calmly without interrupting.', 4),
  CatalogTask('Social & Skills', 'Listen the first time', 'Do what I am asked the first time.', 4),
  CatalogTask('Social & Skills', 'Share with someone', 'Share a toy or a snack.', 4),
  CatalogTask('Social & Skills', 'Say sorry when I am wrong', 'A kind and honest sorry.', 4),
  CatalogTask('Social & Skills', 'Tell someone how I feel', 'Use words for my feelings.', 4),
  CatalogTask('Social & Skills', 'Help someone', 'Do something kind for another person.', 4),
  CatalogTask('Social & Skills', 'Finish what I started', 'Stay with a task until it is done.', 5, minutes: 15),
  CatalogTask('Social & Skills', 'Ask for help politely', 'Ask when something is hard.', 3),
  CatalogTask('Social & Skills', 'Use my inside voice', 'Speak calmly at home.', 3),
];
