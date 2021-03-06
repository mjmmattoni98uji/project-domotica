import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:frontendCliente/f_dispositivos/dispositivos/view/dispositivos_asignados_page.dart';
import 'package:frontendCliente/f_habitaciones/habitaciones/listado_habitaciones.dart';
import 'package:room_repository/room_repository.dart';
import 'package:frontendCliente/Widgets/menu_widget.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ListaHabitacionesLogic extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _ListaHabitacionesLogicState();
  }
}

class _ListaHabitacionesLogicState extends State<ListaHabitacionesLogic>{
  bool showBottomMenu = false;
  TextEditingController controladorNombre = TextEditingController();
  final FirebaseMessaging _fcm = FirebaseMessaging();
  // String idHabitacion = "";

  @override
  void dispose(){
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    _fcm.configure(
      //app in the foreground
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: ListTile(
              title: Text(message['notification']['title']),
              subtitle: Text(message['notification']['body']),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Ok'),
                onPressed: () {
                  // setState((){
                  //   idHabitacion = message['data']['idHabitacion'];
                  //   listadoInicial(context);
                  //   Navigator.of(context).pop();
                  // });
                  // listadoInicial(context);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
      //
      // onBackgroundMessage: myBackgroundMessageHandler,
      //app in the background
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        // setState(() {
        //   idHabitacion = message['data']['idHabitacion'];
        // });
        // listadoInicial(context);
      },
      //app terminated
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        // setState(() {
        //   idHabitacion = message['data']['idHabitacion'];
        // });
        // listadoInicial(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    const int threshold = 50;

    return BlocListener<HabitacionBloc, HabitacionState>(
        listener: (context, state){
          if(state is ErrorHabitacionExistente){
            Scaffold.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(state.mensaje)),
              );
          }else if(state is HabitacionSinNombre){
            Scaffold.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text("Escriba un nombre a la habitación")),
              );
          } else if(state is HabitacionConDispositivos){
            createConfirmDialog(context, state.habitacion);
          }
        },
      child: GestureDetector(
        onPanEnd: (details){
          if(details.velocity.pixelsPerSecond.dy > threshold){
            this.setState(() {
              showBottomMenu = false;
            });
          }
          else if(details.velocity.pixelsPerSecond.dy < -threshold){
            this.setState(() {
              showBottomMenu = true;
            });
          }
        },
        child: Stack(
          children: <Widget>[
            BlocBuilder<HabitacionBloc, HabitacionState>(
                builder: (context, state){
                  if(state is HabitacionCargando){
                    return buildCargando();
                  }else if(state is HabitacionesActuales){
                    return buildListado(context, state.habitaciones);
                  }else if(state is HabitacionesInitial){
                    context.bloc<HabitacionBloc>().add(HabitacionesStarted());
                  }else if(state is HabitacionModificada){
                    listadoInicial(context);
                  }else if(state is ListaError){
                    return Center(
                        child: Text("No existe ninguna habitación actualmente",
                          style: TextStyle(
                            fontFamily: "Raleway"
                          ),
                          textAlign: TextAlign.center,
                        ),
                    );
                  }else if(state is HabitacionAnadida){
                    context.bloc<HabitacionBloc>().add(HabitacionesStarted());
                  }else if(state is HabitacionConDispositivos){
                    context.bloc<HabitacionBloc>().add(HabitacionesStarted());
                  }else if(state is HabitacionEliminada){
                    context.bloc<HabitacionBloc>().add(HabitacionesStarted());
                  }else if(state is HabitacionSinNombre){
                    context.bloc<HabitacionBloc>().add(HabitacionesStarted());
                  }else if(state is ErrorHabitacionExistente) {
                    context.bloc<HabitacionBloc>().add(HabitacionesStarted());
                  }
                  return buildCargando();
                }
            ),
            AnimatedPositioned(
              curve: Curves.fastLinearToSlowEaseIn,
              duration: Duration(milliseconds: 800),
              child: MenuWidget(
                callback: (String nombre){
                  anadirHabitacion(context, nombre);
                },
              ),
              left: 0.0,
              bottom: (showBottomMenu) ? 0 : -(height/3),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCargando(){
    return Center(child: CircularProgressIndicator());
  }

  Widget buildListado(BuildContext context, List<Room> habitaciones){
    return Column(
      children: [
        Flexible(
          child: ListView.builder(
              addAutomaticKeepAlives: true,
              physics: BouncingScrollPhysics( parent: AlwaysScrollableScrollPhysics() ),
              itemCount: habitaciones.length,
              itemBuilder: (_, int index) {
                return Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Container(
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      elevation: 5,
                      child: InkWell(
                        child: FocusedMenuHolder(
                          blurBackgroundColor: Colors.white38,
                          blurSize: 2.0,
                          animateMenuItems: true,
                          onPressed: (){
                            Navigator.push(
                                context,
                                MaterialPageRoute<void>(builder: (context) => DispositivosAsignadosPage(habitaciones[index]))
                            );
                            // Navigator.of(context).push<void>(DispositivosAsignadosPage.route(habitaciones[index]));
                          },
                          menuItems: <FocusedMenuItem>[
                            FocusedMenuItem(
                                title: Text("Cambiar nombre",
                                  style: TextStyle(fontFamily: "Raleway"),
                                ),
                                onPressed: (){
                                  createAlertDialog(context, habitaciones[index], controladorNombre);
                                },
                                trailingIcon: Icon(Icons.update),
                            ),
                            FocusedMenuItem(
                                title: Text("Eliminar",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "Raleway",
                                  ),
                                ),
                                onPressed: (){
                                  eliminarHabitacion(context, habitaciones[index], false);
                                },
                                trailingIcon: Icon(Icons.delete),
                                backgroundColor: Colors.redAccent,
                            ),
                          ],
                          child: ListTile(
                            title: Text(habitaciones[index].nombre,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20.0,
                                  fontFamily: "Raleway"
                              ),
                            ),
                            tileColor: habitaciones[index].activo ? Colors.red : Colors.white,
                          ),
                        ),
                        onTap: (){},
                      ),
                    ),
                  ),
                );
              }
          ),
        ),
      ],
    );
  }

