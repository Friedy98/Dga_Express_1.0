
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:smart_shop/Common/Widgets/gradient_header.dart';
import 'package:smart_shop/Utils/font_styles.dart';
import 'package:smart_shop/screens/Login/login.dart';

import 'package:http/http.dart' as http;
import 'dart:io' as plateform;

import 'package:smart_shop/screens/Services/delayed_animation.dart';

import '../../main.dart';

// ignore: must_be_immutable
class SignUp extends StatefulWidget {
  static const String routeName = 'signup';
  const SignUp({Key? key}) : super(key: key);


  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  bool isChecked = false;
  bool isButtonActive = true;
  double value = 0;
  bool showbackArrow = true;
  final storage = const FlutterSecureStorage();


  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController pseudoController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController telController = TextEditingController();
  TextEditingController confirmpasswordController = TextEditingController();

  String? selectedValue;
  String? selectedValue2;
  int activeIndex = 0;
  int totalIndex = 2;
  String? code = "";
  String? number = "";


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(context),
      bottomSheet: _buildBottomSheet(context),
    );
  }

  Widget _buildBottomSheet(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50.0.h,
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0.r),
          topRight: Radius.circular(20.0.r),
        ),
      ),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("D??j?? un utilisateur?",
              style: FontStyles.montserratBold17().copyWith(
                  color: Colors.white)),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                PageTransition(type: PageTransitionType.fade,duration: const Duration(milliseconds: 500),
                    child: const login()),
              );
            },
            child: Text(
              "Sign In",
              style: FontStyles.montserratRegular17().copyWith(color: Colors.cyanAccent, decoration: TextDecoration.underline),
            )
          ),
        ],
      ),
    );
  }
  //static Box box = Hive.box('user_box');

  submitData() async{
    var headers = {
      'Content-Type': 'application/json'
    };
    var request = http.Request('POST', Uri.parse('${Domain.dgaExpressPort}signup'));
    request.body = json.encode({
      "firstName": firstNameController.text,
      "lastName": lastNameController.text,
      "profileimgage": "",
      "pseudo": pseudoController.text,
      "phone": telController.text,
      "email": emailController.text,
      "password": passwordController.text
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {

      await response.stream.bytesToString();

      Navigator.push(
        context,
        PageTransition(type: PageTransitionType.fade,duration: const Duration(milliseconds: 500),
            child: const login()),
      );

      MotionToast.success(
        description:  Text("Registrer Sucessful", style: FontStyles.montserratRegular17().copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold)),
        width:  300,
        height: 90,
      ).show(context);

    }else if(response.statusCode == 500){
      Fluttertoast.showToast(
          msg: "User Already Exists!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 20.0
      );
    }
    else {
      final error = await response.stream.bytesToString();
      var errorMessage = json.decode(error)["error"];

      MotionToast.error(
        description:  Text(errorMessage, style: FontStyles.montserratRegular17().copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold)),
        width:  300,
        height: 90,
      ).show(context);

    }
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(context),
          _buildSignUpBody(context),
        ],
      ),
    );
  }

  Widget _buildSignUpBody(BuildContext context){
    switch (activeIndex){
      case 0:
        return _buildForm(context);
      case 1:
        return _buildSecondForm(context);

      default:
        return _buildForm(context);
    }
  }

  Widget _buildHeader(BuildContext context) {
    return AppHeaderGradient(
      fixedHeight: MediaQuery.of(context).size.height * .20,
      isProfile: false,
      text: 'Enregistrement',
    );
  }

  RegExp pass_valid = RegExp(r"(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*\W)");
  double password_strength = 0;

  bool validatePassword(String pass){
    String _password = pass.trim();
    if(_password.isEmpty){
      setState(() {
        password_strength = 0;
      });
    }else if(_password.length < 6 ){
      setState(() {
        password_strength = 1 / 4;
      });
    }else if(_password.length < 8){
      setState(() {
        password_strength = 2 / 4;
      });
    }else{
      if(pass_valid.hasMatch(_password)){
        setState(() {
          password_strength = 4 / 4;
        });
        return true;
      }else{
        setState(() {
          password_strength = 3 / 4;
        });
        return false;
      }
    }
    return false;
  }

  final _formKey = GlobalKey<FormState>();
  bool isValidForm = false;
  bool _isObscure = true;
  bool isloading = false;
  String phoneNumber = "";

  Widget _buildForm(BuildContext context) {

    return Form(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10.0),
                DelayedAnimation(
                    delay: 300,
                    child: TextFormField(
                      controller: firstNameController,
                      autofocus: false,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                        hintText: 'Entrez Nom',
                        labelText: 'Nom',
                        icon: const Icon(Icons.person),
                      ),
                      validator: (inputValue){
                        if(inputValue!.isEmpty ) {
                          return "field Required!";
                        }
                      },
                    ),
                ),

                const SizedBox(height: 10.0),
                DelayedAnimation(delay: 500,
                    child: TextFormField(
                      controller: lastNameController,
                      autofocus: false,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                        hintText: 'Entrez Pr??nom',
                        labelText: 'Pr??nom',
                        icon: const Icon(Icons.person_pin_outlined),
                      ),
                      validator: (inputValue){
                        if(inputValue!.isEmpty ) {
                          return "field Required!";
                        }
                      },
                    ),
                ),
                const SizedBox(height: 10.0),
                DelayedAnimation(delay: 700,
                    child: TextFormField(
                      controller: pseudoController,
                      autofocus: false,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                        hintText: 'Entrez Pseudo',
                        labelText: 'Pseudo',
                        icon: const Icon(Icons.person_pin_rounded),
                      ),
                      validator: (inputValue){
                        if(inputValue!.isEmpty ) {
                          return "field Required!";
                        }
                      },
                    ),
                ),
                const SizedBox(height: 10.0),
                DelayedAnimation(delay: 900,
                    child: IntlPhoneField(
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                        hintText: '+237 655333333',
                        labelText: 'T??l??phone',
                        icon: const Icon(Icons.phone),
                      ),
                      initialCountryCode: 'IN',
                      onChanged: (phone) {
                        phoneNumber = phone.completeNumber;
                        telController.text = phoneNumber;
                      },
                    ),
                ),
                const SizedBox(height: 10.0),
                DelayedAnimation(delay: 1100,
                    child: TextFormField(
                      controller: emailController,
                      autofocus: false,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                        hintText: 'Entrez E-mail',
                        labelText: 'E-mail',
                        icon: const Icon(Icons.mail_rounded),
                      ),
                      validator: (inputValue){
                        if(inputValue!.isEmpty ) {
                          return "field Required!";
                        }
                      },
                    ),
                ),
                const SizedBox(height: 10.0),
                DelayedAnimation(delay: 1300,
                    child: TextFormField(
                      controller: passwordController,
                      obscureText: _isObscure,
                      autofocus: false,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                        hintText: 'Mot de Pass',
                        labelText: 'Mot de Pass',
                        filled: true,
                        icon: const Icon(Icons.lock),
                      ),
                      validator: (inputValue){
                        if(inputValue!.isEmpty){
                          return "Please Enter Password";
                        }else{
                          bool result = validatePassword(inputValue);
                          if(result){
                            // create account event
                            return null;
                          }else{
                            return " Password should contain Capital, small letter & Number & Special";
                          }
                        }
                      },
                    ),
                ),
                const SizedBox(height: 10.0),
                DelayedAnimation(delay: 1300,
                    child: TextFormField(
                      controller: confirmpasswordController,
                      obscureText: _isObscure,
                      autofocus: false,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                        hintText: 'Confirmer Mot de Pass',
                        labelText: 'Confirmer Mot de Pass',
                        filled: true,
                        icon: const Icon(Icons.lock),
                        suffixIcon: IconButton(onPressed: (){
                          setState(() {
                            _isObscure = !_isObscure;
                          });
                        }, icon: Icon(
                            _isObscure ? Icons.visibility : Icons.visibility_off),
                        ),
                      ),
                      validator: (inputValue){
                        if(inputValue!.isEmpty){
                          return "Field Required";
                        }if(inputValue != passwordController.text){
                          return "Not Match";
                        }
                        else{
                          bool result = validatePassword(inputValue);
                          if(result){
                            // create account event
                            return null;
                          }else{
                            return " Password should contain Capital, small letter & Number & Special";
                          }
                        }
                      },
                    ),
                ),
                DelayedAnimation(delay: 1500,
                    child: Row(
                      children: <Widget>[
                        Checkbox(
                          value: isChecked,
                          onChanged: (value) {
                            setState(() {
                              isChecked = value!;
                            });
                          },
                        ),
                        const Text('J\'accepte ',style: TextStyle(fontSize: 18.0), ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              activeIndex++;
                            });
                          },
                          child: Text(
                            'Terms & Conditions',
                            overflow: TextOverflow.ellipsis,
                            style: FontStyles.montserratRegular17().copyWith(color: Colors.blue, decoration: TextDecoration.underline),
                          ),
                        ),
                      ],
                    ),
                ),
                DelayedAnimation(delay: 1700,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(150, 40),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15))),
                      onPressed:isChecked?() async{
                        if(_formKey.currentState!.validate() && isChecked == true){
                          isValidForm = true;
                          setState(() => isloading = true);
                          await submitData();
                          setState(() => isloading = false);
                        } else{
                          setState(() {
                            isValidForm = false;
                          });
                        }
                      } : null,
                      child: (isloading)
                          ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 1.5,
                          )) : Text("Valider", style:
                      FontStyles.montserratRegular17().copyWith(color: Colors.white)),
                    ),
                ),

                const SizedBox(height: 30.0),
              ],
            ),
          ),
        )
    );
  }

  Widget _buildSecondForm(BuildContext context){
    return SingleChildScrollView(
        key: _formKey,
      child: Container(
        margin: EdgeInsets.only(left: 10.0.w, right: 10.w, top: 8.0.h, bottom: 10.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: (){
                    setState(() {
                      activeIndex--;
                    });
                  },
                  icon: Icon( showbackArrow ? plateform.Platform.isIOS
                      ? Icons.arrow_back_ios
                      : Icons.arrow_back : null,
                  ),
                ),
                Text("Termes & conditions",
                    style: FontStyles.montserratRegular19().copyWith(color: Colors.blue, fontWeight: FontWeight.bold)
                ),
              ],
            ),
            const SizedBox(height: 15),
            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "Avant propos",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue, fontWeight: FontWeight.bold)),
                  TextSpan(text: " \n Vous etes pri?? de  lire attentivement  les  conditions g??n??rales d???utilisation de cette  plateforme . "
                      "Ces derni??res contiennent des informations concernant vos droits, obligations et recours l??gaux. En acc??dant ?? la Plateforme DGA-EXPRESS ainsi qu???a son application mobile,"
                      " vous acceptez d?????tre li?? par ses normes d???utilisations  et vous y conformer"
                      "En outre, les pr??sentes Conditions constituent un accord juridique contraignant qui vous lie ?? DGA-EXPRESS  (tel que d??fini ci-dessous)"
                      " et qui r??git votre acc??s au site DGA-EXPRESS ainsi qu????? son application , y compris ses sous-domaines ( plateformes E-commerce )  et tous les autres sites par le biais desquels"
                      "DGA-EXPRESS fournit les services .  nos applications pour mobiles, tablettes , smartphones et les interfaces de programme d???application , ainsi que tous les services associ??s ."
                      "Le Site, l???Application et les Services DGA-EXPRESS sont collectivement d??sign??s dans ses diff??rentes plateformes."
                      " ????DGA-EXPRESS???? dont le si??ge social est situ?? ?? la rue d???arquet 64,5000 Namur  immatricul?? au......................"
                      " Disposant un  points de relais dans la ville de bruxelle ?? l???adress rue des tanneurs 130 , 1000 bruxelles ."
                      "La mani??re dont nous collectons et utilisons des donn??es ?? caract??re personnel en lien avec votre acc??s ?? nos Plateformes  et votre"
                      "utilisation de ladite Plateforme est d??crite dans notre Charte??Cookies.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "1. OBJET",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue, fontWeight: FontWeight.bold)),
                  TextSpan(text: " \n La Plateforme est une place de march?? en ligne, un espace interactif d?????changes personnalis??s, facilitant la mise en relation des diff??rents acteurs de l???industrie du voyage d???une part et un espace E-commerce d???autre part . Cette Plateforme a pour objectif principal de participer ?? la r??duction des co??ts lors des voyages en maximisant le gain potentiel "
                      "pour une ??conomie solidaire de partage, elle offre ??galement des possibilt??s d???achats et de ventes des articles de pr??mi??res necessit??s pouvant faire office de cadeaux "
                      "Les pr??sentes Conditions s???appliquent aux services propos??s sur la Plateforme et tout particuli??rement sur le site et l???application  www.DGA_EXPRESS.com   Il s???agit de mani??re non exhaustive, des services d???envoi"
                      "de colis, de courriers et/ou de bagages (ci-apr??s ensemble ????Bagages????), de la mise en relation d???Exp??diteurs et de Voyageurs dans le stricte respect des r??gles de transport a??rien ??dict??es par les compagnies a??riennes, assorti de la collecte"
                      " d???une Participation aux Frais des Voyageurs au travers de la Plateforme ainsi qu???une plateformes E-commerce (permettant aux voyageurs , expediteurs d???offrir un present ?? leurs proches , de completer leurs bagages et aux ti??rces utilisateurs de s???offrir les articles de leurs choix ?? des moindres prix)  d???un syst??me de notation des Voyageurs et commercants"
                      "Ainsi, ne sont pas admis au transport aux travers des Plateformes les objets suivants : armes, explosifs, armes et objets coupants, produits combustibles, bouteilles de gaz, thermom??tres ?? mercure, allumettes, briquets ou tout autre petit combustible, cartouches d???imprimantes, batteries ?? ??lectrolyte, batteries au lithium,"
                      "produits chimiques exceptionnels du type engrais pesticides et d??sherbants, produits liquides d??capants et tout autre produit ou marchandise consid??r??e comme ??tant dangereuse et dont le transport est interdit par la compagnie a??rienne emprunt??e."
                      "Tout autre produit dont le transport par voie a??rienne n???est pas sp??cifiquement interdit par les r??gles d???aviation civile et la compagnie a??rienne emprunt??e peut ??tre transport?? par le biais des Membres des difeerentes Plateformes (cl??s, v??tements, boissons, appareils ??lectroniques, etc.)."
                      "Toute action de connexion, d???inscription et de t??l??chargement effectu??e sur la Plateforme conduit automatiquement ?? l???acceptation des pr??sentes Conditions et vous permet de recevoir les offres commerciales, les publicit??s et les newsletters pendant toute la dur??e de votre adh??sion ?? nos Plateformes ( site et Application mobile)",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "2. D??FINITIONS",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue, fontWeight: FontWeight.bold)),
                  TextSpan(text: " \n Dans les pr??sentes,"
                      "????Annonce???? d??signe toute publication d???un Voyageur, visant ?? proposer un service pour le transport  colis (vendu au kilogrammes), courriers, ventes des articles (reserver ?? la plateforme E-commerce )"
                      "????Application???? d??signe un logicie applicatif d??v??lopp?? pour des appareils mobiles, tablettes et smartphone t??l??chargeable sur l'App Store et/ou sur Google Play, ainsi que les interfaces des programmes d???application ;"
                      "????Attestation de Remise de Bagages???? d??signe le contrat par lequel le Voyageur atteste avoir re??u le Bagage, avoir v??rifi?? son contenu et s???engage ?? en ??tre le Gardien et ?? le remettre au Destinataire ou dans un point de relais DGA-EXPRESS"
                      "????Bagage???? d??signe, sans que cette liste ne soit exhaustive, le (s) bien (s), colis, courriers, ou tout(t)(s) autre(s) objet(s) r??glement??(s) convoy??(s) par le Voyageur et confi??(s) ?? l???Exp??diteur ;"
                      " ????CGU???? d??signe les pr??sentes Conditions G??n??rales d???Utilisation y compris la charte de bonne conduite ci-apr??s ;"
                      " ????Compte???? d??signe un ensemble des ressources informatiques attribu??es ?? un utilisateur ou ?? un appareil. Il ne peut etre exploiter qu???en s???enregistrant aupres d???un syst??me ?? l???aide d???un identifiant et d???un  authentifiant tel qu???un mot de passe qui doit ??tre cr???? pour pouvoir devenir Membre et acc??der aux services propos??s par la Plateforme sous r??serve du respect de certaines conditions ;"
                      "????Destinataire???? est la personne indiqu??e par l???Exp??diteur ?? qui le Voyageur doit remettre en mains propres le bien convoy??, dans le cas o?? celui-ci n???est pas confisqu?? en douanes ;"
                      "????Envoi???? faire partir l???objet via  Espace publi?? par un Exp??diteur sur la Plateforme et pour lequel il souhaite exp??dier des Bagages via un tiers en contrepartie de la Participation aux Frais de ce dernier ;"
                      "????Espace???? d??signe le nombre de Kg r??serv?? par un Exp??diteur ?? bord d???une ou plusieurs valises d???un Voyageur ;"
                      "????Exp??diteur???? d??signe le Membre ayant accept?? la proposition d???exp??dier ses Bagages par le Voyageur ou, le cas ??ch??ant, la personne pour le compte de laquelle un Membre a r??serv?? un Espace ;"
                      "????Frais de Service???? d??signent des sommes d???argent correspondant ?? la commission demand??e par DGA-EXPRESS pour la mise en relation, lorsque le Membre de la Plateforme d??cide de passer par un autre Membre de la Plateforme au travers d???un Trajet avec R??servation, cette commission ??tant ??nonc??e de mani??re pr??cise et visible dans l???Annonce et accept??e par l???Exp??diteur ;"
                      "????Gardien???? ou ????Gardien de la chose???? d??signe la notion de droit selon laquelle une personne est r??put??e ??tre gardienne d???une chose lorsqu???elle a, sur cette chose, en l???occurrence ici le Bagage, un pouvoir d???usage, de direction et de contr??le, et qu???en cons??quence, qu???elle puisse ??tre consid??r?? comme ayant la responsabilit?? juridique sur cette chose, ici le Bagage, pendant la dur??e au courant de laquelle le Bagage est en sa possession, pour tous dommages auquel ce Bagage pourrait ??tre expos??."
                      "????Membre???? d??signe toute personne physique ayant cr???? un compte sur les Plateformes DGA-EXPRESS ;"
                      "????Participation aux Frais???? est la somme d???argent demand??e par le Voyageur et accept??e par l???Exp??diteur au titre de sa participation aux frais de d??placement pour un trajet donn????"
                      "????Plateforme???? emplacement d??di?? ?? recevoir des annonces de voyages et autres"
                      "????DGA ?? Darling global African Express ."
                      "????DGA-EXPRESS???? plateforme de mise en relation entre particuliers  pour l???acheminement des colis/courriers faisant l???objet d???une annonce publi??e par un Voyageur pour lequel il accepte de transporter ces colis/courriers en contrepartie de paiements ;"
                      "????R??servation???? action qui consiste ?? retenir une place pour bagage dans l???annonce d???un voyageur  (    ;"
                      "????Services????  l???ensemble des devoirs rendus au moyen de la Plateforme ?? un Membre tel qu?????nonc?? plus haut dans les conditions, ??tant pr??cis?? que DGA-EXPRESS  n???est pas partie prenante dans un contrat d???envoi de colis ou de marchandises ;"
                      "????Site???? plateforme  accessible ?? l???adresse??www.DGA_EXPRESS.com??ou tout autre site par lequel DAGA-EXPRESS fournit ses Services ;"
                      "????Sous-Trajet???? Parcours d???un point ?? un autre ;"
                      "????Trajet???? d??signe le point de depart ( ville -pays ) et le point d???arriv??e (destination) faisant l???objet d???une Annonce publi??e par un Voyageur sur la Plateforme et pour lequel il accepte de transporter des Bagages de tiers en contrepartie de la Participation aux Frais ;"
                      "????Voyageur???? est le Membre proposant sur la Plateforme, un certain nombre de Kg pour le transport de marchandises en avion pour un trajet pr??cis .",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),

                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "3. ACCEPTATION ET MODIFICATIONS DES CONDITIONS",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue, fontWeight: FontWeight.bold)),
                  TextSpan(text: "\n 3.1. ACCEPTATION DES CONDITIONS",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n L???acceptation de nos Conditions vous donne droit ?? l???inscription et/ou au t??l??chargement de l???Application ?? partir de votre t??l??phone mobile ou via internet de mani??re gratuite. L\'utilisation de la Plateforme est subordonn??e ?? l\'acceptation des pr??sentes Conditions. Au moment de la cr??ation du compte utilisateur, les Membres acceptent les Conditions en ouvrant l???Application et/ou en cliquant sur le bouton [\'Confirmer l???inscription\']. Seule l\'acceptation de ces Conditions permet aux Membres d\'acc??der aux services propos??s sur la Plateforme. L\'acceptation des pr??sentes Conditions est enti??re et forme un tout indivisible, et les Membres ne peuvent choisir de voir appliquer une partie des Conditions seulement ou encore formuler des r??serves. En acceptant les Conditions, le Membre accepte ??galement la Charte de bonne conduite qui y est annex??e. En cas de manquement ?? l\'une des obligations pr??vues par les pr??sentes, DGA-EXPRESS se r??serve la possibilit?? de supprimer le Compte Utilisateur concern??.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "3.2. MODIFICATION DES CONDITIONS",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n DGA-EXPRESS   se r??serve le droit de modifier ?? tout moment les Conditions, les fonctionnalit??s offertes sur la Plateforme ou les r??gles de fonctionnement de cette derni??re. Les modifications prendront effets  imm??diatement d??s la mise en ligne des Conditions, avec mention de la date de mise ?? jour, que tout utilisateur reconna??t avoir pr??alablement consult??es. Les publications d'Annonces au moyen des Plateformes sont totalement gratuite. La consultation d???Annonce et la mise en relation entre les deux parties en sont de m??me. Toutefois, DGA-EXPRESS se r??serve notamment le droit de prendre une commission, des Frais de Service, ?? tout moment, qui repr??sentera un pourcentage sur la transaction qui sera effectu??e au travers de ses Plateformes, pour les Trajets avec R??servation. DGA-EXPRESS   pourra aussi ?? tout moment proposer des services nouveaux, gratuits ou payants sur la Plateforme.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "4. INSCRIPTION ?? LA PLATEFORME ET CR??ATION DE COMPTE",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue, fontWeight: FontWeight.bold)),
                  TextSpan(text: "\n 4.1. CONDITIONS D'INSCRIPTION ?? LA PLATEFORME",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n L???utilisation de la Plateforme est r??serv??e aux personnes physiques ??g??es d???au moins dix-huit (18) ans r??volus ?? la date d???utilisation. Toute inscription sur la Plateforme par une personne physique ??g??e de moins de (dix-huit) 18 ans est strictement interdite. En acc??dant, ou en  vous inscrivant sur la Plateforme, vous d??clarez et garantissez avoir 18 ans ou plus.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "4.2. CR??ATION DE COMPTE",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n Chaque Membre doit au pr??alable cr??er un Compte, en fournissant des donn??es personnelles le concernant, indispensables au bon fonctionnement du service de mise en relation des personnes (notamment nom, pr??nom, civilit??, num??ro de t??l??phone et adresse e-mail valides, adress de residence, preuve de reservation, pi??ce  d???identit?? : CNI,passeport ). Nous ne pourrons en aucun cas ??tre tenue responsable des informations qui pourraient ??tre erron??es ou frauduleuses communiqu??es par les Membres. Le Membre s'engage ?? ne pas cr??er ou utiliser d'autres comptes que celui initialement cr????, que ce soit sous sa propre identit?? ou celle des tiers. Toute d??rogation ?? cette r??gle devra faire l'objet d'une demande explicite de la part du Membre et d'une autorisation express et sp??cifique de Notre part. Le fait de cr??er ou utiliser de nouveaux comptes sous sa propre identit?? ou celle de tiers sans en avoir demand?? et obtenu l'autorisation pourra entra??ner non seulment une poursuite judiciaire , mais aussi la suspension imm??diate des comptes du Membre et de tous les services associ??s"
                      "Par ailleurs, il est permis de consulter les Annonces m??me si vous n?????tes pas inscrit sur la Plateforme. En revanche, vous ne pouvez ni publier une Annonce ni r??server un Espace sans avoir, au pr??alable, cr???? un Compte et ??tre devenu Membre."
                      "Pour cr??er votre Compte, vous pouvez :",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                  TextSpan(text: " \n ???  soit remplir l???ensemble des champs obligatoires figurant sur le formulaire d???inscription ;telecharger tous les documents demand??s. La verification de compte est obligatoire par une photo d???identification . le compte ne sera en aucun cas cr??er si tous les informations d??mand??es ne sont pas renseign??es . "
                      " \n ???  soit vous connecter, via notre Plateforme, ?? votre compte Facebook (ci-apr??s, votre ????Compte Facebook????). En utilisant une telle fonctionnalit??, vous comprenez que Nous aurons acc??s, publierons sur la Plateforme et conserverons certaines informations de votre Compte Facebook. Vous pouvez ?? tout moment supprimer le lien entre votre Compte et votre Compte Facebook par l???interm??diaire de la rubrique ?? V??rifications ?? de votre profil. Si vous souhaitez en savoir plus sur l???utilisation de vos donn??es dans le cadre de votre Compte Facebook, nous vous invitons ?? consulter notre politique de confidentialit?? et celle de Facebook.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                  TextSpan(text: " \n A l???occasion de la cr??ation de votre Compte, et ce, quelle que soit la m??thode choisie pour ce faire, vous vous engagez ?? fournir des informations personnelles exactes et conformes ?? la r??alit?? et ?? les mettre ?? jour, par l???interm??diaire de votre profil ou en en avertissant DGA-EXPRESS, afin d???en garantir la pertinence et l???exactitude tout au long de votre relation contractuelle avec Nous."
                      "En cas d???inscription par email, vous vous engagez ?? garder secret le mot de passe "
                      "choisi lors de la cr??ation de votre Compte et ?? ne le communiquer ?? personne. En cas de perte ou divulgation de votre mot de passe, vous vous engagez ?? en informer sans d??lai DGA-EXPRESS, qui vous permettra alors de r??initialiser votre mot de passe. Vous ??tes seul responsable de l???utilisation faite de votre Compte par un tiers, tant que vous n???avez pas express??ment notifi?? DGA-EXPRESS  de la perte, de l???utilisation frauduleuse par un tiers et/ou de la divulgation de votre mot de passe ?? un tiers."
                      "Vous vous engagez ?? ne pas cr??er ou utiliser, sous votre propre identit?? ou celle d???un tiers, d???autres Comptes que celui initialement cr????.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "4.3. V??RIFICATION",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n Nous nous r??servons le droit, ?? des fins de transparence, d???am??lioration de la confiance, ou de pr??vention ou d??tection des fraudes, de mettre en place un syst??me de v??rification de certaines des informations que vous fournissez sur votre profil. C???est notamment le cas lorsque vous renseignez votre num??ro de t??l??phone ou vous fournissez une pi??ce d???identit??."
                      "Vous reconnaissez et acceptez que toute r??f??rence sur la Plateforme ?? des informations dites ?? v??rifi??es ?? ou tout terme similaire signifie uniquement qu???un Membre a r??ussi avec succ??s la proc??dure de v??rification existante sur la Plateforme afin de fournir davantage d???informations sur le Membre avec lequel vous envisagez une exp??dition. Nous ne garantissons ni la v??racit??, ni la fiabilit??, ni la validit?? d???une information ayant fait l???objet de la proc??dure de v??rification.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "5. UTILISATION DES SERVICES",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue, fontWeight: FontWeight.bold)),
                  TextSpan(text: " \n 5.1. UTILISATION ?? TITRE NON PROFESSIONNEL ET NON COMMERCIAL POUR LES PARTICULIERS",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n Vous vous engagez ?? n???utiliser les Services et la Plateforme que pour ??tre mis en relation, ?? titre non professionnel et non commercial, avec des personnes souhaitant r??server un Espace sur votre Trajet avec vous. Nous ne pourrons, en aucun cas, ??tre tenus responsables d???une utilisation ?? titre professionnel ou commercial de la Plateforme. Nous consid??rons, de mani??re non exhaustive, comme activit?? professionnelle toute activit?? sur la Plateforme qui, par la nature des services propos??s, leur fr??quence ou le nombre de colis transport??s, entra??nerait une situation de b??n??fice pour le Voyageur. Seul l???option E-COMMERCE de cette plateformes est reconnu ?? titre commercial et professionnel ."
                      "En tant que Voyageur, vous vous engagez ?? ne pas demander une Participation  sup??rieure aux frais que vous supportez r??ellement et susceptible de vous faire g??n??rer un b??n??fice, ??tant pr??cis?? que s???agissant d???un partage de frais, vous devez ??galement, en tant que Voyageur, supporter votre part des co??ts aff??rents au Trajet. Vous ??tes seul responsable d???effectuer le calcul des frais que vous supportez pour le Trajet, et de vous assurer que le montant demand?? ?? vos Exp??diteurs n???exc??de pas les frais que vous supportez r??ellement (en excluant votre part de Participation aux Frais)."
                      "DGA-EXPRESS se r??serve ??galement la possibilit?? de suspendre votre Compte, limiter votre acc??s aux Services ou r??silier votre souscription aux pr??sentes Conditions en cas d???activit?? de votre part sur la Plateforme, qui, du fait de la nature des trajets propos??s, de leur fr??quence, du nombre d???Espaces propos??s ?? la r??servation ou du montant de la Participation aux Frais demand??e, entra??nerait une situation de b??n??fice pour vous ou pour quelque raison que ce soit faisant suspecter ?? DGA-express  que vous g??n??rez un b??n??fice sur la Plateforme.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "5.2. LE SERVICE",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n La Plateforme est un service de mise en relation, par lequel l'Exp??diteur souhaitant effectuer un Envoi contacte le Voyageur pour fixer un lieu de rencontre pour la remise du Bagage ?? envoyer et les ??ventuelles conditions d???envois (volume ou taille des Bagages transport??s, nombre de Kg disponibles, d??lai de livraison, point de livraison, etc.)."
                      "Pour la belgique et le cameroun  tous les colis passer ont dans point de relais DGA-EXPRESS et le voyageur  pourront soient passer reuperer le colis avant son voyage ou alors se faire livr?? ?? domicile contre des frais impos??s par DGA-Express. Une fois au cameroun ou en belgique tous les bagages doivent etre depos??s dans les points de relais le plus proche pour distribution , les voyageurs ne pourront etre r?? num??rer que si les destinataires recoivent leurs colis ou si ce dernier deposer le colis dans un point de relais DGA-EXPRESS"
                      "Lors de la remise du ou des Bagage(s), les Exp??diteurs et Voyageurs concern??s consentent aux termes de l???Attestation de Remise de Bagages produite lors de chaque Confirmation de R??servation et dont le mod??le est t??l??chargeable??dans le mail de confirmation de reservation ."
                      "Par ailleurs, la Plateforme met ?? la disposition de ses Membres des moyens s??curis??s de paiement et se r??serve le droit de percevoir une commission, appel??e Frais de Service, pour les Trajets avec R??servation, ?? charge pour Nous de reverser la somme au Voyageur une fois que le Destinataire confirmera avoir re??u le Bagage. Les annulations de derni??res minutes, le paiement des Frais de Participation, sont alors supervis??es par Nous. Pour autant, Nos Membres souscrivant aux Trajets avec R??servation restent responsables, dans la mesure des dispositions ??nonc??es ?? l\???article 7.1 ci-dessous, dans certains cas d\???annulation, pour lesquels DGA-EXPRESS n\???est nullement responsable."
                      "De la m??me mani??re, les Membres demeurent responsables des risques li??s au transport du ou des Bagage(s), notamment s???agissant du contenu du Bagage, de la perte du Bagage et de la remise du Bagage au Destinataire sauf si les bagages ont ??t?? depos?? dans les points de relais DGA-EXPRESS  pour distribution.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "5.3. PUBLICATION DES ANNONCES",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n En tant que Membre, et sous r??serve que vous remplissiez les conditions ci-dessous, vous pouvez cr??er et publier des Annonces sur la Plateforme en indiquant des informations quant au Trajet que vous comptez effectuer (dates/heures et lieux de d??part et d???arriv??e, nombre de Kg mis ?? disposition, options propos??es, montant de la Participation aux Frais, compagnie de voyage etc.)."
                      "Lors de la publication de votre Annonce, vous pouvez indiquer des villes ??tapes, dans lesquelles vous acceptez de vous arr??ter pour prendre ou d??poser des Bagages. Les tron??ons du Trajet entre ces villes ??tapes ou entre l???une de ces villes ??tapes et le point de d??part ou d???arriv??e du Trajet constituent des ????Sous-Trajets????."
                      "Vous n?????tes autoris?? ?? publier une Annonce que si vous remplissez l???ensemble des conditions suivantes :"
                      "\ ???  Vous ??tes titulaire d???un titre de transport valide (billet d???avion, tickets de train???) ;"
                      "\n ???  Vous ne proposez des Annonces que pour des Trajets dont l???acquisition du titre de transport a ??t?? faite par des moyens licites par vous-m??me ou par un tiers que vous connaissez personnellement ;"
                      "\n ???  Vous ??tes et demeurez le Voyageur, objet de l???Annonce ;"
                      "\n ???  Vous n???avez aucune contre-indication ou incapacit?? m??dicale ?? voyager ;"
                      "\n ???  La compagnie de transport que vous comptez utiliser n???est pas interdite d???exploitation ;"
                      "\n ???  Vous ne comptez pas publier une autre Annonce pour le m??me Trajet sur la Plateforme;"
                      "n ???  Vous n???offrez pas plus d???Espace que celle disponible dans votre valise ;"
                      "\n ???  Vous utilisez une valise en parfait ??tat de fonctionnement, qui ne pr??sente aucun danger ou risque de dommages pour les Bagages des Exp??diteurs ;"
                      "\n ???  Vous acceptez d???assumer la responsabilit?? de Gardien de la chose pour le compte de l???Exp??diteur. A cet effet, vous ??tes responsable du Bagage pendant la dur??e du Trajet et vous vous engagez ?? remettre ledit Bagage en l?????tat, ?? l???arriv??e du Trajet au Destinataire, et ce moyennant Participation de l???Exp??diteur aux Frais de votre voyage."
                      "Vous reconnaissez ??tre le seul responsable du contenu de l???Annonce que vous publiez sur la Plateforme. En cons??quence, vous d??clarez et garantissez l???exactitude et la v??racit?? de toute information contenue dans votre Annonce et vous engagez ?? effectuer le Trajet selon les modalit??s d??crites dans votre Annonce."
                      "Sous r??serve que votre Annonce soit conforme aux CGU, elle sera publi??e sur la Plateforme et donc visible des Membres et de tous visiteurs, m??me non Membre, effectuant une recherche sur la Plateforme. DGA-EXPRESS se r??serve la possibilit??, ?? sa seule discr??tion et sans pr??avis, de ne pas publier ou retirer, ?? tout moment, toute Annonce qui ne serait pas conforme aux pr??sentes Conditions ou qu\???elle consid??rerait comme pr??judiciable ?? son image, celle de la Plateforme ou celle des Services."
                      "Vous reconnaissez et acceptez que les crit??res pris en compte dans le classement et l\???ordre d\???affichage de votre Annonce parmi les autres Annonces rel??vent de la seule politique de DGA-Express",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "5.4. VALIDATION DE L'ANNONCE",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n La validation de l???information par le client, sur la Plateforme d???une publication ou d???une recherche d???Annonce n???est effective que, lorsque les deux acteurs auront rempli toutes les informations n??cessaires ?? savoir : pays et ville de destination, dates de d??part et d???arriv??e, le moyen de transport emprunt??, preuve de reservation (billet d???avion ), pi??ce d???identit?? ( passeport , cni), le nombre de Kg libres ou ?? c??der ainsi que les prix y aff??rents. Toutefois, nous d??clinons toute responsabilit?? subs??quente des al??as qui pourraient survenir lors des rencontres entre clients (arriv??es tardives aux lieux de rendez-vous, oubli d???entrer en contact, etc.).",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "5.5. DUR??E DE L'ANNONCE SUR LA PLATEFORME",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n La dur??e de l???Annonce sur la Plateforme est de trente (30) jours ?? partir de la date de sa mise en ligne sur la plateforme. A l???expiration de celle-ci, cette annonce est automatiquement d??class??e et ne pourra donc plus figurer sur la Plateforme. Cependant, l???Annonce peut toutefois faire l???objet d???un repositionnement ?? l???initiative du Voyageur en utilisant son Compte pr??c??demment cr????. Le nombre de kilogramme  d??clar??s comme disponible par le voyageur diminura aufur et ?? mesure que les reservations se feront sur l???annonce. Une fois la totalit?? de kilo reserver l???annonce sera bloqu??e automatiquement il ne sera plus possible de faire d???autres reservations .",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "5.6. RETRAIT OU ANNULATION DE L'ANNONCE - DELAI DE R??TRACTATION",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n Le retrait ou l???annulation d???une Annonce apr??s publication reste gratuit pendant quarante huit (48) heures ?? compter de l???heure de sa publication ou de mise en ligne. Au-del?? de ces deux (2) heures, elle est assujettie au paiement de la somme de 2 euroS, somme d???argent ?? d??biter lors du prochain achat sur la Plateforme. Cependant, en cas d???annulation de vols ou de changement de la date de voyage par le Voyageur, celui-ci se doit d???informer l???Exp??diteur de la nouvelle date, et convenir avec lui d???une nouvelle r??servation."
                      "Par ailleurs, le retrait ou l\???annulation, sans motif valable, d???une Annonce ayant d??j?? fait l\???objet de r??servation d\???Espace par un Voyageur est assujetti au paiement de la somme de six (6)  euros, somme d\???argent ?? d??biter lors du prochain achat sur la Plateforme . En cas de r??cidive, le Voyageur se verra interdire l\???acc??s ?? la page pour une p??riode minimale de huit  (8) mois.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "5.7. R??SERVATION D'UN ESPACE",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n Les modalit??s de R??servation d???un Espace d??pendent de la nature du Trajet envisag??, DGA-Express ayant mis en place pour certains Trajets un syst??me de r??servation en ligne."
                      "En tant que Membre, et sous r??serve que vous remplissiez les conditions ci-dessous, vous pouvez r??server un Espace sur une Annonce sur la Plateforme en indiquant des informations quant ?? l???Envoi que vous souhaitez effectuer (description du contenu, poids, montant de la Participation aux Frais, date limite de r??ception, options propos??es, etc.)."
                      "Vous n?????tes autoris?? ?? r??server un Espace que si vous remplissez l???ensemble des conditions suivantes :"
                      "\n ???  Vous ne r??servez des Espaces que pour des Envois dont l???acquisition du contenu a ??t?? faite par des moyens licites par vous-m??me ou par un tiers que vous connaissez personnellement ;"
                      "\n ???  Vous ne r??servez des Espaces que pour des Envois dont le contenu est licite et le transport non prohib?? par les compagnies de transport (cf. r??glementation sur le transport a??rien des compagnies objet du Trajet vis??) ;"
                      "\n ???  Vous ??tes et demeurez l???Exp??diteur, objet de l???Espace ;"
                      "\n ???  Vous ne comptez pas r??server un autre Espace pour la m??me Annonce sur la Plateforme ;"
                      "\n ???  Vous ne comptez pas changer le contenu d??crit dans l???Envoi apr??s validation du Voyageur auteur de l???Annonce ;"
                      "\n ???  Vous vous engagez ?? bien conditionner vos Bagages de mani??re ?? ce qu???ils ne pr??sentent aucun danger ou risque de dommages pour la valise du Voyageur ;"
                      "\n ???  Vous vous engagez ?? pr??senter le Contenu de votre Envoi ouvert pour v??rification et contr??le par le Voyageur, faciliter en participant pleinement ?? cet exercice de v??rification de conformit??, valider que le Voyageur a bien contr??l?? et v??rifi?? votre Envoi ;"
                      "\n ???  Vous acceptez de confier la responsabilit?? de Gardien de la chose au Voyageur pour le Bagage ?? transporter par ce dernier, et ce jusqu????? la remise du dit Bagage au Destinataire ( pour tout autres destinations) ou dans un  point de relais DGA ( uniquement applicable en belgique et au cameroun) , dans la ville de destination du Voyageur, ?? son arriv??e du Trajet, moyennant votre Participation aux Frais de son voyage."
                      "\n ???  Vous acceptez ??galement fournir les informations sur vos pi??ces d???identit??es ( CNI, passeport ), en cas de constat d???objets ou produits illicites ( stup??fiants)  dissimul??s dans vos bagages vous serrez tenue pour seul responsable et ferez l???objet des poursuites judiciaires.  "
                      "Vous reconnaissez ??tre le seul responsable du contenu de l???Espace que vous publiez sur la Plateforme. En cons??quence, vous d??clarez et garantissez l???exactitude et la v??racit?? de toute information contenue dans votre Espace et vous engagez ?? effectuer l???Envoi selon les modalit??s d??crites dans votre Espace."
                      "Sous r??serve que votre Espace soit conforme aux Conditions, elle sera publi??e sur l???Annonce choisie et donc visible du Voyageur. Nous nous r??servons la possibilit??, ?? notre seule discr??tion et sans pr??avis, de ne pas publier ou retirer, ?? tout moment, tout Espace qui ne serait pas conforme aux Conditions ou qu???elle consid??rerait comme pr??judiciable ?? son image, celle de la Plateforme ou celle des Services."
                      "Vous reconnaissez et acceptez que les crit??res pris en compte dans le classement et l???ordre d???affichage de votre Espace parmi les autres Espaces rel??vent de la seule politique de DGA-Express",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "5.7.1. Trajet R??serv??",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n Nous avons mis en place un syst??me de r??servation d???Espaces en ligne  pour les Trajets propos??s sur la Plateforme (les ????Trajets avec R??servation????)."
                      "L?????ligibilit?? d???un Trajet au syst??me de R??servation reste ?? notre seule d??cision et nous nous r??servons la possibilit?? de modifier ces conditions ?? tout moment."
                      "Lorsqu???un Exp??diteur est int??ress?? par une Annonce b??n??ficiant de la R??servation, il peut effectuer une demande de R??servation en ligne. Cette demande de R??servation est (i) soit accept??e automatiquement (si le Voyageur a choisi cette option lors de la publication de son Annonce), (ii) soit accept??e manuellement par levoyageur . Au moment de la R??servation, l???Exp??diteur proc??de au paiement en ligne du montant de la Participation renseign?? par le voyageur  et des Frais de Service aff??rents, le cas ??ch??ant. Apr??s v??rification du paiement par DGA-Express et validation de la demande de R??servation par le Voyageur, l???Exp??diteur re??oit une confirmation de R??servation . Si vous ??tes un Voyageur et que vous avez choisi de g??rer vous-m??mes les demandes de R??servation lors de la publication de votre Annonce, vous ??tes tenu de r??pondre ?? toute demande de R??servation dans un d??lai incompressible de deux heures ?? compter de la demande de chaque Exp??diteur. A d??faut, la demande de R??servation expire automatiquement et l???Exp??diteur est rembours?? de l???int??gralit?? des sommes vers??es au moment de la demande de R??servation, le cas ??ch??ant."
                      "De plus, d??s la Confirmation de R??servation et conform??ment aux termes de l???Attestation de Remise de Bagages, le Voyageur devient seul responsable du Bagage en sa qualit?? de Gardien de la Chose transport??e. A cet effet, il s???engage ?? prendre toutes les mesures n??cessaires pour s???assurer de la conformit?? du Bagage ?? transporter et de sa bonne tenue jusqu????? sa remise entre les mains du Destinataire. DGA-Express n???est garant d???aucune r??clamation,, revendication, action ou recours d???un Exp??diteur vers le Voyageur et/ou de tout tiers pour le Bagage transport?? , sauf si le bagage a ??t?? remis ?? un point de r??lais DGA-express au depart ou ?? l???arriv??e . A compter de la Confirmation de la R??servation, nous vous transmettons les coordonn??es t??l??phoniques du Voyageur (si vous ??tes Exp??diteur) ou de l???Exp??diteur (si vous ??tes Voyageur), dans le cas o?? le Membre a donn?? son accord ?? la divulgation de son num??ro de t??l??phone. Vous ??tes d??sormais seuls responsables de l???ex??cution du contrat vous liant ?? l???autre Membre.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "5.7.2. Caract??re nominatif de la r??servation d???Espace et modalit??s d???utilisation des Services pour le compte d???un tiers",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n Toute utilisation des Services, que ce soit en qualit?? d???Exp??diteur ou de Voyageur, est nominative. Le Voyageur comme l???Exp??diteur doivent correspondre ?? l???identit?? communiqu??e ?? DGA-express."
                      "Toutefois . www.DGA-express.com  permet ?? ses Membres de r??server un ou plusieurs Espaces pour le compte d???un tiers. Dans ce cas, vous vous engagez ?? indiquer avec exactitude au Voyageur, au moment de la R??servation, les noms, pr??noms, ??ges et num??ros de t??l??phone de la personne pour le compte de laquelle vous r??servez un Espace. Il est strictement interdit de r??server un Espace pour un mineur. En revanche, il est interdit de publier une Annonce pour un Voyageur autre que vous-m??me."
                      "Ainsi donc, les Membres sont admis ?? r??server un espace pour une Exp??dition concernant un tiers. Par contre, il est formellement interdit de publier une Annonce de voyage alors qu???on ne voyage pas soit m??me. Dans cette hypoth??se, Nous vous invitons ?? encourager le v??ritable Voyageur ?? cr??er son compte sur la Plateforme et ?? publier son voyage ?? partir de son Compte.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "5.8. SYST??ME D'AVIS",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: "\n 5.8.1. Fonctionnement",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n Nous vous encourageons fortement ?? laisser un avis sur un Voyageur (si vous ??tes Exp??diteur) ou un Exp??diteur (si vous ??tes Voyageur) avec lequel vous avez r??serv?? un Espace ou pour lequel vous avez transport?? un Bagage. En revanche, vous n?????tes pas autoris?? ?? laisser un avis sur un autre Exp??diteur, si vous ??tiez vous-m??me Exp??diteur, ni sur un Voyageur avec lequel vous n???avez pas r??serv?? d???Espace."
                      "Votre avis, ainsi que celui laiss?? par un autre Membre ?? votre ??gard, ne sont visibles et publi??s sur la Plateforme qu???apr??s le plus court des d??lais suivants : (i) imm??diatement apr??s que vous ayez, tous les deux, laiss?? un avis ou (ii) pass?? un d??lai de (sept) 7 jours apr??s le premier avis laiss??."
                      "Vous avez la possibilit?? de r??pondre ?? un avis qu???un autre Membre a laiss?? sur votre profil dans un d??lai maximum de (sept) 7 jours suivant la publication de l???avis laiss?? ?? votre ??gard. L???avis et votre r??ponse, le cas ??ch??ant, seront publi??s sur votre profil.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "5.8.2. Mod??ration",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n Vous reconnaissez et acceptez que DGA-express se r??serve la possibilit?? de ne pas publier ou supprimer tout avis, toute question, tout commentaire ou toute r??ponse dont il jugerait le contenu contraire aux pr??sentes Conditions.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "5.8.3. Seuil",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n DGA-EXPRESS se r??serve la possibilit?? de suspendre votre Compte, limiter vos acc??s aux Services ou r??silier vos souscription aux pr??sentes Conditions dans le cas o?? :"
                      "\n - (i) vous avez re??u au moins trois (3) avis mauvaises"
                      "\, -   (ii) la moyenne des avis que vous avez re??us est ??gale ou inf??rieure ?? deux sur cinq (2/5).",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "6. CONDITIONS FINANCI??RES",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n L???acc??s et l???inscription ?? la Plateforme, de m??me que la recherche, la consultation et la publication d???Annonces sont gratuites. En revanche, tout achat et/ou toute R??servation effectu??e sur la Plateforme pour les Trajets R??serv??s sont payants dans les conditions d??crites ci-dessous.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "6.1. PARTICIPATION AUX FRET",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n Le montant de la Participation aux Fret est d??termin?? par vous, en tant que Voyageur, sous votre seule responsabilit??. Il est strictement interdit de tirer le moindre b??n??fice du fait de l???utilisation de notre Plateforme. Par cons??quent, vous vous engagez ?? limiter le montant de la Participation que vous demandez ?? vos Exp??diteurs aux frais que vous supportez r??ellement pour effectuer le Trajet. A d??faut, vous supporterez seul les risques de requalification de l???op??ration effectu??e par l???interm??diaire de la Plateforme."
                      "Lorsque vous publiez une Annonce, DGA-Express vous sugg??re un montant de Participation aux Frais qui tient compte notamment de la nature du Trajet, du moyen de transport et de la distance parcourue. Ce montant est purement indicatif et il vous appartient de le modifier ?? la hausse ou ?? la baisse pour tenir compte des frais que vous supportez r??ellement sur le Trajet. Afin d?????viter les abus, DGA-express  limite les seuils plafonds et planchers du montant de la Participation aux Frais respectivement entre 200 euros Pour un bagage de 23kg.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "6.2. FRAIS DE SERVICE",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n La Plateforme offre aux utilisateurs plusieurs moyens de paiement modernes pour le r??glement des frais de service. Les utilisateurs ont ainsi la possibilit?? de r??gler par :"
                      "\n ???  Carte bancaire (Visa, Master card) ;"
                      "\n ???  PayPal ;"
                      "\n ???  Monnaie ??lectronique fournie par les op??rateurs de t??l??phonie mobile."
                      "\n Le paiement est r??put?? effectif aussit??t apr??s validation du nombre de kilos ou du montant net ?? payer."
                      "Lors des transactions bancaires, les frais de virement relatifs ?? l???interconnexion des banques sont ?? la charge du client."
                      " Dans le cadre des Trajets avec R??servation, DGA-express pr??l??ve, en contrepartie de l???utilisation de la Plateforme, au moment de la R??servation, une commission correspondant ?? des frais de service  calcul??s sur la base du montant de la Participation aux Frais. Les modalit??s de calcul des Frais de Service en vigueur sont d???une part c??t?? exp??diteur 4,50 euros plus TVA, et d???autre part c??t?? Voyageur : 13% de la Participation aux Frais demand?? plus TVA."
                      "Les paiements par carte bancaire seront r??ceptionn??s par Stripe, laquelle d??duira le montant des Frais de Service avant de remettre le montant de la Participation aux Frais au Voyageur."
                      "Les Frais de Service sont per??us par DGA-EXPRESS  pour chaque Espace r??serv?? par un Exp??diteur."
                      "En ce qui concerne les trajets transfrontaliers, veuillez noter que les modalit??s de calcul du montant des Frais de Services et de la TVA applicable varient selon le point de d??part et/ou d???arriv??e du Trajet."
                      "Lorsque vous utilisez la Plateforme pour des Trajets transfrontaliers ou hors de la belgique , les Frais de Services peuvent ??tre factur??s par  DGA-express ",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "6.3. ARRONDIS",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n Vous reconnaissez et acceptez que dga-express  peut, ?? son enti??re discr??tion, arrondir au chiffre inf??rieur ou sup??rieur les Frais de Service et la Participation aux Frais.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "6.4. R??GLEMENT DES FRAIS DE VENTE AU PROFI DU VOYAGEUR",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n Le r??glement des frais s???effectuera soixante-douze (72) heures apr??s la confirmation de l???Exp??diteur. Le Voyageur recevra son paiement via le mod??le de paiement souscrit lors de son inscription sur la Plateforme. Le Voyageur recevra directement la somme r??elle d??duite du pr??l??vement automatique des frais de services de notre part."
                      "Il en est de meme pour les commercants de la rubrique E-commerce ",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "6.4.1. R??glement des frais de vente au profit du Voyageur",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n A la suite du Trajet, les Exp??diteurs disposent d???un d??lai de quarante-huit (48) heures pour pr??senter une r??clamation ?? dga-express. En l???absence de contestation de leur part dans cette p??riode, DGA consid??re la confirmation du Trajet comme ??tant acquise (A compter de cette Confirmation de R??servation, vous disposez, en tant que Voyageur, d???un cr??dit exigible sur votre Compte. Ce cr??dit correspond au montant total pay?? par l???Exp??diteur au moment de la Confirmation de R??servation diminu?? des Frais de Service, c???est-??-dire au montant de la Participation aux Frais pay??e par l???Exp??diteur."
                      "Une fois le Bagage achemin??, le Voyageur doit ensuite proc??der ?? la confirmation de livraison tacite ou expresse du Bagage, en remettant ledit Bagage au Destinataire. La confirmation de livraison peu egalement se fait dans les point de relais DGA-express si le voyageur y achemine les colis . La Confirmation de Livraison est dite tacite lorsque les Exp??diteurs n???ont pas fait de r??clamation dans les quarante-huit (48) heures suivant la r??ception du Bagage et express lorsque les Exp??diteurs ont not?? le Voyageur en indiquant que tout s???est bien pass??."
                      "Une fois la Confirmation de Livraison valid?? , vous avez la possibilit??, en tant que Voyageur, de Nous donner l???instruction soit de vous verser la Participation aux Frais re??ue de l???Exp??diteur sur votre compte bancaire (en renseignant sur votre Compte, au pr??alable, vos coordonn??es bancaires), soit sur votre compte Paypal (en renseignant sur votre Compte, au pr??alable, votre adresse email Paypal) ou tout autre compte admettant des paiements ??lectroniques."
                      "L???ordre de virement ?? votre nom sera transmis le premier jour ouvrable  suivant votre demande ou ?? d??faut de demande de votre part, le premier jour ouvrable  suivant la mise ?? disposition sur votre profil des sommes concern??es (sous r??serve que DGA-EXPRESS dispose de vos informations bancaires)."
                      "A l???issue du d??lai de prescription de trois (3) ans applicable, toute somme non r??clam??e ?? DGA sera r??put??e appartenir ?? DGA-express.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "6.4.2. Mandat d'Encaissement",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n En utilisant la Plateforme en tant que Voyageur, vous Nous confiez un mandat d???encaissement du montant de la Participation aux Frais en votre nom et pour votre compte."
                      "Par cons??quent, apr??s acceptation manuelle ou automatique de la R??servation, DGA-express encaisse la totalit?? de la somme vers??e par l???Exp??diteur (Frais de Service et Participation aux Frais)."
                      "Les Participations aux Frais re??ues par DGA-EXPRESS sont d??pos??es sur un compte d??di?? au paiement des Voyageurs."
                      "Vous reconnaissez et acceptez qu???aucune des sommes per??ues par DGA-express au nom et pour le compte du Voyageur n???emporte droit ?? int??r??ts. Vous acceptez de r??pondre avec exigences ?? toute demande de dga-express  et plus g??n??ralement de toute autorit?? administrative ou judiciaire comp??tente en particulier en mati??re de pr??vention ou de lutte contre le blanchiment. Notamment, vous acceptez de fournir, sur simple demande, tout justificatif d???adresse et/ou d???identit?? utile."
                      "En l???absence de r??ponse de votre part ?? ces demandes, dga-express pourra prendre toute mesure qui lui semblera appropri??e notamment le gel des sommes vers??es et/ou la suspension de votre Compte et/ou la r??siliation de la souscription aux pr??sentes Conditions.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "7. POLITIQUE D'ANNULATION",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue, fontWeight: FontWeight.bold)),
                  TextSpan(text: "\n 7.1. MODALIT??S DE REMBOURSEMENT EN CAS D'ANNULATION",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n Nos Trajets font l???objet de la pr??sente politique d???annulation."
                      "DGA-express appr??cie ?? sa seule discr??tion, sur la base des ??l??ments ?? sa disposition, la l??gitimit?? des demandes de remboursement qu???elle re??oit."
                      "En tout ??tat de cause, en cas d???annulation Voyageur, dga-express vous proposera un autre Voyageur dont la date de d??part est comprise entre 0 et 3 jours compar?? ?? la date de d??part initialement r??serv??e. Dans ce cas aucune demande de remboursement ne sera accept??e."
                      "L???annulation d???un Espace d???un Trajet avec R??servation par le Voyageur ou l???Exp??diteur apr??s la Confirmation de R??servation est soumise aux stipulations ci-apr??s :",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "7.1.1. Annulation Imputable au Voyageur",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n ???Si le Voyageur annule plus de quarante-huit (48) heures avant l???heure pr??vue pour le d??part telle que mentionn??e dans l???Annonce, l???Exp??diteur est rembours?? du montant int??gral de la Participation aux Frais de Voyage et des Frais de Service aff??rents. Le Voyageur ne re??oit aucune somme de quelque nature que ce soit ;"
                      "\n ???  Si le Voyageur annule moins de quarante-huit (48) heures ou quarante-huit (48) heures avant l???heure pr??vue pour le d??part, telle que mentionn??e dans l???Annonce et plus de vingt-quatre (24) heures apr??s la Confirmation de R??servation, l???Exp??diteur est rembours?? du montant int??gral de la Participation aux Frais de Voyage et Frais de Service aff??rents ; le Voyageur ne re??oit aucune somme de quelque nature que ce soit, au contraire le Voyageur devra acquitter une p??nalit?? correspondante aux Frais de Service qui seront imput??s par DGA-EXPRESS sur son prochain Voyage ;"
                      "\n ???  Si le Voyageur annule moins de vingt-quatre (24) heures ou vingt-quatre (24) heures avant l???heure pr??vue pour le d??part, telle que mentionn??e dans l???Annonce et moins de trente (30) minutes apr??s la Confirmation de R??servation, l???Exp??diteur est rembours?? du montant int??gral de la Participation aux Frais de Voyage et des Frais de Service aff??rents. Le Voyageur ne re??oit aucune somme de quelque nature que ce soit ;"
                      "\n ???  Si le Voyageur annule moins de vingt-quatre (24) heures ou vingt-quatre (24) heures avant l???heure pr??vue pour le d??part, telle que mentionn??e dans l???Annonce et entre trente (30) et une (1) heure apr??s la Confirmation de R??servation, l???Exp??diteur est rembours?? du montant int??gral de la Participation aux Frais de Voyage et Frais de Service aff??rents ; le Voyageur ne re??oit aucune somme de quelque nature que ce soit, au contraire le Voyageur devra acquitter une p??nalit?? correspondante aux Frais de Service qui seront imput??s par DGA-EXPRESS sur son prochain Voyage ;"
                      "\n ???  Si le Voyageur annule moins de vingt-quatre (24) heures ou vingt-quatre (24) heures avant l???heure pr??vue pour le d??part, telle que mentionn??e dans l???Annonce et plus d???une (1) heure apr??s la Confirmation de R??servation, ou s???il ne se pr??sente pas au lieu de rendez-vous au plus tard dans un d??lai de trente (30) minutes ?? compter de l???heure convenue, l???Exp??diteur est rembours?? du montant int??gral de la Participation aux Frais de Voyage et Frais de Service aff??rents ; Le Voyageur ne re??oit aucune somme de quelque nature que ce soit, au contraire le Voyageur devra acquitter une p??nalit?? qui sera imput??e sur son prochain transport ; la p??nalit?? est compos??e d???une part des Frais de Service qui seront conserv??s par DGA-EXPRESS et d???autre part 15 euros (10???) de la Participation aux Frais dont la moiti?? (7,50???) sera revers??e ?? l???Exp??diteur.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "7.1.2. Annulation Imputable ?? l'Exp??diteur",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n ???  Si le Voyageur annule plus de quarante-huit (48) heures avant l???heure pr??vue pour le d??part telle que mentionn??e dans l???Annonce, l???Exp??diteur est rembours?? du montant int??gral de la Participation aux Frais de Voyage et des Frais de Service aff??rents. Le Voyageur ne re??oit aucune somme de quelque nature que ce soit ;"
                      " \n ???  Si le Voyageur annule moins de quarante-huit (48) heures ou quarante-huit (48) heures avant l???heure pr??vue pour le d??part, telle que mentionn??e dans l???Annonce et plus de vingt-quatre (24) heures apr??s la Confirmation de R??servation, l???Exp??diteur est rembours?? du montant int??gral de la Participation aux Frais de Voyage et Frais de Service aff??rents ; le Voyageur ne re??oit aucune somme de quelque nature que ce soit, au contraire le Voyageur devra acquitter une p??nalit?? correspondante aux Frais de Service qui seront imput??s par DGA-EXPRESS sur son prochain Voyage ;"
                      " \n ???  Si le Voyageur annule moins de vingt-quatre (24) heures ou vingt-quatre (24) heures avant l???heure pr??vue pour le d??part, telle que mentionn??e dans l???Annonce et moins de trente (30) minutes apr??s la Confirmation de R??servation, l???Exp??diteur est rembours?? du montant int??gral de la Participation aux Frais de Voyage et des Frais de Service aff??rents. Le Voyageur ne re??oit aucune somme de quelque nature que ce soit ;"
                      " \n ???  Si le Voyageur annule moins de vingt-quatre (24) heures ou vingt-quatre (24) heures avant l???heure pr??vue pour le d??part, telle que mentionn??e dans l???Annonce et entre trente (30) et une (1) heure apr??s la Confirmation de R??servation, l???Exp??diteur est rembours?? du montant int??gral de la Participation aux Frais de Voyage et Frais de Service aff??rents ; le Voyageur ne re??oit aucune somme de quelque nature que ce soit, au contraire le Voyageur devra acquitter une p??nalit?? correspondante aux Frais de Service qui seront imput??s par DGA-EXPRESS sur son prochain Voyage ;"
                      " \n ???  Si le Voyageur annule moins de vingt-quatre (24) heures ou vingt-quatre (24) heures avant l???heure pr??vue pour le d??part, telle que mentionn??e dans l???Annonce et plus d???une (1) heure apr??s la Confirmation de R??servation, ou s???il ne se pr??sente pas au lieu de rendez-vous au plus tard dans un d??lai de trente (30) minutes ?? compter de l???heure convenue, l???Exp??diteur est rembours?? du montant int??gral de la Participation aux Frais de Voyage et Frais de Service aff??rents ; Le Voyageur ne re??oit aucune somme de quelque nature que ce soit, au contraire le Voyageur devra acquitter une p??nalit?? qui sera imput??e sur son prochain transport ; la p??nalit?? est compos??e d???une part des Frais de Service qui seront conserv??s par DGA-EXPRESS et d???autre part 15 euros (10???) de la Participation aux Frais dont la moiti?? (7,50???) sera revers??e ?? l???Exp??diteur.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "7.1.2. Annulation Imputable ?? l'Exp??diteur",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n ???  Si l???Exp??diteur annule plus de quarante-huit (48) heures avant l???heure pr??vue pour le d??part telle que mentionn??e dans l???Annonce, l???Exp??diteur est rembours?? du montant int??gral de la Participation aux Frais. Les Frais de Service demeurent acquis ?? DGA-EXPRESS et le Voyageur ne re??oit aucune somme de quelque nature que ce soit ;"
                      " \n ???  Si l???Exp??diteur annule moins de quarante-huit (48) heures ou quarante-huit 48 heures avant l???heure pr??vue pour le d??part, telle que mentionn??e dans l???Annonce et plus de vingt-quatre (24) heures apr??s la Confirmation de R??servation, l???Exp??diteur est rembours?? ?? hauteur de la moiti?? de la Participation aux Frais vers??e lors de la R??servation, les Frais de Service demeurent acquis ?? DGA-EXPRESS et le Voyageur re??oit la moiti?? (50%) de la Participation aux Frais ;"
                      " \n ???  Si l???Exp??diteur annule moins de vingt-quatre (24) heures ou vingt-quatre (24) heures avant l???heure pr??vue pour le d??part, comme mentionn??e dans l???Annonce et moins de trente (30) minutes apr??s la Confirmation de R??servation l???Exp??diteur est rembours?? de l???int??gralit?? de la Participation aux Frais. Les Frais de Service demeurent acquis ?? DGA-Express et le Voyageur ne re??oit aucune somme de quelque nature que ce soit ;"
                      " \n ???  Si l???Exp??diteur annule moins de vingt-quatre (24) heures ou vingt-quatre (24) heures avant l???heure pr??vue pour le d??part, comme mentionn??e dans l???Annonce et entre une (1) heure et deux (2) heures apr??s la Confirmation de R??servation, l???Exp??diteur est rembours?? ?? hauteur de la moiti?? de la Participation aux Frais vers??e lors de la R??servation, les Frais de Service demeurent acquis ?? DGA-EXPRESS et le Voyageur re??oit la moiti?? (50%) de la Participation aux Frais ;"
                      " \n ???  Si l???Exp??diteur annule moins de vingt-quatre (24) heures ou vingt-quatre (24) heures avant l???heure pr??vue pour le d??part, telle que mentionn??e dans l???Annonce et plus de deux (2) heure apr??s la Confirmation de R??servation, ou s???il ne se pr??sente pas au lieu de rendez-vous au plus tard dans un d??lai de quarante-cinq (45) minutes ?? compter de l???heure convenue, aucun remboursement n???est effectu??. Le Voyageur est d??dommag?? de la Participation aux Frais et les Frais de Services sont conserv??s par DGA-EXPRESS."

                      "\n Lorsque l???annulation intervient ?? compter d???au moins trois (3) heures avant le d??part et du fait de l???Exp??diteur, le ou les Espaces annul??s par l???Exp??diteur sont de plein droit remis ?? la disposition d???autres Exp??diteurs pouvant les r??server en ligne, lesquelles nouvelles R??servations seront soumises aux pr??sentes Conditions.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "7.2. DROIT DE R??TRACTION",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n En acceptant les pr??sentes Conditions, vous acceptez express??ment que la mise en relation avec un autre Membre soit ex??cut??e avant l???expiration du d??lai de r??tractation fix?? ?? 2 heures apr??s l?????dition "
                      "de l???Annonce ou la R??servation du Trajet. D??s la Confirmation de la R??servation des Trajets, vous ne disposez de "
                      "la facult?? de vous r??tracter que dans les conditions ??nonc??es ci-dessus ?? l???article 7.1 des pr??sentes Conditions.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "8. COMPORTEMENT DES UTILISATEURS DE LA PLATEFORME ET MEMBRES",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue, fontWeight: FontWeight.bold)),
                  TextSpan(text: "\n 8.1. ENGAGEMENT DE TOUS LES UTILISATEURS DE LA PLATEFORME",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n Vous reconnaissez ??tre seul responsable du respect de l???ensemble des lois, r??glements et obligations applicables ?? votre utilisation de la Plateforme."
                      "Par ailleurs, en utilisant la Plateforme et lors des Trajets, vous vous engagez ?? :"
                      "\n ???  Ne pas utiliser la Plateforme reserver aux annonces de voyages  ?? des fins professionnelles, commerciales ou lucratives ;"
                      "\n ???  Ne transmettre ?? DGA-express (notamment lors de la cr??ation ou la mise ?? jour de votre Compte) ou aux autres Membres aucune information erron??e, trompeuse, mensong??re ou frauduleuse ;"
                      "\n ???  Ne tenir aucun propos, n???avoir aucun comportement ou ne publier sur la Plateforme aucun contenu ?? caract??re diffamatoire, injurieux, obsc??ne, pornographique, vulgaire, offensant, agressif, d??plac??, violent, mena??ant, harcelant, raciste, x??nophobe, ?? connotation sexuelle, incitant ?? la haine, ?? la violence, ?? la discrimination ou ?? la haine, encourageant les activit??s ou l???usage de substances ill??gales ou, plus g??n??ralement, contraires aux finalit??s de la Plateforme, de nature ?? porter atteinte aux droits de DGA-express  ou d???un tiers ou contraires aux bonnes m??urs ;"
                      "\n ???  Ne pas porter atteinte aux droits et ?? l???image de DGA-EXPRESS notamment ?? ses droits de propri??t?? intellectuelle ;"
                      "\n ???  Ne pas ouvrir plus d???un Compte sur la Plateforme et ne pas ouvrir de Compte au nom d???un tiers ;"
                      "\n ???  Ne pas tenter de contourner le syst??me de r??servation en ligne de la Plateforme, notamment en tentant de communiquer ?? un autre Membre vos coordonn??es afin de r??aliser la r??servation en dehors de la Plateforme et ne pas payer les Frais de Service ;"
                      "\n ???  Ne pas contacter un autre Membre, notamment par l???interm??diaire de la Plateforme, ?? une autre fin que celle de d??finir les modalit??s du partage de valises ;"
                      "\n ???  Ne pas accepter ou effectuer un paiement en dehors de la Plateforme ;"
                      "\n ???  Vous conformer aux pr??sentes Conditions et ?? la Politique de Confidentialit??.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "8.2. ENGAGEMENT DES VOYAGEURS",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n En outre, lorsque vous utilisez la Plateforme en tant que Voyageur, vous vous engagez ?? :"
                      "\n ???  Respecter l???ensemble des lois, r??gles, codes applicables au voyage, notamment ?? disposer d???une assurance responsabilit?? civile valide au moment du Trajet et ??tre en possession d???un titre de transport en vigueur ;"
                      "\n ???  Vous assurez que votre assurance couvre la garde de la chose pour tiers et que les Bagages de vos Exp??diteurs sont consid??r??s comme tiers dans votre bagage et donc couverts par votre assurance ;"
                      "\n ???  Publier des Annonces correspondant uniquement ?? des trajets r??ellement envisag??s ;"
                      "\n ???  Effectuer le Trajet tel que d??crit dans l???Annonce (notamment en ce qui concerne la compagnie a??rienne, la pr??sence d???escale ou non) et respecter les horaires et lieux convenus avec les autres Membres (notamment lieu de collecte et de livraison) ;"
                      "\n ???  Ne pas prendre plus de Kg que le nombre indiqu?? dans l???Annonce ;"
                      "\n ???  Communiquer ?? DGA-express qui vous en fait la demande, votre billet d???avion, votre pi??ce d???identit??, votre attestation d???assurance, votre VISA, votre passeport ainsi que tout document attestant de votre capacit?? ?? utiliser ce v??hicule en tant que Voyageur sur la Plateforme ;"
                      "\n ???  En cas d???emp??chement ou de changement de l???horaire ou du Trajet, en informer sans d??lai vos Exp??diteurs ;"
                      "\n ???  En cas de Trajet transfrontalier, disposer et tenir ?? disposition de l???Exp??diteur et de toute autorit?? qui le solliciterait tout document de nature ?? justifier de votre identit?? et de votre facult?? ?? franchir la fronti??re ;"
                      "\n ???  Attendre les Exp??diteurs sur le lieu de rencontre convenu au moins trente (30) minutes au-del?? de l???heure convenue ( pour la belgique et le cameroun tous les colis seront colis seront recus au point relais DGA-express)"
                      "\n ???  Ne pas publier d???Annonce relative ?? un Trajet dont vous n?????tes pas le Voyageur ;"
                      "\n ???  Vous assurez d?????tre joignable par t??l??phone par vos Exp??diteurs, au num??ro enregistr?? sur votre profil ;"
                      "\n ???  Ne g??n??rer aucun b??n??fice par l???interm??diaire de la Plateforme ;"
                      "\n ???  Garantir n???avoir aucune contre-indication ou incapacit?? m??dicale ?? voyager ;"
                      "\n ???  Avoir un comportement convenable et responsable, au cours de la collecte et livraison des colis/courriers.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "8.3. ENGAGEMENT DES EXP??DITEURS",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n Lorsque vous utilisez la Plateforme en tant qu???Exp??diteur, vous vous engagez ?? :"
                      "\n ???  Adopter un comportement convenable et responsable au cours de la remise des Bagages au Voyageur et leur collecte par le Destinataire ;"
                      "\n ???  En cas d???emp??chement, en informer sans d??lai le Voyageur ;"
                      "\n ???  Attendre le Voyageur sur le lieu de rencontre convenu au moins 15 minutes au-del?? de l???heure convenue ;"
                      "\n ???  ommuniquer ?? DGA-express ou tout Voyageur qui vous en fait la demande, votre carte d???identit?? ou tout document de nature ?? attester de votre identit?? ;"
                      "\n ???  N???exp??dier, dans l???Espace r??serv??, aucun objet, marchandise, substance, animal dont le transport est contraire aux r??gles, codes, lois et dispositions l??gales en vigueur au sein des pays de d??part, d???arriv??e et ??ventuellement d???escale ;"
                      "\n ???  En cas de Trajet transfrontalier, disposer et tenir ?? disposition du Voyageur et de toute autorit?? qui le solliciterait tout document de nature ?? justifier de votre identit?? et de votre facult?? ?? franchir la fronti??re ;"
                      "\n ???  Vous assurez d?????tre joignable par t??l??phone par le Voyageur, au num??ro enregistr?? sur votre profil et notamment au point de rendez-vous."

                      "\n Dans le cas o?? vous auriez proc??d?? ?? la R??servation d???un ou plusieurs Espaces pour le compte de tiers, vous vous portez fort du respect de celle-ci par ce tiers. DGA-express se r??serve la possibilit?? de suspendre votre Compte, limiter votre acc??s aux Services ou r??silier la souscription aux pr??sentes Conditions, en cas de manquement de la part du tiers pour le compte duquel vous avez r??serv?? un Espace aux pr??sentes Conditions.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "9. SUSPENSION DE COMPTES, LIMITATIONS D'ACC??S ET R??SILIATION",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n Vous avez la possibilit?? de mettre fin ?? votre relation contractuelle avec Nous ?? tout moment, sans frais et sans motif. Pour cela, il vous suffit de vous rendre dans l???onglet ?? Fermeture de compte ?? de votre page Profil."
                      "En cas de non-respect de votre part de tout ou partie des Conditions, vous reconnaissez et acceptez que DGA-express peut ?? tout moment, sans notification pr??alable, interrompre ou suspendre, de mani??re temporaire ou d??finitive, tout ou partie du Service ou l???acc??s des Membres ?? la Plateforme (y compris notamment le Compte Utilisateur) ou pour toute raison objective."
                      "Lorsque cela est n??cessaire, vous serez notifi?? de la mise en place d???une telle mesure afin de vous permettre de donner des explications ?? DGA-express. Nous d??ciderons, ?? Notre seule discr??tion, de lever les mesures mises en place ou non.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "10. DONN??ES PERSONNELLES",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n Dans le cadre de votre utilisation de la Plateforme, Nous pouvons ??tre amen??s ?? collecter et traiter certaines de vos donn??es personnelles. En utilisant la Plateforme et en vous y inscrivant en tant que Membre, vous reconnaissez et acceptez le traitement de vos donn??es personnelles par DGA-express conform??ment ?? la loi applicable et aux stipulations de la politique de confidentialit?? de DGA-express.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "11. PROPRI??T?? INTELLECTUELLE",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue, fontWeight: FontWeight.bold)),
                  TextSpan(text: "\n 11.1. CONTENU PUBLI?? PAR DGA-EXPRESS",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n Sous r??serve des contenus fournis par ses Membres, dga-express  est seule titulaire de l???ensemble des droits de propri??t?? intellectuelle aff??rents au Service, ?? la Plateforme, ?? son contenu (notamment les textes, images, dessins, logos, vid??os, sons, donn??es, graphiques) ainsi qu???aux logiciels et bases de donn??es assurant leur fonctionnement."
                      "Nous vous accordons une licence non exclusive, personnelle et non cessible d???utilisation de la Plateforme et des Services, pour votre usage personnel et priv??, ?? titre non commercial et conform??ment aux finalit??s de la Plateforme et des Services."
                      "Vous vous interdisez toute autre utilisation ou exploitation de la Plateforme et des Services, et de leur contenu sans l???autorisation pr??alable ??crite de DGA-express. Notamment, vous vous interdisez de :"
                      "\n ???  Reproduire, modifier, adapter, distribuer, repr??senter publiquement, diffuser la Plateforme, les Services et leur contenu, ?? l???exception de ce qui est express??ment autoris?? par DGA-EXPRESS ;"
                      "\n ???  D??compiler, proc??der ?? de l???ing??nierie inverse de la Plateforme ou des Services, sous r??serve des exceptions pr??vues par les textes en vigueur ;"
                      "\n ???  Extraire ou tenter d???extraire (notamment en utilisant des robots d???aspiration de donn??es ou tout autre outil similaire de collecte de donn??es) une partie substantielle des donn??es de la Plateforme.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "11.2. CONTENU PUBLI?? PAR VOUS SUR LA PLATEFORME",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n Afin de permettre la fourniture des Services et conform??ment ?? la finalit?? de la Plateforme, vous conc??dez ?? DGA-express une licence non exclusive d???utilisation des contenus et donn??es que vous fournissez dans le cadre de votre utilisation des Services . Afin de permettre la diffusion par r??seau num??rique et selon tout protocole de communication (notamment Internet et r??seau mobile), ainsi que la mise ?? disposition au public du contenu de la Plateforme, vous autorisez DGA-EXPRESS, pour le monde entier et pour toute la dur??e de votre relation contractuelle avec DGA-express ?? reproduire, repr??senter, adapter et traduire votre Contenu Membre de la fa??on suivante :"
                      "\n ???  Vous autorisez DGA-expresss ?? reproduire tout ou partie de votre Contenu Membre sur tout support d???enregistrement num??rique, connu ou inconnu ?? ce jour, et notamment sur tout serveur, disque dur, carte m??moire, ou tout autre support ??quivalent, en tout format et par tout proc??d?? connu et inconnu ?? ce jour, dans la mesure n??cessaire ?? toute op??ration de stockage, sauvegarde, transmission ou t??l??chargement li?? au fonctionnement de la Plateforme et ?? la fourniture du Service ;"
                      "\n ???  Vous autorisez DGA-express ?? adapter et traduire votre Contenu Membre, ainsi qu????? reproduire ces adaptations sur tout support num??rique, actuel ou futur, stipul?? au (i) ci-dessus, dans le but de fournir les Services, notamment en diff??rentes langues. Ce droit comprend notamment la facult?? de r??aliser, dans le respect de votre droit moral, des modifications de la mise en forme de votre Contenu Membre aux fins de respecter la charte graphique de la Plateforme et/ou de rendre ledit Contenu techniquement compatible en vue de sa publication via la Plateforme.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "12. NOTRE R??LE",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n La Plateforme constitue une plateforme en ligne de mise en relation sur laquelle les Membres peuvent cr??er et publier des Annonces pour des Trajets ?? des fins de transport de colis/courriers pour tiers d???une part et d???autre part l???option E-commerce. Ces Annonces peuvent notamment ??tre consult??es par les autres Membres pour prendre connaissance des modalit??s du Trajet et, le cas ??ch??ant, r??server directement un Espace sur le Trajet concern?? aupr??s du Membre ayant post?? l???annonce sur la Plateforme."
                      "En utilisant la Plateforme et en acceptant les pr??sentes Conditions, vous reconnaissez que DGA-express n???est partie ?? aucun accord conclu entre vous et les autres Membres en vue de partager les frais aff??rents ?? un Trajet."
                      "En outre, il est express??ment ??tabli que nous n???avons aucun contr??le sur le comportement des Membres et des utilisateurs de la Plateforme. Nous ne poss??dons pas, n???exploitons pas, ne fournissons pas, ne g??rons pas les moyens de transport objets des Annonces, ni ne proposons le moindre Trajet sur la Plateforme."
                      "Vous reconnaissez et acceptez que DGA-EXPRESS ne contr??le ni la validit??, ni la v??racit??, ni la l??galit?? des Annonces, des Espaces et Trajets propos??s. En sa qualit?? d???interm??diaire en transport de Bagages, DGA-EXPRESS ne fournit aucun service de transport et n???agit pas en qualit?? de transporteur, Notre r??le ne se limitant qu????? faciliter l???acc??s ?? des Membres via la Plateforme pour le transport de leurs Bagages entre Exp??diteurs et Vendeurs."
                      "Les Membres (Voyageurs ou Exp??diteurs) agissent sous leur seule et enti??re responsabilit??."
                      "En sa qualit?? d???interm??diaire, DGA-EXPRESS ne saurait voir sa responsabilit?? engag??e au titre du d??roulement effectif d???un Trajet, et notamment du fait :"
                      "\n ???  D???informations erron??es communiqu??es par le Voyageur, dans son Annonce, ou par tout autre moyen, quant au Trajet et ?? ses modalit??s ;"
                      "\n ???  L???annulation ou la modification d???un Trajet par un Membre ;"
                      "\n ???  Le comportement de ses Membres pendant, avant, ou apr??s le Trajet.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "13. NAVIGATION OU UTILISATION DE LA PLATEFORME",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n Nous nous efforcerons, dans la mesure du possible, de maintenir la Plateforme accessible sept (7) jours sur sept (7) et vingt-quatre (24) heures sur vingt-quatre (24) partout dans le monde au moyen d???une connexion internet avec des mises ?? jour des informations les plus r??centes. Pour continuer sa navigation de mani??re fluide et avoir l???acc??s facile ?? l???information publi??e sur la Plateforme, le Membre se doit de faire les choix ci-dessous : Langue de navigation, - Mode de transport : Avion, Autres ;1- Avion : Pour les colis, les plis et les bagages accompagn??s, etc??? Le nombre de Kg libres pour le cas des Bagages accompagn??s ou exp??di??s par avion. 2- Train :volume d???espace libre pour le transport des Bagages. - Pays, villes de destination ; - Dates de d??parts et d???arriv??es ; - A??roports ou gares de d??parts et d???arriv??es ; - Compagnie a??rienne ; - Compagnie ferroviaire."
                      "N??anmoins, l???acc??s ?? la Plateforme pourra ??tre temporairement suspendu, sans pr??avis, en raison d???op??rations techniques de maintenance, de migration, de mises ?? jour ou en raison de pannes ou de contraintes li??es au fonctionnement des r??seaux."
                      "En outre, DGA-EXPRESS se r??serve le droit de modifier ou d???interrompre, ?? sa seule discr??tion, de mani??re temporaire ou permanente, tout ou partie de l???acc??s ?? la Plateforme ou ?? ses fonctionnalit??s.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "14. DROIT APPLICABLE - LITIGE",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n Les pr??sentes Conditions sont r??dig??es en fran??ais et soumises ?? la loi et r??glementation fran??aise."
                      "Vous pouvez ??galement pr??senter, vos r??clamations relatives ?? notre Plateforme ou ?? nos Services, sur la plateforme de r??solution des litiges mise en ligne par la Commission Europ??enne accessible ici. La Commission Europ??enne se chargera de transmettre votre r??clamation aux m??diateurs nationaux comp??tents. Conform??ment aux r??gles applicables ?? la m??diation, vous ??tes tenus, avant toute demande de m??diation, d???avoir fait pr??alablement part par ??crit ?? DGA-EXPRESS de tout litige afin d???obtenir une solution ?? la miable.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "15.MENTIONS L??GALES",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \nDGA-express ",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.blue, fontWeight: FontWeight.bold)),
                  TextSpan(text: " est une entreprise ?? personne physique immatricul??e au registre de"
                      "commerce RC/DLA/2022/A/1496/ACE/APME/CFCE DU 22/07/2022 bas??e au"
                      "Cameroun dans la ville de douala avec un capital de 500.000fcfa ",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                  TextSpan(text: " ( email :contact@dga-experss.com ) ",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.blue, fontWeight: FontWeight.bold)),
                ],

              ),
            ),
            SizedBox(height: 50.h)
          ],
        ),
      )
    );
  }

  showModalSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                child: ListTile(
                  onTap: () {
                  },
                  leading: const Icon(Icons.settings_rounded),
                  title: const Text('From gallery'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ListTile(
                  onTap: () {
                  },
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: const Text('From Camera'),
                ),
              )
            ],
          );
        });
  }

}
