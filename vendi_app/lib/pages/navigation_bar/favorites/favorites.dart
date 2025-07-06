import 'package:flutter/material.dart';
import 'package:vendi_app/backend/classes/user.dart';
import 'package:vendi_app/pages/navigation_bar/locations/widgets/machine_bottom_sheet.dart';
import '../../bottom_nav/backend/classes/machine.dart';
import 'package:google_fonts/google_fonts.dart';

// All code on this page was developed by the team using the flutter framework
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritesPage> {
  Future<List<Machine>>? favMachines;

  @override
  void initState() {
    super.initState();
    favMachines = getMachinesFavorited();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              height: 32,
            ),
          ],
        ),
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FutureBuilder<List<Machine>>(
        future: favMachines,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Loading favorites...',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Error Loading Favorites",
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            final favMachines = snapshot.data!;
            if (favMachines.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 80,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No Favorite Machines",
                      style: GoogleFonts.roboto(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Add machines to favorites to see them here",
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      'My Favorites',
                      style: GoogleFonts.bebasNeue(
                        fontSize: 36,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: favMachines.length,
                      itemBuilder: (context, index) {
                        // Determine color based on machine icon (matching machine_bottom_sheet.dart)
                        Color iconBgColor = favMachines[index].icon ==
                                'assets/images/BlueMachine.png'
                            ? Colors.blue.withOpacity(0.2)
                            : favMachines[index].icon ==
                                    'assets/images/PinkMachine.png'
                                ? Colors.pink.withOpacity(0.2)
                                : Colors.amber.withOpacity(0.2);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Card(
                            color: Theme.of(context).cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 6,
                            shadowColor:
                                Theme.of(context).shadowColor.withOpacity(0.3),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => showModalBottomSheet(
                                context: context,
                                builder: (context) =>
                                    MachineBottomSheet(favMachines[index]),
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                isDismissible: true,
                                enableDrag: true,
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: iconBgColor,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.asset(
                                        favMachines[index].icon,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            favMachines[index].name,
                                            style: GoogleFonts.roboto(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge
                                                  ?.color,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Floor: ${favMachines[index].desc}',
                                            style: GoogleFonts.roboto(
                                              fontSize: 14,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color
                                                  ?.withOpacity(0.8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.favorite,
                                        color: Colors.red,
                                      ),
                                      onPressed: () =>
                                          onDeletePressed(favMachines[index]),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Error Loading Favorites",
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  void onDeletePressed(Machine machine) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => DeleteMachineDialog(machine: machine),
    );
    if (result != null && result) {
      await removeMachineFromFavorited(machine.id);
      setState(() {
        //Scan for favorites again after deletion
        favMachines = getMachinesFavorited();
      });
    }
  }
}

class DeleteMachineDialog extends StatelessWidget {
  final Machine machine;

  const DeleteMachineDialog({Key? key, required this.machine})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      buttonPadding: EdgeInsets.all(15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 10,
      title: Row(
        children: [
          Icon(
            Icons.favorite_border,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(width: 10),
          Text(
            'Remove Favorite',
            style: GoogleFonts.roboto(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
      content: Text(
        'Are you sure you want to remove ${machine.name} from your favorites?',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: Theme.of(context).colorScheme.primary,
          ),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            removeMachineFromFavorited(machine.id);
            Navigator.of(context).pop(true);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Remove'),
        ),
      ],
    );
  }
}