  void listadoInicial(BuildContext context){
    context.bloc<HabitacionBloc>().add(ActualizarListarHabitaciones());
  }

  void modificarHabitacion(BuildContext context, Room habitacion){
    context.bloc<HabitacionBloc>().add(CambiarNombreHabitacion(habitacion, controladorNombre.text));
  }

  void anadirHabitacion(BuildContext context, String habitacion){
    context.bloc<HabitacionBloc>().add(AnadirHabitacion(habitacion));
  }

  void eliminarHabitacion(BuildContext context, Room habitacion, bool confirmacion){
    context.bloc<HabitacionBloc>().add(EliminarHabitacion(habitacion, confirmacion));
  }

  createConfirmDialog(BuildContext context, Room habitacion){
    return showDialog(
      context: context,
        builder: (_){
          return AlertDialog(
            elevation: 10.0,
            title: Text("¿Estas seguro de que quieres eliminar la habitación?",
              style: TextStyle(fontFamily: "Raleway"),
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              MaterialButton(
                elevation: 10.0,
                child: Text("Confirmar",
                  style: TextStyle(fontFamily: "Raleway"),
                ),
                onPressed: (){
                  eliminarHabitacion(context, habitacion, true);
                  Navigator.pop(context);
                },
              ),
              MaterialButton(
                elevation: 10.0,
                child: Text("Cancelar",
                  style: TextStyle(fontFamily: "Raleway"),
                ),
                onPressed: (){
                  Navigator.pop(context);
                },
              )
            ],
          );
      }
    );
  }

  createAlertDialog(BuildContext context, Room habitacion, TextEditingController controller){
    return showDialog(context: context, builder: (_){
      return AlertDialog(
        elevation: 10.0,
        title: Text("Nuevo nombre para esta habitación",
          style: TextStyle(fontFamily: "Raleway"),
          textAlign: TextAlign.center,
        ),
        content: TextField(
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: "Raleway",
          ),
          controller: controller,
        ),
        actions: <Widget>[
          MaterialButton(
            elevation: 10.0,
            child: Text("Cambiar",
              style: TextStyle(fontFamily: "Raleway"),
            ),
            onPressed: (){
              modificarHabitacion(context, habitacion);
              controller.clear();
              Navigator.pop(context);
            },
          )
        ],
      );
    });
  }
}