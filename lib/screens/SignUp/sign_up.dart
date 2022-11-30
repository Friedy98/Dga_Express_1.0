
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
          Text("Déjà un utilisateur?",
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
                        hintText: 'Entrez Prénom',
                        labelText: 'Prénom',
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
                        labelText: 'Téléphone',
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
                  TextSpan(text: " \n Vous etes prié de  lire attentivement  les  conditions générales d’utilisation de cette  plateforme . "
                      "Ces dernières contiennent des informations concernant vos droits, obligations et recours légaux. En accédant à la Plateforme DGA-EXPRESS ainsi qu’a son application mobile,"
                      " vous acceptez d’être lié par ses normes d’utilisations  et vous y conformer"
                      "En outre, les présentes Conditions constituent un accord juridique contraignant qui vous lie à DGA-EXPRESS  (tel que défini ci-dessous)"
                      " et qui régit votre accès au site DGA-EXPRESS ainsi qu’à son application , y compris ses sous-domaines ( plateformes E-commerce )  et tous les autres sites par le biais desquels"
                      "DGA-EXPRESS fournit les services .  nos applications pour mobiles, tablettes , smartphones et les interfaces de programme d’application , ainsi que tous les services associés ."
                      "Le Site, l’Application et les Services DGA-EXPRESS sont collectivement désignés dans ses différentes plateformes."
                      " « DGA-EXPRESS » dont le siège social est situé à la rue d’arquet 64,5000 Namur  immatriculé au......................"
                      " Disposant un  points de relais dans la ville de bruxelle à l’adress rue des tanneurs 130 , 1000 bruxelles ."
                      "La manière dont nous collectons et utilisons des données à caractère personnel en lien avec votre accès à nos Plateformes  et votre"
                      "utilisation de ladite Plateforme est décrite dans notre Charte Cookies.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "1. OBJET",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue, fontWeight: FontWeight.bold)),
                  TextSpan(text: " \n La Plateforme est une place de marché en ligne, un espace interactif d’échanges personnalisés, facilitant la mise en relation des différents acteurs de l’industrie du voyage d’une part et un espace E-commerce d’autre part . Cette Plateforme a pour objectif principal de participer à la réduction des coûts lors des voyages en maximisant le gain potentiel "
                      "pour une économie solidaire de partage, elle offre également des possibiltés d’achats et de ventes des articles de prémières necessités pouvant faire office de cadeaux "
                      "Les présentes Conditions s’appliquent aux services proposés sur la Plateforme et tout particulièrement sur le site et l’application  www.DGA_EXPRESS.com   Il s’agit de manière non exhaustive, des services d’envoi"
                      "de colis, de courriers et/ou de bagages (ci-après ensemble « Bagages »), de la mise en relation d’Expéditeurs et de Voyageurs dans le stricte respect des règles de transport aérien édictées par les compagnies aériennes, assorti de la collecte"
                      " d’une Participation aux Frais des Voyageurs au travers de la Plateforme ainsi qu’une plateformes E-commerce (permettant aux voyageurs , expediteurs d’offrir un present à leurs proches , de completer leurs bagages et aux tiérces utilisateurs de s’offrir les articles de leurs choix à des moindres prix)  d’un système de notation des Voyageurs et commercants"
                      "Ainsi, ne sont pas admis au transport aux travers des Plateformes les objets suivants : armes, explosifs, armes et objets coupants, produits combustibles, bouteilles de gaz, thermomètres à mercure, allumettes, briquets ou tout autre petit combustible, cartouches d’imprimantes, batteries à électrolyte, batteries au lithium,"
                      "produits chimiques exceptionnels du type engrais pesticides et désherbants, produits liquides décapants et tout autre produit ou marchandise considérée comme étant dangereuse et dont le transport est interdit par la compagnie aérienne empruntée."
                      "Tout autre produit dont le transport par voie aérienne n’est pas spécifiquement interdit par les règles d’aviation civile et la compagnie aérienne empruntée peut être transporté par le biais des Membres des difeerentes Plateformes (clés, vêtements, boissons, appareils électroniques, etc.)."
                      "Toute action de connexion, d’inscription et de téléchargement effectuée sur la Plateforme conduit automatiquement à l’acceptation des présentes Conditions et vous permet de recevoir les offres commerciales, les publicités et les newsletters pendant toute la durée de votre adhésion à nos Plateformes ( site et Application mobile)",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "2. DÉFINITIONS",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue, fontWeight: FontWeight.bold)),
                  TextSpan(text: " \n Dans les présentes,"
                      "« Annonce » désigne toute publication d’un Voyageur, visant à proposer un service pour le transport  colis (vendu au kilogrammes), courriers, ventes des articles (reserver à la plateforme E-commerce )"
                      "« Application » désigne un logicie applicatif dévéloppé pour des appareils mobiles, tablettes et smartphone téléchargeable sur l'App Store et/ou sur Google Play, ainsi que les interfaces des programmes d’application ;"
                      "« Attestation de Remise de Bagages » désigne le contrat par lequel le Voyageur atteste avoir reçu le Bagage, avoir vérifié son contenu et s’engage à en être le Gardien et à le remettre au Destinataire ou dans un point de relais DGA-EXPRESS"
                      "« Bagage » désigne, sans que cette liste ne soit exhaustive, le (s) bien (s), colis, courriers, ou tout(t)(s) autre(s) objet(s) réglementé(s) convoyé(s) par le Voyageur et confié(s) à l’Expéditeur ;"
                      " « CGU » désigne les présentes Conditions Générales d’Utilisation y compris la charte de bonne conduite ci-après ;"
                      " « Compte » désigne un ensemble des ressources informatiques attribuées à un utilisateur ou à un appareil. Il ne peut etre exploiter qu’en s’enregistrant aupres d’un système à l’aide d’un identifiant et d’un  authentifiant tel qu’un mot de passe qui doit être créé pour pouvoir devenir Membre et accéder aux services proposés par la Plateforme sous réserve du respect de certaines conditions ;"
                      "« Destinataire » est la personne indiquée par l’Expéditeur à qui le Voyageur doit remettre en mains propres le bien convoyé, dans le cas où celui-ci n’est pas confisqué en douanes ;"
                      "« Envoi » faire partir l’objet via  Espace publié par un Expéditeur sur la Plateforme et pour lequel il souhaite expédier des Bagages via un tiers en contrepartie de la Participation aux Frais de ce dernier ;"
                      "« Espace » désigne le nombre de Kg réservé par un Expéditeur à bord d’une ou plusieurs valises d’un Voyageur ;"
                      "« Expéditeur » désigne le Membre ayant accepté la proposition d’expédier ses Bagages par le Voyageur ou, le cas échéant, la personne pour le compte de laquelle un Membre a réservé un Espace ;"
                      "« Frais de Service » désignent des sommes d’argent correspondant à la commission demandée par DGA-EXPRESS pour la mise en relation, lorsque le Membre de la Plateforme décide de passer par un autre Membre de la Plateforme au travers d’un Trajet avec Réservation, cette commission étant énoncée de manière précise et visible dans l’Annonce et acceptée par l’Expéditeur ;"
                      "« Gardien » ou « Gardien de la chose » désigne la notion de droit selon laquelle une personne est réputée être gardienne d’une chose lorsqu’elle a, sur cette chose, en l’occurrence ici le Bagage, un pouvoir d’usage, de direction et de contrôle, et qu’en conséquence, qu’elle puisse être considéré comme ayant la responsabilité juridique sur cette chose, ici le Bagage, pendant la durée au courant de laquelle le Bagage est en sa possession, pour tous dommages auquel ce Bagage pourrait être exposé."
                      "« Membre » désigne toute personne physique ayant créé un compte sur les Plateformes DGA-EXPRESS ;"
                      "« Participation aux Frais » est la somme d’argent demandée par le Voyageur et acceptée par l’Expéditeur au titre de sa participation aux frais de déplacement pour un trajet donnéé"
                      "« Plateforme » emplacement dédié à recevoir des annonces de voyages et autres"
                      "« DGA » Darling global African Express ."
                      "« DGA-EXPRESS » plateforme de mise en relation entre particuliers  pour l’acheminement des colis/courriers faisant l’objet d’une annonce publiée par un Voyageur pour lequel il accepte de transporter ces colis/courriers en contrepartie de paiements ;"
                      "« Réservation » action qui consiste à retenir une place pour bagage dans l’annonce d’un voyageur  (    ;"
                      "« Services »  l’ensemble des devoirs rendus au moyen de la Plateforme à un Membre tel qu’énoncé plus haut dans les conditions, étant précisé que DGA-EXPRESS  n’est pas partie prenante dans un contrat d’envoi de colis ou de marchandises ;"
                      "« Site » plateforme  accessible à l’adresse www.DGA_EXPRESS.com ou tout autre site par lequel DAGA-EXPRESS fournit ses Services ;"
                      "« Sous-Trajet » Parcours d’un point à un autre ;"
                      "« Trajet » désigne le point de depart ( ville -pays ) et le point d’arrivée (destination) faisant l’objet d’une Annonce publiée par un Voyageur sur la Plateforme et pour lequel il accepte de transporter des Bagages de tiers en contrepartie de la Participation aux Frais ;"
                      "« Voyageur » est le Membre proposant sur la Plateforme, un certain nombre de Kg pour le transport de marchandises en avion pour un trajet précis .",
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
                  TextSpan(text: " \n L’acceptation de nos Conditions vous donne droit à l’inscription et/ou au téléchargement de l’Application à partir de votre téléphone mobile ou via internet de manière gratuite. L\'utilisation de la Plateforme est subordonnée à l\'acceptation des présentes Conditions. Au moment de la création du compte utilisateur, les Membres acceptent les Conditions en ouvrant l’Application et/ou en cliquant sur le bouton [\'Confirmer l’inscription\']. Seule l\'acceptation de ces Conditions permet aux Membres d\'accéder aux services proposés sur la Plateforme. L\'acceptation des présentes Conditions est entière et forme un tout indivisible, et les Membres ne peuvent choisir de voir appliquer une partie des Conditions seulement ou encore formuler des réserves. En acceptant les Conditions, le Membre accepte également la Charte de bonne conduite qui y est annexée. En cas de manquement à l\'une des obligations prévues par les présentes, DGA-EXPRESS se réserve la possibilité de supprimer le Compte Utilisateur concerné.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "3.2. MODIFICATION DES CONDITIONS",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n DGA-EXPRESS   se réserve le droit de modifier à tout moment les Conditions, les fonctionnalités offertes sur la Plateforme ou les règles de fonctionnement de cette dernière. Les modifications prendront effets  immédiatement dès la mise en ligne des Conditions, avec mention de la date de mise à jour, que tout utilisateur reconnaît avoir préalablement consultées. Les publications d'Annonces au moyen des Plateformes sont totalement gratuite. La consultation d’Annonce et la mise en relation entre les deux parties en sont de même. Toutefois, DGA-EXPRESS se réserve notamment le droit de prendre une commission, des Frais de Service, à tout moment, qui représentera un pourcentage sur la transaction qui sera effectuée au travers de ses Plateformes, pour les Trajets avec Réservation. DGA-EXPRESS   pourra aussi à tout moment proposer des services nouveaux, gratuits ou payants sur la Plateforme.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "4. INSCRIPTION À LA PLATEFORME ET CRÉATION DE COMPTE",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue, fontWeight: FontWeight.bold)),
                  TextSpan(text: "\n 4.1. CONDITIONS D'INSCRIPTION À LA PLATEFORME",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n L’utilisation de la Plateforme est réservée aux personnes physiques âgées d’au moins dix-huit (18) ans révolus à la date d’utilisation. Toute inscription sur la Plateforme par une personne physique âgée de moins de (dix-huit) 18 ans est strictement interdite. En accédant, ou en  vous inscrivant sur la Plateforme, vous déclarez et garantissez avoir 18 ans ou plus.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "4.2. CRÉATION DE COMPTE",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n Chaque Membre doit au préalable créer un Compte, en fournissant des données personnelles le concernant, indispensables au bon fonctionnement du service de mise en relation des personnes (notamment nom, prénom, civilité, numéro de téléphone et adresse e-mail valides, adress de residence, preuve de reservation, piéce  d’identité : CNI,passeport ). Nous ne pourrons en aucun cas être tenue responsable des informations qui pourraient être erronées ou frauduleuses communiquées par les Membres. Le Membre s'engage à ne pas créer ou utiliser d'autres comptes que celui initialement créé, que ce soit sous sa propre identité ou celle des tiers. Toute dérogation à cette règle devra faire l'objet d'une demande explicite de la part du Membre et d'une autorisation express et spécifique de Notre part. Le fait de créer ou utiliser de nouveaux comptes sous sa propre identité ou celle de tiers sans en avoir demandé et obtenu l'autorisation pourra entraîner non seulment une poursuite judiciaire , mais aussi la suspension immédiate des comptes du Membre et de tous les services associés"
                      "Par ailleurs, il est permis de consulter les Annonces même si vous n’êtes pas inscrit sur la Plateforme. En revanche, vous ne pouvez ni publier une Annonce ni réserver un Espace sans avoir, au préalable, créé un Compte et être devenu Membre."
                      "Pour créer votre Compte, vous pouvez :",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                  TextSpan(text: " \n ●  soit remplir l’ensemble des champs obligatoires figurant sur le formulaire d’inscription ;telecharger tous les documents demandés. La verification de compte est obligatoire par une photo d’identification . le compte ne sera en aucun cas créer si tous les informations démandées ne sont pas renseignées . "
                      " \n ●  soit vous connecter, via notre Plateforme, à votre compte Facebook (ci-après, votre « Compte Facebook »). En utilisant une telle fonctionnalité, vous comprenez que Nous aurons accès, publierons sur la Plateforme et conserverons certaines informations de votre Compte Facebook. Vous pouvez à tout moment supprimer le lien entre votre Compte et votre Compte Facebook par l’intermédiaire de la rubrique « Vérifications » de votre profil. Si vous souhaitez en savoir plus sur l’utilisation de vos données dans le cadre de votre Compte Facebook, nous vous invitons à consulter notre politique de confidentialité et celle de Facebook.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                  TextSpan(text: " \n A l’occasion de la création de votre Compte, et ce, quelle que soit la méthode choisie pour ce faire, vous vous engagez à fournir des informations personnelles exactes et conformes à la réalité et à les mettre à jour, par l’intermédiaire de votre profil ou en en avertissant DGA-EXPRESS, afin d’en garantir la pertinence et l’exactitude tout au long de votre relation contractuelle avec Nous."
                      "En cas d’inscription par email, vous vous engagez à garder secret le mot de passe "
                      "choisi lors de la création de votre Compte et à ne le communiquer à personne. En cas de perte ou divulgation de votre mot de passe, vous vous engagez à en informer sans délai DGA-EXPRESS, qui vous permettra alors de réinitialiser votre mot de passe. Vous êtes seul responsable de l’utilisation faite de votre Compte par un tiers, tant que vous n’avez pas expressément notifié DGA-EXPRESS  de la perte, de l’utilisation frauduleuse par un tiers et/ou de la divulgation de votre mot de passe à un tiers."
                      "Vous vous engagez à ne pas créer ou utiliser, sous votre propre identité ou celle d’un tiers, d’autres Comptes que celui initialement créé.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "4.3. VÉRIFICATION",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n Nous nous réservons le droit, à des fins de transparence, d’amélioration de la confiance, ou de prévention ou détection des fraudes, de mettre en place un système de vérification de certaines des informations que vous fournissez sur votre profil. C’est notamment le cas lorsque vous renseignez votre numéro de téléphone ou vous fournissez une pièce d’identité."
                      "Vous reconnaissez et acceptez que toute référence sur la Plateforme à des informations dites « vérifiées » ou tout terme similaire signifie uniquement qu’un Membre a réussi avec succès la procédure de vérification existante sur la Plateforme afin de fournir davantage d’informations sur le Membre avec lequel vous envisagez une expédition. Nous ne garantissons ni la véracité, ni la fiabilité, ni la validité d’une information ayant fait l’objet de la procédure de vérification.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "5. UTILISATION DES SERVICES",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue, fontWeight: FontWeight.bold)),
                  TextSpan(text: " \n 5.1. UTILISATION À TITRE NON PROFESSIONNEL ET NON COMMERCIAL POUR LES PARTICULIERS",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n Vous vous engagez à n’utiliser les Services et la Plateforme que pour être mis en relation, à titre non professionnel et non commercial, avec des personnes souhaitant réserver un Espace sur votre Trajet avec vous. Nous ne pourrons, en aucun cas, être tenus responsables d’une utilisation à titre professionnel ou commercial de la Plateforme. Nous considérons, de manière non exhaustive, comme activité professionnelle toute activité sur la Plateforme qui, par la nature des services proposés, leur fréquence ou le nombre de colis transportés, entraînerait une situation de bénéfice pour le Voyageur. Seul l’option E-COMMERCE de cette plateformes est reconnu à titre commercial et professionnel ."
                      "En tant que Voyageur, vous vous engagez à ne pas demander une Participation  supérieure aux frais que vous supportez réellement et susceptible de vous faire générer un bénéfice, étant précisé que s’agissant d’un partage de frais, vous devez également, en tant que Voyageur, supporter votre part des coûts afférents au Trajet. Vous êtes seul responsable d’effectuer le calcul des frais que vous supportez pour le Trajet, et de vous assurer que le montant demandé à vos Expéditeurs n’excède pas les frais que vous supportez réellement (en excluant votre part de Participation aux Frais)."
                      "DGA-EXPRESS se réserve également la possibilité de suspendre votre Compte, limiter votre accès aux Services ou résilier votre souscription aux présentes Conditions en cas d’activité de votre part sur la Plateforme, qui, du fait de la nature des trajets proposés, de leur fréquence, du nombre d’Espaces proposés à la réservation ou du montant de la Participation aux Frais demandée, entraînerait une situation de bénéfice pour vous ou pour quelque raison que ce soit faisant suspecter à DGA-express  que vous générez un bénéfice sur la Plateforme.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "5.2. LE SERVICE",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n La Plateforme est un service de mise en relation, par lequel l'Expéditeur souhaitant effectuer un Envoi contacte le Voyageur pour fixer un lieu de rencontre pour la remise du Bagage à envoyer et les éventuelles conditions d’envois (volume ou taille des Bagages transportés, nombre de Kg disponibles, délai de livraison, point de livraison, etc.)."
                      "Pour la belgique et le cameroun  tous les colis passer ont dans point de relais DGA-EXPRESS et le voyageur  pourront soient passer reuperer le colis avant son voyage ou alors se faire livré à domicile contre des frais imposés par DGA-Express. Une fois au cameroun ou en belgique tous les bagages doivent etre deposés dans les points de relais le plus proche pour distribution , les voyageurs ne pourront etre ré numérer que si les destinataires recoivent leurs colis ou si ce dernier deposer le colis dans un point de relais DGA-EXPRESS"
                      "Lors de la remise du ou des Bagage(s), les Expéditeurs et Voyageurs concernés consentent aux termes de l’Attestation de Remise de Bagages produite lors de chaque Confirmation de Réservation et dont le modèle est téléchargeable dans le mail de confirmation de reservation ."
                      "Par ailleurs, la Plateforme met à la disposition de ses Membres des moyens sécurisés de paiement et se réserve le droit de percevoir une commission, appelée Frais de Service, pour les Trajets avec Réservation, à charge pour Nous de reverser la somme au Voyageur une fois que le Destinataire confirmera avoir reçu le Bagage. Les annulations de dernières minutes, le paiement des Frais de Participation, sont alors supervisées par Nous. Pour autant, Nos Membres souscrivant aux Trajets avec Réservation restent responsables, dans la mesure des dispositions énoncées à l\’article 7.1 ci-dessous, dans certains cas d\’annulation, pour lesquels DGA-EXPRESS n\’est nullement responsable."
                      "De la même manière, les Membres demeurent responsables des risques liés au transport du ou des Bagage(s), notamment s’agissant du contenu du Bagage, de la perte du Bagage et de la remise du Bagage au Destinataire sauf si les bagages ont été deposé dans les points de relais DGA-EXPRESS  pour distribution.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "5.3. PUBLICATION DES ANNONCES",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n En tant que Membre, et sous réserve que vous remplissiez les conditions ci-dessous, vous pouvez créer et publier des Annonces sur la Plateforme en indiquant des informations quant au Trajet que vous comptez effectuer (dates/heures et lieux de départ et d’arrivée, nombre de Kg mis à disposition, options proposées, montant de la Participation aux Frais, compagnie de voyage etc.)."
                      "Lors de la publication de votre Annonce, vous pouvez indiquer des villes étapes, dans lesquelles vous acceptez de vous arrêter pour prendre ou déposer des Bagages. Les tronçons du Trajet entre ces villes étapes ou entre l’une de ces villes étapes et le point de départ ou d’arrivée du Trajet constituent des « Sous-Trajets »."
                      "Vous n’êtes autorisé à publier une Annonce que si vous remplissez l’ensemble des conditions suivantes :"
                      "\ ●  Vous êtes titulaire d’un titre de transport valide (billet d’avion, tickets de train…) ;"
                      "\n ●  Vous ne proposez des Annonces que pour des Trajets dont l’acquisition du titre de transport a été faite par des moyens licites par vous-même ou par un tiers que vous connaissez personnellement ;"
                      "\n ●  Vous êtes et demeurez le Voyageur, objet de l’Annonce ;"
                      "\n ●  Vous n’avez aucune contre-indication ou incapacité médicale à voyager ;"
                      "\n ●  La compagnie de transport que vous comptez utiliser n’est pas interdite d’exploitation ;"
                      "\n ●  Vous ne comptez pas publier une autre Annonce pour le même Trajet sur la Plateforme;"
                      "n ●  Vous n’offrez pas plus d’Espace que celle disponible dans votre valise ;"
                      "\n ●  Vous utilisez une valise en parfait état de fonctionnement, qui ne présente aucun danger ou risque de dommages pour les Bagages des Expéditeurs ;"
                      "\n ●  Vous acceptez d’assumer la responsabilité de Gardien de la chose pour le compte de l’Expéditeur. A cet effet, vous êtes responsable du Bagage pendant la durée du Trajet et vous vous engagez à remettre ledit Bagage en l’état, à l’arrivée du Trajet au Destinataire, et ce moyennant Participation de l’Expéditeur aux Frais de votre voyage."
                      "Vous reconnaissez être le seul responsable du contenu de l’Annonce que vous publiez sur la Plateforme. En conséquence, vous déclarez et garantissez l’exactitude et la véracité de toute information contenue dans votre Annonce et vous engagez à effectuer le Trajet selon les modalités décrites dans votre Annonce."
                      "Sous réserve que votre Annonce soit conforme aux CGU, elle sera publiée sur la Plateforme et donc visible des Membres et de tous visiteurs, même non Membre, effectuant une recherche sur la Plateforme. DGA-EXPRESS se réserve la possibilité, à sa seule discrétion et sans préavis, de ne pas publier ou retirer, à tout moment, toute Annonce qui ne serait pas conforme aux présentes Conditions ou qu\’elle considérerait comme préjudiciable à son image, celle de la Plateforme ou celle des Services."
                      "Vous reconnaissez et acceptez que les critères pris en compte dans le classement et l\’ordre d\’affichage de votre Annonce parmi les autres Annonces relèvent de la seule politique de DGA-Express",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "5.4. VALIDATION DE L'ANNONCE",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n La validation de l’information par le client, sur la Plateforme d’une publication ou d’une recherche d’Annonce n’est effective que, lorsque les deux acteurs auront rempli toutes les informations nécessaires à savoir : pays et ville de destination, dates de départ et d’arrivée, le moyen de transport emprunté, preuve de reservation (billet d’avion ), pièce d’identité ( passeport , cni), le nombre de Kg libres ou à céder ainsi que les prix y afférents. Toutefois, nous déclinons toute responsabilité subséquente des aléas qui pourraient survenir lors des rencontres entre clients (arrivées tardives aux lieux de rendez-vous, oubli d’entrer en contact, etc.).",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "5.5. DURÉE DE L'ANNONCE SUR LA PLATEFORME",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n La durée de l’Annonce sur la Plateforme est de trente (30) jours à partir de la date de sa mise en ligne sur la plateforme. A l’expiration de celle-ci, cette annonce est automatiquement déclassée et ne pourra donc plus figurer sur la Plateforme. Cependant, l’Annonce peut toutefois faire l’objet d’un repositionnement à l’initiative du Voyageur en utilisant son Compte précédemment créé. Le nombre de kilogramme  déclarés comme disponible par le voyageur diminura aufur et à mesure que les reservations se feront sur l’annonce. Une fois la totalité de kilo reserver l’annonce sera bloquée automatiquement il ne sera plus possible de faire d’autres reservations .",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "5.6. RETRAIT OU ANNULATION DE L'ANNONCE - DELAI DE RÉTRACTATION",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n Le retrait ou l’annulation d’une Annonce après publication reste gratuit pendant quarante huit (48) heures à compter de l’heure de sa publication ou de mise en ligne. Au-delà de ces deux (2) heures, elle est assujettie au paiement de la somme de 2 euroS, somme d’argent à débiter lors du prochain achat sur la Plateforme. Cependant, en cas d’annulation de vols ou de changement de la date de voyage par le Voyageur, celui-ci se doit d’informer l’Expéditeur de la nouvelle date, et convenir avec lui d’une nouvelle réservation."
                      "Par ailleurs, le retrait ou l\’annulation, sans motif valable, d’une Annonce ayant déjà fait l\’objet de réservation d\’Espace par un Voyageur est assujetti au paiement de la somme de six (6)  euros, somme d\’argent à débiter lors du prochain achat sur la Plateforme . En cas de récidive, le Voyageur se verra interdire l\’accès à la page pour une période minimale de huit  (8) mois.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "5.7. RÉSERVATION D'UN ESPACE",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n Les modalités de Réservation d’un Espace dépendent de la nature du Trajet envisagé, DGA-Express ayant mis en place pour certains Trajets un système de réservation en ligne."
                      "En tant que Membre, et sous réserve que vous remplissiez les conditions ci-dessous, vous pouvez réserver un Espace sur une Annonce sur la Plateforme en indiquant des informations quant à l’Envoi que vous souhaitez effectuer (description du contenu, poids, montant de la Participation aux Frais, date limite de réception, options proposées, etc.)."
                      "Vous n’êtes autorisé à réserver un Espace que si vous remplissez l’ensemble des conditions suivantes :"
                      "\n ●  Vous ne réservez des Espaces que pour des Envois dont l’acquisition du contenu a été faite par des moyens licites par vous-même ou par un tiers que vous connaissez personnellement ;"
                      "\n ●  Vous ne réservez des Espaces que pour des Envois dont le contenu est licite et le transport non prohibé par les compagnies de transport (cf. réglementation sur le transport aérien des compagnies objet du Trajet visé) ;"
                      "\n ●  Vous êtes et demeurez l’Expéditeur, objet de l’Espace ;"
                      "\n ●  Vous ne comptez pas réserver un autre Espace pour la même Annonce sur la Plateforme ;"
                      "\n ●  Vous ne comptez pas changer le contenu décrit dans l’Envoi après validation du Voyageur auteur de l’Annonce ;"
                      "\n ●  Vous vous engagez à bien conditionner vos Bagages de manière à ce qu’ils ne présentent aucun danger ou risque de dommages pour la valise du Voyageur ;"
                      "\n ●  Vous vous engagez à présenter le Contenu de votre Envoi ouvert pour vérification et contrôle par le Voyageur, faciliter en participant pleinement à cet exercice de vérification de conformité, valider que le Voyageur a bien contrôlé et vérifié votre Envoi ;"
                      "\n ●  Vous acceptez de confier la responsabilité de Gardien de la chose au Voyageur pour le Bagage à transporter par ce dernier, et ce jusqu’à la remise du dit Bagage au Destinataire ( pour tout autres destinations) ou dans un  point de relais DGA ( uniquement applicable en belgique et au cameroun) , dans la ville de destination du Voyageur, à son arrivée du Trajet, moyennant votre Participation aux Frais de son voyage."
                      "\n ●  Vous acceptez également fournir les informations sur vos piéces d’identitées ( CNI, passeport ), en cas de constat d’objets ou produits illicites ( stupéfiants)  dissimulés dans vos bagages vous serrez tenue pour seul responsable et ferez l’objet des poursuites judiciaires.  "
                      "Vous reconnaissez être le seul responsable du contenu de l’Espace que vous publiez sur la Plateforme. En conséquence, vous déclarez et garantissez l’exactitude et la véracité de toute information contenue dans votre Espace et vous engagez à effectuer l’Envoi selon les modalités décrites dans votre Espace."
                      "Sous réserve que votre Espace soit conforme aux Conditions, elle sera publiée sur l’Annonce choisie et donc visible du Voyageur. Nous nous réservons la possibilité, à notre seule discrétion et sans préavis, de ne pas publier ou retirer, à tout moment, tout Espace qui ne serait pas conforme aux Conditions ou qu’elle considérerait comme préjudiciable à son image, celle de la Plateforme ou celle des Services."
                      "Vous reconnaissez et acceptez que les critères pris en compte dans le classement et l’ordre d’affichage de votre Espace parmi les autres Espaces relèvent de la seule politique de DGA-Express",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "5.7.1. Trajet Réservé",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n Nous avons mis en place un système de réservation d’Espaces en ligne  pour les Trajets proposés sur la Plateforme (les « Trajets avec Réservation »)."
                      "L’éligibilité d’un Trajet au système de Réservation reste à notre seule décision et nous nous réservons la possibilité de modifier ces conditions à tout moment."
                      "Lorsqu’un Expéditeur est intéressé par une Annonce bénéficiant de la Réservation, il peut effectuer une demande de Réservation en ligne. Cette demande de Réservation est (i) soit acceptée automatiquement (si le Voyageur a choisi cette option lors de la publication de son Annonce), (ii) soit acceptée manuellement par levoyageur . Au moment de la Réservation, l’Expéditeur procède au paiement en ligne du montant de la Participation renseigné par le voyageur  et des Frais de Service afférents, le cas échéant. Après vérification du paiement par DGA-Express et validation de la demande de Réservation par le Voyageur, l’Expéditeur reçoit une confirmation de Réservation . Si vous êtes un Voyageur et que vous avez choisi de gérer vous-mêmes les demandes de Réservation lors de la publication de votre Annonce, vous êtes tenu de répondre à toute demande de Réservation dans un délai incompressible de deux heures à compter de la demande de chaque Expéditeur. A défaut, la demande de Réservation expire automatiquement et l’Expéditeur est remboursé de l’intégralité des sommes versées au moment de la demande de Réservation, le cas échéant."
                      "De plus, dès la Confirmation de Réservation et conformément aux termes de l’Attestation de Remise de Bagages, le Voyageur devient seul responsable du Bagage en sa qualité de Gardien de la Chose transportée. A cet effet, il s’engage à prendre toutes les mesures nécessaires pour s’assurer de la conformité du Bagage à transporter et de sa bonne tenue jusqu’à sa remise entre les mains du Destinataire. DGA-Express n’est garant d’aucune réclamation,, revendication, action ou recours d’un Expéditeur vers le Voyageur et/ou de tout tiers pour le Bagage transporté , sauf si le bagage a été remis à un point de rélais DGA-express au depart ou à l’arrivée . A compter de la Confirmation de la Réservation, nous vous transmettons les coordonnées téléphoniques du Voyageur (si vous êtes Expéditeur) ou de l’Expéditeur (si vous êtes Voyageur), dans le cas où le Membre a donné son accord à la divulgation de son numéro de téléphone. Vous êtes désormais seuls responsables de l’exécution du contrat vous liant à l’autre Membre.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "5.7.2. Caractère nominatif de la réservation d’Espace et modalités d’utilisation des Services pour le compte d’un tiers",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n Toute utilisation des Services, que ce soit en qualité d’Expéditeur ou de Voyageur, est nominative. Le Voyageur comme l’Expéditeur doivent correspondre à l’identité communiquée à DGA-express."
                      "Toutefois . www.DGA-express.com  permet à ses Membres de réserver un ou plusieurs Espaces pour le compte d’un tiers. Dans ce cas, vous vous engagez à indiquer avec exactitude au Voyageur, au moment de la Réservation, les noms, prénoms, âges et numéros de téléphone de la personne pour le compte de laquelle vous réservez un Espace. Il est strictement interdit de réserver un Espace pour un mineur. En revanche, il est interdit de publier une Annonce pour un Voyageur autre que vous-même."
                      "Ainsi donc, les Membres sont admis à réserver un espace pour une Expédition concernant un tiers. Par contre, il est formellement interdit de publier une Annonce de voyage alors qu’on ne voyage pas soit même. Dans cette hypothèse, Nous vous invitons à encourager le véritable Voyageur à créer son compte sur la Plateforme et à publier son voyage à partir de son Compte.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "5.8. SYSTÈME D'AVIS",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: "\n 5.8.1. Fonctionnement",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n Nous vous encourageons fortement à laisser un avis sur un Voyageur (si vous êtes Expéditeur) ou un Expéditeur (si vous êtes Voyageur) avec lequel vous avez réservé un Espace ou pour lequel vous avez transporté un Bagage. En revanche, vous n’êtes pas autorisé à laisser un avis sur un autre Expéditeur, si vous étiez vous-même Expéditeur, ni sur un Voyageur avec lequel vous n’avez pas réservé d’Espace."
                      "Votre avis, ainsi que celui laissé par un autre Membre à votre égard, ne sont visibles et publiés sur la Plateforme qu’après le plus court des délais suivants : (i) immédiatement après que vous ayez, tous les deux, laissé un avis ou (ii) passé un délai de (sept) 7 jours après le premier avis laissé."
                      "Vous avez la possibilité de répondre à un avis qu’un autre Membre a laissé sur votre profil dans un délai maximum de (sept) 7 jours suivant la publication de l’avis laissé à votre égard. L’avis et votre réponse, le cas échéant, seront publiés sur votre profil.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "5.8.2. Modération",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n Vous reconnaissez et acceptez que DGA-express se réserve la possibilité de ne pas publier ou supprimer tout avis, toute question, tout commentaire ou toute réponse dont il jugerait le contenu contraire aux présentes Conditions.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "5.8.3. Seuil",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n DGA-EXPRESS se réserve la possibilité de suspendre votre Compte, limiter vos accès aux Services ou résilier vos souscription aux présentes Conditions dans le cas où :"
                      "\n - (i) vous avez reçu au moins trois (3) avis mauvaises"
                      "\, -   (ii) la moyenne des avis que vous avez reçus est égale ou inférieure à deux sur cinq (2/5).",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "6. CONDITIONS FINANCIÈRES",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n L’accès et l’inscription à la Plateforme, de même que la recherche, la consultation et la publication d’Annonces sont gratuites. En revanche, tout achat et/ou toute Réservation effectuée sur la Plateforme pour les Trajets Réservés sont payants dans les conditions décrites ci-dessous.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "6.1. PARTICIPATION AUX FRET",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n Le montant de la Participation aux Fret est déterminé par vous, en tant que Voyageur, sous votre seule responsabilité. Il est strictement interdit de tirer le moindre bénéfice du fait de l’utilisation de notre Plateforme. Par conséquent, vous vous engagez à limiter le montant de la Participation que vous demandez à vos Expéditeurs aux frais que vous supportez réellement pour effectuer le Trajet. A défaut, vous supporterez seul les risques de requalification de l’opération effectuée par l’intermédiaire de la Plateforme."
                      "Lorsque vous publiez une Annonce, DGA-Express vous suggère un montant de Participation aux Frais qui tient compte notamment de la nature du Trajet, du moyen de transport et de la distance parcourue. Ce montant est purement indicatif et il vous appartient de le modifier à la hausse ou à la baisse pour tenir compte des frais que vous supportez réellement sur le Trajet. Afin d’éviter les abus, DGA-express  limite les seuils plafonds et planchers du montant de la Participation aux Frais respectivement entre 200 euros Pour un bagage de 23kg.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "6.2. FRAIS DE SERVICE",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n La Plateforme offre aux utilisateurs plusieurs moyens de paiement modernes pour le règlement des frais de service. Les utilisateurs ont ainsi la possibilité de régler par :"
                      "\n ●  Carte bancaire (Visa, Master card) ;"
                      "\n ●  PayPal ;"
                      "\n ●  Monnaie électronique fournie par les opérateurs de téléphonie mobile."
                      "\n Le paiement est réputé effectif aussitôt après validation du nombre de kilos ou du montant net à payer."
                      "Lors des transactions bancaires, les frais de virement relatifs à l’interconnexion des banques sont à la charge du client."
                      " Dans le cadre des Trajets avec Réservation, DGA-express prélève, en contrepartie de l’utilisation de la Plateforme, au moment de la Réservation, une commission correspondant à des frais de service  calculés sur la base du montant de la Participation aux Frais. Les modalités de calcul des Frais de Service en vigueur sont d’une part côté expéditeur 4,50 euros plus TVA, et d’autre part côté Voyageur : 13% de la Participation aux Frais demandé plus TVA."
                      "Les paiements par carte bancaire seront réceptionnés par Stripe, laquelle déduira le montant des Frais de Service avant de remettre le montant de la Participation aux Frais au Voyageur."
                      "Les Frais de Service sont perçus par DGA-EXPRESS  pour chaque Espace réservé par un Expéditeur."
                      "En ce qui concerne les trajets transfrontaliers, veuillez noter que les modalités de calcul du montant des Frais de Services et de la TVA applicable varient selon le point de départ et/ou d’arrivée du Trajet."
                      "Lorsque vous utilisez la Plateforme pour des Trajets transfrontaliers ou hors de la belgique , les Frais de Services peuvent être facturés par  DGA-express ",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "6.3. ARRONDIS",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n Vous reconnaissez et acceptez que dga-express  peut, à son entière discrétion, arrondir au chiffre inférieur ou supérieur les Frais de Service et la Participation aux Frais.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "6.4. RÈGLEMENT DES FRAIS DE VENTE AU PROFI DU VOYAGEUR",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n Le règlement des frais s’effectuera soixante-douze (72) heures après la confirmation de l’Expéditeur. Le Voyageur recevra son paiement via le modèle de paiement souscrit lors de son inscription sur la Plateforme. Le Voyageur recevra directement la somme réelle déduite du prélèvement automatique des frais de services de notre part."
                      "Il en est de meme pour les commercants de la rubrique E-commerce ",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "6.4.1. Règlement des frais de vente au profit du Voyageur",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n A la suite du Trajet, les Expéditeurs disposent d’un délai de quarante-huit (48) heures pour présenter une réclamation à dga-express. En l’absence de contestation de leur part dans cette période, DGA considère la confirmation du Trajet comme étant acquise (A compter de cette Confirmation de Réservation, vous disposez, en tant que Voyageur, d’un crédit exigible sur votre Compte. Ce crédit correspond au montant total payé par l’Expéditeur au moment de la Confirmation de Réservation diminué des Frais de Service, c’est-à-dire au montant de la Participation aux Frais payée par l’Expéditeur."
                      "Une fois le Bagage acheminé, le Voyageur doit ensuite procéder à la confirmation de livraison tacite ou expresse du Bagage, en remettant ledit Bagage au Destinataire. La confirmation de livraison peu egalement se fait dans les point de relais DGA-express si le voyageur y achemine les colis . La Confirmation de Livraison est dite tacite lorsque les Expéditeurs n’ont pas fait de réclamation dans les quarante-huit (48) heures suivant la réception du Bagage et express lorsque les Expéditeurs ont noté le Voyageur en indiquant que tout s’est bien passé."
                      "Une fois la Confirmation de Livraison validé , vous avez la possibilité, en tant que Voyageur, de Nous donner l’instruction soit de vous verser la Participation aux Frais reçue de l’Expéditeur sur votre compte bancaire (en renseignant sur votre Compte, au préalable, vos coordonnées bancaires), soit sur votre compte Paypal (en renseignant sur votre Compte, au préalable, votre adresse email Paypal) ou tout autre compte admettant des paiements électroniques."
                      "L’ordre de virement à votre nom sera transmis le premier jour ouvrable  suivant votre demande ou à défaut de demande de votre part, le premier jour ouvrable  suivant la mise à disposition sur votre profil des sommes concernées (sous réserve que DGA-EXPRESS dispose de vos informations bancaires)."
                      "A l’issue du délai de prescription de trois (3) ans applicable, toute somme non réclamée à DGA sera réputée appartenir à DGA-express.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "6.4.2. Mandat d'Encaissement",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n En utilisant la Plateforme en tant que Voyageur, vous Nous confiez un mandat d’encaissement du montant de la Participation aux Frais en votre nom et pour votre compte."
                      "Par conséquent, après acceptation manuelle ou automatique de la Réservation, DGA-express encaisse la totalité de la somme versée par l’Expéditeur (Frais de Service et Participation aux Frais)."
                      "Les Participations aux Frais reçues par DGA-EXPRESS sont déposées sur un compte dédié au paiement des Voyageurs."
                      "Vous reconnaissez et acceptez qu’aucune des sommes perçues par DGA-express au nom et pour le compte du Voyageur n’emporte droit à intérêts. Vous acceptez de répondre avec exigences à toute demande de dga-express  et plus généralement de toute autorité administrative ou judiciaire compétente en particulier en matière de prévention ou de lutte contre le blanchiment. Notamment, vous acceptez de fournir, sur simple demande, tout justificatif d’adresse et/ou d’identité utile."
                      "En l’absence de réponse de votre part à ces demandes, dga-express pourra prendre toute mesure qui lui semblera appropriée notamment le gel des sommes versées et/ou la suspension de votre Compte et/ou la résiliation de la souscription aux présentes Conditions.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "7. POLITIQUE D'ANNULATION",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue, fontWeight: FontWeight.bold)),
                  TextSpan(text: "\n 7.1. MODALITÉS DE REMBOURSEMENT EN CAS D'ANNULATION",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n Nos Trajets font l’objet de la présente politique d’annulation."
                      "DGA-express apprécie à sa seule discrétion, sur la base des éléments à sa disposition, la légitimité des demandes de remboursement qu’elle reçoit."
                      "En tout état de cause, en cas d’annulation Voyageur, dga-express vous proposera un autre Voyageur dont la date de départ est comprise entre 0 et 3 jours comparé à la date de départ initialement réservée. Dans ce cas aucune demande de remboursement ne sera acceptée."
                      "L’annulation d’un Espace d’un Trajet avec Réservation par le Voyageur ou l’Expéditeur après la Confirmation de Réservation est soumise aux stipulations ci-après :",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "7.1.1. Annulation Imputable au Voyageur",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n ●Si le Voyageur annule plus de quarante-huit (48) heures avant l’heure prévue pour le départ telle que mentionnée dans l’Annonce, l’Expéditeur est remboursé du montant intégral de la Participation aux Frais de Voyage et des Frais de Service afférents. Le Voyageur ne reçoit aucune somme de quelque nature que ce soit ;"
                      "\n ●  Si le Voyageur annule moins de quarante-huit (48) heures ou quarante-huit (48) heures avant l’heure prévue pour le départ, telle que mentionnée dans l’Annonce et plus de vingt-quatre (24) heures après la Confirmation de Réservation, l’Expéditeur est remboursé du montant intégral de la Participation aux Frais de Voyage et Frais de Service afférents ; le Voyageur ne reçoit aucune somme de quelque nature que ce soit, au contraire le Voyageur devra acquitter une pénalité correspondante aux Frais de Service qui seront imputés par DGA-EXPRESS sur son prochain Voyage ;"
                      "\n ●  Si le Voyageur annule moins de vingt-quatre (24) heures ou vingt-quatre (24) heures avant l’heure prévue pour le départ, telle que mentionnée dans l’Annonce et moins de trente (30) minutes après la Confirmation de Réservation, l’Expéditeur est remboursé du montant intégral de la Participation aux Frais de Voyage et des Frais de Service afférents. Le Voyageur ne reçoit aucune somme de quelque nature que ce soit ;"
                      "\n ●  Si le Voyageur annule moins de vingt-quatre (24) heures ou vingt-quatre (24) heures avant l’heure prévue pour le départ, telle que mentionnée dans l’Annonce et entre trente (30) et une (1) heure après la Confirmation de Réservation, l’Expéditeur est remboursé du montant intégral de la Participation aux Frais de Voyage et Frais de Service afférents ; le Voyageur ne reçoit aucune somme de quelque nature que ce soit, au contraire le Voyageur devra acquitter une pénalité correspondante aux Frais de Service qui seront imputés par DGA-EXPRESS sur son prochain Voyage ;"
                      "\n ●  Si le Voyageur annule moins de vingt-quatre (24) heures ou vingt-quatre (24) heures avant l’heure prévue pour le départ, telle que mentionnée dans l’Annonce et plus d’une (1) heure après la Confirmation de Réservation, ou s’il ne se présente pas au lieu de rendez-vous au plus tard dans un délai de trente (30) minutes à compter de l’heure convenue, l’Expéditeur est remboursé du montant intégral de la Participation aux Frais de Voyage et Frais de Service afférents ; Le Voyageur ne reçoit aucune somme de quelque nature que ce soit, au contraire le Voyageur devra acquitter une pénalité qui sera imputée sur son prochain transport ; la pénalité est composée d’une part des Frais de Service qui seront conservés par DGA-EXPRESS et d’autre part 15 euros (10€) de la Participation aux Frais dont la moitié (7,50€) sera reversée à l’Expéditeur.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "7.1.2. Annulation Imputable à l'Expéditeur",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n ●  Si le Voyageur annule plus de quarante-huit (48) heures avant l’heure prévue pour le départ telle que mentionnée dans l’Annonce, l’Expéditeur est remboursé du montant intégral de la Participation aux Frais de Voyage et des Frais de Service afférents. Le Voyageur ne reçoit aucune somme de quelque nature que ce soit ;"
                      " \n ●  Si le Voyageur annule moins de quarante-huit (48) heures ou quarante-huit (48) heures avant l’heure prévue pour le départ, telle que mentionnée dans l’Annonce et plus de vingt-quatre (24) heures après la Confirmation de Réservation, l’Expéditeur est remboursé du montant intégral de la Participation aux Frais de Voyage et Frais de Service afférents ; le Voyageur ne reçoit aucune somme de quelque nature que ce soit, au contraire le Voyageur devra acquitter une pénalité correspondante aux Frais de Service qui seront imputés par DGA-EXPRESS sur son prochain Voyage ;"
                      " \n ●  Si le Voyageur annule moins de vingt-quatre (24) heures ou vingt-quatre (24) heures avant l’heure prévue pour le départ, telle que mentionnée dans l’Annonce et moins de trente (30) minutes après la Confirmation de Réservation, l’Expéditeur est remboursé du montant intégral de la Participation aux Frais de Voyage et des Frais de Service afférents. Le Voyageur ne reçoit aucune somme de quelque nature que ce soit ;"
                      " \n ●  Si le Voyageur annule moins de vingt-quatre (24) heures ou vingt-quatre (24) heures avant l’heure prévue pour le départ, telle que mentionnée dans l’Annonce et entre trente (30) et une (1) heure après la Confirmation de Réservation, l’Expéditeur est remboursé du montant intégral de la Participation aux Frais de Voyage et Frais de Service afférents ; le Voyageur ne reçoit aucune somme de quelque nature que ce soit, au contraire le Voyageur devra acquitter une pénalité correspondante aux Frais de Service qui seront imputés par DGA-EXPRESS sur son prochain Voyage ;"
                      " \n ●  Si le Voyageur annule moins de vingt-quatre (24) heures ou vingt-quatre (24) heures avant l’heure prévue pour le départ, telle que mentionnée dans l’Annonce et plus d’une (1) heure après la Confirmation de Réservation, ou s’il ne se présente pas au lieu de rendez-vous au plus tard dans un délai de trente (30) minutes à compter de l’heure convenue, l’Expéditeur est remboursé du montant intégral de la Participation aux Frais de Voyage et Frais de Service afférents ; Le Voyageur ne reçoit aucune somme de quelque nature que ce soit, au contraire le Voyageur devra acquitter une pénalité qui sera imputée sur son prochain transport ; la pénalité est composée d’une part des Frais de Service qui seront conservés par DGA-EXPRESS et d’autre part 15 euros (10€) de la Participation aux Frais dont la moitié (7,50€) sera reversée à l’Expéditeur.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "7.1.2. Annulation Imputable à l'Expéditeur",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n ●  Si l’Expéditeur annule plus de quarante-huit (48) heures avant l’heure prévue pour le départ telle que mentionnée dans l’Annonce, l’Expéditeur est remboursé du montant intégral de la Participation aux Frais. Les Frais de Service demeurent acquis à DGA-EXPRESS et le Voyageur ne reçoit aucune somme de quelque nature que ce soit ;"
                      " \n ●  Si l’Expéditeur annule moins de quarante-huit (48) heures ou quarante-huit 48 heures avant l’heure prévue pour le départ, telle que mentionnée dans l’Annonce et plus de vingt-quatre (24) heures après la Confirmation de Réservation, l’Expéditeur est remboursé à hauteur de la moitié de la Participation aux Frais versée lors de la Réservation, les Frais de Service demeurent acquis à DGA-EXPRESS et le Voyageur reçoit la moitié (50%) de la Participation aux Frais ;"
                      " \n ●  Si l’Expéditeur annule moins de vingt-quatre (24) heures ou vingt-quatre (24) heures avant l’heure prévue pour le départ, comme mentionnée dans l’Annonce et moins de trente (30) minutes après la Confirmation de Réservation l’Expéditeur est remboursé de l’intégralité de la Participation aux Frais. Les Frais de Service demeurent acquis à DGA-Express et le Voyageur ne reçoit aucune somme de quelque nature que ce soit ;"
                      " \n ●  Si l’Expéditeur annule moins de vingt-quatre (24) heures ou vingt-quatre (24) heures avant l’heure prévue pour le départ, comme mentionnée dans l’Annonce et entre une (1) heure et deux (2) heures après la Confirmation de Réservation, l’Expéditeur est remboursé à hauteur de la moitié de la Participation aux Frais versée lors de la Réservation, les Frais de Service demeurent acquis à DGA-EXPRESS et le Voyageur reçoit la moitié (50%) de la Participation aux Frais ;"
                      " \n ●  Si l’Expéditeur annule moins de vingt-quatre (24) heures ou vingt-quatre (24) heures avant l’heure prévue pour le départ, telle que mentionnée dans l’Annonce et plus de deux (2) heure après la Confirmation de Réservation, ou s’il ne se présente pas au lieu de rendez-vous au plus tard dans un délai de quarante-cinq (45) minutes à compter de l’heure convenue, aucun remboursement n’est effectué. Le Voyageur est dédommagé de la Participation aux Frais et les Frais de Services sont conservés par DGA-EXPRESS."

                      "\n Lorsque l’annulation intervient à compter d’au moins trois (3) heures avant le départ et du fait de l’Expéditeur, le ou les Espaces annulés par l’Expéditeur sont de plein droit remis à la disposition d’autres Expéditeurs pouvant les réserver en ligne, lesquelles nouvelles Réservations seront soumises aux présentes Conditions.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "7.2. DROIT DE RÉTRACTION",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n En acceptant les présentes Conditions, vous acceptez expressément que la mise en relation avec un autre Membre soit exécutée avant l’expiration du délai de rétractation fixé à 2 heures après l’édition "
                      "de l’Annonce ou la Réservation du Trajet. Dès la Confirmation de la Réservation des Trajets, vous ne disposez de "
                      "la faculté de vous rétracter que dans les conditions énoncées ci-dessus à l’article 7.1 des présentes Conditions.",
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
                  TextSpan(text: " \n Vous reconnaissez être seul responsable du respect de l’ensemble des lois, règlements et obligations applicables à votre utilisation de la Plateforme."
                      "Par ailleurs, en utilisant la Plateforme et lors des Trajets, vous vous engagez à :"
                      "\n ●  Ne pas utiliser la Plateforme reserver aux annonces de voyages  à des fins professionnelles, commerciales ou lucratives ;"
                      "\n ●  Ne transmettre à DGA-express (notamment lors de la création ou la mise à jour de votre Compte) ou aux autres Membres aucune information erronée, trompeuse, mensongère ou frauduleuse ;"
                      "\n ●  Ne tenir aucun propos, n’avoir aucun comportement ou ne publier sur la Plateforme aucun contenu à caractère diffamatoire, injurieux, obscène, pornographique, vulgaire, offensant, agressif, déplacé, violent, menaçant, harcelant, raciste, xénophobe, à connotation sexuelle, incitant à la haine, à la violence, à la discrimination ou à la haine, encourageant les activités ou l’usage de substances illégales ou, plus généralement, contraires aux finalités de la Plateforme, de nature à porter atteinte aux droits de DGA-express  ou d’un tiers ou contraires aux bonnes mœurs ;"
                      "\n ●  Ne pas porter atteinte aux droits et à l’image de DGA-EXPRESS notamment à ses droits de propriété intellectuelle ;"
                      "\n ●  Ne pas ouvrir plus d’un Compte sur la Plateforme et ne pas ouvrir de Compte au nom d’un tiers ;"
                      "\n ●  Ne pas tenter de contourner le système de réservation en ligne de la Plateforme, notamment en tentant de communiquer à un autre Membre vos coordonnées afin de réaliser la réservation en dehors de la Plateforme et ne pas payer les Frais de Service ;"
                      "\n ●  Ne pas contacter un autre Membre, notamment par l’intermédiaire de la Plateforme, à une autre fin que celle de définir les modalités du partage de valises ;"
                      "\n ●  Ne pas accepter ou effectuer un paiement en dehors de la Plateforme ;"
                      "\n ●  Vous conformer aux présentes Conditions et à la Politique de Confidentialité.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "8.2. ENGAGEMENT DES VOYAGEURS",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n En outre, lorsque vous utilisez la Plateforme en tant que Voyageur, vous vous engagez à :"
                      "\n ●  Respecter l’ensemble des lois, règles, codes applicables au voyage, notamment à disposer d’une assurance responsabilité civile valide au moment du Trajet et être en possession d’un titre de transport en vigueur ;"
                      "\n ●  Vous assurez que votre assurance couvre la garde de la chose pour tiers et que les Bagages de vos Expéditeurs sont considérés comme tiers dans votre bagage et donc couverts par votre assurance ;"
                      "\n ●  Publier des Annonces correspondant uniquement à des trajets réellement envisagés ;"
                      "\n ●  Effectuer le Trajet tel que décrit dans l’Annonce (notamment en ce qui concerne la compagnie aérienne, la présence d’escale ou non) et respecter les horaires et lieux convenus avec les autres Membres (notamment lieu de collecte et de livraison) ;"
                      "\n ●  Ne pas prendre plus de Kg que le nombre indiqué dans l’Annonce ;"
                      "\n ●  Communiquer à DGA-express qui vous en fait la demande, votre billet d’avion, votre pièce d’identité, votre attestation d’assurance, votre VISA, votre passeport ainsi que tout document attestant de votre capacité à utiliser ce véhicule en tant que Voyageur sur la Plateforme ;"
                      "\n ●  En cas d’empêchement ou de changement de l’horaire ou du Trajet, en informer sans délai vos Expéditeurs ;"
                      "\n ●  En cas de Trajet transfrontalier, disposer et tenir à disposition de l’Expéditeur et de toute autorité qui le solliciterait tout document de nature à justifier de votre identité et de votre faculté à franchir la frontière ;"
                      "\n ●  Attendre les Expéditeurs sur le lieu de rencontre convenu au moins trente (30) minutes au-delà de l’heure convenue ( pour la belgique et le cameroun tous les colis seront colis seront recus au point relais DGA-express)"
                      "\n ●  Ne pas publier d’Annonce relative à un Trajet dont vous n’êtes pas le Voyageur ;"
                      "\n ●  Vous assurez d’être joignable par téléphone par vos Expéditeurs, au numéro enregistré sur votre profil ;"
                      "\n ●  Ne générer aucun bénéfice par l’intermédiaire de la Plateforme ;"
                      "\n ●  Garantir n’avoir aucune contre-indication ou incapacité médicale à voyager ;"
                      "\n ●  Avoir un comportement convenable et responsable, au cours de la collecte et livraison des colis/courriers.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "8.3. ENGAGEMENT DES EXPÉDITEURS",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n Lorsque vous utilisez la Plateforme en tant qu’Expéditeur, vous vous engagez à :"
                      "\n ●  Adopter un comportement convenable et responsable au cours de la remise des Bagages au Voyageur et leur collecte par le Destinataire ;"
                      "\n ●  En cas d’empêchement, en informer sans délai le Voyageur ;"
                      "\n ●  Attendre le Voyageur sur le lieu de rencontre convenu au moins 15 minutes au-delà de l’heure convenue ;"
                      "\n ●  ommuniquer à DGA-express ou tout Voyageur qui vous en fait la demande, votre carte d’identité ou tout document de nature à attester de votre identité ;"
                      "\n ●  N’expédier, dans l’Espace réservé, aucun objet, marchandise, substance, animal dont le transport est contraire aux règles, codes, lois et dispositions légales en vigueur au sein des pays de départ, d’arrivée et éventuellement d’escale ;"
                      "\n ●  En cas de Trajet transfrontalier, disposer et tenir à disposition du Voyageur et de toute autorité qui le solliciterait tout document de nature à justifier de votre identité et de votre faculté à franchir la frontière ;"
                      "\n ●  Vous assurez d’être joignable par téléphone par le Voyageur, au numéro enregistré sur votre profil et notamment au point de rendez-vous."

                      "\n Dans le cas où vous auriez procédé à la Réservation d’un ou plusieurs Espaces pour le compte de tiers, vous vous portez fort du respect de celle-ci par ce tiers. DGA-express se réserve la possibilité de suspendre votre Compte, limiter votre accès aux Services ou résilier la souscription aux présentes Conditions, en cas de manquement de la part du tiers pour le compte duquel vous avez réservé un Espace aux présentes Conditions.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "9. SUSPENSION DE COMPTES, LIMITATIONS D'ACCÈS ET RÉSILIATION",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n Vous avez la possibilité de mettre fin à votre relation contractuelle avec Nous à tout moment, sans frais et sans motif. Pour cela, il vous suffit de vous rendre dans l’onglet « Fermeture de compte » de votre page Profil."
                      "En cas de non-respect de votre part de tout ou partie des Conditions, vous reconnaissez et acceptez que DGA-express peut à tout moment, sans notification préalable, interrompre ou suspendre, de manière temporaire ou définitive, tout ou partie du Service ou l’accès des Membres à la Plateforme (y compris notamment le Compte Utilisateur) ou pour toute raison objective."
                      "Lorsque cela est nécessaire, vous serez notifié de la mise en place d’une telle mesure afin de vous permettre de donner des explications à DGA-express. Nous déciderons, à Notre seule discrétion, de lever les mesures mises en place ou non.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "10. DONNÉES PERSONNELLES",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n Dans le cadre de votre utilisation de la Plateforme, Nous pouvons être amenés à collecter et traiter certaines de vos données personnelles. En utilisant la Plateforme et en vous y inscrivant en tant que Membre, vous reconnaissez et acceptez le traitement de vos données personnelles par DGA-express conformément à la loi applicable et aux stipulations de la politique de confidentialité de DGA-express.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "11. PROPRIÉTÉ INTELLECTUELLE",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue, fontWeight: FontWeight.bold)),
                  TextSpan(text: "\n 11.1. CONTENU PUBLIÉ PAR DGA-EXPRESS",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n Sous réserve des contenus fournis par ses Membres, dga-express  est seule titulaire de l’ensemble des droits de propriété intellectuelle afférents au Service, à la Plateforme, à son contenu (notamment les textes, images, dessins, logos, vidéos, sons, données, graphiques) ainsi qu’aux logiciels et bases de données assurant leur fonctionnement."
                      "Nous vous accordons une licence non exclusive, personnelle et non cessible d’utilisation de la Plateforme et des Services, pour votre usage personnel et privé, à titre non commercial et conformément aux finalités de la Plateforme et des Services."
                      "Vous vous interdisez toute autre utilisation ou exploitation de la Plateforme et des Services, et de leur contenu sans l’autorisation préalable écrite de DGA-express. Notamment, vous vous interdisez de :"
                      "\n ●  Reproduire, modifier, adapter, distribuer, représenter publiquement, diffuser la Plateforme, les Services et leur contenu, à l’exception de ce qui est expressément autorisé par DGA-EXPRESS ;"
                      "\n ●  Décompiler, procéder à de l’ingénierie inverse de la Plateforme ou des Services, sous réserve des exceptions prévues par les textes en vigueur ;"
                      "\n ●  Extraire ou tenter d’extraire (notamment en utilisant des robots d’aspiration de données ou tout autre outil similaire de collecte de données) une partie substantielle des données de la Plateforme.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "11.2. CONTENU PUBLIÉ PAR VOUS SUR LA PLATEFORME",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n Afin de permettre la fourniture des Services et conformément à la finalité de la Plateforme, vous concédez à DGA-express une licence non exclusive d’utilisation des contenus et données que vous fournissez dans le cadre de votre utilisation des Services . Afin de permettre la diffusion par réseau numérique et selon tout protocole de communication (notamment Internet et réseau mobile), ainsi que la mise à disposition au public du contenu de la Plateforme, vous autorisez DGA-EXPRESS, pour le monde entier et pour toute la durée de votre relation contractuelle avec DGA-express à reproduire, représenter, adapter et traduire votre Contenu Membre de la façon suivante :"
                      "\n ●  Vous autorisez DGA-expresss à reproduire tout ou partie de votre Contenu Membre sur tout support d’enregistrement numérique, connu ou inconnu à ce jour, et notamment sur tout serveur, disque dur, carte mémoire, ou tout autre support équivalent, en tout format et par tout procédé connu et inconnu à ce jour, dans la mesure nécessaire à toute opération de stockage, sauvegarde, transmission ou téléchargement lié au fonctionnement de la Plateforme et à la fourniture du Service ;"
                      "\n ●  Vous autorisez DGA-express à adapter et traduire votre Contenu Membre, ainsi qu’à reproduire ces adaptations sur tout support numérique, actuel ou futur, stipulé au (i) ci-dessus, dans le but de fournir les Services, notamment en différentes langues. Ce droit comprend notamment la faculté de réaliser, dans le respect de votre droit moral, des modifications de la mise en forme de votre Contenu Membre aux fins de respecter la charte graphique de la Plateforme et/ou de rendre ledit Contenu techniquement compatible en vue de sa publication via la Plateforme.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "12. NOTRE RÔLE",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n La Plateforme constitue une plateforme en ligne de mise en relation sur laquelle les Membres peuvent créer et publier des Annonces pour des Trajets à des fins de transport de colis/courriers pour tiers d’une part et d’autre part l’option E-commerce. Ces Annonces peuvent notamment être consultées par les autres Membres pour prendre connaissance des modalités du Trajet et, le cas échéant, réserver directement un Espace sur le Trajet concerné auprès du Membre ayant posté l’annonce sur la Plateforme."
                      "En utilisant la Plateforme et en acceptant les présentes Conditions, vous reconnaissez que DGA-express n’est partie à aucun accord conclu entre vous et les autres Membres en vue de partager les frais afférents à un Trajet."
                      "En outre, il est expressément établi que nous n’avons aucun contrôle sur le comportement des Membres et des utilisateurs de la Plateforme. Nous ne possédons pas, n’exploitons pas, ne fournissons pas, ne gérons pas les moyens de transport objets des Annonces, ni ne proposons le moindre Trajet sur la Plateforme."
                      "Vous reconnaissez et acceptez que DGA-EXPRESS ne contrôle ni la validité, ni la véracité, ni la légalité des Annonces, des Espaces et Trajets proposés. En sa qualité d’intermédiaire en transport de Bagages, DGA-EXPRESS ne fournit aucun service de transport et n’agit pas en qualité de transporteur, Notre rôle ne se limitant qu’à faciliter l’accès à des Membres via la Plateforme pour le transport de leurs Bagages entre Expéditeurs et Vendeurs."
                      "Les Membres (Voyageurs ou Expéditeurs) agissent sous leur seule et entière responsabilité."
                      "En sa qualité d’intermédiaire, DGA-EXPRESS ne saurait voir sa responsabilité engagée au titre du déroulement effectif d’un Trajet, et notamment du fait :"
                      "\n ●  D’informations erronées communiquées par le Voyageur, dans son Annonce, ou par tout autre moyen, quant au Trajet et à ses modalités ;"
                      "\n ●  L’annulation ou la modification d’un Trajet par un Membre ;"
                      "\n ●  Le comportement de ses Membres pendant, avant, ou après le Trajet.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "13. NAVIGATION OU UTILISATION DE LA PLATEFORME",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n Nous nous efforcerons, dans la mesure du possible, de maintenir la Plateforme accessible sept (7) jours sur sept (7) et vingt-quatre (24) heures sur vingt-quatre (24) partout dans le monde au moyen d’une connexion internet avec des mises à jour des informations les plus récentes. Pour continuer sa navigation de manière fluide et avoir l’accès facile à l’information publiée sur la Plateforme, le Membre se doit de faire les choix ci-dessous : Langue de navigation, - Mode de transport : Avion, Autres ;1- Avion : Pour les colis, les plis et les bagages accompagnés, etc… Le nombre de Kg libres pour le cas des Bagages accompagnés ou expédiés par avion. 2- Train :volume d’espace libre pour le transport des Bagages. - Pays, villes de destination ; - Dates de départs et d’arrivées ; - Aéroports ou gares de départs et d’arrivées ; - Compagnie aérienne ; - Compagnie ferroviaire."
                      "Néanmoins, l’accès à la Plateforme pourra être temporairement suspendu, sans préavis, en raison d’opérations techniques de maintenance, de migration, de mises à jour ou en raison de pannes ou de contraintes liées au fonctionnement des réseaux."
                      "En outre, DGA-EXPRESS se réserve le droit de modifier ou d’interrompre, à sa seule discrétion, de manière temporaire ou permanente, tout ou partie de l’accès à la Plateforme ou à ses fonctionnalités.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "14. DROIT APPLICABLE - LITIGE",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \n Les présentes Conditions sont rédigées en français et soumises à la loi et réglementation française."
                      "Vous pouvez également présenter, vos réclamations relatives à notre Plateforme ou à nos Services, sur la plateforme de résolution des litiges mise en ligne par la Commission Européenne accessible ici. La Commission Européenne se chargera de transmettre votre réclamation aux médiateurs nationaux compétents. Conformément aux règles applicables à la médiation, vous êtes tenus, avant toute demande de médiation, d’avoir fait préalablement part par écrit à DGA-EXPRESS de tout litige afin d’obtenir une solution à la miable.",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                ],

              ),
            ),

            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "15.MENTIONS LÉGALES",
                      style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                  TextSpan(text: " \nDGA-express ",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.blue, fontWeight: FontWeight.bold)),
                  TextSpan(text: " est une entreprise à personne physique immatriculée au registre de"
                      "commerce RC/DLA/2022/A/1496/ACE/APME/CFCE DU 22/07/2022 basée au"
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
