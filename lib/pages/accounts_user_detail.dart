import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:grimm_scanner/models/grimm_user.dart';
import 'package:grimm_scanner/pages/update_account.dart';

class UserDetail extends StatefulWidget {
  static const routeName = "/users/detail";

  const UserDetail({Key? key}) : super(key: key);

  @override
  _UserDetailState createState() => _UserDetailState();
}

class _UserDetailState extends State<UserDetail> {
  bool isAdmin = false;
  bool isObjectManager = false;
  bool isMember = false;

  @override
  Widget build(BuildContext context) {
    var userUID;
    userUID = ModalRoute.of(context)!.settings.arguments as String;
    print(userUID);

    return Scaffold(
        appBar: AppBar(
          title: const Text("Détails de l'utilisateur"),
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
        ),
        backgroundColor: Theme.of(context).primaryColor,
        body: Container(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 20.0),
                Container(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(userUID)
                        .snapshots(),
                    builder: buildUserDetails,
                  ),
                ),
                const SizedBox(height: 60.0),
              ],
            ),
          ],
        )));
  }

  Widget buildUserDetails(
      BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
    print(snapshot.data);
          
    if (snapshot.hasData) {
      if (snapshot.data!.data() != null) {
        GrimmUser user = GrimmUser.fromJson(snapshot.data);
        String status;
        if (user.enable == true) {
          status = "Actif";
        } else {
          status = "Inactif";
        }
        print(user);
        return Container(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              Text(
                "Informations",
                style: TextStyle(
                  fontFamily: "Raleway-Regular",
                  fontSize: 30.0,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 50,
              ),
              Text("Nom : " + user.name,
                  style: TextStyle(color: Colors.black, fontSize: 14)),
              const SizedBox(height: 20.0),
              Text("Prénom : " + user.firstname,
                  style: TextStyle(color: Colors.black, fontSize: 14)),
              const SizedBox(height: 20.0),
              Text("Email : " + user.email,
                  style: TextStyle(color: Colors.black, fontSize: 14)),
              const SizedBox(height: 20.0),
              Text("Statut : " + status,
                  style: TextStyle(color: Colors.black, fontSize: 14)),
              const SizedBox(height: 20.0),
              //Text("Compte actif : " + user.enable.toString(),
              //    style: TextStyle(color: Colors.black, fontSize: 14)),
              //const SizedBox(height: 20.0),
              /*CheckboxListTile(
                title: const Text("Administrateur"),
                tileColor: Theme.of(context).primaryColor,
                checkColor: Colors.white,
                activeColor: Colors.black,
                value: isAdmin,
                onChanged: null,
              ),
              CheckboxListTile(
                title: const Text("Responsable inventaire"),
                tileColor: Theme.of(context).primaryColor,
                checkColor: Colors.white,
                activeColor: Colors.black,
                value: isObjectManager,
                onChanged: null,
              ),
              CheckboxListTile(
                title: const Text("Membre"),
                tileColor: Theme.of(context).primaryColor,
                checkColor: Colors.white,
                activeColor: Colors.black,
                value: isMember,
                onChanged: null,
              ),*/
              const SizedBox(
                height: 20,
              ),
               ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                  textStyle: TextStyle(fontFamily: "Raleway-Regular",
                      fontSize: 14.0),
                  side: const BorderSide(width: 1.0, color: Colors.black),
                  padding: EdgeInsets.all(20.0),

                ),
                onPressed: () async {
                   Navigator.pushNamed(context, UserUpdate.routeName,
                      arguments: user);
                },
                child: Text("Modifier le profil")),
            SizedBox(
              height: 20,
            ),
              /*MaterialButton(
                  color: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  onPressed: () {},
                  child: Text(
                    "Delete user",
                    style: TextStyle(color: Colors.white),
                  ),
                )*/
            ]));
      } else {
        return Text(
            "Pas d'utilisateur trouvé, erreur. Veuillez contacter les développeurs");
      }
    }
    return Text(
        "Pas d'utilisateur trouvé, erreur. Veuillez contacter les développeurs");
  }
}
